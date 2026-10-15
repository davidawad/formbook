-- ca11.lua: pandoc filter for the ca11 reply-brief LaTeX template (latex/template.tex; engine "latex").
-- It does what typst/ca11-reply-brief.typ does in Lua, and leaves every printed form, font and spacing
-- choice to template.tex:
--   * heading labels and the table-of-contents entry of each heading (typst: heading-label, toc-entry); inside
--     the Argument the labels are I. / A. / 1. / a., elsewhere A. / 1. / a. / (1);
--   * the table of citations: which authorities are cited, their groups and their order; the page numbers are
--     collected by LaTeX from the \catoahit links in the body, a `toa-primary:` link marks a primary citation
--     (typst: toa-section);
--   * the word count of the body and the limit of FRAP 32(a)(7)(B)(ii) (typst: count-words);
--   * the keep-with-signature flag.

local LIMIT = 6500   -- FRAP 32(a)(7)(B)(ii): a reply brief is half the principal limit
local TOC_DEPTH = 2  -- heading levels listed in the table of contents (typst: toc-depth)

local stringify = pandoc.utils.stringify

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Inline content as LaTeX (pandoc does the escaping).
local function latex_of(inlines)
  return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "latex"))
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- Label of a numbered heading (typst heading-label). The Argument has its own scheme.
local function label(level, n, in_arg)
  if in_arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    return string.char(96 + n) .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

-- Table-of-contents entry styles, one per indent of half an inch (template.tex: \l@caTzero ...).
local STEP_NAMES = { "caTzero", "caTone", "caTtwo", "caTthree", "caTfour", "caTfive" }

-- Words of the markdown source, counted as the typst template counts them (count-words).
local function count_words(md)
  local s = "\n" .. md
  s = s:gsub("<!%-%-.-%-%->", " ")
  s = s:gsub("\n%[%^[^%]]*%]:", "\n ")
  s = s:gsub("%[%^[^%]]*%]", "")
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[%-%*%+][ \t]+", "\n")
  s = s:gsub("\n[ \t]*%d+[%.%)][ \t]+", "\n")
  s = s:gsub("\\(.)", "%1")
  s = s:gsub("%*", "")
  s = s:gsub("([%s%(%[\"])_", "%1")
  s = s:gsub("_([%s%.,;:%)%]\"!%?])", "%1")
  local n = 0
  for _ in s:gmatch("%S+") do
    n = n + 1
  end
  return n
end

-- 6500 -> "6,500"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local AUTH_GROUPS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "regulation", "Regulations" },
  { "rule", "Rules" },
  { "other", "Other Authorities" },
}

-- The markdown body the pandoc run was given, the frontmatter stripped (typst: split-frontmatter).
local function source_body()
  local path = PANDOC_STATE.input_files[1]
  local f = assert(io.open(path, "r"))
  local src = f:read("a")
  f:close()
  local pos = src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n()")
  if not pos then error("ca11.lua: the sample must start with a YAML frontmatter block") end
  return src:sub(pos)
end

-- Every toa: and toa-primary: link becomes \catoahit{key}{primary}{text}.
local used = {}
local function link_filter(el)
  local key = el.target:match("^toa%-primary:(.+)$")
  local primary = key ~= nil
  if key == nil then key = el.target:match("^toa:(.+)$") end
  if key == nil then return nil end
  used[key] = true
  local out = { pandoc.RawInline("latex", "\\catoahit{" .. key .. "}{" .. (primary and "1" or "0") .. "}{") }
  for _, i in ipairs(el.content) do
    out[#out + 1] = i
  end
  out[#out + 1] = pandoc.RawInline("latex", "}")
  return out
end

local function toa_section(authorities)
  for key in pairs(used) do
    if authorities == nil or authorities[key] == nil then
      error("ca11.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  local lines = {}
  for _, g in ipairs(AUTH_GROUPS) do
    local members = {}
    for key, a in pairs(authorities or {}) do
      if a.kind and stringify(a.kind) == g[1] and used[key] then
        local base = a.sort and stringify(a.sort) or ((a.name and stringify(a.name) or "") .. " " .. stringify(a.cite))
        members[#members + 1] = { key = key, a = a, sort = base:lower():gsub("[^a-z0-9 ]", "") }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      lines[#lines + 1] = "\\catoagroup{" .. g[2] .. "}{" .. (#lines == 0 and 1 or 0) .. "}"
      for _, m in ipairs(members) do
        local name = ""
        if m.a.name then
          name = latex_of(m.a.name)
          if g[1] == "case" then name = "\\emph{" .. name .. "}" end
        end
        lines[#lines + 1] = "\\catoarow{" .. name .. "}{" .. latex_of(m.a.cite) .. "}{" .. m.key .. "}"
      end
    end
  end
  return table.concat(lines, "\n")
end

-- Heading output (typst: style-heading, toc-entry). Each step of the hang is half an inch (label-indent is
-- (level - 1) half inches). Each macro of template.tex makes its own table-of-contents entry after the page-break
-- check, so the entry carries the page the heading really lands on.
local function heading_latex(level, content, in_arg, counts)
  local text = latex_of(content)
  if level == 1 then
    return "\\caHone{" .. text .. "}"
  end
  local lab = label(level, counts[level], in_arg)
  local k = level - 1
  local name, entry = "", ""
  if level <= TOC_DEPTH then
    name = STEP_NAMES[k + 1]
    entry = "\\calab{" .. lab .. "}{" .. text .. "}"
  end
  local styled = level >= 4 and "{\\bfseries\\itshape " .. text .. "}" or "{\\bfseries " .. text .. "}"
  return "\\casub{" .. string.format("%.1f", k * 0.5) .. "in}{{\\bfseries " .. lab .. "}}{" .. styled .. "}{" .. name .. "}{" .. entry .. "}"
end

function Pandoc(doc)
  local words = count_words(source_body())
  if words > LIMIT then
    error("ca11.lua: the reply brief has " .. words .. " words; FRAP 32(a)(7)(B)(ii) allows " .. LIMIT)
  end
  doc = doc:walk({ Link = link_filter })

  local in_arg = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local level = b.level
      if level > 5 then error("ca11.lua: headings deeper than level 5 are not supported") end
      counts[level] = counts[level] + 1
      for k = level + 1, 6 do counts[k] = 0 end
      if level == 1 then in_arg = trim(stringify(b.content)):lower():sub(1, 8) == "argument" end
      body[#body + 1] = pandoc.RawBlock("latex", heading_latex(level, b.content, in_arg, counts))
    else
      body[#body + 1] = b
    end
  end

  -- The signature stays with the last paragraph (typst: the tail block is kept together with the signature).
  local last = body[#body]
  if last and last.t ~= "Header" then
    table.insert(body, #body, pandoc.RawBlock("latex", "\\begin{samepage}"))
    doc.meta.keep = "1"
  end

  -- The telephone number closes the last counsel group (typst: the last group carries the number).
  local counsel = doc.meta.counsel
  if counsel and #counsel > 0 then counsel[#counsel].phone = doc.meta.phone end

  doc.meta.words = group_digits(words)
  doc.meta.limit = group_digits(LIMIT)
  doc.meta.toa = pandoc.MetaBlocks({ pandoc.RawBlock("latex", toa_section(doc.meta.authorities)) })
  doc.blocks = body
  return doc
end

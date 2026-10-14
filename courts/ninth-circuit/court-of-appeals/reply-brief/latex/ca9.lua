-- ca9.lua: pandoc filter for the ca9 LaTeX template (latex/template.tex; engine "latex").
-- It does what the typst template does in Lua, and leaves every printed form, font and spacing
-- choice to template.tex:
--   * heading labels (I., A., 1., a. in the Argument; A., 1., a., (1) elsewhere) and the table-of-contents
--     entry of each heading (typst: ca9-reply-brief.typ, heading-label and toc-entry);
--   * the table of authorities: which authorities are cited, their groups and their order; the page numbers
--     are collected by LaTeX from the links (\catoahit) in the body;
--   * the word count of the body, counted from the markdown source the way the typst template counts it,
--     and the Circuit Rule limit;
--   * the Addendum split, the keep-with-signature flag and the flags that tick the form boxes.
local LIMIT = 7000   -- Cir. R. 32-1(b): a reply brief may not exceed half of 14,000 words
local TOC_DEPTH = 4  -- heading levels listed in the table of contents

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

-- Indent of a heading's label, in half inches (typst label-indent; the centered Argument point is 0).
local function steps(level, in_arg)
  local first = in_arg and 3 or 2
  return level - first + 1
end

-- Table-of-contents entry styles, one per indent of half an inch (template.tex: \l@caTzero ...).
local STEP_NAMES = { "caTzero", "caTone", "caTtwo", "caTthree", "caTfour", "caTfive" }
local function step_name(k)
  return STEP_NAMES[k + 1]
end

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

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local AUTH_GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

-- The body of the markdown source the pandoc run was given: the frontmatter is stripped and
-- everything from the Addendum heading on is cut off (typst: split-frontmatter, then count-words).
local function counted_source()
  local path = PANDOC_STATE.input_files[1]
  local f = assert(io.open(path, "r"))
  local src = f:read("a")
  f:close()
  local pos = src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n()")
  if not pos then error("ca9.lua: the sample must start with a YAML frontmatter block") end
  local padded = "\n" .. src:sub(pos)
  local cut = padded:lower():find("\n#[ \t]+addendum[ \t]*\n")
  if cut then return padded:sub(2, cut) end
  return padded:sub(2)
end

-- Every toa: link becomes \catoahit{key}{text}; the key is remembered for the table of authorities.
local used = {}
local function link_filter(el)
  if el.target:sub(1, 4) ~= "toa:" then return nil end
  local key = el.target:sub(5)
  used[key] = true
  local out = { pandoc.RawInline("latex", "\\catoahit{" .. key .. "}{") }
  for _, i in ipairs(el.content) do
    out[#out + 1] = i
  end
  out[#out + 1] = pandoc.RawInline("latex", "}")
  return out
end

local function toa_section(authorities)
  for key in pairs(used) do
    if authorities == nil or authorities[key] == nil then
      error("ca9.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  local lines = {}
  for gi, g in ipairs(AUTH_GROUPS) do
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

-- Word count, the limit, and the flags of the certificates.
local function certificates(doc, words)
  local meta = doc.meta
  if words > LIMIT then
    error("ca9.lua: the brief has " .. words .. " words; Circuit Rule 32-1(b) allows " .. LIMIT)
  end
  meta.words = group_digits(words)
  local basis = meta.word_limit_basis and stringify(meta.word_limit_basis) or "standard"
  meta["wl_" .. basis] = "x"
  if basis:sub(1, 6) == "longer" then meta.wl_longer = "x" end
  if meta.related_cases then
    local status = meta.related_cases.status and stringify(meta.related_cases.status) or "none"
    meta["rc_" .. (status == "other-briefs" and "other" or status)] = "x"
  end
  if meta.counsel then
    local last = #meta.counsel
    for i, g in ipairs(meta.counsel) do
      if g.phone == nil and i == last then g.phone = meta.phone end
    end
  end
end

local function addendum_split(blocks)
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 and trim(stringify(b.content)):lower() == "addendum" then
      local main, add = {}, {}
      for j = 1, i - 1 do main[#main + 1] = blocks[j] end
      for j = i + 1, #blocks do add[#add + 1] = blocks[j] end
      return main, add
    end
  end
  return blocks, nil
end

-- Numbered headings (body) and unnumbered ones (addendum); the table-of-contents entry is written
-- next to the heading so the entry carries the heading's own page.
-- Heading output. Each macro of template.tex makes its own table-of-contents entry after the page-break check,
-- so the entry carries the page the heading really lands on. #1 of caSub etc. are the TOC style and entry.
local function heading_latex(level, content, in_arg, counts, numbered)
  local text = latex_of(content)
  if level == 1 then
    return "\\caHone{" .. text .. "}"
  end
  if not numbered then
    -- Unnumbered (Addendum) headings: bold, flush left; listed in the addendum's table when level 2.
    local name = level <= 2 and step_name(level - 2) or ""
    return "\\caunnum{" .. text .. "}{" .. name .. "}{" .. text .. "}"
  end
  local lab = label(level, counts[level], in_arg)
  local k = steps(level, in_arg)
  if in_arg and level == 2 then k = 0 end
  local name, entry = "", ""
  if level <= TOC_DEPTH then
    name = step_name(k)
    entry = "\\calab{" .. lab .. "}{" .. text .. "}"
  end
  if in_arg and level == 2 then
    return "\\capoint{" .. lab .. "}{" .. text .. "}{" .. name .. "}{" .. entry .. "}"
  end
  local styled_lab = level >= 4 and "{\\bfseries\\itshape " .. lab .. "}" or "{\\bfseries " .. lab .. "}"
  local styled = level >= 4 and "{\\bfseries\\itshape " .. text .. "}" or "{\\bfseries " .. text .. "}"
  return "\\casub{" .. (k * 0.5) .. "in}{" .. styled_lab .. "}{" .. styled .. "}{" .. name .. "}{" .. entry .. "}"
end

function Pandoc(doc)
  local words = count_words(counted_source())
  doc = doc:walk({ Link = link_filter })
  local main_blocks, add_blocks = addendum_split(doc.blocks)

  local in_arg = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local body = {}
  for _, b in ipairs(main_blocks) do
    if b.t == "Header" then
      local level = b.level
      if level > 5 then error("ca9.lua: headings deeper than level 5 are not supported") end
      counts[level] = counts[level] + 1
      for k = level + 1, 6 do counts[k] = 0 end
      if level == 1 then in_arg = trim(stringify(b.content)):lower() == "argument" end
      body[#body + 1] = pandoc.RawBlock("latex", heading_latex(level, b.content, in_arg, counts, true))
    else
      body[#body + 1] = b
    end
  end

  -- The signature stays with the last paragraph (typst: keep the tail block with the signature block).
  local last = body[#body]
  if last and last.t ~= "Header" then
    table.insert(body, #body, pandoc.RawBlock("latex", "\\begin{samepage}"))
    doc.meta.keep = "1"
  end

  local add = {}
  if add_blocks then
    local counts_add = { 0, 0, 0, 0, 0, 0 }
    for _, b in ipairs(add_blocks) do
      if b.t == "Header" then
        add[#add + 1] = pandoc.RawBlock("latex", heading_latex(b.level, b.content, false, counts_add, false))
      else
        add[#add + 1] = b
      end
    end
    doc.meta.addendum = pandoc.MetaBlocks(add)
  end

  doc.meta.toa = pandoc.MetaBlocks({ pandoc.RawBlock("latex", toa_section(doc.meta.authorities)) })
  certificates(doc, words)
  doc.blocks = body
  return doc
end

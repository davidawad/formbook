-- ca11.lua: pandoc filter for the ca11 answering-brief LaTeX template (latex/template.tex; engine "latex").
-- It does what typst/ca11-answering-brief.typ does in Lua, and leaves every printed form, font and spacing
-- choice to template.tex:
--   * heading labels (I., A., 1., a. at every level) and the table-of-contents entry of each heading
--     (typst: heading-label, toc-entry);
--   * the table of citations: which authorities are cited, their groups and their order; the page numbers are
--     collected by LaTeX from the \catoahit links in the body (typst: toa-section);
--   * the word count of the body and the limit of its basis (typst: count-words, word-limits);
--   * the Addendum: split off the body, its headings listed in its own table (typst: toc-addendum);
--   * the keep-with-signature flag.

local TOC_DEPTH = 4  -- heading levels listed in the table of contents (typst: toc-depth)
local WORD_LIMITS = { standard = 13000, ["cross-appeal"] = 15300 }  -- FRAP 32(a)(7)(B)(i); FRAP 28.1(e)(2)(A)(ii)

local stringify = pandoc.utils.stringify
-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe = require("latex.xengine")

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Inline content as LaTeX (pandoc does the escaping).
local function latex_of(inlines)
  return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(xe.inlines(pandoc.Inlines(inlines))) }), "latex"))
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

-- Label of a numbered heading (typst heading-label): I. / A. / 1. / a. at every level.
local function label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return n .. "." end
  return string.char(96 + n) .. "."
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

-- 13000 -> "13,000"
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

-- Every toa: link keeps its text, with \catoahit{key}{0} right after its first word (typst: tag-after-first-word,
-- so a citation that runs over a page end is listed at the page where it starts); this brief marks no primary
-- citations.
local function mark_first(inlines, mark)
  local out, done = pandoc.Inlines({}), false
  for _, el in ipairs(inlines) do
    if not done and el.t == "Str" then
      out:insert(el)
      out:insert(mark)
      done = true
    elseif not done and el.t ~= "Note" and el.content ~= nil and type(el.content) == "table" then
      local inner, d = mark_first(el.content, mark)
      el.content = inner
      out:insert(el)
      done = d
    else
      out:insert(el)
    end
  end
  return out, done
end
local used = {}
local function link_filter(el)
  local key = el.target:match("^toa:(.+)$")
  if key == nil then return nil end
  used[key] = true
  local mark = pandoc.RawInline("latex", "\\catoahit{" .. key .. "}{0}")
  local out, done = mark_first(el.content, mark)
  if not done then out:insert(1, mark) end
  return out
end

-- The cover's counsel (typst: cover-body): one group from the middle of the page; two or more side by side, up to
-- three a row, in columns of (text width - gutters) / n, 14 bp (1 em) apart, rows 11.2 bp apart. Each group: the
-- names, then the lines (the telephone closes the last group) 0.5 em in, wrapped lines 1 em in; 3.5 bp between them.
local function counsel_tex(groups, phone)
  local function group(gi, g)
    local out = {}
    for _, n in ipairs(g.names or {}) do out[#out + 1] = "\\noindent " .. latex_of(n) .. "\\par" end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = phone end
    for _, l in ipairs(lines) do
      out[#out + 1] = "\\noindent\\hangindent=14bp\\hangafter=1\\relax\\hspace*{7bp}\\emph{" .. latex_of(l) .. "}\\par"
    end
    return "\\casingle\\parskip=3.5bp\\relax\\parindent=0pt\\relax\n" .. table.concat(out, "\n")
  end
  if #groups == 1 then
    return "{\\raggedright\\leftskip=0.5\\textwidth\n" .. group(1, groups[1]) .. "\n}"
  end
  local cols = math.min(#groups, 3)
  local w = "\\dimexpr(\\textwidth-" .. (14 * (cols - 1)) .. "bp)/" .. cols .. "\\relax"
  local rows = {}
  for r = 1, #groups, cols do
    local cells = {}
    for gi = r, math.min(r + cols - 1, #groups) do
      cells[#cells + 1] = "\\begin{minipage}[t]{" .. w .. "}" .. group(gi, groups[gi]) .. "\\end{minipage}"
    end
    rows[#rows + 1] = (r > 1 and "\\par\\addvspace{11.2bp}" or "") .. "\\carow{" .. table.concat(cells, "\\hspace{14bp minus 1bp}") .. "}"
  end
  return table.concat(rows, "\n")
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

-- Heading output (typst: style-heading, toc-entry). Level 1 is a centered section; the others hang under their
-- label, each step half an inch further in (label-indent = (level - 2) half inches). Each macro of template.tex
-- makes its own table-of-contents entry after the page-break check, so the entry carries the page it lands on.
local function heading_latex(level, content, counts)
  local text = latex_of(content)
  if level == 1 then
    return "\\caHone{" .. text .. "}"
  end
  local lab = label(level, counts[level])
  local k = level - 2
  local name, entry = "", ""
  if level <= TOC_DEPTH then
    name = STEP_NAMES[k + 1]
    entry = "\\calab{" .. lab .. "}{" .. text .. "}"
  end
  local styled_lab = "{\\bfseries " .. lab .. "}"
  local styled = level >= 4 and "{\\bfseries\\itshape " .. text .. "}" or "{\\bfseries " .. text .. "}"
  return "\\casub{" .. string.format("%.1f", k * 0.5) .. "in}{" .. styled_lab .. "}{" .. styled .. "}{" .. name .. "}{" .. entry .. "}"
end

-- The addendum's headings are unnumbered: level 1 centered (as in the body), level 2 and deeper bold, flush left,
-- and only level 2 is listed in the addendum's table (typst: toc-addendum, depth 2).
local function addendum_heading(level, content)
  local text = latex_of(content)
  if level == 1 then
    return "\\caunnumhone{" .. text .. "}"
  end
  local name = level == 2 and "caTzero" or "\\relax"
  return "\\caunnum{" .. text .. "}{" .. name .. "}{" .. text .. "}"
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

local function render_blocks(blocks, heading_fn)
  local out = {}
  local counts = { 0, 0, 0, 0, 0, 0 }
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = b.level
      if level > 5 then error("ca11.lua: headings deeper than level 5 are not supported") end
      counts[level] = counts[level] + 1
      for k = level + 1, 6 do counts[k] = 0 end
      out[#out + 1] = pandoc.RawBlock("latex", heading_fn(level, b.content, counts))
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local limit = WORD_LIMITS[doc.meta.word_limit_basis and stringify(doc.meta.word_limit_basis) or "standard"]
  if limit == nil then error("ca11.lua: unknown word_limit_basis") end
  local words = count_words(source_body())
  if words > limit then
    error("ca11.lua: the brief has " .. words .. " words; FRAP 32(a)(7)(B) allows " .. limit)
  end
  doc = doc:walk({ Link = link_filter })
  -- the break rules of typst on the body and on every metadata value the template prints
  doc = doc:walk({ Inlines = xe.inlines })
  doc.meta = pandoc.Pandoc({}, doc.meta):walk({ Inlines = xe.inlines }).meta

  local main_blocks, add_blocks = addendum_split(doc.blocks)
  local body = render_blocks(main_blocks, heading_latex)

  -- The signature stays with the last paragraph (typst: the tail block is kept together with the signature).
  -- (A paragraph with a footnote is not boxed: a footnote inside a \vbox would not reach the page.)
  local last = body[#body]
  local has_note = false
  if last then pandoc.Pandoc({ last }):walk({ Note = function() has_note = true end }) end
  if last and last.t ~= "Header" and not has_note then
    table.insert(body, #body, pandoc.RawBlock("latex", "\\cakeepbegin"))
    doc.meta.keep = "1"
  end

  if add_blocks then
    local add = render_blocks(add_blocks, function(level, content)
      return addendum_heading(level, content)
    end)
    doc.meta.addendum = pandoc.MetaBlocks(add)
  end

  if stringify(doc.meta.word_limit_basis or "standard") == "cross-appeal" then doc.meta.cross = "1" end
  -- The phone line closes the last counsel group (typst: the last group carries the telephone number).
  -- Two or more counsel groups sit side by side across the full width (typst: up to three per row).
  doc.meta.counsel_tex = pandoc.MetaBlocks({ pandoc.RawBlock("latex", counsel_tex(doc.meta.counsel or {}, doc.meta.phone)) })
  doc.meta.words = group_digits(words)
  doc.meta.limit = group_digits(limit)
  doc.meta.toa = pandoc.MetaBlocks({ pandoc.RawBlock("latex", toa_section(doc.meta.authorities)) })
  doc.blocks = body
  return doc
end

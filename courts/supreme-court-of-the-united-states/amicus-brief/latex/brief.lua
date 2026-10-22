-- Supreme Court of the United States: amicus curiae brief (booklet format), LaTeX engine.
-- Mirrors typst/scotus-amicus-brief-amicus-brief.typ: cover (Rule 34.1), roman front matter (TOC, TOA),
-- arabic body, signature block (Rule 34.3), certificate of compliance (Rule 33.1(h)).
-- All text comes from the sample's YAML frontmatter and body; nothing is case-specific.

-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): lib/latex/xengine.lua gives the body and every
-- metadata value typst's break opportunities; template.tex sets the spaces and line boxes.
local xe = require("latex.xengine")
-- TeX Gyre Schola at the vendored 2.609 advances (lib/latex/xeschola.lua), after the break rules
local xs = require("latex.xeschola")
-- A line may end after a slash before a letter, as typst and Word break a web address (Unicode line breaking).
local function slash_breaks(inlines)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "Str" and el.text:find("/%a") then
      local rest = el.text
      while true do
        local s = rest:find("/%a")
        if not s then break end
        out:insert(pandoc.Str(rest:sub(1, s)))
        out:insert(pandoc.RawInline("latex", "\\allowbreak{}"))
        rest = rest:sub(s + 1)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end
local function xinl(l) return slash_breaks(xe.inlines(l)) end
local meta = nil
local word_limits = { government = 9000, other = 8000 }
local passim_threshold = 6
local auth_list = {}      -- ordered authorities, each with its citation labels in document order
local ncite = 0
local counters = { 0, 0, 0, 0, 0, 0 }
local toc = {}
local words = 0

-- Inline markdown in a metadata value -> LaTeX. Strings, inline lists and block lists are accepted.
local function tex(v)
  if v == nil then return "" end
  local t = pandoc.utils.type(v)
  local blocks
  if t == "string" then
    blocks = pandoc.read(v, "markdown").blocks
  elseif t == "Inlines" then
    blocks = { pandoc.Plain(v) }
  elseif t == "Blocks" then
    -- a value that reads as a list item ("(202) 787-1060") is a line of text, its marker as written (typst)
    blocks = {}
    for _, b in ipairs(v) do
      if b.t == "OrderedList" and #b.content == 1 and #b.content[1] == 1 then
        local a, n = b.listAttributes, tostring(b.listAttributes.start)
        local lab = a.delimiter == "TwoParens" and ("(" .. n .. ")") or a.delimiter == "OneParen" and (n .. ")") or (n .. ".")
        local il = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
        il:extend(b.content[1][1].content)
        blocks[#blocks + 1] = pandoc.Plain(il)
      else
        blocks[#blocks + 1] = b
      end
    end
  else
    blocks = { pandoc.Plain(pandoc.utils.stringify(v)) }
  end
  local s = pandoc.write(pandoc.Pandoc(blocks):walk({ Inlines = xinl }):walk(xs.filter), "latex")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(key)
  if meta[key] == nil then error("brief.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- Authority citations: the body's occurrences of each authority's `match` string get an invisible
-- label on their page (\toacite), as the typst template does with its show rule.
-- The label goes after the top-level inline that holds the match end, so emphasis is not split.
local function mark(inlines)
  local ends, S = {}, ""
  for i, el in ipairs(inlines) do
    S = S .. pandoc.utils.stringify(el)
    ends[i] = #S
  end
  local marks = {}
  for _, a in ipairs(auth_list) do
    if a.match ~= "" then
      local init = 1
      while true do
        local s, e = S:find(a.match, init, true)
        if not s then break end
        local k
        for i = 1, #ends do
          if ends[i] >= e then k = i; break end
        end
        ncite = ncite + 1
        local lab = "toa" .. ncite
        a.labels[#a.labels + 1] = lab
        marks[k] = marks[k] or {}
        marks[k][#marks[k] + 1] = lab
        init = e + 1
      end
    end
  end
  local out = {}
  for i, el in ipairs(inlines) do
    out[#out + 1] = el
    for _, lab in ipairs(marks[i] or {}) do
      out[#out + 1] = pandoc.RawInline("latex", "\\toacite{" .. lab .. "}")
    end
  end
  return out
end

-- Front matter ----------------------------------------------------------------------------------

-- Front matter ----------------------------------------------------------------------------------

-- The cover (typst: cover): one centred line or paragraph per part, the counsel at the foot of the page.
local function cover()
  local out = {}
  local function add(s) out[#out + 1] = s end
  local function line(above, s) add("\\scotusline{" .. above .. "}{" .. s .. "}") end
  add("\\thispagestyle{empty}")
  add("\\scotusleft{0}{No. " .. tex(need("case_number")) .. "}")
  line(20, "In the")
  line(0, "\\textbf{SUPREME COURT OF THE UNITED STATES}")
  for i, side in ipairs(need("caption")) do
    if i > 1 then line(6, "v.") end
    for j, n in ipairs(side.names) do line(j > 1 and 0 or (i == 1 and 14 or 6), tex(n)) end
    line(0, tex(side.designation))
  end
  line(14, tex(need("proceeding")))
  line(14, "\\textbf{\\MakeUppercase{" .. tex(need("brief_title")) .. "}}")
  add("\\par\\vfill")
  for i, g in ipairs(need("counsel")) do
    for j, n in ipairs(g.names) do line((i > 1 and j == 1) and 12 or 0, tex(n)) end
    if g.role then line(0, "\\emph{" .. tex(g.role) .. "}") end
    for _, l in ipairs(g.lines) do line(0, tex(l)) end
    if i == 1 then line(0, tex(need("phone"))) end
  end
  line(12, "\\emph{" .. tex(need("counsel_role")) .. "}")
  line(12, tex(need("date")))
  add("\\clearpage")
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function toc_block()
  local out = { "\\pagenumbering{roman}\\setcounter{page}{1}", "\\scotustitle{TABLE OF CONTENTS}" }
  for _, h in ipairs(toc) do
    if h.level <= 3 then
      if h.level == 1 then
        out[#out + 1] = "\\tocsection{" .. h.title .. "}{\\pageref{" .. h.tag .. "}}"
      else
        out[#out + 1] = "\\tocpoint{" .. string.format("%.1f", (h.level - 2) * 0.4) .. "in}{" .. h.label .. "}{"
          .. h.title .. "}{\\pageref{" .. h.tag .. "}}"
      end
    end
  end
  out[#out + 1] = "\\clearpage"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function toa_block()
  local out = { "\\scotustitle{TABLE OF AUTHORITIES}" }
  local sections = {
    { "Cases", "case" }, { "Statutes", "statute" }, { "Regulations", "regulation" }, { "Other Authorities", "other" },
  }
  for _, sec in ipairs(sections) do
    local items = {}
    for _, a in ipairs(auth_list) do
      if a.kind == sec[2] then
        if #a.labels == 0 then error("brief.lua: authority `" .. a.key .. "` is listed but not cited in the body") end
        items[#items + 1] = a
      end
    end
    if #items > 0 then
      table.sort(items, function(x, y) return x.sortkey < y.sortkey end)
      out[#out + 1] = "\\toaheading{" .. sec[1] .. "}"
      for _, a in ipairs(items) do
        out[#out + 1] = "\\toaline{" .. a.entry .. "}{\\toapages{" .. table.concat(a.labels, ",") .. "}}"
      end
    end
  end
  out[#out + 1] = "\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

-- The signer's name in bold capitals, the lines, and the date 8 bp below them (typst: signer-lines).
local function signer_lines()
  local sig = need("signature")
  local out = { "\\scotusleft{0}{\\textbf{\\MakeUppercase{" .. tex(sig.signer) .. "}}}" }
  for _, l in ipairs(sig.lines) do out[#out + 1] = "\\scotusleft{0}{" .. tex(l) .. "}" end
  out[#out + 1] = "\\scotusleft{8}{" .. tex(need("date")) .. "}"
  return table.concat(out, "\n")
end

-- typst: signature-block: 14 bp above, not split across pages.
local function signature_block()
  return pandoc.RawBlock("latex", "\\par\\addvspace{14bp}\\vbox{\\scotusleft{0}{Respectfully submitted,}\n"
    .. "\\addvspace{20bp}" .. signer_lines() .. "}")
end

local function certificate()
  local limit = (pandoc.utils.stringify(need("amicus_class")) == "government") and word_limits.government or word_limits.other
  local kind = (pandoc.utils.stringify(need("amicus_class")) == "government")
      and "an amicus curiae identified in Rule 37.6" or "any other amicus curiae"
  local out = {
    "\\clearpage\\thispagestyle{empty}",
    "\\scotustitle{CERTIFICATE OF COMPLIANCE}",
    "\\scotusleft{12}{" .. tex("Pursuant to Rule 33.1(h), I certify that the attached brief complies with the word "
      .. "limitation of Rule 33.1(g). It contains " .. group_digits(words) .. " words, excluding the items listed in "
      .. "Rule 33.1(d). The limit for " .. kind .. " is " .. group_digits(limit) .. " words.") .. "}",
    "\\par\\addvspace{12bp}\\vbox{" .. signer_lines() .. "}",
  }
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
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
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

-- The body of the markdown source the pandoc run was given: the frontmatter is stripped (typst: split-frontmatter).
local function counted_source()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local pos = src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n()")
  if not pos then error("brief.lua: the sample must start with a YAML frontmatter block") end
  return src:sub(pos)
end

-- Body ------------------------------------------------------------------------------------------

local function heading(h)
  local lvl = h.level
  counters[lvl] = counters[lvl] + 1
  for i = lvl + 1, #counters do counters[i] = 0 end
  local n = counters[lvl]
  local label
  if lvl == 1 then label = nil
  elseif lvl == 2 then label = roman(n):upper() .. "."
  elseif lvl == 3 then label = string.char(64 + n) .. "."
  elseif lvl == 4 then label = tostring(n) .. "."
  elseif lvl == 5 then label = string.char(96 + n) .. "."
  else error("brief.lua: headings deeper than level 5 are not supported") end
  local inl = mark(h.content)
  local t = tex(pandoc.Inlines(inl))
  local tag = "toc" .. (#toc + 1)
  toc[#toc + 1] = { level = lvl, label = label, title = t, tag = tag }
  if lvl == 1 then
    return pandoc.RawBlock("latex", "\\scotussection{" .. t .. "}{\\label{" .. tag .. "}}")
  end
  return pandoc.RawBlock("latex", "\\scotuspoint{" .. string.format("%.1f", (lvl - 2) * 0.4) .. "in}{" .. label .. "}{"
    .. t .. "}{\\label{" .. tag .. "}}")
end

local function prepare_authorities()
  local keys = {}
  for k in pairs(meta.authorities or {}) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local a = meta.authorities[k]
    local name = tex(a.name or "")
    local cite = (a.cite and pandoc.utils.stringify(a.cite) ~= "") and tex(a.cite) or ""
    local entry = cite == "" and name or (name .. ", " .. cite)
    auth_list[#auth_list + 1] = {
      key = k,
      kind = pandoc.utils.stringify(a.kind),
      match = a.match and pandoc.utils.stringify(a.match) or "",
      entry = entry,
      sortkey = pandoc.utils.stringify(a.name or ""):gsub("[%*“”\"]", ""):lower(),
      labels = {},
    }
  end
end

function Pandoc(doc)
  meta = doc.meta
  prepare_authorities()
  words = count_words(counted_source())
  local limit = (pandoc.utils.stringify(need("amicus_class")) == "government") and word_limits.government or word_limits.other
  if words > limit then error("brief.lua: the body has " .. words .. " words; Rule 33.1(g) allows " .. limit) end

  local body = doc:walk({
    Para = function(p) return pandoc.Para(mark(p.content)) end,
    Plain = function(p) return pandoc.Plain(mark(p.content)) end,
    Header = function(h) return heading(h) end,
  })
  -- the break rules of typst on the body text (headings were set by tex() above)
  body = body:walk({ Inlines = xinl }):walk(xs.filter)
  local blocks = { cover(), toc_block(), toa_block() }
  local prev = nil
  for _, b in ipairs(body.blocks) do
    -- one em between two paragraphs of the body; next to a heading, the heading's own space
    if prev and prev.t == "Para" and b.t == "Para" then blocks[#blocks + 1] = pandoc.RawBlock("latex", "\\scotuspar") end
    blocks[#blocks + 1] = b
    prev = b
  end
  blocks[#blocks + 1] = signature_block()
  if pandoc.utils.stringify(meta.certificate or "") == "true" then blocks[#blocks + 1] = certificate() end
  return pandoc.Pandoc(blocks, doc.meta)
end

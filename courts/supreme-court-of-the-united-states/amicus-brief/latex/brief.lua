-- Supreme Court of the United States: amicus curiae brief (booklet format), LaTeX engine.
-- Mirrors typst/scotus-amicus-brief-amicus-brief.typ: cover (Rule 34.1), roman front matter (TOC, TOA),
-- arabic body, signature block (Rule 34.3), certificate of compliance (Rule 33.1(h)).
-- All text comes from the sample's YAML frontmatter and body; nothing is case-specific.

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
    blocks = v
  else
    blocks = { pandoc.Plain(pandoc.utils.stringify(v)) }
  end
  local s = pandoc.write(pandoc.Pandoc(blocks), "latex")
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

local function cover()
  local out = {}
  local function add(s) out[#out + 1] = s end
  add("\\begingroup\\setlength{\\parskip}{0pt}\\thispagestyle{empty}")
  add("\\noindent No. " .. tex(need("case_number")) .. "\\par")
  add("\\vspace{0.25in}")
  add("\\begin{center}")
  add("In the\\par\\vspace{0.35em}")
  add("\\textbf{SUPREME COURT OF THE UNITED STATES}\\par")
  add("\\vspace{0.2in}")
  for i, side in ipairs(need("caption")) do
    if i > 1 then add("\\vspace{0.6em}v.\\vspace{0.6em}\\par") end
    for _, n in ipairs(side.names) do add(tex(n) .. "\\par") end
    add(tex(side.designation) .. "\\par")
  end
  add("\\vspace{0.2in}")
  add(tex(need("proceeding")) .. "\\par")
  add("\\vspace{0.2in}")
  add("\\textbf{\\MakeUppercase{" .. tex(need("brief_title")) .. "}}\\par")
  add("\\end{center}")
  add("\\vfill")
  add("\\begin{center}")
  for i, g in ipairs(need("counsel")) do
    for _, n in ipairs(g.names) do add(tex(n) .. "\\par") end
    if g.role then add("\\emph{" .. tex(g.role) .. "}\\par") end
    for _, l in ipairs(g.lines) do add(tex(l) .. "\\par") end
    if i == 1 then add(tex(need("phone")) .. "\\par") end
    add("\\vspace{0.6em}")
  end
  add("\\emph{" .. tex(need("counsel_role")) .. "}\\par")
  add("\\vspace{0.9em}")
  add(tex(need("date")) .. "\\par")
  add("\\end{center}\\endgroup")
  add("\\newpage")
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function toc_block()
  local out = { "\\begingroup\\setlength{\\parskip}{0pt}\\pagenumbering{roman}\\setcounter{page}{1}", "\\begin{center}\\textbf{TABLE OF CONTENTS}\\end{center}\\vspace{1em}" }
  for _, h in ipairs(toc) do
    if h.level == 1 then
      out[#out + 1] = "\\tocsection{" .. h.title .. "}{\\pageref{" .. h.tag .. "}}"
    else
      out[#out + 1] = "\\tocpoint{" .. ((h.level - 2) * 0.4) .. "in}{" .. h.label .. "}{" .. h.title .. "}{\\pageref{" .. h.tag .. "}}"
    end
  end
  out[#out + 1] = "\\endgroup\\newpage"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function toa_block()
  local out = { "\\begingroup\\setlength{\\parskip}{0pt}\\begin{center}\\textbf{TABLE OF AUTHORITIES}\\end{center}\\vspace{1em}" }
  local sections = {
    { "Cases", "case" }, { "Statutes", "statute" }, { "Regulations", "regulation" }, { "Other Authorities", "other" },
  }
  for _, sec in ipairs(sections) do
    local items = {}
    for _, a in ipairs(auth_list) do
      if a.kind == sec[2] and #a.labels > 0 then items[#items + 1] = a end
    end
    if #items > 0 then
      table.sort(items, function(x, y) return x.sortkey < y.sortkey end)
      out[#out + 1] = "\\toaheading{" .. sec[1] .. "}"
      for _, a in ipairs(items) do
        out[#out + 1] = "\\toaline{" .. a.entry .. "}{\\toapages{" .. table.concat(a.labels, ",") .. "}}"
      end
    end
  end
  out[#out + 1] = "\\endgroup\\newpage\\pagenumbering{arabic}\\setcounter{page}{1}"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function signature_block()
  local sig = need("signature")
  local out = { "\\par\\vspace{1.2em}\\noindent\\needspace{12\\baselineskip}Respectfully submitted,\\par\\vspace{1.6em}" }
  out[#out + 1] = "\\textbf{\\MakeUppercase{" .. tex(sig.signer) .. "}}\\par"
  for _, l in ipairs(sig.lines) do out[#out + 1] = tex(l) .. "\\par" end
  out[#out + 1] = "\\vspace{0.6em}" .. tex(need("date")) .. "\\par"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function certificate()
  local limit = (pandoc.utils.stringify(need("amicus_class")) == "government") and word_limits.government or word_limits.other
  local kind = (pandoc.utils.stringify(need("amicus_class")) == "government")
      and "an amicus curiae identified in Rule 37.6" or "any other amicus curiae"
  local sig = need("signature")
  local out = {
    "\\newpage\\thispagestyle{empty}",
    "\\begin{center}\\textbf{CERTIFICATE OF COMPLIANCE}\\end{center}\\vspace{1.2em}",
    "Pursuant to Rule 33.1(h), I certify that the attached brief complies with the word limitation of Rule 33.1(g). It contains "
      .. group_digits(words) .. " words, excluding the items listed in Rule 33.1(d). The limit for " .. kind .. " is "
      .. group_digits(limit) .. " words.\\par\\vspace{1.2em}",
    "\\noindent\\textbf{\\MakeUppercase{" .. tex(sig.signer) .. "}}\\par",
  }
  for _, l in ipairs(sig.lines) do out[#out + 1] = tex(l) .. "\\par" end
  out[#out + 1] = "\\vspace{0.6em}" .. tex(need("date")) .. "\\par"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

-- Word count of the body, whitespace-delimited like a word processor (Rule 33.1(d)); footnote text counts.
local function count_words(s)
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
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
  local title = t
  if lvl == 1 then
    toc[#toc + 1] = { level = 1, title = title, tag = tag }
    return pandoc.RawBlock("latex", "\\scotussection{" .. title .. "}\\label{" .. tag .. "}")
  end
  toc[#toc + 1] = { level = lvl, label = label, title = title, tag = tag }
  return pandoc.RawBlock("latex", "\\scotuspoint{" .. ((lvl - 2) * 0.4) .. "in}{" .. label .. "}{" .. title .. "}\\label{" .. tag .. "}")
end

local function prepare_authorities()
  local keys = {}
  for k in pairs(meta.authorities or {}) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local a = meta.authorities[k]
    local name = tex(a.name or "")
    local cite = a.cite and tex(a.cite) or ""
    local entry = cite == "" and name or (name .. " " .. cite)
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
  -- count the body before any markup is changed
  words = 0
  for _, b in ipairs(doc.blocks) do words = words + count_words(pandoc.utils.stringify(b)) end

  local body = doc:walk({
    Para = function(p) return pandoc.Para(mark(p.content)) end,
    Plain = function(p) return pandoc.Plain(mark(p.content)) end,
    Header = function(h) return heading(h) end,
  })
  local blocks = { cover(), toc_block(), toa_block() }
  for _, b in ipairs(body.blocks) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = signature_block()
  if pandoc.utils.stringify(meta.certificate or "") == "true" then blocks[#blocks + 1] = certificate() end
  return pandoc.Pandoc(blocks, doc.meta)
end

-- Supreme Court of the United States: brief on the merits (booklet format), LaTeX engine.
-- Mirrors typst/merits-brief.typ: cover (Rule 34.1), questions presented and parties pages, roman front
-- matter (TOC, TOA), arabic body, signature block (Rule 34.3), certificate of word count (Rule 33.1(h)).
-- Authority citations are tagged in the markdown as links to toa:<key>; each tag gets a label on its page.

local meta = nil
local word_limit = 13000
local auth_list = {}
local auth_by_key = {}
local ncite = 0
local counters = { 0, 0, 0, 0, 0, 0 }
local toc = {}
local words = 0

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
  return out:upper()
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- Citation tags: a link to toa:<key> in the body becomes its text followed by a label on its page.
local function cite_link(el)
  local target = el.target
  if target:sub(1, 4) ~= "toa:" then return nil end
  local key = target:sub(5)
  local a = auth_by_key[key]
  if a == nil then error("brief.lua: citation tag toa:" .. key .. " has no authority in the frontmatter") end
  ncite = ncite + 1
  local lab = "toa" .. ncite
  a.labels[#a.labels + 1] = lab
  local out = { table.unpack(el.content) }
  out[#out + 1] = pandoc.RawInline("latex", "\\toacite{" .. lab .. "}")
  return out
end

local function cover()
  local out = {}
  local function add(s) out[#out + 1] = s end
  add("\\begingroup\\setlength{\\parskip}{0pt}\\thispagestyle{empty}")
  add("\\noindent " .. tex(need("docket")) .. "\\par")
  add("\\vspace{0.3in}")
  add("\\begin{center}")
  add("\\textbf{IN THE}\\par\\vspace{0.3em}")
  add("\\textbf{SUPREME COURT OF THE UNITED STATES}\\par")
  add("\\vspace{0.3in}")
  for _, c in ipairs(need("caption")) do add(tex(c) .. "\\par") end
  add("\\vspace{0.3in}")
  add(tex(need("proceeding")) .. "\\par")
  add("\\vspace{0.3in}")
  add("\\textbf{\\MakeUppercase{" .. tex(need("brief_title")) .. "}}\\par")
  add("\\end{center}")
  add("\\vfill")
  add("\\begin{center}\\fontsize{10pt}{12pt}\\selectfont")
  for _, g in ipairs(need("counsel")) do
    for _, n in ipairs(g.names) do add(tex(n) .. "\\par") end
    for _, l in ipairs(g.lines) do add(tex(l) .. "\\par") end
    add("\\vspace{0.6em}")
  end
  add("\\vspace{0.6em}" .. tex(need("date")) .. "\\par")
  add("\\end{center}\\endgroup")
  add("\\newpage")
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

-- Questions presented and parties: front pages after the cover (Rules 14.1(a), 14.1(b)).
local function front_pages()
  local out = { "\\begingroup\\setlength{\\parskip}{0pt}\\begin{center}\\textbf{QUESTION PRESENTED}\\end{center}\\vspace{1em}" }
  for _, q in ipairs(need("questions")) do out[#out + 1] = tex(q) .. "\\par" end
  out[#out + 1] = "\\endgroup\\newpage"
  out[#out + 1] = "\\begingroup\\setlength{\\parskip}{0pt}\\begin{center}\\textbf{PARTIES TO THE PROCEEDINGS}\\end{center}\\vspace{1em}"
  out[#out + 1] = tex(need("parties")) .. "\\par\\vspace{1.4em}"
  out[#out + 1] = "\\begin{center}\\textbf{CORPORATE DISCLOSURE STATEMENT}\\end{center}\\vspace{1em}"
  out[#out + 1] = tex(need("disclosure")) .. "\\par"
  out[#out + 1] = "\\endgroup\\newpage"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function toc_block()
  local out = { "\\begingroup\\setlength{\\parskip}{0pt}\\pagenumbering{roman}\\setcounter{page}{1}",
    "\\begin{center}\\textbf{TABLE OF CONTENTS}\\end{center}\\vspace{1em}" }
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
  local sections = { { "Cases", "case" }, { "Rules", "rule" }, { "Statutes", "statute" }, { "Other Authorities", "other" } }
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
  local sig = need("signature")
  local out = {
    "\\newpage\\thispagestyle{empty}",
    "\\begin{center}\\textbf{Certificate of Compliance}\\end{center}\\vspace{1.2em}",
    "I certify that this brief complies with the word limit of Supreme Court Rule 33.1(g). It contains "
      .. group_digits(words) .. " words, excluding the items listed in Rule 33.1(d). The limit for a brief on the merits for a petitioner or appellant is "
      .. group_digits(word_limit) .. " words.\\par\\vspace{1.2em}",
    "\\noindent\\textbf{\\MakeUppercase{" .. tex(sig.signer) .. "}}\\par",
  }
  for _, l in ipairs(sig.lines) do out[#out + 1] = tex(l) .. "\\par" end
  out[#out + 1] = "\\vspace{0.6em}" .. tex(need("date")) .. "\\par"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function heading(h)
  local lvl = h.level
  counters[lvl] = counters[lvl] + 1
  for i = lvl + 1, #counters do counters[i] = 0 end
  local label = ""  -- the sample writes its own numerals in the heading text
  if lvl > 5 then error("brief.lua: headings deeper than level 5 are not supported") end
  local title = tex(pandoc.Inlines(h.content))
  local tag = "toc" .. (#toc + 1)
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
    local rec = {
      key = k,
      kind = pandoc.utils.stringify(a.kind),
      entry = entry,
      sortkey = pandoc.utils.stringify(a.name or a.cite or ""):gsub("[%*“”\"]", ""):lower(),
      labels = {},
    }
    auth_list[#auth_list + 1] = rec
    auth_by_key[k] = rec
  end
end

function Pandoc(doc)
  meta = doc.meta
  prepare_authorities()
  words = 0
  for _, b in ipairs(doc.blocks) do words = words + select(2, pandoc.utils.stringify(b):gsub("%S+", "")) end
  local body = doc:walk({
    Link = function(el) return cite_link(el) end,
    Header = function(h) return heading(h) end,
  })
  local blocks = { cover(), front_pages(), toc_block(), toa_block() }
  for _, b in ipairs(body.blocks) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = signature_block()
  blocks[#blocks + 1] = certificate()
  return pandoc.Pandoc(blocks, doc.meta)
end

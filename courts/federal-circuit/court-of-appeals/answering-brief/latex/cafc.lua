-- cafc.lua: pandoc Lua filter for the LaTeX engine of the Federal Circuit answering brief (template.tex).
-- Builds the cover, the representative-claim page, the table of contents, the table of authorities, the statement
-- of related cases, the signature block and the certificates from the YAML frontmatter (the same fields as
-- ../typst/cafc-answering-brief.typ), numbers the headings as the typst template does and turns each
-- [text](toa:key) citation into a counted hit for the table of authorities. Typesetting macros are in template.tex.
-- No case-specific text lives here.

local WORD_LIMIT = 14000 -- Fed. Cir. R. 32(b) (typst word-limit)
local TOC_DEPTH = 4      -- typst toc-depth

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_inlines = require("latex.xengine").inlines

local function fail(msg) error("cafc answering-brief: " .. msg, 0) end

-- Inline markdown in a metadata value -> LaTeX.
local function tex(v)
  if v == nil then return "" end
  if type(v) == "string" then v = pandoc.Inlines({ pandoc.Str(v) }) end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(xe_inlines(pandoc.Inlines(v))) }), "latex")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Plain text of a metadata value (sort keys, word counts).
local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function need(meta, k)
  if meta[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

-- Printed label of a numbered heading (typst heading-label): I. / A. / 1. / a. / (1).
local function label_for(level, n)
  if level == 1 then return roman(n) .. "." end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return tostring(n) .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  if level == 5 then return "(" .. n .. ")" end
  fail("headings deeper than level 5 are not supported")
end

local function raw(s) return pandoc.RawBlock("latex", s) end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2); typst cover-body)
-- ---------------------------------------------------------------------------

-- Rules in vertical mode: they cost their own height, as in typst.
local SHORT = "\\par\\hbox to\\linewidth{\\hss\\rule{2in}{0.7pt}\\hss}"
local DOUBLE = "\\par\\hbox to\\linewidth{\\rule{\\linewidth}{1.6pt}}\\vskip 2.5pt\\hbox to\\linewidth{\\rule{\\linewidth}{0.5pt}}"

local function cover(meta)
  local L = {}
  local function add(s) L[#L + 1] = s end
  add("\\thispagestyle{empty}\\begingroup\\singlespacing\\centering\\parindent=0pt")
  add("\\cagap[0.6]\\textbf{" .. tex(need(meta, "case_number")) .. "}")
  add("\\cagap" .. DOUBLE .. "\\cagap")
  add("\\textbf{UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT}")
  add("\\cagap" .. SHORT .. "\\cagap")
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for j, name in ipairs(side.names) do
      add((j > 1 and "\\par\\addvspace{4.9bp}" or "") .. tex(name))
    end
    add("\\par\\addvspace{4.9bp}{\\carighthalf " .. tex(side.designation) .. "\\par}")
    if i < #sides then add("\\cagap[0.3]v.\\cagap[0.3]") end
  end
  add("\\cagap" .. SHORT .. "\\cagap")
  add(tex(need(meta, "proceeding")))
  add("\\cagap" .. SHORT .. "\\cagap")
  add("\\textbf{\\MakeUppercase{" .. tex(need(meta, "brief_title")) .. "}}")
  add("\\cagap" .. SHORT .. "\\cagap")
  -- Counsel (FRAP 32(a)(2)(F)): the right half; each name a line, each address line 0.5 em in (wrapped lines too);
  -- 7 bp between the groups; the telephone number after the last group's lines.
  add("{\\carighthalf")
  local groups = need(meta, "counsel")
  for gi, g in ipairs(groups) do
    if gi > 1 then add("\\par\\addvspace{7bp}") end
    for _, n in ipairs(g.names) do add(tex(n) .. "\\par") end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = need(meta, "phone") end
    for _, l in ipairs(lines) do add("{\\advance\\leftskip 0.5em " .. tex(l) .. "\\par}") end
  end
  add("\\par}")
  if meta.date ~= nil then add("\\cagap{\\carighthalf " .. tex(meta.date) .. "\\par}") end
  add("\\cagap" .. DOUBLE)
  add("\\par\\endgroup\\clearpage")
  return table.concat(L, "\n")
end

-- Exemplary patent claims (Fed. Cir. R. 32(a)(3); typst patent-claims-page): their own unnumbered page(s) after the
-- cover, single-spaced, 14 bp between the paragraphs.
local function patent_claims(meta)
  if meta.patent_claims == nil then return nil end
  local L = { "\\thispagestyle{empty}\\casection{" ..
    (meta.patent_claims_heading ~= nil and tex(meta.patent_claims_heading) or "Exemplary Patent Claims") .. "}" }
  L[#L + 1] = "\\begingroup\\singlespacing\\parindent=0pt"
  for i, p in ipairs(meta.patent_claims) do L[#L + 1] = (i > 1 and "\\addvspace{14bp}" or "") .. tex(p) .. "\\par" end
  L[#L + 1] = "\\endgroup\\clearpage"
  return table.concat(L, "\n")
end

-- ---------------------------------------------------------------------------
-- Signature and certificates (typst signature-block, certificate-signature)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local L = { "\\par\\nobreak\\addvspace{19.6bp}\\nobreak\\begingroup\\singlespacing\\parindent=0pt" }
  if meta.date ~= nil then
    L[#L + 1] = "Dated: " .. tex(meta.date) .. "\\par\\nobreak\\vskip 14bp\\nobreak"
  end
  L[#L + 1] = "\\carighthalf Respectfully submitted,\\par\\nobreak\\vskip 16.8bp\\nobreak"
  L[#L + 1] = "/s/ " .. tex(sig.signer)
  for _, l in ipairs(sig.lines or {}) do L[#L + 1] = "\\par\\nobreak " .. tex(l) end
  L[#L + 1] = "\\par\\endgroup"
  return table.concat(L, "\n")
end

local function certificate_signature(meta)
  local sig = need(meta, "signature")
  local L = { "\\par\\nobreak\\addvspace{22.4bp}\\nobreak\\begingroup\\singlespacing\\carighthalf" }
  L[#L + 1] = "/s/ " .. tex(sig.signer) .. "\\par\\nobreak"
  L[#L + 1] = "\\MakeUppercase{" .. tex(sig.signer) .. "}"
  for _, l in ipairs(sig.certificate_lines or {}) do L[#L + 1] = "\\par\\nobreak " .. tex(l) end
  L[#L + 1] = "\\par\\endgroup"
  return table.concat(L, "\n")
end

-- ---------------------------------------------------------------------------
-- Table of authorities
-- ---------------------------------------------------------------------------

local ORDER = { "case", "constitution", "statute", "regulation", "rule", "other" }
local TITLES = {
  case = "Cases:", constitution = "Constitutional Provisions:", statute = "Statutes:",
  regulation = "Regulations:", rule = "Rules:", other = "Other Authorities:",
}

local function sort_key(a)
  local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function toa(meta, hits)
  local out = {}
  local auth = meta.authorities or {}
  for key in pairs(hits) do
    if auth[key] == nil then fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
  end
  out[#out + 1] = "\\casection{Table of Authorities}"
  local first = true
  for _, kind in ipairs(ORDER) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == kind and hits[key] ~= nil then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      local kx, ky = sort_key(x.a), sort_key(y.a)
      if kx == ky then return x.key < y.key end
      return kx < ky
    end)
    if #members > 0 then
      out[#out + 1] = "\\toagroup{" .. TITLES[kind] .. "}{" .. (first and 1 or 0) .. "}"
      first = false
      for _, m in ipairs(members) do
        local name = m.a.name ~= nil and tex(m.a.name) or ""
        out[#out + 1] = string.format("\\toaitem{%s}{%s}{%d}{%s}", name, tex(m.a.cite), kind == "case" and 1 or 0, m.key)
      end
    end
  end
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- Words (Fed. Cir. R. 32(b)): whitespace-delimited words of the body, headings and footnotes included
-- ---------------------------------------------------------------------------

-- Block by block (stringify of the whole document would run the last word of one block into the first of the
-- next), footnote text included, footnote marks and list markers not counted: the typst template's count.
local function words_in(s)
  local n = 0
  for _ in s:gsub("\194\160", " "):gmatch("%S+") do n = n + 1 end
  return n
end

local function count_blocks(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do n = n + count_blocks(item) end
    elseif b.t == "BlockQuote" or b.t == "Div" then
      n = n + count_blocks(b.content)
    elseif b.t ~= "RawBlock" then
      local notes = {}
      local without = pandoc.Pandoc({ b }):walk({
        Note = function(note) notes[#notes + 1] = note.content; return {} end,
      })
      n = n + words_in(pandoc.utils.stringify(without.blocks))
      for _, c in ipairs(notes) do n = n + count_blocks(c) end
    end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- The filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature",
    "related_statement" }) do
    need(meta, k)
  end

  local words = count_blocks(doc.blocks)
  if words > WORD_LIMIT then
    fail("the brief has " .. words .. " words; Fed. Cir. R. 32(b) allows " .. WORD_LIMIT)
  end

  -- the toa: citations; each writes its page to the aux file at its place (\toahit)
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) ~= "toa:" then return el.content end
      local key = el.target:sub(5)
      hits[key] = true
      local out = pandoc.Inlines({ pandoc.RawInline("latex", "\\toahit{" .. key .. "}") })
      out:extend(el.content)
      return out
    end,
  })
  -- the cross-engine inline rules over the body text
  doc = doc:walk({ Inlines = xe_inlines })

  -- headings: every heading of the body is numbered, I. / A. / 1. / a. / (1)
  local counters = { 0, 0, 0, 0, 0, 0 }
  local heads = {}
  doc = doc:walk({
    Header = function(h)
      counters[h.level] = counters[h.level] + 1
      for i = h.level + 1, 6 do counters[i] = 0 end
      local label = label_for(h.level, counters[h.level])
      local title = tex(h.content)
      heads[#heads + 1] = { level = h.level, label = label, title = title }
      return raw(string.format("\\cahead{%d}{%d}{%s}{%s}{h%d}", h.level, h.level - 1, label, title, #heads))
    end,
  })

  local front = {}
  front[#front + 1] = raw(cover(meta))
  local claims = patent_claims(meta)
  if claims then front[#front + 1] = raw(claims) end

  -- the front matter counts from i (typst: counter(page).update(1) after the cover)
  local toc = { "\\pagenumbering{roman}\\singlespacing\\casection{Table of Contents}",
    "\\par\\addvspace{4.2bp}\\begingroup\\raggedleft\\singlespacing\\bfseries\\underline{Page}\\par\\endgroup" }
  for i, h in ipairs(heads) do
    if h.level <= TOC_DEPTH then
      toc[#toc + 1] = string.format("\\tocline{%d}{%s}{%s}{h%d}{%s}", h.level - 1, h.label, h.title, i,
        h.level == 1 and "8.4bp" or "4.9bp")
    end
  end
  front[#front + 1] = raw(table.concat(toc, "\n"))
  front[#front + 1] = raw("\\clearpage\n" .. toa(meta, hits))

  -- Statement of Related Cases (Fed. Cir. R. 47.5): the sample's paragraphs, set as the text
  local rel = { "\\clearpage\\casection{Statement of Related Cases}\\normalsize" }
  for _, p in ipairs(need(meta, "related_statement")) do rel[#rel + 1] = tex(p) .. "\\par" end
  front[#front + 1] = raw(table.concat(rel, "\n"))
  front[#front + 1] = raw("\\clearpage\\pagenumbering{arabic}\\normalsize")

  -- A paragraph that anchors a footnote has no widow or orphan control: typst's widow and orphan rules do not see
  -- the note, so a line whose note does not fit moves to the next page alone (docx: style "Body Text Note").
  local nb = pandoc.Blocks({})
  for _, b in ipairs(doc.blocks) do
    local note = false
    if b.t == "Para" then pandoc.Pandoc({ b }):walk({ Note = function(n) note = true return n end }) end
    if note then
      nb:insert(raw("\\begingroup\\widowpenalty=0 \\clubpenalty=0 "))
      nb:insert(b)
      nb:insert(raw("\\par\\endgroup"))
    else
      nb:insert(b)
    end
  end
  doc.blocks = nb

  -- The signature never stands alone: the brief's last paragraph is not broken across pages and stays with the
  -- signature block (typst: one unbreakable block).
  local n = #doc.blocks
  if n > 0 and doc.blocks[n].t == "Para" then
    doc.blocks:insert(n, raw("\\begingroup\\interlinepenalty=10000\\relax"))
    doc.blocks:insert(raw("\\par\\endgroup"))
  end

  -- back matter: the signature, then the certificates, each on a new page; the arabic count goes on
  local back = { raw(signature(meta)) }
  back[#back + 1] = raw("\\clearpage\\casection{Certificate of Compliance}")
  local counter = meta.word_counter ~= nil and tex(meta.word_counter) or "the word-processing system used to prepare it"
  back[#back + 1] = raw("\\begingroup\\singlespacing\\parindent=0pt " ..
    "I certify that this brief complies with the type-volume limitation of Fed. Cir. R. 32(b). The total number " ..
    "of words in the brief is " .. group_digits(words) .. ", as calculated by " .. counter .. ".\\par\\addvspace{14bp}" ..
    "The brief\u{2019}s typeface and type style comply with FRAP 32(a)(5) and (6).\\par\\endgroup")
  back[#back + 1] = raw(certificate_signature(meta))
  local svc = meta.service
  if svc ~= nil and svc.certificate then
    back[#back + 1] = raw("\\clearpage\\casection{Certificate of Service}")
    back[#back + 1] = raw("\\begingroup\\singlespacing\\parindent=0pt I certify that on " ..
      (meta.date ~= nil and tex(meta.date) or "the date of filing") ..
      " I electronically filed the foregoing brief with the Clerk of Court using the CM/ECF system, which will " ..
      "send notice of the filing to all counsel of record.\\par\\endgroup")
    back[#back + 1] = raw(certificate_signature(meta))
  end

  local blocks = pandoc.Blocks({})
  for _, b in ipairs(front) do blocks:insert(b) end
  for _, b in ipairs(doc.blocks) do blocks:insert(b) end
  for _, b in ipairs(back) do blocks:insert(b) end
  doc.blocks = blocks
  return doc
end

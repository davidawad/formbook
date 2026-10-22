-- cafc.lua: pandoc Lua filter for the LaTeX engine of the Federal Circuit reply brief (template.tex).
-- Builds the cover, the table of contents, the table of authorities, the signature block and the certificates
-- (Form 19, service) from the YAML frontmatter (the same fields as ../typst/cafc-reply-brief.typ), numbers the
-- headings as the typst template does and turns each [text](toa:key) citation into a counted hit for the table of
-- authorities. Typesetting macros are in template.tex. No case-specific text lives here.

local WORD_LIMIT = 7000 -- Fed. Cir. R. 32(b)(1): reply brief (typst word-limit)
local TOC_DEPTH = 4     -- typst toc-depth

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_lib = require("latex.xengine").inlines

-- Two break rules of typst this folder adds to the shared ones: a line may end after a slash before a letter
-- ("CM/ECF", Unicode line breaking), and an ellipsis is the one 1 em glyph (template.tex \\caellipsis), not \\ldots.
local function folder_inlines(inlines)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "Str" and (el.text:find("\u{2026}") or el.text:find("/%a")) then
      -- marks: \1 a break after the slash, \2 the ellipsis
      local s = el.text:gsub("/(%a)", "/\1%1"):gsub("\u{2026}", "\2")
      for part, mark in (s .. "\3"):gmatch("([^\1\2\3]*)([\1\2\3])") do
        if part ~= "" then out:insert(pandoc.Str(part)) end
        if mark == "\1" then out:insert(pandoc.RawInline("latex", "\\allowbreak{}"))
        elseif mark == "\2" then out:insert(pandoc.RawInline("latex", "\\caellipsis{}")) end
      end
    else
      out:insert(el)
    end
  end
  return out
end

local function xe_inlines(l) return folder_inlines(xe_lib(l)) end

local function fail(msg) error("cafc reply-brief: " .. msg, 0) end

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

local function roman(n, lower)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return lower and out:lower() or out
end

-- Printed label of a numbered heading (typst heading-label): I. / A. / i. / 1. / a.
local function label_for(level, n)
  if level == 1 then return roman(n) .. "." end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return roman(n, true) .. "." end
  if level == 4 then return tostring(n) .. "." end
  if level == 5 then return string.char(96 + n) .. "." end
  fail("headings deeper than level 5 are not supported")
end

local function raw(s) return pandoc.RawBlock("latex", s) end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Cover (Fed. Cir. R. 32(a)(1); FRAP 32(a)(2); typst cover-body)
-- ---------------------------------------------------------------------------

-- Rules in vertical mode: they cost their own height, as in typst.
local SHORT = "\\par\\hbox to\\linewidth{\\hss\\rule{2in}{0.7pt}\\hss}"
local DOUBLE = "\\par\\hbox to\\linewidth{\\rule{\\linewidth}{1.6pt}}\\vskip 2.5pt\\hbox to\\linewidth{\\rule{\\linewidth}{0.5pt}}"

local function cover(meta)
  local L = {}
  local function add(s) L[#L + 1] = s end
  add("\\thispagestyle{empty}\\begingroup\\singlespacing\\centering\\parindent=0pt")
  add("\\cagap[0.6]\\textbf{No.\\ " .. tex(need(meta, "case_number")) .. "}")
  -- the court's name in a 4 in block, centered
  add("\\cagap{\\leftskip=\\dimexpr(\\linewidth-4in)/2\\relax plus 1fil\\relax\\rightskip=\\leftskip\\bfseries " ..
    "UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT\\par}")
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
  -- Counsel (FRAP 32(a)(2)(F)): two groups to a row, columns of (text width - 0.1 in) / 2; each line a paragraph,
  -- a line too long for its column hanging 14 bp; 8.4 bp between the rows.
  local counsel = need(meta, "counsel")
  local function block(g)
    local b = {}
    for _, n in ipairs(g.names) do b[#b + 1] = tex(n) .. "\\par" end
    for _, x in ipairs(g.lines or {}) do b[#b + 1] = tex(x) .. "\\par" end
    return "\\begin{minipage}[t]{\\dimexpr(\\linewidth-0.1in)/2\\relax}\\singlespacing\\raggedright\\parindent=0pt" ..
      "\\hangindent=14bp\\hangafter=1\\everypar{\\hangindent=14bp\\hangafter=1\\relax}" ..
      table.concat(b, "\n") .. "\\end{minipage}"
  end
  for i = 1, #counsel, 2 do
    local row = block(counsel[i])
    if counsel[i + 1] ~= nil then row = row .. "\\hfill" .. block(counsel[i + 1]) else row = row .. "\\hfill\\null" end
    add((i > 1 and "\\par\\addvspace{8.4bp}" or "\\par") .. "\\carow{" .. row .. "}")
  end
  add("\\cagap[0.6]" .. tex(need(meta, "counsel_for")))
  add("\\cagap" .. DOUBLE)
  add("\\par\\endgroup\\clearpage")
  return table.concat(L, "\n")
end

-- ---------------------------------------------------------------------------
-- Signature and certificates (typst signature-block, certificate-of-compliance, certificate-of-service)
-- ---------------------------------------------------------------------------

-- The signature's two columns [grid (1fr, 3.9 in)]: the date at the margin, the signature 3.9 in from the right.
local LEFTCOL = "\\dimexpr\\linewidth-3.9in\\relax"

-- the right column's lines: the first as it is, every further one 0.5 em in on its own line (typst: linebreak,
-- h(0.5em)); a line that wraps goes on at the column's edge
local function signer_lines(first, lines)
  local L = { first }
  for _, l in ipairs(lines or {}) do L[#L + 1] = "\\par\\nobreak\\hspace*{0.5em}" .. tex(l) end
  return table.concat(L, "\n")
end

local function signature(meta)
  local sig = need(meta, "signature")
  local L = { "\\par\\addvspace{19.6bp}\\begingroup\\singlespacing\\parindent=0pt\\interlinepenalty=10000\\relax" }
  L[#L + 1] = "\\noindent\\makebox[" .. LEFTCOL .. "][l]{" .. (meta.date ~= nil and ("Dated: " .. tex(meta.date)) or "") ..
    "}Respectfully submitted,\\par\\nobreak\\leftskip=" .. LEFTCOL .. "\\vskip 16.8bp\\nobreak"
  L[#L + 1] = signer_lines("/s/ " .. tex(sig.signer), sig.lines)
  for _, o in ipairs(sig.also or {}) do
    L[#L + 1] = "\\par\\nobreak\\vskip 16.8bp\\nobreak " .. signer_lines(tex(o.name), o.lines)
  end
  L[#L + 1] = "\\par\\nobreak\\vskip 11.2bp\\nobreak " .. tex(need(meta, "counsel_for")) .. "\\par\\endgroup"
  return table.concat(L, "\n")
end

-- One option of Form 19 [option-row]: the box in a 22.4 bp column, the text hanging after it; 11.2 bp above.
local function option_row(checked, text)
  return "\\par\\addvspace{11.2bp}{\\interlinepenalty=10000\\noindent\\hangindent=22.4bp\\hangafter=1\\relax" ..
    "\\makebox[22.4bp][l]{\\cabox{" .. (checked and 1 or 0) .. "}}" .. text .. "\\par}"
end

local BLANK = "\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_"

local function certificate_of_compliance(meta, words)
  local L = { "\\clearpage\\casection{Certificate of Compliance with Type-Volume Limitations}",
    "\\begingroup\\singlespacing\\parindent=0pt" }
  L[#L + 1] = "Case Number: " .. tex(need(meta, "case_number")) .. "\\par\\addvspace{14bp}"
  L[#L + 1] = "Short Case Caption: " .. tex(need(meta, "short_caption")) .. "\\par\\addvspace{14bp}"
  L[#L + 1] = "Instructions: When computing a word, line, or page count, you may exclude any items listed as " ..
    "exempted under Fed. R. App. P. 5(c), Fed. R. App. P. 21(d), Fed. R. App. P. 27(d)(2), Fed. R. App. P. 32(f), " ..
    "or Fed. Cir. R. 32(b)(2).\\par\\addvspace{14bp}"
  L[#L + 1] = "The foregoing filing complies with the relevant type-volume limitation of the Federal Rules of " ..
    "Appellate Procedure and Federal Circuit Rules because it meets one of the following:"
  L[#L + 1] = option_row(true, "the filing has been prepared using a proportionally-spaced typeface and includes " ..
    group_digits(words) .. " words.")
  L[#L + 1] = option_row(false, "the filing has been prepared using a monospaced typeface and includes " .. BLANK ..
    " lines of text.")
  L[#L + 1] = option_row(false, "the filing contains " .. BLANK .. " pages / " .. BLANK .. " words / " .. BLANK ..
    " lines of text, which does not exceed the maximum authorized by this court\u{2019}s order (ECF No. " .. BLANK .. ").")
  -- [grid (1fr, 1fr), gutter 14 bp]: the date at the margin, the signature and the name in the right column
  L[#L + 1] = "\\par\\nobreak\\addvspace{22.4bp}\\nobreak\\noindent\\makebox[\\dimexpr(\\linewidth+14bp)/2\\relax][l]{Date: " ..
    tex(need(meta, "date")) .. "}Signature: /s/ " .. tex(need(meta, "signature").signer) ..
    "\\par\\nobreak\\addvspace{14bp}\\nobreak\\leftskip=\\dimexpr(\\linewidth+14bp)/2\\relax Name: " ..
    tex(need(meta, "signature").signer) .. "\\par\\endgroup"
  return table.concat(L, "\n")
end

local function certificate_of_service(meta)
  local sig = need(meta, "signature")
  local L = { "\\clearpage\\casection{Certificate of Service}", "\\begingroup\\singlespacing\\parindent=0pt" }
  L[#L + 1] = "I hereby certify that on " .. tex(need(meta, "date")) .. ", I electronically filed the foregoing " ..
    tex(need(meta, "brief_title")) .. ", with the Court\u{2019}s CM/\\allowbreak{}ECF filing system, which constitutes service, " ..
    "pursuant to Fed. R. App. P. 25(c) and Fed. Cir. R. 25(a).\\par"
  -- [grid (1fr, 3.9 in)]: the date at the margin, the signature in the right column
  L[#L + 1] = "\\nobreak\\addvspace{22.4bp}\\nobreak\\noindent\\makebox[" .. LEFTCOL .. "][l]{Date: " ..
    tex(need(meta, "date")) .. "}/s/ " .. tex(sig.signer) .. "\\par\\leftskip=" .. LEFTCOL ..
    signer_lines("", sig.lines) .. "\\par\\endgroup"
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
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "short_caption", "counsel",
    "counsel_for", "signature", "date" }) do
    need(meta, k)
  end

  local words = count_blocks(doc.blocks)
  if words > WORD_LIMIT then
    fail("the brief has " .. words .. " words; Fed. Cir. R. 32(b)(1) allows " .. WORD_LIMIT .. " for a reply brief")
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

  -- headings: every heading of the body is numbered, I. / A. / i. / 1. / a.
  local counters = { 0, 0, 0, 0, 0, 0 }
  local heads = {}
  doc = doc:walk({
    Header = function(h)
      counters[h.level] = counters[h.level] + 1
      for i = h.level + 1, 6 do counters[i] = 0 end
      local label = label_for(h.level, counters[h.level])
      local title = tex(h.content)
      heads[#heads + 1] = { level = h.level, label = label, title = title }
      if h.level == 1 then return raw(string.format("\\casectionnum{%s}{%s}{h%d}", label, title, #heads)) end
      return raw(string.format("\\cahead{%d}{%d}{%s}{%s}{h%d}", h.level, h.level - 1, label, title, #heads))
    end,
  })

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

  local front = { raw(cover(meta)) }
  -- the front matter counts from i (typst: counter(page).update(1) after the cover)
  local toc = { "\\pagenumbering{roman}\\singlespacing\\casection{Table of Contents}",
    "\\par\\addvspace{4.2bp}\\begingroup\\raggedleft\\singlespacing\\bfseries\\underline{Page}\\par\\endgroup" }
  for i, h in ipairs(heads) do
    if h.level <= TOC_DEPTH then
      local title = h.level == 1 and ("\\MakeUppercase{" .. h.title .. "}") or h.title
      toc[#toc + 1] = string.format("\\tocline{%d}{%s}{%s}{h%d}{%s}", h.level - 1, h.label, title, i,
        h.level == 1 and "8.4bp" or "4.9bp")
    end
  end
  front[#front + 1] = raw(table.concat(toc, "\n"))
  front[#front + 1] = raw("\\clearpage\n" .. toa(meta, hits))
  front[#front + 1] = raw("\\clearpage\\pagenumbering{arabic}\\normalsize")

  -- back matter: the signature block (kept whole, after the conclusion), then the certificates on new pages; the
  -- arabic count goes on
  local back = { raw(signature(meta)) }
  back[#back + 1] = raw(certificate_of_compliance(meta, words))
  back[#back + 1] = raw(certificate_of_service(meta))

  local blocks = pandoc.Blocks({})
  for _, b in ipairs(front) do blocks:insert(b) end
  for _, b in ipairs(doc.blocks) do blocks:insert(b) end
  for _, b in ipairs(back) do blocks:insert(b) end
  doc.blocks = blocks
  return doc
end

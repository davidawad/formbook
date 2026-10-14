-- Second Circuit brief, docx engine: the parts of the typst template (typst/ca2-<doc>.typ) that pandoc
-- cannot write itself, as Word styles of reference.docx (built by make-reference.sh). Read by
-- tools/render-docx.sh as a pandoc filter.
--
-- Sections: the cover (no page number), the table of contents and of authorities (lower-case roman),
-- the body and the certificates (arabic from 1). Headings are Word heading styles with their labels
-- (I., A., 1., a.) in the text; the Argument's points are centered "Point Heading" paragraphs.
--
-- DOC selects the wording of the doc type's own template: "opening", "answering" or "reply".
local DOC = "reply"
local WORD_LIMIT = ({ opening = 14000, answering = 13000, reply = 7000 })[DOC]   -- Local Rule 32.1(a), FRAP 32(a)(7)(B)
local FIRST_ARG_LEVEL = 3  -- sub-heading steps start at level 3 inside the Argument (typst label-indent)

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function plain(x)
  if x == nil then return "" end
  if type(x) == "string" then return x end
  return pandoc.utils.stringify(x)
end

local function need(m, key)
  if m[key] == nil then error("ca2.lua: missing required metadata field `" .. key .. "`") end
  return m[key]
end

-- Meta inlines (or a plain string) as a fresh Inlines list.
local function inl(x)
  local r = pandoc.Inlines({})
  if x == nil then return r end
  if type(x) == "string" then r:insert(pandoc.Str(x)); return r end
  r:extend(x)
  return r
end

-- Concatenate Inlines lists (and single inline elements) into a new list.
local function cat(...)
  local r = pandoc.Inlines({})
  for _, x in ipairs({ ... }) do
    if x.t then r:insert(x) else r:extend(x) end
  end
  return r
end

local function S(s) return pandoc.Str(s) end
local SP = pandoc.Space()
local BR = pandoc.LineBreak()

local function upper(x)
  return inl(x):walk({ Str = function(s) s.text = s.text:upper(); return s end })
end

local function style(name, blocks)
  return pandoc.Div(blocks, { ["custom-style"] = name })
end

local function para(content) return pandoc.Para(content) end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- A rule: a double rule the width of the text (the cover's top and bottom), or a short single rule.
local function rule(kind)
  if kind == "double" then
    return raw('<w:p><w:pPr><w:pBdr><w:bottom w:val="double" w:sz="4" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="120" w:after="120" w:line="240" w:lineRule="auto"/></w:pPr></w:p>')
  end
  return raw('<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="2880" w:right="2880"/><w:jc w:val="center"/></w:pPr></w:p>')
end

local PAGE_SETUP = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

-- The end of a section: the paragraph carries the section's properties (footer, page numbering).
local function section_end(footer_rid, fmt)
  local num = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:sectPr><w:footerReference w:type="default" r:id="' ..
    footer_rid .. '"/>' .. PAGE_SETUP .. num .. '<w:type w:val="nextPage"/></w:sectPr></w:pPr></w:p>')
end

local function page_break()
  return raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function letter(n, lower) return string.char((lower and 96 or 64) + n) end

local function sort_key(a)
  local k = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  return (k:lower():gsub("[^a-z0-9 ]", ""))
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function count_words(el)
  local _, k = pandoc.utils.stringify(el):gsub("\u{00A0}", " "):gsub("%S+", "")
  return k
end

-- ---------------------------------------------------------------------------
-- State filled in while the body is walked (in document order)
-- ---------------------------------------------------------------------------

local counts = { 0, 0, 0, 0, 0 }
local in_argument = false
local header_words = 0   -- words of headings that are not Para blocks (point headings count as paragraphs)
local marker_words = 0   -- decimal list markers (1., 2., ...): typst does not count them
local cited = {}         -- authority keys linked from the body
local toc_entries = {}   -- { label, text } in document order, for the table of contents

local function heading_label(level)
  local n = counts[level]
  if in_argument then
    if level == 2 then return roman(n) .. "."
    elseif level == 3 then return letter(n, false) .. "."
    elseif level == 4 then return tostring(n) .. "."
    elseif level == 5 then return letter(n, true) .. "."
    end
  else
    if level == 2 then return letter(n, false) .. "."
    elseif level == 3 then return tostring(n) .. "."
    elseif level == 4 then return letter(n, true) .. "."
    elseif level == 5 then return "(" .. n .. ")"
    end
  end
  error("ca2.lua: headings deeper than level 5 are not supported")
end

function Header(h)
  local lvl = h.level
  if lvl > 5 then error("ca2.lua: headings deeper than level 5 are not supported") end
  if lvl == 1 then
    in_argument = plain(h.content):lower():match("^%s*(.-)%s*$") == "argument"
    for j = 2, 5 do counts[j] = 0 end
    counts[1] = counts[1] + 1
    header_words = header_words + count_words(h)
    table.insert(toc_entries, { label = "", text = inl(h.content), upper = true })
    return pandoc.Header(1, h.content)
  end
  counts[lvl] = counts[lvl] + 1
  for j = lvl + 1, 5 do counts[j] = 0 end
  local label = heading_label(lvl)
  table.insert(toc_entries, { label = label, text = inl(h.content) })
  if in_argument and lvl == 2 then
    -- the point heading is a paragraph: its words are counted with the paragraphs, the label is not
    marker_words = marker_words + 1
    return style("Point Heading", { para(cat(S(label), SP, h.content)) })
  end
  header_words = header_words + count_words(h)
  -- The label's step: Heading 2 for the first step (label at half an inch), Heading 3 for the next, ...
  local first = in_argument and FIRST_ARG_LEVEL or 2
  local steps = lvl - first + 1
  return pandoc.Header(steps + 1, cat(S(label), TAB, h.content))
end

function Link(el)
  local key = el.target:match("^toa:(.+)$")
  if key == nil then return nil end
  cited[key] = true
  return el.content
end

-- Numbered lists that are really markers such as "(A)" are text, as in the latex engine.
local function marker(style_name, n)
  if style_name == "UpperAlpha" then return letter(n, false)
  elseif style_name == "LowerAlpha" then return letter(n, true)
  elseif style_name == "UpperRoman" then return roman(n)
  elseif style_name == "LowerRoman" then return roman(n):lower()
  end
  return tostring(n)
end

function OrderedList(l)
  local a = l.listAttributes
  local out = {}
  for i, item in ipairs(l.content) do
    local lab = marker(a.style, a.start + i - 1)
    if a.style == "Decimal" then marker_words = marker_words + 1 end
    if a.delimiter == "TwoParens" then lab = "(" .. lab .. ")"
    elseif a.delimiter == "OneParen" then lab = lab .. ")"
    else lab = lab .. "." end
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      item[1] = para(cat(S(lab), SP, first.content))
    end
    for _, b in ipairs(item) do table.insert(out, b) end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover, signature and certificates
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local function add(b) table.insert(out, b) end
  local court
  if DOC == "opening" then
    court = cat(S("IN"), SP, S("THE"), SP, S("UNITED"), SP, S("STATES"), SP, S("COURT"), SP, S("OF"), SP, S("APPEALS"), BR,
      S("FOR"), SP, S("THE"), SP, S("SECOND"), SP, S("CIRCUIT"))
  else
    court = cat(S("IN"), SP, S("THE"), BR, S("United"), SP, S("States"), SP, S("Court"), SP, S("of"), SP, S("Appeals"), SP,
      S("for"), SP, S("the"), SP, S("Second"), SP, S("Circuit"))
  end
  add(style("Center Single", { para({ pandoc.Strong(cat(S("No."), SP, inl(need(m, "case_number")))) }) }))
  add(rule("double"))
  add(style("Center Single", { para({ pandoc.Strong(court) }) }))
  if DOC ~= "reply" then add(rule("short")) end
  local sides = need(m, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(style("Center Single", { para(inl(name)) })) end
    add(style(DOC == "opening" and "Half Block" or "Center Single", { para(inl(side.designation)) }))
    if i < #sides then
      add(style("Center Single", { para({ S(DOC == "opening" and "-v-" or "\u{2013} v. \u{2013}") }) }))
    end
  end
  if DOC ~= "reply" then add(rule("short")) end
  add(style("Center Single", { para(inl(need(m, "proceeding"))) }))
  if m.district_court_case or m.judge then
    local dc = pandoc.Inlines({})
    if m.district_court_case then
      dc = cat(S(DOC == "reply" and "Case No." or "D.C. No."), SP, inl(m.district_court_case))
    end
    if m.district_court_case and m.judge then dc = cat(dc, S(";"), SP) end
    if m.judge then dc = cat(dc, inl(m.judge)) end
    add(style("Center Single", { para(dc) }))
  end
  if DOC ~= "reply" then add(rule("short")) end
  add(style("Center Single", { para({ pandoc.Strong(upper(need(m, "brief_title"))) }) }))
  if DOC ~= "reply" then add(rule("short")) end
  local groups = need(m, "counsel")
  local groups_out = {}
  for gi, g in ipairs(groups) do
    local content = pandoc.Inlines({})
    for _, n in ipairs(g.names) do content:extend(inl(n)); content:insert(BR) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do table.insert(lines, { emph = true, text = l }) end
    local phone = g.phone or (gi == #groups and m.phone or nil)
    if phone then table.insert(lines, { emph = DOC ~= "reply", text = phone }) end
    for _, l in ipairs(lines) do
      local t = inl(l.text)
      content:insert(S(" "))
      if l.emph then content:insert(pandoc.Emph(t)) else content:extend(t) end
      content:insert(BR)
    end
    groups_out[gi] = style(DOC == "reply" and "Single Left" or "Half Block", { para(content) })
  end
  if DOC == "reply" then
    -- two columns of counsel, as the reply typst template sets them (a borderless table)
    local half = math.ceil(#groups / 2)
    -- a cell holds the counsel paragraphs: names, then the italic lines, then the telephone number
    local function xesc(s) return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
    local function line(text, italic)
      return "<w:p><w:pPr><w:pStyle w:val=\"SingleLeft\"/></w:pPr><w:r>" .. (italic and "<w:rPr><w:i/></w:rPr>" or "") ..
        "<w:t xml:space=\"preserve\">" .. xesc(text) .. "</w:t></w:r></w:p>"
    end
    local function column(first, last)
      local xml = {}
      for gi = first, last do
        local g = groups[gi]
        for _, n in ipairs(g.names) do table.insert(xml, line(plain(n), false)) end
        for _, l in ipairs(g.lines or {}) do table.insert(xml, line(plain(l), true)) end
        local phone = g.phone or (gi == #groups and m.phone or nil)
        if phone then table.insert(xml, line(plain(phone), DOC ~= "reply")) end
      end
      return table.concat(xml)
    end
    local cell = function(x) return "<w:tc><w:tcPr><w:tcW w:w=\"4680\" w:type=\"dxa\"/></w:tcPr>" .. x .. "</w:tc>" end
    add(raw("<w:tbl><w:tblPr><w:tblW w:w=\"9360\" w:type=\"dxa\"/><w:tblLayout w:type=\"fixed\"/></w:tblPr><w:tblGrid><w:gridCol w:w=\"4680\"/><w:gridCol w:w=\"4680\"/></w:tblGrid><w:tr>" .. cell(column(1, half)) .. cell(column(half + 1, #groups)) .. "</w:tr></w:tbl>"))
  else
    for gi = 1, #groups do add(groups_out[gi]) end
  end
  add(rule("double"))
  return out
end

local function signature(m)
  local sig = need(m, "signature")
  local out = {}
  if DOC ~= "opening" and m.date then
    local d = cat(S("Dated:"), SP, inl(m.date))
    if m.city then d = cat(d, S(","), SP, inl(m.city)) end
    table.insert(out, para(d))
  end
  local lines = cat(S("Respectfully"), SP, S("submitted,"), BR,
    S(DOC == "opening" and "s/" or "/s/"), SP, inl(sig.signer), BR,
    DOC == "opening" and upper(sig.signer) or inl(sig.signer))
  for _, l in ipairs(sig.lines or {}) do lines = cat(lines, BR, S(" "), pandoc.Emph(inl(l))) end
  if DOC == "reply" and m.counsel_for then lines = cat(lines, BR, pandoc.Emph(inl(m.counsel_for))) end
  table.insert(out, style("Half Block", { para(lines) }))
  if DOC == "opening" and m.date then table.insert(out, para(inl(m.date))) end
  return out
end

local function sig_foot(signer, date)
  return {
    style("Cert Text", { para(cat(S(DOC == "opening" and "s/" or "/s/"), SP, inl(signer))) }),
    para(cat(S("Signature"), BR, inl(date))),
  }
end

local function certificate_of_compliance(m, words)
  local n = group_digits(words)
  local texts
  if DOC == "opening" then
    texts = {
      "1. This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) and Local Rule 32.1(a) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f): this document contains " .. n .. " words.",
      "2. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because: this document has been prepared in a proportionally spaced typeface using EB Garamond in 14-point type." }
  elseif DOC == "answering" then
    texts = {
      "This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because this brief contains " .. n .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f).",
      "This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because this brief has been prepared in a proportionally spaced typeface using Word in 14-point EB Garamond." }
  else
    texts = {
      "This brief complies with the type-volume limitation set forth in Local Rule 32.1(a)(4)(B) because it contains " .. n .. " words, excluding the parts of the brief exempted by Federal Rule of Appellate Procedure 32(f).",
      "This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and the type-style requirements of Federal Rule of Appellate Procedure 32(a)(6) because it was prepared in a proportionally spaced typeface using Word in 14-point EB Garamond font." }
  end
  local out = { page_break(), pandoc.Header(1, { S("Certificate"), SP, S("of"), SP, S("Compliance") }) }
  for _, t in ipairs(texts) do table.insert(out, style("Cert Text", { para({ S(t) }) })) end
  if DOC ~= "opening" then table.insert(out, para(inl(m.date))) end
  for _, b in ipairs(sig_foot(need(m, "signature").signer, m.date and plain(m.date) or "")) do table.insert(out, b) end
  return out
end

local function certificate_of_service(m)
  local svc = need(m, "service")
  local out = { page_break(), pandoc.Header(1, { S("Certificate"), SP, S("of"), SP, S("Service") }) }
  if DOC == "opening" then
    table.insert(out, style("Cert Text", { para(cat(S("I"), SP, S("certify"), SP, S("that"), SP, S("on"), SP, inl(svc.date),
      S(", I served one copy of the foregoing"), SP, inl(m.brief_title),
      S(" on the following counsel of record, by the method stated:"))) }))
    for _, p in ipairs(svc.parties) do
      table.insert(out, style("Half Block", { para(cat(inl(p.name), BR, inl(p.address), BR, pandoc.Emph(inl(p.method)))) }))
    end
    for _, b in ipairs(sig_foot(svc.signer or need(m, "signature").signer, svc.date and plain(svc.date) or "")) do table.insert(out, b) end
  else
    local t
    if DOC == "answering" then
      t = cat(S("I"), SP, S("hereby"), SP, S("certify"), SP, S("that"), SP, S("on"), SP, inl(m.date),
        S(", a true and correct copy of the foregoing was served via"), SP, S(svc.method or "ACMS"),
        S(" to all counsel of record or parties pro se."))
    else
      t = cat(S("I"), SP, S("hereby"), SP, S("certify"), SP, S("that,"), SP, S("on"), SP, inl(m.date),
        S(", I electronically filed the foregoing"), SP, inl(m.brief_title),
        S(" with the United States Court of Appeals for the Second Circuit using the Court\u{2019}s electronic filing system, which will serve copies on all registered counsel."))
    end
    table.insert(out, style("Cert Text", { para(t) }))
    for _, u in ipairs(svc.unregistered or {}) do table.insert(out, style("Half Block", { para(cat(inl(u.name), BR, inl(u.address))) })) end
    for _, b in ipairs(sig_foot(need(m, "signature").signer, "")) do table.insert(out, b) end
    table.insert(out, 3, para(inl(m.date)))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The table of contents and of authorities
-- ---------------------------------------------------------------------------

local function contents_block()
  local out = { style("Center Single", { para({ pandoc.Strong(S("TABLE OF CONTENTS")) }) }),
    style("Single Left", { para({ pandoc.Strong(S("Page")) }) }) }
  table.insert(out, style("Toc Entry", { para(cat(S("TABLE OF AUTHORITIES"), TAB, S("ii"))) }))
  for _, e in ipairs(toc_entries) do
    local text = e.upper and upper(e.text) or e.text
    local content = pandoc.Inlines({})
    if e.label ~= "" then content = cat(S(e.label), SP) end
    content = cat(content, text, TAB, S(""))   -- the page number: see README, "Engines" (docx)
    table.insert(out, style("Toc Entry", { para(content) }))
  end
  return out
end

local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local function authorities_block(auths)
  local out = { style("Center Single", { para({ pandoc.Strong(S("TABLE OF AUTHORITIES")) }) }) }
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auths) do
      if plain(a.kind) == g[1] and cited[key] then table.insert(members, { key = key, a = a }) end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
      table.insert(out, style("Toa Group", { para({ S(g[2]) }) }))
      for _, mem in ipairs(members) do
        if mem.a.name then
          local nm = inl(mem.a.name)
          if g[1] == "case" then nm = pandoc.Inlines({ pandoc.Emph(nm) }) end
          table.insert(out, style("Toa Name", { para(cat(nm, S(","))) }))
          table.insert(out, style("Toa Entry", { para(cat(inl(mem.a.cite), TAB, S(""))) }))
        else
          table.insert(out, style("Toa Entry", { para(cat(inl(mem.a.cite), TAB, S(""))) }))
        end
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local blocks = doc.blocks
  local auths = m.authorities or {}
  for key in pairs(cited) do
    if auths[key] == nil then error("ca2.lua: link `toa:" .. key .. "` has no entry under `authorities:`") end
  end
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "signature", "service" }) do
    need(m, k)
  end

  -- word count, as the latex engine: paragraphs (footnotes and block quotations included) and headings
  local words = header_words - marker_words
  pandoc.Pandoc(blocks):walk({ Para = function(el) words = words + count_words(el) end,
    Plain = function(el) words = words + count_words(el) end })
  if words > WORD_LIMIT then
    error("ca2.lua: the brief has " .. words .. " words; Local Rule 32.1(a) allows " .. WORD_LIMIT)
  end

  local out = {}
  local function addall(list) for _, b in ipairs(list) do table.insert(out, b) end end

  addall(cover(m))
  table.insert(out, section_end("rIdFooter2", nil))
  -- front matter: the contents and the authorities, lower-case roman
  addall(contents_block())
  table.insert(out, page_break())
  addall(authorities_block(auths))
  table.insert(out, section_end("rIdFooter1", "lowerRoman"))
  -- body (arabic from 1): the reference's final section supplies the footer and the numbering
  local n = #blocks
  for i = 1, n do
    table.insert(out, blocks[i])
    if i == n and blocks[i].t == "Para" then addall(signature(m)) end
  end
  if n == 0 or blocks[n].t ~= "Para" then addall(signature(m)) end
  addall(certificate_of_compliance(m, words))
  if DOC == "opening" or (m.service and m.service.certificate) then addall(certificate_of_service(m)) end
  -- the date is printed where the signature puts it, not as pandoc's title-block date at the top
  local meta = {}
  for k, v in pairs(doc.meta) do if k ~= "date" then meta[k] = v end end
  return pandoc.Pandoc(out, meta)
end

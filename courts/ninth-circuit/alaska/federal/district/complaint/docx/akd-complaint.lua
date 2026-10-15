-- Complaint, United States District Court for the District of Alaska (akd), DOCX engine (docs/DOCX.md).
-- Markdown contract -> Word document on docx/reference.docx. Mirrors typst/akd-complaint.typ:
-- the cover (counsel block, court title, caption, title, statute), the lead-in, numbered paragraphs
-- (Fed. R. Civ. P. 10(b)), Roman-numeral level-1 headings, lettered prayer items, the jury demand, the
-- signature block and the verification. Footer text is filled in by docx/render.sh.
-- Everything case-specific comes from the sample's frontmatter, never from this file.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- one paragraph: style, extra pPr (schema order after pStyle), runs
local function xpara(style, ppr, runs)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function spacer(twips)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

local function caption(parties, case_number)
  -- one row: the party groups in the left cell, ruled right and below (typst caption()), the case number at right
  local left = ""
  for _, s in ipairs(parties) do
    for _, n in ipairs(s.names or {}) do left = left .. xpara("Single", "", run(plain(n))) end
    left = left .. xpara("Single", '<w:spacing w:before="104" w:after="208" w:line="340" w:lineRule="exact"/><w:jc w:val="right"/>', run(plain(s.designation)))
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local right = xpara("Single", '<w:spacing w:before="52" w:after="0" w:line="340" w:lineRule="exact"/><w:ind w:left="104" w:firstLine="0"/>', run("Case No. " .. case_number))
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="156"/><w:gridCol w:w="4308"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/>' .. rule .. '</w:tcPr>' .. left .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="156" w:type="dxa"/></w:tcPr>' .. xpara("Single", "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4308" w:type="dxa"/></w:tcPr>' .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

-- Cover (typst cover()): counsel block, 0.8 in, court title, 0.3 in, caption, title, statute.
local function cover(meta)
  local out = {}
  for _, l in ipairs(meta.counsel or {}) do
    out[#out + 1] = raw(xpara("Single", "", run(plain(l))))
  end
  local courts = meta.court or {}
  for i, l in ipairs(courts) do
    local ppr = ''
    if i == 1 then ppr = ppr .. '<w:spacing w:before="1152" w:after="0" w:line="340" w:lineRule="exact"/>' end
    if i == #courts then ppr = ppr .. '<w:spacing w:before="' .. (i == 1 and 1152 or 0) .. '" w:after="432" w:line="340" w:lineRule="exact"/>' end
    out[#out + 1] = raw(xpara("CourtTitle", ppr, run(plain(l))))
  end
  out[#out + 1] = raw(spacer(260))
  out[#out + 1] = caption(meta.caption, plain(meta.case_number))
  out[#out + 1] = raw(xpara("DocTitle", '', run(plain(meta.title), true)))
  if meta.statute then out[#out + 1] = raw(xpara("Centered", '', run("(" .. plain(meta.statute) .. ")"))) end
  return out
end

-- Signature block (typst signature-block()): date line, then the firm block at 2.5 in, kept together.
local function signature(sig, date)
  local out = {}
  local function keep(x) return x:gsub('<w:pStyle w:val="([^"]+)"/>', '<w:pStyle w:val="%1"/><w:keepNext/>', 1) end
  if date then
    out[#out + 1] = raw(keep(xpara("SingleIndent", '<w:spacing w:before="390" w:after="0" w:line="340" w:lineRule="exact"/>', run(plain(date)))))
  end
  out[#out + 1] = raw(spacer(208))
  for _, l in ipairs(sig.preamble or {}) do out[#out + 1] = raw(keep(xpara("SigBlock", '', run(plain(l))))) end
  if sig.firm then out[#out + 1] = raw(keep(xpara("SigBlock", '', run(plain(sig.firm), true)))) end
  if sig.role then out[#out + 1] = raw(keep(xpara("SigBlock", '', run(plain(sig.role))))) end
  out[#out + 1] = raw(spacer(340))
  out[#out + 1] = raw(keep(xpara("SigBlock", '', run("/s/ " .. plain(sig.signer)))))
  out[#out + 1] = raw(keep(xpara("SigBlock", '', run(plain(sig.signer)))))
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = raw(keep(xpara("SigBlock", '', run(plain(l))))) end
  if sig.bar then out[#out + 1] = raw(xpara("SigBlock", '', run(plain(sig.bar)))) end
  return out
end

-- Verification of factual allegations (typst verification()): its own page.
local function verification(v)
  local out = {}
  out[#out + 1] = raw(xpara("Heading2", '<w:pageBreakBefore/><w:jc w:val="center"/>', run(plain(v.heading), true)))
  out[#out + 1] = pandoc.Div({ pandoc.Para(v.text) }, pandoc.Attr("", {}, { ["custom-style"] = "Verification" }))
  if v.date then out[#out + 1] = raw(xpara("SingleIndent", '<w:spacing w:before="390" w:after="0" w:line="340" w:lineRule="exact"/>', run(plain(v.date)))) end
  out[#out + 1] = raw(spacer(624))
  out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="SigBlock"/><w:pBdr><w:top w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr><w:ind w:left="4320" w:right="720" w:firstLine="0"/></w:pPr></w:p>')
  out[#out + 1] = raw(xpara("SigBlock", '<w:ind w:left="4320" w:firstLine="0"/>', run(plain(v.signer))))
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local m = {
    counsel = meta.counsel, court = meta.court, caption = meta.caption, case_number = meta.case_number,
    title = meta.title, statute = meta.statute, opening = meta.opening, jury = meta.jury_demand,
    signature = meta.signature, date = meta.date, verification = meta.verification,
  }
  for _, k in ipairs({ "court", "case_number", "caption", "counsel", "title", "signature" }) do
    if m[k] == nil then error("akd-complaint: the sample frontmatter needs `" .. k .. "`", 0) end
  end
  -- plain Lua tables for the cover/signature helpers
  local function listify(v)
    if v == nil then return nil end
    local t = {}
    for i, x in ipairs(v) do t[i] = x end
    return t
  end
  local cover_meta = {
    counsel = listify(m.counsel), court = listify(m.court), case_number = plain(m.case_number),
    title = m.title, statute = m.statute and plain(m.statute) or nil,
  }
  cover_meta.caption = {}
  for _, p in ipairs(m.caption) do
    local names = {}
    for _, n in ipairs(p.names or {}) do names[#names + 1] = n end
    cover_meta.caption[#cover_meta.caption + 1] = { names = names, designation = p.designation }
  end
  local sig = m.signature
  local sig_meta = {
    preamble = sig.preamble and listify(sig.preamble) or nil,
    firm = sig.firm, role = sig.role, signer = plain(sig.signer),
    lines = sig.lines and listify(sig.lines) or nil, bar = sig.bar,
  }

  local out = {}
  local function add(b) out[#out + 1] = b end
  for _, b in ipairs(cover(cover_meta)) do add(b) end
  if m.opening then
    add(pandoc.Div({ pandoc.Para(m.opening) }, pandoc.Attr("", {}, { ["custom-style"] = "LeadIn" })))
  end

  -- body: paragraphs numbered 1, 2, ... (Fed. R. Civ. P. 10(b)); level-1 headings Roman numerals;
  -- lists lettered (a), (b), ...; quotations single-spaced and indented
  local n, h1 = 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.Space() })
      inl:extend(b.content)
      add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" })))
    elseif b.t == "Header" then
      if b.level == 1 then
        h1 = h1 + 1
        b.content:insert(1, pandoc.Space())
        b.content:insert(1, pandoc.Str(roman(h1) .. "."))
      end
      add(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local label = (b.t == "OrderedList") and ("(" .. string.char(96 + i) .. ")") or "\u{2022}"
        local first = item[1]
        local rest = { table.unpack(item, 2) }
        if first and (first.t == "Para" or first.t == "Plain") then
          local inl = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
          inl:extend(first.content)
          add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Relief" })))
        end
        for _, x in ipairs(rest) do add(x) end
      end
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(b.content) do
        if x.t == "Para" or x.t == "Plain" then
          add(pandoc.Div({ pandoc.Para(x.content) }, pandoc.Attr("", {}, { ["custom-style"] = "Quote" })))
        else
          add(x)
        end
      end
    else
      add(b)
    end
  end

  if m.jury then
    add(raw(xpara("Centered", '<w:keepNext/><w:spacing w:before="390" w:after="390" w:line="340" w:lineRule="exact"/>', run("DEMAND FOR JURY TRIAL", true))))
    add(pandoc.Div({ pandoc.Para(pandoc.Str("Plaintiff demands a trial by jury on all issues so triable.")) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" })))
  end
  for _, b in ipairs(signature(sig_meta, m.date)) do add(b) end
  if m.verification then
    for _, b in ipairs(verification({
      heading = plain(m.verification.heading), text = m.verification.text,
      date = m.verification.date and plain(m.verification.date) or nil, signer = plain(m.verification.signer),
    })) do add(b) end
  end

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end

-- wvnd memorandum of law (motion brief), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/wvnd-motion-brief.typ: court title, caption (a ")" column; the case number beside its row),
-- the brief title, the body (first-line indent, footnotes native), headings numbered I. / A. / 1. (levels 2-4),
-- the signature block (LR Gen P 5.03(c); Fed. R. Civ. P. 11(a)), and the certificate of service on its own page
-- with the caption repeated (LR Gen P 5.06(e)). Every word comes from the sample's frontmatter or body.
-- Known differences: the number-to-text gap is a tab stop (typst: a grid cell); levels 3 and 4 do not occur in the
-- sample and are set as hanging labels at 0.5 in and 1 in. Pages are counted on the LibreOffice PDF (see README).

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX" }

local function xesc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function run(text, rpr)
  return '<w:r>' .. (rpr or "") .. '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

local BR = "<w:r><w:br/></w:r>"
local TAB = "<w:r><w:tab/></w:r>"

local function px(style_id, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style_id .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (inner or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- frontmatter strings are markdown (case names and role lines are italic): emphasis and strong become runs
local function inl_xml(inlines)
  local out = {}
  local function walk(list, rpr)
    for _, x in ipairs(list) do
      if x.t == "Str" then
        out[#out + 1] = run(x.text, rpr)
      elseif x.t == "Space" or x.t == "SoftBreak" then
        out[#out + 1] = run(" ", rpr)
      elseif x.t == "Emph" then
        walk(x.content, "<w:rPr><w:i/><w:iCs/></w:rPr>")
      elseif x.t == "Strong" then
        walk(x.content, "<w:rPr><w:b/><w:bCs/></w:rPr>")
      else
        out[#out + 1] = run(plain(pandoc.Inlines({ x })), rpr)
      end
    end
  end
  walk(inlines, nil)
  return table.concat(out)
end

local function inls_of(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "table" and v.t == nil and v[1] ~= nil and v[1].t ~= nil then return v end
  return pandoc.Inlines({ pandoc.Str(plain(v)) })
end

local function roman(n) return ROMAN[n] or tostring(n) end
local function letter(n) return string.char(64 + n) end

-- the caption: a ")" column (3.4 in | 0.3 in | the rest). Each line is one exact 13.8 pt row, so the ")" marks line up.
local function caption_xml(meta, page_break)
  local cap = meta.caption
  local rows = {}
  local case_row = tonumber(plain(cap.case_row or 0)) or 0
  for i, item in ipairs(cap.lines) do
    local indent, text = nil, nil
    if item.indent ~= nil then
      indent = tonumber(plain(item.indent))
      text = plain(item.text)
    else
      text = plain(item)
    end
    local left_ppr = indent and ('<w:ind w:left="' .. math.floor(indent * 1440) .. '" w:firstLine="0"/>') or ""
    local right = (i - 1 == case_row) and run("No. " .. plain(meta.case_number)) or ""
    rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="276" w:hRule="exact"/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/></w:tcPr>' .. px("CaptionLine", run(text), left_ppr) .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="432" w:type="dxa"/></w:tcPr>' .. px("CaptionLine", run(")")) .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="4032" w:type="dxa"/></w:tcPr>' .. px("CaptionLine", right) .. "</w:tc></w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="432"/><w:gridCol w:w="4032"/></w:tblGrid>'
    .. table.concat(rows) .. "</w:tbl>"
end

local function court_title_xml(meta, page_break)
  local inner = run("UNITED STATES DISTRICT COURT") .. BR .. run("NORTHERN DISTRICT OF WEST VIRGINIA")
  if meta.division ~= nil then inner = inner .. BR .. run(plain(meta.division)) end
  return px("CourtTitle", inner, (page_break and "<w:pageBreakBefore/>" or "") .. '<w:spacing w:before="0" w:after="480" w:line="480" w:lineRule="exact"/>')
end

-- signature block after the conclusion: "DATED:" then the firm block at the middle of the page
local function signature_xml(meta)
  local sig = meta.signature
  local lines = {}
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = l end
  local has_email, has_phone = false, false
  for _, l in ipairs(lines) do
    local s = plain(l)
    if s:find("@", 1, true) then has_email = true end
    if s:match("%(?%d%d%d%)?[ .-]?%d%d%d[ .-]?%d%d%d%d") then has_phone = true end
  end
  assert(has_email, "wvnd-motion-brief: the signature lines need an e-mail address (Fed. R. Civ. P. 11(a))")
  assert(has_phone, "wvnd-motion-brief: the signature lines need a telephone number (Fed. R. Civ. P. 11(a))")
  local out = {}
  out[#out + 1] = px("SigDate", run("DATED: " .. plain(meta.date)))
  out[#out + 1] = px("SigParty", run("Respectfully submitted,"))
  out[#out + 1] = px("SigLine", run("s/ " .. plain(sig.signer)), '<w:spacing w:before="480" w:after="120" w:line="240" w:lineRule="auto"/>')
  for _, l in ipairs(lines) do
    out[#out + 1] = px("SigLine", inl_xml(inls_of(l)))
  end
  return table.concat(out)
end

-- the certificate of service: its own page, the caption repeated, the served counsel, the signature
local function certificate_xml(meta)
  local c = meta.certificate_of_service
  assert(c and c.served, "wvnd-motion-brief: the certificate needs served (who was served, LR Gen P 5.06(e))")
  local out = {}
  out[#out + 1] = court_title_xml(meta, true)
  out[#out + 1] = caption_xml(meta)
  out[#out + 1] = px("DocTitle", run("CERTIFICATE OF SERVICE"))
  out[#out + 1] = px("BodyText", run("I hereby certify that on " .. plain(c.date) .. ", I electronically filed the foregoing with the Clerk of the District Court using the CM/ECF system, which will send notification of such filing electronically to the following counsel of record, who are served by that means:"))
  for _, s in ipairs(c.served) do
    out[#out + 1] = px("Served", inl_xml(inls_of(s)))
  end
  out[#out + 1] = px("SigLine", run("s/ " .. plain(c.signer)), '<w:spacing w:before="480" w:after="120" w:line="240" w:lineRule="auto"/>')
  out[#out + 1] = px("SigLine", inl_xml(inls_of(c.role)))
  return table.concat(out)
end

function Pandoc(doc)
  local meta = doc.meta
  assert(meta.case_number, "wvnd-motion-brief: frontmatter needs case_number")
  assert(meta.caption, "wvnd-motion-brief: frontmatter needs caption (lines and case_row)")
  assert(meta.brief_title, "wvnd-motion-brief: frontmatter needs brief_title")
  assert(meta.signature, "wvnd-motion-brief: frontmatter needs signature")
  assert(meta.certificate_of_service, "wvnd-motion-brief: frontmatter needs certificate_of_service")

  local out = {}
  out[#out + 1] = raw(court_title_xml(meta, false))
  out[#out + 1] = raw(caption_xml(meta))
  out[#out + 1] = raw(px("DocTitle", run(plain(meta.brief_title))))

  local h2, h3, h4 = 0, 0, 0
  local function header_block(b)
    local lvl = b.level
    local label
    if lvl == 1 then
      h2, h3, h4 = 0, 0, 0
    elseif lvl == 2 then
      h2 = h2 + 1; h3 = 0; h4 = 0
      label = roman(h2) .. "."
    elseif lvl == 3 then
      h3 = h3 + 1; h4 = 0
      label = letter(h3) .. "."
    else
      h4 = h4 + 1
      label = tostring(h4) .. "."
    end
    local inl = b.content
    if label then
      table.insert(inl, 1, pandoc.RawInline("openxml", TAB))
      table.insert(inl, 1, pandoc.RawInline("openxml", run(label)))
    end
    b.content = inl
    return b
  end

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = header_block(b)
    elseif b.t == "DefinitionList" then
      for _, item in ipairs(b.content) do
        out[#out + 1] = pandoc.Para(item[1])
        for _, d in ipairs(item[2]) do
          for _, db in ipairs(d) do out[#out + 1] = db end
        end
      end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = raw(signature_xml(meta))
  out[#out + 1] = raw(certificate_xml(meta))
  -- pandoc would print the metadata title and date above the body; the caption, title and date are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

-- Complaint, United States District Court for the Eastern District of California (caed), DOCX engine
-- (docs/DOCX.md). Markdown contract -> Word document on docx/reference.docx. Mirrors typst/caed-complaint.typ:
-- the cover (counsel block, court title, caption, title, jury demand), the lead-in, numbered paragraphs
-- (Fed. R. Civ. P. 10(b)), the prayer items numbered 1, 2, ..., the signature block.
-- Everything case-specific comes from the sample's frontmatter, never from this file.
-- Counter note: the numbered paragraphs are written as text ("N." and a tab), as the typst template does.

local PT = 20 -- twips per point
local COUNSEL_LINE = 276 -- single-spaced line: 13.8 pt (typst single-leading 0.5em on a 0.65em line box)
local ROW = 24 * PT -- one numbered line (exact 24 pt)
local MIN_COUNSEL_ROWS = 7 -- L.R. 131(a): counsel on lines 1 to 7; the court title starts on line 8

local para_no = 0

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

-- one paragraph: style, extra pPr (after pStyle), runs
local function xpara(style, ppr, runs)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function spacer(twips)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function tab_run() return '<w:r><w:tab/></w:r>' end

-- Counsel block (typst counsel-block): one single-spaced line per item; the court title starts on
-- the grid line after at least MIN_COUNSEL_ROWS numbered lines.
local function counsel(lines)
  local out = {}
  for _, l in ipairs(lines) do out[#out + 1] = raw(xpara("Single", "", run(plain(l)))) end
  local h = #lines * COUNSEL_LINE
  local rows = math.max(MIN_COUNSEL_ROWS * ROW, math.ceil(h / ROW) * ROW)
  return out, rows - h
end

local function caption(parties, case_number, brief_title, jury)
  local left = ""
  for k, p in ipairs(parties) do
    if k > 1 then left = left .. xpara("Single", "", run("v.")) end
    for _, n in ipairs(p.names or {}) do left = left .. xpara("Single", "", run(plain(n))) end
    left = left .. xpara("Single", "", run(plain(p.designation)))
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local right = xpara("Single", '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>', run("Case No.: " .. case_number))
  right = right .. xpara("Single", '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>', run(brief_title, true))
  if jury then
    right = right .. xpara("Single", '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>', run("DEMAND FOR JURY TRIAL", true))
  end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="288"/><w:gridCol w:w="4104"/></w:tblGrid>'
    .. '<w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/>' .. rule .. '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="160" w:type="dxa"/></w:tcMar></w:tcPr>' .. left .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. xpara("Single", "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4104" w:type="dxa"/></w:tcPr>' .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

-- Cover (typst cover()): counsel, court title (after the counsel grid), one grid line, caption, then a page break.
local function cover(meta)
  local out, pad = counsel(meta.counsel or {})
  local courts = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF CALIFORNIA" }
  if meta.division then courts[#courts + 1] = plain(meta.division):upper() end
  for i, l in ipairs(courts) do
    local ppr = '<w:jc w:val="center"/>'
    if i == 1 then ppr = '<w:spacing w:before="' .. math.floor(pad) .. '" w:after="0" w:line="' .. ROW .. '" w:lineRule="exact"/>' .. ppr end
    out[#out + 1] = raw(xpara("CourtTitle", ppr, run(l)))
  end
  out[#out + 1] = raw(spacer(ROW))
  out[#out + 1] = caption(meta.caption.parties, plain(meta.case_number), plain(meta.brief_title), meta.jury_demand == true)
  return out
end

-- Signature block (typst signature-block()): the date at left, the firm at right; "By: /s/" and the signer.
local function keep_last(blocks)
  local last = blocks[#blocks]
  if last and last.t == "Para" then
    blocks[#blocks] = styled("BodyKeep", { last })
  elseif last and last.t == "Div" and last.attributes["custom-style"] then
    last.attributes["custom-style"] = last.attributes["custom-style"] .. "Keep" -- the keep-with-next variant of that style
  end
end

local function signature(sig, date)
  local function lines(items, style)
    local s = ""
    for _, l in ipairs(items or {}) do s = s .. xpara(style or "SigBlock", "", run(plain(l))) end
    return s
  end
  local right = lines(sig.firm, "Single")
  right = right .. xpara("SingleKeep", '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="exact"/>', run(""))
  right = right .. xpara("SingleKeep", "", run("By: /s/ " .. plain(sig.signer)))
  right = right .. xpara("SingleKeep", "", run(plain(sig.signer)))
  right = right .. lines(sig.lines, "Single")
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="3744"/><w:gridCol w:w="288"/><w:gridCol w:w="4968"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/></w:tcPr>' .. xpara("SingleKeep", "", run("Dated: " .. plain(date))) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. xpara("SingleKeep", "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4968" w:type="dxa"/></w:tcPr>' .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

-- A numbered allegation: "N." then a tab to the text position (typst: 0.3 in after the number).
local function allegation(p)
  para_no = para_no + 1
  table.insert(p.content, 1, pandoc.RawInline("openxml", run(para_no .. ".") .. tab_run()))
  return styled("Allegation", { p })
end

-- Unnumbered paragraph: the marker "[unnumbered]" is removed (the WHEREFORE clause, the jury demand text).
local function unnumbered(p)
  local c = p.content
  table.remove(c, 1)
  if c[1] and c[1].t == "Space" then table.remove(c, 1) end
  return styled("Allegation", { p })
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end
  -- the lead-in starts page 2 (LeadIn style has pageBreakBefore: typst pagebreak() after the cover)
  if meta.lead_in then
    blocks[#blocks + 1] = styled("LeadIn", { pandoc.Para(meta.lead_in) })
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local c = b.content
      if c[1] and c[1].t == "Str" and c[1].text == "[unnumbered]" then
        blocks[#blocks + 1] = unnumbered(b)
      else
        blocks[#blocks + 1] = allegation(b)
      end
    elseif b.t == "OrderedList" then
      -- prayer items: numbered 1, 2, ... by the template (as the typst template numbers them)
      local start = b.start or 1
      for i, item in ipairs(b.content) do
        local p = item[1]
        table.insert(p.content, 1, pandoc.RawInline("openxml", run((start + i - 1) .. ".") .. tab_run()))
        blocks[#blocks + 1] = styled("Relief", { p })
      end
    elseif b.t == "HorizontalRule" then
      keep_last(blocks)
      blocks[#blocks + 1] = raw('<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:p>') -- the signature starts on the next numbered line (typst on-grid)
      blocks[#blocks + 1] = signature(meta.signature, meta.date)
    else
      blocks[#blocks + 1] = b
    end
  end
  return pandoc.Pandoc(blocks)
end

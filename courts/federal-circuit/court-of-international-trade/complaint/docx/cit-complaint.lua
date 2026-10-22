-- cit-complaint.lua: pandoc filter for the CIT complaint, docx engine (see ../README.md, "Engines").
-- Mirrors typst/cit-complaint.typ on the shared cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md,
-- "Cross-engine gate"): every paragraph is written here with exact line spacing at the typst pitch (24 pt body,
-- 14 pt single lines), its spaces and indents in twips, and its text through the shared break rules. The cover
-- (court, caption with a ")" column, title), numbered allegations (Rule 10(b)) with the number in a 0.6 in box (a tab
-- to 1.1 in), headings, lettered lists (a), (b), ..., and the signature block (Rule 11(a)).

local xe = require("docx.xengine")

-- the typst parameters, in twips (20 x pt)
local BODY, SINGLE = 480, 280          -- pitch, pitch-single
local INDENT = 720                     -- para-indent
local NUMBER_TAB = 1584                -- para-indent + number-box (1.1 in)
local ITEM_LEFT, ITEM_BOX = 1296, 576  -- item-indent + item-box (0.9 in), item-box (0.4 in)
local HEADING_ABOVE = 240              -- heading-above
local SIG_GAP = 240                    -- sig-gap
-- Text width 6 1/2 in = 9360 twips. Caption columns: party 3.4 in, ")" 0.3 in, court number the rest.
local CAP_LEFT, CAP_PAREN, CAP_RIGHT = 4896, 432, 4032
local DESIG_INDENT = 1728              -- caption-desig, 1.2 in
local COURT_INDENT = 288               -- caption-right, 0.2 in
local SIG_LEFT, SIG_RIGHT = 4032, 5328 -- sig-left 2.8 in, the rest

local stringify = pandoc.utils.stringify

local function line(runs, extra, before)
  return xe.para({ xe.spacing(before or 0, 0, SINGLE), extra or "" }, runs)
end

local function raw(xml) return xe.raw(xml) end

local function cell(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. paras .. '</w:tc>'
end

-- A table with no borders, no cell margins and fixed column widths.
local function xtable(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>')
end

-- An empty line of the body pitch (typst v(pitch)).
local function spacer()
  return raw(xe.para({ xe.spacing(0, 0, BODY) }, ""))
end

-- The caption (Rule 10(a)): every party line with a ")" on each row, the designation indented, the
-- court number at the right of the first row.
local function caption(meta)
  local lines = {}
  for i, side in ipairs(meta.caption) do
    for _, n in ipairs(side.names) do lines[#lines + 1] = { x = n } end
    lines[#lines + 1] = { x = side.designation, extra = xe.ind(DESIG_INDENT) }
    if i < #meta.caption then lines[#lines + 1] = { x = "v.", extra = xe.jc("center") } end
  end
  local rows = {}
  for k, l in ipairs(lines) do
    local right
    if k == 1 then
      local court = line(xe.runs("Court No. " .. stringify(meta.court_no)), xe.ind(COURT_INDENT))
      if meta.before then
        court = court .. line(xe.runs("Before: " .. stringify(meta.before)), xe.ind(COURT_INDENT))
      end
      right = cell(CAP_RIGHT, court, '<w:vMerge w:val="restart"/>')
    else
      right = cell(CAP_RIGHT, line(""), '<w:vMerge/>')
    end
    rows[#rows + 1] = '<w:tr>' .. cell(CAP_LEFT, line(xe.inl(l.x), l.extra)) ..
      cell(CAP_PAREN, line(xe.runs(")"))) .. right .. '</w:tr>'
  end
  return xtable({ CAP_LEFT, CAP_PAREN, CAP_RIGHT }, rows)
end

local function cover(meta)
  local out = {}
  for _, l in ipairs(meta.court) do
    out[#out + 1] = raw(line(xe.runs(stringify(l):upper(), { b = true }), xe.jc("center")))
  end
  out[#out + 1] = spacer()
  out[#out + 1] = caption(meta)
  out[#out + 1] = spacer()
  -- the title, and the page break after the cover
  out[#out + 1] = raw(line(xe.runs(stringify(meta.brief_title):upper(), { b = true }), xe.jc("center")))
  out[#out + 1] = raw('<w:p><w:pPr>' .. xe.spacing(0, 0, SINGLE) .. '</w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')
  return out
end

-- Signature block (Rule 11(a)): "Dated" at left, the counsel block at right; kept on one page.
local function signature(meta)
  local sig = meta.signature
  local right = { line(xe.runs("Respectfully submitted,")), line(xe.runs("/s/ " .. stringify(sig.signer)), nil, SIG_GAP) }
  for _, l in ipairs(sig.lines) do right[#right + 1] = line(xe.inl(l)) end
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(SIG_LEFT, line(xe.runs("Dated: " .. stringify(meta.date)))) ..
    cell(SIG_RIGHT, table.concat(right)) .. '</w:tr>'
  return { spacer(), xtable({ SIG_LEFT, SIG_RIGHT }, { row }) }
end

-- A doubled section sign ("§§ 2643(a)(1)") stays with its number, as the typst template boxes it; the shared
-- bind_signs (lib/pandoc/xengine.lua) binds a single sign only.
local function bind_double(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A body paragraph at the body pitch: first line indented 0.5 in; `lead` (runs) before its text.
local function body_para(inlines, lead)
  return raw(xe.para({ xe.style("BodyText"),
    '<w:tabs><w:tab w:val="left" w:pos="' .. NUMBER_TAB .. '"/></w:tabs>',
    xe.spacing(0, 0, BODY), xe.ind(0, nil, INDENT) }, (lead or "") .. xe.inl(bind_double(inlines))))
end

-- Lettered list: (a), (b), ... ; the letter at 0.5 in, the text at 0.9 in, wrapped lines hanging there.
local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("cit-complaint: a list item must be one paragraph", 0)
    end
    local lab = "(" .. string.char(string.byte("a") + i - 1) .. ")\t"
    out[#out + 1] = raw(xe.para({ xe.style("ListItem"), xe.spacing(0, 0, BODY), xe.ind(ITEM_LEFT, ITEM_BOX) },
      xe.runs(lab) .. xe.inl(bind_double(item[1].content))))
  end
  return out
end

local function heading(b)
  return raw(xe.para({ xe.style("Heading" .. math.min(b.level, 5)), xe.KEEP, xe.spacing(HEADING_ABOVE, 0, BODY),
    xe.ind(0, nil, 0), xe.jc("center") }, xe.runs(stringify(b.content):upper(), { b = true })))
end

function Pandoc(doc)
  local meta = doc.meta
  local unnumbered = {}
  for _, h in ipairs(meta.unnumbered or {}) do unnumbered[stringify(h)] = true end

  local out = cover(meta)
  if meta.lead_in then out[#out + 1] = body_para(meta.lead_in) end

  local n = 0
  local in_unnumbered = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      in_unnumbered = unnumbered[stringify(b.content)] == true
      out[#out + 1] = heading(b)
    elseif (b.t == "Para" or b.t == "Plain") and not in_unnumbered then
      n = n + 1
      out[#out + 1] = body_para(b.content, xe.runs(n .. ".\t"))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_para(b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, d in ipairs(lettered(b)) do out[#out + 1] = d end
    else
      error("cit-complaint: unsupported block " .. b.t, 0)
    end
  end

  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  -- pandoc writes the title and date metadata as paragraphs at the top; the cover carries them instead
  local meta_out = doc.meta
  meta_out.date = nil
  meta_out.title = nil
  return pandoc.Pandoc(out, meta_out)
end

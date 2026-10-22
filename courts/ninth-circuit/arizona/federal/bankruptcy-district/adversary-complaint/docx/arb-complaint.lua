-- Adversary complaint, Bankruptcy Court for the District of Arizona (arb), DOCX engine (docs/DOCX.md): what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/arb-adversary-complaint.typ does: the
-- filer block from line 1 (LRBP 9004-1(a)), the court title (LRBP 1005-1(a)), the dual caption (LRBP 9004-1(c), (e)),
-- the lead-in, the numbered allegations (Fed. R. Civ. P. 10(b), applied by FRBP 7010), the headings, the lettered
-- relief items, the jury demand when asked for, and the signature block. The page furniture is this filter's too,
-- since the footer names the paper and its adversary number: the footers (the pleading numbers 1 to 27 in a frame on
-- the page, the page number, the title and "ADV. NO.") go to $FORMBOOK_FOOTERS and the section that names them to
-- $FORMBOOK_FINAL (fb render, tools/fb/src/docxpass.rs). Everything printed comes from the sample's frontmatter and
-- body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered line, 320 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Allegations and relief
-- items stay pandoc paragraphs (styles Allegation and Relief Item of docx/reference.xml), so their footnotes are
-- Word's own.

local xe = require("docx.xengine")

local PITCH, SINGLE = 480, 320           -- typst pitch, pitch-single
local LINES = 27                         -- typst lines-per-page
local FILER_LINES = 7                    -- typst filer-lines
local TEXTW = 8640                       -- 8.5 in - 1.5 in - 1 in
local CAP_LEFT, CAP_GUTTER = 4464, 288   -- typst caption-left 3.1 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local OFFSET = 128                       -- typst single-offset 6.4 pt: a run of single lines starts this far below a
                                         -- numbered line (every single baseline on a numbered line's or 8 pt off it)
local CAP_PAD = 177                      -- typst caption-pad 9.6 pt, less the 0.75 pt rule LibreOffice adds to a row
local SIG_LEFT, SIG_GUTTER = 3744, 288   -- typst sig-left 2.6 in, sig-gutter 0.2 in
local NUMBERS_W = 1555                   -- typst left-margin - 0.42 in: the box of the pleading numbers
local FOOTER_LINE, FOOTER_SZ, FOOTER_GAP = 260, 22, 80   -- typst pitch-footer, footer-size, footer-line-gap
-- Word measures the footer from the page foot to its last line: the bottom margin (72 pt) less the gap above the
-- footer (typst footer-gap, 6 pt) and the footer's own height (two 13 pt lines and 4 pt between them).
local FOOTER_DIST = 1440 - 120 - 2 * FOOTER_LINE - FOOTER_GAP
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function text(v) return pandoc.utils.stringify(v) end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A run of single lines (typst line-run): `single-offset` above the first, `after` below the last; false is an
-- empty line.
local function run_of(lines, o)
  o = o or {}
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l or "", { before = i == 1 and OFFSET or 0, after = i == #lines and (o.after or 0) or 0,
      left = o.left, keep = o.keep })
  end
  return out
end

local function tc(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. table.concat(body) ..
    '</w:tc>'
end

local function tbl(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- First page: filer block, court title, dual caption
-- ---------------------------------------------------------------------------

local COURT = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF ARIZONA" }  -- LRBP 1005-1(a)

local function cover(meta, out)
  local filer = {}
  for _, l in ipairs(meta.filer) do filer[#filer + 1] = xe.inl(l) end
  -- at least filer-lines numbered lines, counted from the lines as typst counts them
  local used = OFFSET + #filer * SINGLE
  for _, x in ipairs(run_of(filer, { after = math.max(FILER_LINES, math.ceil(used / PITCH)) * PITCH - used })) do
    out[#out + 1] = x
  end
  for i, l in ipairs(COURT) do
    -- the caption a numbered line below (Word has no space before a table: the line above carries it)
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = PITCH, jc = "center", keep = true, after = i == #COURT and PITCH or 0 })
  end

  local debtor = meta.debtor
  local debtor_rows = { xe.runs("In re:"), false }
  for _, n in ipairs(debtor.names) do debtor_rows[#debtor_rows + 1] = xe.inl(n) end
  debtor_rows[#debtor_rows + 1] = false
  debtor_rows[#debtor_rows + 1] = xe.runs("Debtor.", { i = true })
  local case_rows = { xe.runs("Chapter " .. text(debtor.chapter)), false, xe.runs("Case No. " .. text(debtor.case_number)) }

  local party_rows = {}
  for k, party in ipairs(meta.parties) do
    if k > 1 then
      party_rows[#party_rows + 1] = false
      party_rows[#party_rows + 1] = xe.runs("v.")
      party_rows[#party_rows + 1] = false
    end
    for _, n in ipairs(party.names) do party_rows[#party_rows + 1] = xe.inl(n) end
    party_rows[#party_rows + 1] = false
    party_rows[#party_rows + 1] = xe.inl(party.designation, { i = true })
  end
  local title = meta.title:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  local adv_rows = { xe.runs("Adv. No. " .. text(meta.adversary_number)), false, xe.inl(title, { b = true }), false,
    xe.inl(meta.relief) }
  if meta.hearing then
    local hr = meta.hearing
    adv_rows[#adv_rows + 1] = false
    adv_rows[#adv_rows + 1] = xe.runs("Hearing date: " .. text(hr.date or ""))
    adv_rows[#adv_rows + 1] = xe.runs("Time: " .. text(hr.time or ""))
    adv_rows[#adv_rows + 1] = xe.runs("Place: " .. text(hr.place or ""))
  end

  local rule = '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>'
  local rows = {}
  for _, r in ipairs({ { debtor_rows, case_rows }, { party_rows, adv_rows } }) do
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      tc(CAP_LEFT, rule, run_of(r[1], { after = CAP_PAD })) .. tc(CAP_GUTTER, nil, { p("") }) ..
      tc(TEXTW - CAP_LEFT - CAP_GUTTER, '<w:tcMar><w:left w:w="' .. RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>',
        run_of(r[2], { after = CAP_PAD })) .. '</w:tr>'
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, rows)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el)
  local lvl = math.min(el.level, 3)
  local content = el.content
  if lvl == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, PITCH), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

-- A paragraph pandoc writes itself, in a style of docx/reference.xml, with a label and a tab before its text.
local function styled(style, label, inlines)
  local l = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(label .. "\t")) })
  l:extend(xe.inlines(inlines))
  return pandoc.Div({ pandoc.Para(l) }, { ["custom-style"] = style })
end

local function letter(n)
  local s = ""
  repeat
    n = n - 1
    s = string.char(97 + n % 26) .. s
    n = n // 26
  until n == 0
  return s
end

local function body(blocks, keep_last)
  local out = {}
  local n = 0
  for i, b in ipairs(blocks) do
    local keep = keep_last and i == #blocks and " Keep" or ""
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = styled("Allegation" .. keep, n .. ".", b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- relief items, lettered (a), (b), ... (typst enum "(a)"): the label half an inch in, the text a box after it
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Para" and item[1].t ~= "Plain") then
          error("arb-complaint: a relief item must be one paragraph")
        end
        local lab = b.t == "OrderedList" and ("(" .. letter(start + j - 1) .. ")") or "\u{2022}"
        out[#out + 1] = styled("Relief Item" .. (j == #b.content and keep or ""), lab, item[1].content)
      end
    else
      error("arb-complaint: unsupported block " .. b.t)
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local rows = { xe.runs("Respectfully submitted,"), false, xe.runs("/s/ " .. text(sig.signer)) }
  for _, l in ipairs(sig.lines or {}) do rows[#rows + 1] = xe.inl(l) end
  return tbl({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER }, { '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    tc(SIG_LEFT, nil, run_of({ xe.runs("Dated: " .. text(meta.date)) })) .. tc(SIG_GUTTER, nil, { p("") }) ..
    tc(TEXTW - SIG_LEFT - SIG_GUTTER, nil, run_of(rows)) .. '</w:tr>' })
end

-- ---------------------------------------------------------------------------
-- Page furniture: footers and the section
-- ---------------------------------------------------------------------------

local function footer(title, adv)
  local fr = '<w:framePr w:w="' .. NUMBERS_W .. '" w:h="' .. (LINES * PITCH) .. '" w:hRule="exact" w:hSpace="0"' ..
    ' w:wrap="around" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="1440"/>'
  local x = {}
  -- the pleading numbers: one per numbered line, right-aligned left of the rules (typst line-numbers)
  for i = 1, LINES do
    x[#x + 1] = '<w:p><w:pPr>' .. fr .. xe.spacing(0, 0, PITCH) .. xe.jc("right") .. '</w:pPr>' .. xe.runs(tostring(i)) ..
      '</w:p>'
  end
  local o = { sz = FOOTER_SZ }
  x[#x + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, FOOTER_LINE) .. xe.jc("center") .. '</w:pPr>' ..
    '<w:r>' .. xe.rpr(o) .. '<w:fldChar w:fldCharType="begin"/></w:r><w:r>' .. xe.rpr(o) ..
    '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>' .. xe.rpr(o) ..
    '<w:fldChar w:fldCharType="separate"/></w:r><w:r>' .. xe.rpr(o) .. '<w:t>1</w:t></w:r><w:r>' .. xe.rpr(o) ..
    '<w:fldChar w:fldCharType="end"/></w:r></w:p>'
  x[#x + 1] = '<w:p><w:pPr><w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>' ..
    xe.spacing(FOOTER_GAP, 0, FOOTER_LINE) .. xe.jc("left") .. '</w:pPr>' ..
    xe.runs(title .. (adv ~= "" and ("\tADV. NO. " .. adv) or ""), o) .. '</w:p>'
  return table.concat(x)
end

local function write_file(var, s)
  local path = os.getenv(var)
  if not path then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

local function furniture(meta)
  write_file("FORMBOOK_FOOTERS", "rIdArbFooter\t" ..
    footer(pandoc.text.upper(text(meta.footer_title)), text(meta.adversary_number)) .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdArbFooter"/>' ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160"' ..
    ' w:header="720" w:footer="' .. FOOTER_DIST .. '" w:gutter="0"/><w:pgBorders w:offsetFrom="text">' ..
    '<w:left w:val="double" w:sz="4" w:space="12" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders></w:sectPr>')
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 547(b)"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local t = a.text
      if #t >= 4 and t:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
        inlines[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return inlines
end

function Pandoc(doc)
  for _, k in ipairs({ "filer", "debtor", "adversary_number", "parties", "title", "relief", "footer_title", "date",
    "signature", "consent_to_final_orders" }) do
    if doc.meta[k] == nil then error("arb-complaint: missing required metadata field `" .. k .. "`", 0) end
  end
  local consent = text(doc.meta.consent_to_final_orders)
  if consent ~= "yes" and consent ~= "no" then
    error('arb-complaint: consent_to_final_orders must be "yes" or "no" (FRBP 7008(a))', 0)
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local raw = {}
  cover(meta, raw)
  if meta.lead_in then raw[#raw + 1] = p(xe.inl(meta.lead_in), { line = PITCH, first = 720, before = PITCH }) end
  local blocks = {}
  for _, x in ipairs(raw) do blocks[#blocks + 1] = xe.raw(x) end
  -- the last block is kept with the jury demand and the signature block
  for _, b in ipairs(body(doc.blocks, true)) do blocks[#blocks + 1] = b end
  if meta.jury_demand then
    blocks[#blocks + 1] = xe.raw(p(xe.runs("Plaintiff demands a trial by jury on all claims so triable. " ..
      "Fed. R. Civ. P. 38, as applied by FRBP 9015."), { line = PITCH, first = 720, keep = true }))
  end
  blocks[#blocks + 1] = xe.raw(signature(meta))
  furniture(meta)
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

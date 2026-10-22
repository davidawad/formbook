-- Adversary complaint, D.N.J. Bankr. (njb), docx engine (docs/DOCX.md). Mirrors typst/njb-adversary-complaint.typ:
--   * page 1: the counsel block (LBR 9004-1(a)), the court (two centred bold lines), the LBR 9004-1 note set right,
--     the two captions (each a one-row table: the left cell ruled at its right and foot; the case information
--     0.35 in right of the rule), all from the sample's frontmatter;
--   * page 2 on: the title, the lead-in, unnumbered; body paragraphs numbered 1., 2., ... (FRCP 10(b), via FRBP 7010):
--     the number at the indent, a tab to the text 1 in in; headings on the body pitch, kept with the next block
--     (level 1 centred bold capitals, level 3 bold italic); the WHEREFORE lead-in unnumbered; the prayer items
--     lettered (a), (b), ... half an inch in, the text hanging at 0.9 in; a bracketed note centred in italics;
--   * the signature block after the last paragraph and kept on one page with it: "Dated:" left of the first line,
--     the closing, the firm, the signer and the lines from 3.1 in (single lines).
-- The footer (the page number, centred) and the last section (letter, 1 in margins) are written for fb render
-- ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the base styles are in docx/reference.xml. Nothing case-specific is written
-- here: every string comes from the sample (the court's name and the LBR note are the court's, as in typst).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 560 the body, 320 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 560, 320                 -- typst pitch-body 28 pt, pitch-single 16 pt
local TW = 9360                               -- the text width: 6.5 in
local INDENT = 720                            -- typst para-indent, num-box, list-indent 0.5 in
local LIST_BOX = 576                          -- typst list-box 0.4 in
local CAP_LEFT = 4680                         -- typst cap-left 3.25 in
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local CAP_PAD_RIGHT = 200                     -- typst cap-pad-right 10 pt
local CAP_PAD_BELOW = 160 - 15                -- typst cap-pad-below 8 pt, less the rule LibreOffice sets below it
local CAP_RIGHT = 504                         -- typst cap-right 0.35 in
local SIG_COL = 4464                          -- typst sig-col 3.1 in
local GAP = 320                               -- typst gap 16 pt
local TEXT_ABOVE = 560                        -- typst text-above 28 pt
local SIG_ABOVE = 560                         -- typst sig-above 28 pt
local NOTE_SZ, FOOTER_SZ = 22, 24             -- typst note-size 11 pt, footer-size 12 pt (half points)
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge
local COURT = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEW JERSEY" }
local LBR = "Caption in Compliance with D.N.J. LBR 9004-1"

local function check(cond, msg)
  if not cond then error("njb-adversary-complaint docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tab, brk }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- Single lines, one paragraph each (metadata values or plain strings).
local function lines(list, o)
  local out = {}
  for _, l in ipairs(list) do out[#out + 1] = p(xe.inl(l), o) end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Footer and section
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FSZ = '<w:rPr><w:sz w:val="' .. FOOTER_SZ .. '"/><w:szCs w:val="' .. FOOTER_SZ .. '"/></w:rPr>'
local FOOTER_P = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r>' .. FSZ .. '<w:fldChar w:fldCharType="begin"/></w:r><w:r>' .. FSZ
  .. '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>' .. FSZ
  .. '<w:fldChar w:fldCharType="separate"/></w:r><w:r>' .. FSZ .. '<w:t>1</w:t></w:r><w:r>' .. FSZ
  .. '<w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdNjbFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover (typst cover)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function mar(top, left, bottom, right)
  return '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

-- One caption block (typst caption-block): two cells, the left ruled at its right and foot.
local function caption_block(left, right)
  local rule = ' w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local borders = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom' .. rule .. '<w:right' .. rule
    .. '</w:tcBorders>'
  return space(GAP) .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/>'
    .. '<w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. NOLOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TW - CAP_LEFT)
    .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. borders
    .. mar(0, 0, CAP_PAD_BELOW, CAP_PAD_RIGHT) .. '</w:tcPr>' .. lines(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TW - CAP_LEFT) .. '" w:type="dxa"/>' .. mar(0, CAP_RIGHT, CAP_PAD_BELOW, 0)
    .. '</w:tcPr>' .. lines(right) .. '</w:tc></w:tr></w:tbl>'
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function cover(m)
  local out = { lines(items(m.counsel)) }
  for k, l in ipairs(COURT) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", before = k == 1 and GAP or 0 })
  end
  out[#out + 1] = p(xe.runs(LBR, { sz = NOTE_SZ }), { jc = "right" })
  local left = { "In re:" }
  for _, l in ipairs(items(m.debtor)) do left[#left + 1] = l end
  left[#left + 1] = "Debtor."
  local right = { "Case No.: " .. txt(m.case_no), "Chapter " .. txt(m.chapter), "Judge: " .. txt(m.judge) }
  if m.hearing ~= nil then right[#right + 1] = m.hearing end
  out[#out + 1] = caption_block(left, right)
  local rows = {}
  for k, party in ipairs(items(m.caption.parties)) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, l in ipairs(items(party.names)) do rows[#rows + 1] = l end
    rows[#rows + 1] = party.designation
  end
  out[#out + 1] = caption_block(rows, { "Adv. Pro. No. " .. txt(m.adv_no) })
  -- the title opens page 2
  out[#out + 1] = p(xe.inl(upper(m.title), { b = true }), { jc = "center", brk = true })
  out[#out + 1] = space(TEXT_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block): "Dated:" left of the first line (a tab and a hanging indent), the rest
-- from SIG_COL; kept on one page
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local rows = { "Respectfully submitted,", "" }
  for _, l in ipairs(items(sig.firm)) do rows[#rows + 1] = l end
  rows[#rows + 1] = ""
  rows[#rows + 1] = "/s/ " .. txt(sig.signer)
  for _, l in ipairs(items(sig.lines)) do rows[#rows + 1] = l end
  local list, gap = {}, SIG_ABOVE
  for _, r in ipairs(rows) do
    if txt(r) == "" then gap = gap + SINGLE else
      list[#list + 1] = { xe.inl(r), gap }
      gap = 0
    end
  end
  local out = {}
  for i, l in ipairs(list) do
    local o = { before = l[2], left = SIG_COL, keep = i < #list }
    local body = l[1]
    if i == 1 then
      body = xe.runs("Dated: ") .. xe.inl(m.date) .. xe.runs("\t") .. body
      o.hanging, o.tab = SIG_COL, SIG_COL
    end
    out[#out + 1] = p(body, o)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body (typst render-chunk)
-- ---------------------------------------------------------------------------

local function body(blocks)
  local out = {}
  local n = 0
  for k, b in ipairs(blocks) do
    local keep = k == #blocks
    if b.t == "Header" then
      if b.level == 1 then
        out[#out + 1] = p(xe.inl(upper(b.content), { b = true }), { pitch = BODY, keep = true, jc = "center" })
      else
        out[#out + 1] = p(xe.inl(b.content, { b = true, i = true }), { pitch = BODY, keep = true })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local s = stringify(b)
      if s:match("^%[") then
        out[#out + 1] = p(xe.inl(b.content, { i = true }), { pitch = BODY, jc = "center", keep = keep })
      elseif s:match("^WHEREFORE") then
        out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, first = INDENT, keep = keep })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          { pitch = BODY, first = INDENT, tab = 2 * INDENT, keep = keep })
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local letter = "(" .. string.char(96 + start + i - 1) .. ")"
        out[#out + 1] = p(xe.runs(letter .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { pitch = BODY, left = INDENT + LIST_BOX, hanging = LIST_BOX, tab = INDENT + LIST_BOX,
            keep = keep and i == #b.content })
      end
    else
      error("njb-adversary-complaint.lua: unexpected block " .. b.t)
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 1408"; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("^[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "counsel", "debtor", "case_no", "chapter", "judge", "adv_no", "caption", "title", "date",
    "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  write_file("FORMBOOK_FOOTERS", "rIdNjbFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = { cover(m) }
  if m.lead_in then out[#out + 1] = p(xe.inl(m.lead_in), { pitch = BODY, first = INDENT }) end
  out[#out + 1] = body(doc.blocks)
  out[#out + 1] = signature(m)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

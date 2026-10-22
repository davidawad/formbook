-- Adversary complaint, W.D. Pa. Bankr. (pawb), docx engine (docs/DOCX.md). Mirrors typst/pawb-adversary-complaint.typ:
--   * the court title (two centred bold lines), the Form 416D caption (LBR 7010-1; a two-row table: the debtor, then
--     the parties, in the left column, ruled at its right, the debtor row at its top and the party row at its foot;
--     the case number and chapter, then the adversary number, beside it), the title, all from the frontmatter;
--   * the lead-in (the text before the first heading) unnumbered; then every paragraph numbered 1., 2., ...
--     (FRCP 10(b) via FRBP 7010; LBR 5005-13(b)(3)): the number at the indent, a tab to the text 1 in in; WHEREFORE
--     clauses unnumbered; headings bold on the body pitch, kept with the next block (level 1 centred capitals,
--     level 2 centred, level 3 bold italic at the margin); a paragraph of hard-broken lines (an address) as single
--     lines with a blank single line around it;
--   * the signature block (LBR 5005-6(d)) after the last paragraph and kept on one page with it;
--   * the certificate of service (from its heading on) on a new page, unnumbered.
-- The footer (the page number, centred, LBR 5005-13(b)(2)) and the last section (letter, 1 in margins) are written
-- for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the base styles are in docx/reference.xml. Nothing
-- case-specific is written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 280                 -- typst pitch-body 24 pt, pitch-single 14 pt
local TW = 9360                               -- typst text-width: 6.5 in
local INDENT = 720                            -- typst para-indent, num-box 0.5 in
local CAP_LEFT = 4896                         -- typst cap-left 3.4 in
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local RULE = 15                               -- LibreOffice sets a 0.75 pt rule inside the cell (typst strokes take no
                                              -- room): the cell padding beside it is that much less
local CAP_PAD = 200                           -- typst cap-pad 10 pt
local CAP_GUTTER = 360                        -- typst cap-gutter 0.25 in
local CAP_TOP1, CAP_TOP2, CAP_BELOW = 120, 240, 120 -- typst cap-top1 6 pt, cap-top2 12 pt, cap-below 6 pt
local DESIG_INDENT = 2160                     -- typst desig-indent 1.5 in
local COVER_GAP = 280                         -- typst cover-gap 14 pt
local TITLE_BELOW = 240                       -- typst title-below 12 pt
local LINES_GAP = 280                         -- typst lines-gap 14 pt
local SIG_GAP = 480                           -- typst sig-gap 24 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function check(cond, msg)
  if not cond then error("pawb docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, brk, tab }; single pitch by default.
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

local FOOTER_P = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdPawbFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court title, Form 416D caption, title (typst cover)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function mar(top, left, bottom, right)
  return '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

local function caption(m)
  local row1l = { p(xe.runs("In re:")), p(xe.inl(m.debtor.name)), p(xe.inl(m.debtor.designation), { left = DESIG_INDENT }) }
  local row1r = { p(xe.runs("Case No. " .. txt(m.bankruptcy_case))), p(xe.inl(m.chapter)) }
  local row2l = {}
  for k, party in ipairs(items(m.caption.parties)) do
    for i, n in ipairs(items(party.names)) do
      row2l[#row2l + 1] = p(xe.inl(n), { before = (k > 1 and i == 1) and SINGLE or 0 })
    end
    row2l[#row2l + 1] = p(xe.inl(party.designation), { left = DESIG_INDENT })
  end
  local adv = txt(m.adversary_number)
  local row2r = { p(xe.runs("Adv. Proc. No. " .. (adv ~= "" and adv or string.rep("_", 14)))) }
  local rule = ' w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local function borders(edge)
    return '<w:tcBorders><w:top' .. (edge == "top" and rule or ' w:val="nil"/>') .. '<w:left w:val="nil"/><w:bottom'
      .. (edge == "bottom" and rule or ' w:val="nil"/>') .. '<w:right' .. rule .. '</w:tcBorders>'
  end
  local rows = {
    { row1l, row1r, "top", CAP_TOP1, 0 },
    { row2l, row2r, "bottom", CAP_TOP2, CAP_BELOW },
  }
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TW - CAP_LEFT) .. '"/></w:tblGrid>' }
  for _, r in ipairs(rows) do
    local top = r[3] == "top" and (r[4] - RULE) or r[4]
    local bottom = r[3] == "bottom" and (r[5] - RULE) or r[5]
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. borders(r[3]) .. mar(top, 0, bottom, CAP_PAD)
      .. '</w:tcPr>' .. table.concat(r[1]) .. '</w:tc>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TW - CAP_LEFT) .. '" w:type="dxa"/>' .. mar(top, CAP_GUTTER, bottom, 0)
      .. '</w:tcPr>' .. table.concat(r[2]) .. '</w:tc></w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return p("", { pitch = COVER_GAP }) .. table.concat(out)
end

local function cover(m)
  return p(xe.runs("IN THE UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" })
    .. p(xe.runs("FOR THE WESTERN DISTRICT OF PENNSYLVANIA", { b = true }), { jc = "center" })
    .. caption(m)
    .. p(xe.inl(m.title, { b = true }), { jc = "center", before = COVER_GAP })
    .. p("", { pitch = TITLE_BELOW })
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block): single lines at the margin, kept together
-- ---------------------------------------------------------------------------

local function signature(m)
  local lines = { { xe.runs("Respectfully submitted,"), SIG_GAP }, { xe.runs("Date: ") .. xe.inl(m.date), SIG_GAP } }
  for _, b in ipairs(items(m.signature.blocks)) do
    lines[#lines + 1] = { xe.runs("/s/ ") .. xe.inl(b.signer), SIG_GAP }
    lines[#lines + 1] = { xe.runs(pandoc.text.upper(txt(b.signer))), 0 }
    lines[#lines + 1] = { xe.inl(b.pa_id), 0 }
    for _, l in ipairs(items(b.lines)) do lines[#lines + 1] = { xe.inl(l), 0 } end
  end
  local out = {}
  for i, l in ipairs(lines) do out[#out + 1] = p(l[1], { before = l[2], keep = i < #lines }) end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body (typst render-chunk)
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function has_break(b)
  for _, el in ipairs(b.content) do
    if el.t == "LineBreak" then return true end
  end
  return false
end

-- A paragraph of hard-broken lines: one single line each, a blank single line around them, kept whole.
local function hard_lines(b, keep)
  local lines, cur = {}, pandoc.Inlines({})
  for _, el in ipairs(b.content) do
    if el.t == "LineBreak" then
      lines[#lines + 1] = cur
      cur = pandoc.Inlines({})
    elseif not (el.t == "SoftBreak" and #cur == 0) then
      cur:insert(el)
    end
  end
  lines[#lines + 1] = cur
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.inl(l), { before = i == 1 and LINES_GAP or 0, after = i == #lines and LINES_GAP or 0,
      keep = i < #lines or keep })
  end
  return table.concat(out)
end

-- The blocks of one part; `numbering` numbers the paragraphs after the first heading; the last block is kept with
-- what follows when `keep_last`; the first opens a page when `brk_first`.
local function part(blocks, numbering, keep_last, brk_first)
  local out, n, started = {}, 0, false
  for k, b in ipairs(blocks) do
    local keep = keep_last and k == #blocks
    if b.t == "Header" then
      started = true
      local body = b.level == 1 and upper(b.content) or b.content
      out[#out + 1] = p(xe.inl(body, { b = true, i = b.level >= 3 }),
        { pitch = BODY, keep = true, jc = b.level <= 2 and "center" or "left", brk = brk_first and k == 1 })
    elseif b.t == "Para" or b.t == "Plain" then
      if has_break(b) then
        out[#out + 1] = hard_lines(b, keep)
      elseif numbering and started and not stringify(b):match("^WHEREFORE") then
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          { pitch = BODY, first = INDENT, tab = 2 * INDENT, keep = keep })
      else
        out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, first = INDENT, keep = keep })
      end
    else
      error("pawb.lua: unexpected block " .. b.t)
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("548(a)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."), and none between a doubled section sign or pilcrow and its number
-- ("§§ 1408"; the typst template boxes them): no-break spaces.
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
  for _, k in ipairs({ "debtor", "bankruptcy_case", "chapter", "caption", "title", "date", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  write_file("FORMBOOK_FOOTERS", "rIdPawbFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  -- the certificate of service (exemplar order: after the signature block) starts at its heading
  local main, cert = {}, {}
  for _, b in ipairs(doc.blocks) do
    if #cert == 0 and b.t == "Header" and stringify(b.content):upper():match("^CERTIFICATE") then cert[1] = b
    elseif #cert > 0 then cert[#cert + 1] = b
    else main[#main + 1] = b end
  end
  local out = { cover(m), part(main, true, true), signature(m) }
  if #cert > 0 then
    out[#out + 1] = part(cert, false, false, true)
  end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

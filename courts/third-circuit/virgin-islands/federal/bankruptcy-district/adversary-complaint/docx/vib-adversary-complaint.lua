-- Adversary complaint, United States Bankruptcy Court, District of the Virgin Islands (vib), docx engine
-- (docs/DOCX.md). Mirrors typst/vib-adversary-complaint.typ:
--   * the court header (two centred bold single lines), the caption (a table of two rows: the parties at the left in
--     a column ruled on the right and below each row, Form 416; the chapter and case number, then the adversary
--     number and its note at the right; VIB-AC-CAPTION) and the title, all from the sample's frontmatter;
--   * the body: every "1." item one paragraph numbered from one counter through the whole document (the typed
--     numbers are not used; VIB-AC-NUMBER, LBR 5005-1(A)): the number at the indent, a tab to the text 1 in in;
--     other paragraphs unnumbered with a first-line indent; headings centred bold on the body pitch, kept with the
--     next block; footnotes as Word footnotes;
--   * the signature block (VIB-AC-SIGNATURE): "Dated:" at the margin, each counsel group in the signature column,
--     "- and –" between two groups, kept on one page with the last paragraph.
-- The footer (the short title at the left, "Page n of N" at the right; VIB-AC-PAGE) and the last section (letter,
-- 1 in margins) are written for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the body styles are in
-- docx/reference.xml. Nothing case-specific is written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body 24 pt, pitch-single 13.8 pt
local TW = 9360                               -- typst text-width: 6.5 in
local CAP_LEFT = 4968                         -- typst cap-left 3.45 in
local CAP_PAD = 288                           -- typst cap-pad 0.2 in
local CAP_TOP, CAP_BOTTOM = 120, 200          -- typst cap-top 6 pt, cap-bottom 10 pt
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local CAP_RULE_TW = 15                        -- the same rule in twips: LibreOffice sets a cell's bottom rule below
                                              -- the row (typst strokes take no room), so the bottom margin is less
local DESIGNATION = 720                       -- typst designation-indent 0.5 in
local SIG_COL = 4320                          -- typst sig-col 3.0 in
local FOOTER_PAGE = 1872                      -- typst footer-page 1.3 in
local CAPTION_ABOVE, TITLE_ABOVE = 480, 480   -- typst caption-above, title-above 24 pt
local TEXT_ABOVE = 276                        -- typst text-above 13.8 pt
local SIG_ABOVE, SIG_GAP = 480, 276           -- typst sig-above 24 pt, sig-gap 13.8 pt
local FOOTER = 432                            -- the footer's last line box ends 0.3 in above the page edge

local function check(cond, msg)
  if not cond then error("vib-adversary-complaint docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, jc, keep }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Single-pitch lines (typst lines): an item is a metadata value, a string of runs (`raw`), or "" (a blank single
-- line, added to the space above the next); o = { above, left, jc, keep (every line kept with the next) }.
local function lines(list, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for _, l in ipairs(list) do
    if type(l) == "string" and l == "" then gap = gap + SINGLE else
      local body = type(l) == "table" and l.raw or xe.inl(l)
      out[#out + 1] = p(body, { before = gap, left = o.left, jc = o.jc, keep = o.keep })
      gap = 0
    end
  end
  return table.concat(out)
end

local function raw(s) return { raw = s } end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" '
  .. 'w:noHBand="0" w:noVBand="0"/>'

local function tc(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>"
    .. paras .. "</w:tc>"
end

local function tbl(widths, rows)
  local cols = {}
  for _, w in ipairs(widths) do cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Footer (VIB-AC-PAGE) and section
-- ---------------------------------------------------------------------------

local function field(name)
  return '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> ' .. name
    .. ' </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
end

-- The short title at the left (it wraps before the page column), "Page n of N" at the right on its last line.
local function footer(m)
  local title = pandoc.text.upper(txt(m.footer or m.title))
  local cell = '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/></w:tcMar>'
  return tbl({ TW - FOOTER_PAGE, FOOTER_PAGE }, { "<w:tr>"
    .. tc(TW - FOOTER_PAGE, p(xe.runs(title)), cell)
    .. tc(FOOTER_PAGE, p(xe.runs("Page ") .. field("PAGE") .. xe.runs(" of ") .. field("NUMPAGES"), { jc = "right" }),
      cell .. '<w:vAlign w:val="bottom"/>')
    .. "</w:tr>" }) .. p("", { pitch = 20 })
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdVibFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Court header, caption, title (VIB-AC-CAPTION)
-- ---------------------------------------------------------------------------

local function party(pt)
  return lines(items(pt.names)) .. lines({ pt.designation }, { left = DESIGNATION })
end

local function cover(m)
  local out = {}
  out[#out + 1] = lines({ raw(xe.runs("IN THE DISTRICT COURT OF THE VIRGIN ISLANDS", { b = true })),
    raw(xe.runs("DIVISION OF " .. pandoc.text.upper(txt(m.division)) .. ", BANKRUPTCY DIVISION", { b = true })) },
    { jc = "center" })
  local sides, adv = items(m.caption), m.adversary
  local rule = 'w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local bottom = CAP_BOTTOM - CAP_RULE_TW
  local lmar = '<w:tcBorders><w:bottom ' .. rule .. '<w:right ' .. rule .. '</w:tcBorders><w:tcMar><w:top w:w="'
    .. CAP_TOP .. '" w:type="dxa"/><w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD
    .. '" w:type="dxa"/></w:tcMar>'
  local rmar = '<w:tcMar><w:top w:w="' .. CAP_TOP .. '" w:type="dxa"/><w:left w:w="' .. CAP_PAD
    .. '" w:type="dxa"/><w:bottom w:w="' .. bottom .. '" w:type="dxa"/></w:tcMar>'
  local right_w = TW - CAP_LEFT
  local adv_lines = { raw(xe.runs("Adv. Proc. No. " .. txt(adv.number))) }
  if adv.note then adv_lines[#adv_lines + 1] = ""; adv_lines[#adv_lines + 1] = adv.note end
  local row = function(l, r)
    return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. tc(CAP_LEFT, l, lmar) .. tc(right_w, r, rmar) .. "</w:tr>"
  end
  out[#out + 1] = p("", { pitch = CAPTION_ABOVE })
  out[#out + 1] = tbl({ CAP_LEFT, right_w }, {
    row(lines({ raw(xe.runs("In re:")), "" }) .. party(m.debtor),
      lines({ m.chapter, "", raw(xe.runs("Case No. " .. txt(m.case_number))) })),
    row(party(sides[1]) .. lines({ "", raw(xe.runs("v.")), "" }) .. party(sides[2]), lines(adv_lines)),
  })
  out[#out + 1] = lines({ raw(xe.runs(pandoc.text.upper(txt(m.title)), { b = true })) },
    { above = TITLE_ABOVE, jc = "center" })
  out[#out + 1] = p("", { pitch = TEXT_ABOVE })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (VIB-AC-SIGNATURE)
-- ---------------------------------------------------------------------------

local function signature(m)
  local out = { lines({ raw(xe.runs("Dated: " .. txt(m.date))) }, { above = SIG_ABOVE, keep = true }) }
  local groups = items(m.signature)
  for i, g in ipairs(groups) do
    if i > 1 then out[#out + 1] = lines({ raw(xe.runs("- and –")) }, { above = SIG_GAP, left = SIG_COL, keep = true }) end
    local ls = {}
    if g.signer then ls[#ls + 1] = raw(xe.runs("By: /s/ ") .. xe.inl(g.signer)) end
    for _, l in ipairs(items(g.lines)) do ls[#ls + 1] = l end
    local x = lines(ls, { above = SIG_GAP, left = SIG_COL, keep = i < #groups })
    if i == #groups then
      -- every line but the last kept with the next
      x = lines({ table.unpack(ls, 1, #ls - 1) }, { above = SIG_GAP, left = SIG_COL, keep = true })
        .. lines({ ls[#ls] }, { above = #ls == 1 and SIG_GAP or 0, left = SIG_COL })
    end
    out[#out + 1] = x
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A paragraph pandoc writes (so its footnotes are Word footnotes): `label` and a tab, then the text.
local function styled(style, label, content)
  local inl = pandoc.Inlines({})
  if label then inl:insert(pandoc.RawInline("openxml", xe.runs(label .. "\t"))) end
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
end

-- The body as blocks; the last paragraph is kept with the signature ("... Keep" styles).
local function body(blocks)
  local flat = {}
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        flat[#flat + 1] = { numbered = true, content = pandoc.utils.blocks_to_inlines(item) }
      end
    elseif b.t == "Para" or b.t == "Plain" then
      flat[#flat + 1] = { content = b.content }
    elseif b.t == "Header" then
      flat[#flat + 1] = { header = b.content }
    else
      error("vib-adversary-complaint.lua: unexpected block " .. b.t)
    end
  end
  check(#flat > 0 and not flat[#flat].header, "the body must end with a paragraph (the signature is set with it)")
  local out = pandoc.Blocks({})
  local n = 0
  for k, x in ipairs(flat) do
    local keep = k == #flat and " Keep" or ""
    if x.header then
      out:insert(xe.raw(p(xe.inl(x.header, { b = true }), { pitch = BODY, jc = "center", keep = true })))
    elseif x.numbered then
      n = n + 1
      out:insert(styled("Numbered Paragraph" .. keep, n .. ".", x.content))
    else
      out:insert(styled("Body Text" .. keep, nil, x.content))
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 157"; the typst template boxes them): no-break spaces.
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
  for _, k in ipairs({ "division", "debtor", "chapter", "case_number", "caption", "adversary", "title", "date",
    "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  write_file("FORMBOOK_FOOTERS", "rIdVibFooter\t" .. footer(m) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  out:extend(body(doc.blocks))
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out:walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

-- pawb brief in support of a motion, docx engine (docs/DOCX.md). Mirrors typst/pawb-motion-brief.typ:
--   * the court title (two centred bold single lines), the Official Form 416D caption (a borderless table: the boxed
--     column ruled above and right with "In re:", the debtor and its designation, then ruled right and below with the
--     parties; the case number and chapter, and the adversary proceeding number, on the right; LBR 7010-1(a)), the
--     descriptive title (LBR 7010-1(b)), all from the sample's frontmatter;
--   * body paragraphs unnumbered (LBR 5005-13(b)(3): briefs are not paragraph numbered) with a 0.5 in first-line
--     indent; headings on the body pitch, kept with the next block (level 2 centred bold capitals, 3 bold, 4 bold
--     italic); block quotations single spaced, half an inch in on each side; footnotes as Word footnotes;
--   * the signature block (LBR 5005-6(d): "/s/" before the filing user's name only) kept on one page with the last
--     paragraph.
-- The footer (the page number, centred; LBR 5005-13(b)(2)) and the last section (letter, 1 in margins) are written
-- for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the body styles are in docx/reference.xml. Nothing
-- case-specific is written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body 24 pt, pitch-single 13.8 pt
local TW = 9360                               -- typst text-width: 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360        -- typst cap-left 3.4 in, cap-gutter 0.25 in
local CAP_PAD = 200                           -- typst cap-pad 10 pt
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local CAP_INSET = 120                         -- typst cap-inset 6 pt
local CAP_DESIGNATION = 720                   -- typst cap-designation 0.5 in
local CAPTION_ABOVE = 360                     -- typst caption-above 18 pt
local TITLE_ABOVE = 360                       -- typst title-above 18 pt
local TEXT_ABOVE = 240                        -- typst text-above 12 pt
local SIG_ABOVE = 480                         -- typst sig-above 24 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function check(cond, msg)
  if not cond then error("pawb-motion-brief docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, first, jc, keep }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- Single lines (typst lines): an empty item is a blank single line; `indent`: the left indent by position;
-- `before`: the space above the first; `after`: the space below the last.
local function lines(list, o)
  o = o or {}
  local out, gap = {}, o.before or 0
  local n = 0
  for k, l in ipairs(list) do
    if l ~= "" then n = k end
  end
  for k, l in ipairs(list) do
    if l == "" then gap = gap + SINGLE else
      out[#out + 1] = p(type(l) == "string" and xe.runs(l) or xe.inl(l),
        { before = gap, after = k == n and o.after or 0, left = (o.indent or {})[k], keep = o.keep and k < n })
      gap = 0
    end
  end
  return out
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
-- Cover: court title, caption, title of the paper (typst cover)
-- ---------------------------------------------------------------------------

local function tc(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>"
    .. paras .. "</w:tc>"
end

local function cover(m)
  local out = {}
  for _, l in ipairs({ "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF PENNSYLVANIA" }) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" })
  end
  local debtor = { "In re:", "", m.debtor.name, "", m.debtor.designation }
  local dind = { [5] = CAP_DESIGNATION }
  local parties, pind = {}, {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then parties[#parties + 1] = "" end
    for _, n in ipairs(items(party.names)) do parties[#parties + 1] = n end
    parties[#parties + 1] = ""
    parties[#parties + 1] = party.designation
    pind[#parties] = CAP_DESIGNATION
  end
  local adv = txt(m.adversary_number)
  if adv == "" then adv = string.rep("_", 14) end

  local rule = 'w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local right_w = TW - CAP_LEFT - CAP_GUTTER
  local pad = '<w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  local row1 = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. tc(CAP_LEFT, table.concat(lines(debtor, { before = CAP_INSET, indent = dind })),
      '<w:tcBorders><w:top ' .. rule .. '<w:right ' .. rule .. '</w:tcBorders>' .. pad)
    .. tc(CAP_GUTTER, p(""))
    .. tc(right_w, table.concat(lines({ "Case No. " .. txt(m.bankruptcy_case), txt(m.chapter) }, { before = CAP_INSET })))
    .. "</w:tr>"
  local row2 = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. tc(CAP_LEFT, table.concat(lines(parties, { before = SINGLE, after = CAP_INSET, indent = pind })),
      '<w:tcBorders><w:bottom ' .. rule .. '<w:right ' .. rule .. '</w:tcBorders>' .. pad)
    .. tc(CAP_GUTTER, p(""))
    .. tc(right_w, table.concat(lines({ "Adv. Proc. No. " .. adv }, { before = SINGLE })))
    .. "</w:tr>"
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. right_w .. '"/>'
    .. '</w:tblGrid>' .. row1 .. row2 .. "</w:tbl>"
  -- LBR 7010-1(b): a short, concise descriptive title in addition to the adversary caption.
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { before = TITLE_ABOVE, jc = "center" })
  out[#out + 1] = space(TEXT_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block; LBR 5005-6(d)): single lines at the margin, kept on one page
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local list = { "Respectfully submitted,", "" }
  if sig.firm then
    for _, l in ipairs(items(sig.firm)) do list[#list + 1] = l end
    list[#list + 1] = ""
  end
  for k, b in ipairs(items(sig.blocks)) do
    if k > 1 then list[#list + 1] = "" end
    list[#list + 1] = (b.sign and "/s/" or "") .. txt(b.signer)
    list[#list + 1] = b.pa_id
    for _, l in ipairs(items(b.lines)) do list[#list + 1] = l end
  end
  return table.concat(lines(list, { before = SIG_ABOVE, keep = true }))
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph pandoc writes (so its footnotes are Word footnotes) in a style of docx/reference.xml.
local function styled(style, content)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

local function heading(level, content)
  local o = { b = true, i = level >= 4 }
  return xe.raw(p(xe.inl(level <= 2 and upper(content) or content, o),
    { pitch = BODY, jc = level <= 2 and "center" or "left", keep = true }))
end

-- The body as blocks (typst render-chunk); the last paragraph is kept with the signature ("Body Text Keep").
local function body(blocks)
  local out = pandoc.Blocks({})
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out:insert(heading(b.level, b.content))
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        check(q.t == "Para" or q.t == "Plain", "a block quotation holds paragraphs only")
        out:insert(styled("Block Text", q.content))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out:insert(styled(i == #blocks and "Body Text Keep" or "Body Text", b.content))
    else
      error("pawb-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  check(blocks[#blocks].t == "Para", "the body must end with a paragraph (the signature is set with it)")
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("malpractice/professional"), where LibreOffice keeps the word whole: a zero-width space
-- (U+200B) after it. Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 108"; the typst template boxes them): no-break spaces.
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
  for _, k in ipairs({ "debtor", "bankruptcy_case", "chapter", "caption", "title", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  write_file("FORMBOOK_FOOTERS", "rIdPawbFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  out:extend(body(doc.blocks))
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out:walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

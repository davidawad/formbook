-- Adversary complaint, D. Del. Bankr. (deb), docx engine (docs/DOCX.md). Mirrors typst/deb-adversary-complaint.typ:
--   * the court line (centred bold capitals), the two Form 416 captions (LR 9004-1(a); each a one-row table: the
--     party names at the left, each designation set right, the cell ruled at its right and foot; the case
--     information 0.35 in right of the rule), the title, all from the sample's frontmatter;
--   * the preamble, unnumbered; body paragraphs numbered 1., 2., ... (FRCP 10(b), via FRBP 7010): the number at the
--     indent, a tab to the text 1 in in; headings bold on the body pitch, kept with the next block (level 1 centred
--     capitals, level 2 at the margin hanging 0.5 in, level 3 centred); the WHEREFORE clause and its "a)" items
--     unnumbered; an editorial note in italic brackets ("*[...]*") centred;
--   * the signature block after the last paragraph and kept on one page with it: "Dated:" and the place at the
--     left, "Respectfully submitted," and each counsel block in the signature column (single lines).
-- The footer (the page number, centred) and the last section (letter, 1 in margins) are written for fb render
-- ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the base styles are in docx/reference.xml. Nothing case-specific is written
-- here: every string comes from the sample.
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
local CAP_PAD_RIGHT = 200                     -- typst cap-pad-right 10 pt
local RIGHT_SET = -44                         -- a designation set right: LibreOffice ends it 2.2 pt short of the margin
local CAP_PAD_BELOW = 160 - 15                -- typst cap-pad-below 8 pt, less the rule LibreOffice sets below it
local CAP_RIGHT = 504                         -- typst cap-right 0.35 in
local SIG_COL = 4032                          -- typst sig-col 2.8 in
local COVER_GAP = 280                         -- typst cover-gap 14 pt
local TEXT_ABOVE = 480                        -- typst text-above 24 pt
local SIG_ABOVE = 480                         -- typst sig-above 24 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function check(cond, msg)
  if not cond then error("deb-adversary-complaint docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, right, jc, keep, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- Single lines, one paragraph each; an empty item is a blank single line (the space before the next).
local function lines(list, o)
  local out, gap = {}, 0
  for _, l in ipairs(list) do
    if txt(l) == "" then gap = gap + SINGLE else
      local q = { before = gap }
      for k, v in pairs(o or {}) do q[k] = v end
      out[#out + 1] = p(xe.inl(l), q)
      gap = 0
    end
  end
  return table.concat(out), gap
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

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdDebFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court line, the Form 416 captions, title (typst cover)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function caption_block(c)
  local left = {}
  for k, party in ipairs(items(c.parties)) do
    local names = items(party.names)
    if k > 1 then table.insert(names, 1, "") end
    local x, gap = lines(names)
    left[#left + 1] = x
    if party.designation then
      left[#left + 1] = p(xe.inl(party.designation), { before = gap, jc = "right", right = RIGHT_SET })
    end
  end
  local right = lines(items(c.right))
  local rule = ' w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local lborders = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom' .. rule .. '<w:right' .. rule
    .. '</w:tcBorders>'
  local function mar(top, left_, bottom, right_)
    return '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left_ .. '" w:type="dxa"/>'
      .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right_ .. '" w:type="dxa"/></w:tcMar>'
  end
  return space(COVER_GAP) .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/>'
    .. '<w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. NOLOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TW - CAP_LEFT)
    .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. lborders .. mar(0, 0, CAP_PAD_BELOW, CAP_PAD_RIGHT)
    .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TW - CAP_LEFT) .. '" w:type="dxa"/>' .. mar(0, CAP_RIGHT, 0, 0)
    .. '</w:tcPr>' .. (right ~= "" and right or p("")) .. '</w:tc></w:tr></w:tbl>'
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function cover(m)
  return p(xe.inl(upper(m.court), { b = true }), { jc = "center" })
    .. caption_block(m.caption.bankruptcy)
    .. caption_block(m.caption.adversary)
    .. p(xe.inl(m.title, { b = true }), { jc = "center", before = COVER_GAP })
    .. space(TEXT_ABOVE)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block): the left column's lines beside the first single lines of the right
-- column (a tab and a hanging indent), the rest from SIG_COL; kept on one page
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local rows = { "Respectfully submitted,", "" }
  for k, b in ipairs(items(sig.blocks)) do
    if k > 1 then rows[#rows + 1] = "" end
    for _, l in ipairs(items(b.firm)) do rows[#rows + 1] = l end
    rows[#rows + 1] = ""
    for _, l in ipairs(items(b.attorneys)) do rows[#rows + 1] = l end
  end
  local left = { xe.runs("Dated: ") .. xe.inl(m.date), xe.inl(sig.place) }
  local lines_, gap = {}, SIG_ABOVE
  for n, r in ipairs(rows) do
    if txt(r) == "" and n > #left then gap = gap + SINGLE else
      lines_[#lines_ + 1] = { left[n], txt(r) ~= "" and xe.inl(r) or "", gap }
      gap = 0
    end
  end
  local out = {}
  for i, l in ipairs(lines_) do
    local o = { before = l[3], left = SIG_COL, keep = i < #lines_ }
    local body = l[2]
    if l[1] then
      body = l[1] .. xe.runs("\t") .. body
      o.hanging, o.tab = SIG_COL, SIG_COL
    end
    out[#out + 1] = p(body, o)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body (typst render-chunk)
-- ---------------------------------------------------------------------------

local function is_note(b)
  local first = b.content[1]
  return first and first.t == "Emph" and stringify(first):sub(1, 1) == "["
end

local function unnumbered(b)
  local s = stringify(b)
  return s:match("^WHEREFORE") ~= nil or s:match("^[a-z]%)%s") ~= nil
end

local function body(blocks)
  local out = {}
  local n = 0
  for k, b in ipairs(blocks) do
    local keep = k == #blocks
    if b.t == "Header" then
      local o = { pitch = BODY, keep = true, jc = b.level == 2 and "left" or "center" }
      if b.level == 2 then o.left, o.hanging = INDENT, INDENT end
      out[#out + 1] = p(xe.inl(b.level == 1 and upper(b.content) or b.content, { b = true }), o)
    elseif b.t == "Para" or b.t == "Plain" then
      if is_note(b) then
        out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, jc = "center", keep = keep })
      elseif unnumbered(b) then
        out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, first = INDENT, keep = keep })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          { pitch = BODY, first = INDENT, tab = 2 * INDENT, keep = keep })
      end
    else
      error("deb-adversary-complaint.lua: unexpected block " .. b.t)
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
  for _, k in ipairs({ "court", "caption", "title", "date", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  check(m.caption.bankruptcy ~= nil and m.caption.adversary ~= nil,
    "LR 9004-1(a): the caption needs `bankruptcy` and `adversary` blocks")
  write_file("FORMBOOK_FOOTERS", "rIdDebFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = { cover(m) }
  if m.preamble then out[#out + 1] = p(xe.inl(m.preamble), { pitch = BODY, first = INDENT }) end
  out[#out + 1] = body(doc.blocks)
  out[#out + 1] = signature(m)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

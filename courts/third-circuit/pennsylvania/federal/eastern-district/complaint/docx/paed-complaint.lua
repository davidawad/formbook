-- paed complaint, docx engine. Mirrors typst/paed-complaint.typ: the court title (centred bold single lines), the
-- caption (a table: the party lines on the left, a ":" per line in the middle column, "Civil Action No." on the
-- middle line at the right; Fed. R. Civ. P. 10(a)), the title of the pleading, the lead-in, the body (paragraphs
-- numbered 1, 2, ..., Fed. R. Civ. P. 10(b), except a request for relief opening with "WHEREFORE"; lists lettered
-- "(a)", the text hanging), and the signature block kept on one page with the last paragraph. Numbers and letters
-- are typed text, as the typst template types them. Every case word comes from the frontmatter. The footer (the
-- page number, centred) and the last section are written for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); font,
-- body styles, headings and margins are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local TW = 9360                               -- typst text-width: 6.5 in
local CAP_LEFT, CAP_COLON = 4320, 504         -- typst caption-left 3.0 in, caption-colon 0.35 in
local CAP_RIGHT_INSET = 216                   -- typst caption-right-inset 0.15 in
local CAPTION_ABOVE = 276                     -- typst caption-above 13.8 pt
local TITLE_ABOVE = 276                       -- typst title-above 13.8 pt
local TEXT_ABOVE = 276                        -- typst text-above 13.8 pt
local SIG_ABOVE, SIG_GAP = 480, 240           -- typst sig-above 24 pt, sig-gap 12 pt
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("paed complaint docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  if not o.style or o.left or o.hanging or o.first then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  end
  if not o.style or o.jc then props[#props + 1] = xe.jc(o.jc or "left") end
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
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

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdPaedFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Page one: court title, caption, title
-- ---------------------------------------------------------------------------

local function tc(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>"
    .. paras .. "</w:tc>"
end

local function cover(m)
  local out = {}
  for _, l in ipairs(items(m.court_lines)) do out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center" }) end

  local rows = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then rows[#rows + 1] = xe.runs("v.") end
    for _, n in ipairs(items(party.names)) do rows[#rows + 1] = xe.inl(n) end
    rows[#rows + 1] = xe.inl(party.designation)
  end
  local left, colons = {}, {}
  for _, r in ipairs(rows) do
    left[#left + 1] = p(r)
    colons[#colons + 1] = p(xe.runs(":"))
  end
  local number = txt(m.case_number)
  if number == "" then number = "________________" end
  local mid = (#rows - 1) // 2
  local right = p(xe.runs("Civil Action No. " .. number), { before = mid * SINGLE })

  local right_w = TW - CAP_LEFT - CAP_COLON
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_COLON .. '"/><w:gridCol w:w="' .. right_w .. '"/>'
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. tc(CAP_LEFT, table.concat(left))
    .. tc(CAP_COLON, table.concat(colons))
    .. tc(right_w, right, '<w:tcMar><w:left w:w="' .. CAP_RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>')
    .. "</w:tr></w:tbl>"
  out[#out + 1] = p(xe.inl(m.brief_title, { b = true }), { before = TITLE_ABOVE, jc = "center" })
  out[#out + 1] = space(TEXT_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature
-- ---------------------------------------------------------------------------

-- The signature block (typst signature-block): the firm, "BY: /s/" and the signer's lines, the date, single-spaced
-- at the margin, kept on one page.
local function signature(m)
  local s = m.signature
  local lines = {}
  local function add(body, before) lines[#lines + 1] = { body, before } end
  for k, l in ipairs(items(s.firm)) do add(xe.inl(l), k == 1 and SIG_ABOVE or 0) end
  add(xe.runs("BY: /s/ ") .. xe.inl(s.signer), SIG_GAP)
  for _, l in ipairs(items(s.lines)) do add(xe.inl(l), 0) end
  add(xe.runs("Date: ") .. xe.inl(m.date), SIG_GAP)
  local out = {}
  for k, l in ipairs(lines) do out[#out + 1] = p(l[1], { before = l[2], keep = k < #lines }) end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- The body as raw paragraphs; the last one is kept with the signature.
local function body(blocks)
  local out = {}
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      out[#out + 1] = p(xe.inl(level == 1 and upper(b.content) or b.content),
        { style = "Heading" .. level, keep = true, pitch = BODY })
    elseif b.t == "Para" or b.t == "Plain" then
      local content = b.content
      if stringify(content):sub(1, 9) == "WHEREFORE" then
        out[#out + 1] = function(keep)
          return p(xe.inl(content), { style = "BodyText", keep = keep, pitch = BODY })
        end
      else
        n = n + 1
        local lab = n .. ".\t"
        out[#out + 1] = function(keep)
          return p(xe.runs(lab) .. xe.inl(content), { style = "NumberedParagraph", keep = keep, pitch = BODY })
        end
      end
    elseif b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        local lab, content = "(" .. string.char(96 + j) .. ")\t", pandoc.utils.blocks_to_inlines(item)
        out[#out + 1] = function(keep)
          return p(xe.runs(lab) .. xe.inl(content), { style = "Lettered", keep = keep, pitch = BODY })
        end
      end
    else
      error("paed-complaint.lua: unexpected block " .. b.t)
    end
  end
  check(type(out[#out]) == "function", "the body must end with a paragraph or a list (the signature is set with it)")
  for i, x in ipairs(out) do
    if type(x) == "function" then x = x(i == #out) end
    out[i] = xe.raw(x)
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1681e(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 1681"; the typst template boxes them): no-break spaces.
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
  check(m.court_lines ~= nil, "Fed. R. Civ. P. 10(a): the court's name is required")
  check(m.caption ~= nil and m.caption.parties ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.brief_title ~= nil, "Fed. R. Civ. P. 10(a): the title of the pleading is required")
  check(m.signature ~= nil and m.signature.signer ~= nil, "Fed. R. Civ. P. 11(a): the signature block is required")
  write_file("FORMBOOK_FOOTERS", "rIdPaedFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  if m.lead_in then out:insert(xe.raw(p(xe.inl(m.lead_in), { style = "BodyText", pitch = BODY }))) end
  out:extend(body(doc.blocks))
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

-- vid complaint, docx engine. Mirrors typst/vid-complaint.typ: the court title (the court's name bold, the division,
-- centred single lines), the caption (a table: the parties on the left, ruled on the right and below, each name
-- single-spaced with its designation under it and "v." centred between them; the civil action number on the right;
-- Fed. R. Civ. P. 10(a)), the title, the lead-in, the body (paragraphs numbered 1, 2, ..., Fed. R. Civ. P. 10(b);
-- "~ " paragraphs unnumbered; quotations single-spaced and indented; lists with the author's numbers, the text
-- hanging), and the signature block kept on one page with the last paragraph. Numbers are typed text, as the typst
-- template types them. Every case word comes from the frontmatter. The footer (the page number, centred; LRCi
-- 5.1(a)) and the last section are written for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); font, body styles,
-- headings and margins are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local CFG = {
  numbered = true,                            -- the complaint numbers its paragraphs (Fed. R. Civ. P. 10(b))
  court_name = "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS",
  number_label = "Civil Action No.",
  name = "vid complaint",
}

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local TW = 9360                               -- typst text-width: 6.5 in
local CAP_LEFT = 5040                         -- typst caption-left 3.5 in
local CAP_PAD, CAP_PAD_BOTTOM = 288, 180      -- typst caption-pad 14.4 pt, caption-pad-bottom 9 pt
local CAP_RULE = 6                            -- typst caption-rule 0.75 pt (eighths of a point)
local CAP_RULE_TW = 15                        -- the same rule in twips: LibreOffice sets a cell's bottom rule below
                                              -- the whole row (typst adds it below the grid), and gives a cell's
                                              -- bottom margin to the whole row, so the party column's padding is
                                              -- its last line's space after, less the rule
local CAP_RIGHT_INSET = 432                   -- typst caption-right-inset 0.3 in
local DESIG_INDENT = 1728                     -- typst designation-indent 1.2 in
local CAPTION_ABOVE = 276                     -- typst caption-above 13.8 pt
local DESIG_ABOVE, VERSUS_GAP = 120, 140      -- typst designation-above 6 pt, versus-gap 7 pt
local TITLE_ABOVE = 480                       -- typst title-above 24 pt (the rule's 0.75 pt is the table's)
local QUOTE_GAP, QUOTE_INDENT = 240, 720      -- typst quote-gap 12 pt, quote-indent 0.5 in
local SIG_ABOVE, SIG_GAP = 480, 140           -- typst sig-above 24 pt, sig-gap 7 pt
local SIG_COL = 4896                          -- typst sig-col 3.4 in
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error(CFG.name .. " docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, right, hanging, first, jc, keep, tab, style }; single pitch by
-- default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  if not o.style or o.left or o.hanging or o.first or o.right then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  end
  if not o.style or o.jc then props[#props + 1] = xe.jc(o.jc or "left") end
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- ---------------------------------------------------------------------------
-- Footer and section (LRCi 5.1(a))
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

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdVidFooter"/>'
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
  out[#out + 1] = p(xe.runs(CFG.court_name, { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("DIVISION OF " .. txt(m.division):upper()), { jc = "center" })

  local left = {}
  local parties = items(m.caption)
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { before = VERSUS_GAP, jc = "center" }) end
    for j, n in ipairs(items(party.names)) do
      left[#left + 1] = p(xe.inl(n), { before = (k > 1 and j == 1) and VERSUS_GAP or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { before = DESIG_ABOVE, left = DESIG_INDENT,
      after = k == #parties and CAP_PAD_BOTTOM - CAP_RULE_TW or 0 })
  end
  local number = txt(m.case_number)
  if number == "" then number = "____________" end
  local label = txt(m.number_label)
  if label == "" then label = CFG.number_label end
  local right = p(xe.runs(label .. " " .. number))

  local rule = 'w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local borders = '<w:tcBorders><w:bottom ' .. rule .. '<w:right ' .. rule .. '</w:tcBorders>'
  local right_w = TW - CAP_LEFT
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. right_w .. '"/>'
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. tc(CAP_LEFT, table.concat(left), borders .. '<w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. tc(right_w, right, '<w:tcMar><w:left w:w="' .. CAP_RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>')
    .. "</w:tr></w:tbl>"
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { before = TITLE_ABOVE, pitch = BODY, jc = "center" })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature and certificate
-- ---------------------------------------------------------------------------

-- The signature block (typst signature-block): "Dated:" and the date at the left of the first line (a tab), the
-- preamble, "/s/" with the signer and counsel's lines from SIG_COL; kept on one page.
local function signature(sig)
  local pre = items(sig.preamble)
  local lines = { { xe.runs("Dated: " .. txt(sig.date) .. "\t") .. (pre[1] and xe.inl(pre[1]) or ""), SIG_ABOVE, true } }
  for k = 2, #pre do lines[#lines + 1] = { xe.inl(pre[k]), 0 } end
  lines[#lines + 1] = { xe.runs("/s/ ") .. xe.inl(sig.signer), SIG_GAP }
  for _, l in ipairs(items(sig.lines)) do lines[#lines + 1] = { xe.inl(l), 0 } end
  local out = {}
  for k, l in ipairs(lines) do
    if l[3] then
      out[#out + 1] = p(l[1], { before = l[2], left = SIG_COL, hanging = SIG_COL, tab = SIG_COL, keep = true })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG_COL, keep = k < #lines })
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A paragraph the author marks unnumbered with a leading "~ ": its inlines without the mark, or nil.
local function unmarked(c)
  if c[1] and c[1].t == "Str" and c[1].text == "~" and c[2] and c[2].t == "Space" then
    return pandoc.Inlines({ table.unpack(c, 3) })
  end
end

-- The body as raw paragraphs; the last one is kept with the signature.
local function body(blocks)
  local out = {}
  local n = 0
  local function para(content, style, lab)
    return function(keep)
      return p((lab and xe.runs(lab) or "") .. xe.inl(content), { style = style, keep = keep, pitch = BODY })
    end
  end
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      out[#out + 1] = p(xe.inl(b.content), { style = "Heading" .. level, keep = true, pitch = BODY })
    elseif b.t == "Para" or b.t == "Plain" then
      local plain = unmarked(b.content)
      if plain then
        out[#out + 1] = para(plain, "BodyText")
      elseif CFG.numbered then
        n = n + 1
        out[#out + 1] = para(b.content, "NumberedParagraph", n .. ".\t")
      else
        out[#out + 1] = para(b.content, "BodyText")
      end
    elseif b.t == "BlockQuote" then
      local content = pandoc.utils.blocks_to_inlines(b.content)
      out[#out + 1] = function(keep)
        return p(xe.inl(content), { before = QUOTE_GAP, after = QUOTE_GAP, left = QUOTE_INDENT,
          right = QUOTE_INDENT, keep = keep })
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes.start
      for j, item in ipairs(b.content) do
        out[#out + 1] = para(pandoc.utils.blocks_to_inlines(item), "NumberedItem", (start + j - 1) .. ".\t")
      end
    else
      error(CFG.name .. ": unexpected block " .. b.t)
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
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or", "d/b/a"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after
-- it. Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 454"; the typst template boxes them): no-break spaces.
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
  check(m.caption ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.title ~= nil, "Fed. R. Civ. P. 10(a): the title of the paper is required")
  check(m.signature ~= nil and m.signature.signer ~= nil, "Fed. R. Civ. P. 11(a): the signature block is required")
  write_file("FORMBOOK_FOOTERS", "rIdVidFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  if m.lead_in then out:insert(xe.raw(p(xe.inl(m.lead_in), { style = "BodyText", pitch = BODY }))) end
  out:extend(body(doc.blocks))
  out:insert(xe.raw(signature(m.signature)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

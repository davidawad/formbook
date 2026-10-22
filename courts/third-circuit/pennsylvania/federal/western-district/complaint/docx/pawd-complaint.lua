-- pawd complaint, docx engine. Mirrors typst/pawd-complaint.typ: the court title (centred bold single lines), the
-- caption (a table: the party lines on the left, a ")" per line, the case number, "JURY TRIAL DEMANDED" and
-- "Electronically Filed." on the right; Fed. R. Civ. P. 10(a)), the title, the lead-in, the body (paragraphs
-- numbered 1, 2, ..., Fed. R. Civ. P. 10(b), except "WHEREFORE" and "JURY TRIAL DEMANDED"; "- " items lettered
-- "a.", the text hanging), and the signature block kept on one page with the last block. Numbers and letters are
-- typed text, as the typst template types them. Every case word comes from the sample. The footer (the page number,
-- centred) and the last section are written for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); font, body styles,
-- headings and margins are in docx/reference.xml.
--
-- The body is cut into blank-line separated chunks from the sample text, as the typst template cuts it: a count
-- heading's further source lines (its statute and theory) are lines of the heading, which pandoc would read as a
-- paragraph. Each chunk's inline markdown is read by pandoc.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local TW = 9360                               -- the text width: 6.5 in
local CAP_PAREN, CAP_RIGHT = 576, 4176        -- typst caption-paren 0.4 in, caption-right 2.9 in
local CAPTION_ABOVE = 480                     -- typst caption-above 24 pt
local TITLE_ABOVE = 480                       -- typst title-above 24 pt
local SIG_ABOVE = 480                         -- typst sig-above 24 pt
local SIG_COL = 4320                          -- typst sig-col 3.0 in
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("pawd complaint docx: " .. msg, 0) end
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

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdPawdFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Break rules (typst's), on the frontmatter (pandoc walks it) and on every chunk read here
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("§ 1343(3)(a)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 2611"; the typst template boxes them): no-break spaces.
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

-- A chunk's inline markdown as pandoc inlines, with the break rules.
local function md(s)
  local blocks = pandoc.read(s, "markdown+smart", PANDOC_READER_OPTIONS).blocks
  local out = pandoc.Inlines({})
  for k, b in ipairs(blocks) do
    if k > 1 then out:insert(pandoc.Space()) end
    out:extend(b.content or pandoc.utils.blocks_to_inlines({ b }))
  end
  return out:walk({ Str = break_rules }):walk({ Inlines = bind })
end

-- ---------------------------------------------------------------------------
-- Page one: court title, caption, title
-- ---------------------------------------------------------------------------

local function tc(width, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. paras .. "</w:tc>"
end

local function cover(m)
  local out = {}
  for _, l in ipairs({ "IN THE UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF PENNSYLVANIA" }) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" })
  end
  local left, parens = {}, {}
  for k, party in ipairs(items(m.caption)) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  for _ = 1, #left do parens[#parens + 1] = p(xe.runs(")"), { jc = "center" }) end
  local right = { p(xe.runs("Civil Action No. " .. txt(m.case_number))) }
  if m.jury_demand == true then right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = SINGLE }) end
  if m.electronically_filed == true then right[#right + 1] = p(xe.runs("Electronically Filed."), { before = SINGLE }) end

  local left_w = TW - CAP_PAREN - CAP_RIGHT
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. left_w .. '"/><w:gridCol w:w="' .. CAP_PAREN .. '"/><w:gridCol w:w="' .. CAP_RIGHT .. '"/>'
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. tc(left_w, table.concat(left)) .. tc(CAP_PAREN, table.concat(parens)) .. tc(CAP_RIGHT, table.concat(right))
    .. "</w:tr></w:tbl>"
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { before = TITLE_ABOVE, jc = "center" })
  out[#out + 1] = space(TITLE_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature
-- ---------------------------------------------------------------------------

-- The signature block (typst signature): "Dated:" at the margin, then from SIG_COL "Respectfully submitted," the
-- firm, the signer's line and the attorney lines, a blank double line between the groups; kept on one page.
local function signature(m)
  local s = m.signature
  local lines = {}
  local function add(body, before, left) lines[#lines + 1] = { body, before, left } end
  if m.date then add(xe.runs("Dated: ") .. xe.inl(m.date), SIG_ABOVE, 0) end
  add(xe.inl(s.lead), SIG_ABOVE, SIG_COL)
  for k, l in ipairs(items(s.firm)) do add(xe.inl(l), k == 1 and SIG_ABOVE or 0, SIG_COL) end
  add(xe.inl(s.signer), SIG_ABOVE, SIG_COL)
  for _, l in ipairs(items(s.lines)) do add(xe.inl(l), 0, SIG_COL) end
  local out = {}
  for k, l in ipairs(lines) do out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = k < #lines }) end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- The sample's body text (after the frontmatter), in blank-line separated chunks.
local function chunks()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local body = src:gsub("\r\n", "\n"):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out
end

-- The body as raw paragraphs; the last one is kept with the signature.
local function body()
  local out = {}
  local n = 0
  local function para(inlines, style)
    return function(keep) return p(inlines, { style = style, keep = keep, pitch = BODY }) end
  end
  for _, c in ipairs(chunks()) do
    local hashes = c:match("^(#+)")
    if hashes then
      local level = math.min(#hashes, 3)
      local text = c:sub(#hashes + 1):match("^%s*(.-)$")
      if level == 2 then
        local lines = {}
        for l in (text .. "\n"):gmatch("(.-)\n") do lines[#lines + 1] = l:match("^%s*(.-)%s*$") end
        for _, l in ipairs(lines) do
          out[#out + 1] = p(xe.inl(md(l), { b = true }), { style = "Heading2", keep = true, pitch = BODY })
        end
      else
        local inl = md(text)
        if level == 1 then inl = upper(inl) end
        out[#out + 1] = p(xe.inl(inl, { b = true }), { style = "Heading" .. level, keep = true, pitch = BODY })
      end
    elseif c:sub(1, 2) == "- " then
      local its = {}
      for l in (c .. "\n"):gmatch("(.-)\n") do
        if l:sub(1, 2) == "- " then its[#its + 1] = l:sub(3) elseif #its > 0 then
          its[#its] = its[#its] .. " " .. l:match("^%s*(.-)%s*$")
        end
      end
      for j, it in ipairs(its) do
        out[#out + 1] = para(xe.runs(string.char(96 + j) .. ".\t") .. xe.inl(md(it)), "Lettered")
      end
    elseif c:sub(1, 19) == "JURY TRIAL DEMANDED" then
      local inl = md(c)
      out[#out + 1] = function(keep)
        return p(xe.inl(inl, { b = true }), { keep = keep, pitch = BODY, jc = "center" })
      end
    elseif c:sub(1, 9) == "WHEREFORE" then
      out[#out + 1] = para(xe.inl(md(c)), "BodyText")
    else
      n = n + 1
      out[#out + 1] = para(xe.runs(n .. ".\t") .. xe.inl(md(c)), "NumberedParagraph")
    end
  end
  check(type(out[#out]) == "function", "the body must end with a paragraph, a list or the jury demand")
  for i, x in ipairs(out) do
    if type(x) == "function" then x = x(i == #out) end
    out[i] = xe.raw(x)
  end
  return out
end

local function finish(doc)
  local m = doc.meta
  check(m.caption ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.title ~= nil, "Fed. R. Civ. P. 10(a): the title of the pleading is required")
  check(m.signature ~= nil and m.signature.signer ~= nil, "LCvR 5.2.B: the signature block is required")
  write_file("FORMBOOK_FOOTERS", "rIdPawdFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  if m.lead_in then out:insert(xe.raw(p(xe.inl(m.lead_in), { style = "BodyText", pitch = BODY }))) end
  out:extend(body())
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

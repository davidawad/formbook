-- ncmd complaint, docx engine. Mirrors typst/ncmd-complaint.typ; rules and conventions are in ../README.md. The cover
-- (court title, caption table with the rules that close the party column), the numbered allegations (FRCP 10(b): the
-- number half an inch in, a tab, the text; the prayer and any section in unnumbered_sections are not numbered), the
-- lists, the date line and the signature block (LR 7.1(b)) are built here. Font, size, the body and single pitches,
-- margins and the page number are styles and section settings in docx/reference.xml (fb render builds the reference
-- document from it). Content-agnostic: every case-specific word comes from the sample's frontmatter and body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 460 the body, 300 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run. Body paragraphs and list items stay pandoc
-- paragraphs (custom styles of reference.xml), so their footnotes are pandoc's.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 460, 300            -- typst pitch-body 23 pt, pitch-single 15 pt
local BLANK = 460                        -- typst blank: one blank body line
local CAP_LEFT, CAP_PAD = 4896, 288      -- typst caption-left 3.4 in, caption-pad 0.2 in
local CAP_BELOW = 285                    -- typst caption-below 15 pt, less the 0.75 pt bottom rule LibreOffice adds to the row
local TEXTW = 9360                       -- 6.5 in
local DESIG = 1728                       -- typst designation-indent 1.2 in
local SIG_IND = 4320                     -- typst sig-indent 3 in

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("ncmd-complaint.lua: missing required metadata field `" .. key .. "`") end
  return v
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, line, left, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single-spaced lines (typst line-stack): each item { xml, o } or "" (a blank single line: the next line a line
-- lower). keep: every line kept with the next; above: space above the first line.
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for k, l in ipairs(lines) do
    if l == "" then
      gap = gap + SINGLE
    else
      local po = {}
      for key, v in pairs(l.o or {}) do po[key] = v end
      po.before = gap
      po.left = (po.left or 0) + (o.left or 0)
      if o.keep and k < #lines then po.keep = true end
      out[#out + 1] = p(l.xml, po)
      gap = 0
    end
  end
  if #out == 0 then out[1] = p("") end
  return table.concat(out)
end

local function line(xml, o)
  return { xml = xml, o = o }
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper (NCMD-FIRST-001..003)
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for _, l in ipairs(items(need(m, "court"))) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center" })
  end
  if m.division ~= nil then
    out[#out + 1] = p(xe.inl(upper(m.division), { b = true }), { jc = "center", before = SINGLE })
  end
  -- typst caption: above blank (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = BLANK })

  local left = {}
  local sides = need(m, "caption").parties
  for i, side in ipairs(sides) do
    for _, n in ipairs(items(side.names)) do left[#left + 1] = line(xe.inl(n)) end
    left[#left + 1] = line(xe.inl(side.designation), { left = DESIG })
    if i < #sides then
      left[#left + 1] = ""
      left[#left + 1] = line(xe.runs("v."), { jc = "center" })
      left[#left + 1] = ""
    end
  end
  local right = {
    line(xe.runs("Civil Action No. " .. stringify(need(m, "case_number")))),
    "",
    line(xe.inl(upper(need(m, "brief_title")), { b = true })),
  }
  if m.jury_demand == true then
    right[#right + 1] = ""
    right[#right + 1] = line(xe.runs("(Jury Trial Demanded)"))
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. rule
    .. '<w:tcMar><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
    .. '</w:tcPr>' .. stack(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/>'
    .. '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. stack(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
  return xe.raw(table.concat(out))
end

-- ---------------------------------------------------------------------------
-- Signature block (NCMD-FIRST-004; LR 7.1(b)): the date line at the margin, the counsel lines 3 in from it; kept
-- together and with the block before them (typst: one unbreakable block)
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = need(m, "signature")
  for _, k in ipairs({ "firm", "signer", "bar_number", "address", "phone", "email", "role" }) do
    if sig[k] == nil then error("ncmd-complaint.lua: signature block missing `" .. k .. "` (LR 7.1(b))") end
  end
  local date = p(xe.runs("This the ") .. xe.inl(need(m, "date_line")), { before = BLANK, keep = true })
  local lines = { line(xe.inl(sig.firm)), "", line(xe.runs("/s/ " .. stringify(sig.signer))), line(xe.inl(sig.signer)),
    line(xe.inl(sig.bar_number)) }
  for _, l in ipairs(items(sig.address)) do lines[#lines + 1] = line(xe.inl(l)) end
  lines[#lines + 1] = line(xe.inl(sig.phone))
  lines[#lines + 1] = line(xe.inl(sig.email))
  lines[#lines + 1] = ""
  lines[#lines + 1] = line(xe.inl(sig.role, { i = true }))
  return xe.raw(date .. stack(lines, { above = BLANK, left = SIG_IND, keep = true }))
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1391(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A heading (typst heading-block): on the body pitch, kept with the next block; level 1 centred bold capitals with a
-- blank line above, level 2 and below bold at the margin.
local function heading(b)
  local c = b.level == 1 and upper(b.content) or b.content
  return xe.raw(p(xe.inl(c, { b = true }), { before = b.level == 1 and BLANK or 0, line = BODY, keep = true,
    jc = b.level == 1 and "center" or "left" }))
end

-- A pandoc paragraph in a style of reference.xml; the "Keep" variant kept whole with the next paragraph. Widow control
-- stays on where a paragraph anchors a footnote: typst carries two lines over with a note that does not fit.
local function styled(style, keep, inlines)
  if keep then style = style .. " Keep" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function prefixed(label, inlines)
  local out = pandoc.Inlines({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
  out:extend(inlines)
  return out
end

-- The blocks of the body; keep_all: every block kept with the next (the closing block, kept with the signature).
local function convert(blocks, state, keep_all, out)
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then state.numbered = not state.unnumbered[pandoc.text.upper(stringify(b.content))] end
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      -- a paragraph that introduces a list ("... that this Court:") stays whole with the list
      local keep = keep_all or stringify(b):sub(-1) == ":"
      if state.numbered then
        state.n = state.n + 1
        out[#out + 1] = styled("Numbered Paragraph", keep, prefixed(state.n .. ".", b.content))
      else
        out[#out + 1] = styled("Body Text", keep, b.content)
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for k, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and ((start + k - 1) .. ".") or "\u{2022}"
        out[#out + 1] = styled("Ncmd List", keep_all, prefixed(label, pandoc.utils.blocks_to_inlines(item)))
      end
    else
      error("ncmd-complaint.lua: unsupported block " .. b.t)
    end
  end
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "brief_title", "date_line", "signature" }) do
    local _ = need(m, k)
  end
  local state = { numbered = true, n = 0, unnumbered = {} }
  for _, s in ipairs(items(m.unnumbered_sections)) do state.unnumbered[pandoc.text.upper(stringify(s))] = true end

  local out = { cover(m) }
  local head = {}
  for i = 1, #doc.blocks - 1 do head[#head + 1] = doc.blocks[i] end
  convert(head, state, false, out)
  -- the last block (a paragraph, or the whole closing list) stays with the signature block (typst: unbreakable)
  convert({ doc.blocks[#doc.blocks] }, state, true, out)
  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(signature(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }

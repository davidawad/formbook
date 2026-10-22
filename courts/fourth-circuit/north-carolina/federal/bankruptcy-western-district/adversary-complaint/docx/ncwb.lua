-- ncwb.lua (docx engine, W.D.N.C. bankruptcy court, adversary complaint): the complaint as Word paragraphs, so that
-- it reads and breaks as typst/ncwb-adversary-complaint.typ does: the court title (three bold lines), the caption
-- (debtor box, then the adversary box, each ruled at its right and foot; Official Form 416 via Fed. R. Bankr. P.
-- 7010), the title, the body (paragraphs with the numbers the sample types, headings, block quotations) and the
-- signature block ("Dated:" beside the first line). Every case word comes from the sample's frontmatter and body,
-- never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 280 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. pandoc reads the sample
-- without fancy lists (reference.xml pandoc-from), so a typed marker such as "(a)" stays text, as typst prints it.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 280            -- typst pitch-double, pitch-single
local GAP = 320                          -- typst gap, 16 pt
local QGAP = 120                         -- typst quote-gap, 6 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 5184                    -- typst caption-left, 3.6 in
local BOX_PAD = 158                      -- typst box-pad, 0.12 in (173 twips), less the 0.75 pt rule Word adds below it
local BOX_GUTTER = 288                   -- typst box-gutter, 0.2 in
local SIG = 4032                         -- typst sig-col, 2.8 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  local out = {}
  for _, v in ipairs(m or {}) do out[#out + 1] = v end
  return out
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single lines, one per item; an empty item is a blank line (typst: lines).
local function lines(items, left, out)
  out = out or {}
  for _, l in ipairs(items) do out[#out + 1] = p(plain(l) == "" and "" or xe.inl(l), { left = left }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption boxes, title
-- ---------------------------------------------------------------------------

local function court_title(meta)
  local out = {}
  for _, t in ipairs({ meta.court, meta.district, meta.division }) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(t)), { b = true }), { jc = "center" })
  end
  return out
end

local function parties_rows(parties)
  local rows = {}
  for k, party in ipairs(parties) do
    if k > 1 then
      rows[#rows + 1] = "v."
      rows[#rows + 1] = ""
    end
    for _, n in ipairs(party.names) do rows[#rows + 1] = n end
    rows[#rows + 1] = party.designation
  end
  return rows
end

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

-- One caption box (typst: caption-box): a one-row table, the party column ruled at its right and foot with the
-- box padding inside the rules, the right column after the gutter.
local function caption_box(left_rows, right_rows)
  local function cell(w, pr, ps) return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' ..
    table.concat(ps) .. '</w:tc>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, RULES .. '<w:tcMar><w:bottom w:w="' .. BOX_PAD .. '" w:type="dxa"/><w:right w:w="' .. BOX_PAD ..
      '" w:type="dxa"/></w:tcMar>', lines(left_rows, 0)) ..
    cell(TEXTW - CAP_LEFT, "", lines(right_rows, BOX_GUTTER)) .. '</w:tr></w:tbl>'
end

local function caption(meta)
  local d = meta.debtor
  local debtor = { "In re:", "" }
  for _, n in ipairs(d.names) do debtor[#debtor + 1] = n end
  debtor[#debtor + 1] = ""
  debtor[#debtor + 1] = d.designation
  -- typst: each box stands a paragraph gap below what precedes it
  return {
    p("", { line = GAP }),
    caption_box(debtor, { "Case No. " .. plain(d.case_number), "", "Chapter " .. plain(d.chapter) }),
    p("", { line = GAP }),
    caption_box(parties_rows(meta.caption.parties), { "Adv. Proc. No. " .. plain(meta.adversary.number) }),
  }
end

local function title(text)
  return p(xe.runs(pandoc.text.upper(text), { b = true }), { jc = "center", before = GAP, after = GAP, line = BODY })
end

local function cover(meta, out)
  for _, x in ipairs(court_title(meta)) do out[#out + 1] = x end
  for _, x in ipairs(caption(meta)) do out[#out + 1] = x end
end

-- ---------------------------------------------------------------------------
-- Signature: "Dated:" in the first column, the first line beside it (a tab to the hanging indent), the rest under it
-- ---------------------------------------------------------------------------

local function signature(date, sig, out)
  sig = list(sig)
  out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(date) .. xe.runs("\t") .. (sig[1] and xe.inl(sig[1]) or ""),
    { before = GAP, left = SIG, hanging = SIG })
  lines({ table.unpack(sig, 2) }, SIG, out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, a paragraph gap above and below, kept with the text: level 1 centered bold capitals,
-- level 2 centered bold, level 3 bold at the margin.
local function heading(b)
  local content = b.content
  if b.level == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(b.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(GAP, GAP, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

local function body_par(body)
  return p(body, { line = BODY, first = INDENT, before = GAP, after = GAP })
end

local function blocks(list_, out)
  for _, b in ipairs(list_) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = QGAP, after = QGAP, left = QUOTE, right = QUOTE })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(xe.inl(b.content))
    else
      error("ncwb.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 2201"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  out[#out + 1] = title(plain(meta.title))
  blocks(doc.blocks, out)
  signature(meta.signature.date, meta.signature.lines, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

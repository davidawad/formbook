-- Pandoc filter for the gasd memorandum of law (motion brief), engine docx, so that it reads and breaks as
-- typst/gasd-motion-brief.typ does: court title, caption, title, numbered headings (I. / A. / 1.), double-spaced
-- body with footnotes, block quotations, signature block, certificate of service on its own page (LR 5.1). Every
-- case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. The body paragraphs,
-- headings and list items (which may carry footnotes) are written by pandoc in the styles of docx/reference.xml;
-- everything else is written here.

local xe = require("docx.xengine")

local SINGLE = 276                       -- typst pitch-single
local GAP, SIG_GAP = 324, 162            -- typst gap 16.2 pt, sig-gap
local QUOTE = 1080                       -- typst quote-indent, 0.75 in
local ADDRESS = 1440                     -- typst address-indent, 1 in
local SIG = 4608                         -- typst signature-indent, 3.2 in
local TEXTW = 9360                       -- 6.5 in
local PARTY, PAREN = 4464, 432           -- typst caption-party-width 3.1 in, caption-paren-width 0.3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- Inlines in capitals (typst upper), footnotes left as written.
local function upper(x)
  if type(x) == "string" then return pandoc.text.upper(x) end
  if pandoc.utils.type(x) ~= "Inlines" then return pandoc.text.upper(plain(x)) end
  local out = pandoc.Inlines({})
  for _, el in ipairs(x) do
    if el.t == "Str" then
      out:insert(pandoc.Str(pandoc.text.upper(el.text)))
    elseif el.t == "Note" then
      out:insert(el)
    elseif el.content and pandoc.utils.type(el.content) == "Inlines" then
      local c = el:clone()
      c.content = upper(el.content)
      out:insert(c)
    else
      out:insert(el)
    end
  end
  return out
end

-- A paragraph: o = { before, after, line, left, right, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title (also on the certificate's page, which it opens)
-- ---------------------------------------------------------------------------

local function cover(meta, out, brk)
  local lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF GEORGIA" }
  if meta.division then lines[#lines + 1] = pandoc.text.upper(plain(meta.division)) end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #lines and GAP or 0,
      brk = brk and i == 1 })
  end
  -- Caption: a borderless three-column table, one row per line of the party column, ")" in the middle.
  local rows = {}
  local function cell(w, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. p(body) .. '</w:tc>'
  end
  for _, r in ipairs(meta.caption.rows) do
    rows[#rows + 1] = '<w:tr>' .. cell(PARTY, xe.inl(r.left)) .. cell(PAREN, xe.runs(")")) ..
      cell(TEXTW - PARTY - PAREN, xe.inl(r.right)) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. PARTY .. '"/><w:gridCol w:w="' .. PAREN .. '"/><w:gridCol w:w="' ..
    (TEXTW - PARTY - PAREN) .. '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- the title: Word has no space after a table, so it takes the gap before it
  out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { before = GAP, after = GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }

-- The body: headings numbered (level 1 "I." in capitals, level 2 "A.", level 3 "1." in italics), paragraphs and
-- list items as pandoc writes them, quotations single-spaced and indented.
local function body(doc, out)
  local sec, sub, subsub = 0, 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local label, content
      if b.level == 1 then
        sec, sub, subsub = sec + 1, 0, 0
        label, content = ROMAN[sec] .. ".", upper(b.content)
      elseif b.level == 2 then
        sub, subsub = sub + 1, 0
        label, content = string.char(64 + sub) .. ".", b.content
      else
        subsub = subsub + 1
        label, content = subsub .. ".", b.content
      end
      local c = pandoc.Inlines({ pandoc.Str(label), pandoc.Space() })
      c:extend(content)
      if b.level >= 3 then c = pandoc.Inlines({ pandoc.Emph(c) }) end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.Str(b.t == "OrderedList" and (i .. ".") or "\u{2022}"),
          pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        for k, blk in ipairs(item) do
          if k > 1 then inl:insert(pandoc.Space()) end
          inl:extend(blk.content)
        end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "List Body" })
      end
    elseif b.t == "BlockQuote" then
      -- run in as one paragraph (typst joins its lines)
      local inl = pandoc.Inlines({})
      for k, q in ipairs(b.content) do
        if k > 1 then inl:insert(pandoc.Space()) end
        inl:extend(q.content)
      end
      out[#out + 1] = xe.raw(p(xe.inl(inl), { after = GAP, left = QUOTE, right = QUOTE }))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Para(b.content)
    else
      error("gasd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature (LR 11.1) and certificate of service (LR 5.1)
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = {}
  if sig.date then lines[#lines + 1] = { xe.runs("This the " .. plain(sig.date) .. "."), GAP, 0, GAP } end
  lines[#lines + 1] = { xe.runs("Respectfully submitted,"), GAP, SIG }
  for _, s in ipairs(sig.signers) do
    lines[#lines + 1] = { xe.runs("By: /s/ ") .. xe.inl(s.name), SIG_GAP, SIG }
    lines[#lines + 1] = { xe.inl(s.name), 0, SIG }
    for _, l in ipairs(s.lines) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], after = l[4], keep = i < #lines })
  end
end

local function certificate(meta, out)
  local raw = {}
  cover(meta, raw, true)
  local svc = meta.service
  local text = "I hereby certify that on " .. plain(svc.date) .. ", I electronically filed the foregoing "
  local body = xe.runs(text) .. xe.inl(upper(meta.title)) .. xe.runs(" with the Clerk of Court using the CM/ECF " ..
    "system, which will send notification of such filing to counsel of record.")
  if svc.unregistered then
    body = body .. xe.runs(" I further certify that I served a true and correct copy of the same on the following " ..
      "by First-Class Mail, postage prepaid, addressed to:")
  end
  raw[#raw + 1] = xe.para({ xe.spacing(0, GAP, 480), xe.ind(0, nil, 720), xe.jc("left") }, body)
  for _, addr in ipairs(svc.unregistered or {}) do
    for i, l in ipairs(addr) do
      raw[#raw + 1] = p(xe.inl(l), { before = i == 1 and SIG_GAP or 0, left = ADDRESS, keep = i < #addr })
    end
  end
  local lines = { xe.runs("/s/ ") .. xe.inl(svc.signer.name) }
  for _, l in ipairs(svc.signer.lines) do lines[#lines + 1] = xe.inl(l) end
  for i, l in ipairs(lines) do
    raw[#raw + 1] = p(l, { before = i == 1 and GAP or 0, left = SIG, keep = i < #lines })
  end
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("Doc/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1334": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local raw = {}
  cover(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  body(doc, out)
  raw = {}
  signature(meta, raw)
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  certificate(meta, out)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

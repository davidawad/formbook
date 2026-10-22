-- U.S. Bankruptcy Court, M.D. Alabama: motion with its grounds in numbered paragraphs, pandoc filter for the docx
-- engine. The same form as the typst template (typst/almb-motion-brief.typ) and the same contract: every
-- case-specific string comes from the sample (its YAML frontmatter and body). The court title, the boxed caption,
-- the notice legend, the title, the body, the signature block and the certificate of service are WordprocessingML
-- written here, so that it reads and breaks as typst does. The body is split into blocks at blank lines as the typst
-- template splits it ("#" a heading, "##" a subheading, "N. " a numbered paragraph that keeps the number the
-- markdown gives it, ">" a quotation, "- " a bulleted list), each read as commonmark (the reader of typst's
-- cmarker). Requirement IDs (ALMB-MOT-...) are in ../README.md.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276             -- typst pitch-double, pitch-single
local GAP = SINGLE                        -- typst gap
local INDENT = 720                        -- typst para-indent, 0.5 in
local BULLET = 360                        -- typst bullet-box, 0.25 in
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT = 4752                     -- typst caption-col, 3.3 in
local CAP_INSET, CAP_PAD = 173, 138       -- typst caption-inset 0.12 in, pitch-single / 2
local RIGHT_INSET = 288                   -- typst right-inset 0.2 in
local SIG_LEFT = TEXTW - 4608             -- typst sig-col 3.2 in at the right margin
local QUOTE = 240                         -- typst pitch-double / 2 around a quotation

local function need(meta, key)
  if meta[key] == nil then error("almb-motion-brief: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, lines, page }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.page then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 1408"; typst binds it too; xe.inl binds a single sign).
local function bind_doubled(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "\u{00A7}\u{00A7}" or l[i].text == "\u{00B6}\u{00B6}") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A markdown string read as typst's cmarker reads it.
local function read(md)
  return pandoc.read(md, "commonmark+smart").blocks:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
end

local function inlines(md)
  local b = read(md)[1]
  return b and b.content or pandoc.Inlines({})
end

-- ---------------------------------------------------------------------------
-- Court title, caption (FRBP 9004(b)), notice legend, title
-- ---------------------------------------------------------------------------

local function court_title(meta, out)
  local lines = need(meta, "court")
  for i, l in ipairs(lines) do
    -- the caption stands a double line below (typst: the caption block's above)
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", keep = true, after = i == #lines and BODY or 0 })
  end
end

local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
local BOX = '<w:tcBorders><w:top ' .. RULE .. '/><w:left ' .. RULE .. '/><w:bottom ' .. RULE .. '/><w:right ' .. RULE ..
  '/></w:tcBorders><w:tcMar><w:top w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:left w:w="' .. CAP_INSET ..
  '" w:type="dxa"/><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>'
local RIGHT = '<w:tcMar><w:left w:w="' .. RIGHT_INSET .. '" w:type="dxa"/></w:tcMar><w:vAlign w:val="center"/>'

-- The boxed left column ("IN RE:" and the debtor), the case number and the chapter beside it.
local function caption(meta)
  local debtor = need(meta, "debtor")
  local left = { p(xe.runs("IN RE:")) }
  for i, n in ipairs(debtor.name) do left[#left + 1] = p(xe.inl(n), { left = INDENT, before = i == 1 and GAP or 0 }) end
  local right = p(xe.runs("CASE NO. ") .. xe.inl(debtor.case_number)) .. p(xe.inl(debtor.chapter), { before = GAP })
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. BOX .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/>' .. RIGHT .. '</w:tcPr>' .. right .. '</w:tc>' ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature blocks (LBR 9011-1: name, address, telephone and email of each signer; /s/ is acceptable): single
-- lines in a column at the right margin; every line is kept with the next, so a block never splits across pages.
-- ---------------------------------------------------------------------------

local function column(lines, before, out)
  lines[1].before = math.max(lines[1].before or 0, before)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, left = l.left or SIG_LEFT, keep = i < #lines })
  end
end

local function signature(meta, out)
  local sig = need(meta, "signature")
  local lines = {}
  if meta.date then lines[#lines + 1] = { body = xe.runs("Dated: ") .. xe.inl(meta.date), left = 0 } end
  local closing = sig.closing == nil and "Respectfully submitted," or sig.closing
  local before = 0
  if plain(closing) ~= "" then
    lines[#lines + 1] = { body = xe.inl(closing) }
    before = GAP
  end
  if plain(sig.firm) ~= "" then
    lines[#lines + 1] = { body = xe.inl(sig.firm), before = before }
    before = GAP
  end
  lines[#lines + 1] = { body = xe.runs("/s/ ") .. xe.inl(sig.signer), before = before }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { body = xe.inl(l) } end
  column(lines, SINGLE, out)
end

-- ---------------------------------------------------------------------------
-- Certificate of service (FRBP 9014(b)) and the service list (LBR 9013-3), on a page of their own
-- ---------------------------------------------------------------------------

local function certificate(meta, out)
  if meta.certificate == nil then return end
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", line = BODY, keep = true, page = true })
  out[#out + 1] = p(xe.inl(meta.certificate), { line = BODY, first = INDENT })
  if meta.certificate_signature then
    local lines = {}
    for _, l in ipairs(meta.certificate_signature) do lines[#lines + 1] = { body = xe.inl(l) } end
    column(lines, SINGLE, out)
  end
  for _, group in ipairs(meta.service or {}) do
    -- one short underlined line: no break opportunity after a slash (LibreOffice splits the underlined word there)
    local method = pandoc.Inlines(group.method):walk({ Str = function(s) return pandoc.Str((s.text:gsub("\u{200B}", ""))) end })
    out[#out + 1] = p(xe.inl(method, { u = true }), { before = BODY, keep = true })
    for _, party in ipairs(group.parties or {}) do
      for i, l in ipairs(party) do
        out[#out + 1] = p(xe.inl(l), { before = i == 1 and GAP or 0, keep = i < #party })
      end
    end
  end
end

-- ---------------------------------------------------------------------------
-- The body, block by block as the typst template splits it
-- ---------------------------------------------------------------------------

local function chunks_of(src)
  src = src:gsub("\r", "")
  src = src:gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  src = src:gsub("^%s+", ""):gsub("%s+$", "")
  local chunks = {}
  local pos = 1
  while true do
    local s, e = src:find("\n[ \t]*\n", pos)
    local t = src:sub(pos, s and s - 1 or #src):gsub("^%s+", ""):gsub("%s+$", "")
    if t ~= "" then chunks[#chunks + 1] = t end
    if not s then break end
    pos = e + 1
  end
  return chunks
end

-- One block; `last`: the prayer, kept whole with the signature block (typst: sticky and unbreakable).
local function block(t, out, last)
  local head = t:match("^(#+)")
  if head then
    local text = inlines((t:gsub("^#+", ""):gsub("#+$", "")))
    out[#out + 1] = xe.para({ xe.KEEP, xe.spacing(0, 0, BODY),
      xe.ind(0, nil, 0), xe.jc(#head >= 2 and "left" or "center") }, xe.inl(text, { b = true }))
  elseif t:sub(1, 1) == ">" then
    -- a quotation: single-spaced, half an inch in on both sides, half a double line off the text
    local paras = read(t)[1].content
    for i, b in ipairs(paras) do
      out[#out + 1] = p(xe.inl(b.content), { left = INDENT, right = INDENT, before = i == 1 and QUOTE or 0,
        after = i == #paras and QUOTE or 0 })
    end
  elseif t:match("^[-*] ") then
    -- a bulleted list: the bullet in a box half an inch in, the text hanging after it, at the body pitch
    for _, item in ipairs(read(t)[1].content) do
      for k, b in ipairs(item) do
        out[#out + 1] = p((k == 1 and xe.runs("\u{2022}\t") or "") .. xe.inl(b.content),
          { line = BODY, left = INDENT + BULLET, hanging = BULLET })
      end
    end
  else
    local n, rest = t:match("^(%d+)%.%s+(.*)$")
    local runs = n and (xe.runs(n .. ". ") .. xe.inl(inlines(rest))) or xe.inl(inlines(t))
    out[#out + 1] = p(runs, { line = BODY, first = INDENT, keep = last })
  end
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtor", "title", "signature" }) do
    need(meta, k)
  end
  local f = io.open(PANDOC_STATE.input_files[1], "r")
  local src = f:read("a")
  f:close()
  local out = {}
  court_title(meta, out)
  out[#out + 1] = caption(meta)
  -- Notice legend (LBR 1017-2(b), 9007-1(c), 4001-1): capitals, bold, centered under the style of the case. The
  -- notice, or else the title, stands a double line below the caption (Word has no space after a table).
  if meta.notice then
    out[#out + 1] = p(xe.inl(upper(meta.notice), { b = true }), { jc = "center", before = BODY })
  end
  out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { jc = "center", before = BODY, after = SINGLE })
  local chunks = chunks_of(src)
  for i, t in ipairs(chunks) do block(t, out, i == #chunks) end
  signature(meta, out)
  certificate(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- emptied metadata: pandoc would otherwise print the frontmatter title as a Title paragraph above the caption
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

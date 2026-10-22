-- U.S. Bankruptcy Court, M.D. Alabama: adversary complaint, pandoc filter for the docx engine. The same form as
-- the typst template (typst/almb-adversary-complaint.typ) and the same contract: every case-specific string comes
-- from the sample (its YAML frontmatter and body). The court title, the boxed caption, the title, the consent
-- block, the body and the signature block are WordprocessingML written here, so that it reads and breaks as typst
-- does. The body is split into blocks at blank lines as the typst template splits it ("#" a heading, "N. " a
-- numbered allegation that keeps the number the markdown gives it, ">" a quotation), each read as commonmark (the
-- reader of typst's cmarker). Requirement IDs (ALMB-ADV-...) are in ../README.md.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276             -- typst pitch-double, pitch-single
local GAP = SINGLE                        -- typst gap
local INDENT = 720                        -- typst para-indent, 0.5 in
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT = 4752                     -- typst caption-col, 3.3 in
local CAP_INSET, CAP_PAD = 173, 138       -- typst caption-inset 0.12 in, pitch-single / 2
local RIGHT_INSET = 288                   -- typst right-inset 0.2 in
local SIG_LEFT = TEXTW - 4608             -- typst sig-col 3.2 in at the right margin
local QUOTE = 240                         -- typst pitch-double / 2 around a quotation

local function need(meta, key)
  if meta[key] == nil then error("almb-adversary-complaint: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
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
-- Court title, caption (FRBP 7010, Form 416D; FRBP 9004(b)), title
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

local function row(left, right)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. BOX .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/>' .. RIGHT .. '</w:tcPr>' .. right .. '</w:tc></w:tr>'
end

-- The boxed left column in two parts, "IN RE:" and the debtor, then the parties; the case number beside the first,
-- the adversary number (a blank when the clerk has not assigned one) beside the second.
local function caption(meta)
  local debtor = need(meta, "debtor")
  local sides = need(meta, "caption")
  local top = { p(xe.runs("IN RE:")) }
  for i, n in ipairs(debtor.name) do top[#top + 1] = p(xe.inl(n), { left = INDENT, before = i == 1 and GAP or 0 }) end
  local bottom = {}
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do bottom[#bottom + 1] = p(xe.inl(n), { before = (k == 1 and i > 1) and GAP or 0 }) end
    bottom[#bottom + 1] = p(xe.inl(side.designation), { left = INDENT })
    if i < #sides then bottom[#bottom + 1] = p(xe.runs("v."), { jc = "center", before = GAP }) end
  end
  local adv = plain(meta.adversary_number)
  if adv == "" then adv = "____________" end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    row(top, p(xe.runs("CASE NO. ") .. xe.inl(debtor.case_number))) ..
    row(bottom, p(xe.runs("ADV. PROC. NO. " .. adv))) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Consent statement (FRBP 7008(a)), placed under the caption; the body does not repeat it.
-- ---------------------------------------------------------------------------

local function consent(meta, out)
  local j = need(meta, "jurisdiction")
  local debtor = need(meta, "debtor")
  out[#out + 1] = p(xe.runs("Jurisdiction and Consent", { b = true }), { jc = "center", line = BODY, keep = true })
  out[#out + 1] = p(xe.runs("This adversary proceeding arises in and relates to the ") .. xe.inl(debtor.chapter) ..
    xe.runs(" case of ") .. xe.inl(debtor.name[1]) .. xe.runs(", Case No. ") .. xe.inl(debtor.case_number) ..
    xe.runs(", pending in the United States Bankruptcy Court for the ") .. xe.inl(j.district) .. xe.runs("."),
    { line = BODY, first = INDENT })
  out[#out + 1] = p(xe.inl(need(j, "consent")), { line = BODY, first = INDENT })
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 9011-1: name, address, telephone and email of each signer; /s/ is acceptable): the date
-- (when given) at the margin, the signature column at the right margin; every line is kept with the next, so the
-- block never splits across pages.
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = need(meta, "signature")
  local lines = {}
  local function add(body, before, left) lines[#lines + 1] = { body = body, before = before or 0, left = left or SIG_LEFT } end
  if meta.date then add(xe.runs("Dated: ") .. xe.inl(meta.date), 0, 0) end
  add(xe.runs("Respectfully submitted,"))
  add(xe.inl(sig.firm), GAP)
  local function signer(s)
    add(xe.runs("/s/ ") .. xe.inl(s.signer), GAP)
    for _, l in ipairs(s.lines or {}) do add(xe.inl(l)) end
  end
  signer(sig)
  for _, also in ipairs(sig.also or {}) do
    add(xe.runs("-and-"), GAP)
    signer(also)
  end
  lines[1].before = SINGLE    -- typst: the block's above
  for i, l in ipairs(lines) do out[#out + 1] = p(l.body, { before = l.before, left = l.left, keep = i < #lines }) end
end

-- ---------------------------------------------------------------------------
-- The body, block by block as the typst template splits it
-- ---------------------------------------------------------------------------

local function body(src, out)
  src = src:gsub("\r", "")
  src = src:gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  src = src:gsub("^%s+", ""):gsub("%s+$", "")
  local chunks = {}
  local pos = 1
  while true do
    local s, e = src:find("\n[ \t]*\n", pos)
    chunks[#chunks + 1] = src:sub(pos, s and s - 1 or #src)
    if not s then break end
    pos = e + 1
  end
  for _, c in ipairs(chunks) do
    local t = c:gsub("^%s+", ""):gsub("%s+$", "")
    if t ~= "" then
      if t:sub(1, 1) == "#" then
        out[#out + 1] = xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
          xe.inl(upper(inlines((t:gsub("^#+", ""):gsub("#+$", "")))), { b = true }))
      elseif t:sub(1, 1) == ">" then
        -- a quotation: single-spaced, half an inch in on both sides, half a double line off the text
        local paras = read(t)[1].content
        for i, b in ipairs(paras) do
          out[#out + 1] = p(xe.inl(b.content), { left = INDENT, right = INDENT, before = i == 1 and QUOTE or 0,
            after = i == #paras and QUOTE or 0 })
        end
      else
        local n, rest = t:match("^(%d+)%.%s+(.*)$")
        local runs = n and (xe.runs(n .. ". ") .. xe.inl(inlines(rest))) or xe.inl(inlines(t))
        out[#out + 1] = p(runs, { line = BODY, first = INDENT })
      end
    end
  end
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtor", "caption", "title", "jurisdiction", "signature" }) do
    need(meta, k)
  end
  local f = io.open(PANDOC_STATE.input_files[1], "r")
  local src = f:read("a")
  f:close()
  local out = {}
  court_title(meta, out)
  out[#out + 1] = caption(meta)
  -- the title stands a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { jc = "center", before = BODY, after = SINGLE })
  consent(meta, out)
  body(src, out)
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- emptied metadata: pandoc would otherwise print the frontmatter title as a Title paragraph above the caption
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

-- Complaint, S.D. Fla. (flsd), docx engine: what the Word output adds to pandoc's conversion, so that it reads and
-- breaks as typst/flsd-complaint.typ does: the caption (S.D. Fla. L.R. 5.1(a)(5)), the numbered paragraphs
-- (Fed. R. Civ. P. 10(b)), the unnumbered lead-in, WHEREFORE and jury-demand paragraphs, the headings and the
-- signature block (L.R. 5.1(a)(6)). Everything printed comes from the sample's frontmatter and body: no case text
-- lives in this file. The page number comes from the reference's footer (docx/reference.xml).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent, 0.5 in
local GAP = BODY                       -- typst caption-gap
local STYLE_W = 4680                   -- typst style-width, 3.25 in
local TEXTW = 9360                     -- 6.5 in
local SIG = 5040                       -- typst sig-indent, 3.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function brk(s)
  return (s:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1"))
end

-- ---------------------------------------------------------------------------
-- Caption: court (L.R. 5.1(a)(5)(A)), docket line (B), style at the left (C), title (D)
-- ---------------------------------------------------------------------------

local function caption(meta, out)
  local function add(x) out[#out + 1] = x end
  add(p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" }))
  add(p(xe.runs("SOUTHERN DISTRICT OF FLORIDA", { b = true }), { jc = "center" }))
  if meta.division then
    add(p(xe.runs(pandoc.text.upper(plain(meta.division)), { b = true }), { jc = "center" }))
  end
  add(p(xe.runs("CIVIL CASE NO. " .. plain(meta.case_number)), { jc = "center", before = GAP }))
  local first = true
  local function row(x)
    add(p(x, { right = TEXTW - STYLE_W, before = first and GAP or 0 }))
    first = false
  end
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then row(xe.runs("v.")) end
    for _, n in ipairs(party.names) do row(xe.inl(n)) end
    row(xe.inl(party.designation))
  end
  row(xe.runs("/"))
  add(p(xe.runs(pandoc.text.upper(plain(meta.title)), { b = true }), { jc = "center", before = GAP, after = GAP }))
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch, first line indented: unnumbered, or the number, a tab to the end of its
-- half-inch box (typst: box(width: para-indent)), the text.
local function body_par(label, inlines)
  if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT,
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' })
end

-- Headings at the body pitch, bold: level 1 centered capitals, level 2 centered, level 3 at the margin; kept with
-- the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- ---------------------------------------------------------------------------
-- Signature block (L.R. 5.1(a)(6)): its lines kept together (typst: an unbreakable block)
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local rows = {
    { xe.runs("Dated: ") .. xe.inl(meta.date), 0, BODY },
    { xe.runs("Respectfully submitted,"), SIG, BODY },
    { xe.runs("By: /s/ ") .. xe.inl(sig.signer), SIG, BODY },
  }
  for _, l in ipairs(sig.lines or {}) do rows[#rows + 1] = { xe.inl(l), SIG, 0 } end
  for i, r in ipairs(rows) do
    out[#out + 1] = p(r[1], { left = r[2], before = r[3], keep = i < #rows })
  end
end

function Pandoc(doc)
  doc = doc:walk({ Str = function(s) return pandoc.Str(brk(s.text)) end })
  local meta = doc.meta
  local out = {}
  caption(meta, out)
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in) end
  local n = 0
  local unnumbered = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      unnumbered = stringify(b.content) == "DEMAND FOR JURY TRIAL"
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered or stringify(b):match("^WHEREFORE") then
        out[#out + 1] = body_par(nil, b.content)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("flsd.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

-- docx engine for the areb templates (the same layout as ../typst/areb-adversary-complaint.typ and
-- ../../motion-brief/typst/areb-motion-brief.typ). Pandoc passes the YAML frontmatter as the document
-- metadata; this filter writes the caption (a table with a rule under and beside the party block),
-- numbers the body paragraphs continuously, and appends the signature block and, when the metadata has
-- a `service` block, the certificate of service. Rule IDs (AREB-...) are in ../README.md.
-- Nothing here is case-specific: every name and number comes from the sample's frontmatter.
-- Styles live in reference.xml (fb render builds reference.docx from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 444 the body, 264 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 264                     -- typst pitch-single
local BODY = 444                       -- typst pitch-body
local TEXTW = 9360                     -- typst text-width, 6.5 in
local CAP_LEFT = 5040                  -- the party block, 3.5 in
local CAP_INSET, CAP_TOP, CAP_PAD = 288, 48, 216 -- typst caption-inset 0.2 in, caption-top 2.4 pt, caption-pad 10.8 pt
local CASE_PAD = 360                   -- typst case-pad 0.25 in
local COURT_BELOW, TITLE_BELOW = 384, 288 -- typst court-below 19.2 pt, title-below 14.4 pt
local SIG_LEFT = TEXTW - 4608          -- typst: the signature column, 3.2 in at the right margin
local SIG_GAP, COUNSEL_ABOVE = 216, 360 -- typst: 10.8 pt under "Respectfully submitted,", 18 pt above the counsel
local INDENT = 720                     -- typst paragraph-indent

local function need(meta, key)
  if meta[key] == nil then error("areb.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function plain(m)
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A single-spaced paragraph: o = { before, after, line, left, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A run of paragraphs kept on one page (typst: block(breakable: false)): every one but the last keeps with the next.
local function kept(ps)
  for i, x in ipairs(ps) do
    if i < #ps then ps[i] = x:gsub("^<w:p><w:pPr>", "<w:p><w:pPr>" .. xe.KEEP, 1) end
  end
  return ps
end

-- ---------------------------------------------------------------------------
-- Caption: court name, then the two-column block (debtor, parties | case numbers)
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function caption(meta)
  local court = need(meta, "court")
  local out = {}
  for _, k in ipairs({ "name", "district", "division" }) do
    out[#out + 1] = p(xe.runs(plain(need(court, k)):upper(), { b = true }),
      { jc = "center", after = k == "division" and COURT_BELOW or 0 })
  end

  local debtor = need(meta, "debtor")
  local left = {}
  -- IN RE: the debtor(s), centred, then the designation; a single line between the groups (typst party-block)
  left[#left + 1] = p(xe.runs("IN RE:"))
  for _, n in ipairs(debtor.names) do
    left[#left + 1] = p(xe.inl(n), { jc = "center" })
  end
  left[#left + 1] = p(xe.runs(#debtor.names > 1 and "Debtors." or "Debtor."), { jc = "right" })
  local in_adversary = meta.adversary_number ~= nil
  if in_adversary then
    -- plaintiffs, then "v." centred, then defendants, each group followed by its designation
    for i, n in ipairs(need(meta, "plaintiffs").names) do
      left[#left + 1] = p(xe.inl(n), { before = i == 1 and SINGLE or 0 })
    end
    left[#left + 1] = p(xe.inl(need(meta, "plaintiff_designation")), { jc = "right" })
    left[#left + 1] = p(xe.runs("v."), { jc = "center", before = SINGLE, after = SINGLE })
    for _, n in ipairs(need(meta, "defendants").names) do
      left[#left + 1] = p(xe.inl(n))
    end
    left[#left + 1] = p(xe.inl(need(meta, "defendant_designation")), { jc = "right" })
  end

  -- Right, at the bottom: the case numbers a line apart, on the party block's own lines.
  local right = { p(xe.runs("Case No. " .. plain(need(debtor, "case_number")))) }
  right[#right + 1] = p(xe.runs("Chapter " .. plain(need(debtor, "chapter"))), { before = SINGLE })
  if in_adversary then
    right[#right + 1] = p(xe.runs("Adv. Proc. No. " .. plain(meta.adversary_number)), { before = SINGLE })
  end

  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders>'
    .. string.format(RULE, "bottom") .. string.format(RULE, "right")
    .. '</w:tcBorders><w:tcMar><w:top w:w="' .. CAP_TOP .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_PAD
    .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CASE_PAD
    .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar><w:vAlign w:val="bottom"/></w:tcPr>'
    .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'

  -- the document title, after the caption (typst: court-below above, title-below below)
  out[#out + 1] = p(xe.inl(need(meta, "title"), { b = true }), { jc = "center", before = COURT_BELOW, after = TITLE_BELOW })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (LR 5005-4, FRBP 9011)
-- ---------------------------------------------------------------------------

local function signature(meta, dated)
  local sig = need(meta, "signature")
  local block = {}
  if dated ~= nil then
    block[#block + 1] = p(xe.runs("Dated: ") .. xe.inl(dated), { before = TITLE_BELOW })
  end
  block[#block + 1] = p(xe.runs("Respectfully submitted,"), { left = SIG_LEFT, before = TITLE_BELOW, after = SIG_GAP })
  block[#block + 1] = p(xe.runs("s/ " .. plain(need(sig, "signer"))), { left = SIG_LEFT })
  for _, l in ipairs(sig.lines or {}) do
    block[#block + 1] = p(xe.inl(l), { left = SIG_LEFT })
  end
  local out = kept(block)

  -- counsel: every group's names and lines, then the telephone number (LR 5005-4); one block
  local counsel = {}
  for _, g in ipairs(need(meta, "counsel")) do
    for _, item in ipairs(g.names or {}) do counsel[#counsel + 1] = xe.inl(item) end
    for _, l in ipairs(g.lines or {}) do counsel[#counsel + 1] = xe.inl(l) end
  end
  counsel[#counsel + 1] = xe.inl(need(meta, "phone"))
  local cs = {}
  for i, c in ipairs(counsel) do cs[#cs + 1] = p(c, { before = i == 1 and COUNSEL_ABOVE or 0 }) end
  for _, x in ipairs(kept(cs)) do out[#out + 1] = x end
  return out
end

-- The certificate of service (typst `certificate`): one block, 24 pt below the counsel.
local function certificate(meta)
  local svc = need(meta, "service")
  local out = {}
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", before = 480, after = SIG_GAP })
  out[#out + 1] = p(xe.runs("I certify that on ") .. xe.inl(need(svc, "date")) ..
    xe.runs(", the foregoing motion and memorandum in support were served electronically through the Court\u{2019}s " ..
      "CM/\u{200B}ECF system on the parties registered to receive notice, and by first-class United States mail, " ..
      "postage prepaid, on the parties listed below who are not registered."),
    { line = BODY, first = INDENT, after = SIG_GAP })
  for i, party in ipairs(need(svc, "parties")) do
    out[#out + 1] = p(xe.inl(party), { after = i == #svc.parties and TITLE_BELOW or 0 })
  end
  out[#out + 1] = p(xe.runs("s/ " .. plain(need(meta, "signature").signer)), { left = SIG_LEFT })
  return kept(out)
end

-- ---------------------------------------------------------------------------
-- Numbered paragraphs: every ordered-list item is one paragraph, numbered continuously through
-- the whole document (FRCP 10(b)), as the typst template does with its counter.
-- ---------------------------------------------------------------------------

local number = 0

local function numbered(list)
  local out = pandoc.List()
  for _, item in ipairs(list.content) do
    number = number + 1
    local blocks = pandoc.List(item)
    local first = blocks[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inl = pandoc.List({ pandoc.Str(number .. "."), pandoc.Space() })
      inl:extend(first.content)
      blocks[1] = pandoc.Para(inl)
    end
    out:insert(pandoc.Div(blocks, pandoc.Attr("", {}, { { "custom-style", "Numbered Paragraph" } })))
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(I)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("CM/ECF"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A body paragraph that anchors a footnote has no widow control ("Body Text Note", docx/reference.xml).
local function Para(el)
  local note = false
  el:walk({ Note = function() note = true end })
  if note then return pandoc.Div({ el }, pandoc.Attr("", {}, { ["custom-style"] = "Body Text Note" })) end
end

-- ---------------------------------------------------------------------------
-- Document
-- ---------------------------------------------------------------------------

local function finish(doc)
  local meta = doc.meta
  -- The caption carries the title and the signature carries the date; pandoc must not add its own
  -- title block, author or date lines, so they are taken out of the metadata here.
  local dated = meta.date
  local blocks = {}
  for _, b in ipairs(caption(meta)) do blocks[#blocks + 1] = xe.raw(b) end
  local body = doc:walk({ OrderedList = numbered }).blocks:walk({ Inlines = xe.inlines })
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta, dated)) do blocks[#blocks + 1] = xe.raw(b) end
  if meta.service ~= nil then
    for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = xe.raw(b) end
  end
  meta.title = nil
  meta.author = nil
  meta.date = nil
  return pandoc.Pandoc(blocks, meta)
end

return { { Str = break_rules, Para = Para }, { Pandoc = finish } }

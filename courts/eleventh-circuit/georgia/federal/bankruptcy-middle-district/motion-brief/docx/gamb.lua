-- gamb.lua (docx engine): the motion with memorandum as Word paragraphs, so that it reads and breaks as
-- typst/gamb-motion-brief.typ does:
--   * the court lines, the Form 416D caption (a table: the parties on the left, the case information on the right,
--     a rule on the right and bottom of the party column), and the title;
--   * the body: paragraphs in Body Text (pandoc writes them, with their footnotes), the author's headings in the
--     heading styles, block quotations single-spaced and indented on both sides;
--   * the date line and the signature blocks, kept together;
--   * the certificate of service (LBR 9013-3(a)): its statement, the parties served through CM/ECF and by mail, and
--     the attorney's signature, kept together.
-- The headings are the author's own (no numbering is added). Every name, date and address comes from the sample's
-- frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 276, 240 -- typst pitch-body, pitch-single, gap (half a body line)
local QUOTE_GAP = 138                   -- typst quote-gap, half a single line
local INDENT = 720                      -- typst para-indent, 0.5 in
local TEXTW = 9360                      -- 6.5 in
local CAP_LEFT = 5184                   -- typst caption-left, 3.6 in
local CAP_INSET, RIGHT_INSET = 288, 504 -- typst caption-inset 0.2 in, right-inset 0.35 in
local V_INDENT, ROLE_INDENT = 1728, 3168 -- typst v-indent 1.2 in, role-indent 2.2 in
local TITLE_INSET = 468                 -- typst title-inset 0.325 in
local QUOTE_INSET = 1080                -- typst quote-inset 0.75 in
local SIG_LEFT = 4752                   -- typst 6.5 in - sig-column 3.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep } (keep: with the next paragraph and its
-- lines together).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Court lines, caption and title (GAMB-CAP-001 to GAMB-CAP-003)
-- ---------------------------------------------------------------------------

local function court_lines(m, out)
  for i, l in ipairs(m.court) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", after = i == #m.court and BODY or 0 })
  end
end

-- The party column: "In re:" before the debtor, "v." between the plaintiffs and the defendants, the role under
-- each party (typst: caption()).
local function party_lines(parties)
  local out = {}
  for i, party in ipairs(parties) do
    if i > 1 and plain(parties[i - 1].kind) ~= "debtor" then
      out[#out + 1] = p(xe.runs("v."), { before = GAP, after = GAP, left = V_INDENT })
    end
    if plain(party.kind) == "debtor" then out[#out + 1] = p(xe.runs("In re:"), { after = GAP }) end
    for _, n in ipairs(party.names) do out[#out + 1] = p(xe.inl(n)) end
    out[#out + 1] = p(xe.inl(party.role), { left = ROLE_INDENT, after = i == #parties and GAP or 0 })
  end
  return out
end

local function caption(m, out)
  local adv = plain(m.adversary_number)
  local right = {
    p(xe.runs("Bankruptcy Case No. " .. plain(m.case_number)), { after = GAP }),
    p(xe.runs("Chapter " .. plain(m.chapter)), { after = GAP }),
    p(xe.runs("Adversary Proceeding No. " .. (adv == "" and "________" or adv))),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. rule .. '/><w:right ' ..
    rule .. '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(party_lines(m.parties)) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. RIGHT_INSET ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

local function upper(x)
  if pandoc.utils.type(x) == "Inlines" then
    return x:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(plain(x))
end

-- the title stands a body line below the caption (Word has no space after a table: the title takes it before)
local function title(m, out)
  out[#out + 1] = p(xe.inl(upper(m.title), { b = true }), { before = BODY, after = GAP, left = TITLE_INSET,
    right = TITLE_INSET, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Signature and certificate of service (GAMB-SIG-001, GAMB-SERV-001)
-- ---------------------------------------------------------------------------

-- The attorneys' signature lines, one block per attorney (LBR 9011-1(b)), a body line above each; the role line only
-- when it is not empty. Each entry: { runs, space before, left indent }.
local function attorney_lines(m, lines)
  for _, s in ipairs(m.signature) do
    lines[#lines + 1] = { xe.runs("/s/ " .. plain(s.signer)), BODY, SIG_LEFT }
    for _, l in ipairs({ s.signer, s.bar }) do lines[#lines + 1] = { xe.inl(l), 0, SIG_LEFT } end
    for _, l in ipairs(s.firm) do lines[#lines + 1] = { xe.inl(l), 0, SIG_LEFT } end
    for _, l in ipairs({ s.phone, s.email }) do lines[#lines + 1] = { xe.inl(l), 0, SIG_LEFT } end
    if plain(s.role) ~= "" then lines[#lines + 1] = { xe.inl(s.role, { i = true }), 0, SIG_LEFT } end
  end
end

-- Lines kept together (typst: one unbreakable block); the first takes `before`.
local function kept(lines, before, out)
  for i, l in ipairs(lines) do
    local o = l.o or {}
    o.keep, o.before, o.left = i < #lines, i == 1 and before or l[2], l[3]
    out[#out + 1] = p(l[1], o)
  end
end

-- The date line, then the attorneys (typst: signature-block()).
local function signature(m, out)
  local lines = { { xe.inl(m.dated), 0, 0 } }
  attorney_lines(m, lines)
  kept(lines, BODY, out)
end

-- The certificate: the statement (double-spaced, first-line indent), the parties served through CM/ECF and by
-- first-class mail, and the attorney's signature (LBR 9013-3(a)); one block in the template (typst: breakable: false).
local function certificate(m, out)
  local svc = m.service
  local lines = {
    { xe.runs("Certificate of Service", { b = true }), 0, 0, o = { jc = "center", after = GAP } },
    { xe.runs("I certify that on ") .. xe.inl(svc.date) .. xe.runs(" I filed the foregoing with the Clerk of Court " ..
      "using the CM/ECF system, which will send notification of the filing to the parties listed below who are " ..
      "registered CM/ECF users. I further certify that I served by first-class United States mail, postage prepaid, " ..
      "the parties listed below who are not registered CM/ECF users."), 0, 0, o = { line = BODY, first = INDENT } },
    { xe.runs("Served through CM/ECF:", { b = true }), GAP, 0 },
  }
  for _, l in ipairs(svc.ecf) do lines[#lines + 1] = { xe.inl(l), 0, 0 } end
  lines[#lines + 1] = { xe.runs("Served by first-class mail:", { b = true }), GAP, 0 }
  for _, l in ipairs(svc.mail) do lines[#lines + 1] = { xe.inl(l), 0, 0 } end
  attorney_lines(m, lines)
  kept(lines, BODY, out)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("Loan/Award": a zero-width space). Neither shows in the PDF text.
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
  local m = doc.meta
  local head = {}
  court_lines(m, head)
  caption(m, head)
  title(m, head)
  local blocks = {}
  for _, x in ipairs(head) do blocks[#blocks + 1] = xe.raw(x) end

  -- the body: pandoc writes the paragraphs (Body Text, with their footnotes) and the headings (the heading styles:
  -- level 1 centered capitals, level 2 bold, level 3 bold italic); block quotations as single-spaced paragraphs
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level >= 3 then b.content = pandoc.Inlines({ pandoc.Emph(b.content) }) end
      blocks[#blocks + 1] = b:walk({ Inlines = xe.inlines })
    elseif b.t == "Para" or b.t == "Plain" then
      blocks[#blocks + 1] = pandoc.Div({ pandoc.Para(b.content):walk({ Inlines = xe.inlines }) },
        { ["custom-style"] = "Body Text" })
    elseif b.t == "BlockQuote" then
      for i, q in ipairs(b.content) do
        blocks[#blocks + 1] = xe.raw(p(xe.inl(q.content), { before = i == 1 and GAP or QUOTE_GAP,
          after = i == #b.content and GAP or 0, left = QUOTE_INSET, right = QUOTE_INSET }))
      end
    else
      error("gamb.lua: unsupported block " .. b.t)
    end
  end

  local tail = {}
  signature(m, tail)
  certificate(m, tail)
  for _, x in ipairs(tail) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

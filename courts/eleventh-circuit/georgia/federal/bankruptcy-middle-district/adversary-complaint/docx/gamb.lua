-- gamb.lua (docx engine): the adversary complaint as Word paragraphs, so that it reads and breaks as
-- typst/gamb-adversary-complaint.typ does:
--   * the court lines, the Form 416D caption (a table: the parties on the left, the case information on the right,
--     a rule on the right and bottom of the party column), and the title;
--   * the paragraphs after the first heading, numbered 1, 2, ...; the "(a)" sub-items as hanging labels (pandoc's
--     fancy lists are off in docx/reference.xml, so "(a)" is text, not a list);
--   * the WHEREFORE paragraph, the date line and the signature blocks, kept together.
-- Every number, name and address comes from the sample's frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 276, 240 -- typst pitch-body, pitch-single, gap (half a body line)
local INDENT = 720                      -- typst para-indent, number-box and sub-label-width, 0.5 in
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

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, next, tab } (a hanging indent
-- writes no firstLine: Word takes firstLine over hanging). keep: with the next paragraph and its lines together;
-- next: with the next paragraph only; tab: a left tab stop (twips).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.next then props[#props + 1] = "<w:keepNext/>" end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
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

-- The party column: "In re:" before the debtor, "v." between the plaintiffs and the defendant, the role under
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

-- the title stands a body line below the caption (Word has no space after a table: the title takes it before)
local function title(m, out)
  local t = pandoc.utils.type(m.title) == "Inlines" and m.title:walk({
    Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }) or pandoc.text.upper(plain(m.title))
  out[#out + 1] = p(xe.inl(t, { b = true }), { before = BODY, after = GAP, left = TITLE_INSET, right = TITLE_INSET,
    jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Body (GAMB-CONT-002)
-- ---------------------------------------------------------------------------

-- Headings: single-spaced, half a body line above and below, kept with the text; level 1 centered capitals, level 2
-- bold, level 3 bold italic.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(GAP, GAP, SINGLE), xe.ind(0, nil, 0),
    xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, { b = true, i = el.level >= 3 }))
end

-- A chunk that starts with a lettered label, "(a)" or "(iv)": a sub-item.
local function is_label(el)
  return el ~= nil and el.t == "Str" and el.text:match("^%([%w]+%)$") ~= nil
end

-- The inlines after the first one (and the space after it).
local function tail(content)
  local i = 2
  if content[i] and (content[i].t == "Space" or content[i].t == "SoftBreak") then i = i + 1 end
  local out = pandoc.Inlines({})
  for j = i, #content do out:insert(content[j]) end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature (GAMB-SIG-001 to GAMB-SIG-003): the date line, "Respectfully submitted," and one block per attorney
-- (LBR 9011-1(b)); every line kept with the next (typst: one unbreakable block).
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local lines = { { xe.inl(m.date), 0, 0 }, { xe.runs("Respectfully submitted,"), BODY, SIG_LEFT } }
  for _, s in ipairs(m.signature) do
    lines[#lines + 1] = { xe.runs("/s/ " .. plain(s.signer)), BODY, SIG_LEFT }
    for _, l in ipairs({ s.signer, s.bar }) do lines[#lines + 1] = { xe.inl(l), 0, SIG_LEFT } end
    for _, l in ipairs(s.firm) do lines[#lines + 1] = { xe.inl(l), 0, SIG_LEFT } end
    for _, l in ipairs({ s.phone, s.email }) do lines[#lines + 1] = { xe.inl(l), 0, SIG_LEFT } end
    lines[#lines + 1] = { xe.inl(s.role, { i = true }), 0, SIG_LEFT }
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { keep = i < #lines, before = i == 1 and BODY or l[2], left = l[3] })
  end
end

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

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local m = doc.meta
  local out = {}
  court_lines(m, out)
  caption(m, out)
  title(m, out)

  -- paragraphs after the first heading are numbered; a paragraph before it is the unnumbered lead-in
  local seen, k = false, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      seen = true
      out[#out + 1] = heading(b)
    elseif (b.t == "Para" or b.t == "Plain") and is_label(b.content[1]) then
      -- the label half an inch in, a tab to one inch, the text hanging at one inch
      out[#out + 1] = p(xe.runs(b.content[1].text .. "\t") .. xe.inl(tail(b.content)),
        { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT })
    elseif (b.t == "Para" or b.t == "Plain") and seen then
      k = k + 1
      out[#out + 1] = p(xe.runs(k .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = 2 * INDENT })
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = GAP, after = GAP, left = QUOTE_INSET, right = QUOTE_INSET })
      end
    else
      error("gamb.lua: unsupported block " .. b.t)
    end
  end

  -- the WHEREFORE paragraph stays with the signature (typst: sticky)
  out[#out + 1] = p(xe.inl(m.wherefore), { next = true, line = BODY, first = INDENT })
  signature(m, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

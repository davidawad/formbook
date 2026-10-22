-- U.S. Bankruptcy Court, W.D. Mich., adversary complaint (miwb), DOCX engine (docs/DOCX.md). Mirrors
-- ../typst/miwb-adversary-complaint.typ:
--   * the caption (court, "In re" debtor block with the case number and chapter, the adversary parties with the
--     adversary number, each party block ending in the "_____/" rule), then the title, centered and bold;
--   * allegations numbered 1, 2, ... (Fed. R. Civ. P. 10(b)): the number at 0.5 in, the text at 1 in (style Numbered
--     Para). Headings, block quotations and WHEREFORE clauses are not numbered;
--   * the statements the rules require (LBR 9004(c); Fed. R. Bankr. P. 7008(a); LBR 7008) are numbered and printed
--     after the first paragraph under JURISDICTION, from the frontmatter;
--   * lists are lettered a., b., ... (after a WHEREFORE: A., B., ...) with the style List Letter;
--   * the signing block as a borderless two-column table.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter, and the court's
-- name is the court's own title. Font, spacing, margins and the "Page n of N" footer are styles and section settings
-- in docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276               -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local LEFT, GUTTER, RIGHT = 5040, 360, 3960 -- typst caption-left 3.5 in, caption-gutter 0.25 in, the rest of 6.5 in
local RULE_W = 4896                         -- typst rule-width, 3.4 in
local NAME_IND, DESIG_IND = 720, 1728       -- typst name-indent 0.5 in, designation-indent 1.2 in
local ROW_GAP, V_GAP = 144, 96              -- typst row-gap 7.2 pt, v-gap 4.8 pt
local SIG_LEFT, SIG_GUTTER, SIG_RIGHT = 4176, 288, 4896 -- typst sig-left 2.9 in, sig-gutter 0.2 in, the rest
local COURT_TITLE = { "UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF MICHIGAN" }

local function need(meta, key)
  if meta[key] == nil then error("miwb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- A metadata value as plain text, as typst reads the YAML string: pandoc's abbreviation no-break spaces undone.
local function txt(v)
  return v and (pandoc.utils.stringify(v):gsub("\u{00A0}", " ")) or ""
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

local function flag(v)
  if type(v) == "boolean" then return v end
  return txt(v) == "true"
end

-- A single-spaced paragraph: o = { before, after, line, left, jc, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A metadata line, its inline markdown kept (typst inl()).
local function line(v, o)
  return xe.inl(v, o)
end

-- Vertical space of its own (typst v() or a block's space above): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- The rule ending a party block ("_____/"): an underlined tab to a right tab stop, then the slash (typst slash-rule).
local function slash_rule()
  return p('<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>' .. xe.runs("/"),
    { tabs = '<w:tabs><w:tab w:val="right" w:pos="' .. RULE_W .. '"/></w:tabs>' })
end

local function cell(width, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. inner .. '</w:tc>'
end

-- Two columns and the gutter, fixed widths, no borders and no cell margins; the row is not split across pages
-- (typst: one grid row in an unbreakable block).
local function grid3(widths, left, right)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (widths[1] + widths[2] + widths[3]) .. '" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. widths[1] .. '"/><w:gridCol w:w="' .. widths[2] .. '"/><w:gridCol w:w="'
    .. widths[3] .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(widths[1], left) .. cell(widths[2], p("")) .. cell(widths[3], right) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- the caption (Fed. R. Bankr. P. 7010, 9004(b); LBR 9004(a), (b)) and the title
-- ---------------------------------------------------------------------------

local function caption(meta)
  local debtor = need(meta, "debtor")
  local plaintiff = need(meta, "plaintiff")
  local defendants = need(meta, "defendants")
  local case = need(meta, "case")
  local out = {}
  for _, l in ipairs(COURT_TITLE) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end

  -- row 1: the debtor (In re:), with its case number and chapter on the right (LBR 9004(a): chapter under the number)
  local left = { p(xe.runs("In re:")) }
  for i, n in ipairs(items(debtor.names)) do
    left[#left + 1] = p(line(n), { left = NAME_IND, before = i == 1 and SINGLE or 0 })
  end
  left[#left + 1] = p(line(debtor.designation), { left = DESIG_IND })
  left[#left + 1] = slash_rule()
  local right = { p(xe.runs("Case No. ") .. line(case.number)), p(xe.runs("Chapter ") .. line(case.chapter)) }
  if case.judge ~= nil and txt(case.judge) ~= "" then right[#right + 1] = p(line(case.judge)) end
  out[#out + 1] = space(BODY)
  out[#out + 1] = grid3({ LEFT, GUTTER, RIGHT }, table.concat(left), table.concat(right))

  -- row 2: the plaintiff, "v.", the defendants; the adversary number on the right
  left = {}
  for _, n in ipairs(items(plaintiff.names)) do left[#left + 1] = p(line(n)) end
  left[#left + 1] = p(line(plaintiff.designation), { left = DESIG_IND })
  left[#left + 1] = p(xe.runs("v."), { before = V_GAP })
  for i, n in ipairs(items(defendants.names)) do left[#left + 1] = p(line(n), { before = i == 1 and V_GAP or 0 }) end
  left[#left + 1] = p(line(defendants.designation), { left = DESIG_IND })
  left[#left + 1] = slash_rule()
  out[#out + 1] = space(ROW_GAP)
  out[#out + 1] = grid3({ LEFT, GUTTER, RIGHT }, table.concat(left),
    p(xe.runs("Adv. Proc. No. ") .. line(need(meta, "adversary_number"))))

  -- LBR 9004(b): the description of the document, centered, immediately before the body (typst upper(): the text
  -- is upper-cased, not a style, so the PDF text agrees)
  out[#out + 1] = p(xe.runs(txt(need(meta, "title")):upper(), { b = true }), { jc = "center", before = BODY, after = SINGLE })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- signing block (LBR 9004(d)): the typst layout, as a borderless table
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(items(need(sig, "firm"))) do right[#right + 1] = p(line(l), { before = i == 1 and SINGLE or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ " .. txt(need(sig, "signer"))), { before = SINGLE })
  right[#right + 1] = p(xe.runs(txt(need(sig, "signer")) .. " (" .. txt(need(sig, "bar_id")) .. ")"))
  right[#right + 1] = p(line(need(sig, "role")))
  right[#right + 1] = p(xe.runs("BUSINESS ADDRESS:"), { before = SINGLE })
  for _, l in ipairs(items(need(sig, "address"))) do right[#right + 1] = p(line(l)) end
  right[#right + 1] = p(xe.runs("Telephone " .. txt(need(sig, "phone"))))
  right[#right + 1] = p(xe.runs("Email " .. txt(need(sig, "email"))))
  return space(BODY) .. grid3({ SIG_LEFT, SIG_GUTTER, SIG_RIGHT },
    p(xe.runs("Dated: " .. txt(need(meta, "date")))), table.concat(right))
end

-- ---------------------------------------------------------------------------
-- the body
-- ---------------------------------------------------------------------------

-- the statements the rules require (MIWB-FORM-005, -007), from the frontmatter (see ../README.md)
local function generated_statements(meta)
  local case = need(meta, "case")
  local debtor = need(meta, "debtor")
  local dates = need(meta, "dates")
  local scope = "the United States Bankruptcy Court for the Western District of Michigan"
  if meta.division ~= nil and txt(meta.division) ~= "" then
    scope = "the " .. txt(meta.division) .. " of " .. scope
  end
  local petition = "The petition commencing the underlying Chapter " .. txt(case.chapter) .. " case was filed on "
    .. txt(dates.petition) .. ". " .. txt(dates.later)
  local relation = "This Adversary Proceeding arises in and relates to *In re " .. txt(debtor.name) .. "*, Case No. "
    .. txt(case.number) .. " (Chapter " .. txt(case.chapter) .. "), pending in " .. scope .. "."
  local core
  if flag(need(meta, "core")) then
    core = "This Adversary Proceeding is a core proceeding under 28 U.S.C. § 157(b)(2). "
  else
    core = "This Adversary Proceeding is a non-core proceeding under 28 U.S.C. § 157(c). "
  end
  local consent
  if flag(need(meta, "consent")) then
    consent = "The Plaintiff consents to the entry of a final order or judgment by the Bankruptcy Court."
  else
    consent = "The Plaintiff does not consent to the entry of a final order or judgment by the Bankruptcy Court."
  end
  return { petition, relation, core .. consent }
end

local function inlines_of_markdown(md)
  local doc = pandoc.read(md, "markdown+smart")
  local b = doc.blocks[1]
  return b and b.content or pandoc.Inlines({})
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows
-- in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

-- A paragraph that anchors a footnote has no widow control (the "Note" styles, docx/reference.xml).
local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function styled(style, inlines)
  if has_note(inlines) then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- an allegation: its number, a tab to the text (typst label-box)
local function numbered(inlines, n)
  local content = pandoc.Inlines({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
  content:extend(inlines)
  return styled("Numbered Para", content)
end

local function finish(doc)
  local meta = doc.meta
  local out = { xe.raw(caption(meta)) }
  local n = 0
  local after_jurisdiction = false
  local generated_done = false
  local prayer = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      prayer = false
      local s = pandoc.utils.stringify(b.content)
      after_jurisdiction = s:lower():find("^jurisdiction") ~= nil and not generated_done
      -- Levels 1 and 2 in capitals, as typst's upper() (the text is upper-cased, not a style).
      local c = b.content
      if b.level <= 2 then c = c:walk({ Str = function(x) return pandoc.Str(x.text:upper()) end }) end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):find("^WHEREFORE") then
        prayer = true
        out[#out + 1] = styled("Body Text", b.content)
      else
        n = n + 1
        out[#out + 1] = numbered(b.content, n)
        if after_jurisdiction then
          for _, g in ipairs(generated_statements(meta)) do
            n = n + 1
            out[#out + 1] = numbered(inlines_of_markdown(g), n)
          end
          after_jurisdiction = false
          generated_done = true
        end
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local label = prayer and string.char(64 + i) or string.char(96 + i)
        local content = pandoc.Inlines({ pandoc.Str(label .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        content:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "List Letter" })
      end
    else
      -- The block quotation (Block Text) is kept as pandoc writes it.
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(meta)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }

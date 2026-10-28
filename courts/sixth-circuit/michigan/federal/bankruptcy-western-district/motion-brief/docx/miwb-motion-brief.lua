-- U.S. Bankruptcy Court, W.D. Mich., motion with brief in support in an adversary proceeding (miwb), DOCX engine
-- (docs/DOCX.md). Mirrors ../typst/miwb-motion-brief.typ: two documents, as the court's ECF Administrative Procedures
-- file them (the brief is an attachment to the motion):
--   * the motion: court, caption (the "In re" debtor block with the case number and chapter, the adversary parties
--     with the adversary number, each party block ending in the "_____/" rule), the motion's title, its body from the
--     frontmatter with the LBR 9004(c) statement after its first paragraph, the signing block (LBR 9004(d));
--   * the brief in support: a new section (its page numbers restart at 1), the same caption, the brief's title, the
--     markdown body, the signing block.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter, and the court's
-- name is the court's own title. Font, spacing and margins are styles and section settings in docx/reference.xml (fb
-- render builds the reference document from it); the page-number footer and the sections are written here.
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
  if meta[key] == nil then error("miwb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
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
-- the caption (Fed. R. Bankr. P. 7010, 9004(b); LBR 9004(a), (b)) and the description of the document
-- ---------------------------------------------------------------------------

local function document_head(meta, title)
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

  -- LBR 9004(b): the description of the document, centered, on the body pitch, immediately before the body (typst
  -- upper(): the text is upper-cased, not a style, so the PDF text agrees)
  out[#out + 1] = p(xe.runs(txt(title):upper(), { b = true }), { jc = "center", line = BODY, before = BODY, after = SINGLE })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the LBR 9004(c) statement and the signing block (LBR 9004(d)): the typst layout, as a borderless table
-- ---------------------------------------------------------------------------

local function petition_statement(meta)
  local case = need(meta, "case")
  local dates = need(meta, "dates")
  return "The petition commencing the underlying Chapter " .. txt(case.chapter) .. " case was filed on "
    .. txt(dates.petition) .. ". " .. txt(dates.later)
end

local function signature(meta)
  local sig = need(meta, "signature")
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(items(need(sig, "firm"))) do right[#right + 1] = p(line(l), { before = i == 1 and SINGLE or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ " .. txt(need(sig, "signer"))), { before = SINGLE })
  right[#right + 1] = p(xe.runs(txt(need(sig, "signer")) .. " (" .. txt(need(sig, "bar_id")) .. ")"))
  for _, l in ipairs(items(sig.also)) do right[#right + 1] = p(line(l)) end
  right[#right + 1] = p(line(need(sig, "role")))
  right[#right + 1] = p(xe.runs("BUSINESS ADDRESS:"), { before = SINGLE })
  for _, l in ipairs(items(need(sig, "address"))) do right[#right + 1] = p(line(l)) end
  right[#right + 1] = p(xe.runs("Telephone " .. txt(need(sig, "phone"))))
  right[#right + 1] = p(xe.runs("Email " .. txt(need(sig, "email"))))
  return space(BODY) .. grid3({ SIG_LEFT, SIG_GUTTER, SIG_RIGHT },
    p(xe.runs("Dated: " .. txt(need(meta, "date")))), table.concat(right))
end

-- The footer of both sections: the page number at 11 pt in a single line (a PAGE field), 731 twips above the page foot
-- so its baseline stands where typst sets it (footer-descent 30 %). fb render adds it (FORMBOOK_FOOTERS): a sectPr
-- naming the reference document's own footer id can dangle, as pandoc may renumber it (fb-595.64, fb-595.70).
local FOOTER_ID = "rIdMiwbPage"
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr>'
  .. '<w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:t>1</w:t></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT_PG = '<w:footerReference w:type="default" r:id="' .. FOOTER_ID .. '"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="731" w:gutter="0"/>'

-- The end of the motion's section: the next section (the brief, the last: FORMBOOK_FINAL) starts on a new page and
-- restarts its page numbers (typst pagebreak() and counter(page).update(1)). The paragraph that holds it is a 1 pt
-- line, so it never pushes the signature on.
local SECTION_END = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>'
  .. SECT_PG .. '</w:sectPr></w:pPr></w:p>'
local FINAL = '<w:sectPr>' .. SECT_PG .. '<w:pgNumType w:start="1"/></w:sectPr>'

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local fh = assert(io.open(path, "w"))
  fh:write(text)
  fh:close()
end

-- ---------------------------------------------------------------------------
-- the body
-- ---------------------------------------------------------------------------

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

-- The blocks of a markdown body: headings (level 1 in capitals, as typst's upper()), paragraphs, lettered lists, the
-- block quotation as pandoc writes it (Block Text). `insert`: inlines of a paragraph put after the first paragraph.
local function body_blocks(blocks, out, insert)
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local c = b.content
      if b.level == 1 then c = c:walk({ Str = function(x) return pandoc.Str(x.text:upper()) end }) end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled("Body Text", b.content)
      if insert then
        out[#out + 1] = styled("Body Text", insert)
        insert = nil
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local content = pandoc.Inlines({ pandoc.Str(string.char(96 + i) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        content:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "List Letter" })
      end
    else
      out[#out + 1] = b
    end
  end
end

-- The motion's body is a YAML block scalar of markdown: pandoc reads it as blocks (MetaBlocks); a single line is
-- MetaInlines.
local function motion_blocks(motion)
  local body = need(motion, "body")
  if pandoc.utils.type(body) == "Blocks" or (type(body) == "table" and body[1] ~= nil and body[1].t == "Para") then
    return pandoc.Blocks(body)
  end
  return pandoc.read(txt(body), "markdown+smart").blocks
end

local function finish(doc)
  local meta = doc.meta
  local motion = need(meta, "motion")
  local motion_out, brief_out = {}, {}
  body_blocks(motion_blocks(motion), motion_out, pandoc.read(petition_statement(meta), "markdown+smart").blocks[1].content)
  body_blocks(doc.blocks, brief_out)

  local body = pandoc.Blocks({ xe.raw(document_head(meta, need(motion, "title"))) })
  body:extend(pandoc.Blocks(motion_out):walk({ Inlines = xe.inlines }))
  body:insert(xe.raw(signature(meta) .. SECTION_END .. document_head(meta, need(meta, "brief_title"))))
  body:extend(pandoc.Blocks(brief_out):walk({ Inlines = xe.inlines }))
  body:insert(xe.raw(signature(meta)))
  write_file("FORMBOOK_FOOTERS", FOOTER_ID .. "\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }

-- ianb adversary complaint (docx engine): the same layout as ../typst/ianb-adversary-complaint.typ (the rules are in
-- ../README.md). Pandoc passes the YAML frontmatter as the document metadata; this filter
--   * writes the caption (court name, party block ruled right and below, case numbers and title) and the signature
--     block from the frontmatter, so no case text is in this file;
--   * numbers the body paragraphs (1., 2., ...; a tab to the Numbered Paragraph tab stop); the paragraphs before the
--     first heading and those beginning COMES NOW or WHEREFORE are not numbered (Plain Paragraph);
--   * letters an ordered list (the prayer) (a), (b), ... as Prayer Item paragraphs;
--   * leaves the metadata title out of the body: the caption carries it.
-- Styles live in reference.xml (fb render builds reference.docx from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                       -- typst pitch-single
local TEXTW = 9360                       -- typst text-width, 6.5 in
local PARTY_COL = 4752                   -- typst party-col, 3.3 in
local PARTY_INSET, PARTY_PAD = 240, 200  -- typst party-inset 12 pt, party-pad 10 pt
local NAME_INDENT = 720                  -- typst name-indent
local CASE_INSET, CASE_TOP = 320, 2 * SINGLE -- typst case-inset 16 pt, case-top two single lines
local COURT_BELOW, CAPTION_BELOW = 360, 288 -- typst court-below 18 pt, caption-below 14.4 pt
local SIG_ABOVE, SIG_LEFT = 432, 3744    -- typst sig-above 21.6 pt, sig-left 2.6 in
local SIG_GAP, ROLE_GAP = 576, 240       -- typst sig-gap 28.8 pt, role-gap 12 pt

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function need(meta, key, where)
  if meta == nil or meta[key] == nil then
    error("frontmatter field missing: " .. (where and (where .. ".") or "") .. key)
  end
  return meta[key]
end

-- A single-spaced paragraph: o = { before, after, line, left, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
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

-- An empty paragraph of `twips` height (typst: a block of that height).
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- ---------------------------------------------------------------------------
-- Caption (FRBP 7010, 9004(b)): both columns on the single line grid, top aligned
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function caption(meta)
  local out = {
    p(xe.runs("IN THE UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }),
    p(xe.runs("FOR THE NORTHERN DISTRICT OF IOWA", { b = true }), { jc = "center", after = COURT_BELOW }),
  }
  local left = {
    p(xe.runs("In re:")),
    p(xe.inl(need(meta, "debtor")), { left = NAME_INDENT, before = SINGLE }),
    p(xe.runs("Debtor."), { jc = "right", before = SINGLE }),
    p(xe.inl(need(meta, "plaintiff")), { left = NAME_INDENT, before = SINGLE }),
    p(xe.runs("Plaintiff,"), { jc = "right", before = SINGLE }),
    p(xe.runs("v."), { left = NAME_INDENT, before = SINGLE }),
    p(xe.inl(need(meta, "defendant")), { left = NAME_INDENT, before = SINGLE }),
    p(xe.runs("Defendant."), { jc = "right", before = SINGLE }),
  }
  local adv = meta.adversary_no and xe.inl(meta.adversary_no) or xe.runs("Adversary Case No. ____________")
  local right = {
    p(xe.inl(need(meta, "chapter")), { before = CASE_TOP }),
    p(xe.inl(need(meta, "case_no"))),
    p(adv, { before = SINGLE }),
    p(xe.inl(need(meta, "title"), { b = true }), { before = SINGLE }),
  }
  local w2 = TEXTW - PARTY_COL
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. PARTY_COL .. '"/><w:gridCol w:w="' .. w2 .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr><w:tc><w:tcPr><w:tcW w:w="' .. PARTY_COL .. '" w:type="dxa"/><w:tcBorders>'
    .. string.format(RULE, "bottom") .. string.format(RULE, "right")
    .. '</w:tcBorders><w:tcMar><w:bottom w:w="' .. PARTY_PAD .. '" w:type="dxa"/><w:right w:w="' .. PARTY_INSET
    .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. w2 .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CASE_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  out[#out + 1] = space(CAPTION_BELOW)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (FRBP 9011; N.D. Iowa L.R. 9010-1(b): address, telephone, FAX and e-mail below the signature)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local s = need(meta, "signature")
  local function f(k) return xe.inl(need(s, k, "signature")) end
  local out = {
    p(xe.runs("Dated: ") .. f("date") .. xe.runs("\tRespectfully submitted,"), { tab = SIG_LEFT, before = SIG_ABOVE }),
    p(xe.runs("/s/ ", { i = true }) .. xe.inl(need(s, "signer", "signature"), { i = true }), { left = SIG_LEFT, before = SIG_GAP }),
    p(f("signer") .. xe.runs(", ") .. f("bar"), { left = SIG_LEFT }),
  }
  for _, l in ipairs(need(s, "address", "signature")) do out[#out + 1] = p(xe.inl(l), { left = SIG_LEFT }) end
  out[#out + 1] = p(f("firm"), { left = SIG_LEFT })
  out[#out + 1] = p(xe.runs("Telephone: ") .. f("phone"), { left = SIG_LEFT })
  out[#out + 1] = p(xe.runs("Fax: ") .. f("fax"), { left = SIG_LEFT })
  out[#out + 1] = p(xe.runs("E-mail: ") .. f("email"), { left = SIG_LEFT })
  out[#out + 1] = p(f("role"), { left = SIG_LEFT, before = ROLE_GAP })
  return kept(out)
end

-- ---------------------------------------------------------------------------
-- Body: numbered, plain and lettered paragraphs (the typst render-body rules)
-- ---------------------------------------------------------------------------

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    assert(#item == 1 and (item[1].t == "Para" or item[1].t == "Plain"), "a prayer item is one paragraph")
    local inl = pandoc.Inlines({ pandoc.Str("(" .. string.char(96 + i) .. ")"), TAB })
    inl:extend(item[1].content)
    out[#out + 1] = styled("Prayer Item", inl)
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows
-- in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function finish(doc)
  local meta = doc.meta
  -- FRBP 7008(a): the complaint must say whether the pleader consents to final orders or judgment.
  assert(pandoc.utils.stringify(pandoc.Div(doc.blocks)):find("consent", 1, true),
    "FRBP 7008(a): the complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court")
  doc:walk({ Note = function() error("footnotes are not supported in the adversary complaint template") end })
  local blocks = {}
  for _, b in ipairs(caption(meta)) do blocks[#blocks + 1] = xe.raw(b) end
  local front, number = true, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      assert(b.level <= 2, "headings deeper than ## are not in the adversary complaint template")
      front = false
      blocks[#blocks + 1] = b
    elseif b.t == "Para" or b.t == "Plain" then
      local text = pandoc.utils.stringify(b)
      if front or text:match("^COMES NOW") or text:match("^WHEREFORE") then
        blocks[#blocks + 1] = styled("Plain Paragraph", b.content)
      else
        number = number + 1
        local inl = pandoc.Inlines({ pandoc.Str(number .. "."), TAB })
        inl:extend(b.content)
        blocks[#blocks + 1] = styled("Numbered Paragraph", inl)
      end
    elseif b.t == "OrderedList" then
      for _, x in ipairs(lettered(b)) do blocks[#blocks + 1] = x end
    else
      error("ianb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  blocks = pandoc.Blocks(blocks):walk({ Inlines = xe.inlines })
  for _, b in ipairs(signature(meta)) do blocks:insert(xe.raw(b)) end
  meta.title = nil
  meta.author = nil
  meta.date = nil
  return pandoc.Pandoc(blocks, meta)
end

return { { Str = break_rules }, { Pandoc = finish } }

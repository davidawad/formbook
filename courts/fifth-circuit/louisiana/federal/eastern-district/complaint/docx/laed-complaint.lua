-- E.D. La. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> Word on the styles of docx/reference.xml
-- (fb render builds reference.docx from it; pandoc reads the sample with fancy lists off, reference.xml pandoc-from).
-- Mirrors typst/laed-complaint.typ: the court title, the caption (a table, the party column closed by a right and a
-- bottom rule), the title, the body (numbered paragraphs, paragraphs after an "<!-- unnumbered -->" marker,
-- lettered items, single-spaced block quotations) and the signature block on the right half. Page numbers come from
-- the reference's footer (none on page 1). Paragraph numbers are typed as text by this filter, as the typst
-- template does it; Word's list numbering is not used, so every viewer shows the same numbers.
-- Nothing here is case-specific: every name and number comes from the sample's frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                      -- typst pitch-single 13.8 pt
local COURT_BELOW = 276                 -- typst court-below 13.8 pt
local TITLE_ABOVE, TITLE_BELOW = 480, 240 -- typst title-above 24 pt, title-below 12 pt
local SIG_ABOVE, SIG_GAP = 164, 204     -- typst sig-above 8.2 pt, sig-gap 10.2 pt
local SIG_IND = 4320                    -- typst sig-indent 3 in
local TEXT_W = 9360                     -- 6.5 in: letter, 1 in margins
local CAP_L, CAP_G = 4680, 504          -- typst caption-left 3.25 in, caption-gutter 0.35 in
local CAP_PAD = 288                     -- typst caption-pad 0.2 in
local RULE_W = 15                       -- the caption's 0.75 pt bottom rule: Word and LibreOffice add its width below the
                                        -- row (typst draws the stroke over the cell edge), so the title's space is less by it
local VERSUS_IND, DESIG_IND = 720, 2160 -- typst versus-indent 0.5 in, designation-indent 1.5 in
local BLANK = "______________"

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function or_blank(v)
  if v == "" then return BLANK end
  return v
end

-- A single-pitch paragraph: o = { before, after, left, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, SINGLE)
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

-- The court title: two centred bold single lines.
local function court_title()
  return p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
    .. p(xe.runs("EASTERN DISTRICT OF LOUISIANA", { b = true }), { jc = "center" })
end

-- The caption: the parties on the left (the cell's right and bottom borders are the caption rules), the case fields
-- on the right; every line single-pitch. typst court-below above it.
local function caption(meta)
  local left = {}
  for i, side in ipairs(meta.caption) do
    if i > 1 then left[#left + 1] = p(xe.runs("v."), { left = VERSUS_IND }) end
    for _, n in ipairs(side.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIG_IND })
  end
  local right = {
    p(xe.runs("CIVIL ACTION NO. " .. or_blank(plain(meta.civil_action_no))), {}),
    p(xe.runs("SECTION: " .. or_blank(plain(meta.section)))),
    p(xe.runs("JUDGE " .. or_blank(plain(meta.judge)))),
    p(xe.runs("MAGISTRATE JUDGE " .. or_blank(plain(meta.magistrate)))),
  }
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  -- the rules stand off the party block by typst caption-pad: a right cell margin, and below the last line an empty
  -- line of that height (a bottom cell margin would add to the whole row in LibreOffice, even where the case fields
  -- are the taller column)
  local mar = '<w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  left[#left + 1] = xe.para({ xe.spacing(0, 0, CAP_PAD) }, "")
  local cap_r = TEXT_W - CAP_L - CAP_G
  local function cell(w, inner, extra)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
  end
  return xe.para({ xe.spacing(0, 0, COURT_BELOW) }, "")
    .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_L .. '"/><w:gridCol w:w="' .. CAP_G .. '"/><w:gridCol w:w="'
    .. cap_r .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_L, table.concat(left), rule .. mar) .. cell(CAP_G, p(""))
    .. cell(cap_r, table.concat(right)) .. '</w:tr></w:tbl>'
end

-- The title and, when the sample demands a jury, "JURY TRIAL DEMANDED": centred bold single lines, typst
-- title-above and title-below around them.
local function title(meta)
  local ps = { p(xe.inl(meta.title, { b = true }), { jc = "center", before = TITLE_ABOVE - RULE_W, keep = true }) }
  if meta.jury_demand == true then ps[#ps + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { jc = "center" }) end
  ps[#ps] = ps[#ps]:gsub('w:after="0"', 'w:after="' .. TITLE_BELOW .. '"', 1)
  return table.concat(ps)
end

-- The signature block (typst signature-block): "Dated" on the left and "Respectfully submitted," at the signature
-- indent (a tab), then each group of names and lines at the indent, typst sig-gap above each; kept on one page.
local function signature(meta)
  local date = plain(meta.date)
  local s = { p((date ~= "" and xe.runs("Dated: ") .. xe.inl(meta.date) or "") .. xe.runs("\tRespectfully submitted,"),
    { before = SIG_ABOVE, tab = SIG_IND }) }
  for _, group in ipairs(meta.signature) do
    local ls = {}
    for _, n in ipairs(group.names or {}) do ls[#ls + 1] = n end
    for _, l in ipairs(group.lines or {}) do ls[#ls + 1] = l end
    for i, l in ipairs(ls) do
      s[#s + 1] = p(xe.inl(l), { left = SIG_IND, before = i == 1 and SIG_GAP or 0 })
    end
  end
  return table.concat(kept(s))
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1332(d)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function is_text(el, pattern)
  return el ~= nil and el.t == "Str" and el.text:match(pattern) ~= nil
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function unnumbered_marker(b)
  return b.t == "RawBlock" and b.format == "html" and b.text:match("^<!%-%-%s*unnumbered%s*%-%->%s*$") ~= nil
end

local function finish(doc)
  local meta = doc.meta
  local out = { xe.raw(court_title() .. caption(meta) .. title(meta)) }

  local n = 0
  local skip_number = false
  for _, b in ipairs(doc.blocks) do
    if unnumbered_marker(b) then
      skip_number = true
    elseif b.t == "Para" then
      local c = pandoc.Inlines(b.content)
      if skip_number then
        -- an unnumbered paragraph (after the marker): a lead-in, the prayer's WHEREFORE, the jury demand
        out[#out + 1] = pandoc.Para(c)
      elseif (is_text(c[1], "^%a%.$") or is_text(c[1], "^%(%a%)$")) and c[2] and c[2].t == "Space" then
        -- a lettered item: the author types the label; a tab moves the text to the hanging indent
        local lead = pandoc.Inlines({ c[1], pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        for k = 3, #c do lead:insert(c[k]) end
        out[#out + 1] = styled("Lettered", lead)
      else
        n = n + 1
        local lead = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
        lead:extend(c)
        out[#out + 1] = styled("Numbered Paragraph", lead)
      end
      skip_number = false
    elseif b.t == "Header" then
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), b.content)
    else
      -- the block quotations (Block Text) as pandoc writes them
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(meta)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }

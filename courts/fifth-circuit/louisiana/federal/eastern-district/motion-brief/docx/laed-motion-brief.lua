-- E.D. La. memorandum supporting a motion, DOCX engine (docs/DOCX.md): the markdown contract -> Word on the styles of
-- docx/reference.xml (fb render builds reference.docx from it; pandoc reads the sample with fancy lists off,
-- reference.xml pandoc-from). Mirrors typst/laed-motion-brief.typ: the court title, the caption (a table, the party
-- column closed by a right and a bottom rule; VERSUS between the sides; the case fields on the right as a label over
-- its value), the title, the body (not numbered; lettered items; single-spaced block quotations), the signature
-- block on the right half and, when the sample gives `service`, the certificate of service. Page numbers come from
-- the reference's footer (none on page 1). LR 7.7 (25 pages) is checked by the typst build; the docx breaks its
-- pages where typst does (Gate 4).
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
local BODY, INDENT = 480, 720           -- typst pitch-body 24 pt, para-indent 0.5 in
local CERT_ABOVE = 480                  -- typst cert-above 24 pt
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
    if i > 1 then left[#left + 1] = p(xe.runs("VERSUS"), { left = VERSUS_IND }) end
    for _, n in ipairs(side.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIG_IND })
  end
  -- each case field a label over its value (or a blank to fill in)
  local right = {}
  for _, f in ipairs({ { "CIVIL ACTION NO.", meta.civil_action_no }, { "SECTION:", meta.section },
    { "JUDGE", meta.judge }, { "MAGISTRATE JUDGE", meta.magistrate } }) do
    right[#right + 1] = p(xe.runs(f[1]))
    right[#right + 1] = p(xe.runs(or_blank(plain(f[2]))))
  end
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

-- The title: centred bold single lines, typst title-above and title-below around it.
local function title(meta)
  return p(xe.inl(meta.title, { b = true }), { jc = "center", before = TITLE_ABOVE - RULE_W, after = TITLE_BELOW })
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

-- The certificate of service (FRCP 5(b)(2)(E); typst certificate): typst cert-above, the centred bold title on the
-- body pitch kept with the text, two body paragraphs, the electronic signature at the signature indent.
local function certificate(s)
  local function body(inner, keep)
    return xe.para({ keep and xe.KEEP or "", xe.spacing(0, 0, BODY), xe.ind(0, nil, INDENT) }, inner)
  end
  return xe.para({ xe.KEEP, xe.spacing(CERT_ABOVE, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
      xe.runs("CERTIFICATE OF SERVICE", { b = true }))
    .. body(xe.runs("I hereby certify that a copy of the foregoing has been served on all counsel of record via the "
      .. "Court\u{2019}s Electronic Filing System."))
    .. body(xe.runs("This ") .. xe.inl(s.date) .. xe.runs("."))
    .. p(xe.runs("/s/ ") .. xe.inl(s.signer), { left = SIG_IND, before = SIG_ABOVE })
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

local function finish(doc)
  local meta = doc.meta
  local out = { xe.raw(court_title() .. caption(meta) .. title(meta)) }

  for _, b in ipairs(doc.blocks) do
    local c = b.t == "Para" and pandoc.Inlines(b.content) or nil
    if c and (is_text(c[1], "^%a%.$") or is_text(c[1], "^%(%a%)$")) and c[2] and c[2].t == "Space" then
      -- a lettered item: the author types the label; a tab moves the text to the hanging indent
      local lead = pandoc.Inlines({ c[1], pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
      for k = 3, #c do lead:insert(c[k]) end
      out[#out + 1] = styled("Lettered", lead)
    elseif b.t == "Header" then
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), b.content)
    else
      -- body paragraphs (Body Text, First Paragraph) and block quotations (Block Text) as pandoc writes them
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(meta) .. (meta.service and certificate(meta.service) or "")))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }

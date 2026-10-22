-- E.D. Ky. complaint, DOCX engine (docs/DOCX.md): the markdown contract (../README.md) -> Word on the styles of
-- docx/reference.xml (fb render builds reference.docx from it). Mirrors typst/kyed-complaint.typ: the court title,
-- the civil action number and e-filing legend, the caption (a table row between a top and a bottom rule: the
-- parties, and JURY DEMAND on the right), the title, the body (numbered paragraphs, paragraphs marked "~ ", lettered
-- lists, single-spaced block quotations) and the signature block in the right column. Paragraph numbers and list
-- letters are typed as text by this filter, as the typst template does it; Word's list numbering is not used, so
-- every viewer shows the same numbers. Requirement IDs (KYED-...) are in ../README.md. Nothing here is
-- case-specific: every name and number comes from the sample's frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                      -- typst pitch-single 13.8 pt
local COURT_BELOW = 480                 -- typst court-below 24 pt
local RULE_SPACE = 240                  -- typst rule-space 12 pt
local RULE_W = 15                       -- the caption's 0.75 pt rules (w:sz 6): Word and LibreOffice set each rule in a
                                        -- height of its own (typst draws the strokes over the block's edges), so the
                                        -- space below each rule is less by it
local DESIG_ABOVE = 120                 -- typst desig-above 6 pt
local VERSUS_SPACE = 240                -- typst versus-space 12 pt
local TITLE_ABOVE, TITLE_BELOW = 480, 240 -- typst title-above 24 pt, title-below 12 pt
local SIG_ABOVE, SIG_GAP = 480, 240     -- typst sig-above 24 pt, sig-gap 12 pt
local SIG_IND = 4896                    -- typst sig-indent 3.4 in
local TEXT_W = 9360                     -- 6.5 in: letter, 1 in margins
local CAP_R, CAP_G = 3456, 360          -- typst caption-right 2.4 in, caption-gutter 0.25 in
local VERSUS_IND = 1728                 -- typst versus-indent 1.2 in
local DESIG_PAD = 432                   -- typst designation-pad 0.3 in

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- A single-pitch paragraph: o = { before, after, left, right, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- An empty line of `h` twips (a space of its own, where Word would drop a paragraph's space).
local function space(h)
  return xe.para({ xe.spacing(0, 0, h) }, "")
end

-- A run of paragraphs kept on one page (typst: block(breakable: false)): every one but the last keeps with the next.
local function kept(ps)
  for i, x in ipairs(ps) do
    if i < #ps then ps[i] = x:gsub("^<w:p><w:pPr>", "<w:p><w:pPr>" .. xe.KEEP, 1) end
  end
  return ps
end

-- KYED-FIRST-001, KYED-FIRST-002: the court title, one centred bold line per `court` entry, in capitals.
local function court_title(meta)
  local out = {}
  for _, l in ipairs(meta.court) do out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }), { jc = "center" }) end
  return table.concat(out)
end

-- The civil action number and the e-filing legend, centred; then the caption: the parties (names, the designation
-- right-aligned, "v." between them) and, on the right, JURY DEMAND, in one table row whose top and bottom borders are
-- the rules; the space inside the rules an empty line of typst rule-space at the top and foot of the cells.
local function caption(meta)
  local head = p(xe.runs("Civil Action No. " .. plain(meta.case_number)), { jc = "center", before = COURT_BELOW })
  if meta.electronically_filed == true then head = head .. p(xe.runs("ELECTRONICALLY FILED"), { jc = "center" }) end
  local left = { space(RULE_SPACE - RULE_W) }
  for i, side in ipairs(meta.caption) do
    if i > 1 then left[#left + 1] = p(xe.runs("v."), { left = VERSUS_IND, before = VERSUS_SPACE }) end
    for j, n in ipairs(side.names) do
      left[#left + 1] = p(xe.inl(n), { before = (i > 1 and j == 1) and VERSUS_SPACE or 0 })
    end
    local d = plain(side.designation)
    if d ~= "" then left[#left + 1] = p(xe.inl(side.designation), { jc = "right", right = DESIG_PAD, before = DESIG_ABOVE }) end
  end
  left[#left + 1] = space(RULE_SPACE)
  local right = space(RULE_SPACE - RULE_W) .. (meta.jury_demand == true and p(xe.runs("JURY DEMAND")) or p(""))
  local cap_l = TEXT_W - CAP_R - CAP_G
  local function cell(w, inner)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. inner .. '</w:tc>'
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  return head .. space(RULE_SPACE)
    .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top ' .. rule .. '<w:left w:val="nil"/><w:bottom ' .. rule .. '<w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. cap_l .. '"/><w:gridCol w:w="' .. CAP_G .. '"/><w:gridCol w:w="'
    .. CAP_R .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(cap_l, table.concat(left)) .. cell(CAP_G, p("")) .. cell(CAP_R, right) .. '</w:tr></w:tbl>'
end

-- The title of the paper: a centred bold single line in capitals, typst title-above and title-below around it.
local function title(meta)
  return p(xe.runs(pandoc.text.upper(plain(meta.title)), { b = true }),
    { jc = "center", before = TITLE_ABOVE - RULE_W, after = TITLE_BELOW, keep = true })
end

-- KYED-SIG-001: the signature block in the right column, single spaced, kept on one page: "Respectfully submitted,",
-- the preamble (typst sig-gap above it), the s/ line (sig-gap above it) and the signer's lines.
local function signature(meta)
  local sig = meta.signature
  local s = { p(xe.runs("Respectfully submitted,"), { left = SIG_IND, before = SIG_ABOVE }) }
  for i, l in ipairs(sig.preamble or {}) do
    s[#s + 1] = p(xe.inl(l), { left = SIG_IND, before = i == 1 and SIG_GAP or 0 })
  end
  s[#s + 1] = p(xe.runs("s/" .. plain(sig.signer)), { left = SIG_IND, before = SIG_GAP })
  for _, l in ipairs(sig.lines or {}) do s[#s + 1] = p(xe.inl(l), { left = SIG_IND }) end
  return table.concat(kept(s))
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1332(d)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("d/b/a", "and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after
-- it. Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- An unnumbered paragraph is marked "~ " in the sample (the opening sentence, the WHEREFORE lead-in, the demand).
local function unnumbered(c)
  return c[1] ~= nil and c[1].t == "Str" and c[1].text == "~" and c[2] ~= nil and c[2].t == "Space"
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function finish(doc)
  local meta = doc.meta
  local out = { xe.raw(court_title(meta) .. caption(meta) .. title(meta)) }

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local c = pandoc.Inlines(b.content)
      if unnumbered(c) then
        c:remove(1); c:remove(1)
        out[#out + 1] = pandoc.Para(c)
      else
        -- KYED-CONT-001: a numbered paragraph (Fed. R. Civ. P. 10(b)): the number, a tab to 1 in, the text
        n = n + 1
        local lead = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        lead:extend(c)
        out[#out + 1] = styled("Numbered Paragraph", lead)
      end
    elseif b.t == "OrderedList" then
      -- KYED-CONT-002: a list is lettered (a), (b), ...; the label at the indent, a tab to the hanging indent
      for i, item in ipairs(b.content) do
        for j, x in ipairs(item) do
          if j == 1 and (x.t == "Para" or x.t == "Plain") then
            local lead = pandoc.Inlines({ pandoc.Str("(" .. string.char(96 + i) .. ")"), TAB })
            lead:extend(x.content)
            out[#out + 1] = styled("Lettered", lead)
          else
            out[#out + 1] = x
          end
        end
      end
    elseif b.t == "Header" then
      local c = b.content
      if b.level == 1 then c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end }) end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    else
      -- the block quotations (Block Text) as pandoc writes them
      out[#out + 1] = b
    end
  end

  -- The last block keeps with the signature block (typst sticky): its style's "Keep" variant (docx/reference.xml).
  local last = out[#out]
  if last.t == "Para" then
    out[#out] = styled("Body Text Keep", last.content)
  elseif last.t == "Div" and last.attributes["custom-style"] then
    last.attributes["custom-style"] = last.attributes["custom-style"] .. " Keep"
  elseif last.t == "BlockQuote" then
    out[#out] = pandoc.Div(last.content, { ["custom-style"] = "Block Text Keep" })
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(meta)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }

-- E.D. Ky. memorandum in support of a motion, DOCX engine (docs/DOCX.md): the markdown contract (../README.md) ->
-- Word on the styles of docx/reference.xml (fb render builds reference.docx from it). Mirrors
-- typst/kyed-motion-brief.typ: the court title, the case number, the caption (the parties between a top and a bottom
-- rule), the title, the body (headings, paragraphs, block quotations; footnotes are pandoc's native footnotes, style
-- Footnote Text), the conclusion kept with the signature block ("Dated:" and "Respectfully submitted," on one line),
-- and the optional certificate of service on a new page. Requirement IDs (KYED-...) are in ../README.md. Nothing
-- here is case-specific: every name and number comes from the sample's frontmatter.
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
local CERT_TEXT_BELOW = 240             -- typst cert-text-below 12 pt
local SERVICE_GAP = 180                 -- typst service-gap 9 pt
local SIG_IND = 4896                    -- typst sig-indent 3.4 in
local TEXT_W = 9360                     -- 6.5 in: letter, 1 in margins
local VERSUS_IND = 1728                 -- typst versus-indent 1.2 in
local DESIG_PAD = 432                   -- typst designation-pad 0.3 in

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- The frontmatter as written (typst reads the strings, not markdown: the title's apostrophe stays straight).
local function raw_meta()
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  local s = f and f:read("a") or ""
  if f then f:close() end
  return s ~= "" and pandoc.json.decode(s, false) or {}
end

-- A single-pitch paragraph: o = { before, after, left, right, jc, keep, tab, border }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
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

-- KYED-FIRST-001, KYED-FIRST-002: the court title (one centred bold line per `court` entry, in capitals), the case
-- number, the caption (the parties in a one-cell table whose top and bottom borders are the rules; the space inside
-- the rules an empty line of typst rule-space at the top and foot) and the title of the paper.
local function first_page(meta, raw)
  local out = {}
  for _, l in ipairs(meta.court) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }), { jc = "center" })
  end
  local label = meta.case_label and plain(meta.case_label) or "Civil Action No."
  out[#out + 1] = p(xe.runs(label .. " " .. plain(meta.case_number)), { jc = "center", before = COURT_BELOW })
  local cell = { space(RULE_SPACE - RULE_W) }
  for i, side in ipairs(meta.caption) do
    if i > 1 then cell[#cell + 1] = p(xe.runs("v."), { left = VERSUS_IND, before = VERSUS_SPACE }) end
    for j, n in ipairs(side.names) do
      cell[#cell + 1] = p(xe.inl(n), { before = (i > 1 and j == 1) and VERSUS_SPACE or 0 })
    end
    if plain(side.designation) ~= "" then
      cell[#cell + 1] = p(xe.inl(side.designation), { jc = "right", right = DESIG_PAD, before = DESIG_ABOVE })
    end
  end
  cell[#cell + 1] = space(RULE_SPACE)
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  out[#out + 1] = space(RULE_SPACE)
    .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top ' .. rule .. '<w:left w:val="nil"/><w:bottom ' .. rule .. '<w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. TEXT_W .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. TEXT_W .. '" w:type="dxa"/></w:tcPr>' .. table.concat(cell) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
  -- the title as written, in capitals, centred bold single lines; typst title-above and title-below around it
  local title = raw.title or plain(meta.title)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(title), { b = true }),
    { jc = "center", before = TITLE_ABOVE - RULE_W, after = TITLE_BELOW, keep = true })
  return table.concat(out)
end

-- KYED-SIG-001: "Dated:" at the margin, "Respectfully submitted," at the signature indent (a tab), then the preamble,
-- the signature line (typst sig-gap above each group) and the signer's lines; kept on one page.
local function signature(meta)
  local sig = meta.signature
  local s = { p(xe.runs("Dated: ") .. xe.inl(meta.date) .. xe.runs("\tRespectfully submitted,"),
    { before = SIG_ABOVE, tab = SIG_IND }) }
  for i, l in ipairs(sig.preamble or {}) do
    s[#s + 1] = p(xe.inl(l), { left = SIG_IND, before = i == 1 and SIG_GAP or 0 })
  end
  s[#s + 1] = p(xe.inl(sig.sign_line), { left = SIG_IND, before = SIG_GAP })
  for _, l in ipairs(sig.lines or {}) do s[#s + 1] = p(xe.inl(l), { left = SIG_IND }) end
  return table.concat(kept(s))
end

-- KYED-SIG-002: the optional certificate of service on a new page: its heading (Certificate Heading), its text (a
-- body paragraph), the service blocks (single lines, each kept whole, typst service-gap between them) and the
-- signature line and designation at the signature indent.
local function certificate(meta)
  local c = meta.certificate
  if c == nil then return {} end
  local out = {
    pandoc.Div({ pandoc.Para({ pandoc.Str("CERTIFICATE"), pandoc.Space(), pandoc.Str("OF"), pandoc.Space(),
      pandoc.Str("SERVICE") }) }, { ["custom-style"] = "Certificate Heading" }),
    pandoc.Div({ pandoc.Para(c.text) }, { ["custom-style"] = "Body Text" }),
  }
  local x = {}
  for i, s in ipairs(c.services) do
    local block = {}
    for j, l in ipairs(s) do
      block[#block + 1] = p(xe.inl(l), { before = j == 1 and (i == 1 and CERT_TEXT_BELOW or SERVICE_GAP) or 0 })
    end
    x[#x + 1] = table.concat(kept(block))
  end
  x[#x + 1] = table.concat(kept({ p(xe.inl(c.sign_line), { left = SIG_IND, before = SIG_ABOVE }),
    p(xe.inl(c.designation), { left = SIG_IND }) }))
  out[#out + 1] = xe.raw(table.concat(x))
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows
-- in the PDF text. On the body and the metadata alike (pandoc walks both).
-- A doubled sign keeps with its number ("¶¶ 133-134", as typst binds it): the space after it a no-break space.
local function bind_doubled(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and l[i + 1].t == "Space" and l[i].text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
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

local function finish(doc)
  local meta = doc.meta
  local out = { xe.raw(first_page(meta, raw_meta())) }
  local in_conclusion = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local c = b.content
      if b.level == 1 then
        -- the conclusion keeps with the signature block (typst sticky); level 1 in capitals, as typst's upper()
        in_conclusion = pandoc.text.upper(plain(c)) == "CONCLUSION"
        c = c:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
      end
      out[#out + 1] = pandoc.Header(math.min(b.level, 4), c)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled(in_conclusion and "Conclusion" or "Body Text", b.content)
    else
      -- the block quotations (Block Text) as pandoc writes them
      out[#out + 1] = b
    end
  end
  for _, b in ipairs(certificate(meta)) do out[#out + 1] = b end
  -- the signature block goes before the certificate
  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  local at = #body + 1
  for i, b in ipairs(body) do
    if b.t == "Div" and b.attributes["custom-style"] == "Certificate Heading" then at = i break end
  end
  body:insert(at, xe.raw(signature(meta)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind_doubled }, { Pandoc = finish } }

-- lawb motion with memorandum, docx engine. Mirrors typst/lawb-motion-brief.typ; rules and conventions are in
-- ../README.md (Engines). The cover (court name, the caption box: parties left, case numbers right, a rule round and
-- between them; the title lines and a rule under them), the lettered items, the signature block (LBR 5005-1(b)) and
-- the certificate of service (LBR 9013-1(d), when the frontmatter supplies one) are built here. Font, spacing, margins,
-- footnotes and the "- n -" page number are styles and section settings in docx/reference.xml (fb render builds the
-- reference document from it). Letters are typed text, as the typst template types them. Content-agnostic: every
-- case-specific word comes from the sample's frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line and a footnote line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 280                        -- typst pitch-single
local TEXTW = 9360                        -- typst text-width, 6.5 in
local COURT = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF LOUISIANA" }
local CAP_LEFT = 4896                     -- typst caption-left 3.4 in
local CAP_INSET_X, CAP_INSET_Y = 173, 144 -- typst caption-inset-x 8.65 pt, caption-inset-y 0.1 in
local PARTY_STEP = 720                    -- typst party-step 0.5 in
local COURT_BELOW, CAPTION_BELOW = 480, 480 -- typst court-below, caption-below 24 pt
local RULE_ABOVE, RULE_BELOW = 240, 480   -- typst rule-above 12 pt, rule-below 24 pt
local SIG_LEFT = 3960                     -- typst sig-left 2.75 in
local SIG_ABOVE = 240                     -- typst signature-above 12 pt
local CERT_ABOVE = 480                    -- typst certificate-above 24 pt

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
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

-- A single-spaced paragraph: o = { before, after, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- A line of text: a string as runs, a metadata value as its inlines.
local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- Single-spaced lines (typst line-stack): an empty item is a blank line, the next line a line lower. An item is
-- { text, level }; o = { left, keep } for every line (keep: all but the last line keep with the next).
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, 0
  for i, l in ipairs(lines) do
    if txt(l[1]) == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(line(l[1]), { before = gap, left = (o.left or 0) + (l[2] or 0) * PARTY_STEP,
        keep = o.keep and i < #lines })
      gap = 0
    end
  end
  return table.concat(out)
end

local function cell(width, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. inner .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption box, title, rule
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(m)
  local out = {}
  for _, l in ipairs(COURT) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end
  out[#out + 1] = space(COURT_BELOW)

  local left, right = {}, {}
  for _, it in ipairs(m.caption.left) do left[#left + 1] = { it.t, tonumber(txt(it.i)) or 0 } end
  for _, t in ipairs(items(m.caption.right)) do right[#right + 1] = { t, 0 } end
  local borders = {}
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    borders[#borders + 1] = string.format(RULE, side)
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>'
    .. '<w:tblBorders>' .. table.concat(borders) .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="' .. CAP_INSET_Y .. '" w:type="dxa"/><w:left w:w="' .. CAP_INSET_X .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. CAP_INSET_Y .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET_X .. '" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(CAP_LEFT, stack(left)) .. cell(TEXTW - CAP_LEFT, stack(right))
    .. '</w:tr></w:tbl>'

  for i, l in ipairs(items(m.title)) do
    out[#out + 1] = p(xe.runs(txt(l):upper(), { b = true }), { jc = "center", before = i == 1 and CAPTION_BELOW or 0 })
  end
  -- The rule under the title: a 1 pt line with the rule as its bottom border.
  out[#out + 1] = xe.para({ '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>',
    xe.spacing(RULE_ABOVE, RULE_BELOW, 20) }, "")
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 5005-1(b)): single-spaced at 2.75 in, kept on one page, after a space of its own
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local lines = { { s.lead }, { "" }, { s.firm },
    { pandoc.Inlines({ pandoc.Str("By:"), pandoc.Space() }) .. pandoc.Inlines(s.by) } }
  for _, l in ipairs(items(s.lines)) do lines[#lines + 1] = { l } end
  lines[#lines + 1] = { "" }
  for _, l in ipairs(items(s.counsel_for)) do lines[#lines + 1] = { l } end
  return space(SIG_ABOVE) .. stack(lines, { left = SIG_LEFT, keep = true })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12:146(C)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("d/b/a"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there even after a word joiner): the space becomes a no-break space, as wide.
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

-- The markdown blocks as the typst template sets them (typst blocks()).
local function convert(blocks, out)
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = pandoc.Header(math.min(b.level, 2), b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled("Body Text", b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(string.char(96 + i) .. ".\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("List Letter", inl)
      end
    else
      error("lawb-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  return out
end

-- The blocks of a metadata value: a YAML block scalar is a Blocks list; a single line is one paragraph.
local function blocks_of(v)
  if v.t == "MetaBlocks" or pandoc.utils.type(v) == "Blocks" then return pandoc.Blocks(v) end
  return pandoc.Blocks({ pandoc.Para(pandoc.Inlines(v)) })
end

local function finish(doc)
  local m = doc.meta
  local out = convert(doc.blocks, { xe.raw(cover(m)) })
  out[#out + 1] = xe.raw(signature(m))
  if m.certificate then
    out[#out + 1] = xe.raw(space(CERT_ABOVE))
    convert(blocks_of(m.certificate), out)
  end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }

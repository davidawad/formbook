-- U.S. Bankruptcy Court, M.D. La.: adversary complaint, DOCX engine (docs/DOCX.md). Mirrors
-- ../typst/lamb-adversary-complaint.typ: Form 416 caption, court name, title, unnumbered opening paragraph, numbered
-- allegations (FRCP 10(b) via FRBP 7010), unnumbered WHEREFORE, lettered prayer, signature block. Every string comes
-- from the YAML frontmatter of the sample; nothing is case-specific here. Font, spacing, margins and the page number
-- are styles and section settings in docx/reference.xml (fb render builds the reference document from it). Numbers
-- are typed text, as the typst template types them, so every viewer shows the same numbering.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 626 the body, 313 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 626, 313              -- typst pitch-body 31.3 pt, pitch-single 15.65 pt
local COL, GUTTER = 4500, 360              -- typst caption-col, caption-gutter 0.25 in
local CAP_PAD, CASE_PAD = 173, 144         -- typst caption-pad 8.65 pt, case-pad 0.1 in
local LABEL, V_IND = 2160, 1080            -- typst label-indent 1.5 in, v-indent 0.75 in
local COURT_BELOW = 360                    -- typst court-below 18 pt
local IN_RE_GAP, GROUP_GAP, V_GAP = 48, 216, 108 -- typst in-re-gap 2.4 pt, group-gap 10.8 pt, v-gap 5.4 pt
local CAPTION_BELOW, TITLE_BELOW = 216, 360 -- typst caption-below 10.8 pt, title-below 18 pt
local SIG_ABOVE, SIG_GAP = 360, 216        -- typst signature-above 18 pt, signature-gap 10.8 pt

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("lamb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- A metadata value as plain text, as typst reads the YAML string: pandoc's abbreviation no-break spaces ("No. 5") undone.
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

-- A single-spaced paragraph: o = { before, after, line, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A metadata line as plain text (typst line-block with a string).
local function line(v, o)
  return xe.runs(txt(v), o)
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- Two columns and the gutter, fixed widths, no borders and no cell margins unless a cell sets its own; the row is
-- not split across pages (typst: one grid row).
local function grid3(left, right, left_extra, right_extra)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (2 * COL + GUTTER) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. COL .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="' .. COL
    .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(COL, left, left_extra) .. cell(GUTTER, p("")) .. cell(COL, right, right_extra) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Caption (Form 416 style) and title
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(m)
  local out = {
    p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }),
    p(xe.runs("MIDDLE DISTRICT OF LOUISIANA", { b = true }), { jc = "center" }),
    space(COURT_BELOW),
  }
  local left = { p(xe.runs("In re:")), p(line(need(m, "debtor")), { before = IN_RE_GAP }),
    p(xe.runs("Debtor."), { left = LABEL }) }
  for i, l in ipairs(items(need(m, "plaintiff"))) do
    left[#left + 1] = p(line(l), { before = i == 1 and GROUP_GAP or 0 })
  end
  left[#left + 1] = p(xe.runs("Plaintiff,"), { left = LABEL })
  left[#left + 1] = p(xe.runs("v."), { left = V_IND, before = V_GAP })
  for i, l in ipairs(items(need(m, "defendants"))) do
    left[#left + 1] = p(line(l), { before = i == 1 and V_GAP or 0 })
  end
  left[#left + 1] = p(xe.runs("Defendant."), { left = LABEL })
  local right = {
    p(xe.runs("Case No. " .. txt(need(m, "case_no")))),
    p(line(need(m, "chapter")), { before = IN_RE_GAP }),
    p(xe.runs("Adversary Proceeding No. " .. txt(need(m, "adv_no"))), { before = IN_RE_GAP }),
  }
  local borders = '<w:tcBorders>' .. string.format(RULE, "bottom") .. string.format(RULE, "right") .. '</w:tcBorders>'
  local mar = '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = grid3(table.concat(left), table.concat(right), borders .. mar,
    '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>')
  -- The title, centred bold capitals on the body pitch (typst upper(); the text is upper-cased, not a style).
  out[#out + 1] = p(xe.runs(txt(need(m, "title")):upper(), { b = true }),
    { jc = "center", line = BODY, before = CAPTION_BELOW, after = TITLE_BELOW })
  return table.concat(out)
end

-- Dated line on the left; "Respectfully submitted,", the /s/ line and the counsel lines (italic) on the right.
-- typst signature-above is spacing of its own, before the block.
local function signature(m)
  local s = need(m, "signature")
  local right = { p(xe.runs("Respectfully submitted,")),
    p(xe.runs("/s/ " .. txt(s.signer)), { before = SIG_GAP }) }
  for _, l in ipairs(items(s.lines)) do right[#right + 1] = p(line(l, { i = true })) end
  return space(SIG_ABOVE) .. grid3(p(xe.runs("Dated: " .. txt(need(m, "date")))), table.concat(right))
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(I)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
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

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "title", "debtor", "case_no", "chapter", "adv_no", "plaintiff", "defendants", "date", "signature" }) do
    local _ = need(m, k)
  end
  -- LAMB-CONT-001: the statement of consent is required (FRBP 7008(a)); the body must state it.
  local body_text = {}
  for _, b in ipairs(doc.blocks) do body_text[#body_text + 1] = pandoc.utils.stringify(b) end
  if not table.concat(body_text, "\n"):find("consent", 1, true) then
    error("lamb-adversary-complaint: the body must state whether the pleader consents to the entry of final orders (FRBP 7008(a))", 0)
  end

  local out = { xe.raw(cover(m)) }
  local n = 0
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- Level 1 in capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
      local c = b.content
      if b.level == 1 then
        c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "Para" or b.t == "Plain" then
      if i == 1 or pandoc.utils.stringify(b):sub(1, 9) == "WHEREFORE" then
        -- The opening paragraph and the prayer's lead-in are not numbered (LAMB-CONT-002).
        out[#out + 1] = styled("Body Text", b.content)
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(n .. "."), pandoc.Space() })
        inl:extend(b.content)
        out[#out + 1] = styled("Body Text", inl)
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      -- The prayer items are lettered (a), (b), ... (typed text, as in the typst template), the letter hanging.
      for k, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs("(" .. string.char(96 + k) .. ")\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Prayer Item", inl)
      end
    else
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }

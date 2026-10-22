-- W.D. Ky. complaint (kywd), DOCX engine (docs/DOCX.md): the markdown contract -> Word on the styles of
-- docx/reference.xml (fb render builds reference.docx from it). Mirrors typst/kywd-complaint.typ:
--   * court title (centred bold single lines), the caption as a borderless table (party column, a column of ")"
--     marks, CASE NO. on the "vs." row), the title centred bold, all from the sample's frontmatter;
--   * body paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b)), the number in a half-inch box (a tab); a
--     paragraph beginning "WHEREFORE" is unnumbered; headings (level 1 in capitals) and prayer items;
--   * the signature block at 3.25 in, kept on one page, and the jury demand with its own signature block.
-- Page numbers come from the reference's footer. Nothing case-specific is written here: every string comes from
-- the sample's YAML frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276           -- typst pitch-body 24 pt, pitch-single 13.8 pt
local COURT_BELOW = 276                 -- typst court-below 13.8 pt
local TITLE_ABOVE, TITLE_BELOW = 276, 480 -- typst title-above 13.8 pt, title-below 24 pt
local SIG_ABOVE, SIG_GAP = 480, 276     -- typst sig-above 24 pt, sig-gap 13.8 pt
local SIG_IND = 4680                    -- typst sig-indent 3.25 in
local CAP_W = { 4464, 432, 4464 }       -- typst caption-left 3.1 in, paren-col 0.3 in, the rest of 6.5 in
local VERSUS_IND, DESIG_IND = 1080, 2160 -- typst versus-indent 0.75 in, designation-indent 1.5 in

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function need(t, key)
  if t[key] == nil then error("kywd-complaint: missing required metadata field `" .. key .. "`", 0) end
  return t[key]
end

-- a metadata list (or a single value) as a Lua list
local function list(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then return v end
  return { v }
end

-- A single-pitch paragraph: o = { before, line, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
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

-- The court title: centred bold single lines.
local function court_title(meta)
  local out = {}
  for _, l in ipairs(list(need(meta, "court"))) do out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center" }) end
  return table.concat(out)
end

-- The caption: one table row per line of the party column, a ")" in the middle column of each, CASE NO. on the
-- "vs." row; typst court-below above it.
local function caption(meta)
  local rows = {}
  for k, side in ipairs(need(need(meta, "caption"), "parties")) do
    if k > 1 then
      rows[#rows + 1] = { t = "", indent = 0 }
      rows[#rows + 1] = { t = "vs.", indent = VERSUS_IND }
      rows[#rows + 1] = { t = "", indent = 0 }
    end
    for _, n in ipairs(list(side.names)) do rows[#rows + 1] = { t = n, indent = 0 } end
    rows[#rows + 1] = { t = side.designation, indent = DESIG_IND }
  end
  local case_row = 1
  for i, r in ipairs(rows) do
    if plain(r.t) == "vs." then case_row = i; break end
  end
  local function cell(w, inner)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. inner .. '</w:tc>'
  end
  local out = { xe.para({ xe.spacing(0, 0, COURT_BELOW) }, ""),
    '<w:tbl><w:tblPr><w:tblW w:w="' .. (CAP_W[1] + CAP_W[2] + CAP_W[3]) .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_W[1] .. '"/><w:gridCol w:w="' .. CAP_W[2] .. '"/><w:gridCol w:w="'
    .. CAP_W[3] .. '"/></w:tblGrid>' }
  local label = "CASE NO. " .. plain(need(meta, "case_number"))
  for i, r in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      .. cell(CAP_W[1], p(xe.inl(r.t), { left = r.indent }))
      .. cell(CAP_W[2], p(xe.runs(")")))
      .. cell(CAP_W[3], p(i == case_row and xe.runs(label) or ""))
      .. '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return table.concat(out)
end

-- The title: a centred bold single line, typst title-above and title-below around it.
local function title(meta)
  return xe.para({ xe.spacing(TITLE_ABOVE, TITLE_BELOW, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
    xe.inl(need(meta, "title"), { b = true }))
end

-- The signature block (typst signature-block): "Respectfully submitted,", the /s/ line and the lines at the
-- signature indent, typst sig-gap above the /s/ line, the first line and each line after an empty one; kept on
-- one page.
local function signature(meta)
  local sig = need(meta, "signature")
  local s = { p(xe.runs("Respectfully submitted,"), { before = SIG_ABOVE, left = SIG_IND }),
    p(xe.runs("By: /s/ ") .. xe.inl(need(sig, "by")), { before = SIG_GAP, left = SIG_IND }) }
  local gap = SIG_GAP
  for _, l in ipairs(list(need(sig, "lines"))) do
    if plain(l) == "" then gap = SIG_GAP else
      s[#s + 1] = p(xe.inl(l), { before = gap, left = SIG_IND })
      gap = 0
    end
  end
  return table.concat(kept(s))
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("2000e-5(f)(3)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- A list as "Prayer Item" paragraphs: the label, a tab to the hanging indent, the text (typst list-item).
local function prayer_items(b)
  local out = {}
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  for _, item in ipairs(b.content) do
    local lead = pandoc.Inlines({ pandoc.Str(b.t == "OrderedList" and (n .. ".") or "\u{2022}"),
      pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
    for _, blk in ipairs(item) do
      if blk.content then lead:extend(blk.content) end
    end
    out[#out + 1] = styled("Prayer Item", lead)
    n = n + 1
  end
  return out
end

local function upper(inlines)
  return inlines:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function finish(doc)
  local meta = doc.meta
  local out = { xe.raw(court_title(meta) .. caption(meta) .. title(meta)) }
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local c = pandoc.Inlines(b.content)
      if pandoc.utils.stringify(c):match("^WHEREFORE") then
        out[#out + 1] = pandoc.Para(c)
      else
        n = n + 1
        local lead = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
        lead:extend(c)
        out[#out + 1] = styled("Numbered Paragraph", lead)
      end
    elseif b.t == "Header" then
      local level = math.min(b.level, 3)
      out[#out + 1] = pandoc.Header(level, level == 1 and upper(b.content) or b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(prayer_items(b)) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(meta)))
  local jd = meta.jury_demand
  if jd ~= nil then
    body:insert(xe.raw(p(xe.inl(need(jd, "heading"), { b = true }),
      { before = SIG_ABOVE, line = BODY, jc = "center", keep = true })))
    body:insert(xe.raw(xe.para({ xe.style("BodyText") }, xe.inl(need(jd, "text")))))
    body:insert(xe.raw(signature(meta)))
  end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }

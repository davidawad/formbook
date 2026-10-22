-- Adversary complaint for the United States Bankruptcy Court, Northern District of Florida (flnb), docx engine: what
-- the Word output adds to pandoc's conversion, so that it reads and breaks as typst/flnb-adversary-complaint.typ does
-- (README "Engines"): the caption (court, debtor case style, adversary case style, LBR 9004-1(A)), the title, the
-- headings and the signature block (District LR 5.1(D)). Everything printed comes from the sample's frontmatter and
-- body: no case text lives in this file. The caption is one borderless OOXML table, one row per line.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, District LR 5.1(C); 322 a single
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 644, 322            -- typst pitch-double 32.2 pt, pitch-single 16.1 pt
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 5688, 144   -- typst caption-left 3.95 in, caption-gutter 0.1 in
local SIG_LEFT = 4176                    -- typst sig-left 2.9 in

-- The frontmatter as written (fb render's $FORMBOOK_META), so a line keeps its spaces as typst sets them;
-- pandoc's metadata when the filter runs alone.
local function raw_meta(meta)
  local f = os.getenv("FORMBOOK_META")
  local h = f and io.open(f, "r")
  if h then
    local s = h:read("a")
    h:close()
    return pandoc.json.decode(s, false)
  end
  local out = {}
  for k, v in pairs(meta) do
    if type(v) == "table" and v[1] ~= nil and pandoc.utils.type(v) == "List" then
      local l = {}
      for i, x in ipairs(v) do l[i] = pandoc.utils.stringify(x) end
      out[k] = l
    else
      out[k] = pandoc.utils.stringify(v)
    end
  end
  return out
end

-- A single-spaced paragraph: o = { before, after, left, jc, keep, b }.
local function p(text, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = o.keep end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, text == "" and "" or xe.runs(text, { b = o.b }))
end

-- The caption: the debtor case style and its numbers, a blank line, the adversary case style and its numbers;
-- one row per line (typst: one grid row per line), the numbers in the right column.
local function caption_table(m)
  local rows = {}
  local function add(left, right)
    for i = 1, math.max(#left, #right) do
      rows[#rows + 1] = { left[i] or "", right[i] or "" }
    end
  end
  add(m.debtor_style or {}, m.debtor_numbers or {})
  rows[#rows + 1] = { "", "" }
  add(m.adversary_style or {}, m.adversary_numbers or {})
  local right_w = TEXTW - CAP_LEFT - CAP_GUTTER
  local function tc(w, xml) return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. xml .. '</w:tc>' end
  local trs = {}
  for _, r in ipairs(rows) do
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(CAP_LEFT, p(r[1])) .. tc(CAP_GUTTER, p("")) ..
      tc(right_w, p(r[2])) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblCellMar>' ..
    '<w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. right_w .. '"/></w:tblGrid>' ..
    table.concat(trs) .. '</w:tbl>'
end

-- Court name (capitals, centered), the caption a double line below it, the title (bold, centered) a double line
-- below the caption; the body a single line below the title.
local function caption(m)
  local out = {}
  for i, l in ipairs(m.court or {}) do
    out[#out + 1] = p(l:upper(), { jc = "center", after = i == #m.court and BODY or 0 })
  end
  out[#out + 1] = caption_table(m)
  for i, l in ipairs(m.title_lines or {}) do
    out[#out + 1] = p(l, { jc = "center", b = true, before = i == 1 and BODY or 0,
      after = i == #m.title_lines and SINGLE or 0, keep = xe.KEEP })
  end
  return out
end

-- The signature block (District LR 5.1(D)): a single line below the text, at the right; kept together and with the
-- paragraph before it (typst: one unbreakable block with the last paragraph).
local function signature(m)
  local out = {}
  local lines = m.signature or {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { left = SIG_LEFT, before = i == 1 and SINGLE or 0, keep = i < #lines and xe.KEEP or xe.LINES })
  end
  return out
end

-- Headings: centered single lines, the section headings (##) bold a single line below the text before them, the
-- claim subtitles (####) regular; kept with the text after them.
local function heading(h)
  local bold = h.level <= 2
  -- a hyphen before a digit (xe.inlines made it a no-break hyphen run): the hyphen and a word joiner after it, as
  -- text runs; LibreOffice drops the bold no-break hyphen from the PDF text
  local content = h.content:walk({ RawInline = function(r)
    if r.text:find("noBreakHyphen", 1, true) then return pandoc.Str("-\u{2060}") end
  end })
  local runs = xe.inl(content, { b = bold })
  runs = runs:gsub("<w:r>(<w:[^r])", "<w:r><w:rPr></w:rPr>%1")
  runs = runs:gsub("<w:rPr>(.-)</w:rPr>", function(x)
    if not bold then x = '<w:b w:val="0"/><w:bCs w:val="0"/>' .. x end
    if not x:find("<w:i/>", 1, true) then
      local at = x:find("<w:caps", 1, true) or x:find("<w:sz", 1, true) or (#x + 1)
      x = x:sub(1, at - 1) .. '<w:i w:val="0"/><w:iCs w:val="0"/>' .. x:sub(at)
    end
    return "<w:rPr>" .. x .. "</w:rPr>"
  end)
  return xe.para({ xe.style("Heading" .. h.level), xe.KEEP, xe.spacing(bold and SINGLE or 0, 0, SINGLE),
    xe.ind(0, nil, 0), xe.jc("center") }, runs)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  local m = raw_meta(doc.meta)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = xe.inlines })
  local out = pandoc.List({})
  for _, x in ipairs(caption(m)) do out:insert(xe.raw(x)) end
  local last = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out:insert(xe.raw(heading(b)))
    elseif b.t == "Para" or b.t == "Plain" then
      -- Body Text (reference.xml: 32.2 pt lines, half-inch first-line indent); the last paragraph is kept with the
      -- signature block
      local style = i == last and "Body Text Keep Next" or "Body Text"
      out:insert(pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style }))
    else
      error("flnb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  for _, x in ipairs(signature(m)) do out:insert(xe.raw(x)) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

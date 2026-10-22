-- flmb adversary complaint, docx engine: what the Word output adds to pandoc's conversion, so that it reads and
-- breaks as typst/flmb-adversary-complaint.typ does (README "Engines"): the court title, the caption (Fed. R. Bankr.
-- P. 9004(b), 7010; Local Rule 9004-1(a)), the title, the numbered paragraphs (Fed. R. Civ. P. 10(b)), the "^"
-- unnumbered paragraphs, the lettered items, the body table and the signature block. Everything printed comes from
-- the sample's frontmatter and body: no case text lives in this file. Body paragraphs stay pandoc paragraphs (in
-- the reference's styles) so that pandoc writes their footnotes; the rest is written as WordprocessingML.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288   -- typst caption-left 3.4 in, caption-gutter 0.2 in
local SIG_RIGHT, SIG_GUTTER = 4464, 288  -- typst sig-right 3.1 in, sig-gutter 0.2 in
local TABLE_COL = 1800                   -- typst table-col 1.25 in
local TABLE_X, TABLE_Y = 200, 60         -- typst table-inset-x 10 pt, table-inset-y 3 pt

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, jc, keep, rule } (rule: a rule below the line).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.rule then
    props[#props + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>'
  end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tc(w, body, pr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' ..
    (body ~= "" and body or p("")) .. '</w:tc>'
end

local function tbl(widths, rows, o)
  o = o or {}
  local grid = {}
  local total = 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. (o.jc and xe.jc(o.jc) or "") ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
    '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

local function tr(cells, cant)
  return '<w:tr>' .. (cant and '<w:trPr><w:cantSplit/></w:trPr>' or '') .. table.concat(cells) .. '</w:tr>'
end

-- ---------------------------------------------------------------------------
-- Court title and caption
-- ---------------------------------------------------------------------------

local function court_title(meta, out)
  for _, l in ipairs({ "UNITED STATES BANKRUPTCY COURT", "MIDDLE DISTRICT OF FLORIDA",
    plain(meta.division):upper() .. " DIVISION" }) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true })
  end
end

-- One side of the caption: lines (each { body, left }) and the closing rule with "/" when asked. `before` goes on
-- the first line (the row gap; typst: the grid's row-gutter, or the caption block's space above it).
local function side_lines(lines, slash)
  if slash then lines[#lines + 1] = { body = xe.runs("/"), rule = true } end
  return lines
end

local function cell_body(lines, before)
  local x = {}
  for i, l in ipairs(lines) do
    x[#x + 1] = p(l.body, { left = l.left, before = i == 1 and before or 0, rule = l.rule,
      jc = l.rule and "right" or "left" })
  end
  return table.concat(x)
end

local function party(names, designation, slash, lead)
  local lines = {}
  if lead then lines[1] = { body = xe.runs(lead) } end
  for _, n in ipairs(names) do lines[#lines + 1] = { body = xe.inl(n) } end
  if designation then lines[#lines + 1] = { body = xe.inl(designation), left = 720 } end
  return side_lines(lines, slash)
end

local function caption(meta)
  local label = meta.adversary_label and plain(meta.adversary_label) or "Adv. Case No."
  local rows = {
    { party(meta.in_re, "Debtor.", true, "In re:"),
      { { body = xe.runs("Case No. " .. plain(meta.case_number)) }, { body = xe.inl(meta.chapter) } } },
    { party(meta.caption[1].names, meta.caption[1].designation, false), {} },
    { { { body = xe.runs("v.") } }, { { body = xe.runs(label .. " " .. plain(meta.adversary_number)) } } },
    { party(meta.caption[2].names, meta.caption[2].designation, true), {} },
  }
  local trs = {}
  for i, r in ipairs(rows) do
    -- the caption stands a double line below the court title; its rows a single line apart
    local before = i == 1 and BODY or SINGLE
    local right = #r[2] > 0 and cell_body(r[2], before) or p("", { before = before })
    trs[#trs + 1] = tr({ tc(CAP_LEFT, cell_body(r[1], before)),
      tc(TEXTW - CAP_LEFT, right, '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>') }, true)
  end
  return tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, trs)
end

-- Title as printed: capitals, then the words the Local Rules require (typst full-title()).
local function full_title(meta)
  local parts = { plain(meta.title):upper() }
  if meta.injunctive_relief then table.insert(parts, "INJUNCTIVE RELIEF SOUGHT") end
  if meta.jury_demand then table.insert(parts, "DEMAND FOR JURY TRIAL") end
  return table.concat(parts, "; ")
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" at the left, counsel at the right; the row never splits
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,"), { before = BODY }) }
  for i, l in ipairs(sig.firm) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and SINGLE or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = SINGLE })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(sig.lines) do right[#right + 1] = p(xe.inl(l)) end
  local left = meta.date and p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = BODY }) or p("", { before = BODY })
  local lw = TEXTW - SIG_RIGHT - SIG_GUTTER
  return tbl({ lw, TEXTW - lw }, { tr({ tc(lw, left),
    tc(TEXTW - lw, table.concat(right), '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>') }, true) })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body size and pitch, centered and bold (level 1 in capitals, level 3 italic too); kept with
-- the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(content, { b = true, i = el.level == 3 }))
end

-- A markdown table: unruled, centered, single-spaced, fixed columns, a single line above and below (typst
-- body-table(): the space on the first row's and the last row's lines).
local function body_table(t)
  local aligns = {}
  for i, spec in ipairs(t.colspecs) do
    local a = tostring(spec[1])
    aligns[i] = a == "AlignCenter" and "center" or a == "AlignRight" and "right" or "left"
  end
  local rows = {}
  for _, r in ipairs(t.head.rows) do rows[#rows + 1] = r end
  for _, b in ipairs(t.bodies) do for _, r in ipairs(b.body) do rows[#rows + 1] = r end end
  local trs = {}
  for k, r in ipairs(rows) do
    local cells = {}
    for i, c in ipairs(r.cells) do
      local inl = pandoc.Inlines({})
      for _, cb in ipairs(c.contents) do inl:extend(cb.content) end
      local body = p(xe.inl(inl), { jc = aligns[i], before = k == 1 and SINGLE or 0, after = k == #rows and SINGLE or 0 })
      cells[#cells + 1] = tc(TABLE_COL, body, '<w:tcMar><w:top w:w="' .. TABLE_Y .. '" w:type="dxa"/><w:left w:w="' ..
        TABLE_X .. '" w:type="dxa"/><w:bottom w:w="' .. TABLE_Y .. '" w:type="dxa"/><w:right w:w="' .. TABLE_X ..
        '" w:type="dxa"/></w:tcMar>')
    end
    trs[#trs + 1] = tr(cells, true)
  end
  local widths = {}
  for i = 1, #aligns do widths[i] = TABLE_COL end
  return tbl(widths, trs, { jc = "center" })
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function body_blocks(blocks)
  local out = {}
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      local first = c[1]
      if first and first.t == "Str" and first.text:sub(1, 1) == "^" then
        -- "^": an unnumbered paragraph (the reservation of rights, the prayer for relief)
        first.text = first.text:sub(2)
        if first.text == "" then c:remove(1) end
        out[#out + 1] = styled("Body Text", c)
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(tostring(n)), TAB })
        inl:extend(c)
        out[#out + 1] = styled("Numbered Paragraph", inl)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- lettered items: the letter half an inch in, a tab to the text, which hangs at one inch
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local inl = pandoc.Inlines({})
          if k == 1 then
            inl:insert(pandoc.Str(b.t == "OrderedList" and (string.char(96 + j) .. ".") or "\u{2022}"))
            inl:insert(TAB)
          end
          inl:extend(ib.content)
          out[#out + 1] = styled("Lettered Item", inl)
        end
      end
    elseif b.t == "Table" then
      out[#out + 1] = xe.raw(body_table(b))
    else
      error("flmb-pleading.lua: unsupported block " .. b.t)
    end
  end
  return out
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space); a doubled section sign stays with its number (a no-break space, as
-- xe binds a single one). None of these shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = xe.inlines })
  local out = {}
  court_title(meta, out)
  out[#out + 1] = caption(meta)
  -- the title stands a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = xe.para({ xe.KEEP, xe.spacing(BODY, SINGLE, BODY), xe.ind(0, nil, 0), xe.jc("center") },
    xe.runs(full_title(meta), { b = true }))
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  for _, b in ipairs(body_blocks(doc.blocks)) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

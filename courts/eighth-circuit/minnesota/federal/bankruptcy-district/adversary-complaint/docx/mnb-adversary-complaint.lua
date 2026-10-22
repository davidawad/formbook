-- mnb-adversary-complaint.lua (docx engine, see ../README.md "Engines"): the markdown contract -> Word, laid out and
-- broken as typst/mnb-adversary-complaint.typ lays it out: the court title, the caption boxes (Fed. R. Bankr. P. 7010,
-- Official Form 416A), the numbered paragraphs (Fed. R. Civ. P. 10(b), through 7010; a WHEREFORE paragraph is not
-- numbered), the lettered prayer items, a list that carries its own letters, the headings and the signature block.
-- Nothing case-specific is in this file: every word comes from the sample. The caption and signature lines are read
-- as written ($FORMBOOK_META, fb render), where a leading ">" marks an indented designation ("> Debtors.").
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local LIST_LEFT = 1296                   -- typst list-left 0.9 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 5040, 288   -- typst caption-left 3.5 in, caption-gutter 0.2 in
local CAP_INSET, CAP_PAD = 144, 160      -- typst caption-inset 0.1 in, caption-pad 8 pt
local DESIG = 2592                       -- typst designation-indent 1.8 in
local SIG_LEFT, SIG_GUTTER = 3744, 288   -- typst sig-left 2.6 in, sig-gutter 0.2 in

local function read_file(path)
  local f = path and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (pandoc's metadata would read "> Debtors." as a block quotation).
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

-- A frontmatter string as inlines: its markdown read as pandoc reads the body.
local function md(s)
  local blocks = pandoc.read(s, "markdown+smart", PANDOC_READER_OPTIONS).blocks
  return blocks[1] and blocks[1].content or pandoc.Inlines({})
end

-- A paragraph: o = { before, after, line, left, hanging, first, tab, jc, keep } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table of rows of cells, rows = { { { w, pr, body } } }: the cells of the first row set the grid; mar is the
-- cell margin above and below the text in every cell.
local function tbl(rows, trpr, mar)
  local grid, trs = {}, {}
  for _, c in ipairs(rows[1]) do grid[#grid + 1] = '<w:gridCol w:w="' .. c.w .. '"/>' end
  for _, cells in ipairs(rows) do
    local tcs = {}
    for _, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.w .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  mar = mar or 0
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="' .. mar .. '" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="' .. mar ..
    '" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- Caption and signature lines (typst line-stack): "" a blank line, "> x" indented.
local function lines(list, out)
  out = out or {}
  for _, s in ipairs(list or {}) do
    if s == "" then
      out[#out + 1] = p(xe.runs("\u{00A0}"))
    elseif s:sub(1, 1) == ">" then
      out[#out + 1] = p(xe.inl(md((s:sub(2):gsub("^%s+", "")))), { left = DESIG })
    else
      out[#out + 1] = p(xe.inl(md(s)))
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Court title and caption (Fed. R. Bankr. P. 7010; typst caption())
-- ---------------------------------------------------------------------------

-- One box of the caption (a table row): two columns between rules, the text CAP_PAD off them.
local function caption_box(top, left, right)
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  local borders = '<w:tcBorders>' .. (top and ('<w:top ' .. rule .. '/>') or "") .. '<w:bottom ' .. rule .. '/></w:tcBorders>'
  return {
    { w = CAP_LEFT, pr = borders .. '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { w = TEXTW - CAP_LEFT, pr = borders .. '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + CAP_INSET) .. '" w:type="dxa"/></w:tcMar>',
      body = right },
  }
end

local function cover(meta)
  local c = RAW.caption
  local out = {
    p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }),
    p(xe.runs("DISTRICT OF MINNESOTA", { b = true }), { jc = "center", after = BODY }),
  }
  local debtor = caption_box(true, lines(c.debtor), lines(c.debtor_case))
  local right = lines(c.adversary)
  right[#right + 1] = p(xe.inl(meta.title, { b = true }), { before = SINGLE })
  if RAW.jury_demand == true then
    right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = SINGLE })
  end
  out[#out + 1] = tbl({ debtor, caption_box(false, lines(c.parties), right) }, nil, CAP_PAD)
  return out
end

-- The signature block: "Dated" at the left, the signer's lines at the right; the row never splits.
local function signature(meta)
  local s = RAW.signature
  local right = { p(xe.runs("/s/ ") .. xe.inl(md(s.signer)), { before = BODY }) }
  lines(s.lines, right)
  return tbl({ {
    { w = SIG_LEFT, body = { p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = BODY }) } },
    { w = TEXTW - SIG_LEFT, pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right },
  } }, '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, o)
  o.line, o.first = BODY, INDENT
  if label == nil then return p(xe.inl(inlines), o) end
  o.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), o)
end

-- Headings at the body pitch, bold: levels 1 and 2 centered (1 in capitals), level 3 italic; kept with the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = el.level >= 3 }))
end

local function is_wherefore(b)
  local first = b.content[1]
  return first ~= nil and first.t == "Str" and first.text:match("^WHEREFORE") ~= nil
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  if not RAW.caption then error("mnb-adversary-complaint: the sample frontmatter needs a caption", 0) end
  local out = cover(meta)
  -- the caption stands a double line above the text (typst: the caption block's below); Word has no space after a
  -- table, so the first paragraph after it takes the space before it
  local gap = BODY
  local function take()
    local g = gap
    gap = 0
    return g
  end
  -- body paragraphs as { body, o } so the last one can be kept with the signature block
  local paras = {}
  local function add(f, ...) paras[#paras + 1] = { f = f, args = { ... } } end
  if meta.lead_in then add(body_par, nil, meta.lead_in, { before = take() }) end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      paras[#paras + 1] = { xml = heading(b), before = take() }
    elseif b.t == "Para" or b.t == "Plain" then
      local label = nil
      if not is_wherefore(b) then
        n = n + 1
        label = n .. "."
      end
      add(body_par, label, b.content, { before = take() })
    elseif b.t == "BulletList" then
      -- a list that carries its own letters ("- A. ..."): each item list-left in
      for _, item in ipairs(b.content) do
        add(function(inl, o) o.line, o.left = BODY, LIST_LEFT; return p(xe.inl(inl), o) end, item[1].content,
          { before = take() })
      end
    elseif b.t == "OrderedList" then
      -- the prayer: lettered A., B., ... (typst lettered-item: the letter half an inch in, the text hanging)
      for i, item in ipairs(b.content) do
        local letter = string.char(64 + b.listAttributes.start + i - 1) .. ".\t"
        add(function(inl, o)
          o.line, o.left, o.hanging = BODY, 2 * INDENT, INDENT
          return p(xe.runs(letter) .. xe.inl(inl), o)
        end, item[1].content, { before = take() })
      end
    else
      error("mnb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  for i, x in ipairs(paras) do
    if x.xml then
      out[#out + 1] = x.xml
    else
      -- the last paragraph is kept whole with the signature block (typst: one unbreakable block)
      if i == #paras then x.args[#x.args].keep = true end
      out[#out + 1] = x.f(table.unpack(x.args))
    end
  end
  out[#out + 1] = signature(meta)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

-- iasd complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it reads and
-- breaks as typst/iasd-complaint.typ does: the court title and caption (LR 10(d); a table: party column with a
-- right and bottom rule, case number and title), the numbered paragraphs (Fed. R. Civ. P. 10(b); not after
-- "Requested Relief" and "Jury Demand"), the lettered lists (a), (b), ..., headings, block quotations, and the
-- signature block (LR 11) with the optional filing note. Content-agnostic: every case word comes from the sample's
-- frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, HSPACE = 480, 276, 240 -- typst pitch, pitch-single, heading-space
local INDENT, QUOTE = 720, 720             -- typst para-indent, quote-indent
local TEXTW = 9360                         -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 288     -- typst caption-left 3.25 in, caption-gutter 0.2 in
local CAP_INSET = 200                      -- typst caption-inset 10 pt
local RIGHT_INSET = 144                    -- typst right-inset 0.1 in
local LETTERS = "abcdefghijklmnopqrst"
local UNNUMBERED_AFTER = { ["REQUESTED RELIEF"] = true, ["JURY DEMAND"] = true }

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function need(meta, k)
  if meta[k] == nil then error("iasd-complaint.lua: frontmatter field `" .. k .. "` is required") end
  return meta[k]
end

-- A paragraph: o = { before, after, line, left, right, first, tab, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A single line of frontmatter text; an empty one is a blank line.
local function line(v, o)
  local s = plain(v)
  return p(s == "" and xe.runs("\u{00A0}") or xe.inl(v), o)
end

local function tbl(widths, cells)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Court title and caption (LR 10(d))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local titles = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF IOWA",
    pandoc.text.upper(plain(need(meta, "division"))) }
  for i, l in ipairs(titles) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #titles and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation; the versus line between the parties. The bottom rule
  -- stands the inset below the last line (space after it).
  local cap = need(meta, "caption")
  local left = {}
  for k, party in ipairs(cap.parties) do
    if k > 1 then left[#left + 1] = line(cap.versus or "v.") end
    for _, n in ipairs(party.names) do left[#left + 1] = line(n) end
    left[#left + 1] = line(party.designation, { after = k == #cap.parties and CAP_INSET or 0 })
  end
  local right = {
    p(xe.runs("Case No. ") .. xe.inl(need(meta, "case_number"))),
    p(xe.runs(pandoc.text.upper(plain(need(meta, "title"))), { b = true }), { before = SINGLE }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: the first-line indent, then (when labelled) the label and a tab to the next
-- half inch (typst: the label in a box of para-indent), the text.
local function body_par(label, inlines, before)
  local body = (label and xe.runs(label .. "\t") or "") .. xe.inl(inlines)
  return p(body, { line = BODY, first = INDENT, tab = label and 2 * INDENT or nil, before = before })
end

-- Headings: centered bold capitals (level 1), centered bold (level 2), bold at the margin (level 3), at the body
-- pitch with half a line above and below; kept with the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(HSPACE, HSPACE, BODY),
    xe.ind(0, nil, 0), xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = cover(meta)
  -- the caption stands a double line above the text (typst: the caption block's below); Word has no space after a
  -- table, so the first paragraph after it takes the space before it
  local gap = BODY
  local function take()
    local g = gap
    gap = 0
    return g
  end
  if meta.lead_in ~= nil then out[#out + 1] = body_par(nil, meta.lead_in, take()) end

  local numbered, n = true, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 and UNNUMBERED_AFTER[pandoc.text.upper(plain(b.content))] then numbered = false end
      out[#out + 1] = heading(b)
      gap = 0
    elseif b.t == "Para" or b.t == "Plain" then
      local label = nil
      if numbered then
        n = n + 1
        label = n .. "."
      end
      out[#out + 1] = body_par(label, b.content, take())
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = body_par("(" .. LETTERS:sub(i, i) .. ")", item[1].content, take())
      end
    elseif b.t == "BlockQuote" then
      -- single spaced, indented on both sides, half a line after it
      out[#out + 1] = p(xe.inl(pandoc.utils.blocks_to_inlines(b.content)),
        { left = QUOTE, right = QUOTE, after = HSPACE, before = take() })
    else
      error("iasd-complaint.lua: unsupported block " .. b.t)
    end
  end

  -- Signature block (LR 11): the signature lines in the signature column (after the caption's party column), then
  -- the filing note at the margin; kept on one page.
  local sig = need(meta, "signature")
  local sigp = {}
  local first = BODY
  if sig.date ~= nil then
    sigp[#sigp + 1] = { v = sig.date, o = { before = first } }
    first = HSPACE
  end
  for _, l in ipairs(sig.lines) do
    sigp[#sigp + 1] = { v = l, o = { before = first, left = CAP_LEFT + CAP_GUTTER } }
    first = 0
  end
  if meta.filing_note ~= nil then sigp[#sigp + 1] = { v = meta.filing_note, o = { before = BODY } } end
  for i, s in ipairs(sigp) do
    s.o.keep = i < #sigp
    out[#out + 1] = line(s.v, s.o)
  end

  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

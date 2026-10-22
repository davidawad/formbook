-- Adversary complaint for the United States Bankruptcy Court, District of Guam (gub), docx engine: the whole Word
-- document, so that it reads and breaks as typst/gub-adversary-complaint.typ does (see ../README.md): the pleading
-- page (line numbers 1 to 27 down the left margin on the 24 pt grid, a double rule left of the text and a single rule
-- right of it, the page number and the paper's title below the numbered lines; GNLR 5.1(a)), the cover (counsel
-- block upper left on the first eight numbered lines, the court title below it, GNLR 5.1(b); the caption with the
-- right-hand case information, GNLR 5.1(c), Fed. R. Bankr. P. 7010), the body from a new page (the lead-in;
-- numbered paragraphs, Fed. R. Civ. P. 10(b), the number in a half-inch box after the indent; a paragraph that
-- starts with "§ " unnumbered and kept with the block after it; headings centered and bold on one numbered line;
-- list items lettered (a), (b), ...) and the signature block (GNLR 5.1(d), Fed. R. Bankr. P. 9011(a)). Everything
-- printed comes from the sample's frontmatter and body: no case text lives in this file. Counsel block and caption
-- are OOXML tables; the page furniture is a footer of page-anchored frames.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 a numbered line, 276 a single line), the spaces between
-- blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 240            -- typst pitch, pitch-single (half a numbered line)
local DROP = 192                         -- typst grid-drop: a single-spaced group starts 9.6 pt into a numbered line
local INDENT = 720                       -- typst para-indent, num-box, item-indent and item-box, 0.5 in
local TEXTW = 8640                       -- typst text-width, 6 in
local LINES = 27                         -- typst lines-per-page
local TOP, LEFT = 1440, 2160             -- typst top-margin 1 in, left-margin 1.5 in
local COUNSEL_H = 8 * BODY               -- typst counsel-lines
local CAP_LEFT, CAP_GUTTER = 4608, 288   -- typst caption-left 3.2 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local CAP_PAD = 145                      -- typst caption-pad (8 pt, 160) less the 0.75 pt rule, which LibreOffice adds
                                         -- to the cell height
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local SIG_LEFT = 4032                    -- typst sig-left 2.8 in
local FOOT_SZ, FOOT_LINE, FOOT_GAP = 20, 230, 80   -- typst foot-size 10 pt, foot-pitch 11.5 pt, foot-gap 4 pt
local FOOT_TOP = TOP + LINES * BODY + 120          -- typst foot-top: 6 pt below the last numbered line

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { keep, brk, tab, before, after, line, left, hanging, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }; trpr the row's properties.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/>' .. (trpr or "") .. '</w:trPr>' ..
    table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- The pleading page: one section, its footer the page furniture in frames anchored to the page
-- ---------------------------------------------------------------------------

local PAGE_FIELD = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' ..
  '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'

local function frame(x, y, w, h)
  return '<w:framePr w:w="' .. w .. '"' .. (h and (' w:h="' .. h .. '" w:hRule="exact"') or "") ..
    ' w:wrap="none" w:vAnchor="page" w:hAnchor="page" w:x="' .. x .. '" w:y="' .. y .. '"/>'
end

local function furniture(title)
  local out = {}
  -- the line numbers, right-aligned to the 1 in line, one per numbered line
  local nums = frame(0, TOP, 1440, LINES * BODY)
  for i = 1, LINES do
    out[#out + 1] = xe.para({ nums, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("right") }, xe.runs(tostring(i)))
  end
  -- the rules: a double rule 0.2 in left of the text, a single rule 0.1 in right of it, the height of the page
  local rule = 'w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = xe.para({ frame(LEFT - 288, 0, TEXTW + 288 + 144, 15840),
    '<w:pBdr><w:left w:val="double" ' .. rule .. '/><w:right w:val="single" ' .. rule .. '/></w:pBdr>',
    xe.spacing(0, 0, 15840), xe.ind(0, nil, 0) }, "")
  -- the page number, centered, and the paper's title below it, at 10 pt
  local foot = frame(LEFT, FOOT_TOP, TEXTW)
  out[#out + 1] = xe.para({ foot, xe.spacing(0, 0, FOOT_LINE), xe.ind(0, nil, 0), xe.jc("center") },
    PAGE_FIELD:gsub("<w:r>", '<w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/><w:szCs w:val="' .. FOOT_SZ .. '"/></w:rPr>'))
  out[#out + 1] = xe.para({ foot, xe.spacing(FOOT_GAP, 0, FOOT_LINE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs(pandoc.text.upper(title), { sz = FOOT_SZ }))
  -- the footer's own line, empty and 1 pt high
  out[#out + 1] = xe.para({ xe.spacing(0, 0, 20) }, "")
  return table.concat(out)
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdGubFurniture"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="' .. TOP .. '" w:right="1440" w:bottom="1440" w:left="' ..
  LEFT .. '" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  -- Counsel identification, upper left (GNLR 5.1(c)(1)), in a row eight numbered lines high, so the court title
  -- starts on the ninth (GNLR 5.1(b): at least 3 inches from the top).
  local counsel = {}
  for k, l in ipairs(meta.counsel or {}) do counsel[#counsel + 1] = p(xe.inl(l), { before = k == 1 and DROP or 0 }) end
  out[#out + 1] = tbl({ TEXTW }, { { body = counsel } }, '<w:trHeight w:val="' .. COUNSEL_H .. '" w:hRule="exact"/>')
  local title = { "IN THE DISTRICT COURT OF GUAM", "TERRITORY OF GUAM", "BANKRUPTCY DIVISION" }
  for k, l in ipairs(title) do
    -- the caption stands a numbered line below (Word has no space before a table: the last title line takes it)
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center", after = k == #title and BODY or 0 })
  end
  -- Left cell: "In re:", the debtor and its designation, a blank line; each party's names and designation, "v."
  -- between the parties.
  local left = {}
  local c = meta.caption
  if c.debtor then
    left[#left + 1] = xe.runs("In re:")
    for _, n in ipairs(c.debtor.names) do left[#left + 1] = xe.inl(n) end
    left[#left + 1] = xe.inl(c.debtor.designation)
    left[#left + 1] = ""
  end
  for k, party in ipairs(c.parties) do
    if k > 1 then left[#left + 1] = xe.runs("v.") end
    for _, n in ipairs(party.names) do left[#left + 1] = xe.inl(n) end
    left[#left + 1] = xe.inl(party.designation)
  end
  for k, l in ipairs(left) do left[k] = p(l, { after = k == #left and CAP_PAD or 0 }) end
  -- Right cell: the case information (GNLR 5.1(c)(3)), a single line between the groups.
  local right = {}
  if meta.chapter then right[#right + 1] = p(xe.inl(meta.chapter)) end
  right[#right + 1] = p(xe.runs("Case No. ") .. xe.inl(meta.case_number))
  right[#right + 1] = p(xe.runs("Adversary Proceeding"), { before = SINGLE })
  right[#right + 1] = p(xe.runs("Adv. Proc. No. ") .. xe.inl(meta.adversary_number))
  right[#right + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE })
  if meta.jury_demand then
    right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = SINGLE })
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("") } },
    { pr = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:left w:w="' .. RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space), none between a doubled section sign and its number (typst boxes the
-- signs with the number).
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end
local function signs(inls)
  for i = 1, #inls - 1 do
    local a, b = inls[i], inls[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then inls[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return inls
end

-- A paragraph that starts with "§ " is unnumbered: the marker is dropped.
local function unnumbered(b)
  local c = b.content
  if c[1] and c[1].t == "Str" and c[1].text == "§" and c[2] and (c[2].t == "Space" or
    (c[2].t == "Str" and c[2].text == "\u{00A0}")) then
    local rest = pandoc.Inlines({})
    for i = 3, #c do rest:insert(c[i]) end
    return rest
  end
end

function Pandoc(doc)
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  write_file("FORMBOOK_FINAL", FINAL)
  write_file("FORMBOOK_FOOTERS", "rIdGubFurniture\t" .. furniture(plain(meta.footer_title)) .. "\n")

  local out = {}
  cover(meta, out)
  -- the body from a new page: the lead-in, then the blocks
  local brk = true
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, brk = true })
    brk = false
  end
  local blocks = doc.blocks
  local n = 0
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      -- centered and bold on one numbered line (level 1 in capitals), kept with the block after it
      local content = b.content
      if b.level == 1 then
        content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
      end
      out[#out + 1] = xe.para({ xe.style("Heading" .. math.min(b.level, 3)), xe.KEEP, brk and xe.BREAK or "",
        xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") }, xe.inl(content, { b = true }))
    elseif b.t == "Para" or b.t == "Plain" then
      local rest = unnumbered(b)
      if rest then
        out[#out + 1] = p(xe.inl(rest), { line = BODY, first = INDENT, keep = true, brk = brk })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          { line = BODY, first = INDENT, tab = 2 * INDENT, keep = last, brk = brk })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("gub-adversary-complaint.lua: a list item holds one paragraph")
        end
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + k) .. ")\t") .. xe.inl(item[1].content),
          { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT, keep = last and k == #b.content,
            brk = brk and k == 1 })
      end
    else
      error("gub-adversary-complaint.lua: unsupported block " .. b.t)
    end
    brk = false
  end

  -- the signature in the right column, a single line below the text (on the grid of the line numbers), kept whole
  local sig = meta.signature
  local lines = {}
  for _, l in ipairs(sig.firm or {}) do lines[#lines + 1] = { xe.inl(l), 0 } end
  lines[#lines + 1] = { xe.runs("/s/ ") .. xe.inl(sig.signer), SINGLE }
  lines[#lines + 1] = { xe.inl(sig.signer), 0 }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { xe.inl(l), 0 } end
  lines[1][2] = SINGLE + DROP
  for k, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { left = SIG_LEFT, before = l[2], keep = k < #lines })
  end

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

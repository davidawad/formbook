-- nywd memorandum of law (W.D.N.Y.), docx engine (docs/DOCX.md): the same markdown contract as
-- typst/nywd-motion-brief.typ, and every block written as it sets it: the cover (court title, the caption with the
-- parties box and the case number at its right, the title, the counsel block at the right), the table of contents
-- (a row per heading, a dot leader to the page in a 36 pt column), the body (level 2 headings numbered I., II. and
-- level 3 headings A., B.; paragraphs unnumbered; block quotations single-spaced and indented both sides; lettered
-- items) and the signature block. Everything printed comes from the sample's frontmatter and body: no case text
-- lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body and contents, 276 a single line),
-- the spaces between blocks those of the typst template, and the break rules of typst on every run.
--
-- Sections and page numbers (were docx/render.sh's two passes): the cover is a section without a page number (fb
-- render's rIdFtrNone), the table of contents a section numbered in lower roman from i, the body a section numbered
-- from 1 ($FORMBOOK_FINAL), both with fb render's page-number footer (rIdFtrPage). The contents' page numbers: fb
-- render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes ($FORMBOOK_NEEDLES:
-- the contents' title, then each heading by its label and title and the words after it) in the PDF and passes their
-- pages back ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, heading-tab, item-indent, item-label,
                                                       -- quote-indent
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 432                 -- typst caption-left (3.4 in), caption-gutter (0.3 in)
local CAP_PAD = 144                                    -- typst caption-pad, 0.1 in
local CAP_FOOT = 145                                   -- typst caption-foot (160) less the 0.75 pt rule LibreOffice
                                                       -- sets below the cell
local CAP_GAP = 138                                    -- typst caption-gap, half a single line
local AGAINST, DESIGNATION = 1728, 3168                -- typst against-indent (1.2 in), designation-indent (2.2 in)
local COUNSEL = 5040                                   -- typst counsel-indent, 3.5 in
local SIG_W = 4608                                     -- typst signature-w, 3.2 in
local PNUM = 720                                       -- typst page-col, 36 pt
local RULE = 'w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt
local COURT = { "UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF NEW YORK" }
local NEEDLE_MAX = 60

local stringify = pandoc.utils.stringify

-- A paragraph: o = { before, after, line, left, right, hanging, first, tabs, jc, keep, lines, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table without cell margins that is never split: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- Several metadata values as runs, a space between them (typst: join(" ")).
local function joined(vs)
  local out = {}
  for _, v in ipairs(list(vs)) do out[#out + 1] = xe.inl(v) end
  return table.concat(out, xe.runs(" "))
end

local function upper(x)
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render's multi-pass build)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function needle(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, _, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Sections: letter page, 1 in margins (Local Rule 10(a)(4)); the page number 0.5 in above the bottom edge
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title, counsel block
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for i, l in ipairs(COURT) do
    -- the caption a single line below the court title (the last title line takes it as space after)
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true, after = i == #COURT and SINGLE or 0 })
  end
  local left = {}
  for k, party in ipairs(list(m.caption.parties)) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { left = AGAINST, before = CAP_GAP }) end
    left[#left + 1] = p(joined(party.names), { before = k > 1 and CAP_GAP or 0 })
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIGNATION, before = CAP_GAP })
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" ' .. RULE .. '/><w:right w:val="single" ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("") } },
    { body = { p(xe.runs("Case No. ") .. xe.inl(m.case_number)) } },
  })
  out[#out + 1] = p(xe.inl(upper(m.title), { b = true }), { jc = "center", before = BODY })
  -- the counsel groups at the right: the first name in bold, the other names and the lines; a single line apart
  for k, g in ipairs(list(m.counsel)) do
    for i, n in ipairs(list(g.names)) do
      local before = 0
      if i == 1 then before = k == 1 and BODY or SINGLE end
      out[#out + 1] = p(xe.inl(n, { b = i == 1 }), { left = COUNSEL, before = before, keep = true })
    end
    for _, l in ipairs(list(g.lines)) do out[#out + 1] = p(xe.inl(l), { left = COUNSEL, keep = true }) end
  end
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  out[#out + 1] = section("rIdFtrNone", nil)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings: level 1 centered bold capitals; level 2 "I.", level 3 "A." (half an inch in), the label in a box half
-- an inch wide (a tab), the title hanging after it; single-spaced, a single line above and below, kept with the
-- next block. The first block of the body opens a page: no space above it (typst drops it there).
-- ---------------------------------------------------------------------------

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
local LETTER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function label_indent(level)
  return level >= 3 and INDENT or 0
end

local function heading(level, lab, content, before)
  if level == 1 then
    return p(xe.inl(upper(content), { b = true }), { style = "Heading1", keep = true, jc = "center", before = before,
      after = SINGLE })
  end
  local ind = label_indent(level)
  return p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(content, { b = true }),
    { style = "Heading" .. level, keep = true, left = ind + INDENT, hanging = INDENT, before = before,
      after = SINGLE })
end

-- ---------------------------------------------------------------------------
-- Table of contents: a row per heading at the body pitch; the text wraps before the page column, a dot leader runs
-- to the page (typst listing-row).
-- ---------------------------------------------------------------------------

local function row(text_xml, page, left, hanging)
  return p(text_xml .. xe.runs(xe.LEAD) .. xe.runs(page), { lines = true, tabs = xe.leader_tab(TEXTW),
    line = BODY, left = left, hanging = hanging, right = PNUM })
end

local function toc(entries)
  local out = { p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", after = BODY }) }
  for _, e in ipairs(entries) do
    local page = labels[e.id] or "0"
    if e.level == 1 then
      out[#out + 1] = row(xe.inl(e.title), page, 0, nil)
    else
      local ind = label_indent(e.level)
      out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), page, ind + INDENT, INDENT)
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature: a double line below the body (the space above its first lines), "Dated:" at the left; the firm in
-- bold, a double line below it "By:" and the signer's lines at the right; never split.
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local right = {}
  for i, f in ipairs(list(sig.firm)) do
    right[#right + 1] = p(xe.inl(f, { b = true }), { before = i == 1 and BODY or 0 })
  end
  right[#right + 1] = p(xe.runs("By: ") .. xe.inl(sig.by), { before = BODY })
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("Dated: ") .. xe.inl(m.date), { before = BODY }) }
  return tbl({ TEXTW - SIG_W, SIG_W }, { { body = left }, { body = right } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number, as the typst template boxes it. Another of typst's rules (Unicode
-- line breaking): no break at a space before a period, comma, colon or semicolon (". . ."); that space becomes a
-- no-break space.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    elseif l[i].t == "Str" and l[i + 1].t == "Space" and l[i + 2] and l[i + 2].t == "Str"
      and l[i + 2].text:find("^[.,:;]") then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A "::" prefix (the old unnumbered marker) is dropped.
local function drop_marker(inlines)
  local out = pandoc.Inlines({})
  for _, il in ipairs(inlines) do out:insert(il) end
  if out[1] and out[1].t == "Str" and out[1].text:sub(1, 2) == "::" then out[1] = pandoc.Str(out[1].text:sub(3)) end
  while out[1] and (out[1].t == "Space" or (out[1].t == "Str" and out[1].text == "")) do out:remove(1) end
  return out
end

function Pandoc(doc)
  load_pages()
  local m = doc.meta
  local blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })

  needle("S:toc", "TABLE OF CONTENTS", "")
  local entries, body = {}, {}
  local h2, h3 = 0, 0
  local start = nil
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local before = start and SINGLE or 0
    local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      local lab = ""
      if level == 1 then
        h2, h3 = 0, 0
      elseif level == 2 then
        h2, h3 = h2 + 1, 0
        lab = ROMAN[h2] .. "."
      else
        h3 = h3 + 1
        lab = LETTER:sub(h3, h3) .. "."
      end
      local id = "H:" .. (#entries + 1)
      needle(id, (lab ~= "" and (lab .. " ") or "") .. stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = level, label = lab, title = b.content }
      body[#body + 1] = heading(level, lab, b.content, before)
      start = start or id
    else
      if not start then
        start = "S:body"
        needle(start, stringify(b), nxt)
      end
      if b.t == "Para" or b.t == "Plain" then
        body[#body + 1] = p(xe.inl(drop_marker(b.content)), { line = BODY, first = INDENT, keep = last })
      elseif b.t == "BlockQuote" then
        local qs = b.content
        for k, q in ipairs(qs) do
          body[#body + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT,
            before = k == 1 and before > 0 and SINGLE or 0, after = k == #qs and SINGLE or 0, keep = last })
        end
      elseif b.t == "OrderedList" then
        for k, item in ipairs(b.content) do
          if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
            error("nywd-motion-brief.lua: a list item holds one paragraph")
          end
          body[#body + 1] = p(xe.runs("(" .. string.char(96 + k) .. ")\t") .. xe.inl(item[1].content),
            { line = BODY, left = 2 * INDENT, hanging = INDENT, tabs = '<w:tabs><w:tab w:val="left" w:pos="' ..
              2 * INDENT .. '"/></w:tabs>', keep = last and k == #b.content })
        end
      else
        error("nywd-motion-brief.lua: unsupported block " .. b.t)
      end
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, "B", n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (start or "S:toc") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  local out = { xe.raw(cover(m) .. toc(entries) .. section("rIdFtrPage", "lowerRoman")) }
  for _, x in ipairs(body) do out[#out + 1] = xe.raw(x) end
  out[#out + 1] = xe.raw(signature(m))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

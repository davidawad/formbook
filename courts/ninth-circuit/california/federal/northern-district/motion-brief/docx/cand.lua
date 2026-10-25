-- N.D. Cal. motion (notice of motion and memorandum of points and authorities), docx engine (docs/DOCX.md): what the
-- Word output adds to pandoc's conversion, so that it reads and breaks as typst/cand-motion-brief.typ does: the cover
-- (counsel block with the role line, court title, caption with the case number, title and noticed hearing; Civil
-- L.R. 3-4(a), 7-2(b)(1)), the tables of contents and authorities (Civil L.R. 7-4(a)(2)), the numbered headings (I.,
-- A., 1. written as text, as typst prints them), the body, the signature block, and the footer with the page number,
-- the paper's title and the case number (CAND-FORM-003). Everything printed comes from the sample's frontmatter and
-- body: no case text lives in this file. Caption and signature are OOXML tables; body paragraphs are pandoc
-- paragraphs (style "Body Text"), so pandoc writes their footnotes.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES: the first block of the motion, every heading and every `toa:` link, with the words after it, in
-- document order) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle.
-- The cover is a section with no footer (rIdFtrNone); the tables number their pages in roman from i and the motion
-- from 1 (FORMBOOK_FINAL), both under the filter's own footer (FORMBOOK_FOOTERS).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 240            -- typst pitch-double, pitch-single
local FOOT_LINE, FOOT_SZ = 230, 20       -- typst pitch-footer 11.5 pt, footer-size 10 pt
local FOOT_DIST = 160                    -- typst footer-foot 8 pt
local LINES = 28                         -- typst lines-per-page: the pleading paper's numbered lines
local TOP, LEFT, RIGHT = 1200, 2160, 1440 -- typst margins: top and bottom 60 pt, left 1.5 in, right 1 in
local NUMBER_COL = 1440                  -- typst number-col: the line numbers end 1 in from the page edge
local HALF = 240                         -- typst half-gap 12 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local TAB = 720                          -- typst heading-tab, 0.5 in
local TEXTW = 8640                       -- 6 in: letter, 1.5 in left and 1 in right margins
local CAP_PAD, CAP_BELOW, CAP_TOP = 288, 240, 72 -- typst caption-pad 14.4 pt, caption-below 12 pt, caption-top 3.6 pt
local DESIGNATION = 2592                 -- typst designation-indent 1.8 in
local SIG_W = 4608                       -- typst signature-width 3.2 in
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-page-col 36 pt, toa-page-col 72 pt
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local ROW_GAP = 120                      -- typst row-gap 6 pt
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60

local function need_meta(meta, k)
  if meta[k] == nil then error("cand-motion-brief: missing required metadata field `" .. k .. "`", 0) end
  return meta[k]
end

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table that does not split; a cell = { pr, body = { xml, .. } }.
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

-- A left tab at `at` (a label's box) and the dot leader to the page column.
local function row_tabs(at)
  return '<w:tabs>' .. (at and ('<w:tab w:val="left" w:pos="' .. at .. '"/>') or "") ..
    '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, kind, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
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
-- Sections and the footer
-- ---------------------------------------------------------------------------

local PAGE_FIELD = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE ' ..
  '</w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>' ..
  '<w:r><w:fldChar w:fldCharType="end"/></w:r>'

local VML = 'xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"'
-- LibreOffice keeps a VML text box's inset whatever its `inset` says: the box moves by the difference, so that its
-- lines are typst's (the numbers end at number-col, each on its body line's baseline; measured in the PDF).
local BOX_DX, BOX_DY = 4, -4.25
local BOX_PAD = 12                            -- and room below the last number for the inset LibreOffice keeps
local PAGE_POS = 'position:absolute;mso-position-horizontal:absolute;mso-position-horizontal-relative:page;' ..
  'mso-position-vertical:absolute;mso-position-vertical-relative:page'

-- The pleading paper (typst line-numbers, pleading-rules; as ../../complaint/docx/cand.lua): the numbers 1 to 28 in
-- a text box at the left of the page, one per exact 24 pt line from the top margin, ending at number-col; and the
-- rules, a double one at the text's left edge and a single one at its right, the height of the page. Both behind
-- the text, anchored to the page, in the footer so that they take no room in the text and repeat on every page.
local function furniture()
  local nums = {}
  for i = 1, LINES do
    nums[#nums + 1] = p(xe.runs(tostring(i)), { line = BODY, jc = "right" })
  end
  -- a rule: a black box 0.75 pt wide, centered on x_in inches, the height of the page
  local function rule(x_in, id)
    return '<w:r><w:pict ' .. VML .. '><v:rect id="CandRule' .. id .. '" fillcolor="black" filled="t" stroked="f" style="' .. PAGE_POS ..
      string.format(";margin-left:%.2fpt;margin-top:0;width:0.75pt;height:792pt", x_in * 72 - 0.375) ..
      ";z-index:-251658" .. (700 + id) .. '"/></w:pict></w:r>'
  end
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:pict ' ..
    VML .. '>' ..
    '<v:shape id="CandLineNumbers" filled="f" stroked="f" style="' .. PAGE_POS .. ';margin-left:' .. BOX_DX .. 'pt;margin-top:' ..
    (TOP / 20 + BOX_DY) .. 'pt;width:' .. (NUMBER_COL / 20) .. 'pt;height:' .. (LINES * BODY / 20 + BOX_PAD) .. 'pt;z-index:-251658752">' ..
    '<v:textbox inset="0pt,0pt,0pt,0pt"><w:txbxContent>' .. table.concat(nums) .. '</w:txbxContent></v:textbox></v:shape>' ..
    '</w:pict></w:r>' .. rule(LEFT / 1440 - 0.2, 1) .. rule(LEFT / 1440 - 0.16, 2) .. rule(8.5 - RIGHT / 1440 + 0.1, 3) ..
    '</w:p>'
end

-- The footer (typst running-footer): the page number, the paper's title in capitals and the case number, centered,
-- 10 pt in 11.5 pt line boxes, its last line FOOT_DIST above the page's foot.
local function footer(meta)
  local sz = '<w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/><w:szCs w:val="' .. FOOT_SZ .. '"/></w:rPr>'
  local function line(body) return p(body, { line = FOOT_LINE, jc = "center" }) end
  local o = { sz = FOOT_SZ }
  return furniture() .. line((PAGE_FIELD:gsub("<w:r>", "<w:r>" .. sz))) ..
    line(xe.inl(upper(need_meta(meta, "footer_title")), o)) ..
    line(xe.runs("No. " .. stringify(need_meta(meta, "case_number")), o))
end

-- The cover's footer: the pleading paper alone (typst: no footer text on the cover, the page's background stays).
local function cover_footer() return furniture() end

local function sect_pr(footer_id, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer_id .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="' .. TOP .. '" w:right="' .. RIGHT .. '" w:bottom="' .. TOP .. '" w:left="' .. LEFT .. '" '
    .. 'w:header="720" w:footer="' .. FOOT_DIST .. '" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer_id, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer_id, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  for _, l in ipairs(need_meta(meta, "counsel")) do out[#out + 1] = p(xe.inl(l)) end
  out[#out + 1] = p(xe.inl(need_meta(meta, "counsel_role"), { i = true }))
  for i, l in ipairs(need_meta(meta, "court")) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", before = i == 1 and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation set in; "v." centered between the parties, half a double
  -- line around it. Right cell: the case number, the title, the noticed hearing.
  local left = {}
  local sides = need_meta(meta, "caption")
  for i, side in ipairs(sides) do
    if i > 1 then left[#left + 1] = p(xe.runs("v."), { before = HALF, jc = "center" }) end
    for j, n in ipairs(side.names) do
      left[#left + 1] = p(xe.inl(n), { before = (i > 1 and j == 1) and HALF or 0 })
    end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
  end
  local right = { p(xe.runs("Case No. " .. stringify(meta.case_number)), { before = CAP_TOP }) }
  right[#right + 1] = p(xe.inl(upper(need_meta(meta, "brief_title")), { b = true }), { before = HALF })
  local hearing = need_meta(meta, "hearing")
  local first = true
  for _, kl in ipairs({ { "date", "Date: " }, { "time", "Time: " }, { "place", "Place: " }, { "judge", "" } }) do
    if hearing[kl[1]] then
      right[#right + 1] = p(xe.runs(kl[2]) .. xe.inl(hearing[kl[1]]), { before = first and HALF or 0 })
      first = false
    end
  end
  -- the caption a double line below the court title: a 1 pt paragraph carries the space (Word sets none above a
  -- table)
  out[#out + 1] = p("", { before = BODY - 20, line = 20 })
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ TEXTW // 2, TEXTW - TEXTW // 2 }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>',
      body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>',
      body = right },
  })
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities
-- ---------------------------------------------------------------------------

local function table_head(out, title, col, brk)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(title), { b = true }), { jc = "center", keep = true, brk = brk })
  out[#out + 1] = p(xe.runs(col, { b = true }), { jc = "right", before = HALF, keep = true })
end

-- Contents: the label in its box at the heading's indent, the title hanging after it, the page in its column.
local function contents(entries, out)
  table_head(out, "Table of Contents", "Page")
  for _, e in ipairs(entries) do
    if e.level <= 4 then
      local ind = math.max(e.level - 2, 0) * TAB
      local lab = e.label ~= "" and xe.runs(e.label .. "\t") or ""
      local title = e.level == 1 and upper(e.title) or e.title
      out[#out + 1] = p(lab .. xe.inl(title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
        { lines = true, tabs = row_tabs(ind + TAB), before = ROW_GAP, left = ind + TAB, hanging = TAB, right = TOC_COL })
    end
  end
end

local GROUPS = {
  { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" }, { "other", "Other Authorities" },
}

local function authorities(meta, cites, out)
  table_head(out, "Table of Authorities", "Page(s)", true)
  local auth = meta.authorities or {}
  for key in pairs(cites) do
    if auth[key] == nil then
      error("cand-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter", 0)
    end
  end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if stringify(a.kind) == g[1] and cites[key] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      local kx = pandoc.text.lower(stringify(x.a.name or x.a.cite))
      local ky = pandoc.text.lower(stringify(y.a.name or y.a.cite))
      return kx < ky
    end)
    if #members > 0 then
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = HALF, keep = true })
      for _, m in ipairs(members) do
        -- distinct printed page labels, in document order
        local pages, seen = {}, {}
        for _, id in ipairs(cites[m.key]) do
          local l = labels[id] or "0"
          if not seen[l] then seen[l] = true; pages[#pages + 1] = l end
        end
        local pg = #pages >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pages, ", "))
        local name = ""
        if m.a.name then name = xe.inl(m.a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        out[#out + 1] = p(name .. xe.inl(m.a.cite) .. xe.runs(xe.LEAD) .. pg,
          { lines = true, tabs = row_tabs(), before = ROW_GAP, left = TOA_HANG, hanging = TOA_HANG, right = TOA_COL })
      end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block: the date at the margin; "Respectfully submitted,", the preamble, the signature, the signer and
-- the signer's lines at the right; the row never splits. The space above it is a 1 pt paragraph kept with the
-- table, its space before the rest: at the top of a page LibreOffice drops a paragraph's space before, as typst
-- drops a block's.
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = need_meta(meta, "signature")
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(sig.preamble or {}) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and BODY or 0 }) end
  right[#right + 1] = p(xe.runs("/s/ " .. stringify(sig.signer), { i = true }), { before = BODY })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  out[#out + 1] = p("", { keep = true, before = BODY - 20, line = 20 })
  out[#out + 1] = tbl({ TEXTW - SIG_W, SIG_W }, {
    { body = { p(xe.runs("Dated: ") .. xe.inl(need_meta(meta, "date"))) } }, { body = right } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return s
end

-- typst heading-num: level 2 "I.", 3 "A.", 4 "1.", 5 "a.", level 1 none.
local function heading_label(level, k)
  if level == 2 then return roman(k) .. "." end
  if level == 3 then return string.char(64 + k) .. "." end
  if level == 4 then return k .. "." end
  if level == 5 then return string.char(96 + k) .. "." end
  return ""
end

-- Headings single-spaced, half a double line above and below, kept with the text: level 1 centered in bold
-- capitals, deeper levels with the label in a box at the level's indent and the bold title hanging after it (Word's
-- Heading 1 to 3: the recipe sets levels 4 and 5 in italics, typst does not).
local function heading(level, label, content, before)
  if level == 1 then
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(before, HALF, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(upper(content), { b = true }))
  end
  local ind = math.max(level - 2, 0) * TAB
  return xe.para({ xe.style("Heading" .. math.min(level, 3)), xe.KEEP,
    '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + TAB) .. '"/></w:tabs>',
    xe.spacing(before, HALF, SINGLE), xe.ind(ind + TAB, TAB), xe.jc("left") },
    xe.runs(label .. "\t") .. xe.inl(content, { b = true }))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
-- A web address breaks only where the typst template lets it: after "?", "=", "&", or a hyphen or slash that no
-- digit, no second slash and no first slash comes next to (a zero-width space there, and none after the slashes of
-- "https://").
local function url_breaks(t)
  local cs = {}
  for _, c in utf8.codes(t) do cs[#cs + 1] = utf8.char(c) end
  local out = {}
  for i, c in ipairs(cs) do
    out[#out + 1] = c
    local nxt, prev = cs[i + 1] or "", cs[i - 1] or ""
    if nxt ~= "" and (c == "?" or c == "=" or c == "&" or ((c == "/" or c == "-") and nxt ~= "/"
        and not (c == "/" and prev == "/") and not nxt:match("^%d$"))) then
      out[#out + 1] = "\u{200B}"
    end
  end
  return table.concat(out)
end

local function breaks(s)
  local t = s.text
  local a = t:find("https?://") or t:find("www%.")
  if a then return pandoc.Str(t:sub(1, a - 1) .. url_breaks(t:sub(a))) end
  return pandoc.Str((t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1391"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" and #a.text >= 4 and a.text:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- The printed text of a block or of inlines, without footnotes (a note is printed at the foot of the page).
local function printed(x)
  local blocks = x.t and { x } or { pandoc.Plain(x) }
  return stringify(pandoc.Pandoc(blocks):walk({ Note = function() return {} end }))
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "counsel", "counsel_role", "brief_title", "footer_title",
    "hearing", "signature", "date" }) do need_meta(meta, k) end
  write_file("FORMBOOK_FOOTERS", "rIdCandFooter\t" .. footer(meta) .. "\nrIdCandCover\t" .. cover_footer() .. "\n")
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  meta = doc.meta
  local blocks = doc.blocks
  if blocks[1] == nil then error("cand-motion-brief: the motion has no body") end

  local body, entries, cites = {}, {}, {}
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n, l_n = 0, 0
  -- every `toa:` link of a paragraph or of its footnotes, as a needle: its text and the words after it
  local function links(inlines, kind)
    for i, el in ipairs(inlines) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        l_n = l_n + 1
        local id = "A:" .. l_n
        local after = {}
        for j = i + 1, #inlines do after[#after + 1] = inlines[j] end
        need(id, kind, stringify(el.content), printed(pandoc.Inlines(after)):sub(1, 40))
        cites[key] = cites[key] or {}
        table.insert(cites[key], id)
      elseif el.t == "Note" then
        for _, nb in ipairs(el.content) do
          if nb.content then links(nb.content, "N") end
        end
      end
    end
  end
  -- the motion's first page: the page of its first block
  local first_id = "S:1"
  for i, b in ipairs(blocks) do
    local next_text = blocks[i + 1] and printed(blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      counts[b.level] = counts[b.level] + 1
      for j = b.level + 1, #counts do counts[j] = 0 end
      h_n = h_n + 1
      local id = "H:" .. h_n
      if i == 1 then first_id = id end
      local label = heading_label(b.level, counts[b.level])
      need(id, "B", stringify(b.content), next_text)
      entries[#entries + 1] = { id = id, level = b.level, label = label, title = b.content }
      -- the motion opens a section (a new page): Word keeps the space above there, typst drops it
      body[#body + 1] = xe.raw(heading(b.level, label, b.content, i == 1 and 0 or HALF))
    elseif b.t == "Para" or b.t == "Plain" then
      if i == 1 then need(first_id, "B", printed(b):sub(1, 40), "") end
      links(b.content, "B")
      local inlines = pandoc.Pandoc({ pandoc.Para(b.content) }):walk({
        Link = function(el) if el.target:match("^toa:") then return el.content end end,
      }):walk({ Inlines = xe.inlines }).blocks[1].content
      body[#body + 1] = pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = "Body Text" })
    else
      error("cand-motion-brief: unsupported block " .. b.t)
    end
  end
  local tail = {}
  signature(meta, tail)
  for _, x in ipairs(tail) do body[#body + 1] = xe.raw(x) end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\t" .. first_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdCandFooter", "decimal"))

  local out = {}
  cover(meta, out)
  out[#out + 1] = section("rIdCandCover")
  contents(entries, out)
  authorities(meta, cites, out)
  out[#out + 1] = section("rIdCandFooter", "lowerRoman")

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  for _, x in ipairs(body) do res[#res + 1] = x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

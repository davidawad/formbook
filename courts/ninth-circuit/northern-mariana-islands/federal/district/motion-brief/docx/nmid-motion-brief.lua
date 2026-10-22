-- nmid motion with memorandum, docx engine. Mirrors typst/nmid-motion-brief.typ; rules and conventions are in
-- ../README.md. The cover (counsel, court title, caption with the hearing, the lead-in), the table of contents and
-- the table of authorities (LR 7.1.d.1; built from the `toa:` links of the body, as typst builds them), the headings
-- with their labels (I., 1., a., (1)), the lettered items and the signature block are built here; body paragraphs stay
-- pandoc paragraphs (style Body Text of docx/reference.xml), so their footnotes are pandoc's. Content-agnostic: every
-- case-specific word comes from the sample's frontmatter and body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 a numbered line, 240 a single line), the spaces between
-- blocks those of the typst template, and the break rules of typst on every run.
--
-- Page furniture and pages (were docx/build-reference.sh, docx/render.sh and pagemap.awk): one section numbered from
-- 1 ($FORMBOOK_FINAL), its footer written here ($FORMBOOK_FOOTERS: the numbered lines 1 to 25 in a text box anchored
-- to the page, the page number, the paper's title and the case number from the frontmatter). The tables' page
-- numbers: fb render (tools/fb/src/docxpass.rs) finds the needles this filter writes ($FORMBOOK_NEEDLES: the table
-- titles, each heading, each citation, in document order) in the LibreOffice PDF and renders again with their pages
-- ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE, HALF = 480, 240, 240 -- typst pitch 24 pt, pitch-single 12 pt, half 12 pt
local LIFT, DROP = 192, 48               -- typst lift 9.6 pt (a single line's baseline on a numbered line's), drop 2.4 pt
local LINES = 25                         -- typst lines-per-page
local TOP = 2160                         -- typst top-margin 1.5 in
local TEXTW = 10080                      -- 7 in between the 1 in and 0.5 in margins
local COUNSEL_W, COUNSEL_MIN = 6048, 3360 -- typst counsel-width 4.2 in; counsel-lines 7 x 24 pt
local CAP_LEFT, CAP_GUT = 4896, 360      -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_PAD = 200                      -- typst caption-pad 10 pt
local CAP_BELOW = 273                    -- typst caption-below 12 pt and drop, less the 0.75 pt bottom rule LibreOffice adds
local CASE_PAD = 144                     -- typst case-pad 0.1 in
local SIG_LEFT, SIG_GUT = 3744, 288      -- typst sig-left 2.6 in, sig-gutter 0.2 in
local TAB_W = 720                        -- typst heading-tab 0.5 in
local PNUM = 720                         -- typst page-col 0.5 in
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60

local COURT_TITLE = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN MARIANA ISLANDS" } -- LR 5.2.d.1

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("nmid-motion-brief.lua: missing required metadata field `" .. key .. "`") end
  return v
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word), nor after a doubled sign ("(§§ 175-10.1-610(b)"; typst
-- boxes the token): the space becomes a no-break space, as wide.
local function bind_spaces(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    local s = l[i]
    if s.t == "Str" and l[i + 1].t == "Space" and (s.text:find("§§$") or s.text:find("¶¶$")) then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single-spaced lines (typst line-stack), `above` the first.
local function stack(lines, above)
  local out = {}
  for k, l in ipairs(lines) do
    out[#out + 1] = p(l, { before = k == 1 and (above or 0) or 0 })
  end
  return table.concat(out)
end

-- A one-row table with fixed column widths; cells = { { xml, tcpr } }; the row is not split across pages.
local function table_xml(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i][2] or "") .. '</w:tcPr>'
      .. (cells[i][1] ~= "" and cells[i][1] or p("")) .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/>' .. (trpr or "") .. '</w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function needle(id, kind, text, context)
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
-- Page furniture: the section, the footer with the numbered lines
-- ---------------------------------------------------------------------------

-- Letter; top 1.5 in, bottom 84 pt (25 lines of 24 pt between them), left 1 in, right 0.5 in (LR 5.2.a); the footer
-- 0.4 in above the bottom edge (typst footer-foot).
local function sect_pr()
  return '<w:sectPr><w:footerReference w:type="default" r:id="rIdNmidFooter"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="' .. TOP .. '" w:right="720" w:bottom="1680" w:left="1440" '
    .. 'w:header="720" w:footer="576" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'
end

-- The numbers 1 to 25 down the left margin, right-aligned 0.7 in from the page edge, one exact 24 pt line each from
-- the top margin (typst line-numbers): a VML text box anchored to the page, which Word and LibreOffice both place
-- absolutely, outside the text flow.
-- The pleading rules (typst pleading-rules): two at the text's left edge (0.12 in and 0.08 in before it), one 0.08 in
-- after its right edge, 0.75 pt, the full height of the page; DrawingML lines anchored to the page, behind the text
-- (positions in EMU, 12700 a point).
local RULES_X = { 804672, 841248, 7388352 }
local DML = 'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
  .. 'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
  .. 'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"'
local function rules()
  local out = {}
  for k, x in ipairs(RULES_X) do
    out[#out + 1] = '<w:r><w:drawing ' .. DML .. '><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" '
      .. 'relativeHeight="' .. (251659270 + k) .. '" behindDoc="1" locked="1" layoutInCell="1" allowOverlap="1">'
      .. '<wp:simplePos x="0" y="0"/><wp:positionH relativeFrom="page"><wp:posOffset>' .. x .. '</wp:posOffset>'
      .. '</wp:positionH><wp:positionV relativeFrom="page"><wp:posOffset>0</wp:posOffset></wp:positionV>'
      .. '<wp:extent cx="0" cy="10058400"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/>'
      .. '<wp:docPr id="' .. (100 + k) .. '" name="Pleading rule ' .. k .. '"/><wp:cNvGraphicFramePr/><a:graphic>'
      .. '<a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp><wps:cNvCnPr/>'
      .. '<wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="10058400"/></a:xfrm><a:prstGeom prst="line">'
      .. '<a:avLst/></a:prstGeom><a:ln w="9525"><a:solidFill><a:srgbClr val="000000"/></a:solidFill></a:ln></wps:spPr>'
      .. '<wps:bodyPr/></wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r>'
  end
  return table.concat(out)
end

local function line_numbers()
  local ps = {}
  for i = 1, LINES do
    ps[#ps + 1] = p(xe.runs(tostring(i)), { line = BODY, jc = "right" })
  end
  return '<w:r><w:pict xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">'
    .. '<v:shapetype id="_x0000_t202" coordsize="21600,21600" o:spt="202" '
    .. 'path="m,l,21600r21600,l21600,xe"><v:stroke joinstyle="miter"/><v:path gradientshapeok="t" o:connecttype="rect"/>'
    .. '</v:shapetype><v:shape id="LineNumbers" o:spid="_x0000_s1025" type="#_x0000_t202" filled="f" stroked="f" '
    .. 'style="position:absolute;margin-left:0;margin-top:' .. (TOP / 20) .. 'pt;width:50.4pt;height:' .. (LINES * BODY / 20)
    .. 'pt;z-index:-251657216;mso-position-horizontal-relative:page;mso-position-vertical-relative:page">'
    .. '<v:textbox inset="0,0,0,0"><w:txbxContent>' .. table.concat(ps) .. '</w:txbxContent></v:textbox></v:shape>'
    .. '</w:pict></w:r>' .. rules()
end

local PAGE_FIELD = '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t>1</w:t></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>'

-- The page number centred, then the paper's title (upper case) at left and the case number at right: 10 pt type in
-- 12 pt lines, 4 pt apart (typst footer-block).
local function footer_xml(m)
  local o = { sz = 20 }
  local title = xe.runs(pandoc.text.upper(stringify(need(m, "footer_title"))), o)
  return p(line_numbers() .. PAGE_FIELD, { line = 240, jc = "center" })
    .. p(title .. xe.runs("\tCASE NO. " .. stringify(need(m, "case_number")), o),
      { line = 240, before = 80, tabs = '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>' })
end

-- ---------------------------------------------------------------------------
-- First page: counsel (lines 1-7), court title, caption with the hearing, the lead-in
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  -- counsel: lines 1 to 7 at least (a row at least that tall; LR 5.2.c)
  local counsel = {}
  for _, l in ipairs(items(need(m, "counsel"))) do counsel[#counsel + 1] = xe.inl(l) end
  out[#out + 1] = table_xml({ COUNSEL_W }, { { stack(counsel, LIFT) } },
    '<w:trHeight w:val="' .. COUNSEL_MIN .. '" w:hRule="atLeast"/>')
  for _, l in ipairs(COURT_TITLE) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center", keep = true })
  end
  -- typst caption: a blank numbered line above (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = BODY })
  local left = {}
  local versus = m.versus and stringify(m.versus) or "v."
  for k, side in ipairs(items(need(m, "caption"))) do
    if k > 1 then left[#left + 1] = xe.runs(versus) end
    for _, n in ipairs(items(side.names)) do left[#left + 1] = xe.inl(n) end
    left[#left + 1] = xe.inl(side.designation)
  end
  local h = need(m, "hearing")
  local right = stack({ xe.runs("CIVIL CASE NO. ") .. xe.inl(need(m, "case_number")) })
    .. stack({ xe.inl(need(m, "brief_title"), { b = true }) }, HALF)
    .. stack({ xe.runs("Hearing Date: ") .. xe.inl(h.date), xe.runs("Hearing Time: ") .. xe.inl(h.time),
      xe.runs("Judge: ") .. xe.inl(h.judge) }, HALF)
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  out[#out + 1] = table_xml({ CAP_LEFT, CAP_GUT, TEXTW - CAP_LEFT - CAP_GUT }, {
    { stack(left), rule .. '<w:tcMar><w:top w:w="' .. LIFT .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_BELOW
      .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>' },
    { "" },
    { right, '<w:tcMar><w:top w:w="' .. LIFT .. '" w:type="dxa"/><w:left w:w="' .. CASE_PAD
      .. '" w:type="dxa"/><w:bottom w:w="' .. DROP .. '" w:type="dxa"/></w:tcMar>' },
  })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings: "I." level 2, "1." level 3, "a." level 4, "(1)" level 5; level 1 unnumbered
-- ---------------------------------------------------------------------------

local function roman(n)
  local t = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, x in ipairs(t) do while n >= x[1] do s = s .. x[2]; n = n - x[1] end end
  return s
end

local function label(level, k)
  if level == 2 then return roman(k) .. "."
  elseif level == 3 then return k .. "."
  elseif level == 4 then return string.char(96 + k) .. "."
  elseif level == 5 then return "(" .. k .. ")"
  end
  return ""
end

local function indent(level)
  return math.max(level - 2, 0) * TAB_W
end

-- A heading on the numbered-line pitch, kept with the next block (typst sticky): level 1 centred bold capitals;
-- deeper levels bold, the label in a box half an inch wide (a tab), the title hanging after it.
local function heading(level, lab, content, pre)
  if level == 1 then
    return p(xe.inl(upper(content), { b = true }), { pre = pre, line = BODY, keep = true, jc = "center" })
  end
  local ind = indent(level)
  return p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(content, { b = true }),
    { pre = pre, line = BODY, keep = true, left = ind + TAB_W, hanging = TAB_W })
end

-- ---------------------------------------------------------------------------
-- The tables (contents and authorities)
-- ---------------------------------------------------------------------------

-- A table's title and its column label (typst table-head), each one numbered line; a page of its own.
local function table_head(title, col)
  return p(xe.runs(title, { b = true }), { pre = xe.BREAK, line = BODY, keep = true, jc = "center" })
    .. p(xe.runs(col, { b = true }), { line = BODY, keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging)
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = xe.leader_tab(TEXTW),
    line = BODY, left = left, hanging = hanging, right = PNUM })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    if e.level <= 4 then
      local ind = indent(e.level)
      local title = e.level == 1 and upper(e.title) or e.title
      out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(title), xe.runs(labels[e.id] or "0"), ind + TAB_W, TAB_W)
    end
  end
  return table.concat(out)
end

local GROUPS = { { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "rule", "Rules" }, { "regulation", "Regulations" }, { "other", "Other Authorities" } }

local function toa(authorities, cites)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)") }
  -- the distinct page labels of each authority, in document order (the page a citation starts on)
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then
      error("nmid-motion-brief.lua: link `toa:" .. c.key .. "` has no entry under `authorities:` in the frontmatter")
    end
    pages[c.key] = pages[c.key] or {}
    seen[c.key] = seen[c.key] or {}
    local l = labels[c.id] or "0"
    if not seen[c.key][l] then
      seen[c.key][l] = true
      pages[c.key][#pages[c.key] + 1] = l
    end
  end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if pages[key] and stringify(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = pandoc.text.lower(stringify(a.name or a.cite or "")) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { line = BODY, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        local text = ""
        if a.name then text = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        text = text .. xe.inl(a.cite)
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_HANG, TOA_HANG)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 5.2; the layout is a convention, the rules cite no form)
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = need(m, "signature")
  local pre = {}
  for _, l in ipairs(items(sig.preamble)) do pre[#pre + 1] = xe.inl(l) end
  local signer = { xe.runs("/s/ " .. stringify(need(sig, "signer"))), xe.inl(sig.signer) }
  for _, l in ipairs(items(sig.lines)) do signer[#signer + 1] = xe.inl(l) end
  local right = stack({ xe.runs("Respectfully submitted,") }, LIFT) .. (#pre > 0 and stack(pre, HALF) or "")
    .. stack(signer, HALF)
  return table_xml({ SIG_LEFT, SIG_GUT, TEXTW - SIG_LEFT - SIG_GUT },
    { { stack({ xe.runs("Date: ") .. xe.inl(need(m, "date")) }, LIFT) }, { "" }, { right } })
end

-- ---------------------------------------------------------------------------
-- The motion
-- ---------------------------------------------------------------------------

-- The citations of a list of inlines, in document order, as needles (B in the body, N in a footnote): the link text
-- and the words after it.
local cites = {}
local scan_blocks
local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      local id = "A:" .. (#cites + 1)
      cites[#cites + 1] = { id = id, key = el.target:sub(5) }
      needle(id, in_note and "N" or "B", stringify(el.content), stringify(rest):sub(1, 40))
    elseif el.t == "Note" then
      scan_blocks(el.content, true)
    elseif el.content and type(el.content) ~= "string" and el.t ~= "Link" then
      scan_inlines(el.content, in_note)
    end
  end
end
scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" then
      scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

local function has_note(inlines)
  local found = false
  pandoc.Inlines(inlines):walk({ Note = function() found = true end })
  return found
end

-- A body paragraph (style Body Text; the last one kept with the signature, one with a footnote without widow control).
local function body_para(content, keep)
  local style = keep and "Body Text Keep" or has_note(content) and "Body Text Note" or "Body Text"
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

-- A lettered list (typst: (a), (b), ...): each item an "Item" paragraph, its label and a tab before the text.
local function lettered(b)
  local out = {}
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  for _, item in ipairs(b.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("nmid-motion-brief.lua: a list item must be one paragraph")
    end
    local inlines = pandoc.Inlines({ pandoc.Str("(" .. string.char(96 + n) .. ")"),
      pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
    inlines:extend(item[1].content)
    out[#out + 1] = pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = "Item" })
    n = n + 1
  end
  return out
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "case_number", "caption", "counsel", "brief_title", "footer_title", "hearing", "signature",
    "date" }) do
    local _ = need(m, k)
  end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end

  -- the heading labels (I., 1., a., (1))
  local counters = { 0, 0, 0, 0, 0, 0 }
  local labs = {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 6)
      counters[level] = counters[level] + 1
      for l = level + 1, 6 do counters[l] = 0 end
      labs[i] = label(level, counters[level])
    end
  end
  -- the last paragraph, kept with the signature block (typst: one unbreakable block)
  local last = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Para" then last = i end
  end

  needle("S:cover", "B", stringify(items(need(m, "counsel"))[1]), stringify(items(m.counsel)[2] or ""))
  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
  local entries, body = {}, {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 6)
      local id = "H:" .. (#entries + 1)
      -- A heading is kept with the block after it, so it is on the page where that block (the first that is not a
      -- heading) starts: its needle is that block's first words, a note-kind needle (searched from the page the body
      -- has reached, moving nothing; docxpages.rs). pdftotext may print a heading's title, tabbed away from its
      -- label, after the lines that follow it (the label, the title and the line numbers read as columns), so the
      -- heading's own words are no needle.
      local k = i + 1
      while doc.blocks[k] and doc.blocks[k].t == "Header" do k = k + 1 end
      local after = doc.blocks[k] and stringify(doc.blocks[k]):sub(1, 50) or stringify(b.content)
      needles[#needles + 1] = { id = id, kind = "N", needle = norm(after):sub(1, NEEDLE_MAX),
        fallback = norm(stringify(b.content)):sub(1, NEEDLE_MAX) }
      entries[#entries + 1] = { id = id, level = level, label = labs[i], title = b.content }
      -- the body opens a page (typst pagebreak)
      body[#body + 1] = xe.raw(heading(level, labs[i], b.content, #body == 0 and xe.BREAK or nil))
    else
      scan_blocks({ b }, false)
      if #body == 0 then error("nmid-motion-brief.lua: the memorandum must open with a heading") end
      if b.t == "Para" or b.t == "Plain" then
        body[#body + 1] = body_para(b.content, i == last)
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        for _, x in ipairs(lettered(b)) do body[#body + 1] = x end
      else
        error("nmid-motion-brief.lua: unsupported block " .. b.t)
      end
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdNmidFooter\t" .. footer_xml(m) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr())

  local out = { xe.raw(cover(m)) }
  if m.lead_in then out[#out + 1] = body_para(m.lead_in, false) end
  out[#out + 1] = xe.raw(toc(entries) .. toa(authorities, cites))
  for _, x in ipairs(body) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind_spaces }, { Pandoc = finish } }

-- ttab-trial-brief.lua (docx engine, brief on the case). Builds the front matter, the table of authorities and the
-- trailing blocks (signature, certificate of service) as WordprocessingML from the sample's YAML frontmatter (the
-- contract the typst template reads, ../README.md "Markdown contract"). The body paragraphs, block quotations and
-- footnotes are pandoc's own conversion, styled by reference.docx (make-reference.sh); the headings are written here.
--
--   * Sections (Word-native numbering): the caption page and the table of authorities are roman (i, ii); the body is
--     arabic from 1 (set on the final section in reference.docx). Each front-matter section ends in a one-point
--     paragraph that carries its sectPr, so the break adds no page.
--   * The counsel block and the date sit at the foot of the caption page: a frame anchored to the bottom margin.
--   * The table of authorities lists each key with its pages and dot leaders. pandoc cannot know the pages, so
--     render.sh converts twice: this filter writes one search needle per link (TTAB_TOA_SEARCH); render.sh finds
--     the needles on the body pages of the PDF and writes TTAB_TOA_PAGES ("key<TAB>1, 4, 7"); the next pass lists
--     them. An authority cited on 7 or more pages prints "passim" (the typst template's rule).
--   * A citation is a link whose target is toa:KEY (../README.md). A key that is not in the authorities stops the build.
-- No case text is in this file.
--
-- Cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph has
-- exact line spacing at the typst template's pitch (typst/ttab-trial-brief.typ: pitch-double 24 pt = 480 twips,
-- pitch-single 13.8 pt = 276 twips) and the typst spaces between blocks (twips = 20 x pt). Where typst collapses two
-- spaces to the larger, the larger is written on one side only. A paragraph that opens a page after a hard break
-- carries no space above (Word keeps it there; typst drops it).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local TWIP = 1440
local function tw(inches) return math.floor(inches * TWIP + 0.5) end

local TEXT_WIDTH = tw(6.5)
local SIG_LEFT = tw(3.0)
local INDENT = 720
local SINGLE = 276
local DOUBLE = 480
local PASSIM = 7
local TOA_COL = 1120        -- typst toa-page-col, 56 pt
local TOA_HANG = 720        -- typst toa-hang

local function T(s, o) return xe.runs(s, o) end
local function I(v, o) return xe.inl(v, o) end

local function need(meta, key)
  if meta[key] == nil then error("ttab-trial-brief.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- One paragraph: o = { before, after, left, hanging, first, right, jc, keep, lines, tabs, line, frame, outline }
local function line(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.frame then props[#props + 1] = o.frame end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  if o.jc then props[#props + 1] = xe.jc(o.jc) end
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

-- The footer is referenced once, by the first section; later sections inherit it.
local FOOTER = '<w:footerReference w:type="default" r:id="rIdFooter1" />'
local PAGE = '<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="432" w:gutter="0" />'

local function section_xml(numfmt, first)
  return "<w:sectPr>" .. (first and FOOTER or "") .. PAGE .. '<w:pgNumType w:fmt="' .. numfmt .. '" /></w:sectPr>'
end

-- A one-point paragraph that ends a section: it takes no room, so it cannot push a page over.
local function section_end(numfmt, first)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/>'
    .. section_xml(numfmt, first) .. '</w:pPr></w:p>'
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>' ..
  '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local NO_MARGINS = '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
local function cell(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Caption page
-- ---------------------------------------------------------------------------

-- TBMP 309.02(a): the heading the Board requires at the top of the first page.
local function board_heading()
  return line(T("IN THE UNITED STATES PATENT AND TRADEMARK OFFICE", { b = true }), { jc = "center", keep = true }) ..
    line(T("BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD", { b = true }), { jc = "center", keep = true })
end

-- The party caption: one single-spaced row per line of names, a ")" column beside them, and the proceeding numbers
-- on the right, one every other row, centered against the caption (typst caption-table). 18 pt above it.
local function caption_table(meta)
  local sides = need(meta, "caption")
  local rows = {}
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do rows[#rows + 1] = { ind = 0, body = I(name) } end
    rows[#rows + 1] = { ind = tw(2.1), body = I(side.designation) }
    if i < #sides then
      rows[#rows + 1] = { ind = 0, body = "" }
      rows[#rows + 1] = { ind = tw(1.2), body = T("v.") }
      rows[#rows + 1] = { ind = 0, body = "" }
    end
  end
  local right = need(meta, "caption_right")
  local step = (2 * #right - 1 <= #rows) and 2 or 1
  local used = step * (#right - 1) + 1
  local start = math.max(0, (#rows - used) // 2)
  local n = math.max(#rows, start + used)
  local W = { tw(3.4), tw(0.35), tw(2.4) }
  local out = {}
  for i = 0, n - 1 do
    local row = rows[i + 1]
    local k = i - start
    local r = ""
    if k >= 0 and k % step == 0 and k // step < #right then r = I(right[k // step + 1]) end
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. SINGLE .. '" w:hRule="exact"/></w:trPr>' ..
      cell(W[1], line(row and row.body or "", { left = row and row.ind or 0 })) ..
      cell(W[2], line(row and T(")") or "", { jc = "center" })) ..
      cell(W[3], line(r)) .. '</w:tr>'
  end
  local gap = line("", { line = 360, keep = true })   -- the space above the table (a table carries none)
  return gap .. '<w:tbl><w:tblPr><w:tblW w:w="' .. (W[1] + W[2] + W[3]) .. '" w:type="dxa"/>' .. NO_BORDERS ..
    '<w:tblLayout w:type="fixed"/>' .. NO_MARGINS ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>' ..
    '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. W[1] .. '"/><w:gridCol w:w="' .. W[2] .. '"/><w:gridCol w:w="' .. W[3] ..
    '"/></w:tblGrid>' .. table.concat(out) .. '</w:tbl>'
end

-- The counsel block and the date at the foot of the caption page: consecutive paragraphs with one framePr form one
-- frame, anchored to the bottom margin (typst: v(1fr) above them).
local function counsel_frame(meta)
  local frame = '<w:framePr w:w="' .. TEXT_WIDTH .. '" w:hRule="auto" w:wrap="around" w:vAnchor="margin" w:hAnchor="margin" w:yAlign="bottom"/>'
  local out = {}
  for gi, g in ipairs(need(meta, "counsel")) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = n end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    for k, l in ipairs(lines) do
      out[#out + 1] = line(I(l), { frame = frame, left = SIG_LEFT, before = (gi > 1 and k == 1) and 120 or 0 })
    end
  end
  out[#out + 1] = line(I(need(meta, "phone")), { frame = frame, left = SIG_LEFT })
  out[#out + 1] = line(I(need(meta, "date")), { frame = frame, before = 384 })
  return table.concat(out)
end

local function caption_page(meta)
  local x = board_heading() .. caption_table(meta) ..
    line(I(need(meta, "brief_title"), { b = true }), { jc = "center", keep = true, before = 528 })
  if meta.version ~= nil then x = x .. line(I(meta.version), { jc = "center", before = 144 }) end
  return xe.raw(x .. counsel_frame(meta) .. section_end("lowerRoman", true))
end

-- ---------------------------------------------------------------------------
-- Table of authorities (37 CFR 2.128(b): the index of cases, then the other authorities)
-- ---------------------------------------------------------------------------

-- The page list of each key from render.sh's previous pass (TTAB_TOA_PAGES: "key<TAB>1, 4, 7" per line). Before the
-- first pass, each authority is listed on a placeholder page, so the first pass has the same entries.
local function read_pages()
  local path = os.getenv("TTAB_TOA_PAGES")
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local pages = {}
  for l in f:lines() do
    local key, list = l:match("^([^\t]+)\t(.*)$")
    if key ~= nil then
      local t = {}
      for n in list:gmatch("%d+") do t[#t + 1] = n end
      pages[key] = t
    end
  end
  f:close()
  return pages
end

local GROUPS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "regulation", "Regulations" },
  { "rule", "Rules" },
  { "other", "Other Authorities" },
}

-- Sort key: the name (or sort field) without emphasis markers, lower case.
local function sort_key(a)
  local s = stringify(a.sort or a.name or a.cite)
  return (s:gsub("%*", "")):lower()
end

-- The width of a page list in twips, at 12 pt Times New Roman: a digit is 0.5 em, a comma and a space 0.25 em each
-- (typst: measure() of the same text). "passim" (italic, 2.78 em) is narrower than the page column.
local function list_width(s)
  local w = 0
  for ch in s:gmatch(".") do
    if ch:match("%d") then w = w + 120 elseif ch == "," or ch == " " then w = w + 60 else w = w + 120 end
  end
  return w
end

local function toa_section(meta, pages)
  local auth = need(meta, "authorities")
  local x = {}
  -- the heading opens a page after a section break: no space above it (typst drops it at the top of a page)
  x[#x + 1] = line(T("TABLE OF AUTHORITIES", { b = true }), { jc = "center", keep = true, after = 240, outline = 0 })
  x[#x + 1] = line(T("Page(s)", { b = true }), { jc = "right", keep = true })
  for _, g in ipairs(GROUPS) do
    local kind, label = g[1], g[2]
    local keys = {}
    for k, a in pairs(auth) do
      if stringify(a.kind) == kind then keys[#keys + 1] = k end
    end
    if #keys > 0 then
      if kind == "case" then
        table.sort(keys, function(p, q) return sort_key(auth[p]) < sort_key(auth[q]) end)
      else
        table.sort(keys)
      end
      x[#x + 1] = line(T(label, { b = true }), { keep = true, before = 276 })
      for _, k in ipairs(keys) do
        local list = { "0" }
        if pages then list = pages[k] or {} end
        if #list > 0 then
          local shown, sx
          if #list >= PASSIM then
            shown, sx = T("passim", { i = true }), 0
          else
            local s = table.concat(list, ", ")
            shown, sx = T(s), list_width(s)
          end
          local a = auth[k]
          local head = ""
          if a.name ~= nil then head = I(a.name) .. T(", ") end
          x[#x + 1] = line(head .. I(a.cite) .. T(xe.LEAD) .. shown, { lines = true, before = 204,
            tabs = xe.leader_tab(TEXT_WIDTH), left = TOA_HANG, hanging = TOA_HANG, right = math.max(TOA_COL, sx) })
        end
      end
    end
  end
  x[#x + 1] = section_end("lowerRoman", false)
  return xe.raw(table.concat(x))
end

-- ---------------------------------------------------------------------------
-- Headings, signature block and certificate of service
-- ---------------------------------------------------------------------------

-- Level 1 centered bold; level 2 bold, hanging a half inch; level 3 bold italic, hanging an inch. Single-spaced.
local HEAD = {
  [1] = { before = 336, after = 240, jc = "center", rpr = { b = true } },
  [2] = { before = 264, after = 240, hang = 720, rpr = { b = true } },
  [3] = { before = 240, after = 216, hang = 1440, rpr = { b = true, i = true } },
}
local function heading(b, first)
  local h = HEAD[b.level] or HEAD[3]
  return xe.raw(line(I(b.content, h.rpr), { keep = true, before = first and 0 or h.before, after = h.after,
    jc = h.jc, left = h.hang or 0, hanging = h.hang, outline = b.level - 1 }))
end

-- Signature block (37 CFR 2.193(c): the electronic signature is "s/Name"), at 3 in., 19.2 pt below the text.
local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = line(I(sig.party), { keep = true, left = SIG_LEFT, before = 384 })
  out[#out + 1] = line(T("By its attorneys,"), { keep = true, left = SIG_LEFT })
  out[#out + 1] = line(T("s/" .. stringify(sig.signer)), { keep = true, left = SIG_LEFT, before = 288 })
  for k, l in ipairs(sig.lines) do
    out[#out + 1] = line(I(l), { keep = k < #sig.lines, lines = true, left = SIG_LEFT })
  end
  return xe.raw(table.concat(out))
end

-- Certificate of service (37 CFR 2.119(a), (b)): its own page; the date and the manner of service; "s/Name".
local function certificate(meta)
  local c = need(meta, "service")
  local out = {}
  out[#out + 1] = xe.para({ xe.KEEP, xe.BREAK, xe.spacing(0, 336, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
    T("CERTIFICATE OF SERVICE", { b = true }))
  out[#out + 1] = line(T("I hereby certify that a true and correct copy of the foregoing ") .. I(need(meta, "brief_title")) ..
    T(" was filed electronically and served on this ") .. I(c.date) .. T(", via email to:"), { line = DOUBLE, first = INDENT })
  for k, r in ipairs(c.recipients) do
    out[#out + 1] = line(I(r), { left = INDENT, before = (k == 1) and 144 or 0 })
  end
  out[#out + 1] = line(T("s/" .. stringify(c.signer)), { keep = true, left = SIG_LEFT, before = 480 })
  out[#out + 1] = line(T(stringify(c.signer)), { left = SIG_LEFT })
  return xe.raw(table.concat(out))
end

-- ---------------------------------------------------------------------------
-- Links to authorities: recorded for the first pass, shown as their text
-- ---------------------------------------------------------------------------

local used_keys = {}
local search_path = os.getenv("TTAB_TOA_SEARCH")

-- The first 30 characters of the link text: enough to find the citation's start on a page.
local function needle_of(s)
  s = s:gsub("\u{00A0}", " ")
  local cut = utf8.offset(s, 31)
  if cut then return s:sub(1, cut - 1) end
  return s
end

function Link(el)
  local target = el.target
  if target:sub(1, 4) ~= "toa:" then return nil end
  local key = target:sub(5)
  used_keys[#used_keys + 1] = key
  if search_path ~= nil then
    local f = io.open(search_path, "a")
    if f ~= nil then
      f:write(key .. "\t" .. needle_of(stringify(el)) .. "\n")
      f:close()
    end
  end
  return el.content
end

-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local auth = need(meta, "authorities")
  for _, key in ipairs(used_keys) do
    if auth[key] == nil then error("ttab-trial-brief.lua: `" .. key .. "` is not in authorities") end
  end
  doc = doc:walk({ Inlines = xe.inlines })
  local pages = read_pages()
  local blocks = pandoc.List({ caption_page(meta), toa_section(meta, pages) })
  local n = #doc.blocks
  -- the last paragraph is kept with the signature block (typst: one unbreakable block)
  local last = n
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      blocks:insert(heading(b, i == 1))
    elseif i == last and b.t == "Para" then
      blocks:insert(xe.raw(xe.para({ xe.KEEP, xe.spacing(0, 0, DOUBLE), xe.ind(0, nil, INDENT) }, I(b.content))))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      blocks:extend(xe.list_items(b))
    else
      blocks:insert(b)
    end
  end
  blocks:insert(signature(meta))
  blocks:insert(certificate(meta))
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

-- N.Y. Supreme Court verified complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it
-- reads and breaks as typst/nysupct-complaint.typ does: the caption (court, county, the bordered party box with
-- "-against-" between the sides, the index number and the title at its right; 22 NYCRR 202.5(a)), the table of
-- contents (levels 1 and 2, with page numbers), the body (headings, paragraphs, quotations, lists, footnotes), the
-- signature block (CPLR 2101(a)), the service list and the verification on a page of its own (CPLR 3020(a), 2106).
-- Every case-specific word comes from the sample's frontmatter and body, never from this file. Font and paragraph
-- styles are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run. A paragraph that anchors a footnote stays a
-- pandoc paragraph (style Body Text Note, without widow control: typst may leave its last line alone).
--
-- The contents' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this
-- filter writes ($FORMBOOK_NEEDLES: the court line, the first body paragraph, each heading with the words after it,
-- in document order) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst gap: a blank double line
local HGAP = 240                         -- typst heading-gap 12 pt
local INDENT = 720                       -- typst para-indent 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_BOX, CAP_GUTTER = 5184, 288    -- typst caption-box 3.6 in, caption-gutter 0.2 in
local QUOTE = 720                        -- typst quote-indent 0.5 in
local TOC_INDENT, TOC_HANG, TOC_COL = 576, 576, 720 -- typst toc-indent 0.4 in, toc-hang 0.4 in, toc-col 0.5 in
local SIG = 4608                         -- typst sig-col 3.2 in
local RULE_SHORT = 864                   -- typst rule-short 0.6 in
local TOC_DEPTH = 2
local NEEDLE_MAX = 60

-- The section: letter page, one-inch margins (22 NYCRR 202.5(a)); the page number centered on every page in a
-- 13.8 pt line whose box ends 0.5 in above the page edge (typst footer-distance).
local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:jc w:val="center"/>'
  .. '</w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText>'
  .. '</w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/>'
  .. '</w:r></w:p>'
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrNy"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

local function fail(msg) error("nysupct-complaint: " .. msg, 0) end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
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

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("63(12)(a)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
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

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide. A doubled
-- sign stays with its number ("§§ 63": typst binds it with a box).
local function bind(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    local a = l[i]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs, border }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.border then
    props[#props + 1] = '<w:pBdr><w:' .. o.border .. ' w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>'
  end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

local function line(xml, o)
  return { xml = xml, o = o }
end

-- Single-spaced lines (typst line-stack): each item a line() or "" (a blank single line). `o.keep`: every line kept
-- with the next (typst: an unbreakable block); `o.above`: the space above the first.
local function stack(lines, o)
  o = o or {}
  local out = {}
  for k, l in ipairs(lines) do
    local po = {}
    if l ~= "" then for key, v in pairs(l.o or {}) do po[key] = v end end
    po.before = k == 1 and (o.above or 0) or 0
    if o.keep and k < #lines then po.keep = true end
    out[#out + 1] = p(l == "" and "" or l.xml, po)
  end
  if #out == 0 then out[1] = p("") end
  return table.concat(out)
end

-- A one-row table with fixed column widths; cells = { { xml, tcpr } }; the row is not split across pages.
local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i][2] or "") .. '</w:tcPr>'
      .. cells[i][1] .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
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

local function has_note(b)
  local found = false
  pandoc.Blocks({ b }):walk({ Note = function() found = true end })
  return found
end

-- ---------------------------------------------------------------------------
-- Caption: court, county, the party box and the right column (typst caption-block)
-- ---------------------------------------------------------------------------

local function caption(m)
  local out = { stack({
    line(xe.runs("SUPREME COURT OF THE STATE OF NEW YORK", { b = true }), { jc = "center" }),
    line(xe.inl(m.county, { b = true })),
  }) }
  local left = { "" }
  for i, g in ipairs(items(m.parties)) do
    if i > 1 then
      left[#left + 1] = ""
      left[#left + 1] = line(xe.runs("-against-", { i = true }), { jc = "center" })
      left[#left + 1] = ""
    end
    for _, n in ipairs(items(g.names)) do
      left[#left + 1] = line(xe.inl(n), { left = CAP_GUTTER, right = CAP_GUTTER })
    end
    left[#left + 1] = ""
    left[#left + 1] = line(xe.inl(g.designation), { right = CAP_GUTTER, jc = "right" })
  end
  left[#left + 1] = ""
  local right = { "", line(xe.inl(m.index_no)) }
  if m.judge then right[#right + 1] = line(xe.inl(m.judge)) end
  if m.motion_seq then right[#right + 1] = line(xe.inl(m.motion_seq)) end
  right[#right + 1] = ""
  right[#right + 1] = ""
  right[#right + 1] = line(xe.inl(m.title, { b = true }))
  local rule = '<w:tcBorders><w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  -- typst: the caption block 12 pt below the county line (Word has no space before a table: an empty paragraph)
  out[#out + 1] = p("", { line = HGAP })
  out[#out + 1] = table_xml({ CAP_BOX, TEXTW - CAP_BOX }, {
    { stack(left), rule },
    { stack(right), '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>' },
  })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Table of contents (typst toc-section)
-- ---------------------------------------------------------------------------

local function toc(entries)
  local out = { p(xe.runs("TABLE OF CONTENTS", { b = true }), { before = GAP, after = HGAP, keep = true, jc = "center" }) }
  for _, e in ipairs(entries) do
    if e.level <= TOC_DEPTH then
      local ind = (e.level - 1) * TOC_INDENT
      local tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
      out[#out + 1] = p(xe.inl(e.title) .. xe.runs(xe.LEAD) .. xe.runs(labels[e.id] or "0"),
        { lines = true, tabs = tabs, left = ind + TOC_HANG, hanging = TOC_HANG, right = TOC_COL })
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body blocks
-- ---------------------------------------------------------------------------

local function heading(b, pre)
  local lv = b.level
  local o = { before = HGAP, after = HGAP, keep = true, pre = pre }
  if lv == 1 then
    o.jc = "center"
    return p(xe.inl(b.content, { b = true }), o)
  end
  return p(xe.inl(b.content, { b = true, i = lv >= 3 }), o)
end

-- A body block as Word paragraphs: a paragraph on the body pitch, its first line indented (one with a footnote stays
-- a pandoc paragraph), a quotation single-spaced and indented on both sides, a list's items with the label half an
-- inch in and the text an inch in.
local function body_block(b, out, pre)
  if b.t == "Para" or b.t == "Plain" then
    if has_note(b) then
      local blocks = { pandoc.Para(b.content) }
      if pre then out[#out + 1] = xe.raw(p("", { pre = pre, line = 20 })) end
      out[#out + 1] = pandoc.Div(blocks, { ["custom-style"] = "Body Text Note" })
    else
      out[#out + 1] = xe.raw(p(xe.inl(b.content), { line = BODY, first = INDENT, pre = pre }))
    end
  elseif b.t == "Header" then
    out[#out + 1] = xe.raw(heading(b, pre))
  elseif b.t == "BlockQuote" then
    for k, q in ipairs(b.content) do
      if q.t ~= "Para" and q.t ~= "Plain" then fail("unsupported block in a quotation: " .. q.t) end
      out[#out + 1] = xe.raw(p(xe.inl(q.content), { left = QUOTE, right = QUOTE, pre = k == 1 and pre or nil,
        before = k == 1 and HGAP or 0, after = k == #b.content and HGAP or 0 }))
    end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    local n = b.t == "OrderedList" and b.listAttributes.start or 1
    for k, item in ipairs(b.content) do
      if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then fail("unsupported list item (one paragraph each)") end
      local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
      out[#out + 1] = xe.raw(p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = 2 * INDENT,
        hanging = INDENT, pre = k == 1 and pre or nil,
        tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' }))
      n = n + 1
    end
  else
    fail("unsupported block " .. b.t)
  end
end

-- ---------------------------------------------------------------------------
-- Signature block, service list, verification
-- ---------------------------------------------------------------------------

local function dated(m)
  if m.place then
    return { line(xe.runs("Dated:")), line(xe.inl(m.place)), line(xe.inl(m.date)) }
  end
  return { line(xe.runs("Dated: ") .. xe.inl(m.date)) }
end

local function signature(m)
  local sig = m.signature or {}
  local right = { line(xe.runs("Respectfully submitted,")), "" }
  if sig.firm then
    for _, l in ipairs(items(sig.firm)) do right[#right + 1] = line(xe.inl(l)) end
    right[#right + 1] = ""
  end
  right[#right + 1] = line(xe.runs("By:"), { border = "bottom", right = RULE_SHORT })
  right[#right + 1] = line(xe.inl(sig.signer))
  for _, l in ipairs(items(sig.lines)) do right[#right + 1] = line(xe.inl(l, { i = true })) end
  -- the blank double line above is the block's own (typst: above gap)
  return p("", { line = GAP, keep = true })
    .. table_xml({ TEXTW - SIG, SIG }, { { stack(dated(m)) }, { stack(right) } })
end

local function service(m)
  if m.to == nil then return "" end
  local ls = { line(xe.runs("To:")) }
  for _, g in ipairs(items(m.to)) do
    ls[#ls + 1] = ""
    for _, n in ipairs(items(g.names)) do ls[#ls + 1] = line(xe.inl(n)) end
    for _, l in ipairs(items(g.lines)) do ls[#ls + 1] = line(xe.inl(l, { i = true })) end
  end
  return stack(ls, { above = GAP, keep = true })
end

local function verification(m)
  local v = m.verification or {}
  local text = xe.inl(v.verifier) .. xe.runs(", ") .. xe.inl(v.capacity)
    .. xe.runs(", affirms under the penalties of perjury under the laws of New York, which may include a fine or "
      .. "imprisonment, that the foregoing ") .. xe.inl(m.title)
    .. xe.runs(" is true to the knowledge of the affirmant, except as to matters alleged on information and belief, "
      .. "and as to those matters the affirmant believes them to be true. The affirmant understands that this document "
      .. "may be filed in an action or proceeding in a court of law.")
  return p(xe.runs("VERIFICATION", { b = true }), { pre = xe.BREAK, after = GAP, keep = true, jc = "center" })
    .. p(text, { line = BODY, first = INDENT })
    .. stack({ line(xe.runs("Dated: ") .. xe.inl(m.date)), "", "" }, { above = GAP, keep = true })
    .. table_xml({ TEXTW - SIG, SIG }, { { p("") }, { stack({ line(xe.inl(v.verifier), { border = "top" }) }) } })
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "county", "index_no", "parties", "title", "date", "signature", "verification" }) do
    if m[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  end
  local with_toc = m.toc == true

  needle("S:start", "B", "SUPREME COURT OF THE STATE OF NEW YORK", plain(m.county))
  local entries, body = {}, {}
  for i, b in ipairs(doc.blocks) do
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if i == 1 and b.t ~= "Header" then needle("S:body", "B", stringify(b):sub(1, 40), nxt) end
    if b.t == "Header" then
      local id = "H:" .. (#entries + 1)
      needle(id, "B", stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = b.level, title = b.content }
    end
    -- the body starts on a new page after the contents, a blank double line under the caption without them
    local pre = (i == 1 and with_toc) and xe.BREAK or nil
    if i == 1 and not with_toc then body[#body + 1] = xe.raw(p("", { line = GAP })) end
    body_block(b, body, pre)
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:start\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrNy\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", SECT)

  local out = { xe.raw(caption(m) .. (with_toc and toc(entries) or "")) }
  for _, x in ipairs(body) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m) .. service(m) .. verification(m))
  local blocks = pandoc.Blocks(out):walk({ Link = function(el) return el.content end }):walk({ Inlines = xe.inlines })
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top.
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

-- uscfc-motion-brief.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads and breaks
-- as typst/uscfc-motion-brief.typ does (README "Engines"): the cover (caption, title, counsel), the table of contents
-- and table of authorities (front matter, roman), the numbered headings (I., A., 1., a., (1)), the links to
-- authorities (toa:KEY), the signature block and the certificate of service (body, arabic from 1).
-- The page numbers in the table of contents and authorities are measured on a build of this file: fb render
-- (tools/fb/src/docxpass.rs) renders it, finds the page of each heading and each authority link in the PDF (the
-- needles this file writes to FORMBOOK_NEEDLES; contract in tools/fb/src/docxpages.rs), and this file prints them
-- again with the page numbers (FORMBOOK_PAGES) until they settle; the body is then held to RCFC 5.4(b)(1) (were
-- docx/render.sh and its measure). The styles: docx/reference.xml. Nothing here is a case's text or a measured
-- coordinate.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. A paragraph that opens a
-- page (a section start or a page break) carries no space above it: typst drops it there, Word would keep it.

local xe = require("docx.xengine")


local BODY, SINGLE = 552, 276          -- typst pitch-double, pitch-single
local GAP = 552                        -- typst cover-gap
local INDENT, TAB_W = 720, 720         -- typst para-indent, heading-tab
local TEXTW = 9360                     -- 6.5 in
local TOC_COL, TOA_COL = 720, 1120     -- typst toc-page-col 36 pt, toa-page-col 56 pt
local TOA_HANG = 504                   -- typst 0.35 in
local CAP = { 4896, 504 }              -- typst caption-cols 3.4 in, 0.35 in
local ROLE = 2304                      -- typst role-indent 1.6 in
local TAB = "<w:r><w:tab/></w:r>"
-- The empty paragraph that ends a Word section: a 1 pt line, so it never pushes a line of the page on.
local SECT_LINE = xe.spacing(0, 0, 20)
local SECT_PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="432" w:gutter="0"/>'

local function need(meta, key)
  if meta[key] == nil then error("uscfc-motion-brief.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function flag(m)
  return m == true
end

-- A paragraph: o = { before, after, line, left, hang, first, right, jc, keep, keepnext, brk, tabs, sect }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.keepnext then props[#props + 1] = "<w:keepNext/>" end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hang, o.hang == nil and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.sect then props[#props + 1] = o.sect end
  return xe.para(props, body)
end

local function tbl(widths, rows, trpr)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. table.concat(c) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- The signer over a rule to the end of the column (typst `signed`: the rule takes no room of its own).
local function signed(name, col, before)
  return p(xe.runs("/s/ " .. name, { u = true }) .. xe.runs("\t", { u = true }),
    { tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. col .. '"/></w:tabs>', before = before, keepnext = true })
end

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render's multi-pass build): the labels of the previous build, id -> label; none on the first
-- ---------------------------------------------------------------------------

local LABELS, HAVE_PAGES = {}, false
do
  local path = os.getenv("FORMBOOK_PAGES")
  local fh = path and path ~= "" and io.open(path, "r")
  if fh then
    HAVE_PAGES = true
    for line in fh:lines() do
      local id, _, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
      if id then LABELS[id] = lab end
    end
    fh:close()
  end
end

local NEEDLE_MAX = 60 -- a needle is a prefix of the text (letters and digits only)

-- letters and digits only, lower case: fb render normalizes the PDF text the same way
local function key_norm(t)
  return (t:lower():gsub("[^a-z0-9]", ""))
end

-- a needle: id, kind B (body, in document order: moves the search on) or N (inside a footnote: searched from the
-- page the body has reached, moves nothing), the text and the words after it; the fallback is the text alone
local NEEDLES = {}
local function need_at(id, kind, t, context)
  local short = key_norm(t):sub(1, NEEDLE_MAX)
  local long = key_norm(t .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  NEEDLES[#NEEDLES + 1] = table.concat({ id, kind, long, short }, "\t")
end

local function write_file(env, t)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local fh = assert(io.open(path, "w"))
  fh:write(t)
  fh:close()
end

-- ---------------------------------------------------------------------------
-- Headings: the numbering of the typst template (I. / A. / 1. / a. / (1))
-- ---------------------------------------------------------------------------

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function label(level, n)
  if level == 1 then return roman(n) .. "." end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

local function upper(inlines)
  return inlines:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local counts = { 0, 0, 0, 0, 0, 0 }
local HEADINGS = {}   -- { index, level, label, content (inlines) }
local LINKED = {}     -- authority keys linked in the body
local OCC = {}        -- every authority link in the body, in document order: { key, id } (its needle's id)
local BLOCKS = {}     -- each top-level block of the body: { header, cites = { kind, key, text, context }, lead }

-- The pages of an authority's links, in order, each once ("3,5,8"), for the table of authorities.
local function auth_pages(key)
  local ls, got = {}, {}
  for _, o in ipairs(OCC) do
    local l = LABELS[o.id]
    if o.key == key and l and not got[l] then got[l] = true; ls[#ls + 1] = l end
  end
  return table.concat(ls, ",")
end

-- A section heading: bold capitals, centered (typst section-above, section-below); a sub-heading: its label in a
-- half-inch box at its level's indent, the text hanging after it, bold (bold italic from level 4), a single line
-- above and below. The first heading of the body opens its page: no space above it.
local function heading_para(level, lab, content, before)
  if level == 1 then
    local il = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
    il:extend(upper(content))
    return p(xe.inl(il, { b = true }), { keep = true, jc = "center", before = before or BODY, after = SINGLE })
  end
  local ind = (level - 1) * TAB_W
  local f = { b = true, i = level >= 4 }
  return p(xe.runs(lab, f) .. TAB .. xe.inl(content, f),
    { keep = true, left = ind + TAB_W, hang = TAB_W, before = before or SINGLE, after = SINGLE })
end

local function Header(el)
  if el.level > 5 then error("uscfc-motion-brief.lua: headings deeper than level 5 are not supported") end
  counts[el.level] = counts[el.level] + 1
  for k = el.level + 1, 6 do counts[k] = 0 end
  local idx = #HEADINGS + 1
  local lab = label(el.level, counts[el.level])
  HEADINGS[idx] = { index = idx, level = el.level, label = lab, content = el.content }
  return xe.raw(heading_para(el.level, lab, el.content, idx == 1 and 0 or nil))
end

-- Authority links: [*Full cite*](toa:KEY). The text is shown as is. Each link is a needle (scan): its text and the
-- words after it, so that a heading or a sentence that names the same authority without a link is not counted (typst
-- counts the links only).
local function Links(il)
  local out = pandoc.Inlines({})
  for _, el in ipairs(il) do
    if el.t == "Link" and el.target:sub(1, 4) == "toa:" then
      LINKED[el.target:sub(5)] = true
      out:extend(el.content)
    else
      out:insert(el)
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover (RCFC 10(a), 5.5(h) bid protest, 5.5(g) judge; 5.5(f) counsel)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local bid = flag(meta.bid_protest)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES COURT OF FEDERAL CLAIMS", { b = true }), { jc = "center" })
  if bid then out[#out + 1] = p(xe.runs("BID PROTEST", { b = true }), { jc = "center" }) end
  -- Caption rows (typst caption-rows): each party's name, its role stepped in, an empty row; a ")" on every row;
  -- the case number and the judge on the two rows at the middle.
  local rows = {}
  for _, pt in ipairs(need(meta, "parties")) do
    if pt.name ~= nil then rows[#rows + 1] = { xe.inl(pt.name), 0 } end
    if pt.role ~= nil then rows[#rows + 1] = { xe.inl(pt.role), ROLE } end
    if pt.name == nil and pt.role == nil then rows[#rows + 1] = { "", 0 } end
    rows[#rows + 1] = { "", 0 }
  end
  local mid = math.max(0, #rows // 2 - 1)
  local trs = {}
  for i, r in ipairs(rows) do
    local right = ""
    if i - 1 == mid then right = xe.runs("Case No. " .. plain(need(meta, "case_number")))
    elseif i - 1 == mid + 1 then right = xe.inl(need(meta, "judge")) end
    local before = i == 1 and GAP or 0
    trs[#trs + 1] = { { p(r[1], { left = r[2], before = before }) }, { p(xe.runs(")"), { jc = "center", before = before }) },
      { p(right, { before = before }) } }
  end
  out[#out + 1] = tbl({ CAP[1], CAP[2], TEXTW - CAP[1] - CAP[2] }, trs)
  out[#out + 1] = p(xe.runs(plain(need(meta, "brief_title")):upper(), { b = true }), { jc = "center", before = GAP })
  -- Counsel groups side by side (RCFC 5.5(f): the attorney of record's e-mail and telephone number).
  local groups = need(meta, "counsel")
  local width = TEXTW // #groups
  local widths, cells = {}, {}
  for gi, g in ipairs(groups) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = p(xe.inl(n), { before = #lines == 0 and GAP or 0 }) end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = p(xe.inl(l, { i = true }), { before = #lines == 0 and GAP or 0 }) end
    widths[gi] = gi == #groups and TEXTW - width * (#groups - 1) or width
    cells[gi] = lines
  end
  out[#out + 1] = tbl(widths, { cells })
  return out
end

-- The paragraph that ends a section: the cover has no page number, the front matter is roman from i (the body's own
-- section, arabic from 1, is the last: FORMBOOK_FINAL).
local function section_break(fmt)
  local footer = fmt == "none" and "" or '<w:footerReference w:type="default" r:id="rIdFooter1"/>'
  local numfmt = fmt == "none" and "decimal" or fmt
  local sect = "<w:sectPr>" .. footer .. SECT_PG .. '<w:pgNumType w:fmt="' .. numfmt .. '" w:start="1"/></w:sectPr>'
  return xe.para({ SECT_LINE, sect }, "")
end

-- ---------------------------------------------------------------------------
-- Table of contents and table of authorities (RCFC 5.4(a)(2)(A)-(B))
-- ---------------------------------------------------------------------------

-- A row (typst listing-row): the text wraps before the page column (a right indent), a dot leader from three spaces
-- after it to the page number at the margin.
local function row(body, page, col, left, hang, before)
  return p(body .. xe.runs(xe.LEAD) .. page,
    { tabs = xe.leader_tab(TEXTW), keep = false, left = left, hang = hang, right = col, before = before })
end

local function toc()
  local out = {}
  out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { keep = true, jc = "center", after = SINGLE })
  out[#out + 1] = p(xe.runs("Page", { b = true, u = true }), { keepnext = true, jc = "right" })
  for _, h in ipairs(HEADINGS) do
    local ind = h.level >= 2 and (h.level - 1) * TAB_W or 0
    local page = LABELS["H:" .. h.index] or "0"
    local title = h.level == 1 and upper(h.content) or h.content
    out[#out + 1] = row(xe.runs(h.label) .. TAB .. xe.inl(title), xe.runs(page), TOC_COL, ind + TAB_W, TAB_W,
      h.level == 1 and 180 or 80)
  end
  return out
end

local function toa(meta)
  local authorities = meta.authorities or {}
  for key, _ in pairs(LINKED) do
    if authorities[key] == nil then
      error("uscfc-motion-brief.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  local groups = {
    { "case", "Cases:" }, { "statute", "Statutes:" }, { "regulation", "Regulations:" },
    { "rule", "Rules:" }, { "other", "Other Authorities:" },
  }
  local out = {}
  out[#out + 1] = p(xe.runs("TABLE OF AUTHORITIES", { b = true }), { keep = true, brk = true, jc = "center", after = SINGLE })
  local first = true
  for _, g in ipairs(groups) do
    local members = {}
    for key, a in pairs(authorities) do
      if plain(a.kind) == g[1] and HAVE_PAGES and LINKED[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      local function sk(key)
        local a = authorities[key]
        local s = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
        return s:lower():gsub("[^a-z0-9 ]", "")
      end
      table.sort(members, function(x, y) return sk(x) < sk(y) end)
      local head = xe.runs(g[2], { b = true })
      if first then head = head .. TAB .. xe.runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = p(head, { keep = true, tabs = first and '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>' or nil,
        before = first and 0 or BODY, after = 80 })
      first = false
      for _, key in ipairs(members) do
        local a = authorities[key]
        local pages = auth_pages(key)
        local n = 0
        for _ in pages:gmatch("[^,]+") do n = n + 1 end
        local text = pages:gsub(",", ", ")
        local shown = n >= 7 and xe.runs("passim", { i = true }) or xe.runs(text)
        -- the page column: 56 pt, or the page list's own width when longer (digits, commas, spaces: 6 pt or less)
        local col = math.max(TOA_COL, #text * 120)
        local lead = ""
        if a.name ~= nil then
          lead = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(",") .. xe.BR
        end
        out[#out + 1] = row(lead .. xe.inl(a.cite), shown, col, TOA_HANG, TOA_HANG, 200)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (RCFC 5.5(e), 5.5(f), 5.3)
-- ---------------------------------------------------------------------------

local HALF = TEXTW // 2

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = p(xe.runs("Dated: " .. plain(need(meta, "date"))), { keepnext = true, before = BODY })
  local right = {
    p(xe.runs("Respectfully submitted,"), { keepnext = true, before = SINGLE }),
    signed(plain(need(sig, "signer")), HALF, BODY),
    p(xe.runs(plain(sig.signer)), { keepnext = true }),
    p(xe.runs("Phone: " .. plain(need(meta, "phone"))), { keepnext = true }),
    p(xe.runs("Email: " .. plain(need(meta, "email"))), { keepnext = true }),
  }
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l, { i = true }), { keepnext = true }) end
  out[#out + 1] = tbl({ HALF, TEXTW - HALF }, { { { p("", { before = SINGLE }) }, right } }, '<w:trPr><w:cantSplit/></w:trPr>')
  return out
end

local function certificate(meta)
  local svc = need(meta, "service")
  local out = {}
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { keep = true, brk = true, jc = "center", after = SINGLE })
  out[#out + 1] = p(xe.runs("I hereby certify that on this " .. plain(need(svc, "day")) .. ", I caused a true and correct copy of the foregoing ") ..
    xe.inl(svc.documents) .. xe.runs(" to be served by " .. plain(need(svc, "manner")) .. " on:"),
    { line = BODY, first = INDENT })
  for _, r in ipairs(need(svc, "recipients")) do
    for i, l in ipairs(r.lines) do
      out[#out + 1] = p(xe.inl(l), { left = 720, before = i == 1 and SINGLE or 0, keepnext = i < #r.lines })
    end
  end
  out[#out + 1] = tbl({ HALF, TEXTW - HALF }, { { { p("", { before = BODY }) },
    { signed(plain(need(need(meta, "signature"), "signer")), HALF, BODY) } } }, '<w:trPr><w:cantSplit/></w:trPr>')
  return out
end

-- ---------------------------------------------------------------------------
-- Document
-- ---------------------------------------------------------------------------

-- The body as written, block by block (before the filters below change it): its headings, its authority links (kind
-- B in the text, N in a footnote; the link text and the words after it, up to a footnote, a quotation or another
-- link) and the text each block starts with, as printed (a footnote's text stops at its mark).
local function scan(doc)
  local function lead_text(b)
    local d = pandoc.Pandoc({ b }):walk({ Note = function() return pandoc.Str("\1") end })
    return (pandoc.utils.stringify(d):match("^[^\1]*"))
  end
  local scan_blocks
  local function scan_inlines(il, kind, list)
    for k, el in ipairs(il) do
      if el.t == "Link" and el.target:sub(1, 4) == "toa:" then
        local rest = {}
        for j = k + 1, math.min(#il, k + 12) do
          local t = il[j].t
          if t == "Note" or t == "Quoted" or t == "Link" then break end
          rest[#rest + 1] = il[j]
        end
        list[#list + 1] = { kind = kind, key = el.target:sub(5), text = pandoc.utils.stringify(el.content),
          context = pandoc.utils.stringify(pandoc.Inlines(rest)) }
      elseif el.t == "Note" then
        scan_blocks(el.content, "N", list)
      elseif el.content ~= nil and type(el.content) == "table" and el.t ~= "Code" then
        scan_inlines(el.content, kind, list)
      end
    end
  end
  scan_blocks = function(bs, kind, list)
    for _, b in ipairs(bs) do
      if b.t == "Para" or b.t == "Plain" or b.t == "Header" then scan_inlines(b.content, kind, list)
      elseif b.t == "BlockQuote" or b.t == "Div" then scan_blocks(b.content, kind, list)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, it in ipairs(b.content) do scan_blocks(it, kind, list) end
      end
    end
  end
  for _, b in ipairs(doc.blocks) do
    local cites = {}
    scan_blocks({ b }, "B", cites)
    BLOCKS[#BLOCKS + 1] = { header = b.t == "Header", cites = cites, lead = lead_text(b):sub(1, 40) }
  end
end

-- The needles, in document order: each heading (its label and title and the text after it, so the same words
-- earlier on the page are not taken for it), each link, then the certificate of service and its signature (the
-- last page). Sections: the body from its first block, arabic from 1.
local function write_needles(meta)
  local h, pending, first = 0, nil, nil
  local function cites(bl)
    for _, c in ipairs(bl.cites) do
      OCC[#OCC + 1] = { key = c.key, id = "T:" .. (#OCC + 1) }
      need_at(OCC[#OCC].id, c.kind, c.text, c.context)
    end
  end
  local function flush(next_text)
    if pending then
      need_at(pending.id, "B", pending.text, next_text)
      cites(pending.bl)
      pending = nil
    end
  end
  for bi, bl in ipairs(BLOCKS) do
    if bl.header then
      h = h + 1
      local hd = HEADINGS[h]
      local shown = hd.label .. " " .. pandoc.utils.stringify(hd.content)
      flush(shown)
      pending = { id = "H:" .. h, text = shown, bl = bl }
      first = first or "H:" .. h
    else
      flush(bl.lead)
      if bi == 1 then
        need_at("S:body", "B", bl.lead, "")
        first = "S:body"
      end
      cites(bl)
    end
  end
  flush("")
  need_at("S:cert", "B", "Certificate of Service", "I hereby certify")
  need_at("S:end", "B", "/s/ " .. plain(need(need(meta, "signature"), "signer")), "")
  write_file("FORMBOOK_NEEDLES", table.concat(NEEDLES, "\n") .. "\n#section\t" .. (first or "S:cert") .. "\tdecimal\t\n")  -- the body's section (the last): arabic from 1, the reference's page-number footer
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/>' .. SECT_PG
    .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>')
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14):
--   * none inside a token of adjacent parentheses ("2304a(d)(4)"; lib/typst/xengine.typ boxes it; UAX #14 would allow
--     a break before each "("): a word joiner (U+2060) between ")" and "(";
--   * one after a slash that is followed by a letter (a URL: ".../blogs/policy/..."), where LibreOffice keeps the
--     URL whole: a zero-width space (U+200B) after it. A slash before a digit ("2/4/19") stays unbreakable in both.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function finish(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "judge", "parties", "brief_title", "counsel", "phone", "email", "signature", "date", "service" }) do
    need(meta, k)
  end

  write_needles(meta)
  -- Front matter: cover (no number), then the table of contents and authorities (roman), single spaced.
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = xe.raw(b) end
  blocks[#blocks + 1] = xe.raw(section_break("none"))
  for _, b in ipairs(toc()) do blocks[#blocks + 1] = xe.raw(b) end
  for _, b in ipairs(toa(meta)) do blocks[#blocks + 1] = xe.raw(b) end
  blocks[#blocks + 1] = xe.raw(section_break("lowerRoman"))

  -- Body (arabic from 1). The break rules of typst on every run pandoc writes itself.
  local body = doc.blocks:walk({ Inlines = xe.inlines })
  -- The signature block never stands alone: the last paragraph is kept with it.
  if #body > 0 and body[#body].t == "Para" then
    local last = body[#body]
    body[#body] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "Keep With Next" }))
  end
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = xe.raw(b) end
  for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = xe.raw(b) end

  -- The body fits the page limit (RCFC 5.4(b)(1): 40 pages, 50 for a cross-motion, counting the body and the
  -- certificate): its last page is the certificate's signature.
  if HAVE_PAGES then
    local limit = meta.cross_motion == true and 50 or 40
    local pages = tonumber(LABELS["S:end"] or "")
    if pages and pages > limit then
      error("uscfc-motion-brief.lua: the body runs " .. pages .. " pages; RCFC 5.4(b)(1) allows " .. limit
        .. " without leave of court")
    end
  end

  doc.blocks = blocks
  -- pandoc would print title and date above the body; the cover carries them.
  doc.meta.title = nil
  doc.meta.date = nil
  doc.meta.author = nil
  return doc
end

return { { Pandoc = scan }, { Inlines = Links }, { Str = break_rules }, { Header = Header }, { Pandoc = finish } }

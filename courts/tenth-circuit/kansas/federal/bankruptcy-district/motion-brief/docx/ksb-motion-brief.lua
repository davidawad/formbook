-- D. Kan. Bankr. memorandum in support of a motion, docx engine (docs/DOCX.md): the same markdown contract as
-- typst/ksb-motion-brief.typ, and every block written as it sets it: the cover (counsel block, the party represented,
-- the court, the caption with the party column ruled at its right and the case column beside it, the title), the
-- table of contents and the table of authorities (a row per heading or authority, a dot leader to the page in a
-- column of its own), the body (level 1 headings centered capitals; level 2 "A.", level 3 "1.", level 4 "a.", the
-- label in a half-inch box; paragraphs at the double pitch; quotations), the signature block and the certificate of
-- service (LBR 9013.3(a)). Everything printed comes from the sample's frontmatter and body: no case text lives in
-- this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 640 the double-spaced body, 368 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers (were docx/render.sh's two passes and pages.lua): every page numbered from the first, the cover
-- included (LBR 9004.1(a)(2)): one section, its footer fb render's page number (rIdFtrPage, $FORMBOOK_FINAL). The
-- tables' pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- ($FORMBOOK_NEEDLES: the cover's first line, where page 1 starts; then in document order each heading by its label
-- and title and the words after it, and each `toa:` citation by its text and the words after it) in the PDF and
-- passes their pages back ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")

local BODY, SINGLE, HALF = 640, 368, 184               -- typst pitch-double, pitch-single, half-line
local INDENT = 720                                     -- typst para-indent, heading-tab (0.5 in)
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT = 5184                                  -- typst caption-left, 3.6 in
local CAP_PAD, CAP_GAP = 288, 288                      -- typst caption-pad, caption-gap (0.2 in)
local DESIGNATION = 2880                               -- typst designation-indent, 2 in
local SIG = 4752                                       -- typst sig-left, 3.3 in
local TOC_COL, TOA_COL = 720, 1440                     -- typst toc-col (36 pt), toa-col (72 pt)
local TOA_HANG = 504                                   -- typst toa-hang, 0.35 in
local PASSIM = 7                                       -- typst passim-threshold
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
local NEEDLE_MAX = 60
local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" }, { "other", "Other Authorities" },
}

local stringify = pandoc.utils.stringify

-- A paragraph: o = { before, after, line, left, hanging, first, right, tabs, jc, keep, lines, brk }.
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

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("ksb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function upper(x)
  if type(x) == "string" then return pandoc.text.upper(x) end
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

-- The one section: letter page, 1 in margins; the page number centered, its line 645 twips above the page foot
-- (where typst sets its single line box, footer-descent 30 %).
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="645" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: counsel, the party represented, the court, the caption, the title
-- ---------------------------------------------------------------------------

local function caption(meta)
  local debtor = need(meta, "debtor")
  local sides = list(need(meta, "caption"))
  local gap = p("", { line = HALF })
  local left = { p(xe.runs("In re:")), gap }
  local at_debtor = #left + 1
  for _, n in ipairs(list(debtor.names)) do left[#left + 1] = p(xe.inl(n)) end
  left[#left + 1] = p(xe.inl(debtor.designation), { left = DESIGNATION })
  local at_v
  for i, side in ipairs(sides) do
    left[#left + 1] = gap
    if i > 1 then
      at_v = at_v or #left + 1
      left[#left + 1] = p(xe.runs("v."), { jc = "center" })
      left[#left + 1] = gap
    end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
  end
  at_v = at_v or #left
  local right = {}
  for i = 1, #left do right[i] = left[i] == gap and gap or p("") end
  right[at_debtor] = p(xe.inl(need(meta, "bankruptcy_case")))
  right[at_debtor + 1] = p(xe.inl(need(meta, "chapter")))
  right[at_v] = p(meta.adversary_number and xe.inl(meta.adversary_number)
    or xe.runs("Adv. No. " .. string.rep("_", 10)))
  local rows = {}
  for i = 1, #left do
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:right ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. left[i] ..
      '</w:tc><w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' ..
      CAP_GAP .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. right[i] .. '</w:tc></w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>'
end

local function cover(meta)
  local out = {}
  for _, l in ipairs(list(need(meta, "counsel"))) do out[#out + 1] = p(xe.inl(l)) end
  out[#out + 1] = p(xe.inl(need(meta, "counsel_role"), { i = true }), { before = SINGLE })
  local court = list(need(meta, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true, before = i == 1 and SINGLE or 0,
      after = i == #court and SINGLE or 0 })
  end
  out[#out + 1] = caption(meta)
  out[#out + 1] = p(xe.inl(upper(need(meta, "title")), { b = true }), { jc = "center", before = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities: a table's title, a single line below it its column label at the right; a
-- row per entry half a line apart, the text wrapping before the page column, a dot leader to the page (typst
-- listing-row).
-- ---------------------------------------------------------------------------

local function table_title(title, col, brk)
  return {
    p(xe.runs(title, { b = true }), { jc = "center", keep = true, brk = brk }),
    p(xe.runs(col, { b = true }), { jc = "right", keep = true, before = SINGLE }),
  }
end

local function row(text_xml, page, col, left, hanging)
  return p(text_xml .. xe.runs(xe.LEAD) .. page, { lines = true, tabs = xe.leader_tab(TEXTW), before = HALF,
    left = left, hanging = hanging, right = col })
end

local function label_indent(level)
  return math.max(level - 2, 0) * INDENT
end

local function toc(entries)
  local out = table_title("TABLE OF CONTENTS", "Page", true)
  for _, e in ipairs(entries) do
    local page = xe.runs(labels[e.id] or "0")
    local ind = label_indent(e.level)
    if e.level == 1 then
      out[#out + 1] = row(xe.inl(upper(e.title)), page, TOC_COL, ind + INDENT, ind + INDENT)
    else
      out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), page, TOC_COL, ind + INDENT, INDENT)
    end
  end
  return out
end

local function toa(auth, hits)
  local out = table_title("TABLE OF AUTHORITIES", "Page(s)", true)
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and hits[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return auth[x].sort < auth[y].sort end)
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = SINGLE, keep = true })
      for _, key in ipairs(members) do
        local a = auth[key]
        local pages, seen = {}, {}
        for _, id in ipairs(hits[key]) do
          local l = labels[id] or "0"
          if not seen[l] then
            seen[l] = true
            pages[#pages + 1] = l
          end
        end
        local page = #pages >= PASSIM and xe.runs("passim", { i = true }) or xe.runs(table.concat(pages, ", "))
        local text = ""
        if a.name then text = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        text = text .. xe.inl(a.cite)
        out[#out + 1] = row(text, page, TOA_COL, TOA_HANG, TOA_HANG)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service: a column at sig-left a double line below the block before it, the
-- date (if any) at the left margin beside its first line (a hanging indent), single-spaced, kept whole.
-- ---------------------------------------------------------------------------

local function column(lines, date)
  local out = {}
  for k, l in ipairs(lines) do
    local body, before = l[1], k == 1 and BODY or l[2]
    if k == 1 and date then
      out[#out + 1] = p(date .. xe.runs("\t") .. body, { left = SIG, hanging = SIG, before = before, keep = true })
    else
      out[#out + 1] = p(body, { left = SIG, before = before, keep = true })
    end
  end
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return out
end

local function signature(meta)
  local s = need(meta, "signature")
  local lines = {}
  for _, l in ipairs(list(s.preamble)) do lines[#lines + 1] = { xe.inl(l), 0 } end
  lines[#lines + 1] = { xe.runs("/s/ ") .. xe.inl(s.signer), SINGLE }
  lines[#lines + 1] = { xe.inl(s.signer) .. (s.bar and (xe.runs(", ") .. xe.inl(s.bar)) or ""), 0 }
  for _, l in ipairs(list(s.lines)) do lines[#lines + 1] = { xe.inl(l), 0 } end
  if s.role then lines[#lines + 1] = { xe.inl(s.role, { i = true }), SINGLE } end
  return column(lines, xe.runs("Dated: ") .. xe.inl(need(meta, "date")))
end

local function certificate(meta)
  local svc = need(meta, "service")
  local s = need(meta, "signature")
  local out = { p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", keep = true, brk = true,
    after = SINGLE }) }
  out[#out + 1] = p(xe.runs("I hereby certify that on ") .. xe.inl(need(meta, "date")) ..
    xe.runs(", I electronically filed the foregoing ") .. xe.inl(upper(svc.document)) ..
    xe.runs(" with the Clerk of the Court using the CM/ECF system, which will send notice of electronic filing to " ..
      "all counsel of record."), { line = BODY, first = INDENT })
  local lines = { { xe.runs("/s/ ") .. xe.inl(s.signer), 0 }, { xe.inl(svc.signer), 0 } }
  if s.role then lines[#lines + 1] = { xe.inl(s.role, { i = true }), 0 } end
  for _, x in ipairs(column(lines)) do out[#out + 1] = x end
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number, as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function label(level, n)
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return tostring(n) .. "." end
  return string.char(96 + n) .. "."
end

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtor", "bankruptcy_case", "chapter", "caption", "title", "counsel",
    "counsel_role", "date", "signature", "service" }) do
    need(meta, k)
  end
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    local name, cite = a.name and stringify(a.name), stringify(a.cite)
    auth[key] = { kind = stringify(a.kind), name = a.name, cite = a.cite,
      sort = (name or cite):lower() .. "\1" .. cite:lower() .. "\1" .. key }
  end

  -- LBR 9013.1(a)(1)-(4): the four sections must be there
  local found = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      for _, frag in ipairs({ "NATURE", "FACT", "QUESTION", "ARGUMENT" }) do
        if stringify(b.content):find(frag, 1, true) then found[frag] = true end
      end
    end
  end
  for _, frag in ipairs({ "NATURE", "FACT", "QUESTION", "ARGUMENT" }) do
    if not found[frag] then error("ksb-motion-brief: no `# ...` section heading containing `" .. frag ..
      "` (LBR 9013.1(a))", 0) end
  end

  needle("S:cover", stringify(list(meta.counsel)[1]), stringify(list(meta.counsel)[2] or ""))

  -- authority links: the text stays, each one a needle in document order
  local hits, nhits = {}, 0
  local function cite_links(inlines)
    local out = pandoc.Inlines({})
    for i, el in ipairs(inlines) do
      local key = el.t == "Link" and el.target:match("^toa:(.+)$")
      if key then
        if not auth[key] then error("ksb-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
        nhits = nhits + 1
        local id = "C:" .. nhits
        local after = {}
        for j = i + 1, #inlines do after[#after + 1] = inlines[j] end
        needle(id, stringify(el.content), stringify(after):sub(1, 40))
        hits[key] = hits[key] or {}
        table.insert(hits[key], id)
        out:extend(el.content)
      else
        out:insert(el)
      end
    end
    return out
  end

  local entries, body = {}, {}
  local c = { 0, 0, 0 }
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local first = i == 1
    local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local level = math.min(b.level, 4)
      local lab = ""
      if level == 1 then c = { 0, 0, 0 } else
        c[level - 1] = c[level - 1] + 1
        for k = level, 3 do c[k] = 0 end
        lab = label(level, c[level - 1])
      end
      local id = "H:" .. (#entries + 1)
      needle(id, (lab ~= "" and (lab .. " ") or "") .. stringify(b.content), nxt)
      local content = cite_links(b.content)
      entries[#entries + 1] = { id = id, level = level, label = lab, title = content }
      local o = { keep = true, brk = first, before = first and 0 or SINGLE, after = SINGLE }
      if level == 1 then
        o.jc = "center"
        body[#body + 1] = p(xe.inl(upper(content), { b = true }), o)
      else
        local ind = label_indent(level)
        o.left, o.hanging = ind + INDENT, INDENT
        body[#body + 1] = p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(content, { b = true }), o)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      body[#body + 1] = p(xe.inl(cite_links(b.content)), { line = BODY, first = INDENT, keep = last, brk = first })
    elseif b.t == "BlockQuote" then
      for k, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("ksb-motion-brief.lua: a quotation holds paragraphs") end
        body[#body + 1] = p(xe.inl(cite_links(q.content)), { left = INDENT, right = INDENT,
          before = SINGLE, after = SINGLE, keep = last, brk = first and k == 1 })
      end
    else
      error("ksb-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, "B", n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", SECT)

  local out = {}
  local function add(xs) for _, x in ipairs(xs) do out[#out + 1] = xe.raw(x) end end
  add(cover(meta))
  add(toc(entries))
  add(toa(auth, hits))
  add(body)
  add(signature(meta))
  add(certificate(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

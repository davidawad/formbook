-- mtd-motion-brief.lua (docx engine): the D. Mont. brief in support of a motion as Word paragraphs, so that it reads
-- and breaks as typst/mtd-motion-brief.typ does: the cover (counsel in two columns with the role under the left one,
-- the court title, the caption with the case number and the title; Appendix C, Form A; no page number), the table of
-- contents and the table of authorities (L.R. 7.1(d)(2)(C); lower roman from i), the memorandum (arabic from 1) with
-- headings labelled I., A., 1. by the filter, the signature block kept with the last paragraph, the certificate of
-- compliance (L.R. 7.1(d)(2)(E), the word count) and the certificate of service. Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 640 the double-spaced body, 320 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. A paragraph that carries a
-- footnote is left to pandoc in "Body Text Note" (the same layout), so that pandoc writes the note.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle:
-- the contents' page of each heading, and the authorities' pages of each `toa:` link (the link text and the words
-- after it, where typst records the link). Three sections: the cover (no number), the tables (lower roman from i;
-- the section starts at the contents' title) and the body (arabic from 1, at the first heading; FORMBOOK_FINAL).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 640, 320            -- typst pitch-double, pitch-single
local GAP = 320                          -- typst gap-half
local INDENT = 720                       -- typst para-indent, heading-tab: 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAD = 4896, 288      -- typst caption-left 3.4 in, caption-pad 0.2 in
local DESIG = 2016                       -- typst designation-indent, 1.4 in
local RULE = 15                         -- the caption rule, 0.75 pt: LibreOffice sets the cell text inside it, typst draws it over the gap
local GUTTER = 432                       -- typst counsel-gutter, 0.3 in
local SIG_LEFT = 4896                    -- typst sig-left, 3.4 in
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-col 36 pt, toa-col 72 pt
local TOA_HANG = 504                     -- typst toa-hang, 0.35 in
local ROW_GAP, GROUP_GAP = 160, 320      -- typst row-gap 8 pt, group-gap 16 pt
local PASSIM_AT = 7                      -- typst passim-threshold
local WORD_LIMIT = 6500                  -- typst word-limit (L.R. 7.1(d)(2)(A))
local FOOTER = 688                       -- the page number's line 34.4 pt above the page foot (typst footer-descent 30 %)
local FACE = "Times New Roman"           -- typst face-name: the face the certificate of compliance names
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { style, before, after, line, left, right, first, hanging, jc, keep, lines, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless one-row table that never splits: cells = { { width, paragraphs, tcBorders } }.
local function tbl(cells)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    local body = #c[2] > 0 and table.concat(c[2]) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- A section's properties: its footer (fb render's rIdFtrNone or rIdFtrPage), the page numbers, letter paper with
-- 1-inch margins (L.R. 1.5(a)(1)).
local function sect_pr(footer, fmt, start)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' .. pg .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(footer, fmt, start)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' ..
    sect_pr(footer, fmt, start) .. '</w:pPr></w:p>'
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
  needles[#needles + 1] = table.concat({ id, kind, long, short:sub(1, NEEDLE_MAX) }, "\t")
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

-- The sample's frontmatter as written (fb render's FORMBOOK_META), for the authorities' kinds and sort keys.
local function raw_meta()
  local path = os.getenv("FORMBOOK_META")
  if not path or path == "" then return {} end
  local f = io.open(path, "r")
  if not f then return {} end
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false)
end

-- The body of the sample (the text after the frontmatter), for the word count.
local function source_body()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then error("mtd-motion-brief: cannot read the sample for the word count", 0) end
  local text = h:read("a")
  h:close()
  if text:sub(1, 4) ~= "---\n" then return text end
  local _, e = text:find("\n%-%-%-[ \t]*\r?\n")
  if not e then return text end
  return text:sub(e + 1)
end

-- typst count-words: whitespace-separated tokens with a letter or digit; footnote labels and (toa:KEY) excluded.
local function count_words(md)
  local s = md:gsub("%[%^[^%]]*%]", " "):gsub("%(toa:[^%)]*%)", " ")
  local n = 0
  for tok in s:gmatch("%S+") do
    if tok:find("[A-Za-z0-9]") then n = n + 1 end
  end
  return n
end

local function commas(n)
  local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (s:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption and title (Appendix C, Form A)
-- ---------------------------------------------------------------------------

-- typst counsel-split: the first k groups on the left, so that the taller column has as few lines as possible.
local function counsel_split(groups)
  local n = #groups
  if n < 2 then return n end
  local function lines(a, b)
    local s, c = 0, 0
    for i = a, b do s = s + #groups[i]; c = c + 1 end
    return s + math.max(c - 1, 0)
  end
  local best, cost = 1, nil
  for k = 1, n - 1 do
    local m = math.max(lines(1, k), lines(k + 1, n))
    if cost == nil or m < cost then best, cost = k, m end
  end
  return best
end

local function counsel_column(groups, a, b, out)
  for i = a, b do
    for j, l in ipairs(groups[i]) do
      out[#out + 1] = p(xe.inl(l), { before = (i > a and j == 1) and GAP or 0 })
    end
  end
  return out
end

local function counsel(meta)
  local groups = {}
  for _, g in ipairs(meta.counsel) do groups[#groups + 1] = g end
  local k = counsel_split(groups)
  local left = counsel_column(groups, 1, k, {})
  left[#left + 1] = p(xe.inl(meta.counsel_role, { i = true }), { before = GAP })
  local right = counsel_column(groups, k + 1, #groups, {})
  local half = (TEXTW - GUTTER) // 2
  return tbl({ { half, left }, { GUTTER, {} }, { TEXTW - GUTTER - half, right } })
end

local function caption(meta)
  local left = {}
  local function add(x, o)
    o = o or {}
    o.right = CAP_PAD - RULE
    left[#left + 1] = p(x, o)
  end
  for k, side in ipairs(meta.caption) do
    if k > 1 then add(xe.runs("v."), { before = GAP, after = GAP }) end
    for _, n in ipairs(side.names) do add(xe.inl(n)) end
    -- the last designation keeps the caption's bottom padding (typst: pad(bottom: gap-half))
    add(xe.inl(side.designation), { before = GAP, left = DESIG, after = k == #meta.caption and GAP or 0 })
  end
  local right = {
    p(xe.runs("Case No. " .. plain(meta.case_number)), { left = CAP_PAD }),
    p(xe.runs(pandoc.text.upper(plain(meta.brief_title)), { b = true }), { before = BODY, left = CAP_PAD }),
  }
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return tbl({ { CAP_LEFT, left, rule }, { TEXTW - CAP_LEFT, right } })
end

local function cover(meta)
  local out = { counsel(meta) }
  local lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF MONTANA",
    pandoc.text.upper(plain(meta.division)) }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", before = i == 1 and BODY or 0 })
  end
  -- typst: the caption stands half a double line below the court title
  out[#out + 1] = p("", { line = GAP })
  out[#out + 1] = caption(meta)
  return out
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities (L.R. 7.1(d)(2)(C)): rows with a dot leader to the page column
-- ---------------------------------------------------------------------------

local function table_head(title, label, brk)
  return {
    p(xe.runs(title, { b = true }), { jc = "center", keep = true, brk = brk }),
    p(xe.runs(label, { b = true }), { jc = "right", before = GAP, keep = true }),
  }
end

-- typst listing-row: the text wraps before the page column, the leader runs from three spaces after it to the page.
local function row(text, page, left, hanging, col)
  return p(text .. xe.runs(xe.LEAD .. page), { lines = true, tabs = xe.leader_tab(TEXTW), before = ROW_GAP,
    left = left, hanging = hanging, right = col })
end

local function contents(entries)
  local out = table_head("TABLE OF CONTENTS", "Page")
  for _, e in ipairs(entries) do
    local page = labels[e.id] or "0"
    if e.label then
      local ind = (e.level - 2) * INDENT
      out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), page, ind + INDENT, INDENT, TOC_COL)
    else
      out[#out + 1] = row(xe.inl(e.title), page, 0, nil, TOC_COL)
    end
  end
  return out
end

local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "rule", "Rules" }, { "regulation", "Regulations" }, { "other", "Other Authorities" },
}

local function authorities(meta, raw, hits)
  local out = table_head("TABLE OF AUTHORITIES", "Page(s)", true)
  local auth, rawauth = meta.authorities or {}, raw.authorities or {}
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(rawauth) do
      if hits[key] and a.kind == g[1] then
        members[#members + 1] = { key = key, sort = (a.name or a.cite or ""):lower() }
      end
    end
    -- typst sort-key, a stable order on equal keys
    table.sort(members, function(x, y) if x.sort ~= y.sort then return x.sort < y.sort end return x.key < y.key end)
    if #members > 0 then
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = first and 0 or GROUP_GAP, keep = true })
      first = false
      for _, m in ipairs(members) do
        local a = auth[m.key]
        local pages, seen = {}, {}
        for _, id in ipairs(hits[m.key]) do
          local l = labels[id] or "0"
          if not seen[l] then
            seen[l] = true
            pages[#pages + 1] = l
          end
        end
        local where = #pages >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pages, ", "))
        local text = ""
        if a.name then text = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        text = text .. xe.inl(a.cite)
        out[#out + 1] = p(text .. xe.runs(xe.LEAD) .. where, { lines = true, tabs = xe.leader_tab(TEXTW),
          before = ROW_GAP, left = TOA_HANG, hanging = TOA_HANG, right = TOA_COL })
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates (L.R. 1.5(b), 7.1(d)(2)(E); FRCP 5(b))
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = {}
  local pre = sig.preamble or {}
  for i, l in ipairs(pre) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and BODY or 0 }) end
  right[#right + 1] = p(xe.runs("/s/ " .. plain(sig.signer)), { before = BODY })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("DATED: " .. plain(meta.date)), { before = BODY }) }
  return tbl({ { SIG_LEFT, left }, { TEXTW - SIG_LEFT, right } })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function break_text(t)
  return (t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1"))
end

local function breaks(s)
  return pandoc.Str(break_text(s.text))
end

-- A certificate: its heading (kept), its text (double-spaced, first line indented) and the signature grid.
local function certificate(id, title, above, brk, text, left, signer)
  return {
    xe.para({ xe.style("Heading1"), xe.KEEP, brk and xe.BREAK or "", xe.spacing(above, GAP, SINGLE), xe.ind(0, nil, 0),
      xe.jc("center") }, xe.runs(pandoc.text.upper(title), { b = true })),
    p(xe.runs(break_text(text)), { line = BODY, first = INDENT, keep = true }),
    tbl({ { SIG_LEFT, { p(left, { before = BODY }) } },
      { TEXTW - SIG_LEFT, { p(xe.runs("/s/ " .. plain(signer)), { before = BODY }), p(xe.inl(signer)) } } }),
  }
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do out = out .. v[2]; n = n - v[1] end
  end
  return out
end

-- typst heading-num: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 unnumbered.
local CNT = { 0, 0, 0, 0, 0 }
local function label_for(level)
  level = math.min(level, 5)
  CNT[level] = CNT[level] + 1
  for l = level + 1, 5 do CNT[l] = 0 end
  if level == 2 then return roman(CNT[2]) .. "." end
  if level == 3 then return string.char(64 + CNT[3]) .. "." end
  if level == 4 then return tostring(CNT[4]) .. "." end
  if level == 5 then return string.char(96 + CNT[5]) .. "." end
  return nil
end

-- Headings, single-spaced and bold, half a double line above and below, kept with the text: level 1 centered
-- capitals; deeper levels the label in a half-inch box, the text hanging after it.
local function heading(b, label, first)
  local lvl = b.level
  local content = b.content
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(first and 0 or GAP, GAP, SINGLE), xe.ind(0, nil, 0),
      xe.jc("center") }, xe.inl(content, { b = true }))
  end
  local left = (lvl - 1) * INDENT
  return xe.para({ xe.style("Heading" .. math.min(lvl, 3)), xe.KEEP, xe.spacing(first and 0 or GAP, GAP, SINGLE),
    xe.ind(left, INDENT, nil), xe.jc("left") }, xe.runs(label .. "\t", { b = true }) .. xe.inl(content, { b = true }))
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- A space before a footnote mark is not printed (typst sets the mark against the word).
local function tight_notes(inl)
  for i = #inl - 1, 1, -1 do
    if inl[i].t == "Space" and inl[i + 1].t == "Note" then inl:remove(i) end
  end
  return inl
end

-- A doubled sign stays with its number ("§§ 2201"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- The text of inlines as the PDF prints it, with the position of every `toa:` link (its key) in it. Footnotes are
-- collected apart (their text is printed at the foot of the page).
local function flatten(inl, acc)
  for _, el in ipairs(inl) do
    if el.t == "Str" then
      acc.text = acc.text .. el.text
    elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then
      acc.text = acc.text .. " "
    elseif el.t == "Note" then
      acc.notes[#acc.notes + 1] = el
    elseif el.t == "Link" and el.target:match("^toa:") then
      acc.links[#acc.links + 1] = { key = el.target:sub(5), pos = #acc.text + 1 }
      flatten(el.content, acc)
    elseif el.t == "Quoted" then
      acc.text = acc.text .. "\""
      flatten(el.content, acc)
      acc.text = acc.text .. "\""
    elseif el.content then
      flatten(el.content, acc)
    else
      acc.text = acc.text .. stringify(el)
    end
  end
  return acc
end

local k_n = 0
-- The needles of a paragraph's `toa:` links (kind B in the body, N in a footnote), listed under their keys.
local function link_needles(inl, kind, hits, auth)
  local acc = flatten(inl, { text = "", links = {}, notes = {} })
  for _, l in ipairs(acc.links) do
    if auth[l.key] == nil then
      error("mtd-motion-brief: link `toa:" .. l.key .. "` has no entry under `authorities:` in the frontmatter", 0)
    end
    k_n = k_n + 1
    local id = "K:" .. k_n
    need(id, kind, acc.text:sub(l.pos, l.pos + 80))
    hits[l.key] = hits[l.key] or {}
    hits[l.key][#hits[l.key] + 1] = id
  end
  for _, n in ipairs(acc.notes) do
    for _, b in ipairs(n.content) do
      if b.content then link_needles(b.content, "N", hits, auth) end
    end
  end
end

-- toa: links keep their text only.
local function unlink(el)
  if el.target:match("^toa:") then return el.content end
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "counsel", "counsel_role", "caption", "brief_title", "division", "case_number", "signature", "date" }) do
    if meta[k] == nil then error("mtd-motion-brief: missing required metadata field `" .. k .. "`", 0) end
  end
  local raw = raw_meta()
  local words = raw.word_count and tonumber(raw.word_count) or count_words(source_body())
  if words > WORD_LIMIT then
    error("mtd-motion-brief: L.R. 7.1(d)(2)(A): " .. words .. " words exceeds the " .. WORD_LIMIT .. "-word limit", 0)
  end
  local auth = meta.authorities or {}
  doc = doc:walk({ Inlines = bind_doubled }):walk({ Inlines = tight_notes })
  local blocks = doc.blocks

  -- the needles, in document order: the contents' title (lower roman from i), each heading with the words after it
  -- (the first opens the body, arabic from 1), each authority link with the words after it
  need("S:toc", "B", "TABLE OF CONTENTS", "Page")
  local hits, entries, h_n, heads = {}, {}, 0, {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      need(id, "B", stringify(b.content), nxt)
      local label = b.level > 1 and label_for(b.level) or label_for(1)
      heads[i] = label
      if b.level <= 3 then entries[#entries + 1] = { id = id, level = b.level, title = b.content, label = label } end
    elseif b.t == "Para" or b.t == "Plain" then
      link_needles(b.content, "B", hits, auth)
    else
      error("mtd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  local cert_text = "Pursuant to Local Rule 7.1(d)(2)(E), I certify that this brief is printed with a proportionately "
    .. "spaced " .. FACE .. " typeface of 14 points; is double-spaced except for footnotes and for quoted and indented "
    .. "material; and the word count is " .. commas(words) .. " words, excluding caption, certificate of compliance, "
    .. "table of contents and authorities, exhibit index, and certificate of service."
  local serv_text = "I hereby certify that on this date, an accurate copy of the foregoing document was served "
    .. "electronically through the Court\u{2019}s CM/ECF system on registered counsel."
  local service = raw.certificate_service ~= false
  need("H:cc", "B", "Certificate of Compliance", cert_text:sub(1, 40))
  entries[#entries + 1] = { id = "H:cc", level = 1, title = pandoc.Inlines({ pandoc.Str("CERTIFICATE OF COMPLIANCE") }) }
  if service then
    need("H:cs", "B", "Certificate of Service", serv_text:sub(1, 40))
    entries[#entries + 1] = { id = "H:cs", level = 1, title = pandoc.Inlines({ pandoc.Str("CERTIFICATE OF SERVICE") }) }
  end
  for _, e in ipairs(entries) do
    if e.level == 1 then
      e.title = pandoc.Inlines(e.title):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    end
  end
  local nl = needles
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  blocks = blocks:walk({ Link = unlink }):walk({ Str = breaks })
  local out = cover(meta)
  out[#out + 1] = section_end("rIdFtrNone")
  for _, x in ipairs(contents(entries)) do out[#out + 1] = x end
  for _, x in ipairs(authorities(meta, raw, hits)) do out[#out + 1] = x end
  out[#out + 1] = section_end("rIdFtrPage", "lowerRoman", 1)

  -- the last paragraph stays on one page with the signature block (typst: one unbreakable block)
  local last = 0
  for i, b in ipairs(blocks) do if b.t ~= "Header" then last = i end end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b, heads[i], i == 1)
    elseif has_note(b) then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content):walk({ Inlines = xe.inlines }) },
        { ["custom-style"] = "Body Text Note" })
    else
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = i == last })
    end
  end
  out[#out + 1] = signature(meta)
  local sig = meta.signature
  for _, x in ipairs(certificate("H:cc", "Certificate of Compliance", 0, true, cert_text, "", sig.signer)) do
    out[#out + 1] = x
  end
  if service then
    for _, x in ipairs(certificate("H:cs", "Certificate of Service", BODY, false, serv_text,
      xe.runs("Dated: " .. plain(meta.date)), sig.signer)) do
      out[#out + 1] = x
    end
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

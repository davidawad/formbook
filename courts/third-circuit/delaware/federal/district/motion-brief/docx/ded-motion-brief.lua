-- D. Del. motion brief (opening brief), docx engine (docs/DOCX.md). Mirrors typst/ded-motion-brief.typ:
--   * the cover (LR 7.1.3(a)(1)): the court title, the caption (a one-row table, the party cell ruled at its right
--     and foot, "C.A. No." at the right), the title, the counsel block in two columns ("OF COUNSEL:" at the left),
--     "Dated:"; no page number;
--   * the contents and the table of citations (LR 7.1.3(b)(1)(A)-(B)), lower roman from i: single-spaced rows, the
--     page in a column at the right with a dot leader to it (a right indent and a right tab beyond it); the pages
--     come from fb render's passes (needles in $FORMBOOK_NEEDLES, pages back in $FORMBOOK_PAGES; docxpages.rs): one
--     per body heading (its text and the words after it) and one per [text](toa:KEY) citation (N inside a footnote);
--   * the memorandum, arabic from 1: paragraphs pandoc writes (footnotes are Word footnotes), headings numbered I.
--     and A. as typst numbers them, the last paragraph kept with the signature block (Delaware counsel under the
--     signature line, LR 5.1.1(a)).
-- The footers (none on the cover; the page number, centred) and the sections are written for fb render
-- ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the body styles are in docx/reference.xml. Nothing case-specific is
-- written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276                 -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local TW = 9360                               -- the text width: 6.5 in
local LABEL = 720                             -- typst label-box 0.5 in
local CAP_LEFT = 4896                         -- typst cap-left 3.4 in
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local CAP_PAD = 173                           -- typst cap-pad 8.65 pt
local CAP_RIGHT = 648                         -- typst cap-right 0.45 in
local COUNSEL_COL, COUNSEL_GUTTER = 4464, 432 -- typst: two columns of (6.5 in - 0.3 in) / 2, counsel-gutter 0.3 in
local SIG_COL = 4608                          -- typst sig-col 3.2 in
local TOC_COL, TOA_COL, TOA_HANG = 720, 1440, 504  -- typst toc-col 0.5 in, toa-col 1 in, toa-hang 0.35 in
local LEADER_ROOM = 60                        -- LibreOffice wants a space more (3 pt) than typst before a leader tab past the
                                              -- right indent: a row typst fits within 3 pt of its column wrapped here
local COVER_GAP = 552                         -- typst cover-gap 27.6 pt
local HEAD_SPACE = 276                        -- typst head-space 13.8 pt
local TOC_GAP, TOA_GAP, GROUP_ABOVE = 276, 138, 276  -- typst toc-gap, toa-gap, group-above
local SIG_ABOVE = 552                         -- typst sig-above 27.6 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge
local PASSIM = 7                              -- typst passim-threshold

local function check(cond, msg)
  if not cond then error("ded-motion-brief docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph: o = { style, keep, lines, brk, tabs, before, after, pitch, left, hanging, first, right, jc }; single
-- pitch by default; its properties in the schema's order.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- Single lines, one paragraph each (metadata values or plain strings); an empty item is a blank single line.
local function lines(list)
  local out, gap = {}, 0
  for _, l in ipairs(list) do
    if txt(l) == "" then gap = gap + SINGLE else
      out[#out + 1] = p(type(l) == "string" and xe.runs(l) or xe.inl(l), { before = gap })
      gap = 0
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Footers and sections (LR 5.1.1(a): pages numbered consecutively)
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_PAGE = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')
local FOOTER_NONE = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") }, "")

-- A section's properties: its footer, letter paper, 1 in margins, the page numbering.
local function sect(footer, fmt, start)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="' .. fmt .. '"'
    .. (start and (' w:start="' .. start .. '"') or "") .. '/></w:sectPr>'
end

-- The section ends with this paragraph (no empty paragraph of its own: it would take a line of the page).
local function end_section(xml, sectpr)
  local last
  local from = 1
  while true do
    local j = xml:find("</w:pPr>", from, true)
    if not j then break end
    last, from = j, j + 1
  end
  check(last ~= nil, "a section must end with a paragraph")
  return xml:sub(1, last - 1) .. sectpr .. xml:sub(last)
end

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render's multi-pass build)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- The text of inlines up to the first footnote (its mark is a number in the PDF text).
local function plain(list)
  local out = pandoc.Inlines({})
  for _, el in ipairs(list) do
    if el.t == "Note" then break end
    out:insert(el)
  end
  return stringify(out)
end

local needles = {}
local function need(id, kind, text, after)
  local long = norm(text .. " " .. (after or "")):sub(1, NEEDLE_MAX)
  local short = norm(text):sub(1, NEEDLE_MAX)
  needles[#needles + 1] = table.concat({ id, kind, long, short ~= "" and short or long }, "\t")
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, _, lab = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = lab end
  end
  f:close()
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function mar(left, bottom, right)
  return '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

-- A borderless one-row table: cells = { { width, tcPr extra, paragraphs } }.
local function row_table(cells)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. c[2] .. '</w:tcPr>'
      .. (c[3] ~= "" and c[3] or p("")) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs)
    .. '</w:tr></w:tbl>'
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function cover(m)
  local left = {}
  for k, party in ipairs(items(m.caption)) do
    if k > 1 then left[#left + 1] = "v." end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = n end
    left[#left + 1] = party.designation
  end
  local rule = ' w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local borders = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom' .. rule .. '<w:right' .. rule
    .. '</w:tcBorders>'
  local counsel_left = ""
  if m.of_counsel then
    local l = { "OF COUNSEL:", "" }
    for _, x in ipairs(items(m.of_counsel)) do l[#l + 1] = x end
    counsel_left = lines(l)
  end
  return p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
    .. p(xe.runs("FOR THE DISTRICT OF DELAWARE", { b = true }), { jc = "center" })
    .. space(COVER_GAP)
    -- the bottom margin of the party cell, less its rule, is the row's (LibreOffice); none in the other cell
    .. row_table({ { CAP_LEFT, borders .. mar(0, CAP_PAD - 15, CAP_PAD), lines(left) },
      { TW - CAP_LEFT, mar(CAP_RIGHT, 0, 0), space(SINGLE) .. p(xe.runs("C.A. No. ") .. xe.inl(m.case_number)) } })
    .. p(xe.inl(upper(m.brief_title), { b = true }), { jc = "center", before = COVER_GAP })
    .. space(COVER_GAP)
    .. row_table({ { COUNSEL_COL, mar(0, 0, 0), counsel_left },
      { TW - COUNSEL_COL, mar(COUNSEL_GUTTER, 0, 0), lines(items(m.counsel)) } })
    .. p(xe.runs("Dated: ") .. xe.inl(m.date), { before = COVER_GAP })
end

-- ---------------------------------------------------------------------------
-- Contents and citations (typst toc-section, toa-section)
-- ---------------------------------------------------------------------------

local function title_block(s, brk, column)
  return p(xe.runs(s:upper(), { b = true }), { pitch = BODY, jc = "center", keep = true, brk = brk })
    .. p(xe.runs(column, { b = true }), { jc = "right", keep = true })
end

local function contents(entries)
  local out = { title_block("Table of Contents", false, "Page") }
  for _, e in ipairs(entries) do
    local ind = e.level <= 1 and 0 or (e.level - 2) * LABEL
    local body = e.level <= 1 and xe.inl(e.content) or (xe.runs(e.label .. "\t") .. xe.inl(e.content))
    out[#out + 1] = p(body .. xe.runs(xe.LEAD) .. xe.runs(labels[e.id] or "0"), {
      lines = true, tabs = xe.leader_tab(TW), before = TOC_GAP,
      left = e.level <= 1 and 0 or ind + LABEL, hanging = e.level > 1 and LABEL or nil, right = TOC_COL - LEADER_ROOM })
  end
  return table.concat(out)
end

local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "other", "Other Authorities" } }

local function citations(auth, occurrences)
  local pages = {}
  for _, o in ipairs(occurrences) do
    check(auth[o.key] ~= nil, "link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    pages[o.key] = pages[o.key] or {}
    local lab = labels[o.id] or "0"
    local seen = false
    for _, x in ipairs(pages[o.key]) do if x == lab then seen = true end end
    if not seen then table.insert(pages[o.key], lab) end
  end
  local out = { title_block("Table of Citations", true, "Page(s)") }
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if txt(a.kind) == g[1] and pages[key] then
        members[#members + 1] = { key = key, a = a, sort = (txt(a.name) .. " " .. txt(a.cite)):lower() }
      end
    end
    table.sort(members, function(x, y) return x.sort < y.sort end)
    if #members > 0 then
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = GROUP_ABOVE, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        local entry = ""
        if a.name then entry = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(" ") end
        local pg = pages[mm.key]
        local page = #pg >= PASSIM and xe.runs("passim", { i = true }) or xe.runs(table.concat(pg, ", "))
        out[#out + 1] = p(entry .. xe.inl(a.cite) .. xe.runs(xe.LEAD) .. page, {
          lines = true, tabs = xe.leader_tab(TW), before = TOA_GAP, left = TOA_HANG, hanging = TOA_HANG,
          right = TOA_COL - LEADER_ROOM })
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block): single lines from SIG_COL, "Dated:" left of the first; kept whole
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local rows = {}
  for _, l in ipairs(items(sig.firm)) do rows[#rows + 1] = l end
  rows[#rows + 1] = ""
  rows[#rows + 1] = pandoc.Inlines({ pandoc.Str("/s/"), pandoc.Space() }) .. pandoc.Inlines(sig.signer)
  for _, l in ipairs(items(sig.lines)) do rows[#rows + 1] = l end
  local list, gap = {}, SIG_ABOVE
  for _, r in ipairs(rows) do
    if txt(r) == "" then gap = gap + SINGLE else
      list[#list + 1] = { r, gap }
      gap = 0
    end
  end
  local out = {}
  for i, l in ipairs(list) do
    local o = { before = l[2], left = SIG_COL, keep = i < #list }
    local body = xe.inl(l[1])
    if i == 1 then
      body = xe.runs("Dated: ") .. xe.inl(m.date) .. xe.runs("\t") .. body
      o.hanging, o.tabs = SIG_COL, '<w:tabs><w:tab w:val="left" w:pos="' .. SIG_COL .. '"/></w:tabs>'
    end
    out[#out + 1] = p(body, o)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The memorandum
-- ---------------------------------------------------------------------------

-- Citations in document order: a needle each (B in the body, N in a footnote).
local occurrences = {}
local function scan(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local id = "T" .. (#occurrences + 1)
      occurrences[#occurrences + 1] = { id = id, key = el.target:sub(5) }
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      need(id, in_note and "N" or "B", stringify(el.content), plain(rest))
    elseif el.t == "Note" then
      for _, b in ipairs(el.content) do
        if b.t == "Para" or b.t == "Plain" then scan(b.content, true) end
      end
    elseif el.content and type(el.content) ~= "string" and el.t ~= "Link" then
      scan(el.content, in_note)
    end
  end
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("¶¶ 19-20"; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("^[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "case_number", "caption", "brief_title", "counsel", "date", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  load_pages()
  write_file("FORMBOOK_FOOTERS", "rIdDedPage\t" .. FOOTER_PAGE .. "\nrIdDedNone\t" .. FOOTER_NONE .. "\n")
  write_file("FORMBOOK_FINAL", sect("rIdDedPage", "decimal", 1))

  -- the needles in document order: the contents' title (the front matter's first page), the first paragraph (the
  -- memorandum's), each heading with the words after it, each citation
  local blocks = doc.blocks
  need("S:toc", "B", "Table of Contents Page")
  local first = blocks[1]
  check(first and first.t == "Para", "the memorandum must open with a paragraph")
  need("S:body", "B", plain(first.content):sub(1, 80))
  local entries, nums = {}, { 0, 0 }
  local body = pandoc.Blocks({})
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      check(b.level <= 3, "headings go to level 3")
      if b.level == 2 then nums = { nums[1] + 1, 0 } elseif b.level == 3 then nums[2] = nums[2] + 1 end
      local label = b.level == 2 and pandoc.utils.to_roman_numeral(nums[1]) .. "."
        or b.level == 3 and string.char(64 + nums[2]) .. "." or ""
      local id = "H" .. (#entries + 1)
      local nxt = blocks[i + 1]
      need(id, "B", label .. " " .. stringify(b.content), nxt and plain(nxt.content or {}):sub(1, 40) or "")
      entries[#entries + 1] = { id = id, level = b.level, label = label, content = b.content }
      if b.level == 1 then
        body:insert(xe.raw(p(xe.inl(upper(b.content), { b = true }), { pitch = BODY, jc = "center", keep = true })))
      else
        local ind = (b.level - 2) * LABEL
        body:insert(xe.raw(p(xe.runs(label .. "\t", { b = true }) .. xe.inl(b.content, { b = true }),
          { before = HEAD_SPACE, after = HEAD_SPACE, left = ind + LABEL, hanging = LABEL, keep = true })))
      end
    elseif b.t == "Para" then
      scan(b.content, false)
      body:insert(pandoc.Div({ b }, { ["custom-style"] = i == #blocks and "Body Text Keep" or "Body Text" }))
    else
      error("ded-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  check(#entries > 0, "LR 7.1.3(b)(1)(A): the memorandum needs headings for its table of contents")
  needles[#needles + 1] = "#section\tS:toc\tlower-roman\t"
  needles[#needles + 1] = "#section\tS:body\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")

  local auth = {}
  for k, v in pairs(m.authorities or {}) do auth[k] = v end
  local out = pandoc.Blocks({
    xe.raw(end_section(cover(m), sect("rIdDedNone", "decimal"))),
    xe.raw(end_section(contents(entries) .. citations(auth, occurrences), sect("rIdDedPage", "lowerRoman", 1))),
  })
  out:extend(body)
  out:insert(xe.raw(signature(m)))
  -- the citations' links keep their text; the frontmatter was consumed above (pandoc would write its title)
  out = out:walk({ Link = function(el) if el.target:match("^toa:") then return el.content end end })
  return pandoc.Pandoc(out:walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

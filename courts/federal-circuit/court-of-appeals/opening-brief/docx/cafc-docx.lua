-- cafc-docx.lua: pandoc filter for the cafc .docx engine (docx/render.sh). It lays out the opening brief the way the
-- typst template does: cover, front matter (roman), body (arabic), addendum (Add-), certificates (arabic, continuing).
-- The styles come from docx/reference.docx (made from docx/styles.xml.in by docx/make-reference.sh).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the document breaks every line and page where the
-- typst render (the reference) breaks them. The break rules on every run come from lib/docx/xengine.lua (a no-break
-- hyphen before a digit, pandoc's abbreviation no-break spaces undone, a section sign bound to its number); every
-- paragraph this filter writes carries the typst template's line pitch and spaces as exact line spacing (twips =
-- 20 x pt; [name] refers to the typst template), and the tables' rows wrap before a page column, a dot leader running
-- from three spaces after the text to the page number.
--
-- Page numbers in the contents and the table of authorities are not known to pandoc. render.sh runs the build
-- more than once: a run writes CAFC_PATTERNS (what to look for, and where), LibreOffice renders the .docx, pages.sh
-- finds the page labels, and the next run reads them from CAFC_PAGES. The first run writes placeholders.

local xe = require("docx.xengine")

local DATE = nil -- the brief's date (frontmatter), kept out of the metadata pandoc prints

-- Pitches and spaces of the typst template, in twips.
local SINGLE = 399 -- [pitch-single] 19.95 pt
local TEXTW = 9360 -- the text width: 6.5 in
local HALF = 4680 -- [half-width]: signature, counsel and designation blocks start at the middle of the text
local TAB = 720 -- [heading-tab], [para-indent]: 0.5 in

-- ---------------------------------------------------------------------------
-- Inputs written by render.sh between runs
-- ---------------------------------------------------------------------------

local PAGES = {}
do
  local path = os.getenv("CAFC_PAGES")
  local f = path and io.open(path, "r")
  if f then
    for line in f:lines() do
      local id, val = line:match("^([^\t]+)\t(.*)$")
      if id then
        PAGES[id] = val
      end
    end
    f:close()
  end
end

local function pg(id)
  return PAGES[id] or "00"
end

local PATTERNS = {} -- lines "mode area id needle" for pages.sh

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function text(x)
  return pandoc.utils.stringify(x)
end

-- Upper case (ASCII), single spaces: the form pages.sh compares (it runs in the C locale).
local function norm(s)
  s = s:gsub("\194\160", " ")
  s = s:gsub("%s+", " ")
  s = s:gsub("^ ", ""):gsub(" $", "")
  return s:upper()
end

local function need_pattern(mode, area, id, needle)
  PATTERNS[#PATTERNS + 1] = mode .. "\t" .. area .. "\t" .. id .. "\t" .. norm(needle)
end

-- Inlines of a metadata value, emphasis kept (YAML strings are read as markdown by pandoc).
local function inlines_of(v)
  if v == nil then
    return pandoc.Inlines({})
  end
  if v.t == "MetaInlines" then
    return pandoc.Inlines(v)
  elseif v.t == "MetaString" then
    return pandoc.Inlines({ pandoc.Str(v) })
  elseif v.t == "MetaBlocks" then
    local out = pandoc.Inlines({})
    for _, b in ipairs(v) do
      if b.content then
        out:extend(b.content)
      end
    end
    return out
  end
  if type(v) == "table" and v.t == nil then
    return pandoc.Inlines(v)
  end
  return pandoc.Inlines({ pandoc.Str(text(v)) })
end

local function append(list, more)
  for _, x in ipairs(more) do
    list[#list + 1] = x
  end
  return list
end

-- Runs of a metadata value (or a string), with run properties o ({ b, i, u, box }).
local function R(v, o)
  if type(v) == "string" then
    return xe.runs(v, o)
  end
  return xe.inl(inlines_of(v), o)
end

-- A paragraph with explicit properties. o: style, keep (keep with next and lines), lines (keep lines), brk (page
-- break before), tabs, before, after, line (twips; default SINGLE), ind = { left, hanging, first, right }, jc.
local function PX(o, runs)
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  if o.ind then props[#props + 1] = xe.ind(o.ind[1], o.ind[2], o.ind[3], o.ind[4]) end
  if o.jc then props[#props + 1] = xe.jc(o.jc) end
  return xe.raw(xe.para(props, runs))
end

-- A paragraph in one of the court's styles (docx/styles.xml.in), its inlines written by pandoc.
local function P(style, inls)
  return pandoc.Div({ pandoc.Para(xe.inlines(pandoc.Inlines(inls))) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw(x)
  return pandoc.RawBlock("openxml", x)
end

-- A box for the type-volume certificate [checkbox]: a bordered run, "X" or three no-break spaces inside, in the body
-- face (as ca9.lua draws Form 8's boxes), so no symbol font can fall back to another face (DEF-FONT-002).
local function checkbox(checked)
  return xe.runs(checked and "X" or "\u{00A0}\u{00A0}\u{00A0}", { box = true })
end

-- Vertical space on the cover: one empty line of exact height, in twentieths of a point.
local function gap(twips)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

-- Cover rules: a double rule (full width), or a short rule (2 in, centered).
local function rule(kind)
  local ind = ""
  local border = '<w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/>'
  if kind == "double" then
    border = '<w:bottom w:val="double" w:sz="6" w:space="1" w:color="000000"/>'
  elseif kind == "short" then
    ind = '<w:ind w:left="3240" w:right="3240"/>'
  end
  return raw('<w:p><w:pPr><w:pBdr>' .. border .. '</w:pBdr><w:spacing w:before="0" w:after="0" w:line="200" w:lineRule="exact"/>' .. ind .. "</w:pPr></w:p>")
end

local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="0" w:footer="576" w:gutter="0"/>'

-- The section break that ends a section: its footer part (nil: none), its page number format and start. The empty
-- paragraph that carries it is 1 pt high, so it never pushes a full page's last line on.
local function section_end(footer_rid, fmt, start)
  local x = "<w:sectPr>"
  if footer_rid then
    x = x .. '<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>'
  end
  x = x .. '<w:type w:val="nextPage"/>' .. PG
  if fmt then
    x = x .. '<w:pgNumType w:fmt="' .. fmt .. '"' .. (start and (' w:start="' .. start .. '"') or "") .. "/>"
  end
  x = x .. "</w:sectPr>"
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. x .. "</w:pPr></w:p>")
end

-- A section heading [style-heading, level 1]: bold capitals, centered, 16 pt (the Heading 1 style); 21 pt above,
-- 15.4 pt below. `top`: it opens a page (after a page or section break), where typst drops the space above it and
-- Word keeps it, so it carries none; `brk`: it starts a new page itself.
local function heading_1(inls, top, brk)
  return PX({ style = "Heading1", keep = true, brk = brk, before = top and 0 or 420, after = 308, jc = "center" },
    xe.inl(inls, { b = true }))
end

-- ---------------------------------------------------------------------------
-- Headings: labels as the typst template numbers them (heading-label)
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { 1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1 }
  local syms = { "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I" }
  local s = ""
  for i, v in ipairs(vals) do
    while n >= v do
      s = s .. syms[i]
      n = n - v
    end
  end
  return s
end

-- The printed label of a heading of `level` (2 to 5) with the running counters `c`: Argument I. / A. / 1. / a.;
-- elsewhere A. / 1. / a. / (1).
local function label_of(level, c, in_arg)
  if in_arg then
    if level == 2 then return roman(c[2]) .. "." end
    if level == 3 then return string.char(64 + c[3]) .. "." end
    if level == 4 then return tostring(c[4]) .. "." end
    if level == 5 then return string.char(96 + c[5]) .. "." end
  else
    if level == 2 then return string.char(64 + c[2]) .. "." end
    if level == 3 then return tostring(c[3]) .. "." end
    if level == 4 then return string.char(96 + c[4]) .. "." end
    if level == 5 then return "(" .. c[5] .. ")" end
  end
  error("cafc-docx: headings deeper than level 5 are not supported")
end

-- [label-indent]: the label's left edge, in twips. Labels sit half an inch in; each further level steps in half an
-- inch more; in the Argument the level-2 point heading is centered, so its sub-headings start at the first step.
local function label_indent(level, in_arg)
  local first = in_arg and 3 or 2
  return (level - first + 1) * TAB
end

-- ---------------------------------------------------------------------------
-- Citations: a toa: link is plain text here; its shown text is what the page search looks for
-- ---------------------------------------------------------------------------

local cited, seen = {}, {}

local function link_filter(el)
  local key = el.target:match("^toa:(.+)$")
  if not key then
    return nil
  end
  if not seen[key] then
    seen[key] = true
    cited[#cited + 1] = key
  end
  PATTERNS[#PATTERNS + 1] = "all\tbody\tt:" .. key .. "\t" .. norm(text(el.content))
  return pandoc.Span(el.content)
end

local groups = {
  { kind = "case", title = "Cases:" },
  { kind = "constitution", title = "Constitutional Provisions:" },
  { kind = "statute", title = "Statutes:" },
  { kind = "regulation", title = "Regulations:" },
  { kind = "rule", title = "Rules:" },
  { kind = "other", title = "Other Authorities:" },
}

local function sort_key(a)
  local s = a.sort and text(a.sort) or (text(a.name or "") .. " " .. text(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

-- The width of a page label in twips (Times New Roman advances at 14 pt), for a label wider than its column.
local ADV = { ["0"] = 500, ["1"] = 500, ["2"] = 500, ["3"] = 500, ["4"] = 500, ["5"] = 500, ["6"] = 500, ["7"] = 500,
  ["8"] = 500, ["9"] = 500, [","] = 250, [" "] = 250, ["-"] = 333, A = 722, d = 500, i = 278, v = 500, x = 500,
  l = 278, c = 444, m = 778, p = 500, a = 444, s = 389 }
local function label_width(s)
  local w = 0
  for ch in s:gmatch(".") do
    w = w + (ADV[ch] or 722)
  end
  return math.ceil(w * 280 / 1000)
end

-- One row of a table of contents or authorities [listing-row]: the text wraps before a page column `col` (twips;
-- wider when the page label is), a dot leader runs from three no-break spaces after the text to the page number on
-- the last line; the row is not split. o: left, hanging, before, label (or nil), tabs at the label.
local function listing_row(o, body_runs, page)
  local col = math.max(o.col, label_width(page))
  local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. o.left .. '"/><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return PX({ lines = true, tabs = tabs, before = o.before, ind = { o.left, o.hanging, nil, col } },
    body_runs .. xe.runs(xe.LEAD) .. xe.runs(page))
end

-- The table of authorities [toa-section]: each group's title, then each cited authority: name, cite, dot leader,
-- pages. 14 pt above the first group (which carries the "Page(s)" head), 19.6 pt above the others, 2.8 pt below;
-- 9.8 pt above each entry, wrapped lines hang 0.35 in, the page column 56 pt.
local function toa_blocks(authorities)
  local out = {}
  local first = true
  for _, g in ipairs(groups) do
    local members = {}
    for _, key in ipairs(cited) do
      local a = authorities[key]
      if a and text(a.kind) == g.kind then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(p, q)
        if p.sort == q.sort then
          return p.key < q.key
        end
        return p.sort < q.sort
      end)
      local head = xe.runs(g.title, { b = true })
      if first then
        head = head .. xe.runs("\t") .. xe.runs("Page(s)", { b = true, u = true })
      end
      out[#out + 1] = PX({ keep = true, tabs = '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>',
        before = first and 280 or 392, after = 56 }, head)
      first = false
      for _, m in ipairs(members) do
        local a = m.a
        local body = ""
        if a.name then
          body = R(a.name, { i = g.kind == "case" }) .. xe.runs(",") .. xe.BR
        end
        body = body .. R(a.cite)
        out[#out + 1] = listing_row({ left = 504, hanging = 504, before = 196, col = 1120 }, body, pg("t:" .. m.key))
        need_pattern("all", "body", "t:" .. m.key, text(a.cite))
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2); Fed. Cir. R. 32(a)(1)) [cover-body]
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local CG = 200
  local function add(b)
    out[#out + 1] = b
  end
  local function line(runs, o)
    o = o or {}
    add(PX({ before = o.before, ind = o.ind, jc = o.ind and "left" or "center" }, runs))
  end
  add(gap(CG))
  line(R(meta.case_number, { b = true }))
  add(gap(CG))
  add(rule("double"))
  add(gap(CG))
  line(xe.runs("UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT", { b = true }))
  add(gap(CG))
  add(rule("short"))
  add(gap(CG))
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for k, nm in ipairs(side.names or {}) do
      line(R(nm), { before = k > 1 and 98 or 0 })
    end
    line(R(side.designation), { before = 98, ind = { HALF } })
    if i < #sides then
      line(xe.runs("v."), { before = 84 })
      add(gap(84))
    end
  end
  add(gap(CG))
  add(rule("short"))
  add(gap(CG))
  line(R(meta.proceeding))
  add(gap(CG))
  add(rule("short"))
  add(gap(CG))
  line(xe.runs(norm(text(meta.brief_title)), { b = true }))
  add(gap(CG))
  add(rule("short"))
  add(gap(CG))
  local cg = meta.counsel or {}
  for gi, g in ipairs(cg) do
    for k, nm in ipairs(g.names or {}) do
      line(R(nm), { before = (gi > 1 and k == 1) and 140 or 0, ind = { HALF } })
    end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do
      lines[#lines + 1] = l
    end
    if gi == #cg and meta.phone then
      lines[#lines + 1] = meta.phone
    end
    for _, l in ipairs(lines) do
      line(R(l, { i = true }), { ind = { HALF + 140 } })
    end
  end
  add(gap(CG))
  add(rule("double"))
  return out
end

-- ---------------------------------------------------------------------------
-- Signatures and certificates
-- ---------------------------------------------------------------------------

local function signer(meta)
  return (meta.signature or {}).signer
end

-- A signature of a certificate filed by counsel [signature-line-block]: 22.4 pt above, in the right half: "/s/"
-- and the name, the name in capitals, the date.
local function certificate_signature(meta)
  local out = {}
  local who = signer(meta)
  out[#out + 1] = PX({ keep = true, before = 448, ind = { HALF } }, xe.runs("/s/ ") .. R(who))
  out[#out + 1] = PX({ keep = DATE ~= nil, lines = true, ind = { HALF } }, xe.runs(norm(text(who or ""))))
  if DATE then
    out[#out + 1] = PX({ lines = true, ind = { HALF } }, R(DATE))
  end
  return out
end

-- Words of the brief body for the certificate, block by block as the typst template counts them (stringify of the
-- whole document would run the last word of one block into the first of the next): footnote text included, footnote
-- marks and list markers not counted, the addendum and the certificates excluded.
local function words_in(s)
  local n = 0
  for _ in s:gsub("\194\160", " "):gmatch("%S+") do
    n = n + 1
  end
  return n
end

local function count_blocks(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        n = n + count_blocks(item)
      end
    elseif b.t == "BlockQuote" or b.t == "Div" then
      n = n + count_blocks(b.content)
    elseif b.t ~= "RawBlock" then
      local notes = {}
      local without = pandoc.Pandoc({ b }):walk({
        Note = function(note)
          notes[#notes + 1] = note.content
          return {}
        end,
      })
      n = n + words_in(text(without.blocks))
      for _, c in ipairs(notes) do
        n = n + count_blocks(c)
      end
    end
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Meta(meta)
  -- pandoc would print the date as a title block at the top of the document: the date is set by the brief itself
  DATE = meta.date
  meta.date = nil
  return meta
end

local function has_note(b)
  local found = false
  pandoc.Pandoc({ b }):walk({ Note = function(n) found = true return n end })
  return found
end

function Pandoc(doc)
  local meta = doc.meta
  local body, add = {}, {}
  local in_add = false
  for _, b in ipairs(doc.blocks) do
    if not in_add and b.t == "Header" and b.level == 1 and text(b.content):lower() == "addendum" then
      in_add = true
    elseif in_add then
      add[#add + 1] = b
    else
      body[#body + 1] = b
    end
  end
  local authorities = meta.authorities or {}
  local has_addendum = #add > 0
  local sig = meta.signature or {}
  local words = count_blocks(body)

  -- ---- the body: labels, contents entries, the body blocks ----
  local c = { 0, 0, 0, 0, 0 }
  local in_arg = false
  local contents = {}
  local body_blocks = {}
  local bd = pandoc.Pandoc(body):walk({ Link = link_filter }):walk({ Inlines = xe.inlines })

  for i, b in ipairs(bd.blocks) do
    if b.t == "Header" then
      local level = b.level
      local title = text(b.content):lower()
      if level == 1 then
        for k = 2, 5 do
          c[k] = 0
        end
        in_arg = (title == "argument" or title == "reply argument")
      end
      local label = nil
      if level >= 2 then
        c[level] = c[level] + 1
        for k = level + 1, 5 do
          c[k] = 0
        end
        label = label_of(level, c, in_arg)
      end
      local id = "h:" .. (#contents + 1)
      need_pattern("line", "body", id, text(b.content))
      if level <= 4 then
        contents[#contents + 1] = { level = level, label = label, title = b.content, id = id, in_arg = in_arg }
      end
      if level == 1 then
        body_blocks[#body_blocks + 1] = heading_1(b.content, i == 1)
      elseif level == 2 and in_arg then
        -- [style-heading] a point heading of the Argument: centered, bold, its label before the title; 16.8 pt above,
        -- 14 pt below
        body_blocks[#body_blocks + 1] = PX({ style = "Heading2", keep = true, before = 336, after = 280,
          ind = { 0, nil, 0 }, jc = "center" }, xe.runs(label .. " ", { b = true }) .. xe.inl(b.content, { b = true }))
      else
        -- a sub-heading: the label in a half-inch box at its level's indent, the title hanging after it; bold, bold
        -- italic from level 4; 15.4 pt above, 12.6 pt below
        local ind = label_indent(level, in_arg)
        local o = { b = true, i = level >= 4 }
        body_blocks[#body_blocks + 1] = PX({ style = "Heading" .. level, keep = true,
          tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + TAB) .. '"/></w:tabs>', before = 308, after = 252,
          ind = { ind + TAB, TAB }, jc = "left" }, xe.runs(label .. "\t", o) .. xe.inl(b.content, o))
      end
    elseif b.t == "Para" and has_note(b) then
      -- a paragraph that anchors a footnote has no widow or orphan control ("Body Text Note"): typst's widow rule
      -- does not see the note, so its last line moves to the next page alone when the note does not fit
      body_blocks[#body_blocks + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Body Text Note" }))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      append(body_blocks, xe.list_items(b))
    else
      body_blocks[#body_blocks + 1] = b
    end
  end
  -- [cafc-brief] the brief's last paragraph is kept with the signature block (one unbreakable block in typst)
  local last = body_blocks[#body_blocks]
  if last and last.t == "Para" then
    body_blocks[#body_blocks] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "Body Text Keep" }))
  end

  -- ---- front matter (roman): certificate of interest (Fed. Cir. R. 47.4; Form 9) ----
  -- [certificate-of-interest]: the paragraphs 14 pt apart; [numbered-items]: the number in a 0.3 in box, the text
  -- hanging after it, 12.6 pt above.
  local front = {}
  local function item(n, runs)
    return PX({ lines = true, tabs = '<w:tabs><w:tab w:val="left" w:pos="432"/></w:tabs>', before = 252,
      ind = { 432, 432 } }, xe.runs(n .. ".\t") .. runs)
  end
  local ci = meta.interest
  front[#front + 1] = heading_1({ pandoc.Str("Certificate of Interest") }, true)
  need_pattern("top", "front", "f:interest", "CERTIFICATE OF INTEREST")
  front[#front + 1] = PX({}, xe.runs("Counsel for ") .. R(ci["for"]) .. xe.runs(" certifies the following:"))
  local items = {
    { "The full name of every party or amicus represented by me is: ", ci.represented },
    { "The name of the real party in interest represented by me is: ", ci.real_party },
    { "All parent corporations and any publicly held companies that own 10 percent of the stock of a party or amicus curiae represented by me are: ", ci.parents },
    { "The names of all law firms and the partners and associates that (a) appeared for the entities in the originating court or agency or (b) are expected to appear in this court for the entities not including those who have already entered an appearance in this court: ", ci.other_counsel },
  }
  for n, it in ipairs(items) do
    front[#front + 1] = item(n, xe.runs(it[1]) .. R(it[2]) .. xe.runs("."))
  end
  local five
  if meta.related_cases and meta.related_cases.cases then
    five = "Related or prior cases meeting the criteria under Fed. Cir. R. 47.5(a) are listed in the Statement of Related Cases."
  else
    five = "I am unaware of any cases pending in this or any other court or agency that meet the criteria under Fed. Cir. R. 47.5(a). I am unaware of any cases pending that will directly affect or be directly affected by this court\u{2019}s decision in the pending appeal."
  end
  front[#front + 1] = item(5, xe.runs(five))
  append(front, certificate_signature(meta))

  -- ---- contents [toc-section, toc-entry] ----
  local toc = {}
  toc[#toc + 1] = heading_1({ pandoc.Str("Table of Contents") }, true, true)
  -- the "Page" column head, right, 4.2 pt below the heading
  toc[#toc + 1] = PX({ keep = true, before = 84, jc = "right" }, xe.runs("Page", { b = true, u = true }))
  -- one row: the label at its indent in a half-inch box, wrapped lines hang under the title; 8.4 pt above a section,
  -- 4.9 pt above a sub-heading; the page column 36 pt
  local function entry(level, label, title_runs, id, ind)
    local runs = ""
    if label then
      runs = xe.runs(label .. "\t")
    end
    return listing_row({ left = ind + TAB, hanging = TAB, before = level == 1 and 168 or 98, col = 720 },
      runs .. title_runs, pg(id))
  end
  local function upper_runs(s)
    return xe.runs(norm(s))
  end
  toc[#toc + 1] = entry(1, nil, upper_runs("Certificate of Interest"), "f:interest", 0)
  toc[#toc + 1] = entry(1, nil, upper_runs("Table of Contents"), "f:contents", 0)
  toc[#toc + 1] = entry(1, nil, upper_runs("Table of Authorities"), "f:authorities", 0)
  need_pattern("top", "front", "f:contents", "TABLE OF CONTENTS")
  need_pattern("top", "front", "f:authorities", "TABLE OF AUTHORITIES")
  toc[#toc + 1] = entry(1, nil, upper_runs("Statement of Related Cases"), "f:related", 0)
  need_pattern("top", "front", "f:related", "STATEMENT OF RELATED CASES")
  for _, e in ipairs(contents) do
    if e.level == 1 then
      toc[#toc + 1] = entry(1, nil, xe.runs(norm(text(e.title))), e.id, 0)
    else
      -- the Argument's centered point heading has no body indent in the table; its label starts at the margin
      local ind = (e.in_arg and e.level == 2) and 0 or label_indent(e.level, e.in_arg)
      toc[#toc + 1] = entry(e.level, e.label, xe.inl(e.title), e.id, ind)
    end
  end
  if has_addendum then
    toc[#toc + 1] = entry(1, nil, upper_runs("Addendum"), "f:addendum", 0)
    need_pattern("top", "add", "f:addendum", "ADDENDUM")
  end

  -- ---- table of authorities ----
  local toa = { heading_1({ pandoc.Str("Table of Authorities") }, true, true) }
  append(toa, toa_blocks(authorities))

  -- ---- statement of related cases (Fed. Cir. R. 28(a)(4), 47.5) ----
  local related = {}
  related[#related + 1] = heading_1({ pandoc.Str("Statement of Related Cases") }, true, true)
  related[#related + 1] = PX({}, xe.runs("Pursuant to Federal Circuit Rules 28(a)(4) and 47.5, counsel for ") ..
    R(ci["for"]) .. xe.runs(" certifies:"))
  if meta.related_cases and meta.related_cases.cases then
    for n, cs in ipairs(meta.related_cases.cases) do
      related[#related + 1] = item(n, R(cs))
    end
  else
    related[#related + 1] = item(1, xe.runs("I am unaware of any other appeal in or from the same civil action or proceeding in the originating tribunal that was previously before this or any other appellate court."))
    related[#related + 1] = item(2, xe.runs("I am unaware of any case pending in this or any other tribunal that will directly affect or be directly affected by this court\u{2019}s decision in the pending case."))
  end
  append(related, certificate_signature(meta))

  -- ---- the signature after the body [signature-block]: 19.6 pt above; in the right half "Respectfully submitted,",
  -- 16.8 pt, the signature, the name in capitals, the signer's lines (italic, 0.5 em in); 11.2 pt, the date ----
  local closing = {}
  closing[#closing + 1] = PX({ keep = true, before = 392, ind = { HALF } }, xe.runs("Respectfully submitted,"))
  closing[#closing + 1] = PX({ keep = true, before = 336, ind = { HALF } }, xe.runs("/s/ ") .. R(sig.signer))
  local lines = sig.lines or {}
  closing[#closing + 1] = PX({ keep = #lines > 0 or DATE ~= nil, ind = { HALF } }, xe.runs(norm(text(sig.signer or ""))))
  for k, l in ipairs(lines) do
    closing[#closing + 1] = PX({ keep = k < #lines or DATE ~= nil, ind = { HALF + 140 } }, R(l, { i = true }))
  end
  if DATE then
    closing[#closing + 1] = PX({ before = 224 }, R(DATE))
  end

  -- ---- addendum: its own contents of level-2 headings ----
  local addendum = {}
  if has_addendum then
    addendum[#addendum + 1] = heading_1({ pandoc.Str("Addendum") }, true)
    addendum[#addendum + 1] = heading_1({ pandoc.Str("Table of Contents") })
    local ad = pandoc.Pandoc(add):walk({ Link = link_filter }):walk({ Inlines = xe.inlines })
    local nadd = 0
    for _, b in ipairs(ad.blocks) do
      if b.t == "Header" and b.level == 2 then
        nadd = nadd + 1
        local id = "a:" .. nadd
        need_pattern("notoc", "add", id, text(b.content))
        addendum[#addendum + 1] = entry(2, nil, xe.inl(b.content), id, 0)
      end
    end
    local first = true
    for _, b in ipairs(ad.blocks) do
      if b.t == "Header" then
        -- [style-heading] an unnumbered sub-heading: bold, at the margin; 16.8 pt above, 12.6 pt below
        addendum[#addendum + 1] = PX({ style = "Heading" .. b.level, keep = true, brk = first, before = first and 0 or 336,
          after = 252, ind = { 0, nil, 0 }, jc = "left" }, xe.inl(b.content, { b = true }))
      elseif first then
        addendum[#addendum + 1] = PX({ brk = true }, "")
        addendum[#addendum + 1] = b
      else
        addendum[#addendum + 1] = b
      end
      first = false
    end
  end

  -- ---- certificates [certificate-of-compliance]: Federal Circuit Form 19 ----
  local certs = {}
  certs[#certs + 1] = heading_1({ pandoc.Str("Certificate of Compliance with Type-Volume Limitations") }, true)
  certs[#certs + 1] = PX({}, xe.runs("Case Number: ") .. R(meta.case_number) .. xe.BR .. xe.runs("Short Case Caption: ") ..
    R(meta.short_caption or meta.brief_title))
  certs[#certs + 1] = PX({ before = 280 }, xe.runs("The foregoing filing complies with the relevant type-volume limitation of the Federal Rules of Appellate Procedure and Federal Circuit Rules because it meets one of the following:"))
  -- [option-row]: the box in a 0.35 in column 0.35 in from the margin, the text hanging after it; 11.2 pt around
  local function option(checked, s)
    return PX({ lines = true, tabs = '<w:tabs><w:tab w:val="left" w:pos="1008"/></w:tabs>', before = 224, after = 224,
      ind = { 1008, 504 } }, checkbox(checked) .. xe.runs("\t" .. s))
  end
  certs[#certs + 1] = option(true, "the filing has been prepared using a proportionally-spaced typeface and includes " .. group_digits(words) .. " words.")
  certs[#certs + 1] = option(false, "the filing has been prepared using a monospaced typeface and includes ____ lines of text.")
  certs[#certs + 1] = option(false, "the filing contains ____ pages / ____ words / ____ lines of text, which does not exceed the maximum authorized by this court\u{2019}s order (ECF No. ____).")
  certs[#certs + 1] = PX({ lines = true, before = 448 }, xe.runs("Date: ") .. R(DATE) .. xe.BR ..
    xe.runs("Signature: /s/ ") .. R(sig.signer) .. xe.BR .. xe.runs("Name: " .. norm(text(sig.signer or ""))))

  -- ---- certificate of service (Form 30), only when the sample asks for it [certificate-of-service] ----
  if meta.service and meta.service.certificate then
    certs[#certs + 1] = heading_1({ pandoc.Str("Certificate of Service") }, true, true)
    certs[#certs + 1] = PX({}, xe.runs("I hereby certify under penalty of perjury that on ") .. R(DATE) ..
      xe.runs(", a copy of the foregoing \u{201C}") .. R(meta.brief_title) ..
      xe.runs("\u{201D} was filed electronically and served via the Court\u{2019}s ECF system."))
    local unreg = meta.service.unregistered or {}
    if #unreg > 0 then
      certs[#certs + 1] = PX({ before = 280 }, xe.runs("I further certify that on the same date I served the foregoing by U.S. Mail on the following persons, who are not registered for electronic filing:"))
      for _, u in ipairs(unreg) do
        certs[#certs + 1] = PX({ lines = true, before = 196, ind = { 720 } }, R(u.name) .. xe.runs(", ") .. R(u.address))
      end
    end
    append(certs, certificate_signature(meta))
  end

  -- ---- assemble: cover | front matter (roman) | body (arabic) | addendum (Add-) | certificates (arabic) ----
  local result = {}
  append(result, cover(meta))
  result[#result + 1] = section_end(nil)
  append(result, front)
  append(result, toc)
  append(result, toa)
  append(result, related)
  result[#result + 1] = section_end("rIdFooterArabic", "lowerRoman", "1")
  append(result, body_blocks)
  append(result, closing)
  result[#result + 1] = section_end("rIdFooterArabic", "decimal", "1")
  append(result, addendum)
  if has_addendum then
    result[#result + 1] = section_end("rIdFooterAdd", "decimal", "1")
  end
  append(result, certs)

  local pf = os.getenv("CAFC_PATTERNS")
  local f = pf and io.open(pf, "w")
  if f then
    f:write(table.concat(PATTERNS, "\n"), "\n")
    f:close()
  end
  doc.blocks = result
  return doc
end

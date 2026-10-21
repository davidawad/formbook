-- ca9.lua (docx engine): the ca9 principal brief as Word paragraphs and sections (typst: ca9-brief.typ,
-- latex: template.tex). pandoc writes the body text (paragraphs, quotations, lists, footnotes) with
-- docx/reference.docx; this filter writes what needs Word formatting:
--   * the cover (FRAP 32(a)(2)), the table of contents, the table of authorities, the signature block, the
--     statement of related cases (Form 17), the certificate of compliance (Form 8), the certificate of service
--     (Form 15) and the addendum (Circuit Rule 28-2.7), as paragraphs with explicit spacing, indents and tabs;
--   * the heading labels (I., A., 1., a. in the Argument; A., 1., a., (1) elsewhere) and each heading's outline
--     level (Heading 1-5 styles, so the PDF has bookmarks);
--   * the pages in the two tables. fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of every heading and
--     citation in that PDF (the needles this filter writes), and renders again with those pages (the pages file
--     this filter reads);
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and
--     certificates (1, 2 ...), addendum (Add-1 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local TOC_DEPTH = 4    -- heading levels listed in the table of contents (typst: toc-depth)
local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local TAB = 720        -- half an inch (para-indent, label width), in twips
local TEXT_W = 9360    -- the text width, 6.5 in
local TAB_R = 9340     -- the right tab of the tables: 1 pt inside the margin (a glyph may overhang its advance)
local PNUM_TOC = 720   -- the column the contents' page numbers keep to themselves (latex: \ca@rtoc, 36 bp)
local PNUM_TOA = 1120  -- the column of the authorities' page lists (latex: \ca@rtoa, 56 bp)
local HALF_W = 4680    -- the middle of the text: designations, counsel and signature blocks start here
local SINGLE = 340     -- single-spaced material (headings, cover, tables, certificates): 17 pt line (typst pitch-single)
local DOUBLE = 588     -- body text (reference.docx Body Text): 29.4 pt, 2.1 x 14 pt (CA9-FORM-003; typst pitch-double)
local HEAD = 400       -- section headings: 20 pt line (typst pitch-heading)
local HEAD_SZ = 32     -- section headings: 16 pt (half points; typst heading-size)
-- Exact line spacing throughout: Word sets each line in a box of that height, the baseline at 0.8 of it, which is
-- the layout the typst and LaTeX engines reproduce (docs/EVAL-LOOP.md, "Cross-engine gate"). Spacing between
-- paragraphs is the larger of the one's after and the next one's before, and is dropped at the top of a page.
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)

local stringify = pandoc.utils.stringify

-- ---------------------------------------------------------------------------
-- XML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function merge(a, b)
  local out = {}
  for k, v in pairs(a or {}) do out[k] = v end
  for k, v in pairs(b or {}) do out[k] = v end
  return out
end

local function rpr(o)
  local x = ""
  if o.b then x = x .. "<w:b/><w:bCs/>" end
  if o.i then x = x .. "<w:i/><w:iCs/>" end
  if o.caps then x = x .. "<w:caps/>" end
  if o.sz then x = x .. '<w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/>' end
  if o.u then x = x .. '<w:u w:val="single"/>' end
  if o.box then x = x .. '<w:bdr w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

-- Text with tabs (\t) as Word runs. No line breaks are ever written: lines wrap where they wrap.
local function runs(text, o)
  local x = rpr(o or {})
  local out = {}
  local pos = 1
  while pos <= #text do
    if text:sub(pos, pos) == "\t" then
      out[#out + 1] = "<w:r>" .. x .. "<w:tab/></w:r>"
      pos = pos + 1
    else
      local e = text:find("\t", pos, true) or (#text + 1)
      -- a hyphen before a digit does not end a line ("ER-178-82"; Unicode line breaking, as typst breaks)
      local t = esc(text:sub(pos, e - 1)):gsub("%-(%d)", '</w:t><w:noBreakHyphen/><w:t xml:space="preserve">%1')
      out[#out + 1] = "<w:r>" .. x .. '<w:t xml:space="preserve">' .. t .. "</w:t></w:r>"
      pos = e
    end
  end
  return table.concat(out)
end

-- pandoc's smart reading puts a no-break space after an abbreviation ("v. Jones", "ed. 2020"); typst's markdown
-- reader does not, so the space after a period is an ordinary one again (the engines must break lines alike).
local function unabbrev(inlines)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "Str" and el.text:find(".\u{00A0}", 1, true) then
      local rest = el.text
      while true do
        local s = rest:find(".\u{00A0}", 1, true)
        if not s then break end
        out:insert(pandoc.Str(rest:sub(1, s)))
        out:insert(pandoc.Space())
        rest = rest:sub(s + 3)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end

-- A section or pilcrow sign stays with the number after it, as in the typst template ("§ 1331" is not split).
local function bind_signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}" or a.text == "\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A hyphen before a digit does not end a line ("ER-178-82"): Word's non-breaking hyphen, as typst breaks (Unicode
-- line breaking keeps a hyphen with the number after it) and LibreOffice would not. The hyphen is its own run.
local NBH = pandoc.RawInline("openxml", "<w:r><w:noBreakHyphen/></w:r>")
local function nobreak_hyphens(inlines)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "Str" and el.text:find("%-%d") then
      local rest = el.text
      while true do
        local s = rest:find("%-%d")
        if not s then break end
        if s > 1 then out:insert(pandoc.Str(rest:sub(1, s - 1))) end
        out:insert(NBH)
        rest = rest:sub(s + 1)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end

-- Pandoc inlines (or a metadata value) as Word runs; links keep their text.
local function inl(x, o)
  o = o or {}
  if x == nil then return "" end
  if type(x) == "string" then return runs(x, o) end
  x = bind_signs(unabbrev(x))
  local out = {}
  for _, el in ipairs(x) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = runs(el.text, o)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out[#out + 1] = runs(" ", o)
    elseif t == "Emph" then
      out[#out + 1] = inl(el.content, merge(o, { i = true }))
    elseif t == "Strong" then
      out[#out + 1] = inl(el.content, merge(o, { b = true }))
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = runs(q[1], o) .. inl(el.content, o) .. runs(q[2], o)
    elseif t == "Link" or t == "Span" or t == "SmallCaps" or t == "Underline" then
      out[#out + 1] = inl(el.content, o)
    else
      out[#out + 1] = runs(stringify(el), o)
    end
  end
  return table.concat(out)
end

-- Paragraph properties are given in the schema's order: style, keep, page break, border, tabs, spacing, indent,
-- justification, outline level. Word refuses a file whose paragraph properties are out of order or repeated.
local function para(props, body)
  return "<w:p><w:pPr>" .. table.concat(props) .. "</w:pPr>" .. body .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local KEEP = "<w:keepNext/><w:keepLines/>"
local LINES = "<w:keepLines/>"
local BREAK = "<w:pageBreakBefore/>"
-- A line break inside a paragraph: only the table of authorities uses one, after a case name (typst: linebreak()).
local BR = "<w:r><w:br/></w:r>"

local function style(id)
  return '<w:pStyle w:val="' .. id .. '"/>'
end

local function spacing(before, after, line)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before, after,
    line or SINGLE)
end

local function ind(left, hanging, first, right)
  local x = '<w:ind w:left="' .. (left or 0) .. '"'
  if right then x = x .. ' w:right="' .. right .. '"' end
  if hanging then x = x .. ' w:hanging="' .. hanging .. '"' end
  if first then x = x .. ' w:firstLine="' .. first .. '"' end
  return x .. "/>"
end

local function jc(v)
  return '<w:jc w:val="' .. v .. '"/>'
end

-- A dot leader to the right margin (the page number follows the last tab).
local function dot_tabs()
  return '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TAB_R .. '"/></w:tabs>'
end

-- A horizontal rule: an empty paragraph with a bottom border. `left`/`right` narrow it (the 2 in rules).
local function rule(kind, before, left_right)
  local b = kind == "double"
      and '<w:pBdr><w:bottom w:val="thickThinSmallGap" w:sz="12" w:space="1" w:color="000000"/></w:pBdr>'
      or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  return para({ b, spacing(before, 0, 120), ind(left_right or 0, nil, nil, left_right or 0) }, "")
end

-- The paragraph that ends a section: its sectPr is the section's (footer, page number format and start).
-- A section's properties: its footer (rIdFtrNone, rIdFtrPage or rIdFtrAdd, written by fb render), page number
-- format and start, letter paper with 1 in margins.
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="576" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties.
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Numbers, needles and pages
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

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing).
local needles = {}
-- The fallback is the text's first words (at least 8 letters and digits): a needle that runs over a page break
-- is not found whole, because the page's footnotes come between its two halves in the PDF text.
local function opening(text)
  local out = ""
  for w in text:gmatch("%S+") do
    out = out .. norm(w)
    if #out >= 8 then break end
  end
  return out:sub(1, NEEDLE_MAX)
end

local function need(id, kind, text, context)
  local short = opening(text)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- The pages of the first pass: id -> { page, label }. Absent on the first pass itself.
local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = label } end
  end
  f:close()
end

local function label_of(id)
  local l = labels[id]
  if l then return l.label end
  return "00" -- the first pass: a placeholder of the final width
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Headings
-- ---------------------------------------------------------------------------

-- The label of a numbered heading (typst heading-label). The Argument: I. / A. / 1. / a.; elsewhere: A. / 1. / a. / (1).
local function label(level, n, arg)
  if arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    return string.char(96 + n) .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

-- The indent of a sub-heading's label, in half inches (latex: \ca@subhead): the Argument's point is centered.
local function step(level, arg)
  if arg then return level - 2 end
  return level - 1
end

local function hstyle(level)
  return style("Heading" .. level)
end

-- A section heading (level 1, the tables, the certificates): bold capitals, centered (CA9-FORM-009).
-- `top`: the heading opens a page (no space above); `brk`: it also breaks the page (not after a section break).
-- typst `space`: the spacing above and below each kind of heading, in twips (21 / 15.4, 16.8 / 14, 15.4 / 12.6 pt).
local SPACE = {
  section = { 420, 308 },
  point = { 336, 280 },
  sub = { 308, 252 },
  plain = { 336, 252 },
}

local function section_heading(text, top, brk, plain)
  return para({ plain and "" or hstyle(1), KEEP, brk and BREAK or "", spacing(top and 0 or SPACE.section[1], SPACE.section[2], HEAD),
    ind(0, nil, 0), jc("center") }, runs(text:upper(), { b = true, sz = HEAD_SZ }))
end

-- A body heading (latex: \ca@hone .. \ca@hfive).
local function heading_xml(level, content, lab, arg)
  if level == 1 then return section_heading(stringify(content), false) end
  if arg and level == 2 then
    return para({ hstyle(2), KEEP, spacing(SPACE.point[1], SPACE.point[2]), ind(0, nil, 0), jc("center") },
      runs(lab .. " ", { b = true }) .. inl(content, { b = true }))
  end
  local k = step(level, arg)
  local o = { b = true, i = level >= 4 }
  return para({ hstyle(level), KEEP, spacing(SPACE.sub[1], SPACE.sub[2]), ind(TAB * (k + 1), TAB) },
    runs(lab .. "\t", o) .. inl(content, o))
end

-- One row of a table of contents (typst listing-row): label, title, a dot leader from the end of the title and the
-- page. The title wraps before the page column (the right indent); the right tab sits beyond it.
local function toc_row(item)
  local title = item.level == 1 and item.title:upper() or item.title
  local left, hanging, lead = 0, nil, ""
  if item.label then
    left, hanging = TAB * item.step + TAB, TAB
    lead = runs(item.label .. "\t", {})
  end
  return para({ LINES, dot_tabs(), spacing(item.level == 1 and 168 or 98, 0), ind(left, hanging, nil, PNUM_TOC) },
    lead .. runs(title .. "\t" .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities (latex: toa_block)
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

local occurrences = {} -- the authority links, in document order: { key, index }

local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function toa_rows(authorities)
  local used = {}
  for _, o in ipairs(occurrences) do used[o.key] = true end
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and a.kind and stringify(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      -- the group title; the first one carries the column heading "Page(s)" at the right margin (typst toa-section)
      local head = runs(g[2], { b = true })
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TAB_R .. '"/></w:tabs>',
        spacing(#out == 0 and 280 or 392, 56) }, head)
      for _, m in ipairs(members) do
        -- the distinct pages of the authority, in page order
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local k = l and l.page or -o.index
            if not seen[k] then
              seen[k] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
            end
          end
        end
        table.sort(pages, function(x, y) return x.page < y.page end)
        local list
        local list_w = 0
        if #pages >= PASSIM then
          list = runs("passim", { i = true })
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          list = runs(table.concat(l, ", "), {})
          -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): Times New
          -- Roman digits are 0.5 em (140 twips at 14 pt), a comma and a space 0.25 em each
          local s = table.concat(l, ", ")
          list_w = 0
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 140 or 70) end
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = g[1] == "case" }) .. runs(",", {}) .. BR
        end
        out[#out + 1] = para({ LINES, dot_tabs(), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. runs("\t", {}) .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (lib/typst/ca9-cover.typ, latex: the cover)
-- ---------------------------------------------------------------------------

local function need_meta(meta, k)
  if meta[k] == nil then error("ca9.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- Lines a text takes in a column of `chars` characters (an estimate: Times New Roman 14 pt averages about
-- 6.3 pt a character, so 6.5 in holds about 74).
local function est_lines(text, chars)
  return math.max(1, math.ceil(#stringify(text) / chars))
end

local function cover(meta)
  local sides = need_meta(meta, "caption")
  local counsel = need_meta(meta, "counsel")
  -- The gap between the cover's parts is the largest that keeps it on one page (typst: ca9-cover); the type
  -- size and line pitch never shrink. 9 in of text height = 648 pt, less a safety margin for the estimate.
  local lines = 1 + 2 + est_lines(need_meta(meta, "proceeding"), 70) + est_lines(need_meta(meta, "brief_title"), 60)
  if meta.district_court_case or meta.judge then lines = lines + 1 end
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do lines = lines + est_lines(n, 70) end
    lines = lines + 1 + (i < #sides and 1 or 0)
  end
  for _, g in ipairs(counsel) do
    for _, n in ipairs(g.names or {}) do lines = lines + est_lines(n, 32) end
    for _, l in ipairs(g.lines or {}) do lines = lines + est_lines(l, 32) end
  end
  lines = lines + 1 -- the telephone
  local free = (612 - lines * SINGLE / 20 - 6 * 6) * 20 -- twips left for the 12 gaps
  local gap = math.max(0, math.min(320, math.floor(free / 12.6)))

  local out = {}
  local function add(x) out[#out + 1] = x end
  add(para({ KEEP, spacing(0, 0), jc("center") }, runs("No. ", { b = true }) .. inl(meta.case_number, { b = true })))
  add(rule("double", math.floor(gap * 0.6)))
  -- the court's name on two lines, broken after APPEALS (lib/typst/ca9-cover.typ)
  add(para({ spacing(gap, 0), jc("center") },
    runs("IN THE UNITED STATES COURT OF APPEALS", { b = true }) .. BR .. runs("FOR THE NINTH CIRCUIT", { b = true })))
  add(rule("short", gap, 3240))
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do
      add(para({ spacing((i == 1 and k == 1) and gap or 0, 0), jc("center") }, inl(n, {})))
    end
    add(para({ spacing(0, 0), ind(HALF_W) }, inl(side.designation, {})))
    if i < #sides then
      add(para({ spacing(math.floor(gap * 0.3), math.floor(gap * 0.3)), jc("center") }, runs("v.", {})))
    end
  end
  add(rule("short", gap, 3240))
  add(para({ spacing(gap, 0), jc("center") }, inl(meta.proceeding, {})))
  if meta.district_court_case or meta.judge then
    local x = ""
    if meta.district_court_case then x = runs("D.C. No. ", {}) .. inl(meta.district_court_case, {}) end
    if meta.district_court_case and meta.judge then x = x .. runs("; ", {}) end
    if meta.judge then x = x .. inl(meta.judge, {}) end
    add(para({ spacing(0, 0), jc("center") }, x))
  end
  add(rule("short", gap, 3240))
  add(para({ spacing(gap, 0), jc("center") }, inl(meta.brief_title, { b = true, caps = true })))
  add(rule("short", gap, 3240))
  -- counsel (FRAP 32(a)(2)(F)): name, office address and telephone number
  for gi, g in ipairs(counsel) do
    local first = true
    local function cl(body)
      add(para({ LINES, spacing(first and (gi == 1 and gap or 100) or 0, 0), ind(HALF_W) }, body))
      first = false
    end
    for _, n in ipairs(g.names or {}) do cl(inl(n, {})) end
    local ls = {}
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = l end
    if g.phone then ls[#ls + 1] = g.phone elseif gi == #counsel then ls[#ls + 1] = need_meta(meta, "phone") end
    for _, l in ipairs(ls) do cl(inl(l, { i = true })) end
  end
  add(rule("double", gap))
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Signature blocks and certificates (latex: the signature block, Forms 17, 8 and 15)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  -- typst signature-block: "Respectfully submitted," then 16.8 pt, the signature and the signer's lines in the right
  -- half (each further line 0.5 em in), then 11.2 pt and the date at the margin
  out[#out + 1] = para({ KEEP, spacing(392, 0), ind(HALF_W) }, runs("Respectfully submitted,", {}))
  out[#out + 1] = para({ KEEP, spacing(336, 0), ind(HALF_W) }, runs("s/ " .. signer, {}))
  out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W) }, runs(signer:upper(), {}))
  for _, l in ipairs(sig.lines or {}) do
    out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 140) }, inl(l, { i = true }))
  end
  if meta.date then
    out[#out + 1] = para({ LINES, spacing(224, 0), ind(0) }, inl(meta.date, {}))
  end
  return table.concat(out)
end

-- The signature under a court form (typst form-sig-line): two columns, "s/ Name" over "Signature" at the margin and
-- the date over "Date" in the right one (the columns are 1fr with a 1 em gutter: the right one starts 241 pt in).
local FORM_COL = 4820
local function form_signature(meta)
  local signer = stringify(meta.signature.signer)
  local tab = '<w:tabs><w:tab w:val="left" w:pos="' .. FORM_COL .. '"/></w:tabs>'
  local date = meta.date and inl(meta.date, {}) or ""
  return para({ KEEP, tab, spacing(448, 0), ind(0) }, runs("s/ " .. signer .. "\t", {}) .. date)
    .. para({ LINES, tab, spacing(0, 0), ind(0) }, runs("Signature\tDate", {}))
end

local function case_line(meta)
  return para({ spacing(0, 280), ind(0) }, runs("9th Cir. Case Number(s) ", {}) .. inl(meta.case_number, {}))
end

local function text_para(body, after)
  return para({ spacing(0, after or 280), ind(0) }, body)
end

-- A row of a form (typst option-row): a drawn box (a bordered run: no symbol font, so no fallback face), X when
-- selected, in a 1.6 em column; the text hangs under the text.
local function option(checked, body, keep, indent)
  indent = indent or 0
  local box = runs(checked and "X" or "\u{00A0}\u{00A0}\u{00A0}", { box = true })
  local left = indent + 448
  local tabs, lead = "", ""
  if indent > 0 then
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. indent .. '"/></w:tabs>'
    lead = runs("\t", {})
  end
  return para({ keep and KEEP or LINES, tabs, spacing(224, 0), ind(left, left) }, lead .. box .. runs("\t", {}) .. body)
end

local function related_cases(meta)
  local rc = meta.related_cases or {}
  local status = rc.status and stringify(rc.status) or "none"
  local out = { section_heading("Statement of Related Cases", true, true), case_line(meta),
    text_para(runs("The undersigned attorney or self-represented party states the following:", {}), 0) }
  out[#out + 1] = option(status == "none", runs("I am unaware of any related cases currently pending in this court.", {}))
  out[#out + 1] = option(status == "other-briefs", runs("I am unaware of any related cases currently pending in this "
    .. "court other than the case(s) identified in the initial brief(s) filed by the other party or parties.", {}))
  out[#out + 1] = option(status == "pending", runs("I am aware of one or more related cases currently pending in "
    .. "this court. The case number and name of each related case and its relationship to this case are:", {}), true)
  if status == "pending" then
    for _, c in ipairs(rc.cases or {}) do
      out[#out + 1] = para({ KEEP, spacing(196, 0), ind(896, 448) }, runs("No. ", {}) .. inl(c.number, {})
        .. runs(", ", {}) .. inl(c.name, { i = true }) .. runs(" (", {}) .. inl(c.relationship, {}) .. runs(").", {}))
    end
  end
  out[#out + 1] = form_signature(meta)
  return table.concat(out)
end

local BASES = {
  { "standard", "complies with the word limit of Cir. R. 32-1." },
  { "cross-appeal", "is a cross-appeal brief and complies with the word limit of Cir. R. 28.1-1." },
  { "amicus", "is an amicus brief and complies with the word limit of FRAP 29(a)(5), Cir. R. 29-2(c)(2), or Cir. R. 29-2(c)(3)." },
  { "death-penalty", "is for a death penalty case and complies with the word limit of Cir. R. 32-4." },
  { "longer", "complies with the longer length limit permitted by Cir. R. 32-2(b) because (select only one):" },
  { "longer-joint", "it is a joint brief submitted by separately represented parties." },
  { "longer-multiple", "a party or parties are filing a single brief in response to multiple briefs." },
  { "longer-response-to-joint", "a party or parties are filing a single brief in response to a longer joint brief." },
  { "court-order", "complies with the length limit designated by court order dated " },
  { "motion-to-exceed", "is accompanied by a motion to file a longer brief pursuant to Cir. R. 32-2(a)." },
}

local function compliance(meta, words)
  local basis = meta.word_limit_basis and stringify(meta.word_limit_basis) or "standard"
  local manual = meta.manual_image_words and stringify(meta.manual_image_words) or "0"
  local out = { section_heading("Certificate of Compliance", true, true), case_line(meta),
    text_para(runs("I am the attorney or self-represented party.", {})),
    text_para(runs("This brief contains " .. group_digits(words) .. " words, including " .. manual
      .. " words manually counted in any visual images, and excluding the items exempted by FRAP 32(f). The brief\u{2019}s "
      .. "type size and typeface comply with FRAP 32(a)(5) and (6).", {})),
    text_para(runs("I certify that this brief (select only one):", {}), 0) }
  for i, b in ipairs(BASES) do
    local on = basis == b[1] or (b[1] == "longer" and basis:match("^longer%-") ~= nil)
    local text = b[2]
    if b[1] == "court-order" then
      text = text .. (meta.court_order_date and stringify(meta.court_order_date) or "__________") .. "."
    end
    out[#out + 1] = option(on, runs(text, {}), i == #BASES, b[1]:match("^longer%-") and 448 or 0)
  end
  out[#out + 1] = form_signature(meta)
  return table.concat(out)
end

local function service(meta)
  local svc = meta.service or {}
  local out = { section_heading("Certificate of Service", true, true), case_line(meta),
    text_para(runs("I hereby certify that I electronically filed the foregoing/attached document(s) on this date with "
      .. "the Clerk of the Court for the United States Court of Appeals for the Ninth Circuit using the Appellate "
      .. "Electronic Filing system.", {})) }
  if svc.unregistered and #svc.unregistered > 0 then
    out[#out + 1] = text_para(runs("Service on Case Participants Who Are NOT Registered for Electronic Filing:", { b = true }))
    out[#out + 1] = text_para(runs("I certify that I served the foregoing/attached document(s) on this date by hand "
      .. "delivery, mail, third party commercial carrier for delivery within 3 calendar days, or, having obtained prior "
      .. "consent, by email to the following unregistered case participants (list each name and mailing/email address):", {}), 0)
    for _, u in ipairs(svc.unregistered) do
      out[#out + 1] = para({ LINES, spacing(200, 0), ind(TAB) }, inl(u.name, {}) .. runs(", ", {}) .. inl(u.address, {}))
    end
  end
  out[#out + 1] = para({ spacing(280, 280), ind(0) },
    runs("Description of Document(s) (required for all documents):", { b = true }))
  out[#out + 1] = para({ KEEP, spacing(0, 0), ind(0) }, inl(meta.brief_title, {}))
  out[#out + 1] = form_signature(meta)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Word count (latex ca9.lua: the same count, so every engine certifies the same number)
-- ---------------------------------------------------------------------------

local function words_in(s)
  s = s:gsub("\194\160", " ")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do n = n + count_words(item) end
    elseif b.t == "BlockQuote" then
      n = n + count_words(b.content)
    else
      n = n + words_in(stringify(b))
      pandoc.Pandoc({ b }):walk({ Note = function(note) n = n + count_words(note.content) end })
    end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Citations, in document order (the needles of the table of authorities)
-- ---------------------------------------------------------------------------

local scan_blocks

local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local key = el.target:sub(5)
      occurrences[#occurrences + 1] = { key = key, index = #occurrences + 1 }
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      need("T:" .. #occurrences, in_note and "N" or "B", stringify(el.content), stringify(rest))
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

local function strip_links(blocks)
  return pandoc.Pandoc(blocks):walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
    Inlines = function(l) return nobreak_hyphens(bind_signs(unabbrev(l))) end,
  }).blocks
end

-- A list as paragraphs of the style "List Item" (typst list-item): the number or bullet, a tab to the half inch, the
-- text hanging there, double-spaced like the body. Items of more than one paragraph stay a Word list.
local function list_items(b)
  if b.t ~= "OrderedList" and b.t ~= "BulletList" then return { b } end
  local out = {}
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  local delim = b.t == "OrderedList" and b.listAttributes.delimiter or "Period"
  for _, item in ipairs(b.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then return { b } end
    local lab = "\u{2022}"
    if b.t == "OrderedList" then
      lab = delim == "OneParen" and (n .. ")") or delim == "TwoParens" and ("(" .. n .. ")") or (n .. ".")
    end
    local inlines = pandoc.Inlines({ pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
    inlines:extend(item[1].content)
    out[#out + 1] = pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = "List Item" })
    n = n + 1
  end
  return out
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- The text a heading's needle continues with: the start of the block after it.
local function next_text(blocks, i)
  local b = blocks[i + 1]
  if not b then return "" end
  return stringify(b):sub(1, 40)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}

  -- the body and the addendum
  local body_in, add_in, in_add = {}, {}, false
  for _, b in ipairs(doc.blocks) do
    if not in_add and b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "addendum" then
      in_add = true
    elseif in_add then
      add_in[#add_in + 1] = b
    else
      body_in[#body_in + 1] = b
    end
  end
  local words = count_words(body_in)

  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "Page(s)")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles).
  local headings = {}
  local body = {}
  local in_arg = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n = 0
  for i, b in ipairs(body_in) do
    if b.t == "Header" then
      if b.level > 5 then error("ca9.lua: headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then in_arg = norm(stringify(b.content)) == "argument" end
      local lab = b.level == 1 and "" or label(b.level, counts[b.level], in_arg)
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", lab .. stringify(b.content), next_text(body_in, i))
      if b.level <= TOC_DEPTH then
        local point = in_arg and b.level == 2
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = stringify(b.content), step = point and 0 or step(b.level, in_arg) }
      end
      body[#body + 1] = raw(heading_xml(b.level, b.content, lab, in_arg))
    else
      scan_blocks({ b }, false)
      for _, x in ipairs(list_items(b)) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("ca9.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  -- the table of authorities' needle goes on with its first group title (the contents list the same title)
  for _, g in ipairs(GROUPS) do
    local used = false
    for _, o in ipairs(occurrences) do
      local a = authorities[o.key]
      if a and a.kind and stringify(a.kind) == g[1] then used = true end
    end
    if used then
      for _, n in ipairs(needles) do
        if n.id == "S:toa" then n.needle = norm("Table of Authorities " .. g[2]):sub(1, NEEDLE_MAX) end
      end
      break
    end
  end
  body = strip_links(body)
  -- The last paragraph stays with the signature block (typst: the tail block is kept with the signature).
  local last = body[#body]
  if last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end

  local svc = meta.service and meta.service.certificate
  local with_service = svc == true or (svc ~= nil and stringify(svc) == "true")
  need("H:related", "B", "Statement of Related Cases", "9th Cir. Case Number")
  need("H:compliance", "B", "Certificate of Compliance", "9th Cir. Case Number")
  if with_service then need("H:service", "B", "Certificate of Service", "9th Cir. Case Number") end

  -- The addendum: unnumbered headings; its level-2 headings are listed in its own contents.
  local add_items, add_body = {}, {}
  if #add_in > 0 then
    need("S:add", "B", "Addendum", "Table of Contents")
    for i, b in ipairs(add_in) do
      if b.t == "Header" then
        local id = "A:" .. i
        if b.level == 2 then
          add_items[#add_items + 1] = { id = id, level = 2, title = stringify(b.content) }
          need(id, "B", stringify(b.content), next_text(add_in, i))
        end
        add_body[#add_body + 1] = raw(para({ hstyle(math.min(b.level, 5)), KEEP, spacing(440, 360), ind(0, nil, 0) },
          inl(b.content, { b = true })))
      else
        scan_blocks({ b }, false)
        for _, x in ipairs(list_items(b)) do add_body[#add_body + 1] = x end
      end
    end
    add_body = strip_links(add_body)
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: each section starts at the page of a needle (format, prefix)
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  if #add_in > 0 then nl[#nl + 1] = "#section\tS:add\tdecimal\tAdd-" end
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  -- the last section is the document's own sectPr: arabic from 1, or Add-1 when the addendum ends the brief
  write_file("FORMBOOK_FINAL", sect_pr(#add_in > 0 and "rIdFtrAdd" or "rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): the table of contents, the table of authorities
  -- typst toc-section: the title (a section heading that is not itself listed) and "Page" over the page column
  add(raw(section_heading("Table of Contents", true, false, true)))
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, nil, 20), jc("right") }, runs("Page", { b = true, u = true }))))
  local items = { { id = "S:toa", level = 1, title = "Table of Authorities" } }
  for _, h in ipairs(headings) do items[#items + 1] = h end
  items[#items + 1] = { id = "H:related", level = 1, title = "Statement of Related Cases" }
  items[#items + 1] = { id = "H:compliance", level = 1, title = "Certificate of Compliance" }
  if with_service then items[#items + 1] = { id = "H:service", level = 1, title = "Certificate of Service" } end
  if #add_in > 0 then items[#items + 1] = { id = "S:add", level = 1, title = "Addendum" } end
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...), the signature, and the statement and certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(related_cases(meta)))
  add(raw(compliance(meta, words)))
  if with_service then add(raw(service(meta))) end

  -- Section 4: the addendum (Add-1 ...), with its own contents; FORMBOOK_FINAL closes it with the last section's footer
  if #add_in > 0 then
    add(section("rIdFtrPage", "decimal", 1))
    add(raw(section_heading("Addendum", true)))
    add(raw(section_heading("Table of Contents", false, false, true)))
    for _, it in ipairs(add_items) do
      add(raw(para({ LINES, dot_tabs(), spacing(98, 0), ind(0, nil, nil, PNUM_TOC) }, runs(it.title .. "\t" .. label_of(it.id), {}))))
    end
    -- the items start on the page after the addendum's contents (typst and latex do the same)
    if add_body[1] and add_body[1].t == "RawBlock" then
      add_body[1] = raw((add_body[1].text:gsub("<w:keepLines/>", "<w:keepLines/>" .. BREAK, 1)))
    else
      add(raw(para({ BREAK, spacing(0, 0, 20) }, "")))
    end
    for _, x in ipairs(add_body) do add(x) end
  end

  doc.blocks = out
  doc.meta.date = nil -- the date is printed by the signature blocks only, not by pandoc at the top
  doc.meta.title = nil
  return doc
end

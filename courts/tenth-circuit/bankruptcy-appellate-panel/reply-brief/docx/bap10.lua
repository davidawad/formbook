-- bap10 brief, DOCX engine (docs/DOCX.md): the markdown contract -> Word, on docx/reference.docx.
-- Mirrors the typst template (typst/bap10-<kind>.typ) on the cross-engine layout model (lib/docx/xengine.lua;
-- docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in exact line boxes of the typst pitches (31.4 pt body,
-- 20 pt single, 23 pt section headings), the typst spaces between blocks (twips = 20 x pt), first-fit breaking on
-- typst's break opportunities. pandoc writes the body text (paragraphs, quotations, lists, footnotes) with the styles
-- of reference.docx; this filter writes the cover, the disclosure, the table of contents, the table of authorities,
-- the headings with their labels, the signature, the certificate of compliance and the statement of related cases.
-- Pages: fb render (tools/fb/src/docxpass.rs) renders once, finds the page of every heading and citation in that
-- PDF (the needles this filter writes to FORMBOOK_NEEDLES), and renders again with those pages (FORMBOOK_PAGES)
-- until they settle. Three sections give the typst page numbering: no number on the cover, lowercase roman for the
-- front matter, arabic from 1 for the body (fb render writes the footers; the last section is FORMBOOK_FINAL).
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

-- The only part that differs between the three copies
local CFG = {
  kind = "reply-brief",
  word_limit = 6500,
  word_limit_note = "FRBP 8015(a)(7)(B)(ii)",
}

local COURT_NAME = "United States Bankruptcy Appellate Panel of the Tenth Circuit"
local TYPE_SIZE = 14     -- points (typst type-size)
local TOC_DEPTH = 4      -- typst toc-depth
local PASSIM = 7         -- typst passim-threshold
local TAB = 720          -- half an inch (para-indent, heading-tab), in twips
local TEXT_W = 9360      -- the text width, 6.5 in
local HALF_W = 4680      -- pad(left: 50%): counsel, designations and signature blocks start here
local STEP = 140         -- h(0.5em): the counsel and signature lines step in under the name
local PNUM_TOC = 720     -- typst toc-page-col, 36 pt
local PNUM_TOA = 1120    -- typst toa-page-col, 56 pt
local DOUBLE = 628       -- typst pitch-double, 31.4 pt (reference.docx Body Text)
local SINGLE = 400       -- typst pitch-single, 20 pt
local HEAD = 460         -- typst pitch-heading, 23 pt (section headings)
local HEAD_SZ = 32       -- typst heading-size, 16 pt (half points)
local NEEDLE_MAX = 60    -- a needle is a prefix of the text (letters and digits only)

local stringify = pandoc.utils.stringify
local xe = require("docx.xengine")
local runs, inl = xe.runs, xe.inl
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.LEAD
local list_items = xe.list_items
-- A body heading is not "kept with next" in Word: LibreOffice moves a kept heading and the whole paragraph after it
-- to the next page when that paragraph would split there with a line moved for widow control (typst splits it, the
-- heading staying with its first lines). The heading is kept with its text through the page map instead (see
-- `sticky` below). Its lines stay together.
local NOKEEP = '<w:keepNext w:val="0"/><w:keepLines/>'

local function fail(msg) error("bap10 " .. CFG.kind .. ": " .. msg, 0) end

-- Exact line spacing; single-spaced unless another pitch is given.
local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

local function need_meta(meta, k)
  if meta[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

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

-- ---------------------------------------------------------------------------
-- Sections and rules
-- ---------------------------------------------------------------------------

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, written by fb render), page number format and start,
-- letter paper with 1 in margins (FRBP 8015(a)(4)). The footer: typst footer-descent 30 % of the margin under the
-- text, a 20 pt line box.
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="628" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (a 1 pt line: it takes no room).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing). The fallback is the text's first words (at
-- least 8 letters and digits): a needle that runs over a page break is not found whole.
local needles = {}
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

-- The pages of the previous pass: id -> { page, label }. Absent on the first pass.
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
-- Headings (typst style-heading, heading-label, label-indent)
-- ---------------------------------------------------------------------------

-- Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
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

-- The left edge of a sub-heading's label in half inches: one step in from the margin, a step more per level; in the
-- Argument the point heading is centered, so its sub-headings start at the first step.
local function step(level, arg)
  return level - (arg and 3 or 2) + 1
end

-- A section heading (level 1 and the front and back matter): bold capitals, centered, 16 pt in a 23 pt line, 21 pt
-- above and 15.4 pt below. `top`: it opens a page (typst drops the space above there; Word keeps it after a break);
-- `brk`: it also breaks the page (not after a section break); `outline`: it has an outline level (a bookmark).
local function section_heading(text, top, brk, outline, keep)
  return para({ outline and style("Heading1") or "", keep or KEEP, brk and BREAK or "", spacing(top and 0 or 420, 308, HEAD),
    ind(0, nil, 0), jc("center") }, runs(text:upper(), { b = true, sz = HEAD_SZ }))
end

local function heading_xml(level, content, lab, arg)
  if level == 1 then return section_heading(stringify(content), false, false, true, NOKEEP) end
  if arg and level == 2 then
    -- the point heading: bold, centered, the roman numeral before it; 16.8 pt above, 14 pt below
    return para({ style("Heading2"), NOKEEP, spacing(336, 280), ind(0, nil, 0), jc("center") },
      runs(lab .. " ", { b = true }) .. inl(content, { b = true }))
  end
  -- the label in a half-inch box at its step, the text hanging after it; italic from level 4; 15.4 / 12.6 pt
  local k = step(level, arg)
  local o = { b = true, i = level >= 4 }
  return para({ style("Heading" .. level), NOKEEP, spacing(308, 252), ind(TAB * (k + 1), TAB) },
    runs(lab .. "\t", o) .. inl(content, o))
end

-- ---------------------------------------------------------------------------
-- Table of contents and table of authorities (typst listing-row)
-- ---------------------------------------------------------------------------

-- A dot leader to a right tab at the margin, beyond the right indent that keeps the page column free.
local function dot_tabs()
  return xe.leader_tab(TEXT_W)
end

-- One row of the table of contents: the label at its step (a point heading's at the margin), the title hanging a
-- half inch after it (a section's title hangs a half inch too), the leader and the page.
local function toc_row(item)
  local title = item.level == 1 and item.title:upper() or item.title
  local lead = ""
  local left = TAB
  if item.label then
    left = TAB * item.step + TAB
    lead = runs(item.label .. "\t", {})
  end
  return para({ LINES, dot_tabs(), spacing(item.level == 1 and 168 or 98, 0), ind(left, TAB, nil, PNUM_TOC) },
    lead .. runs(title .. LEAD .. label_of(item.id), {}))
end

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
  -- typst sort-key: lower case, letters, digits and single spaces
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  s = s:gsub("\u{00A0}", " "):lower():gsub("[^a-z0-9 ]", ""):gsub(" +", " ")
  return (s:gsub("^ ", ""):gsub(" $", ""))
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
      -- the group title, 14 pt under the heading (19.6 pt under the group before), 2.8 pt above its first entry; the
      -- first carries the column heading "Page(s)" at the right margin
      local head = runs(g[2], { b = true })
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TEXT_W .. '"/></w:tabs>',
        spacing(#out == 0 and 280 or 392, 56), ind(0, nil, 0) }, head)
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
          local s = table.concat(l, ", ")
          list = runs(s, {})
          -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): Liberation
          -- Serif digits are 0.5 em (140 twips at 14 pt), a comma and a space 0.25 em each
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 140 or 70) end
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = g[1] == "case" }) .. runs(",", {}) .. xe.BR
        end
        out[#out + 1] = para({ LINES, dot_tabs(), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. runs(LEAD, {}) .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body: FRBP 8015(a)(2)(A)-(F))
-- ---------------------------------------------------------------------------

-- Lines a text takes in a column `width` pt wide, broken first fit at spaces: Liberation Serif's advances (Times
-- metrics, 1/1000 em) at 14 pt; other characters count 0.5 em. An estimate for the cover's fit only.
local ADV = {
  regular = { upper = { 722, 667, 667, 722, 611, 556, 722, 722, 333, 389, 722, 611, 889, 722, 722, 556, 722, 667, 556, 611,
    722, 722, 944, 722, 722, 611 }, lower = { 444, 500, 444, 500, 444, 333, 500, 500, 278, 278, 500, 278, 778, 500, 500,
    500, 500, 333, 389, 278, 500, 500, 722, 500, 500, 444 } },
  bold = { upper = { 722, 667, 722, 722, 667, 611, 778, 778, 389, 500, 778, 667, 944, 722, 778, 611, 778, 722, 556, 667,
    722, 722, 1000, 722, 722, 667 }, lower = { 500, 556, 444, 556, 444, 333, 500, 556, 278, 333, 556, 278, 833, 556, 500,
    556, 556, 444, 389, 333, 556, 500, 722, 500, 500, 444 } },
}
local PUNCT = { [" "] = 250, [","] = 250, ["."] = 250, [":"] = 278, [";"] = 278, ["-"] = 333, ["("] = 333, [")"] = 333,
  ["'"] = 180, ["@"] = 921, ["/"] = 278, ["&"] = 778 }
local function est_lines(text, width, bold)
  local t = bold and ADV.bold or ADV.regular
  local function adv(s)
    local w = 0
    for c in s:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
      local b = c:byte()
      if #c == 1 and b >= 65 and b <= 90 then w = w + t.upper[b - 64]
      elseif #c == 1 and b >= 97 and b <= 122 then w = w + t.lower[b - 96]
      elseif #c == 1 and b >= 48 and b <= 57 then w = w + 500
      else w = w + (PUNCT[c] or 500) end
    end
    return w * 14 / 1000
  end
  local n, cur = 1, nil
  for word in stringify(text):gmatch("%S+") do
    local ww = adv(word)
    if cur == nil then cur = ww
    elseif cur + 3.5 + ww <= width then cur = cur + 3.5 + ww
    else n = n + 1; cur = ww end
  end
  return n
end

local function cover(meta)
  local sides = need_meta(meta, "caption")
  local groups = need_meta(meta, "counsel")
  -- typst cover-body: the parts one after another, 4.9 pt between any two (paragraphs and rules alike), and a space
  -- of `gap` (or a fraction of it) between the parts on top of that; the rules take no height. The gap is the
  -- largest of typst's steps (1, 0.8, 0.6 ... em) at which the cover fits the page (9 in, 648 pt); the type size
  -- and the line pitch never shrink. Counted here: lines (20 pt each), elements, and the gap's multiples.
  local S = 4.9
  local lines, elems, mult = 0, 0, 0.6 + 11 -- the gap before the case number, and the 11 between the parts
  local function el(n) lines = lines + n; elems = elems + 1 end
  el(1); elems = elems + 2; el(est_lines(COURT_NAME:upper(), 468, true)); elems = elems + 1 -- number, double rule, court, rule
  local function side_count(side)
    for _, n in ipairs(side.names or {}) do el(est_lines(n, 468)) end
    el(est_lines(side.designation, 234))
  end
  if meta.in_re then side_count(meta.in_re); mult = mult + 0.3 end
  for i, side in ipairs(sides) do
    side_count(side)
    if i < #sides then el(1); mult = mult + 0.6 end
  end
  if meta.bankruptcy then el(1); mult = mult + 0.5 end
  elems = elems + 1; el(est_lines(need_meta(meta, "proceeding"), 468))
  elems = elems + 1; el(est_lines(stringify(need_meta(meta, "brief_title")):upper(), 468, true))
  elems = elems + 1
  for gi, g in ipairs(groups) do
    for _, n in ipairs(g.names or {}) do lines = lines + est_lines(n, 234) end
    for _, l in ipairs(g.lines or {}) do lines = lines + est_lines(l, 227) end
    if gi == #groups then lines = lines + 2 end
  end
  elems = elems + 1 + 2 -- the counsel block, the double rule
  local g = 0
  for _, f in ipairs({ 1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0 }) do
    if lines * 20 + (elems - 1) * S + 2 * 2.5 + (#groups - 1) * 7 + mult * 14 * f <= 648 then g = f; break end
  end
  local G = 14 * g -- the gap in points
  local function tw(pt) return math.max(0, math.floor(pt * 20 + 0.5)) end

  local out = {}
  local function add(x) out[#out + 1] = x end
  local function centered(before, body)
    add(para({ KEEP, spacing(tw(before), 0), ind(0, nil, 0), jc("center") }, body))
  end
  -- a rule: a 1 pt line with a border under it (typst line(): no height), `before` pt under the text above
  local function rule(before, width, left_right)
    local b = '<w:pBdr><w:bottom w:val="single" w:sz="' .. width .. '" w:space="0" w:color="000000"/></w:pBdr>'
    add(para({ KEEP, b, spacing(tw(before - 1), 0, 20), ind(left_right or 0, nil, 0, left_right or 0) }, ""))
  end
  local SHORT = (TEXT_W - 2880) / 2 -- a 2 in rule, centered (typst short-rule)
  local function short_rule() rule(S + G, 6, SHORT) end
  -- typst double-rule: a 1.6 pt line, 2.5 pt (and the 4.9 pt between elements), a 0.5 pt line
  local function double_rule(before) rule(before, 12); rule(S + 2.5 - 1.5, 4) end
  local after_rule = S + G - 0.75 -- the text after a rule: the rule's own width is part of its paragraph
  local function side_block(side, before)
    for k, n in ipairs(side.names or {}) do centered(k == 1 and before or S, inl(n, {})) end
    add(para({ KEEP, spacing(tw(S), 0), ind(HALF_W, nil, 0) }, inl(side.designation, {})))
  end
  centered(0.6 * G, runs("BAP No. ", { b = true }) .. inl(meta.case_number, { b = true }))           -- (A)
  double_rule(S + G)
  centered(after_rule, runs(COURT_NAME:upper(), { b = true }))                                       -- (B)
  short_rule()
  -- (C) the title of the case (FRBP 8003(d)(2)): the debtor, if any, then the parties
  local before = after_rule
  if meta.in_re then
    side_block(meta.in_re, before)
    before = S + 0.3 * G
  end
  for i, side in ipairs(sides) do
    side_block(side, before)
    if i < #sides then
      centered(S + 0.3 * G, runs("v.", {}))
      before = S + 0.3 * G
    end
  end
  if meta.bankruptcy then
    add(para({ KEEP, spacing(tw(S + 0.5 * G), 0), ind(0, nil, 0), jc("right") }, inl(meta.bankruptcy, {})))
  end
  short_rule()
  centered(after_rule, inl(need_meta(meta, "proceeding"), {}))                                      -- (D)
  short_rule()
  centered(after_rule, inl(need_meta(meta, "brief_title"), { b = true, caps = true }))              -- (E)
  short_rule()
  -- (F) name, office address, telephone number and email address of counsel: the names, then the lines a half em
  -- in; 7 pt between the groups
  for gi, grp in ipairs(groups) do
    local first = true
    local function cl(body, step_in)
      add(para({ KEEP, spacing(first and tw(gi == 1 and after_rule or 7) or 0, 0), ind(HALF_W, nil, step_in or 0) }, body))
      first = false
    end
    for _, n in ipairs(grp.names or {}) do cl(inl(n, {})) end
    local ls = {}
    for _, l in ipairs(grp.lines or {}) do ls[#ls + 1] = l end
    if gi == #groups then
      ls[#ls + 1] = need_meta(meta, "phone")
      ls[#ls + 1] = need_meta(meta, "email")
    end
    for _, l in ipairs(ls) do cl(inl(l, { i = true }), STEP) end
  end
  double_rule(S + G)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Signature, certificate of compliance, statement of related cases
-- ---------------------------------------------------------------------------

-- typst signature-block: 19.6 pt above, "Respectfully submitted," in the right half, 16.8 pt, "/s/ Name", the name in
-- capitals and the signer's lines a half em in; then 11.2 pt and the date at the margin
local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = plain(need_meta(sig, "signer"))
  local out = {}
  out[#out + 1] = para({ KEEP, spacing(392, 0), ind(HALF_W, nil, 0) }, runs("Respectfully submitted,", {}))
  out[#out + 1] = para({ KEEP, spacing(336, 0), ind(HALF_W, nil, 0) }, runs("/s/ " .. signer, {}))
  out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 0) }, runs(signer:upper(), {}))
  for _, l in ipairs(sig.lines or {}) do
    out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W, nil, STEP) }, inl(l, { i = true }))
  end
  if meta.date then
    out[#out + 1] = para({ LINES, spacing(224, 0), ind(0, nil, 0) }, inl(meta.date, {}))
  end
  return table.concat(out)
end

-- A numbered paragraph of a certificate (typst: an enum item, the number in a half-inch box, the text hanging).
local function numbered(n, text, before)
  return para({ spacing(before, 0), ind(TAB, TAB) }, runs(n .. "\t" .. text, {}))
end

-- Certificate of Compliance (FRBP 8014(a)(10), 8015(h)); typst certificate-of-compliance
local function compliance(meta, words)
  local sig = need_meta(meta, "signature")
  local out = { section_heading("Certificate of Compliance", true, true, true) }
  out[#out + 1] = numbered("1.", "This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) "
    .. "because, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g) and 10th Cir. BAP L.R. "
    .. "8015-1(d), it contains no more than " .. group_digits(CFG.word_limit) .. " words. The brief contains "
    .. group_digits(words) .. " words, as counted by the drafting software.", 0)
  -- the check box: a ruled box around an X in a 21 pt column, 22.4 pt in; 11.2 pt above and below
  out[#out + 1] = para({ LINES, '<w:tabs><w:tab w:val="left" w:pos="868"/></w:tabs>', spacing(224, 224), ind(448, nil, 0) },
    runs("X", { box = true }) .. runs("\tthis brief contains " .. group_digits(words) .. " words.", {}))
  out[#out + 1] = numbered("2.", "This brief complies with the typeface requirements of Fed. R. Bankr. P. 8015(a)(5) and "
    .. "10th Cir. BAP L.R. 8015-1(b) because it has been prepared in a proportionally spaced typeface using "
    .. plain(need_meta(meta, "word_processor")) .. " in " .. TYPE_SIZE .. "-point " .. plain(need_meta(meta, "typeface"))
    .. " roman type.", 0)
  -- the signature: 22.4 pt above, in the right half
  out[#out + 1] = para({ KEEP, spacing(448, 0), ind(HALF_W, nil, 0) }, runs("/s/ " .. plain(sig.signer), {}))
  local last = not meta.date
  out[#out + 1] = para({ last and LINES or KEEP, spacing(0, 0), ind(HALF_W, nil, 0) },
    runs("Attorney for ", {}) .. inl(sig["for"] or "", {}))
  if meta.date then
    out[#out + 1] = para({ LINES, spacing(0, 0), ind(HALF_W, nil, 0) }, runs("Dated: ", {}) .. inl(meta.date, {}))
  end
  return table.concat(out)
end

-- Statement of Related Cases (10th Cir. BAP L.R. 8014-1): the last page; typst related-cases-page
local function related_cases(meta)
  local rc = need_meta(meta, "related_cases")
  local out = { section_heading("Statement of Related Cases", true, true, false) }
  if plain(rc.status or "none") == "none" then
    out[#out + 1] = para({ spacing(0, 0), ind(0, nil, 0) }, runs("The filer knows of no related case pending before the "
      .. "United States Supreme Court, any United States Court of Appeals, any United States District Court, or the "
      .. "Bankruptcy Appellate Panel.", {}))
  else
    out[#out + 1] = para({ spacing(0, 0), ind(0, nil, 0) }, runs("The following related case(s) are pending before the "
      .. "court(s) listed. A related case involves substantially the same litigants and substantially the same fact "
      .. "pattern or legal issues as this appeal.", {}))
    for _, c in ipairs(rc.cases or {}) do
      out[#out + 1] = para({ LINES, spacing(196, 0), ind(TAB, nil, 0) }, inl(c, {}))
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Word count: typst count-words, line by line on the markdown source, so every engine certifies the same number
-- (FRBP 8015(g): the statement regarding oral argument is not counted)
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then fail("no input file to count words from") end
  local h = io.open(f, "r")
  if not h then fail("cannot read " .. f) end
  local text = h:read("a")
  h:close()
  local lines, dashes = {}, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    else
      lines[#lines + 1] = line
    end
  end
  local n, skipping = 0, false
  for _, line in ipairs(lines) do
    if line:match("^#%s+[Ss]tatement of [Rr]elated [Cc]ases%s*$") then break end
    if line:match("^#%s+.*[Oo]ral [Aa]rgument") then skipping = true
    elseif skipping and line:match("^#%s") then skipping = false end
    if not skipping then
      local s = line
      s = s:gsub("<!%-%-.-%-%->", " ")
      s = s:gsub("^%[%^[^%]]+%]:", " ")
      s = s:gsub("%[%^[^%]]*%]", "")
      s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
      s = s:gsub("^#+%s+", "")
      s = s:gsub("^>%s?", "")
      s = s:gsub("^%s*[-*+]%s+", "")
      s = s:gsub("^%s*%d+[.)]%s+", "")
      s = s:gsub("\\(.)", "%1")
      s = s:gsub("%*", "")
      s = s:gsub("_", "")
      for _ in s:gmatch("%S+") do n = n + 1 end
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
    elseif b.t == "BlockQuote" or b.t == "Div" then
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
    Inlines = xe.inlines,
  }).blocks
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

-- A doubled section sign or pilcrow stays with the number after it ("§§ 157"; typst boxes it), as xe.inlines binds
-- a single one.
local function bind_double(l)
  for i = 1, #l - 1 do
    local a, b = l[i], l[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Inlines = bind_double })
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "email", "signature",
    "word_processor", "typeface", "related_cases" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}

  -- a "Statement of Related Cases" section is generated, not authored: anything from its heading on is dropped
  local body_in = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "statementofrelatedcases" then break end
    body_in[#body_in + 1] = b
  end

  local words = source_words()
  if words > CFG.word_limit then
    fail("the brief has " .. words .. " words; " .. CFG.word_limit_note .. " allows " .. CFG.word_limit)
  end

  if meta.disclosure then need("S:disc", "B", "Disclosure Statement", stringify(meta.disclosure):sub(1, 30)) end
  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "Page(s)")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles).
  local headings = {}
  local body = {}
  local in_arg = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n = 0
  -- A run of headings stays on the page of the text after it (typst: sticky blocks). From the pages of the previous
  -- pass: the run's first heading k breaks the page when it was left at the foot of a page whose text went on to the
  -- next (H:k before F:k), or when it opened a page anyway (E:k, the end of the block before it, on an earlier page:
  -- the break then changes nothing, and keeps the run where it went). E:k is searched as a footnote needle is (from
  -- the page the body has reached, moving nothing): its text may begin before the block's last citation.
  local function page(id) return labels[id] and labels[id].page or nil end
  local function sticky(k)
    local e, h, f = page("E:" .. k), page("H:" .. k), page("F:" .. k)
    return e ~= nil and h ~= nil and f ~= nil and (e < h or h < f)
  end
  local function text_of(b)
    return stringify(pandoc.Pandoc({ b }):walk({ Note = function() return {} end }).blocks)
  end
  local last_block, run = nil, nil -- the block before the current one (nil after a heading); the open run's heading
  for i, b in ipairs(body_in) do
    if b.t == "Header" then
      local opens = last_block ~= nil
      if opens then
        local t = text_of(last_block)
        need("E:" .. (h_n + 1), "N", t:sub(math.max(1, #t - 40)))
        run = h_n + 1
      end
      last_block = nil
      if b.level > 5 then fail("headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then
        local t = stringify(b.content):lower():match("^%s*(.-)%s*$")
        in_arg = (t == "argument" or t == "reply argument")
      end
      local lab = b.level == 1 and "" or label(b.level, counts[b.level], in_arg)
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", lab .. stringify(b.content), next_text(body_in, i))
      if b.level <= TOC_DEPTH then
        local point = in_arg and b.level == 2
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = stringify(b.content), step = point and 0 or step(b.level, in_arg) }
      end
      local x = heading_xml(b.level, b.content, lab, in_arg)
      -- the body opens a section (a new page): Word keeps space above there, typst drops it at the top of a page
      if #body == 0 then x = x:gsub('w:before="%d+"', 'w:before="0"', 1) end
      if opens and sticky(h_n) then
        x = x:gsub('w:before="%d+"', 'w:before="0"', 1):gsub("<w:keepLines/>", "<w:keepLines/>" .. BREAK, 1)
      end
      body[#body + 1] = raw(x)
    else
      if run then
        need("F:" .. run, "B", text_of(b):sub(1, 40))
        run = nil
      end
      last_block = b
      scan_blocks({ b }, false)
      for _, x in ipairs(list_items(b)) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      fail("link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
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

  need("H:compliance", "B", "Certificate of Compliance", "1. This brief complies")
  need("H:related", "B", "Statement of Related Cases", "The")

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: the front matter from its first page, the body from its first heading
  nl[#nl + 1] = "#section\t" .. (meta.disclosure and "S:disc" or "S:toc") .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): the disclosure, the table of contents, the table of authorities
  local first_top = false
  if meta.disclosure then
    add(raw(section_heading("Disclosure Statement", true, false, false)))
    local d = meta.disclosure
    local blocks = d.t == "MetaBlocks" and d or { pandoc.Plain(d) }
    for i, b in ipairs(blocks) do
      local il = b.content or pandoc.Inlines({})
      add(raw(para({ spacing(i == 1 and 0 or 280, 0), ind(0, nil, 0) }, inl(il, {}))))
    end
    first_top = true
  end
  -- typst toc-section: the title (a section heading that is not itself listed) and "Page" over the page column
  add(raw(section_heading("Table of Contents", true, first_top, false)))
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, 0, 20), jc("right") }, runs("Page", { b = true, u = true })))) -- 1 pt in: LibreOffice lets the underlined word overhang its advance
  local items = { { id = "S:toa", level = 1, title = "Table of Authorities" } }
  for _, h in ipairs(headings) do items[#items + 1] = h end
  items[#items + 1] = { id = "H:compliance", level = 1, title = "Certificate of Compliance" }
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true, true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3 (arabic from 1): the body, the signature, the certificate and the statement of related cases
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(compliance(meta, words)))
  add(raw(related_cases(meta)))

  doc.blocks = out
  doc.meta = pandoc.Meta({}) -- the frontmatter is read above; pandoc must not write its own title block
  return doc
end

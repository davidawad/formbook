-- Georgia Supreme Court brief, docx engine (docs/DOCX.md): the double-spaced briefs (answering, opening, reply share
-- this filter), built to the typst template (typst/ga-<doc type>.typ). pandoc writes the body (headings, paragraphs,
-- lists, quotations, footnotes) with docx/reference.xml's styles (Schola 13 pt in 31.2 pt lines, single lines 15.6 pt,
-- 11 pt notes in 13.2 pt lines); this filter writes what needs Word formatting:
--   * the cover (court, caption, case numbers, title, counsel), the table of contents and the table of authorities
--     (SCt R 19(1)(a)), the closing (the Rule 20(7) statement, the date, the signature blocks) and the certificate of
--     service (SCt R 14), as paragraphs and borderless tables with explicit spacing, indents and tabs, from the
--     frontmatter as written ($FORMBOOK_META: the strings typst sets, not pandoc's markdown reading of them);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of every
--     heading and citation in the LibreOffice PDF (the needles this filter writes) and renders again with those pages
--     ($FORMBOOK_PAGES), until they settle. A citation is a `[text](toa:key)` link; its page is the one it starts on
--     (typst tags its first word); seven pages or more read "passim";
--   * the sections whose footers number the pages: cover (none), front matter (ii, iii ...: the cover counts as i),
--     body, closing and certificate (1, 2 ...). The page number is the filter's own footer ($FORMBOOK_FOOTERS), the
--     last section $FORMBOOK_FINAL.
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every line and page breaks where the typst render
-- breaks it. The model is lib/docx/xengine.lua (the break rules of typst on every run, exact line spacing: each line a
-- box of its pitch, the space between paragraphs the larger of the two); the pitches and spaces below are the typst
-- template's, in twips (20 x pt).

local xe = require("docx.xengine")
local raw, para, jc, KEEP, LINES, BREAK = xe.raw, xe.para, xe.jc, xe.KEEP, xe.LINES, xe.BREAK
local stringify = pandoc.utils.stringify

-- The text width, 6.5 in, less what the right margin takes beyond 1 in (MARGIN_R). LibreOffice sets Schola a little
-- narrower than typst and starts each line 0.1 pt in (docs/EVAL-LOOP.md, "What the federal-appellate adoption
-- found"), so a line typst overflows by a hair would fit here. Measured on the three samples (answering, opening,
-- reply): a right margin of 1440 to 1442 twips breaks every line as typst does, 1443 moves a line of the answering
-- brief (p10); the middle of that range, never less than the 1 in of SCt R 16(5).
local MARGIN_R = 1441
local TEXT_W = 9360 - (MARGIN_R - 1440)
local FULL_W = 9360       -- the tables' width: typst's grids span the text width
local PITCH = 624         -- typst pitch-body: 31.2 pt, double spacing (SCt R 16(4))
local SINGLE = 312        -- typst pitch-single: 15.6 pt, 1.2 x 13 pt
local HALF = 156          -- typst half: 7.8 pt
local INDENT = 720        -- typst indent: 0.5 in
local TOC_COL = 720       -- typst toc-col: 36 pt
local TOA_COL = 1440      -- typst toa-col: 72 pt (a longer page list widens its own row's column)
local TOA_HANG = 576      -- typst toa-hang: 0.4 in
local CAPTION_GUTTER = 576 -- typst cover grid: 0.4 in between caption and case numbers
local GUTTER = 432        -- typst columns-of: 0.3 in between counsel, signature and service columns
local FOOTER = 552        -- the page number's line box ends 27.6 pt above the page edge (typst: 1 in margin, footer
                          -- descent 0.4 in, a 15.6 pt line)
local PASSIM_AT = 7       -- typst passim-at
local TOC_DEPTH = 2       -- heading levels in the table of contents
local NEEDLE_MAX = 60     -- a needle is a prefix of the text (letters and digits only)

local COURT_LINES = { "IN THE SUPREME COURT", "STATE OF GEORGIA" }
local CLOSING_SENTENCE = "This submission does not exceed the word-count limit imposed by Rule 20." -- SCt R 20(7)
local KINDS = {
  { "case", "CASES" }, { "statute", "STATUTES" }, { "constitution", "CONSTITUTIONAL PROVISIONS" },
  { "rule", "RULES" }, { "other", "OTHER AUTHORITIES" },
}

-- Before the leader tab of a table row: no-break spaces as wide as typst's 0.75 em (9.75 pt) between the text and the
-- leader. Schola's space is 0.278 em, so xe.LEAD's three are 10.8 pt (LibreOffice ignores character spacing on
-- them): two at 13 pt and one at 9 pt, 9.73 pt.
local LEAD_XML = '<w:r><w:t xml:space="preserve">\u{00A0}\u{00A0}</w:t></w:r><w:r><w:rPr><w:sz w:val="18"/></w:rPr>'
  .. '<w:t xml:space="preserve">\u{00A0}</w:t></w:r><w:r><w:tab/></w:r>'

-- ---------------------------------------------------------------------------
-- Text: the break rules of typst
-- ---------------------------------------------------------------------------

-- typst never breaks inside a token of adjacent parentheses ("II(1)(a)": lib/typst/xengine.typ boxes it); LibreOffice
-- would break between ")" and "(": a word joiner (U+2060) between every two characters of such a token.
local function bind_parens(s)
  return (s:gsub("%S+", function(tok)
    if not tok:find(")(", 1, true) then return tok end
    local cs = {}
    for _, c in utf8.codes(tok) do cs[#cs + 1] = utf8.char(c) end
    return table.concat(cs, "\u{2060}")
  end))
end
-- A line may end after a slash before a letter, as typst breaks (Unicode line breaking); LibreOffice would not: a
-- zero-width space there.
local function slash_breaks(s)
  return (s:gsub("/(%a)", "/\u{200B}%1"))
end
-- A section sign or pilcrow, single or doubled, stays with what follows ("§§ 51-4-1": typst boxes "§ 51-4-1" and
-- does not break between the two signs).
local function bind_signs(s)
  return (s:gsub("([\u{00A7}\u{00B6}]) ", "%1\u{00A0}"))
end
local BIND = {
  Str = function(s) return pandoc.Str(slash_breaks(bind_parens(s.text))) end,
  Inlines = function(l)
    for i = 1, #l - 1 do
      if l[i].t == "Str" and l[i + 1].t == "Space" and l[i].text:match("^[\u{00A7}\u{00B6}]+$") then
        l[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
    return l
  end,
}

-- A frontmatter string as runs, as typst sets it (plain text).
local function runs(text, o)
  return xe.runs(slash_breaks(bind_parens(bind_signs(tostring(text or "")))), o or {})
end

-- Inlines as runs (the headings in the table of contents), without their footnotes.
local function inl(x, o)
  local l = pandoc.Inlines(x):walk({ Note = function() return {} end })
  return xe.inl(l:walk(BIND), o or {})
end

local function spacing(before, after, line)
  return xe.spacing(before or 0, after or 0, line or SINGLE)
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order), N (inside a footnote).
local needles = {}
local function need(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

local labels = {} -- id -> { page, label }; empty on the first pass
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
  return l and l.label or "00" -- the first pass: a placeholder
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function read_meta()
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  if not f then error("ga-brief.lua: no $FORMBOOK_META (render with fb render)") end
  local m = pandoc.json.decode(f:read("a"), false)
  f:close()
  return m
end

-- ---------------------------------------------------------------------------
-- Citations (`[text](toa:key)` links): their needles, in document order
-- ---------------------------------------------------------------------------

local occurrences = {} -- { key, index }

-- The plain text of inlines without footnotes, and the citations and footnotes in it by position.
local function flatten(list, st)
  for _, el in ipairs(list) do
    if el.t == "Note" then
      st.events[#st.events + 1] = { pos = #st.buf, note = el.content }
    elseif el.t == "Link" and el.target:match("^toa:") then
      st.events[#st.events + 1] = { pos = #st.buf, key = el.target:sub(5), text = stringify(el.content) }
      flatten(el.content, st)
    elseif el.t == "Str" then st.buf = st.buf .. el.text
    elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then st.buf = st.buf .. " "
    elseif el.content and type(el.content) ~= "string" then flatten(el.content, st)
    end
  end
end

local scan_blocks
local function scan_inlines(list, in_note)
  local st = { buf = "", events = {} }
  flatten(list, st)
  for _, e in ipairs(st.events) do
    if e.note then
      scan_blocks(e.note, true)
    else
      occurrences[#occurrences + 1] = { key = e.key, index = #occurrences + 1 }
      need("T:" .. #occurrences, in_note and "N" or "B", e.text, st.buf:sub(e.pos + #e.text + 1))
    end
  end
end

scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" or b.t == "Header" then scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" then scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Tables and sections
-- ---------------------------------------------------------------------------

-- A borderless table of one row, the columns `widths` (twips) apart by `gutter`, top-aligned, never split (typst:
-- grid). `cells`: the paragraphs of each column, as XML.
local function grid(cells, gutter)
  local n = #cells
  local w = math.floor((FULL_W - gutter * (n - 1)) / n)
  local cols, tcs = {}, {}
  local function empty() return para({ spacing(0, 0) }, "") end
  for i, c in ipairs(cells) do
    if i > 1 then
      cols[#cols + 1] = '<w:gridCol w:w="' .. gutter .. '"/>'
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. gutter .. '" w:type="dxa"/></w:tcPr>' .. empty() .. "</w:tc>"
    end
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>'
      .. (c ~= "" and c or empty()) .. "</w:tc>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. FULL_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. "<w:tblGrid>" .. table.concat(cols) .. "</w:tblGrid>"
    .. "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(tcs) .. "</w:tr></w:tbl>"
end

-- Single lines, one paragraph each (typst lines-of), the first `before` below what precedes it.
local function lines(list, o, before, keep)
  local x = {}
  for k, l in ipairs(list or {}) do
    x[#x + 1] = para({ keep and KEEP or "", spacing(k == 1 and before or 0, 0), xe.ind(0) }, runs(l, o))
  end
  return table.concat(x)
end

local FOOTER_XML = '<w:p><w:pPr>' .. spacing(0, 0) .. jc("center") .. '</w:pPr>'
  .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'

-- A section's properties: its footer (rIdFtrNone, written by fb render, or the filter's rIdFtrGa) and page numbers;
-- letter paper, 1 in margins (SCt R 16(5), 17(1)).
local function sect_pr(footer, fmt, start)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="' .. MARGIN_R .. '" w:bottom="1440" '
    .. 'w:left="1440" w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or "") .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (1 pt high).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

-- A title of the front matter or the certificate (typst front-title): centered, bold, a single line below it.
local function front_title(text, page_break)
  return para({ KEEP, page_break and BREAK or "", spacing(0, SINGLE), xe.ind(0), jc("center") }, runs(text, { b = true }))
end

-- ---------------------------------------------------------------------------
-- The parts the filter writes
-- ---------------------------------------------------------------------------

local function need_meta(m, k)
  if m[k] == nil then error("ga-brief.lua: missing required metadata field `" .. k .. "`") end
  return m[k]
end

-- The cover (typst cover): the court in two centered bold lines; two single lines below, the caption (each side's
-- names, its designation a half inch in, "v." between them) beside the case numbers; two lines below, the title;
-- three lines below, the counsel in columns, names then the firm lines in italics.
local function cover(m)
  local x = {}
  x[#x + 1] = para({ spacing(0, 0), xe.ind(0), jc("center") }, runs(COURT_LINES[1], { b = true }))
  x[#x + 1] = para({ spacing(0, 2 * SINGLE), xe.ind(0), jc("center") }, runs(COURT_LINES[2], { b = true }))
  local left = {}
  for i, side in ipairs(need_meta(m, "caption")) do
    if i > 1 then left[#left + 1] = para({ spacing(SINGLE, 0), xe.ind(INDENT) }, runs("v.")) end
    left[#left + 1] = lines(side.names, nil, i > 1 and SINGLE or 0)
    left[#left + 1] = para({ spacing(0, 0), xe.ind(INDENT) }, runs(side.designation))
  end
  local right = para({ spacing(0, 0), xe.ind(0) }, runs("Case No. " .. tostring(need_meta(m, "case_number"))))
  if m.lower_court_case then
    right = right .. para({ spacing(SINGLE, 0), xe.ind(0) }, runs("Lower Court Case No. " .. tostring(m.lower_court_case)))
  end
  x[#x + 1] = grid({ table.concat(left), right }, CAPTION_GUTTER)
  x[#x + 1] = para({ spacing(2 * SINGLE, 3 * SINGLE), xe.ind(0), jc("center") },
    runs(need_meta(m, "brief_title"), { b = true }))
  local cells = {}
  for _, g in ipairs(need_meta(m, "counsel")) do
    cells[#cells + 1] = lines(g.names) .. lines(g.lines, { i = true })
  end
  x[#x + 1] = grid(cells, GUTTER)
  return raw(table.concat(x))
end

-- The signature blocks in columns (typst signature-blocks).
local function signatures(m)
  local cells = {}
  for _, g in ipairs(need_meta(m, "signature")) do cells[#cells + 1] = lines(g.lines) end
  return grid(cells, GUTTER)
end

-- The closing (typst closing, never split): the Rule 20(7) statement and the date at the body pitch, a single line
-- below them the signature blocks.
local function closing(m)
  return raw(para({ KEEP, spacing(0, 0, PITCH), xe.ind(0) }, runs(CLOSING_SENTENCE))
    .. para({ KEEP, spacing(0, SINGLE, PITCH), xe.ind(0) }, runs("Respectfully submitted, this " .. tostring(need_meta(m, "date")) .. "."))
    .. signatures(m))
end

-- The certificate of service on a page of its own (typst certificate-of-service; SCt R 14): the statement, the
-- parties served in columns, the date and the signature blocks, a single line apart.
local function certificate(m)
  local svc = m.service
  local text
  if svc.email then
    text = "I certify that there is a prior agreement with counsel to allow documents in a PDF format sent via e-mail "
      .. "to suffice for service under Supreme Court Rule 14. I further certify that I have on this day served true and "
      .. "correct copies of the foregoing upon the following counsel of record via e-mail:"
  else
    text = "I certify that I have on this day served true and correct copies of the foregoing upon the following "
      .. "counsel of record by " .. tostring(svc.method or "") .. ":"
  end
  local cells = {}
  for _, g in ipairs(svc.recipients or {}) do cells[#cells + 1] = lines(g.names) .. lines(g.lines) end
  return raw(front_title("CERTIFICATE OF SERVICE", true)
    .. para({ spacing(0, SINGLE, PITCH), xe.ind(0) }, runs(text))
    .. grid(cells, GUTTER)
    .. para({ KEEP, spacing(SINGLE, SINGLE, PITCH), xe.ind(0) }, runs("Respectfully submitted, this " .. tostring(need_meta(m, "date")) .. "."))
    .. signatures(m))
end

-- One row of a table (typst listing-row): `before` above it; the text from `left`, its wrapped lines at `left` +
-- `hang`, wraps before the page column `col`; a dot leader from three spaces after the text runs to the page.
local function row(before, left, hang, col, body, page)
  return para({ LINES, xe.leader_tab(TEXT_W), spacing(before, 0), xe.ind(left + (hang or 0), hang, hang == nil and 0 or nil, col) },
    body .. LEAD_XML .. runs(page))
end

-- The width of a page list in twips (Schola advances at 13 pt, 1/1000 em): the authorities' page column is as wide
-- as a longer list (typst: calc.max(toa-col, measure(shown).width)).
local ADV = { [","] = 278, [" "] = 278, p = 574, a = 556, s = 463, i = 315, m = 889 }
local function list_width(s)
  local u = 0
  for c in s:gmatch(".") do u = u + (ADV[c] or 556) end
  return math.ceil(u * 260 / 1000)
end

-- The table of authorities (typst table-of-authorities): by kind, sorted, each entry with every page it is cited on
-- (seven or more: passim); an authority never cited is left out.
local function toa_rows(auths)
  local out = {}
  for _, k in ipairs(KINDS) do
    local members = {}
    for key, a in pairs(auths) do
      local cited = false
      for _, o in ipairs(occurrences) do if o.key == key then cited = true end end
      if tostring(a.kind) == k[1] and cited then
        members[#members + 1] = { key = key, a = a, sort = tostring(a.sort or a.name or a.cite or ""):lower() }
      end
    end
    table.sort(members, function(p, q)
      if p.sort ~= q.sort then return p.sort < q.sort end
      return p.key < q.key
    end)
    if #members > 0 then
      out[#out + 1] = para({ KEEP, spacing(SINGLE, HALF), xe.ind(0) }, runs(k[2], { b = true }))
      for _, mb in ipairs(members) do
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == mb.key then
            local l = labels["T:" .. o.index]
            local key = l and l.page or -o.index
            if not seen[key] then
              seen[key] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
            end
          end
        end
        table.sort(pages, function(p, q) return p.page < q.page end)
        local list = {}
        for _, p in ipairs(pages) do list[#list + 1] = p.label end
        local where = #list >= PASSIM_AT and "passim" or table.concat(list, ", ")
        local a = mb.a
        local body
        if k[1] == "case" then
          body = runs(a.name, { i = true }) .. runs(", " .. tostring(a.cite or ""))
        elseif a.cite then
          body = runs(tostring(a.name) .. ", " .. tostring(a.cite))
        else
          body = runs(a.name)
        end
        out[#out + 1] = row(HALF, 0, TOA_HANG, math.max(TOA_COL, list_width(where)), body, where)
      end
    end
  end
  return table.concat(out)
end

-- A paragraph pandoc reads as a list and typst does not ("b. The ...": letters as list markers): a paragraph with
-- the marker as written.
local function unlist_blocks(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" and (b.listAttributes.style == "LowerAlpha" or b.listAttributes.style == "UpperAlpha") then
      local a = b.listAttributes
      for k, item in ipairs(b.content) do
        local n = a.start + k - 1
        local lab = a.style == "LowerAlpha" and string.char(96 + n) or string.char(64 + n)
        lab = lab .. (a.delimiter == "OneParen" and ")" or ".")
        for j, c in ipairs(item) do
          if j == 1 and (c.t == "Para" or c.t == "Plain") then
            local il = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
            il:extend(c.content)
            out[#out + 1] = pandoc.Para(il)
          else
            out[#out + 1] = c
          end
        end
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local m = read_meta()
  for _, k in ipairs({ "case_number", "caption", "brief_title", "counsel", "date", "signature" }) do need_meta(m, k) end
  local auths = m.authorities or {}
  local has_toa = next(auths) ~= nil

  -- the front matter's needles, in page order: the contents' title, then the authorities' title with its first kind,
  -- so the body's needles are searched after the tables (which repeat the headings and citations)
  need("S:toc", "B", "TABLE OF CONTENTS", "")
  if has_toa then need("S:toa", "B", "TABLE OF AUTHORITIES", "") end

  -- the body: headings (needles, contents entries), citations (needles), paragraphs with their styles: the one after
  -- a heading, list or quotation not indented (typst indents a paragraph only after a paragraph), one with a footnote
  -- mark without widow control (typst keeps two lines together by their height alone: when a line's footnote does
  -- not fit, that line moves on and the one before it stays behind alone)
  local items = {}
  local blocks = unlist_blocks(doc.blocks)
  local body = {}
  local first_id
  local after_para = false
  for i, b in ipairs(blocks) do
    local text = stringify(b)
    local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      if b.level > 3 then error("ga-brief.lua: headings deeper than level 3 are not supported") end
      local id = "H:" .. i
      need(id, "B", stringify(b.content:walk({ Note = function() return {} end })), nxt)
      first_id = first_id or id
      if b.level <= TOC_DEPTH then items[#items + 1] = { id = id, level = b.level, title = b.content } end
      scan_blocks({ b }, false)
    else
      if not first_id then
        first_id = "S:body"
        need(first_id, "B", text, nxt)
      end
      scan_blocks({ b }, false)
    end
    b = pandoc.Pandoc({ b }):walk({
      Link = function(el) if el.target:match("^toa:") then return el.content end end,
    }).blocks[1]
    -- the break rules of typst on the text pandoc writes itself (body, headings, footnotes)
    b = b:walk({ Inlines = xe.inlines }):walk(BIND)
    if b.t == "Header" and b.level == 3 then
      -- emphasis in an italic heading is upright (typst's emph toggles the style)
      b = b:walk({ Emph = function(el)
        return pandoc.RawInline("openxml", (xe.runs(stringify(el.content), {}):gsub("<w:r>",
          '<w:r><w:rPr><w:i w:val="0"/><w:iCs w:val="0"/></w:rPr>')))
      end })
    end
    if b.t == "Header" then
      if #body == 0 then
        -- the heading that opens the body page: no space above it (typst drops it at the top of a page; Word keeps
        -- it after the section break)
        body[#body + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Heading " .. b.level .. " Top" })
      else
        body[#body + 1] = b
      end
    elseif b.t == "Para" then
      local style = (after_para and "Body Text" or "First Paragraph") .. (has_note(b) and " Note" or "")
      body[#body + 1] = pandoc.Div({ b }, { ["custom-style"] = style })
    else
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
    after_para = b.t == "Para"
  end
  for _, o in ipairs(occurrences) do
    if not auths[o.key] then
      error("ga-brief.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  if first_id then nl[#nl + 1] = "#section\t" .. first_id .. "\tdecimal\t" end
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrGa\t" .. FOOTER_XML .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrGa", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  add(cover(m))
  add(section("rIdFtrNone"))

  -- Section 2: the contents and the authorities, each from a page of its own (ii, iii ...: the cover counts as i)
  local toc = { front_title("TABLE OF CONTENTS") }
  for _, it in ipairs(items) do
    local left = (it.level - 1) * INDENT
    toc[#toc + 1] = row(SINGLE, left, nil, TOC_COL, inl(it.title), label_of(it.id))
  end
  add(raw(table.concat(toc)))
  if has_toa then
    add(raw(front_title("TABLE OF AUTHORITIES", true) .. toa_rows(auths)))
  end
  add(section("rIdFtrGa", "lowerRoman", 2))

  -- Section 3: the body (1, 2 ...), the closing and the certificate of service; FORMBOOK_FINAL closes it
  for _, x in ipairs(body) do add(x) end
  add(closing(m))
  if m.service then add(certificate(m)) end

  -- empty metadata: pandoc would otherwise print the title and date as a title block above the cover
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

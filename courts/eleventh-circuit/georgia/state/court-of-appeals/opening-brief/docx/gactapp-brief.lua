-- gactapp-brief.lua (docx engine, brief types: answering-brief, opening-brief, reply-brief).
-- The typst template (typst/gactapp-*-brief.typ) is the reference for what each block looks like and where every line
-- and page breaks (cross-engine layout model, docs/EVAL-LOOP.md; lib/docx/xengine.lua): this filter writes the same
-- layout in Word: the cover (page 1, Rule 24 (e)), the table of contents and the table of authorities (Rule 25 (a)
-- (1)), the body (pandoc's paragraphs, quotations and footnotes in the reference.xml styles; headings written here),
-- the word-count certificate (Rule 24 (f) (1)), date and signature block, and the certificate of service.
-- One section, every page numbered from the cover on (Rule 24 (e)); the footer is a centered PAGE field in a single
-- line (FORMBOOK_FOOTERS), the section FORMBOOK_FINAL. The contents' and authorities' page numbers: fb render
-- (tools/fb/src/docxpass.rs) renders the document, finds the page of every heading and citation in that PDF (the
-- needles written to FORMBOOK_NEEDLES) and renders again with them (FORMBOOK_PAGES) until they settle (was
-- docx/render.sh). A citation is every occurrence of an authority's `find` string in the body and its footnotes, as
-- the typst template's show rule marks it. No case-specific text is in this file.

local xe = require("docx.xengine")

local TEXTW = 9360          -- 6.5 in, the text width (letter, 1 in margins; Rule 24 (c))
local SINGLE = 322          -- typst pitch-single, 16.1 pt
local DOUBLE = 644          -- typst pitch-double, 32.2 pt
local TITLE = 368           -- typst pitch-title, 18.4 pt
local GAP = 322             -- typst gap
local GAP_SMALL = 160       -- typst gap-small, 8 pt
local COVER_GAP = 432       -- typst cover-gap, 0.3 in
local COVER_TITLE_GAP = 1440 -- typst cover-title-gap, 1 in
local SIG = 4608            -- typst sig-indent, 3.2 in
local SIG_FIRM_GAP = 240    -- typst sig-firm-gap, 12 pt
local RECIPIENT = 1440      -- typst recipient-indent, 1 in
local TOC_STEP = 720        -- typst toc-step, 0.5 in
local TOC_COL = 720         -- typst toc-page-col, 36 pt
local TOA_COL = 1120        -- typst toa-page-col, 56 pt
local TOA_HANG = 720        -- typst toa-hang
local TOC_DEPTH = 3
local WORD_COUNT = "This submission does not exceed the word count limit imposed by Rule 24." -- Rule 24 (f) (1)

local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r>'
  .. '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdGaFtr"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

local function fail(msg) error("gactapp-brief: " .. msg, 0) end

-- ---------------------------------------------------------------------------
-- Text
-- ---------------------------------------------------------------------------

-- The sample's frontmatter as written (FORMBOOK_META): typst prints some values as plain strings, others as markdown.
local RAW = {}
do
  local path = os.getenv("FORMBOOK_META")
  if path and path ~= "" then
    local f = io.open(path, "r")
    if f then
      RAW = pandoc.json.decode(f:read("a"), false)
      f:close()
    end
  end
end

-- typst's break rules on Word inlines (lib/docx/xengine.lua) and the ones this template adds: a doubled sign stays
-- with its number ("¶¶ 2"), no break inside ")(" (a word joiner), a break after a slash before a letter.
local function rules(il)
  il = xe.inlines(pandoc.Inlines(il))
  local out = pandoc.Inlines({})
  for i, el in ipairs(il) do
    -- no break before a closing or infix sign (". . .": typst follows Unicode line breaking, LibreOffice breaks there)
    if el.t == "Space" and il[i + 1] and il[i + 1].t == "Str" and il[i + 1].text:match("^[%.,;:!%?%)%]}]") then
      el = pandoc.Str("\u{00A0}")
    end
    if el.t == "Str" then
      local t = el.text:gsub("%)%(", ")\u{2060}("):gsub("(%w)/(%a)", "%1/\u{200B}%2")
      if t:match("^[\u{00A7}\u{00B6}]+$") and il[i + 1] and il[i + 1].t == "Space" then
        out:insert(pandoc.Str(t))
        il[i + 1] = pandoc.Str("\u{00A0}")
      else
        out:insert(pandoc.Str(t))
      end
    else
      out:insert(el)
    end
  end
  return out
end

-- markdown (smart punctuation, as typst's cmarker) as inlines; one line of text, never a list or a heading ("(229)
-- 247-0386" is not a list item): read after a word that is then dropped
local function md(s)
  if s == nil then return pandoc.Inlines({}) end
  local d = pandoc.read("x " .. tostring(s), "markdown+smart")
  if #d.blocks == 0 then return pandoc.Inlines({}) end
  local il = pandoc.utils.blocks_to_inlines(d.blocks)
  il:remove(1)
  il:remove(1)
  return il
end

-- a plain string as inlines (words and spaces)
local function plain(s)
  local out = pandoc.Inlines({})
  local first = true
  for w in tostring(s or ""):gmatch("%S+") do
    if not first then out:insert(pandoc.Space()) end
    out:insert(pandoc.Str(w))
    first = false
  end
  return out
end

local function upper(il)
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(pandoc.text.upper(e.text)) end }).content
end

-- ---------------------------------------------------------------------------
-- Raw paragraphs
-- ---------------------------------------------------------------------------

local function runs(il, f, out)
  for _, el in ipairs(il) do
    local t = el.t
    if t == "Str" then out[#out + 1] = xe.runs(el.text, f)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then out[#out + 1] = xe.runs(" ", f)
    elseif t == "Emph" then runs(el.content, xe.merge(f, { i = true }), out)
    elseif t == "Strong" then runs(el.content, xe.merge(f, { b = true }), out)
    elseif t == "Underline" then runs(el.content, xe.merge(f, { u = true }), out)
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = xe.runs(q[1], f)
      runs(el.content, f, out)
      out[#out + 1] = xe.runs(q[2], f)
    elseif t == "Span" or t == "Link" or t == "SmallCaps" then runs(el.content, f, out)
    elseif t == "RawInline" then
      if el.format == "openxml" then out[#out + 1] = el.text end
    else out[#out + 1] = xe.runs(pandoc.utils.stringify(el), f) end
  end
end

-- One paragraph: pPr children (schema order: keep, page break, tabs, spacing, indent, jc), inlines, run format.
local function P(ppr, il, f)
  local out = {}
  runs(rules(il), f or {}, out)
  return xe.raw('<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. table.concat(out) .. '</w:p>')
end

local function sp(before, after, line) return xe.spacing(before, after, line or SINGLE) end
local function ind(left, hanging, right)
  if hanging then return xe.ind(left, hanging, nil, right) end
  return xe.ind(left, nil, 0, right)
end
local CENTER = xe.jc("center")
local KEEP_NEXT = "<w:keepNext/>"
local KEEP = "<w:keepNext/><w:keepLines/>"

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60
local function letters(s) return (s:lower():gsub("[^a-z0-9]", "")) end
local needles = {}
local function need_at(id, kind, text, fallback)
  local long = letters(text):sub(1, NEEDLE_MAX)
  local short = letters(fallback or text):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, kind, long, short }, "\t")
end

local labels = {}
do
  local path = os.getenv("FORMBOOK_PAGES")
  local f = path and path ~= "" and io.open(path, "r")
  if f then
    for line in f:lines() do
      local id, _, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
      if id then labels[id] = lab end
    end
    f:close()
  end
end
local function label_of(id) return labels[id] or "0" end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The text of inlines as typst sets it (a no-break space is a space); footnotes are collected apart, each with the
-- offset of its mark in the text.
local function text_of(il, notes)
  local buf = {}
  local function walk(l)
    for _, el in ipairs(l) do
      if el.t == "Str" then buf[#buf + 1] = el.text:gsub("\u{00A0}", " ")
      elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then buf[#buf + 1] = " "
      elseif el.t == "Note" then
        if notes then notes[#notes + 1] = { at = #table.concat(buf), blocks = el.content } end
      elseif el.t == "Quoted" then
        buf[#buf + 1] = el.quotetype == "DoubleQuote" and "\u{201C}" or "\u{2018}"
        walk(el.content)
        buf[#buf + 1] = el.quotetype == "DoubleQuote" and "\u{201D}" or "\u{2019}"
      elseif el.content and type(el.content) == "table" and el.t ~= "Code" then walk(el.content)
      elseif el.t == "Code" then buf[#buf + 1] = el.text end
    end
  end
  walk(il)
  return table.concat(buf)
end

-- the paragraphs of a block, as text: { text, notes }
local function block_texts(b, out)
  if b.t == "Para" or b.t == "Plain" or b.t == "Header" then
    local notes = {}
    out[#out + 1] = { text = text_of(b.content, notes), notes = notes }
  elseif b.t == "BlockQuote" or b.t == "Div" then
    for _, x in ipairs(b.content) do block_texts(x, out) end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    for _, item in ipairs(b.content) do for _, x in ipairs(item) do block_texts(x, out) end end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Parts
-- ---------------------------------------------------------------------------

local function cover(meta, raw, out)
  local function line(before, il, f, ppr) out[#out + 1] = P((ppr or "") .. sp(before, 0) .. ind(0) .. CENTER, il, f) end
  line(0, plain("IN THE COURT OF APPEALS OF THE STATE OF GEORGIA"), { b = true })
  line(COVER_GAP, plain("Case No. " .. tostring(raw.case_number or "")), { b = true })
  for i = 1, 2 do
    local side = (raw.caption or {})[i] or fail("the caption needs two sides")
    if i == 2 then line(COVER_GAP, plain("v.")) end
    for j, n in ipairs(side.names or {}) do line(j == 1 and COVER_GAP or 0, md(n)) end
    line(0, plain(side.designation), { i = true })
  end
  local next = COVER_GAP
  if raw.proceeding then line(next, md(raw.proceeding)); next = 0 end
  if raw.trial_court_case then line(next, md(raw.trial_court_case)) end
  out[#out + 1] = P(sp(COVER_TITLE_GAP, 0, TITLE) .. ind(0) .. CENTER, upper(md(raw.brief_title)), { b = true, sz = 32 })
  for gi, g in ipairs(raw.counsel or {}) do
    for j, n in ipairs(g.names or {}) do
      local before = j > 1 and 0 or (gi == 1 and COVER_TITLE_GAP or GAP_SMALL)
      out[#out + 1] = P(sp(before, 0) .. ind(SIG), plain(n), { b = true })
    end
    for _, l in ipairs(g.lines or {}) do out[#out + 1] = P(sp(0, 0) .. ind(SIG), md(l)) end
  end
  if raw.phone then out[#out + 1] = P(sp(GAP_SMALL, 0) .. ind(SIG), plain(raw.phone)) end
end

-- The signature block [signature-block]: single lines `SIG` from the margin, kept whole and with what comes before.
local function signature(sig, before, first_only, out)
  local list = sig.signers or { { name = sig.signer, lines = {} } }
  if first_only then list = { list[1] } end
  local rows = {}
  local function row(b, il, f) rows[#rows + 1] = { b, il, f } end
  local next = 0
  if sig.firm then row(0, plain(sig.firm), { b = true }); next = SIG_FIRM_GAP end
  for i, s in ipairs(list) do
    row(i > 1 and SIG_FIRM_GAP or next, pandoc.Inlines({ pandoc.Str("/s/"), pandoc.Space(), pandoc.Emph(plain(s.name)) }), { u = true })
    row(0, plain(s.name))
    for _, l in ipairs(s.lines or {}) do row(0, md(l)) end
  end
  for i, l in ipairs(sig.lines or {}) do row(i == 1 and GAP_SMALL or 0, md(l)) end
  for i, r in ipairs(rows) do
    local b = i == 1 and math.max(before, r[1]) or r[1]
    out[#out + 1] = P((i < #rows and KEEP or "<w:keepLines/>") .. sp(b, 0) .. ind(SIG), r[2], r[3])
  end
end

-- A heading [the typst show rules]: level 1 centered bold capitals; levels 2 and 3 bold (3 italic too), hanging.
local function heading(level, il, extra)
  if level == 1 then
    return P(KEEP .. (extra or "") .. sp(extra and 0 or 480, 320) .. ind(0) .. CENTER, upper(il), { b = true })
  end
  return P(KEEP .. sp(320, 240) .. ind(720, 720), il, { b = true, i = level == 3 })
end

-- a table row [listing-row]: the text wraps before the page column, a dot leader to the page number
local function row(il, page, left, hang, col, before)
  local l = pandoc.Inlines(il)
  l:extend({ pandoc.Str("\u{00A0}\u{00A0}\u{00A0}"), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"), pandoc.Str(page) })
  return P("<w:keepLines/>" .. xe.leader_tab(TEXTW) .. sp(before, 0) .. xe.ind(left, hang, nil, col), l)
end

function Pandoc(doc)
  local raw = RAW
  local auth = raw.authorities
  local blocks = doc.blocks:walk({})

  -- the authorities' `find` strings, in the order of the frontmatter
  local finds = {}
  for _, g in ipairs(auth or {}) do
    for _, e in ipairs(g.entries or {}) do if e.find then finds[#finds + 1] = e.find end end
  end
  local occ = {}   -- key -> list of needle ids
  local n_occ = 0
  local function cite_needles(text, kind)
    local hits = {}
    for _, key in ipairs(finds) do
      local from = 1
      while true do
        local s = text:find(key, from, true)
        if not s then break end
        hits[#hits + 1] = { s = s, key = key }
        from = s + #key
      end
    end
    table.sort(hits, function(a, b) return a.s < b.s or (a.s == b.s and #a.key > #b.key) end)
    for _, h in ipairs(hits) do
      n_occ = n_occ + 1
      local id = "T:" .. n_occ
      occ[h.key] = occ[h.key] or {}
      table.insert(occ[h.key], id)
      need_at(id, kind, text:sub(h.s, h.s + 80), h.key)
    end
  end

  -- the TOC entries (typst outlines the TOA's title, the body's headings to TOC_DEPTH, the certificate's title)
  local heads = {}
  need_at("S:cover", "B", "IN THE COURT OF APPEALS OF THE STATE OF GEORGIA Case No. " .. tostring(raw.case_number or ""))
  if auth then
    local first = auth[1]
    local e1 = first and first.entries and first.entries[1]
    heads[#heads + 1] = { level = 1, il = plain("Table of Authorities"), id = "S:toa" }
    need_at("S:toa", "B", "Table of Authorities " .. text_of(md(first and first.heading)) .. " " .. text_of(md(e1 and e1.cite)),
      "Table of Authorities")
  end

  -- the body: headings written here, every block's citations as needles in document order
  local body = {}
  for bi, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level <= TOC_DEPTH then
        local id = "H:" .. (#heads + 1)
        heads[#heads + 1] = { level = b.level, il = b.content, id = id }
        local nxt = blocks[bi + 1] and pandoc.utils.stringify(blocks[bi + 1]) or ""
        need_at(id, "B", text_of(b.content) .. " " .. nxt:sub(1, 40), text_of(b.content))
      end
      body[#body + 1] = heading(b.level, b.content, #body == 0 and xe.BREAK or nil)
    else
      body[#body + 1] = b
    end
    for _, p in ipairs(block_texts(b, {})) do
      -- the body text's citations, then each footnote's (searched from the page the body has reached)
      cite_needles(p.text, "B")
      for _, n in ipairs(p.notes) do
        for _, t in ipairs(block_texts(pandoc.Div(n.blocks), {})) do cite_needles(t.text, "N") end
      end
    end
  end
  local svc = raw.service
  if svc then
    local id = "H:" .. (#heads + 1)
    heads[#heads + 1] = { level = 1, il = plain("Certificate of Service"), id = id }
    need_at(id, "B", "Certificate of Service " .. text_of(md((svc.paragraphs or {})[1] or "")):sub(1, 40), "Certificate of Service")
  end

  needles[#needles + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdGaFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", SECT)

  local out = {}
  cover(doc.meta, raw, out)

  -- the table of contents (Rule 25 (a) (1))
  if raw.toc ~= false then
    out[#out + 1] = P(xe.BREAK .. sp(0, GAP) .. ind(0) .. CENTER, plain("TABLE OF CONTENTS"), { b = true })
    for _, h in ipairs(heads) do
      local left = (h.level - 1) * TOC_STEP
      out[#out + 1] = row(h.il, label_of(h.id), left + TOC_STEP, TOC_STEP, TOC_COL, GAP_SMALL)
    end
  end

  -- the table of authorities (Rule 25 (a) (1))
  if auth then
    out[#out + 1] = heading(1, plain("Table of Authorities"), xe.BREAK)
    for _, g in ipairs(auth) do
      out[#out + 1] = P(KEEP .. sp(GAP, 0) .. ind(0), md(g.heading), { b = true })
      for _, e in ipairs(g.entries or {}) do
        local pages
        if e.find then
          local ls, seen = {}, {}
          for _, id in ipairs(occ[e.find] or {}) do
            local l = label_of(id)
            if not seen[l] then seen[l] = true; ls[#ls + 1] = l end
          end
          table.sort(ls, function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end)
          pages = #ls == 0 and "--" or table.concat(ls, ", ")
        else
          pages = tostring(e.pages or "")
        end
        out[#out + 1] = row(md(e.cite), pages, TOA_HANG, TOA_HANG, TOA_COL, GAP_SMALL)
      end
    end
  end

  -- the body, pandoc's paragraphs on the template's break rules
  for _, b in ipairs(pandoc.Blocks(body):walk({ Inlines = rules })) do out[#out + 1] = b end

  -- the word-count certificate, the date and the signature block, kept together (Rule 24 (f) (1))
  out[#out + 1] = P(KEEP .. sp(0, 0, DOUBLE) .. xe.ind(0, nil, 720), plain(WORD_COUNT))
  if raw.date then out[#out + 1] = P(KEEP .. sp(0, 0, DOUBLE) .. xe.ind(0, nil, 720), md(raw.date)) end
  signature(raw.signature or fail("missing `signature`"), GAP_SMALL, false, out)

  -- the certificate of service (Rules 2 (a), 6), on a page of its own
  if svc then
    out[#out + 1] = heading(1, plain("Certificate of Service"), xe.BREAK)
    for _, p in ipairs(svc.paragraphs or {}) do out[#out + 1] = P(sp(0, 0, DOUBLE) .. xe.ind(0, nil, 720), md(p)) end
    for _, r in ipairs(svc.recipients or {}) do
      for i, l in ipairs(r) do
        out[#out + 1] = P((i < #r and KEEP or "<w:keepLines/>") .. sp(i == 1 and GAP or 0, i == #r and GAP or 0)
          .. ind(RECIPIENT), md(l))
      end
    end
    if svc.closing then out[#out + 1] = P(sp(0, 0, DOUBLE) .. xe.ind(0, nil, 720), md(svc.closing)) end
    signature(raw.signature, GAP_SMALL, svc.first_signer_only ~= false, out)
  end

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({}) -- the frontmatter is read here; pandoc must not write its own title block from it
  return doc
end

-- Second Circuit answering (appellee's) brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document
-- on reference.docx. Mirrors typst/ca2-answering-brief.typ (the reference): the cover (FRAP 32(a)(2), the docket
-- number one inch high per Local Rule 32.1(a)(1)), the front matter (lower-roman pages: contents and authorities),
-- the body (arabic from 1) with the signature block, the certificate of compliance and the certificate of service,
-- and the addendum (FRAP 28(f), pages Add-1 ...) when the sample has a `# Addendum` section.
-- Pages are separated by section breaks (SectionBreak paragraphs carrying a sectPr), so the footer numbering
-- follows the sections and no page starts with an empty line.
-- Heading labels are written here, as the typst template labels them (Argument: I. A. 1. a.; elsewhere
-- A. 1. a. (1)). Paragraph and heading geometry comes from the styles in docx/reference.xml (fb render builds
-- reference.docx from it).
-- The pages in the contents and the table of authorities: fb render (tools/fb/src/docxpass.rs) renders the
-- document once, finds the page of every heading and citation in that PDF (the needles this filter writes to
-- FORMBOOK_NEEDLES), and renders again with those pages (FORMBOOK_PAGES) until they settle. fb render writes the
-- footers (rIdFtrNone, rIdFtrPage, rIdFtrAdd); this filter writes the last section (FORMBOOK_FINAL). Word may
-- paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local WORD_LIMIT = 14000   -- 2d Cir. Local Rule 32.1(a)(4)(A), principal brief (typst: type-volume-limit)
local TYPEFACE = "Times New Roman"   -- the face reference.xml sets; the certificate names it
local SOFTWARE = "Microsoft Word"    -- the program the .docx is made for (typst names Typst); `software:` overrides
local COURT_NAME = "United States Court of Appeals for the Second Circuit"
local TOC_DEPTH = 4    -- heading levels listed in the contents (typst: toc-depth)
local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)

local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local PAGE_SIZE = "<w:pgSz w:w=\"12240\" w:h=\"15840\"/>"
  .. "<w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" w:left=\"1440\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/>"

-- A section's properties: its footer (rIdFtrNone, rIdFtrPage or rIdFtrAdd, the centered footers fb render
-- writes), page size and margins, page number format.
local function sect_pr(footer, pgnum)
  local ftr = "<w:footerReference w:type=\"default\" r:id=\"" .. footer .. "\"/>"
  return "<w:sectPr>" .. ftr .. "<w:type w:val=\"nextPage\"/>" .. PAGE_SIZE .. (pgnum or "") .. "</w:sectPr>"
end

-- A section break: the paragraph ends the section.
local function section_break(footer, pgnum)
  return pandoc.RawBlock("openxml",
    "<w:p><w:pPr><w:pStyle w:val=\"SectionBreak\"/>" .. sect_pr(footer, pgnum) .. "</w:pPr></w:p>")
end
local ROMAN_FIRST = "<w:pgNumType w:fmt=\"lowerRoman\" w:start=\"1\"/>"
local ROMAN = "<w:pgNumType w:fmt=\"lowerRoman\"/>"
local DECIMAL_FIRST = "<w:pgNumType w:fmt=\"decimal\" w:start=\"1\"/>"
local DECIMAL = "<w:pgNumType w:fmt=\"decimal\"/>"

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Needles and pages (the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing).
local needles = {}
local function need_at(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- The pages of the previous pass: id -> { page, label }. Empty on the first pass.
local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = lab } end
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
-- Metadata and paragraph helpers
-- ---------------------------------------------------------------------------

-- Metadata as an inline list (MetaInlines, MetaString or a plain Lua string).
local function I(v)
  if v == nil then return pandoc.List({}) end
  if type(v) == "string" then return pandoc.List({ pandoc.Str(v) }) end
  if v.t == "MetaString" then return pandoc.List({ pandoc.Str(pandoc.utils.stringify(v)) }) end
  if v.t == "MetaBlocks" then return pandoc.List(pandoc.utils.blocks_to_inlines(v)) end
  return pandoc.List(v)
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function need(meta, key)
  if meta[key] == nil then error("ca2: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function upper(inl)
  return pandoc.Inlines(inl):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- A paragraph in a named style (reference.docx).
local function styled(name, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

local function tab_run() return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") end
local NBSP = "\u{00A0}"

-- ---------------------------------------------------------------------------
-- Headings: the labels and the contents entries
-- ---------------------------------------------------------------------------

local counts = { 0, 0, 0, 0, 0 }
local in_arg = false

-- Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)   (typst heading-label)
local function label_for(level)
  local n = counts[level]
  if in_arg then
    if level == 2 then return roman(n) .. "."
    elseif level == 3 then return string.char(64 + n) .. "."
    elseif level == 4 then return tostring(n) .. "."
    elseif level == 5 then return string.char(96 + n) .. "."
    end
  else
    if level == 2 then return string.char(64 + n) .. "."
    elseif level == 3 then return tostring(n) .. "."
    elseif level == 4 then return string.char(96 + n) .. "."
    elseif level == 5 then return "(" .. tostring(n) .. ")"
    end
  end
  error("ca2: headings deeper than level 5 are not supported", 0)
end

local toc = {}   -- contents entries, in order: { id, level, label, text, k }

-- The body heading for a markdown heading; `context` is the start of the text after it (the needle goes on into
-- it). k is the label's step: the label at k half-inches, the text hanging half an inch after it (typst
-- label-indent: in the Argument the centered point heading is step 0 and its sub-headings start at step 1).
local function body_heading(h, context)
  local level = h.level
  local text = pandoc.utils.stringify(h.content)
  local id = "H:" .. (#needles + 1)
  if level == 1 then
    in_arg = text:lower():match("^%s*(.-)%s*$") == "argument"
    for l = 2, 5 do counts[l] = 0 end
    counts[1] = counts[1] + 1
    need_at(id, "B", text, context)
    toc[#toc + 1] = { id = id, level = 1, label = nil, text = h.content, k = 0 }
    return pandoc.Header(1, h.content)
  end
  if level > 5 then error("ca2: headings deeper than level 5 are not supported", 0) end
  for l = level + 1, 5 do counts[l] = 0 end
  counts[level] = counts[level] + 1
  local lab = label_for(level)
  need_at(id, "B", lab .. " " .. text, context)
  if in_arg and level == 2 then
    toc[#toc + 1] = { id = id, level = 2, label = lab, text = h.content, k = 0 }
    local inl = pandoc.List({ pandoc.Str(lab), pandoc.Space() })
    inl:extend(h.content)
    return styled("PointHeading", inl)
  end
  local first = in_arg and 3 or 2
  local k = level - first + 1
  if level <= TOC_DEPTH then
    toc[#toc + 1] = { id = id, level = level, label = lab, text = h.content, k = k }
  end
  local inl
  if level >= 4 then
    inl = pandoc.List({ pandoc.Strong(pandoc.Emph({ pandoc.Str(lab) })), tab_run(),
      pandoc.Strong(pandoc.Emph(h.content)) })
  else
    inl = pandoc.List({ pandoc.Strong({ pandoc.Str(lab) }), tab_run(), pandoc.Strong(h.content) })
  end
  return styled("SubHead" .. math.min(k, 4), inl)
end

-- Contents line for one toc entry (label at its step, title hanging after it; level 1 has no label and is in
-- capitals), the dot leader and the entry's page (TOCK styles: a right tab inside the margin, past the page
-- column's right indent).
local function toc_line(e)
  local inl = pandoc.List({})
  if e.label then inl:insert(pandoc.Str(e.label)); inl:insert(tab_run()) end
  if e.level == 1 then inl:extend(upper(e.text)) else inl:extend(e.text) end
  inl:insert(pandoc.Space())
  inl:insert(tab_run())
  inl:insert(pandoc.Str(label_of(e.id)))
  return styled("TOCK" .. math.min(e.k, 3), inl)
end

-- ---------------------------------------------------------------------------
-- Word count, sort key, list markers
-- ---------------------------------------------------------------------------

-- Plain word count of the markdown body up to the addendum (typst count-words, line by line).
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return 0 end
  local h = io.open(f, "r")
  if not h then return 0 end
  local text = h:read("a")
  h:close()
  text = text:gsub("<!%-%-.-%-%->", " ")
  local dashes, n = 0, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line:match("^%-%-%-%s*$") then dashes = dashes + 1 end
    else
      if line:lower():match("^#[ \t]+addendum[ \t]*$") then break end
      local s = line:gsub("^%[%^[^%]]+%]:", " ")
      s = s:gsub("%[%^[^%]]*%]", "")
      s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
      s = s:gsub("^#+[ \t]+", "")
      s = s:gsub("^>[ \t]?", "")
      s = s:gsub("^[ \t]*[-*+][ \t]+", "")
      s = s:gsub("^[ \t]*%d+[.)][ \t]+", "")
      s = s:gsub("\\(.)", "%1")
      s = s:gsub("%*", "")
      for _ in s:gmatch("%S+") do n = n + 1 end
    end
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- Case-insensitive, digit runs compared by value ("9 U.S.C." before "10 U.S.C."; typst sort-key).
local function sort_key(a)
  local s = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  s = s:lower():gsub("%d+", function(d) return string.rep("0", math.max(0, 10 - #d)) .. d end)
  return (s:gsub("[^a-z0-9 ]", ""))
end

-- Fancy list markers ("(I)", "A.", "(1)") are text in the markdown contract, not lists (CommonMark reads them
-- as text, and so does the typst template): they become paragraphs that keep their marker.
local function list_marker(n, style, delim)
  local s
  if style == "LowerRoman" or style == "UpperRoman" then
    s = roman(n)
    if style == "LowerRoman" then s = s:lower() end
  elseif style == "LowerAlpha" or style == "UpperAlpha" then
    s = string.char((style == "LowerAlpha" and 96 or 64) + n)
  else
    s = tostring(n)
  end
  if delim == "OneParen" then return s .. ")" end
  if delim == "TwoParens" then return "(" .. s .. ")" end
  return s .. "."
end

local function unlist_fancy(blocks)
  return pandoc.Pandoc(blocks):walk({
    OrderedList = function(el)
      local a = el.listAttributes
      local st, dl = tostring(a.style), tostring(a.delimiter)
      local fancy = st == "LowerRoman" or st == "UpperRoman" or st == "LowerAlpha" or st == "UpperAlpha"
        or dl == "OneParen" or dl == "TwoParens"
      if not fancy then return nil end
      local out = {}
      for i, item in ipairs(el.content) do
        local marker = list_marker(a.start + i - 1, st, dl)
        for j, b in ipairs(item) do
          if j == 1 and (b.t == "Para" or b.t == "Plain") then
            local inl = pandoc.List({ pandoc.Str(marker), pandoc.Space() })
            inl:extend(b.content)
            out[#out + 1] = pandoc.Para(inl)
          else
            out[#out + 1] = b
          end
        end
      end
      return out
    end,
  }).blocks
end

-- ---------------------------------------------------------------------------
-- Cover, signature, certificates
-- ---------------------------------------------------------------------------

-- The cover (FRAP 32(a)(2)(A)-(F)), as typst cover-body: docket number, court, caption, proceeding and the case
-- below, brief title, counsel; short rules between the parts.
local function cover(meta)
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function rule() add(styled("RuleShort", { pandoc.Str(NBSP) })) end
  add(styled("Docket", I(need(meta, "case_number"))))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("IN THE") }) }))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(COURT_NAME) }) }))
  rule()
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names or {}) do add(styled("Centered", I(n))) end
    add(styled("Centered", I(side.designation)))
    if i < #sides then add(styled("CoverPart", { pandoc.Str("\u{2013} v. \u{2013}") })) end
  end
  rule()
  add(styled("Centered", I(need(meta, "proceeding"))))
  if meta.district_court_case then
    local dc = pandoc.List({ pandoc.Str("Case No. ") })
    dc:extend(I(meta.district_court_case))
    if meta.judge then
      dc:insert(pandoc.Str(" ("))
      dc:extend(I(meta.judge))
      dc:insert(pandoc.Str(")"))
    end
    add(styled("Centered", dc))
  end
  rule()
  add(styled("Centered", { pandoc.Strong(upper(I(need(meta, "brief_title")))) }))
  rule()
  local groups = need(meta, "counsel")
  for gi, g in ipairs(groups) do
    for _, n in ipairs(g.names or {}) do add(styled("Counsel", I(n))) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = need(meta, "phone") end
    for _, l in ipairs(lines) do add(styled("CounselLine", I(l))) end
  end
  return out
end

-- The signature block (typst signature-block): "Dated:" and the city, then at 35 %: "Respectfully submitted,",
-- the /s/ line, the signer and the signature lines.
local function signature_block(meta)
  local sig = need(meta, "signature")
  local out = {}
  if meta.date then
    local d = pandoc.List({ pandoc.Str("Dated: ") })
    d:extend(I(meta.date))
    out[#out + 1] = styled("SigDated", d)
  end
  if meta.city then out[#out + 1] = styled("SingleLine", I(meta.city)) end
  out[#out + 1] = styled("GapSig", { pandoc.Str(NBSP) })
  out[#out + 1] = styled("SigLeft", { pandoc.Str("Respectfully submitted,") })
  out[#out + 1] = styled("GapSig", { pandoc.Str(NBSP) })
  out[#out + 1] = styled("SigLeft", { pandoc.Str("/s/ " .. plain(sig.signer)) })
  out[#out + 1] = styled("SigLeft", I(sig.signer))
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = styled("SigLine", I(l)) end
  return out
end

-- Signature under a certificate: "/s/ Name" over "Signature", the date over "Date" (typst form-sig-line).
local function form_sig(meta)
  local l1 = pandoc.List({ pandoc.Str("/s/ " .. plain(need(meta, "signature").signer)), tab_run() })
  l1:extend(I(meta.date))
  local l2 = pandoc.List({ pandoc.Str("Signature"), tab_run(), pandoc.Str("Date") })
  return { styled("SigGridTop", l1), styled("SigGrid", l2) }
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature" }) do
    need(meta, k)
  end
  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
    end
  end
  local service = meta.service and meta.service.certificate ~= nil and plain(meta.service.certificate) == "true"

  local words = source_words()
  if words > WORD_LIMIT then
    error("ca2: the brief has " .. words .. " words; Local Rule 32.1(a)(4)(A) allows " .. WORD_LIMIT, 0)
  end

  -- the body and the addendum (from a level-1 heading "Addendum")
  local all = unlist_fancy(doc.blocks)
  local blocks, add_blocks = {}, nil
  for _, b in ipairs(all) do
    if add_blocks then
      add_blocks[#add_blocks + 1] = b
    elseif b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^%s*addendum%s*$") then
      add_blocks = {}
    else
      blocks[#blocks + 1] = b
    end
  end

  -- Citations, in document order: each `toa:` link is an occurrence and a needle (kind N inside a footnote).
  local used = {}
  local occurrences = {}
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        if not auth[key] then
          error("ca2: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter", 0)
        end
        used[key] = true
        occurrences[#occurrences + 1] = { key = key, id = "T:" .. (#occurrences + 1) }
        local rest = {}
        for j = i + 1, #list do rest[#rest + 1] = list[j] end
        need_at(occurrences[#occurrences].id, in_note and "N" or "B", plain(el.content), pandoc.utils.stringify(rest))
      elseif el.t == "Note" then
        scan_blocks(el.content, true)
      elseif el.content and type(el.content) ~= "string" then
        scan_inlines(el.content, in_note)
      end
    end
  end
  scan_blocks = function(list, in_note)
    for _, b in ipairs(list) do
      if b.t == "Para" or b.t == "Plain" then
        scan_inlines(b.content, in_note)
      elseif b.t == "BlockQuote" or b.t == "Div" then
        scan_blocks(b.content, in_note)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
      end
    end
  end

  -- The body: headings (labels, contents entries, needles) and citations (needles), in order. Its page 1 is the
  -- page of its first block.
  local body_id = "S:body"
  if blocks[1] and blocks[1].t == "Header" then
    body_id = "H:" .. (#needles + 1)
  elseif blocks[1] then
    need_at(body_id, "B", pandoc.utils.stringify(blocks[1]):sub(1, NEEDLE_MAX), "")
  end
  local body = {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local nxt = blocks[i + 1] and pandoc.utils.stringify(blocks[i + 1]):sub(1, 40) or ""
      body[#body + 1] = body_heading(b, nxt)
    else
      scan_blocks({ b }, false)
      body[#body + 1] = b
    end
  end
  -- the signature block never stands alone on a page: the last paragraph keeps with it (typst `keep`)
  if body[#body] and body[#body].t == "Para" then
    body[#body] = pandoc.Div({ body[#body] }, pandoc.Attr("", {}, { ["custom-style"] = "BodyLast" }))
  end

  local compliance, svc_title = "Certificate of Compliance", "Certificate of Service"
  need_at("C:compliance", "B", compliance, "This brief complies")
  if service then need_at("C:service", "B", svc_title, "I hereby certify") end

  -- the addendum: its own contents (level 2 headings, pages Add-1 ...) and text
  local add_toc, add_body = {}, {}
  if add_blocks then
    need_at("A:start", "B", "Addendum Table of Contents", "")
    for i, b in ipairs(add_blocks) do
      if b.t == "Header" and b.level == 2 then
        local id = "H:" .. (#needles + 1)
        local nxt = add_blocks[i + 1] and pandoc.utils.stringify(add_blocks[i + 1]):sub(1, 40) or ""
        need_at(id, "B", pandoc.utils.stringify(b.content), nxt)
        add_toc[#add_toc + 1] = { id = id, level = 2, text = b.content, k = 0 }
        add_body[#add_body + 1] = styled("SingleLine", { pandoc.Strong(b.content) })
      else
        if b.t == "Header" then
          error("ca2: in the addendum only level 2 headings are supported", 0)
        end
        scan_blocks({ b }, false)
        add_body[#add_body + 1] = b
      end
    end
  end

  local strip = {
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  }
  body = pandoc.Pandoc(body):walk(strip).blocks
  add_body = pandoc.Pandoc(add_body):walk(strip).blocks

  local toa = {}
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return sort_key(auth[x]) < sort_key(auth[y]) end)
      toa[#toa + 1] = { title = g[2], members = members, kind = g[1] }
    end
  end

  -- The needles, in document order: the two tables first, then the body's, the certificates', the addendum's.
  local toa_context = toa[1] and (toa[1].title .. " Page(s)") or pandoc.utils.stringify(blocks[1] or "")
  table.insert(needles, 1, { id = "S:toc", kind = "B", needle = norm("Table of Contents Page Table of Authorities"),
    fallback = norm("Table of Contents") })
  table.insert(needles, 2, { id = "S:toa", kind = "B",
    needle = norm("Table of Authorities " .. toa_context):sub(1, NEEDLE_MAX), fallback = norm("Table of Authorities") })
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: the front matter from the contents (i, ii ...), the body and the certificates
  -- from the body's first block (1, 2 ...), the addendum from its first page (Add-1 ...)
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  if add_blocks then nl[#nl + 1] = "#section\tA:start\tdecimal\tAdd-" end
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", add_blocks and sect_pr("rIdFtrAdd", DECIMAL) or sect_pr("rIdFtrPage", DECIMAL))

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- ---- cover ----
  addall(cover(meta))
  add(section_break("rIdFtrNone", nil))

  -- ---- front matter (lower roman): contents, authorities ----
  add(pandoc.Header(1, { pandoc.Str("Table of Contents") }))
  add(styled("RightHead", { pandoc.Str("Page") }))
  add(toc_line({ id = "S:toa", level = 1, text = { pandoc.Str("Table of Authorities") }, k = 0 }))
  for _, e in ipairs(toc) do add(toc_line(e)) end
  add(toc_line({ id = "C:compliance", level = 1, text = { pandoc.Str(compliance) }, k = 0 }))
  if service then add(toc_line({ id = "C:service", level = 1, text = { pandoc.Str(svc_title) }, k = 0 })) end
  if add_blocks then add(toc_line({ id = "A:start", level = 1, text = { pandoc.Str("Addendum") }, k = 0 })) end
  add(section_break("rIdFtrPage", ROMAN_FIRST))

  add(pandoc.Header(1, { pandoc.Str("Table of Authorities") }))
  for gi, g in ipairs(toa) do
    local head = pandoc.List({ pandoc.Strong({ pandoc.Str(g.title) }) })
    if gi == 1 then head:insert(tab_run()); head:insert(pandoc.Strong(pandoc.Underline({ pandoc.Str("Page(s)") }))) end
    add(styled("TOAGroup", head))
    for _, k in ipairs(g.members) do
      local a = auth[k]
      local line = pandoc.List({})
      if a.name then
        local nm = I(a.name)
        if g.kind == "case" then nm = pandoc.List({ pandoc.Emph(nm) }) end
        line:extend(nm)
        line:insert(pandoc.Str(","))
        line:insert(pandoc.LineBreak())
      end
      line:extend(I(a.cite))
      -- the distinct pages of the authority, in page order (typst: printed page labels, passim from PASSIM)
      local pages, seen = {}, {}
      for oi, o in ipairs(occurrences) do
        if o.key == k then
          local l = labels[o.id]
          local p = l and l.page or -oi
          if not seen[p] then
            seen[p] = true
            pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
          end
        end
      end
      table.sort(pages, function(x, y) return x.page < y.page end)
      line:insert(pandoc.Space())
      line:insert(tab_run())
      if #pages >= PASSIM then
        line:insert(pandoc.Emph({ pandoc.Str("passim") }))
      else
        local l = {}
        for _, p in ipairs(pages) do l[#l + 1] = p.label end
        line:insert(pandoc.Str(table.concat(l, ", ")))
      end
      add(styled("TOALine", line))
    end
  end
  add(section_break("rIdFtrPage", ROMAN))

  -- ---- body (arabic from 1) and the signature block ----
  addall(body)
  addall(signature_block(meta))
  add(section_break("rIdFtrPage", DECIMAL_FIRST))

  -- ---- certificate of compliance (FRAP 32(g)(1), Form 6) ----
  add(pandoc.Header(1, { pandoc.Str(compliance) }))
  add(styled("Single", { pandoc.Str("This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) and Local Rule 32.1(a)(4)(A) because this brief contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f).") }))
  local software = meta.software and plain(meta.software) or SOFTWARE
  add(styled("Single", { pandoc.Str("This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because this brief has been prepared in a proportionally spaced typeface using " .. software .. " in 14-point " .. TYPEFACE .. ".") }))
  addall(form_sig(meta))

  -- ---- certificate of service (FRAP 25(d)), when `service.certificate: true` ----
  if service then
    add(section_break("rIdFtrPage", DECIMAL))
    add(pandoc.Header(1, { pandoc.Str(svc_title) }))
    local method = (meta.service.method and plain(meta.service.method)) or "ACMS"
    add(styled("Single", { pandoc.Str("I hereby certify that on " .. plain(need(meta, "date")) .. ", a true and correct copy of the foregoing was served via " .. method .. " to all counsel of record or parties pro se.") }))
    local unreg = meta.service.unregistered or {}
    if #unreg > 0 then
      add(styled("Single", { pandoc.Str("The following case participants are NOT registered for electronic filing and were served by mail or another method (name and address):") }))
      for _, u in ipairs(unreg) do
        add(styled("Indented", { pandoc.Str(plain(u.name) .. ", " .. plain(u.address)) }))
      end
    end
    addall(form_sig(meta))
  end

  -- ---- addendum (FRAP 28(f); pages Add-1 ...) ----
  if add_blocks then
    add(section_break("rIdFtrPage", DECIMAL))
    add(pandoc.Header(1, { pandoc.Str("Addendum") }))
    add(pandoc.Header(1, { pandoc.Str("Table of Contents") }))
    for _, e in ipairs(add_toc) do add(toc_line(e)) end
    add(section_break("rIdFtrAdd", DECIMAL_FIRST))
    addall(add_body)
  end

  -- the writer would print title, author and date from the metadata at the top; the cover prints them itself
  doc.meta.title = nil
  doc.meta.author = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end

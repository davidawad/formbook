-- Bankruptcy Appellate Panel of the Ninth Circuit, appellant's reply brief: DOCX engine (docs/DOCX.md).
-- The markdown contract (the frontmatter of usage/INPUT-*.md, as in typst/bap9-opening-brief.typ) becomes a Word
-- document on docx/reference.docx. The cover, table of contents, table of authorities, signature block and
-- certificates are built here from the frontmatter, in the custom styles of reference.docx; the body keeps its
-- markdown structure. Sections: cover (no footer), front matter (lower roman, from i), body and certificates
-- (arabic, from 1), as in the typst form.
-- The pages in the contents and the table of authorities: fb render (tools/fb/src/docxpass.rs) renders the
-- document once, finds the page of every heading and citation in that PDF (the needles this filter writes to
-- FORMBOOK_NEEDLES), and renders again with those pages (FORMBOOK_PAGES) until they settle; this filter writes the
-- last section (FORMBOOK_FINAL, the body's: reference.docx's rId101 footer, arabic from 1). Word may paginate
-- slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

-- The only part that differs between the three copies (CFG).
local CFG = {
  title = "APPELLANT'S REPLY BRIEF",
  word_limit = 6500,
  -- BAP-CONTENT-001: the titles a brief may use for each required section (FRBP 8014).
  required = {},
  -- BAP-CERT: the certificates printed for this brief type
  certs = { "compliance", "service" },
}
local COURT = "UNITED STATES BANKRUPTCY APPELLATE PANEL OF THE NINTH CIRCUIT"
-- rIds of the footers in reference.docx (section 3, the body, uses rId101 from the final sectPr)
local FOOTER = { blank = "rId103", roman = "rId102" }
local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "rule", "Rules" }, { "regulation", "Regulations" }, { "other", "Other Authorities" },
}

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value (markdown inlines) as a list of inlines
local function inl_of(v)
  if v == nil then return pandoc.List() end
  if v.t == "MetaInlines" then return v end
  return pandoc.List({ pandoc.Str(plain(v)) })
end

-- concatenate inline lists (a string becomes one Str)
local function cat(parts)
  local out = pandoc.List()
  for _, p in ipairs(parts) do
    if type(p) == "string" then out:insert(pandoc.Str(p))
    else for _, i in ipairs(p) do out:insert(i) end end
  end
  return out
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)
local PAGE_SETUP = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"'
  .. ' w:header="720" w:footer="720" w:gutter="0"/>'

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing).
local needles = {}
local function need(id, kind, text, context)
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

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local PAGE_BREAK = raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

-- the paragraph that ends a section; the next section starts on a new page
local function section_end(footer_rid, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return raw('<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="' .. footer_rid
    .. '"/>' .. PAGE_SETUP .. pg .. '</w:sectPr></w:pPr></w:p>')
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- typst's count-words on the body markdown (after the frontmatter): link targets dropped, tokens with a letter or digit
local function body_words()
  local f = PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then error("bap9: cannot read the sample markdown for the word count", 0) end
  local text = h:read("a")
  h:close()
  local body = text:match("^%-%-%-[ \t]*\r?\n.-\n%-%-%-[ \t]*\r?\n(.*)$") or text
  body = body:gsub("%]%([^%)]*%)", "]"):gsub("[\t\r\n]", " ")
  local n = 0
  for tok in body:gmatch("%S+") do
    if tok:find("%w") then n = n + 1 end
  end
  return n
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  local function bail(msg) error("bap9: " .. msg, 0) end

  -- required level-1 headings (BAP-CONTENT-001)
  local h1 = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then h1[plain(b.content)] = true end
  end
  for _, titles in ipairs(CFG.required) do
    local ok = false
    for _, t in ipairs(titles) do ok = ok or h1[t] end
    if not ok then bail("the brief has no level-1 heading `" .. table.concat(titles, "` or `") .. "` (FRBP 8014(a))") end
  end

  -- length (BAP-LENGTH-001): the body only
  local words = body_words()
  if words > CFG.word_limit then bail("the brief has " .. words .. " words; FRBP 8015(a)(7) allows " .. CFG.word_limit) end

  -- authorities (frontmatter registry); a link [text](toa:KEY) in the body cites KEY
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    local name, cite = plain(a.name), plain(a.cite)
    auth[key] = {
      kind = plain(a.kind), name = a.name, cite = inl_of(a.cite), same = (name == cite),
      sort = (a.sort and plain(a.sort) or (name .. " " .. cite)):lower(),
    }
  end
  -- Citations and headings, in document order: each `toa:` link is an occurrence and a needle (kind N inside a
  -- footnote), each heading a needle and, at levels 1 and 2, a contents entry (typst: outline depth 2).
  local used, occurrences, entries = {}, {}, {}
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        if not auth[key] then bail("link `toa:" .. key .. "` has no entry under `authorities:`") end
        used[key] = true
        occurrences[#occurrences + 1] = { key = key, id = "T:" .. (#occurrences + 1) }
        local rest = {}
        for j = i + 1, #list do rest[#rest + 1] = list[j] end
        need(occurrences[#occurrences].id, in_note and "N" or "B", plain(el.content), pandoc.utils.stringify(rest))
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
  local blocks = doc.blocks
  local body_id = "S:body"
  if blocks[1] and blocks[1].t == "Header" then
    body_id = "H:1"
  elseif blocks[1] then
    need(body_id, "B", pandoc.utils.stringify(blocks[1]):sub(1, NEEDLE_MAX), "")
  end
  local h_n = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = blocks[i + 1] and pandoc.utils.stringify(blocks[i + 1]):sub(1, 40) or ""
      need(id, "B", plain(b.content), nxt)
      if b.level <= 2 then entries[#entries + 1] = { id = id, level = b.level, text = plain(b.content) } end
    else
      scan_blocks({ b }, false)
    end
  end
  doc = doc:walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  })

  -- the needles of the two tables come first (they precede the body), then the body's
  local first_group = ""
  for _, g in ipairs(TOA_GROUPS) do
    for _, a in pairs(auth) do if first_group == "" and a.kind == g[1] then first_group = g[2] end end
  end
  table.insert(needles, 1, { id = "S:toc", kind = "B",
    needle = norm("TABLE OF CONTENTS " .. (entries[1] and entries[1].text or "")):sub(1, NEEDLE_MAX), fallback = norm("TABLE OF CONTENTS") })
  if next(auth) ~= nil then
    table.insert(needles, 2, { id = "S:toa", kind = "B", needle = norm("TABLE OF AUTHORITIES " .. first_group), fallback = norm("TABLE OF AUTHORITIES") })
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: the front matter from the contents (i, ii ...), the body from its first block
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rId101"/>' .. PAGE_SETUP
    .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>')

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover (BAP-COVER-001); section 1 has no footer
  add(styled("Centered", { pandoc.Strong(inl_of(meta.case_number)) }))
  if meta.district_court_case then add(styled("Centered", inl_of(meta.district_court_case))) end
  add(styled("CenterGap", { pandoc.Strong({ pandoc.Str(COURT) }) }))
  for i, side in ipairs(meta.caption) do
    if i > 1 then add(styled("CenterGap", { pandoc.Str("v.") })) end
    for _, n in ipairs(side.names) do add(styled("Centered", inl_of(n))) end
    add(styled("Centered", inl_of(side.designation)))
  end
  add(styled("CenterGap", inl_of(meta.proceeding)))
  add(styled("CenterGap", { pandoc.Strong({ pandoc.Str(CFG.title) }) }))
  for gi, g in ipairs(meta.counsel) do
    for ni, n in ipairs(g.names) do add(styled(gi > 1 and ni == 1 and "CenterGap" or "Centered", inl_of(n))) end
    for _, l in ipairs(g.lines or {}) do add(styled("Centered", inl_of(l))) end
  end
  add(styled("Centered", inl_of(meta.phone)))
  add(section_end(FOOTER.blank))

  -- front matter (section 2, lower roman): table of contents, table of authorities
  add(styled("SectionTitle", { pandoc.Strong({ pandoc.Str("TABLE OF CONTENTS") }) }))
  -- each entry: the title, the dot leader and its page (TOCEntry1/2: a right tab inside the margin, past the page
  -- column's right indent; level 2 indented under its section, as typst's outline indent)
  for _, e in ipairs(entries) do
    add(styled(e.level == 1 and "TOCEntry1" or "TOCEntry2",
      { pandoc.Str(e.text), pandoc.Space(), TAB, pandoc.Str(label_of(e.id)) }))
  end
  add(PAGE_BREAK)

  -- the table of authorities is printed when the frontmatter has a registry (typst: `if authorities != none`)
  if next(auth) ~= nil then
  add(styled("SectionTitle", { pandoc.Strong({ pandoc.Str("TABLE OF AUTHORITIES") }) }))
  for _, g in ipairs(TOA_GROUPS) do
    local keys = {}
    for k, a in pairs(auth) do if a.kind == g[1] then keys[#keys + 1] = k end end
    if #keys > 0 then
      table.sort(keys, function(x, y) return auth[x].sort < auth[y].sort end)
      add(styled("Single", { pandoc.Strong({ pandoc.Str(g[2]) }) }))
      for _, k in ipairs(keys) do
        if not used[k] then bail("authority `" .. k .. "` is listed but never cited") end
        local a = auth[k]
        local line = pandoc.List()
        if a.name and not a.same then line = cat({ a.name, ", " }) end
        line:extend(a.cite)
        -- the distinct pages of the authority, in page order (typst: passim from PASSIM pages)
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
        line:extend({ pandoc.Space(), TAB })
        if #pages >= PASSIM then
          line:insert(pandoc.Str("passim"))
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          line:insert(pandoc.Str(table.concat(l, ", ")))
        end
        add(styled("TOAEntry", line))
      end
    end
  end
  end
  add(section_end(FOOTER.roman, "lowerRoman"))

  -- body (section 3, arabic from 1); the last paragraph stays with the signature block
  local n = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if i == n and b.t == "Para" then b = styled("KeepWithNext", b.content) end
    add(b)
  end
  local sig = meta.signature
  if sig then
    add(styled("Signature", cat({ "/s/ ", inl_of(sig.signer) })))
    for _, l in ipairs(sig.lines or {}) do add(styled("Signature", inl_of(l))) end
    if meta.date then add(styled("Signature", inl_of(meta.date))) end
  end

  -- certificates (BAP R. 8015(a)-1, FRBP 8015(g) and (h)); each stays together
  local function cert(title, blocks)
    add(styled("SectionTitle", { pandoc.Strong({ pandoc.Str(title) }) }))
    addall(blocks)
  end
  local function sigline()
    return styled("Signature", cat({ "/s/ ", inl_of(sig and sig.signer) }))
  end
  add(PAGE_BREAK)
  local function has(c) for _, x in ipairs(CFG.certs) do if x == c then return true end end return false end

  if has("interested-parties") then
    local blocks = { styled("Single", { pandoc.Str("The following listed parties have an interest in the outcome of this case. These representations are made in order that judges of the Panel may evaluate possible disqualification or recusal.") }) }
    for _, p in ipairs(meta.interested_parties or {}) do blocks[#blocks + 1] = styled("Hanging", inl_of(p)) end
    blocks[#blocks + 1] = sigline()
    cert("CERTIFICATION OF INTERESTED PARTIES", blocks)
  end
  if has("related-cases") then
    local rc = meta.related_cases or {}
    local blocks = {}
    local status = rc.status and plain(rc.status) or "none"
    if status == "none" then
      blocks[1] = styled("Single", { pandoc.Str("Appellant is aware of no related cases or appeals pending before this Panel, the Ninth Circuit Court of Appeals, or the district court.") })
    else
      blocks[1] = styled("Single", { pandoc.Str("The following related cases and appeals are known to the appellant:") })
      for _, c in ipairs(rc.cases or {}) do
        blocks[#blocks + 1] = styled("Hanging", cat({ inl_of(c.number), ", ", inl_of(c.name), ", ", inl_of(c.relationship) }))
      end
    end
    blocks[#blocks + 1] = sigline()
    cert("CERTIFICATION OF RELATED CASES", blocks)
  end
  if has("compliance") then
    cert("CERTIFICATE OF COMPLIANCE", {
      styled("Single", { pandoc.Str("This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g).") }),
      styled("Single", { pandoc.Str("This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, 14-point Times New Roman, with plain roman type and italics for emphasis.") }),
      sigline(),
    })
  end
  if has("service") then
    local svc = meta.service or {}
    local unreg = svc.unregistered or {}
    local blocks = {
      styled("Single", cat({ "I hereby certify that on ", inl_of(meta.date), ", I electronically filed the foregoing document with the Clerk of the Court for the Bankruptcy Appellate Panel for the Ninth Circuit by using the CM/ECF system." })),
    }
    if #unreg == 0 then
      blocks[2] = styled("Single", { pandoc.Str("I certify that all parties of record to this appeal either are registered CM/ECF users, or have registered for electronic notice, or have consented in writing to electronic service, and that service will be accomplished through the CM/ECF system.") })
    else
      blocks[2] = styled("Single", { pandoc.Str("I further certify that some of the parties of record to this appeal have not consented to electronic service. I have mailed the foregoing document by First-Class Mail, postage prepaid, or have dispatched it to a third party commercial carrier for delivery within 3 calendar days, to the following parties:") })
      for _, u in ipairs(unreg) do
        blocks[#blocks + 1] = styled("Hanging", cat({ inl_of(u.name), ", ", inl_of(u.address) }))
      end
    end
    blocks[#blocks + 1] = sigline()
    cert("CERTIFICATE OF SERVICE", blocks)
  end

  doc.blocks = out
  doc.meta = pandoc.Meta({})  -- the frontmatter is consumed here; no title block
  return doc
end

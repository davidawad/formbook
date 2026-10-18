-- Bankruptcy Appellate Panel of the Ninth Circuit, appellant's opening brief: DOCX engine (docs/DOCX.md).
-- The markdown contract (the frontmatter of usage/INPUT-*.md, as in typst/bap9-opening-brief.typ) becomes a Word
-- document on docx/reference.docx. The cover, table of contents, table of authorities, signature block and
-- certificates are built here from the frontmatter, in the custom styles of reference.docx; the body keeps its
-- markdown structure. Sections: cover (no footer), front matter (lower roman, from i), body and certificates
-- (arabic, from 1), as in the typst form.
-- Known limits (BLOCKED, see ../README.md "Engines"): the table of contents is a TOC field whose cached result lists
-- the headings without page numbers (Word fills them in on a field update); the table of authorities lists the
-- cited authorities without page numbers.

-- The only part that differs between the three copies (CFG).
local CFG = {
  title = "APPELLANT'S OPENING BRIEF",
  word_limit = 13000,
  -- BAP-CONTENT-001: FRBP 8014(a)(1)-(7). Each requirement needs one of its titles as a level-1 heading.
  required = {
    { "Statement of Jurisdiction", "Jurisdictional Statement" },
    { "Statement of Issues and Standards of Review", "Statement of Issues", "Standard of Review", "Standards of Review" },
    { "Statement of the Case", "Statement of Case" },
    { "Summary of Argument", "Summary of the Argument" },
    { "Argument" },
    { "Conclusion" },
  },
  -- BAP-CERT-001, BAP-CERT-002, compliance, service
  certs = { "interested-parties", "related-cases", "compliance", "service" },
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

local PAGE_BREAK = raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

-- the paragraph that ends a section; the next section starts on a new page
local function section_end(footer_rid, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return raw('<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="' .. footer_rid
    .. '"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"'
    .. ' w:header="720" w:footer="720" w:gutter="0"/>' .. pg .. '</w:sectPr></w:pPr></w:p>')
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
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then bail("link `toa:" .. key .. "` has no entry under `authorities:`") end
      used[key] = true
      return el.content
    end,
  })

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
  add(raw('<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r></w:p>'))
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 2 then
      add(styled(b.level == 1 and "Single" or "TOCLevel2", { pandoc.Str(plain(b.content)) }))
    end
  end
  add(raw('<w:p><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'))
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
        add(styled("Hanging", line))
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
      styled("Single", { pandoc.Str("This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, 14-point EB Garamond, with plain roman type and italics for emphasis.") }),
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

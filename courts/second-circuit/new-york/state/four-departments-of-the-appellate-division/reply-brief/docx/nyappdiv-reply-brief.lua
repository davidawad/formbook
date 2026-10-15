-- New York Appellate Division, Fourth Department: reply brief, DOCX engine (docs/DOCX.md).
-- The markdown contract (../README.md) becomes a Word document on reference.docx: the cover, the table of
-- contents, the table of authorities (roman page numbers), the body (arabic from 1), the signature block,
-- the printing specifications statement and the affidavit of service. The metadata is read here; no
-- case-specific text lives in this file.
-- Known limits (BLOCKED, see the README "Engines" section): the contents are a TOC field whose cached entries
-- have no page numbers until a field update; the authorities list has no page references; the cover is a
-- centered layout (no caption rules), and the word count is measured from the markdown source, with the
-- word limit enforced here as in the typst template.

local CFG = {
  word_limit = 7000, -- 22 NYCRR 1250.8(f)(2): reply brief
}

local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Statutes" }, { "regulation", "Regulations" },
  { "rule", "Rules" }, { "constitution", "Constitutional Provisions" }, { "other", "Other Authorities" },
}

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw(x) return pandoc.RawBlock("openxml", x) end

local function page_break()
  return raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- A section break paragraph: it ends the section it sits in. The footer part is named by the id that the
-- reference's footer uses in the output (rId100 is kept by pandoc; checked on the opening brief).
local function section_break(fmt, footer_rid, restart)
  local ref = footer_rid and ('<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>') or ""
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0"/><w:sectPr>' .. ref
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="' .. fmt .. '"' .. (restart and ' w:start="1"' or "") .. '/></w:sectPr></w:pPr></w:p>')
end

local function toc_field(entries)
  local out = {}
  out[#out + 1] = raw('<w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r></w:p>')
  for _, h in ipairs(entries) do out[#out + 1] = styled("Single", { pandoc.Str(h) }) end
  out[#out + 1] = raw('<w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
  return out
end

-- Word count of the markdown body (frontmatter excluded), footnote text included, as the typst template counts it.
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return 0 end
  local h = io.open(f, "r")
  if not h then return 0 end
  local text = h:read("a")
  h:close()
  local n, dashes = 0, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    else
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

function Pandoc(doc)
  local meta = doc.meta
  doc.meta = pandoc.Meta({}) -- the cover is built from these values; pandoc must not add a title block
  local words = source_words()
  if words > CFG.word_limit then
    error("nyappdiv-reply-brief: the brief has " .. words .. " words; 22 NYCRR 1250.8(f)(2) limits a reply to " .. CFG.word_limit, 0)
  end

  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
    end
  end
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("nyappdiv-reply-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      return el.content
    end,
  })

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover (no page number)
  local arg = meta.argument or {}
  add(styled("Single", { pandoc.Str("Case No.: " .. plain(meta.docket)) }))
  if meta.county_clerk_index then add(styled("Single", meta.county_clerk_index)) end
  add(styled("Right", {}))
  if arg.presenter then
    add(styled("Right", { pandoc.Str("To be Argued by:") }))
    add(styled("Right", { pandoc.Strong(arg.presenter) }))
    add(styled("Right", { pandoc.Str("(Time Requested: " .. plain(arg.time_requested) .. ")") }))
  else
    add(styled("Right", { pandoc.Str("Submitted without oral argument") }))
  end
  add(styled("Centered", {}))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("New York Supreme Court") }) }))
  add(styled("Centered", { pandoc.Str("Appellate Division\u{2014}" .. plain(meta.department)) }))
  add(styled("Centered", {}))
  for i, side in ipairs(meta.caption or {}) do
    for _, n in ipairs(side.names or {}) do add(styled("Single", n)) end
    add(styled("Counsel", side.designation))
    if i < #meta.caption then add(styled("Centered", { pandoc.Str("--against--") })) end
  end
  if meta.caption_note then add(styled("Centered", meta.caption_note)) end
  add(styled("Centered", {}))
  add(styled("Centered", { pandoc.Strong(meta.brief_title or {}) }))
  add(styled("Centered", {}))
  for _, g in ipairs(meta.counsel or {}) do
    if g.firm then add(styled("Counsel", { pandoc.Strong({ pandoc.Str(plain(g.firm):upper()) }) })) end
    for _, l in ipairs(g.lines or {}) do add(styled("Counsel", l)) end
    add(styled("Counsel", {}))
  end
  if meta.attorneys_for then add(styled("Counsel", { pandoc.Emph(meta.attorneys_for) })) end
  add(section_break("decimal", nil, false))

  -- front matter: contents and authorities, lowercase roman
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("TABLE OF CONTENTS") }) }))
  add(styled("Centered", {}))
  local heads = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then heads[#heads + 1] = plain(b.content) end
  end
  addall(toc_field(heads))
  add(page_break())

  add(styled("Centered", { pandoc.Strong({ pandoc.Str("TABLE OF AUTHORITIES") }) }))
  add(styled("Centered", {}))
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local ax = auth[x].sort and plain(auth[x].sort) or (plain(auth[x].name) .. " " .. plain(auth[x].cite))
        local ay = auth[y].sort and plain(auth[y].sort) or (plain(auth[y].name) .. " " .. plain(auth[y].cite))
        return ax:lower() < ay:lower()
      end)
      add(styled("Single", { pandoc.Strong({ pandoc.Str(g[2]) }) }))
      for _, k in ipairs(members) do
        local a = auth[k]
        local line = pandoc.List({})
        if a.name then
          local nm = a.name
          if g[1] == "case" then nm = { pandoc.Emph(nm) } end
          line:extend(nm)
          line:insert(pandoc.Str(","))
          line:insert(pandoc.LineBreak())
        end
        line:extend(a.cite)
        add(styled("Single", line))
      end
    end
  end
  add(section_break("lowerRoman", "rId100", true))

  -- body (arabic from 1), then the signature block
  addall(doc.blocks)
  local sig = meta.signature or {}
  if sig.date then add(styled("Single", { pandoc.Str(plain(sig.date)) })) end
  if sig.place then add(styled("Single", { pandoc.Str(plain(sig.place)) })) end
  for _, b in ipairs(sig.blocks or {}) do
    add(styled("Signature", { pandoc.Strong({ pandoc.Str(plain(b.firm):upper()) }) }))
    if b.by then add(styled("Signature", { pandoc.Str("By: ________________________") })) end
    for _, n in ipairs(b.names or {}) do add(styled("Signature", n)) end
    for _, l in ipairs(b.lines or {}) do add(styled("Signature", { pandoc.Emph(l) })) end
    add(styled("Single", {}))
  end
  if sig.attorneys_for then add(styled("Single", { pandoc.Emph(sig.attorneys_for) })) end

  -- printing specifications statement (1250.8(j)), then the affidavit of service
  add(page_break())
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("PRINTING SPECIFICATIONS STATEMENT") }) }))
  add(styled("Centered", {}))
  add(pandoc.Para({ pandoc.Str("I hereby certify pursuant to 22 NYCRR 1250.8(j) that the foregoing brief was prepared on a computer using a word-processing system. A proportionally spaced typeface was used, as follows: name of typeface, EB Garamond; point size, 14; line spacing, double.") }))
  add(pandoc.Para({ pandoc.Strong({ pandoc.Str("Word Count.") }), pandoc.Str(" The total number of words in this brief, inclusive of point headings and footnotes and exclusive of pages containing the table of contents, table of citations, proof of service, and this statement, is " .. group_digits(words) .. ".") }))
  add(page_break())
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("AFFIDAVIT OF SERVICE") }) }))
  add(styled("Centered", {}))
  add(styled("Single", { pandoc.Str("STATE OF NEW YORK )") }))
  add(styled("Single", { pandoc.Str(") ss.:") }))
  add(styled("Single", { pandoc.Str("COUNTY OF ____________ )") }))
  add(pandoc.Para({ pandoc.Str("____________________, being duly sworn, deposes and says: deponent is not a party to this action, is over 18 years of age, and resides at ____________________.") }))
  add(pandoc.Para({ pandoc.Str("On the ____ day of ____________, 20__, deponent served the within brief upon each attorney for each party to this appeal, at the address designated by that attorney for that purpose, by ____________________.") }))
  add(styled("Signature", {}))
  add(styled("Signature", { pandoc.Str("____________________") }))
  add(styled("Signature", { pandoc.Str("Sworn to before me this ____ day of ____________, 20__") }))

  doc.blocks = out
  return doc
end

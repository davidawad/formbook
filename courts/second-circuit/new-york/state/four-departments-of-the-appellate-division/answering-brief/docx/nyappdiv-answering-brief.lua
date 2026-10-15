-- New York Appellate Division (all four Departments): answering brief (respondent), DOCX engine (docs/DOCX.md).
-- The markdown contract (../README.md) becomes a Word document on reference.docx: the cover, the table of
-- contents, the table of authorities, the body, the signature block, the printing specifications statement
-- and the affidavit of service are built here from the YAML metadata; the body keeps its markdown structure.
-- No case-specific text lives in this file.
-- Known limits (BLOCKED, see the README "Engines" section): the contents are a TOC field whose cached entries
-- have no page numbers until a field update; the authorities list has no page references; the word count is
-- measured from the markdown source (footnote definitions excluded, as in the typst template), not by Word.

local CFG = {
  word_limit = 14000, -- 22 NYCRR 1250.8(f)(2): respondent's brief
}

local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
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

-- A section break paragraph: it ends the section it sits in. The cover names no footer (no page number);
-- the front matter and body name the footer part (rId100, kept by pandoc; checked on the opening brief).
local function section_break(fmt, footer_rid, restart)
  local ref = footer_rid and ('<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>') or ""
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0"/><w:sectPr>' .. ref
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="' .. fmt .. '"' .. (restart and ' w:start="1"' or "") .. '/></w:sectPr></w:pPr></w:p>')
end

local function toc_field(entries)
  local out = {}
  out[#out + 1] = raw('<w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r></w:p>')
  for _, h in ipairs(entries) do out[#out + 1] = styled("Single", { pandoc.Str(h) }) end
  out[#out + 1] = raw('<w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
  return out
end

-- Word count of the markdown body: frontmatter and footnote definitions excluded (the typst template's rule).
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
    elseif not line:match("^%[%^[^%]]+%]:") then
      local s = line
      s = s:gsub("<!%-%-.-%-%->", " ")
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
    error("nyappdiv-answering-brief: the brief has " .. words .. " words; 22 NYCRR 1250.8(f)(2) limits it to " .. CFG.word_limit, 0)
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
      if not auth[key] then error("nyappdiv-answering-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      return el.content
    end,
  })

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover (no page number)
  add(styled("Single", { pandoc.Str(plain(meta.index_no)) }))
  add(styled("Single", { pandoc.Str(plain(meta.docket)) }))
  add(styled("Centered", {}))
  add(styled("Centered", { pandoc.Str(plain(meta.court)) }))
  add(styled("Centered", {}))
  for i, side in ipairs(meta.caption or {}) do
    for _, n in ipairs(side.names or {}) do add(styled("Centered", n)) end
    add(styled("Centered", side.designation))
    if i < #meta.caption then add(styled("Centered", { pandoc.Emph({ pandoc.Str("--against--") }) })) end
  end
  add(styled("Centered", {}))
  local cal = meta.calendar or {}
  if cal.mode == "submitted" then
    add(styled("Right", { pandoc.Str("Submitted") }))
  else
    add(styled("Right", { pandoc.Str("Argued: " .. plain(cal.argued_by or "[attorney]")) }))
    add(styled("Right", { pandoc.Str("Time requested: " .. plain(cal.time or "[time]")) }))
  end
  add(styled("Centered", {}))
  add(styled("Centered", { pandoc.Strong(meta.brief_title or {}) }))
  add(styled("Centered", {}))
  local c = meta.counsel or {}
  for _, n in ipairs(c.names or {}) do add(styled("Counsel", n)) end
  for _, l in ipairs(c.lines or {}) do add(styled("Counsel", l)) end
  if meta.phone then add(styled("Counsel", meta.phone)) end
  if c.email then add(styled("Counsel", c.email)) end
  add(section_break("decimal", nil, false))

  -- front matter: contents and authorities (arabic numbering continues from the cover, as in the typst template)
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("TABLE OF CONTENTS") }) }))
  add(styled("Centered", {}))
  local heads = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 2 then heads[#heads + 1] = plain(b.content) end
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
  add(page_break())

  -- body, then the signature block
  addall(doc.blocks)
  local sig = meta.signature or {}
  add(styled("Single", { pandoc.Str("Respectfully submitted,") }))
  add(styled("Signature", {}))
  add(styled("Signature", { pandoc.Str(plain(sig.signer)) }))
  for _, l in ipairs(sig.lines or {}) do add(styled("Signature", l)) end
  if meta.date then add(styled("Single", meta.date)) end

  -- printing specifications statement (22 NYCRR 1250.8(j))
  add(page_break())
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("PRINTING SPECIFICATIONS STATEMENT") }) }))
  add(styled("Centered", {}))
  add(pandoc.Para({ pandoc.Str("This brief was prepared on a computer. The typeface is EB Garamond, a serifed, proportionally spaced typeface. The body is printed in 14 point type and footnotes in 12 point type. The line spacing is double-spaced. The word count, exclusive of the pages containing the table of contents, table of authorities, proof of service and certificate of compliance, and exclusive of the signature block, is " .. group_digits(words) .. " words. The word count was made by the word-processing system used to prepare the brief.") }))
  add(styled("Signature", {}))
  add(styled("Signature", { pandoc.Str(plain(sig.signer)) }))

  -- affidavit of service (the method and the affiant come from the metadata)
  if meta.service then
    add(page_break())
    add(styled("Centered", { pandoc.Strong({ pandoc.Str("AFFIDAVIT OF SERVICE") }) }))
    add(styled("Centered", {}))
    add(pandoc.Para({ pandoc.Str(plain(meta.service.affiant or "[Affiant name]") .. " states that on the date below copies of this brief were served on counsel for every party by " .. plain(meta.service.method) .. ".") }))
    for _, u in ipairs(meta.service.unregistered or {}) do
      add(styled("Single", { pandoc.Str(plain(u.name)) }))
      add(styled("Single", { pandoc.Str(plain(u.address)) }))
    end
    add(styled("Signature", {}))
    add(styled("Signature", { pandoc.Str(plain(sig.signer)) }))
  end

  doc.blocks = out
  return doc
end

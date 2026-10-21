-- U.S. Court of Appeals for Veterans Claims brief, DOCX engine (docs/DOCX.md; ../README.md, "Engines").
-- The markdown contract (the sample's YAML frontmatter, as in typst/cavc-answering-brief.typ) becomes a Word
-- document on reference.docx: the caption page, the table of contents and table of authorities, the body with
-- the Rule 28 labels and indents, the signature block and the certificate of service. Section breaks give the
-- page numbers: caption none; contents and authorities lower roman from i; body arabic from 1; certificate
-- lower roman from i (Vet. App. R. 32(d)).
-- Known limits (BLOCKED in the PR, see ../README.md "Engines"): the table of contents and the table of
-- authorities carry no page numbers (they need a pagination pass this engine does not have); the 30-page
-- limit of R. 32(e) is checked by the typst template only.

-- The only part that differs between the two copies (answering-brief/docx and opening-brief/docx).
local CFG = {
  kind = "answering-brief",
  required = { "summary of the argument", "argument", "conclusion" },
}

-- typst's toa-groups, in order
local TOA_GROUPS = {
  { "case", "Cases:" }, { "statute", "Statutes:" }, { "regulation", "Regulations:" },
  { "rule", "Rules:" }, { "other", "Other Authorities:" },
  { "rba", "Citations to the Record Before the Agency:" },
}

-- The footers fb render adds (docxpass.rs), not the reference document's: pandoc may renumber those ids, and a
-- sectPr naming a missing one stops the .docx from opening.
local FOOTER_PAGE = "rIdFtrPage"   -- PAGE field, centered
local FOOTER_BLANK = "rIdFtrNone"  -- the caption page

local function fail(msg) error(CFG.kind .. ": " .. msg, 0) end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value (markdown inlines) as a list of inlines
local function inl(v)
  if v == nil then return pandoc.List {} end
  if type(v) == "string" then return pandoc.List { pandoc.Str(v) } end
  if v.t == "MetaInlines" then return pandoc.List(v) end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return pandoc.List { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function S(text) return pandoc.List { pandoc.Str(text) } end

local function cat(...)
  local r = pandoc.List {}
  for _, t in ipairs({ ... }) do
    for _, x in ipairs(t) do r:insert(x) end
  end
  return r
end

local function need(meta, key)
  if meta[key] == nil then fail("missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- empty paragraphs with the rule styles (a border with no text)
local DOUBLE_RULE = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="DoubleRule"/></w:pPr></w:p>')
local SHORT_RULE = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="ShortRule"/></w:pPr></w:p>')

local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- the paragraph that ends a section carries the section properties (Word: the section ends here)
-- extra: XML after the footer reference (the last section keeps the reference document's footnote restart)
local function sect_pr(footer, fmt, extra)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. (extra or "")
    .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="432" w:gutter="0"/>'
    .. pg .. '</w:sectPr>'
end

local function section_break(footer, fmt)
  return pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. sect_pr(footer, fmt) .. "</w:pPr></w:p>")
end

-- the last section: fb render puts it in place of the reference document's ($FORMBOOK_FINAL)
local function write_final(footer, fmt)
  local path = os.getenv("FORMBOOK_FINAL")
  if path == nil then return end
  local f = assert(io.open(path, "w"))
  f:write(sect_pr(footer, fmt, '<w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr>'))
  f:close()
end

local function xml_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

-- Rule 28 structure (typst check-sections): the level-1 headings must contain the required ones in order
local function check_sections(blocks)
  local heads = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then heads[#heads + 1] = plain(b.content):lower():gsub("^%s+", ""):gsub("%s+$", "") end
  end
  local i = 1
  for _, want in ipairs(CFG.required) do
    local found = false
    while i <= #heads and not found do
      found = heads[i]:sub(1, #want) == want
      i = i + 1
    end
    if not found then fail("Vet. App. R. 28 needs a level-1 section `# " .. want .. "` in this order") end
  end
end

local function cover(meta)
  local out = {}
  local function add(b) out[#out + 1] = b end
  add(styled("Centered", cat(
    { pandoc.Strong(cat(S("Vet. App. No. "), inl(need(meta, "case_number")))) })))
  add(DOUBLE_RULE)
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("IN THE UNITED STATES COURT OF APPEALS"),
    pandoc.LineBreak(), pandoc.Str("FOR VETERANS CLAIMS") }) }))
  add(SHORT_RULE)
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names or {}) do add(styled("Centered", inl(name))) end
    add(styled("Counsel", inl(side.designation)))
    if i < #sides then add(styled("Centered", S("v."))) end
  end
  add(SHORT_RULE)
  add(styled("Centered", { pandoc.Strong(inl(need(meta, "proceeding"))) }))
  add(SHORT_RULE)
  local title = need(meta, "brief_title")
  add(styled("Centered", { pandoc.Strong(S(plain(title):upper())) }))
  add(SHORT_RULE)
  local groups = need(meta, "counsel")
  for gi, g in ipairs(groups) do
    for _, name in ipairs(g.names or {}) do add(styled("Counsel", inl(name))) end
    local lines = g.lines or {}
    for _, l in ipairs(lines) do add(styled("Counsel", { pandoc.Emph(inl(l)) })) end
    if gi == #groups then add(styled("Counsel", { pandoc.Emph(inl(need(meta, "phone"))) })) end
  end
  add(DOUBLE_RULE)
  return out
end

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  local function add(b) out[#out + 1] = b end
  add(styled("Keep", S("Respectfully submitted,")))
  add(styled("Keep", cat(S("s/ "), inl(sig.signer))))
  add(styled("Keep", S(plain(sig.signer):upper())))
  for _, l in ipairs(sig.lines or {}) do add(styled("Keep", { pandoc.Emph(inl(l)) })) end
  add(styled("Single", { pandoc.Emph(inl(need(meta, "phone"))) }))
  if meta.date then add(styled("Single", inl(meta.date))) end
  return out
end

-- Rule 28(a)(1), (2): the table of authorities lists the authorities cited (a `toa:` link in the body).
-- Page numbers are not generated by this engine (see the header comment).
local function toa(meta, used)
  local auth = meta.authorities or {}
  local out = {}
  local function add(b) out[#out + 1] = b end
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      local function sort_key(k)
        local a = auth[k]
        local s = a.sort and plain(a.sort) or (plain(a.name or "") .. " " .. plain(a.cite))
        return s:lower():gsub("[^%w ]", "")
      end
      table.sort(members, function(x, y) return sort_key(x) < sort_key(y) end)
      add(styled("Single", { pandoc.Strong(S(g[2])) }))
      for _, k in ipairs(members) do
        local a = auth[k]
        local line = pandoc.List {}
        if a.name then
          local nm = inl(a.name)
          if plain(a.kind) == "case" then nm = { pandoc.Emph(nm) } end
          line:extend(nm)
          line:insert(pandoc.Str(","))
          line:insert(pandoc.LineBreak())
        end
        line:extend(inl(a.cite))
        add(styled("Single", line))
      end
    end
  end
  return out
end

-- the table of contents: every level-1 to level-4 heading, with its label (typst's outline depth 4)
local function toc_entries(entries)
  local out = {}
  for _, e in ipairs(entries) do
    local ind = e.ind
    local body = '<w:r><w:t xml:space="preserve">' .. xml_escape(e.label) .. '</w:t></w:r>'
    if e.label ~= "" then body = body .. '<w:r><w:tab/></w:r>' end
    body = body .. '<w:r><w:t xml:space="preserve">' .. xml_escape(e.title) .. '</w:t></w:r>'
    local pPr = '<w:spacing w:before="' .. (e.level == 1 and "240" or "120") .. '" w:after="0" w:line="240" w:lineRule="auto"/>'
      .. '<w:ind w:left="' .. (ind + (e.label ~= "" and 720 or 0)) .. '" w:hanging="' .. (e.label ~= "" and 720 or 0) .. '"/>'
    out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr>' .. pPr .. '</w:pPr>' .. body .. '</w:p>')
  end
  return out
end

-- Rule 28 labels and indents, as typst: argument point headings I., A., 1., a.; elsewhere A., 1., a., (1).
-- A level-2 heading in the argument is a centered point heading; the others hang under their label.
local function body_blocks(blocks)
  local out = {}
  local counters = { 0, 0, 0, 0, 0, 0 }
  local in_arg = false
  local entries = {}
  local function bump(level)
    counters[level] = counters[level] + 1
    for l = level + 1, 6 do counters[l] = 0 end
    return counters[level]
  end
  local function label(level, n)
    if in_arg then
      if level == 2 then return roman(n) .. "." end
      if level == 3 then return string.char(64 + n) .. "." end
      if level == 4 then return tostring(n) .. "." end
      if level == 5 then return string.char(96 + n) .. "." end
    else
      if level == 2 then return string.char(64 + n) .. "." end
      if level == 3 then return tostring(n) .. "." end
      if level == 4 then return string.char(96 + n) .. "." end
      if level == 5 then return "(" .. n .. ")" end
    end
    fail("headings deeper than level 5 are not supported")
  end
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = b.level
      if level > 5 then fail("headings deeper than level 5 are not supported") end
      if level == 1 then
        bump(1)
        in_arg = (plain(b.content):lower():gsub("^%s+", ""):gsub("%s+$", "") == "argument")
        out[#out + 1] = b
        if level <= 4 then entries[#entries + 1] = { level = 1, label = "", title = plain(b.content):upper(), ind = 0 } end
      else
        local n = bump(level)
        local lab = label(level, n)
        if level <= 4 then
          local ind
          if in_arg and level == 2 then ind = 0 else ind = (in_arg and (level - 2) or (level - 1)) * 720 end
          entries[#entries + 1] = { level = level, label = lab, title = plain(b.content), ind = ind }
        end
        if in_arg and level == 2 then
          out[#out + 1] = styled("Point", cat(S(lab .. " "), b.content))
        else
          local depth = in_arg and (level - 2) or (level - 1)
          local lab_i, body_i = S(lab), b.content
          if level >= 4 then
            lab_i = { pandoc.Emph(lab_i) }
            body_i = { pandoc.Emph(body_i) }
          end
          local tab = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
          out[#out + 1] = styled("Sub" .. depth, cat(lab_i, pandoc.List { tab }, body_i))
        end
      end
    else
      out[#out + 1] = b
    end
  end
  return out, entries
end

function Pandoc(doc)
  local meta = doc.meta
  check_sections(doc.blocks)

  -- every toa: link in the body names an authority (the link text stays)
  local used = {}
  local auth = meta.authorities or {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
      used[key] = true
      return el.content
    end,
  })

  -- the parts from the markdown
  local body, entries = body_blocks(doc.blocks)

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- caption page (Rule 32(c); Form 2): no page number
  addall(cover(meta))
  add(section_break(FOOTER_BLANK, nil))

  -- table of contents and table of authorities: lower roman from i (Rule 32(d))
  add(styled("FrontHeading", S("Table of Contents")))
  addall(toc_entries(entries))
  add(page_break())
  add(styled("FrontHeading", S("Table of Authorities")))
  addall(toa(meta, used))
  add(section_break(FOOTER_PAGE, "lowerRoman"))

  -- the brief: arabic from 1 (Rule 32(d)); the last paragraph is kept with the signature
  local last = #body
  for i, b in ipairs(body) do
    if i == last and b.t == "Para" then
      add(styled("KeepBody", b.content))
    else
      add(b)
    end
  end
  addall(signature(meta))
  add(section_break(FOOTER_PAGE, "decimal"))

  -- certificate of service (Rule 25(a)): the last section, lower roman from i
  write_final(FOOTER_PAGE, "lowerRoman")
  local s = need(meta, "service")
  add(styled("FrontHeading", S("Certificate of Service")))
  add(pandoc.Para(cat(S("I certify that on "), inl(s.date), S(", I filed the foregoing "),
    S(plain(need(meta, "brief_title"))), S(" with the Clerk of the Court and served it on counsel for the other party by "),
    inl(s.method), S("."))))
  local sig = need(meta, "signature")
  add(styled("Keep", cat(S("s/ "), inl(sig.signer))))
  add(styled("Single", S(plain(sig.signer):upper())))

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end

-- bap1 brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/bap1-*.typ: the cover (its own section, no page number), the corporate disclosure (when
-- given), the table of contents, the table of authorities, the oral-argument statement, the body (headings
-- numbered I., A., 1., a. from level 2; level 1 unnumbered), the signature block, the statement regarding
-- related cases, and the certificate of compliance. The word limit and the required sections are checked
-- here, as in the typst template. The same file is in each doc-type folder; only the KIND line differs.
-- Known limits (BLOCKED, see README.md "Engines"): the table of contents and the table of authorities
-- list their entries without page numbers (Word fills them when fields are updated; the page numbers are
-- not measured here, see DOCX.md on TOC/TOA).

local KIND = "answering"   -- "opening" | "answering" | "reply"  (set per doc-type folder)

local KINDS = {
  opening = { title = "BRIEF FOR APPELLANT", limit = 13000, cite = "Fed. R. Bankr. P. 8015(a)(7)(A)",
    required = { "Jurisdictional Statement", "Statement of the Issues", "Statement of the Case",
                 "Summary of the Argument", "Argument", "Conclusion" } },
  answering = { title = "BRIEF FOR APPELLEE", limit = 13000, cite = "Fed. R. Bankr. P. 8015(a)(7)(A)",
    required = { "Argument", "Conclusion" } },
  reply = { title = "REPLY BRIEF FOR APPELLANT", limit = 6500, cite = "Fed. R. Bankr. P. 8015(a)(7)(B)",
    required = { "Argument", "Conclusion" } },
}
local CFG = KINDS[KIND]
local FONT_NAME, FONT_SIZE = "EB Garamond", 14

local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

-- ---------------------------------------------------------------- helpers
local function stringify(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value (YAML strings are read as markdown) as inlines
local function inl(v)
  local out = pandoc.Inlines {}
  if v == nil then return out end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" then
    for _, x in ipairs(v) do out:insert(x) end
  elseif ty == "Blocks" then
    out = pandoc.utils.blocks_to_inlines(v)
  else
    local b = pandoc.read(stringify(v), "markdown+smart").blocks
    if #b > 0 then out = b[1].content end
  end
  return out
end

-- inline text from a Lua string (markdown: *emphasis* and the like)
local function md(s)
  local b = pandoc.read(s, "markdown+smart").blocks
  if #b == 0 then return pandoc.Inlines {} end
  return b[1].content
end

local function cat(...)
  local out = pandoc.Inlines {}
  for _, part in ipairs({ ... }) do
    for _, x in ipairs(part) do out:insert(x) end
  end
  return out
end

local function styled(style, content)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- a spacer paragraph of exactly `pts` points (the cover spacing, measured in typst line pitches)
local function gp(pts)
  return pandoc.RawBlock("openxml", string.format('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="%d" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:p>', math.floor(pts * 20 + 0.5)))
end

-- the same spacer, kept with the next paragraph (inside the signature block)
local function gpk(pts)
  return pandoc.RawBlock("openxml", string.format('<w:p><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="%d" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:p>', math.floor(pts * 20 + 0.5)))
end

local function gap(n)
  local out = {}
  for _ = 1, (n or 1) do out[#out + 1] = styled("Gap", pandoc.Inlines {}) end
  return out
end

local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- the section break that ends the cover: its own section, no footer, numbering off
SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'

local function cover_section_end()
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. SECT_COVER .. '</w:pPr></w:p>')
end

local function xml_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function box(checked)
  local ch = checked and "\u{2612}" or "\u{2610}"   -- ballot box with / without X
  return pandoc.RawInline("openxml", '<w:r><w:rPr><w:rFonts w:ascii="DejaVu Sans" w:hAnsi="DejaVu Sans" w:eastAsia="DejaVu Sans" w:cs="DejaVu Sans"/></w:rPr><w:t xml:space="preserve">' .. ch .. '</w:t></w:r>')
end

local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    for w in stringify(b):gmatch("%S+") do
      if w:find("[%w]") then n = n + 1 end
    end
  end
  return n
end

local function need(meta, key)
  if meta[key] == nil then error("bap1: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- ---------------------------------------------------------------- front matter
local function cover(meta)
  local out = {}
  local function add(x) for _, b in ipairs(type(x) == "table" and x or { x }) do out[#out + 1] = b end end
  add(styled("Centered", md("BAP No. " .. stringify(need(meta, "case_number")))))
  add({ gp(66.3) })
  add(styled("Centered", pandoc.Inlines { pandoc.Str("UNITED STATES BANKRUPTCY APPELLATE PANEL") }))
  add(styled("Centered", pandoc.Inlines { pandoc.Str("FOR THE FIRST CIRCUIT") }))
  add({ gp(45.1) })
  for i, side in ipairs(need(meta, "caption")) do
    for _, name in ipairs(side.names) do add(styled("Centered", inl(name))) end
    add(styled("Centered", inl(side.designation)))
    if i == 1 then
      add(gp(5.6))
      add(styled("Centered", pandoc.Inlines { pandoc.Str("v.") }))
      add(gp(5.6))
    end
  end
  add({ gp(45.1) })
  add(styled("Centered", inl(need(meta, "proceeding"))))
  if meta.bankruptcy_case then
    add(styled("Centered", md("Bankruptcy Case No. " .. stringify(meta.bankruptcy_case))))
  end
  add({ gp(59.7) })
  add(styled("Centered", pandoc.Inlines { pandoc.Strong { pandoc.Str(CFG.title) } }))
  add({ gp(59.7) })
  for _, group in ipairs(need(meta, "counsel")) do
    for _, name in ipairs(group.names) do
      add(styled("CoverLeft", pandoc.Inlines { pandoc.Strong { pandoc.Str(string.upper(stringify(name))) } }))
    end
    for _, line in ipairs(group.lines) do add(styled("CoverLeft", pandoc.Inlines { pandoc.Emph(inl(line)) })) end
    add(gp(4.5))
  end
  -- the last cover line carries the section break (no extra paragraph that could spill onto page 2)
  if meta.phone then
    add(pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="CoverLeft"/>' .. SECT_COVER .. '</w:pPr><w:r><w:t xml:space="preserve">Telephone: ' .. xml_escape(stringify(meta.phone)) .. '</w:t></w:r></w:p>'))
  else
    add(cover_section_end())
  end
  return out
end

-- table of contents: the body's headings (levels 1 to 4), numbered as in the body. Entries without page
-- numbers; the TOC field lets Word fill them in when fields are updated.
local function toc_block(entries)
  local xml = {}
  local function para(style, text, first, last)
    local runs = ""
    if first then
      runs = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    runs = runs .. '<w:r><w:t xml:space="preserve">' .. xml_escape(text) .. '</w:t></w:r>'
    if last then runs = runs .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. runs .. '</w:p>'
  end
  if #entries == 0 then return {} end
  for i, e in ipairs(entries) do
    xml[#xml + 1] = para("TOC" .. e.level, e.text, i == 1, i == #entries)
  end
  return { pandoc.RawBlock("openxml", table.concat(xml)) }
end

local function toa_blocks(meta)
  local out = {}
  local auths = meta.authorities or {}
  for _, g in ipairs(TOA_GROUPS) do
    local keys = {}
    for k, a in pairs(auths) do
      if stringify(a.kind) == g[1] then keys[#keys + 1] = k end
    end
    if #keys > 0 then
      local entries = {}
      for _, k in ipairs(keys) do
        local a = auths[k]
        local sort = stringify(a.sort or a.name or a.cite)
        entries[#entries + 1] = { sort = string.lower(sort), a = a, kind = g[1] }
      end
      table.sort(entries, function(x, y) return x.sort < y.sort end)
      out[#out + 1] = styled("TOAHead", pandoc.Inlines { pandoc.Str(g[2]) })
      for _, e in ipairs(entries) do
        local a = e.a
        local text
        if a.name ~= nil and e.kind == "case" then
          text = cat(pandoc.Inlines { pandoc.Emph(inl(a.name)) }, md(", " .. stringify(a.cite)))
        elseif a.name ~= nil then
          text = cat(inl(a.name), md(", " .. stringify(a.cite)))
        else
          text = inl(a.cite)
        end
        out[#out + 1] = styled("TOAEntry", text)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------- the document
function Pandoc(doc)
  local meta = doc.meta

  -- links to authorities keep their text (the page numbers are not measured here, see the header)
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not (meta.authorities and meta.authorities[key]) then
        error("bap1: link toa:" .. key .. " has no entry under authorities:", 0)
      end
      return el.content
    end,
  })

  -- required sections, word count (before the numbers are added)
  local present = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then present[stringify(b.content)] = true end
  end
  for _, h in ipairs(CFG.required) do
    if not present[h] then
      error("bap1: the " .. KIND .. " brief needs a level-1 heading `" .. h .. "` (FRBP 8014)", 0)
    end
  end
  local words = count_words(doc.blocks)
  if words > CFG.limit then
    error("bap1: " .. words .. " words exceeds the " .. CFG.limit .. "-word limit (" .. CFG.cite .. ")", 0)
  end

  -- headings: numbering (levels 2 to 5), and the list of headings for the contents
  local counters = { 0, 0, 0, 0, 0 }
  local body, toc_entries = {}, {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lvl = b.level
      local label = ""
      if lvl >= 2 then
        counters[lvl] = counters[lvl] + 1
        for d = lvl + 1, 5 do counters[d] = 0 end
        local c = counters[lvl]
        if lvl == 2 then label = roman(c) .. "."
        elseif lvl == 3 then label = string.char(64 + c) .. "."
        elseif lvl == 4 then label = tostring(c) .. "."
        else label = string.char(96 + c) .. "." end
      else
        for d = 2, 5 do counters[d] = 0 end
      end
      local content = b.content
      local text = stringify(content)
      if label ~= "" then
        content = cat(pandoc.Inlines { pandoc.Str(label), pandoc.Space() }, content)
        text = label .. " " .. text
      end
      if lvl <= 4 then toc_entries[#toc_entries + 1] = { level = lvl, text = text } end
      b = pandoc.Header(lvl, content, b.attr)
    end
    body[#body + 1] = b
  end

  local front = {}
  local function add(list) for _, b in ipairs(list) do front[#front + 1] = b end end

  -- cover (section 1)
  add(cover(meta))

  -- corporate disclosure (FRBP 8012), when given
  if meta.disclosure then
    add({ styled("FrontTitle", pandoc.Inlines { pandoc.Str("Corporate Disclosure Statement") }) })
    add({ pandoc.Div({ pandoc.Para(inl(meta.disclosure)) }, pandoc.Attr("", {}, { ["custom-style"] = "FrontFirst" })) })
    add({ page_break() })
  end

  -- table of contents (FRBP 8014(a)(2))
  add({ styled("FrontTitle", pandoc.Inlines { pandoc.Str("Table of Contents") }) })
  add(toc_block(toc_entries))
  add({ page_break() })

  -- table of authorities (FRBP 8014(a)(3))
  add({ styled("FrontTitle", pandoc.Inlines { pandoc.Str("Table of Authorities") }) })
  add(toa_blocks(meta))
  add({ page_break() })

  -- statement regarding oral argument (1st Cir. BAP L.R. 8019-1(a)), after the tables
  if meta["oral-argument"] then
    add({ styled("FrontTitle", pandoc.Inlines { pandoc.Str("Statement Regarding Oral Argument") }) })
    add({ pandoc.Div({ pandoc.Para(inl(meta["oral-argument"])) }, pandoc.Attr("", {}, { ["custom-style"] = "FrontFirst" })) })
    add({ page_break() })
  end

  -- the brief (section 2: numbered from 1 by the footer of reference.docx)
  add(body)

  -- signature block, kept together (typst: block(breakable: false, ...))
  local sig = need(meta, "signature")
  add({ gp(16.8) })
  add({ styled("Signature", pandoc.Inlines { pandoc.Str("Respectfully submitted,") }) })
  if meta.date then add({ styled("Signature", inl(meta.date)) }) end
  add({ gpk(11.2) })
  add({ styled("Signature", pandoc.Inlines { pandoc.Str("s/ " .. string.upper(stringify(sig.signer))) }) })
  for i, line in ipairs(sig.lines) do
    -- the last line of the block is not kept with the next paragraph (the page break after it)
    add({ styled(i == #sig.lines and "SignatureEnd" or "Signature", pandoc.Inlines { pandoc.Emph(inl(line)) }) })
  end

  -- statement regarding related cases (1st Cir. BAP L.R. 8014-1(a)(2))
  add({ page_break() })
  add({ styled("FrontTitle", pandoc.Inlines { pandoc.Str("Statement Regarding Related Cases") }) })
  add({ pandoc.Div({ pandoc.Para(md("1st Cir. BAP L.R. 8014-1(a)(2)")) }, pandoc.Attr("", {}, { ["custom-style"] = "FrontFirst" })) })
  local rc = meta.related_cases or { status = pandoc.Inlines { pandoc.Str("none") } }
  local pending = stringify(rc.status) == "pending"
  add({ styled("Single", cat(pandoc.Inlines { box(pending), pandoc.Space() },
    md("The undersigned certifies that the following are known related cases and appeals:"))) })
  if pending and rc.cases then
    for _, c in ipairs(rc.cases) do
      add({ styled("CaseIndent", md(stringify(c.number) .. ", " .. stringify(c.name) .. " (" .. stringify(c.relationship) .. ")")) })
    end
  end
  add(gap(1))
  add({ styled("Single", cat(pandoc.Inlines { box(not pending), pandoc.Space() },
    md("The undersigned certifies that the undersigned knows of no related cases or appeals as that term is defined in 1st Cir. BAP L.R. 8014-1(a)(2)(A)."))) })

  -- certificate of compliance (FRBP 8015(h)); wording as in the typst template
  add({ page_break() })
  add({ styled("FrontTitle", pandoc.Inlines { pandoc.Str("Certificate of Compliance") }) })
  add({ pandoc.Div({ pandoc.Para(md("This brief complies with the type-volume limitation of " .. CFG.cite
    .. " because it contains " .. tostring(words) .. " words, excluding the parts of the brief exempted under Fed. R. Bankr. P. 8015(g).")) },
    pandoc.Attr("", {}, { ["custom-style"] = "FrontFirst" })) })
  add({ pandoc.Div({ pandoc.Para(md("This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, "
    .. FONT_NAME .. " " .. FONT_SIZE .. "-point, using the vendored font.")) },
    pandoc.Attr("", {}, { ["custom-style"] = "BodyIndent" })) })
  add({ gp(16.8) })
  add({ styled("Signature", pandoc.Inlines { pandoc.Str("s/ " .. string.upper(stringify(sig.signer))) }) })
  local first_line = sig.lines[1]
  if first_line then add({ styled("Signature", pandoc.Inlines { pandoc.Emph(inl(first_line)) }) }) end
  if meta.date then add({ styled("Signature", md("Dated: " .. stringify(meta.date))) }) end

  return pandoc.Pandoc(front, pandoc.Meta({}))
end

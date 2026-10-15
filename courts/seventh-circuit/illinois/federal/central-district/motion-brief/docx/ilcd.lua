-- Memorandum of law, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on docx/reference.docx,
-- laid out to match motion-brief/typst/ilcd-motion-brief.typ (see ../README.md, "Engines").
-- Every case-specific word comes from the sample's frontmatter or body; no text, coordinate or forced line break
-- is written here except the template's own rule wording (the certificate of compliance, LR 7.1(B)(4)(c)).
-- Sections: the cover (no page number), the contents and authorities (roman), the body and the certificate (arabic
-- from 1). The footer is the PAGE field of reference.docx, referenced by its relationship id "rId9" (the id pandoc
-- gives the footer in this reference; checked on the output, see the README).
-- Known limits (BLOCKED, see the README): the table of contents is a TOC field and the table of authorities
-- lists the authorities without page numbers (both need a field update or a second pass); the word count is
-- the typst template's count of the body markdown, approximately the word processor's count.

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local FOOTER_RID = "rId9"
local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, fmt)
  return "<w:r>" .. (fmt ~= "" and ("<w:rPr>" .. fmt .. "</w:rPr>") or "")
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- inline content -> OpenXML runs (bold, italic, quotes; a link keeps its text, no hyperlink part is written)
local function runs(inl, fmt)
  fmt = fmt or ""
  local out = {}
  for _, x in ipairs(inl) do
    if x.t == "Str" then out[#out + 1] = run(x.text, fmt)
    elseif x.t == "Space" or x.t == "SoftBreak" then out[#out + 1] = run(" ", fmt)
    elseif x.t == "Emph" then out[#out + 1] = runs(x.content, fmt .. "<w:i/>")
    elseif x.t == "Strong" then out[#out + 1] = runs(x.content, fmt .. "<w:b/>")
    elseif x.t == "Link" or x.t == "Span" then out[#out + 1] = runs(x.content, fmt)
    elseif x.t == "Quoted" then
      local q = x.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], fmt) .. runs(x.content, fmt) .. run(q[2], fmt)
    else out[#out + 1] = run(pandoc.utils.stringify(x), fmt) end
  end
  return table.concat(out)
end

local function para_xml(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. inner .. '</w:p>'
end

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- one blank line of the given height (480 = double, 276 = single, 240 = half a double line), in a style
local function gap(style, line)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. (style or "Single")
    .. '"/><w:spacing w:before="0" w:after="0" w:line="' .. (line or 480) .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

local PAGE_BREAK = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/>'
  .. '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')

-- a section break ending the section above: no footer (the cover), or the footer with a page-number format
local function section_break(footer, fmt)
  local refs = footer and ('<w:footerReference w:type="default" r:id="' .. FOOTER_RID .. '"/>') or ''
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ''
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/>'
    .. '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>' .. refs
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>' .. pg .. '</w:sectPr></w:pPr></w:p>')
end

-- the caption (typst grid): party names, one ")" per caption line, the case number at the right
local COLS = { 4608, 432, 4320 } -- 3.2 in party column, 0.3 in ")" column, the rest of 6.5 in

local function cell(w, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. paras .. '</w:tc>'
end

local function caption_table(meta)
  local rows = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then rows[#rows + 1] = { text = pandoc.Inlines({ pandoc.Str("v.") }), indent = true } end
    for _, n in ipairs(p.names) do rows[#rows + 1] = { text = n } end
    rows[#rows + 1] = { text = p.designation, indent = true }
  end
  local trs = {}
  for k, r in ipairs(rows) do
    local c1 = para_xml("Single", runs(r.text), r.indent and '<w:ind w:left="1800"/>' or nil)
    local c2 = para_xml("Single", '<w:r><w:t>)</w:t></w:r>', '<w:jc w:val="right"/>')
    local c3
    if k == 1 then
      c3 = cell(COLS[3], para_xml("Single", run("Case No. " .. plain(meta.case_number), ""), '<w:ind w:left="216"/>'),
        '<w:vMerge w:val="restart"/><w:vAlign w:val="center"/>')
    else
      c3 = cell(COLS[3], para_xml("Single", ''), '<w:vMerge/>')
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(COLS[1], c1)
      .. cell(COLS[2], c2) .. c3 .. '</w:tr>'
  end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>' .. none .. '</w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="432"/>'
    .. '<w:gridCol w:w="4320"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- the body's words, counted as the typst template counts them (ilcd-motion-brief.typ, word-count): link targets,
-- footnote labels and markers are not words; a token with no letter or digit is not a word
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("ilcd-motion-brief: no sample file to count words from", 0) end
  local h = assert(io.open(f, "r"))
  local text = h:read("a")
  h:close()
  local body, dashes = {}, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    else
      body[#body + 1] = line
    end
  end
  local s = table.concat(body, "\n")
  s = s:gsub("%(toa:[^%)]*%)", "")
  s = s:gsub("%(https://[^%)]*%)", "")
  s = s:gsub("%(http://[^%)]*%)", "")
  s = s:gsub("%[%^[^%]]*%]:?", "")
  local n = 0
  for w in s:gmatch("%S+") do
    if w:find("%w") then n = n + 1 end
  end
  return n
end

local function drop_front(inl, k)
  local r = pandoc.List({})
  for i = k, #inl do r[#r + 1] = inl[i] end
  return r
end

function Pandoc(doc)
  local meta = doc.meta
  if not meta.division then error("ilcd-motion-brief: LR 40.1(E)(1) requires the division in the caption (frontmatter: division)", 0) end
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    auth[key] = { kind = plain(a.kind), name = plain(a.name), cite = plain(a.cite) }
  end

  -- citations: a link [text](toa:key) prints its text; the keys cited are collected for the table of authorities
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("ilcd-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      return el.content
    end,
  })

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover (no page number): court title, caption, title, counsel block at the right half
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("UNITED STATES DISTRICT COURT") }) }))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("CENTRAL DISTRICT OF ILLINOIS") }) }))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(plain(meta.division):upper()) }) }))
  add(gap("Single"))
  add(pandoc.RawBlock("openxml", caption_table(meta)))
  add(gap("Single"))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(plain(meta.brief_title):upper()) }) }))
  add(gap("Single"))
  add(gap("Single"))
  for gi, g in ipairs(meta.counsel or {}) do
    if gi > 1 then add(gap("Single")) end
    for _, n in ipairs(g.names or {}) do add(styled("Counsel", n)) end
    for _, l in ipairs(g.lines or {}) do add(styled("Counsel", l)) end
  end
  add(section_break(false, nil))

  -- contents (page i): a TOC field over the heading styles; its page numbers appear after a field update
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("TABLE OF CONTENTS") }) }))
  add(gap("Single"))
  add(pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr>'
    .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. '<w:r><w:t>Table of contents: update fields to show page numbers.</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'))
  add(PAGE_BREAK)

  -- authorities (page ii): the authorities the body cites, by group; no page numbers (see the README)
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("TABLE OF AUTHORITIES") }) }))
  add(gap("Single"))
  for _, g in ipairs(TOA_GROUPS) do
    local keys = {}
    for k, a in pairs(auth) do
      if a.kind == g[1] and used[k] then keys[#keys + 1] = k end
    end
    if #keys > 0 then
      table.sort(keys, function(x, y) return auth[x].name:lower() < auth[y].name:lower() end)
      add(styled("AuthorityHead", { pandoc.Str(g[2]) }))
      for _, k in ipairs(keys) do
        local a = auth[k]
        local line = pandoc.List({})
        if a.kind == "case" then line:insert(pandoc.Emph({ pandoc.Str(a.name) })) else line:insert(pandoc.Str(a.name)) end
        if a.cite ~= "" then line:insert(pandoc.Str(", " .. a.cite)) end
        add(styled("Authority", line))
      end
    end
  end
  add(section_break(true, "lowerRoman"))

  -- body (arabic from 1): the conclusion is kept with the signature block
  local conclusion = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):upper() == "CONCLUSION" then conclusion = true end
    if b.t == "Para" and conclusion then
      add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" })))
    else
      add(b)
    end
  end

  -- signature block (typst signature-block): "Dated" at the left and the firm at the right, then "/s/ name"
  -- and the signer's details (LR 5.11(A)(2), LR 11.1)
  local sig = meta.signature or {}
  add(gap("Signature"))
  local dated = pandoc.List({ pandoc.Str("Dated: " .. plain(meta.date)), TAB, pandoc.Str("Respectfully submitted,") })
  add(pandoc.Div({ pandoc.Para(dated) }, pandoc.Attr("", {}, { ["custom-style"] = "Dated" })))
  for _, l in ipairs(sig.firm or {}) do add(styled("Counsel", l)) end
  add(gap("Counsel", 240))
  add(styled("Counsel", pandoc.Inlines({ pandoc.Str("/s/ " .. plain(sig.signer)) })))
  for _, l in ipairs(sig.lines or {}) do add(styled("Counsel", l)) end

  -- certificate of compliance (LR 7.1(B)(4)(c)), when the frontmatter says the type-volume limit is relied on
  if meta.type_volume then
    local words = source_words()
    add(PAGE_BREAK)
    add(pandoc.Header(1, { pandoc.Str("Certificate of Compliance") }))
    add(pandoc.Para({ pandoc.Str("I certify pursuant to Civil Local Rule 7.1(B)(4)(c) that this memorandum complies with the type-volume limitation. This memorandum contains " .. tostring(words) .. " words, including headings, footnotes, and quotations, and excluding the cover page, tables, and signature block.") }))
    add(gap("Counsel"))
    add(styled("Counsel", pandoc.Inlines({ pandoc.Str("/s/ " .. plain(sig.signer)) })))
    if sig.lines and sig.lines[1] then add(styled("Counsel", sig.lines[1])) end
  end

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end

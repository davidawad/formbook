-- txnb (N.D. Tex. bankruptcy) DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- docx/reference.docx. Mirrors typst/txnb-<doc>.typ: the cover (counsel, court title, Form 416 caption as a
-- borderless table with the party column ruled on the right and bottom, title), the body, the signature block,
-- and (motion) the certificates. Page numbers come from the reference's footer. Paragraph numbers are typed
-- text ("1.", a tab), as the typst template does; lists are lettered (a), (b) or numbered as written.

-- The only part that differs between the two doc types (the typst templates differ in the same way).
local CFG = {
  numbered = true,            -- complaint: body paragraphs are numbered (Fed. R. Civ. P. 10(b)); motion: not
  enum = "letter",            -- complaint lists are (a), (b), ...; motion lists are 1., 2., ...
  certificates = false,       -- motion: certificate_conference / certificate_service
  toc = false,                -- motion: table of contents when the frontmatter says toc: true (a TOC field)
}

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, rpr)
  return '<w:r>' .. (rpr and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function raw_p(style, runs, ppr)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. runs .. '</w:p>')
end

-- a vertical gap of exactly pts points (an empty paragraph with an exact line height)
local function gap(pts, keep)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/>' .. (keep and '<w:keepNext/>' or '') .. '<w:spacing w:before="0" w:after="0" w:line="' .. math.floor(pts * 20 + 0.5) .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

-- Pandoc's Lua meta values are inline lists (markdown strings) or block lists (multi-paragraph values).
local BLOCK_TYPES = { Para = true, Plain = true, BlockQuote = true, BulletList = true, OrderedList = true, Div = true }

local function is_blocks(v)
  return v[1] ~= nil and BLOCK_TYPES[v[1].t] == true
end

-- a metadata value (markdown inlines or blocks) as a list of blocks
local function meta_blocks(v)
  if v == nil then return {} end
  if type(v) == "string" or v.t == "MetaString" or v.t == "MetaInlines" then return { pandoc.Plain(v) } end
  if is_blocks(v) then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b end
    return out
  end
  return { pandoc.Plain(v) }
end

-- a metadata value as a plain inline list (for a single line of markdown)
local function plain_inl(v)
  if type(v) == "string" or v.t == "MetaString" then return { pandoc.Str(tostring(v)) } end
  if is_blocks(v) then return pandoc.utils.blocks_to_inlines(v) end
  return v
end
local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end



local function single_div(inlines, style)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style or "Single" }))
end

-- a tag such as "[unnumbered]" at the start of a paragraph: removed, and reported
local function strip_tag(inls, tag)
  if inls[1] and inls[1].t == "Str" and inls[1].text == tag then
    table.remove(inls, 1)
    if inls[1] and inls[1].t == "Space" then table.remove(inls, 1) end
    return true
  end
  return false
end

-- ---------------------------------------------------------------------------
-- cover: counsel (top left), court title, Form 416 caption, title of the paper
-- ---------------------------------------------------------------------------

local CAP_LEFT = 4680   -- 3.25 in
local CAP_GUTTER = 360  -- 0.25 in
local CAP_RIGHT = 4320  -- 3.00 in

local function caption_rows(meta)
  local rows = {}
  local cap = meta.caption
  if cap.debtor then
    rows[#rows + 1] = "In re: " .. plain(cap.debtor)
    rows[#rows + 1] = ""
    rows[#rows + 1] = "Debtor."
    rows[#rows + 1] = ""
  end
  for k, p in ipairs(cap.parties) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, n in ipairs(p.names) do rows[#rows + 1] = plain(n) end
    rows[#rows + 1] = plain(p.designation) .. "."
  end
  return rows
end

local function caption_table(meta)
  local function para_xml(text)
    if text == "" then
      return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="120" w:lineRule="exact"/></w:pPr></w:p>'
    end
    return '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr>' .. run(text) .. '</w:p>'
  end
  local left = {}
  for _, r in ipairs(caption_rows(meta)) do left[#left + 1] = para_xml(r) end
  local right = {
    "Chapter " .. plain(meta.chapter), "", "Case No. " .. plain(meta.case_number), "",
    "Adversary Proceeding No. " .. plain(meta.adversary_number),
  }
  local rxml = {}
  for _, r in ipairs(right) do rxml[#rxml + 1] = para_xml(r) end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  local lb = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local lm = '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  local rm = '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblW w:w="' .. (CAP_LEFT + CAP_GUTTER + CAP_RIGHT) .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders>' .. none .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. CAP_RIGHT .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. lb .. lm .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_RIGHT .. '" w:type="dxa"/>' .. rm .. '</w:tcPr>' .. table.concat(rxml) .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

local function cover(meta)
  local out = {}
  for _, line in ipairs(meta.counsel) do
    out[#out + 1] = single_div(plain_inl(line))
  end
  out[#out + 1] = gap(34.2)
  out[#out + 1] = raw_p("CenteredBold", run("UNITED STATES BANKRUPTCY COURT"))
  out[#out + 1] = raw_p("CenteredBold", run("NORTHERN DISTRICT OF TEXAS"))
  if meta.division then
    out[#out + 1] = raw_p("CenteredBold", run(plain(meta.division):upper()))
  end
  out[#out + 1] = gap(24)
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = gap(34.2)
  out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong(meta.title) }) },
    pandoc.Attr("", {}, { ["custom-style"] = "Centered Bold" }))
  out[#out + 1] = gap(24)
  return out
end

-- ---------------------------------------------------------------------------
-- body, lists, numbering, signature, certificates
-- ---------------------------------------------------------------------------

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

local function list_marker(kind, i)
  if kind == "bullet" then return "\u{2022}" end
  if CFG.enum == "letter" then return "(" .. LETTERS:sub(i, i) .. ")" end
  return tostring(i) .. "."
end

local function tab_inline()
  return pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
end

local function list_blocks(lst, kind)
  local out = {}
  local start = 1
  if kind == "ordered" and lst.listAttributes then start = lst.listAttributes.start or 1 end
  for i, item in ipairs(lst.content) do
    local marker = list_marker(kind, start + i - 1)
    for j, b in ipairs(item) do
      if j == 1 and (b.t == "Para" or b.t == "Plain") then
        local inl = { pandoc.Str(marker), tab_inline() }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "List Item" }))
      elseif b.t == "Para" or b.t == "Plain" then
        out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, pandoc.Attr("", {}, { ["custom-style"] = "List Continue" }))
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

local counter = 0

local function body_para(b)
  local inls = b.content
  local t = pandoc.utils.stringify(b)
  if t:match("^%[unnumbered%]") then
    strip_tag(inls, "[unnumbered]")
    return pandoc.Div({ pandoc.Para(inls) }, pandoc.Attr("", {}, { ["custom-style"] = "Body Text" }))
  end
  if t:match("^%[noindent%]") then
    strip_tag(inls, "[noindent]")
    return pandoc.Div({ pandoc.Para(inls) }, pandoc.Attr("", {}, { ["custom-style"] = "No Indent" }))
  end
  if CFG.numbered then
    counter = counter + 1
    local withnum = { pandoc.Str(tostring(counter) .. "."), tab_inline() }
    for _, x in ipairs(inls) do withnum[#withnum + 1] = x end
    return pandoc.Div({ pandoc.Para(withnum) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Paragraph" }))
  end
  return b
end

local function body(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      out[#out + 1] = body_para(b)
    elseif b.t == "BulletList" then
      for _, x in ipairs(list_blocks(b, "bullet")) do out[#out + 1] = x end
    elseif b.t == "OrderedList" then
      for _, x in ipairs(list_blocks(b, "ordered")) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- signature block: kept together (the typst block is unbreakable)
local function signature(meta)
  local out = {}
  local function kp(style, text, ppr)
    return raw_p(style, run(text), '<w:keepNext/>' .. (ppr or ''))
  end
  out[#out + 1] = kp("NoIndent", "Dated: " .. plain(meta.date))
  out[#out + 1] = gap(12, true)
  out[#out + 1] = kp("Signature", "Respectfully submitted,")
  out[#out + 1] = gap(6, true)
  for _, line in ipairs(meta.signature.firm) do
    out[#out + 1] = pandoc.Div({ pandoc.Para(plain_inl(line)) }, pandoc.Attr("", {}, { ["custom-style"] = "Signature" }))
  end
  out[#out + 1] = gap(6, true)
  local first = "By: /s/ " .. plain(meta.signature.signer)
  out[#out + 1] = kp("Signature", first)
  for k, line in ipairs(meta.signature.lines) do
    local inls = plain_inl(line)
    out[#out + 1] = pandoc.Div({ pandoc.Para(inls) }, pandoc.Attr("", {}, { ["custom-style"] = "Signature" }))
  end
  return out
end

local function certificate(title, value, signer)
  local out = {}
  out[#out + 1] = gap(34.2)
  out[#out + 1] = raw_p("Centered", run(title:upper(), "<w:b/><w:bCs/>"), '<w:keepNext/>')
  out[#out + 1] = gap(12, true)
  local blocks = meta_blocks(value)
  for k, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      strip_tag(b.content, "[noindent]")
      local style = "Certificate Body"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = gap(12, true)
  out[#out + 1] = raw_p("Single", run("/s/ " .. plain(signer)), '<w:jc w:val="right"/>')
  return out
end

local function toc(meta)
  local out = {}
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
  out[#out + 1] = raw_p("Centered", run("TABLE OF CONTENTS", "<w:b/><w:bCs/>"))
  out[#out + 1] = gap(12, true)
  -- a TOC field: Word and LibreOffice fill the page numbers only when the fields are updated (see README, BLOCKED)
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. run("Table of contents: update fields to show the entries and page numbers.")
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end
  if CFG.toc and meta.toc == true then
    for _, b in ipairs(toc(meta)) do blocks[#blocks + 1] = b end
  end
  for _, b in ipairs(body(doc.blocks)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  if CFG.certificates then
    if meta.certificate_conference then
      for _, b in ipairs(certificate("Certificate of Conference", meta.certificate_conference, meta.signature.signer)) do blocks[#blocks + 1] = b end
    end
    if meta.certificate_service then
      for _, b in ipairs(certificate("Certificate of Service", meta.certificate_service, meta.signature.signer)) do blocks[#blocks + 1] = b end
    end
  end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

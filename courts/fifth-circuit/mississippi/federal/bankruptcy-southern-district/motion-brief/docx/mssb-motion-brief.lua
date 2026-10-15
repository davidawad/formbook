-- Motion with memorandum (memorandum brief in support) for the U.S. Bankruptcy Court, S.D. Mississippi (mssb):
-- pandoc filter for the docx engine. The same content and rules as typst/mssb-motion-brief.typ, from the same
-- markdown contract: the cover and caption (FRBP 9004(b)), the title and docket reference (Miss. Bankr. L.R. 9004-1(b)),
-- unnumbered body paragraphs (a memorandum brief), headings I./A./1., block quotations, address blocks, the
-- signature block before the certificate of service, which starts a new page. Every case word comes from the
-- frontmatter. Styles (MSSB ...) come from reference.docx (make-reference.sh). See ../README.md, "Engines".

local TEXT_W = 9360 -- 6.5 in in twips (8.5 in less two 1 in margins)
local CAP_LEFT = 5184 -- 3.6 in: the party column of the caption (typst caption-left)
local CAP_GAP = 360 -- 0.25 in gutter
local CAP_RIGHT = TEXT_W - CAP_LEFT - CAP_GAP

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function txt(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

local function need(v, msg)
  if v == nil or txt(v) == "" then error("mssb-motion-brief: " .. msg) end
  return v
end

-- A block of one paragraph in a named MSSB style (defined in reference.docx).
local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines or {}) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function blank(style)
  return styled(style, {})
end

-- The inlines of a markdown string from the frontmatter (the signature and docket lines may carry markup).
local function md_inlines(s)
  local d = pandoc.read(s, "markdown")
  local b = d.blocks[1]
  if b == nil or b.content == nil then return pandoc.Inlines({ pandoc.Str(s) }) end
  return b.content
end

local function has_line_break(blk)
  local found = false
  pandoc.walk_block(blk, {
    LineBreak = function()
      found = true
    end,
  })
  return found
end

-- Caption: one borderless three-column table (party names | gutter | case facts and designations), as in typst.
local function xml_para(text, style, jc)
  local ppr = '<w:pStyle w:val="' .. style .. '" />'
  if jc then ppr = ppr .. '<w:jc w:val="' .. jc .. '" />' end
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr><w:r><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r></w:p>'
end

local function xml_cell(width, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa" /></w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function caption_row(left, right, right_jc)
  local lp, rp = {}, {}
  for _, s in ipairs(left) do
    lp[#lp + 1] = xml_para(s, "MSSBSingle")
  end
  for _, s in ipairs(right) do
    rp[#rp + 1] = xml_para(s, "MSSBSingle", right_jc)
  end
  return '<w:tr>' .. xml_cell(CAP_LEFT, lp) .. xml_cell(CAP_GAP, { '<w:p />' }) .. xml_cell(CAP_RIGHT, rp) .. '</w:tr>'
end

-- A spacer row exactly 12 pt high: half a double-spaced row, as typst's v(pitch * 0.5).
local SPACER = '<w:tr><w:trPr><w:trHeight w:val="240" w:hRule="exact" /></w:trPr>'
  .. '<w:tc><w:tcPr><w:tcW w:w="' .. TEXT_W .. '" w:type="dxa" /><w:gridSpan w:val="3" /></w:tcPr>'
  .. '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:p></w:tc></w:tr>'

local function names_of(list)
  local out = {}
  for _, n in ipairs(list) do
    out[#out + 1] = txt(n)
  end
  return out
end

local function caption_table(meta)
  local c = need(meta.caption, "frontmatter needs caption (debtor, case_number, chapter, parties, adversary_number)")
  local rows = {}
  rows[#rows + 1] = caption_row(names_of(c.debtor.names), { "CASE NO. " .. txt(c.case_number), txt(c.chapter) }, nil)
  rows[#rows + 1] = SPACER
  for k, p in ipairs(c.parties) do
    if k > 1 then
      rows[#rows + 1] = caption_row({ "V." }, { "ADV. PROC. NO. " .. txt(c.adversary_number) }, nil)
      rows[#rows + 1] = SPACER
    end
    rows[#rows + 1] = caption_row(names_of(p.names), { txt(p.designation) }, "right")
    if k < #c.parties then rows[#rows + 1] = SPACER end
  end
  local borders = '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" />'
    .. '<w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa" />' .. borders .. '<w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '" /><w:gridCol w:w="' .. CAP_GAP .. '" /><w:gridCol w:w="' .. CAP_RIGHT .. '" /></w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
  return pandoc.RawBlock("openxml", xml)
end

-- Cover: court name, division, caption, title and docket reference (typst cover()).
local function cover(meta)
  local out = {
    styled("MSSB Cover", { pandoc.Str("IN THE UNITED STATES BANKRUPTCY COURT") }),
    styled("MSSB Cover", { pandoc.Str("FOR THE SOUTHERN DISTRICT OF MISSISSIPPI") }),
  }
  local division = txt(meta.division)
  if division ~= "" then
    out[#out + 1] = styled("MSSB Cover", { pandoc.Str(division:upper()) })
  end
  out[#out + 1] = blank("MSSB Body")
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = blank("MSSB Single")
  local title = need(meta.title, "frontmatter needs title: every content of the paper goes in the caption (5005-1(a)(2)(I); FRBP 9004(b)(4))")
  out[#out + 1] = styled("MSSB Cover", { pandoc.Str(txt(title):upper()) })
  local docket = need(meta.related_docket, "frontmatter needs related_docket (Miss. Bankr. L.R. 9004-1(b))")
  out[#out + 1] = styled("MSSB Cover", { pandoc.Str("(Dkt. # " .. txt(docket) .. ")") })
  out[#out + 1] = blank("MSSB Body")
  return out
end

-- Signature block: date at the left; party, "/s/", signer and counsel in the right half (typst signature-block).
local function signature(meta)
  local s = need(meta.signature, "frontmatter needs signature")
  local out = {
    blank("MSSB Body"),
    styled("MSSB Single", md_inlines(txt(s.date))),
    blank("MSSB Body"),
  }
  if s.party ~= nil and txt(s.party) ~= "" then
    out[#out + 1] = styled("MSSB Signature", { pandoc.Str(txt(s.party)) })
  end
  out[#out + 1] = styled("MSSB Signature", { pandoc.Str("/s/ " .. txt(s.signer)) })
  for _, line in ipairs(s.counsel) do
    out[#out + 1] = styled("MSSB Signature", md_inlines(txt(line)))
  end
  return out
end

local function tab_run()
  return pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>")
end

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

-- The label the filed text prints for item i of an ordered list ("1.", "b.", "V.", "(1)"), so that a list
-- in a quotation keeps the numbering of the source instead of Word's automatic list formatting.
local function list_label(attrs, i)
  local n = (attrs.start or 1) + i - 1
  local style = tostring(attrs.style)
  local delim = tostring(attrs.delimiter)
  local s
  if style:find("Alpha") then
    s = style:find("Lower") and string.char(96 + n) or string.char(64 + n)
  elseif style:find("Roman") then
    s = style:find("Lower") and roman(n):lower() or roman(n)
  else
    s = tostring(n)
  end
  if delim:find("OneParen") then return s .. ")" end
  if delim:find("TwoParens") then return "(" .. s .. ")" end
  return s .. "."
end

-- Each list item as paragraphs in `style`, the first one carrying the item's label.
local function list_paragraphs(list, style)
  local out = {}
  local ordered = list.t == "OrderedList"
  for i, item in ipairs(list.content) do
    local label = ordered and list_label(list.listAttributes, i) or "\u{2022}"
    for j, blk in ipairs(item) do
      if blk.t == "Para" or blk.t == "Plain" then
        local inl = pandoc.Inlines({})
        if j == 1 then
          inl:insert(pandoc.Str(label))
          inl:insert(tab_run())
        end
        for _, x in ipairs(blk.content) do
          inl:insert(x)
        end
        out[#out + 1] = styled(style, inl)
      else
        out[#out + 1] = blk
      end
    end
  end
  return out
end

local HEADING_STYLE = { [1] = "MSSB Heading Caps", [2] = "MSSB Heading Left", [3] = "MSSB Heading Italic" }

function Pandoc(doc)
  local meta = doc.meta
  local out = cover(meta)
  local signed = false

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local t = txt(b)
      if t:sub(1, 11) == "CERTIFICATE" then
        -- The signature block closes the text; the certificate of service starts a new page after it.
        for _, x in ipairs(signature(meta)) do
          out[#out + 1] = x
        end
        signed = true
        out[#out + 1] = styled("MSSB Heading Page", b.content)
      else
        out[#out + 1] = styled(HEADING_STYLE[b.level] or HEADING_STYLE[3], b.content)
      end
    elseif b.t == "Para" then
      if has_line_break(b) then
        out[#out + 1] = styled("MSSB Address", b.content)
      else
        out[#out + 1] = styled("MSSB Body", b.content)
      end
    elseif b.t == "BlockQuote" then
      for _, inner in ipairs(b.content) do
        if inner.t == "Para" or inner.t == "Plain" then
          out[#out + 1] = styled("MSSB Quote", inner.content)
        elseif inner.t == "OrderedList" or inner.t == "BulletList" then
          for _, x in ipairs(list_paragraphs(inner, "MSSB Quote")) do
            out[#out + 1] = x
          end
        else
          out[#out + 1] = inner
        end
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(list_paragraphs(b, "MSSB Sub Item")) do
        out[#out + 1] = x
      end
    else
      out[#out + 1] = b
    end
  end

  if not signed then
    for _, x in ipairs(signature(meta)) do
      out[#out + 1] = x
    end
  end
  return pandoc.Pandoc(out, meta)
end

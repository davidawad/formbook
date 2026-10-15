-- txeb adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The court title, caption, title, signature block and allegation numbers are built here, as the typst template
-- builds them (../typst/txeb-adversary-complaint.typ); the body keeps its markdown text. Every case word comes from
-- the sample's frontmatter. Styles are in reference.docx (make-reference.sh); render.sh writes the footer.
-- Unknown markdown is an error, never a silent drop: a block the template does not place stops the build.

local CAPTION_COLS = { 4896, 576, 3888 }   -- twips: 3.4 in, 0.4 in, the rest of the 6.5 in text width

local function xml_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- an empty paragraph exactly `twips` high: the vertical space typst's v() adds
local function spacer(twips)
  return raw(string.format('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="%d" w:lineRule="exact"/></w:pPr></w:p>', twips))
end

local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

-- one paragraph in a custom style (reference.docx)
local function styled(style, content)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- plain text as inlines (words and spaces), for metadata values and fixed template text
local function plain_inlines(s)
  local out = {}
  for word in s:gmatch("%S+") do
    if #out > 0 then out[#out + 1] = pandoc.Space() end
    out[#out + 1] = pandoc.Str(word)
  end
  return out
end

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value that is a list of strings, or one string, as a Lua list of strings
local function list_of(v)
  local out = {}
  if v == nil then return out end
  if v.t == nil or v.t == "MetaList" then
    for _, x in ipairs(v) do out[#out + 1] = text_of(x) end
  else
    out[1] = text_of(v)
  end
  return out
end

-- Caption rows, as the typst template lays them out: { left, right } per single-spaced line.
local function caption_rows(meta)
  local rows = {}
  local function row(left, right) rows[#rows + 1] = { left, right } end
  row("IN RE:", "Chapter " .. text_of(meta.chapter))
  row("", "")
  for i, name in ipairs(list_of(meta.debtor.names)) do
    row(name .. ",", i == 1 and ("Case No. " .. text_of(meta.case_number)) or "")
  end
  -- LBR 7010-1(2): the debtor's address and the last four digits of the TIN are part of the caption.
  -- A missing value stays a blank for the filer to complete; the template never guesses one.
  local addr = list_of(meta.debtor.address)
  local first = addr[1]
  if first == nil or first == "" then first = "________________" end
  row("Address: " .. first, "")
  for i = 2, #addr do row("     " .. addr[i], "") end
  local tin = text_of(meta.debtor.tin_last4)
  if tin == "" then tin = "____" end
  row("Last four digits of TIN: " .. tin, "")
  row(text_of(meta.debtor.designation), "")
  row("", "")
  for pi, p in ipairs(meta.parties) do
    if pi > 1 then
      -- LBR 7010-1(4): a space for the adversary number, placed beside the "v." line.
      row("v.", "Adv. Proc. No. " .. text_of(meta.adversary_number))
      row("", "")
    end
    for _, n in ipairs(list_of(p.names)) do row(n, "") end
    row(text_of(p.designation), "")
  end
  return rows
end

local function caption_cell(width, text, center)
  local jc = center and '<w:jc w:val="center"/>' or ""
  local run = text == "" and "" or ('<w:r><w:t xml:space="preserve">' .. xml_escape(text) .. "</w:t></w:r>")
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="CaptionRow"/>'
    .. jc .. "</w:pPr>" .. run .. "</w:p></w:tc>"
end

-- The caption: a borderless table, one fixed-height row per caption line, the section sign in the middle column.
local function caption_table(meta)
  local rows = {}
  for _, r in ipairs(caption_rows(meta)) do
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="290" w:hRule="exact"/></w:trPr>'
      .. caption_cell(CAPTION_COLS[1], r[1], false) .. caption_cell(CAPTION_COLS[2], "§", true)
      .. caption_cell(CAPTION_COLS[3], r[2], false) .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAPTION_COLS[1] .. '"/><w:gridCol w:w="' .. CAPTION_COLS[2]
    .. '"/><w:gridCol w:w="' .. CAPTION_COLS[3] .. '"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>"
end

-- The court title (FRBP 9004(b)(1); LBR 7010-1(1)): three centered bold lines.
local function court_title(meta)
  local out = {}
  for _, l in ipairs({
    "IN THE UNITED STATES BANKRUPTCY COURT",
    "FOR THE EASTERN DISTRICT OF TEXAS",
    string.upper(text_of(meta.division)) .. " DIVISION",
  }) do
    out[#out + 1] = styled("Court Title", plain_inlines(l))
  end
  return out
end

-- The signature block: "Dated" at the left, the signer's lines from the third inch (typst: grid column of 3 in).
local function signature(meta)
  local out = {}
  for i, l in ipairs(list_of(meta.signature.lines)) do
    if i == 1 then
      local content = plain_inlines("Dated: " .. text_of(meta.signature.dated))
      content[#content + 1] = tab()
      for _, x in ipairs(plain_inlines(l)) do content[#content + 1] = x end
      out[#out + 1] = styled("Signature First", content)
    else
      out[#out + 1] = styled("Signature", plain_inlines(l))
    end
  end
  return out
end

local function numbered(n, content)
  local inl = { pandoc.Str(tostring(n) .. "."), tab() }
  for _, x in ipairs(content) do inl[#inl + 1] = x end
  return styled("Numbered", inl)
end

-- The line-start marker of a paragraph ("~" lead-in, "~|" flush-left line, "~>" right-half line), or nil.
local function marker_of(content)
  local first = content[1]
  if first and first.t == "Str" and (first.text == "~" or first.text == "~|" or first.text == "~>") then
    return first.text
  end
  return nil
end

-- the inlines without the marker and the space after it
local function drop_marker(content)
  local out = {}
  for i, x in ipairs(content) do out[i] = x end
  table.remove(out, 1)
  if out[1] and out[1].t == "Space" then table.remove(out, 1) end
  return out
end

local function is_signature(b)
  return text_of(b) == "<<signature>>"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, b in ipairs(court_title(meta)) do out[#out + 1] = b end
  out[#out + 1] = spacer(480)
  out[#out + 1] = raw(caption_table(meta))
  out[#out + 1] = spacer(480)
  out[#out + 1] = styled("Doc Title", plain_inlines(string.upper(text_of(meta.title))))
  out[#out + 1] = spacer(240)

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        out[#out + 1] = styled("Section Heading", b.content)
      elseif b.level == 2 then
        out[#out + 1] = styled("Count Heading", b.content)
      else
        error("txeb-adversary-complaint.lua: heading level " .. b.level .. " is not in the template")
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if is_signature(b) then
        for _, s in ipairs(signature(meta)) do out[#out + 1] = s end
      else
        local marker = marker_of(b.content)
        if marker == "~" then
          out[#out + 1] = styled("Unnumbered", drop_marker(b.content))
        elseif marker == nil then
          n = n + 1
          out[#out + 1] = numbered(n, b.content)
        else
          error("txeb-adversary-complaint.lua: the marker " .. marker .. " is not in this template")
        end
      end
    elseif b.t == "BlockQuote" then
      for _, inner in ipairs(b.content) do
        if inner.t ~= "Para" and inner.t ~= "Plain" then
          error("txeb-adversary-complaint.lua: a block quotation holds " .. inner.t)
        end
        out[#out + 1] = styled("Block Quote", inner.content)
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        local first = item[1]
        if #item ~= 1 or (first.t ~= "Para" and first.t ~= "Plain") then
          error("txeb-adversary-complaint.lua: a relief item is not one paragraph")
        end
        out[#out + 1] = styled("Relief Item", first.content)
      end
    else
      error("txeb-adversary-complaint.lua: block " .. b.t .. " is not in the template")
    end
  end
  -- the title is printed by the body (DocTitle); pandoc must not print it again as its own Title block
  meta.title = nil
  return pandoc.Pandoc(out, meta)
end

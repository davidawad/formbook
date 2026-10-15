-- Adversary complaint, C.D. Cal. bankruptcy court (cacb), DOCX engine (docs/DOCX.md). Markdown contract -> Word
-- document on docx/reference.docx, laid out as typst/cacb-adversary-complaint.typ: counsel block on lines 1-7
-- (a table at least 7 numbered lines high), the court title, a double caption (a table: the debtor and the
-- parties ruled on the left, the case numbers and the title on the right), then the body on the next page.
-- Allegations are numbered 1, 2, ... here (FRBP 7010); WHEREFORE and headings are unnumbered; list items are
-- numbered from the markdown start number, as the typst enum does. The signature block is a borderless table.
-- Page numbers come from the reference footer; the footer title and case number are its SUBJECT and COMMENTS fields, set below.
-- Everything case-specific comes from the sample's frontmatter, never from this file.

local TEXTW = 9000          -- text width in twips (6.25 in)
local CAPL, CAPG, CAPR = 4752, 288, 3960   -- caption: party column 3.3 in, gutter 0.2 in, rest
local SIGL, SIGG, SIGR = 3744, 288, 4968   -- signature: left 2.6 in, gutter 0.2 in, rest
local TAB = '<w:r><w:tab/></w:r>'

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value as a list of plain strings (a YAML list or one string)
local function strings(v)
  local out = {}
  if v == nil then return out end
  if v.t == nil or v.t == "MetaList" then
    for _, x in ipairs(v) do out[#out + 1] = plain(x) end
  else
    out[#out + 1] = plain(v)
  end
  return out
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- one paragraph: style, direct pPr (schema order: keepNext, pageBreakBefore, spacing, ind, jc), text, bold
local function para(style, text, ppr, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local body = ""
  if text ~= nil and text ~= "" then
    body = '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. body .. '</w:p>'
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(grid, rows)
  local cols, total = {}, 0
  for _, w in ipairs(grid) do
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- a cell: width, inner paragraphs (never empty), optional borders (bottom and right, in schema order)
local function cell(w, inner, rule)
  if inner == "" then inner = para("Single", "") end
  local b = ""
  if rule then
    b = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
      .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. b .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function row(cells, height)
  local h = height and ('<w:trHeight w:val="' .. height .. '" w:hRule="atLeast"/>') or ""
  return '<w:tr><w:trPr><w:cantSplit/>' .. h .. '</w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

-- counsel block (Central Guide 9004-1(c)(1)(A)): single-spaced from line 1, at least seven numbered lines (168 pt)
local function counsel(lines)
  local ps = {}
  for _, l in ipairs(lines) do ps[#ps + 1] = para("Single", l) end
  return raw(table_xml({ TEXTW }, { row({ cell(TEXTW, table.concat(ps)) }, 3360) }))
end

-- double caption (Central Guide 9004-1(c)(2)): debtor, then the parties, on the left (ruled right and below);
-- case, chapter and adversary numbers, the title and the hearing lines on the right
local function caption(meta)
  local left = {}
  local function add(text, ppr, bold) left[#left + 1] = para("Single", text, ppr, bold) end
  local IN = '<w:ind w:right="200"/>'
  add("In re:", IN)
  for _, n in ipairs(strings(meta.caption and meta.caption.debtor and meta.caption.debtor.names)) do add(n, IN) end
  add(plain(meta.caption and meta.caption.debtor and meta.caption.debtor.designation), IN)
  add("", IN)
  local parties = (meta.caption and meta.caption.parties) or {}
  for k, p in ipairs(parties) do
    if k > 1 then
      add("", IN)
      add("v.", IN)
      add("", IN)
    end
    for _, n in ipairs(strings(p.names)) do add(n, IN) end
    add(plain(p.designation), IN)
  end
  local RIGHT = '<w:ind w:left="144"/>'
  local right = {}
  local function radd(text, bold) right[#right + 1] = para("Single", text, RIGHT, bold) end
  radd("Case No. " .. plain(meta.bankruptcy_case))
  radd("Chapter " .. plain(meta.chapter))
  radd("")
  radd("Adv. No. " .. plain(meta.adversary_number))
  radd("")
  right[#right + 1] = para("Single", plain(meta.brief_title), RIGHT, true)
  if meta.legend ~= nil then
    radd("")
    radd(string.upper(plain(meta.legend)), true)
  end
  radd("")
  for _, l in ipairs(strings(meta.hearing)) do radd(l) end
  return raw(table_xml({ CAPL, CAPG, CAPR }, { row({
    cell(CAPL, table.concat(left), true),
    cell(CAPG, ""),
    cell(CAPR, table.concat(right)),
  }) }))
end

-- signature block (Central Guide 9004-1(c)); "Dated" at left, the firm and the signer at right
local function signature(meta)
  local sig = meta.signature or {}
  local right = { para("Single", "Respectfully submitted,") }
  right[#right + 1] = para("Single", "")
  for _, l in ipairs(strings(sig.firm)) do right[#right + 1] = para("Single", l) end
  right[#right + 1] = para("Single", "")
  local signer = plain(sig.signer)
  right[#right + 1] = para("Single", "By: /s/ " .. signer)
  right[#right + 1] = para("Single", string.upper(signer))
  for _, l in ipairs(strings(sig.lines)) do right[#right + 1] = para("Single", l) end
  local left = para("Single", meta.date and ("Dated: " .. plain(meta.date)) or "")
  return raw(table_xml({ SIGL, SIGG, SIGR }, { row({ cell(SIGL, left), cell(SIGG, ""), cell(SIGR, table.concat(right)) }) }))
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function numbered(label, inl)
  local content = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", TAB) })
  content:extend(inl)
  return pandoc.Para(content)
end

function Pandoc(doc)
  local meta = doc.meta
  if meta.footer_title == nil or meta.adversary_number == nil then
    error("cacb-adversary: the frontmatter needs footer_title and adversary_number", 0)
  end
  -- the footer reads the document properties (docProps/core.xml) through its SUBJECT and COMMENTS fields;
  -- the title property is not set, so pandoc writes no title block into the body
  doc.meta.subject = pandoc.MetaInlines({ pandoc.Str(string.upper(plain(meta.footer_title))) })
  doc.meta.description = pandoc.MetaInlines({ pandoc.Str(plain(meta.adversary_number)) })

  local out = {}
  local function add(b) out[#out + 1] = b end

  add(counsel(strings(meta.counsel)))
  add(raw(para("CourtTitle", "UNITED STATES BANKRUPTCY COURT")))
  add(raw(para("CourtTitle", "CENTRAL DISTRICT OF CALIFORNIA")))
  add(raw(para("CourtTitle", string.upper(plain(meta.division)))))
  add(raw(para("CourtTitle", "")))
  add(caption(meta))

  -- lead-in: starts the body on its own page (the cover is page 1)
  if meta.lead_in ~= nil then
    local inl = pandoc.read(plain(meta.lead_in), "markdown").blocks[1].content
    add(styled("LeadInPB", { pandoc.Para(inl) }))
  end

  -- the last heading group and the last block stay with the signature block (the typst template keeps the last
  -- group of prayer items with its signature): those blocks chain by keep-with-next
  local last_header = 0
  for i, b in ipairs(doc.blocks) do if b.t == "Header" then last_header = i end end
  local n = 0
  for i, b in ipairs(doc.blocks) do
    local keep = i > last_header or i == #doc.blocks
    if b.t == "Header" then
      local text = plain(b.content)
      if b.level == 1 then
        add(raw(para("Heading1", string.upper(text))))
      elseif b.level == 2 then
        add(raw(para("Heading2", text)))
      else
        add(raw(para("Heading3", text)))
      end
    elseif b.t == "Para" then
      local text = plain(b.content)
      if text:match("^WHEREFORE") then
        add(styled("LeadIn", { b }))
      else
        n = n + 1
        add(styled(keep and "AllegationKeep" or "Allegation", { numbered(n .. ".", b.content) }))
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes and b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local label = (start + i - 1) .. "."
        local first = item[1]
        local rest = { table.unpack(item, 2) }
        if first and (first.t == "Para" or first.t == "Plain") then
          add(styled(keep and "ListItemKeep" or "ListItem", { numbered(label, first.content) }))
        else
          add(styled(keep and "ListItemKeep" or "ListItem", { pandoc.Para({ pandoc.Str(label) }) }))
        end
        for _, x in ipairs(rest) do add(x) end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          add(styled("ListItem", { numbered("\u{2022}", first.content) }))
        end
      end
    elseif b.t == "Table" then
      add(b:walk({
        Plain = function(p) return styled("Single", { pandoc.Para(p.content) }) end,
        Para = function(p) return styled("Single", { pandoc.Para(p.content) }) end,
      }))
    else
      add(b)
    end
  end

  -- one blank numbered line before the signature (typst: each list item ends with a line), kept with it
  add(raw(para("BodyText", "", "<w:keepNext/>")))
  add(signature(meta))
  doc.meta.date = nil
  doc.blocks = out
  return doc
end

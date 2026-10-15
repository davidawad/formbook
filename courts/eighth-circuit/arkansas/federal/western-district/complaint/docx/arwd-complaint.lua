-- Complaint for the Western District of Arkansas, DOCX engine (docs/DOCX.md): markdown -> Word on reference.docx.
-- Follows typst/arwd-complaint.typ: the court title and the caption (a borderless table) single spaced, the title
-- in bold capitals, the lead-in, numbered paragraphs (the filter numbers them; the sample types no numbers),
-- lettered lists (a., b., ...), unnumbered paragraphs that start with "^ ", headings, and the signature block.
-- Every word comes from the sample's frontmatter or body. Styles are defined in reference.docx (build-reference.sh).
-- Known limits (see README.md, Engines): Word's line breaking and tab stops differ slightly from typst's; the
-- stacked headings (COUNT I over STRICT LIABILITY) are a single "Heading Continued" paragraph, not a heading;
-- the caption and signature tables hold plain text (no italics inside them).

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function style(blocks, name)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- one double-spaced blank line (the gap that typst puts with v(pitch))
local function blank()
  return pandoc.RawBlock("openxml", "<w:p/>")
end

-- a frontmatter value as inlines: markdown (parsed as Inlines), a plain string, or blocks
local function inl(v)
  if type(v) == "string" then return pandoc.Inlines({ pandoc.Str(v) }) end
  local kind = pandoc.utils.type(v)
  if kind == "Inlines" then return pandoc.Inlines(v) end
  if kind == "Blocks" then return pandoc.utils.blocks_to_inlines(v) end
  error("arwd-complaint: unexpected frontmatter value of type " .. kind, 0)
end

local function upper(ils)
  return pandoc.Inlines(ils):walk({
    Str = function(s) return pandoc.Str(s.text:upper()) end,
  })
end

-- A paragraph of plain text in a table cell (formatting is not kept inside the tables: none is needed there).
local function para(text, style_name)
  return { text = text, style = style_name }
end

local function text(v)
  return pandoc.utils.stringify(inl(v))
end

local function xml_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- A borderless table written as WordprocessingML, so its widths are exact: pandoc scales its own tables to a
-- fixed 5.5 in. Each row is a list of cells; each cell a list of para() paragraphs; widths are in twips (1440 = 1 in).
local function grid(rows, widths)
  local total = 0
  local cols = {}
  for _, w in ipairs(widths) do
    total = total + w
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local out = {
    '<w:tbl><w:tblPr><w:tblStyle w:val="Table"/><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
      .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
      .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/></w:tblPr>'
      .. '<w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>',
  }
  for _, r in ipairs(rows) do
    out[#out + 1] = '<w:tr>'
    for i, c in ipairs(r) do
      if #c == 0 then c = { para("", "Single") } end
      local paras = {}
      for _, p in ipairs(c) do
        local run = p.text ~= "" and ('<w:r><w:t xml:space="preserve">' .. xml_escape(p.text) .. '</w:t></w:r>') or ""
        paras[#paras + 1] = '<w:p><w:pPr><w:pStyle w:val="' .. p.style .. '"/></w:pPr>' .. run .. '</w:p>'
      end
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. table.concat(paras) .. '</w:tc>'
    end
    out[#out + 1] = '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return pandoc.RawBlock("openxml", table.concat(out))
end

-- the text width is 6.5 in (letter, 1 in margins); typst's caption column is 3.6 in plus a 0.2 in gutter
local CAPTION_COLS = { 5472, 3888 }
-- the signature block: "Dated" in a 2.6 in column plus a 0.2 in gutter, the signer in the rest
local SIGNATURE_COLS = { 4032, 5328 }

local function court_title(meta)
  local lines = {}
  for _, c in ipairs(meta.court) do lines[#lines + 1] = c end
  if meta.division then lines[#lines + 1] = meta.division end
  local out = {}
  for _, l in ipairs(lines) do
    out[#out + 1] = style({ pandoc.Para(upper(inl(l))) }, "Centered")
  end
  return out
end

-- party names on the left with their designation on the right; "v." and the case number share the row
-- between two parties
local function caption(meta)
  local case = pandoc.utils.stringify(meta.case_number)
  local rows = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      rows[#rows + 1] = { { para("v.", "Single") }, { para("CASE NO. " .. case, "Single") } }
    end
    for i, n in ipairs(p.names) do
      local right = {}
      if i == 1 then right = { para(text(p.designation), "SingleRight") } end
      rows[#rows + 1] = { { para(text(n), "Single") }, right }
    end
  end
  return grid(rows, CAPTION_COLS)
end

-- "Dated:" on the left; the firm, "/s/" over the signer's name, and the signer's lines on the right
local function signature(meta)
  local sig = meta.signature
  local left = {}
  if meta.date then left = { para("Dated: " .. text(meta.date), "Single") } end
  local right = {}
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = para(text(l), "Single") end
  if sig.firm then right[#right + 1] = para("", "Single") end
  right[#right + 1] = para("/s/ " .. text(sig.signer), "Single")
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = para(text(l), "Single") end
  return grid({ { left, right } }, SIGNATURE_COLS)
end

local function letter(i) return string.char(96 + i) .. "." end

-- a markdown list (the complaint's "1." items) as lettered paragraphs with a hanging indent
local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local blocks = { table.unpack(item) }
    local first = blocks[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local ils = pandoc.Inlines({ pandoc.Str(letter(i)), TAB }):extend(first.content)
      blocks[1] = pandoc.Para(ils)
    else
      table.insert(blocks, 1, pandoc.Para({ pandoc.Str(letter(i)), TAB }))
    end
    out[#out + 1] = style(blocks, "Lettered")
  end
  return out
end

-- a paragraph that begins "^ " is unnumbered (the WHEREFORE clauses): the marker is dropped, the indent kept
local function unnumbered(p)
  return p.content[1] and p.content[1].t == "Str" and p.content[1].text == "^"
    and p.content[2] and p.content[2].t == "Space"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  addall(court_title(meta))
  add(blank())
  add(caption(meta))
  add(blank())
  add(style({ pandoc.Para({ pandoc.Strong(upper(inl(meta.title))) }) }, "Centered"))
  add(blank())
  if meta.lead_in then add(pandoc.Para(inl(meta.lead_in))) end

  local n = 0
  local prev_header = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local content = b.level == 1 and upper(b.content) or b.content
      if prev_header then
        -- a heading under a heading (COUNT I over STRICT LIABILITY) sits one line below it, not a blank line
        add(style({ pandoc.Para(content) }, "HeadingContinued"))
      else
        add(pandoc.Header(b.level, content, b.attr))
      end
      prev_header = true
    else
      prev_header = false
      if b.t == "Para" or b.t == "Plain" then
        if unnumbered(b) then
          local ils = pandoc.Inlines(b.content)
          ils:remove(1)
          ils:remove(1)
          add(pandoc.Para(ils))
        else
          n = n + 1
          local ils = pandoc.Inlines({ pandoc.Str(n .. "."), TAB }):extend(b.content)
          add(pandoc.Para(ils))
        end
      elseif b.t == "OrderedList" then
        addall(lettered(b))
      else
        add(b)
      end
    end
  end

  add(blank())
  add(signature(meta))
  add(blank())

  doc.blocks = out
  doc.meta = {}
  return doc
end

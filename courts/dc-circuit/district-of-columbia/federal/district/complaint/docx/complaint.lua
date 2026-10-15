-- Complaint for the U.S. District Court for the District of Columbia (dcd), DOCX engine. Mirrors
-- ../typst/dcd-complaint.typ: the court title, caption and signature block are raw WordprocessingML (a
-- borderless table with the caption rule), numbered paragraphs, lettered prayer items and the unnumbered
-- WHEREFORE line are custom-style paragraphs of reference.docx (make-reference.sh); headings are Heading 1
-- to 3 of the reference. Page numbers come from the reference footer (centered, arabic, from page 1).
-- Prayer lists are lettered A to Z (one letter per item).

local meta
local counter = 0

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- One raw paragraph. ppr is the pPr body (children in schema order: pStyle, keepNext, spacing, ind, jc);
-- runs is a list of {text, bold} pairs, or a single string.
local function para_xml(ppr, runs)
  local body = {}
  if type(runs) == "string" then runs = { { runs, false } } end
  for _, r in ipairs(runs) do
    local rpr = r[2] and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
    if r[1] == "\n" then
      body[#body + 1] = "<w:r>" .. rpr .. "<w:br/></w:r>"
    else
      body[#body + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(r[1]) .. "</w:t></w:r>"
    end
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. table.concat(body) .. "</w:p>"
end

local function style(id, extra)
  return '<w:pStyle w:val="' .. id .. '"/>' .. (extra or "")
end

-- An empty Normal line (exact 24 pt): the typst v(pitch) gap between two blocks.
local function spacer()
  return para_xml('<w:keepNext/>', "")
end

-- Cell paragraphs: CaptionLine (single spacing, 13.8 pt pitch) for every item.
local function lines_xml(items)
  local out = {}
  for _, it in ipairs(items) do
    if type(it) == "table" then
      out[#out + 1] = para_xml(style("CaptionLine", it.before and ('<w:spacing w:before="' .. it.before .. '" w:after="0" w:line="276" w:lineRule="exact"/>') or ""), it.runs)
    else
      out[#out + 1] = para_xml(style("CaptionLine"), it)
    end
  end
  return table.concat(out)
end

local function cell(width, inner, extra_pr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra_pr or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function court_title()
  return raw(para_xml(style("CourtTitle"), {
    { "UNITED STATES DISTRICT COURT", true }, { "\n", false }, { "FOR THE DISTRICT OF COLUMBIA", true },
  }))
end

-- The caption: parties (left, closed by a rule on the right and bottom, as the typst template) and the case
-- number, title and jury line (right). Column widths are the typst grid: 3.4 in, 0.2 in gutter, the rest.
local function caption()
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = "v." end
    for _, n in ipairs(p.names) do left[#left + 1] = txt(n) end
    left[#left + 1] = txt(p.designation)
  end
  local number = txt(meta.case_number)
  if number == "" then number = "____________" end
  local right = {
    "Civil Action No. " .. number,
    { runs = { { txt(meta.brief_title), true } }, before = 240 },
  }
  local jury = meta.jury_demand == true or txt(meta.jury_demand) == "true"
  if jury then right[#right + 1] = { runs = { { "DEMAND FOR JURY TRIAL", true } }, before = 240 } end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local left_mar = '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  local right_mar = '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="288"/><w:gridCol w:w="4176"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(4896, lines_xml(left), rule .. left_mar)
    .. cell(288, para_xml(style("CaptionLine"), ""))
    .. cell(4176, lines_xml(right), right_mar)
    .. '</w:tr></w:tbl>')
end

-- The signature block: "Dated" at left; "Respectfully submitted," and the signature line at right, then the
-- signer, firm and role lines (typst: a grid of 2.8 in, a 0.2 in gutter and the rest; the row does not split).
local function signature()
  local sig = meta.signature
  local right = { "Respectfully submitted," }
  right[#right + 1] = { runs = { { "", false } }, before = 204 }  -- 24 pt gap: 204 + the 276 line
  right[#right + 1] = "________________________________"
  right[#right + 1] = txt(sig.signer)
  for _, l in ipairs(sig.firm) do right[#right + 1] = txt(l) end
  right[#right + 1] = txt(sig.role)
  local left = lines_xml({ "Dated: " .. txt(meta.date) })
  return raw(spacer() ..  -- the typst v(pitch) before the block
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4032"/><w:gridCol w:w="288"/><w:gridCol w:w="5040"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(4032, left)
    .. cell(288, para_xml(style("CaptionLine"), ""))
    .. cell(5040, lines_xml(right))
    .. '</w:tr></w:tbl>')
end

local function inlines_of(b)
  if b.t == "Para" or b.t == "Plain" then return b.content end
  return nil
end

function Pandoc(doc)
  meta = doc.meta
  local out = {}
  out[#out + 1] = court_title()
  out[#out + 1] = raw(spacer())
  out[#out + 1] = caption()
  out[#out + 1] = raw(spacer())
  if meta.lead_in then
    out[#out + 1] = pandoc.Div({ pandoc.Para(meta.lead_in) }, { ["custom-style"] = "Pleading Text" })
  end
  local blocks = doc.blocks
  for idx, b in ipairs(blocks) do
    -- The last block keeps with the signature block (keep-with-next), so a signature never stands alone.
    local last = idx == #blocks
    if b.t == "Header" then
      out[#out + 1] = b
    elseif inlines_of(b) then
      -- A numbered paragraph (Fed. R. Civ. P. 10(b)): the template numbers it.
      counter = counter + 1
      local items = { pandoc.Str(counter .. "."), TAB }
      for _, x in ipairs(inlines_of(b)) do items[#items + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(items) }, { ["custom-style"] = last and "Last Numbered Paragraph" or "Numbered Paragraph" })
    elseif b.t == "OrderedList" then
      -- Prayer items are lettered (A., B., ...) as in the filed exemplar; the markdown numbers are dropped.
      for j, item in ipairs(b.content) do
        local letter = string.char(64 + j)
        local first = item[1] and inlines_of(item[1])
        local items = { pandoc.Str(letter .. "."), TAB }
        for _, x in ipairs(first or {}) do items[#items + 1] = x end
        local keep = last and j == #b.content
        out[#out + 1] = pandoc.Div({ pandoc.Para(items) }, { ["custom-style"] = keep and "Last Prayer Item" or "Prayer Item" })
        for k = 2, #item do out[#out + 1] = pandoc.Div({ item[k] }, { ["custom-style"] = "Pleading Text" }) end
      end
    elseif b.t == "BlockQuote" then
      -- A ">" line is an unnumbered paragraph (for example the WHEREFORE lead-in).
      out[#out + 1] = pandoc.Div(b.content, { ["custom-style"] = last and "Last Pleading Text" or "Pleading Text" })
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = signature()
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

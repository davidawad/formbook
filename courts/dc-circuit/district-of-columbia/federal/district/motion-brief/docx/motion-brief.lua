-- Memorandum of points and authorities in support of a motion, for the U.S. District Court for the District of
-- Columbia (dcd), DOCX engine. Mirrors ../typst/dcd-motion-brief.typ: the caption page, contents and signature block
-- are raw WordprocessingML; body paragraphs, block quotations and headings are custom-style paragraphs and Heading 1 to 3
-- of reference.docx (make-reference.sh). Sections: the caption page has no page number; the contents are numbered in
-- lower-case roman; the body is numbered in arabic from 1 (the reference's final section). The contents entries are
-- typed text (not a TOC field) with the page numbers from a first layout pass, read from DCD_TOC_PAGES (one number per
-- heading, in order); docx/render.sh writes that file. DCD_SIDECAR, when set, receives the headings and the first
-- body words so the render script can find the pages in the PDF.

local meta
local toc = {}

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local PAGE_W = 12240
local MARGIN = 1440

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

-- One raw paragraph; ppr holds the pPr children in schema order (pStyle, keepNext, tabs, spacing, ind, jc).
-- runs: a string, or a list of {text, bold} pairs; the text "\n" is a line break.
local function para_xml(ppr, runs)
  local body = {}
  if type(runs) == "string" then runs = { { runs, false } } end
  for _, r in ipairs(runs) do
    local rpr = r[2] and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
    if r[1] == "\n" then
      body[#body + 1] = "<w:r>" .. rpr .. "<w:br/></w:r>"
    elseif r[1] == "\t" then
      body[#body + 1] = "<w:r>" .. rpr .. "<w:tab/></w:r>"
    else
      body[#body + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(r[1]) .. "</w:t></w:r>"
    end
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. table.concat(body) .. "</w:p>"
end

local function style(id, extra)
  return '<w:pStyle w:val="' .. id .. '"/>' .. (extra or "")
end

-- Single-spaced lines (13.8 pt pitch); a line with before= starts that much lower (the typst v(...) gaps).
local function lines_xml(items)
  local out = {}
  for _, it in ipairs(items) do
    if type(it) == "table" then
      out[#out + 1] = para_xml(style("CaptionLine", '<w:spacing w:before="' .. it.before .. '" w:after="0" w:line="276" w:lineRule="exact"/>'), it.runs or it.text)
    else
      out[#out + 1] = para_xml(style("CaptionLine"), it)
    end
  end
  return table.concat(out)
end

local function cell(width, inner, extra_pr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra_pr or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function borderless_table(widths, rows_xml)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. rows_xml .. '</w:tr></w:tbl>'
end

-- The empty line of the typst v(pitch) gap between two blocks.
local function spacer()
  return para_xml('<w:keepNext/>', "")
end

-- A section break: the paragraph ends the section it closes. footer: the footer relationship, or nil (no footer);
-- fmt: the page number format of the section ("lowerRoman" or "decimal"), or nil (no numbering).
local function section_break(footer, fmt)
  local fr = footer and ('<w:footerReference w:type="default" r:id="' .. footer .. '"/>') or ""
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:sectPr>' .. fr
    .. '<w:pgSz w:w="' .. PAGE_W .. '" w:h="15840"/><w:pgMar w:top="' .. MARGIN .. '" w:right="' .. MARGIN
    .. '" w:bottom="' .. MARGIN .. '" w:left="' .. MARGIN .. '" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. '</w:sectPr></w:pPr></w:p>')
end

-- The caption: parties (left, closed by a rule on the right and bottom) and the case number (right).
local function caption()
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = "v." end
    for _, n in ipairs(p.names) do left[#left + 1] = txt(n) end
    left[#left + 1] = txt(p.designation)
  end
  local number = txt(meta.case_number)
  if number == "" then number = "____________" end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local left_mar = '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  local right_mar = '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'
  return raw(borderless_table({ 4896, 288, 4176 },
    cell(4896, lines_xml(left), rule .. left_mar)
    .. cell(288, para_xml(style("CaptionLine"), ""))
    .. cell(4176, lines_xml({ "Civil Action No. " .. number }), right_mar)))
end

-- The signature block (typst: "Dated" at left; "Respectfully submitted," and the firm, the signature line and the
-- signature at right; then one block of lines per signer, each after a half-line gap).
local function signature()
  local sig = meta.signature
  local right = { "Respectfully submitted,", { text = txt(sig.firm), before = 240 } }
  right[#right + 1] = { text = "________________________________", before = 240 }
  right[#right + 1] = txt(sig.signature)
  for _, lines in ipairs(sig.blocks) do
    local first = true
    for _, l in ipairs(lines) do
      if first then
        right[#right + 1] = { text = txt(l), before = 240 }
        first = false
      else
        right[#right + 1] = txt(l)
      end
    end
  end
  return raw(spacer() .. borderless_table({ 4032, 288, 5040 },
    cell(4032, lines_xml({ "Dated: " .. txt(meta.date) }))
    .. cell(288, para_xml(style("CaptionLine"), ""))
    .. cell(5040, lines_xml(right))))
end

local function cover()
  local out = {}
  out[#out + 1] = raw(para_xml(style("CourtTitle"), {
    { "UNITED STATES DISTRICT COURT", true }, { "\n", false }, { "FOR THE DISTRICT OF COLUMBIA", true },
  }))
  out[#out + 1] = raw(spacer())
  out[#out + 1] = caption()
  out[#out + 1] = raw(spacer())
  -- The title of the paper, centered under the caption (double-spaced, bold).
  out[#out + 1] = raw(para_xml(style("CourtTitle"), txt(meta.brief_title)))
  return out
end

local function contents()
  local out = {}
  out[#out + 1] = raw(para_xml(style("CourtTitle"), "TABLE OF CONTENTS"))
  out[#out + 1] = raw(spacer())
  local pages = {}
  local f = os.getenv("DCD_TOC_PAGES") and io.open(os.getenv("DCD_TOC_PAGES"), "r")
  if f then
    for line in f:lines() do pages[#pages + 1] = line end
    f:close()
  end
  for i, h in ipairs(toc) do
    -- indented one step (0.25 in) per heading level below the first
    local ind = '<w:ind w:left="' .. ((h.level - 1) * 360) .. '"/>'
    local runs = { { h.title, false }, { "\t", false }, { pages[i] or "", false } }
    out[#out + 1] = raw(para_xml(style("ContentsLine") .. ind, runs))
  end
  out[#out + 1] = section_break("rIdFtr1", "lowerRoman")
  return out
end

local function first_words(s, n)
  local words = {}
  for w in s:gmatch("%S+") do
    words[#words + 1] = w
    if #words == n then break end
  end
  return table.concat(words, " ")
end

local function write_sidecar(first_body)
  local path = os.getenv("DCD_SIDECAR")
  if not path then return end
  local f = assert(io.open(path, "w"))
  f:write("B\t", first_words(first_body, 4), "\n")
  for _, h in ipairs(toc) do
    f:write("H\t", h.level, "\t", first_words(h.title, 4), "\n")
  end
  f:close()
end

function Pandoc(doc)
  meta = doc.meta
  -- The contents list: every heading of the body, in order.
  local first_body = nil
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      toc[#toc + 1] = { level = b.level, title = pandoc.utils.stringify(b.content) }
    elseif b.t == "Para" and first_body == nil then
      first_body = pandoc.utils.stringify(b.content)
    end
  end
  write_sidecar(first_body or "")

  local out = {}
  -- The caption page closes its own section (no page number), then the contents (roman) if the sample asks for them.
  for _, b in ipairs(cover()) do out[#out + 1] = b end
  out[#out + 1] = section_break(nil, nil)
  if meta.toc == true then
    for _, b in ipairs(contents()) do out[#out + 1] = b end
  end

  local blocks = doc.blocks
  for idx, b in ipairs(blocks) do
    -- The last paragraph keeps with the signature block, so a signature never stands alone on a page.
    local last = idx == #blocks
    if b.t == "Header" then
      out[#out + 1] = b
    elseif b.t == "Para" or b.t == "Plain" then
      -- A paragraph: first-line indented, unnumbered (a memorandum is not numbered).
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = last and "Last Pleading Text" or "Pleading Text" })
    elseif b.t == "BlockQuote" then
      -- A ">" line: a block quotation, indented from both margins (LCvR 5.1(d) does not except quotations).
      out[#out + 1] = pandoc.Div(b.content, { ["custom-style"] = "Block Quote" })
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = signature()
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

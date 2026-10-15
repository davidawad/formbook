-- lamd-complaint.lua: the M.D. La. complaint for the docx engine (pandoc --lua-filter, run by tools/render-docx.sh).
-- Builds the cover (court name, caption table, title, subtitle), the lead-in and the signature block from the
-- sample's frontmatter, exactly as typst/lamd-complaint.typ does, and numbers the body paragraphs (Fed. R. Civ. P.
-- 10(b)). A ">" paragraph is unnumbered. The last body block stays on the page with the signature (keepNext).
-- Styles are the Lamd* styles and the Heading styles of docx/reference.docx (docx/build-reference.sh).

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function strings(v)
  local out = {}
  if v ~= nil and pandoc.utils.type(v) == "List" then
    for _, x in ipairs(v) do table.insert(out, text(x)) end
  end
  return out
end

-- one paragraph of OpenXML; extra is pPr content placed after the style (keepNext etc., in schema order)
local function para_xml(style, s, extra)
  local run = ""
  if s ~= nil and s ~= "" then
    run = '<w:r><w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. "</w:pPr>" .. run .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- caption: party names in a 2.7 in column, the civil action number (with the judge initials) at the right
local function caption_table(meta)
  local left, right = {}, {}
  for _, line in ipairs(strings(meta.caption)) do
    table.insert(left, para_xml("LamdCaption", line))
  end
  local number = text(meta.civil_action_no)
  for _, j in ipairs(strings(meta.judges)) do
    number = number .. "-" .. j
  end
  table.insert(right, para_xml("LamdCaptionRight", "CIVIL ACTION NO. " .. number))
  if text(meta.judge) ~= "" then
    table.insert(right, para_xml("LamdCaptionRight", ""))
    table.insert(right, para_xml("LamdCaptionRight", text(meta.judge)))
  end
  if text(meta.magistrate) ~= "" then
    table.insert(right, para_xml("LamdCaptionRight", text(meta.magistrate)))
  end
  local function cell(w, paras)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(paras) .. "</w:tc>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
    .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="3888"/><w:gridCol w:w="5472"/></w:tblGrid>'
    .. "<w:tr>" .. cell(3888, left) .. cell(5472, right) .. "</w:tr></w:tbl>"
end

local function cover(meta, title, subtitle)
  local x = {}
  table.insert(x, para_xml("LamdCourt", "UNITED STATES DISTRICT COURT"))
  table.insert(x, para_xml("LamdCourt", "MIDDLE DISTRICT OF LOUISIANA"))
  table.insert(x, para_xml("LamdBlank"))
  table.insert(x, caption_table(meta))
  table.insert(x, para_xml("LamdBlank"))
  table.insert(x, para_xml("LamdTitle", title))
  if subtitle ~= "" then
    table.insert(x, para_xml("LamdSubtitle", subtitle))
  end
  table.insert(x, para_xml("LamdBlank"))
  return x
end

-- a paragraph with a leading label ("1." or a bullet) and a tab to the text
local function labelled(label, inlines, style)
  local content = pandoc.List:new({ pandoc.Str(label), TAB })
  for _, x in ipairs(inlines) do
    content:insert(x)
  end
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

-- body blocks to docx blocks; the last block gets the "keep with next" style when keep_last is set
local function convert(blocks, keep_last)
  local out = pandoc.List:new({})
  local n = 0
  for i, b in ipairs(blocks) do
    local keep = keep_last and i == #blocks
    if b.t == "Para" then
      n = n + 1
      out:insert(labelled(n .. ".", b.content, keep and "Lamd Numbered Keep" or "Lamd Numbered"))
    elseif b.t == "BlockQuote" then
      -- unnumbered paragraph, flush with the numbered ones (the jurisdiction statement, the prayer's lead-in)
      for _, c in ipairs(b.content) do
        if c.t == "Para" then
          if keep and c == b.content[#b.content] then
            out:insert(pandoc.Div({ pandoc.Para(c.content) }, { ["custom-style"] = "Lamd Body Keep" }))
          else
            out:insert(pandoc.Para(c.content))
          end
        else
          out:insert(c)
        end
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      local start = (b.t == "OrderedList" and b.start) or 1
      local style = keep and "Lamd List Keep" or "Lamd List"
      for k, item in ipairs(b.content) do
        local label = (b.t == "OrderedList") and (tostring(start + k - 1) .. ".") or "\u{2022}"
        local first = item[1]
        if first and (first.t == "Plain" or first.t == "Para") then
          out:insert(labelled(label, first.content, style))
          for j = 2, #item do
            out:insert(item[j])
          end
        else
          out:insert(labelled(label, {}, style))
          for _, c in ipairs(item) do
            out:insert(c)
          end
        end
      end
    else
      out:insert(b)
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local title = text(meta.title)
  local subtitle = text(meta.subtitle)
  -- the cover is built below; pandoc must not print the metadata title or subtitle again
  meta.title = nil
  meta.subtitle = nil

  local out = pandoc.List:new({})
  for _, x in ipairs(cover(meta, title, subtitle)) do
    out:insert(raw(x))
  end
  if meta.lead_in ~= nil then
    local lead = meta.lead_in
    if pandoc.utils.type(lead) == "Inlines" then
      out:insert(pandoc.Para(lead))
    else
      out:insert(pandoc.Para({ pandoc.Str(text(lead)) }))
    end
  end

  local body = doc.blocks
  out:extend(convert(body, true))

  -- signature block: single spaced, in the right part of the page, kept together with the last paragraph
  local sig = meta.signature
  local lines = sig and strings(sig.lines) or {}
  local date = sig and text(sig.date) or ""
  out:insert(raw(para_xml("LamdBlank", "", "<w:keepNext/>")))
  if date ~= "" then
    out:insert(raw(para_xml("LamdSignature", "Dated: " .. date, "<w:keepNext/>")))
    out:insert(raw(para_xml("LamdBlank", "", "<w:keepNext/>")))
  end
  for k, line in ipairs(lines) do
    out:insert(raw(para_xml("LamdSignature", line, k < #lines and "<w:keepNext/>" or nil)))
  end
  return pandoc.Pandoc(out, meta)
end

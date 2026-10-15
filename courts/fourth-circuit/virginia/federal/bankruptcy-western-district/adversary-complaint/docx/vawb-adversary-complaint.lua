-- Complaint commencing an adversary proceeding, United States Bankruptcy Court, W.D. Virginia (vawb), DOCX engine.
-- The markdown contract -> Word on docx/reference.docx. The front matter (court title, caption, title, salutation),
-- the signature block and the service addresses are built here with the layout of
-- typst/vawb-adversary-complaint.typ: Word paragraphs in the styles of reference.docx and borderless tables.
-- The body keeps its markdown structure; numbered allegations are written as text with a hanging indent (not Word
-- list numbering) so that the numbers are the ones the sample gives. The last body paragraph is kept with the
-- signature block (keepNext), which the typst template does not do (see README.md, Engines).
-- The title is printed under the caption (the sample gives it; the typst template does not print it, see README.md).

local TAB = pandoc.Inlines({ pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function empty(v)
  return v == nil or pandoc.utils.stringify(v) == ""
end

-- a metadata value (markdown inlines in the YAML) as an Inlines list
local function inl(v)
  local out = pandoc.Inlines({})
  if v == nil then return out end
  if type(v) == "string" then
    out:insert(pandoc.Str(v))
  elseif v.t == "MetaInlines" then
    for _, x in ipairs(v) do out:insert(x) end
  else
    out:insert(pandoc.Str(pandoc.utils.stringify(v)))
  end
  return out
end

-- concatenate Inlines lists
local function join(...)
  local out = pandoc.Inlines({})
  for _, part in ipairs({ ... }) do
    for _, x in ipairs(part) do out:insert(x) end
  end
  return out
end

local function list(v)
  local out = {}
  if v == nil then return out end
  for _, x in ipairs(v) do out[#out + 1] = x end
  return out
end

local function text(s)
  return pandoc.Inlines({ pandoc.Str(s) })
end

local function upper_inlines(content)
  return pandoc.Inlines(content):walk({
    Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end,
  })
end

-- Inlines -> Word runs (plain, italic, bold; the front matter uses no other inline markup)
local function runs(inlines)
  local out = {}
  local function emit(s, f)
    local rpr = (f.b and "<w:b/><w:bCs/>" or "") .. (f.i and "<w:i/><w:iCs/>" or "")
    out[#out + 1] = "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
      .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
  end
  local function walk(items, f)
    for _, x in ipairs(items) do
      if x.t == "Str" then emit(x.text, f)
      elseif x.t == "Space" or x.t == "SoftBreak" or x.t == "LineBreak" then emit(" ", f)
      elseif x.t == "Emph" then walk(x.content, { b = f.b, i = true })
      elseif x.t == "Strong" then walk(x.content, { b = true, i = f.i })
      else emit(pandoc.utils.stringify(x), f) end
    end
  end
  walk(inlines, {})
  return table.concat(out)
end

-- one paragraph in a named paragraph style
local function para(style, inlines)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. runs(inlines) .. "</w:p>"
end

local function gap(style)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Tables: borderless, fixed widths in twips (9360 = the 6.5 in text width)
-- ---------------------------------------------------------------------------

local function cell(width, paras, o)
  o = o or {}
  local borders = ""
  if o.bottom or o.right then
    borders = "<w:tcBorders>"
      .. (o.bottom and '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' or "")
      .. (o.right and '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' or "")
      .. "</w:tcBorders>"
  end
  local mar = string.format(
    '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="%d" w:type="dxa"/><w:bottom w:w="%d" w:type="dxa"/><w:right w:w="%d" w:type="dxa"/></w:tcMar>',
    o.left or 0, o.bottom_mar or 0, o.right_mar or 0)
  return string.format('<w:tc><w:tcPr><w:tcW w:w="%d" w:type="dxa"/>%s%s</w:tcPr>%s</w:tc>',
    width, borders, mar, table.concat(paras))
end

local function row(cells)
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
end

local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = string.format('<w:gridCol w:w="%d"/>', w)
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Front matter (typst: court-title, caption, salutation)
-- ---------------------------------------------------------------------------

local CAP_L, CAP_R = 5760, 3600 -- caption: the party column is 4 in; the right column starts 0.35 in in (gutter + inset)

local function court_title(meta)
  local x = para("CourtTitle", text("UNITED STATES BANKRUPTCY COURT"))
    .. para("CourtTitle", text("WESTERN DISTRICT OF VIRGINIA"))
  if not empty(meta.division) then
    x = x .. para("CourtTitle", text(pandoc.text.upper(pandoc.utils.stringify(meta.division))))
  end
  return x .. gap("Gap16")
end

-- Adversary caption (Form 416 layout, LR 9013-1(I) style): the "In re" block and the parties in one bordered
-- left column; chapter, case number and the adversary number on the right.
local function caption_adversary(meta)
  local left, right = {}, {}
  for k, d in ipairs(list(meta.caption.in_re)) do
    if k == 1 then left[#left + 1] = para("Single", text("In re:")) end
    for _, n in ipairs(list(d.names)) do left[#left + 1] = para("Single", inl(n)) end
    left[#left + 1] = para("Single", inl(d.designation))
    left[#left + 1] = gap("Single")
    right[#right + 1] = para("Single", join(text("Chapter "), inl(d.chapter)))
    right[#right + 1] = para("Single", join(text("Case No. "), inl(d.case_number)))
    right[#right + 1] = gap("Single")
  end
  for k, p in ipairs(list(meta.caption.parties)) do
    if k > 1 then left[#left + 1] = para("Single", text("v.")) end
    for _, n in ipairs(list(p.names)) do left[#left + 1] = para("Single", inl(n)) end
    left[#left + 1] = para("Single", inl(p.designation))
  end
  local value = empty(meta.caption.number.value) and text("________") or inl(meta.caption.number.value)
  right[#right + 1] = para("Single", join(inl(meta.caption.number.label), text(" "), value))
  return table_xml({ CAP_L, CAP_R }, {
    row({
      cell(CAP_L, left, { bottom = true, right = true, right_mar = 60, bottom_mar = 160 }),
      cell(CAP_R, right, { left = 504 }),
    }),
  })
end

-- ---------------------------------------------------------------------------
-- Signature block (counsel lower left) and the service addresses under it
-- ---------------------------------------------------------------------------

local SIG_L, SIG_G, SIG_R = 4896, 288, 4176

local function signature_block(meta)
  local x = gap("Gap16")
  if meta.signature and not empty(meta.signature.date) then
    x = x .. para("SingleKeep", join(text("Dated: "), inl(meta.signature.date))) .. gap("Gap6")
  end
  local left = {}
  for _, n in ipairs(list(meta.counsel.names)) do left[#left + 1] = para("SingleKeep", inl(n)) end
  for _, n in ipairs(list(meta.counsel.lines)) do left[#left + 1] = para("SingleKeep", inl(n)) end
  local right = {
    para("SingleKeep", text("Respectfully submitted,")),
    gap("SingleKeep"),
    para("SingleKeep", text(pandoc.text.upper(pandoc.utils.stringify(meta.signature.party)))),
    gap("SingleKeep"),
    para("SingleKeep", join(text("BY: /s/ "), inl(meta.signature.signer))),
  }
  for _, n in ipairs(list(meta.signature.lines)) do right[#right + 1] = para("SingleKeep", inl(n)) end
  return x .. table_xml({ SIG_L, SIG_G, SIG_R },
    { row({ cell(SIG_L, left), cell(SIG_G, { gap("SingleKeep") }), cell(SIG_R, right) }) })
end

local function service_block(meta)
  if meta.service == nil then return "" end
  local x = gap("Gap16") .. para("SingleKeep", text("Service:")) .. gap("Gap6")
  for _, g in ipairs(list(meta.service)) do
    for _, n in ipairs(list(g.names)) do x = x .. para("SingleKeep", inl(n)) end
    for _, n in ipairs(list(g.lines)) do x = x .. para("SingleKeep", inl(n)) end
    x = x .. gap("Gap6")
  end
  return x
end

-- ---------------------------------------------------------------------------
-- Body: numbered allegations (Fed. R. Civ. P. 10(b) through FRBP 7010)
-- ---------------------------------------------------------------------------

local function number_body(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      b.content = upper_inlines(b.content)
      out[#out + 1] = b
    elseif b.t == "OrderedList" then
      local start = b.listAttributes.start
      for i, item in ipairs(b.content) do
        local num = start + i - 1
        for k, blk in ipairs(item) do
          if k == 1 and (blk.t == "Para" or blk.t == "Plain") then
            local content = join(text(num .. "."), TAB, blk.content)
            out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "NumberedPara" }))
          else
            out[#out + 1] = blk
          end
        end
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local body = number_body(doc.blocks)

  -- keep the last body paragraph with the signature block
  local last = body[#body]
  if last and last.t == "Para" then
    body[#body] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" }))
  elseif last and last.t == "Div" and last.attr.attributes["custom-style"] == "NumberedPara" then
    last.attr.attributes["custom-style"] = "NumberedKeep"
  end

  local head = court_title(meta) .. caption_adversary(meta) .. gap("Gap16")
  if not empty(meta.title) then
    head = head .. para("CenteredHead", upper_inlines(inl(meta.title))) .. gap("Gap16")
  end
  if not empty(meta.salutation) then
    head = head .. para("BodyText", inl(meta.salutation))
  end

  local out = {}
  out[#out + 1] = pandoc.RawBlock("openxml", head)
  for _, b in ipairs(body) do out[#out + 1] = b end
  out[#out + 1] = pandoc.RawBlock("openxml", signature_block(meta) .. service_block(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

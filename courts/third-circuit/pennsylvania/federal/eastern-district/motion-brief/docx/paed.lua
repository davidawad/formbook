-- paed motion with memorandum of law, DOCX engine. Builds the parts of motion-brief/typst/paed-motion-brief.typ that
-- pandoc cannot write from the markdown contract: the cover of each part (court title, caption table, title), the
-- proposed order's signature, the motion's counsel signature blocks, the certificate of service, the table of
-- contents field, and the section breaks that give the parts their page numbering:
--   order (no number) | motion (arabic from 1) | memorandum cover (no number) | contents (roman) | memorandum (arabic from 1)
-- Styles come from docx/reference.docx (Centered, Compact, Lettered, Signature, SigLine, Body Text, Heading 1-3,
-- Block Text, Table). Every case word is read from the sample's frontmatter and body; nothing here is case text.
-- The section breaks name the footers by relationship id: rId9 is the page-number footer and rId10 the empty
-- footer, the ids pandoc gives footer1.xml and footer2.xml of the reference (checked in the build README).
-- Known differences (see the court README, "Engines"): the table of contents is a field, so its entries and page
-- numbers appear only after Word or LibreOffice updates fields; the caption's right cell is top-aligned.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local TEXT_W = 6.5
local FOOTER_PAGE = '<w:footerReference w:type="default" r:id="rId9"/>'
local FOOTER_NONE = '<w:footerReference w:type="default" r:id="rId10"/>'
local PAGE_SETUP = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

local function inl(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  local t = {}
  if v.t == "MetaInlines" then
    for _, x in ipairs(v) do t[#t + 1] = x end
    return t
  end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function spacer() return pandoc.Para({}) end

-- a table cell: each item is one line (a list of inlines), single spaced as Compact
local function cell(lines)
  local out = {}
  for _, l in ipairs(lines) do out[#out + 1] = pandoc.Plain(l) end
  return pandoc.Cell(out)
end

local function table_of(widths, rows)
  local specs = {}
  for i, w in ipairs(widths) do specs[i] = { pandoc.AlignDefault, w / TEXT_W } end
  return pandoc.Table(pandoc.Caption(nil, {}), specs, pandoc.TableHead({}),
    { { attr = pandoc.Attr(), row_head_columns = 0, head = {}, body = rows } }, pandoc.TableFoot({}))
end

-- a section break: the section that ends here gets the footer, the page-number format and the start
local function section_break(footer, pgnum)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:sectPr>' .. footer .. PAGE_SETUP .. pgnum .. '</w:sectPr></w:pPr></w:p>')
end

local function cover(meta, title)
  local out = {}
  for _, line in ipairs(meta.court_lines) do
    out[#out + 1] = styled("Centered", { pandoc.Para({ pandoc.Strong(inl(line)) }) })
  end
  out[#out + 1] = spacer()
  -- caption: party lines, a ":" per line, and CIVIL ACTION / No. <number> on the right
  local rows = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then rows[#rows + 1] = { pandoc.Str("v.") } end
    for _, nm in ipairs(p.names) do rows[#rows + 1] = inl(nm) end
    rows[#rows + 1] = inl(p.designation)
  end
  local colons = {}
  for _ = 1, #rows do colons[#colons + 1] = { pandoc.Str(":") } end
  local number = inl(meta.case_number)
  if #number == 0 then number = { pandoc.Str("________________") } end
  local right = { { pandoc.Str("CIVIL ACTION") }, { pandoc.Str("No. ") } }
  for _, x in ipairs(number) do table.insert(right[2], x) end
  local left_cell = {}
  for _, r in ipairs(rows) do left_cell[#left_cell + 1] = r end
  out[#out + 1] = table_of({ 3.3 * 72, 0.35 * 72, 2.85 * 72 }, {
    pandoc.Row({ cell(left_cell), cell(colons), cell(right) }),
  })
  out[#out + 1] = spacer()
  out[#out + 1] = styled("Centered", { pandoc.Para({ pandoc.Strong(inl(title)) }) })
  out[#out + 1] = spacer()
  return out
end
-- counsel signature blocks: the date at the left, "Respectfully submitted," and the counsel at the right
local function signature(meta)
  local right = { { pandoc.Str("Respectfully submitted,") }, {} }
  for k, b in ipairs(meta.signature.blocks) do
    if k > 1 then right[#right + 1] = {} end
    for _, l in ipairs(b.firm) do right[#right + 1] = inl(l) end
    right[#right + 1] = {}
    local by = { pandoc.Str("By: /s/ ") }
    for _, x in ipairs(inl(b.signer)) do by[#by + 1] = x end
    right[#right + 1] = by
    for _, l in ipairs(b.lines) do right[#right + 1] = inl(l) end
  end
  local date = { pandoc.Str("Date: ") }
  for _, x in ipairs(inl(meta.date)) do date[#date + 1] = x end
  return { spacer(), table_of({ 2.8 * 72, 3.7 * 72 }, { pandoc.Row({ cell({ date }), cell(right) }) }) }
end

local function order_signature()
  return {
    spacer(), spacer(),
    styled("Signature", { pandoc.Para({ pandoc.Str("BY THE COURT:") }) }),
    styled("SigLine", { pandoc.Para({}) }),
    styled("Signature", { pandoc.Para({ pandoc.Str("J.") }) }),
  }
end

local function certificate(meta)
  local out = { spacer(), styled("Centered", { pandoc.Para({ pandoc.Strong({ pandoc.Str("CERTIFICATE OF SERVICE") }) }) }), spacer() }
  out[#out + 1] = pandoc.Para(inl(meta.service.text))
  out[#out + 1] = spacer()
  local date = { pandoc.Str("Date: ") }
  for _, x in ipairs(inl(meta.service.date)) do date[#date + 1] = x end
  local sig = { pandoc.Str("/s/ ") }
  for _, x in ipairs(inl(meta.service.signer)) do sig[#sig + 1] = x end
  local right = { sig }
  for _, l in ipairs(meta.service.lines) do right[#right + 1] = inl(l) end
  out[#out + 1] = table_of({ 2.8 * 72, 3.7 * 72 }, { pandoc.Row({ cell({ date }), cell(right) }) })
  return out
end

local function render(blocks, out)
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local label = tostring(i) .. "."
        local first = item[1]
        local items = {}
        if first and (first.t == "Plain" or first.t == "Para") then
          local inlines = { pandoc.Str(label), TAB }
          for _, x in ipairs(first.content) do inlines[#inlines + 1] = x end
          items[1] = pandoc.Para(inlines)
          for j = 2, #item do items[#items + 1] = item[j] end
        else
          items[1] = pandoc.Para({ pandoc.Str(label), TAB })
          for _, x in ipairs(item) do items[#items + 1] = x end
        end
        out[#out + 1] = styled("Lettered", items)
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- split the body at the "<!-- name -->" markers (pandoc keeps them as raw html blocks)
local function sections(doc)
  local parts = {}
  local cur = nil
  for _, b in ipairs(doc.blocks) do
    local name = b.t == "RawBlock" and b.text:match("^<!%-%-%s*(%a+)%s*%-%->$")
    if name then
      cur = {}
      parts[name] = cur
    elseif cur then
      cur[#cur + 1] = b
    end
  end
  for _, n in ipairs({ "order", "motion", "memorandum" }) do
    if not parts[n] then error("paed-motion-brief: the sample needs a <!-- " .. n .. " --> section") end
  end
  return parts
end

local function heading_to_toc(doc)
  -- the contents field, with a cached result; Word and LibreOffice update it on open (settings updateFields)
  return pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="Compact"/></w:pPr><w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. '<w:r><w:t>Table of contents: update fields to show the entries and page numbers.</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
end

function Pandoc(doc)
  local meta = doc.meta
  local parts = sections(doc)
  local out = {}

  -- 1. proposed order: no page number
  for _, b in ipairs(cover(meta, meta.order_title)) do out[#out + 1] = b end
  render(parts.order, out)
  for _, b in ipairs(order_signature()) do out[#out + 1] = b end
  out[#out + 1] = section_break(FOOTER_NONE, "")

  -- 2. motion and its certificate of service: arabic from 1
  for _, b in ipairs(cover(meta, meta.motion_title)) do out[#out + 1] = b end
  render(parts.motion, out)
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  out[#out + 1] = spacer()
  for _, b in ipairs(certificate(meta)) do out[#out + 1] = b end
  out[#out + 1] = section_break(FOOTER_PAGE, '<w:pgNumType w:fmt="decimal" w:start="1"/>')

  -- 3. memorandum cover: no page number
  for _, b in ipairs(cover(meta, meta.memo_title)) do out[#out + 1] = b end
  out[#out + 1] = section_break(FOOTER_NONE, "")

  -- 4. table of contents: roman numbers from i
  out[#out + 1] = styled("Centered", { pandoc.Para({ pandoc.Strong({ pandoc.Str("TABLE OF CONTENTS") }) }) })
  out[#out + 1] = spacer()
  out[#out + 1] = heading_to_toc(doc)
  out[#out + 1] = section_break(FOOTER_PAGE, '<w:pgNumType w:fmt="lowerRoman" w:start="1"/>')

  -- 5. memorandum body: arabic from 1 (the final section, from the reference); its numbered headings come from
  --    the Heading styles of the reference
  render(parts.memorandum, out)
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end

  return pandoc.Pandoc(out, pandoc.Meta({}))
end

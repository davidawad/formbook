-- Pandoc Lua filter for the nmb Word template (mirrors typst/nmb-adversary-complaint.typ).
-- Everything case-specific comes from the sample's YAML frontmatter; nothing here names a party.
-- Builds: caption (court, debtor block, case number, party block with rule, adversary number, title),
-- lead-in, numbered paragraphs (the typed numbers are dropped and renumbered), lettered sub-items,
-- prayer, and the signature block. Headings, block quotes, footnotes and plain paragraphs are pandoc's.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Metadata value -> list of blocks (YAML strings are read as markdown by pandoc).
local function as_blocks(m)
  if m == nil then return {} end
  local t = pandoc.utils.type(m)
  if t == "Blocks" then return m end
  if t == "Inlines" then return { pandoc.Para(m) } end
  if t == "string" then return { pandoc.Para({ pandoc.Str(m) }) } end
  error("nmb-filter: unexpected metadata value of type " .. t)
end

local function str(m)
  return pandoc.utils.stringify(m)
end

-- Raw WordprocessingML paragraph: style, optional keep-with-next, optional bold, optional jc.
local function px(style, text, opts)
  opts = opts or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if opts.keep then ppr = ppr .. "<w:keepNext/>" end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local rpr = opts.bold and "<w:rPr><w:b/></w:rPr>" or ""
  local run = ""
  if text ~= "" then
    run = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. run .. "</w:p>"
end

-- A paragraph block (the same XML as px, as a pandoc raw block).
local function para(style, text, opts)
  return pandoc.RawBlock("openxml", px(style, text, opts))
end

-- A bordered-or-plain table; widths in twips, rows = list of { cells = { {tcpr=, xml=}, ... } }.
local function table_xml(widths, rows)
  local total, grid = 0, ""
  for _, w in ipairs(widths) do
    total = total + w
    grid = grid .. '<w:gridCol w:w="' .. w .. '"/>'
  end
  local none = '<w:top w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:left w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:bottom w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:right w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:insideH w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:insideV w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
  local out = '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. "<w:tblBorders>" .. none .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. "</w:tblPr><w:tblGrid>" .. grid .. "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out = out .. "<w:tr>"
    for i, c in ipairs(row) do
      out = out .. '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.tcpr or "")
        .. "</w:tcPr>" .. c.xml .. "</w:tc>"
    end
    out = out .. "</w:tr>"
  end
  return out .. "</w:tbl>"
end

-- Caption: Fed. R. Bankr. P. 7010 and 9004(b); Official Form 416 layout.
local function caption(m)
  local out = {}
  for _, l in ipairs(m.court or {}) do
    out[#out + 1] = para("Centered", str(l), { bold = true })
  end
  out[#out + 1] = para("Single", "")

  local debtor, debtor_xml = {}, ""
  for _, l in ipairs(m.debtor or {}) do debtor[#debtor + 1] = px("Cell", str(l)) end
  debtor_xml = table.concat(debtor)
  out[#out + 1] = pandoc.RawBlock("openxml", table_xml({ 4680, 4680 }, {
    { { xml = debtor_xml }, { xml = px("Cell", str(m.case_number), { jc = "right" }) } },
  }))
  out[#out + 1] = para("Single", "")

  local parties = {}
  for _, p in ipairs(m.parties or {}) do
    parties[#parties + 1] = px("Cell", str(p.names))
    parties[#parties + 1] = px("Cell", str(p.role))
    parties[#parties + 1] = px("Single", "")
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local inset = '<w:tcMar><w:right w:w="173" w:type="dxa"/><w:bottom w:w="173" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = pandoc.RawBlock("openxml", table_xml({ 4896, 360, 4104 }, {
    {
      { xml = table.concat(parties), tcpr = rule .. inset },
      { xml = px("Cell", "") },
      { xml = px("Cell", str(m.adv_number)), tcpr = '<w:vAlign w:val="center"/>' },
    },
  }))
  out[#out + 1] = para("Single", "")
  out[#out + 1] = para("Centered", str(m.title), { bold = true })
  out[#out + 1] = para("Single", "")
  return out
end

-- Signature block (NM LBR 9011-1(a): name, address, telephone and e-mail below the signature line).
local function signature(s)
  local out = {}
  out[#out + 1] = para("Signature", "Respectfully Submitted,", { keep = true })
  out[#out + 1] = para("Single", "", { keep = true })
  out[#out + 1] = para("Signature", str(s.firm), { keep = true, bold = true })
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="Signature"/><w:keepNext/>'
    .. '<w:tabs><w:tab w:val="left" w:leader="underscore" w:pos="8424"/></w:tabs></w:pPr>'
    .. '<w:r><w:t xml:space="preserve">By: </w:t></w:r><w:r><w:tab/></w:r></w:p>')
  out[#out + 1] = para("Single", "", { keep = true })
  out[#out + 1] = para("Signature", str(s.signer), { keep = true })
  for _, l in ipairs(s.lines or {}) do
    out[#out + 1] = para("Signature", str(l), { keep = true })
  end
  out[#out + 1] = para("Signature", str(s.email), { keep = true })
  out[#out + 1] = para("Signature", str(s.role))
  return out
end

-- Footnote markers "[^n]" left in text by pandoc become real footnotes from the frontmatter map.
local function note_strs(notes)
  return function(el)
    local s = el.text
    if not s:find("%[%^%d+%]") then return nil end
    local out, pos = {}, 1
    while true do
      local a, b, n = s:find("%[%^(%d+)%]", pos)
      if not a then break end
      if a > pos then out[#out + 1] = pandoc.Str(s:sub(pos, a - 1)) end
      assert(notes[n], "nmb-filter: footnote [^" .. n .. "] has no text in the frontmatter")
      out[#out + 1] = pandoc.Note(as_blocks(notes[n]))
      pos = b + 1
    end
    if pos <= #s then out[#out + 1] = pandoc.Str(s:sub(pos)) end
    return out
  end
end

local function first_inlines(block)
  if block.t == "Para" or block.t == "Plain" then return block.content end
  return nil
end

function Pandoc(doc)
  local m = doc.meta
  local notes = m.footnotes or {}
  doc = doc:walk({ Str = note_strs(notes) })

  local out = caption(m)

  if m.lead_in then
    out[#out + 1] = pandoc.Div(as_blocks(m.lead_in), { ["custom-style"] = "Indented" })
  end

  local para_no = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "OrderedList" then
      -- Top-level numbered list = numbered paragraphs. The template numbers them; typed numbers are dropped.
      for _, item in ipairs(b.content) do
        para_no = para_no + 1
        for i, sub in ipairs(item) do
          if i == 1 and first_inlines(sub) then
            local inl = { pandoc.Str(para_no .. "."), pandoc.Space() }
            for _, x in ipairs(first_inlines(sub)) do inl[#inl + 1] = x end
            out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Indented" })
          elseif sub.t == "OrderedList" then
            -- Indented list under a numbered paragraph = lettered sub-items (a), (b), ...
            for k, si in ipairs(sub.content) do
              local label = "(" .. string.char(96 + k) .. ")"
              local first = si[1] and first_inlines(si[1])
              if first then
                local inl = { pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
                for _, x in ipairs(first) do inl[#inl + 1] = x end
                out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "SubItem" })
              end
            end
          else
            out[#out + 1] = sub
          end
        end
      end
    else
      out[#out + 1] = b
    end
  end

  if m.prayer then
    out[#out + 1] = pandoc.Div(as_blocks(m.prayer), { ["custom-style"] = "Indented" })
  end

  out[#out + 1] = para("Single", "")
  for _, x in ipairs(signature(m.signature or {})) do out[#out + 1] = x end

  if m.certificate then
    out[#out + 1] = para("Single", "")
    out[#out + 1] = para("Centered", "CERTIFICATE OF SERVICE", { bold = true, keep = true })
    out[#out + 1] = pandoc.Div(as_blocks(m.certificate), { ["custom-style"] = "Indented" })
  end

  -- No metadata in the output: the title is printed in the caption, not as a Title paragraph.
  return pandoc.Pandoc(out, {})
end

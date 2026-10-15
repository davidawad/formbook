-- D. Colo. complaint, DOCX engine (docs/DOCX.md): the markdown contract of samples/INPUT-<id>.md -> Word.
-- Mirrors typst/cod-complaint.typ: court lines, "Civil Action No.", party block with "v." between sides,
-- bold centred title, lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)) with "N." at the first-line
-- indent, unnumbered paragraphs ("::" prefix), headings (level 1 and 2 centred bold, level 3 bold italic),
-- block quotations single spaced and indented one inch each side, lettered prayer items (A., B., ...),
-- and the signature block kept together on one page. Styles come from reference.docx (build-reference.sh).
-- Content-agnostic: every word comes from the sample's frontmatter or body.
-- Vertical gaps are the measured typst gaps (in twips: 40.2 pt = 516, 24 pt = 480 pitch, 9.6 pt = 192,
-- 17.7 pt = 354), not forced page breaks.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- one paragraph of plain text in a style with optional spacing (twips), bold and keep-with-next
-- o: { bold, before, after, keep, left, jc }
local function rp(style, text, o)
  o = o or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if o.keep then ppr = ppr .. "<w:keepNext/>" end
  if o.before or o.after then
    ppr = ppr .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '"/>'
  end
  if o.left then ppr = ppr .. '<w:ind w:left="' .. o.left .. '" w:firstLine="0"/>' end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  local rpr = o.bold and "<w:rPr><w:b/></w:rPr>" or ""
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr><w:r>' .. rpr
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>"
end

-- an empty paragraph of an exact height in twips
local function gap_p(twips)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function wrap(block, style)
  return pandoc.Div({ block }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- the caption (Fed. R. Civ. P. 10(a)); gaps are the measured typst gaps (see the header comment)
local function caption(meta)
  local out = {}
  local function add(x) out[#out + 1] = raw(x) end
  add(rp("Centered", "IN THE UNITED STATES DISTRICT COURT"))
  add(rp("Centered", "FOR THE DISTRICT OF COLORADO"))
  local cn = str(meta.case_number)
  if cn == "" then cn = "__________________" end
  add(rp("Single", "Civil Action No. " .. cn, { before = 516 }))
  for i, p in ipairs(meta.caption) do
    if i > 1 then add(rp("Single", "v.", { before = 354 })) end
    local first = true
    for _, n in ipairs(p.names) do
      local before = 0
      if first then before = (i == 1) and 516 or 354 end
      add(rp("Single", str(n), { before = before }))
      first = false
    end
    add(rp("Single", str(p.designation), { before = 192, left = 720 }))
  end
  add(rp("Centered", str(meta.title), { bold = true, before = 516, after = 362 }))
  return out
end

-- the signature block (LCivR 5.1; Fed. R. Civ. P. 11(a)): kept together with the last paragraph
local function signature(sig)
  local out = {}
  local function add(x) out[#out + 1] = raw(x) end
  local intro = sig.intro or {}
  for i, l in ipairs(intro) do
    add(rp("SingleKeep", str(l), { before = (i == 1) and 480 or 0 }))
  end
  if sig.firm then add(rp("SingleKeep", str(sig.firm), { before = 156 })) end
  for _, s in ipairs(sig.signers or {}) do
    local sig_line = s.sig_line and str(s.sig_line) or ("s/ " .. str(s.name))
    add(rp("SingleKeep", sig_line, { before = 480 }))
    add(rp("SingleKeep", str(s.name)))
    for _, l in ipairs(s.lines or {}) do add(rp("SingleKeep", str(l))) end
  end
  if sig.role then add(rp("Single", str(sig.role), { before = 480 })) end
  return out
end

local function is_unnumbered(b)
  return b.t == "Para" and b.content[1] ~= nil and b.content[1].t == "Str" and b.content[1].text:match("^::")
end

-- "::" marks an unnumbered paragraph: drop the marker and the space that follows it
local function strip_marker(b)
  local first = b.content[1]
  first.text = first.text:gsub("^::%s*", "")
  if first.text == "" then table.remove(b.content, 1) end
  return b
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  for _, b in ipairs(caption(meta)) do add(b) end

  if meta.lead_in then add(pandoc.Para({ pandoc.Str(str(meta.lead_in)) })) end

  local count = 0
  local blocks = doc.blocks
  for _, b in ipairs(blocks) do
    if b.t == "Para" and is_unnumbered(b) then
      add(strip_marker(b))
    elseif b.t == "Para" then
      count = count + 1
      local content = { pandoc.Str(count .. ".\u{2002}") }
      for _, x in ipairs(b.content) do content[#content + 1] = x end
      add(pandoc.Para(content))
    elseif b.t == "OrderedList" then
      -- markdown "1. text" items: the prayer for relief, lettered A., B., ... by the template
      for j, item in ipairs(b.content) do
        local first = item[1]
        local content = { pandoc.Str(string.char(64 + j) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        if first and (first.t == "Para" or first.t == "Plain") then
          for _, x in ipairs(first.content) do content[#content + 1] = x end
        end
        add(wrap(pandoc.Para(content), "Lettered"))
      end
    else
      add(b)
    end
  end

  -- a paragraph that ends a block before a heading carries the heading gap (the heading has none above it, so
  -- no gap is lost at the top of a page); the same 6.5 pt as typst's block spacing
  for i, b in ipairs(out) do
    if b.t == "Para" and out[i + 1] and out[i + 1].t == "Header" then out[i] = wrap(b, "Body Before Heading") end
  end

  for _, b in ipairs(signature(meta.signature or {})) do add(b) end

  doc.meta.title = nil
  doc.meta.caption = nil
  doc.meta.case_number = nil
  doc.meta.lead_in = nil
  doc.meta.signature = nil
  doc.blocks = out
  return doc
end

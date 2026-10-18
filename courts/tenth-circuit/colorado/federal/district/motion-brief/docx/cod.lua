-- D. Colo. motion to dismiss with its memorandum, DOCX engine (docs/DOCX.md): the markdown contract of
-- usage/INPUT-<id>.md -> Word. Mirrors typst/cod-motion-brief.typ: court lines, "Civil Action No.", party
-- block with "v." between sides, bold centred title, lead-in, optional certificate of compliance, the body
-- (sections numbered by the template: I. centred caps; A., 1., a. with a hanging number; body paragraphs
-- double spaced with a first-line indent; block quotations single spaced, indented one inch each side;
-- footnotes single spaced at 12 pt), the signature block, and the certificate of service. Styles come from
-- reference.docx (build-reference.sh). Content-agnostic: every word comes from the sample's frontmatter or body.
-- Vertical gaps are the measured typst gaps (twips: 40.2 pt = 516, 24 pt pitch = 480, 9.6 pt = 192,
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

-- a metadata value (markdown inlines, or blocks) as a block
local function meta_para(v)
  if v.t == "MetaInlines" then return pandoc.Para(v) end
  return pandoc.Para({ pandoc.Str(str(v)) })
end

-- one paragraph of plain text in a style with optional spacing (twips), bold and keep-with-next
-- o: { bold, before, after, keep, left, firstline, jc }
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

local function wrap(block, style)
  return pandoc.Div({ block }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- the caption (Fed. R. Civ. P. 10(a)); the same measured gaps as the complaint
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
  add(rp("Centered", str(meta.title), { bold = true, before = 516, after = 516 }))
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
  for _, s in ipairs(sig.signers or {}) do
    local sig_line = s.sig_line and str(s.sig_line) or ("s/ " .. str(s.name))
    add(rp("SingleKeep", sig_line, { before = 480 }))
    add(rp("SingleKeep", str(s.name)))
    for _, l in ipairs(s.lines or {}) do add(rp("SingleKeep", str(l))) end
  end
  if sig.role then add(rp("Single", str(sig.role), { before = 480 })) end
  return out
end

-- Section numbers, as typst: level 1 "I.", level 2 "A.", level 3 "1.", level 4 "a."
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX" }
local SEC_MARKS = {
  function(n) return (ROMAN[n] or tostring(n)) .. "." end,
  function(n) return string.char(64 + n) .. "." end,
  function(n) return tostring(n) .. "." end,
  function(n) return string.char(96 + n) .. "." end,
}

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  for _, b in ipairs(caption(meta)) do add(b) end

  if meta.lead_in then add(meta_para(meta.lead_in)) end

  if meta.conferral then
    add(raw(rp("Centered", str(meta.conferral_heading or "CERTIFICATE OF COMPLIANCE"),
      { bold = true, before = 480, after = 480 })))
    add(pandoc.Div({ meta_para(meta.conferral) }, pandoc.Attr("", {}, { ["custom-style"] = "Body Flush" })))
  end

  -- sections: number the headings; a level resets the deeper counters
  local sec = { 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lvl = math.min(b.level, 4)
      sec[lvl] = sec[lvl] + 1
      for k = lvl + 1, 4 do sec[k] = 0 end
      local mark = SEC_MARKS[lvl](sec[lvl])
      local content = { pandoc.Str(mark) }
      if lvl == 1 then
        content[#content + 1] = pandoc.Space()
      else
        content[#content + 1] = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
      end
      for _, x in ipairs(b.content) do content[#content + 1] = x end
      add(pandoc.Header(b.level, content))
    else
      add(b)
    end
  end

  -- a paragraph that ends a block before a heading carries the heading gap (headings have none above them,
  -- so no gap is lost at the top of a page); the same 6.5 pt as typst's block spacing
  for i, b in ipairs(out) do
    local before_heading = out[i + 1] and out[i + 1].t == "Header"
    if b.t == "Para" and before_heading then out[i] = wrap(b, "Body Before Heading") end
    if b.t == "Div" and before_heading and b.attr.attributes["custom-style"] == "Body Flush" then
      b.attr.attributes["custom-style"] = "Body Flush Before Heading"
    end
  end

  for _, b in ipairs(signature(meta.signature or {})) do add(b) end

  -- certificate of service (Fed. R. Civ. P. 5(b)): heading, text, the party block, the signer line
  if meta.service then
    local s = meta.service
    add(raw(rp("Centered", str(s.heading or "CERTIFICATE OF SERVICE"), { bold = true, before = 480, after = 480 })))
    add(pandoc.Div({ pandoc.Para({ pandoc.Str(str(s.text)) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Body Flush" })))
    for i, l in ipairs(s.party_lines or {}) do
      add(raw(rp("Single", str(l), { left = 720, before = (i == 1) and 240 or 0 })))
    end
    for i, l in ipairs(s.signer_lines or {}) do
      add(raw(rp("Single", str(l), { before = (i == 1) and 480 or 0 })))
    end
  end

  doc.meta.title = nil
  doc.meta.caption = nil
  doc.meta.case_number = nil
  doc.meta.lead_in = nil
  doc.meta.conferral = nil
  doc.meta.conferral_heading = nil
  doc.meta.signature = nil
  doc.meta.service = nil
  doc.blocks = out
  return doc
end

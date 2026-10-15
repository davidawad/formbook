-- ncmb-motion-brief.lua (docx engine). Builds what pandoc does not write for the typst template
-- (../typst/ncmb-motion-brief.typ), from the frontmatter of the sample, so no case text is in this file:
--   * the caption page: court lines, the caption (a table: parties, a ")" column, case numbers, closed by a rule),
--     the title; the body starts on the same page (no cover page);
--   * heading labels: level 2 "I.", level 3 "A.", level 4 "1.", level 5 "a." (level 1 is unnumbered), typed before
--     the heading text with a tab, so the label hangs as in the typst template;
--   * the numbered lists "1.", "2." (label at 0.5 in, text at 1.125 in);
--   * the signature block (kept together, at 3.25 in), and the certificate of service on a new page.
-- Footnotes are pandoc's native footnotes ([^n] with a definition in the body). The styles named here
-- ("NCMB ...") and the heading styles are defined in docx/make-reference.sh.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function text(v)
  return pandoc.utils.stringify(v)
end

local function inlines(v)
  if type(v) == "string" then
    return pandoc.Inlines({ pandoc.Str(v) })
  end
  local out = pandoc.Inlines({})
  for _, el in ipairs(v) do
    out:insert(el)
  end
  return out
end

local function plain(s)
  return pandoc.Inlines({ pandoc.Str(s) })
end

local function para(inl, style)
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
end

local function need(m, key)
  if m[key] == nil then
    error("ncmb-motion-brief.lua: missing required frontmatter field `" .. key .. "`")
  end
  return m[key]
end

local function is_map(v)
  return type(v) == "table" and v.t ~= nil
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- Printed label of a numbered heading (level 2 "I.", 3 "A.", 4 "1.", 5 "a."), as heading-num() in the typst template.
local function label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return n .. "." end
  return string.char(96 + n) .. "."
end

-- Caption: a fixed-layout table, 9360 twips wide: party column 3.2 in, ")" column 0.35 in, case numbers the rest.
local W_LEFT, W_PAREN, W_RIGHT = 4608, 504, 4248
local JC = { l = "left", c = "center", r = "right" }

local function cap_cell_xml(item, style, width, jc)
  local t, a = item, "l"
  if is_map(item) then
    t = item.t
    a = item.a and text(item.a) or "l"
  end
  if jc then a = jc end
  local ppr = '<w:pPr><w:pStyle w:val="' .. style .. '"/><w:jc w:val="' .. JC[a] .. '"/></w:pPr>'
  local s = esc(text(t))
  local run = s ~= "" and ('<w:r><w:t xml:space="preserve">' .. s .. '</w:t></w:r>') or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr><w:p>' .. ppr .. run .. '</w:p></w:tc>'
end

local function caption_table(m)
  local cap = need(m, "caption")
  local left = need(cap, "left")
  local right = cap.right or {}
  local n = math.max(#left, #right)
  local rows = {}
  for i = 1, n do
    rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="320" w:hRule="atLeast"/></w:trPr>'
      .. cap_cell_xml(left[i] or "", "NCMBCaption", W_LEFT)
      .. cap_cell_xml(")", "NCMBCaption", W_PAREN, "c")
      .. cap_cell_xml(right[i] or "", "NCMBCaptionRight", W_RIGHT)
      .. '</w:tr>'
  end
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. W_LEFT .. '"/><w:gridCol w:w="' .. W_PAREN .. '"/><w:gridCol w:w="' .. W_RIGHT .. '"/></w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
  return pandoc.RawBlock("openxml", tbl)
end

-- Signature block (LR 9011-4), in the order of the typst template: dated; "/s/" and each signer (name, bar,
-- email); the firm; the address; the telephone; the role. Each line's gap is the style's space before.
local function signature(out, S)
  out[#out + 1] = para(inlines(S.dated), "NCMB Sig Left First")
  out[#out + 1] = para(plain("/s/ " .. text(S.signed_by)), "NCMB Sig Right Gap")
  for _, s in ipairs(S.signers) do
    out[#out + 1] = para(plain(text(s.name)), "NCMB Sig Right Gap")
    out[#out + 1] = para(plain("N.C. State Bar No. " .. text(s.bar)), "NCMB Sig Right")
    out[#out + 1] = para(plain("Email: " .. text(s.email)), "NCMB Sig Right")
  end
  for i, v in ipairs(S.firm) do
    out[#out + 1] = para(inlines(v), i == 1 and "NCMB Sig Right Gap" or "NCMB Sig Right")
  end
  for i, v in ipairs(S.address) do
    out[#out + 1] = para(inlines(v), i == 1 and "NCMB Sig Right Small" or "NCMB Sig Right")
  end
  out[#out + 1] = para(plain("Telephone: " .. text(S.phone)), "NCMB Sig Right Small")
  for i, v in ipairs(S.role) do
    out[#out + 1] = para(inlines(v), i == 1 and "NCMB Sig Right Gap" or "NCMB Sig Right")
  end
end

-- Certificate of service (LR 9004-1): on a new page; the statement; each recipient's lines and the method (italic);
-- the date and the /s/ of the person who served.
local function certificate(out, m)
  local svc = m.service
  local S = need(m, "signature")
  out[#out + 1] = para(plain("CERTIFICATE OF SERVICE"), "NCMB Cert Head")
  out[#out + 1] = para(inlines(need(svc, "statement")), "NCMB Cert Statement")
  for _, r in ipairs(need(svc, "recipients")) do
    local c = pandoc.Inlines({})
    for i, v in ipairs(need(r, "lines")) do
      if i > 1 then c:insert(pandoc.LineBreak()) end
      for _, x in ipairs(inlines(v)) do c:insert(x) end
    end
    out[#out + 1] = para(c, "NCMB Recipient")
    out[#out + 1] = para(pandoc.Inlines({ pandoc.Emph(inlines(need(r, "method"))) }), "NCMB Recipient Method")
  end
  local dated = svc.dated or S.dated
  out[#out + 1] = para(inlines(dated), "NCMB Sig Left First")
  out[#out + 1] = para(plain("/s/ " .. text(S.signed_by)), "NCMB Sig Right Gap")
end

-- Heading labels: counters per level, reset below a higher heading (level 1 is not numbered).
local function number_headings(blocks)
  local counts = { 0, 0, 0, 0, 0, 0 }
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level > 5 then
        error("ncmb-motion-brief.lua: headings deeper than level 5 are not supported")
      end
      if b.level == 1 then
        out[#out + 1] = b
      else
        counts[b.level] = counts[b.level] + 1
        for k = b.level + 1, 6 do counts[k] = 0 end
        local c = pandoc.Inlines({ pandoc.Str(label(b.level, counts[b.level])), TAB })
        for _, x in ipairs(b.content) do c:insert(x) end
        out[#out + 1] = pandoc.Header(b.level, c, b.attr)
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local m = doc.meta
  for _, k in ipairs({ "court", "caption", "title", "signature" }) do
    need(m, k)
  end
  local out = {}

  -- Caption page
  local courts = m.court
  for i, line in ipairs(courts) do
    out[#out + 1] = para(inlines(line), i == #courts and "NCMB Court Last" or "NCMB Court")
  end
  out[#out + 1] = caption_table(m)
  out[#out + 1] = para(inlines(m.title), "NCMB Title")

  -- Body: headings numbered, lists lettered as the typst "1." lists (numbered 1., 2., ...)
  local blocks = number_headings(doc.blocks)
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        local c = pandoc.Inlines({ pandoc.Str(tostring(j) .. "."), TAB })
        for _, x in ipairs(item[1].content) do c:insert(x) end
        out[#out + 1] = para(c, "NCMB List")
        for k = 2, #item do out[#out + 1] = item[k] end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        out[#out + 1] = para(item[1].content, "NCMB Sub")
        for k = 2, #item do out[#out + 1] = item[k] end
      end
    else
      out[#out + 1] = b
    end
  end

  signature(out, m.signature)
  if m.service ~= nil then
    certificate(out, m)
  end

  m.title = nil
  return pandoc.Pandoc(out, m)
end

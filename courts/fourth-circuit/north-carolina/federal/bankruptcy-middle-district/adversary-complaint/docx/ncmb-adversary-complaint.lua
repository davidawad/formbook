-- ncmb-adversary-complaint.lua (docx engine). Builds what pandoc does not write for the typst template
-- (../typst/ncmb-adversary-complaint.typ), from the frontmatter of the sample, so no case text is in this file:
--   * the cover: court lines, the caption (a table: parties, a ")" column, case numbers, closed by a rule), the title;
--   * the lead-in, and the body: numbered paragraphs (1, 2, ...; a WHEREFORE chunk is not numbered), headings
--     (pandoc's Heading 1 and 2, styled in reference.docx), the prayer lettered A., B., ..., the unnumbered
--     sub-items of a bulleted list, block quotations;
--   * footnotes: a [^n] marker becomes a native Word footnote whose text is footnotes.n in the frontmatter;
--   * the signature block (kept together, at 3.25 in).
-- The styles named here ("NCMB ...") are defined in docx/make-reference.sh.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return string.lower(out)
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function text(v)
  return pandoc.utils.stringify(v)
end

-- A frontmatter value (markdown inlines) as an Inlines list.
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
    error("ncmb-adversary-complaint.lua: missing required frontmatter field `" .. key .. "`")
  end
  return m[key]
end

local function is_map(v)
  return type(v) == "table" and v.t ~= nil
end

-- Footnote markers: pandoc leaves "[^n]" as text when its definition is not in the body, so split the Str.
local function expand(inls, notes)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inls) do
    if el.t == "Str" and el.text:find("%[%^%d+%]") then
      local s = el.text
      local pos = 1
      while true do
        local a, b, k = s:find("%[%^(%d+)%]", pos)
        if not a then break end
        if a > pos then out:insert(pandoc.Str(s:sub(pos, a - 1))) end
        local note = notes[k]
        if note == nil then
          error("ncmb-adversary-complaint.lua: footnote [^" .. k .. "] has no text under `footnotes:`")
        end
        out:insert(pandoc.Note({ pandoc.Para(inlines(note)) }))
        pos = b + 1
      end
      if pos <= #s then out:insert(pandoc.Str(s:sub(pos))) end
    else
      out:insert(el)
    end
  end
  return out
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
    local l = left[i] or ""
    local r = right[i] or ""
    rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="320" w:hRule="atLeast"/></w:trPr>'
      .. cap_cell_xml(l, "NCMBCaption", W_LEFT)
      .. cap_cell_xml(")", "NCMBCaption", W_PAREN, "c")
      .. cap_cell_xml(r, "NCMBCaptionRight", W_RIGHT)
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

function Pandoc(doc)
  local m = doc.meta
  for _, k in ipairs({ "court", "caption", "title", "lead_in", "signature", "footnotes" }) do
    need(m, k)
  end
  local notes = m.footnotes
  local out = {}

  -- Cover
  local courts = m.court
  for i, line in ipairs(courts) do
    out[#out + 1] = para(inlines(line), i == #courts and "NCMB Court Last" or "NCMB Court")
  end
  out[#out + 1] = caption_table(m)
  out[#out + 1] = para(inlines(m.title), "NCMB Title")

  -- Lead-in (unnumbered) and body
  out[#out + 1] = para(expand(inlines(m.lead_in), notes), "NCMB Body")
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" then
      if text(b):match("^WHEREFORE") then
        out[#out + 1] = para(expand(b.content, notes), "NCMB Body")
      else
        n = n + 1
        local c = pandoc.Inlines({ pandoc.Str(tostring(n) .. "."), TAB })
        for _, x in ipairs(expand(b.content, notes)) do c:insert(x) end
        out[#out + 1] = para(c, "NCMB Numbered")
      end
    elseif b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        local c = pandoc.Inlines({ pandoc.Str(string.char(64 + j) .. "."), TAB })
        for _, x in ipairs(expand(item[1].content, notes)) do c:insert(x) end
        out[#out + 1] = para(c, "NCMB Prayer")
        for k = 2, #item do out[#out + 1] = item[k] end
      end
    elseif b.t == "BulletList" then
      -- A "- (i) text" item is parsed by pandoc as a one-item roman list inside the bullet; the marker is written
      -- back as text, as the typst template prints it (no bullet, the (i) label kept).
      for _, item in ipairs(b.content) do
        if item[1].t == "OrderedList" then
          -- each "- (i)" item is its own one-item list whose start number is the roman numeral.
          local start = item[1].listAttributes.start
          for k, sub in ipairs(item[1].content) do
            local c = pandoc.Inlines({ pandoc.Str("(" .. roman(start + k - 1) .. ")"), pandoc.Space() })
            for _, x in ipairs(expand(sub[1].content, notes)) do c:insert(x) end
            out[#out + 1] = para(c, "NCMB Sub")
          end
        else
          out[#out + 1] = para(expand(item[1].content, notes), "NCMB Sub")
        end
      end
    elseif b.t == "BlockQuote" then
      for _, p in ipairs(b.content) do
        out[#out + 1] = pandoc.Div({ pandoc.Para(expand(p.content, notes)) }, { ["custom-style"] = "Block Text" })
      end
    else
      out[#out + 1] = b
    end
  end

  -- Signature block (LR 9011-4): kept together; 3.25 in from the left margin.
  local S = need(m, "signature")
  out[#out + 1] = para(inlines(S.dated), "NCMB Sig Left First")
  for i, v in ipairs(S.firm) do
    out[#out + 1] = para(inlines(v), i == 1 and "NCMB Sig Right Gap" or "NCMB Sig Right")
  end
  out[#out + 1] = para(plain("/s/ " .. text(S.signed_by)), "NCMB Sig Right Gap")
  for _, s in ipairs(S.signers) do
    out[#out + 1] = para(plain(text(s.name)), "NCMB Sig Right Gap")
    out[#out + 1] = para(plain("N.C. State Bar No. " .. text(s.bar)), "NCMB Sig Right")
    out[#out + 1] = para(plain("Email: " .. text(s.email)), "NCMB Sig Right")
  end
  for i, v in ipairs(S.address) do
    out[#out + 1] = para(inlines(v), i == 1 and "NCMB Sig Right Gap" or "NCMB Sig Right")
  end
  out[#out + 1] = para(plain("Telephone: " .. text(S.phone)), "NCMB Sig Right")
  for _, v in ipairs(S.role) do
    out[#out + 1] = para(inlines(v), "NCMB Sig Right")
  end

  -- The title is printed by the cover above; pandoc must not write its own Title paragraph from the metadata.
  m.title = nil
  return pandoc.Pandoc(out, m)
end

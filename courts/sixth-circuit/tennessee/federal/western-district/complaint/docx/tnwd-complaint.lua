-- W.D. Tenn. complaint, DOCX engine (docs/DOCX.md): the markdown contract of usage/INPUT-<id>.md -> Word.
-- Mirrors typst/tnwd-complaint.typ: court title (single), caption (parties with a rule at the right of the
-- party column, case number and JURY DEMAND opposite), the title, numbered allegations after the first heading
-- (the number at 1/2 inch, the text at the tab after it), lead-in paragraphs unnumbered, a lettered prayer list,
-- the signature block (kept together) and one verification per party (unnumbered, with a signature rule).
-- Styles come from reference.docx (build-reference.sh). Content-agnostic: every word comes from the frontmatter.
-- Known differences from the typst output: the caption's ")" column is a cell rule (Word-native), and the
-- verification rule is a paragraph border; both are set by the same measures.

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

-- a run of text, bold or not
local function run(text, bold)
  return "<w:r>" .. (bold and "<w:rPr><w:b/></w:rPr>" or "") .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- a paragraph: style, runs, and direct paragraph properties in schema order (keepNext, pBdr, spacing, ind, jc)
local function P(style, body, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (body or "") .. "</w:p>"
end

-- an exact-height empty line (the typst v() gaps); keep = keep with the next paragraph
local function gap(twips, keep)
  return P("Single", "", (keep and "<w:keepNext/>" or "")
    .. '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/>')
end

local function line(text, ppr, bold, keep)
  return P("Single", run(text, bold), (keep and "<w:keepNext/>" or "") .. (ppr or ""))
end

local function ind(left, right)
  return '<w:ind w:left="' .. left .. '" w:right="' .. (right or 0) .. '" w:firstLine="0"/>'
end

local function tc(width, paras, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. (mar or "")
    .. "</w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

-- a borderless fixed-width table, one row; the row never splits across pages
local function tbl(widths, cells)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid)
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

-- the caption: parties (3.3 in) | gap (0.4 in) | case number and legend (2.8 in); a rule at the right of the party column
local function caption(meta)
  local left = {}
  for idx, side in ipairs(meta.caption) do
    if idx > 1 then
      left[#left + 1] = gap(276)
      left[#left + 1] = line("v.")
      left[#left + 1] = gap(276)
    end
    for _, n in ipairs(side.names) do left[#left + 1] = line(str(n)) end
    left[#left + 1] = line(str(side.designation), ind(1800))
  end
  local cn = str(meta.case_number)
  local right = { gap(552) }
  if cn ~= "" then
    right[#right + 1] = line("Case No. " .. cn)
  else
    right[#right + 1] = P("Single", run("Case No.") .. "<w:r><w:tab/></w:r>", '<w:tabs><w:tab w:val="left" w:leader="underscore" w:pos="2304"/></w:tabs>')
  end
  if meta.jury_demand == true then
    right[#right + 1] = gap(828)
    right[#right + 1] = line("JURY DEMAND")
  end
  return raw(tbl({ 4752, 432, 4176 }, {
    tc(4752, left),
    tc(432, { line("") }, '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'),
    tc(4176, right, nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'),
  }))
end

-- the signature block (LR 11.1(b)): "Dated:" at the left, the rest in the right half (3.25 in); one unbreakable run
local function signature(meta)
  local sig = meta.signature
  local out = { gap(380, true) }
  if meta.date then
    out[#out + 1] = line("Dated: " .. str(meta.date), nil, false, true)
    out[#out + 1] = gap(828, true)
  else
    out[#out + 1] = gap(947, true)
  end
  local right = ind(4680)
  out[#out + 1] = line("Respectfully submitted,", right, false, true)
  out[#out + 1] = gap(828, true)
  if sig.firm then out[#out + 1] = line(str(sig.firm), right, false, true) end
  out[#out + 1] = gap(552, true)
  out[#out + 1] = line("s/ " .. str(sig.signer), right, false, true)
  out[#out + 1] = line("Attorney Bar No. " .. str(sig.bar_number), right, false, true)
  for i, l in ipairs(sig.lines) do
    out[#out + 1] = line(str(l), right, false, i < #sig.lines)
  end
  return out
end

-- a verification (28 U.S.C. 1746): unnumbered, single spaced, with a signature rule and the name
local function verifications(list)
  local out = {}
  for _, v in ipairs(list) do
    out[#out + 1] = P("Centered", run("VERIFICATION", true), '<w:keepNext/><w:spacing w:before="434" w:after="0" w:line="276" w:lineRule="exact"/>')
    out[#out + 1] = gap(828, true)
    out[#out + 1] = P("Single", run("I, " .. str(v.name) .. ", declare under penalty of perjury that the foregoing is true and correct."),
      '<w:keepNext/><w:spacing w:before="0" w:after="395" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="720"/>')
    out[#out + 1] = gap(808, true)
    out[#out + 1] = P("Single", "", '<w:keepNext/><w:pBdr><w:top w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>'
      .. '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>' .. ind(4680, 720))
    out[#out + 1] = line(str(v.name), ind(4680), false, true)
    if v.executed then out[#out + 1] = line("Executed on: " .. str(v.executed), ind(4680)) end
  end
  return out
end

local function wrap(block, style)
  return pandoc.Div({ block }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- the body paragraph is numbered (after the first heading) unless it starts with "[unnumbered]"
local function strip_unnumbered(para)
  local c = para.content
  if c[1] and c[1].t == "Str" and c[1].text == "[unnumbered]" then
    table.remove(c, 1)
    if c[1] and c[1].t == "Space" then table.remove(c, 1) end
    return true
  end
  return false
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- the court title (single spaced, centred), then the caption, the title of the paper
  add(raw(line("IN THE UNITED STATES DISTRICT COURT", '<w:jc w:val="center"/>')))
  add(raw(line("FOR THE WESTERN DISTRICT OF TENNESSEE", '<w:jc w:val="center"/>')))
  if meta.court_division and str(meta.court_division) ~= "" then
    add(raw(line(str(meta.court_division), '<w:jc w:val="center"/>')))
  end
  add(raw(gap(828)))
  add(caption(meta))
  add(raw(gap(728)))
  add(raw(P("Single", run(str(meta.title), true), '<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:jc w:val="center"/>')))
  add(raw(gap(552)))

  -- the body: numbered allegations after the first heading; lettered prayer items; quotations single spaced
  local numbered = false
  local count = 0
  local last = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      numbered = true
      add(b)
    elseif b.t == "Para" then
      local unnum = strip_unnumbered(b)
      if numbered and not unnum then
        count = count + 1
        local digits = #tostring(count)
        local style = digits >= 3 and "Allegation 3" or (digits == 2 and "Allegation 2" or "Allegation")
        local c = { pandoc.Str(count .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        for _, x in ipairs(b.content) do c[#c + 1] = x end
        add(wrap(pandoc.Para(c), style))
      else
        add(wrap(b, i == last and "Body End" or "Body Text"))
      end
    elseif b.t == "BlockQuote" then
      add(wrap(b, "Block Text"))
    elseif b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        local first = item[1]
        local c = { pandoc.Str("(" .. string.char(96 + j) .. ")"), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        if first and (first.t == "Para" or first.t == "Plain") then
          for _, x in ipairs(first.content) do c[#c + 1] = x end
        end
        add(wrap(pandoc.Para(c), "Lettered"))
      end
    else
      add(b)
    end
  end

  -- the signature block, the verifications
  for _, r in ipairs(signature(meta)) do add(raw(r)) end
  if meta.verifications then
    for _, r in ipairs(verifications(meta.verifications)) do add(raw(r)) end
  end

  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end

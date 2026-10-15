-- ncwb.lua (docx engine, W.D.N.C. bankruptcy court). Builds, as WordprocessingML (raw openxml), the parts of
-- typst/ncwb-*.typ that pandoc cannot write from markdown, with the same layout:
--   * the court title (three bold lines), the caption (debtor box, then the adversary box, each with its
--     right rule and bottom rule), the title of the paper;
--   * the signature block after the body (Dated: on the left, the lines on the right);
--   * for a motion: the signature after the memorandum, then the notice of hearing on a new page with the
--     caption repeated, then the notice's own signature, then the certificate of service if the frontmatter
--     has a `service` block.
-- Every case word comes from the sample's frontmatter (the YAML block of the sample), never from this file.
-- Body text, headings and quotations come from pandoc through the styles of reference.docx (make-reference.sh).

local GAP = 320          -- the "double" gap between blocks (typst: 1.35 em, about 16 pt)
local CAP_LEFT = 5184    -- caption-left: 3.6 in
local CAP_RIGHT = 4176   -- the rest of 6.5 in
local SIG_TAB = 4032     -- signature lines start 2.8 in in (the 2.6 in date column and a 0.2 in gutter)

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  s = s:gsub('"', "&quot;")
  return s
end

local function S(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

local function L(x)
  local out = {}
  if x ~= nil then
    for _, v in ipairs(x) do out[#out + 1] = S(v) end
  end
  return out
end

local function upper(s)
  return string.upper(s)
end

-- Text runs. A tab in the text becomes a w:tab element (a literal tab character in w:t is not a tab in Word).
local function run(text, o)
  local rpr = ""
  if o.b then rpr = rpr .. "<w:b/><w:bCs/>" end
  if o.i then rpr = rpr .. "<w:i/><w:iCs/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  local xs = {}
  local first = true
  for seg in (text .. "\t"):gmatch("(.-)\t") do
    if not first then xs[#xs + 1] = '<w:r>' .. rpr .. '<w:tab/></w:r>' end
    first = false
    if seg ~= "" then xs[#xs + 1] = '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(seg) .. '</w:t></w:r>' end
  end
  return table.concat(xs)
end

-- One paragraph. o: style, b (bold), i (italic), jc, ind (raw w:ind), line (exact twips), before, after,
-- pagebreak (start on a new page), keep (keep with next).
local function P(text, o)
  o = o or {}
  local ppr = {}
  if o.style then ppr[#ppr + 1] = '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep then ppr[#ppr + 1] = '<w:keepNext/><w:keepLines/>' end
  if o.pagebreak then ppr[#ppr + 1] = '<w:pageBreakBefore/>' end
  if o.tabs then ppr[#ppr + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tabs .. '"/></w:tabs>' end
  if o.line or o.before or o.after then
    ppr[#ppr + 1] = string.format('<w:spacing w:before="%d" w:after="%d"%s/>', o.before or 0, o.after or 0,
      o.line and string.format(' w:line="%d" w:lineRule="exact"', o.line) or "")
  end
  if o.ind then ppr[#ppr + 1] = o.ind end
  if o.jc then ppr[#ppr + 1] = '<w:jc w:val="' .. o.jc .. '"/>' end
  local body = ""
  if text ~= "" then body = run(text, o) end
  return '<w:p><w:pPr>' .. table.concat(ppr) .. '</w:pPr>' .. body .. '</w:p>'
end

-- An empty paragraph of `twips` exact height: the "double" gap between blocks, or a blank line.
local function spacer(twips, keep)
  return P("", { style = "Single", line = twips, keep = keep })
end

-- A list of single-spaced lines; "" is a blank line.
local function lines(items, o)
  local xs = {}
  for _, t in ipairs(items) do
    xs[#xs + 1] = P(t, { style = "Single", b = o and o.b, jc = o and o.jc, ind = o and o.ind })
  end
  return table.concat(xs)
end

local function cell(w, content, borders, mar)
  local pr = string.format('<w:tcW w:w="%d" w:type="dxa"/>', w)
  if borders then pr = pr .. '<w:tcBorders>' .. borders .. '</w:tcBorders>' end
  if mar then pr = pr .. '<w:tcMar>' .. mar .. '</w:tcMar>' end
  return '<w:tc><w:tcPr>' .. pr .. '</w:tcPr>' .. content .. '</w:tc>'
end

-- A borderless one-row table with fixed column widths (twips).
local function row_table(widths, cells, may_split)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = string.format('<w:gridCol w:w="%d"/>', w)
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
    .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr>' .. (may_split and '' or '<w:trPr><w:cantSplit/></w:trPr>') .. table.concat(cells) .. '</w:tr></w:tbl>'
end

local RULE_BOTTOM_RIGHT = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
local MAR_LEFT_BOX = '<w:bottom w:w="173" w:type="dxa"/><w:right w:w="173" w:type="dxa"/>'
local MAR_RIGHT_BOX = '<w:left w:w="288" w:type="dxa"/><w:bottom w:w="173" w:type="dxa"/>'

-- Party rows of the adversary box: names, designation, "v." between parties (typst parties-rows).
local function parties_rows(parties)
  local rows = {}
  for k, p in ipairs(parties) do
    if k > 1 then
      rows[#rows + 1] = "v."
      rows[#rows + 1] = ""
    end
    for _, n in ipairs(L(p.names)) do rows[#rows + 1] = n end
    rows[#rows + 1] = S(p.designation)
  end
  return rows
end

local function caption_xml(m)
  local d = m.debtor
  local debtor_rows = { "In re:", "" }
  for _, n in ipairs(L(d.names)) do debtor_rows[#debtor_rows + 1] = n end
  debtor_rows[#debtor_rows + 1] = ""
  debtor_rows[#debtor_rows + 1] = S(d.designation)
  local t1 = row_table({ CAP_LEFT, CAP_RIGHT }, {
    cell(CAP_LEFT, lines(debtor_rows), RULE_BOTTOM_RIGHT, MAR_LEFT_BOX),
    cell(CAP_RIGHT, lines({ "Case No. " .. S(d.case_number), "", "Chapter " .. S(d.chapter) }), nil, MAR_RIGHT_BOX),
  })
  local label = S(m.adversary and m.adversary.label)
  if label == "" then label = "Adv. Proc. No." end
  local number = S(m.adversary and m.adversary.number)
  local t2 = row_table({ CAP_LEFT, CAP_RIGHT }, {
    cell(CAP_LEFT, lines(parties_rows(m.caption.parties)), RULE_BOTTOM_RIGHT, MAR_LEFT_BOX),
    cell(CAP_RIGHT, lines({ label .. " " .. number }), nil, MAR_RIGHT_BOX),
  })
  return t1 .. spacer(GAP) .. t2
end

local function court_title_xml(m, first_on_new_page)
  return P(upper(S(m.court)), { style = "Single", b = true, jc = "center", pagebreak = first_on_new_page })
    .. P(upper(S(m.district)), { style = "Single", b = true, jc = "center" })
    .. P(upper(S(m.division)), { style = "Single", b = true, jc = "center" })
end

-- Signature block (typst signature()): "Dated:" in the 2.6 in column, the signature lines from a tab stop at
-- 2.8 in. One single-spaced paragraph per line with a hanging indent, so a wrapped line aligns under the first.
-- The lines keep together and with the paragraph before (keep_last): a WHEREFORE clause and its signature
-- are not split from each other.
local function signature_xml(date, sig_lines)
  local rows = { "Dated: " .. date .. "\t" .. (sig_lines[1] or "") }
  for i = 2, #sig_lines do rows[#rows + 1] = "\t" .. sig_lines[i] end
  local xs = { spacer(GAP, true) }
  local hang = '<w:ind w:left="' .. SIG_TAB .. '" w:hanging="' .. SIG_TAB .. '"/>'
  for i, t in ipairs(rows) do
    xs[#xs + 1] = P(t, { style = "Single", keep = i < #rows, tabs = SIG_TAB, ind = hang })
  end
  return table.concat(xs)
end

-- Certificate of service (LR 9013-1(c)), typst certificate(); printed only with a `service` block.
local function certificate_xml(m)
  local s = m.service
  local x = P("CERTIFICATE OF SERVICE", { b = true, jc = "center", pagebreak = true, line = 480 })
    .. spacer(GAP)
    .. P("I certify that on " .. S(s.date) .. ", a copy of the " .. S(s.document) .. " was served by "
      .. S(s.method) .. ", on the following:", { style = "BodyText" })
  for _, p in ipairs(L(s.parties)) do
    x = x .. P(p, { style = "Single", ind = '<w:ind w:left="720"/>' })
  end
  return x .. signature_xml(S(s.date), L(s.signature))
end


-- Statute and rule quotations write their markers as text: "(a) (1) The trustee", "(A) made", "a. Was engaged".
-- pandoc reads those as ordered lists. The typst template prints the markers as written, so each list item
-- becomes a paragraph that starts with its marker (nested lists flatten the same way, and the marker of the
-- outer item joins the first line of the inner one: "(a) (1) The trustee ...").
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

local function marker(n, style, delim)
  local s
  if style == "UpperAlpha" then s = string.char(64 + n)
  elseif style == "LowerAlpha" then s = string.char(96 + n)
  elseif style == "UpperRoman" then s = roman(n)
  elseif style == "LowerRoman" then s = roman(n):lower()
  else s = tostring(n) end
  if delim == "OneParen" then return s .. ")" end
  if delim == "TwoParens" then return "(" .. s .. ")" end
  return s .. "."
end

local flatten_blocks
flatten_blocks = function(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" then
      local a = b.listAttributes
      for i, item in ipairs(b.content) do
        local label = marker((a.start or 1) + i - 1, tostring(a.style), tostring(a.delimiter))
        local inner = flatten_blocks(item)
        local first = inner[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local c = pandoc.List({ pandoc.Str(label), pandoc.Space() })
          c:extend(first.content)
          inner[1] = pandoc.Para(c)
        else
          table.insert(inner, 1, pandoc.Para({ pandoc.Str(label) }))
        end
        for _, x in ipairs(inner) do out[#out + 1] = x end
      end
    elseif b.t == "BlockQuote" then
      out[#out + 1] = pandoc.BlockQuote(flatten_blocks(b.content))
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- The last body paragraph before a signature block keeps with it, so a WHEREFORE clause does not stand alone
-- at the foot of a page above its signature.
local function keep_last(out)
  local last = out[#out]
  if last and last.t == "Para" then
    out[#out] = pandoc.Div({ last }, pandoc.Attr("", {}, { { "custom-style", "Body Text Keep" } }))
  end
end

function Pandoc(doc)
  local m = doc.meta
  local title = upper(S(m.title))
  local out = {}
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end

  -- Cover: court title, caption, title of the paper.
  raw(court_title_xml(m, false) .. spacer(GAP))
  raw(caption_xml(m) .. spacer(GAP))
  raw(P(title, { b = true, jc = "center", line = 480 }) .. spacer(GAP))

  local sig_date, sig_lines = S(m.signature and m.signature.date), L(m.signature and m.signature.lines)
  for _, b in ipairs(flatten_blocks(doc.blocks)) do
    if b.t == "Header" and b.level == 1 and S(b.content):match("^%s*NOTICE OF HEARING%s*$") then
      -- The memorandum ends here; the notice is a separate paper with its own caption and signature.
      keep_last(out)
      raw(signature_xml(sig_date, sig_lines))
      raw(court_title_xml(m, true) .. spacer(GAP) .. caption_xml(m) .. spacer(GAP)
        .. P("NOTICE OF HEARING", { b = true, jc = "center", line = 480 }) .. spacer(GAP))
    else
      out[#out + 1] = b
    end
  end
  keep_last(out)
  raw(signature_xml(sig_date, sig_lines))
  if m.service ~= nil then raw(certificate_xml(m)) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

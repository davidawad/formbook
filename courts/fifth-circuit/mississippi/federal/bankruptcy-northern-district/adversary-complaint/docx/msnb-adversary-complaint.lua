-- msnb adversary complaint: pandoc filter for the docx engine (the same content as typst/
-- msnb-adversary-complaint.typ, from the same markdown contract). Styles and page setup come from
-- reference.docx (make-reference.sh). This filter writes the counsel block, the court title, the caption, the
-- signature block and the DATED line as WordprocessingML paragraphs; numbers every allegation (a paragraph
-- outside a list, and each numbered line before the WHEREFORE lead-in) consecutively, as Fed. R. Civ. P. 10(b)
-- requires; writes each "- " item as "(a)", "(b)", ... with a hanging indent; and keeps the prayer's own
-- "1.", "2.", ... (the list after the WHEREFORE lead-in). Known gaps and the typst differences: README.md.

local PAGE_TEXT_WIDTH = 9360 -- twips: 6.5 in between the 1 in margins

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("msnb-adversary-complaint: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- One WordprocessingML paragraph. runs: a string, or a list of { s = text, b, i, u } and { tab = true }.
-- opts: jc, tab_right (a right tab stop at the right margin), after, before, line (exact, twips),
-- border_bottom (a rule under the paragraph), keep_next.
local function pxml(runs, opts)
  opts = opts or {}
  local ppr = ""
  if opts.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if opts.border_bottom then ppr = ppr .. '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>' end
  if opts.tab_right then ppr = ppr .. '<w:tabs><w:tab w:val="right" w:pos="' .. PAGE_TEXT_WIDTH .. '"/></w:tabs>' end
  ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) ..
    '" w:line="' .. (opts.line or 276) .. '" w:lineRule="exact"/>'
  if opts.ind_left then ppr = ppr .. '<w:ind w:left="' .. opts.ind_left .. '" w:firstLine="0"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  if type(runs) == "string" then runs = { { s = runs } } end
  local body = {}
  for _, r in ipairs(runs) do
    if r.tab then
      body[#body + 1] = "<w:r><w:tab/></w:r>"
    else
      local rpr = ""
      if r.b then rpr = rpr .. "<w:b/>" end
      if r.i then rpr = rpr .. "<w:i/>" end
      if r.u then rpr = rpr .. '<w:u w:val="single"/>' end
      if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
      body[#body + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(r.s) .. "</w:t></w:r>"
    end
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. table.concat(body) .. "</w:p>"
end

local function para(runs, opts)
  return raw(pxml(runs, opts))
end

local function blank(after)
  return para("", { after = after or 0 })
end

-- The counsel block: single spaced, flush left, at the top of the first page.
local function counsel_block(meta)
  local out = {}
  local counsel = meta.counsel or {}
  for _, line in ipairs(counsel) do out[#out + 1] = para(text(line)) end
  if #counsel > 0 then out[#out + 1] = blank(360) end
  return out
end

local function court_title()
  return {
    para({ { s = "UNITED STATES BANKRUPTCY COURT", b = true } }, { jc = "center" }),
    para({ { s = "NORTHERN DISTRICT OF MISSISSIPPI", b = true } }, { jc = "center", after = 240 }),
  }
end

-- A caption row, as a borderless two-column table (names left, the label right), as the typst grid sets it.
-- The left column takes what the right label leaves; a rule under the row (the debtor row) is a cell border.
local CAPTION_LEFT, CAPTION_RIGHT = 5400, 3960
local function caption_row(left_list, right_label, rule, after)
  local left = {}
  for _, n in ipairs(left_list) do left[#left + 1] = pxml({ { s = n } }, { line = 276 }) end
  local border = rule and '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' or ""
  local right = pxml({ { s = right_label } }, { jc = "right", line = 276 })
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="' .. (CAPTION_LEFT + CAPTION_RIGHT) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAPTION_LEFT .. '"/><w:gridCol w:w="' .. CAPTION_RIGHT .. '"/></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_LEFT .. '" w:type="dxa"/>' .. border .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_RIGHT .. '" w:type="dxa"/>' .. border .. '</w:tcPr>' .. right .. '</w:tc></w:tr></w:tbl>'
  local out = { raw(tbl) }
  if after and after > 0 then out[#out + 1] = blank(after) end
  return out
end

-- The caption: the debtor and the case number; a rule; the plaintiff; the adversary number; the defendants.
local function caption(meta)
  local out = {}
  local debtor = need(meta, "debtor")
  local names = {}
  for i, n in ipairs(debtor.names) do names[i] = (i == 1 and "IN RE: " or "") .. text(n) end
  for _, x in ipairs(caption_row(names, "NO. " .. text(need(meta, "case_number")), true, 240)) do out[#out + 1] = x end
  local plaintiffs = {}
  for i, n in ipairs(need(meta, "plaintiffs")) do plaintiffs[i] = text(n) end
  local plabel = (#plaintiffs > 1) and "PLAINTIFFS" or "PLAINTIFF"
  for _, x in ipairs(caption_row(plaintiffs, plabel, false, 360)) do out[#out + 1] = x end
  for _, x in ipairs(caption_row({ "VS." }, "ADVERSARY NO. " .. text(need(meta, "adv_number")), false, 360)) do out[#out + 1] = x end
  local defendants = {}
  for i, n in ipairs(need(meta, "defendants")) do defendants[i] = text(n) end
  for _, x in ipairs(caption_row(defendants, text(meta.defendants_label or "DEFENDANT"), false, 240)) do out[#out + 1] = x end
  return out
end

-- The signature: DATED (indented, as the first line of a paragraph), then the firm, the signature line and the
-- title in the right-hand column (right aligned), then the signer's counsel block flush left.
local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  if meta.dated then
    out[#out + 1] = para({ { s = "DATED: " .. text(meta.dated) } }, { ind_left = 720, before = 360, after = 240, line = 480, keep_next = true })
  end
  out[#out + 1] = para({ { s = text(sig.firm), b = true } }, { jc = "right", before = 240, keep_next = true })
  out[#out + 1] = para({ { s = "By: " }, { s = "/s/ " .. text(sig.signer), u = true } }, { jc = "right", before = 480, keep_next = true })
  out[#out + 1] = para(text(sig.title), { jc = "right" })
  local lines = sig.lines or {}
  if #lines > 0 then
    out[#out + 1] = blank(360)
    for _, l in ipairs(lines) do out[#out + 1] = para(text(l)) end
  end
  return out
end

-- A paragraph numbered by the counter (an allegation): "N." then the text, first line indented.
local count = 0
local function numbered_paragraph(inl_list)
  count = count + 1
  local content = pandoc.Inlines { pandoc.Str(count .. "."), pandoc.Space() }
  content:extend(inl_list)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Paragraph" }))
end

-- Items of a list: the first block of each item as the text of the item, the rest kept.
local function item_inlines(item)
  local first = item[1]
  if first and (first.t == "Plain" or first.t == "Para") then return first.content end
  return pandoc.Inlines {}
end

-- The prayer list (after the WHEREFORE lead-in): "1.", "2.", ... with the markdown's own numbers.
local function prayer(list)
  local out = {}
  for n, item in ipairs(list.content) do
    local label = tostring((list.start or 1) + n - 1) .. "."
    local content = pandoc.Inlines { pandoc.Str(label), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
    content:extend(item_inlines(item))
    out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered Item" }))
  end
  return out
end

-- The lettered list: "(a)", "(b)", ... with a hanging indent.
local function lettered(list)
  local letters = "abcdefghijklmnopqrstuvwxyz"
  local out = {}
  for n, item in ipairs(list.content) do
    local content = pandoc.Inlines { pandoc.Str("(" .. letters:sub(n, n) .. ")"), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
    content:extend(item_inlines(item))
    out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered Item" }))
  end
  return out
end

local function is_wherefore_list(prev)
  return prev ~= nil and prev.t == "BlockQuote"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, b in ipairs(counsel_block(meta)) do out[#out + 1] = b end
  for _, b in ipairs(court_title()) do out[#out + 1] = b end
  for _, b in ipairs(caption(meta)) do out[#out + 1] = b end
  out[#out + 1] = para({ { s = text(need(meta, "title")):upper(), b = true } }, { jc = "center", before = 120, after = 360 })

  local prev = nil
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      out[#out + 1] = numbered_paragraph(b.content)
    elseif b.t == "OrderedList" then
      if is_wherefore_list(prev) then
        for _, d in ipairs(prayer(b)) do out[#out + 1] = d end
      else
        for _, item in ipairs(b.content) do out[#out + 1] = numbered_paragraph(item_inlines(item)) end
      end
    elseif b.t == "BulletList" then
      for _, d in ipairs(lettered(b)) do out[#out + 1] = d end
    else
      out[#out + 1] = b
    end
    prev = b
  end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  doc.meta.title = nil
  doc.blocks = out
  return doc
end

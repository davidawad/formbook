-- msnb motion with memorandum brief: pandoc filter for the docx engine (the same content as typst/
-- msnb-motion-brief.typ, from the same markdown contract). Styles and page setup come from reference.docx
-- (make-reference.sh). This filter writes the caption, the signature blocks and the OF COUNSEL block as
-- WordprocessingML paragraphs, turns each numbered line into a "Numbered Paragraph" (sequential across the
-- whole document, as in the typst template) and each "- " item into a "Lettered Item" "(a)", "(b)", ...,
-- and moves the CERTIFICATE OF SERVICE to the end, after OF COUNSEL. Known gaps: docs/DOCX.md and README.md.

local PAGE_TEXT_WIDTH = 9360 -- twips: 6.5 in between the 1 in margins

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("msnb-motion-brief: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- One WordprocessingML paragraph. runs: a list of { s = text, b = bold, i = italic, u = underline } or a
-- string. opts: jc, ind_left, tab_right (a right tab stop at PAGE_TEXT_WIDTH), after, before, line (exact).
local function para(runs, opts)
  opts = opts or {}
  local ppr = ""
  if opts.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if opts.border_bottom then ppr = ppr .. '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>' end
  if opts.tab_right then ppr = ppr .. '<w:tabs><w:tab w:val="right" w:pos="' .. PAGE_TEXT_WIDTH .. '"/></w:tabs>' end
  ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) ..
    '" w:line="' .. (opts.line or 276) .. '" w:lineRule="exact"/>'
  if opts.ind_left then ppr = ppr .. '<w:ind w:left="' .. opts.ind_left .. '" w:firstLine="0"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local body = {}
  if type(runs) == "string" then runs = { { s = runs } } end
  for _, r in ipairs(runs) do
    if r.tab then
      body[#body + 1] = "<w:r><w:tab/></w:r>"
    else
      local rpr = ""
      if r.b then rpr = rpr .. "<w:b/>" end
      if r.i then rpr = rpr .. "<w:i/>" end
      if r.u then rpr = rpr .. '<w:u w:val="single"/>' end
      if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
      body[#body + 1] = '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(r.s) .. "</w:t></w:r>"
    end
  end
  return raw("<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. table.concat(body) .. "</w:p>")
end

local function blank(after)
  return para("", { after = after or 0 })
end

-- The cover: court title, caption, title of the paper.
local function cover(meta)
  -- (the counsel block is not on the cover: it follows the signature, as OF COUNSEL)
  local out = {}
  out[#out + 1] = para({ { s = "UNITED STATES BANKRUPTCY COURT", b = true } }, { jc = "center" })
  out[#out + 1] = para({ { s = "NORTHERN DISTRICT OF MISSISSIPPI", b = true } }, { jc = "center", after = 240 })
  -- the caption: a left column (names) and a right column (case number, chapter) on a right tab stop
  local debtor = need(meta, "debtor")
  out[#out + 1] = para({ { s = "IN RE:" } }, { after = 120 })
  for i, n in ipairs(debtor.names) do
    local right = (i == 1) and ("CASE NO. " .. text(need(meta, "case_number"))) or ""
    out[#out + 1] = para({ { s = text(n) }, { tab = true }, { s = right } }, { tab_right = true, after = 120 })
  end
  local role = text(debtor.role)
  local chapter = debtor.chapter and ("CHAPTER " .. text(debtor.chapter)) or ""
  out[#out + 1] = para({ { s = role }, { tab = true }, { s = chapter } }, { tab_right = true, after = 240 })
  out[#out + 1] = para({ { s = text(need(meta, "title")):upper(), b = true } }, { jc = "center", before = 120, after = 360 })
  return out
end

-- Respectfully submitted, the firm, the signature line and the title: in the right-hand column.
local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = para("Respectfully submitted,", { jc = "right", keep_next = true, before = 240 })
  out[#out + 1] = para({ { s = text(sig.firm), b = true } }, { jc = "right", keep_next = true, before = 360 })
  out[#out + 1] = para({ { s = "By: " }, { s = text(sig.signer), i = true, u = true } }, { jc = "right", keep_next = true, before = 360 })
  out[#out + 1] = para(text(sig.title), { jc = "right" })
  return out
end

-- OF COUNSEL: flush left after the signature.
local function of_counsel(meta)
  local out = {}
  local counsel = meta.counsel or {}
  if #counsel == 0 then return out end
  out[#out + 1] = para("OF COUNSEL:", { before = 360, keep_next = true })
  for _, line in ipairs(counsel) do out[#out + 1] = para(text(line), { keep_next = true }) end
  return out
end

-- A "[^n]: text" chunk (the typst template's footnote note): the number as a superscript, the text at 10 point.
local function footnote_note(b)
  local first = b.content[1]
  if first == nil or first.t ~= "Str" or not first.text:match("^%[%^%d+%]:$") then return nil end
  local n = first.text:match("%d+")
  local marks = { "¹", "²", "³", "⁴", "⁵" }
  local content = pandoc.Inlines { pandoc.Str(marks[tonumber(n)]), pandoc.Space() }
  for i = 2, #b.content do
    if not (i == 2 and b.content[i].t == "Space") then content[#content + 1] = b.content[i] end
  end
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Footnote Text" }))
end

local function is_certificate(b)
  return b.t == "Header" and b.level == 1 and text(b.content):upper() == "CERTIFICATE OF SERVICE"
end

-- A numbered motion paragraph: "N." then the text, first line indented (global count, as in the typst template).
local motion_count = 0
local function numbered(item)
  motion_count = motion_count + 1
  local first = item[1]
  local inl = (first and (first.t == "Plain" or first.t == "Para")) and first.content or pandoc.Inlines {}
  local content = pandoc.Inlines { pandoc.Str(motion_count .. "."), pandoc.Space() }
  content:extend(inl)
  local blocks = { pandoc.Para(content) }
  for i = 2, #item do blocks[#blocks + 1] = item[i] end
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Paragraph" }))
end

-- A lettered item: "(a)", "(b)", ... with a hanging indent (the label at 0.5 in, the text at 1 in).
local function lettered_list(items)
  local letters = "abcdefghijklmnopqrstuvwxyz"
  local out = {}
  for n, item in ipairs(items) do
    local first = item[1]
    local inl = (first and (first.t == "Plain" or first.t == "Para")) and first.content or pandoc.Inlines {}
    local content = pandoc.Inlines { pandoc.Str("(" .. letters:sub(n, n) .. ")"), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
    content:extend(inl)
    local blocks = { pandoc.Para(content) }
    for i = 2, #item do blocks[#blocks + 1] = item[i] end
    out[#out + 1] = pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = "Lettered Item" }))
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = doc.blocks
  local main, tail = {}, {}
  local in_tail = false
  for _, b in ipairs(blocks) do
    if is_certificate(b) then in_tail = true end
    local dest = in_tail and tail or main
    if b.t == "OrderedList" then
      for _, item in ipairs(b.content) do dest[#dest + 1] = numbered(item) end
    elseif b.t == "BulletList" then
      for _, d in ipairs(lettered_list(b.content)) do dest[#dest + 1] = d end
    else
      dest[#dest + 1] = (b.t == "Para" and footnote_note(b)) or b
    end
  end
  local out = cover(meta)
  for _, b in ipairs(main) do out[#out + 1] = b end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  for _, b in ipairs(of_counsel(meta)) do out[#out + 1] = b end
  for _, b in ipairs(tail) do out[#out + 1] = b end
  doc.meta.title = nil -- the title is set on the cover, not as pandoc's Title paragraph
  doc.blocks = out
  return doc
end

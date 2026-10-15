-- U.S. Bankruptcy Court, M.D. La.: motion with incorporated memorandum, DOCX engine (docs/DOCX.md).
-- Mirrors ../typst/lamb-motion-brief.typ: Form 416 style caption (main case, or adversary when the
-- frontmatter has a plaintiff), title, notice of motion and opportunity for hearing (LR 9013-1(b)(2)),
-- the body (LR 9013-2), signature block with contact details (LR 9013-1(a)). Every string comes from the
-- YAML frontmatter; nothing is case-specific here. Styles are in reference.docx (build-reference.sh).
-- Known limits: see ../README.md "## Engines".

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("lamb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or one value) as a Lua list of strings
local function items(v)
  local out = {}
  if v == nil then return out end
  if pandoc.utils.type(v) == "List" then
    for _, x in ipairs(v) do out[#out + 1] = text(x) end
  else
    out[1] = text(v)
  end
  return out
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- OpenXML runs for an inline list (plain text, emphasis, strong; a RawInline passes through)
local function runs(inl, flags)
  flags = flags or {}
  local out = {}
  for _, el in ipairs(inl) do
    if el.t == "Str" or el.t == "Space" then
      local s = el.t == "Space" and " " or el.text
      local rpr = (flags.b and "<w:b/>" or "") .. (flags.i and "<w:i/>" or "")
      out[#out + 1] = '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or "") ..
        '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
    elseif el.t == "Emph" then
      out[#out + 1] = runs(el.content, { b = flags.b, i = true })
    elseif el.t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = flags.i })
    else
      out[#out + 1] = runs({ pandoc.Str(text(el)) }, flags)
    end
  end
  return table.concat(out)
end

-- one OpenXML paragraph in a custom paragraph style
local function xpara(style, inl, flags)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. runs(inl, flags) .. '</w:p>'
end

local function str(s) return pandoc.List({ pandoc.Str(s) }) end

local function para(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>' ..
  '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function cell(width, xml, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' ..
    (xml ~= "" and xml or '<w:p/>') .. '</w:tc>'
end

-- three columns: 4500 | gutter 360 | 4500 twips (6.5 in text width, 0.25 in gutter, as typst/)
local function grid3(left, right, left_extra)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' .. NOBORDER ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4500"/><w:gridCol w:w="360"/><w:gridCol w:w="4500"/></w:tblGrid><w:tr>' ..
    cell(4500, left, left_extra) .. cell(360, "") .. cell(4500, right) .. '</w:tr></w:tbl>'
end

-- Form 416 style caption: the left cell is closed by a rule at its right and bottom (typst: 0.7 pt stroke)
local function caption(meta)
  local out = {}
  out[#out + 1] = para("Centered", { pandoc.Strong(str("UNITED STATES BANKRUPTCY COURT")) })
  out[#out + 1] = para("CenteredGap", { pandoc.Strong(str("MIDDLE DISTRICT OF LOUISIANA")) })

  local left = {}
  left[#left + 1] = xpara("Single", str("In re:"))
  left[#left + 1] = xpara("Single", str(text(need(meta, "debtor"))))
  left[#left + 1] = xpara("CaptionRight", str("Debtor."))
  if meta.plaintiff ~= nil then
    for i, line in ipairs(items(meta.plaintiff)) do
      left[#left + 1] = xpara(i == 1 and "CaptionBreak" or "Single", str(line))
    end
    left[#left + 1] = xpara("CaptionRight", str("Plaintiff,"))
    left[#left + 1] = xpara("CaptionV", str("v."))
    for _, line in ipairs(items(need(meta, "defendants"))) do
      left[#left + 1] = xpara("Single", str(line))
    end
    left[#left + 1] = xpara("CaptionRight", str("Defendant."))
  end

  local right = {}
  right[#right + 1] = xpara("CaptionCell", str("Case No. " .. text(need(meta, "case_no"))))
  right[#right + 1] = xpara("CaptionCell", str(text(need(meta, "chapter"))))
  if meta.adv_no ~= nil then
    right[#right + 1] = xpara("CaptionCell", str("Adversary Proceeding No. " .. text(meta.adv_no)))
  end

  out[#out + 1] = pandoc.RawBlock("openxml", grid3(
    table.concat(left), table.concat(right),
    '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="173" w:type="dxa"/><w:bottom w:w="173" w:type="dxa"/></w:tcMar>'))
  return out
end

-- Dated line on the left, signature and contact block on the right (typst signature())
local function signature(meta)
  local sig = need(meta, "signature")
  local contact = need(meta, "contact")
  local right = { xpara("Single", str("Respectfully submitted,")),
    xpara("SignatureGap", str("/s/ " .. text(sig.signer))) }
  for _, line in ipairs(items(sig.lines)) do
    right[#right + 1] = xpara("Single", str(line), { i = true })
  end
  for _, line in ipairs(items(need(contact, "address"))) do
    right[#right + 1] = xpara("Single", str(line), { i = true })
  end
  right[#right + 1] = xpara("Single", str("Telephone: " .. text(need(contact, "phone"))), { i = true })
  right[#right + 1] = xpara("Single", str("Email: " .. text(need(contact, "email"))), { i = true })
  local left = xpara("Single", str("Dated: " .. text(need(meta, "date"))))
  return pandoc.RawBlock("openxml", grid3(left, table.concat(right)))
end

-- the notice of motion and opportunity for hearing (LR 9013-1(b)(2)); wording of the objection
-- deadline follows the rule, as in typst/
local function notice(meta)
  local h = need(meta, "hearing")
  local out = {}
  out[#out + 1] = para("NoticeHead", { pandoc.Strong(str("NOTICE OF MOTION AND OPPORTUNITY FOR HEARING")) })
  out[#out + 1] = pandoc.Para(str('PLEASE TAKE NOTICE that the motion titled "' .. text(need(meta, "title")) ..
    '" has been filed. The motion seeks ' .. text(need(meta, "relief"))))
  out[#out + 1] = pandoc.Para(str("A hearing on the motion is set for " .. text(need(h, "date")) .. " at " ..
    text(need(h, "time")) .. ", in " .. text(need(h, "place")) .. "."))
  out[#out + 1] = pandoc.Para(str("Any party opposing the motion must file an objection or response no later than " ..
    "eight days before the scheduled hearing and must at the same time serve a copy of the objection or " ..
    "response on the mover or its counsel, and on all other parties entitled to notice of the objection."))
  return out
end

-- tables are single-spaced, as filed (typst/: table cells keep 12 pt, single leading): each cell
-- becomes one Single-styled block (pandoc would otherwise set table text in the double-spaced Compact style)
local function single_rows(rows)
  for _, row in ipairs(rows) do
    for _, c in ipairs(row.cells) do
      local blocks = {}
      for _, b in ipairs(c.contents) do
        if b.t == "Plain" then b = pandoc.Para(b.content) end
        blocks[#blocks + 1] = b
      end
      c.contents = pandoc.Blocks({ pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = "Single" })) })
    end
  end
end

function single_spaced_table(t)
  if t.head then single_rows(t.head.rows) end
  for _, body in ipairs(t.bodies) do
    single_rows(body.head)
    single_rows(body.body)
  end
  if t.foot then single_rows(t.foot.rows) end
  return t
end

function Pandoc(doc)
  -- a copy of the frontmatter: the caption and signature read it after the title and date are cleared below
  local meta = {}
  for k, v in pairs(doc.meta) do meta[k] = v end
  for _, k in ipairs({ "title", "relief", "hearing", "debtor", "case_no", "chapter", "date", "signature", "contact" }) do
    local _ = need(meta, k)
  end
  if meta.plaintiff ~= nil then local _ = need(meta, "defendants") end
  doc.meta.title = nil
  doc.meta.date = nil
  doc.meta.author = nil

  local out = {}
  local function add(b) out[#out + 1] = b end

  for _, b in ipairs(caption(meta)) do add(b) end
  add(para("TitleLine", { pandoc.Strong(str(string.upper(text(meta.title)))) }))
  for _, b in ipairs(notice(meta)) do add(b) end

  -- the motion and the incorporated memorandum (LR 9013-2): the body keeps its markdown structure
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then add(pandoc.Header(1, str(string.upper(text(b)))))
    else add(b) end
  end

  add(signature(meta))
  doc.blocks = out
  return doc:walk({ Table = single_spaced_table })
end

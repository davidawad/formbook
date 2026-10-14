-- Supreme Court of the United States: amicus curiae brief (booklet format), docx engine.
-- Cover, headings and signature/certificate are raw WordprocessingML paragraphs (pandoc passes
-- openxml through); the body is pandoc's. Page setup, fonts and spacing are in reference.docx.
-- BLOCKED (see README, Engines): the table of contents and table of authorities list headings and
-- authorities without page numbers (no TOC/TOA field results), and the footer page numbers are not built.

local meta = nil
local counters = { 0, 0, 0, 0, 0, 0 }
local toc = {}

local function raw_break()
  return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Plain text of a metadata value (the cover and signature are set without character styling).
local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function xp(text, o)
  o = o or {}
  local ppr = ""
  local jc = o.jc and ('<w:jc w:val="' .. o.jc .. '"/>') or ""
  local ind = ""
  if o.left then ind = ind .. '<w:ind w:left="' .. o.left .. '" w:hanging="' .. (o.hanging or 0) .. '"/>' end
  local after = '<w:spacing w:before="0" w:after="' .. (o.after or 0) .. '" w:line="280" w:lineRule="exact"/>'
  ppr = "<w:pPr>" .. after .. ind .. jc .. "</w:pPr>"
  local rpr = "<w:rPr>" .. (o.bold and "<w:b/>" or "") .. (o.italic and "<w:i/>" or "") .. "</w:rPr>"
  local run = '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  if o.caps then run = run:gsub("<w:t ", "<w:t ") end
  return "<w:p>" .. ppr .. run .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function cover()
  local x = {}
  local function add(s, o) x[#x + 1] = xp(s, o) end
  add("No. " .. txt(meta.case_number), {})
  add("In the", { jc = "center" })
  add("SUPREME COURT OF THE UNITED STATES", { jc = "center", bold = true, after = 200 })
  for i, side in ipairs(meta.caption) do
    if i > 1 then add("v.", { jc = "center" }) end
    for _, n in ipairs(side.names) do add(txt(n), { jc = "center" }) end
    add(txt(side.designation), { jc = "center" })
  end
  add(txt(meta.proceeding), { jc = "center", after = 200 })
  add(string.upper(txt(meta.brief_title)), { jc = "center", bold = true, after = 200 })
  for _, g in ipairs(meta.counsel) do
    for _, n in ipairs(g.names) do add(txt(n), { jc = "center" }) end
    if g.role then add(txt(g.role), { jc = "center", italic = true }) end
    for _, l in ipairs(g.lines) do add(txt(l), { jc = "center" }) end
    add("", { jc = "center" })
  end
  add(txt(meta.counsel_role), { jc = "center", italic = true })
  add(txt(meta.date), { jc = "center", after = 200 })
  x[#x + 1] = raw_break()
  return raw(table.concat(x, ""))
end

local function front_lists()
  local x = { xp("TABLE OF CONTENTS", { jc = "center", bold = true, after = 200 }) }
  for _, h in ipairs(toc) do
    if h.level == 1 then
      x[#x + 1] = xp(string.upper(h.title), { after = 120 })
    else
      x[#x + 1] = xp(h.label .. " " .. h.title, { left = (h.level - 1) * 576, hanging = 576, after = 120 })
    end
  end
  x[#x + 1] = xp("TABLE OF AUTHORITIES", { jc = "center", bold = true, after = 200 })
  local kinds = { { "Cases", "case" }, { "Statutes", "statute" }, { "Regulations", "regulation" }, { "Other Authorities", "other" } }
  for _, k in ipairs(kinds) do
    local items = {}
    for key, a in pairs(meta.authorities or {}) do
      if pandoc.utils.stringify(a.kind) == k[2] then items[#items + 1] = pandoc.utils.stringify(a.name) .. (a.cite and (" " .. pandoc.utils.stringify(a.cite)) or "") end
    end
    table.sort(items)
    if #items > 0 then
      x[#x + 1] = xp(k[1], { bold = true, after = 120 })
      for _, it in ipairs(items) do x[#x + 1] = xp(it, { left = 576, hanging = 576, after = 120 }) end
    end
  end
  x[#x + 1] = raw_break()
  return raw(table.concat(x, ""))
end

local function heading(h)
  local lvl = h.level
  counters[lvl] = counters[lvl] + 1
  for i = lvl + 1, #counters do counters[i] = 0 end
  local n = counters[lvl]
  local title = pandoc.utils.stringify(h)
  if lvl == 1 then
    toc[#toc + 1] = { level = 1, title = title }
    return raw(xp(string.upper(title), { jc = "center", bold = true, after = 240 }))
  end
  local label
  if lvl == 2 then label = ({ "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" })[n] .. "."
  elseif lvl == 3 then label = string.char(64 + n) .. "."
  elseif lvl == 4 then label = tostring(n) .. "."
  else label = string.char(96 + n) .. "." end
  toc[#toc + 1] = { level = lvl, label = label, title = title }
  return raw(xp(label .. "\t" .. title, { left = (lvl - 1) * 576, hanging = 576, bold = true, after = 240 }))
end

function Pandoc(doc)
  meta = doc.meta
  local body = doc:walk({ Header = heading })
  local out = { cover() }
  local lists = {}
  local blocks = body.blocks
  -- TOC and TOA lists are built from the headings and frontmatter; they must come before the body
  local front = front_lists()
  table.insert(out, front)
  for _, b in ipairs(blocks) do out[#out + 1] = b end
  out[#out + 1] = raw(xp("Respectfully submitted,", { after = 240 }))
  local sig = meta.signature
  out[#out + 1] = raw(xp(string.upper(txt(sig.signer)), { bold = true }))
  for _, l in ipairs(sig.lines) do out[#out + 1] = raw(xp(txt(l), {})) end
  out[#out + 1] = raw(xp(txt(meta.date), { after = 240 }))
  -- empty metadata: pandoc would otherwise print the date as a title block above the cover
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

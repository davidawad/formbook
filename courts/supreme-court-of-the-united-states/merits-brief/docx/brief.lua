-- Supreme Court of the United States: brief on the merits (booklet format), docx engine.
-- Cover, front pages, headings, signature and certificate are raw WordprocessingML paragraphs (pandoc
-- passes openxml through); the body is pandoc's. Page setup, fonts and spacing are in reference.docx.
-- BLOCKED (see ../README.md, Engines): the table of contents and table of authorities list headings and
-- authorities without page numbers (no TOC/TOA field results), and the footer page numbers are not built.

local meta = nil
local counters = { 0, 0, 0, 0, 0, 0 }
local toc = {}

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function xp(text, o)
  o = o or {}
  local jc = o.jc and ('<w:jc w:val="' .. o.jc .. '"/>') or ""
  local ind = ""
  if o.left then ind = '<w:ind w:left="' .. o.left .. '" w:hanging="' .. (o.hanging or 0) .. '"/>' end
  local after = '<w:spacing w:before="0" w:after="' .. (o.after or 0) .. '" w:line="280" w:lineRule="exact"/>'
  local ppr = "<w:pPr>" .. after .. ind .. jc .. "</w:pPr>"
  local rpr = "<w:rPr>" .. (o.bold and "<w:b/>" or "") .. (o.italic and "<w:i/>" or "") .. "</w:rPr>"
  return "<w:p>" .. ppr .. '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r></w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function page_break()
  return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
end

local function cover()
  local x = {}
  local function add(s, o) x[#x + 1] = xp(s, o) end
  add("No. " .. txt(meta.docket):gsub("^No%. ", ""), {})
  add("IN THE", { jc = "center" })
  add("SUPREME COURT OF THE UNITED STATES", { jc = "center", bold = true, after = 200 })
  for _, c in ipairs(meta.caption) do add(txt(c), { jc = "center" }) end
  add(txt(meta.proceeding), { jc = "center", after = 200 })
  add(string.upper(txt(meta.brief_title)), { jc = "center", bold = true, after = 200 })
  for _, g in ipairs(meta.counsel) do
    for _, n in ipairs(g.names) do add(txt(n), { jc = "center" }) end
    for _, l in ipairs(g.lines) do add(txt(l), { jc = "center" }) end
    add("", { jc = "center" })
  end
  add(txt(meta.date), { jc = "center", after = 200 })
  x[#x + 1] = page_break()
  return raw(table.concat(x, ""))
end

local function front_pages()
  local x = { xp("QUESTION PRESENTED", { jc = "center", bold = true, after = 240 }) }
  for _, q in ipairs(meta.questions) do x[#x + 1] = xp(txt(q), { after = 240 }) end
  x[#x + 1] = page_break()
  x[#x + 1] = xp("PARTIES TO THE PROCEEDINGS", { jc = "center", bold = true, after = 240 })
  x[#x + 1] = xp(txt(meta.parties), { after = 240 })
  x[#x + 1] = xp("CORPORATE DISCLOSURE STATEMENT", { jc = "center", bold = true, after = 240 })
  x[#x + 1] = xp(txt(meta.disclosure), { after = 240 })
  x[#x + 1] = page_break()
  return raw(table.concat(x, ""))
end

local function front_lists()
  local x = { xp("TABLE OF CONTENTS", { jc = "center", bold = true, after = 200 }) }
  for _, h in ipairs(toc) do
    if h.level == 1 then
      x[#x + 1] = xp(string.upper(h.title), { after = 120 })
    else
      x[#x + 1] = xp(h.title, { left = (h.level - 1) * 576, hanging = 0, after = 120 })
    end
  end
  x[#x + 1] = xp("TABLE OF AUTHORITIES", { jc = "center", bold = true, after = 200 })
  local kinds = { { "Cases", "case" }, { "Rules", "rule" }, { "Statutes", "statute" }, { "Other Authorities", "other" } }
  for _, k in ipairs(kinds) do
    local items = {}
    for _, a in pairs(meta.authorities or {}) do
      if txt(a.kind) == k[2] then items[#items + 1] = txt(a.name) .. (a.cite and (" " .. txt(a.cite)) or "") end
    end
    table.sort(items)
    if #items > 0 then
      x[#x + 1] = xp(k[1], { bold = true, after = 120 })
      for _, it in ipairs(items) do x[#x + 1] = xp(it, { left = 576, hanging = 576, after = 120 }) end
    end
  end
  x[#x + 1] = page_break()
  return raw(table.concat(x, ""))
end

local function heading(h)
  local lvl = h.level
  local title = pandoc.utils.stringify(h)
  toc[#toc + 1] = { level = lvl, title = title }
  if lvl == 1 then
    return raw(xp(string.upper(title), { jc = "center", bold = true, after = 240 }))
  end
  -- the sample writes its own numerals in the heading text
  return raw(xp(title, { left = (lvl - 1) * 576, hanging = 576, bold = true, after = 240 }))
end

local function signature_and_certificate(words)
  local sig = meta.signature
  local out = {}
  out[#out + 1] = raw(xp("Respectfully submitted,", { after = 240 }))
  out[#out + 1] = raw(xp(string.upper(txt(sig.signer)), { bold = true }))
  for _, l in ipairs(sig.lines) do out[#out + 1] = raw(xp(txt(l), {})) end
  out[#out + 1] = raw(xp(txt(meta.date), { after = 240 }))
  out[#out + 1] = raw(page_break())
  out[#out + 1] = raw(xp("CERTIFICATE OF COMPLIANCE", { jc = "center", bold = true, after = 240 }))
  out[#out + 1] = raw(xp("I certify that this brief complies with the word limit of Supreme Court Rule 33.1(g). It contains " .. words .. " words, excluding the items listed in Rule 33.1(d). The limit for a brief on the merits for a petitioner or appellant is 13,000 words.", { after = 240 }))
  out[#out + 1] = raw(xp(string.upper(txt(sig.signer)), { bold = true }))
  for _, l in ipairs(sig.lines) do out[#out + 1] = raw(xp(txt(l), {})) end
  return out
end

function Pandoc(doc)
  meta = doc.meta
  local words = 0
  for _, b in ipairs(doc.blocks) do
    local _, n = pandoc.utils.stringify(b):gsub("%S+", "")
    words = words + n
  end
  local body = doc:walk({ Header = heading })
  local out = { cover(), front_pages() }
  out[#out + 1] = front_lists()
  for _, b in ipairs(body.blocks) do out[#out + 1] = b end
  for _, b in ipairs(signature_and_certificate(words)) do out[#out + 1] = b end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

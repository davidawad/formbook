-- S.D. Cal. motion-brief (memorandum of points and authorities): pandoc filter for the docx engine. The same content as
-- the typst template (casd-motion-brief.typ) from the same markdown contract. Styles come from reference.docx (pleading
-- paper: EB Garamond 14 pt, 24 pt exact lines, first-line indent, heading styles). This filter writes what styles cannot:
-- the cover (counsel, court, caption, title, hearing block), the table of contents and table of authorities, the "I." and
-- "A." labels of the headings, and the signature block. Known gaps (README.md, "Engines"): the TOC is a field that needs
-- updating in Word, the TOA has no page numbers, and there is no footer (page numbers and the footer title).

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("casd-motion-brief: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- One WordprocessingML paragraph from runs. runs: list of {s = text, i = italic, b = bold}.
-- opts: jc, ind_left, line (240 single, 480 double), after/before (twips), keep_next, before_break.
local function para_runs(runs, opts)
  opts = opts or {}
  local ppr = ""
  if opts.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if opts.before_break then ppr = ppr .. "<w:pageBreakBefore/>" end
  ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) .. '" w:line="' .. (opts.line or 240) .. '" w:lineRule="auto"/>'
  if opts.ind_left then ppr = ppr .. '<w:ind w:left="' .. opts.ind_left .. '" w:firstLine="0"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local body = {}
  for _, r in ipairs(runs) do
    local rpr = ""
    if r.b or r.i then rpr = "<w:rPr>" .. (r.b and "<w:b/>" or "") .. (r.i and "<w:i/>" or "") .. "</w:rPr>" end
    body[#body + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(r.s) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. table.concat(body) .. "</w:p>"
end

local function para(s, opts)
  return para_runs({ { s = s, b = opts and opts.bold, i = opts and opts.italic } }, opts)
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function page_break()
  return raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function lines_of(list)
  local out = {}
  for _, v in ipairs(list or {}) do out[#out + 1] = text(v) end
  return out
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return string.upper(out)
end

local function label_run(s)
  return pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r><w:r><w:tab/></w:r>')
end

-- The cover: counsel (single spaced, upper left), court, caption, title and hearing block.
local function cover(meta)
  local out = {}
  for _, s in ipairs(lines_of(need(meta, "counsel"))) do out[#out + 1] = raw(para(s)) end
  if meta.counsel_role then out[#out + 1] = raw(para(text(meta.counsel_role), { italic = true })) end
  out[#out + 1] = raw(para("", { line = 480 }))
  for _, s in ipairs(lines_of(need(meta, "court"))) do out[#out + 1] = raw(para(s, { jc = "center", bold = true, line = 480 })) end
  out[#out + 1] = raw(para("", { line = 480 }))
  local caption = need(meta, "caption")
  for i, p in ipairs(caption) do
    for _, s in ipairs(lines_of(p.names)) do out[#out + 1] = raw(para(s)) end
    out[#out + 1] = raw(para(text(p.designation), { ind_left = 1440 }))
    if i < #caption then out[#out + 1] = raw(para("v.", { ind_left = 720 })) end
  end
  out[#out + 1] = raw(para("Case No. " .. text(need(meta, "case_number")), { ind_left = 4680, line = 480 }))
  out[#out + 1] = raw(para("", { line = 480 }))
  out[#out + 1] = raw(para(text(need(meta, "brief_title")), { jc = "center", bold = true, line = 480 }))
  if meta.hearing then
    local h = meta.hearing
    out[#out + 1] = raw(para("", { line = 480 }))
    if h.date then out[#out + 1] = raw(para("Date: " .. text(h.date), { ind_left = 4680 })) end
    if h.time then out[#out + 1] = raw(para("Time: " .. text(h.time), { ind_left = 4680 })) end
    if h.place then out[#out + 1] = raw(para(text(h.place), { ind_left = 4680 })) end
    if h.judge then out[#out + 1] = raw(para("Judge: " .. text(h.judge), { ind_left = 4680 })) end
  end
  out[#out + 1] = page_break()
  return out
end

-- Table of contents: a TOC field over the heading styles. Word fills it when the field is updated (README.md, gap 1).
local function toc()
  local out = {}
  out[#out + 1] = raw(para("TABLE OF CONTENTS", { jc = "center", bold = true, line = 480 }))
  out[#out + 1] = raw(
    '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>'
      .. '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>'
      .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>'
      .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
      .. '<w:r><w:t>Update the field (select all, then F9) to build the table of contents.</w:t></w:r>'
      .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  )
  out[#out + 1] = page_break()
  return out
end

local GROUPS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "regulation", "Regulations" },
  { "rule", "Rules" },
  { "other", "Other Authorities" },
}

-- Table of authorities: the authorities the body links with toa: keys, grouped by kind. No page numbers (README.md, gap 2).
local function toa(meta, keys)
  local out = {}
  out[#out + 1] = raw(para("TABLE OF AUTHORITIES", { jc = "center", bold = true, line = 480 }))
  local auth = meta.authorities
  for _, g in ipairs(GROUPS) do
    local items = {}
    for _, k in ipairs(keys) do
      local a = auth and auth[k]
      if a == nil then error("casd-motion-brief: toa key `" .. k .. "` has no entry in authorities") end
      if text(a.kind) == g[1] then items[#items + 1] = { name = text(a.name), cite = text(a.cite), italic = g[1] == "case" } end
    end
    if #items > 0 then
      table.sort(items, function(x, y) return x.name < y.name end)
      out[#out + 1] = raw(para(g[2] .. ":", { bold = true, before = 240, after = 240, keep_next = true }))
      for _, it in ipairs(items) do
        local runs = { { s = it.name, i = it.italic } }
        if it.cite ~= "" then runs[#runs + 1] = { s = ", " .. it.cite } end
        out[#out + 1] = raw(para_runs(runs, { after = 240, ind_left = 360 }))
      end
    end
  end
  out[#out + 1] = page_break()
  return out
end

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  if meta.date then out[#out + 1] = raw(para("Dated: " .. text(meta.date), { before = 480, keep_next = true })) end
  out[#out + 1] = raw(para("Respectfully submitted,", { ind_left = 4680, before = 240, keep_next = true }))
  for _, s in ipairs(lines_of(sig.preamble)) do out[#out + 1] = raw(para(s, { ind_left = 4680, before = 240, keep_next = true })) end
  out[#out + 1] = raw(para("By: /s/ " .. text(sig.signer), { ind_left = 4680, before = 480, keep_next = true }))
  for _, s in ipairs(lines_of(sig.lines)) do out[#out + 1] = raw(para(s, { ind_left = 4680, keep_next = true })) end
  return out
end

-- toa: links are ordinary text in the docx (the table of authorities lists the keys; no page numbers, README.md gap 2).
-- Done here, in the document function, so the order of Lua filter functions does not matter.
function Pandoc(doc)
  local meta = doc.meta
  local keys, seen = {}, {}
  local stripped = pandoc.Pandoc(doc.blocks):walk({
    Link = function(el)
      local k = el.target:match("^toa:(.+)$")
      if not k then return nil end
      if not seen[k] then
        seen[k] = true
        keys[#keys + 1] = k
      end
      return el.content
    end,
  })
  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end
  for _, b in ipairs(toc()) do out[#out + 1] = b end
  for _, b in ipairs(toa(meta, keys)) do out[#out + 1] = b end
  local c2, c3 = 0, 0
  for _, b in ipairs(stripped.blocks) do
    if b.t == "Header" and b.level == 1 then
      c2, c3 = 0, 0
      out[#out + 1] = b
    elseif b.t == "Header" and b.level == 2 then
      c2 = c2 + 1
      c3 = 0
      local inl = { label_run(roman(c2) .. ".") }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Header(2, inl)
    elseif b.t == "Header" and b.level == 3 then
      c3 = c3 + 1
      local inl = { label_run(string.char(64 + c3) .. ".") }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Header(3, inl)
    else
      out[#out + 1] = b
    end
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  for _, k in ipairs({ "title", "subtitle", "author", "date", "abstract" }) do doc.meta[k] = nil end
  doc.blocks = out
  return doc
end

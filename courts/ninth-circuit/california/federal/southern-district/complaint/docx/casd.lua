-- S.D. Cal. complaint: pandoc filter for the docx engine. The same content as the typst template (casd-complaint.typ)
-- from the same markdown contract. Styles come from reference.docx (pleading paper: EB Garamond 14 pt, 24 pt exact lines,
-- first-line indent, headings). This filter writes what styles cannot: the counsel block, the caption, the title, the
-- numbering of the allegations (Fed. R. Civ. P. 10(b)), the lettering of the prayer items, and the signature block.
-- Known gaps (README.md, "Engines"): no footer (page numbers and the footer title), the caption is paragraphs, not a box.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("casd-complaint: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- One WordprocessingML paragraph. opts: jc, ind_left, ind_hanging, bold, italic, line (240 single, 480 double),
-- after (twips), before (twips), keep_next, before_break.
local function para(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if opts.before_break then ppr = ppr .. "<w:pageBreakBefore/>" end
  ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) .. '" w:line="' .. (opts.line or 240) .. '" w:lineRule="auto"/>'
  if opts.ind_left then
    ppr = ppr .. '<w:ind w:left="' .. opts.ind_left .. '"' .. (opts.ind_hanging and (' w:hanging="' .. opts.ind_hanging .. '"') or ' w:firstLine="0"') .. "/>"
  end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local rpr = ""
  if opts.bold or opts.italic then
    rpr = "<w:rPr>" .. (opts.bold and "<w:b/>" or "") .. (opts.italic and "<w:i/>" or "") .. "</w:rPr>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr><w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r></w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function lines_of(list)
  local out = {}
  for _, v in ipairs(list or {}) do out[#out + 1] = text(v) end
  return out
end

-- Counsel block (single spaced, upper left), court title, caption, title, legend and jury demand.
local function cover(meta)
  local out = {}
  for _, s in ipairs(lines_of(need(meta, "counsel"))) do out[#out + 1] = raw(para(s)) end
  out[#out + 1] = raw(para("", { line = 480 }))
  out[#out + 1] = raw(para("UNITED STATES DISTRICT COURT", { jc = "center", bold = true, line = 480 }))
  out[#out + 1] = raw(para("SOUTHERN DISTRICT OF CALIFORNIA", { jc = "center", bold = true, line = 480 }))
  out[#out + 1] = raw(para("", { line = 480 }))
  -- caption: party names, designations, "v." between parties; the case number on the right.
  local parties = need(meta, "caption").parties
  for i, p in ipairs(parties) do
    for _, s in ipairs(lines_of(p.names)) do out[#out + 1] = raw(para(s)) end
    out[#out + 1] = raw(para(text(p.designation), { ind_left = 1440 }))
    if i < #parties then out[#out + 1] = raw(para("v.", { ind_left = 720 })) end
  end
  out[#out + 1] = raw(para("Case No. " .. text(need(meta, "case_number")), { ind_left = 4680, line = 480 }))
  out[#out + 1] = raw(para("", { line = 480 }))
  out[#out + 1] = raw(para(text(need(meta, "brief_title")), { jc = "center", bold = true, line = 480 }))
  if meta.legend then out[#out + 1] = raw(para(text(meta.legend), { jc = "center", bold = true, line = 480 })) end
  if meta.jury_demand then out[#out + 1] = raw(para("DEMAND FOR JURY TRIAL", { jc = "right", bold = true, line = 480 })) end
  out[#out + 1] = raw(para("", { line = 480, before_break = true }))
  return out
end

-- The signature block: date at left, firm and signer at the right half, single spaced.
local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  if meta.date then out[#out + 1] = raw(para("Dated: " .. text(meta.date), { before = 480, line = 480 })) end
  for _, s in ipairs(lines_of(sig.firm)) do out[#out + 1] = raw(para(s, { ind_left = 4680, before = 240, keep_next = true })) end
  out[#out + 1] = raw(para("By: /s/ " .. text(sig.signer), { ind_left = 4680, before = 480, keep_next = true }))
  for _, s in ipairs(lines_of(sig.lines)) do out[#out + 1] = raw(para(s, { ind_left = 4680, keep_next = true })) end
  return out
end

local function letter(n)
  return string.char(96 + n)
end

local function numbered_run(n)
  return pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. n .. '.</w:t></w:r><w:r><w:tab/></w:r>')
end

local function letter_run(n)
  return pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">(' .. letter(n) .. ')</w:t></w:r><w:r><w:tab/></w:r>')
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end
  if meta.lead_in then
    -- an unnumbered lead-in paragraph before the body (the typst template's lead_in)
    local lead = pandoc.Para({ pandoc.Str(text(meta.lead_in)) })
    out[#out + 1] = lead
  end
  local numbered = true
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      local title = string.upper(text(b.content))
      numbered = not (title:match("^PRAYER") or title:match("^DEMAND"))
      out[#out + 1] = b
    elseif b.t == "Para" and numbered then
      n = n + 1
      local inl = { numbered_run(n) }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Para(inl)
    elseif b.t == "OrderedList" and not numbered then
      -- prayer items: lettered (a), (b), ... as the typst template letters them
      for i, item in ipairs(b.content) do
        local first = item[1]
        local blocks = {}
        if first and (first.t == "Plain" or first.t == "Para") then
          local inl = { letter_run(i) }
          for _, x in ipairs(first.content) do inl[#inl + 1] = x end
          blocks[1] = pandoc.Para(inl)
          for k = 2, #item do blocks[#blocks + 1] = item[k] end
        else
          -- an item that starts with a nested block: the letter goes on its own line
          blocks[1] = pandoc.Para({ letter_run(i) })
          for k = 1, #item do blocks[#blocks + 1] = item[k] end
        end
        out[#out + 1] = pandoc.Div(blocks, { ["custom-style"] = "Prayer Item" })
      end
    else
      out[#out + 1] = b
    end
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  -- the cover is written above; pandoc's own title block (from the same metadata) must not be written as well
  for _, k in ipairs({ "title", "subtitle", "author", "date", "abstract" }) do doc.meta[k] = nil end
  doc.blocks = out
  return doc
end

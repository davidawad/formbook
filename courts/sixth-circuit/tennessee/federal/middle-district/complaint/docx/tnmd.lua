-- M.D. Tenn. DOCX filter (docs/DOCX.md). Part of the tnmd filter; CFG is set per doc type.
-- Mirrors typst/tnmd-complaint.typ: court heading, caption (party column, ")" column, right column),
-- title, numbered paragraphs (FRCP 10(b)), lettered prayer items (LR 7.03), signature block.
-- Styles come from reference.docx (build-reference.sh). Only frontmatter-driven content: no case words here.
local CFG = { numbered = true, letters = true, markers = false }

local CAP_W = { 4752, 432, 4176 } -- twips: 3.3 in party column, 0.3 in ")" column, rest (2.9 in)
local CAP_LEFT_PT = 237.6 -- 3.3 in in points, for the ")" line estimate
local UNDERSCORES = string.rep("_", 16)

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function xp(style, text, opts)
  opts = opts or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if opts.indent then ppr = ppr .. '<w:ind w:left="' .. opts.indent .. '" w:firstLine="0"/>' end
  local runs
  if opts.breaks then
    runs = {}
    for i, t in ipairs(opts.breaks) do
      if i > 1 then runs[#runs + 1] = "<w:r><w:br/></w:r>" end
      runs[#runs + 1] = '<w:r><w:t xml:space="preserve">' .. esc(t) .. "</w:t></w:r>"
    end
    runs = table.concat(runs)
  elseif text and text ~= "" then
    runs = '<w:r><w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  else
    runs = ""
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. runs .. "</w:p>"
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- Rough width of a caption line in points (13 pt EB Garamond): capitals wider than lower case.
local function lines_needed(text, indent_pt)
  local w = 0
  for ch in text:gmatch(utf8.charpattern) do
    if ch:match("%u") then w = w + 0.68
    elseif ch:match("%l") then w = w + 0.45
    elseif ch:match("%d") then w = w + 0.5
    elseif ch == " " then w = w + 0.25
    else w = w + 0.4 end
  end
  w = w * 13
  return math.max(1, math.ceil(w / (CAP_LEFT_PT - indent_pt) - 0.02))
end

-- caption rows as the typst grid: names, designation (indented 1 in), "v." between parties (indent 1 in)
local function caption_table(meta)
  local c = meta.caption
  local rows = {}
  for k, p in ipairs(c.parties or {}) do
    if k > 1 then
      rows[#rows + 1] = { text = "" }
      rows[#rows + 1] = { text = "v.", indent = 1440, pt = 72 }
      rows[#rows + 1] = { text = "" }
    end
    rows[#rows + 1] = { text = plain(p.names) }
    rows[#rows + 1] = { text = plain(p.designation), indent = 1440, pt = 72 }
  end
  -- right column (vertically centered across the rows, as horizon in typst)
  local case_no = plain(meta.case_number)
  if case_no == "" then case_no = UNDERSCORES end
  local right = { xp("Single", "Case No. " .. case_no) }
  if meta.jury_demand then
    right[#right + 1] = xp("Single", "")
    right[#right + 1] = xp("Single", "JURY DEMAND")
  end
  if meta.judges and #meta.judges > 0 then
    right[#right + 1] = xp("Single", "")
    for _, j in ipairs(meta.judges) do right[#right + 1] = xp("Single", plain(j)) end
  end
  local body = {}
  for i, r in ipairs(rows) do
    local k = lines_needed(r.text, r.pt or 0)
    local paren = {}
    for _ = 1, k do paren[#paren + 1] = ")" end
    local left = xp("Single", r.text, { indent = r.indent })
    local mid = xp("Single", nil, { breaks = paren })
    local rc
    if i == 1 then
      rc = '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_W[3] .. '" w:type="dxa"/><w:vMerge w:val="restart"/><w:vAlign w:val="center"/></w:tcPr>'
        .. table.concat(right) .. "</w:tc>"
    else
      rc = '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_W[3] .. '" w:type="dxa"/><w:vMerge/></w:tcPr>' .. xp("Single", "") .. "</w:tc>"
    end
    body[#body + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_W[1] .. '" w:type="dxa"/></w:tcPr>' .. left .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_W[2] .. '" w:type="dxa"/></w:tcPr>' .. mid .. "</w:tc>"
      .. rc .. "</w:tr>"
  end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_W[1] .. '"/><w:gridCol w:w="' .. CAP_W[2] .. '"/><w:gridCol w:w="' .. CAP_W[3] .. '"/></w:tblGrid>'
    .. table.concat(body) .. "</w:tbl>")
end

local function cover(meta)
  local out = {}
  local function add(x) out[#out + 1] = raw(x) end
  add(xp("Centered", "IN THE UNITED STATES DISTRICT COURT"))
  add(xp("Centered", "FOR THE MIDDLE DISTRICT OF TENNESSEE"))
  add(xp("Centered", plain(meta.division)))
  add(xp("GapDouble", ""))
  out[#out + 1] = caption_table(meta)
  add(xp("GapDouble", ""))
  out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="Centered"/></w:pPr><w:r><w:rPr><w:b/><w:bCs/></w:rPr><w:t xml:space="preserve">' .. esc(plain(meta.title)) .. '</w:t></w:r></w:p>')
  add(xp("Gap", ""))
  return out
end

-- The signature block is kept together (keep-with-next on every line but the last), so a heading
-- before it moves with it, as the typst block (breakable: false) does.
local function signature(sig, opening)
  local out = {}
  if opening then
    out[#out + 1] = raw(xp("SignatureKeep", "Respectfully submitted,"))
    out[#out + 1] = raw(xp("GapKeep", ""))
  else
    out[#out + 1] = raw(xp("GapKeep", ""))
  end
  out[#out + 1] = raw(xp("SignatureKeep", plain(sig.signer)))
  out[#out + 1] = raw(xp("GapHalfKeep", ""))
  local lines = sig.lines or {}
  for i, line in ipairs(lines) do
    local style_name = (i < #lines) and "SignatureKeep" or "Signature"
    out[#out + 1] = raw(xp(style_name, plain(line)))
  end
  return out
end

local function starts_with_marker(b, marker)
  if b.t ~= "Para" and b.t ~= "Plain" then return false end
  local first = b.content[1]
  return first ~= nil and first.t == "Str" and first.text == marker
end

local function drop_marker(b, n)
  local inl = pandoc.List({})
  for i = n + 1, #b.content do inl:insert(b.content[i]) end
  return inl
end

local function number_run(label)
  return pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. label .. '</w:t></w:r><w:r><w:tab/></w:r>')
end

local function style(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

local function service_block(cert)
  local out = {}
  for i, entry in ipairs(cert.service or {}) do
    if i > 1 then out[#out + 1] = raw(xp("GapKeep", "")) end
    for _, line in ipairs(entry) do out[#out + 1] = raw(xp("SingleKeep", plain(line))) end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  addall(cover(meta))

  if meta.lead_in then
    local li = meta.lead_in
    local inl = (type(li) == "table" and li.t == "MetaInlines") and li or pandoc.Inlines(plain(li))
    add(pandoc.Para(inl))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    local whole = b.t == "Para" and plain(b) or nil
    if whole == "@signature" then
      -- signature block after the body (TNMD-MEMO-005 / TNMD-COMP-006)
      add(raw(xp("GapKeep", "")))
      addall(signature(meta.signature, true))
    elseif whole == "@service" then
      -- certificate of service (TNMD-MEMO-006): entries, then the signer block without an opening line
      addall(service_block(meta.certificate))
      addall(signature(meta.certificate, false))
    elseif b.t == "Para" and starts_with_marker(b, "~") then
      -- "~ " marks an unnumbered paragraph (the WHEREFORE clause); the marker is dropped
      add(pandoc.Para(drop_marker(b, 2)))
    elseif b.t == "Para" and CFG.numbered then
      n = n + 1
      local inl = pandoc.List({ number_run(n .. ".") })
      inl:extend(b.content)
      add(style("Allegation", { pandoc.Para(inl) }))
    elseif b.t == "OrderedList" and CFG.letters then
      for i, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local inl = pandoc.List({ number_run(string.char(64 + i) .. ".") })
          inl:extend(first.content)
          add(style("PrayerItem", { pandoc.Para(inl) }))
          for j = 2, #item do add(item[j]) end
        else
          addall(item)
        end
      end
    else
      add(b)
    end
  end

  -- the complaint's signature block (its markdown has no @signature marker)
  if meta.signature and not CFG.markers then
    add(raw(xp("GapKeep", "")))
    addall(signature(meta.signature, true))
  end

  doc.meta = {}
  doc.blocks = out
  return doc
end

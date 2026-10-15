-- NMCCA brief, DOCX engine (docs/DOCX.md). The markdown contract -> a Word brief on reference.docx, with the
-- layout of typst/nmcca-*.typ: a cover (its own section, 2 in bottom margin, no page number), the index of
-- brief (own section, lower-roman page numbers), the body (arabic from 1), the signature block, and the
-- certificate on a new page. Heading labels follow NMCCA-CONT-004 (Argument: I. A. 1. a.; elsewhere A. 1. a. (1)).
-- Index page numbers: render.sh runs the filter twice. Pass 1 writes the heading list to NMCCA_HEADINGS;
-- pass 2 reads the page of each heading (in document order) from NMCCA_PAGES.
-- Known limits (BLOCKED, see the PR): the cover counsel block is a frame placed by its page position;
-- headings are read at the top level of the body only (the samples have no nested headings).

local META = {}
local TEXT_W = 9360 -- 6.5 in, in twips
local PAGE_H = 15840

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

local function lower(s) return string.lower(s) end

local function meta_str(k)
  local v = META[k]
  if v == nil then return "" end
  return trim(pandoc.utils.stringify(v))
end

local function meta_list_of(v)
  local out = {}
  if v == nil then return out end
  if v.t == "MetaList" or (v.t == nil and #v > 0) then
    for _, item in ipairs(v) do out[#out + 1] = trim(pandoc.utils.stringify(item)) end
  else
    out[1] = trim(pandoc.utils.stringify(v))
  end
  return out
end

local function meta_list(k)
  return meta_list_of(META[k])
end

local function meta_sig()
  local sig = META["signature"]
  if sig == nil then return "", {} end
  return trim(pandoc.utils.stringify(sig["signer"] or "")), meta_list_of(sig["lines"])
end

-- ---------------------------------------------------------------------------
-- OpenXML helpers
-- ---------------------------------------------------------------------------

local function rpr(opts)
  local s = ""
  if opts.b then s = s .. "<w:b/><w:bCs/>" end
  if opts.i then s = s .. "<w:i/><w:iCs/>" end
  if opts.caps then s = s .. "<w:caps/>" end
  return s
end

local function run(text, opts)
  local rp = rpr(opts or {})
  local rpx = rp ~= "" and ("<w:rPr>" .. rp .. "</w:rPr>") or ""
  return '<w:r>' .. rpx .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local TAB = '<w:r><w:tab/></w:r>'

-- paragraph properties in schema order: keepNext, keepLines, pageBreakBefore, framePr, pBdr, spacing, ind, jc, sectPr
local function ppr(o)
  o = o or {}
  local s = ""
  if o.style then s = s .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keepNext then s = s .. "<w:keepNext/>" end
  if o.keepLines then s = s .. "<w:keepLines/>" end
  if o.pageBreakBefore then s = s .. "<w:pageBreakBefore/>" end
  if o.frame then s = s .. o.frame end
  if o.border then s = s .. '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>' end
  if o.tabs then s = s .. o.tabs end
  s = s .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>',
    o.before or 0, o.after or 0, o.line or 336)
  if o.left or o.right or o.firstLine or o.hanging then
    local a = ""
    if o.left then a = a .. string.format(' w:left="%d"', o.left) end
    if o.right then a = a .. string.format(' w:right="%d"', o.right) end
    if o.firstLine then a = a .. string.format(' w:firstLine="%d"', o.firstLine) end
    s = s .. "<w:ind" .. a .. "/>"
  end
  if o.jc then s = s .. '<w:jc w:val="' .. o.jc .. '"/>' end
  if o.outline then s = s .. '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  if o.sect then s = s .. o.sect end
  return s
end

local function P(o, inner)
  return pandoc.RawBlock("openxml", "<w:p><w:pPr>" .. ppr(o) .. "</w:pPr>" .. (inner or "") .. "</w:p>")
end

-- section properties: page size and margins, the footer (if any), the page-number format
local function sect(bottom, footer, fmt, start)
  local f = footer and ('<w:footerReference w:type="default" r:id="rIdNmccaFooter"/>') or ""
  local pn = fmt and string.format('<w:pgNumType w:fmt="%s" w:start="%d"/>', fmt, start or 1) or ""
  return '<w:sectPr>' .. f .. '<w:pgSz w:w="12240" w:h="15840"/>' ..
    string.format('<w:pgMar w:top="1440" w:right="1440" w:bottom="%d" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>', bottom) ..
    pn .. '</w:sectPr>'
end

-- a section break: an empty paragraph of 1 pt carrying the sectPr of the section that ends here
local function section_break(bottom, footer, fmt, start)
  return P({ line = 20, sect = sect(bottom, footer, fmt, start) }, '<w:r><w:rPr><w:sz w:val="2"/></w:rPr></w:r>')
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover(): Appendix I, NMCCA-FORM-004)
-- ---------------------------------------------------------------------------

local function cell(width, blocks)
  local parts = {}
  for _, b in ipairs(blocks) do parts[#parts + 1] = b.text end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. table.concat(parts) .. '</w:tc>'
end

local function cover_blocks(out)
  local B = { b = true }
  out[#out + 1] = P({ jc = "center" }, run("IN THE UNITED STATES NAVY-MARINE CORPS", B))
  out[#out + 1] = P({ jc = "center" }, run("COURT OF CRIMINAL APPEALS", B))
  out[#out + 1] = P({ jc = "center", before = 336 }, run("Before " .. meta_str("panel")))

  -- caption: two columns (1fr, 1fr) with a 14 pt gutter; left: parties, right: number and title
  local left = {}
  local function lp(before, text, o, opts)
    local oo = { before = before, jc = o and o.jc or nil }
    left[#left + 1] = P(oo, run(text, opts))
  end
  lp(0, meta_str("appellee"), nil, {})
  lp(252, meta_str("appellee_role"), { jc = "center" }, {})
  lp(252, "v.", nil, {})
  lp(252, meta_str("appellant"), nil, {})
  for _, l in ipairs(meta_list("appellant_lines")) do lp(0, l, nil, { i = true }) end
  lp(252, meta_str("appellant_role"), { jc = "center" }, {})
  local right = {}

  right[#right + 1] = P({}, run("NMCCA No. " .. meta_str("nmcca_no")))
  right[#right + 1] = P({ before = 252 }, run(string.upper(meta_str("title")), B))
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4540"/><w:gridCol w:w="280"/><w:gridCol w:w="4540"/></w:tblGrid>' ..
    '<w:tr>' .. cell(4540, left) .. cell(280, { P({}) }) ..
    cell(4540, right) .. '</w:tr></w:tbl>'
  out[#out + 1] = pandoc.RawBlock("openxml", tbl)

  out[#out + 1] = P({ before = 504, jc = "center" }, run("TO THE HONORABLE, THE JUDGES OF THE UNITED STATES", B))
  out[#out + 1] = P({ jc = "center" }, run("NAVY-MARINE CORPS COURT OF CRIMINAL APPEALS", B))
  out[#out + 1] = P({ before = 336 }, run(meta_str("tried_at")))

  -- counsel block, pinned to the foot of the cover (the 2 in bottom margin ends the text area at
  -- 15840 - 2880 twips); a frame at the page position, so it does not depend on the lines above
  local counsel = meta_list("counsel")
  local h = 336 * #counsel
  local y = (PAGE_H - 2880) - h
  local frame = string.format('<w:framePr w:w="5040" w:h="%d" w:hRule="exact" w:hSpace="0" w:wrap="around" ' ..
    'w:vAnchor="page" w:hAnchor="page" w:x="5760" w:y="%d"/>', h, y)
  for _, l in ipairs(counsel) do out[#out + 1] = P({ frame = frame }, run(l)) end
end

-- ---------------------------------------------------------------------------
-- Heading labels (typst heading-labels(); NMCCA-CONT-004)
-- ---------------------------------------------------------------------------

local UNLAB = { ["standard of review"] = true, ["principles of law"] = true, discussion = true, conclusion = true }

local function upper_roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

local function label_text(kind, n)
  if kind == "R" then return upper_roman(n) .. "." end
  if kind == "A" then return string.char(64 + n) .. "." end
  if kind == "a" then return string.char(96 + n) .. "." end
  if kind == "n" then return tostring(n) .. "." end
  return "(" .. tostring(n) .. ")"
end

local ARG_KINDS = { "R", "A", "n", "a" }
local OTH_KINDS = { "A", "n", "a", "p" }

-- ---------------------------------------------------------------------------
-- Index of brief (typst outline, depth 2): page numbers from NMCCA_PAGES (pass 2)
-- ---------------------------------------------------------------------------

local function read_pages()
  local path = os.getenv("NMCCA_PAGES")
  local pages = {}
  if not path then return pages end
  local f = io.open(path, "r")
  if not f then return pages end
  for line in f:lines() do pages[#pages + 1] = line end
  f:close()
  return pages
end

local function index_blocks(entries, pages, out)
  out[#out + 1] = P({ jc = "center" }, run("INDEX OF BRIEF", { b = true }))
  local first = true
  for k, e in ipairs(entries) do
    if e.level <= 2 then
      local before = first and 336 or 0
      first = false
      local tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/></w:tabs>'
      local pg = pages[k] or ""
      out[#out + 1] = P({ tabs = tabs, before = before, after = 168, left = (e.level == 2) and 420 or 0 },
        run(e.text) .. TAB .. run(pg))
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate (typst signature-block(), certificate())
-- ---------------------------------------------------------------------------

local function signature(out, lead)
  local signer, lines = meta_sig()
  local SIG = { keepNext = true, keepLines = true, left = 4320 }
  local function sp(o, inner)
    local t = {}
    for k, v in pairs(SIG) do t[k] = v end
    for k, v in pairs(o or {}) do t[k] = v end
    return P(t, inner)
  end
  if lead then
    out[#out + 1] = sp({ before = 336 }, run("Respectfully submitted."))
  end
  out[#out + 1] = sp({ before = 672, right = 720, border = true, keepNext = true }, "")
  out[#out + 1] = sp({ before = 0 }, run(signer))
  for _, l in ipairs(lines) do out[#out + 1] = sp({ keepNext = true }, run(l, { i = true })) end
end

local function certificate(out)
  out[#out + 1] = P({ keepNext = true, pageBreakBefore = true, jc = "center" }, run("CERTIFICATE OF FILING AND SERVICE", { b = true }))
  out[#out + 1] = P({ before = 336, line = 672, firstLine = 720, keepNext = true },
    run("I certify that the foregoing was delivered to the Navy-Marine Corps Court of Criminal Appeals, and that a copy was served on " ..
      meta_str("served_on") .. " on " .. meta_str("date") .. "."))
  signature(out, false)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function heading_blocks(blocks)
  -- collect headings in document order (top level); assign labels and the argument italics
  local counts = { 0, 0, 0, 0, 0, 0 }
  local arg = false
  local heads = {}
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local text = trim(pandoc.utils.stringify(b.content))
      local t = lower(text)
      local lvl = b.level
      heads[#heads + 1] = { level = lvl, text = text }
      if lvl == 1 then
        arg = (t == "argument")
        counts = { 0, 0, 0, 0, 0, 0 }
        out[#out + 1] = b
      else
        for j = lvl + 1, 6 do counts[j] = 0 end
        local content = b.content
        if lvl == 2 and arg then
          content = { pandoc.Emph(content) }
        end
        if UNLAB[t] or lvl > 5 then
          out[#out + 1] = pandoc.Header(lvl, content, b.attr)
        else
          counts[lvl] = counts[lvl] + 1
          local kinds = arg and ARG_KINDS or OTH_KINDS
          local kind = kinds[lvl - 1]
          local label = label_text(kind, counts[lvl])
          local inl = { pandoc.Str(label), pandoc.RawInline("openxml", TAB) }
          for _, x in ipairs(content) do inl[#inl + 1] = x end
          local h = pandoc.Header(lvl, inl, b.attr)
          out[#out + 1] = h
        end
      end
    else
      out[#out + 1] = b
    end
  end
  return out, heads
end

local function write_file(path, lines)
  local f = io.open(path, "w")
  if not f then return end
  for _, l in ipairs(lines) do f:write(l, "\n") end
  f:close()
end

function Pandoc(doc)
  META = {}
  for k, v in pairs(doc.meta) do META[k] = v end
  doc.meta.title = nil
  doc.meta.date = nil
  local body, heads = heading_blocks(doc.blocks)

  local headpath = os.getenv("NMCCA_HEADINGS")
  if headpath then
    local lines = {}
    for _, h in ipairs(heads) do lines[#lines + 1] = h.level .. "\t" .. h.text end
    write_file(headpath, lines)
  end

  -- the first heading of the body sits at the top of its page: no space before (typst: none at a page top)
  if body[1] and body[1].t == "Header" and body[1].level == 1 then
    local plain = true
    for _, x in ipairs(body[1].content) do
      if x.t ~= "Str" and x.t ~= "Space" then plain = false end
    end
    if plain then
      body[1] = P({ style = "Heading1", before = 0, after = 0, jc = "center", outline = 0 },
        run(pandoc.utils.stringify(body[1].content)))
    end
  end
  local pages = read_pages()
  local out = {}
  cover_blocks(out)
  out[#out + 1] = section_break(2880, false, nil)
  index_blocks(heads, pages, out)
  out[#out + 1] = section_break(1440, true, "lowerRoman", 2)
  -- the last paragraph of the body moves with the signature block (no signature alone on a page);
  -- it keeps the first-paragraph form when it follows a heading (typst: no indent after a heading)
  local prev = nil
  for i, b in ipairs(body) do
    if i == #body and b.t == "Para" then
      local style = (prev and (prev.t == "Header" or prev.t == "Div")) and "Body Keep With Next First" or "Body Keep With Next"
      b = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = style }))
    end
    out[#out + 1] = b
    prev = b
  end
  signature(out, true)
  certificate(out)
  return pandoc.Pandoc(out, doc.meta)
end

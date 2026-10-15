-- iasd motion brief, docx engine (docs/DOCX.md). Mirrors typst/iasd-motion-brief.typ:
--   * front matter in its own section, numbered i, ii, ... (the footer reference is a placeholder that
--     docx/render.sh replaces with pandoc's footer part): cover (caption, title, ORAL ARGUMENT REQUESTED),
--     table of contents, table of authorities; the body starts again at 1;
--   * headings: level 1 centered bold capitals; levels 2 to 4 labelled I., A., 1. with a hanging indent
--     (the labels are typed here; the template numbers them);
--   * table of authorities built from the toa: links, grouped as in the template; authority links are shown as text;
--   * signature block (LR 11): date on the left, signature lines at the caption's party column.
-- BLOCKED (docs/DOCX.md, "Fields"): the table of contents and table of authorities have no page numbers: the
-- page of each heading and authority is not computed here (no layout engine), so the entries end in an empty
-- page column. See the README, Engines.
-- Content-agnostic: every case word comes from the sample's frontmatter.
local SIG_INDENT = 4968 -- twips: 3.25 in caption column + 0.2 in gutter, as the typst signature block
local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "other", "Other Authorities" } }
local ROMAN_UP = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI",
  "XVII", "XVIII", "XIX", "XX" }

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function need(meta, k)
  if meta[k] == nil then error("iasd-motion-brief.lua: frontmatter field `" .. k .. "` is required") end
  return meta[k]
end

local function rb(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- A run of text in raw WordprocessingML.
local function run(s, o)
  o = o or {}
  local rpr = ""
  if o.bold or o.italic then
    rpr = "<w:rPr>" .. (o.bold and "<w:b/><w:bCs/>" or "") .. (o.italic and "<w:i/><w:iCs/>" or "") .. "</w:rPr>"
  end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

local TAB = "<w:r><w:tab/></w:r>"

-- A raw paragraph. o.runs (XML) replaces the text; o.line: 280 single, 480 double (twips, exact).
local function p(s, o)
  o = o or {}
  local tabs = o.dot and '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs>' or ""
  local ppr = "<w:pPr>" .. (o.keep and "<w:keepNext/>" or "") .. tabs
    .. '<w:spacing w:before="0" w:after="' .. (o.after or 0) .. '" w:line="' .. (o.line or 280) .. '" w:lineRule="exact"/>'
    .. '<w:ind w:left="' .. (o.left or 0) .. '"'
    .. (o.hanging and (' w:hanging="' .. o.hanging .. '"') or ' w:firstLine="0"') .. "/>"
    .. (o.jc and ('<w:jc w:val="' .. o.jc .. '"/>') or "")
    .. "</w:pPr>"
  local body = o.xml or (s ~= "" and run(s, { bold = o.bold }) or "")
  return "<w:p>" .. ppr .. body .. "</w:p>"
end

local function page_break()
  return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
end

local BORDER_NONE = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'

-- The caption: party column (4680 twips, bottom and right rule), gutter (288), case number, title, oral argument.
local function caption_table(meta)
  local cap = need(meta, "caption")
  local versus = cap.versus and text(cap.versus) or "v."
  local left = {}
  for k, party in ipairs(cap.parties) do
    if k > 1 then left[#left + 1] = p(versus) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(text(n)) end
    left[#left + 1] = p(text(party.designation))
  end
  local right = {
    p("Case No. " .. text(need(meta, "case_number")), { after = 240 }),
    p(string.upper(text(need(meta, "brief_title"))), { bold = true, after = 240 }),
  }
  if meta.oral_argument == true then
    right[#right + 1] = p("ORAL ARGUMENT REQUESTED", { bold = true })
  end
  return "<w:tbl><w:tblPr><w:tblW w:w=\"9360\" w:type=\"dxa\"/><w:tblBorders>" .. BORDER_NONE
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="288"/><w:gridCol w:w="4392"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders><w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. p("") .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4392" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. "</w:tc>"
    .. "</w:tr></w:tbl>"
end

local function court_title(meta)
  return p("IN THE UNITED STATES DISTRICT COURT", { bold = true, jc = "center" })
    .. p("FOR THE SOUTHERN DISTRICT OF IOWA", { bold = true, jc = "center" })
    .. p(string.upper(text(need(meta, "division"))), { bold = true, jc = "center", after = 480 })
end

-- Headings in document order: { level, label (nil at level 1), text }. Levels 2 to 4 are labelled as the template
-- labels them; the counters reset below each level, as the typst heading counter does.
local function heading_list(doc)
  local counts = { 0, 0, 0, 0 }
  local heads = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level > 4 then error("iasd-motion-brief.lua: headings deeper than level 4 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 4 do counts[k] = 0 end
      local lab = nil
      if b.level == 2 then lab = ROMAN_UP[counts[2]] .. "." end
      if b.level == 3 then lab = string.char(64 + counts[3]) .. "." end
      if b.level == 4 then lab = counts[4] .. "." end
      heads[#heads + 1] = { level = b.level, label = lab, text = text(b.content) }
    end
  end
  return heads
end

-- Authority keys in the order the body links to them (footnotes included), without repeats.
local function toa_keys(doc)
  local keys, seen = {}, {}
  doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) == "toa:" then
        local k = el.target:sub(5)
        if not seen[k] then
          seen[k] = true
          keys[#keys + 1] = k
        end
      end
    end,
  })
  return keys, seen
end

local function toc_section(heads)
  local out = { p("TABLE OF CONTENTS", { bold = true, jc = "center", line = 480, keep = true }) }
  out[#out + 1] = p("Page", { bold = true, jc = "right", after = 240, keep = true })
  for _, h in ipairs(heads) do
    if h.level == 1 then
      out[#out + 1] = p("", { dot = true, after = 120, line = 480,
        xml = run(string.upper(h.text)) .. TAB .. "" })
    else
      local left = (h.level - 2) * 720 + 720
      out[#out + 1] = p("", { dot = true, after = 120, left = left, hanging = 720,
        xml = run(h.label) .. TAB .. run(h.text) .. TAB })
    end
  end
  return table.concat(out)
end

local function toa_section(meta, keys, seen)
  local authorities = meta.authorities or {}
  for _, k in ipairs(keys) do
    if authorities[k] == nil then
      error("iasd-motion-brief.lua: link `toa:" .. k .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  local out = { p("TABLE OF AUTHORITIES", { bold = true, jc = "center", line = 480, keep = true }) }
  out[#out + 1] = p("Page(s)", { bold = true, jc = "right", after = 240, keep = true })
  for _, g in ipairs(GROUPS) do
    local kind, title = g[1], g[2]
    local members = {}
    for _, k in ipairs(keys) do
      if text(authorities[k].kind) == kind then members[#members + 1] = k end
    end
    local function sort_key(k)
      local a = authorities[k]
      return string.lower(a.name and text(a.name) or text(a.cite))
    end
    table.sort(members, function(x, y) return sort_key(x) < sort_key(y) end)
    if #members > 0 then
      out[#out + 1] = p(title, { bold = true, after = 120, keep = true })
      for _, k in ipairs(members) do
        local a = authorities[k]
        local xml = ""
        if a.name then
          xml = run(text(a.name), { italic = kind == "case" }) .. run(", ")
        end
        xml = xml .. run(text(a.cite))
        out[#out + 1] = p("", { dot = true, after = 120, left = 504, hanging = 504, xml = xml .. TAB })
      end
    end
  end
  return table.concat(out)
end

-- The section break ending the front matter: roman numbers, footer part as pandoc wrote it (placeholder).
local function front_section_break()
  return '<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="rIdFooterFront" />'
    .. '<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />'
    .. '<w:pgNumType w:fmt="lowerRoman" w:start="1" /></w:sectPr></w:pPr></w:p>'
end

-- A non-breaking space after a section or paragraph sign, so the sign stays with its number.
local function nbsp_signs(inlines)
  local out = {}
  for i, x in ipairs(inlines) do
    local prev = inlines[i - 1]
    if x.t == "Space" and prev and prev.t == "Str" and (prev.text == "§" or prev.text == "¶") then
      out[#out + 1] = pandoc.Str("\u{a0}")
    else
      out[#out + 1] = x
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local heads = heading_list(doc)
  local keys, seen = toa_keys(doc)

  local out = {}
  -- Cover (roman i)
  out[#out + 1] = rb(court_title(meta) .. caption_table(meta) .. page_break())
  -- Table of contents and table of authorities (roman ii, iii, ...). BLOCKED: no page numbers (see the header).
  out[#out + 1] = rb(toc_section(heads) .. page_break())
  out[#out + 1] = rb(toa_section(meta, keys, seen))
  out[#out + 1] = rb(front_section_break())

  -- Body (arabic from 1): headings get their labels, the rest is pandoc's.
  local h = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      h = h + 1
      if b.level >= 2 then
        local lab = heads[h].label
        local content = { pandoc.Str(lab), pandoc.RawInline("openxml", TAB) }
        for _, x in ipairs(b.content) do content[#content + 1] = x end
        b.content = content
      end
    end
    out[#out + 1] = b
  end

  -- Signature block (LR 11): the date at the margin, the signature lines at the caption's party column.
  local sig = need(meta, "signature")
  out[#out + 1] = rb(p(text(sig.date), { after = 240, line = 280, keep = true }))
  for _, l in ipairs(sig.lines) do
    out[#out + 1] = rb(p(text(l), { left = SIG_INDENT, line = 280 }))
  end

  local result = pandoc.Pandoc(out, pandoc.Meta({}))
  return result:walk({
    Inlines = nbsp_signs,
    Link = function(el)
      if el.target:sub(1, 4) == "toa:" then return el.content end
      return nil
    end,
  })
end

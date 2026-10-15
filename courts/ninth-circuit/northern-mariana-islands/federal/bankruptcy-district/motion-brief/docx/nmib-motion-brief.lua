-- NMIB motion with memorandum, DOCX engine (docs/DOCX.md). The markdown contract of
-- typst/nmib-motion-brief.typ, as Word XML on docx/reference.docx:
--   section 1, the cover: counsel block (single spaced), role, court title, caption table (a right and
--   bottom rule on the party column; hearing data on the right), no page number;
--   section 2, the table of contents (a TOC field) and the table of authorities, numbered i, ii, ...;
--   section 3, the body, numbered 1, 2, ...: headings get their labels (A., 1., a.) here, the signature block.
-- Every case-specific word comes from the sample's YAML frontmatter, never from this file.
-- Known limits (BLOCKED, see README.md "Engines"): the TOC page numbers appear after Word updates fields (on
-- open) and are not in LibreOffice's first render; the table of authorities lists the authorities without
-- page numbers (a TOA field is not honored by LibreOffice); the caption and the signature are tables, which
-- Word's line numbering does not number; the counsel block is single spaced, not on the 24-point grid.

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function run(s, bold, italic)
  local rpr = ""
  if bold then rpr = rpr .. "<w:b/>" end
  if italic then rpr = rpr .. "<w:i/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

-- one paragraph: style, optional pPr children in schema order (pBdr, spacing, ind, jc), runs
local function para(style, runs, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or '') .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

-- one numbered line of space (24 pt exact), for the spacing the typst form puts between blocks
local PITCH_LINE = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
local function spacer()
  return para("Single", '', PITCH_LINE)
end

local function page_break()
  return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
end

-- section break (ends the section above). footer: the page-number footer; fmt: page number format
local function section_break(footer, fmt)
  local refs = footer and '<w:footerReference w:type="default" r:id="rId900"/>' or ''
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ''
  return '<w:p><w:pPr><w:sectPr>' .. refs
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="1440" w:bottom="1440" w:left="1872" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders>'
    .. '<w:lnNumType w:countBy="1" w:distance="576" w:restart="newPage"/>' .. pg .. '<w:cols w:space="720"/></w:sectPr></w:pPr></w:p>'
end

-- a borderless 2-column table (widths in twips); the left cell may carry a right and a bottom rule
local function two_col(left_xml, right_xml, lw, rw, left_rules)
  local rules = ''
  if left_rules then
    rules = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
      .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (lw + rw) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. lw .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. lw .. '" w:type="dxa"/>' .. rules
    .. '<w:tcMar><w:right w:w="240" w:type="dxa"/></w:tcMar></w:tcPr>' .. left_xml .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. rw .. '" w:type="dxa"/><w:tcMar><w:left w:w="240" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. right_xml .. '</w:tc></w:tr></w:tbl>'
end

-- text width 6.2 in = 8928 twips
local TEXT_W = 8928

-- signers: the frontmatter gives a list of {signer, lines} (or one map)
local function signers(meta)
  local s = meta.signature or {}
  if s.signer ~= nil then return { s } end
  local out = {}
  for _, x in ipairs(s) do out[#out + 1] = x end
  return out
end

local function cover(meta)
  local out = {}
  for _, l in ipairs(meta.counsel or {}) do out[#out + 1] = para("Single", run(str(l))) end
  out[#out + 1] = para("Single", run(str(meta.counsel_role), false, true), '<w:spacing w:before="120" w:after="0" w:line="240" w:lineRule="auto"/>')
  out[#out + 1] = spacer()
  for _, l in ipairs(meta.court or {}) do
    out[#out + 1] = para("Centered", run(str(l):upper(), true))
  end
  out[#out + 1] = spacer()
  -- caption: each side with its designation (indented 1 in), "v." between the sides
  local left, sides = {}, meta.caption or {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names or {}) do left[#left + 1] = para("Single", run(str(n))) end
    left[#left + 1] = para("Single", run(str(side.designation)), '<w:ind w:left="1440"/>')
    if i < #sides then
      left[#left + 1] = para("Centered", run("v."), '<w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/>')
    end
  end
  -- right: case number, chapter, the title, then the hearing (LBR 5005-1(b)) when the paper has one
  local right = {
    para("Single", run("Case No. " .. str(meta.case_number))),
    para("Single", run("Chapter " .. str(meta.chapter)), '<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/>'),
    para("Single", run(str(meta.brief_title):upper(), true), '<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/>'),
  }
  local hearing = meta.hearing or {}
  for _, kv in ipairs({ { "date", "Hearing Date:" }, { "time", "Hearing Time:" }, { "judge", "Judge:" } }) do
    if hearing[kv[1]] ~= nil then
      right[#right + 1] = para("Single", run(kv[2] .. " " .. str(hearing[kv[1]])))
    end
  end
  out[#out + 1] = two_col(table.concat(left), table.concat(right), 4464, 4464, true)
  return out
end

-- the table of contents (a field; Word and LibreOffice fill it when fields are updated) and the table of authorities
local function front_matter(meta, used)
  local out = {}
  out[#out + 1] = para("TOCHeading", run("Table of Contents"))
  out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr>'
    .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h \\z \\u </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. '<w:r><w:t>Table of contents: update fields to show the page numbers.</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  out[#out + 1] = page_break()
  out[#out + 1] = para("TOCHeading", run("Table of Authorities"))
  local auth = meta.authorities or {}
  local groups = {
    { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" },
    { "local", "Local Bankruptcy Rules" }, { "other", "Other Authorities" },
  }
  for _, g in ipairs(groups) do
    local members = {}
    for key, a in pairs(auth) do
      if used[key] and str(a.kind) == g[1] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      local kx = str(x.a.name ~= nil and x.a.name or x.a.cite):lower()
      local ky = str(y.a.name ~= nil and y.a.name or y.a.cite):lower()
      return kx < ky
    end)
    if #members > 0 then
      out[#out + 1] = para("Single", run(g[2], true), '<w:spacing w:before="360" w:after="120" w:line="240" w:lineRule="auto"/>')
      for _, m in ipairs(members) do
        local runs = ''
        if m.a.name ~= nil then
          runs = run(str(m.a.name), false, str(m.a.kind) == "case") .. run(", ")
        end
        runs = runs .. run(str(m.a.cite))
        -- page numbers are not computed here (see README.md, BLOCKED); the entry is listed without them
        out[#out + 1] = para("Single", runs, '<w:spacing w:before="120" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="504" w:hanging="504"/>')
      end
    end
  end
  return out
end

local function signature(meta)
  local left = para("Single", run("Dated: " .. str(meta.date)))
  local right = { para("Single", run("Respectfully submitted,")) }
  for _, s in ipairs(signers(meta)) do
    right[#right + 1] = spacer()
    right[#right + 1] = para("Single", run("/s/"), '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr><w:ind w:right="864"/>')
    right[#right + 1] = para("Single", run(str(s.signer)))
    for _, l in ipairs(s.lines or {}) do right[#right + 1] = para("Single", run(str(l))) end
  end
  return { spacer(), two_col(left, table.concat(right), TEXT_W - 4608, 4608, false) }
end

-- heading labels: level 2 "A.", level 3 "1.", level 4 "a."; a level 1 heading starts the lettering again
local ctr = { 0, 0, 0, 0 }
local function label(level)
  ctr[level] = ctr[level] + 1
  for i = level + 1, 4 do ctr[i] = 0 end
  if level == 2 then return string.char(64 + ctr[2]) .. "." end
  if level == 3 then return tostring(ctr[3]) .. "." end
  return string.char(96 + ctr[4]) .. "."
end

function Pandoc(doc)
  local meta = doc.meta
  local auth = meta.authorities or {}
  local used = {}
  -- authority links: the link text stays; a key with no entry under authorities: is an error
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if auth[key] == nil then error("nmib-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      return el.content
    end,
  })

  local function raw(b)
    if type(b) == "string" then return pandoc.RawBlock("openxml", b) end
    return b
  end

  local blocks = {}
  local function add(list)
    for _, b in ipairs(list) do blocks[#blocks + 1] = raw(b) end
  end

  add(cover(meta))
  add({ section_break(false, nil) })
  -- the front matter needs the authorities cited in the body, so the body is walked first
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        for i = 2, 4 do ctr[i] = 0 end
      else
        table.insert(b.content, 1, pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>'))
        table.insert(b.content, 1, pandoc.Str(label(b.level)))
      end
    end
    body[#body + 1] = b
  end
  add(front_matter(meta, used))
  add({ section_break(true, "lowerRoman") })
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  add(signature(meta))
  -- pandoc would print the date metadata as a title block; the date is printed in the signature block instead
  meta.date = nil
  return pandoc.Pandoc(blocks, meta)
end

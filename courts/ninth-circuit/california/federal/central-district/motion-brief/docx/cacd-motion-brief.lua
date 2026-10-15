-- C.D. Cal. motion (notice of motion, memorandum, certificate), DOCX engine (docs/DOCX.md): markdown contract ->
-- Word document on reference.docx. Mirrors typst/cacd-motion-brief.typ:
--   cover (counsel from line 1, court title, caption with hearing details; no page number, no footer);
--   notice of motion (arabic from 1), signature block;
--   table of contents and table of authorities (roman from i; built from the headings and the toa: links);
--   memorandum (arabic from 1): headings numbered I., A. by the filter, double-spaced body, signature block;
--   certificate of compliance on its own page (L.R. 11-6.2).
-- Sections are set by sectPr paragraphs (one-twip paragraphs at the end of each section); the last section's
-- sectPr is the reference's. Known limit (BLOCKED, see README "Engines"): the table of contents and the table of
-- authorities list the entries without page numbers; a two-pass page lookup is not done here.
-- Every case word comes from the sample's frontmatter or body, never from this file.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, rpr)
  local pr = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. pr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function para(style, inner)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. inner .. "</w:p>"
end

-- an empty paragraph of exact height `twips` (a vertical space on the grid)
local function spacer(twips)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- a one-twip paragraph that ends a section or carries a page break (no blank line is left on the next page)
local function sect_break(fmt, start, footer)
  local refs = '<w:headerReference w:type="default" r:id="rId101"/>'
  if footer then refs = refs .. '<w:footerReference w:type="default" r:id="rId100"/>' end
  local num = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or ""
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>' .. refs
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="144" w:gutter="0"/>'
    .. '<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="auto"/><w:right w:val="single" w:sz="4" w:space="7" w:color="auto"/></w:pgBorders>'
    .. num .. "</w:sectPr></w:pPr></w:p>"
end

local function heading_xml(text, new_page)
  -- a level-1 heading (centered, caps); a new page starts with the heading itself (no page-break run)
  return '<w:p><w:pPr><w:pStyle w:val="Heading1"/>' .. (new_page and "<w:pageBreakBefore/>" or "") .. '</w:pPr>' .. run(text) .. "</w:p>"
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function need(meta, key)
  if meta[key] == nil then error("cacd-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- a metadata value as a list of inlines (markdown in the YAML is already parsed by pandoc)
local function inlines_of(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return { pandoc.Str(plain(v)) }
end

local function strings(list)
  local out = {}
  for _, v in ipairs(list) do out[#out + 1] = plain(v) end
  return out
end

local function counsel_xml(lines)
  local n = #lines
  local xml = {}
  for _, l in ipairs(lines) do xml[#xml + 1] = para("Single", run(l)) end
  local total = math.max(7, math.ceil(n * 16 / 24)) * 24 * 20 -- twips
  local pad = total - n * 320
  if pad > 0 then xml[#xml + 1] = spacer(pad) end
  return table.concat(xml)
end

local function caption_xml(meta)
  local left = {}
  for k, p in ipairs(need(meta, "caption")) do
    if k > 1 then left[#left + 1] = para("Single", run("v.")) end
    for _, nm in ipairs(strings(p.names)) do left[#left + 1] = para("Single", run(nm)) end
    left[#left + 1] = para("Single", run(plain(p.designation)))
  end
  local hearing = need(meta, "hearing")
  local right = {}
  right[#right + 1] = para("Single", run("Case No. " .. plain(need(meta, "case_number"))))
  right[#right + 1] = spacer(240)
  right[#right + 1] = para("Single", run(plain(need(meta, "brief_title")), "<w:b/><w:bCs/>"))
  right[#right + 1] = spacer(240)
  for _, kv in ipairs({ { "date", "Date:" }, { "time", "Time:" }, { "place", "Courtroom:" }, { "judge", "Judge:" } }) do
    if hearing[kv[1]] ~= nil then right[#right + 1] = para("Single", run(kv[2] .. " " .. plain(hearing[kv[1]]))) end
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="3888"/><w:gridCol w:w="288"/><w:gridCol w:w="4824"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3888" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="auto"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="auto"/></w:tcBorders>'
    .. '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4824" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. "</w:tc></w:tr></w:tbl>"
end

local function signature_xml(meta)
  local sig = need(meta, "signature")
  local left = para("Normal", run("Dated: " .. plain(need(meta, "date"))))
  local right = {}
  right[#right + 1] = para("Single", run("Respectfully submitted,"))
  right[#right + 1] = spacer(240)
  for _, f in ipairs(strings(sig.firm or {})) do right[#right + 1] = para("Single", run(f)) end
  right[#right + 1] = spacer(240)
  right[#right + 1] = para("Single", run("By: /s/ " .. plain(sig.signer)))
  right[#right + 1] = para("Single", run(plain(sig.signer)))
  for _, l in ipairs(strings(sig.lines or {})) do right[#right + 1] = para("Single", run(l)) end
  return '<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="3744"/><w:gridCol w:w="288"/><w:gridCol w:w="4968"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/></w:tcPr>' .. left .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4968" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. "</w:tc></w:tr></w:tbl>"
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do
      s = s .. v[2]
      n = n - v[1]
    end
  end
  return s
end

local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" }, { "other", "Other Authorities" },
}

function Pandoc(doc)
  local meta = doc.meta
  doc.meta = pandoc.Meta({})
  for _, k in ipairs({ "case_number", "counsel", "caption", "brief_title", "footer_title", "hearing", "notice",
    "signature", "date", "certificate_party", "word_count" }) do
    need(meta, k)
  end
  local authorities = meta.authorities or {}

  -- authority links: every toa:KEY must have a registry entry; the link keeps its text
  local used = {}
  local order = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if authorities[key] == nil then error("cacd-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      if not used[key] then
        used[key] = true
        order[#order + 1] = key
      end
      return el.content
    end,
  })

  -- headings and their labels: level 2 I., II. ...; level 3 A., B. ... (restarting under each level 2)
  local headings = {}
  local c2, c3 = 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local label = ""
      if b.level == 2 then
        c2 = c2 + 1
        c3 = 0
        label = roman(c2) .. "."
      elseif b.level == 3 then
        c3 = c3 + 1
        label = string.char(64 + c3) .. "."
      elseif b.level ~= 1 then
        error("cacd-motion-brief: heading level " .. b.level .. " is not in the template (levels 1 to 3)", 0)
      end
      headings[#headings + 1] = { level = b.level, content = b.content, label = label }
    end
  end

  local blocks = {}
  local function add(x) blocks[#blocks + 1] = x end

  -- cover: no page number, no footer (section 1)
  add(pandoc.RawBlock("openxml", counsel_xml(strings(need(meta, "counsel")))))
  add(pandoc.RawBlock("openxml", para("CourtTitle", run("UNITED STATES DISTRICT COURT"))))
  add(pandoc.RawBlock("openxml", para("CourtTitle", run("CENTRAL DISTRICT OF CALIFORNIA"))))
  if meta.division ~= nil then
    add(pandoc.RawBlock("openxml", para("CourtTitle", run(plain(meta.division):upper()))))
  end
  add(pandoc.RawBlock("openxml", spacer(480)))
  add(pandoc.RawBlock("openxml", caption_xml(meta)))
  add(pandoc.RawBlock("openxml", sect_break(nil, nil, false)))

  -- notice of motion (section 2, arabic from 1)
  add(pandoc.Para({ pandoc.Str("TO PLAINTIFF AND ITS ATTORNEYS OF RECORD:") }))
  for _, p in ipairs(need(meta, "notice")) do
    add(pandoc.Div({ pandoc.Para(inlines_of(p)) }, pandoc.Attr("", {}, { ["custom-style"] = "BodyPara" })))
  end
  add(pandoc.RawBlock("openxml", signature_xml(meta)))
  add(pandoc.RawBlock("openxml", sect_break("decimal", 1, true)))

  -- table of contents (section 3, roman from i)
  add(pandoc.RawBlock("openxml", heading_xml("Table of Contents", false)))
  add(pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="TocHead"/><w:jc w:val="right"/></w:pPr>' .. run("Page") .. "</w:p>"))
  for _, h in ipairs(headings) do
    local inl = {}
    if h.label ~= "" then
      inl[#inl + 1] = pandoc.Str(h.label)
      inl[#inl + 1] = TAB
    end
    for _, x in ipairs(h.content) do inl[#inl + 1] = x end
    inl[#inl + 1] = TAB
    local style = h.level == 3 and "TocEntry3" or "TocEntry"
    add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style })))
  end

  -- table of authorities: the registry entries used in the body, by group, sorted
  add(pandoc.RawBlock("openxml", heading_xml("Table of Authorities", true)))
  add(pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="TocHead"/><w:jc w:val="right"/></w:pPr>' .. run("Page(s)") .. "</w:p>"))
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for _, key in ipairs(order) do
      local a = authorities[key]
      if plain(a.kind) == g[1] then members[#members + 1] = key end
    end
    table.sort(members, function(x, y)
      local ax, ay = authorities[x], authorities[y]
      local kx = (ax.name and plain(ax.name) or plain(ax.cite)):lower()
      local ky = (ay.name and plain(ay.name) or plain(ay.cite)):lower()
      return kx < ky
    end)
    if #members > 0 then
      add(pandoc.Div({ pandoc.Para({ pandoc.Str(g[2]) }) }, pandoc.Attr("", {}, { ["custom-style"] = "ToaGroup" })))
      for _, key in ipairs(members) do
        local a = authorities[key]
        local inl = {}
        if a.name ~= nil then
          local name = inlines_of(a.name)
          if plain(a.kind) == "case" then
            inl[#inl + 1] = pandoc.Emph(name)
          else
            for _, x in ipairs(name) do inl[#inl + 1] = x end
          end
          inl[#inl + 1] = pandoc.Str(", ")
        end
        for _, x in ipairs(inlines_of(a.cite)) do inl[#inl + 1] = x end
        inl[#inl + 1] = TAB
        add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "ToaEntry" })))
      end
    end
  end
  add(pandoc.RawBlock("openxml", sect_break("lowerRoman", 1, true)))

  -- memorandum (section 4, the final section, arabic from 1)
  local hi = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      hi = hi + 1
      local h = headings[hi]
      if b.level == 1 then
        add(b)
      else
        local inl = {}
        if h.label ~= "" then
          inl[#inl + 1] = pandoc.Str(h.label)
          inl[#inl + 1] = TAB
        end
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        local style = b.level == 2 and "MemoH2" or "MemoH3"
        add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style })))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      add(pandoc.Div({ pandoc.Para(b.content) }, pandoc.Attr("", {}, { ["custom-style"] = "BodyPara" })))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local marker = b.t == "BulletList" and "\u{2022}" or (i .. ".")
        for j, blk in ipairs(item) do
          if (blk.t == "Para" or blk.t == "Plain") then
            local inl = {}
            if j == 1 then
              inl[#inl + 1] = pandoc.Str(marker)
              inl[#inl + 1] = TAB
            end
            for _, x in ipairs(blk.content) do inl[#inl + 1] = x end
            add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "ListItem" })))
          else
            add(blk)
          end
        end
      end
    else
      add(b)
    end
  end
  add(pandoc.RawBlock("openxml", signature_xml(meta)))

  -- certificate of compliance on its own page (L.R. 11-6.2)
  add(pandoc.RawBlock("openxml", heading_xml("Certificate of Compliance", true)))
  local cert = { pandoc.Str("The undersigned, counsel of record for ") }
  for _, x in ipairs(inlines_of(need(meta, "certificate_party"))) do cert[#cert + 1] = x end
  cert[#cert + 1] = pandoc.Str(", certifies that this brief contains " .. plain(need(meta, "word_count"))
    .. " words, which complies with the word limit of L.R. 11-6.1.")
  add(pandoc.Div({ pandoc.Para(cert) }, pandoc.Attr("", {}, { ["custom-style"] = "BodyPara" })))
  add(pandoc.RawBlock("openxml", signature_xml(meta)))

  doc.blocks = blocks
  return doc
end

-- wvsd complaint, DOCX engine (docs/DOCX.md). Mirrors typst/wvsd-complaint.typ on reference.docx:
--  * cover (own section, empty footer): court title, caption table, title of the paper;
--  * table of contents (own section, roman page numbers) when `toc: true`, entries with PAGEREF fields
--    to heading bookmarks; page numbers come from the first pass (docx/render.sh, env WVSD_PAGES);
--  * body (own section, arabic from 1): numbered allegations (Fed. R. Civ. P. 10(b)), template-generated
--    heading numbers, lead-in, signature block, verification on a new page.
-- Every case-specific word comes from the sample's frontmatter.

local TEXT_W = 9360          -- 6.5 in in twips
local PARTY_W = 5328         -- 3.7 in, caption party column (as in the typst template)
local PAREN_W = 432          -- 0.3 in, column of ")" marks
local RIGHT_W = TEXT_W - PARTY_W - PAREN_W
local BLOCK_IND = 4680       -- 3.25 in, signature block
local COURT = "IN THE UNITED STATES DISTRICT COURT"

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- markdown text (already plain or with *italic* segments) -> w:r runs
local function runs(s, rpr)
  s = s:gsub("\\(.)", "%1")
  local parts = {}
  for p in (s .. "*"):gmatch("(.-)%*") do parts[#parts + 1] = p end
  local out = {}
  for k, p in ipairs(parts) do
    if p ~= "" then
      local r = rpr or ""
      if k % 2 == 0 then r = r .. "<w:i/>" end
      out[#out + 1] = '<w:r>' .. (r ~= "" and ('<w:rPr>' .. r .. '</w:rPr>') or '')
        .. '<w:t xml:space="preserve">' .. xesc(p) .. '</w:t></w:r>'
    end
  end
  return table.concat(out)
end

local function para(style, content, extra)
  return '<w:p><w:pPr>' .. (style and ('<w:pStyle w:val="' .. style .. '"/>') or '') .. (extra or '')
    .. '</w:pPr>' .. (content or '') .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end


-- metadata value -> text with *italic* segments kept ("" when empty); no line wrapping.
-- Metadata strings arrive as MetaInlines, MetaBlocks, or plain Lua lists of inlines/blocks.
local function mdstr(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  local out = {}
  local function walk_inl(list)
    for _, i in ipairs(list) do
      if i.t == "Emph" then
        out[#out + 1] = "*"; walk_inl(i.content); out[#out + 1] = "*"
      elseif i.t == "Str" then out[#out + 1] = i.text
      elseif i.t == "Space" or i.t == "SoftBreak" or i.t == "LineBreak" then out[#out + 1] = " "
      elseif i.t == "Strong" or i.t == "Span" then walk_inl(i.content)
      else out[#out + 1] = pandoc.utils.stringify(pandoc.Inlines({ i })) end
    end
  end
  if v.t == "MetaBlocks" or (v.t == nil and v[1] and (v[1].t == "Para" or v[1].t == "Plain")) then
    for _, b in ipairs(v) do if b.content then walk_inl(b.content) end end
  else
    walk_inl(v)
  end
  return (table.concat(out):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function plain(v) return (mdstr(v):gsub("%*", "")) end

local function has(meta, key) return meta[key] ~= nil end

local function as_bool(v) return v ~= nil and (v == true or pandoc.utils.stringify(v) == "true") end

-- sectPr for the section that ends at the paragraph carrying it
local function section_end(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ''
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:rPr><w:sz w:val="2"/></w:rPr><w:sectPr><w:footerReference w:type="default" r:id="' .. footer
    .. '"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. '</w:sectPr></w:pPr></w:p>'
end

local ROMAN = { "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x", "xi", "xii" }
local function upper_roman(n) return string.upper(ROMAN[n] or tostring(n)) end
local function lower_roman(n) return ROMAN[n] or tostring(n) end
local function letter(n, up)
  local s = string.char(string.byte("a") + ((n - 1) % 26))
  return up and string.upper(s) or s
end

-- heading numbers as the template generates them (never typed in the sample)
local function heading_label(level, c)
  if level == 1 then return upper_roman(c[1]) .. "."
  elseif level == 2 then return letter(c[2], true) .. "."
  elseif level == 3 then return tostring(c[3]) .. "."
  elseif level == 4 then return "(" .. lower_roman(c[4]) .. ")"
  elseif level == 5 then return "(" .. tostring(c[5]) .. ")"
  else return "(" .. letter(c[6], true) .. ")" end
end

local function caption_xml(meta)
  local rows = {}   -- { kind = "line"|"blank", text = md, ind = twips }
  local sides = meta.caption or {}
  for k, side in ipairs(sides) do
    local lead
    if side.lead ~= nil then lead = mdstr(side.lead)
    elseif k == 1 then lead = "" else lead = "v." end
    if lead ~= "" then rows[#rows + 1] = { text = lead, ind = 720 } end
    for _, n in ipairs(side.names or {}) do rows[#rows + 1] = { text = mdstr(n), ind = 0 } end
    rows[#rows + 1] = { text = mdstr(side.designation), ind = 1440 }
    if k < #sides then rows[#rows + 1] = { kind = "blank" } end
  end
  local out = {}
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. PARTY_W .. '"/><w:gridCol w:w="' .. PAREN_W .. '"/><w:gridCol w:w="' .. RIGHT_W .. '"/></w:tblGrid>'
  local nrows = #rows
  for i, r in ipairs(rows) do
    local left
    if r.kind == "blank" then
      left = para("Single", "", '<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>')
    else
      left = para("CaptionText", runs(r.text), r.ind > 0 and ('<w:ind w:left="' .. r.ind .. '" w:firstLine="0"/>') or nil)
    end
    local right
    if i == 1 then
      local civ = '<w:tcPr><w:tcW w:w="' .. RIGHT_W .. '" w:type="dxa"/><w:vMerge w:val="restart"/><w:vAlign w:val="center"/></w:tcPr>'
      local body = ""
      if meta.civil_action then body = body .. para("CaptionText", runs(mdstr(meta.civil_action)), '<w:ind w:left="288" w:firstLine="0"/>') end
      if meta.judge then body = body .. para("CaptionText", runs(mdstr(meta.judge)), '<w:ind w:left="288" w:firstLine="0"/>') end
      if body == "" then body = para("CaptionText", "") end
      right = '<w:tc>' .. civ .. body .. '</w:tc>'
    else
      right = '<w:tc><w:tcPr><w:tcW w:w="' .. RIGHT_W .. '" w:type="dxa"/><w:vMerge/></w:tcPr>' .. para("CaptionText", "") .. '</w:tc>'
    end
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. PARTY_W .. '" w:type="dxa"/></w:tcPr>' .. left .. '</w:tc>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. PAREN_W .. '" w:type="dxa"/></w:tcPr>'
      .. para(r.kind == "blank" and "Single" or "CaptionText", runs(")"), r.kind == "blank" and '<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>' or nil) .. '</w:tc>'
      .. right .. '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return table.concat(out)
end

-- signature block: the date at the left (bottom line), the signature lines at the right, kept together
local function signature_xml(meta, date_label)
  local lines = {}
  for _, l in ipairs(meta.signature or {}) do
    local s = mdstr(l)
    if s == "" then
      lines[#lines + 1] = para("Single", "", '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>')
    else
      lines[#lines + 1] = para("Single", runs(s), '<w:keepNext/>')
    end
  end
  local date = para("Single", runs((date_label or "") .. mdstr(meta.date)), '<w:keepNext/>')
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. BLOCK_IND .. '"/><w:gridCol w:w="' .. (TEXT_W - BLOCK_IND) .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. BLOCK_IND .. '" w:type="dxa"/><w:vAlign w:val="bottom"/></w:tcPr>' .. date .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXT_W - BLOCK_IND) .. '" w:type="dxa"/></w:tcPr>' .. table.concat(lines) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

local function sig_gap()
  return para(nil, "", '<w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/>')
end

-- the page-number cache from the first pass: lines "bookmark<TAB>page"
local function page_map()
  local map = {}
  local f = os.getenv("WVSD_PAGES")
  if not f or f == "" then return map end
  local h = io.open(f, "r")
  if not h then return map end
  for line in h:lines() do
    local name, pg = line:match("^(%S+)\t(%S+)$")
    if name then map[name] = pg end
  end
  h:close()
  return map
end

local function pageref(bm, cached)
  return '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGEREF ' .. bm .. ' \\h </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>' .. xesc(cached) .. '</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  local function add(b) blocks[#blocks + 1] = b end
  local pages = page_map()

  -- pass over the body: heading numbers, bookmarks, the TOC entries
  local toc_depth = tonumber(plain(meta.toc_depth or "2")) or 2
  local counters = { 0, 0, 0, 0, 0, 0 }
  local entries = {}
  local nbm = 0
  local body = {}
  local allegations = 0
  local function bookmark_id() nbm = nbm + 1; return nbm end

  local function transform(blist)
    local out = {}
    for _, b in ipairs(blist) do
      if b.t == "Header" then
        local lvl = b.level
        counters[lvl] = counters[lvl] + 1
        for i = lvl + 1, 6 do counters[i] = 0 end
        local label = heading_label(lvl, counters)
        local id = bookmark_id()
        local bm = "_TocWvsd" .. string.format("%03d", id)
        entries[#entries + 1] = { level = lvl, label = label, text = plain(pandoc.Inlines(b.content)), bm = bm }
        local content = pandoc.List({
          pandoc.RawInline("openxml", '<w:bookmarkStart w:id="' .. (7000 + id) .. '" w:name="' .. bm .. '"/>'),
          pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. xesc(label) .. '</w:t></w:r>'),
          pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>'),
        })
        content:extend(b.content)
        content:insert(pandoc.RawInline("openxml", ''))
        content:insert(pandoc.RawInline("openxml", '<w:bookmarkEnd w:id="' .. (7000 + id) .. '"/>'))
        out[#out + 1] = pandoc.Header(lvl, content, b.attr)
      elseif b.t == "Para" then
        allegations = allegations + 1
        local num = pandoc.List({
          pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. allegations .. '</w:t></w:r>'),
          pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>'),
        })
        num:extend(b.content)
        out[#out + 1] = pandoc.Div({ pandoc.Para(num) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" }))
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        -- list items are not allegations: their paragraphs are plain text, not numbered
        local listed = b:walk({ Para = function(p) return pandoc.Plain(p.content) end })
        out[#out + 1] = listed
      else
        out[#out + 1] = b
      end
    end
    return out
  end
  body = transform(doc.blocks)

  -- cover (section 1, no page number)
  add(raw(para("Centered", runs(COURT, "<w:b/>"), '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>')))
  add(raw(para("Centered", runs("FOR THE SOUTHERN DISTRICT OF WEST VIRGINIA", "<w:b/>"))))
  add(raw(para("Centered", runs(string.upper(plain(meta.division or "")), "<w:b/>"))))
  add(raw(para(nil, "", '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>')))
  add(raw(caption_xml(meta)))
  add(raw(para(nil, "", '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>')))
  add(raw(para("Centered", runs(mdstr(meta.brief_title), "<w:b/>"))))

  if as_bool(meta.toc) then
    add(raw(section_end("rId101")))
    -- table of contents (section 2, roman)
    add(raw(para("Centered", runs("TABLE OF CONTENTS", "<w:b/>"), '<w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="exact"/>')))
    for _, e in ipairs(entries) do
      if e.level <= toc_depth then
        local style = e.level == 1 and "TOCEntry1" or "TOCEntry2"
        local cached = pages[e.bm] or "0"
        local content = '<w:r><w:t xml:space="preserve">' .. xesc(e.label) .. '</w:t></w:r><w:r><w:tab/></w:r>'
          .. runs(e.text) .. '<w:r><w:tab/></w:r>' .. pageref(e.bm, cached)
        add(raw(para(style, content)))
      end
    end
    add(raw(section_end("rId100", "lowerRoman")))
  else
    add(raw(section_end("rId101")))
  end

  -- body (section 3, arabic from 1): lead-in, body, signature block, verification
  local lead_in = meta.lead_in or {}
  for k, p in ipairs(lead_in) do
    add(raw(para("BodyFlush", runs(mdstr(p)))))
  end
  for _, b in ipairs(body) do add(b) end
  add(raw(sig_gap()))
  add(raw(signature_xml(meta, "")))

  local v = meta.verification
  if v then
    add(raw(para("Centered", runs(mdstr(v.heading), "<w:b/><w:u w:val=\"single\"/>"),
      '<w:pageBreakBefore/><w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="exact"/>')))
    add(raw(para("BodyFlush", runs(mdstr(v.lead)))))
    for k, item in ipairs(v.items or {}) do
      add(raw(para("Items", runs(k .. ".") .. '<w:r><w:tab/></w:r>' .. runs(mdstr(item)))))
    end
    add(raw(para("BodyFlush", runs("Executed on " .. mdstr(v.executed) .. "."), '<w:spacing w:before="240" w:after="0" w:line="480" w:lineRule="exact"/>')))
    add(raw(sig_gap()))
    local lines = {}
    for _, l in ipairs(v.signature or {}) do
      local s = mdstr(l)
      lines[#lines + 1] = (s == "") and para("Signature", "", '<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>') or para("Signature", runs(s))
    end
    add(raw(table.concat(lines)))
  end

  -- entries for the two-pass page numbering in render.sh (bookmark, label, text)
  local tocout = os.getenv("WVSD_TOC_OUT")
  if tocout and tocout ~= "" then
    local h = assert(io.open(tocout, "w"))
    for _, e in ipairs(entries) do h:write(e.bm, "\t", e.level, "\t", e.label, "\t", e.text, "\n") end
    h:close()
  end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

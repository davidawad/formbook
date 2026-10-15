-- ttab-trial-brief.lua (docx engine, brief on the case). Builds the front matter, the table of authorities and the
-- trailing blocks (signature, certificate of service) as WordprocessingML from the sample's YAML frontmatter (the
-- contract the typst template reads, ../README.md "Markdown contract"). The body is pandoc's own conversion, styled
-- by reference.docx (make-reference.sh).
--
--   * Sections (Word-native numbering): the caption page and the table of authorities are roman (i, ii); the body is
--     arabic from 1 (set on the final section in reference.docx). Each front-matter section ends in a one-point
--     paragraph that carries its sectPr, so the break adds no page.
--   * The counsel block and the date sit at the foot of the caption page: a frame anchored to the bottom margin.
--   * The table of authorities lists each key with its pages and dot leaders. pandoc cannot know the pages, so
--     render.sh converts twice: this filter writes one search needle per link (TTAB_TOA_SEARCH); render.sh finds
--     the needles on the body pages of the PDF and writes TTAB_TOA_PAGES ("key<TAB>1, 4, 7"); the next pass lists
--     them. An authority cited on 7 or more pages prints "passim" (the typst template's rule).
--   * A citation is a link whose target is toa:KEY (../README.md). A key that is not in the authorities stops the build.
-- No case text is in this file.

local TWIP = 1440
local function tw(inches) return math.floor(inches * TWIP + 0.5) end

local TEXT_WIDTH = tw(6.5)
local SIG_LEFT = tw(3.0)
local PASSIM = 7

local function sp(before, after, line)
  if line == nil then
    return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="240" w:lineRule="auto" />'
  end
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. line .. '" w:lineRule="exact" />'
end
local SINGLE = sp(0, 0)
local DOUBLE = sp(0, 0, 480)

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function rpr(b, i)
  local x = ""
  if b then x = x .. "<w:b />" end
  if i then x = x .. "<w:i />" end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function run(text, b, i)
  return "<w:r>" .. rpr(b, i) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- Bold run at the level-1 heading size (1.4 em, 16.8 pt, as the typst template's headings print).
local function big(text)
  return '<w:r><w:rPr><w:b /><w:bCs /><w:sz w:val="34" /><w:szCs w:val="34" /></w:rPr><w:t xml:space="preserve">'
    .. esc(text) .. "</w:t></w:r>"
end

-- Inline markdown (pandoc has parsed the YAML strings, so they arrive as inline lists) as runs.
local function runs(inlines, b, i)
  local out = {}
  local function walk(list, bb, ii)
    for _, el in ipairs(list) do
      local t = el.t
      if t == "Str" then
        out[#out + 1] = run(el.text, bb, ii)
      elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
        out[#out + 1] = run(" ", bb, ii)
      elseif t == "Emph" then
        walk(el.content, bb, true)
      elseif t == "Strong" then
        walk(el.content, true, ii)
      elseif t == "Span" or t == "Link" then
        walk(el.content, bb, ii)
      else
        out[#out + 1] = run(pandoc.utils.stringify(el), bb, ii)
      end
    end
  end
  walk(inlines, b, i)
  return table.concat(out)
end

local function para(ppr, body)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. body .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function str_of(v)
  return pandoc.utils.stringify(v)
end

local function need(meta, key)
  if meta[key] == nil then error("ttab-trial-brief.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- The footer is referenced once, by the first section; later sections inherit it.
local FOOTER = '<w:footerReference w:type="default" r:id="rIdFooter1" />'
local PAGE = '<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />'

local function section_xml(numfmt, first)
  return "<w:sectPr>" .. (first and FOOTER or "") .. PAGE .. '<w:pgNumType w:fmt="' .. numfmt .. '" /></w:sectPr>'
end

-- A one-point paragraph that ends a section: it takes no room, so it cannot push a page over.
local TINY = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact" /><w:ind w:firstLine="0" />'
local function section_end(numfmt, first)
  return para(TINY .. section_xml(numfmt, first), "")
end

-- ---------------------------------------------------------------------------
-- Caption page
-- ---------------------------------------------------------------------------

-- TBMP 309.02(a): the heading the Board requires at the top of the first page.
local function board_heading()
  local ppr = SINGLE .. '<w:ind w:firstLine="0" /><w:jc w:val="center" />'
  return para(ppr, run("IN THE UNITED STATES PATENT AND TRADEMARK OFFICE", true))
    .. para(ppr, run("BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD", true))
end

-- The party caption: one row per line of names, a ")" column beside every row, and the proceeding numbers in a
-- cell that spans the caption and is vertically centered.
local function caption_table(meta)
  local sides = need(meta, "caption")
  local rows = {}
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do
      rows[#rows + 1] = { ind = 0, body = runs(name) }
    end
    rows[#rows + 1] = { ind = tw(2.1), body = runs(side.designation) }
    if i < #sides then
      rows[#rows + 1] = { ind = 0, body = "" }
      rows[#rows + 1] = { ind = tw(1.2), body = run("v.") }
      rows[#rows + 1] = { ind = 0, body = "" }
    end
  end
  local right = need(meta, "caption_right")
  local W = { tw(3.4), tw(0.35), tw(2.4) }
  local out = {}
  for r, row in ipairs(rows) do
    local left = '<w:tc><w:tcPr><w:tcW w:w="' .. W[1] .. '" w:type="dxa" /></w:tcPr>'
      .. para(SINGLE .. '<w:ind w:left="' .. row.ind .. '" w:firstLine="0" />', row.body) .. "</w:tc>"
    local mid = '<w:tc><w:tcPr><w:tcW w:w="' .. W[2] .. '" w:type="dxa" /></w:tcPr>'
      .. para(SINGLE .. '<w:ind w:firstLine="0" /><w:jc w:val="center" />', run(")")) .. "</w:tc>"
    local cell
    if r == 1 then
      local lines = {}
      for k, l in ipairs(right) do
        local after = (k < #right) and 216 or 0
        lines[#lines + 1] = para(sp(0, after) .. '<w:ind w:firstLine="0" />', runs(l))
      end
      cell = '<w:tc><w:tcPr><w:tcW w:w="' .. W[3] .. '" w:type="dxa" /><w:vMerge w:val="restart" />'
        .. '<w:vAlign w:val="center" /></w:tcPr>' .. table.concat(lines) .. "</w:tc>"
    else
      cell = '<w:tc><w:tcPr><w:tcW w:w="' .. W[3] .. '" w:type="dxa" /><w:vMerge />'
        .. '<w:vAlign w:val="center" /></w:tcPr>' .. para(SINGLE, "") .. "</w:tc>"
    end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit /></w:trPr>" .. left .. mid .. cell .. "</w:tr>"
  end
  local none = '<w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" />'
    .. '<w:insideH w:val="nil" /><w:insideV w:val="nil" />'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (W[1] + W[2] + W[3]) .. '" w:type="dxa" />'
    .. "<w:tblBorders>" .. none .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:top w:w="29" w:type="dxa" /><w:left w:w="0" w:type="dxa" />'
    .. '<w:bottom w:w="29" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />'
    .. "</w:tblPr><w:tblGrid>"
    .. '<w:gridCol w:w="' .. W[1] .. '" /><w:gridCol w:w="' .. W[2] .. '" /><w:gridCol w:w="' .. W[3] .. '" />'
    .. "</w:tblGrid>" .. table.concat(out) .. "</w:tbl>"
end

-- The counsel block and the date at the foot of the caption page: consecutive paragraphs with one framePr form one
-- frame, anchored to the bottom margin.
local function counsel_frame(meta)
  local frame = '<w:framePr w:w="' .. TEXT_WIDTH .. '" w:hRule="auto" w:wrap="around" w:vAnchor="margin" w:hAnchor="margin" w:yAlign="bottom" />'
  local ind = '<w:ind w:left="' .. SIG_LEFT .. '" w:firstLine="0" />'
  local out = {}
  for _, g in ipairs(need(meta, "counsel")) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = n end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    for k, l in ipairs(lines) do
      local after = (k == #lines) and 120 or 0
      out[#out + 1] = para(frame .. sp(0, after) .. ind, runs(l))
    end
  end
  out[#out + 1] = para(frame .. sp(0, 0) .. ind, runs(need(meta, "phone")))
  out[#out + 1] = para(frame .. sp(384, 0) .. '<w:ind w:firstLine="0" />', runs(need(meta, "date")))
  return table.concat(out)
end

local function caption_page(meta)
  local blocks = { raw(board_heading()) }
  blocks[#blocks + 1] = raw(para('<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact" />', ""))
  blocks[#blocks + 1] = raw(caption_table(meta))
  blocks[#blocks + 1] = raw(para(sp(528, 0), runs(need(meta, "brief_title"), true)))
  if meta.version ~= nil then
    blocks[#blocks + 1] = raw(para(sp(144, 0) .. '<w:jc w:val="center" />', runs(meta.version)))
  end
  blocks[#blocks + 1] = raw(counsel_frame(meta))
  blocks[#blocks + 1] = raw(section_end("lowerRoman", true))
  return blocks
end

-- ---------------------------------------------------------------------------
-- Table of authorities (37 CFR 2.128(b): the index of cases, then the other authorities)
-- ---------------------------------------------------------------------------

-- The page list of each key from render.sh's previous pass (TTAB_TOA_PAGES: "key<TAB>1, 4, 7" per line). Before the
-- first pass, each authority is listed on a placeholder page, so the first pass has the same entries.
local function read_pages()
  local path = os.getenv("TTAB_TOA_PAGES")
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local pages = {}
  for line in f:lines() do
    local key, list = line:match("^([^\t]+)\t(.*)$")
    if key ~= nil then
      local t = {}
      for n in list:gmatch("%d+") do t[#t + 1] = n end
      pages[key] = t
    end
  end
  f:close()
  return pages
end

local GROUPS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "regulation", "Regulations" },
  { "rule", "Rules" },
  { "other", "Other Authorities" },
}

-- Sort key: the name (or sort field) without emphasis markers, lower case.
local function sort_key(a)
  local s
  if a.sort ~= nil then
    s = str_of(a.sort)
  elseif a.name ~= nil then
    s = str_of(a.name)
  else
    s = str_of(a.cite)
  end
  local plain = s:gsub("%*", "")
  return plain:lower()
end

local function toa_section(meta, pages)
  local auth = need(meta, "authorities")
  local blocks = {}
  blocks[#blocks + 1] = raw(para('<w:keepNext />' .. sp(0, 240) .. '<w:jc w:val="center" />', big("TABLE OF AUTHORITIES")))
  blocks[#blocks + 1] = raw(para('<w:keepNext />' .. sp(0, 240) .. '<w:jc w:val="right" />', run("Page(s)", true)))
  for _, g in ipairs(GROUPS) do
    local kind, label = g[1], g[2]
    local keys = {}
    for k, a in pairs(auth) do
      if str_of(a.kind) == kind then keys[#keys + 1] = k end
    end
    if #keys > 0 then
      if kind == "case" then
        table.sort(keys, function(x, y) return sort_key(auth[x]) < sort_key(auth[y]) end)
      else
        table.sort(keys)
      end
      blocks[#blocks + 1] = raw(para('<w:keepNext />' .. sp(216, 168), run(label, true)))
      for _, k in ipairs(keys) do
        local list = { "0" }
        if pages then list = pages[k] or {} end
        if #list > 0 then
          local shown
          if #list >= PASSIM then shown = "passim" else shown = table.concat(list, ", ") end
          local a = auth[k]
          local head = ""
          if a.name ~= nil then head = runs(a.name) .. run(", ") end
          local ppr = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_WIDTH .. '" /></w:tabs>'
            .. sp(0, 204) .. '<w:ind w:left="720" w:hanging="720" />'
          blocks[#blocks + 1] = raw(para(ppr, head .. runs(a.cite) .. "<w:r><w:tab /></w:r>" .. run(shown)))
        end
      end
    end
  end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

-- Signature block (37 CFR 2.193(c): the electronic signature is "s/Name"), at 3 in.
local function signature(meta)
  local sig = need(meta, "signature")
  local ind = '<w:ind w:left="' .. SIG_LEFT .. '" w:firstLine="0" />'
  local keep = "<w:keepNext /><w:keepLines />"
  local out = {}
  out[#out + 1] = para(keep .. sp(384, 0) .. ind, runs(sig.party))
  out[#out + 1] = para(keep .. SINGLE .. ind, run("By its attorneys,"))
  out[#out + 1] = para(keep .. sp(288, 0) .. ind, run("s/" .. str_of(sig.signer)))
  for k, l in ipairs(sig.lines) do
    local last = (k == #sig.lines)
    out[#out + 1] = para((last and "" or "<w:keepNext />") .. "<w:keepLines />" .. SINGLE .. ind, runs(l))
  end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- Certificate of service (37 CFR 2.119(a), (b)): its own page; the date and the manner of service; "s/Name".
local function certificate(meta)
  local c = need(meta, "service")
  local blocks = {}
  blocks[#blocks + 1] = raw(para('<w:pageBreakBefore />' .. sp(0, 336) .. '<w:ind w:firstLine="0" /><w:jc w:val="center" />', run("CERTIFICATE OF SERVICE", true)))
  local text = run("I hereby certify that a true and correct copy of the foregoing ")
    .. runs(need(meta, "brief_title")) .. run(" was filed electronically and served on this ")
    .. runs(c.date) .. run(", via email to:")
  blocks[#blocks + 1] = raw(para(DOUBLE .. '<w:ind w:firstLine="0" />', text))
  for k, r in ipairs(c.recipients) do
    local before = (k == 1) and 144 or 0
    blocks[#blocks + 1] = raw(para(sp(before, 0) .. '<w:ind w:left="720" w:firstLine="0" />', runs(r)))
  end
  local ind = '<w:ind w:left="' .. SIG_LEFT .. '" w:firstLine="0" />'
  blocks[#blocks + 1] = raw(para(sp(480, 0) .. ind, run("s/" .. str_of(c.signer))))
  blocks[#blocks + 1] = raw(para(SINGLE .. ind, run(str_of(c.signer))))
  return blocks
end

-- ---------------------------------------------------------------------------
-- Links to authorities: recorded for the first pass, shown as their text
-- ---------------------------------------------------------------------------

local used_keys = {}
local search_path = os.getenv("TTAB_TOA_SEARCH")

-- The first 30 characters of the link text: enough to find the citation's start on a page.
local function needle_of(s)
  s = s:gsub("\u{00A0}", " ")
  local cut = utf8.offset(s, 31)
  if cut then return s:sub(1, cut - 1) end
  return s
end

function Link(el)
  local target = el.target
  if target:sub(1, 4) ~= "toa:" then return nil end
  local key = target:sub(5)
  used_keys[#used_keys + 1] = key
  if search_path ~= nil then
    local f = io.open(search_path, "a")
    if f ~= nil then
      f:write(key .. "\t" .. needle_of(pandoc.utils.stringify(el)) .. "\n")
      f:close()
    end
  end
  return el.content
end

-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local auth = need(meta, "authorities")
  for _, key in ipairs(used_keys) do
    if auth[key] == nil then error("ttab-trial-brief.lua: `" .. key .. "` is not in authorities") end
  end
  local pages = read_pages()
  local blocks = {}
  for _, b in ipairs(caption_page(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(toa_section(meta, pages)) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = raw(section_end("lowerRoman", false))
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = b end
  doc.meta.title = nil
  doc.meta.date = nil
  return pandoc.Pandoc(blocks, doc.meta)
end

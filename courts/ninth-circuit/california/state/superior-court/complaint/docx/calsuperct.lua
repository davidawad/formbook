-- calsuperct.lua: the first page, the caption and the signature blocks for the pandoc docx engine.
-- Reads the same YAML frontmatter the typst template reads (footer_title, attorney, court, caption,
-- hearing, signature, jury_demand) and writes the structure Markdown cannot express as raw WordprocessingML.
-- Styles (font, spacing, indents, margins, footer, line numbers) are in reference.docx, made by
-- make-reference.sh. Only text from the frontmatter is written; no case-specific text is in this file.
-- Units: twips (1 pt = 20). Exact 24 pt pitch = 480. Leading spaces in caption lines become a left
-- indent of 0.25 em per space (60 twips at 12 pt), as in the typst template.

local SINGLE = 240        -- 12 pt, one line of the pleading grid's half
local PITCH = 480         -- 24 pt, double spacing
local ATTY_RESERVE = 3360 -- lines 1-7 (168 pt): the attorney block must fit; court title starts at line 8
local CAP_LEFT, CAP_RIGHT = 5184, 4176 -- 3.6 in and 2.9 in
local SIG_INDENT = 4464   -- 3.1 in
local BY_LINE = 3888      -- 2.7 in
local GROUP_GAP = 480     -- 24 pt between caption groups

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function ppr(o)
  local x = {}
  if o.keep then x[#x + 1] = "<w:keepNext/>" end
  if o.tabs then x[#x + 1] = "<w:tabs>" .. o.tabs .. "</w:tabs>" end
  x[#x + 1] = string.format('<w:spacing w:before="%d" w:after="0" w:line="%d" w:lineRule="exact"/>',
    o.before or 0, o.line or SINGLE)
  if o.left or o.first then
    x[#x + 1] = string.format('<w:ind w:left="%d" w:firstLine="%d"/>', o.left or 0, o.first or 0)
  end
  if o.jc then x[#x + 1] = '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:pPr>" .. table.concat(x) .. "</w:pPr>"
end

local function run(text, o)
  o = o or {}
  local rpr = ""
  if o.b then rpr = rpr .. "<w:b/><w:bCs/>" end
  if o.caps then rpr = rpr .. "<w:caps/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local TAB = "<w:r><w:tab/></w:r>"

local function P(content, o)
  return pandoc.RawBlock("openxml", "<w:p>" .. ppr(o or {}) .. (content or "") .. "</w:p>")
end

-- A line of text; leading spaces become an indent (60 twips per space).
local function caption_line(s, o)
  local lead = #(s:match("^( *)"))
  o = o or {}
  o.left = (o.left or 0) + lead * 60
  return P(run(s:sub(lead + 1), o.run or {}), o)
end

-- A list of lines from the frontmatter (pandoc.List of Inlines), or one line.
local function strs(v)
  local t = {}
  if v == nil then return t end
  if pandoc.utils.type(v) == "List" then
    for _, x in ipairs(v) do t[#t + 1] = pandoc.utils.stringify(x) end
  else
    t[#t + 1] = pandoc.utils.stringify(v)
  end
  return t
end

-- Pandoc parses frontmatter strings as Markdown and drops leading spaces, so the caption's indented
-- lines ("   Plaintiff,") are read verbatim from the sample's own frontmatter (caption.left only).
-- Falls back to the parsed text when the raw lines cannot be read.
local function raw_caption_left(parsed)
  local files = PANDOC_STATE and PANDOC_STATE.input_files
  if not files or not files[1] then return parsed end
  local fh = io.open(files[1], "r")
  if not fh then return parsed end
  local src = fh:read("a")
  fh:close()
  local fm = src:match("^%-%-%-\r?\n(.-)\r?\n%-%-%-")
  if not fm then return parsed end
  local items, in_cap, in_left = {}, false, false
  for line in (fm .. "\n"):gmatch("([^\n]*)\n") do
    line = line:gsub("\r$", "")
    if line:match("^caption:%s*$") then
      in_cap, in_left = true, false
    elseif in_cap and line:match("^%S") then
      break
    elseif in_cap and line:match("^  left:%s*$") then
      in_left = true
    elseif in_left and line:match("^  %S") then
      break
    elseif in_left and line:match("^    %- ") then
      local s = line:match('^    %- "(.*)"%s*$') or line:match("^    %- '(.*)'%s*$")
      if not s then return parsed end
      items[#items + 1] = s
    end
  end
  if #items ~= #parsed then return parsed end
  return items
end

local function str(v)
  return v and pandoc.utils.stringify(v) or nil
end

local function cell(width, paras, opts)
  opts = opts or {}
  local pr = string.format('<w:tcW w:w="%d" w:type="dxa"/>', width)
  if opts.borders then pr = pr .. "<w:tcBorders>" .. opts.borders .. "</w:tcBorders>" end
  if opts.mar then pr = pr .. "<w:tcMar>" .. opts.mar .. "</w:tcMar>" end
  local body = {}
  for _, p in ipairs(paras) do body[#body + 1] = p.text end
  return "<w:tc><w:tcPr>" .. pr .. "</w:tcPr>" .. table.concat(body) .. "</w:tc>"
end

local function caption_table(left_paras, right_paras)
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
    .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. string.format('<w:tblGrid><w:gridCol w:w="%d"/><w:gridCol w:w="%d"/></w:tblGrid>', CAP_LEFT, CAP_RIGHT)
    .. "<w:tr>"
    .. cell(CAP_LEFT, left_paras, {
      borders = '<w:bottom w:val="single" w:sz="5" w:space="0" w:color="auto"/>'
        .. '<w:right w:val="single" w:sz="5" w:space="0" w:color="auto"/>',
      mar = '<w:right w:w="173" w:type="dxa"/>' .. '<w:bottom w:w="173" w:type="dxa"/>',
    })
    .. cell(CAP_RIGHT, right_paras, { mar = '<w:left w:w="288" w:type="dxa"/>' })
    .. "</w:tr></w:tbl>"
  return pandoc.RawBlock("openxml", xml)
end

-- Page 1 (CRC 2.111): attorney block on lines 1-7, court title on line 8, caption from line 11.
local function first_page(m)
  local out = {}
  local atty = strs(m.attorney)
  local atty_h = 0
  for _, s in ipairs(atty) do
    out[#out + 1] = caption_line(s, { line = SINGLE })
    atty_h = atty_h + SINGLE
  end
  local court = strs(m.court)
  for i, s in ipairs(court) do
    local o = { jc = "center", line = PITCH, keep = true, b = nil }
    if i == 1 then o.before = math.max(0, ATTY_RESERVE - atty_h) end
    out[#out + 1] = P(run(s, { b = true }), o)
  end
  out[#out + 1] = P("", { line = PITCH })

  local cap = m.caption or {}
  local left = {}
  for _, s in ipairs(raw_caption_left(strs(cap.left))) do
    left[#left + 1] = caption_line(s, { line = SINGLE })
  end
  if #left == 0 then left[1] = P("", { line = SINGLE }) end

  local right = {}
  local groups = {}
  if cap.case_number then groups[#groups + 1] = { P(run(str(cap.case_number)), { line = SINGLE }) } end
  local title = {}
  for _, s in ipairs(strs(cap.title)) do title[#title + 1] = P(run(s, { b = true }), { line = SINGLE }) end
  if #title > 0 then groups[#groups + 1] = title end
  local details = {}
  for _, s in ipairs(strs(cap.details)) do details[#details + 1] = P(run(s), { line = SINGLE }) end
  if #details > 0 then groups[#groups + 1] = details end
  if m.hearing then
    local rows = {}
    for _, k in ipairs({ { "date", "Date:" }, { "time", "Time:" }, { "dept", "Dept.:" }, { "judge", "Judge:" } }) do
      local v = str(m.hearing[k[1]])
      if v then
        rows[#rows + 1] = P(run(k[2]) .. TAB .. run(v), {
          line = SINGLE,
          tabs = '<w:tab w:val="left" w:pos="1080"/>',
        })
      end
    end
    if #rows > 0 then groups[#groups + 1] = rows end
  end
  local extra = {}
  if cap.action_filed then extra[#extra + 1] = P(run("Action Filed: " .. str(cap.action_filed)), { line = SINGLE }) end
  if cap.concurrent then extra[#extra + 1] = P(run("[" .. str(cap.concurrent) .. "]"), { line = SINGLE }) end
  if #extra > 0 then groups[#groups + 1] = extra end
  if cap.amount_demanded then
    groups[#groups + 1] = { P(run(str(cap.amount_demanded)), { line = SINGLE }) }
  end
  for gi, g in ipairs(groups) do
    for pi, p in ipairs(g) do
      -- The first paragraph of each later group starts a 24 pt gap; rebuilt with the gap.
      if gi > 1 and pi == 1 then
        local xml = (p.text:gsub("<w:spacing w:before=\"0\"", '<w:spacing w:before="' .. GROUP_GAP .. '"', 1))
        p = pandoc.RawBlock("openxml", xml)
      end
      right[#right + 1] = p
    end
  end
  if #right == 0 then right[1] = P("", { line = SINGLE }) end

  out[#out + 1] = caption_table(left, right)
  out[#out + 1] = P("", { line = PITCH })
  return out
end

-- Signature block (CRC 2.111 style): Dated at the left; the firm or party lines, the "By:" line and the
-- signer's name and role at 3.1 in.
local function signature_block(sig, m)
  local out = {}
  if not sig then return out end
  if sig.dated then
    out[#out + 1] = P(run("Dated: " .. str(sig.dated)), { before = PITCH, line = SINGLE, keep = true })
  end
  for i, s in ipairs(strs(sig.lines)) do
    out[#out + 1] = P(run(s), { left = SIG_INDENT, line = SINGLE, keep = true, before = (i == 1 and sig.dated == nil) and PITCH or 0 })
  end
  out[#out + 1] = P(run("By:") .. run(" ") .. '<w:r><w:tab/></w:r>', {
    left = SIG_INDENT, before = PITCH, line = SINGLE, keep = true,
    tabs = string.format('<w:tab w:val="left" w:leader="underscore" w:pos="%d"/>', SIG_INDENT + BY_LINE),
  })
  if sig.signer then
    out[#out + 1] = P(run(string.upper(str(sig.signer)), { b = true }), { left = SIG_INDENT + 432, line = SINGLE, keep = true })
  end
  if sig.role then
    out[#out + 1] = P(run(str(sig.role)), { left = SIG_INDENT + 432, line = SINGLE })
  end
  return out
end

function Link(el)
  -- Table-of-authorities targets (toa:<key>) are not generated in docx; keep the visible text.
  if el.target:match("^toa:") then return el.content end
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}

  -- The footer shows the subject (footer1.xml: SUBJECT field). docx writes metadata subject to core.xml.
  if m.footer_title then
    m.subject = pandoc.MetaInlines({ pandoc.Str(str(m.footer_title)) })
  end

  for _, b in ipairs(first_page(m)) do out[#out + 1] = b end

  local sig = m.signature
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and pandoc.utils.stringify(b) == "MEMORANDUM OF POINTS AND AUTHORITIES" then
      -- The notice ends here (CRC 3.1112): its signature block, then the memorandum title.
      for _, s in ipairs(signature_block(sig, m)) do out[#out + 1] = s end
      out[#out + 1] = P(run("MEMORANDUM OF POINTS AND AUTHORITIES", { b = true }), { jc = "center", line = PITCH, keep = true })
    else
      out[#out + 1] = b
    end
  end

  if m.jury_demand then
    out[#out + 1] = P(run(string.upper(str(m.jury_demand)), { b = true }), { jc = "center", before = PITCH, line = PITCH, keep = true })
  end
  if sig then
    for _, s in ipairs(signature_block(sig, m)) do out[#out + 1] = s end
  end

  doc.blocks = out
  doc.meta = m
  return doc
end

-- U.S. District Court of Guam (gud): pandoc filter for the docx engine (one copy per doc type).
-- The same content as the typst template of this doc type, from the same markdown contract (GNLR 5.1, 2022).
-- The counsel block, court title, caption, numbered paragraphs (complaint), lettered items, addresses
-- (<!-- single -->), signature blocks (<!-- signature -->, or at the end) and the page break before a
-- CERTIFICATE heading are written here; the body paragraphs and headings stay pandoc's. Styles come from
-- reference.docx (docx/make-reference.sh): EB Garamond 12 pt, exact 24 pt line pitch, 1 in margins,
-- centred page number in the footer, first-line indent on body text, custom styles GudSingle and GudList.
-- The only line that differs between the copies is TYPE.

local TYPE = "complaint" -- "complaint" | "motion"
local NUMBERED = (TYPE == "complaint") -- FRCP 10(b): the complaint's allegations are numbered; a motion's paragraphs are not

local SINGLE = 276 -- single spacing, exact: 13.8 pt (typst single-leading)
local DOUBLE = 480 -- double spacing, exact: 24 pt (typst body pitch)
local BOX = 2880 -- 3 in (GNLR 5.1(b)) less the 1 in top margin, in twips: the court title starts at 3 in
local COUNSEL_W = 4680 -- 3.25 in: counsel, and the party column of the caption (GNLR 5.1(c)(1))
local GUTTER = 360 -- 0.25 in
local CASE_W = 4320 -- 3.0 in: the right column of the caption
local SIG_LEFT = 4320 -- 3 in: the signature block

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("gud-" .. TYPE .. ": missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- One WordprocessingML paragraph with explicit spacing. o: line (twips, exact), before, after, jc,
-- left, right, first (twips), bold, keep_next, page_break_before, pstyle.
local function para(s, o)
  o = o or {}
  local ppr = ""
  if o.pstyle then ppr = ppr .. '<w:pStyle w:val="' .. o.pstyle .. '"/>' end
  if o.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if o.page_break_before then ppr = ppr .. "<w:pageBreakBefore/>" end
  ppr = ppr .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0)
    .. '" w:line="' .. (o.line or SINGLE) .. '" w:lineRule="exact"/>'
  if o.left or o.right or o.first then
    ppr = ppr .. "<w:ind"
      .. (o.left and (' w:left="' .. o.left .. '"') or "")
      .. (o.right and (' w:right="' .. o.right .. '"') or "")
      .. (o.first and (' w:firstLine="' .. o.first .. '"') or "")
      .. "/>"
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  local run = ""
  if s ~= "" then
    run = "<w:r>" .. (o.bold and "<w:rPr><w:b/></w:rPr>" or "") .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. run .. "</w:p>"
end

-- Cover (GNLR 5.1(b)-(c)): counsel at the upper left, court title centred at 3 in, caption below it.
local function cover(meta)
  local out = {}
  local counsel = need(meta, "counsel")
  for _, l in ipairs(counsel) do
    out[#out + 1] = raw(para(text(l), { right = COUNSEL_W, line = SINGLE }))
  end
  -- The court title starts at 3 in: the counsel block (one single line each) fills the space above it.
  -- A longer counsel block leaves no space and pushes the title down, never up.
  local lift = math.max(0, BOX - #counsel * SINGLE)
  local titles = need(meta, "court_title")
  for i, l in ipairs(titles) do
    out[#out + 1] = raw(para(text(l), {
      jc = "center", bold = true, line = SINGLE,
      before = (i == 1) and lift or 0,
      after = (i == #titles) and DOUBLE or 0,
    }))
  end

  -- Caption: parties (left, 3.25 in), then the case number, designation and brief description (right).
  local left, right = {}, {}
  local parties = need(meta, "caption").parties
  for k, side in ipairs(parties) do
    if k > 1 then
      left[#left + 1] = para("", { line = SINGLE })
      left[#left + 1] = para(text(need(meta, "caption").between), { left = 720, line = SINGLE })
      left[#left + 1] = para("", { line = SINGLE })
    end
    for _, n in ipairs(side.names) do left[#left + 1] = para(text(n), { line = SINGLE }) end
    left[#left + 1] = para(text(side.designation), { left = 1440, line = SINGLE })
  end
  right[#right + 1] = para(text(need(meta, "case_number")), { line = SINGLE })
  right[#right + 1] = para(text(need(meta, "designation")), { line = SINGLE })
  if meta.case_notes then
    for _, n in ipairs(meta.case_notes) do right[#right + 1] = para(text(n), { line = SINGLE }) end
  end
  right[#right + 1] = para("", { line = DOUBLE })
  right[#right + 1] = para(text(need(meta, "brief_title")), { bold = true, line = SINGLE })
  if meta.brief_subtitle then
    right[#right + 1] = para("", { line = SINGLE })
    right[#right + 1] = para(text(meta.brief_subtitle), { line = SINGLE })
  end

  local function cell(w, paras)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(paras) .. "</w:tc>"
  end
  out[#out + 1] = raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. COUNSEL_W .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="' .. CASE_W
    .. '"/></w:tblGrid><w:tr>' .. cell(COUNSEL_W, left) .. cell(GUTTER, { para("", { line = SINGLE }) }) .. cell(CASE_W, right)
    .. "</w:tr></w:tbl>")
  out[#out + 1] = raw(para("", { line = DOUBLE }))
  return out
end

-- Signature block (typst: "Respectfully submitted this <date>.", then the firm, "/s/" and the signer's lines
-- at 3 in, single spaced, kept together).
local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = raw(para("", { line = DOUBLE }))
  out[#out + 1] = raw(para("Respectfully submitted this " .. text(need(meta, "date")) .. ".", { keep_next = true }))
  out[#out + 1] = raw(para("", { line = DOUBLE, keep_next = true }))
  local lines = {}
  for _, f in ipairs(sig.firm) do lines[#lines + 1] = text(f) end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "/s/ " .. text(sig.signer)
  for _, l in ipairs(sig.lines) do lines[#lines + 1] = text(l) end
  for i, l in ipairs(lines) do
    out[#out + 1] = raw(para(l, { left = SIG_LEFT, keep_next = i < #lines }))
  end
  return out
end

-- An empty paragraph of 1 pt that starts the next page (a CERTIFICATE heading starts a new page).
local PAGE_BREAK = '<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p>'

-- Lettered items: (a), (b), ... with a hanging indent (style GudList). Items past z continue as aa, ab, ...
local function letter(i)
  if i <= 26 then return "(" .. string.char(96 + i) .. ")" end
  return "(" .. string.char(96 + (i - 1) // 26) .. string.char(97 + (i - 1) % 26) .. ")"
end

-- Split a paragraph at its line breaks: the lines of an address (<!-- single -->).
local function split_lines(inls)
  local lines, cur = {}, {}
  for _, x in ipairs(inls) do
    if x.t == "SoftBreak" or x.t == "LineBreak" then
      lines[#lines + 1] = cur
      cur = {}
    else
      cur[#cur + 1] = x
    end
  end
  lines[#lines + 1] = cur
  return lines
end

local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end
  if meta.lead_in then
    for _, b in ipairs(pandoc.read(text(meta.lead_in), "markdown+smart").blocks) do out[#out + 1] = b end
  end

  local signatures = 0
  local number = 0
  local skip_number = false
  local single = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "RawBlock" and b.format == "html" then
      local m = b.text:match("^<!%-%-%s*(%a+)%s*%-%->")
      if m == "signature" then
        signatures = signatures + 1
        for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
      elseif m == "unnumbered" then
        skip_number = true
      elseif m == "single" then
        single = true
      end
    elseif b.t == "Header" then
      local title = text(b.content)
      if b.level == 1 and string.upper(title):match("^CERTIFICATE") then out[#out + 1] = raw(PAGE_BREAK) end
      out[#out + 1] = b
    elseif b.t == "Para" and single then
      for _, line in ipairs(split_lines(b.content)) do
        out[#out + 1] = pandoc.Div({ pandoc.Para(line) }, { ["custom-style"] = "GudSingle" })
      end
      single = false
    elseif b.t == "Para" then
      if NUMBERED and not skip_number then
        number = number + 1
        local inl = { pandoc.Str(number .. ".") , tab() }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        out[#out + 1] = pandoc.Para(inl)
      else
        out[#out + 1] = b
      end
      skip_number = false
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local blocks = {}
        for _, x in ipairs(item) do
          if x.t == "Plain" then x = pandoc.Para(x.content) end
          blocks[#blocks + 1] = x
        end
        if blocks[1] and blocks[1].t == "Para" then
          local inl = { pandoc.Str(letter(i)), tab() }
          for _, x in ipairs(blocks[1].content) do inl[#inl + 1] = x end
          blocks[1] = pandoc.Para(inl)
        end
        out[#out + 1] = pandoc.Div(blocks, { ["custom-style"] = "GudList" })
      end
    else
      out[#out + 1] = b
    end
  end
  if signatures == 0 then
    for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  end
  doc.blocks = out
  return doc
end

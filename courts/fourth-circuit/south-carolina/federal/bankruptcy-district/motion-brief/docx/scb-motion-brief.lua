-- scb-motion-brief.lua (docx engine, scb/motion-brief).
-- What pandoc does not do by itself, following typst/scb-motion-brief.typ (see ../README.md, "## Engines"):
--   * the caption (")" column: party names, ")" on every row, case information on the right) and the title line,
--     from the frontmatter, as WordprocessingML; the court title above the caption (Fed. R. Bankr. P. 9004(b)(1));
--   * the SC LBR 7012-1 notice page when the frontmatter has `notice`;
--   * facts numbered 1, 2, 3 ... inside the section named by `numbered_section` (argument prose is not numbered);
--   * headings labelled A., B. (level 3) and 1., 2. (level 4), as the typst template prints them;
--   * lettered lists (a), b), ...); the last two blocks and the signature stay on one page (keepNext);
--   * the signature block ("/s/" and the typed name); the page number is in the reference's footer.
-- Content-agnostic: every case word comes from the sample's frontmatter, except the rule text of the notice,
-- which is the SC LBR 7012-1 text copied from the typst template.

local NOTICE = [[A motion to dismiss is a request that one or more issues in a case be decided without holding a trial. Motions to dismiss are governed by Rule 12, Federal Rules of Civil Procedure. Your complaint, or the portions of your complaint that the motion seeks to dismiss, may be dismissed if the court finds that the complaint does not contain sufficient allegations to state a claim upon which the court can grant relief. If you wish to oppose the motion to dismiss, you must file with the court and serve on the other party a written response within the time period set forth in a notice that will be separately mailed to you by the Clerk of Court. If you file a written response, a hearing will be held at the location and time set forth in the notice from the Clerk of Court. If you fail to file a timely written response to the motion, the court will consider the motion unopposed and may grant the motion without holding a hearing. This will result in the termination of the proceeding, or some part thereof, in favor of the moving party.]]

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function sx(v)
  return pandoc.utils.stringify(v)
end

-- WordprocessingML helpers. Twips: 1440 per inch, 20 per point.
local function P(o, runs)
  local x = {}
  if o.style then x[#x + 1] = '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep then x[#x + 1] = '<w:keepNext/><w:keepLines/>' end
  if o.pbb then x[#x + 1] = '<w:pageBreakBefore/>' end
  if o.rule then x[#x + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>' end
  x[#x + 1] = string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>',
    o.before or 0, o.after or 0, o.line or 391)
  local ind = {}
  if o.left then ind[#ind + 1] = 'w:left="' .. o.left .. '"' end
  if o.right then ind[#ind + 1] = 'w:right="' .. o.right .. '"' end
  if o.first then ind[#ind + 1] = 'w:firstLine="' .. o.first .. '"' end
  if #ind > 0 then x[#x + 1] = '<w:ind ' .. table.concat(ind, ' ') .. '/>' end
  if o.jc then x[#x + 1] = '<w:jc w:val="' .. o.jc .. '"/>' end
  return '<w:p><w:pPr>' .. table.concat(x) .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function R(text, bold)
  local rpr = bold and '<w:rPr><w:b/><w:bCs/></w:rPr>' or ''
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function raw(xml)
  return pandoc.RawBlock('openxml', xml)
end

local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

local function TC(width, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. paras .. '</w:tc>'
end

-- Caption: one row per printed line. Left: names ("~" right-aligned, ">" indented); middle: ")"; right: case data.
local function caption(meta)
  local rows = {}
  for _, r in ipairs(meta.caption.rows) do
    local left, right = sx(r[1]), sx(r[2])
    local lp
    if left:sub(1, 1) == "~" then
      lp = P({ jc = "right", right = 173, line = 340 }, R(left:sub(2)))
    elseif left:sub(1, 1) == ">" then
      lp = P({ left = 576, line = 340 }, R(left:sub(2)))
    else
      lp = P({ line = 340 }, R(left))
    end
    rows[#rows + 1] = '<w:tr>' .. TC(4176, lp) .. TC(360, P({ line = 340 }, R(")"))) .. TC(4824, P({ left = 216, line = 340 }, R(right))) .. '</w:tr>'
  end
  return table_xml({ 4176, 360, 4824 }, rows)
end

local function court_title(meta)
  local out = {}
  local lines = meta.court
  for i, l in ipairs(lines) do
    out[#out + 1] = P({ jc = "center" }, R(sx(l), i == #lines))
  end
  return table.concat(out)
end

local function kind(b)
  if b.t == "Header" then return "heading" end
  if b.t == "BlockQuote" then return "quote" end
  if b.t == "BulletList" or b.t == "OrderedList" then return "list" end
  if b.t == "Para" or b.t == "Plain" then return "para" end
  return "other"
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function attr(style)
  return pandoc.Attr("", {}, { ["custom-style"] = style })
end

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')

-- Signature block (SC LBR 9011-4). The motion has "Respectfully submitted," and the firm; the notice does not.
local function signature(sig, respectfully)
  local x = {}
  if respectfully then
    x[#x + 1] = P({ before = 480, left = 4680, keep = true }, R("Respectfully submitted,"))
    x[#x + 1] = P({ before = 240, left = 4680, keep = true }, R(sx(sig.firm)))
    x[#x + 1] = P({ before = 240, left = 4680, keep = true }, R("/s/ " .. sx(sig.signer)))
  else
    x[#x + 1] = P({ before = 480, left = 4680, keep = true }, R(sx(sig.firm)))
    x[#x + 1] = P({ before = 240, left = 4680, keep = true }, R("/s/ " .. sx(sig.signer)))
  end
  for _, l in ipairs(sig.lines) do
    x[#x + 1] = P({ left = 4680, keep = true }, R(sx(l)))
  end
  x[#x + 1] = P({ left = 4680, keep = true }, R(sx(sig.role)))
  x[#x + 1] = P({ before = 240 }, R(sx(sig.date)))
  return table.concat(x)
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = doc.blocks
  local n = #blocks
  local out = {}
  local function add(x) out[#out + 1] = x end
  local sig = meta.signature

  -- optional notice page (SC LBR 7012-1), then a page break before the motion
  if meta.notice then
    add(raw(P({ line = 218 }, "")))
    add(raw(court_title(meta)))
    add(raw(P({ line = 218 }, "")))
    add(raw(caption(meta)))
    add(raw(P({ before = 240, after = 240, jc = "center", line = 480 }, R("NOTICE REQUIRED BY SC LBR 7012-1", true))))
    add(raw(P({ first = 0, line = 480 }, R("TO: " .. sx(meta.notice.addressee)))))
    add(raw(P({ first = 720, line = 480 }, R(NOTICE))))
    add(raw(signature(sig, false)))
  end

  -- the motion: court title, caption, title line
  local pbb = meta.notice ~= nil
  add(raw(P({ pbb = pbb, line = 218 }, "")))
  add(raw(court_title(meta)))
  add(raw(P({ line = 218 }, "")))
  add(raw(caption(meta)))
  add(raw(P({ before = 480, after = 240, jc = "center", line = 480 }, R(string.upper(sx(meta.title)), true))))

  local numbered_prefix = meta.numbered_section and sx(meta.numbered_section) or nil
  local numbered = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local counter = 0
  local kinds = {}
  for i, b in ipairs(blocks) do kinds[i] = kind(b) end

  for i, b in ipairs(blocks) do
    local k = kinds[i]
    local prev = (i > 1) and kinds[i - 1] or "heading"
    local keep = (i >= n - 1)
    if k == "heading" then
      if b.level == 2 then
        numbered = numbered_prefix ~= nil and sx(b):sub(1, #numbered_prefix) == numbered_prefix
        counts[3] = 0
        counts[4] = 0
        counts[2] = counts[2] + 1
        add(b)
      elseif b.level == 3 or b.level == 4 then
        local lvl = b.level
        counts[lvl] = counts[lvl] + 1
        for q = lvl + 1, 6 do counts[q] = 0 end
        local label
        if lvl == 3 then label = string.char(64 + counts[3]) .. "." else label = counts[4] .. "." end
        local inl = pandoc.List({ pandoc.Str(label), TAB })
        inl:extend(b.content)
        b.content = inl
        add(b)
      else
        add(b)
      end
    elseif k == "para" and numbered then
      counter = counter + 1
      local inl = pandoc.List({ pandoc.Str(tostring(counter) .. "."), TAB })
      inl:extend(b.content)
      add(pandoc.Div({ pandoc.Para(inl) }, attr(keep and "SCB Numbered Keep" or "SCB Numbered")))
    elseif k == "para" then
      local style = keep and "SCB Body Keep" or (prev == "quote" and "SCB After Quote" or nil)
      if style then add(pandoc.Div({ b }, attr(style))) else add(b) end
    elseif k == "list" then
      local ordered = (b.t == "OrderedList")
      for j, item in ipairs(b.content) do
        local label = ordered and (string.char(96 + j) .. ")") or "\u{2022}"
        local first = item[1]
        local inl = pandoc.List({ pandoc.Str(label), TAB })
        if first and (first.t == "Para" or first.t == "Plain") then
          inl:extend(first.content)
        end
        add(pandoc.Div({ pandoc.Para(inl) }, attr(keep and "SCB List Keep" or "SCB List")))
        for q = 2, #item do add(item[q]) end
      end
    else
      add(b)
    end
  end

  add(raw(signature(sig, true)))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

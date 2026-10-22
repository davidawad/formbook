-- Complaint, DOCX engine (docs/DOCX.md). The markdown contract of ../typst/iand-complaint.typ, as a Word document on
-- the styles of docx/reference.xml (fb render builds reference.docx from it): the court title, the caption (a
-- borderless table with a column of ")" marks), the prayer's lettered items and the signature block are written as
-- WordprocessingML paragraphs; headings and body paragraphs keep their markdown structure. Paragraphs are numbered
-- here (Fed. R. Civ. P. 10(b)); a paragraph after an "<!--UNNUMBERED-->" marker (or starting "UNNUMBERED:") and the
-- lead-in are not. "<!--SIGNATURE-->" (or a paragraph "SIGNATURE") places the signature block. Page numbers come from
-- the reference's footer. Nothing here is case-specific: every name and number comes from the sample's frontmatter.
-- Known limit: the caption's ")" column has one mark per party line, as in the typst template; a party name that
-- wraps keeps one mark, so the marks fall short by a line there (typst does the same).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276       -- typst pitch-body 24 pt (LR 10(b)(1): double spaced), pitch-single 13.8 pt
local COURT_BELOW = 480             -- typst court-below: the court title to the caption, the caption to the text
local LIST_SPACE = 162              -- typst list-space 8.1 pt: above and below the prayer's list
local SIG_SPACE, SIG_GAP = 324, 162 -- typst sig-space 16.2 pt, sig-gap 8.1 pt
local TEXT_W = 9360                 -- 6.5 in: letter, 1-inch margins
local CAP_L, CAP_M = 4464, 432      -- typst caption-left 3.1 in, caption-marks 0.3 in
local CAP_R = TEXT_W - CAP_L - CAP_M
local CAP_INSET = 216               -- typst caption-inset 0.15 in
local CAP_GAP = 144                 -- typst caption-gap 0.1 in: the party names stand off the marks
local SIG_IND = 4320                -- typst sig-indent 3.0 in
local NIL = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
  .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- A paragraph: o = { before, after, line, left, jc, style }; single-spaced, flush left unless told otherwise.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  if not o.style then props[#props + 1] = xe.ind(o.left or 0, nil, 0) end
  if o.jc then props[#props + 1] = xe.jc(o.jc) end
  return xe.para(props, body)
end

-- An empty paragraph of `twips` (typst: a block's space above or below that no other block's space absorbs).
local function spacer(twips)
  return p("", { line = twips })
end

-- A run of paragraphs kept on one page (typst: block(breakable: false)): every one but the last keeps with the next.
local function kept(ps)
  for i, x in ipairs(ps) do
    if i < #ps then ps[i] = x:gsub("^<w:p><w:pPr>", "<w:p><w:pPr>" .. xe.KEEP, 1) end
  end
  return ps
end

-- The court title (LR 10(d)): district, division; centred bold single lines.
local function court_title(meta)
  local ls = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF IOWA" }
  if meta.division then ls[#ls + 1] = plain(meta.division):upper() end
  local out = {}
  for _, l in ipairs(ls) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end
  return table.concat(out)
end

-- The caption: the parties on the left, a ")" per party line in the middle, the case number and title on the right,
-- every line single-pitch and the right column's lines on the left column's grid.
local function caption(meta)
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = "v." end
    for _, n in ipairs(party.names) do left[#left + 1] = n end
    left[#left + 1] = party.designation
  end
  local lp, mp, rp = {}, {}, {}
  for i, line in ipairs(left) do
    lp[i] = p(xe.inl(line))
    mp[i] = p(xe.runs(")"))
  end
  rp[#rp + 1] = p(xe.runs("No. " .. plain(meta.case_number)))
  if meta.judge then rp[#rp + 1] = p(xe.runs("Judge: " .. plain(meta.judge)), { before = SINGLE }) end
  if meta.magistrate_judge then
    rp[#rp + 1] = p(xe.runs("Magistrate Judge: " .. plain(meta.magistrate_judge)), { before = SINGLE })
  end
  rp[#rp + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE })
  if meta.jury_demand == true then rp[#rp + 1] = p(xe.runs("JURY DEMAND", { b = true })) end

  local function cell(w, paras, mar, side)
    local tcpr = '<w:tcW w:w="' .. w .. '" w:type="dxa"/>'
    if mar then tcpr = tcpr .. '<w:tcMar><w:' .. (side or "left") .. ' w:w="' .. mar .. '" w:type="dxa"/></w:tcMar>' end
    return '<w:tc><w:tcPr>' .. tcpr .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblBorders>' .. NIL
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/>'
    .. '<w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_L .. '"/><w:gridCol w:w="' .. CAP_M .. '"/><w:gridCol w:w="'
    .. CAP_R .. '"/></w:tblGrid>'
    .. '<w:tr>' .. cell(CAP_L, lp, CAP_GAP, "right") .. cell(CAP_M, mp) .. cell(CAP_R, rp, CAP_INSET) .. '</w:tr></w:tbl>'
end

-- The signature block (typst signature-block): 16.2 pt above, "Dated:", 16.2 pt, then at 3 in "Respectfully
-- submitted,", the party and the firm lines, "By: /s/" with the signer and their lines, 8.1 pt between the groups;
-- 16.2 pt below. One block, kept on one page.
local function signature(meta, date)
  local sig = meta.signature
  local s = {}
  if date then s[#s + 1] = p(xe.runs("Dated: ") .. xe.inl(date), { before = SIG_SPACE }) end
  s[#s + 1] = p(xe.runs("Respectfully submitted,"), { left = SIG_IND, before = SIG_SPACE })
  local function group(items)
    for i, l in ipairs(items or {}) do
      s[#s + 1] = p(xe.inl(l), { left = SIG_IND, before = i == 1 and SIG_GAP or 0 })
    end
  end
  group(sig.party)
  group(sig.firm)
  local by = { "By: /s/ " .. plain(sig.signer), plain(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do by[#by + 1] = l end
  group(by)
  s[#s] = s[#s]:gsub('w:after="0"', 'w:after="' .. SIG_SPACE .. '"', 1)
  return table.concat(kept(s))
end

-- The prayer's lettered items (typst: the letter at 0.5 in, the text hanging at 0.9 in; "List Item" in
-- reference.xml), 8.1 pt above the first and below the last.
local function lettered(list)
  local out = {}
  local n = #list.content
  for i, item in ipairs(list.content) do
    local inl = pandoc.Inlines({})
    for k, b in ipairs(item) do
      if b.content then
        if k > 1 then inl:insert(pandoc.Space()) end
        inl:extend(b.content)
      end
    end
    local lab = list.t == "BulletList" and "\u{2022}" or (string.char(64 + i) .. ".")
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(inl), {
      style = "ListItem", line = BODY, before = i == 1 and LIST_SPACE or 0, after = i == n and LIST_SPACE or 0 })
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1391(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it,
-- except inside an abbreviation of single letters ("d/b/a", "c/o"), which the typst template keeps whole.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function single(t, i, step)
  -- the letter at i is a whole one-letter part: the character beyond it (i + step) is not a letter
  local c = t:sub(i + step, i + step)
  return t:sub(i, i):match("%a") ~= nil and (c == "" or c == "/" or not c:match("%a"))
end

local function slashes(t)
  local out, last = {}, 1
  for i = 2, #t - 1 do
    if t:sub(i, i) == "/" and t:sub(i + 1, i + 1):match("[^/%d%s]") and not (single(t, i - 1, -1) and single(t, i + 1, 1)) then
      out[#out + 1] = t:sub(last, i) .. "\u{200B}"
      last = i + 1
    end
  end
  out[#out + 1] = t:sub(last)
  return table.concat(out)
end

local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = slashes(t) end
  if t ~= s.text then return pandoc.Str(t) end
end

-- strip a leading "WORD" (and the space after it) from a paragraph; true if it was there
local function take_prefix(c, word)
  local first = c[1]
  if first and first.t == "Str" and first.text == word then
    c:remove(1)
    if c[1] and c[1].t == "Space" then c:remove(1) end
    return true
  end
  return false
end

-- The sample's markers are HTML comments ("<!--UNNUMBERED-->", "<!--SIGNATURE-->"). The CommonMark reader (the
-- reader of cmarker, which the typst template renders with; reference.xml pandoc-from) takes a marker and the text
-- after it on the same line as one raw HTML block: the text is read back as its own paragraph after the marker.
local function expand(blocks)
  local out = pandoc.Blocks({})
  for _, b in ipairs(blocks) do
    local word, rest = nil, nil
    if b.t == "RawBlock" and b.format == "html" then word, rest = b.text:match("^<!%-%-(%u+)%-%->%s*(.-)%s*$") end
    if word then
      out:insert(pandoc.RawBlock("html", "<!--" .. word .. "-->"))
      if rest ~= "" then out:extend(pandoc.read(rest, "commonmark+smart").blocks) end
    else
      out:insert(b)
    end
  end
  return out
end

local function marker(b)
  if b.t == "RawBlock" and b.format == "html" then return b.text:match("^<!%-%-(%u+)%-%->$") end
  if b.t == "Para" and #b.content == 1 and b.content[1].t == "Str" and b.content[1].text == "SIGNATURE" then
    return "SIGNATURE"
  end
end

local function finish(doc)
  local meta = doc.meta
  -- pandoc would print the date as a title block; the date belongs to the signature block only
  local date = meta.date
  meta.date = nil
  local out = {}
  local function add(x) out[#out + 1] = x end

  add(xe.raw(court_title(meta) .. spacer(COURT_BELOW)))
  add(xe.raw(caption(meta) .. spacer(COURT_BELOW)))

  if meta.lead_in then add(pandoc.Para(pandoc.Inlines(meta.lead_in))) end

  local numbered = meta.numbered == true
  local n = 0
  local skip_number = false
  for _, b in ipairs(doc.blocks) do
    local m = marker(b)
    if m == "SIGNATURE" then
      add(xe.raw(signature(meta, date)))
    elseif m == "UNNUMBERED" then
      skip_number = true
    elseif b.t == "Header" then
      if b.level == 1 then
        b.content = b.content:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      add(b)
    elseif b.t == "Para" then
      local c = pandoc.List(b.content)
      local unnumbered = take_prefix(c, "UNNUMBERED:") or skip_number
      skip_number = false
      if numbered and not unnumbered then
        n = n + 1
        c:insert(1, pandoc.RawInline("openxml", xe.runs(n .. ".\t")))
      end
      add(pandoc.Para(c))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      add(xe.raw(lettered(b)))
    else
      add(b)
    end
  end

  doc.blocks = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  return doc
end

return { { Blocks = expand }, { Str = break_rules }, { Pandoc = finish } }

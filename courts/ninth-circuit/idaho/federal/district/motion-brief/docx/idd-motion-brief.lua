-- idd-motion-brief.lua (docx engine): the D. Idaho memorandum in support of a motion as Word paragraphs, so that it
-- reads and breaks as typst/idd-motion-brief.typ does: the counsel block in the upper left (Loc. Civ. R. 5.2(b)),
-- the court title and the caption four inches down or right after a longer counsel block (LR 5.2(b): a one-row
-- table at least 3 in high holds the counsel), the caption (a table whose party column has the right and bottom
-- rules; beside it the CM/ECF number, the title and the motion's docket number, LR 5.2(b)(3), (5) and LR 7.1(a)(3));
-- the body (every paragraph indented, headings, bulleted items with a hanging indent, a centered "* * *", footnotes
-- at 12 pt); the signature block; the certificate of service on its own page; the footer "N - TITLE" (LR 5.2(a):
-- every page numbered). Everything printed comes from the sample's frontmatter and body: no case text lives here.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line and a
-- footnote line), the spaces between blocks those of the typst template, and the break rules of typst on every run.
-- A paragraph that carries a footnote is left to pandoc in Body Text Note or List Item Indented (the same layout),
-- so that pandoc writes the note.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap: one blank single line
local COVER_GAP = 240                    -- typst cover-gap, 12 pt below the counsel block at least
local COVER_H = 4320                     -- typst caption-top - margin: 3 in
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local LABEL = 720                        -- typst item-label, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4680                    -- typst caption-left, 3.25 in
local CAP_PAD, CAP_BOTTOM = 185, 160     -- typst caption-pad 10 pt less the 0.75 pt rule LibreOffice takes from the cell; caption-bottom 8 pt
local CAP_RIGHT = 504                    -- typst caption-right, 0.35 in
local SIG_LEFT = 4464                    -- typst sig-left, 3.1 in
local FOOTER = 735                       -- the footer line's foot above the page edge: typst footer-descent 30 %

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless one-row table that never splits: cells = { { width, paragraphs, tcBorders } }; height: the row's
-- least height (twips), if any.
local function tbl(cells, height)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    local body = #c[2] > 0 and table.concat(c[2]) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  local tr = '<w:cantSplit/>' .. (height and ('<w:trHeight w:val="' .. height .. '" w:hRule="atLeast"/>') or '')
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr>' .. tr .. '</w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function caption(meta)
  local parties = meta.caption.parties
  local left = {}
  local function add(x, o)
    o = o or {}
    o.right = CAP_PAD
    left[#left + 1] = p(x, o)
  end
  for k, party in ipairs(parties) do
    if k > 1 then add(xe.runs("v.")) end
    for _, n in ipairs(party.names) do add(xe.inl(n)) end
    -- the last designation keeps the caption's bottom padding (typst: pad(bottom: caption-bottom))
    add(xe.inl(party.designation), { after = k == #parties and CAP_BOTTOM or 0 })
  end
  local right = {
    p(xe.runs("Case No. " .. plain(meta.case_number)), { left = CAP_RIGHT }),
    p(xe.inl(meta.brief_title, { b = true }), { before = GAP, left = CAP_RIGHT }),
  }
  if meta.motion_docket and plain(meta.motion_docket) ~= "" then
    -- LR 7.1(a)(3): a paper filed in support of a motion carries that motion's docket number in the caption.
    right[#right + 1] = p(xe.runs("[" .. plain(meta.motion_docket) .. "]", { b = true }), { before = GAP, left = CAP_RIGHT })
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return tbl({ { CAP_LEFT, left, rule }, { TEXTW - CAP_LEFT, right } })
end

local function cover(meta)
  local out = {}
  -- LR 5.2(b): the counsel block in a row at least 3 in high (the caption four inches down), and at least
  -- COVER_GAP above the court title when it is longer (typst: max(caption-top - margin, used + cover-gap)).
  local counsel = {}
  local lines = meta.counsel or {}
  for i, l in ipairs(lines) do
    local s = plain(l)
    counsel[#counsel + 1] = p(s:match("%S") and xe.inl(l) or "", { after = i == #lines and COVER_GAP or 0 })
  end
  out[#out + 1] = tbl({ { TEXTW, counsel } }, COVER_H)
  for _, c in ipairs(meta.caption.court) do out[#out + 1] = p(xe.inl(c, { b = true }), { jc = "center" }) end
  -- typst: the caption a blank single line below the court title, the body a blank single line below the caption
  out[#out + 1] = p("", { line = GAP })
  out[#out + 1] = caption(meta)
  out[#out + 1] = p("", { line = GAP })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service: the left cell beside the signature column; one row that never splits
-- ---------------------------------------------------------------------------

-- lines: { { before, inlines-or-string } }
local function sig_grid(left, lines)
  local right = {}
  for _, l in ipairs(lines) do right[#right + 1] = p(xe.inl(l[2]), { before = l[1] }) end
  return tbl({ { SIG_LEFT, { left } }, { TEXTW - SIG_LEFT, right } })
end

local function signature(meta)
  local sig = meta.signature
  local lines = { { GAP, "Respectfully submitted," } }
  for i, f in ipairs(sig.firm) do lines[#lines + 1] = { i == 1 and GAP or 0, f } end
  lines[#lines + 1] = { GAP, pandoc.Inlines({ pandoc.Str("/s/"), pandoc.Space() }) .. pandoc.Inlines(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { 0, l } end
  return sig_grid(p(xe.runs("Dated: ") .. xe.inl(meta.signing_date), { before = GAP }), lines)
end

-- Its own page (convention; LR 5.2 is silent), headed like a level-1 heading, signed by the filer.
local function certificate(meta, out)
  local cert = meta.certificate
  out[#out + 1] = xe.para({ xe.style("Heading1"), xe.KEEP, xe.BREAK, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.runs("CERTIFICATE OF SERVICE", { b = true }))
  out[#out + 1] = p(xe.inl(cert.text), { line = BODY, first = INDENT })
  local lines = { { GAP, pandoc.Inlines({ pandoc.Str("/s/"), pandoc.Space() }) .. pandoc.Inlines(cert.signer) } }
  for _, l in ipairs(cert.lines or {}) do lines[#lines + 1] = { 0, l } end
  out[#out + 1] = sig_grid(p("", { before = GAP }), lines)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, on the line grid, kept with the text: level 1 centered bold capitals, level 2
-- centered bold, level 3 bold with a half-inch hanging indent. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  local lvl = math.min(b.level, 3)
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local ind = lvl == 3 and xe.ind(INDENT, INDENT, nil) or xe.ind(0, nil, 0)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), ind,
    xe.jc(lvl < 3 and "center" or "left") }, xe.inl(content, { b = true }))
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

local ZWSP = "\u{200B}"

-- Line breaks inside a web address (as the tenth-circuit briefs' docx/ca10.lua). typst breaks a word that holds
-- "http://" or "https://" (from there to the end of the word, less trailing punctuation) where the class of
-- character changes: letter, digit, opening bracket, other; after an "other" character before anything, and between
-- a letter and a digit either way, never after an opening bracket; a piece of 16 characters or more breaks after
-- any character. LibreOffice breaks such a word by Unicode rules: the typst places get a zero-width space.
local function url_cuts(link)
  local function class(c)
    if c:match("^%a$") or #c > 1 then return "A" end
    if c:match("^%d$") then return "D" end
    if c == "(" or c == "[" then return "O" end
    return "X"
  end
  local cuts, starts = {}, {}
  for q in utf8.codes(link) do starts[#starts + 1] = q - 1 end
  local offset, prev = 0, "X"
  for i, b in ipairs(starts) do
    local c = link:sub(b + 1, starts[i + 1] or #link)
    local cl = class(c)
    if b > 0 and prev ~= "O" and ((cl == "X" and prev == "X") or (cl ~= "X" and cl ~= prev)) then
      if b - offset >= 16 then
        for _, q in ipairs(starts) do if q > offset and q < b then cuts[q] = true end end
      end
      cuts[b] = true
      offset = b
    end
    prev = cl
  end
  return cuts
end

local function url_breaks(text, at)
  local tail_at = #text + 1
  while tail_at > at and text:sub(tail_at - 1, tail_at - 1):match("[.,;:!?]") do tail_at = tail_at - 1 end
  local link = text:sub(at, tail_at - 1)
  local keys = {}
  for k in pairs(url_cuts(link)) do keys[#keys + 1] = k end
  table.sort(keys)
  local out, from = {}, 1
  for _, k in ipairs(keys) do
    out[#out + 1] = link:sub(from, k)
    from = k + 1
  end
  out[#out + 1] = link:sub(from)
  return text:sub(1, at - 1) .. table.concat(out, ZWSP) .. text:sub(tail_at)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space), a web address's (above). None shows in the PDF text.
local function breaks(s)
  local at = s.text:find("https?://")
  if at then return pandoc.Str(url_breaks(s.text, at)) end
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/" .. ZWSP .. "%1")))
end

-- A space before a footnote mark is not printed (typst sets the mark against the word).
local function tight_notes(inl)
  for i = #inl - 1, 1, -1 do
    if inl[i].t == "Space" and inl[i + 1].t == "Note" then inl:remove(i) end
  end
  return inl
end

-- A doubled sign stays with its number ("§§ 7501"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The footer (LR 5.2(a)): the page number, " - " and the paper's title in capitals, flush left in a single-spaced
-- line box (typst: footer-block).
local function footer(meta)
  return '<w:p><w:pPr>' .. xe.spacing(0, 0, SINGLE) .. xe.ind(0, nil, 0) .. xe.jc("left") .. '</w:pPr>' ..
    '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>' ..
    xe.runs(" - " .. pandoc.text.upper(plain(meta.footer_title))) .. '</w:p>'
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdIddFooter"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1441" w:bottom="1440" w:left="1440" ' ..
  'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = tight_notes })
  local meta = doc.meta
  -- pandoc would print the date as a title block; it is used only in the signature.
  meta.signing_date = meta.date
  write_file("FORMBOOK_FOOTERS", "rIdIddFooter\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = cover(meta)
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      local n = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
        if has_note(item[1]) then
          local c = pandoc.Inlines({ pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
          c:extend(item[1].content)
          out[#out + 1] = pandoc.Div({ pandoc.Para(c):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = "List Item Indented" })
        else
          out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
            { line = BODY, left = INDENT + LABEL, hanging = LABEL })
        end
        n = n + 1
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b) == "* * *" then
        -- a section break, centered on its own line
        out[#out + 1] = p(xe.runs("* * *"), { line = BODY, jc = "center" })
      elseif has_note(b) then
        out[#out + 1] = pandoc.Div({ pandoc.Para(b.content):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = "Body Text Note" })
      else
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
      end
    else
      error("idd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  if meta.certificate then certificate(meta, out) end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

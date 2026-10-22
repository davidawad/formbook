-- W.D. Va. brief in support of a motion, docx engine (docs/DOCX.md), so that it reads and breaks as
-- typst/vawd-motion-brief.typ does: the three-line court title, the caption (box or ")" style), the brief title in
-- capitals; section headings (# ) centered bold capitals; numbered headings (## 1., ### a., #### (i)) with a hanging
-- label; paragraphs double-spaced and first-line indented; block quotations single-spaced; native footnotes; the
-- signature block at 3.25 in ("Dated:", the preamble, the e-signature, each counsel, the role lines); the certificate
-- of service (centered bold title, the text, the recipients, the signer's block). Every case word comes from the
-- sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs, headings,
-- quotations, list items and footnotes are written by pandoc in the styles of docx/reference.xml; the cover,
-- signature and certificate are written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body, pitch-single
local GAP = 276                          -- typst gap: a blank single line
local INDENT = 720                       -- typst para-indent
local TEXTW = 9360                       -- 6.5 in
local CAPTION = 4752                     -- typst caption-width, 3.3 in
local INSET = 180                        -- typst caption-inset, 0.125 in
local GUTTER = 216                       -- typst caption-gutter, 0.15 in
local NUMBER = 144                       -- typst number-inset, 0.1 in
local PARENS = 576                       -- typst parens-width, 0.4 in
local VERSUS, DESIGNATION = 864, 2160    -- typst versus-indent 0.6 in, designation-indent 1.5 in
local SIG = 4680                         -- typst signature-indent, 3.25 in
local RECIPIENT = 720                    -- typst recipient-indent, 0.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  if m == nil then return {} end
  return m
end

-- Inlines in capitals (typst upper), footnotes left as written.
local function upper(x)
  if type(x) == "string" then return pandoc.text.upper(x) end
  if pandoc.utils.type(x) ~= "Inlines" then return pandoc.text.upper(plain(x)) end
  local out = pandoc.Inlines({})
  for _, el in ipairs(x) do
    if el.t == "Str" then
      out:insert(pandoc.Str(pandoc.text.upper(el.text)))
    elseif el.t == "Note" then
      out:insert(el)
    elseif el.content and pandoc.utils.type(el.content) == "Inlines" then
      local c = el:clone()
      c.content = upper(el.content)
      out:insert(c)
    else
      out:insert(el)
    end
  end
  return out
end

-- A paragraph: o = { before, after, line, left, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

-- The party lines of the caption, in order: { inlines, left indent, is "v." }.
local function party_lines(caption)
  local items = {}
  for i, party in ipairs(list(caption.parties)) do
    if i > 1 then items[#items + 1] = { xe.runs("v."), VERSUS, true, "v." } end
    for _, n in ipairs(list(party.names)) do items[#items + 1] = { xe.inl(n), 0, false, plain(n) } end
    items[#items + 1] = { xe.inl(party.designation), DESIGNATION, false, plain(party.designation) }
  end
  return items
end

-- The lines a caption line takes in its column (typst measures it): its width estimated from Times New Roman's
-- advances at 12 pt (capitals and wide letters 0.72 em, small letters 0.47 em, spaces 0.25 em, the rest 0.4 em).
local function caption_rows(text, indent)
  local w = indent / 20
  for _, c in utf8.codes(text) do
    local ch = utf8.char(c)
    if ch == " " then w = w + 3
    elseif ch:match("^[A-Z]$") or ch == "m" or ch == "w" then w = w + 8.64
    elseif ch:match("^[a-z]$") then w = w + 5.64
    else w = w + 4.8 end
  end
  return math.max(1, math.ceil(w / (CAPTION / 20)))
end

local function tc(w, body, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. body .. '</w:tc>'
end

local function tbl(cols, rows, mar)
  local grid, total = {}, 0
  for _, c in ipairs(cols) do grid[#grid + 1] = '<w:gridCol w:w="' .. c .. '"/>'; total = total + c end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

local function case_number(meta)
  return xe.runs(plain(meta.case_label) .. " " .. plain(meta.case_number))
end

-- Box caption: the party lines closed by a rule at their right and under the last; the file number opposite, on the
-- first "v." row. One table row per party line, a blank single line between rows.
local function caption_box(meta, caption)
  local lines = party_lines(caption)
  local right = TEXTW - CAPTION - GUTTER
  local rows, numbered = {}, false
  for k, it in ipairs(lines) do
    local last = k == #lines
    local before = k > 1 and GAP or 0
    local box = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
      (last and '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' or '') .. '</w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. INSET .. '" w:type="dxa"/>' ..
      (last and ('<w:bottom w:w="' .. INSET .. '" w:type="dxa"/>') or '') .. '</w:tcMar>'
    local num = p("", { before = before })
    if it[3] and not numbered then numbered = true; num = p(case_number(meta), { before = before, left = NUMBER }) end
    rows[#rows + 1] = '<w:tr>' .. tc(CAPTION, p(it[1], { before = before, left = it[2] }), box) ..
      tc(GUTTER, p("", { before = before })) .. tc(right, num) .. '</w:tr>'
  end
  return tbl({ CAPTION, GUTTER, right }, rows)
end

-- ")" caption: a ")" per line of each party line, and the file number right of the marks on the first "v." row.
local function caption_parens(meta, caption)
  local rows, numbered = {}, false
  local right = TEXTW - CAPTION - PARENS
  for _, it in ipairs(party_lines(caption)) do
    local marks = {}
    for _ = 1, caption_rows(it[4], it[2]) do marks[#marks + 1] = p(xe.runs(")"), { jc = "center" }) end
    local num = p("")
    if it[3] and not numbered then numbered = true; num = p(case_number(meta)) end
    rows[#rows + 1] = '<w:tr>' .. tc(CAPTION, p(it[1], { left = it[2] })) .. tc(PARENS, table.concat(marks)) ..
      tc(right, num) .. '</w:tr>'
  end
  return tbl({ CAPTION, PARENS, right }, rows)
end

local function cover(meta, out)
  local lines = { "UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF VIRGINIA", pandoc.text.upper(plain(meta.division)) }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l), { jc = "center", after = i == #lines and BODY or 0 })
  end
  local caption = meta.caption or {}
  if plain(caption.style) == "parens" then
    out[#out + 1] = caption_parens(meta, caption)
  else
    out[#out + 1] = caption_box(meta, caption)
  end
  -- the title: Word has no space after a table, so it takes the space before it
  out[#out + 1] = p(xe.inl(upper(meta.brief_title), { b = true }), { before = BODY, after = GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (Fed. R. Civ. P. 11(a); Local Rule 11(a))
-- ---------------------------------------------------------------------------

-- The signer's block: { inlines, space before } per line; each group a blank line from the one before.
local function signer_lines(sig, preamble, above)
  local groups = {}
  local pre = preamble and list(sig.preamble) or {}
  if #pre > 0 then groups[#groups + 1] = pre end
  local first = { sig.signed_by }
  for k, g in ipairs(list(sig.counsel)) do
    local lines = {}
    for _, n in ipairs(list(g.names)) do lines[#lines + 1] = n end
    for _, l in ipairs(list(g.lines)) do lines[#lines + 1] = l end
    if k == 1 then
      for _, l in ipairs(lines) do first[#first + 1] = l end
    else
      groups[#groups + 1] = first
      first = lines
    end
  end
  groups[#groups + 1] = first
  if #list(sig.role) > 0 then groups[#groups + 1] = sig.role end
  local out = {}
  for k, g in ipairs(groups) do
    for i, l in ipairs(g) do
      out[#out + 1] = { xe.inl(l), i == 1 and (k == 1 and above or GAP) or 0 }
    end
  end
  return out
end

-- Lines kept together on one page (typst's unbreakable block): every one but the last keeps with the next.
local function kept(lines, out)
  for i, l in ipairs(lines) do
    local o = l[3] or {}
    o.before, o.left, o.keep = l[2], o.left or SIG, i < #lines
    out[#out + 1] = p(l[1], o)
  end
end

local function signature(meta, out)
  local sig = meta.signature or {}
  local lines
  if meta.date then
    lines = { { xe.runs("Dated: " .. plain(meta.date)), BODY, { left = 0 } } }
    for _, l in ipairs(signer_lines(sig, true, GAP)) do lines[#lines + 1] = l end
  else
    lines = signer_lines(sig, true, BODY)
  end
  kept(lines, out)
end

local function certificate(meta, out)
  local svc = meta.service
  if not svc then return end
  out[#out + 1] = p(xe.inl("CERTIFICATE OF SERVICE", { b = true }), { before = BODY, after = GAP, jc = "center", keep = true })
  out[#out + 1] = p(xe.inl(svc.text), { after = GAP, line = BODY, first = INDENT, keep = true })
  local lines = {}
  for _, l in ipairs(list(svc.recipients)) do lines[#lines + 1] = { xe.inl(l), 0, { left = RECIPIENT, keep = true } } end
  for _, l in ipairs(signer_lines(meta.signature or {}, false, GAP)) do lines[#lines + 1] = l end
  kept(lines, out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

local function has_note(b)
  local note = false
  b:walk({ Note = function() note = true end })
  return note
end

-- The last section (its level-1 heading and what follows) is kept on one page with the signature block when it is
-- short and has no footnote: typst's final-section, the same test on the same markdown (the body split at blank
-- lines, footnote definitions left out, the chunks from the last "# " heading joined by a blank line, under 1200
-- bytes and no "[^"). Returns the index of that heading among the blocks, or nil.
local function final_section(blocks)
  local f = io.open(PANDOC_STATE.input_files[1], "r")
  local src = f:read("a")
  f:close()
  local md = src:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1)
  md = md:gsub("\r?\n[ \t]*\r?\n", "\30")
  local chunks = {}
  for c in (md .. "\30"):gmatch("([^\30]*)\30") do
    local t = c:match("^%s*(.-)%s*$")
    if t ~= "" and t:sub(1, 2) ~= "[^" then chunks[#chunks + 1] = c end
  end
  local last
  for i, c in ipairs(chunks) do
    if c:match("^%s*# ") then last = i end
  end
  if not last then return nil end
  local tail = table.concat(chunks, "\n\n", last)
  if #tail >= 1200 or tail:find("[^", 1, true) then return nil end
  local h
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then h = i end
  end
  return h
end

local function body(blocks, out)
  local keep_from = final_section(blocks)
  local c = { 0, 0, 0, 0 }
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lvl = math.min(b.level, 4)
      c[lvl] = c[lvl] + 1
      for k = lvl + 1, 4 do c[k] = 0 end
      if lvl == 1 then
        out[#out + 1] = pandoc.Header(1, upper(b.content))
      else
        local label = lvl == 2 and (c[2] .. ".") or lvl == 3 and (string.char(96 + c[3]) .. ".") or
          ("(" .. roman(c[4]) .. ")")
        local inl = pandoc.Inlines({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        inl:extend(b.content)
        out[#out + 1] = pandoc.Header(lvl, inl)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local style = (keep_from and i > keep_from) and "Body Keep" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("vawd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 55–57": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local raw = {}
  cover(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  body(doc.blocks, out)
  raw = {}
  signature(meta, raw)
  certificate(meta, raw)
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

-- W.D. Mich. complaint (miwd), docx engine. Mirrors typst/miwd-complaint.typ: the cover (the court title centered in
-- bold; the caption, Fed. R. Civ. P. 10(a): the parties single-spaced in a column ruled on its right and under it,
-- "v." between them, and at the right the case number, the judge and the title in bold; the counsel block), page 2
-- (the title centered in bold, the lead-in), the body (paragraphs numbered 1, 2, ... (Fed. R. Civ. P. 10(b)) until
-- the heading named by numbering_stops_at; headings centered in bold; list items lettered A., B., ...), and the
-- signature block (Fed. R. Civ. P. 11(a); LCivR 10.3), kept on one page with the last paragraph. Numbers and letters
-- are typed text, as the typst template types them. Every case word comes from the frontmatter. The footer (the page
-- number centered, none on the cover) and the last section are written for fb render ($FORMBOOK_FOOTERS,
-- $FORMBOOK_FINAL); font, body styles, headings and margins are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local CAP_LEFT, CAP_GUTTER = 4680, 360        -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_RIGHT = 9360 - CAP_LEFT - CAP_GUTTER
local CAP_INSET = 144                         -- typst caption-right-inset 0.1 in
local CAP_PAD_RIGHT = 200                     -- typst caption-pad-right 10 pt
local CAP_PAD_BOTTOM = 160 - 15               -- typst caption-pad-bottom 8 pt, less the 0.75 pt rule LibreOffice
                                              -- sets below the row (typst strokes take no room)
local CAPTION_ABOVE, TITLE_ABOVE = 480, 480   -- typst caption-above, title-above 24 pt
local COUNSEL_ABOVE, GROUP_GAP = 960, 276     -- typst counsel-above 48 pt, group-gap 13.8 pt
local LEAD_ABOVE = 480                        -- typst lead-above 24 pt
local SIG_COL = 4032                          -- typst sig-col 2.8 in
local SIG_ABOVE, SIG_GAP = 480, 240           -- typst sig-above 24 pt, sig-gap 12 pt
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("miwd complaint docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- One line of the frontmatter. pandoc reads a value that starts like a list label ("(313) 567-6170") as a list and
-- keeps only the item's text: such a value is set from its text as written in the sample (`raw`, from
-- $FORMBOOK_META), as typst reads it.
local function line(l, o, raw)
  if type(l) == "string" then return xe.runs(l, o) end
  if type(raw) == "string" and (raw:match("^%(?%d+[%.%)]%s") or raw:match("^%(?%a[%.%)]%s")) then return xe.runs(raw, o) end
  if pandoc.utils.type(l) == "Blocks" then
    if #l == 1 and (l[1].t == "Para" or l[1].t == "Plain") then return xe.inl(l[1].content, o) end
    check(type(raw) == "string", "a frontmatter line pandoc reads as blocks: " .. stringify(l))
    return xe.runs(raw, o)
  end
  return xe.inl(l, o)
end

-- The items of a metadata list, each with the same item as written in the sample (`raw`, a list of strings or nil).
local function with_raw(v, raw)
  local out = {}
  for i, x in ipairs(items(v)) do out[i] = { x, type(raw) == "table" and raw[i] or nil } end
  return out
end

local function read_meta()
  local path = os.getenv("FORMBOOK_META")
  if not path then return {} end
  local f = io.open(path, "r")
  if not f then return {} end
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false)
end

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, brk, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  if not o.style or o.left or o.hanging or o.first then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  end
  if not o.style or o.jc then props[#props + 1] = xe.jc(o.jc or "left") end
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v(), or a block's space above a table): an empty paragraph that tall.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local RULE = ' w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

-- A one-row table without cell margins: cells = { { w, body, pr } }, pr: the cell's own borders and margins.
local function row(cells)
  local total, grid, tcs = 0, {}, {}
  for _, c in ipairs(cells) do
    total = total + c[1]
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>'
      .. (c[2] ~= "" and c[2] or p("")) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Footer and section (LCivR 10.1: letter, 1 in margins)
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local PAGE_FOOTER = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')

-- The page number on every page but the cover (titlePg; fb render's empty rIdFtrNone on the first page).
local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdMiwdPage"/>'
  .. '<w:footerReference w:type="first" r:id="rIdFtrNone"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/>'
  .. '<w:titlePg/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, counsel; page 2: the title and the lead-in
-- ---------------------------------------------------------------------------

local function cover(m, R)
  local out = {}
  local court = { "UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF MICHIGAN" }
  if m.division and txt(m.division) ~= "" then court[#court + 1] = txt(m.division):upper() end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end

  local blank = "__________________"
  local cn = txt(m.case_number)
  if cn == "" then cn = blank end
  local hon = txt(m.judge)
  if hon == "" then hon = blank end
  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(line(n)) end
    left[#left + 1] = p(line(party.designation))
  end
  local right = {
    p(xe.runs("Case No. " .. cn), { left = CAP_INSET }),
    p(xe.runs("Hon. " .. hon), { left = CAP_INSET }),
    p(xe.inl(m.title, { b = true }), { left = CAP_INSET, before = TITLE_ABOVE }),
  }
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = row({
    { CAP_LEFT, table.concat(left), '<w:tcBorders><w:bottom' .. RULE .. '<w:right' .. RULE .. '</w:tcBorders>'
      .. '<w:tcMar><w:bottom w:w="' .. CAP_PAD_BOTTOM .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD_RIGHT
      .. '" w:type="dxa"/></w:tcMar>' },
    { CAP_GUTTER, "" },
    { CAP_RIGHT, table.concat(right) },
  })

  local rc = R.counsel or {}
  for k, g in ipairs(m.counsel) do
    local r = rc[k] or {}
    local ls = with_raw(g.names, r.names)
    for _, x in ipairs(with_raw(g.lines, r.lines)) do ls[#ls + 1] = x end
    for i, l in ipairs(ls) do
      local before = 0
      if i == 1 then before = k == 1 and COUNSEL_ABOVE or GROUP_GAP end
      out[#out + 1] = p(line(l[1], nil, l[2]), { before = before, keep = i < #ls })
    end
  end

  out[#out + 1] = p(xe.inl(m.title, { b = true }), { jc = "center", pitch = BODY, brk = true })
  if m.lead_in then out[#out + 1] = p(xe.inl(m.lead_in), { style = "BodyText", pitch = BODY, before = LEAD_ABOVE }) end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body and signature
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

local LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

-- The body as raw paragraphs; the last one (a paragraph or a list's last item) is kept with the signature.
local function body(blocks, stop_at)
  local out = {}
  local n = 0
  local numbering = true
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      if stop_at and stringify(b.content) == stop_at then numbering = false end
      out[#out + 1] = p(xe.inl(level == 1 and upper(b.content) or b.content),
        { style = "Heading" .. level, keep = true, pitch = BODY })
    elseif b.t == "Para" or b.t == "Plain" then
      local content = b.content
      if numbering then
        n = n + 1
        local label = n .. ".\t"
        out[#out + 1] = function(keep)
          return p(xe.runs(label) .. xe.inl(content), { style = "NumberedParagraph", keep = keep, pitch = BODY })
        end
      else
        out[#out + 1] = function(keep)
          return p(xe.inl(content), { style = "BodyText", keep = keep, pitch = BODY })
        end
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local content = pandoc.utils.blocks_to_inlines(item)
        local label = LETTERS:sub(i, i) .. ".\t"
        out[#out + 1] = function(keep)
          return p(xe.runs(label) .. xe.inl(content), { style = "ListLetter", keep = keep, pitch = BODY })
        end
      end
    else
      error("miwd-complaint.lua: unexpected block " .. b.t)
    end
  end
  for i, x in ipairs(out) do
    if type(x) == "function" then out[i] = x(i == #out) end
  end
  return table.concat(out)
end

-- The signature block (typst signature-block): single-spaced from SIG_COL, "Dated:" and the date at the left of its
-- first line (a tab), kept on one page, a space of its own above.
local function signature(m, R)
  local sig = m.signature
  local rs = R.signature or {}
  local lines = { { xe.runs("Respectfully submitted,"), 0 } }
  for i, f in ipairs(items(sig.firm)) do lines[#lines + 1] = { line(f), i == 1 and SIG_GAP or 0 } end
  lines[#lines + 1] = { xe.runs("By: /s/ " .. txt(sig.signer)), SIG_GAP }
  for _, l in ipairs(with_raw(sig.lines, rs.lines)) do lines[#lines + 1] = { line(l[1], nil, l[2]), 0 } end
  local out = {}
  for i, l in ipairs(lines) do
    local keep = i < #lines
    if i == 1 then
      out[#out + 1] = p(xe.runs("Dated: " .. txt(m.date) .. "\t") .. l[1], { before = SIG_ABOVE, left = SIG_COL,
        hanging = SIG_COL, tab = SIG_COL, keep = keep })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG_COL, keep = keep })
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1343(a)(3)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 1331"; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("^[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  check(m.caption ~= nil and m.caption.parties ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.title ~= nil, "Fed. R. Civ. P. 10(a): the title is required")
  check(m.counsel ~= nil, "the counsel block is required")
  check(m.signature ~= nil, "Fed. R. Civ. P. 11(a): the signature is required")
  write_file("FORMBOOK_FOOTERS", "rIdMiwdPage\t" .. PAGE_FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local R = read_meta()
  local stop_at = m.numbering_stops_at and txt(m.numbering_stops_at) or nil
  local out = pandoc.Blocks({ xe.raw(cover(m, R)) })
  out:insert(xe.raw(body(doc.blocks, stop_at)))
  out:insert(xe.raw(signature(m, R)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

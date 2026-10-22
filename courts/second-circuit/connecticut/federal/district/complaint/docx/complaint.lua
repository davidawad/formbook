-- ctd complaint, docx engine. Mirrors typst/ctd-complaint.typ; rules and conventions are in ../README.md. The court
-- title, the caption (the parties at left in a column ruled right and bottom; the case number, the date, the title
-- and the jury demand at right), the lead-in, the headings, the numbered allegations (Fed. R. Civ. P. 10(b)), the
-- unnumbered paragraphs (marked `<!-- unnumbered -->`), the lists and the signature block (L. Civ. R. 10; EFPP XI.B)
-- are built here. Font, spacing and margins are styles in docx/reference.xml (fb render builds the reference document
-- from it); the page number is the last section's footer, written to $FORMBOOK_FOOTERS and $FORMBOOK_FINAL. Numbers
-- and labels are typed text, as the typst template types them. Content-agnostic: every case-specific word comes from
-- the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local GAP = 552                          -- typst gap: one blank body line
local CAPTION_GAP = 276                  -- typst caption-gap 13.8 pt
local CAP_BELOW = 261                    -- typst caption-below 13.8 pt, less the 0.75 pt bottom rule LibreOffice adds to the row
local TEXTW = 9360                       -- typst text-width, 6.5 in
local CAP_LEFT = 4752                    -- typst caption-left 3.3 in
local CAP_RULE_PAD = 200                 -- typst caption-rule-pad 10 pt
local CAP_RIGHT_IN = 432                 -- typst caption-gutter 0.2 in + caption-pad 0.1 in
local DESIG = 2160                       -- typst designation-indent 1.5 in
local SIG_LEFT = 4032                    -- typst sig-left 2.8 in
local UNNUMBERED = "<!-- unnumbered -->" -- typst unnumbered-mark (pandoc reads it as a raw HTML block of its own)

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

local function need(m, key)
  if m[key] == nil then error("complaint.lua: missing required metadata field `" .. key .. "`") end
  return m[key]
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A single-spaced paragraph: o = { before, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single-spaced lines (typst line-stack): each item { xml, left } or "" (a blank single line). o = { above, left, keep }.
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for _, l in ipairs(lines) do
    if l == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(l[1], { before = gap, left = (o.left or 0) + (l[2] or 0), keep = o.keep, jc = l[3] })
      gap = 0
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Court title and caption (Fed. R. Civ. P. 10(a); L. Civ. R. 10)
-- ---------------------------------------------------------------------------

local function upper(v)
  return pandoc.Inlines(pandoc.utils.type(v) == "Inlines" and v or { pandoc.Str(txt(v)) })
    :walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function cover(m)
  local court = {}
  for _, l in ipairs(items(need(m, "court"))) do court[#court + 1] = { xe.inl(upper(l), { b = true }), 0, "center" } end
  local out = stack(court, { keep = true })
  -- typst caption: above gap (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = GAP, keep = true })

  local rows = {}
  for k, party in ipairs(items(need(m, "caption").parties)) do
    if k > 1 then rows[#rows + 1] = ""; rows[#rows + 1] = { xe.runs("v.") }; rows[#rows + 1] = "" end
    for _, n in ipairs(items(party.names)) do rows[#rows + 1] = { xe.inl(n) } end
    rows[#rows + 1] = { xe.inl(party.designation), DESIG }
  end
  local right = { { xe.runs("Case No. " .. txt(need(m, "case_number"))) }, { xe.runs("Date: " .. txt(need(m, "date"))) },
    "", { xe.inl(need(m, "brief_title"), { b = true }) } }
  if m.jury_demand then
    right[#right + 1] = ""
    right[#right + 1] = { xe.runs("DEMAND FOR JURY TRIAL", { b = true }) }
  end
  local w2 = TEXTW - CAP_LEFT
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. w2 .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="' .. CAP_RULE_PAD .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/></w:tcMar>'
    .. '</w:tcPr>' .. table.concat(stack(rows)) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. w2 .. '" w:type="dxa"/></w:tcPr>'
    .. table.concat(stack(right, { left = CAP_RIGHT_IN })) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (CTD-SIG-001: L. Civ. R. 10; EFPP XI.B): "Dated:" at the margin and "Respectfully submitted," in
-- the signature column on one line (a tab), a blank body line, the /s/ line, the name with the bar number and the
-- address lines; every line kept with the next (typst: one unbreakable block with the last paragraph).
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = need(m, "signature")
  local out = { xe.para({ xe.KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. SIG_LEFT .. '"/></w:tabs>',
    xe.spacing(GAP, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs("Dated: " .. txt(need(m, "date")) .. "\tRespectfully submitted,")) }
  local name = txt(s.signer)
  if s.bar then name = name .. ", Fed. Bar No. " .. txt(s.bar) end
  local lines = { { xe.runs("/s/ " .. txt(s.signer)) }, { xe.runs(name) } }
  for _, l in ipairs(items(s.lines)) do lines[#lines + 1] = { xe.inl(l) } end
  for _, x in ipairs(stack(lines, { above = GAP, left = SIG_LEFT, keep = true })) do out[#out + 1] = x end
  -- the last line keeps with nothing
  out[#out] = out[#out]:gsub(xe.KEEP, "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("2310(d)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or", "are/were"), where LibreOffice keeps the word whole: a zero-width space (U+200B)
-- after it. Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A Str of two or more section signs or pilcrows ("§§", "¶¶"; each two bytes): typst boxes it with its number,
-- lib/pandoc/xengine.lua binds a single sign only.
local function doubled_sign(t)
  local _, s = t:gsub("\u{00A7}", "")
  local _, q = t:gsub("\u{00B6}", "")
  return s + q >= 2 and #t == 2 * (s + q)
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there), nor after a doubled sign ("§§ 2301"): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    if l[i].t == "Space" and l[i - 1].t == "Str" and doubled_sign(l[i - 1].text) then
      l[i] = pandoc.Str("\u{00A0}")
    end
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

-- A body paragraph at the body pitch in a style; keep: with the next paragraph, its lines together.
local function para(style, keep, runs)
  local props = { xe.style(style) }
  if keep then props[#props + 1] = xe.KEEP end
  return xe.para(props, runs)
end

-- Headings (typst heading-block): on the body pitch, kept with the next block; level 1 centred bold capitals, level 2
-- centred bold, level 3 bold italic at the margin.
local function heading(b)
  local level = math.min(b.level, 3)
  local c = b.content
  if level == 1 then c = upper(c) end
  return xe.para({ xe.style("Heading" .. level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(level <= 2 and "center" or "left") }, xe.inl(c, { b = true, i = level == 3 }))
end

-- The body blocks as raw paragraphs; paragraph numbers continue from n. keep: every paragraph kept with the next (the
-- last block stays with the signature block).
local function convert(blocks, n, keep)
  local out = {}
  local unnumbered = false
  for _, b in ipairs(blocks) do
    if b.t == "RawBlock" and b.format == "html" and b.text:match("^%s*" .. UNNUMBERED:gsub("%p", "%%%0") .. "%s*$") then
      unnumbered = true
    elseif b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered then
        out[#out + 1] = para("BodyText", keep, xe.inl(b.content))
      else
        n = n + 1
        out[#out + 1] = para("NumberedParagraph", keep, xe.runs(n .. ".\t") .. xe.inl(b.content))
      end
      unnumbered = false
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and ("(" .. string.char(96 + k) .. ")") or "\u{2022}"
        out[#out + 1] = para("PleadingItem", keep, xe.runs(lab .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)))
      end
    elseif b.t ~= "RawBlock" then
      error("complaint.lua: unsupported block " .. b.t)
    end
  end
  return out, n
end

-- The page number centred in a single line box (typst footer); none on page 1 (titlePg, fb render's empty footer).
local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:left="0" w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>2</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdCtdPage"/>'
  .. '<w:footerReference w:type="first" r:id="rIdFtrNone"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:titlePg/></w:sectPr>'

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function finish(doc)
  local m = doc.meta
  local x = cover(m)
  local first = #x + 1
  if m.lead_in then x[#x + 1] = xe.para({ xe.style("BodyText"), xe.spacing(GAP, 0, BODY) }, xe.inl(m.lead_in)) end

  -- The last block (a paragraph, or a whole list, with an unnumbered mark before it) is kept with the signature block.
  local blocks = doc.blocks
  local cut = #blocks
  if cut > 1 and blocks[cut - 1].t == "RawBlock" then cut = cut - 1 end
  local head, tail = {}, {}
  for i, b in ipairs(blocks) do
    if i < cut then head[#head + 1] = b else tail[#tail + 1] = b end
  end
  local main, n = convert(head, 0, false)
  local last = convert(tail, n, true)
  for _, s in ipairs(main) do x[#x + 1] = s end
  for _, s in ipairs(last) do x[#x + 1] = s end
  -- No lead-in: the first block takes the gap below the caption.
  if not m.lead_in then
    if x[first]:find("<w:spacing", 1, true) then
      x[first] = x[first]:gsub('<w:spacing w:before="%d+"', '<w:spacing w:before="' .. GAP .. '"', 1)
    else
      x[first] = x[first]:gsub('(<w:pStyle w:val="[^"]+"/>)', "%1" .. xe.spacing(GAP, 0, BODY), 1)
    end
  end
  for _, s in ipairs(signature(m)) do x[#x + 1] = s end
  write_file("FORMBOOK_FOOTERS", "rIdCtdPage\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }

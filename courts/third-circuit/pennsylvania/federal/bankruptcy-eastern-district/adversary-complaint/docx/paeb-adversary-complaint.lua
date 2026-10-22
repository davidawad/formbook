-- Adversary complaint, E.D. Pa. Bankr. (paeb), docx engine (docs/DOCX.md). Mirrors typst/paeb-adversary-complaint.typ:
--   * the court title (two centred bold single lines), the caption (a borderless three-column table, one row per
--     single line: the party names with the designations 1.2 in in | a colon beside every line | chapter, case
--     number and adversary number), the title, all from the sample's frontmatter (FRBP 9004(b), 7010);
--   * the lead-in, unnumbered; body paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b), via FRBP 7010): the
--     number at the indent, a tab to the text 1 in in; a "> WHEREFORE" clause unnumbered and kept with the block
--     after it; headings bold on the body pitch, 12 pt above and below, kept with the next block (level 1 centred
--     capitals); a list labelled by the sample's `list_numbering` ("(a)" by default) 0.5 in in, the text hanging
--     at 1 in;
--   * the signature block ("Dated:" at the left, the rest single lines from 3 in), kept on one page with the last
--     paragraph; the optional certificate of service, kept on one page.
-- The footer (the page number, centred) and the last section (letter, 1 in margins) are written for fb render
-- ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the base styles are in docx/reference.xml. Nothing case-specific is written
-- here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 280                 -- typst pitch-body 24 pt, pitch-single 14 pt
local INDENT = 720                            -- typst para-indent, num-box 0.5 in
local LIST_INDENT, LIST_BOX = 720, 720        -- typst list-indent, list-box 0.5 in
local DESIG = 1728                            -- typst designation-indent 1.2 in
local CAP_W = { 4896, 504, 3960 }             -- typst caption-cols 3.4 in, 0.35 in, 2.75 in
local SIG_COL = 4320                          -- typst sig-col 3 in
local COVER_GAP = 280                         -- typst cover-gap 14 pt
local HEADING_SPACE = 240                     -- typst heading-space 12 pt
local SIG_ABOVE = 480                         -- typst sig-above 24 pt
local CERT_ABOVE = 480                        -- typst cert-above 24 pt
local CERT_GAP = 280                          -- typst cert-gap 14 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function check(cond, msg)
  if not cond then error("paeb-adversary-complaint docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, next, tab }; single pitch by default.
-- keep: kept whole and with the next paragraph; next: kept with the next paragraph only.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.next then props[#props + 1] = "<w:keepNext/>" end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local function upper(inlines)
  if type(inlines) == "string" then return pandoc.text.upper(inlines) end
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Footer and section
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_P = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdPaebFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title (typst cover)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- typst caption-rows: { party cell, case cell }, each a string or { desig = value }
local function caption_rows(m)
  local rows = {}
  local function add(l, r) rows[#rows + 1] = { l, r } end
  add("IN RE:", "Chapter " .. txt(m.chapter))
  add(m.debtor.name, "Case No. " .. txt(m.case_number))
  if txt(m.debtor.designation) ~= "" then add({ desig = m.debtor.designation }, "") end
  add("", "")
  for k, party in ipairs(items(m.parties)) do
    if k > 1 then add("", ""); add("v.", ""); add("", "") end
    for j, name in ipairs(items(party.names)) do
      add(name, (k == 1 and j == 1) and ("Adv. Proc. No. " .. txt(m.adversary_number)) or "")
    end
    if txt(party.designation) ~= "" then add({ desig = party.designation }, "") end
  end
  return rows
end

local function caption(m)
  local cols = {}
  for _, w in ipairs(CAP_W) do cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' }
  for _, r in ipairs(caption_rows(m)) do
    local l = r[1]
    local left
    if type(l) == "table" and l.desig then left = p(xe.inl(l.desig), { left = DESIG })
    else left = p(txt(l) ~= "" and xe.inl(l) or "") end
    local cells = { left, p(xe.runs(":")), p(txt(r[2]) ~= "" and xe.inl(r[2]) or "") }
    local tcs = {}
    for i, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_W[i] .. '" w:type="dxa"/></w:tcPr>' .. c .. '</w:tc>'
    end
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return space(COVER_GAP) .. table.concat(out)
end

local function cover(m)
  return p(xe.inl(upper(m.court), { b = true }), { jc = "center" })
    .. p(xe.inl(upper(m.district), { b = true }), { jc = "center" })
    .. caption(m)
    .. p(xe.inl(m.title, { b = true }), { jc = "center", before = COVER_GAP })
    .. space(COVER_GAP)
end

-- ---------------------------------------------------------------------------
-- Signature and certificate (typst column-lines): single lines from SIG_COL, `left` beside the first ones (a tab
-- and a hanging indent); every line but the last kept with the next
-- ---------------------------------------------------------------------------

local function column_lines(rows, left, above)
  local list, gap = {}, above
  for n, r in ipairs(rows) do
    if txt(r) == "" and n > #left then gap = gap + SINGLE else
      list[#list + 1] = { left[n], txt(r) ~= "" and xe.inl(r) or "", gap }
      gap = 0
    end
  end
  local out = {}
  for i, l in ipairs(list) do
    local o = { before = l[3], left = SIG_COL, keep = i < #list }
    local body = l[2]
    if l[1] then
      body = l[1] .. xe.runs("\t") .. body
      o.hanging, o.tab = SIG_COL, SIG_COL
    end
    out[#out + 1] = p(body, o)
  end
  return table.concat(out)
end

local function signature(m)
  local s = m.signature
  local rows = { "Respectfully submitted,", "", s.firm, "", "By: /s/ " .. txt(s.signer) }
  for _, l in ipairs(items(s.lines)) do rows[#rows + 1] = l end
  return column_lines(rows, { xe.runs("Dated: ") .. xe.inl(s.date) }, SIG_ABOVE)
end

local function certificate(m)
  local c = m.certificate
  local out = {
    p(xe.runs("CERTIFICATE OF SERVICE", { b = true }),
      { pitch = BODY, jc = "center", before = math.max(CERT_ABOVE, HEADING_SPACE), after = HEADING_SPACE, keep = true }),
    p(xe.runs("I, ") .. xe.inl(c.signer) .. xe.runs(", hereby certify that I served a true and correct copy of the "
      .. "foregoing document upon the following parties in the manner indicated:"),
      { pitch = BODY, first = INDENT, keep = true }),
    p(xe.inl(txt(c.method) .. ":"), { before = CERT_GAP, keep = true }),
  }
  for _, lines in ipairs(items(c.served)) do
    for i, l in ipairs(items(lines)) do
      out[#out + 1] = p(xe.inl(l), { before = i == 1 and CERT_GAP or 0, keep = true })
    end
  end
  out[#out + 1] = column_lines({ "By: /s/ " .. txt(c.signer) }, { xe.runs("Date: ") .. xe.inl(c.date) }, CERT_GAP)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body (typst render-chunk)
-- ---------------------------------------------------------------------------

local ROMAN = { { 1000, "m" }, { 900, "cm" }, { 500, "d" }, { 400, "cd" }, { 100, "c" }, { 90, "xc" },
  { 50, "l" }, { 40, "xl" }, { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
local function roman(n)
  local s = ""
  for _, r in ipairs(ROMAN) do
    while n >= r[1] do s, n = s .. r[2], n - r[1] end
  end
  return s
end

-- typst numbering(pattern, n) for a pattern with one counting symbol: 1, a, A, i or I.
local function label(pattern, n)
  local s, e = pattern:find("[1aAiI]")
  check(s ~= nil, "list_numbering `" .. pattern .. "` has no counting symbol (1, a, A, i, I)")
  local c = pattern:sub(s, e)
  local v
  if c == "1" then v = tostring(n)
  elseif c == "a" or c == "A" then v = string.char(string.byte(c) + n - 1)
  elseif c == "i" then v = roman(n)
  else v = roman(n):upper() end
  return pattern:sub(1, s - 1) .. v .. pattern:sub(e + 1)
end

local function body(blocks, m, sig)
  local out = {}
  local n = 0
  local pattern = m.list_numbering and txt(m.list_numbering) or "(a)"
  for k, b in ipairs(blocks) do
    local last = k == #blocks
    if b.t == "Header" then
      local o = { pitch = BODY, keep = true, before = HEADING_SPACE, after = HEADING_SPACE,
        jc = b.level == 1 and "center" or "left" }
      out[#out + 1] = p(xe.inl(b.level == 1 and upper(b.content) or b.content, { b = true }), o)
    elseif b.t == "BlockQuote" then
      out[#out + 1] = p(xe.inl(pandoc.utils.blocks_to_inlines(b.content)), { pitch = BODY, first = INDENT,
        next = not last, keep = last })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs(label(pattern, i) .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { pitch = BODY, left = LIST_INDENT + LIST_BOX, hanging = LIST_BOX, tab = LIST_INDENT + LIST_BOX,
            keep = last and i == #b.content })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
        { pitch = BODY, first = INDENT, tab = 2 * INDENT, keep = last })
    else
      error("paeb-adversary-complaint.lua: unexpected block " .. b.t)
    end
  end
  out[#out + 1] = sig
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("523(a)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 151"; the typst template boxes them): no-break spaces.
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
  for _, k in ipairs({ "court", "district", "debtor", "chapter", "case_number", "adversary_number", "parties",
    "title", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  write_file("FORMBOOK_FOOTERS", "rIdPaebFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = { cover(m) }
  if m.lead_in then out[#out + 1] = p(xe.inl(m.lead_in), { pitch = BODY, first = INDENT }) end
  out[#out + 1] = body(doc.blocks, m, signature(m))
  if m.certificate then out[#out + 1] = certificate(m) end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

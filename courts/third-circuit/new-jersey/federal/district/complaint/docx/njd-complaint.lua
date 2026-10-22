-- U.S. District Court, District of New Jersey, complaint (njd): docx engine (docs/DOCX.md). Mirrors
-- typst/njd-complaint.typ:
--   * the counsel block (first page, upper left), the court title (centred bold capitals), the caption (L.Civ.R.
--     10.1(b); a one-row table: the parties, each designation 1.8 in in and "v." between them, the cell ruled at
--     its right and foot; the Civil Action No. (a blank for the Clerk), the judge and the title 0.35 in right of the
--     rule), all from the sample's frontmatter;
--   * body paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b)): the number at the indent, a tab to the text 1 in
--     in; a paragraph that starts with one of `unnumbered_prefixes` unnumbered; headings bold and centred on the body
--     pitch, kept with the next block (level 1 in capitals); list items lettered a., b., ... half an inch in, the text
--     hanging at 0.9 in;
--   * the signature block after the last paragraph and kept on one page with it ("Dated:" left of the first line,
--     the firm, "By: /s/" and the signer's lines from 3.2 in; D.N.J. ECF Policies ¶ 12(a)); the L.Civ.R. 11.2
--     certification on a page of its own with its signature block.
-- The footer (the page number, centred) and the last section (letter, 1 in margins) are written for fb render
-- ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the base styles are in docx/reference.xml. Nothing case-specific is written
-- here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276                 -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local TW = 9360                               -- the text width: 6.5 in
local INDENT = 720                            -- typst para-indent, num-box, list-indent 0.5 in
local LIST_BOX = 576                          -- typst list-box 0.4 in
local CAP_LEFT = 4608                         -- typst cap-left 3.2 in
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local CAP_PAD_RIGHT = 200                     -- typst cap-pad-right 10 pt
local CAP_PAD_BELOW = 200 - 15                -- typst cap-pad-below 10 pt, less the rule LibreOffice sets below it
local CAP_DESIG = 2592                        -- typst cap-desig 1.8 in
local CAP_RIGHT = 504                         -- typst cap-right 0.35 in
local BLANK_NUMBER = string.rep("_", 14)      -- typst blank-number
local SIG_COL = 4608                          -- typst sig-col 3.2 in
local GAP = 552                               -- typst gap 27.6 pt
local SIG_ABOVE = 552                         -- typst sig-above 27.6 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function need(m, key)
  if m[key] == nil then error("njd: missing required metadata field `" .. key .. "`", 0) end
  return m[key]
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

-- A metadata value as inlines (a block value, such as a `|` text, flattened).
local function inlines(v)
  if pandoc.utils.type(v) == "Blocks" or (v.t == "MetaBlocks") then return pandoc.utils.blocks_to_inlines(v) end
  return v
end

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tab, brk }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
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

-- Single lines, one paragraph each (metadata values, strings, or { runs = <xml> }); an empty item is a blank
-- single line.
local function lines(list, o)
  local out, gap = {}, 0
  for _, l in ipairs(list) do
    local ready = type(l) == "table" and l.runs ~= nil
    if not ready and txt(l) == "" then
      gap = gap + SINGLE
    else
      local q = { before = gap }
      for k, v in pairs(o or {}) do q[k] = v end
      out[#out + 1] = p(ready and l.runs or xe.inl(l), q)
      gap = 0
    end
  end
  return table.concat(out)
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

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdNjdFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover (typst cover, caption)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function mar(top, left, bottom, right)
  return '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

local function upper(l)
  return pandoc.Inlines(l):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function caption(m)
  local left = {}
  for k, party in ipairs(items(need(m, "caption").parties)) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    left[#left + 1] = lines(items(party.names))
    left[#left + 1] = p(xe.inl(party.designation), { left = CAP_DESIG })
  end
  local cn = txt(need(m, "case_number"))
  local judge = txt(need(m, "judge"))
  local right = { { runs = xe.runs("Civil Action No. " .. (cn == "" and BLANK_NUMBER or cn)) } }
  if judge ~= "" then right[#right + 1] = { runs = xe.runs("Hon. " .. judge .. ", U.S.D.J.") } end
  right[#right + 1] = ""
  right[#right + 1] = { runs = xe.inl(upper(need(m, "title")), { b = true }) }
  local rule = ' w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local borders = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom' .. rule .. '<w:right' .. rule
    .. '</w:tcBorders>'
  return space(GAP) .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/>'
    .. '<w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. NOLOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TW - CAP_LEFT)
    .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. borders
    .. mar(0, 0, CAP_PAD_BELOW, CAP_PAD_RIGHT) .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TW - CAP_LEFT) .. '" w:type="dxa"/>' .. mar(0, CAP_RIGHT, CAP_PAD_BELOW, 0)
    .. '</w:tcPr>' .. lines(right) .. '</w:tc></w:tr></w:tbl>'
end

local function cover(m)
  local out = { lines(items(need(m, "counsel"))) }
  for k, l in ipairs(items(need(m, "court"))) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", before = k == 1 and GAP or 0 })
  end
  out[#out + 1] = caption(m)
  out[#out + 1] = space(GAP)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature blocks (typst signature-block): "Dated:" left of the first line (a tab and a hanging indent), the rest
-- from SIG_COL; kept on one page
-- ---------------------------------------------------------------------------

local function signature(date, sig)
  local rows = {}
  for _, l in ipairs(items(sig.firm)) do rows[#rows + 1] = l end
  rows[#rows + 1] = ""
  rows[#rows + 1] = "By: /s/ " .. txt(sig.signer)
  for _, l in ipairs(items(sig.lines)) do rows[#rows + 1] = l end
  local list, gap = {}, SIG_ABOVE
  for _, r in ipairs(rows) do
    if txt(r) == "" then gap = gap + SINGLE else
      list[#list + 1] = { xe.inl(r), gap }
      gap = 0
    end
  end
  local out = {}
  for i, l in ipairs(list) do
    local o = { before = l[2], left = SIG_COL, keep = i < #list }
    local body = l[1]
    if i == 1 then
      body = xe.runs("Dated: ") .. xe.inl(date) .. xe.runs("\t") .. body
      o.hanging, o.tab = SIG_COL, SIG_COL
    end
    out[#out + 1] = p(body, o)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body (typst render-chunk)
-- ---------------------------------------------------------------------------

local function heading(level, content, brk)
  return p(xe.inl(level == 1 and upper(content) or content, { b = true }),
    { pitch = BODY, keep = true, jc = "center", brk = brk })
end

local function body(blocks, prefixes)
  local out = {}
  local n = 0
  for k, b in ipairs(blocks) do
    local keep = k == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b.level, b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      local s = stringify(b)
      local unnumbered = false
      for _, pre in ipairs(prefixes) do
        if s:sub(1, #pre) == pre then unnumbered = true end
      end
      if unnumbered then
        out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, first = INDENT, keep = keep })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          { pitch = BODY, first = INDENT, tab = 2 * INDENT, keep = keep })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs(string.char(96 + i) .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { pitch = BODY, left = INDENT + LIST_BOX, hanging = LIST_BOX, tab = INDENT + LIST_BOX,
            keep = keep and i == #b.content })
      end
    else
      error("njd-complaint.lua: unexpected block " .. b.t)
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1332(a)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 2, 6"; the typst template boxes them): no-break spaces.
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
  for _, k in ipairs({ "counsel", "court", "caption", "case_number", "judge", "title", "jury_demand", "date",
    "signature" }) do
    need(m, k)
  end
  -- L.Civ.R. 38.1: a jury demand endorsed on a pleading puts "and Demand for Jury Trial" in its title.
  if m.jury_demand and not txt(m.title):lower():find("demand for jury trial", 1, true) then
    error("njd: a jury demand needs `and Demand for Jury Trial` in the title (L.Civ.R. 38.1)", 0)
  end
  local prefixes = {}
  for _, pre in ipairs(items(m.unnumbered_prefixes)) do prefixes[#prefixes + 1] = txt(pre) end
  write_file("FORMBOOK_FOOTERS", "rIdNjdFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = { cover(m), body(doc.blocks, prefixes), signature(m.date, m.signature) }
  -- Certification (L.Civ.R. 11.2): a page of its own, its own signature.
  if m.certification then
    local cert = m.certification
    out[#out + 1] = heading(1, cert.title, true)
    out[#out + 1] = p(xe.inl(inlines(cert.text)), { pitch = BODY, first = INDENT })
    out[#out + 1] = signature(cert.date, cert.signature)
  end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

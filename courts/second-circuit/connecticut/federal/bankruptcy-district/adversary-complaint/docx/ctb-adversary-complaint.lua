-- Adversary complaint, docx engine (docs/DOCX.md): the markdown contract -> the layout of
-- typst/ctb-adversary-complaint.typ on the styles of docx/reference.xml (fb render builds the reference document from
-- it). The court's name, the caption (two boxes: the party column closed by a right and a bottom rule, the case
-- column beside it), the title and the signature block are written here as OpenXML; numbered paragraphs (FRCP 10(b)
-- via FRBP 7010) get their number typed, as the typst template types it: continuous from the first heading, not under
-- the prayer for relief. Every case word comes from the frontmatter; no case text is written into this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
--
-- Page furniture (was docx/build-reference.sh and docx/render.sh): one section ($FORMBOOK_FINAL), letter, 1 in margins
-- (L. Civ. R. 10), its first page without a footer (fb render's rIdFtrNone, titlePg), the others with this filter's
-- footer ($FORMBOOK_FOOTERS): the page number centred and the docket line (Adv. Pro. No. and the judge's initials, from
-- the frontmatter; L. Civ. R. 10) at the right, in a single-pitch line whose box ends 0.5 in above the page edge.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                -- typst pitch-body 24 pt, pitch-single 13.8 pt
local TW = 9360                              -- typst text-width 6.5 in
local INDENT = 720                           -- typst para-indent 0.5 in
local NUMBER_BOX, LIST_BOX = 720, 720        -- typst number-box, list-box 0.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288       -- typst caption-left 3.4 in, caption-gutter 0.2 in
local CAP_RIGHT = TW - CAP_LEFT - CAP_GUTTER -- 2.9 in
local CAP_RULE = 6                           -- typst caption-rule 0.75 pt (eighths of a point)
local CAP_PAD_RIGHT = 200                    -- typst caption-pad-right 10 pt
local CAP_PAD_BELOW = 160 - 15               -- typst caption-pad-below 8 pt, less the 0.75 pt rule LibreOffice adds to the row
local CASE_PAD = 144                         -- typst case-pad 0.1 in
local DEBTOR, VERSUS, DESIG = 720, 2880, 3600 -- typst debtor-indent 0.5 in, versus-indent 2.0 in, designation-indent 2.5 in
local SIG_LEFT, SIG_GUTTER = 4320, 288       -- typst sig-left 3.0 in, sig-gutter 0.2 in
local CAPTION_ABOVE = 480                    -- typst caption-above 24 pt
local CAPTION_GAP = 240                      -- typst caption-gap 12 pt
local TITLE_ABOVE, TITLE_BELOW = 480, 240    -- typst title-above 24 pt, title-below 12 pt
local SIG_ABOVE = 480                        -- typst sig-above 24 pt
local DOCKET_SIZE = 20                       -- typst docket-size 10 pt (half points)
local FOOTER = 720                           -- typst footer-distance 0.5 in

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst block above): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A one-row table with fixed column widths; cells = { { xml, tcpr } }; the row is not split across pages.
local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    local body = cells[i][1]
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i][2] or "") .. '</w:tcPr>'
      .. (body ~= "" and body or p("")) .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Caption (FRBP 9004(b), Official Form 416A: court, title, case number, document character)
-- ---------------------------------------------------------------------------

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/></w:tcBorders>'

-- One caption box (typst caption-box): the party column with its rules, the gutter, the case column.
local function caption_box(left, right)
  return table_xml({ CAP_LEFT, CAP_GUTTER, CAP_RIGHT }, {
    { table.concat(left), RULES .. '<w:tcMar><w:bottom w:w="' .. CAP_PAD_BELOW .. '" w:type="dxa"/><w:right w:w="'
      .. CAP_PAD_RIGHT .. '" w:type="dxa"/></w:tcMar>' },
    { "" },
    { table.concat(right), '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>' },
  })
end

local function caption(m)
  local out = {}
  for _, k in ipairs({ "court", "district", "division" }) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(txt(m[k])), { b = true }), { jc = "center" })
  end
  out[#out + 1] = space(CAPTION_ABOVE)
  local right1 = { p(xe.runs("Chapter " .. txt(m.chapter))), p(xe.inl(m.main_case)) }
  if m.jointly_administered == true then right1[#right1 + 1] = p(xe.runs("(Jointly Administered)")) end
  out[#out + 1] = caption_box({ p(xe.runs("In re:")), p(xe.inl(m.debtors), { left = DEBTOR }),
    p(xe.runs("Debtors."), { left = DESIG }) }, right1)
  out[#out + 1] = space(CAPTION_GAP)
  local left2 = {}
  for k, party in ipairs(items(m.caption.parties)) do
    if k > 1 then left2[#left2 + 1] = p(xe.runs("v."), { left = VERSUS }) end
    for _, n in ipairs(items(party.names)) do left2[#left2 + 1] = p(line(n)) end
    left2[#left2 + 1] = p(line(party.designation), { left = DESIG })
  end
  out[#out + 1] = caption_box(left2, {
    p(xe.runs("Adv. Pro. No. " .. txt(m.adv_number) .. " (" .. txt(m.judge) .. ")")),
    p(xe.runs("Dated: " .. txt(m.date))),
  })
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { jc = "center", before = TITLE_ABOVE, after = TITLE_BELOW })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (D. Conn. L. Civ. R. 10)
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local right = { p(xe.runs(pandoc.text.upper(txt(s.party)))), p(xe.runs("By: /s/ " .. txt(s.esigner))) }
  for _, signer in ipairs(items(s.signers)) do
    local pair = items(signer)
    right[#right + 1] = p(line(pair[1]))
    right[#right + 1] = p(line(pair[2]))
  end
  for _, l in ipairs(items(s.firm)) do right[#right + 1] = p(line(l)) end
  right[#right + 1] = p(line(s.role))
  local left = { p(xe.runs("Dated: " .. txt(m.date))), p(line(s.dated_place)) }
  -- the space above is the block's own (typst: above sig-above), kept with the table
  return xe.para({ xe.KEEP, xe.spacing(0, 0, SIG_ABOVE) }, "")
    .. table_xml({ SIG_LEFT, SIG_GUTTER, TW - SIG_LEFT - SIG_GUTTER },
      { { table.concat(left) }, { "" }, { table.concat(right) } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings on the body pitch with no space of their own, kept with the next block (typst section-heading): level 1
-- centred bold capitals, 2 bold left, 3 centred bold.
local function heading(level, content)
  local inl = level == 1 and pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    or content
  return p(xe.inl(inl, { b = true }), { style = "Heading" .. level, keep = true, pitch = BODY,
    jc = level == 2 and "left" or "center" })
end

local function body(blocks)
  local out = {}
  local numbered, n = false, 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      -- a section heading starts a numbered run, except the prayer for relief, which is not numbered
      numbered = not stringify(b.content):find("PRAYER", 1, true)
      out[#out + 1] = heading(math.min(b.level, 3), b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      if numbered then
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          { pitch = BODY, first = INDENT, tab = INDENT + NUMBER_BOX })
      else
        out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, first = INDENT })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- typst list-item: the label in a box after the indent, the text hanging after it
      local k = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and (k .. ".") or "\u{2022}"
        out[#out + 1] = p(xe.runs(label .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { pitch = BODY, left = INDENT + LIST_BOX, hanging = LIST_BOX, tab = INDENT + LIST_BOX })
        k = k + 1
      end
    else
      error("ctb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("550(a)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_ID = "rIdCtbPage"

-- The footer of pages 2 on (typst: the number centred, the docket line at the right, 10 pt).
local function footer(m)
  return '<w:p><w:pPr><w:tabs><w:tab w:val="center" w:pos="' .. (TW / 2) .. '"/><w:tab w:val="right" w:pos="' .. TW
    .. '"/></w:tabs>' .. xe.spacing(0, 0, SINGLE) .. xe.ind(0, nil, 0) .. xe.jc("left") .. '</w:pPr>'
    .. '<w:r><w:tab/></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>2</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
    .. '<w:r><w:tab/></w:r>'
    .. xe.runs("Adv. Pro. No. " .. txt(m.adv_number) .. " (" .. txt(m.judge) .. ")", { sz = DOCKET_SIZE }) .. '</w:p>'
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="' .. FOOTER_ID .. '"/>'
  .. '<w:footerReference w:type="first" r:id="rIdFtrNone"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:titlePg/></w:sectPr>'

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "court", "district", "division", "chapter", "main_case", "debtors", "judge", "adv_number",
    "caption", "date", "title", "signature" }) do
    if m[k] == nil then error("ctb-adversary-complaint.lua: missing required metadata field `" .. k .. "`") end
  end
  write_file("FORMBOOK_FOOTERS", FOOTER_ID .. "\t" .. footer(m) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)
  local out = { xe.raw(caption(m) .. body(doc.blocks) .. signature(m)) }
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }

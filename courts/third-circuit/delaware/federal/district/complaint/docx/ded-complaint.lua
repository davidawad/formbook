-- D. Del. complaint (ded), docx engine (docs/DOCX.md). Mirrors typst/ded-complaint.typ:
--   * the court title (two centred bold single lines), the caption (a one-row table: the parties at the left, each
--     designation 2 in in, "v." between, the cell ruled at its right; the file number and the jury demand 0.3 in
--     right of the rule), the title of the pleading, all from the sample's frontmatter (Fed. R. Civ. P. 10(a));
--   * the lead-in, unnumbered; body paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b)): the number at the
--     indent, a tab to the text 1 in in; a paragraph that opens with "<!-- unnumbered -->" (the WHEREFORE clause, the
--     jury demand) unnumbered; headings bold on the body pitch, kept with the next block (level 1 centred capitals,
--     level 2 centred, level 3 bold italic); a markdown list lettered A., B., ... (the prayer), the text hanging 1 in;
--   * the signature block after the body: "Dated:" (LR 5.1.1(a)) left of the firm's line, the signing counsel and
--     "Attorneys for ..." in the signature column, single lines; it may run over a page.
-- The footer (the page number, centred) and the last section (letter, 1 in margins, LR 5.1.1(a)) are written for fb
-- render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the body styles are in docx/reference.xml. Nothing case-specific is
-- written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276                 -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local TW = 9360                               -- the text width: 6.5 in
local INDENT = 720                            -- typst para-indent 0.5 in
local CAP_LEFT = 4752                         -- typst cap-left 3.3 in
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local CAP_PAD = 200                           -- typst cap-pad 10 pt
local CAP_RIGHT = 432                         -- typst cap-right 0.3 in
local DESIG = 2880                            -- typst desig-indent 2 in
local SIG_COL = 4464                          -- typst sig-col 3.1 in
local COVER_GAP = 552                         -- typst cover-gap 27.6 pt
local TEXT_ABOVE = 276                        -- typst text-above 13.8 pt
local SIG_ABOVE = 552                         -- typst sig-above 27.6 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge
local UNNUMBERED = "<!-- unnumbered -->"
local READER = "commonmark+smart+footnotes"   -- docx/reference.xml pandoc-from, less the frontmatter

local function check(cond, msg)
  if not cond then error("ded-complaint docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
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

-- Single lines, one paragraph each (runs given as XML); an empty item is a blank single line.
local function lines(list)
  local out, gap = {}, 0
  for _, l in ipairs(list) do
    if l == "" then gap = gap + SINGLE else
      out[#out + 1] = p(l, { before = gap })
      gap = 0
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Footer and section (LR 5.1.1(a))
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

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdDedFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title (typst cover)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function mar(left, right)
  return '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

local function caption(m)
  local left = {}
  for k, party in ipairs(items(m.caption.parties)) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG })
  end
  local right = { "", xe.runs("C.A. No. ") .. xe.inl(m.case_number) }
  if m.jury_demand then
    right[#right + 1] = ""
    right[#right + 1] = ""
    right[#right + 1] = xe.runs("JURY TRIAL DEMANDED", { b = true })
  end
  local rule = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
    .. '<w:right w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/></w:tcBorders>'
  return space(COVER_GAP) .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/>'
    .. '<w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. NOLOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TW - CAP_LEFT)
    .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. rule .. mar(0, CAP_PAD) .. '</w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TW - CAP_LEFT) .. '" w:type="dxa"/>' .. mar(CAP_RIGHT, 0) .. '</w:tcPr>'
    .. lines(right) .. '</w:tc></w:tr></w:tbl>'
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function cover(m)
  return p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
    .. p(xe.runs("FOR THE DISTRICT OF DELAWARE", { b = true }), { jc = "center" })
    .. caption(m)
    .. p(xe.inl(upper(m.title), { b = true }), { jc = "center", before = COVER_GAP })
    .. space(TEXT_ABOVE)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block): single lines from SIG_COL, "Dated:" left of the first (a tab and a
-- hanging indent); no keeps, so it runs over a page where typst's does
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local rows = {}
  for _, l in ipairs(items(sig.firm)) do rows[#rows + 1] = l end
  rows[#rows + 1] = ""
  for _, l in ipairs(items(sig.lines)) do rows[#rows + 1] = l end
  if m.attorneys_for then
    rows[#rows + 1] = ""
    for _, l in ipairs(items(m.attorneys_for)) do rows[#rows + 1] = l end
  end
  local out, gap, first = {}, SIG_ABOVE, true
  for _, r in ipairs(rows) do
    if txt(r) == "" then gap = gap + SINGLE else
      if first then
        out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(m.date) .. xe.runs("\t") .. xe.inl(r),
          { before = gap, left = SIG_COL, hanging = SIG_COL, tab = SIG_COL })
        first = false
      else
        out[#out + 1] = p(xe.inl(r), { before = gap, left = SIG_COL })
      end
      gap = 0
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("38(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number (the typst template boxes them): no-break spaces.
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

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A paragraph pandoc writes (so its footnotes are Word footnotes): `label` and a tab, then the text.
local function styled(style, label, content)
  local inl = pandoc.Inlines({})
  if label then inl:insert(pandoc.RawInline("openxml", xe.runs(label .. "\t"))) end
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
end

-- The footnote definitions of the sample ("[^n]: text" lines), for a paragraph read again on its own.
local function definitions()
  local file = PANDOC_STATE.input_files[1]
  local f = file and io.open(file, "r")
  if not f then return "" end
  local src = f:read("a")
  f:close()
  local defs = {}
  for l in src:gmatch("[^\n]+") do
    if l:match("^%[%^[^%]]+%]:") then defs[#defs + 1] = l end
  end
  return table.concat(defs, "\n\n")
end

-- A paragraph marked "<!-- unnumbered -->": CommonMark reads the line as an HTML block, so its text is read again
-- as markdown (with the sample's footnote definitions, for a reference in it).
local function unnumbered(b)
  if b.t ~= "RawBlock" or b.text:sub(1, #UNNUMBERED) ~= UNNUMBERED then return nil end
  local rest = b.text:sub(#UNNUMBERED + 1)
  if rest:find("[^", 1, true) then rest = rest .. "\n\n" .. definitions() end
  local blocks = pandoc.read(rest, READER).blocks:walk({ Str = break_rules }):walk({ Inlines = bind })
  check(#blocks == 1 and blocks[1].t == "Para", "an unnumbered paragraph must be one paragraph")
  return blocks[1].content
end

local function body(blocks)
  local out = pandoc.Blocks({})
  local n = 0
  for _, b in ipairs(blocks) do
    local un = unnumbered(b)
    if un then
      out:insert(styled("Body Text", nil, un))
    elseif b.t == "Header" then
      local content = b.level == 1 and upper(b.content) or b.content
      out:insert(xe.raw(p(xe.inl(content, { b = true, i = b.level >= 3 }),
        { pitch = BODY, jc = b.level <= 2 and "center" or "left", keep = true })))
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out:insert(styled("Numbered Paragraph", n .. ".", b.content))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        out:insert(styled("List Letter", string.char(64 + i) .. ".", pandoc.utils.blocks_to_inlines(item)))
      end
    else
      error("ded-complaint.lua: unexpected block " .. b.t)
    end
  end
  return out
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "case_number", "caption", "title", "date", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  check(m.caption.parties ~= nil, "caption.parties is required")
  write_file("FORMBOOK_FOOTERS", "rIdDedFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  if m.lead_in then out:insert(styled("Body Text", nil, m.lead_in)) end
  out:extend(body(doc.blocks))
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out:walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

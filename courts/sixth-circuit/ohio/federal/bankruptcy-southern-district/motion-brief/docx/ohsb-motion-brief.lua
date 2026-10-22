-- S.D. Ohio motion with memorandum in support (ohsb), docx engine (docs/DOCX.md). Mirrors typst/ohsb-motion-brief.typ:
--   * the court title (three centred bold single lines), the caption (a borderless table, one row per single line:
--     the debtor | a ")" beside every party line | the case information 0.15 in in), the title of the paper, all from
--     the sample's frontmatter (LBR 9004-2);
--   * body paragraphs unnumbered with a 0.5 in first-line indent; headings centred bold (level 1 in capitals) on the
--     body pitch, kept with the next block; a markdown list numbered half an inch in, the text hanging; the lettered
--     quotations "(A) ..." 0.75 in in; the centred "***"; a paragraph of hard-broken lines (an address) single spaced,
--     not indented, a blank single line around it;
--   * the signature block at each {{SIGNATURE}} (single lines in the signature column, "Dated:" left of the first),
--     kept on one page; the 21-day notice (LBR 9013-1(a)(2)) at {{NOTICE_21_DAY}}.
-- The footer (the page number, centred) and the last section (letter, 1 in margins, LBR 9004-1(b)) are written for fb
-- render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the body styles are in docx/reference.xml. Nothing case-specific is
-- written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify
local break_rules, bind -- the break rules (below); the notice text read here gets them too

local BODY, SINGLE = 480, 280                 -- typst pitch-body 24 pt, pitch-single 14 pt
local TW = 9360                               -- typst text-width: 6.5 in
local CAP_LEFT, CAP_MID = 4896, 432           -- typst cap-left 3.4 in, cap-mid 0.3 in
local CAP_PAD = 216                           -- typst cap-pad 0.15 in
local SIG_COL = 4032                          -- typst sig-col 2.8 in
local COVER_GAP = 280                         -- typst cover-gap 14 pt
local TEXT_ABOVE = 480                        -- typst text-above 24 pt
local SIG_ABOVE = 240                         -- typst sig-above 12 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function check(cond, msg)
  if not cond then error("ohsb-motion-brief docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, brk, tab }; single pitch by default.
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

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- A borderless table: widths (twips), rows of cells (each cell: paragraphs as a string).
local function grid(widths, rows)
  local total, cols = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblInd w:w="0" w:type="dxa"/>' .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar>'
    .. '<w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' }
  for _, row in ipairs(rows) do
    local cells = {}
    for i, cell in ipairs(row) do
      cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>'
        .. (cell ~= "" and cell or p("")) .. "</w:tc>"
    end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Footer and section (LBR 9004-1(b))
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

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdOhsbFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper (typst cover)
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for _, l in ipairs({ "UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF OHIO", txt(m.division) }) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" })
  end
  local left, right = items(m.caption.left), items(m.caption.right)
  local rows = {}
  for i = 1, math.max(#left, #right) do
    local l, r = left[i], right[i]
    rows[#rows + 1] = {
      p(l and txt(l) ~= "" and xe.inl(l) or ""),
      p(i <= #left and xe.runs(")") or "", { jc = "center" }),
      p(r and txt(r) ~= "" and xe.inl(r) or "", { left = CAP_PAD }),
    }
  end
  out[#out + 1] = space(COVER_GAP)
  out[#out + 1] = grid({ CAP_LEFT, CAP_MID, TW - CAP_LEFT - CAP_MID }, rows)
  out[#out + 1] = p(xe.runs(txt(m.brief_title), { b = true }), { jc = "center", before = COVER_GAP })
  out[#out + 1] = space(TEXT_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-lines): single lines from SIG_COL, "Dated:" left of the first (a tab and a hanging
-- indent), kept on one page
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local list = {}
  if sig.closing and txt(sig.closing) ~= "" then list[#list + 1] = sig.closing; list[#list + 1] = "" end
  if sig.firm then
    for _, l in ipairs(items(sig.firm)) do list[#list + 1] = l end
    list[#list + 1] = ""
  end
  for _, l in ipairs(items(sig.lines)) do list[#list + 1] = l end
  local date = m.date and txt(m.date) ~= "" and xe.runs("Dated: ") .. xe.inl(m.date) or ""
  local lines, gap = {}, SIG_ABOVE
  for _, l in ipairs(list) do
    if l == "" then gap = gap + SINGLE else
      lines[#lines + 1] = { xe.inl(l), gap }
      gap = 0
    end
  end
  local out = {}
  for i, l in ipairs(lines) do
    local first = i == 1 and (date .. xe.runs("\t")) or ""
    out[#out + 1] = p(first .. l[1], { before = l[2], left = SIG_COL, hanging = i == 1 and SIG_COL or nil,
      tab = i == 1 and SIG_COL or nil, keep = i < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph pandoc writes (so its footnotes are Word footnotes and its hard line breaks Word breaks): `label` and a
-- tab, then the text.
local function styled(style, label, content)
  local inl = pandoc.Inlines({})
  if label then inl:insert(pandoc.RawInline("openxml", xe.runs(label .. "\t"))) end
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
end

local function heading(level, content)
  return xe.raw(p(xe.inl(level == 1 and upper(content) or content, { b = true }),
    { pitch = BODY, jc = "center", keep = true }))
end

local function is_directive(b, d)
  return (b.t == "Para" or b.t == "Plain") and stringify(b) == d
end

-- A paragraph that starts "(A) " (a lettered quotation, typst is-quote).
local function is_quote(c)
  return c[1] ~= nil and c[1].t == "Str" and c[1].text:match("^%(%a%)$") ~= nil and c[2] ~= nil and c[2].t == "Space"
end

local function has_break(c)
  for _, x in ipairs(c) do
    if x.t == "LineBreak" then return true end
  end
  return false
end

-- The 21-day notice (LBR 9013-1(a)(2); typst notice-21-day): the rule's sample text, the movant's name and the relief
-- from the frontmatter.
local function notice(m)
  local n = m.notice
  check(n ~= nil, "{{NOTICE_21_DAY}} needs the `notice` frontmatter")
  local movant, relief = txt(n.movant), txt(n.relief)
  local paras = {
    movant .. " has filed papers with the court to obtain " .. relief .. ".",
    "Your rights may be affected. You should read these papers carefully and discuss them with your attorney, if you have one in this bankruptcy case. If you do not have an attorney, you may wish to consult one.",
    "If you do not want the court to grant the relief sought in the motion/objection, then on or before twenty-one (21) days from the date set forth in the certificate of service for the motion/objection, you must file with the court a response explaining your position by mailing your response by first class mail to " .. txt(n.clerk_address) .. " OR your attorney must file a response using the court’s ECF System.",
    "The court must receive your response on or before the above date.",
    "You must also send a copy of your response either by 1) the court’s ECF System or by 2) first class mail to " .. txt(n.movant_address) .. " and " .. txt(n.others) .. ".",
    "If you or your attorney do not take these steps, the court may decide that you do not oppose the relief sought in the motion/objection and may enter an order granting that relief without further hearing or notice.",
  }
  local out = { heading(1, pandoc.Inlines({ pandoc.Str("NOTICE OF MOTION/OBJECTION") })) }
  for _, s in ipairs(paras) do
    local inl = pandoc.read(s, "commonmark+smart").blocks[1].content:walk({ Str = break_rules }):walk({ Inlines = bind })
    out[#out + 1] = styled("Body Text", nil, inl)
  end
  return out
end

-- The body as blocks (typst render-chunk).
local function body(blocks, m)
  local out = pandoc.Blocks({})
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out:insert(heading(b.level, b.content))
    elseif is_directive(b, "{{SIGNATURE}}") then
      out:insert(xe.raw(signature(m)))
    elseif is_directive(b, "{{NOTICE_21_DAY}}") then
      out:extend(notice(m))
    elseif b.t == "HorizontalRule" then
      out:insert(xe.raw(p(xe.runs("***"), { pitch = BODY, jc = "center" })))
    elseif b.t == "Para" or b.t == "Plain" then
      if is_quote(b.content) then
        out:insert(styled("Quotation Lettered", nil, b.content))
      elseif has_break(b.content) then
        out:insert(styled("Lines", nil, b.content))
      else
        out:insert(styled("Body Text", nil, b.content))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        out:insert(styled("List Number", (start + i - 1) .. ".", pandoc.utils.blocks_to_inlines(item)))
      end
    else
      error("ohsb-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1112(b)(4)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 502"; the typst template boxes them): no-break spaces.
function bind(l)
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
  for _, k in ipairs({ "division", "caption", "brief_title", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  check(m.caption.left ~= nil and m.caption.right ~= nil, "LBR 9004-2: the caption needs `left` and `right` lines")
  write_file("FORMBOOK_FOOTERS", "rIdOhsbFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  out:extend(body(doc.blocks, m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out:walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

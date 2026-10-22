-- Shared helpers for the orb (D. Or. Bankruptcy) docx filters: the cover (counsel, court title, the ruled LBR
-- 9004-2(c) caption), body paragraphs and headings, the signature block, the footer and the section, as OpenXML.
-- Loaded with dofile() by the doc-type filter (docx/orb-*.lua); the same file is in both orb doc-type folders.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch, the spaces between blocks those of the typst template (typst/orb-*.typ), the
-- break rules of typst on every run. Twips = 20 x pt: 480 a double line (LBR 9004-1(a)(4)(A)), 276 a single line.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify
local M = {}

M.xe = xe
M.BODY, M.SINGLE, M.BLANK = 480, 276, 480 -- typst pitch-body 24 pt, pitch-single 13.8 pt, blank 24 pt
M.TEXTW = 10080                          -- 7 in between the 0.75 in side margins
M.INDENT = 720                           -- typst para-indent 0.5 in
M.NUM_BOX = 720                          -- typst num-box 0.5 in: the number or letter, then the text 1 in in
local CAP_LEFT = 4896                    -- typst caption-left 3.4 in
local CAP_PAD = 120                      -- typst caption-pad 6 pt
local CAP_RULED = 105                    -- caption-pad less the 0.75 pt rule LibreOffice adds to the row under it
local SIG_INDENT = 4320                  -- typst sig-indent 3 in
local FOOTER_GAP = 40                    -- typst footer-gap 2 pt

function M.need(meta, key)
  local v = meta[key]
  if v == nil then error("orb docx: missing required metadata field `" .. key .. "`") end
  return v
end

function M.items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("60(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

function M.break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word), nor after a doubled sign ("§§ 544"; typst boxes the
-- token): the space becomes a no-break space, as wide.
function M.bind_spaces(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    local s = l[i]
    if s.t == "Str" and l[i + 1].t == "Space" and (s.text:find("§§$") or s.text:find("¶¶$")) then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs }.
function M.p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or M.SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end
local p = M.p

-- Single-spaced lines (typst lines()): each item runs (xml) or "" (a blank single line). o: { above, left, keep }.
function M.lines(list, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for k, l in ipairs(list) do
    if l == "" then
      gap = gap + M.SINGLE
    else
      out[#out + 1] = p(l, { before = gap, left = o.left, keep = o.keep and k < #list })
      gap = 0
    end
  end
  if #out == 0 then out[1] = p("") end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, the LBR 9004-2(c) caption
-- ---------------------------------------------------------------------------

local function cell(w, xml, tcpr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (tcpr or "") .. '</w:tcPr>' .. xml .. '</w:tc>'
end

local RULE = ' w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
local function borders(right, bottom)
  local b = ""
  if bottom then b = b .. '<w:bottom' .. RULE end
  if right then b = b .. '<w:right' .. RULE end
  return b ~= "" and ('<w:tcBorders>' .. b .. '</w:tcBorders>') or ""
end
local function mar(top, left, bottom, right)
  return '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

-- The ruled caption (typst caption()): row 1 the "In re" debtor block | the case number; row 2 the parties | the
-- adversary number, the title and what follows it (`right`, a list of lines). A rule down the right of the party
-- column and one under the debtor block; neither row splits across pages.
function M.caption(meta, right)
  local c = M.need(meta, "caption")
  local debtor = { xe.runs("In re:") }
  for _, d in ipairs(M.items(c.debtor)) do debtor[#debtor + 1] = xe.inl(d) end
  debtor[#debtor + 1] = xe.inl(c.debtor_role)
  local parties = {}
  for k, pt in ipairs(M.items(c.parties)) do
    if k > 1 then
      parties[#parties + 1] = ""
      parties[#parties + 1] = xe.runs("v.")
      parties[#parties + 1] = ""
    end
    for _, n in ipairs(M.items(pt.names)) do parties[#parties + 1] = xe.inl(n) end
    parties[#parties + 1] = xe.inl(pt.designation)
  end
  local r = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
  local right_w = M.TEXTW - CAP_LEFT
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. M.TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. right_w .. '"/></w:tblGrid>'
    .. r .. cell(CAP_LEFT, M.lines(debtor), borders(true, true) .. mar(0, 0, CAP_RULED, CAP_PAD))
    .. cell(right_w, M.lines({ xe.runs("Case No. ") .. xe.inl(M.need(meta, "case_number")) }), mar(0, CAP_PAD, CAP_RULED, 0))
    .. '</w:tr>' .. r .. cell(CAP_LEFT, M.lines(parties), borders(true, false) .. mar(CAP_PAD, 0, 0, CAP_PAD))
    .. cell(right_w, M.lines(right), mar(CAP_PAD, CAP_PAD, 0, 0)) .. '</w:tr></w:tbl>'
end

-- The right column of the caption's second row: the adversary number, a blank line, the title in bold, then `more`
-- (lists of lines, each after a blank line).
function M.caption_right(meta, more)
  local right = { xe.runs("Adv. Proc. No. ") .. xe.inl(M.need(meta, "adv_number")), "",
    xe.inl(M.need(meta, "brief_title"), { b = true }) }
  for _, group in ipairs(more) do
    right[#right + 1] = ""
    for _, l in ipairs(group) do right[#right + 1] = l end
  end
  return right
end

-- Counsel (single-spaced), a blank double line, the court title (two bold centred single lines), a blank double
-- line, the caption (typst cover()).
function M.cover(meta, right)
  local counsel = {}
  for _, l in ipairs(M.items(M.need(meta, "counsel"))) do counsel[#counsel + 1] = xe.inl(l) end
  local out = { M.lines(counsel) }
  out[#out + 1] = p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { before = M.BLANK, jc = "center", keep = true })
  out[#out + 1] = p(xe.runs("FOR THE DISTRICT OF OREGON", { b = true }), { jc = "center", keep = true })
  -- the blank double line above the caption (Word has no space before a table: an empty paragraph that tall)
  out[#out + 1] = p("", { line = M.BLANK, keep = true })
  out[#out + 1] = M.caption(meta, right)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A heading on the body pitch at the type size, kept with the next block (typst sticky). centre2: level 2 centred.
-- pre: xe.BREAK when the heading opens a page.
function M.heading(level, content, centre2, pre)
  if level == 1 then
    local up = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return xe.raw(p(xe.inl(up, { b = true }), { pre = pre, line = M.BODY, keep = true, jc = "center" }))
  elseif level == 2 then
    return xe.raw(p(xe.inl(content, { b = true }),
      { pre = pre, line = M.BODY, keep = true, jc = centre2 and "center" or "left" }))
  end
  return xe.raw(p(xe.inl(content, { b = true, i = true }), { pre = pre, line = M.BODY, keep = true }))
end

-- A body paragraph (typst body-par): style `style` of reference.xml; `label` ("1.", "A.") and a tab to the text 1 in
-- in, if any; keep: kept whole with the next block (the last chunk, with the signature); brk: the paragraph opens a
-- page (a page break before its first run, which Word and LibreOffice set as a break before the paragraph).
function M.para(content, style, label, keep, brk)
  local inl = pandoc.Inlines({})
  if brk then inl:insert(pandoc.RawInline("openxml", '<w:r><w:br w:type="page"/></w:r>')) end
  if label then
    inl:insert(pandoc.Str(label))
    inl:insert(pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
  end
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = keep and (style .. " Keep") or style })
end

-- a paragraph written "~ text" (the marker is dropped)
function M.tilde(b)
  local f, s = b.content[1], b.content[2]
  if f ~= nil and f.t == "Str" and f.text == "~" and s ~= nil and s.t == "Space" then
    local out = pandoc.Inlines({})
    for i = 3, #b.content do out:insert(b.content[i]) end
    return out
  end
end

-- the index of the last block that becomes a paragraph (a list counts by its last item): kept with the signature
function M.last_block(blocks)
  local last = nil
  for i, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" or b.t == "OrderedList" or b.t == "BulletList" then last = i end
  end
  return last
end

-- The date on a double line, then the signature lines single-spaced 3 in from the margin, kept together (typst
-- signature()).
function M.signature(meta)
  local out = {}
  if meta.date then out[#out + 1] = p(xe.inl(meta.date), { line = M.BODY, keep = true }) end
  local sig = {}
  for _, l in ipairs(M.items(M.need(meta, "signature"))) do sig[#sig + 1] = xe.inl(l) end
  out[#out + 1] = M.lines(sig, { left = SIG_INDENT, keep = true })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Page furniture
-- ---------------------------------------------------------------------------

local function field(name)
  return '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> ' .. name
    .. ' </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
end

-- LBR 9004-1(a)(9)(D): the title (`footer_title` in capitals, as written in the frontmatter) and "Page N of M", in
-- single lines at the lower left (typst page-footer); written as the filter's own footer ($FORMBOOK_FOOTERS), with
-- the section that names it ($FORMBOOK_FINAL): letter, 1 in top and bottom, 0.75 in sides (LBR 9004-1(a)(2)), the
-- footer's last line 0.35 in above the bottom edge.
function M.furniture()
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  local meta = f and pandoc.json.decode(f:read("a"), false) or {}
  if f then f:close() end
  local title = pandoc.text.upper(tostring(meta.footer_title or ""))
  local footer = p(xe.runs(title)) .. p(xe.runs("Page ") .. field("PAGE") .. xe.runs(" of ") .. field("NUMPAGES"),
    { before = FOOTER_GAP })
  local function write(env, text)
    local path = os.getenv(env)
    if not path or path == "" then return end
    local w = assert(io.open(path, "w"))
    w:write(text)
    w:close()
  end
  write("FORMBOOK_FOOTERS", "rIdOrbFooter\t" .. footer .. "\n")
  write("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdOrbFooter"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="1440" w:left="1080" '
    .. 'w:header="720" w:footer="504" w:gutter="0"/></w:sectPr>')
end

return M

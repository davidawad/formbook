-- E.D. Wash. pleading paper for the docx engine (LCivR 10(a), 10(d)), shared by the complaint and the motion filters
-- (the same file in both folders' docx/lib/; loaded with dofile). It mirrors the page furniture and the cover of the
-- typst templates on the cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"):
-- every paragraph in exact line boxes of the typst pitches, 640 twips a numbered line (typst pitch 32 pt) and 320 a
-- single line (pitch-single 16 pt); a block whose height typst measures to whole numbered lines (counsel, caption) is
-- sized here from the text's advance widths (no kerning, no ligatures, first fit: the line breaks both engines make).
-- Twips = 20 x pt.

local xe = require("docx.xengine")
local M = {}

M.BODY, M.SINGLE = 640, 320              -- typst pitch 32 pt, pitch-single 16 pt
M.LINES = 20                             -- typst lines-per-page
M.TOP, M.LEFT, M.RIGHT = 1440, 1584, 1440   -- typst top-margin 72 pt, left-margin 1.1 in, right-margin 1 in
M.BOTTOM = 15840 - M.TOP - M.LINES * M.BODY -- typst bottom-margin 80 pt
M.TEXTW = 12240 - M.LEFT - M.RIGHT       -- typst text-width 460.8 pt
M.SIZE = 14                              -- typst type-size 14 pt
-- The footer: one single line whose box starts 12 pt below the last numbered line (typst footer-gap). LibreOffice
-- sets a Word footer's last line with its foot at the footer distance from the bottom edge.
M.FOOTER = 15840 - (M.TOP + M.LINES * M.BODY + 240) - M.SINGLE

-- ---------------------------------------------------------------------------
-- Advance widths (font units of 2048 an em; typst measures the same advances, without kerning). Times New Roman
-- 2.82 regular, bold, italic (the pinned face); a monospaced face sets every character at `mono` units.
-- ---------------------------------------------------------------------------
local TNR = {
  r = {[" "]=512,["!"]=682,["\""]=836,["#"]=1024,["$"]=1024,["%"]=1706,["&"]=1593,["'"]=369,["("]=682,[")"]=682,["*"]=1024,["+"]=1155,[","]=512,["-"]=682,["."]=512,["/"]=569,["0"]=1024,["1"]=1024,["2"]=1024,["3"]=1024,["4"]=1024,["5"]=1024,["6"]=1024,["7"]=1024,["8"]=1024,["9"]=1024,[":"]=569,[";"]=569,["<"]=1155,["="]=1155,[">"]=1155,["?"]=909,["@"]=1886,["A"]=1479,["B"]=1366,["C"]=1366,["D"]=1479,["E"]=1251,["F"]=1139,["G"]=1479,["H"]=1479,["I"]=682,["J"]=797,["K"]=1479,["L"]=1251,["M"]=1821,["N"]=1479,["O"]=1479,["P"]=1139,["Q"]=1479,["R"]=1366,["S"]=1139,["T"]=1251,["U"]=1479,["V"]=1479,["W"]=1933,["X"]=1479,["Y"]=1479,["Z"]=1251,["["]=682,["\\"]=569,["]"]=682,["^"]=961,["_"]=1024,["`"]=682,["a"]=909,["b"]=1024,["c"]=909,["d"]=1024,["e"]=909,["f"]=682,["g"]=1024,["h"]=1024,["i"]=569,["j"]=569,["k"]=1024,["l"]=569,["m"]=1593,["n"]=1024,["o"]=1024,["p"]=1024,["q"]=1024,["r"]=682,["s"]=797,["t"]=569,["u"]=1024,["v"]=1024,["w"]=1479,["x"]=1024,["y"]=1024,["z"]=909,["{"]=983,["|"]=410,["}"]=983,["~"]=1108,["’"]=682,["‘"]=682,["“"]=909,["”"]=909,["–"]=1024,["—"]=2048,["§"]=1024,["¶"]=928,["…"]=2048,["é"]=909,["\u{a0}"]=512},
  b = {[" "]=512,["!"]=682,["\""]=1137,["#"]=1024,["$"]=1024,["%"]=2048,["&"]=1706,["'"]=569,["("]=682,[")"]=682,["*"]=1024,["+"]=1167,[","]=512,["-"]=682,["."]=512,["/"]=569,["0"]=1024,["1"]=1024,["2"]=1024,["3"]=1024,["4"]=1024,["5"]=1024,["6"]=1024,["7"]=1024,["8"]=1024,["9"]=1024,[":"]=682,[";"]=682,["<"]=1167,["="]=1167,[">"]=1167,["?"]=1024,["@"]=1905,["A"]=1479,["B"]=1366,["C"]=1479,["D"]=1479,["E"]=1366,["F"]=1251,["G"]=1593,["H"]=1593,["I"]=797,["J"]=1024,["K"]=1593,["L"]=1366,["M"]=1933,["N"]=1479,["O"]=1593,["P"]=1251,["Q"]=1593,["R"]=1479,["S"]=1139,["T"]=1366,["U"]=1479,["V"]=1479,["W"]=2048,["X"]=1479,["Y"]=1479,["Z"]=1366,["["]=682,["\\"]=569,["]"]=682,["^"]=1190,["_"]=1024,["`"]=682,["a"]=1024,["b"]=1139,["c"]=909,["d"]=1139,["e"]=909,["f"]=682,["g"]=1024,["h"]=1139,["i"]=569,["j"]=682,["k"]=1139,["l"]=569,["m"]=1706,["n"]=1139,["o"]=1024,["p"]=1139,["q"]=1139,["r"]=909,["s"]=797,["t"]=682,["u"]=1139,["v"]=1024,["w"]=1479,["x"]=1024,["y"]=1024,["z"]=909,["{"]=807,["|"]=451,["}"]=807,["~"]=1065,["’"]=682,["‘"]=682,["“"]=1024,["”"]=1024,["–"]=1024,["—"]=2048,["§"]=1024,["¶"]=1106,["…"]=2048,["é"]=909,["\u{a0}"]=512},
  i = {[" "]=512,["!"]=682,["\""]=860,["#"]=1024,["$"]=1024,["%"]=1706,["&"]=1593,["'"]=438,["("]=682,[")"]=682,["*"]=1024,["+"]=1382,[","]=512,["-"]=682,["."]=512,["/"]=569,["0"]=1024,["1"]=1024,["2"]=1024,["3"]=1024,["4"]=1024,["5"]=1024,["6"]=1024,["7"]=1024,["8"]=1024,["9"]=1024,[":"]=682,[";"]=682,["<"]=1382,["="]=1382,[">"]=1382,["?"]=1024,["@"]=1884,["A"]=1251,["B"]=1251,["C"]=1366,["D"]=1479,["E"]=1251,["F"]=1251,["G"]=1479,["H"]=1479,["I"]=682,["J"]=909,["K"]=1366,["L"]=1139,["M"]=1706,["N"]=1366,["O"]=1479,["P"]=1251,["Q"]=1479,["R"]=1251,["S"]=1024,["T"]=1139,["U"]=1479,["V"]=1251,["W"]=1706,["X"]=1251,["Y"]=1139,["Z"]=1139,["["]=797,["\\"]=569,["]"]=797,["^"]=864,["_"]=1024,["`"]=682,["a"]=1024,["b"]=1024,["c"]=909,["d"]=1024,["e"]=909,["f"]=569,["g"]=1024,["h"]=1024,["i"]=569,["j"]=569,["k"]=909,["l"]=569,["m"]=1479,["n"]=1024,["o"]=1024,["p"]=1024,["q"]=1024,["r"]=797,["s"]=797,["t"]=569,["u"]=1024,["v"]=909,["w"]=1366,["x"]=909,["y"]=909,["z"]=797,["{"]=819,["|"]=563,["}"]=819,["~"]=1108,["’"]=682,["‘"]=682,["“"]=1139,["”"]=1139,["–"]=1024,["—"]=1821,["§"]=1024,["¶"]=1071,["…"]=1821,["é"]=909,["\u{a0}"]=512},
}

local face = { mono = nil }
-- The face of the template: mono = advance in font units for a monospaced face (Liberation Mono: 1229), or nil.
function M.set_face(mono) face.mono = mono end

local function adv(ch, style)
  if face.mono then return face.mono end
  local t = TNR[style] or TNR.r
  return t[ch] or TNR.r[ch] or 1024
end

-- The pieces of pandoc inlines (or a metadata value) between break opportunities, each a list of { char, style }
-- with `space` set when a space precedes it: lines break at spaces and after a hyphen or a slash that a letter
-- follows (UAX #14, as typst breaks; xe.runs keeps a hyphen before a digit, docx/lib's break rules a slash).
local function words(x, style, out, cur)
  out = out or {}
  cur = cur or { w = { space = false }, space = false }
  local function flush(space)
    if #cur.w > 0 then out[#out + 1] = cur.w end
    cur.w = { space = space }
  end
  local function add(s, st)
    local chars = {}
    for ch in s:gmatch(utf8.charpattern) do chars[#chars + 1] = ch end
    for k, ch in ipairs(chars) do
      cur.w[#cur.w + 1] = { ch, st }
      local nxt = chars[k + 1]
      if (ch == "-" or ch == "/") and nxt and not nxt:match("^%d") then flush(false) end
    end
  end
  if type(x) == "string" then
    for part in x:gmatch("[^ ]+%s*") do
      add((part:gsub("%s+$", "")), style); flush(true)
    end
    return out, cur
  end
  for _, el in ipairs(x) do
    local t = el.t
    if t == "Str" then add(el.text, style)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then flush(true)
    elseif t == "Emph" then words(el.content, style == "b" and "b" or "i", out, cur)
    elseif t == "Strong" then words(el.content, "b", out, cur)
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      add(q[1], style); words(el.content, style, out, cur); add(q[2], style)
    elseif el.content then words(el.content, style, out, cur)
    else add(pandoc.utils.stringify(el), style) end
  end
  return out, cur
end

-- The number of lines a text sets in `avail` twips at the type size, first fit at spaces.
function M.count_lines(x, avail, bold)
  local ws, cur = words(x, bold and "b" or "r")
  if #cur.w > 0 then ws[#ws + 1] = cur.w end
  local unit = M.SIZE * 20 / 2048          -- twips per font unit
  local space = adv(" ", "r") * unit
  local lines, width = 1, nil
  for _, w in ipairs(ws) do
    local ww = 0
    for _, c in ipairs(w) do ww = ww + adv(c[1], c[2]) * unit end
    local gap = w.space and space or 0
    if width == nil then width = ww
    elseif width + gap + ww <= avail + 0.2 then width = width + gap + ww
    else lines = lines + 1; width = ww end
  end
  return lines
end

-- Whole numbered lines for a height in twips: at least `min`.
function M.grid_lines(h, min)
  return math.max(min or 1, math.ceil(h / M.BODY - 0.001))
end

-- ---------------------------------------------------------------------------
-- Paragraphs
-- ---------------------------------------------------------------------------

-- A paragraph: o = { style, keep, brk (starts a page), before, after, line, left, hanging, first, right, jc, tabs }.
function M.p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or M.SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end
M.txt = txt

-- The items of a metadata list (or of a single metadata value).
function M.items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- Single-spaced lines (typst line-stack): items are metadata values or strings, o = { gaps = { [k] = true }, b, left,
-- keep }: a blank single line before the items in gaps. Returns the paragraphs and the number of lines they set in
-- `avail` twips.
function M.stack(lines, o, avail)
  o = o or {}
  local out, n = {}, 0
  for k, l in ipairs(lines) do
    local before = (o.gaps and o.gaps[k]) and M.SINGLE or 0
    local r = type(l) == "string" and xe.runs(l, { b = o.b }) or xe.inl(l, { b = o.b })
    out[#out + 1] = M.p(r, { before = before, left = o.left, keep = o.keep })
    if avail then n = n + M.count_lines(l, avail, o.b) + (before > 0 and 1 or 0) end
  end
  return out, n
end

local function cell(width, inner, tcpr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (tcpr or '') .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- A one-row table with fixed columns; cols = { { width, xml, tcpr } }; height: an exact row height in twips, or nil.
function M.table(cols, height)
  local grid, tcs = {}, {}
  local w = 0
  for _, c in ipairs(cols) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    tcs[#tcs + 1] = cell(c[1], c[2] ~= "" and c[2] or "<w:p/>", c[3])
    w = w + c[1]
  end
  local trh = height and ('<w:trHeight w:val="' .. height .. '" w:hRule="exact"/>') or ""
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. w .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/>' .. trh .. '</w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- The cover (typst counsel-block, court-title, caption)
-- ---------------------------------------------------------------------------

-- Counsel, single spaced from line 1, in whole numbered lines, at least four (LCivR 10(a)(1)(A)): the last line's
-- space after takes the block to them.
function M.counsel(lines)
  local out, n = M.stack(lines, {}, M.TEXTW)
  local h = M.grid_lines(n * M.SINGLE, 4) * M.BODY
  if #out > 0 then
    out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. (h - n * M.SINGLE) .. '"', 1)
  end
  return table.concat(out)
end

-- The court's name, centred (LCivR 10(a)(1)(B)): one numbered line each and a blank numbered line, or (single)
-- single spaced with a blank single line after it, in whole numbered lines.
function M.court(division, single)
  local lines = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF WASHINGTON" }
  if txt(division) ~= "" then lines[#lines + 1] = txt(division):upper() end
  local out = {}
  for _, l in ipairs(lines) do
    out[#out + 1] = M.p(xe.runs(l), { line = single and M.SINGLE or M.BODY, jc = "center" })
  end
  if single then
    local pad = M.grid_lines((#lines + 1) * M.SINGLE) * M.BODY - #lines * M.SINGLE
    out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. pad .. '"', 1)
  else
    out[#out + 1] = M.p("", { line = M.BODY })
  end
  return table.concat(out)
end

-- The caption (typst caption): the parties at left in a box ruled at its right and foot, 10 pt off the rule and its
-- last line 8 pt above the foot; at right, 0.15 in off the 0.2 in gutter, the items (strings or metadata values;
-- bold = { [k] = true }, gaps = { [k] = true }: a blank single line before). The row is whole numbered lines tall.
local CAP_LEFT, CAP_GUTTER, RULE_PAD, RULE_BELOW, RIGHT_PAD = 4608, 288, 200, 160, 216
function M.caption(parties, right_items, bold, gaps)
  local rows = {}
  for k, party in ipairs(M.items(parties)) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, l in ipairs(M.items(party.names)) do rows[#rows + 1] = l end
    rows[#rows + 1] = party.designation
  end
  local left, nl = M.stack(rows, {}, CAP_LEFT - RULE_PAD)
  local right_w = M.TEXTW - CAP_LEFT - CAP_GUTTER
  local right, nr = {}, 0
  for k, it in ipairs(right_items) do
    local before = gaps[k] and M.SINGLE or 0
    local r = type(it) == "string" and xe.runs(it, { b = bold[k] }) or xe.inl(it, { b = bold[k] })
    right[#right + 1] = M.p(r, { before = before })
    nr = nr + M.count_lines(it, right_w - RIGHT_PAD, bold[k]) + (before > 0 and 1 or 0)
  end
  -- LibreOffice adds the 0.75 pt bottom rule (15 twips) to an exact row's height: the row is that much shorter
  local h = M.grid_lines(math.max(nl * M.SINGLE + RULE_BELOW, nr * M.SINGLE)) * M.BODY - 15
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return M.table({
    { CAP_LEFT, table.concat(left), rule .. '<w:tcMar><w:right w:w="' .. RULE_PAD .. '" w:type="dxa"/></w:tcMar>' },
    { CAP_GUTTER, "" },
    { right_w, table.concat(right), '<w:tcMar><w:left w:w="' .. RIGHT_PAD .. '" w:type="dxa"/></w:tcMar>' },
  }, h)
end

-- The signature block (typst signature-block): the date line at the margin in a 2.6 in column, the signature column
-- after a 0.2 in gutter, single spaced, on one page.
local SIG_LEFT, SIG_GUTTER = 3744, 288
function M.signature(date_line, lines, gaps)
  local g = {}
  for _, k in ipairs(gaps) do g[k] = true end
  local right = M.stack(lines, { gaps = g })
  return M.table({
    { SIG_LEFT, M.p(xe.runs(date_line)) },
    { SIG_GUTTER, "" },
    { M.TEXTW - SIG_LEFT - SIG_GUTTER, table.concat(right) },
  })
end

-- ---------------------------------------------------------------------------
-- Page furniture: the footer (fb render's $FORMBOOK_FOOTERS) and the section ($FORMBOOK_FINAL)
-- ---------------------------------------------------------------------------

-- The footer: the numbers 1 to 20 down the left margin, each in a numbered line's box (exact 640), right aligned in
-- a frame 0.65 in wide at the page's left edge, from the top margin (typst line-numbers); then the title in capitals,
-- " - " and the page number (LCivR 10(a)(1)(E), 10(a)(2)) in a single line at the text's left edge.
M.FOOTER_ID = "rIdFtrWaed"
function M.footer(title)
  local out = {}
  local frame = '<w:framePr w:w="936" w:hSpace="0" w:wrap="around" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="'
    .. M.TOP .. '"/>'
  for i = 1, M.LINES do
    out[#out + 1] = '<w:p><w:pPr>' .. frame .. xe.spacing(0, 0, M.BODY) .. xe.ind(0, nil, 0) .. xe.jc("right")
      .. '</w:pPr>' .. xe.runs(tostring(i)) .. '</w:p>'
  end
  out[#out + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, M.SINGLE) .. xe.ind(0, nil, 0) .. xe.jc("left") .. '</w:pPr>'
    .. xe.runs(title:upper() .. " - ")
    .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  return table.concat(out)
end

-- The section: letter, the typst margins, the footer above, the pleading rules as page borders (a double rule 14 pt
-- left of the text, a single rule 7 pt right of it; typst pleading-rules at 0.2 in and 0.1 in).
function M.sect_pr()
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. M.FOOTER_ID .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="' .. M.TOP .. '" w:right="' .. M.RIGHT .. '" w:bottom="'
    .. M.BOTTOM .. '" w:left="' .. M.LEFT .. '" w:header="720" w:footer="' .. M.FOOTER .. '" w:gutter="0"/>'
    .. '<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders>'
    .. '<w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr>'
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end
M.write_file = write_file

-- The footer (from the sample's footer_title, as written) and the section, for fb render.
function M.furniture()
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  local meta = f and pandoc.json.decode(f:read("a"), false) or {}
  if f then f:close() end
  local title = meta.footer_title
  if type(title) ~= "string" or title == "" then error("pleading.lua: the sample has no footer_title") end
  write_file("FORMBOOK_FOOTERS", M.FOOTER_ID .. "\t" .. M.footer(title) .. "\n")
  write_file("FORMBOOK_FINAL", M.sect_pr())
end

-- ---------------------------------------------------------------------------
-- Break opportunities as typst has them (Unicode line breaking, UAX #14), on the body and the metadata alike
-- ---------------------------------------------------------------------------

-- None inside a token of adjacent parentheses ("216(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060)
-- between ")" and "("; one after a slash followed by a letter ("and/or", "CM/ECF"), where LibreOffice keeps the word
-- whole: a zero-width space (U+200B) after it. Neither shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A Str of two or more section signs or pilcrows ("§§", "¶¶"): typst boxes it with its number.
local function doubled_sign(t)
  local _, s = t:gsub("\u{00A7}", "")
  local _, q = t:gsub("\u{00B6}", "")
  return s + q >= 2 and #t == 2 * (s + q)
end

-- No break at a space before a period (". . ."; UAX #14 has no break before a full stop, LibreOffice breaks there),
-- nor after a doubled sign ("¶¶ 8–9"): the space becomes a no-break space, as wide.
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

M.inline_filter = { Str = break_rules, Inlines = no_break_before_stop }

return M

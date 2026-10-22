-- E.D. Mich. bankruptcy motion with brief (mieb), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document.
-- Mirrors typst/mieb-motion-brief.typ:
--   * the body is split into the documents of the filing at the lines holding only `---`, read from the sample as
--     typst reads it (each part parsed on its own, so its footnotes resolve within it); each document starts on a new
--     page with its own caption (court, the debtor and case block in two columns ruled above and below), and the
--     title is the frontmatter `titles` entry for that document (a count mismatch is an error, as in typst);
--   * the body keeps its markdown structure: `#` centered bold, `##` bold, `###` bold italic; paragraphs are typed by
--     the author ("1\."), not numbered here; footnotes are pandoc's native footnotes; the last block of each document
--     is kept with the signature block;
--   * each document ends with the signature block: "Dated" at the left, "Respectfully submitted" and the signer at
--     the right (a borderless table, the row kept whole).
-- Nothing case-specific is written here: every string comes from the sample; the caption, title and signature
-- strings are read as written ($FORMBOOK_META), as typst reads them. Font, spacing, margins and the "N of M" footer
-- are styles and section settings in docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 560 the body, 340 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 340                         -- typst pitch-single 17 pt
local COL, CASE_PAD = 4680, 360            -- typst caption-col 3.25 in, case-pad 0.25 in
local SIG_LEFT, SIG_COL = 4752, 4608       -- typst text-width - sig-col 3.3 in, sig-col 3.2 in
local RULE_PAD = 80                        -- typst rule-pad 4 pt
local COURT_BELOW = 336                    -- typst court-below 16.8 pt
local CAPTION_BELOW, TITLE_BELOW = 336, 224 -- typst caption-below 16.8 pt, title-below 11.2 pt
local SIG_ABOVE = 336                      -- typst signature-above 16.8 pt

local function read_file(path)
  local f = path and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (strings unchanged by pandoc's smart punctuation), as typst reads it.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(t, key)
  if t[key] == nil then error("mieb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return t[key]
end

-- A metadata value that may be one string or a list of strings, as a list.
local function lines_of(v)
  if type(v) == "table" then return v end
  return { v }
end

-- A single-spaced paragraph: o = { before, after, jc, brk }.
local function p(body, o)
  o = o or {}
  return xe.para({ o.brk and xe.BREAK or "", xe.spacing(o.before or 0, o.after or 0, SINGLE), xe.ind(0, nil, 0),
    xe.jc(o.jc or "left") }, body)
end

-- Vertical space of its own (typst block spacing before a table): an empty paragraph in a line box of that height.
local function space(twips, keep)
  return xe.para({ keep and "<w:keepNext/>" or "", xe.spacing(0, 0, twips) }, "")
end

local RULE = '<w:%s w:val="single" w:sz="4" w:space="0" w:color="000000"/>'

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- Two columns, fixed widths, no cell margins unless a cell sets its own; the row is not split across pages (typst:
-- one grid row).
local function grid2(w1, w2, left, right, left_extra, right_extra)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (w1 + w2) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. w1 .. '"/><w:gridCol w:w="' .. w2 .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(w1, left, left_extra) .. cell(w2, right, right_extra)
    .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- the caption of each document (MIEB-CAP-001)
-- ---------------------------------------------------------------------------

local function caption(title, new_page)
  local out = {}
  for i, l in ipairs(lines_of(need(RAW, "court"))) do
    out[#out + 1] = p(xe.runs(l), { jc = "center", brk = new_page and i == 1 })
  end
  out[#out + 1] = space(COURT_BELOW)
  local ir, cs = need(RAW, "in_re"), need(RAW, "case")
  local left = {}
  for i, n in ipairs(lines_of(ir.names)) do left[#left + 1] = p(xe.runs((i == 1 and "In re: " or "") .. n)) end
  left[#left + 1] = p(xe.runs(ir.role))
  left[#left + 1] = p(xe.runs("/"))
  local right = { p(xe.runs("Chapter " .. cs.chapter)), p(xe.runs("Case No. " .. cs.number)), p(xe.runs(cs.judge)) }
  -- ruled above and below across both columns (typst: the grid's stroke and inset)
  local borders = '<w:tcBorders>' .. string.format(RULE, "top") .. string.format(RULE, "bottom") .. '</w:tcBorders>'
  local mar = function(l)
    return '<w:tcMar><w:top w:w="' .. RULE_PAD .. '" w:type="dxa"/><w:left w:w="' .. l .. '" w:type="dxa"/>'
      .. '<w:bottom w:w="' .. RULE_PAD .. '" w:type="dxa"/></w:tcMar>'
  end
  out[#out + 1] = grid2(COL, COL, table.concat(left), table.concat(right), borders .. mar(0), borders .. mar(CASE_PAD))
  out[#out + 1] = p(xe.runs(title, { b = true }), { jc = "center", before = CAPTION_BELOW, after = TITLE_BELOW })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the signature block at the end of each document (MIEB-SIG-001)
-- ---------------------------------------------------------------------------

local function signature()
  local sig = need(RAW, "signature")
  local right = { p(xe.runs("Respectfully submitted,")), p(xe.runs(sig.signer)) }
  for _, l in ipairs(lines_of(sig.lines)) do right[#right + 1] = p(xe.runs(l)) end
  return space(SIG_ABOVE, true)
    .. grid2(SIG_LEFT, SIG_COL, p(xe.runs("Dated: " .. need(RAW, "date"))), table.concat(right))
end

-- ---------------------------------------------------------------------------
-- the filing: one document per `---`-separated part of the body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows
-- in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled section sign stays with its number ("§§ 157(a)"; the typst template boxes it, lib/docx/xengine.lua binds
-- a single sign): the space after it becomes a no-break space.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    local a, b = l[i], l[i + 1]
    if a.t == "Str" and b.t == "Space" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph keeps Word's widow control when it anchors a footnote: typst moves the line before a footnote line that
-- does not fit along with it (its widow rule), as Word does (the sample's p3 to p4).
local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- The documents of the filing, as typst splits the sample: the body after the frontmatter, at each line holding only
-- `---` (optional trailing blanks).
local function parts_of(src)
  local body = src:gsub("\r\n", "\n"):match("^%-%-%-\n.-\n%-%-%-[ \t]*\n(.*)$")
  if body == nil then error("mieb-motion-brief: the sample must start with a YAML frontmatter block", 0) end
  local parts, rest = {}, "\n" .. body .. "\n"
  while true do
    local s, e = rest:find("\n%-%-%-[ \t]*\n")
    if not s then break end
    parts[#parts + 1] = rest:sub(1, s)
    rest = rest:sub(e)
  end
  parts[#parts + 1] = rest
  return parts
end

local function document(blocks)
  local out = {}
  local last = 0
  for i, b in ipairs(blocks) do
    if b.t ~= "Null" then last = i end
  end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last block is kept with the signature block that follows it (typst sticky)
      out[#out + 1] = styled(i == last and "Conclusion" or "Body Text", b.content)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      -- a block quotation (Block Text) is kept as pandoc writes it
      out[#out + 1] = b
    end
  end
  return out
end

local function filing(doc)
  local titles = lines_of(need(RAW, "titles"))
  local src = read_file(PANDOC_STATE.input_files[1])
  if src == nil then error("mieb-motion-brief: cannot read the sample", 0) end
  local parts = parts_of(src)
  if #parts ~= #titles then
    error("mieb-motion-brief: the body has " .. #parts .. " documents but `titles` lists " .. #titles, 0)
  end

  local out = {}
  for i, part in ipairs(parts) do
    out[#out + 1] = xe.raw(caption(titles[i], i > 1))
    local d = pandoc.read(part, "markdown+smart", PANDOC_READER_OPTIONS)
    d = d:walk({ Str = break_rules }):walk({ Inlines = bind_double_signs })
    for _, b in ipairs(pandoc.Blocks(document(d.blocks)):walk({ Inlines = xe.inlines })) do out[#out + 1] = b end
    out[#out + 1] = xe.raw(signature())
  end
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Pandoc = filing } }

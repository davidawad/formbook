-- E.D. Mich. bankruptcy adversary complaint (mieb), DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document. Mirrors typst/mieb-adversary-complaint.typ:
--   * the court name (centered, single spaced), the debtor caption and the adversary caption as two borderless
--     two-column tables ruled across (the cells' top and bottom borders), the title in bold, centered;
--   * the lead-in paragraph (frontmatter `lead_in`), unnumbered;
--   * the body: `#` and `##` headings centered and bold; every other paragraph numbered here, from 1, with the
--     number typed as text ("1."); a paragraph beginning WHEREFORE is an unnumbered prayer; the last paragraph is
--     kept with the signature block;
--   * the signature block: "Dated" at the left, the signer at the right (a borderless table, the row kept whole).
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter; the caption and
-- title strings are read as written ($FORMBOOK_META), as typst reads them. Font, spacing, margins and the "N of M"
-- footer are styles and section settings in docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 560 the body, 340 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 560, 340              -- typst pitch-body 28 pt, pitch-single 17 pt
local COL, CASE_PAD = 4680, 360            -- typst caption-col 3.25 in, case-pad 0.25 in
local SIG_LEFT, SIG_COL = 4752, 4608       -- typst text-width - sig-col 3.3 in, sig-col 3.2 in
local RULE_PAD = 80                        -- typst rule-pad 4 pt
local COURT_BELOW, CAPTIONS_GAP, VS_GAP = 336, 168, 168 -- typst court-below 16.8 pt, captions-gap, vs-gap 8.4 pt
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
  if t[key] == nil then error("mieb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return t[key]
end

-- A metadata value that may be one string or a list of strings, as a list.
local function lines_of(v)
  if type(v) == "table" then return v end
  return { v }
end

-- A single-spaced paragraph: o = { before, after, line, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Vertical space of its own (typst block spacing between two tables, or before one): an empty paragraph in a line
-- box of that height.
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

-- One caption: the party column and the case column, ruled above (when `top`) and below across both (typst
-- caption-table: the grid's stroke and inset).
local function caption_table(top, left, right)
  local borders = '<w:tcBorders>' .. (top and string.format(RULE, "top") or "") .. string.format(RULE, "bottom")
    .. '</w:tcBorders>'
  local mar = function(l)
    return '<w:tcMar>' .. (top and ('<w:top w:w="' .. RULE_PAD .. '" w:type="dxa"/>') or "")
      .. '<w:left w:w="' .. l .. '" w:type="dxa"/><w:bottom w:w="' .. RULE_PAD .. '" w:type="dxa"/></w:tcMar>'
  end
  return grid2(COL, COL, table.concat(left), table.concat(right), borders .. mar(0), borders .. mar(CASE_PAD))
end

-- ---------------------------------------------------------------------------
-- the cover: court, caption, title (MIEB-CAP-001, MIEB-CAP-002)
-- ---------------------------------------------------------------------------

local function cover()
  local out = {}
  for _, l in ipairs(lines_of(need(RAW, "court"))) do out[#out + 1] = p(xe.runs(l), { jc = "center" }) end
  out[#out + 1] = space(COURT_BELOW)

  -- debtor caption: the debtor on the left (the role at the right), the case block on the right
  local ir, cs = need(RAW, "in_re"), need(RAW, "case")
  local left = {}
  for i, n in ipairs(lines_of(ir.names)) do left[#left + 1] = p(xe.runs((i == 1 and "In re: " or "") .. n)) end
  left[#left + 1] = p(xe.runs(ir.role), { jc = "right" })
  local right = { p(xe.runs("Case No. " .. cs.number)), p(xe.runs("Chapter " .. cs.chapter)), p(xe.runs(cs.judge)) }
  out[#out + 1] = caption_table(true, left, right)
  out[#out + 1] = space(CAPTIONS_GAP)

  -- adversary caption: the parties ("vs." between them), the chapter and the adversary number; a number not yet
  -- assigned is a blank line of underscores, as in typst
  local pl = {}
  for i, side in ipairs(need(RAW, "caption")) do
    if i > 1 then pl[#pl + 1] = p(xe.runs("vs."), { jc = "center", before = VS_GAP }) end
    for j, n in ipairs(lines_of(side.names)) do
      pl[#pl + 1] = p(xe.runs(n), { before = (i > 1 and j == 1) and VS_GAP or 0 })
    end
    pl[#pl + 1] = p(xe.runs(side.designation), { jc = "right" })
  end
  local an = need(RAW, "adversary_number")
  if an == "" then an = string.rep("_", 14) end
  local pr = { p(xe.runs("Chapter " .. cs.chapter)), p(xe.runs("Adversary Proceeding No. " .. an)) }
  out[#out + 1] = caption_table(false, pl, pr)
  out[#out + 1] = p(xe.runs(need(RAW, "title"), { b = true }), { jc = "center", before = CAPTION_BELOW, after = TITLE_BELOW })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the signature block (MIEB-SIG-001): "Dated" at the left, the signer at the right
-- ---------------------------------------------------------------------------

local function signature()
  local sig = need(RAW, "signature")
  local right = { p(xe.runs(sig.signer)) }
  for _, l in ipairs(lines_of(sig.lines)) do right[#right + 1] = p(xe.runs(l)) end
  return space(SIG_ABOVE, true)
    .. grid2(SIG_LEFT, SIG_COL, p(xe.runs("Dated: " .. need(RAW, "date"))), table.concat(right))
end

-- ---------------------------------------------------------------------------
-- the body: numbered paragraphs, unnumbered prayers, centered headings
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("548(a)(1)(B)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows
-- in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function finish(doc)
  local meta = doc.meta
  local out = { xe.raw(cover()) }

  -- the lead-in: the opening paragraph before the first heading, unnumbered
  out[#out + 1] = xe.raw(xe.para({ xe.style("BodyText") }, xe.inl(need(meta, "lead_in"))))

  local last = 0
  for i, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" or b.t == "Header" then last = i end
  end
  local n = 0
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = pandoc.Header(math.min(b.level, 2), b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph is kept with the signature block (typst sticky)
      local style = i == last and "Conclusion" or "Body Text"
      if pandoc.utils.stringify(b):sub(1, 9) == "WHEREFORE" then
        out[#out + 1] = styled(style, b.content)
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(n .. "."), pandoc.Space() })
        inl:extend(b.content)
        out[#out + 1] = styled(style, inl)
      end
    else
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature()))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }

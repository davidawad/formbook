-- texcrimapp-opening-brief.lua (docx engine): the Court of Criminal Appeals of Texas brief on the merits (TRAP 9.4,
-- 9.5, 38.1, 70.3) as Word paragraphs, so that it reads and breaks as ../typst/texcrimapp-opening-brief.typ (the
-- reference for the form) does:
--   * the cover (TRAP 9.4(g)): centered single lines with the typst spaces, its own section without a page number;
--   * the front matter (identity, contents, index; every level-1 heading but the first opens a page), a section
--     numbered in lower-case roman from i;
--   * the body from "# Statement Regarding Oral Argument", the last section, numbered from 1.
-- Blocks as typst sets them: headings (Head 1 / 2 / 3), contents and index entries ("title ..... page": a row with
-- the page reference in a column of its own and a dot leader before it), single-spaced blocks (a hard line break or
-- a bold label: Single Block, a run of them in the body kept together), and double-spaced paragraphs (Body Text,
-- Body Text Note for one that anchors a footnote) and lists, written by pandoc in the styles of docx/reference.xml.
-- Every case word comes from the YAML frontmatter or the body. No coordinates, no forced line breaks.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line, 368 the
-- 16 pt cover title), the spaces between blocks those of the typst template, and typst's break rules on every run.

local xe = require("docx.xengine")

local SINGLE, TITLE = 322, 368   -- typst pitch-single, pitch-title
local GAP = 322                  -- typst gap: a blank single line
local TEXTW = 9360               -- 6.5 in
local HANG = 720                 -- typst row-hang 0.5 in
local PAGE_GAP = 70              -- typst page-gap 3.5 pt
local SIZE = 14                  -- typst type-size
local BODY_START = "statement regarding oral argument"
local REQUIRED = { "case_number", "style_petitioner", "style_respondent", "filing_party", "brief_title",
  "appeal_from", "lead_counsel", "counsel_lines" }

local PGMAR = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="686" w:gutter="0"/>'
local SECT_COVER = '<w:sectPr>' .. PGMAR .. '</w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="rIdRomanFtr"/>' .. PGMAR ..
  '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
local SECT_BODY = '<w:sectPr><w:footerReference w:type="default" r:id="rIdArabicFtr"/>' .. PGMAR ..
  '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'
-- the page number centered in a single line box (typst: text(..edges(pitch-single)))
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>' ..
  '<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r>' ..
  '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
  '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- A paragraph: o = { before, after, line, left, hanging, right, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP else props[#props + 1] = xe.LINES end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and 0 or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- The end of a section: an empty paragraph that takes no room.
local function section(sect)
  return xe.raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. sect ..
    '</w:pPr></w:p>')
end

-- ---------------------------------------------------------------------------
-- Cover (TRAP 9.4(g))
-- ---------------------------------------------------------------------------

local function cover(m, out)
  local function line(body, before, o)
    o = o or {}
    o.before, o.jc = before or 0, "center"
    out[#out + 1] = xe.raw(p(body, o))
  end
  line(xe.inl(m.case_number, { b = true }), 576)                       -- typst v(28.8pt)
  line(xe.runs("IN THE COURT OF CRIMINAL APPEALS OF TEXAS", { b = true }), 288)
  line(xe.inl(m.style_petitioner, { b = true }), 432)
  line(xe.runs("v."), 120)
  line(xe.inl(m.style_respondent, { b = true }), 120)
  line(xe.inl(m.appeal_from), 288)
  line(xe.runs(pandoc.text.upper(plain(m.brief_title)), { b = true, sz = 32 }), 460, { line = TITLE })
  line(xe.inl(m.filing_party), 504)
  line(xe.inl(m.lead_counsel), 180)
  for _, l in ipairs(m.counsel_lines) do line(xe.inl(l), 0) end
  if m.filed_date then line(xe.inl(m.filed_date), 360) end
end

-- ---------------------------------------------------------------------------
-- Contents and index rows
-- ---------------------------------------------------------------------------

-- The advance of a page reference in Times New Roman, 1/2048 em (typst `advances`: the same table).
local ADV = {
  [","] = 512, [" "] = 512, ["\u{2013}"] = 1024, ["-"] = 682, ["."] = 512, i = 569, v = 1024, x = 1024, l = 569,
  c = 909, n = 1024, p = 1024, a = 909, s = 797, m = 1593, ["&"] = 1593,
}
for d = 0, 9 do ADV[tostring(d)] = 1024 end

-- The page column of a row in twips: the reference's width rounded up to a whole twip, plus typst page-gap.
local function page_col(page)
  local units = 0
  for _, c in utf8.codes(page) do units = units + (ADV[utf8.char(c)] or 1024) end
  return math.ceil(units * SIZE * 20 / 2048 - 0.01) + PAGE_GAP
end

-- "title ..... page": the title's inlines and the page reference, or nil.
local function leader_row(b)
  if b.t ~= "Para" and b.t ~= "Plain" then return nil end
  local c = b.content
  for i, el in ipairs(c) do
    if el.t == "LineBreak" or el.t == "SoftBreak" then return nil end
    if el.t == "Str" and el.text:match("^%.%.%.%.+$") then
      local title = pandoc.Inlines({ table.unpack(c, 1, i - 1) })
      while #title > 0 and title[#title].t == "Space" do title:remove(#title) end
      local page = plain(pandoc.Inlines({ table.unpack(c, i + 1) })):gsub("^%s+", ""):gsub("%s+$", "")
      if #title == 0 or page == "" then return nil end
      return title, page
    end
  end
  return nil
end

local function row(title, page)
  local col = page_col(page)
  return xe.raw(p(xe.inl(title) .. xe.runs(xe.LEAD) .. xe.runs(page),
    { before = GAP, left = HANG, hanging = HANG, right = col, tabs = xe.leader_tab(TEXTW) }))
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

local function has(b, kind)
  local found = false
  b:walk({ [kind] = function() found = true end })
  return found
end

-- typst `single`: a hard line break, or a paragraph that opens with a bold label
local function is_single(b)
  if b.t ~= "Para" and b.t ~= "Plain" then return false end
  local hard = false
  pandoc.Inlines(b.content):walk({ LineBreak = function() hard = true end, Note = function() return {} end })
  return hard or (b.content[1] ~= nil and b.content[1].t == "Strong")
end

local function div(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- One part (front matter or body) as typst's render-part sets it.
local function part(blocks, front, out)
  for i, b in ipairs(blocks) do
    -- the break rules on what pandoc writes itself (a row's title goes through xe.inl, which applies them)
    if not leader_row(b) then b = b:walk({ Inlines = xe.inlines }) end
    local nxt = blocks[i + 1]
    if b.t == "Header" then
      if b.level == 1 then
        out[#out + 1] = div(i == 1 and "Head 1 Top" or (front and "Head 1 Break" or "Head 1"), b.content)
      elseif b.level == 2 then
        out[#out + 1] = div("Head 2", b.content)
      else
        out[#out + 1] = div("Head 3", b.content)
      end
    elseif leader_row(b) then
      out[#out + 1] = row(leader_row(b))
    elseif is_single(b) then
      local keep = not front and nxt ~= nil and is_single(nxt)
      out[#out + 1] = div(keep and "Single Block Keep" or "Single Block", b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      local note = false
      pandoc.Inlines(b.content):walk({ Note = function() note = true end })
      out[#out + 1] = div(note and "Body Text Note" or "Body Text", b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("texcrimapp-opening-brief.lua: unsupported block " .. b.t, 0)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 13": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  local m = doc.meta
  for _, k in ipairs(REQUIRED) do
    if m[k] == nil then error("texcrimapp opening brief: frontmatter field `" .. k .. "` is missing", 0) end
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local start
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^%s*(.-)%s*$") == BODY_START then
      start = i
      break
    end
  end
  if not start then
    error("texcrimapp opening brief: the body must start with the heading `# Statement Regarding Oral Argument`", 0)
  end

  local out = {}
  cover(m, out)
  out[#out + 1] = section(SECT_COVER)
  part({ table.unpack(doc.blocks, 1, start - 1) }, true, out)
  out[#out + 1] = section(SECT_ROMAN)
  part({ table.unpack(doc.blocks, start) }, false, out)

  write_file("FORMBOOK_FOOTERS", "rIdRomanFtr\t" .. FOOTER_P .. "\nrIdArabicFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", SECT_BODY)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

-- Bankr. D.N.M. adversary complaint, docx engine (docs/DOCX.md): the same markdown contract as
-- typst/nmb-adversary-complaint.typ, read the way it reads it (the frontmatter strings as written, the body split into
-- blank-line-separated chunks, each chunk's text as CommonMark), and every block written as it sets it: the court
-- lines, the caption (the debtor's lines with the case number, the parties box ruled at its right and bottom with the
-- adversary number beside it; FRBP 7010, Official Form 416, 9004(b)), the title, the lead-in, the headings, the
-- numbered paragraphs (renumbered from 1), the lettered sub-items, the single-spaced quotations, the prayer, the
-- signature block (NM LBR 9011-1(a)), the footnotes (`[^n]` with the text in the frontmatter) and the footer (the
-- short title and "Page X of Y"). Everything printed comes from the sample: no case text lives in this file. The
-- caption boxes are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 300 a single line, 230 a footer
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, NOTE = 480, 300, 230              -- typst pitch-double, pitch-single, pitch-note
local INDENT = 720                                     -- typst para-indent, 0.5 in
local QUOTE = 1080                                     -- typst quote-indent, 0.75 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360                 -- typst caption-left (3.4 in), caption-gutter (0.25 in)
local CAP_PAD = 180                                    -- typst caption-pad, 9 pt
local CAP_RULE = 15                                    -- the 0.75 pt rule LibreOffice sets inside a cell's top and
                                                       -- bottom margin
local SIG_LEFT = 4680                                  -- typst signature-indent, 3.25 in
local SIG_RULE = 31                                    -- typst signature-rule
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt
local FOOTER_ID = "rIdNmbFooter"

-- ---------------------------------------------------------------------------
-- Reading the sample as the typst template reads it
-- ---------------------------------------------------------------------------

local function slurp(path)
  local f = assert(io.open(path, "r"))
  local s = f:read("a")
  f:close()
  return s
end

local function read_meta()
  local path = os.getenv("FORMBOOK_META")
  if not path then error("nmb-adversary-complaint.lua: FORMBOOK_META is not set (render with fb render)", 0) end
  return pandoc.json.decode(slurp(path), false)
end

-- The markdown body after the frontmatter (typst split-frontmatter).
local function body_text()
  local src = slurp(PANDOC_STATE.input_files[1]):gsub("\r\n", "\n")
  local _, e = src:find("^%-%-%-\n.-\n%-%-%-[ \t]*\n")
  if not e then error("nmb-adversary-complaint.lua: the sample must start with a YAML frontmatter block", 0) end
  return src:sub(e + 1)
end

-- Split on a literal separator (typst str.split).
local function split(s, sep)
  local out, pos = {}, 1
  while true do
    local a, b = s:find(sep, pos, true)
    if not a then out[#out + 1] = s:sub(pos); return out end
    out[#out + 1] = s:sub(pos, a - 1)
    pos = b + 1
  end
end

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number, as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function fix(inlines)
  local d = pandoc.Pandoc({ pandoc.Plain(inlines) })
  d = d:walk({ Str = breaks }):walk({ Inlines = bind_double_signs }):walk({ Inlines = xe.inlines })
  return d.blocks[1].content
end

-- Inline markdown as typst's cmarker reads it (CommonMark, smart punctuation).
local function md(s)
  local out = pandoc.Inlines({})
  for i, b in ipairs(pandoc.read(s, "commonmark+smart").blocks) do
    if b.t ~= "Para" and b.t ~= "Plain" then error("nmb-adversary-complaint.lua: not inline text: " .. s, 0) end
    if i > 1 then out:insert(pandoc.Space()) end
    out:extend(b.content)
  end
  return out
end

-- A paragraph's text with `[^n]` markers as footnotes whose text is in the frontmatter (typst with-notes); a space
-- after a marker is kept.
local function with_notes(s, notes)
  local out, pos, has = pandoc.Inlines({}), 1, false
  local function seg(t)
    if pos > 1 and t:match("^%s") then out:insert(pandoc.Space()) end
    out:extend(md(t))
  end
  while true do
    local a, b, n = s:find("%[%^(%d+)%]", pos)
    if not a then break end
    seg(s:sub(pos, a - 1))
    local text = notes[n]
    if text == nil then error("nmb-adversary-complaint.lua: footnote [^" .. n .. "] has no text in the frontmatter", 0) end
    out:insert(pandoc.Note({ pandoc.Para(fix(md(text))) }))
    has = true
    pos = b + 1
  end
  seg(s:sub(pos))
  return fix(out), has
end

-- ---------------------------------------------------------------------------
-- Paragraphs
-- ---------------------------------------------------------------------------

-- A paragraph of raw runs: o = { before, after, line, left, right, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.raw(xe.para(props, body))
end

-- A body paragraph pandoc writes (its footnotes native) in a style of reference.xml.
local function styled(inlines, style)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

local function str(v) return v == nil and "" or tostring(v) end

-- ---------------------------------------------------------------------------
-- Caption: single lines, each box one table row that is never split
-- ---------------------------------------------------------------------------

local function cell(w, pr, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' ..
    table.concat(paras) .. '</w:tc>'
end

local function tbl(widths, cells)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    table.concat(cells) .. '</w:tr></w:tbl>')
end

-- A line of a caption cell (raw XML, not a block).
local function line(text, o)
  o = o or {}
  local props = { xe.spacing(o.before or 0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc(o.jc or "left") }
  return xe.para(props, text == "" and "" or xe.runs(text, o))
end

-- A box ruled on `sides` (top, right, bottom, left), its text CAP_PAD inside the rules; the case column beside it.
local function caption_box(left, right, sides)
  local borders, mar = {}, {}
  for _, s in ipairs(sides) do
    borders[#borders + 1] = '<w:' .. s .. ' ' .. RULE .. '/>'
    local pad = (s == "top" or s == "bottom") and CAP_PAD - CAP_RULE or CAP_PAD
    mar[#mar + 1] = '<w:' .. s .. ' w:w="' .. pad .. '" w:type="dxa"/>'
  end
  local pr = '<w:tcBorders>' .. table.concat(borders) .. '</w:tcBorders><w:tcMar>' .. table.concat(mar) .. '</w:tcMar>'
  return tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    cell(CAP_LEFT, pr, left), cell(CAP_GUTTER, nil, { line("") }), cell(TEXTW - CAP_LEFT - CAP_GUTTER, nil, right) })
end

local function caption(meta)
  local out = {}
  local court = list(meta.court)
  for i, l in ipairs(court) do
    -- the caption a single line below the court
    out[#out + 1] = p(xe.runs(str(l), { b = true }), { jc = "center", keep = true, after = i == #court and SINGLE or 0 })
  end
  local debtor = {}
  for _, l in ipairs(list(meta.debtor)) do debtor[#debtor + 1] = line(str(l)) end
  -- the debtor's lines in the left half, the case number at the right of the first
  local parties = list(meta.parties)
  out[#out + 1] = tbl({ TEXTW // 2, TEXTW // 2 }, {
    cell(TEXTW // 2, nil, debtor), cell(TEXTW // 2, nil, { line(str(meta.case_number), { jc = "right" }) }) })
  -- the parties box a single line below
  out[#out + 1] = p("", { line = 2, after = SINGLE - 2 })
  local left = {}
  for k, x in ipairs(parties) do
    if k > 1 then left[#left + 1] = line("") end
    left[#left + 1] = line(str(x.names))
    left[#left + 1] = line(str(x.role))
  end
  local side = {}
  for _ = 1, (#left - 1) // 2 do side[#side + 1] = line("") end
  side[#side + 1] = line(str(meta.adv_number))
  out[#out + 1] = caption_box(left, side, { "bottom", "right" })
  -- the title a double line below the caption, the body a double line below the title
  out[#out + 1] = p(xe.runs(str(meta.title), { b = true }), { jc = "center", before = BODY, after = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature (NM LBR 9011-1(a))
-- ---------------------------------------------------------------------------

local function signature(s)
  local out = {}
  local function add(text, o)
    o = o or {}
    out[#out + 1] = p(xe.runs(text, { b = o.b }), { left = SIG_LEFT, before = o.before or 0, keep = true })
  end
  add("Respectfully Submitted,", { before = BODY })
  add(str(s.firm), { b = true, before = SINGLE })
  add("By: " .. string.rep("_", SIG_RULE), { before = BODY })
  add(str(s.signer))
  for _, l in ipairs(list(s.lines)) do add(str(l)) end
  add(str(s.email))
  add(str(s.role))
  -- the last line ends the chain
  local last = out[#out].text:gsub("<w:keepNext/>", "", 1)
  out[#out] = xe.raw(last)
  return out
end

-- ---------------------------------------------------------------------------
-- Footer and section
-- ---------------------------------------------------------------------------

local function field(name)
  local r = '<w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr>'
  return '<w:r>' .. r .. '<w:fldChar w:fldCharType="begin"/></w:r><w:r>' .. r ..
    '<w:instrText xml:space="preserve"> ' .. name .. ' </w:instrText></w:r><w:r>' .. r ..
    '<w:fldChar w:fldCharType="separate"/></w:r><w:r>' .. r .. '<w:t>1</w:t></w:r><w:r>' .. r ..
    '<w:fldChar w:fldCharType="end"/></w:r>'
end

local function footer(title)
  local o = { sz = 20 }
  return xe.para({ '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>', xe.spacing(0, 0, NOTE),
    xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs(title .. "\tPage ", o) .. field("PAGE") .. xe.runs(" of ", o) .. field("NUMPAGES"))
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="' .. FOOTER_ID .. '"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/>' ..
  '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>' ..
  '</w:sectPr>'

local function write_file(var, text)
  local path = os.getenv(var)
  if not path then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

function Pandoc(_)
  local meta = read_meta()
  local notes = meta.footnotes or {}
  local out = caption(meta)

  -- the lead-in, unnumbered, a double line below the title (the title's space after)
  local inl, note = with_notes(str(meta.lead_in), notes)
  out[#out + 1] = styled(inl, note and "Body Text Note" or "Body Text")

  local para, letter = 0, 0
  local chunks = split(body_text(), "\n\n")
  for _, chunk in ipairs(chunks) do
    local t = trim(chunk)
    if t ~= "" then
      local hashes, htext = t:match("^(#+)%s+(.*)$")
      if hashes then
        -- a heading: centered and bold at the body pitch, kept with the next block
        letter = 0
        out[#out + 1] = p(xe.inl(fix(md(htext)), { b = true }), { line = BODY, jc = "center", keep = true })
      elseif t:sub(1, 1) == ">" then
        -- a block quotation: single-spaced, 0.75 in in on both sides, a single line above and below each paragraph
        letter = 0
        local lines = {}
        for _, l in ipairs(split(t, "\n")) do lines[#lines + 1] = (l:gsub("^>%s?", "")) end
        local inner = table.concat(lines, "\n")
        for _, q in ipairs(split((inner:gsub("\n[ \t]*\n", "\n\n")), "\n\n")) do
          q = trim(q)
          if q ~= "" then
            out[#out + 1] = p(xe.inl(fix(md(q))), { left = QUOTE, right = QUOTE, before = SINGLE, after = SINGLE })
          end
        end
      elseif chunk:match("^[ \t]+%d+%.%s+") then
        -- an indented list item: a lettered sub-item of the numbered paragraph before it
        letter = letter + 1
        local rest = trim(chunk:gsub("^[ \t]+%d+%.%s+", "", 1))
        local x = with_notes(rest, notes)
        local l = pandoc.Inlines({ pandoc.Str("(" .. LETTERS:sub(letter, letter) .. ")"),
          pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        l:extend(x)
        out[#out + 1] = styled(l, "Sub Item")
      else
        letter = 0
        local rest = t:match("^%d+%.%s+(.*)$")
        local x, has
        if rest then
          -- a numbered paragraph, renumbered from 1
          para = para + 1
          x, has = with_notes(rest, notes)
          table.insert(x, 1, pandoc.Space())
          table.insert(x, 1, pandoc.Str(para .. "."))
        else
          x, has = with_notes(t, notes)
        end
        out[#out + 1] = styled(x, has and "Body Text Note" or "Body Text")
      end
    end
  end

  -- the prayer, kept whole with the signature block
  out[#out + 1] = styled((with_notes(str(meta.prayer), notes)), "Body Text Keep")
  for _, x in ipairs(signature(meta.signature or {})) do out[#out + 1] = x end

  write_file("FORMBOOK_FOOTERS", FOOTER_ID .. "\t" .. footer(str(meta.footer_title)) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)
  -- No metadata in the output: the title is printed in the caption, not as a Title paragraph.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

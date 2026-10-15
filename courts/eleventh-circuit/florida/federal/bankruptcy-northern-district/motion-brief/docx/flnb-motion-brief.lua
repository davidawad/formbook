-- flnb-motion-brief.lua (docx engine): the flnb motion with incorporated memorandum as Word paragraphs (typst: typst/flnb-motion-brief.typ).
-- pandoc writes the body text with docx/reference.docx (headings, footnotes, paragraphs). This filter writes what the
-- typst template lays out with its own blocks, as paragraphs and one borderless table with explicit spacing:
--   * the caption: the court (centred, capitals), the debtor case style and numbers, the adversary case style and numbers;
--   * the title (centred, bold) and the signature block (indented 0.45 of the text width), at the end of the body.
-- The spacers are the measured gaps of the typst render (docs/DOCX.md); the title, caption and signature are not
-- case-specific here: every word comes from the sample's frontmatter.

local stringify = pandoc.utils.stringify

-- Twentieths of a point (twips). Line pitch of single-spaced lines, of the body, and the gaps the typst render has.
local SINGLE = 308          -- 15.4 pt: 1.1 em at 14 pt
local SPACER_BLOCK = 756    -- 37.8 pt: between the court, the caption, the title and the body (typst v(1.5em) and stacks)
local SPACER_CASE = 616     -- 30.8 pt: between the debtor and the adversary case style
local TEXT_W = 9360         -- 6.5 in
local CASE_W = 5806         -- 62% of the text width (typst grid column)
local GUTTER_W = 280        -- 1 em
local RIGHT_W = TEXT_W - CASE_W - GUTTER_W
local SIG_LEFT = 4212       -- 45% of the text width (typst pad)

-- ---------------------------------------------------------------------------
-- XML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- One single-spaced paragraph (exact pitch), optionally centred, indented or bold.
local function para(text, o)
  o = o or {}
  local ppr = o.keep and "<w:keepNext />" or ""
  ppr = ppr .. string.format('<w:spacing w:before="0" w:after="0" w:line="%d" w:lineRule="exact" />', o.line or SINGLE)
  -- the indent: 0 unless the paragraph is set in from the left (the signature)
  ppr = ppr .. string.format('<w:ind w:left="%d" w:firstLine="0" />', o.left or 0)
  if o.jc then ppr = ppr .. string.format('<w:jc w:val="%s" />', o.jc) end
  local run = ""
  if text ~= "" then
    local rpr = o.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
    run = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. run .. "</w:p>"
end

-- An empty paragraph of a given height in twips (the vertical gaps of the typst layout).
local function spacer(h)
  return para("", { line = h })
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function lines_of(list)
  local out = {}
  for _, v in ipairs(list or {}) do out[#out + 1] = stringify(v) end
  return out
end

local function lines_xml(items, o)
  local out = {}
  for _, t in ipairs(items) do out[#out + 1] = para(t, o) end
  return table.concat(out)
end

-- A borderless two-part table: the case style on the left, its numbers on the right of a one-em gutter.
local function case_table(left, right)
  local none = '<w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" />'
  local function cell(w, xml)
    return string.format('<w:tc><w:tcPr><w:tcW w:w="%d" w:type="dxa" /></w:tcPr>%s</w:tc>', w, xml)
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa" /><w:tblBorders>' .. none
    .. '</w:tblBorders><w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="0" w:type="dxa" />'
    .. '<w:right w:w="0" w:type="dxa" /></w:tblCellMar><w:tblLook w:val="0000" /></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. CASE_W .. '" /><w:gridCol w:w="' .. GUTTER_W .. '" /><w:gridCol w:w="' .. RIGHT_W .. '" /></w:tblGrid>'
    .. '<w:tr>' .. cell(CASE_W, lines_xml(left)) .. cell(GUTTER_W, para(""))
    .. cell(RIGHT_W, lines_xml(right)) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Caption, title and signature
-- ---------------------------------------------------------------------------

local function caption(meta)
  local court = {}
  for _, t in ipairs(lines_of(meta.court)) do court[#court + 1] = t:upper() end
  local out = { lines_xml(court, { jc = "center" }), spacer(SPACER_BLOCK) }
  out[#out + 1] = case_table(lines_of(meta.debtor_style), lines_of(meta.debtor_numbers))
  out[#out + 1] = spacer(SPACER_CASE)
  out[#out + 1] = case_table(lines_of(meta.adversary_style), lines_of(meta.adversary_numbers))
  out[#out + 1] = spacer(SPACER_BLOCK)
  out[#out + 1] = lines_xml(lines_of(meta.title_lines), { jc = "center", bold = true })
  out[#out + 1] = spacer(SPACER_BLOCK)
  return raw(table.concat(out))
end

-- The signature block is kept together with the line before it (keep with next), so it never stands alone on a page.
local function signature(meta)
  local items = lines_of(meta.signature)
  local out = { para("", { line = SPACER_BLOCK, keep = true }) }
  for i, t in ipairs(items) do out[#out + 1] = para(t, { left = SIG_LEFT, keep = i < #items }) end
  return raw(table.concat(out))
end
-- ---------------------------------------------------------------------------
-- Word count (LR 7.1(F)): the memorandum, plus the motion's own words when the motion has more than 500
-- ---------------------------------------------------------------------------

local WORD_LIMIT = 8000
local MOTION_WORDS_THRESHOLD = 500

-- Words of a list of blocks; a paragraph number ("1." or "1)") is not a word.
local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    for w in stringify(b):gmatch("%S+") do
      if not w:match("^%d+[%.%)]$") then n = n + 1 end
    end
  end
  return n
end

local function is_header(b, prefix)
  return b.t == "Header" and b.level == 2 and stringify(b):sub(1, #prefix) == prefix
end

local function memorandum_words(blocks)
  local motion, memo = {}, {}
  local state = "motion"
  for _, b in ipairs(blocks) do
    if state == "motion" and is_header(b, "MEMORANDUM OF LAW") then state = "memo" end
    if state == "memo" and is_header(b, "CERTIFICATION") then state = "after" end
    if state == "motion" then
      motion[#motion + 1] = b
    elseif state == "memo" then
      memo[#memo + 1] = b
    end
  end
  local words = count_words(memo)
  local motion_n = count_words(motion)
  if motion_n > MOTION_WORDS_THRESHOLD then words = words + motion_n end
  return words
end

-- ---------------------------------------------------------------------------
-- Document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local words = memorandum_words(doc.blocks)
  if words > WORD_LIMIT then
    error("flnb-motion-brief: memorandum of " .. words .. " words exceeds the " .. WORD_LIMIT .. "-word limit (LR 7.1(F))")
  end
  -- the word-count certificate states the computed count (the sample holds a placeholder)
  doc = doc:walk({
    Str = function(el)
      if el.text:find("{{MEMO_WORDS}}", 1, true) then
        el.text = el.text:gsub("{{MEMO_WORDS}}", tostring(words))
        return el
      end
    end,
  })

  -- the signature block goes after the WHEREFORE paragraph and before the certificates (LR 9013-1; LR 5.1(D));
  -- that paragraph is kept with the block
  local blocks = pandoc.List({ caption(meta) })
  local found = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and stringify(b) == "{{SIGNATURE}}" then
      found = found + 1
      local prev = blocks[#blocks]
      if prev and prev.t == "Para" then
        blocks[#blocks] = pandoc.Div({ prev }, { ["custom-style"] = "Body Text Keep Next" })
      end
      blocks:insert(signature(meta))
    else
      blocks:insert(b)
    end
  end
  if found ~= 1 then
    error("flnb-motion-brief: the sample must contain one {{SIGNATURE}} marker")
  end
  return pandoc.Pandoc(blocks, {})
end

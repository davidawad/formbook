-- Texas Court of Criminal Appeals, opening brief (TRAP 9.4, 9.5, 38.1, 70.3): the DOCX engine.
-- Mirrors typst/texcrimapp-opening-brief.typ with Word-native parts: the cover is a centered block in
-- the "Centered" and "Cover Title" styles; the front matter (identity, contents, index) is its own
-- section in lower-case roman; the body is the final section, numbered from 1. Single-spaced blocks
-- (headings, identity and signature blocks, dot-leader entries) use the "Single" style. Footnotes come
-- from pandoc. Every case word is read from the markdown frontmatter or body; nothing is case-specific here.

local BODY_START = "statement regarding oral argument"
local REQUIRED = { "case_number", "style_petitioner", "style_respondent", "filing_party", "brief_title",
  "appeal_from", "lead_counsel", "counsel_lines" }

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a block's text without its footnotes
local function body_text(b)
  return text_of(b:walk({ Note = function() return {} end }))
end

-- single-spaced: a hard line break (identity, signature, certificate blocks), a dot leader
-- (contents and index entries), or a paragraph that opens with bold (identity labels)
local function is_single(b)
  if b.t ~= "Para" then return false end
  local hard = false
  b:walk({ LineBreak = function() hard = true end, Note = function() return {} end })
  if hard then return true end
  if body_text(b):find("....", 1, true) then return true end
  return b.content[1] ~= nil and b.content[1].t == "Strong"
end

local function styled(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if is_single(b) then
      out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Single" }))
    else
      out[#out + 1] = b
    end
  end
  return out
end

local function centered(inl, style)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style or "Centered" }))
end

-- vertical space of pt points, as an exact-height empty centered paragraph
local function gap(pt)
  return pandoc.RawBlock("openxml", string.format(
    '<w:p><w:pPr><w:pStyle w:val="Centered"/><w:spacing w:before="0" w:after="0" w:line="%d" w:lineRule="exact"/></w:pPr></w:p>',
    math.floor(pt * 20 + 0.5)))
end

-- ends a section: footer is a footer part id (nil = no footer), fmt and start set the page numbers
local function section_break(footer, fmt, start)
  local refs = footer and ('<w:footerReference w:type="default" r:id="' .. footer .. '"/>') or ""
  local num = ""
  if fmt or start then
    num = "<w:pgNumType" .. (fmt and (' w:fmt="' .. fmt .. '"') or "") .. (start and (' w:start="' .. start .. '"') or "") .. "/>"
  end
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>'
    .. refs .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. num .. "</w:sectPr></w:pPr></w:p>")
end

local function S(v) return pandoc.Str(text_of(v)) end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs(REQUIRED) do
    if meta[k] == nil then error("texcrimapp opening brief: frontmatter field `" .. k .. "` is missing", 0) end
  end
  local start
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and text_of(b.content):lower():match("^%s*(.-)%s*$") == BODY_START then
      start = i
      break
    end
  end
  if not start then error("texcrimapp opening brief: the body must start with the heading `# Statement Regarding Oral Argument`", 0) end

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover (TRAP 9.4 cover contents): case number, court, parties, title, filing party, counsel, date
  add(gap(28.8))
  add(centered({ pandoc.Strong({ S(meta.case_number) }) }))
  add(gap(14.4))
  add(centered({ pandoc.Strong({ pandoc.Str("IN THE COURT OF CRIMINAL APPEALS OF TEXAS") }) }))
  add(gap(21.6))
  add(centered({ pandoc.Strong({ S(meta.style_petitioner) }) }))
  add(gap(5.76))
  add(centered({ pandoc.Str("v.") }))
  add(gap(5.76))
  add(centered({ pandoc.Strong({ S(meta.style_respondent) }) }))
  add(gap(14.4))
  add(centered({ S(meta.appeal_from) }))
  add(gap(23.04))
  add(centered({ pandoc.Str(string.upper(text_of(meta.brief_title))) }, "Cover Title"))
  add(gap(25.2))
  add(centered({ S(meta.filing_party) }))
  add(gap(8.64))
  local counsel = { S(meta.lead_counsel) }
  for _, line in ipairs(meta.counsel_lines) do
    counsel[#counsel + 1] = pandoc.LineBreak()
    counsel[#counsel + 1] = S(line)
  end
  add(centered(counsel))
  if meta.filed_date then
    add(gap(18))
    add(centered({ S(meta.filed_date) }))
  end
  add(section_break(nil))

  -- front matter: identity, contents, index (roman numerals)
  for _, b in ipairs(styled({ table.unpack(doc.blocks, 1, start - 1) })) do add(b) end
  add(section_break("rId101", "lowerRoman", 1))

  -- body: from page 1 (the final section of reference.docx)
  for _, b in ipairs(styled({ table.unpack(doc.blocks, start) })) do add(b) end

  return pandoc.Pandoc(out, meta)
end

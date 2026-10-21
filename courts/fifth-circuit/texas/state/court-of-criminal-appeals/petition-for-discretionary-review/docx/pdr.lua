-- Texas Court of Criminal Appeals, petition for discretionary review (TRAP 9.4, 9.5, 68.3-68.4): the DOCX engine.
-- Mirrors typst/texcrimapp-petition-for-discretionary-review.typ with Word-native parts: the cover is a
-- centered block in the "Centered" and "Cover Title" styles and its own section without a page number; the
-- rest is the final section, numbered from 1. Single-spaced blocks (headings, signature and address blocks,
-- dot-leader entries) use the "Single" style. Footnotes come from pandoc. Every case word is read from the
-- markdown frontmatter or body; nothing is case-specific here.

local REQUIRED = { "case_number", "style_petitioner", "style_respondent", "filing_party", "brief_title",
  "appeal_from", "lead_counsel", "counsel_lines" }

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function body_text(b)
  return text_of(b:walk({ Note = function() return {} end }))
end

-- single-spaced: a hard line break (signature and address blocks) or a dot leader (contents, index entries)
local function is_single(b)
  if b.t ~= "Para" then return false end
  local hard = false
  b:walk({ LineBreak = function() hard = true end, Note = function() return {} end })
  if hard then return true end
  return body_text(b):find("....", 1, true) ~= nil
end

-- A table-of-contents or index entry, "title ..... page": the typed dots only mark it. It becomes the title, a tab
-- and the page reference in the "Leader Entry" style, whose right tab draws the leader, so the reference stays on
-- the title's last line and a long title wraps under a hanging indent (DEF-TOC-001). nil when b is not one.
local function leader_entry(b)
  if b.t ~= "Para" then return nil end
  local inl = b.content
  local at
  for i = #inl, 1, -1 do
    if inl[i].t == "Str" and inl[i].text:match("^%.%.%.%.+$") then at = i; break end
  end
  if not at or at == 1 or at == #inl then return nil end
  local title, page = pandoc.Inlines {}, pandoc.Inlines {}
  for i = 1, at - 1 do title:insert(inl[i]) end
  for i = at + 1, #inl do page:insert(inl[i]) end
  while #title > 0 and title[#title].t == "Space" do title:remove(#title) end
  while #page > 0 and page[1].t == "Space" do page:remove(1) end
  if #title == 0 or #page == 0 then return nil end
  title:insert(pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
  title:extend(page)
  return pandoc.Div({ pandoc.Para(title) }, pandoc.Attr("", {}, { ["custom-style"] = "Leader Entry" }))
end

local function styled(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    local entry = leader_entry(b)
    if entry then
      out[#out + 1] = entry
    elseif is_single(b) then
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

local function gap(pt)
  return pandoc.RawBlock("openxml", string.format(
    '<w:p><w:pPr><w:pStyle w:val="Centered"/><w:spacing w:before="0" w:after="0" w:line="%d" w:lineRule="exact"/></w:pPr></w:p>',
    math.floor(pt * 20 + 0.5)))
end

local function section_break(footer)
  local refs = footer and ('<w:footerReference w:type="default" r:id="' .. footer .. '"/>') or ""
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>'
    .. refs .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. "</w:sectPr></w:pPr></w:p>")
end

local function S(v) return pandoc.Str(text_of(v)) end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs(REQUIRED) do
    if meta[k] == nil then error("texcrimapp petition: frontmatter field `" .. k .. "` is missing", 0) end
  end

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover (TRAP 9.4 cover contents): court, case number, parties, title, filing party, counsel, date
  add(gap(28.8))
  add(centered({ pandoc.Strong({ pandoc.Str("IN THE COURT OF CRIMINAL APPEALS OF TEXAS") }) }))
  add(gap(21.6))
  add(centered({ pandoc.Str("No. "), S(meta.case_number) }))
  add(gap(14.4))
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

  -- body: from page 1 (the final section of reference.docx)
  for _, b in ipairs(styled(doc.blocks)) do add(b) end

  return pandoc.Pandoc(out, meta)
end

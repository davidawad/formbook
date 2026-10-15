-- Complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a pleading-paper Word document on reference.docx,
-- laid out as typst/waed-complaint.typ (LCivR 10(a), 10(d); Fed. R. Civ. P. 10(a), (b)). The cover, caption and
-- signature block are OpenXML (pleading.lua, shared helpers). The body keeps its markdown structure with the paragraph
-- styles of reference.docx. Numbered paragraphs get their number typed (as the typst counter does) and lettered lists
-- become A., B., ... Content-agnostic: every case word comes from the sample's frontmatter.

local SCRIPT_DIR = PANDOC_SCRIPT_FILE:match("^(.*/)") or "./"
local P = dofile(SCRIPT_DIR .. "pleading.lua")

-- a numbered paragraph (Fed. R. Civ. P. 10(b)): the number, a tab to 1 in, then the text
local function numbered(n, content)
  local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Numbered" }))
end

-- a lettered list item (typst: A., B., ...): the letter, a tab, then the item
local function lettered(i, blocks)
  local out = {}
  local first = blocks[1]
  local content = (first and (first.t == "Para" or first.t == "Plain")) and first.content or pandoc.List({})
  local inl = pandoc.List({ pandoc.Str(string.char(64 + i) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
  inl:extend(content)
  out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading List" }))
  for k = 2, #blocks do out[#out + 1] = blocks[k] end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local date = meta.date
  doc.meta.date = nil
  doc.meta.title = nil

  -- the cover: counsel, court title (upper case, as typst), one blank line, the caption with the case number,
  -- the title of the paper and the jury line at right
  local right = {
    { inl = { pandoc.Str("Case No. " .. P.plain(meta.case_number or "")) } },
    { spacer = true },
    { inl = P.minl(meta.brief_title), bold = true },
  }
  if meta.jury_demand then
    right[#right + 1] = { spacer = true }
    right[#right + 1] = { inl = { pandoc.Str("DEMAND FOR JURY TRIAL") }, bold = true }
  end
  local cover = { P.counsel_xml(meta.counsel or {}),
    P.PX({ pandoc.Str("UNITED STATES DISTRICT COURT") }, "PleadingCentered"),
    P.PX({ pandoc.Str("EASTERN DISTRICT OF WASHINGTON") }, "PleadingCentered") }
  if meta.division then
    cover[#cover + 1] = P.PX({ pandoc.Str(P.plain(meta.division):upper()) }, "PleadingCentered")
  end
  cover[#cover + 1] = '<w:p><w:pPr><w:pStyle w:val="PleadingCentered"/></w:pPr></w:p>'
  cover[#cover + 1] = P.caption_xml(meta, right)
  local out = { pandoc.RawBlock("openxml", table.concat(cover)) }

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        for _, e in ipairs(b.content) do if e.t == "Str" then e.text = e.text:upper() end end
      end
      out[#out + 1] = b
    elseif b.t == "Para" then
      n = n + 1
      out[#out + 1] = numbered(n, b.content)
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        for _, blk in ipairs(lettered(i, item)) do out[#out + 1] = blk end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, blk in ipairs(item) do out[#out + 1] = blk end
      end
    else
      out[#out + 1] = b
    end
  end

  -- the signature block: the date, "Respectfully submitted," the firm, "/s/" and the signer, then the signer's lines
  local sig = meta.signature
  local items = P.signature_items(sig, {}, true)
  items[#items + 1] = { inl = { pandoc.Str("/s/ " .. P.plain(sig.signer)) } }
  items[#items + 1] = { inl = P.minl(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do items[#items + 1] = { inl = P.minl(l) } end
  out[#out + 1] = pandoc.RawBlock("openxml", P.signature_xml(date, items))
  doc.blocks = out
  return doc
end

-- Adversary complaint, DOCX engine (docs/DOCX.md). The markdown contract -> a Word document on reference.docx,
-- mirroring orb-adversary-complaint.typ: the cover and caption (orb-common.lua), the lead-in, numbered allegations
-- (FRCP 10(b) through FRBP 7010; the number is typed, as the typst counter does), level 1 headings in capitals,
-- unnumbered "~" paragraphs (the WHEREFORE lead-in), lettered prayer items (A., B., ...), the signature block.
local DIR = PANDOC_SCRIPT_FILE:match("^(.*)[/\\]") or "."
local C = dofile(DIR .. "/orb-common.lua")
local LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

-- a paragraph written "~ text" (unnumbered; the marker is dropped)
local function is_tilde(b)
  local f, s = b.content[1], b.content[2]
  return f ~= nil and f.t == "Str" and f.text == "~" and s ~= nil and s.t == "Space"
end

local function drop_tilde(inl)
  local out = pandoc.List()
  for i = 3, #inl do out:insert(inl[i]) end
  return out
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

function Pandoc(doc)
  local meta = doc.meta
  local date = meta.date
  -- pandoc would print date and subtitle as a title block; the date sits in the signature block and the subtitle in the caption
  doc.meta = pandoc.Meta({})

  local out = pandoc.List()
  out:insert(pandoc.RawBlock("openxml", C.cover(meta)))
  if meta.lead_in then
    out:insert(C.styled(C.minl(meta.lead_in), "Pleading Body"))
  end

  local n, letter = 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        b.content = pandoc.List({ pandoc.Str(pandoc.text.upper(pandoc.utils.stringify(b.content))) })
      end
      out:insert(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if is_tilde(b) then
        out:insert(C.styled(drop_tilde(b.content), "Pleading Body"))
      else
        n = n + 1
        local inl = pandoc.List({ pandoc.Str(n .. "."), TAB })
        inl:extend(b.content)
        out:insert(C.styled(inl, "Pleading Body"))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        letter = letter + 1
        local inl = pandoc.List({ pandoc.Str(LETTERS:sub(letter, letter) .. "."), TAB })
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then inl:extend(first.content) end
        out:insert(C.styled(inl, "Pleading Item"))
      end
    else
      out:insert(b)
    end
  end

  out:insert(pandoc.RawBlock("openxml", C.signature(meta, date)))
  doc.blocks = out
  return doc
end

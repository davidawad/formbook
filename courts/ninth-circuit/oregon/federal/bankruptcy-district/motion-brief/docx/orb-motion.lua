-- Motion with memorandum, DOCX engine (docs/DOCX.md). The markdown contract -> a Word document on reference.docx,
-- mirroring orb-motion-brief.typ: the cover and caption (orb-common.lua), the LBR 9013-1(b)(2) notice on its own page
-- start, unnumbered body paragraphs (the first-line indent), "~" paragraphs without the indent, numbered list items
-- (1., 2., ...), headings, the signature block, and the certificate of service on its own page.
local DIR = PANDOC_SCRIPT_FILE:match("^(.*)[/\\]") or "."
local C = dofile(DIR .. "/orb-common.lua")

-- a paragraph written "~ text" (no first-line indent; the marker is dropped)
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

-- the body blocks, in the order and with the styles of the typst body-text()
local function body(blocks, out, state)
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        b.content = pandoc.List({ pandoc.Str(pandoc.text.upper(pandoc.utils.stringify(b.content))) })
      end
      out:insert(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if is_tilde(b) then
        out:insert(C.styled(drop_tilde(b.content), "Pleading Flush"))
      else
        out:insert(C.styled(b.content, "Pleading Body"))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        state.item = state.item + 1
        local inl = pandoc.List({ pandoc.Str(tostring(state.item) .. "."), TAB })
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then inl:extend(first.content) end
        out:insert(C.styled(inl, "Pleading Item"))
      end
    else
      out:insert(b)
    end
  end
end

function Pandoc(doc)
  local meta = doc.meta
  local date = meta.date
  -- pandoc would print date and subtitle as a title block: the date sits in the signature block
  doc.meta = pandoc.Meta({})

  local out = pandoc.List()
  out:insert(pandoc.RawBlock("openxml", C.cover(meta)))

  -- LBR 9013-1(b)(2): the notice of motion precedes the substantive motion (its own paragraphs)
  if meta.notice then
    for _, b in ipairs(C.blocks_of(meta.notice)) do
      if b.t == "Para" or b.t == "Plain" then out:insert(C.styled(b.content, "Pleading Notice")) end
    end
  end

  local state = { item = 0 }
  body(doc.blocks, out, state)

  out:insert(pandoc.RawBlock("openxml", C.signature(meta, date)))

  if meta.certificate then
    out:insert(pandoc.RawBlock("openxml", C.page_break()))
    local cblocks = C.blocks_of(meta.certificate)
    local first = true
    for _, b in ipairs(cblocks) do
      if first and b.t == "Header" then
        -- the certificate's heading opens the page: no space above (the typst heading is a weak spacing)
        out:insert(pandoc.RawBlock("openxml", C.PX({ pandoc.Strong({ pandoc.Str(pandoc.text.upper(pandoc.utils.stringify(b.content))) }) }, "PleadingCertHeading")))
      else
        body({ b }, out, state)
      end
      first = false
    end
  end

  doc.blocks = out
  return doc
end

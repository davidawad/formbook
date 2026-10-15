-- Pandoc filter for the gasd complaint, engine docx. Same layout as typst/gasd-complaint.typ:
-- court title, caption, title, lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)), lettered prayer
-- items, signature block. Every case word comes from the sample's frontmatter, never from this file.
-- Page layout and styles live in reference.docx (make-reference.sh). See ../README.md, "Engines".

-- Frontmatter value -> inlines, keeping markdown emphasis (a MetaInlines is already a list of inlines).
local function ins(v)
  local out = pandoc.List{}
  if v == nil then return out end
  if type(v) == "table" and v.t == "MetaInlines" then
    for _, i in ipairs(v) do out:insert(i) end
  else
    out:insert(pandoc.Str(pandoc.utils.stringify(v)))
  end
  return out
end

-- Several frontmatter lines -> one paragraph of inlines, with a line break between them.
local function lines(list)
  local out = pandoc.List{}
  for i, l in ipairs(list) do
    if i > 1 then out:insert(pandoc.LineBreak()) end
    out:extend(ins(l))
  end
  return out
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Caption: a borderless three-column table (party column 3.1 in, ")" column 0.3 in, file number column).
local function cell(width, s)
  local run = s ~= "" and ('<w:r><w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>") or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>'
    .. '<w:p><w:pPr><w:pStyle w:val="Compact"/></w:pPr>' .. run .. "</w:p></w:tc>"
end

local function caption(meta)
  local rows = {}
  for _, r in ipairs(meta.caption.rows) do
    rows[#rows + 1] = "<w:tr>" .. cell(4464, pandoc.utils.stringify(r.left))
      .. cell(432, ")") .. cell(4464, pandoc.utils.stringify(r.right)) .. "</w:tr>"
  end
  local none = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
    .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
  return pandoc.RawBlock("openxml", '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. none
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4464"/><w:gridCol w:w="432"/><w:gridCol w:w="4464"/></w:tblGrid>'
    .. table.concat(rows) .. "</w:tbl>")
end

local function courtTitle(meta)
  local c = pandoc.List{
    pandoc.Str("IN THE UNITED STATES DISTRICT COURT"), pandoc.LineBreak(),
    pandoc.Str("SOUTHERN DISTRICT OF GEORGIA"),
  }
  if meta.division then
    c:insert(pandoc.LineBreak())
    c:insert(pandoc.Str(pandoc.utils.stringify(meta.division):upper()))
  end
  return styled("Court Title", c)
end

-- Top-level lists become paragraphs with the marker typed in: the prayer's items are lettered (a), (b)
-- with the marker at 0.5 in and the text at 0.9 in, as in typst's `set enum(numbering: "(a)")`.
-- "List Body" is double-spaced with a hanging indent; the marker is text, not Word numbering, so Word
-- cannot indent it differently.
local function bodyList(b)
  local out = pandoc.List{}
  for i, item in ipairs(b.content) do
    local marker = b.t == "OrderedList" and ("(" .. string.char(96 + i) .. ")") or "\u{2022}"
    for j, blk in ipairs(item) do
      if j == 1 and blk.t == "Plain" then
        local inl = pandoc.List{ pandoc.Str(marker), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        inl:extend(blk.content)
        out:insert(styled("List Body", inl))
      elseif blk.t == "Plain" then
        out:insert(styled("List Body", blk.content))
      else
        out:insert(blk)
      end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = pandoc.List{}

  out:insert(courtTitle(meta))
  out:insert(caption(meta))
  out:insert(styled("Case Title", ins(meta.title)))

  if meta.lead_in then
    out:insert(pandoc.Para(ins(meta.lead_in)))
  end

  -- Body: each paragraph is one numbered paragraph; headings, quotations and lists are not numbered.
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      local inl = pandoc.List{ pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
      inl:extend(b.content)
      out:insert(pandoc.Para(inl))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      out:extend(bodyList(b))
    else
      -- Headings and quotations (a quotation's own lists keep Word's numbers: the policy's "1. Covered Property").
      out:insert(b)
    end
  end

  -- Signature block (LR 11.1: counsel's name, address, telephone, State Bar number).
  local sig = meta.signature
  out:insert(styled("Signature Firm", ins(sig.firm)))
  for _, s in ipairs(sig.signers) do
    local inl = pandoc.List{ pandoc.Str("/s/ ") }
    inl:extend(ins(s.name))
    inl:insert(pandoc.LineBreak())
    inl:extend(lines(s.lines))
    out:insert(styled("Signature Block", inl))
  end
  out:insert(styled("Signature Block", lines(sig.address)))
  out:insert(styled("Signature Block", ins(sig["counsel-for"])))

  return pandoc.Pandoc(out)
end

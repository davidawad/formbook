-- Pandoc filter for the gasd memorandum of law (motion brief), engine docx. Same layout as
-- typst/gasd-motion-brief.typ: court title, caption, title, numbered headings (I. / A. / 1.), double-spaced
-- body, signature block, certificate of service on its own page (LR 5.1). Every case word comes from the
-- sample's frontmatter, never from this file. Page layout and styles live in reference.docx
-- (make-reference.sh). See ../README.md, "Engines".

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

-- Caption: a borderless three-column table (party column 3.1 in, ")" column 0.3 in, case number column).
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
    pandoc.Str("FOR THE SOUTHERN DISTRICT OF GEORGIA"),
  }
  if meta.division then
    c:insert(pandoc.LineBreak())
    c:insert(pandoc.Str(pandoc.utils.stringify(meta.division):upper()))
  end
  return styled("Court Title", c)
end

local function pageBreak()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }

-- Body text. Headings are numbered here, not typed in the sample: level 1 "I.", level 2 "A.", level 3 "1.".
-- Lists keep their own numbers in the markdown's order ("1." items), typed as text with a hanging indent.
local function body(doc)
  local out = pandoc.List{}
  local sec, sub, subsub = 0, 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local content = pandoc.List{}
      if b.level == 1 then
        sec, sub, subsub = sec + 1, 0, 0
        content:insert(pandoc.Str(ROMAN[sec] .. "."))
      elseif b.level == 2 then
        sub, subsub = sub + 1, 0
        content:insert(pandoc.Str(string.char(64 + sub) .. "."))
      else
        subsub = subsub + 1
        content:insert(pandoc.Str(subsub .. "."))
      end
      content:insert(pandoc.Space())
      content:extend(b.content)
      b.content = content
      out:insert(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local marker = b.t == "OrderedList" and (i .. ".") or "\u{2022}"
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
    else
      out:insert(b)
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

  out:extend(body(doc))

  -- Signature block (LR 11.1; the date line as in the exemplar).
  local sig = meta.signature
  if sig.date then
    out:insert(styled("Signature Date", pandoc.List{ pandoc.Str("This the " .. pandoc.utils.stringify(sig.date) .. ".") }))
  end
  out:insert(styled("Signature Block", pandoc.List{ pandoc.Str("Respectfully submitted,") }))
  for _, s in ipairs(sig.signers) do
    local inl = pandoc.List{ pandoc.Str("By: /s/ ") }
    inl:extend(ins(s.name))
    inl:insert(pandoc.LineBreak())
    inl:extend(ins(s.name))
    inl:insert(pandoc.LineBreak())
    inl:extend(lines(s.lines))
    out:insert(styled("Signature Signer", inl))
  end

  -- Certificate of service (LR 5.1): the caption again, the statement of service, the signature.
  local svc = meta.service
  out:insert(pageBreak())
  out:insert(courtTitle(meta))
  out:insert(caption(meta))
  out:insert(styled("Case Title", ins(meta.title)))

  local cert = pandoc.List{ pandoc.Str("I hereby certify that on " .. pandoc.utils.stringify(svc.date)
    .. ", I electronically filed the foregoing "), pandoc.Str(pandoc.utils.stringify(meta.title):upper()),
    pandoc.Str(" with the Clerk of Court using the CM/ECF system, which will send notification of such filing to counsel of record.") }
  if svc.unregistered then
    cert:insert(pandoc.Space())
    cert:insert(pandoc.Str("I further certify that I served a true and correct copy of the same on the following by First-Class Mail, postage prepaid, addressed to:"))
  end
  out:insert(pandoc.Para(cert))
  if svc.unregistered then
    for _, p in ipairs(svc.unregistered) do
      out:insert(styled("Address Block", lines(p)))
    end
  end

  local signer = pandoc.List{ pandoc.Str("/s/ ") }
  signer:extend(ins(svc.signer.name))
  signer:insert(pandoc.LineBreak())
  signer:extend(lines(svc.signer.lines))
  out:insert(styled("Signature Certificate", signer))

  return pandoc.Pandoc(out)
end

-- Bankr. N.D. Ga. adversary complaint, DOCX engine (docs/DOCX.md). The markdown contract (../README.md) -> Word on
-- reference.docx, built the way typst/ganb-adversary-complaint.typ builds the PDF: the first page (court title, caption,
-- rule, title, lead-in), the numbered allegations, the lettered prayer, the signature block and the certificate.
-- Paragraph numbers and prayer letters are typed into the text (as the typst template does), not Word list numbering.
-- Styles (reference.docx): Single, Centered, CaptionLine, Rule, Numbered, Signature, CertificateText, BodyText.

local LETTERS = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t" }
local CAPTION_WIDTHS = { 4896, 432, 4032 } -- 3.4 in party column, 0.3 in ")" column, the rest (text width 6.5 in)
local BOLD = "<w:b/><w:bCs/><w:caps/>" -- capitals by the All Caps property, so the citation text keeps its case

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  return v == nil and "" or pandoc.utils.stringify(v)
end

-- a metadata list as a Lua list of plain strings
local function strings(v)
  local out = {}
  for _, x in ipairs(v or {}) do out[#out + 1] = plain(x) end
  return out
end

local function run(text, rpr)
  local pr = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. pr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- one raw Word paragraph: its style, extra pPr children (spacing, after the style), and its runs
local function para(style, ppr, runs)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "")
    .. "</w:pPr>" .. (runs or "") .. "</w:p>")
end

local function spacing(before, after)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '"/>'
end

local function attr(style)
  return pandoc.Attr("", {}, { ["custom-style"] = style })
end

local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

-- markdown metadata (lead-in, certificate) as blocks
local function md_blocks(v)
  if v.t == "MetaBlocks" then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b end
    return out
  end
  return { pandoc.Para(v) }
end

-- page 1: court title, the blank-space gap for the filing stamp, the caption, a rule, the title
local function first_page(meta)
  local out = {}
  local lines = strings(meta.court_title)
  for i, l in ipairs(lines) do
    out[#out + 1] = para("Centered", i < #lines and spacing(0, 130) or nil, run(l, BOLD))
  end
  out[#out + 1] = para("Single", '<w:spacing w:before="0" w:after="0" w:line="576" w:lineRule="exact"/>')

  local rows = {}
  for _, r in ipairs(meta.caption or {}) do
    local cells = { plain(r[1]), ")", plain(r[2]) }
    local tcs = {}
    for c, text in ipairs(cells) do
      local runs = text ~= "" and run(text) or ""
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_WIDTHS[c] .. '" w:type="dxa"/></w:tcPr><w:p>'
        .. '<w:pPr><w:pStyle w:val="CaptionLine"/></w:pPr>' .. runs .. "</w:p></w:tc>"
    end
    rows[#rows + 1] = "<w:tr>" .. table.concat(tcs) .. "</w:tr>"
  end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>' .. none
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. CAPTION_WIDTHS[1] .. '"/><w:gridCol w:w="' .. CAPTION_WIDTHS[2]
    .. '"/><w:gridCol w:w="' .. CAPTION_WIDTHS[3] .. '"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>")

  out[#out + 1] = para("Rule")
  local title = strings(meta.title)
  for i, l in ipairs(title) do
    out[#out + 1] = para("Centered", spacing(i == 1 and 286 or 0, i == #title and 286 or 130),
      run(l, BOLD))
  end
  return out
end

-- signature block: the date line (optional), then the counsel lines in the right half of the page
local function signature(sig, dated)
  local out = {}
  local first = true
  if dated and sig.dated then
    out[#out + 1] = para("Single", spacing(312, 312), run(plain(sig.dated)))
    first = false
  end
  for _, l in ipairs(strings(sig.lines)) do
    out[#out + 1] = para("Signature", first and spacing(312, 130) or nil, run(l))
    first = false
  end
  return out
end

local function certificate(meta)
  if meta.certificate == nil then return {} end
  local out = { para("Centered", spacing(390, 156), run("CERTIFICATE OF SERVICE", BOLD)) }
  out[#out + 1] = pandoc.Div(md_blocks(meta.certificate), attr("CertificateText"))
  for _, b in ipairs(signature(meta.signature, false)) do out[#out + 1] = b end
  return out
end

-- Allegations: a paragraph is numbered 1, 2, ... except one beginning "WHEREFORE"; a list is lettered (a), (b), ...
local function allegations(blocks, out)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      if plain(b):match("^WHEREFORE") then
        out:insert(b)
      else
        n = n + 1
        local content = pandoc.List({ pandoc.Str(n .. "."), tab() })
        content:extend(b.content)
        out:insert(pandoc.Div({ pandoc.Para(content) }, attr("Numbered")))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local content = pandoc.List({ pandoc.Str("(" .. LETTERS[k] .. ")"), tab() })
          content:extend(first.content)
          out:insert(pandoc.Div({ pandoc.Para(content) }, attr("Numbered")))
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
  local out = pandoc.List()
  out:extend(first_page(meta))
  meta.title = nil -- the title of the paper is built on page 1 above, not by pandoc's title block
  if meta.lead_in ~= nil then
    out:extend(md_blocks(meta.lead_in))
  end
  allegations(doc.blocks, out)
  out:extend(signature(meta.signature, true))
  out:extend(certificate(meta))
  return pandoc.Pandoc(out, meta)
end

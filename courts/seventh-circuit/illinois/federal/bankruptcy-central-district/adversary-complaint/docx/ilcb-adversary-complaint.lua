-- ilcb adversary complaint, DOCX engine (docs/DOCX.md). Mirrors typst/ilcb-adversary-complaint.typ.
-- The court heading, the caption (a borderless three-column table), the title, the signature block and
-- the counsel lines are paragraphs in the custom styles of reference.docx (see build-reference.sh); the body
-- keeps its markdown structure. Page numbers come from the footer of reference.docx.
-- Not generated (as in the typst template): a table of contents, a table of authorities, a certificate.

local function attr(style)
  return pandoc.Attr("", {}, { ["custom-style"] = style })
end

local function styled(style, inls)
  return pandoc.Div({ pandoc.Para(inls) }, attr(style))
end

-- a metadata value (markdown inlines) as a list of inlines
local function as_inlines(v)
  if v == nil then return pandoc.List({}) end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" then return pandoc.List(v) end
  if ty == "string" then return pandoc.List({ pandoc.Str(v) }) end
  if ty == "Blocks" then return pandoc.List(pandoc.utils.blocks_to_inlines(v)) end
  return pandoc.List({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function with_prefix(prefix, inls)
  local out = pandoc.List({ pandoc.Str(prefix), pandoc.Space() })
  out:extend(inls)
  return out
end

-- the signature in "/s/ Name" form
local function slash_sig(v)
  local out = pandoc.List({ pandoc.Str("/s/"), pandoc.Space() })
  out:extend(as_inlines(v))
  return out
end

-- "(i) text" and "1) text" are lists to pandoc (hanging indent, its own tab stops). The template prints them
-- as ordinary paragraphs with the marker typed in, as the markdown has it (typst: plain text, first-line indent).
local ROMAN = {
  { 1000, "m" }, { 900, "cm" }, { 500, "d" }, { 400, "cd" }, { 100, "c" }, { 90, "xc" }, { 50, "l" },
  { 40, "xl" }, { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" },
}
local function roman(n)
  local s = ""
  for _, p in ipairs(ROMAN) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end
local function numeral(n, style)
  if style == "LowerRoman" then return roman(n) end
  if style == "UpperRoman" then return roman(n):upper() end
  if style == "LowerAlpha" then return string.char(96 + n) end
  if style == "UpperAlpha" then return string.char(64 + n) end
  return tostring(n)
end
local function flatten_list(el)
  local a = el.listAttributes
  local out = {}
  for i, item in ipairs(el.content) do
    local mark = numeral(a.start + i - 1, a.style)
    if a.delimiter == "TwoParens" then mark = "(" .. mark .. ")"
    elseif a.delimiter == "OneParen" then mark = mark .. ")"
    else mark = mark .. "." end
    local first = item[1]
    if first and (first.t == "Plain" or first.t == "Para") then
      local inls = pandoc.List({ pandoc.Str(mark), pandoc.Space() })
      inls:extend(first.content)
      out[#out + 1] = pandoc.Para(inls)
      for j = 2, #item do out[#out + 1] = item[j] end
    else
      out[#out + 1] = pandoc.Para({ pandoc.Str(mark) })
      for _, b in ipairs(item) do out[#out + 1] = b end
    end
  end
  return out
end

-- section and paragraph signs stay with the number after them (typst: no break inside "§ 548")
local function keep_marks(inls)
  local out = pandoc.List({})
  for i, el in ipairs(inls) do
    if el.t == "Space" and i > 1 and inls[i - 1].t == "Str" and inls[i - 1].text:match("^[§¶]+$") then
      out:insert(pandoc.Str("\u{00A0}"))
    else
      out:insert(el)
    end
  end
  return out
end

local function caption_table(cap)
  local left, right = cap.left or {}, cap.right or {}
  local n = math.max(#left, #right)
  local rows = {}
  for i = 1, n do
    local l = left[i] and as_inlines(left[i]) or pandoc.List({})
    local r = right[i] and as_inlines(right[i]) or pandoc.List({})
    rows[#rows + 1] = pandoc.Row({
      pandoc.Cell({ styled("CaptionCell", l) }),
      pandoc.Cell({ styled("CaptionParen", { pandoc.Str(")") }) }),
      pandoc.Cell({ styled("CaptionCell", r) }),
    })
  end
  -- widths as in the typst template: 3.4 in, 0.3 in, the rest of the 6.5 in text block
  local colspecs = {
    { pandoc.AlignDefault, 3.4 / 6.5 },
    { pandoc.AlignDefault, 0.3 / 6.5 },
    { pandoc.AlignDefault, 2.8 / 6.5 },
  }
  return pandoc.Table(pandoc.Caption(), colspecs, pandoc.TableHead(), { pandoc.TableBody(rows) }, pandoc.TableFoot())
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- the body: section signs kept with their numbers
  doc = doc:walk({ Inlines = keep_marks, OrderedList = flatten_list })

  -- first page: court, caption, title (typst court-heading, caption, title-block)
  add(styled("CenteredBold", { pandoc.Str("UNITED STATES BANKRUPTCY COURT") }))
  add(styled("CourtHeadEnd", { pandoc.Str("CENTRAL DISTRICT OF ILLINOIS") }))
  add(caption_table(meta.caption or {}))
  add(styled("TitleLine", as_inlines(meta.document_title)))

  -- body; the last paragraph is kept with the signature block
  local blocks = pandoc.List(doc.blocks)
  local last = blocks[#blocks]
  if last and last.t == "Para" then
    blocks[#blocks] = pandoc.Div({ last }, attr("BodyKeep"))
  end
  for _, b in ipairs(blocks) do add(b) end

  -- signature block (typst signature-block)
  local sig = meta.signature
  if meta.dated then add(styled("DatedLine", with_prefix("Dated:", as_inlines(meta.dated)))) end
  add(styled(meta.dated and "SigFirst" or "SigTop", { pandoc.Str("Respectfully submitted,") }))
  add(styled("SigGap", { pandoc.Strong(as_inlines(sig.firm)) }))
  add(styled("SigLine", with_prefix("By:", slash_sig(sig.signer))))
  add(styled("SigEnd", { pandoc.Str("One of Its Attorneys") }))
  local counsel = sig.counsel or {}
  for i, v in ipairs(counsel) do
    local style = "Single"
    if i == 1 then style = "CounselFirst"
    elseif i < #counsel then style = "CounselLine" end
    add(styled(style, as_inlines(v)))
  end

  doc.blocks = out
  return doc
end

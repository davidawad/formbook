-- cob (United States Bankruptcy Court, D. Colo.) motion with memorandum, DOCX engine (docs/DOCX.md).
-- The markdown contract -> a Word document on reference.docx, following typst/cob-motion-brief.typ: the court
-- title, the caption (debtor, then the adversary block when the frontmatter has one), the title in centered bold
-- capitals, the body (paragraphs with a 0.5 in first-line indent, "#" centered bold capitals headings, "##" and
-- "###" headings numbered I. and A., block quotations single spaced), the signature block, and the optional
-- certificate of service. Footnotes are pandoc's native footnotes. Page numbers come from the reference footer.
-- Only frontmatter-driven content: no case words live in this file.

local NBSP = pandoc.Str("\u{00A0}")

local function style(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

local function para(name, inl)
  return style(name, { pandoc.Para(inl) })
end

local function gap(name)
  return style(name, { pandoc.Para({ NBSP }) })
end

local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

local function label(s)
  return pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. s .. "</w:t></w:r>")
end

-- a frontmatter value (markdown inlines, a string, or blocks) as a List of inlines
local function inlines(v)
  if v == nil then return pandoc.List({}) end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" then return pandoc.List(v) end
  if ty == "Blocks" then return pandoc.List(pandoc.utils.blocks_to_inlines(v)) end
  return pandoc.List({ pandoc.Str(tostring(v)) })
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function upper_inl(inl)
  return pandoc.List(pandoc.Inlines(inl):walk({
    Str = function(s) return pandoc.Str(s.text:upper()) end,
  }))
end

local function txt(s) return pandoc.List({ pandoc.Str(s) }) end

-- a 1-row borderless table; each cell is a list of blocks; widths in inches of the 6.5 in text block
local function grid(widths, cells)
  local specs, row = {}, {}
  for i, w in ipairs(widths) do
    specs[i] = { pandoc.AlignDefault, w / 6.5 }
    row[i] = pandoc.Cell(cells[i])
  end
  return pandoc.Table(pandoc.Caption({}), specs, pandoc.TableHead({}),
    { pandoc.TableBody({ pandoc.Row(row) }) }, pandoc.TableFoot({}))
end

-- debtor block (left) and case number and chapter (right), typst caption-block(debtor)
local function debtor_caption(meta)
  local d = meta.debtor
  local left = { para("Single", txt("IN RE:")), gap("GapSmall") }
  for _, n in ipairs(d.names or {}) do left[#left + 1] = para("Single04", inlines(n)) end
  left[#left + 1] = gap("Single")
  left[#left + 1] = para("Single08", d.designation and inlines(d.designation) or txt("Debtor."))
  local right = { para("Single", txt("Case No. " .. plain(d.case_number))) }
  if d.chapter then right[#right + 1] = para("Single", inlines(d.chapter)) end
  return grid({ 3.6, 0.3, 2.6 }, { left, { pandoc.Para({ NBSP }) }, right })
end

-- adversary block: parties on the left, Adv. Proc. No. on the right
local function adversary_caption(meta)
  local adv = meta.adversary
  local left = {}
  for i, side in ipairs(adv.parties or {}) do
    for _, n in ipairs(side.names or {}) do left[#left + 1] = para("Single", inlines(n)) end
    left[#left + 1] = para("Single08", inlines(side.designation))
    if i < #adv.parties then left[#left + 1] = gap("GapSmall") end
  end
  local right = { para("Single", txt("Adv. Proc. No. " .. plain(adv.case_number))) }
  return grid({ 3.6, 0.3, 2.6 }, { left, { pandoc.Para({ NBSP }) }, right })
end

-- one signatory: firm lines, a gap, the "/s/" mark and signer, then the address lines (typst signature-block)
local function signature(meta)
  local sig = meta.signature
  local right = {}
  right[#right + 1] = para("Signature", txt("Respectfully submitted,"))
  right[#right + 1] = gap("GapHalf")
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = para("Signature", inlines(l)) end
  right[#right + 1] = gap("GapHalf")
  right[#right + 1] = para("Signature", txt("/s/ " .. plain(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = para("Signature", inlines(l)) end
  local left = { para("Signature", txt("Dated: " .. plain(meta.date))) }
  return grid({ 3.3, 3.2 }, { left, right })
end

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

-- heading labels as typst's heading-num: level 2 "I.", level 3 "A.", level 4 "1."; level 1 unnumbered.
-- A heading of any level steps its own counter and resets the deeper ones.
local function number_headings(blocks)
  local ctr = { 0, 0, 0, 0 }
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local L = b.level
      ctr[L] = ctr[L] + 1
      for k = L + 1, 4 do ctr[k] = 0 end
      if L == 2 then
        local inl = pandoc.List({ label(roman(ctr[2]) .. "."), tab() })
        inl:extend(b.content)
        out[#out + 1] = pandoc.Header(L, inl)
      elseif L == 3 then
        local inl = pandoc.List({ label(string.char(64 + ctr[3]) .. "."), tab() })
        inl:extend(b.content)
        out[#out + 1] = pandoc.Header(L, inl)
      elseif L == 4 then
        local inl = pandoc.List({ label(tostring(ctr[4]) .. "."), tab() })
        inl:extend(b.content)
        out[#out + 1] = pandoc.Header(L, inl)
      else
        out[#out + 1] = b
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- the caption page: court title, debtor caption, adversary caption, title
  for _, l in ipairs(meta.court or {}) do
    add(para("Centered", { pandoc.Strong(upper_inl(inlines(l))) }))
  end
  add(gap("GapCap"))
  add(debtor_caption(meta))
  if meta.adversary then
    add(gap("GapCap"))
    add(adversary_caption(meta))
  end
  add(gap("GapCap"))
  add(para("Centered", { pandoc.Strong(upper_inl(inlines(meta.title))) }))
  add(gap("GapCap"))

  for _, b in ipairs(number_headings(doc.blocks)) do add(b) end

  add(gap("GapFull"))
  add(signature(meta))

  if meta.certificate then
    local cert = meta.certificate
    add(gap("GapFull"))
    add(para("Centered", { pandoc.Strong(txt("CERTIFICATE OF SERVICE")) }))
    add(gap("GapHalf"))
    add(para("Body Text", inlines(cert.text)))
    add(gap("GapHalf"))
    add(grid({ 3.3, 3.2 }, {
      { para("Signature", txt("Dated: " .. plain(cert.date))) },
      { para("Signature", txt("/s/ " .. plain(cert.signer))) },
    }))
  end

  doc.meta = {}
  doc.blocks = out
  return doc
end

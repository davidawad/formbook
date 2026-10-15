-- cob (United States Bankruptcy Court, D. Colo.) adversary complaint, DOCX engine (docs/DOCX.md).
-- The markdown contract -> a Word document on reference.docx, following typst/cob-adversary-complaint.typ:
-- the court title, the adversary caption (FRBP 7010, Form 416D), the generated FRBP 7008(a) consent paragraph
-- (numbered paragraph 1), "#" centered bold caps headings, "%" centered single-spaced lines, "+" unnumbered
-- paragraphs, "1." items lettered (a), (b), numbered paragraphs, and the signature block(s).
-- Only frontmatter-driven content: no case words live in this file. Page numbers come from the reference footer.

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

local function cat(...)
  local out = pandoc.List({})
  for _, part in ipairs({ ... }) do out:extend(part) end
  return out
end

local function txt(s) return pandoc.List({ pandoc.Str(s) }) end

-- the FRBP 7008(a) statement, from `proceeding` and `consent` (typst consent-text)
local function consent_inlines(meta)
  local kind = plain(meta.proceeding) == "core" and "a core proceeding" or "a non-core proceeding"
  local verdict
  if plain(meta.consent) == "missing" then
    verdict = pandoc.List({ pandoc.Strong(txt("[FRBP 7008(a) CONSENT STATEMENT ABSENT FROM THE FILED COMPLAINT]")) })
  else
    verdict = txt("Plaintiff " .. plain(meta.consent) .. " to the entry of final orders or judgment by the bankruptcy judge.")
  end
  return cat(txt("This proceeding is " .. kind .. " under 28 U.S.C. § 157. "), verdict)
end

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

-- debtor block (left) and case number (right), typst caption-block(debtor)
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

-- adversary block (FRBP 7010): parties on the left, Adv. Proc. No. on the right; a blank number is a fill-in line
local function adversary_caption(meta)
  local adv = meta.adversary
  local left = {}
  for i, side in ipairs(adv.parties or {}) do
    for _, n in ipairs(side.names or {}) do left[#left + 1] = para("Single", inlines(n)) end
    left[#left + 1] = para("Single08", inlines(side.designation))
    if i < #adv.parties then left[#left + 1] = gap("GapSmall") end
  end
  local num = plain(adv.case_number)
  local right = { para("Single", txt("Adv. Proc. No. " .. (num ~= "" and num or string.rep("_", 18)))) }
  return grid({ 3.6, 0.3, 2.6 }, { left, { pandoc.Para({ NBSP }) }, right })
end

-- one signatory: firm lines, the mark and signer, then the address lines (typst sig-column)
local function sig_column(s, out)
  for _, l in ipairs(s.firm or {}) do out[#out + 1] = para("Signature", inlines(l)) end
  out[#out + 1] = gap("GapHalf")
  local mark = s.mark and plain(s.mark) or "/s/"
  local signer = plain(s.signer)
  if mark == "/s/" or mark:sub(1, 7) == "By: /s/" then
    out[#out + 1] = para("Signature", txt(mark .. " " .. signer))
  else
    out[#out + 1] = para("Signature", txt(mark))
    out[#out + 1] = para("Signature", txt(signer))
  end
  for _, l in ipairs(s.lines or {}) do out[#out + 1] = para("Signature", inlines(l)) end
  return out
end

local function signature(meta)
  local sig = meta.signature
  local right = {}
  if sig.lead ~= false then
    right[#right + 1] = para("Signature", txt("Respectfully submitted,"))
    right[#right + 1] = gap("GapHalf")
  end
  sig_column(sig, right)
  for _, extra in ipairs(sig.also or {}) do
    right[#right + 1] = gap("GapFull")
    sig_column(extra, right)
  end
  local left = { para("Signature", txt("Dated: " .. plain(meta.date))) }
  return grid({ 3.3, 3.2 }, { left, right })
end

-- "+" marks an unnumbered paragraph, "%" a centered single-spaced sub-caption (typst conventions)
local function starts_with(b, ch)
  if b.t ~= "Para" then return false end
  local first = b.content[1]
  return first ~= nil and first.t == "Str" and first.text:sub(1, #ch) == ch
end

local function strip_marker(inl, ch)
  local out = pandoc.List({})
  for i, el in ipairs(inl) do
    if i == 1 and el.t == "Str" and el.text:sub(1, #ch) == ch then
      if #el.text > #ch then out:insert(pandoc.Str(el.text:sub(#ch + 1))) end
    else
      out:insert(el)
    end
  end
  return out
end

local function letter(i) return string.char(96 + i) end

local function softbreaks(inl)
  return pandoc.List(pandoc.Inlines(inl):walk({
    SoftBreak = function() return pandoc.LineBreak() end,
  }))
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
  add(gap("GapCap"))
  add(adversary_caption(meta))
  add(gap("GapCap"))
  add(para("Centered", { pandoc.Strong(upper_inl(inlines(meta.title))) }))
  add(gap("GapCap"))

  local n = 0
  local consent_done = false
  local function consent()
    n = n + 1
    add(style("Numbered", { pandoc.Para(cat({ label(n .. "."), tab() }, consent_inlines(meta))) }))
  end

  for _, b in ipairs(doc.blocks) do
    -- the FRBP 7008(a) statement is paragraph 1: it follows the unnumbered opening and precedes the first other block
    if not consent_done and not starts_with(b, "+") then
      consent_done = true
      consent()
    end
    if starts_with(b, "+") then
      add(para("Body Text", strip_marker(b.content, "+")))
    elseif starts_with(b, "%") then
      add(para("Centered", softbreaks(strip_marker(b.content, "%"))))
    elseif b.t == "Para" then
      n = n + 1
      add(style("Numbered", { pandoc.Para(cat({ label(n .. "."), tab() }, b.content)) }))
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        if i > 1 then add(gap("GapItem")) end
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          add(style("ListItem", { pandoc.Para(cat({ label("(" .. letter(i) .. ")"), tab() }, first.content)) }))
          for j = 2, #item do add(item[j]) end
        else
          for _, x in ipairs(item) do add(x) end
        end
      end
    else
      add(b)
    end
  end
  if not consent_done then consent() end

  add(gap("GapFull"))
  add(signature(meta))

  doc.meta = {}
  doc.blocks = out
  return doc
end

-- First Circuit brief, DOCX engine (mirrors ../typst/ca1-opening-brief.typ and ../latex/ca1.lua). Pandoc filter:
-- the cover, contents and authorities, certificates and addendum are paragraphs in the custom styles of
-- reference.docx (make-reference.sh); headings and citations come from the markdown; sections carry the
-- roman, arabic and "Add-N" page numbers. Gaps (see docs/DOCX.md and README.md, "Engines"): the contents and
-- authorities list no page numbers (they need a first-pass layout, and no LibreOffice is available here to
-- make one), and point headings are Heading 2 (left) rather than centered small capitals.
-- Per-folder settings: the word limit and whether an addendum is required (as in the latex engine).

local WORD_LIMIT = 13000          -- FRAP 32(a)(7)(B)(i) principal brief (reply: 6500)
local ADDENDUM = "required"       -- 1st Cir. R. 28.0(a)(1) for the appellant's brief; "optional" in the others
local TOA_GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}
local SECT = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local ROMAN_VALUES = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
  { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }

local authorities = {}
local hits = {}
local counters = { 0, 0, 0, 0, 0 }
local inarg = false
local addlist = {}
local tocitems = {}

local function str(x)
  return pandoc.utils.stringify(x)
end

-- Frontmatter value as a list of inlines (a plain string or a MetaInlines).
local function inl(x)
  if x == nil then return {} end
  if type(x) == "string" then return { pandoc.Str(x) } end
  return x
end

local function append(list, items)
  for _, x in ipairs(items) do list[#list + 1] = x end
  return list
end

local function ooxml(s)
  return pandoc.RawBlock("openxml", s)
end

local function styled(style, blocks)
  return pandoc.Div(blocks, { ["custom-style"] = style })
end

local function para(items)
  return pandoc.Para(items)
end

-- A section break: the paragraph's sectPr ends the section it is in. footer: relationship id in document.xml.rels.
local function sect(footer, fmt, start)
  local fr = footer and ('<w:footerReference w:type="default" r:id="' .. footer .. '"/>') or ""
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or ""
  return ooxml('<w:p><w:pPr><w:sectPr>' .. fr .. pg .. SECT .. '</w:sectPr></w:pPr></w:p>')
end

local function pagebreak()
  return ooxml('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function roman_upper(n)
  local out = ""
  for _, v in ipairs(ROMAN_VALUES) do
    while n >= v[1] do out = out .. v[2]; n = n - v[1] end
  end
  return out
end

-- Words in a block, footnotes included. A note becomes a space; Unicode spaces split words as typst's \s does.
local block_words
local function block_words_of(b)
  local text = {}
  local plain = pandoc.Blocks({ b }):walk({ Note = function(nt)
    text[#text + 1] = str(nt.content)
    return pandoc.Space()
  end })
  table.insert(text, 1, str(plain))
  local n = 0
  for _, s in ipairs(text) do
    s = s:gsub("\194\160", " "):gsub("\226\128\137", " "):gsub("\226\128\175", " ")
    for _ in s:gmatch("%S+") do n = n + 1 end
  end
  return n
end
-- Lists and quotations are counted item by item (stringify would run the items together).
block_words = function(b)
  if b.t == "BulletList" or b.t == "OrderedList" then
    local n = 0
    if b.t == "OrderedList" and b.listAttributes.style ~= "Decimal" then n = #b.content end
    for _, item in ipairs(b.content) do
      for _, c in ipairs(item) do n = n + block_words(c) end
    end
    return n
  elseif b.t == "BlockQuote" then
    local n = 0
    for _, c in ipairs(b.content) do n = n + block_words(c) end
    return n
  end
  return block_words_of(b)
end

-- Word count of the body as typst counts it: the oral-argument statement is excluded (FRAP 32(f)).
local function count_words(blocks)
  local n = 0
  local skipping = false
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      skipping = str(b.content):lower():find("oral argument", 1, true) ~= nil
    end
    if not skipping then n = n + block_words(b) end
  end
  return n
end

-- Roman and letter lists are paragraphs with their label as text, as in the other engines.
function OrderedList(l)
  local style = l.listAttributes.style
  if style == "Decimal" then return nil end
  local blocks = {}
  for i, item in ipairs(l.content) do
    local n = l.listAttributes.start + i - 1
    local lab
    if style == "LowerRoman" then lab = roman_upper(n):lower()
    elseif style == "UpperRoman" then lab = roman_upper(n)
    elseif style == "LowerAlpha" then lab = string.char(96 + n)
    else lab = string.char(64 + n) end
    lab = lab .. "."
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local c = { pandoc.Str(lab), pandoc.Space() }
      append(c, first.content)
      first.content = c
    end
    append(blocks, item)
  end
  return blocks
end

local function label(level, n)
  if inarg then
    if level == 2 then return roman_upper(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    if level == 5 then return string.char(96 + n) .. "." end
  else
    if level == 2 then return string.char(64 + n) .. "." end
    if level == 3 then return n .. "." end
    if level == 4 then return string.char(96 + n) .. "." end
    if level == 5 then return "(" .. n .. ")" end
  end
  error("ca1: no label for heading level " .. level)
end

local function on_header_body(h)
  if h.level == 1 then
    local lp = str(h.content):lower()
    inarg = (lp == "argument" or lp == "reply argument")
    for i = 2, 5 do counters[i] = 0 end
    tocitems[#tocitems + 1] = str(h.content)
    return pandoc.Header(1, h.content, h.attr)
  end
  if h.level > 5 then error("ca1: headings deeper than level 5 are not supported") end
  counters[h.level] = counters[h.level] + 1
  for i = h.level + 1, 5 do counters[i] = 0 end
  local lab = label(h.level, counters[h.level])
  if h.level == 2 then tocitems[#tocitems + 1] = lab .. " " .. str(h.content) end
  local content = { pandoc.Str(lab), pandoc.Space() }
  append(content, h.content)
  return pandoc.Header(h.level, content, h.attr)
end

local function on_header_add(h)
  if h.level == 2 then
    addlist[#addlist + 1] = str(h.content)
    return pandoc.Header(2, h.content, h.attr)
  end
  error("ca1: the addendum may only use level-2 headings")
end

-- A citation link is its text; the authorities list is built from the frontmatter.
local function on_link(l)
  if l.target:sub(1, 4) ~= "toa:" then return nil end
  local key = l.target:sub(5)
  if authorities[key] == nil then
    error("ca1: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
  end
  hits[key] = true
  return l.content
end

local function sort_key(a)
  local s
  if a.sort then s = str(a.sort)
  else s = str(inl(a.name)) .. " " .. str(inl(a.cite)) end
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- Cover (FRAP 32(a)(2)): single-spaced centered lines; the caption and counsel block at the middle of the page.
local function cover(meta)
  local o = {}
  local no = { pandoc.Str("No. ") }
  append(no, inl(meta.case_number))
  o[#o + 1] = styled("Cover Line", { para({ pandoc.Strong(no) }) })
  o[#o + 1] = styled("Cover Line", { para({ pandoc.Strong({ pandoc.Str("United States Court of Appeals for the First Circuit") }) }) })
  for i, side in ipairs(meta.caption) do
    for _, name in ipairs(side.names) do o[#o + 1] = styled("Cover Line", { para(inl(name)) }) end
    o[#o + 1] = styled("Signature Block", { para(inl(side.designation)) })
    if i < #meta.caption then o[#o + 1] = styled("Cover Line", { para({ pandoc.Str("v.") }) }) end
  end
  o[#o + 1] = styled("Cover Line", { para(inl(meta.proceeding)) })
  o[#o + 1] = styled("Cover Line", { para({ pandoc.Strong(inl(meta.brief_title)) }) })
  for _, g in ipairs(meta.counsel) do
    local items = {}
    for _, n in ipairs(g.names) do
      append(items, inl(n))
      items[#items + 1] = pandoc.LineBreak()
    end
    for _, l in ipairs(g.lines or {}) do
      items[#items + 1] = pandoc.Emph(inl(l))
      items[#items + 1] = pandoc.LineBreak()
    end
    o[#o + 1] = styled("Signature Block", { para(items) })
  end
  o[#o + 1] = styled("Signature Block", { para(inl(meta.phone)) })
  return o
end

-- Signature block after the body (typst signature-block): left half of the page, date at the margin.
local function signature(meta)
  local sig = meta.signature
  local items = { pandoc.Str("/s/ ") }
  append(items, inl(sig.signer))
  items[#items + 1] = pandoc.LineBreak()
  items[#items + 1] = pandoc.Str(str(inl(sig.signer)):upper())
  for _, l in ipairs(sig.lines or {}) do
    items[#items + 1] = pandoc.LineBreak()
    items[#items + 1] = pandoc.Emph(inl(l))
  end
  local o = {
    styled("Signature Block", { para({ pandoc.Str("Respectfully submitted,") }) }),
    styled("Signature Block", { para(items) }),
  }
  if meta.date then o[#o + 1] = styled("Single Spaced", { para(inl(meta.date)) }) end
  return o
end

-- Attorney line under a certificate (typst form-sig-line).
local function form_signature(meta)
  local sig = meta.signature
  local items = { pandoc.Str("/s/ ") }
  append(items, inl(sig.signer))
  items[#items + 1] = pandoc.LineBreak()
  items[#items + 1] = pandoc.Str("Attorney for ")
  append(items, inl(sig["for"]))
  if meta.date then
    items[#items + 1] = pandoc.LineBreak()
    items[#items + 1] = pandoc.Str("Dated: ")
    append(items, inl(meta.date))
  end
  return styled("Signature Block", { para(items) })
end

-- Certificate of compliance (FRAP 32(g); Form 6). The box is text ("[X]"): EB Garamond has no check-box glyph.
local function certificate_compliance(meta, words)
  local wp = { pandoc.Str("[X] this document has been prepared in a proportionally spaced typeface using ") }
  append(wp, inl(meta.word_processor))
  wp[#wp + 1] = pandoc.Str(" in 14-point ")
  append(wp, inl(meta.typeface))
  wp[#wp + 1] = pandoc.Str(" roman type.")
  return {
    pagebreak(),
    pandoc.Header(1, { pandoc.Str("Certificate of Compliance") }),
    styled("Single Spaced", { para({ pandoc.Str("1. This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f):") }) }),
    styled("Block Text", { para({ pandoc.Str("[X] this document contains " .. group_digits(words) .. " words.") }) }),
    styled("Single Spaced", { para({ pandoc.Str("2. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because:") }) }),
    styled("Block Text", { para(wp) }),
    form_signature(meta),
  }
end

local function certificate_service(meta)
  local items = { pandoc.Str("I hereby certify that on ") }
  append(items, inl(meta.date or "__________"))
  items[#items + 1] = pandoc.Str(", I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the First Circuit by using the appellate CM/ECF system, which will send notification of such filing to all counsel of record.")
  return {
    pagebreak(),
    pandoc.Header(1, { pandoc.Str("Certificate of Service") }),
    styled("Single Spaced", { para(items) }),
    form_signature(meta),
  }
end

-- Table of authorities: the groups and entries, sorted; no page numbers (BLOCKED, see the header comment).
local function toa(meta)
  local list = {}
  for key, a in pairs(authorities) do
    if hits[key] then list[#list + 1] = { key = key, a = a, sort = sort_key(a) } end
  end
  table.sort(list, function(x, y) return x.sort < y.sort end)
  local o = { pandoc.Header(1, { pandoc.Str("Table of Authorities") }) }
  for _, g in ipairs(TOA_GROUPS) do
    local printed = false
    for _, m in ipairs(list) do
      if str(m.a.kind) == g[1] then
        if not printed then
          o[#o + 1] = para({ pandoc.Strong({ pandoc.Str(g[2]) }) })
          printed = true
        end
        local items = {}
        if m.a.name then
          if g[1] == "case" then items[#items + 1] = pandoc.Emph(inl(m.a.name))
          else append(items, inl(m.a.name)) end
          items[#items + 1] = pandoc.Str(",")
          items[#items + 1] = pandoc.LineBreak()
        end
        append(items, inl(m.a.cite))
        o[#o + 1] = styled("Contents Line", { para(items) })
      end
    end
  end
  return o
end

function Pandoc(doc)
  local meta = doc.meta
  authorities = meta.authorities or {}
  local body, add = {}, nil
  for _, b in ipairs(doc.blocks) do
    if add == nil and b.t == "Header" and b.level == 1 and str(b.content):lower():match("^%s*addendum%s*$") then
      add = {}
    elseif add then
      add[#add + 1] = b
    else
      body[#body + 1] = b
    end
  end
  local had_add = add ~= nil
  if not had_add then
    if ADDENDUM == "required" then
      error("ca1: 1st Cir. R. 28.0(a)(1) requires an addendum with the order or decision appealed from; add a `# Addendum` section")
    end
    add = {}
  end

  local words = count_words(body)
  if words > WORD_LIMIT then
    error("ca1: the brief has " .. words .. " words; FRAP 32(a)(7)(B) allows " .. WORD_LIMIT)
  end
  inarg = false
  body = pandoc.Blocks(body):walk({ Header = on_header_body, Link = on_link, OrderedList = OrderedList })
  add = pandoc.Blocks(add):walk({ Header = on_header_add, Link = on_link, OrderedList = OrderedList })

  local out = {}
  local function push(b) out[#out + 1] = b end
  for _, b in ipairs(cover(meta)) do push(b) end
  push(sect("rIdFtr2", nil, nil))                 -- cover: an empty footer, no page number
  push(pandoc.Header(1, { pandoc.Str("Table of Contents") }))
  for _, t in ipairs(tocitems) do push(styled("Contents Line", { para({ pandoc.Str(t) }) })) end
  for _, b in ipairs(toa(meta)) do push(b) end
  push(sect("rIdFtr1", "lowerRoman", 1))          -- front matter: roman numerals from i
  for _, b in ipairs(body) do push(b) end
  for _, b in ipairs(signature(meta)) do push(b) end
  for _, b in ipairs(certificate_compliance(meta, words)) do push(b) end
  if meta.service and meta.service.certificate then
    for _, b in ipairs(certificate_service(meta)) do push(b) end
  end
  if had_add then
    push(sect("rIdFtr1", "decimal", 1))          -- body and certificates: arabic from 1
    push(pandoc.Header(1, { pandoc.Str("Addendum") }))
    push(pandoc.Header(1, { pandoc.Str("Table of Contents") }))
    for _, t in ipairs(addlist) do push(styled("Contents Line", { para({ pandoc.Str(t) }) })) end
    push(pagebreak())
    for _, b in ipairs(add) do push(b) end
  end
  doc.blocks = out
  doc.meta = pandoc.Meta({})   -- the frontmatter is on the page already; no pandoc title block
  return doc
end

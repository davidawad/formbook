-- nysb motion memorandum, DOCX engine (docs/DOCX.md): markdown -> Word on docx/reference.docx, to the form of
-- typst/nysb-motion-brief.typ. The cover (counsel, court, caption with "v.", title), the contents page (a TOC field with
-- its entries written out, so the page shows without a field update), and the memorandum are built here as paragraphs and
-- tables in the custom styles of reference.docx. Section breaks: cover (no page number), contents (roman, from i), body
-- (arabic, from 1). Headings carry their labels as text (I., A., 1.) as the template numbers them.
-- Two passes (docx/render.sh): pass 1 writes the search keys for the page of each heading; pass 2 writes the page numbers.
-- Known limits (see the PR and the README "Engines" section): the TOC page numbers come from LibreOffice's pagination
-- of pass 1; Word may paginate a line or two differently, and a TOC update in Word regenerates the entries from the
-- headings (with their labels).

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local PGSZ = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local SECT_COVER = '<w:sectPr>' .. PGSZ .. '</w:sectPr>'
local SECT_FRONT = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/>' .. PGSZ .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
local FIELD_BEGIN = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
local FIELD_END = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'

local function custom(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para(style, inlines)
  return custom(style, { pandoc.Para(inlines) })
end

local function to_inlines(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "table" and v.t == "MetaInlines" then return pandoc.Inlines(v) end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function is_true(v)
  return v ~= nil and pandoc.utils.stringify(v) == "true"
end

local function join(a, b)
  local out = pandoc.Inlines({})
  for _, x in ipairs(a) do out:insert(x) end
  for _, x in ipairs(b) do out:insert(x) end
  return out
end

-- a table without rules; the column widths are fractions of the text width
local function grid(widths, rows)
  local colspecs = {}
  for i, w in ipairs(widths) do colspecs[i] = { pandoc.AlignDefault, w } end
  local body = {}
  for _, r in ipairs(rows) do
    local cells = {}
    for _, blocks in ipairs(r) do cells[#cells + 1] = pandoc.Cell(blocks) end
    body[#body + 1] = pandoc.Row(cells)
  end
  return pandoc.Table(pandoc.Caption(), colspecs, pandoc.TableHead(), { pandoc.TableBody(body) }, pandoc.TableFoot())
end

-- the search key of a heading or paragraph for pass 2: lower case letters and digits, the first 40 of them
local function key_of(s)
  local k = s:lower():gsub("[^a-z0-9]", "")
  return k:sub(1, 40)
end

local function xml_escape(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function run(text)
  return '<w:r><w:t xml:space="preserve">' .. xml_escape(text) .. '</w:t></w:r>'
end

local function cover(meta)
  local out = {}
  local groups = meta.counsel or {}
  for gi, group in ipairs(groups) do
    for li, line in ipairs(group) do
      local style = (li == #group and gi < #groups) and "Single Gap" or "Single"
      out[#out + 1] = para(style, to_inlines(line))
    end
  end
  if meta.counsel_for then
    out[#out + 1] = para("Counsel For", { pandoc.Emph(to_inlines(meta.counsel_for)) })
  end
  out[#out + 1] = para("Court Name First", { pandoc.Str("UNITED STATES BANKRUPTCY COURT") })
  out[#out + 1] = para("Court Name Last", { pandoc.Str("SOUTHERN DISTRICT OF NEW YORK") })

  -- the caption: parties on the left with a right rule and a bottom rule; the case data on the right
  local left = {}
  local function party(p, note_on_last)
    local names = p.names or {}
    for i, n in ipairs(names) do
      local inl = to_inlines(n)
      if i == #names and note_on_last and p.note then
        inl:insert(pandoc.Note({ pandoc.Para(to_inlines(p.note)) }))
      end
      left[#left + 1] = { "Caption Name", inl }
    end
    left[#left + 1] = { "Caption Designation", to_inlines(p.designation) }
  end
  local c = meta.caption
  local sep = c.separator and pandoc.utils.stringify(c.separator) or "against"
  party(c.debtors, true)
  for k, p in ipairs(c.parties or {}) do
    if k > 1 then left[#left + 1] = { "Caption Against", pandoc.Inlines({ pandoc.Str(sep) }) } end
    party(p, false)
  end
  local last = left[#left]
  left[#left] = { "Caption End", last[2] }
  local left_blocks = {}
  for _, item in ipairs(left) do left_blocks[#left_blocks + 1] = para(item[1], item[2]) end

  local right_blocks = {
    para("Caption Right Gap", { pandoc.Str("Chapter " .. pandoc.utils.stringify(meta.chapter)) }),
    para("Single", { pandoc.Str("Case No. " .. pandoc.utils.stringify(meta.case_number)) }),
  }
  if is_true(meta.jointly_administered) then
    right_blocks[#right_blocks + 1] = para("Caption Right Gap", { pandoc.Str("(Jointly Administered)") })
  end
  right_blocks[#right_blocks + 1] = para("Caption Right", { pandoc.Str("Adv. Pro. No. " .. pandoc.utils.stringify(meta.adv_proc_no)) })
  out[#out + 1] = grid({ 3.35 / 6.5, 3.15 / 6.5 }, { { left_blocks, right_blocks } })

  out[#out + 1] = para("Cover Title", to_inlines(meta.title))
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr>' .. SECT_COVER .. '</w:pPr></w:p>')
  return out
end

-- the contents page: the TOC field with its entries written out; pages come from pass 2 (NYSB_TOC_PAGES), else 0
local function contents(entries, pages)
  local xml = { '<w:p><w:pPr><w:pStyle w:val="TOCTitle"/></w:pPr>' .. run("TABLE OF CONTENTS") .. '</w:p>' }
  for i, e in ipairs(entries) do
    local p = '<w:p><w:pPr><w:pStyle w:val="TOC' .. e.level .. '"/></w:pPr>'
    if i == 1 then p = p .. FIELD_BEGIN end
    if e.label then p = p .. run(e.label) .. '<w:r><w:tab/></w:r>' end
    p = p .. run(e.text) .. '<w:r><w:tab/></w:r>' .. run(tostring(pages[i] or 0))
    if i == #entries then p = p .. FIELD_END end
    xml[#xml + 1] = p .. '</w:p>'
  end
  xml[#xml + 1] = '<w:p><w:pPr>' .. SECT_FRONT .. '</w:pPr></w:p>'
  return pandoc.RawBlock("openxml", table.concat(xml))
end

local function signature(meta)
  local sig = meta.signature
  local right = {}
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = para("Signature Right", to_inlines(l)) end
  local signer = pandoc.utils.stringify(sig.signer)
  right[#right + 1] = para("Signature Gap", { pandoc.Str("By: /s/ " .. signer) })
  right[#right + 1] = para("Signature Right", { pandoc.Str(signer) })
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = para("Signature Right", to_inlines(l)) end
  local left = { para("Signature Left", { pandoc.Str("Dated: " .. pandoc.utils.stringify(meta.date)) }) }
  return grid({ 2.8 / 6.5, 3.7 / 6.5 }, { { left, right } })
end

local function read_pages(path)
  local pages = {}
  local f = path and io.open(path, "r")
  if not f then return pages end
  for line in f:lines() do
    local i, p = line:match("^(%d+)\t(%d+)$")
    if i then pages[tonumber(i)] = tonumber(p) end
  end
  f:close()
  return pages
end

local function letter(i) return string.char(96 + i) end
local function roman(i)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, v in ipairs(vals) do
    while i >= v[1] do s = s .. v[2]; i = i - v[1] end
  end
  return s
end

function Pandoc(doc)
  local meta = doc.meta
  local body = {}
  local entries = {}
  local n = 0
  local sub = { level1 = "", c2 = 0, c3 = 0 }
  local last_div = nil
  local first_key = nil

  local function add_numbered(inl)
    n = n + 1
    local d = custom("Num Para", { pandoc.Para(join({ pandoc.Str(tostring(n) .. ".") }, join({ TAB }, inl))) })
    body[#body + 1] = d
    last_div = d
  end

  local function add_unnumbered(inl)
    local d = custom("Body Para", { pandoc.Para(inl) })
    body[#body + 1] = d
    last_div = d
    if not first_key then first_key = key_of(pandoc.utils.stringify(inl)) end
  end

  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local inl = b.content
      -- "^" marks an unnumbered paragraph (the opening paragraph)
      local first = inl[1]
      if first and first.t == "Str" and first.text:sub(1, 1) == "^" then
        local rest = pandoc.Inlines({})
        if #first.text > 1 then rest:insert(pandoc.Str(first.text:sub(2))) end
        for i = 2, #inl do rest:insert(inl[i]) end
        if rest[1] and rest[1].t == "Space" then rest:remove(1) end
        add_unnumbered(rest)
      else
        if not first_key then first_key = key_of(pandoc.utils.stringify(inl)) end
        add_numbered(inl)
      end
    elseif b.t == "Header" then
      local text = pandoc.utils.stringify(b.content)
      local label = nil
      if b.level == 1 then
        sub.level1 = text
        sub.c2, sub.c3 = 0, 0
      elseif b.level == 2 then
        sub.c2 = sub.c2 + 1
        sub.c3 = 0
      elseif b.level == 3 then
        sub.c3 = sub.c3 + 1
      end
      -- typst: under ARGUMENT, level 2 is roman (I.) and level 3 letters (A.); elsewhere level 2 letters, level 3 numbers
      local in_argument = sub.level1:find("ARGUMENT", 1, true) ~= nil
      if b.level == 2 then
        label = in_argument and (roman(sub.c2):upper() .. ".") or (letter(sub.c2):upper() .. ".")
      elseif b.level == 3 then
        label = in_argument and (letter(sub.c3):upper() .. ".") or (tostring(sub.c3) .. ".")
      end
      local content = pandoc.Inlines({})
      if label then content:insert(pandoc.Str(label)); content:insert(TAB) end
      for _, x in ipairs(b.content) do content:insert(x) end
      body[#body + 1] = pandoc.Header(b.level, content)
      entries[#entries + 1] = { level = b.level, label = label, text = text }
      last_div = nil
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        local inl = (first and (first.t == "Plain" or first.t == "Para")) and first.content or pandoc.Inlines({})
        local lab = b.t == "OrderedList" and ("(" .. letter(i) .. ")") or "\u{2022}"
        local d = custom("List Item", { pandoc.Para(join({ pandoc.Str(lab) }, join({ TAB }, inl))) })
        body[#body + 1] = d
        last_div = d
      end
    else
      body[#body + 1] = b
      last_div = nil
    end
  end

  -- the last body block keeps with the signature block
  if last_div then
    local map = { ["Body Para"] = "Body Last", ["Num Para"] = "Num Last", ["List Item"] = "List Last" }
    local s = last_div.attr.attributes["custom-style"]
    if map[s] then last_div.attr.attributes["custom-style"] = map[s] end
  end

  -- pass 1 writes the keys: the first body paragraph, then each heading (the page search of render.sh)
  local keys_path = os.getenv("NYSB_KEYS")
  if keys_path then
    local f = assert(io.open(keys_path, "w"))
    f:write((first_key or "") .. "\n")
    for _, e in ipairs(entries) do f:write(key_of(e.text) .. "\n") end
    f:close()
  end

  local pages = read_pages(os.getenv("NYSB_TOC_PAGES"))
  local blocks = cover(meta)
  blocks[#blocks + 1] = contents(entries, pages)
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = signature(meta)

  doc.meta = pandoc.Meta({})
  doc.blocks = blocks
  return doc
end

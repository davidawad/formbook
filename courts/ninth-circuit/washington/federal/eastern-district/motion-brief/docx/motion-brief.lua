-- Motion with memorandum, DOCX engine (docs/DOCX.md): the markdown contract -> a pleading-paper Word document on
-- reference.docx, laid out as typst/waed-motion-brief.typ (LCivR 7(b)(1), 7(i)(1), 10(a), 10(d)). The cover, caption
-- (with the hearing notation), table of contents and signature block are OpenXML (pleading.lua, shared helpers); the
-- body keeps its markdown structure with the paragraph styles of reference.docx. The memorandum is not numbered.
-- Page numbers in the table of contents come from a first pass (docx/render.sh): this filter writes the headings it
-- found (MOTION_INDEX_OUT) and, on the second pass, reads their pages (MOTION_PAGES). The contents are a TOC field
-- whose cached result is written, so every viewer shows the entries. Content-agnostic: every case word comes from the
-- sample's frontmatter.

local SCRIPT_DIR = PANDOC_SCRIPT_FILE:match("^(.*/)") or "./"
local P = dofile(SCRIPT_DIR .. "pleading.lua")

-- a lettered list item (typst: A., B., ...): the letter, a tab, then the item
local function lettered(i, blocks)
  local out = {}
  local first = blocks[1]
  local content = (first and (first.t == "Para" or first.t == "Plain")) and first.content or pandoc.List({})
  local inl = pandoc.List({ pandoc.Str(string.char(64 + i) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
  inl:extend(content)
  out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading List" }))
  for k = 2, #blocks do out[#out + 1] = blocks[k] end
  return out
end

-- the table of contents: a TOC field (levels 1 and 2) whose cached result holds the entries and their pages
local function toc_xml(entries)
  local out = {}
  for k, e in ipairs(entries) do
    local pre = ""
    local post = ""
    if k == 1 then
      pre = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    if k == #entries then
      post = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
    end
    out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="TOC' .. e.level .. '"/></w:pPr>' .. pre .. P.runs(e.text, {}) ..
      '<w:r><w:tab/></w:r><w:r><w:t>' .. P.xesc(e.page) .. '</w:t></w:r>' .. post .. '</w:p>'
  end
  return table.concat(out)
end

-- the search text of a heading or paragraph as pdftotext prints it: its non-space characters, the first 30
local function search_text(s)
  local t = s:gsub("%s+", "")
  return t:sub(1, 30)
end

function Pandoc(doc)
  local meta = doc.meta
  local date = meta.date
  local want_toc = meta.toc
  doc.meta.date = nil
  doc.meta.title = nil
  doc.meta.toc = nil   -- pandoc would print its own "Table of Contents" for toc: true

  local blocks = doc.blocks
  -- headings: level 1 in capitals (typst upper()); the table of contents and the search index
  local toc, index = {}, {}
  local body_start, cert_at = nil, nil
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        for _, e in ipairs(b.content) do if e.t == "Str" then e.text = e.text:upper() end end
      end
      local text = P.plain(b.content)
      if b.level <= 2 then
        toc[#toc + 1] = { level = b.level, text = b.content, page = "0" }
        index[#index + 1] = { kind = "h", id = #toc, text = search_text(text) }
      end
      if b.level == 1 and text:upper() == "CERTIFICATE OF SERVICE" then cert_at = cert_at or i end
    elseif b.t == "Para" and not body_start and not cert_at then
      body_start = search_text(P.plain(b))
    end
  end
  table.insert(index, 1, { kind = "start", id = "", text = body_start or "" })

  -- the pages from the first pass (the second pass of docx/render.sh)
  local pages_file = os.getenv("MOTION_PAGES")
  if pages_file then
    local f = assert(io.open(pages_file, "r"))
    for line in f:lines() do
      local id, page = line:match("^(%d+)\t(%d+)$")
      if id then toc[tonumber(id)].page = page end
    end
    f:close()
  end
  local index_out = os.getenv("MOTION_INDEX_OUT")
  if index_out then
    local f = assert(io.open(index_out, "w"))
    for _, r in ipairs(index) do f:write(r.kind .. "\t" .. tostring(r.id) .. "\t" .. r.text .. "\n") end
    f:close()
  end

  -- the cover: counsel, court title (upper case), one blank line, the caption with the hearing notation at right
  local right = {
    { inl = { pandoc.Str("Case No. " .. P.plain(meta.case_number or "")) } },
    { spacer = true },
    { inl = P.minl(meta.brief_title), bold = true },
  }
  if meta.hearing then
    right[#right + 1] = { spacer = true }
    right[#right + 1] = { inl = { pandoc.Str("Hearing date: " .. P.plain(meta.hearing.date or "")) } }
    if meta.hearing.type then right[#right + 1] = { inl = P.minl(meta.hearing.type) } end
    if meta.hearing.judge then right[#right + 1] = { inl = P.minl(meta.hearing.judge) } end
  end
  local cover = { P.counsel_xml(meta.counsel or {}),
    P.PX({ pandoc.Str("UNITED STATES DISTRICT COURT") }, "PleadingCentered"),
    P.PX({ pandoc.Str("EASTERN DISTRICT OF WASHINGTON") }, "PleadingCentered") }
  if meta.division then
    cover[#cover + 1] = P.PX({ pandoc.Str(P.plain(meta.division):upper()) }, "PleadingCentered")
  end
  cover[#cover + 1] = '<w:p><w:pPr><w:pStyle w:val="PleadingCentered"/></w:pPr></w:p>'
  cover[#cover + 1] = P.caption_xml(meta, right)
  local out = { pandoc.RawBlock("openxml", table.concat(cover)) }

  -- the table of contents on its own page (LCivR 10(a)(2): sequential pages; the entries carry the render's pages)
  if want_toc then
    out[#out + 1] = pandoc.RawBlock("openxml", P.page_break() ..
      P.PX({ pandoc.Str("TABLE OF CONTENTS") }, "PleadingCentered", true) .. toc_xml(toc) .. P.page_break())
  end

  -- the body (not numbered; LCivR 7(b)(1)); the signature block, then the certificate of service on its own page
  local sig = meta.signature
  local function signature_block()
    local items = P.signature_items(sig, {}, true)
    items[#items + 1] = { inl = { pandoc.Str("By s/" .. P.plain(sig.signer)) } }
    for _, l in ipairs(sig.lines or {}) do items[#items + 1] = { inl = P.minl(l) } end
    return pandoc.RawBlock("openxml", P.signature_xml(date, items))
  end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      if i == cert_at then
        out[#out + 1] = signature_block()
        out[#out + 1] = pandoc.RawBlock("openxml", P.page_break())
      end
      out[#out + 1] = b
    elseif b.t == "Para" then
      out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Body" }))
    elseif b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        for _, blk in ipairs(lettered(k, item)) do out[#out + 1] = blk end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, blk in ipairs(item) do out[#out + 1] = blk end
      end
    else
      out[#out + 1] = b
    end
  end
  if not cert_at then out[#out + 1] = signature_block() end
  doc.blocks = out
  return doc
end

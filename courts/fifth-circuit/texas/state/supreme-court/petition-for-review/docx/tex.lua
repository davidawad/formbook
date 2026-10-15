-- Texas Supreme Court brief or petition, DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Builds the cover, the front matter (identities, table of contents, index of authorities) and the section breaks:
-- the cover has no footer, the front matter is numbered in lower roman from ii, the body in arabic from 1 (the
-- last section, from reference.docx). The contents entries carry PAGEREF fields to the heading bookmarks. LibreOffice
-- shows the cached result of a PAGEREF, so the page labels come from a first pass (docx/render.sh): DOCX_TOC_MARKS
-- puts a hidden marker in each entry's heading, DOCX_TOC_PAGES gives the label of each entry for the second pass.
-- The word count follows the typst template (word-count in typst/tex-*.typ, Rule 9.4(i)(1)) on the markdown source.
-- Cover, contents and authority lines are paragraphs of reference.docx styles written as OOXML (pandoc's custom-style
-- route would create a second copy of a style whose name differs from its id).

local CFG = { word_limit = 4500 }

local FOOTER_RID = "rId100" -- the footer of reference.docx (build-reference.sh)
local INDEX_ID = "tocindex"
local BOLD = "<w:b/><w:bCs/>"
local ITALIC = "<w:i/><w:iCs/>"

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- a run of text; props is the inside of w:rPr (may be "")
local function run(text, props)
  local rpr = (props and props ~= "") and ("<w:rPr>" .. props .. "</w:rPr>") or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local TAB = '<w:r><w:tab/></w:r>'

local function para(style, body)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. body .. '</w:p>')
end

-- an empty paragraph of a fixed exact height (the typst template's vertical spaces)
local function gap(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

-- a line of the lead-counsel block: a paragraph of the frame at the foot of the cover (anchored to the bottom margin)
local function counsel_line(text)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="CounselFrame"/><w:framePr w:w="9360" w:hSpace="0"'
    .. ' w:wrap="around" w:vAnchor="margin" w:hAnchor="margin" w:yAlign="bottom"/></w:pPr>' .. run(text) .. '</w:p>')
end

local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- a section break: the empty paragraph carries the sectPr of the section that ends there
local function section_break(footer, fmt, start)
  local ref = footer and ('<w:footerReference w:type="default" r:id="' .. FOOTER_RID .. '"/>') or ""
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or ""
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="SectionBreak"/><w:sectPr>' .. ref
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. '</w:sectPr></w:pPr></w:p>')
end

local function fld_begin(instr)
  return '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> ' .. instr
    .. ' </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
end
local FLD_END = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'

-- Rule 9.4(i)(1), 2026 text (typst excluded-section): these sections are not counted; everything else is.
local EXCLUDED = {
  "^identit", "^table of contents", "^index of authorities", "^statement regarding oral argument",
  "^statement of the case", "^statement of jurisdiction", "^issues? presented", "^certificate", "^appendix",
}

local function count_words(s)
  local n = 0
  for tok in s:gmatch("%S+") do
    if tok:find("%w") then n = n + 1 end
  end
  return n
end

-- the words of the counted H1 sections of the markdown source, from the body_start heading on
local function source_word_count(body_start)
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("tex: no input file to count words from", 0) end
  local h = assert(io.open(f, "rb"))
  local text = h:read("a")
  h:close()
  local fm = text:match("^%-%-%-\r?\n.-\n%-%-%-[ \t]*\r?\n")
  if fm then text = text:sub(#fm + 1) end
  local want = ("# " .. body_start):lower()
  local lines, started = {}, false
  for line in (text .. "\n"):gmatch("(.-)\r?\n") do
    if not started and line:gsub("[ \t]+$", ""):lower() == want then started = true end
    if started then lines[#lines + 1] = line end
  end
  if not started then error("tex: body_start heading not found: " .. body_start, 0) end
  -- one chunk per H1 section (typst splits on "^# "); the signature after "Respectfully submitted" is not counted
  local chunks, cur = {}, nil
  for _, line in ipairs(lines) do
    if line:sub(1, 2) == "# " then
      cur = { title = line:sub(3):match("^%s*(.-)%s*$"), text = { line:sub(3) } }
      chunks[#chunks + 1] = cur
    elseif cur then
      cur.text[#cur.text + 1] = line
    end
  end
  local total = 0
  for _, c in ipairs(chunks) do
    local t = c.title:lower()
    local excluded = false
    for _, p in ipairs(EXCLUDED) do
      if t:find(p) then excluded = true break end
    end
    if not excluded then
      local s = table.concat(c.text, "\n")
      local cut = s:find("Respectfully submitted", 1, true)
      if cut then s = s:sub(1, cut - 1) end
      total = total + count_words(s)
    end
  end
  return total
end

-- pass 1 of docx/render.sh: a white 1-pt marker at the start of an entry's heading, for the page search
local function marked(h, i)
  if not os.getenv("DOCX_TOC_MARKS") then return h end
  table.insert(h.content, 1, pandoc.RawInline("openxml", '<w:r><w:rPr><w:color w:val="FFFFFF"/><w:sz w:val="2"/>'
    .. '<w:szCs w:val="2"/></w:rPr><w:t>TOCMARK' .. i .. '</w:t></w:r>'))
  return h
end

-- pass 2: the page label of each entry (lines "index<TAB>label", from pass 1's PDF)
local function page_labels()
  local labels = {}
  local f = os.getenv("DOCX_TOC_PAGES")
  if not f then return labels end
  local h = assert(io.open(f, "r"))
  for line in h:lines() do
    local i, label = line:match("^(%d+)\t(.*)$")
    if i then labels[tonumber(i)] = label end
  end
  h:close()
  return labels
end

function Pandoc(doc)
  local meta = doc.meta
  local body_start = plain(meta.body_start)

  -- front matter (before the body_start heading) and the body
  local front, body, started = {}, {}, false
  for _, b in ipairs(doc.blocks) do
    if not started and b.t == "Header" and b.level == 1 and plain(b.content):lower() == body_start:lower() then
      started = true
    end
    if started then body[#body + 1] = b else front[#front + 1] = b end
  end
  if not started then error("tex: body_start heading not found in the markdown: " .. body_start, 0) end

  local words = source_word_count(body_start)
  if words > CFG.word_limit then
    error("tex: the document has " .. words .. " words; the limit is " .. CFG.word_limit .. " (Rule 9.4(i)(2))", 0)
  end

  -- the contents: the front-matter headings, the index of authorities, then the body headings (typst outline, depth 2)
  local toc = {}
  local function add_toc(h)
    if h.t == "Header" and h.level <= 2 then
      local i = #toc + 1
      h.identifier = "tocentry" .. i
      marked(h, i)
      toc[#toc + 1] = { id = h.identifier, level = h.level, text = plain(h.content) }
    end
  end
  for _, b in ipairs(front) do add_toc(b) end
  local index_at = #toc + 1
  toc[index_at] = { id = INDEX_ID, level = 1, text = "INDEX OF AUTHORITIES" }
  for _, b in ipairs(body) do add_toc(b) end
  local labels = page_labels()
  for i, e in ipairs(toc) do
    if os.getenv("DOCX_TOC_PAGES") and not labels[i] then
      error("tex: no page label for contents entry " .. i .. ": " .. e.text, 0)
    end
    e.page = labels[i] or ""
  end

  local out = {}
  local function add(x) out[#out + 1] = x end
  local function addall(xs) for _, x in ipairs(xs) do add(x) end end

  -- cover (page 1, no footer)
  add(para("Centered", run("No. " .. plain(meta.case_number))))
  add(gap("Gap648"))
  add(para("CenteredHeading", run("IN THE SUPREME COURT OF TEXAS", BOLD)))
  add(gap("Gap504"))
  for i, side in ipairs(meta.caption or {}) do
    add(para("Centered", run(plain(side))))
    if i < #meta.caption then
      add(gap("Gap288"))
      add(para("Centered", run("v.")))
      add(gap("Gap288"))
    end
  end
  add(gap("Gap504"))
  add(para("Centered", run(plain(meta.on_review))))
  add(gap("Gap504"))
  add(para("CoverTitle", run(plain(meta.title), BOLD)))
  add(gap("Gap504"))
  -- lead counsel and the filing party: a frame at the foot of the cover
  local lead = meta.lead_counsel
  for _, l in ipairs(lead.address or {}) do add(counsel_line(plain(l))) end
  add(counsel_line(plain(lead.name)))
  add(counsel_line(plain(lead.phone)))
  add(counsel_line(plain(lead.email)))
  add(counsel_line("Texas Bar No. " .. plain(lead.bar_number)))
  add(counsel_line(plain(meta.filing_party)))
  if meta.oral_argument_requested == true then
    add(counsel_line(""))
    add(counsel_line("ORAL ARGUMENT REQUESTED"))
  end
  add(section_break(false))

  -- front matter (lower roman from ii): identities, contents, index of authorities
  for _, b in ipairs(front) do
    if b.t == "Para" then
      add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Single" })))
    else
      add(b)
    end
  end
  add(page_break())
  add(para("CenteredHeading", run("TABLE OF CONTENTS", BOLD)))
  for i, e in ipairs(toc) do
    local body_xml = ""
    if i == 1 then body_xml = body_xml .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>' end
    body_xml = body_xml .. run(e.text) .. TAB
    body_xml = body_xml .. fld_begin("PAGEREF _" .. e.id .. " \\h") .. run(e.page) .. FLD_END
    if i == #toc then body_xml = body_xml .. FLD_END end
    add(para(e.level == 1 and "TOC1" or "TOC2", body_xml))
  end
  add(page_break())
  local index_header = pandoc.Header(1, { pandoc.Str("INDEX OF AUTHORITIES") }, pandoc.Attr(INDEX_ID))
  add(marked(index_header, index_at))
  for _, g in ipairs(meta.authorities or {}) do
    add(para("AuthorityGroup", run(plain(g.group))))
    for _, it in ipairs(g.items or {}) do
      local name = (it.italic == true) and run(plain(it.name), ITALIC) or run(plain(it.name))
      add(para("AuthorityEntry", name .. run(plain(it.rest)) .. TAB .. run(plain(it.pages))))
    end
  end
  add(section_break(true, "lowerRoman", "2"))

  -- body (arabic from 1), with {{word-count}} filled in
  -- the typst heading has space above it that Word and LibreOffice drop at the top of a page: the paragraph before a
  -- heading carries that space instead (BodyBeforeHeading), so a heading at a page top sits at the margin as in typst
  -- a list before a heading gets the same space (its paragraphs are Compact, with none after); a gap paragraph of 23 pt
  local spaced = {}
  for i, b in ipairs(body) do
    local nxt = body[i + 1]
    if b.t == "Para" and nxt and nxt.t == "Header" and nxt.level <= 2 then
      -- the first paragraph after a heading is not indented (FirstParagraph), and keeps that
      local first = i > 1 and body[i - 1].t == "Header"
      b = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = first and "BodyBeforeHeadingFirst" or "BodyBeforeHeading" }))
    end
    spaced[#spaced + 1] = b
    if (b.t == "BulletList" or b.t == "OrderedList") and nxt and nxt.t == "Header" and nxt.level <= 2 then
      spaced[#spaced + 1] = gap("Gap460")
    end
  end
  addall(spaced)
  doc.blocks = out
  doc.meta.title = nil -- the cover carries the title
  doc = doc:walk({
    Str = function(s)
      if s.text:find("{{word-count}}", 1, true) then
        return pandoc.Str((s.text:gsub("{{word%-count}}", tostring(words))))
      end
    end,
  })
  return doc
end

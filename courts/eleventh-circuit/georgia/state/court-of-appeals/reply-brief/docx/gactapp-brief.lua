-- gactapp-brief.lua (docx engine, brief types: answering-brief, opening-brief, reply-brief).
-- Adds what the typst template (typst/gactapp-*-brief.typ) does around the markdown body, in Word-native form
-- (docs/DOCX.md): the cover (caption, counsel block, title; no page number), a table of contents as a TOC field
-- with cached entries, the body (arabic page numbers from 1), and the signature block.
-- Sections: cover | contents (lower-roman footer) | body (arabic footer). The cover has no footer.
-- Page numbers in the contents are written on the second pass: render.sh reads the heading list written on the
-- first pass (GACTAPP_HEADINGS) and passes the page numbers back (GACTAPP_TOC_PAGES).
-- Cover and signature text is plain (pandoc.utils.stringify); the body is pandoc's own conversion.

local TOC_DEPTH = 2
local TEXT_WIDTH = 9360 -- twips: 8.5 in less two 1-in margins
local BOLD = "<w:b /><w:bCs />"
local ITALIC = "<w:i /><w:iCs />"

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, rpr)
  local rp = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. rp .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function para(content, ppr)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. content .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function spacing(before, after)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="240" w:lineRule="auto" />', before, after)
end

-- Single-spaced paragraph with no first-line indent.
local function line(text, rpr, before, after, jc)
  local ppr = spacing(before or 0, after or 0) .. '<w:ind w:firstLine="0" />' .. (jc and ('<w:jc w:val="' .. jc .. '" />') or "")
  return raw(para(text and run(text, rpr) or "", ppr))
end

local function sectpr(footer, pgnum)
  local fref = footer and '<w:footerReference w:type="default" r:id="rIdFooterPage" />' or ""
  return "<w:sectPr>" .. fref .. '<w:type w:val="nextPage" /><w:pgSz w:w="12240" w:h="15840" />'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />'
    .. (pgnum or "") .. "</w:sectPr>"
end

local function section_break(footer, pgnum)
  return raw('<w:p><w:pPr>' .. spacing(0, 0) .. sectpr(footer, pgnum) .. "</w:pPr></w:p>")
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function cover(meta)
  local out = {}
  local function add(b) out[#out + 1] = b end
  add(line("IN THE COURT OF APPEALS OF THE STATE OF GEORGIA", BOLD, 0, 0, "center"))
  add(line("Case No. " .. str(meta.case_number), BOLD, 240, 0, "center"))
  for i, side in ipairs(meta.caption or {}) do
    add(line(nil, nil, i == 1 and 240 or 180, 0, "center"))
    if i == 2 then add(line("v.", nil, 0, 240, "center")) end
    for _, n in ipairs(side.names or {}) do
      add(line(str(n), nil, 0, 0, "center"))
    end
    add(line(str(side.designation), nil, 0, 0, "center"))
  end
  add(line(nil, nil, 360, 0))
  add(line(str(meta.proceeding), ITALIC, 0, 0, "center"))
  if meta.trial_court_case then
    add(line("Trial court case no. " .. str(meta.trial_court_case), ITALIC, 0, 0, "center"))
  end
  add(line(str(meta.brief_title):upper(), BOLD .. '<w:sz w:val="32" /><w:szCs w:val="32" />', 1400, 0, "center"))
  add(line(nil, nil, 1000, 0))
  for _, g in ipairs(meta.counsel or {}) do
    for _, n in ipairs(g.names or {}) do add(line(str(n), BOLD, 0, 0)) end
    for _, l in ipairs(g.lines or {}) do add(line(str(l), ITALIC, 0, 0)) end
    add(line(nil, nil, 0, 120))
  end
  if meta.phone then add(line(str(meta.phone), nil, 0, 0)) end
  add(section_break(false))
  return out
end

-- Page numbers for the contents, one per heading, from the second pass (render.sh). "00" on the first pass.
local function page_reader()
  local pages = {}
  local path = os.getenv("GACTAPP_TOC_PAGES")
  local f = path and io.open(path, "r")
  if f then
    for l in f:lines() do pages[#pages + 1] = l end
    f:close()
  end
  return function(i) return pages[i] or "00" end
end

local function contents(headings)
  local out = {}
  out[#out + 1] = line("TABLE OF CONTENTS", BOLD, 0, 240, "center")
  local page_of = page_reader()
  for i, h in ipairs(headings) do
    local ind = h.level == 1 and '<w:ind w:left="0" w:firstLine="0" />' or '<w:ind w:left="720" w:firstLine="0" />'
    local tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. (TEXT_WIDTH - 10) .. '" /></w:tabs>'
    local ppr = spacing(0, 120) .. ind .. tabs
    local content = ""
    if i == 1 then
      content = '<w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-'
        .. TOC_DEPTH .. '" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r>'
    end
    content = content .. run(h.text) .. "<w:r><w:tab /></w:r>" .. run(page_of(i))
    if i == #headings then
      content = content .. '<w:r><w:fldChar w:fldCharType="end" /></w:r>'
    end
    out[#out + 1] = raw(para(content, ppr))
  end
  out[#out + 1] = section_break(true, '<w:pgNumType w:fmt="lowerRoman" w:start="1" />')
  return out
end

local function signature(meta)
  local out = {}
  local sig = meta.signature
  if meta.date then out[#out + 1] = line(str(meta.date), nil, 240, 0) end
  if sig then
    local ppr = '<w:keepNext /><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:left="4608" w:firstLine="0" />'
    out[#out + 1] = raw(para(run("/s/ " .. str(sig.signer):upper()), ppr))
    for _, l in ipairs(sig.lines or {}) do
      out[#out + 1] = raw(para(run(str(l), ITALIC), ppr))
    end
  end
  return out
end

local function collect_headings(blocks)
  local hs = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= TOC_DEPTH then
      hs[#hs + 1] = { level = b.level, text = pandoc.utils.stringify(b.content) }
    end
  end
  return hs
end

function Pandoc(doc)
  local meta = doc.meta
  -- the frontmatter is read here (cover, signature); pandoc must not write its own title block from it
  doc.meta = pandoc.Meta({})
  local hs = collect_headings(doc.blocks)
  local blocks = {}
  local function add_all(list)
    for _, b in ipairs(list) do blocks[#blocks + 1] = b end
  end

  add_all(cover(meta))
  add_all(contents(hs))
  add_all(doc.blocks)
  add_all(signature(meta))

  local hfile = os.getenv("GACTAPP_HEADINGS")
  if hfile then
    local f = assert(io.open(hfile, "w"))
    for _, h in ipairs(hs) do f:write(h.level, "\t", h.text, "\n") end
    f:close()
  end

  doc.blocks = blocks
  return doc
end

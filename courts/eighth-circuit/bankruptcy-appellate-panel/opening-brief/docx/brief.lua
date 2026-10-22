-- brief.lua: pandoc filter for the BAP 8th Cir. brief (docx engine; fb render, tools/fb/src/docxpass.rs).
-- It does what the typst template does in bap8-*.typ, on the pandoc AST:
--   * builds the document from the sample (lib/front.lua): the cover, the front matter and the back matter from
--     the frontmatter as written ($FORMBOOK_META), around the body, after the word count (FRBP 8015(a)(7)(B));
--   * numbers the body headings (Argument: I. / A. / 1. / a.; elsewhere A. / 1. / a. / (1)) and sets each
--     heading as a paragraph style (Section Heading, Point Heading, Sub2..Sub5, ArgSub3..ArgSub5) so the
--     hanging label positions match the typst output; the outline level is kept in the style;
--   * writes the table of contents (levels 1-4, dot leaders) and the table of authorities (grouped by kind,
--     "passim" at 7 or more pages) at the two placeholders;
--   * removes the toa: link targets, so citations are plain text (no hyperlinks).
-- Page numbers: fb render renders the document, finds the page of every body heading and citation in the
-- LibreOffice PDF (the needles this filter writes to $FORMBOOK_NEEDLES; contract in tools/fb/src/docxpages.rs) and
-- renders again with those pages ($FORMBOOK_PAGES) until they settle (fb-595.68.1: were docx/render.sh and
-- docx/front.jq). The numbered sections name the footer this filter gives fb render ($FORMBOOK_FOOTERS); the last
-- section goes to $FORMBOOK_FINAL.

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
-- The cross-engine layout model (lib/docx/xengine.lua): the break rules of typst on every run (a no-break hyphen
-- before a digit, pandoc's abbreviation no-break spaces undone, a section sign bound to its number).
local xe = require("docx.xengine")
-- Before the page number of a table row: three no-break spaces, so the leader is never shorter than that.
local LEAD = pandoc.Str("\u{00A0}\u{00A0}\u{00A0}")
local ACOL = 1120   -- the authorities' page column, twips (typst toa-page-col, 56 pt)

-- No break inside a token of adjacent parentheses ("8015(a)(7)(B)"), as typst's xengine boxes it: LibreOffice would
-- break between ")" and "(" (Unicode line breaking allows it); a word joiner forbids it.
local function joined(s)
  return (s:gsub("%)%(", ")\u{2060}("))
end

-- The width of a page list in twips, Times New Roman 14 pt: digits 500/1000 em, comma and space 250, "passim" in
-- italics 2778 (the font's advances; typst measures the same list).
local function page_width(s)
  if s == "passim" then return math.ceil(2778 * 0.28) end
  local units = 0
  for c in s:gmatch(".") do
    if c:match("%d") then units = units + 500 elseif c == "," or c == " " then units = units + 250
    else error("brief.lua: unexpected character in a page list: " .. s) end
  end
  return math.ceil(units * 0.28)
end

local function read_file(path)
  local f = path and path ~= "" and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- the pages of the previous pass: needle id -> { page, label }; empty on the first pass (placeholders "0")
local function read_pages()
  local P = {}
  for line in (read_file(os.getenv("FORMBOOK_PAGES")) or ""):gmatch("[^\n]+") do
    local id, page, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then P[id] = { page = tonumber(page) or 0, label = label } end
  end
  return P
end

-- letters and digits only, lower case: fb render normalizes the PDF text the same way
local NEEDLE_MAX = 60
local function norm(s) return (s:lower():gsub("[^a-z0-9]", "")) end

local function roman(n)
  local vals = { {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"}, {100, "C"}, {90, "XC"}, {50, "L"},
                 {40, "XL"}, {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"} }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

-- the printed label of a heading, as typst's heading-label()
local function label_for(level, n, in_arg)
  if in_arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    if level == 5 then return string.char(96 + n) .. "." end
  else
    if level == 2 then return string.char(64 + n) .. "." end
    if level == 3 then return tostring(n) .. "." end
    if level == 4 then return string.char(96 + n) .. "." end
    if level == 5 then return "(" .. tostring(n) .. ")" end
  end
  error("brief.lua: headings deeper than level 5 are not supported")
end

local function plain(inlines) return pandoc.utils.stringify(inlines) end

local function upper_inlines(inlines)
  return inlines:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

local function sort_key(cite)
  return (cite:lower():gsub("[^a-z0-9 ]", ""))
end

local function div(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para_div(style, inlines)
  return div(style, { pandoc.Para(inlines) })
end

-- heading styles (outline level kept in each style): returns style name for a non-point heading
local function sub_style(level, in_arg)
  if in_arg then return "ArgSub" .. level end
  return "Sub" .. level
end

-- TOC paragraph style: where the label sits (typst's label-indent), as in the heading styles
local function toc_style(level, in_arg, numbered)
  if level == 1 then return "TOC1" end
  if in_arg and level == 2 then return "TOCArg" end
  if in_arg then return level == 3 and "TOC2" or "TOC3" end
  return ({ [2] = "TOC2", [3] = "TOC3", [4] = "TOC4" })[level]
end

-- the table of authorities' groups, as typst's toa-groups
local GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

-- the footer the numbered sections name (lib/front.lua writes the front matter's section break), and the body's
-- section: arabic from 1
local FOOTER_P = '<w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p>'
local function body_sect(footer)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'
end

-- the text a needle may run on into: a block's text up to its first footnote mark (the note is printed elsewhere)
local function lead(b)
  if b == nil then return "" end
  if b.t == "Para" or b.t == "Plain" then
    local il = {}
    for _, x in ipairs(b.content) do
      if x.t == "Note" then break end
      il[#il + 1] = x
    end
    return plain(pandoc.Inlines(il)):sub(1, 40)
  end
  return plain(b):sub(1, 40)
end

-- every toa: citation of a block, in order: { key, kind (B body, N footnote), text, context (the words after it in
-- its paragraph, up to a footnote mark, a quotation or another link) }
local function citations(blocks, kind, out)
  local function scan(inls, k)
    for i, el in ipairs(inls) do
      if el.t == "Link" and el.target:match("^toa:") then
        local rest = {}
        for j = i + 1, math.min(#inls, i + 12) do
          local t = inls[j].t
          if t == "Note" or t == "Quoted" or t == "Link" then break end
          rest[#rest + 1] = inls[j]
        end
        out[#out + 1] = { key = el.target:sub(5), kind = k, text = plain(el.content), context = plain(pandoc.Inlines(rest)) }
      elseif el.t == "Note" then
        citations(el.content, "N", out)
      elseif el.content ~= nil and type(el.content) == "table" and el.t ~= "Code" then
        scan(el.content, k)
      end
    end
  end
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" or b.t == "Header" then scan(b.content, kind)
    elseif b.t == "BlockQuote" or b.t == "Div" then citations(b.content, kind, out)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do citations(item, kind, out) end
    end
  end
  return out
end

function Pandoc(doc)
  -- 0. the document: the sample with its cover, front matter and back matter (lib/front.lua), as render.sh built it
  local front = dofile(pandoc.path.join({ pandoc.path.directory(PANDOC_SCRIPT_FILE), "lib", "front.lua" }))
  local src = read_file(PANDOC_STATE.input_files[1])
  if not src then error("brief.lua: cannot read the sample") end
  local meta = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)
  local kind = pandoc.path.filename(pandoc.system.get_working_directory())
  doc = pandoc.read((front.assemble(meta, src, kind)), "markdown+smart", PANDOC_READER_OPTIONS)
  local authorities = meta.authorities
  if authorities == nil or authorities == pandoc.json.null then authorities = {} end
  local T = {}   -- the cited authorities, in order of first citation: { key, kind, cite }
  for _, k in ipairs(front.cited_keys(src)) do
    local a = authorities[k]
    if a == nil or a == pandoc.json.null then
      error("brief.lua: link toa:" .. k .. " has no entry under authorities: in the frontmatter")
    end
    T[#T + 1] = { key = k, kind = tostring(a.kind), cite = tostring(a.cite) }
  end
  local P = read_pages()
  local function label_of(id) return P[id] and P[id].label or "0" end

  -- 1. number the body headings (top-level Headers, in order), building their replacement blocks
  local counters = { 0, 0, 0, 0, 0 }
  local first_section = true   -- the first heading of the body starts a new section: no space above it
  local in_arg = false
  local heads = {}     -- { level, in_arg, label, content, id }
  local head_at = {}   -- block index -> its heading record
  local body = {}
  for bi, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local level = b.level
      counters[level] = counters[level] + 1
      for i = level + 1, 5 do counters[i] = 0 end
      local title = plain(b.content):lower():gsub("^%s+", ""):gsub("%s+$", "")
      local rec = { level = level, in_arg = in_arg, content = b.content, label = nil, title = title,
        id = "H:" .. (#heads + 1) }
      if level == 1 then
        in_arg = (title == "argument" or title == "reply argument")
        rec.in_arg = false
        local out = para_div(first_section and "SectionHeadingTop" or "SectionHeading", b.content)
        first_section = false
        body[#body + 1] = out
      else
        rec.label = label_for(level, counters[level], in_arg)
        rec.in_arg = in_arg
        if in_arg and level == 2 then
          -- point heading: label and title on one centered line
          local inl = { pandoc.Str(rec.label), pandoc.Space() }
          for _, x in ipairs(b.content) do inl[#inl + 1] = x end
          body[#body + 1] = para_div("PointHeading", inl)
        else
          local inl = { pandoc.Str(rec.label), TAB }
          for _, x in ipairs(b.content) do inl[#inl + 1] = x end
          body[#body + 1] = para_div(sub_style(level, in_arg), inl)
        end
      end
      heads[#heads + 1] = rec
      head_at[bi] = rec
    else
      body[#body + 1] = b
    end
  end

  -- the authorities by group, sorted by cite
  local groups = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for _, t in ipairs(T) do
      if t.kind == g[1] then members[#members + 1] = t end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return sort_key(x.cite) < sort_key(y.cite) end)
      groups[#groups + 1] = { label = g[2], members = members }
    end
  end

  -- the needles, in document order: the table of authorities' heading (with its first group's head, so it is not
  -- taken for a line of the contents), then the body's headings (label, title and the text after them) and
  -- citations; the body is numbered from its first block with text (after the front matter's section break)
  local needles, occurrences = {}, {}
  local function need(id, k, text, context)
    local short = norm(text):sub(1, NEEDLE_MAX)
    local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
    if short == "" then short = long end
    needles[#needles + 1] = table.concat({ id, k, long, short }, "\t")
  end
  local toa = norm("Table of Authorities" .. (groups[1] and (groups[1].label .. "Page(s)") or ""))
  needles[1] = table.concat({ "S:toa", "B", toa, toa }, "\t")
  local blocks, body_id, body_from = doc.blocks, nil, nil
  for bi, b in ipairs(blocks) do
    if b.t == "Div" and b.attr.attributes["custom-style"] == "TOAPlaceholder" then body_from = bi + 2 end
  end
  if not body_from then error("brief.lua: no table of authorities placeholder") end
  local function heading_text(h) return (h.label and (h.label .. " ") or "") .. plain(h.content) end
  for bi = body_from, #blocks do
    local b, h = blocks[bi], head_at[bi]
    if h then
      local nh = head_at[bi + 1]
      need(h.id, "B", heading_text(h), nh and heading_text(nh) or lead(blocks[bi + 1]))
      body_id = body_id or h.id
    elseif body_id == nil and norm(lead(b)) ~= "" then
      body_id = "S:body"
      need(body_id, "B", lead(b), "")
    end
    for _, c in ipairs(citations({ b }, "B", {})) do
      occurrences[#occurrences + 1] = { key = c.key, id = "T:" .. (#occurrences + 1) }
      need(occurrences[#occurrences].id, c.kind, c.text, c.context)
    end
  end
  needles[#needles + 1] = "#section\t" .. (body_id or "S:body") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", front.FOOTER_ID .. "\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", body_sect(front.FOOTER_ID))

  -- the printed pages of an authority: its distinct body pages, in order ("passim" from 7)
  local function pages_of(key)
    local seen, pages = {}, {}
    for _, o in ipairs(occurrences) do
      local p = P[o.id]
      if o.key == key and p and not seen[p.page] then seen[p.page] = true; pages[#pages + 1] = p end
    end
    if #pages == 0 then return "0" end
    if #pages >= 7 then return "passim" end
    table.sort(pages, function(x, y) return x.page < y.page end)
    local ls = {}
    for _, p in ipairs(pages) do ls[#ls + 1] = p.label end
    return table.concat(ls, ", ")
  end

  -- 2. the table of contents: levels 1-4 (typst toc-depth = 4), with the pages of the previous pass
  local function toc_blocks()
    local out = { para_div("FrontHeading", { pandoc.Str("Table of Contents") }) }
    out[#out + 1] = para_div("PageLabel", { pandoc.Strong(pandoc.Underline(pandoc.Str("Page"))) })
    for _, h in ipairs(heads) do
      if h.level <= 4 then
        local inl = {}
        if h.level == 1 then
          for _, x in ipairs(upper_inlines(h.content)) do inl[#inl + 1] = x end
        else
          inl[#inl + 1] = pandoc.Str(h.label)
          inl[#inl + 1] = TAB
          for _, x in ipairs(h.content) do inl[#inl + 1] = x end
        end
        inl[#inl + 1] = LEAD
        inl[#inl + 1] = TAB
        inl[#inl + 1] = pandoc.Str(label_of(h.id))
        out[#out + 1] = para_div(toc_style(h.level, h.in_arg, h.label ~= nil), inl)
      end
    end
    return out
  end

  -- 3. the table of authorities
  local function toa_blocks()
    local out = { para_div("FrontHeading", { pandoc.Str("Table of Authorities") }) }
    for gi, g in ipairs(groups) do
      local head = { pandoc.Strong(pandoc.Str(g.label)) }
      if gi == 1 then
        head[#head + 1] = TAB
        head[#head + 1] = pandoc.Strong(pandoc.Underline(pandoc.Str("Page(s)")))
      end
      out[#out + 1] = para_div(gi == 1 and "TOAGroupFirst" or "TOAGroup", head)
      for _, t in ipairs(g.members) do
        local pages = pages_of(t.key)
        local prun = pages == "passim" and xe.runs("passim", { i = true }) or xe.runs(pages)
        -- the cite wraps before the page column: 56 pt, or the page list's own width when longer (typst
        -- calc.max(toa-page-col, measure(page-text).width)); a section sign stays with its number
        local cite = joined(t.cite):gsub("§ ", "§\u{00A0}"):gsub("¶ ", "¶\u{00A0}")
        out[#out + 1] = xe.raw(xe.para({ xe.style("TOAEntry"), xe.ind(504, 504, nil, math.max(ACOL, page_width(pages))) },
          xe.runs(cite) .. xe.runs(xe.LEAD) .. prun))
      end
    end
    return out
  end

  -- 4. placeholders and link handling
  local final = {}
  for _, b in ipairs(body) do
    local placeholder = b.t == "Div" and b.attr.attributes["custom-style"] or nil
    if placeholder == "TOCPlaceholder" then
      for _, x in ipairs(toc_blocks()) do final[#final + 1] = x end
    elseif placeholder == "TOAPlaceholder" then
      for _, x in ipairs(toa_blocks()) do final[#final + 1] = x end
    else
      final[#final + 1] = b
    end
  end

  -- bullet items (interested parties): a bullet, a tab, then the text, in a hanging-indent style
  for i, b in ipairs(final) do
    if b.t == "Div" and b.attr.attributes["custom-style"] == "BulletItem" then
      local p = b.content[1]
      local inl = { pandoc.Str("\u{2022}"), TAB }
      for _, x in ipairs(p.content) do inl[#inl + 1] = x end
      final[i] = para_div("BulletItem", inl)
    elseif b.t == "Div" and b.attr.attributes["custom-style"] == "CertBox" then
      -- a certificate's check box: a ruled box around an X (a bordered run, typst checkbox), then a tab to the text
      local p = b.content[1]
      local c = p.content
      if not (c[1] and c[1].t == "Str" and c[1].text == "CHECKBOXMARK" and c[2] and c[2].t == "Space") then
        error("brief.lua: a check-box row must start with CHECKBOXMARK")
      end
      local inl = { pandoc.RawInline("openxml", xe.runs("X", { box = true })), TAB }
      for j = 3, #c do inl[#inl + 1] = c[j] end
      final[i] = para_div("CertBox", inl)
    end
  end

  local result = pandoc.Pandoc(final, doc.meta)
  -- citations are plain text: the toa: target is only a key for the table of authorities
  result = result:walk({
    Link = function(l)
      if l.target:match("^toa:") then return l.content end
      return nil
    end,
  })
  -- the break rules of typst on every run pandoc writes
  return result:walk({ Inlines = xe.inlines, Str = function(s) return pandoc.Str(joined(s.text)) end })
end

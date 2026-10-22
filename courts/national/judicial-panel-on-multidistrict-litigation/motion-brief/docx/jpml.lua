-- JPML motion-brief, DOCX engine (docs/DOCX.md): the markdown contract -> one Word document, laid out as the
-- typst template lays out its pages (typst/jpml-motion-brief.typ): the motion (numbered 1, 2), the memorandum
-- cover (unnumbered), the table of contents and table of authorities (roman), the memorandum body (arabic
-- from 1), its signature block and certificate of service.
--
-- Pandoc gives the body as paragraphs (Body Text, First Paragraph, Compact: double spaced, first line indent,
-- from reference.docx), headings as custom styles (JPML Heading 2..5: single spaced, hanging labels), footnotes
-- as native footnotes. Everything else (caption, counsel blocks, signature block, tables of contents and
-- authorities, certificate) is written here as OpenXML from the frontmatter, in the same styles' spacing.
-- Sections are set with sectPr paragraphs (the last one through fb render's FORMBOOK_FINAL); the footers are
-- reference.xml's rId100 (page number) and rId101 (empty).
--
-- Table of contents and table of authorities: static text (no TOC/TA field), so they show page numbers in any
-- viewer. The page numbers: fb render (tools/fb/src/docxpass.rs) renders the document once, finds where each heading
-- and each authority's link text lands in the LibreOffice PDF (the needles this filter writes to FORMBOOK_NEEDLES,
-- in document order), and renders again with those pages (FORMBOOK_PAGES) until they settle (fb-595.68.4: were
-- docx/render.sh and docx/pages.awk).
--
-- No case-specific text lives here: everything comes from the sample's frontmatter and markdown.

local stringify = pandoc.utils.stringify

local NEEDLES_OUT = os.getenv("FORMBOOK_NEEDLES")  -- written when set: "I:n<TAB>B<TAB>needle<TAB>needle"
local PAGES_IN = os.getenv("FORMBOOK_PAGES")       -- the previous pass's pages: "I:n<TAB>page<TAB>label"
-- the memorandum body's last section (arabic from 1, the page-number footer): pandoc writes its own final sectPr
local FINAL_SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr>'
local MARKER = "<!-- memorandum -->"
local PASSIM_AT = 7                            -- authority cited on this many pages or more: "passim"
local TOC_LEVELS = 4                           -- typst: headings up to level 4 are in the table of contents
local TAB = "<w:r><w:tab/></w:r>"
local FOOTER_NUM, FOOTER_NONE = "rId100", "rId101"

-- ---------------------------------------------------------------------------
-- OpenXML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  local t = s:gsub("&", "&amp;")
  t = t:gsub("<", "&lt;")
  t = t:gsub(">", "&gt;")
  return t
end

local function r(text, o)
  o = o or {}
  local rpr = ""
  if o.b then rpr = rpr .. "<w:b/><w:bCs/>" end
  if o.i then rpr = rpr .. "<w:i/><w:iCs/>" end
  return "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- spacing in twentieths of a point; rule "auto" uses line as 240ths of a line
local function sp(before, after, line, rule)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>',
    before, after, line, rule or "auto")
end
local SINGLE = sp(0, 0, 240, "auto")
local DOUBLE = sp(0, 0, 480, "exact")        -- 24 pt: the typst line-pitch (JPML-FORM-003)

-- paragraph properties, in schema order
local function pp(o)
  local x = ""
  if o.keep then x = x .. "<w:keepNext/>" end
  if o.keeplines then x = x .. "<w:keepLines/>" end
  if o.pbb then x = x .. "<w:pageBreakBefore/>" end
  if o.tabs then x = x .. o.tabs end
  if o.sp then x = x .. o.sp end
  if o.ind then x = x .. o.ind end
  if o.jc then x = x .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return x
end

local function para(inner, props)
  local ppr = props and pp(props) or ""
  return "<w:p>" .. (ppr ~= "" and ("<w:pPr>" .. ppr .. "</w:pPr>") or "") .. (inner or "") .. "</w:p>"
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function blank(props)
  props = props or {}
  props.sp = props.sp or DOUBLE
  return raw(para("", props))
end

-- v(length) in typst: an empty paragraph of exact height (twips)
local function gap(twips, keep)
  return raw(para("", { sp = sp(0, 0, twips, "exact"), keep = keep }))
end

local function tbl(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = string.format('<w:gridCol w:w="%d"/>', w)
  end
  local out = {}
  for _, row in ipairs(rows) do
    local cells = {}
    for i, c in ipairs(row) do
      cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>'
        .. (c.borders or "")
        .. (c.valign and ('<w:vAlign w:val="' .. c.valign .. '"/>') or "")
        .. "</w:tcPr>" .. c.paras .. "</w:tc>"
    end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. "</w:tblGrid>"
    .. table.concat(out) .. "</w:tbl>"
end

-- section break: the paragraph ends the section whose properties it carries
local function section_break(footer_rid, fmt)
  local sect = '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. string.format('<w:pgNumType w:fmt="%s" w:start="1"/>', fmt) .. '<w:cols w:space="720"/></w:sectPr>'
  -- a 1 pt empty paragraph, so the break cannot push a blank page
  return raw('<w:p><w:pPr>' .. sp(0, 0, 20, "exact") .. sect .. '</w:pPr></w:p>')
end

-- ---------------------------------------------------------------------------
-- Frontmatter values
-- ---------------------------------------------------------------------------

local function upper(s) return string.upper(s) end

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

-- heading label as typst numbers it: level 2 "I.", 3 "A.", 4 "1.", 5 "a."
local function heading_label(level, k)
  if level == 2 then return roman(k) .. "." end
  if level == 3 then return string.char(64 + k) .. "." end
  if level == 4 then return tostring(k) .. "." end
  if level == 5 then return string.char(96 + k) .. "." end
  return ""
end

local function is_toa(el)
  return type(el.target) == "string" and el.target:match("^toa:") ~= nil
end

local function toa_key(el) return el.target:match("^toa:(.+)$") end

-- ---------------------------------------------------------------------------
-- Pages from the first pass
-- ---------------------------------------------------------------------------

local pages = {}
if PAGES_IN and PAGES_IN ~= "" then
  local f = io.open(PAGES_IN, "r")
  if not f then error("jpml.lua: FORMBOOK_PAGES is set but cannot be read: " .. PAGES_IN) end
  for line in f:lines() do
    local n, label = line:match("^I:(%d+)\t[^\t]*\t(.*)$")
    if n then pages[tonumber(n)] = label end
  end
  f:close()
end

local function page_of(n)
  local p = pages[n]
  if p == nil then return "0" end  -- first pass only; the final build always has the page list
  return p
end

-- ---------------------------------------------------------------------------
-- Document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local M = doc.meta
  local function need(k)
    if M[k] == nil then error("jpml.lua: missing frontmatter field `" .. k .. "`") end
    return M[k]
  end
  local heading = upper(stringify(need("heading")))
  local mdl_no = stringify(need("mdl_no"))
  local in_re = upper(stringify(need("in_re")))
  local motion_title = upper(stringify(need("motion_title")))
  local brief_title = upper(stringify(need("brief_title")))
  local counsel_role = stringify(need("counsel_role"))
  local date = stringify(need("date"))
  local signer = stringify(need("signature").signer)

  local counsel = {}
  for _, blk in ipairs(need("counsel")) do
    local lines = {}
    for _, l in ipairs(blk) do lines[#lines + 1] = stringify(l) end
    counsel[#counsel + 1] = lines
  end

  local authorities = {}
  if M.authorities then
    for key, a in pairs(M.authorities) do
      authorities[key] = {
        kind = stringify(a.kind),
        name = a.name and stringify(a.name) or nil,
        cite = stringify(a.cite),
      }
    end
  end

  -- split the blocks at the marker (pandoc keeps the HTML comment as a raw block)
  local motion, memo, found = {}, {}, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "RawBlock" and b.format == "html" and b.text:match("^%s*<!%-%- memorandum %-%->%s*$") then
      if found then error("jpml.lua: more than one memorandum marker") end
      found = true
    elseif found then
      memo[#memo + 1] = b
    else
      motion[#motion + 1] = b
    end
  end
  if not found then error("jpml.lua: the sample has no line `" .. MARKER .. "`") end

  -- ---- the memorandum body: number the headings, collect the search items (document order) ----
  local items = {}
  local function add_item(it)
    items[#items + 1] = it
    it.n = #items
    return it
  end
  add_item({ kind = "T", needle = "Table of Authorities" })
  local first = memo[1]
  if not first then error("jpml.lua: the memorandum is empty") end
  add_item({ kind = "B", needle = string.sub(stringify(first), 1, 80) })

  local counters = { 0, 0, 0, 0, 0, 0 }
  local headings = {}   -- {level, label, text, item}
  local hits = {}       -- authority key -> list of items (document order)
  for _, b in ipairs(memo) do
    if b.t == "Header" then
      if b.level < 2 or b.level > 5 then error("jpml.lua: heading level " .. b.level .. " is not used by the template") end
      counters[b.level] = counters[b.level] + 1
      for k = b.level + 1, 5 do counters[k] = 0 end
      local text = stringify(b.content)
      local it = add_item({ kind = "H", needle = text })
      local h = { level = b.level, label = heading_label(b.level, counters[b.level]), text = text, item = it }
      headings[#headings + 1] = h
    end
    pandoc.Pandoc({ b }):walk({
      Link = function(el)
        if is_toa(el) then
          local key = toa_key(el)
          if authorities[key] == nil then
            error("jpml.lua: link toa:" .. key .. " has no entry under `authorities:` in the frontmatter")
          end
          local it = add_item({ kind = "L", needle = stringify(el.content), key = key })
          hits[key] = hits[key] or {}
          table.insert(hits[key], it)
        end
        return nil
      end,
    })
  end

  -- every item in document order, each searched after the one before; the body (kind B) is page 1
  if NEEDLES_OUT and NEEDLES_OUT ~= "" then
    local f = io.open(NEEDLES_OUT, "w")
    local body
    for _, it in ipairs(items) do
      local nd = it.needle:lower():gsub("[^a-z0-9]", "")
      if nd == "" then error("jpml.lua: empty needle for item " .. it.n) end
      f:write("I:", it.n, "\tB\t", nd, "\t", nd, "\n")
      if it.kind == "B" then body = body or it.n end
    end
    f:write("#section\tI:", body, "\tdecimal\t\n")
    f:close()
    local g = assert(io.open(os.getenv("FORMBOOK_FINAL"), "w"))
    g:write(FINAL_SECT)
    g:close()
  end

  -- distinct printed pages of an authority, in order
  local function key_pages(key)
    local seen, out = {}, {}
    for _, it in ipairs(hits[key] or {}) do
      local p = page_of(it.n)
      if not seen[p] then seen[p] = true; out[#out + 1] = p end
    end
    return out
  end

  -- ---- body blocks: links to authorities become plain text; headings become styled paragraphs with labels ----
  local body = {}
  local hi = 0
  for _, b in ipairs(memo) do
    if b.t == "Header" then
      hi = hi + 1
      local h = headings[hi]
      local inl = {}
      inl[#inl + 1] = pandoc.Str(h.label)
      inl[#inl + 1] = pandoc.RawInline("openxml", TAB)
      inl[#inl + 1] = pandoc.Strong(b.content)
      body[#body + 1] = pandoc.Div({ pandoc.Para(inl) },
        pandoc.Attr("", {}, { ["custom-style"] = "JPML Heading " .. b.level }))
    else
      local nb = pandoc.Pandoc({ b }):walk({
        Link = function(el)
          if is_toa(el) then return el.content end
          return nil
        end,
      })
      body[#body + 1] = nb.blocks[1]
    end
  end

  -- ---- the authorities list (typst groups, sorted by name or cite; only those cited) ----
  local toa_groups = {
    { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" },
    { "regulation", "Regulations" }, { "other", "Other Authorities" },
  }
  local function toa_xml()
    local out = {}
    local first_group = true
    for _, g in ipairs(toa_groups) do
      local members = {}
      for key, a in pairs(authorities) do
        if a.kind == g[1] and hits[key] then
          members[#members + 1] = { key = key, a = a, sort = string.lower(a.name or a.cite) }
        end
      end
      if #members > 0 then
        table.sort(members, function(x, y) return x.sort < y.sort end)
        out[#out + 1] = para(r(g[2], { b = true }), { keep = true, sp = sp(first_group and 240 or 336, 120, 240, "auto") })
        first_group = false
        for _, m in ipairs(members) do
          local pl = key_pages(m.key)
          local ptxt
          if #pl >= PASSIM_AT then ptxt = r("passim", { i = true }) else ptxt = r(table.concat(pl, ", ")) end
          local inner = ""
          if m.a.name then
            inner = r(m.a.name, { i = m.a.kind == "case" }) .. r(", ")
          end
          inner = inner .. r(m.a.cite) .. r(" ") .. TAB .. ptxt
          out[#out + 1] = para(inner, {
            sp = sp(120, 0, 240, "auto"),
            ind = '<w:ind w:left="504" w:right="864" w:hanging="504"/>',
            tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs>',
          })
        end
      end
    end
    return out
  end

  local function toc_xml()
    local out = {}
    for _, h in ipairs(headings) do
      if h.level <= TOC_LEVELS then
        local ind = (h.level - 2) * 720
        local inner = r(h.label) .. TAB .. r(h.text) .. TAB .. r(page_of(h.item.n))
        if h.label == "" then inner = r(h.text) .. TAB .. r(page_of(h.item.n)) end
        out[#out + 1] = para(inner, {
          sp = sp(108, 0, 240, "auto"),
          ind = string.format('<w:ind w:left="%d" w:right="576" w:hanging="720"/>', ind + 720),
          tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs>',
        })
      end
    end
    return out
  end

  -- ---- the case documents' fixed parts ----
  local function panel_heading()
    return raw(para(r(heading, { b = true }), { sp = SINGLE, jc = "center" }))
  end

  local function caption()
    local left = para(r("IN RE:"), { sp = SINGLE, ind = '<w:ind w:left="0" w:right="288"/>' })
      .. para(r(in_re, { b = true }), { sp = sp(0, 240, 240, "auto"), ind = '<w:ind w:left="0" w:right="288"/>' })
    local right = para(r(mdl_no), { sp = SINGLE, ind = '<w:ind w:left="288" w:right="0"/>', jc = "center" })
    return raw(tbl({ 6192, 3168 }, {
      {
        { paras = left, borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
          .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' },
        { paras = right, valign = "center" },
      },
    }))
  end

  -- counsel blocks in two columns (typst counsel-grid): block i goes to column i mod 2
  local function counsel_grid_xml()
    local cols = { {}, {} }
    for i, blk in ipairs(counsel) do
      local col = cols[((i - 1) % 2) + 1]
      for j, line in ipairs(blk) do
        local last = (j == #blk)
        col[#col + 1] = para(r(line), { sp = last and sp(0, 144, 240, "auto") or SINGLE })
      end
    end
    local function cell(list)
      local x = table.concat(list)
      if x == "" then x = para("", { sp = SINGLE }) end
      return x
    end
    return tbl({ 4464, 432, 4464 }, {
      { { paras = cell(cols[1]) }, { paras = para("", { sp = SINGLE }) }, { paras = cell(cols[2]) } },
    })
  end

  -- signature block (typst signature-block): one unbreakable row holding the dates and signature, the counsel
  -- blocks and the role line. A single row cannot split across pages, so the block moves whole, as in the typst form.
  local function signature_block()
    local left = para(r("Dated: " .. date), { sp = SINGLE })
    local right = para(r("Respectfully submitted,"), { sp = SINGLE })
      .. para(r("/s/ " .. signer), { sp = sp(480, 0, 240, "auto") })
    local inner = para("", { sp = DOUBLE })
      .. tbl({ 4752, 4608 }, { { { paras = left }, { paras = right } } })
      .. para("", { sp = DOUBLE })
      .. counsel_grid_xml()
      .. para("", { sp = sp(0, 0, 144, "exact") })
      .. para(r(counsel_role), { sp = SINGLE })
    return { raw(tbl({ 9360 }, { { { paras = inner } } })) }
  end

  local function certificate()
    return {
      raw(para(r("CERTIFICATE OF SERVICE", { b = true }), { keep = true, sp = sp(480, 240, 240, "auto"), jc = "center" })),
      raw(para(r("The undersigned hereby certifies that on " .. date .. ", a true and correct copy of the above and "
        .. "foregoing was filed with the Clerk of the Panel through CM/ECF, which will serve it electronically on all "
        .. "counsel of record."), { keep = true, sp = DOUBLE, ind = '<w:ind w:firstLine="720"/>' })),
      blank({ keep = true }),
      raw(para(r("By: /s/ " .. signer), { sp = SINGLE })),
    }
  end

  -- ---- assemble (page by page, as the typst template) ----
  local out = {}
  local function add(x) out[#out + 1] = x end
  local function add_all(list)
    for _, x in ipairs(list) do out[#out + 1] = type(x) == "string" and raw(x) or x end
  end

  -- the motion (pages 1 and 2)
  add(panel_heading())
  add(blank())
  add(caption())
  add(blank())
  add(raw(para(r(motion_title, { b = true }), { sp = SINGLE, jc = "center" })))
  add(blank())
  for _, b in ipairs(motion) do add(b) end
  add_all(signature_block())
  add(section_break(FOOTER_NUM, "decimal"))

  -- the memorandum cover (unnumbered)
  add(panel_heading())
  add(blank())
  add(caption())
  add(blank())
  add(raw(para(r(brief_title, { b = true }), { sp = SINGLE, jc = "center" })))
  add(blank())
  add(blank())
  add(raw(counsel_grid_xml()))
  add(gap(144))
  add(raw(para(r(counsel_role), { sp = SINGLE })))
  add(blank())
  add(raw(para(r("Dated: " .. date), { sp = SINGLE })))
  add(section_break(FOOTER_NONE, "decimal"))

  -- table of contents and table of authorities (roman)
  add(raw(para(r("TABLE OF CONTENTS", { b = true }), { sp = sp(0, 240, 240, "auto"), jc = "center" })))
  add(raw(para(r("Page", { b = true }), { sp = sp(0, 120, 240, "auto"), jc = "right" })))
  add_all(toc_xml())
  add(raw(para(r("TABLE OF AUTHORITIES", { b = true }), { pbb = true, sp = sp(0, 240, 240, "auto"), jc = "center" })))
  add(raw(para(r("Page(s)", { b = true }), { sp = sp(0, 120, 240, "auto"), jc = "right" })))
  add_all(toa_xml())
  add(section_break(FOOTER_NUM, "lowerRoman"))

  -- the memorandum body (arabic from 1), its signature block and certificate
  add_all(body)
  add_all(signature_block())
  add_all(certificate())

  return pandoc.Pandoc(out, pandoc.Meta({}))
end

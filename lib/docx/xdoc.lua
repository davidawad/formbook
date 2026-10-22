-- lib/docx/xdoc.lua: the shared document model (fb-595.54.12) in Word. A folder's docx/xdoc.lua, written by
-- `fb engines gen` from typst/layout.yaml, is `return require("docx.xdoc")(<layout>)`; its docx/reference.xml (the
-- styles, also generated) is the cross-engine recipe at the layout's sizes and pitches plus the styles named below.
-- Every block lib/typst/xdoc.typ sets is written here from the same tree (lib/pandoc/xdoc.lua), in twips (20 x pt):
--   par    a paragraph, exact line spacing at its pitch, its space before and after, indents, alignment;
--   rule   a paragraph of one twip with a top border of the stroke (LibreOffice: one twip plus the border);
--   cols   a one-row table that cannot split: fixed column widths, no cell margins except the gutter on the left
--          of every column after the first;
--   group  a one-cell table row that cannot split (typst: an unbreakable block).
-- The space between two blocks is the larger of the one's after and the other's before (LibreOffice collapses them,
-- as typst and \addvspace do); a table has no space of its own, so the space around it is an empty paragraph of
-- exact height (a spacer) or the next paragraph's before. The body is pandoc's: paragraphs in Body Text (Body Text
-- Note when they anchor a footnote: no widow control, as the latex engine), quotations in the XdQuote styles,
-- lists as List Item paragraphs (lib/docx/xengine.lua), headings written here; footnotes are Word's own.
local xe = require("docx.xengine")
local xd = require("pandoc.xdoc")

local function tw(x) return math.floor((tonumber(x) or 0) * 20 + 0.5) end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- inside a word before a letter ("CM/ECF": a zero-width space; not in "/s/", where neither engine breaks and the
-- space would split the word in the PDF text).
local function breaks(x)
  return pandoc.Str((x.text:gsub("%)%(", ")\u{2060}("):gsub("([^%s/])/(%a)", "%1/\u{200B}%2")))
end

-- A doubled section sign stays with its number, as typst binds it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local TBL = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
  .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
  .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" '
  .. 'w:noVBand="0"/>'

return function(spec)
  local TEXTW = tw(612 - spec.margin.left - spec.margin.right)

  -- An empty paragraph of exact height h twips (a spacer), or a one-twip one (an empty cell).
  local function spacer(h, keep)
    return xe.para({ keep and xe.KEEP or "", xe.spacing(0, 0, math.max(h, 1)) }, "")
  end

  local function par(n, before, after)
    local st = n.st
    local props = {}
    if st.keep then props[#props + 1] = xe.KEEP end
    props[#props + 1] = xe.spacing(before, after, tw(xd.pitch(spec, st.pitch)))
    local hang = tw(st.hang)
    local first
    if hang == 0 then first = tw(st.indent) end -- a hanging indent and a first-line one exclude each other
    props[#props + 1] = xe.ind(tw(st.left) + hang, hang > 0 and hang or nil, first,
      tw(st.right) > 0 and tw(st.right) or nil)
    props[#props + 1] = xe.jc(st.align == "center" and "center" or st.align == "right" and "right" or "left")
    local size = st.size and tw(st.size) // 10 or nil
    local text = n.text:walk({ Str = breaks })
    -- a heading's number (layout.yaml heading `number`): the label, a tab to the hanging indent, the text
    local label = n.label and (xe.runs(n.label, { b = st.bold, i = st.italic, sz = size }) .. "<w:r><w:tab/></w:r>") or ""
    return xe.para(props, label .. xe.inl(bind_double_signs(text), { b = st.bold, i = st.italic, u = st.underline, sz = size }))
  end

  local function rule(n, before, after)
    return xe.para({ '<w:pBdr><w:top w:val="single" w:sz="' .. math.floor(n.w * 8 + 0.5)
      .. '" w:space="0" w:color="000000"/></w:pBdr>', xe.spacing(before, after, tw(xd.RULE)) }, "")
  end

  local emit_list

  -- A table: one row that cannot split; `cells` = { { width = twips, left = twips, xml = .. }, .. }.
  local function table_row(cells)
    local grid, tcs = {}, {}
    for _, c in ipairs(cells) do
      grid[#grid + 1] = '<w:gridCol w:w="' .. c.width .. '"/>'
      local mar = c.left > 0 and ('<w:tcMar><w:left w:w="' .. c.left .. '" w:type="dxa"/></w:tcMar>') or ""
      if c.valign == "center" then mar = mar .. '<w:vAlign w:val="center"/>' end
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.width .. '" w:type="dxa"/>' .. mar .. '</w:tcPr>'
        .. c.xml .. '</w:tc>'
    end
    return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL .. '</w:tblPr><w:tblGrid>'
      .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs)
      .. '</w:tr></w:tbl>'
  end

  -- The cells' content: the nodes of a container, its last paragraph without space after (typst drops a block's
  -- space below at the end of a container).
  local function cell(items)
    local xml = emit_list(items, { prev_after = 0, pending = 0 }, true)
    -- a cell ends in a paragraph (a nested table is followed by a one-twip one)
    if #xml == 0 or xml[#xml]:sub(1, 6) == "<w:tbl" then xml[#xml + 1] = spacer(1) end
    return table.concat(xml)
  end

  local function columns(n)
    local cells, used = {}, 0
    local fixed = 0
    for i, c in ipairs(n.cols) do
      if c.width then fixed = fixed + tw(c.width) end
      if i > 1 then fixed = fixed + tw(n.gutter) end
    end
    local flex = 0
    for _, c in ipairs(n.cols) do if not c.width then flex = flex + 1 end end
    for i, c in ipairs(n.cols) do
      local gut = i > 1 and tw(n.gutter) or 0
      local w = c.width and tw(c.width) or math.floor((TEXTW - fixed) / math.max(flex, 1))
      cells[#cells + 1] = { width = w + gut, left = gut, valign = c.valign, xml = cell(c.items) }
      used = used + w + gut
    end
    cells[#cells].width = cells[#cells].width + (TEXTW - used)
    return table_row(cells)
  end

  -- Emit nodes in order; `s` carries the after of the last paragraph written (prev_after) and the space a table
  -- left to the next block (pending). In a container (`inner`) the last node has no space after.
  emit_list = function(items, s, inner)
    local out = {}
    for k, n in ipairs(items) do
      local last = inner and k == #items
      local above = math.max(tw(n.lead), tw(n.above))
      local after = last and 0 or tw(n.below)
      if n.t == "break" then
        -- a page break: an empty paragraph of one twip that starts a page (brk below)
        out[#out + 1] = xe.para({ xe.BREAK, xe.spacing(0, 0, 1) }, "")
        s.top, s.prev_after, s.pending = true, 0, 0
      elseif n.t == "par" or n.t == "rule" then
        local before = s.top and 0 or math.max(above, s.pending)
        s.top = false
        out[#out + 1] = (n.t == "par" and par or rule)(n, before, after)
        s.prev_after, s.pending = after, 0
      else
        local h = math.max(above, s.pending) - s.prev_after
        if h > 0 and not s.top then out[#out + 1] = spacer(h) end
        s.top = false
        if n.t == "cols" then
          out[#out + 1] = columns(n)
        else
          out[#out + 1] = table_row({ { width = TEXTW, left = 0, xml = cell(n.items) } })
        end
        s.prev_after, s.pending = 0, after
      end
    end
    return out
  end

  -- A heading of the body: a paragraph of its level's style, kept with the next.
  -- `first`: the heading opens the tail, whose own space above replaces the heading's (typst drops a block's space
  -- above at the start of a container).
  local function heading(b, first)
    local st = {}
    for k, v in pairs(xd.heading(spec, b.level)) do st[k] = v end
    st.keep = true
    local text = b.content
    if st.upper then text = xd.upper(text) end
    return { t = "par", text = text, st = st, lead = 0, above = first and 0 or tonumber(st.above) or 0,
      below = tonumber(st.below) or 0, label = b.attributes["xd-label"] }
  end

  local function has_note(inlines)
    for _, el in ipairs(inlines) do if el.t == "Note" then return true end end
    return false
  end

  local list_items, needles_of

  local function styled(style, inlines)
    return pandoc.Div({ pandoc.Para(inlines:walk({ Str = breaks }):walk({ Inlines = xe.inlines })) },
      { ["custom-style"] = style })
  end

  -- -------------------------------------------------------------------------------------------------------------
  -- Pages: contents and authorities (lib/typst/xdoc.typ contents-pages, authorities-pages). Word cannot know a page:
  -- every heading and every mark of an authority (lib/pandoc/xdoc.lua mark) is a needle, in document order, which
  -- fb render finds in the LibreOffice PDF of the previous pass and hands back in $FORMBOOK_PAGES (docxpass.rs,
  -- docxpages.rs); the first pass prints "00".
  -- -------------------------------------------------------------------------------------------------------------
  local needles, labels, hn, occ = {}, {}, 0, {}
  local NEEDLE = 48 -- reduced characters of a needle: the text and what follows it

  local function needle(id, kind, text, fallback)
    needles[#needles + 1] = id .. "\t" .. kind .. "\t" .. xd.norm(text):sub(1, NEEDLE) .. "\t" .. xd.norm(fallback or "")
  end

  local function read_pages()
    local path = os.getenv("FORMBOOK_PAGES")
    local f = path and path ~= "" and io.open(path, "r")
    if not f then return end
    for line in f:lines() do
      local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t([^\t]*)")
      if id then labels[id] = label end
    end
    f:close()
  end

  -- The text of inlines as printed, footnotes left out (their marks are digits Word sets apart).
  local function plain(x)
    if x == nil then return "" end
    local out = {}
    local function go(l)
      for _, el in ipairs(l) do
        if el.t == "Str" then out[#out + 1] = el.text
        elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then out[#out + 1] = " "
        elseif el.t ~= "Note" and el.content then go(el.content) -- italics, quotes, links: their words
        end
      end
    end
    if x.t == "Header" or x.t == "Para" or x.t == "Plain" then go(x.content)
    elseif x.t == "BlockQuote" or x.t == "Div" then for _, b in ipairs(x.content) do out[#out + 1] = plain(b) .. " " end
    elseif x.t == "BulletList" or x.t == "OrderedList" then
      for _, it in ipairs(x.content) do for _, b in ipairs(it) do out[#out + 1] = plain(b) .. " " end end
    end
    return table.concat(out)
  end

  -- The needles of a body block: a heading by its text and the text after it; each authority mark by its text and
  -- the words after it in its run (kind N in a footnote).
  -- The numbering of the page labels (docxpages.rs `#section`): a numbering starts at the page of a needle; the one
  -- wanted next (`want`) starts at the next needle written.
  local sections, want, pn = {}, nil, 0
  local function section_at(id)
    if want then sections[#sections + 1] = "#section\t" .. id .. "\t" .. want .. "\t"; want = nil end
  end

  function needles_of(b, nxt)
    if b.t == "Header" then
      hn = hn + 1
      needle("h" .. hn, "B", plain(b) .. " " .. plain(nxt), plain(b))
      section_at("h" .. hn)
    elseif want then
      pn = pn + 1
      needle("p" .. pn, "B", plain(b) .. " " .. plain(nxt), plain(b))
      section_at("p" .. pn)
    end
    b:walk({ Span = function(sp)
      local k = sp.attributes["xd-k"]
      if k then
        occ[k] = (occ[k] or 0) + 1
        local e = sp.attributes["xd-find"]
        needle("a" .. k .. "." .. occ[k], sp.attributes["xd-n"], e .. sp.attributes["xd-after"], e)
      end
    end })
  end

  -- A row of a table: the text wraps before a page column (a right indent of `col`), `hang` under its first line,
  -- `left` in; a dot leader from three spaces after the text to the page at the margin (typst listing-row).
  local function row(above, left, hang, col, xml, pages, pitch)
    local h = tw(hang)
    local first
    if h == 0 then first = 0 end
    return xe.para({ xe.LINES, xe.leader_tab(TEXTW), xe.spacing(tw(above), 0, tw(pitch)),
      xe.ind(tw(left) + h, h > 0 and h or nil, first, col) }, xml .. xe.runs(xe.LEAD .. pages))
  end

  -- The width of a page list in twips at the type size: Times New Roman's advances (digits 1/2 em, comma and space
  -- 1/4 em, hyphen 1/3 em), as typst measure() gives it.
  local function list_width(s)
    local em = 0
    for c in s:gmatch(".") do
      em = em + (c:match("%d") and 0.5 or c == "-" and 0.333 or 0.25)
    end
    return math.ceil(em * spec.size * 20)
  end

  local function table_title(t)
    local st = {}
    for k, v in pairs(xd.heading(spec, 1)) do st[k] = v end
    for k, v in pairs(t.style or {}) do st[k] = v end
    st.keep = true
    local text = xd.inlines(t.title)
    if st.upper then text = xd.upper(text) end
    return { t = "par", text = text, st = st, lead = 0, above = 0, below = tonumber(st.below) or 0 }
  end

  local function contents(c, heads, s)
    local out = emit_list({ table_title(c) }, s, false)
    local pitch = xd.pitch(spec, c.pitch)
    for _, h in ipairs(heads) do
      if h.level <= (c.depth or 3) then
        out[#out + 1] = row(c.above, (h.level - 1) * (tonumber(c.step) or 0), tonumber(c.hang) or 0,
          tw(c.col or 36), xe.inl(bind_double_signs(h.row:walk({ Str = breaks }))), labels["h" .. h.n] or "00", pitch)
      end
    end
    return out
  end

  local function authorities(a, meta, s, counts)
    local out = emit_list({ table_title(a) }, s, false)
    local gst = a.group or { bold = true }
    local pitch = xd.pitch(spec, a.pitch)
    local entries = xd.authority_entries(meta)
    local k = 0
    for _, g in ipairs(meta.authorities) do
      for _, x in ipairs(emit_list({ { t = "par", text = xd.inlines(g.heading),
        st = setmetatable({ keep = true }, { __index = gst }), lead = 0, above = gst.above, below = gst.below } }, s,
        false)) do out[#out + 1] = x end
      for _ = 1, #(g.entries or {}) do
        k = k + 1
        local e = entries[k]
        local ls = {}
        for i = 1, (counts[tostring(k)] or 0) do ls[#ls + 1] = labels["a" .. k .. "." .. i] or "00" end
        local list = xd.page_list(e, ls)
        out[#out + 1] = row(a.above, 0, tonumber(a.hang) or 0, math.max(tw(a.col or 56), list_width(list)),
          xe.inl(bind_double_signs(xd.inlines(e.cite):walk({ Str = breaks }))), list, pitch)
      end
    end
    s.prev_after = 0
    return out
  end

  -- A page break: an empty paragraph of one twip that starts a page; what follows has no space above (typst drops it
  -- at the top of a page, Word keeps it after a hard break).
  local function brk(s)
    s.top, s.prev_after, s.pending = true, 0, 0
    return xe.para({ xe.BREAK, xe.spacing(0, 0, 1) }, "")
  end

  -- The document's footer (the page number in a single line box, layout.yaml page_number) and last section, which a
  -- multi-pass build writes itself ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL; docxpass.rs).
  local function sect_xml(footer, fmt, first)
    local m = spec.margin
    local foot = tw(math.floor((0.7 * m.bottom - spec.pitch.single) * 20 + 0.5) / 20)
    return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
      .. (first and '<w:footerReference w:type="first" r:id="rIdXdNone"/>' or "")
      .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="' .. tw(m.top) .. '" w:right="' .. tw(m.right)
      .. '" w:bottom="' .. tw(m.bottom) .. '" w:left="' .. tw(m.left) .. '" w:header="720" w:footer="' .. foot
      .. '" w:gutter="0"/>' .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "")
      .. (first and "<w:titlePg/>" or "") .. "</w:sectPr>"
  end

  -- The end of a section (the cover, the tables numbered apart): an empty paragraph of one twip holding its sectPr;
  -- the next section starts a page.
  local function section_end(s, footer, fmt)
    s.top, s.prev_after, s.pending = true, 0, 0
    return '<w:p><w:pPr>' .. xe.spacing(0, 0, 1) .. sect_xml(footer, fmt, false) .. '</w:pPr></w:p>'
  end

  local WORD_FMT = { ["lower-roman"] = "lowerRoman", ["upper-roman"] = "upperRoman", decimal = "decimal" }

  local function write_section()
    local pn = spec.page_number or {}
    local single = tw(spec.pitch.single)
    local fld = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText>'
      .. '</w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
    local function ftr(runs_xml)
      return xe.para({ xe.spacing(0, 0, single), xe.jc(pn.align or "center") }, runs_xml)
    end
    local f = io.open(os.getenv("FORMBOOK_FOOTERS"), "w")
    f:write("rIdXdPage\t" .. ftr(fld) .. "\n" .. "rIdXdNone\t" .. ftr("") .. "\n")
    f:close()
    f = io.open(os.getenv("FORMBOOK_FINAL"), "w")
    f:write(sect_xml("rIdXdPage", pn.front and "decimal" or nil, (pn.from or 1) > 1))
    f:close()
  end

  -- A list at nesting `level` (lib/typst/xdoc.typ list-items): one paragraph per item in the level's style (the label,
  -- a tab to the hanging indent, the text; XdList1.. in the body, XdTailList1.. in the tail), nested lists after it.
  local markers = spec.list and spec.list.markers or { "\u{2022}" }
  function list_items(b, level, base)
    local out = pandoc.Blocks({})
    local n = b.t == "OrderedList" and b.listAttributes.start or 1
    local delim = b.t == "OrderedList" and b.listAttributes.delimiter or "Period"
    for _, item in ipairs(b.content) do
      local lab = markers[math.min(level + 1, #markers)]
      if b.t == "OrderedList" then
        lab = delim == "OneParen" and (n .. ")") or delim == "TwoParens" and ("(" .. n .. ")") or (n .. ".")
      end
      local inlines = pandoc.Inlines({ pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
      local subs = {}
      for k, blk in ipairs(item) do
        if k == 1 and (blk.t == "Plain" or blk.t == "Para") then inlines:extend(blk.content)
        elseif blk.t == "OrderedList" or blk.t == "BulletList" then subs[#subs + 1] = blk
        else error("xdoc: a list item holds one paragraph and nested lists", 0) end
      end
      out:insert(styled(base .. math.min(level + 1, 3), inlines))
      for _, sb in ipairs(subs) do out:extend(list_items(sb, level + 1, base)) end
      n = n + 1
    end
    return out
  end

  -- The body blocks as Word paragraphs; `para` the style of a plain paragraph (Body Text, or XdTail in the tail).
  local function body(blocks, s, para, first)
    local out = pandoc.Blocks({})
    local function raw(xml) out:insert(xe.raw(xml)) end
    local function flush()
      if s.pending > s.prev_after and not s.top then raw(spacer(s.pending - s.prev_after)) end
      s.pending, s.top = 0, false
    end
    for k, b in ipairs(blocks) do
      needles_of(b, blocks[k + 1])
      if b.t == "Header" then
        for _, x in ipairs(emit_list({ heading(b, first and k == 1) }, s, false)) do raw(x) end
      elseif b.t == "Para" or b.t == "Plain" then
        flush()
        out:insert(styled(para == "Body Text" and has_note(b.content) and "Body Text Note" or para, b.content))
        s.prev_after = para == "Body Text" and 0 or tw(spec.tail and spec.tail.gap)
      elseif b.t == "BlockQuote" then
        flush()
        local ps = b.content
        for i, q in ipairs(ps) do
          if q.t ~= "Para" and q.t ~= "Plain" then error("xdoc: a quotation holds paragraphs only", 0) end
          local style = #ps == 1 and "XdQuoteOnly" or i == 1 and "XdQuoteFirst" or i == #ps and "XdQuoteLast"
            or "XdQuote"
          out:insert(styled(style, q.content))
        end
        s.prev_after = tw(spec.quote and spec.quote.below)
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        flush()
        out:extend(list_items(b, 0, para == "Body Text" and "XdList" or "XdTailList"))
        s.prev_after = 0
      else
        error("xdoc: unsupported block " .. b.t, 0)
      end
    end
    return out
  end

  return {
    {
      Pandoc = function(doc)
        local meta = xd.context(spec, xd.meta())
        local entries = xd.authority_entries(meta)
        -- a URL's break opportunities (lib/pandoc/xengine.lua urls; lib/typst/xdoc.typ sets the same)
        local blocks = xd.mark(xd.commonmark_lists(doc.blocks):walk({ Inlines = require("pandoc.xengine").urls }):walk({ Inlines = bind_double_signs }), entries, function(k, note, after)
          return pandoc.Span({}, { ["xd-k"] = tostring(k), ["xd-n"] = note and "N" or "B", ["xd-after"] = after,
            ["xd-find"] = entries[k].find })
        end)
        xd.number_headings(spec, blocks)
        local main, rest = xd.split_tail(spec, blocks)
        local s = { prev_after = 0, pending = 0 }
        local out = pandoc.Blocks({})
        local paged = spec.contents or (spec.authorities and meta.authorities)
        if paged then
          read_pages()
          -- the numbering starts at the first line of the document (page 1)
          local first = xd.tree(spec, spec.cover or spec.front or {}, meta, true)[1]
          needle("start", "B", first and first.text and pandoc.utils.stringify(first.text) or "", "")
          local front = spec.page_number and spec.page_number.front
          if not front then sections[1] = "#section\tstart\tdecimal\t" end
          -- how often each authority is marked (its rows read one page per mark)
          local counts = {}
          blocks:walk({ Span = function(sp) local k = sp.attributes["xd-k"]
            if k then counts[k] = (counts[k] or 0) + 1 end end })
          local heads = xd.headings(blocks, 9)
          if spec.cover then
            for _, x in ipairs(emit_list(xd.tree(spec, spec.cover, meta, true), s, false)) do out:insert(xe.raw(x)) end
            -- the cover a section of its own (no page number) when the tables are numbered apart
            out:insert(xe.raw(front and section_end(s, "rIdXdNone", nil) or brk(s)))
          end
          if front then
            -- the tables' numbering starts at the first of them: its title and its first row
            local t = spec.contents or spec.authorities
            local h1 = heads[1] and plain({ t = "Plain", content = heads[1].content }) or ""
            needle("front", "B", t.title .. " " .. (spec.contents and h1 or ""), t.title)
            sections[#sections + 1] = "#section\tfront\t" .. front .. "\t"
          end
          if spec.contents then
            for _, x in ipairs(contents(spec.contents, heads, s)) do out:insert(xe.raw(x)) end
          end
          if spec.authorities and meta.authorities then
            out:insert(xe.raw(brk(s)))
            for _, x in ipairs(authorities(spec.authorities, meta, s, counts)) do out:insert(xe.raw(x)) end
          end
          if front then
            out:insert(xe.raw(section_end(s, "rIdXdPage", WORD_FMT[front])))
            want = "decimal" -- the body from 1, at its first needle
          else
            out:insert(xe.raw(brk(s)))
          end
        end
        for _, x in ipairs(emit_list(xd.tree(spec, spec.front, meta, true), s, false)) do out:insert(xe.raw(x)) end
        out:extend(body(main, s, "Body Text"))
        for _, x in ipairs(emit_list(xd.tree(spec, spec.closing, meta, false), s, false)) do
          out:insert(xe.raw(x))
        end
        if #rest > 0 then
          if spec.tail["break"] then out:insert(xe.raw(brk(s))) end
          s.pending = math.max(tw(spec.tail.above), s.pending)
          out:extend(body(rest, s, "XdTail", true))
        end
        if paged then
          local f = io.open(os.getenv("FORMBOOK_NEEDLES"), "w")
          f:write(table.concat(sections, "\n") .. "\n" .. table.concat(needles, "\n") .. "\n")
          f:close()
          write_section()
        end
        return pandoc.Pandoc(out, pandoc.Meta({}))
      end,
    },
  }
end

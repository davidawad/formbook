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
    if hang == 0 then first = 0 end -- a hanging indent and a first-line one exclude each other
    props[#props + 1] = xe.ind(tw(st.left) + hang, hang > 0 and hang or nil, first,
      tw(st.right) > 0 and tw(st.right) or nil)
    props[#props + 1] = xe.jc(st.align == "center" and "center" or st.align == "right" and "right" or "left")
    local size = st.size and tw(st.size) // 10 or nil
    local text = n.text:walk({ Str = breaks })
    return xe.para(props, xe.inl(bind_double_signs(text), { b = st.bold, i = st.italic, u = st.underline, sz = size }))
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
      cells[#cells + 1] = { width = w + gut, left = gut, xml = cell(c.items) }
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
      if n.t == "par" or n.t == "rule" then
        local before = math.max(above, s.pending)
        out[#out + 1] = (n.t == "par" and par or rule)(n, before, after)
        s.prev_after, s.pending = after, 0
      else
        local h = math.max(above, s.pending) - s.prev_after
        if h > 0 then out[#out + 1] = spacer(h) end
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
  local function heading(b)
    local st = {}
    for k, v in pairs(xd.heading(spec, b.level)) do st[k] = v end
    st.keep = true
    local text = b.content
    if st.upper then text = xd.upper(text) end
    return { t = "par", text = text, st = st, lead = 0, above = tonumber(st.above) or 0,
      below = tonumber(st.below) or 0 }
  end

  local function has_note(inlines)
    for _, el in ipairs(inlines) do if el.t == "Note" then return true end end
    return false
  end

  local function styled(style, inlines)
    return pandoc.Div({ pandoc.Para(inlines:walk({ Str = breaks }):walk({ Inlines = xe.inlines })) },
      { ["custom-style"] = style })
  end

  -- The body blocks as Word paragraphs; `para` the style of a plain paragraph (Body Text, or XdTail in the tail).
  local function body(blocks, s, para)
    local out = pandoc.Blocks({})
    local function raw(xml) out:insert(xe.raw(xml)) end
    local function flush()
      if s.pending > 0 then raw(spacer(s.pending)); s.pending = 0 end
    end
    for _, b in ipairs(blocks) do
      if b.t == "Header" then
        for _, x in ipairs(emit_list({ heading(b) }, s, false)) do raw(x) end
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
        for _, d in ipairs(xe.list_items(b)) do
          if d.t ~= "Div" then error("xdoc: a list item holds one paragraph", 0) end
          d.content[1].content = d.content[1].content:walk({ Str = breaks }):walk({ Inlines = xe.inlines })
          out:insert(d)
        end
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
        local meta = xd.meta()
        local main, rest = xd.split_tail(spec, doc.blocks:walk({ Inlines = bind_double_signs }))
        local s = { prev_after = 0, pending = 0 }
        local out = pandoc.Blocks({})
        for _, x in ipairs(emit_list(xd.tree(spec, spec.front, meta, true), s, false)) do out:insert(xe.raw(x)) end
        out:extend(body(main, s, "Body Text"))
        for _, x in ipairs(emit_list(xd.tree(spec, spec.closing, meta, false), s, false)) do
          out:insert(xe.raw(x))
        end
        if #rest > 0 then
          local h = math.max(tw(spec.tail.above), s.pending) - s.prev_after
          if h > 0 then out:insert(xe.raw(spacer(h))) end
          s.pending = 0
          out:extend(body(rest, s, "XdTail"))
        end
        return pandoc.Pandoc(out, pandoc.Meta({}))
      end,
    },
  }
end

-- lib/docx/xdoc.lua: the shared document model (fb-595.54.12) in Word. A folder's docx/xdoc.lua, written by
-- `fb engines gen` from typst/layout.yaml, is `return require("docx.xdoc")(<layout>)`; its docx/reference.xml (the
-- styles, also generated) is the cross-engine recipe at the layout's sizes and pitches plus the styles named below.
-- Every block lib/typst/xdoc.typ sets is written here from the same tree (lib/pandoc/xdoc.lua), in twips (20 x pt):
--   par    a paragraph, exact line spacing at its pitch, its space before and after, indents, alignment;
--   rule   a paragraph of one twip with a top border of the stroke (LibreOffice: one twip plus the border);
--   cols   a one-row table that cannot split: fixed column widths, no cell margins except the gutter on the left
--          of every column after the first;
--   group  a one-cell table row that cannot split (typst: an unbreakable block).
--   box    a one-cell table with the box's borders, cell margins (its insets) and row height;
--   fill   an empty paragraph of exact height: its share of what the page leaves, measured in the pass before (plan)
-- The space between two blocks is the larger of the one's after and the other's before (LibreOffice collapses them,
-- as typst and \addvspace do); a table has no space of its own, so the space around it is an empty paragraph of
-- exact height (a spacer) or the next paragraph's before. The body is pandoc's: paragraphs in Body Text (Body Text
-- Note when they anchor a footnote: no widow control, as the latex engine), quotations in the XdQuote styles,
-- lists as List Item paragraphs (lib/docx/xengine.lua), headings written here; footnotes are Word's own.
local xe = require("docx.xengine")
local xd = require("pandoc.xdoc")
local common = require("pandoc.xengine")

local function tw(x) return math.floor((tonumber(x) or 0) * 20 + 0.5) end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- inside a word before a letter ("CM/ECF": a zero-width space; not in "/s/", where neither engine breaks and the
-- space would split the word in the PDF text).
-- And one after a hyphen that starts a word before a letter ("social -media"): typst breaks there, LibreOffice does not
-- (Unicode 15.1 LB20a).
local function breaks(x)
  -- a URL breaks only between its pieces (lib/pandoc/xdoc.lua url_pieces), as typst and LaTeX break it; a hyphen before
  -- a digit inside a piece is held by a word joiner, not Word's no-break hyphen (lib/docx/xengine.lua), which LibreOffice
  -- broke a piece at when it ran over a line ("8796-5576b" in a table row)
  local pre, pieces, post = xd.url_pieces(x.text)
  if pre then
    for i, p in ipairs(pieces) do pieces[i] = p:gsub("%-(%d)", "-\u{2060}%1") end
    return pandoc.Str(pre .. table.concat(pieces, "\u{200B}") .. post)
  end
  return pandoc.Str((x.text:gsub("%)%(", ")\u{2060}("):gsub("([^%s/])/(%a)", "%1/\u{200B}%2"):gsub("^%-(%a)", "-\u{200B}%1")))
end

-- The space before a closing mark that must not break (xd.bind_punct): a no-break space, or in a face whose space is a
-- quarter em (Times New Roman: the layout has no face_advances) a four-per-em space and a word joiner. LibreOffice
-- breaks a line at a no-break space when a run of them overflows (". . . ." after a word), and fits such a run as if it
-- were wider; it keeps the joiner (fb-595.54.16, measured).
local GLUE = "\u{00A0}"

-- A doubled section sign stays with its number, no line breaks before a closing mark (lib/pandoc/xdoc.lua
-- bind_double_signs, bind_punct), hyphen runs as CommonMark sets them (lib/pandoc/xengine.lua dashes).
local function bind_double_signs(l)
  return xd.bind_punct(xd.bind_double_signs(common.dashes(l)), function() return pandoc.Str(GLUE) end)
end

local TBL = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
  .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
  .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" '
  .. 'w:noVBand="0"/>'

return function(spec)
  GLUE = spec.face_advances == nil and "\u{2005}\u{2060}" or "\u{00A0}"
  local PAGE_W, PAGE_H = xd.paper(spec)
  local TEXTW = tw(PAGE_W - spec.margin.left - spec.margin.right)

  -- An empty paragraph of exact height h twips (a spacer), or a one-twip one (an empty cell).
  local function spacer(h, keep)
    return xe.para({ keep and xe.KEEP or "", xe.spacing(0, 0, math.max(h, 1)) }, "")
  end

  -- A footnote in a paragraph written as raw XML (a heading, a block of the layout): Word's footnotes are pandoc's
  -- to write (footnotes.xml), so the paragraph's runs carry a mark for each one, and raw_block hands the paragraph to
  -- pandoc as a Para of raw runs around its Notes, in the paragraph style Xd Note Host. Pandoc writes that style's
  -- <w:pPr> before the paragraph's own; fb render drops it (docxpass.rs drop_note_host) (fb-595.89).
  local notes = {}
  local function note_mark(note)
    -- its text under the break rules of the body's footnotes (styled)
    notes[#notes + 1] = note:walk({ Inlines = xe.inlines })
    return "<!--xd-note:" .. #notes .. "-->"
  end
  local function raw_block(xml)
    if not xml:find("<!--xd-note:", 1, true) then return xe.raw(xml) end
    local inner = xml:match("^<w:p>(.*)</w:p>$")
    -- a paragraph in a table (a cell, a box, a group) has no Para of its own to hold the Note
    if not inner or inner:find("<w:p>", 1, true) or inner:find("<w:tbl>", 1, true) then
      error("xdoc: a footnote in a table, box or group of the layout is not supported in Word", 0)
    end
    local ils, pos = pandoc.Inlines({}), 1
    for a, k, b in inner:gmatch("()<!%-%-xd%-note:(%d+)%-%->()") do
      ils:insert(pandoc.RawInline("openxml", xe.bind_raw(inner:sub(pos, a - 1))))
      ils:insert(notes[tonumber(k)])
      pos = b
    end
    ils:insert(pandoc.RawInline("openxml", xe.bind_raw(inner:sub(pos))))
    return pandoc.Div({ pandoc.Para(ils) }, { ["custom-style"] = "Xd Note Host" })
  end

  local bmid = 9000 -- bookmark ids (pandoc numbers its own from 0)
  local function par(n, before, after)
    local st = n.st
    local props = {}
    if st.keep then props[#props + 1] = xe.KEEP end
    if n.right then props[#props + 1] = '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>' end
    props[#props + 1] = xe.spacing(before, after, tw(xd.pitch(spec, st.pitch)))
    local hang = tw(st.hang)
    local first
    if hang == 0 then first = tw(st.indent) end -- a hanging indent and a first-line one exclude each other
    props[#props + 1] = xe.ind(tw(st.left) + hang, hang > 0 and hang or nil, first,
      tw(st.right) > 0 and tw(st.right) or nil)
    props[#props + 1] = xe.jc(st.align == "center" and "center" or st.align == "right" and "right" or "left")
    local size = st.size and tw(st.size) // 10 or nil
    local text = n.text:walk({ Str = breaks })
    local o = { b = st.bold, i = st.italic, u = st.underline, sz = size, note = note_mark }
    local runs = xe.inl(bind_double_signs(text), o)
    -- a numbered heading's label, a tab to its box (the hanging indent) or a space
    if n.label then runs = xe.runs(n.label .. (n.labeltab and "\t" or " "), o) .. runs end
    -- text at the right margin after a tab (the page heading of a table of authorities)
    if n.right then runs = runs .. xe.runs("\t" .. n.right, o) end
    -- a bookmark that measures the paragraph (repeat_count): at its start (its first line) or its end (its last)
    local function bm(name) bmid = bmid + 1; return '<w:bookmarkStart w:id="' .. bmid .. '" w:name="' .. name
      .. '"/><w:bookmarkEnd w:id="' .. bmid .. '"/>' end
    return xe.para(props, (n.bm_start and bm(n.bm_start) or "") .. runs .. (n.bm_end and bm(n.bm_end) or ""))
  end

  local function rule(n, before, after)
    -- a rule of 0: the one-twip paragraph without a border
    local border = n.w > 0 and ('<w:pBdr><w:top w:val="single" w:sz="' .. math.floor(n.w * 8 + 0.5)
      .. '" w:space="0" w:color="000000"/></w:pBdr>') or ""
    return xe.para({ border, xe.spacing(before, after, tw(xd.RULE)) }, "")
  end

  local emit_list
  local repeat_count -- the lines of a `repeat` column (with the needles, below)
  local on_head -- a layout heading's needle (with the needles, below)

  -- A table: one row that cannot split; `cells` = { { width = twips, left = twips, xml = .. }, .. }.
  local function table_row(cells, width)
    local grid, tcs = {}, {}
    for _, c in ipairs(cells) do
      grid[#grid + 1] = '<w:gridCol w:w="' .. c.width .. '"/>'
      local mar = c.left > 0 and ('<w:tcMar><w:left w:w="' .. c.left .. '" w:type="dxa"/></w:tcMar>') or ""
      if c.valign == "center" then mar = mar .. '<w:vAlign w:val="center"/>' end
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.width .. '" w:type="dxa"/>' .. mar .. '</w:tcPr>'
        .. c.xml .. '</w:tc>'
    end
    return '<w:tbl><w:tblPr><w:tblW w:w="' .. (width or TEXTW) .. '" w:type="dxa"/>' .. TBL .. '</w:tblPr><w:tblGrid>'
      .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs)
      .. '</w:tr></w:tbl>'
  end

  -- The cells' content: the nodes of a container `width` twips wide, its last paragraph without space after (typst
  -- drops a block's space below at the end of a container).
  local function cell(items, width)
    local xml = emit_list(items, { prev_after = 0, pending = 0, width = width }, true)
    -- a cell ends in a paragraph (a nested table is followed by a one-twip one)
    if #xml == 0 or xml[#xml]:sub(1, 6) == "<w:tbl" then xml[#xml + 1] = spacer(1) end
    return table.concat(xml)
  end

  -- A row of columns in a container `W` twips wide (the text, or a cell that holds the row).
  local function columns(n, W)
    W = W or TEXTW
    local cells, used = {}, 0
    local fixed = 0
    for i, c in ipairs(n.cols) do
      if c.width then fixed = fixed + tw(c.width) end
      if i > 1 then fixed = fixed + tw(n.gutter) end
    end
    local flex = 0
    for _, c in ipairs(n.cols) do if not c.width then flex = flex + 1 end end
    local count -- a `repeat` column's lines: measured in the pass before (repeat_count)
    for _, c in ipairs(n.cols) do if c["repeat"] then count = count or repeat_count(n) end end
    for i, c in ipairs(n.cols) do
      local gut = i > 1 and tw(n.gutter) or 0
      local w = c.width and tw(c.width) or math.floor((W - fixed) / math.max(flex, 1))
      local xml
      if c["repeat"] then
        local r = c["repeat"]
        local p = par({ t = "par", text = r.text, st = r.st, lead = 0, above = 0, below = 0 }, 0, 0)
        xml = count > 0 and string.rep(p, count) or spacer(1)
      else
        xml = cell(c.items, w)
      end
      cells[#cells + 1] = { width = w + gut, left = gut, valign = c.valign, xml = xml }
      used = used + w + gut
    end
    cells[#cells].width = cells[#cells].width + (W - used)
    return table_row(cells, W)
  end

  -- A ruled box: a one-cell table `width` twips wide (the container's unless the box gives one), its borders the
  -- box's strokes, its cell margins the insets, an exact row height when the box has one, the blocks at its valign.
  local function rbox(n, width)
    local W = n.width and tw(n.width) or width
    local st, i = n.stroke, n.inset
    local function border(side, w)
      if w <= 0 then return '<w:' .. side .. ' w:val="nil"/>' end
      return '<w:' .. side .. ' w:val="single" w:sz="' .. math.floor(w * 8 + 0.5) .. '" w:space="0" w:color="000000"/>'
    end
    local function mar(side, x) return '<w:' .. side .. ' w:w="' .. tw(x) .. '" w:type="dxa"/>' end
    return '<w:tbl><w:tblPr><w:tblW w:w="' .. W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders>'
      .. border("top", st.t) .. border("left", st.l) .. border("bottom", st.b) .. border("right", st.r)
      .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar>' .. mar("top", i.t) .. mar("left", i.l)
      .. mar("bottom", i.b) .. mar("right", i.r) .. '</w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" '
      .. 'w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>'
      .. '<w:gridCol w:w="' .. W .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/>'
      .. (n.height and ('<w:trHeight w:val="' .. tw(n.height) .. '" w:hRule="exact"/>') or "")
      .. '</w:trPr><w:tc><w:tcPr><w:tcW w:w="' .. W .. '" w:type="dxa"/>'
      .. (n.valign ~= "top" and ('<w:vAlign w:val="' .. n.valign .. '"/>') or "") .. '</w:tcPr>'
      .. cell(n.items, W - tw(i.l) - tw(i.r)) .. '</w:tc></w:tr></w:tbl>'
  end

  -- Emit nodes in order; `s` carries the after of the last paragraph written (prev_after) and the space a table
  -- left to the next block (pending). In a container (`inner`) the last node has no space after.
  emit_list = function(items, s, inner)
    -- a block of the layout ends the body's run of paragraphs and lists (body: s.flow)
    if #items > 0 then s.flow = nil end
    local out = {}
    for k, n in ipairs(items) do
      local last = inner and k == #items
      local above = math.max(tw(n.lead), tw(n.above))
      local after = last and 0 or tw(n.below)
      if n.t == "break" then
        -- a page break: an empty paragraph of one twip that starts a page (brk below)
        out[#out + 1] = xe.para({ xe.BREAK, xe.spacing(0, 0, 1) }, "")
        s.top, s.prev_after, s.pending = true, 0, 0
      elseif n.t == "fill" then
        -- space that fills the page: a spacer of the height plan() measured for it (one twip until measured)
        out[#out + 1] = spacer(n.h or 1)
        s.top, s.prev_after, s.pending = false, 0, 0
      elseif n.t == "par" or n.t == "rule" then
        local before = s.top and 0 or math.max(above, s.pending)
        s.top = false
        s.keepnext = nil
        if n.head then on_head(n, items[k + 1]) end
        out[#out + 1] = (n.t == "par" and par or rule)(n, before, after)
        s.prev_after, s.pending = after, 0
      else
        local h = math.max(above, s.pending) - s.prev_after
        if h > 0 and not s.top then out[#out + 1] = spacer(h, s.keepnext) end
        s.top, s.keepnext = false, nil
        if n.t == "cols" then
          out[#out + 1] = columns(n, s.width or TEXTW)
        elseif n.t == "box" then
          out[#out + 1] = rbox(n, s.width or TEXTW)
        else
          -- a group: a one-cell table of the container's width (the text, or the cell that holds it)
          local W = s.width or TEXTW
          out[#out + 1] = table_row({ { width = W, left = 0, xml = cell(n.items, W) } }, W)
        end
        s.prev_after, s.pending = 0, after
      end
    end
    return out
  end

  -- A heading of the body: a paragraph of its level's style, kept with the next.
  -- `first`: the heading opens the tail, whose own space above replaces the heading's (typst drops a block's space
  -- above at the start of a container).
  -- The nodes of a heading: its label (xd.heading_labels) on a line of its own (`label_line`), or before its text, a
  -- tab to the hanging indent of its label box (xd.label_width; Word's tab stop there) or a space.
  local hlabels, hcount = {}, 0
  local function heading(b, first)
    local st = {}
    for k, v in pairs(xd.heading(spec, b.level)) do st[k] = v end
    st.keep = true
    local text = b.content
    if st.upper then text = xd.upper(text) end
    hcount = hcount + 1
    local lab = hlabels[hcount]
    local above, below = first and 0 or tonumber(st.above) or 0, tonumber(st.below) or 0
    if lab and st.label_line then
      return { { t = "par", text = pandoc.Inlines({ pandoc.Str(lab) }), st = st, lead = 0, above = above, below = 0 },
        { t = "par", text = text, st = st, lead = 0, above = 0, below = below } }
    end
    local w = lab and xd.label_width(st)
    if w then st.hang = w end
    return { { t = "par", text = text, st = st, lead = 0, above = above, below = below, label = lab,
      labeltab = w ~= nil } }
  end

  -- a footnote anywhere in the paragraph (inside emphasis or a link too)
  local function has_note(inlines)
    local found = false
    pandoc.Inlines(inlines):walk({ Note = function() found = true end })
    return found
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
  local needles, labels, ylabels, hn, occ = {}, {}, {}, 0, {}
  local measured = false -- a fill wrote position needles: the passes run, as for the tables
  local NEEDLE = 48 -- reduced characters of a needle: the text and what follows it

  -- (`len`: the reduced characters kept, NEEDLE unless given; `upto`: an authority's fallback up to its mark, when the
  -- mark is not at its end, a keyed authority's first word)
  local function needle(id, kind, text, fallback, len, upto)
    needles[#needles + 1] = id .. "\t" .. kind .. "\t" .. xd.norm(text):sub(1, len or NEEDLE) .. "\t"
      .. xd.norm(fallback or "") .. (upto and ("\t" .. xd.norm(upto)) or "")
  end

  local function read_pages()
    local path = os.getenv("FORMBOOK_PAGES")
    local f = path and path ~= "" and io.open(path, "r")
    if not f then return end
    for line in f:lines() do
      local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t([^\t]*)")
      if id then labels[id] = label end
      local base, fills
      if id then base, fills = id:match("^(Y[%d.]+):(%d+)$") end
      if base then ylabels[base] = { y = tonumber(label), fills = tonumber(fills) } end
    end
    f:close()
  end

  -- -------------------------------------------------------------------------------------------------------------
  -- Fills (lib/typst/xdoc.typ v(1fr)). Word has no space that fills a page: each pass writes, for every page of a
  -- page's own blocks that holds a fill, a needle for the first line of its first paragraph (kind T) and for the last
  -- line of each paragraph that ends the page's last block (kind Y, its id carrying the height of the fills above
  -- it in this pass); fb render finds their lines in the LibreOffice PDF (docxpages.rs: the line's yMax, points from
  -- the page top), and the next pass shares out what the page leaves below the blocks' own height. The first line's
  -- yMax against its known top gives the face's descent as LibreOffice's PDF reports it; the pages settle on the
  -- pass after the fills are first set.
  -- -------------------------------------------------------------------------------------------------------------
  local FILL_SAFETY = 0.5 -- points left under the last line: LibreOffice rounds a line's place to the twip
  local DESCENT = 0.216 -- the descent of the face when no first line measures it (Liberation Serif)
  local NEEDLE_END = 16 -- reduced characters of a position needle
  local fillseg = 0

  -- the paragraphs whose line boxes end a node: itself, or the last one of each column or group
  local last_pars
  local function last_of(items)
    for i = #items, 1, -1 do
      if items[i].t ~= "rule" and items[i].t ~= "fill" and items[i].t ~= "break" then return last_pars(items[i]) end
    end
    return {}
  end
  last_pars = function(n)
    if n.t == "par" then return { n } end
    local out = {}
    if n.t == "cols" then
      for _, c in ipairs(n.cols) do for _, p in ipairs(last_of(c.items)) do out[#out + 1] = p end end
    elseif n.t == "group" or n.t == "box" then
      out = last_of(n.items)
    end
    return out
  end

  local function ptext(n) return xd.norm(pandoc.utils.stringify(n.text)) end

  -- The pages of `nodes` (a page's own blocks, from a page start: `top`, a page Word starts after a break) that hold a
  -- fill: each fill gets its height `h` (twips) from the pages of the last pass, and the position needles.
  local function plan(nodes, top)
    local seg, segs = {}, {}
    for _, n in ipairs(nodes) do
      if n.t == "break" then segs[#segs + 1] = seg; seg = {} else seg[#seg + 1] = n end
    end
    segs[#segs + 1] = seg
    for si, sg in ipairs(segs) do
      local fills, w = {}, 0
      for _, n in ipairs(sg) do if n.t == "fill" then fills[#fills + 1] = n; w = w + n.w end end
      if #fills > 0 then
        fillseg = fillseg + 1
        measured = true
        local k = fillseg
        -- the last block that is not a fill, and the rules after it (their exact height)
        local last, extra = nil, 0
        for i = #sg, 1, -1 do
          local n = sg[i]
          if n.t == "rule" then extra = extra + n.w + xd.RULE + math.max(tonumber(n.above) or 0, tonumber(n.lead) or 0)
          elseif n.t ~= "fill" then last = i; break end
        end
        local cands = last and last_pars(sg[last]) or {}
        -- the face's descent from the first line of the page, whose top is known when the page opens with a
        -- paragraph (Word keeps its space before at the top of the document, not after a break)
        local first = sg[1] and sg[1].t == "par" and ptext(sg[1]) ~= "" and sg[1] or nil
        local d = DESCENT
        local yt = first and tonumber(labels["T" .. k])
        if yt then
          local before = (top or si > 1) and 0 or math.max(tw(first.lead), tw(first.above))
          local m = (yt - spec.margin.top - before / 20 - 0.8 * xd.pitch(spec, first.st.pitch))
            / (tonumber(first.st.size) or spec.size)
          if m > 0.1 and m < 0.35 then d = m end
        end
        -- the blocks' own bottom: the lowest last line, less the fills above it in the pass that measured it
        local bottom
        for j, p in ipairs(cands) do
          local m = ylabels["Y" .. k .. "." .. j]
          if m and m.y then
            local b = m.y - d * (tonumber(p.st.size) or spec.size) + 0.2 * xd.pitch(spec, p.st.pitch) - m.fills / 20
            bottom = math.max(bottom or b, b)
          end
        end
        if bottom then
          local free = math.max(PAGE_H - spec.margin.bottom - (bottom + extra) - FILL_SAFETY, 0)
          for _, f in ipairs(fills) do f.h = math.max(1, math.floor(free * f.w / w * 20)) end
        end
        -- the needles of this pass, the Y ids with the height of the fills above the last block
        local above = 0
        for i = 1, (last or 0) do if sg[i].t == "fill" then above = above + (sg[i].h or 1) end end
        if first then needle("T" .. k, "T", ptext(first):sub(1, NEEDLE_END), "") end
        for j, p in ipairs(cands) do
          if ptext(p) ~= "" then needle("Y" .. k .. "." .. j .. ":" .. above, "Y", ptext(p):sub(-NEEDLE_END), "") end
        end
      end
    end
  end

  -- The lines of a `repeat` column (")" beside a caption): as many as the tallest other column of the row is high at
  -- its pitch (lib/typst/xdoc.typ: ceil(height / pitch - 0.01)). Word cannot measure a cell: the first and last
  -- paragraphs of each other column carry bookmarks, which LibreOffice exports as named destinations at the top of
  -- their lines (docxpages.rs, kind D); a column is its first line's space before plus the distance from its first
  -- line's top to its last line's foot. Until measured (the first pass), a line a paragraph.
  local rowk = 0
  repeat_count = function(n)
    rowk = rowk + 1
    measured = true
    local r
    for _, c in ipairs(n.cols) do if c["repeat"] then r = c["repeat"] end end
    local p = xd.pitch(spec, r.st.pitch)
    local best, est = nil, 0
    for j, c in ipairs(n.cols) do
      if not c["repeat"] and #c.items > 0 then
        local pars = 0
        local function walk(items)
          for _, x in ipairs(items) do
            if x.t == "par" then pars = pars + 1
            elseif x.items then walk(x.items)
            elseif x.cols then for _, cc in ipairs(x.cols) do walk(cc.items) end end
          end
        end
        walk(c.items)
        est = math.max(est, pars)
        local first = c.items[1].t == "par" and c.items[1] or nil
        if first then
          local id = "xdr" .. rowk .. "c" .. j
          first.bm_start = id .. "a"
          needle(id .. "a", "D", id .. "a", "")
          local ya = tonumber(labels[id .. "a"])
          for m, last in ipairs(last_of(c.items)) do
            last.bm_end = id .. "z" .. m
            needle(id .. "z" .. m, "D", id .. "z" .. m, "")
            local yz = tonumber(labels[id .. "z" .. m])
            if ya and yz then
              local h = math.max(tw(first.lead), tw(first.above)) / 20 + yz - ya + xd.pitch(spec, last.st.pitch)
              best = math.max(best or h, h)
            end
          end
        end
      end
    end
    if best then return math.max(math.ceil(best / p - 0.01), 0) end
    return est
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
      -- an ordered list's items with their numbers, as the PDF prints them (list_items): a needle without them never
      -- matched, and its fallback found the heading's row in the contents
      local n = x.t == "OrderedList" and x.listAttributes.start or nil
      for _, it in ipairs(x.content) do
        if n then out[#out + 1] = tostring(n) .. ". "; n = n + 1 end
        for _, b in ipairs(it) do out[#out + 1] = plain(b) .. " " end
      end
    end
    return table.concat(out)
  end


  -- A run holding a rectangle of the page's size in `hex` ("#rrggbb"), behind the text from the page's corner, no wrap:
  -- a coloured cover (layout.yaml cover_fill; typst a page background, LaTeX \pagecolor). EMU: 12700 a point.
  local function cover_fill(hex)
    local w, h = math.floor(PAGE_W * 12700 + 0.5), math.floor(PAGE_H * 12700 + 0.5)
    local A = 'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"'
    local WPS = 'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"'
    return '<w:r><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="0" '
      .. 'behindDoc="1" locked="1" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/>'
      .. '<wp:positionH relativeFrom="page"><wp:posOffset>0</wp:posOffset></wp:positionH>'
      .. '<wp:positionV relativeFrom="page"><wp:posOffset>0</wp:posOffset></wp:positionV>'
      .. '<wp:extent cx="' .. w .. '" cy="' .. h .. '"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/>'
      .. '<wp:docPr id="9901" name="Cover fill"/><wp:cNvGraphicFramePr/><a:graphic ' .. A .. '>'
      .. '<a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp ' .. WPS .. '>'
      .. '<wps:cNvSpPr/><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="' .. w .. '" cy="' .. h .. '"/></a:xfrm>'
      .. '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:solidFill><a:srgbClr val="'
      .. hex:gsub("^#", ""):upper() .. '"/></a:solidFill><a:ln><a:noFill/></a:ln></wps:spPr><wps:bodyPr/></wps:wsp>'
      .. '</a:graphicData></a:graphic></wp:anchor></w:drawing></w:r>'
  end
  -- The text of the first paragraph of a tree (inside columns, groups and boxes too), or nil.
  local function first_text(nodes)
    for _, n in ipairs(nodes or {}) do
      if n.t == "par" then
        local t = plain({ t = "Plain", content = n.text })
        if t:find("%S") then return t end
      end
      local inner = n.items and first_text(n.items)
      if not inner and n.cols then
        for _, c in ipairs(n.cols) do inner = inner or first_text(c.items) end
      end
      if inner then return inner end
    end
    return nil
  end

  -- the last text of the nodes (lib/pandoc/xdoc.lua tree), inside columns and groups too
  local function last_text(nodes)
    for i = #(nodes or {}), 1, -1 do
      local n = nodes[i]
      if n.t == "par" then
        local t = plain({ t = "Plain", content = n.text })
        if t:find("%S") then return t end
      end
      local inner = n.items and last_text(n.items)
      if not inner and n.cols then
        for c = #n.cols, 1, -1 do inner = inner or last_text(n.cols[c].items) end
      end
      if inner then return inner end
    end
    return nil
  end

  -- The needles of a body block: a heading by its text and the text after it; each authority mark by its text and
  -- the words after it in its run, and before it when few follow (kind N in a footnote).
  -- The numbering of the page labels (docxpages.rs `#section`): a numbering starts at the page of a needle; the one
  -- wanted next (`want`) starts at the next needle written.
  local sections, want, pn = {}, nil, 0
  local function section_at(id)
    if want then sections[#sections + 1] = "#section\t" .. id .. "\t" .. want .. "\t"; want = nil end
  end

  local nbody = 0 -- the body's headings so far (their labels: hlabels)
  function needles_of(b, nxt)
    if b.t == "Header" then
      hn = hn + 1
      nbody = nbody + 1
      -- a numbered heading prints its label before its text, and so may the next block
      local own = (hlabels[nbody] or "") .. " " .. plain(b)
      local after = (nxt and nxt.t == "Header" and hlabels[nbody + 1] or "") .. " " .. plain(nxt)
      -- the whole heading and the start of what follows it: a long heading's first 48 characters are also its
      -- contents row's
      local o = xd.norm(own)
      if #o < NEEDLE - 8 then needle("h" .. hn, "B", own .. " " .. after, own)
      else needle("h" .. hn, "B", o .. xd.norm(after):sub(1, 16), own, #o + 16) end
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
        needle("a" .. k .. "." .. occ[k], sp.attributes["xd-n"],
          (sp.attributes["xd-before"] or "") .. e .. sp.attributes["xd-after"], e, nil, sp.attributes["xd-upto"])
      end
    end })
  end

  -- A layout heading (`head`, a certificate's title) is a heading of the document: its needle, by its text.
  on_head = function(n, nxt)
    hn = hn + 1
    local t = pandoc.utils.stringify(n.text)
    -- its text and the text after it, so that its row in the contents is not taken for it (the fallback: its text)
    local after = nxt and first_text({ nxt }) or ""
    needle("h" .. hn, "B", t .. " " .. after, t)
    section_at("h" .. hn)
  end

  -- A row of a table: the text wraps before a page column (a right indent of `col`), `hang` under its first line,
  -- `left` in; a dot leader from three spaces after the text to the page at the margin (typst listing-row).
  local function row(above, left, hang, col, xml, pages, pitch, italic)
    local h = tw(hang)
    local first
    if h == 0 then first = 0 end
    return xe.para({ xe.LINES, xe.leader_tab(TEXTW), xe.spacing(tw(above), 0, tw(pitch)),
      xe.ind(tw(left) + h, h > 0 and h or nil, first, col) },
      xml .. (italic and (xe.runs(xe.LEAD) .. xe.runs(pages, { i = true })) or xe.runs(xe.LEAD .. pages)))
  end

  -- The width of a page list in twips at the type size: the face's advances (layout face_advances, gen.rs; Times New
  -- Roman's by default: digits 1/2 em, comma and space 1/4 em, hyphen 1/3 em), as typst measure() gives it.
  local adv = spec.face_advances or { digit = 0.5, comma = 0.25, space = 0.25, hyphen = 0.333 }
  local function list_width(s)
    local em = 0
    for c in s:gmatch(".") do
      em = em + (c:match("%d") and adv.digit or c == "-" and adv.hyphen or c == " " and adv.space or adv.comma)
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
    -- `break: false` (the contents on the cover's page): its heading's space above
    return { t = "par", text = text, st = st, lead = 0, above = t["break"] == false and (tonumber(st.above) or 0) or 0,
      below = tonumber(st.below) or 0 }
  end

  local function contents(c, heads, s)
    local out = emit_list({ table_title(c) }, s, false)
    local pitch = xd.pitch(spec, c.pitch)
    for _, h in ipairs(heads) do
      if h.level <= (c.depth or 3) then
        -- a numbered heading's row carries its label: a tab to the level's label box (the row's hanging indent), or
        -- a space
        local st, hang = xd.heading(spec, h.level), tonumber(c.hang) or 0
        local xml = xe.inl(bind_double_signs(h.content:walk({ Str = breaks })))
        if h.label then
          xml = xe.runs(h.label .. (st.label_box and "\t" or " ")) .. xml
          if st.label_box then hang = st.label_box end
        end
        out[#out + 1] = row(c.above, (h.level - 1) * (tonumber(c.step) or 0), hang, tw(c.col or 36), xml,
          labels["h" .. h.n] or "00", pitch)
      end
    end
    return out
  end

  -- Keyed authorities (layout authorities.kinds): the cited entries of each group, in order, their pages from the
  -- needles of their links ("passim" in italics for `passim` pages or more); `page_heading` on the first group's
  -- line, after a right tab at the margin.
  local function keyed_authorities(a, meta, s, counts)
    if not a.kinds then
      error("xdoc: the frontmatter's authorities are keyed (a map): layout.yaml authorities.kinds names their groups", 0)
    end
    local out = emit_list({ table_title(a) }, s, false)
    local gst = a.group or { bold = true }
    local pitch = xd.pitch(spec, a.pitch)
    local first = true
    for gi, g in ipairs(a.kinds) do
      local members = {}
      for _, e in ipairs(xd.keyed(spec, meta)) do
        if e.group == gi and (counts[tostring(e.k)] or 0) > 0 then members[#members + 1] = e end
      end
      if #members > 0 then
        local title = xd.inlines(g.title)
        if gst.upper then title = xd.upper(title) end
        local node = { t = "par", text = title, st = setmetatable({ keep = true }, { __index = gst }), lead = 0,
          above = gst.above, below = gst.below }
        if first and a.page_heading then node.right = a.page_heading end
        for _, x in ipairs(emit_list({ node }, s, false)) do out[#out + 1] = x end
        first = false
        for _, e in ipairs(members) do
          local ls = {}
          for i = 1, (counts[tostring(e.k)] or 0) do ls[#ls + 1] = labels["a" .. e.k .. "." .. i] or "00" end
          local list, passim = xd.page_list(e, ls, a.passim)
          out[#out + 1] = row(a.above, 0, tonumber(a.hang) or 0, math.max(tw(a.col or 56), list_width(list)),
            xe.inl(bind_double_signs(xd.inlines(xd.keyed_text(g, e)):walk({ Str = breaks }))), list, pitch, passim)
        end
      end
    end
    s.prev_after = 0
    return out
  end

  local function authorities(a, meta, s, counts)
    local out = emit_list({ table_title(a) }, s, false)
    local gst = a.group or { bold = true }
    local pitch = xd.pitch(spec, a.pitch)
    local entries = xd.authority_entries(meta)
    local k = 0
    for _, g in ipairs(meta.authorities) do
      -- the group's heading in the group style, in capitals when it says (typst inl)
      local title = xd.inlines(g.heading)
      if gst.upper then title = xd.upper(title) end
      for _, x in ipairs(emit_list({ { t = "par", text = title,
        st = setmetatable({ keep = true }, { __index = gst }), lead = 0, above = gst.above, below = gst.below } }, s,
        false)) do out[#out + 1] = x end
      for _ = 1, #(g.entries or {}) do
        k = k + 1
        local e = entries[k]
        local ls = {}
        for i = 1, (counts[tostring(k)] or 0) do ls[#ls + 1] = labels["a" .. k .. "." .. i] or "00" end
        local list, passim = xd.page_list(e, ls, a.passim)
        out[#out + 1] = row(a.above, 0, tonumber(a.hang) or 0, math.max(tw(a.col or 56), list_width(list)),
          xe.inl(bind_double_signs(xd.inlines(e.cite):walk({ Str = breaks }))), list, pitch, passim)
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
  local function sect_xml(footer, fmt, first, cont)
    local m = spec.margin
    -- (a running footer of n lines: the last line's box ends n - 1 lines lower, where typst stacks them)
    local pt = spec.page_number and spec.page_number.text
    local nlines = xd.is_running(pt) and select(2, pt:gsub("<br>", "")) + 1 or 1
    -- (the footer's top `page_number.descent` below the text, 30 % of the bottom margin by default)
    local descent = spec.page_number and tonumber(spec.page_number.descent) or 0.3 * m.bottom
    local foot = tw(math.floor((m.bottom - descent - nlines * spec.pitch.single) * 20 + 0.5) / 20)
    return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
      .. (first and '<w:footerReference w:type="first" r:id="rIdXdNone"/>' or "")
      .. '<w:pgSz w:w="' .. tw(PAGE_W) .. '" w:h="' .. tw(PAGE_H) .. '"/><w:pgMar w:top="' .. tw(m.top) .. '" w:right="' .. tw(m.right)
      .. '" w:bottom="' .. tw(m.bottom) .. '" w:left="' .. tw(m.left) .. '" w:header="720" w:footer="' .. foot
      .. '" w:gutter="0"/>' .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '"' .. (cont and "" or ' w:start="1"') .. '/>') or "")
      .. (first and "<w:titlePg/>" or "") .. "</w:sectPr>"
  end

  -- The end of a section (the cover, the tables numbered apart): an empty paragraph of one twip holding its sectPr;
  -- the next section starts a page.
  -- (`cont`: the numbering goes on from the section before, not from 1)
  local function section_end(s, footer, fmt, cont)
    s.top, s.prev_after, s.pending = true, 0, 0
    return '<w:p><w:pPr>' .. xe.spacing(0, 0, 1) .. sect_xml(footer, fmt, false, cont) .. '</w:pPr></w:p>'
  end

  local WORD_FMT = { ["lower-roman"] = "lowerRoman", ["upper-roman"] = "upperRoman", decimal = "decimal" }


  -- Word runs of a page-number text: its text as runs, {page} the PAGE field, {pages} the field `pages` names.
  local function page_text(text, pages)
    local function field(name)
      return '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> ' .. name
        .. ' </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
    end
    local out, rest = {}, text
    while #rest > 0 do
      local a = rest:find("{", 1, true)
      local pre = a and rest:sub(1, a - 1) or rest
      if pre ~= "" then out[#out + 1] = xe.runs(pre, {}) end
      if not a then break end
      rest = rest:sub(a)
      if rest:sub(1, 7) == "{pages}" then out[#out + 1] = field(pages); rest = rest:sub(8)
      elseif rest:sub(1, 6) == "{page}" then out[#out + 1] = field("PAGE"); rest = rest:sub(7)
      else out[#out + 1] = xe.runs("{", {}); rest = rest:sub(2) end
    end
    return table.concat(out)
  end
  local function write_section()
    local pn = spec.page_number or {}
    local single = tw(spec.pitch.single)
    local fld = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText>'
      .. '</w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
    local function ftr(runs_xml)
      return xe.para({ xe.spacing(0, 0, single), xe.jc(pn.align or "center") }, runs_xml)
    end
    -- the layout's `page_number.text` ("Page {page} of {pages}"): the body's pages (SECTIONPAGES when it is a section
    -- numbered apart from the tables, NUMPAGES otherwise; tools/fb/src/enginegen/word.rs page_text_runs)
    local pages = pn.front and "SECTIONPAGES" or "NUMPAGES"
    local page_xml = pn.text and page_text(pn.text, pages) or fld
    -- a running footer (frontmatter fields, lines at "<br>"): a paragraph per line, a field's value as markdown
    if xd.is_running(pn.text) then
      local ps = {}
      for _, pieces in ipairs(xd.footer_lines(pn.text, xd.meta())) do
        local xml = {}
        for _, p in ipairs(pieces) do
          if p.lit then xml[#xml + 1] = xe.runs(p.lit, {})
          elseif p.field then xml[#xml + 1] = xe.inl(bind_double_signs(xd.inlines(p.field):walk({ Str = breaks })), {})
          else xml[#xml + 1] = page_text("{" .. p.key .. "}", pages) end
        end
        ps[#ps + 1] = ftr(table.concat(xml))
      end
      page_xml = nil
      fld = table.concat(ps)
    end
    local f = io.open(os.getenv("FORMBOOK_FOOTERS"), "w")
    f:write("rIdXdPage\t" .. (page_xml and ftr(page_xml) or fld) .. "\n" .. "rIdXdNone\t" .. ftr("") .. "\n")
    f:close()
    f = io.open(os.getenv("FORMBOOK_FINAL"), "w")
    f:write(sect_xml("rIdXdPage", pn.front and "decimal" or nil, (pn.from or 1) > 1))
    f:close()
  end

  -- A list at nesting `level` (lib/typst/xdoc.typ list-items): one paragraph per item in the level's style (the label,
  -- a tab to the hanging indent, the text; XdList1.. in the body, XdTailList1.. in the tail), nested lists after it.
  local markers = spec.list and spec.list.markers or { "\u{2022}" }
  function list_items(b, level, base, gap)
    local out = pandoc.Blocks({})
    local n = b.t == "OrderedList" and b.listAttributes.start or 1
    local delim = b.t == "OrderedList" and b.listAttributes.delimiter or "Period"
    for idx, item in ipairs(b.content) do
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
      -- the first item of a list after a paragraph or list of the body: XdList1Gap (paragraph_gap)
      local st = base .. math.min(level + 1, 3)
      if gap and level == 0 and idx == 1 then st = st .. "Gap" end
      out:insert(styled(st, inlines))      for _, sb in ipairs(subs) do out:extend(list_items(sb, level + 1, base)) end
      n = n + 1
    end
    return out
  end

  -- The body blocks as Word paragraphs; `para` the style of a plain paragraph (Body Text, or XdTail in the tail).
  local function body(blocks, s, para, first)
    local out = pandoc.Blocks({})
    local function raw(xml) out:insert(raw_block(xml)) end
    local function flush()
      if s.pending > s.prev_after and not s.top then raw(spacer(s.pending - s.prev_after)) end
      s.pending, s.top = 0, false
    end
    for k, b in ipairs(blocks) do
      needles_of(b, blocks[k + 1])
      -- the kind of the block before this one, for the space between body paragraphs and lists (s.flow: across calls,
      -- reset by a block of the layout, emit_list)
      local function gapped()
        return para:find("^Body Text") and tw(spec.paragraph_gap) > 0 and (s.flow == "Para" or s.flow == "List")
      end
      if b.t == "Header" then
        for _, x in ipairs(emit_list(heading(b, first and k == 1), s, false)) do raw(x) end
      elseif b.t == "Para" or b.t == "Plain" then
        flush()
        -- (layout.yaml footnote.widows: Body Text, with widow control, for it too)
        local widows = spec.footnote and spec.footnote.widows
        local st = para == "Body Text" and not widows and has_note(b.content) and "Body Text Note" or para
        -- after a paragraph or list of the body, the space between them (paragraph_gap): the style's Gap variant
        if gapped() then st = st .. " Gap" end
        out:insert(styled(st, b.content))
        -- the space it leaves below: Body Text's (paragraph_gap), the tail's gap
        s.prev_after = para:find("^Body Text") and tw(spec.paragraph_gap) or tw(spec.tail and spec.tail.gap)
      elseif b.t == "Table" then
        -- a table of the body (lib/pandoc/xdoc.lua table_nodes): its rules and rows as the layout's blocks
        for _, x in ipairs(emit_list(xd.table_nodes(spec, b), s, false)) do raw(x) end
      elseif b.t == "BlockQuote" then
        flush()
        local ps = b.content
        local qt = spec.quote or {}
        local listed = false -- the last block a list (its items have no space of their own)
        for i, q in ipairs(ps) do
          if q.t == "OrderedList" or q.t == "BulletList" then
            -- a list in the quotation (XdQuoteList1..: the quote's indents and pitch): the quotation's space above
            -- before it when it opens it, the gap after a list before it
            if i == 1 then
              s.pending = math.max(s.pending, tw(qt.above))
              flush()
            elseif listed then
              raw(spacer(tw(qt.gap)))
            end
            out:extend(list_items(q, 0, "XdQuoteList"))
            listed = true
          elseif q.t == "Para" or q.t == "Plain" then
            local style = #ps == 1 and "XdQuoteOnly" or i == 1 and "XdQuoteFirst" or i == #ps and "XdQuoteLast"
              or "XdQuote"
            out:insert(styled(style, q.content))
            listed = false
          else
            error("xdoc: a quotation holds paragraphs and lists only", 0)
          end
        end
        -- the space below the quotation: its last paragraph's, or pending after a list
        if listed then
          s.prev_after, s.pending = 0, tw(qt.below)
        else
          s.prev_after = tw(qt.below)
        end
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        flush()
        out:extend(list_items(b, 0, para == "Body Text" and "XdList" or "XdTailList", para == "Body Text" and gapped()))
        s.prev_after = 0
      else
        error("xdoc: unsupported block " .. b.t, 0)
      end
      s.flow = (b.t == "Para" or b.t == "Plain") and "Para" or (b.t == "OrderedList" or b.t == "BulletList") and "List"
        or nil
    end
    return out
  end

  return {
    {
      Pandoc = function(doc)
        local meta = xd.computed(spec, xd.context(spec, xd.meta()))
        local entries = xd.authority_entries(meta)
        local _, keyed = xd.keyed(spec, meta)
        local blocks = xd.mark(xd.attach_notes(xd.commonmark_lists(doc.blocks)):walk({ Inlines = bind_double_signs }), entries,
          function(k, note, after, find, before, upto)
            return pandoc.Span({}, { ["xd-k"] = tostring(k), ["xd-n"] = note and "N" or "B", ["xd-after"] = after,
              ["xd-find"] = find, ["xd-before"] = before or "", ["xd-upto"] = upto })
          end, keyed)
        xd.check(spec, doc.blocks)
        xd.switch_contents(spec, meta)
        -- links as their text when the court bars hyperlinks (layout.yaml links: false)
        blocks = xd.unlink(spec, blocks)
        -- the token after a section or pilcrow sign unbroken, as typst boxes it: a word joiner after each of its hyphens,
        -- dashes and slashes (after the marks: their finds read the text as written; xd.hold_sign_tokens)
        blocks = blocks:walk({ Inlines = function(l)
          return xd.hold_sign_tokens(l, function(p)
            return p:walk({ Str = function(x)
              -- (one character at a time: a Lua class would match the bytes of other characters)
              local t = x.text:gsub("%-", "-\u{2060}"):gsub("\u{2013}", "\u{2013}\u{2060}"):gsub("\u{2014}", "\u{2014}\u{2060}")
                :gsub("/", "/\u{2060}")
              return pandoc.Str(t)
            end })
          end)
        end })
        local main, rest = xd.split_tail(spec, blocks)
        -- the body sections set before the tables (body_before_tables)
        local pre
        pre, main = xd.split_head(spec, main, meta)
        local bnodes = xd.tree(spec, spec.before_tables, meta, true, true)
        local wnodes = xd.tree(spec, spec.between_tables, meta, true, true)
        local late = spec.body_before_tables and spec.body_before_tables.place == "between"
        local s = { prev_after = 0, pending = 0 }
        hlabels = xd.heading_labels(spec, blocks)
        local out = pandoc.Blocks({})
        -- pages numbered apart from the body: the tables, and the pages before them
        local paged = spec.contents or (spec.authorities and meta.authorities) or spec.before_tables or spec.between_tables
          or #pre > 0
        local front = spec.page_number and spec.page_number.front
        -- the document writes its own sections and footers: for the tables, or for a cover numbered apart
        local sectioned = paged or (spec.cover and front)
        xd.check_fills(spec.front)
        xd.check_fills(spec.closing)
        xd.check_fills(spec.after_tail)
        read_pages()
        -- the body's page count (fb-595.92: when: xd.pages, words.limit_pages), from the previous pass's needles: the
        -- first page of `front` (P:start, its first text; page 1 when the body is numbered apart and `front` has none)
        -- through the closing's last (P:end); 0 before they are known
        local paged_body = xd.uses_pages(spec)
        if paged_body then
          measured = true
          local a = first_text(xd.tree(spec, spec.front, meta, true, true)) and tonumber(labels["P:start"])
            or (front and 1)
          if not first_text(xd.tree(spec, spec.front, meta, true, true)) and not front then
            error("xdoc: when: xd.pages and words.limit_pages need a `front` with text or page_number.front (Word)", 0)
          end
          local b = tonumber(labels["P:end"])
          meta.xd = meta.xd or {}
          meta.xd.pages = (a and b) and (b - a + 1) or 0
          if meta.xd.words_over and meta.xd.pages > tonumber(spec.words.limit_pages) then
            error("xdoc: " .. meta.xd.words_over, 0)
          end
        end
        if paged then
          -- the numbering starts at the first line of the document (page 1)
          -- (its first paragraph's text, inside columns too: a cover may open with a caption's columns)
          needle("start", "B", first_text(xd.tree(spec, spec.cover or spec.front or {}, meta, true, true)) or "", "")
          if not front then sections[1] = "#section\tstart\tdecimal\t" end
        end
        -- the body sections before the tables on the cover's page (body_before_tables.place: cover, fb-595.92)
        local oncover = #pre > 0 and spec.body_before_tables.place == "cover"
        if oncover and (front or not spec.cover or spec.before_tables) then
          error("xdoc: body_before_tables.place: cover needs a cover numbered with the body (no page_number.front) and no before_tables", 0)
        end
        if spec.cover then
          local nodes = xd.tree(spec, spec.cover, meta, true, true)
          plan(nodes, false)
          local xs = emit_list(nodes, s, false)
          -- a coloured cover (cover_fill): a rectangle of the page behind the text, anchored in its first paragraph
          if spec.cover_fill then
            for i, x in ipairs(xs) do
              local a, b = x:find("</w:pPr>", 1, true)
              if a then xs[i] = x:sub(1, b) .. cover_fill(spec.cover_fill) .. x:sub(b + 1); break end
            end
          end
          for _, x in ipairs(xs) do out:insert(raw_block(x)) end
          if oncover then out:extend(body(pre, s, "Body Text")) end
          -- the cover a section of its own (no page number) when the pages after it are numbered apart
          -- (the contents on the cover's page, contents.break: false: no break)
          -- (page_number.cover: the cover counted in the tables' numbering, printed when `numbered`)
          local cmode = spec.page_number and spec.page_number.cover
          if front and cmode then
            out:insert(raw_block(section_end(s, cmode == "numbered" and "rIdXdPage" or "rIdXdNone", WORD_FMT[front])))
          elseif front then
            out:insert(raw_block(section_end(s, "rIdXdNone", nil)))
          elseif not (spec.contents and spec.contents["break"] == false) then
            out:insert(raw_block(brk(s)))
          end
        end
        if paged then
          -- how often each authority is marked (its rows read one page per mark)
          local counts = {}
          blocks:walk({ Span = function(sp) local k = sp.attributes["xd-k"]
            if k then counts[k] = (counts[k] or 0) + 1 end end })
          -- every heading in document order: the body's and the layout's (closing, after_tail)
          local heads = xd.all_heads(spec, main, xd.tree(spec, spec.closing, meta, false, true), rest,
            xd.tree(spec, spec.after_tail, meta, false, true), pre, bnodes, wnodes, late)
          if front then
            -- the tables' numbering starts at the first page after the cover: the first of the pages before the tables
            -- (its first text), or the first table (its title and its first row)
            local b1 = first_text(bnodes) or (#pre > 0 and not late and plain(pre[1]))
            if b1 then
              needle("front", "B", b1, b1)
            else
              local t = spec.contents or spec.authorities
              local h1 = heads[1] and plain({ t = "Plain", content = heads[1].content }) or ""
              needle("front", "B", t.title .. " " .. (spec.contents and h1 or ""), t.title)
            end
            -- the tables' numbering starts at the cover when the cover is counted in it
            local counted = spec.page_number.cover
            sections[#sections + 1] = "#section\t" .. (counted and "start" or "front") .. "\t" .. front .. "\t"
          end
          -- the pages before the tables, numbered with them
          if spec.before_tables then
            plan(bnodes, false)
            for _, x in ipairs(emit_list(bnodes, s, false)) do out:insert(raw_block(x)) end
            out:insert(raw_block(brk(s)))
          end
          if #pre > 0 and not late and not oncover then
            out:extend(body(pre, s, "Body Text"))
            out:insert(raw_block(brk(s)))
          end
          if spec.contents then
            for _, x in ipairs(contents(spec.contents, heads, s)) do out:insert(raw_block(x)) end
          end
          -- between the contents and the authorities: the layout's blocks, the body sections set there (place: between)
          if spec.between_tables then
            if not s.top then out:insert(raw_block(brk(s))) end
            plan(wnodes, false)
            for _, x in ipairs(emit_list(wnodes, s, false)) do out:insert(raw_block(x)) end
          end
          if #pre > 0 and late then
            if not s.top then out:insert(raw_block(brk(s))) end
            out:extend(body(pre, s, "Body Text"))
          end
          if spec.authorities and meta.authorities then
            out:insert(raw_block(brk(s)))
            local tbl = xd.is_keyed(meta) and keyed_authorities or authorities
            for _, x in ipairs(tbl(spec.authorities, meta, s, counts)) do out:insert(raw_block(x)) end
          end
          if front then
            out:insert(raw_block(section_end(s, "rIdXdPage", WORD_FMT[front], spec.page_number.cover ~= nil)))
            want = "decimal" -- the body from 1, at its first needle
          else
            out:insert(raw_block(brk(s)))
          end
        end
        local fnodes = xd.tree(spec, spec.front, meta, true, true)
        if paged_body and first_text(fnodes) then needle("P:start", "B", first_text(fnodes), first_text(fnodes)) end
        plan(fnodes, s.top)
        for _, x in ipairs(emit_list(fnodes, s, false)) do out:insert(raw_block(x)) end
        -- the last paragraph kept whole on the page of the closing (keep_with_closing): Body Text Keep, kept with the
        -- next paragraph, and the spacer before a closing that opens with a table kept too
        local kept
        main, kept = xd.last_para(spec, main)
        out:extend(body(main, s, "Body Text"))
        if kept then
          out:extend(body({ kept }, s, "Body Text Keep"))
          s.keepnext = true
        end
        local cnodes = xd.tree(spec, spec.closing, meta, false, true)
        plan(cnodes, false)
        for _, x in ipairs(emit_list(cnodes, s, false)) do
          out:insert(raw_block(x))
        end
        -- the closing's last text (or the body's last block's), on the body's last page
        if paged_body then
          local t = last_text(cnodes) or plain(kept or main[#main])
          needle("P:end", "B", t, t)
        end
        if #rest > 0 then
          if spec.tail["break"] then out:insert(raw_block(brk(s))) end
          s.pending = math.max(tw(spec.tail.above), s.pending)
          out:extend(body(rest, s, "XdTail", true))
        end
        -- the blocks after the tail (layout after_tail)
        local anodes = xd.tree(spec, spec.after_tail, meta, false, true)
        plan(anodes, false)
        for _, x in ipairs(emit_list(anodes, s, false)) do out:insert(raw_block(x)) end
        if paged or measured then
          local f = io.open(os.getenv("FORMBOOK_NEEDLES"), "w")
          f:write(table.concat(sections, "\n") .. "\n" .. table.concat(needles, "\n") .. "\n")
          f:close()
        end
        -- (a running footer names frontmatter fields: the document writes its footer)
        if sectioned or measured or xd.is_running(spec.page_number and spec.page_number.text) then write_section() end
        return pandoc.Pandoc(out, pandoc.Meta({}))
      end,
    },
  }
end

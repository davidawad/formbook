-- lib/pandoc/xdoc.lua: the engine-neutral half of the shared document model (fb-595.54.12) for the pandoc engines.
-- lib/typst/xdoc.typ sets a folder's typst/layout.yaml in typst; lib/latex/xdoc.lua and lib/docx/xdoc.lua set the
-- same layout in LaTeX and Word, from the tree this module builds, so the three agree on every block, every space
-- and every line box. `fb engines gen` writes the folder's latex/xdoc.lua and docx/xdoc.lua, which hand the layout
-- (as a Lua table) to those modules. fb render puts lib/ on LUA_PATH:
--   local xd = require("pandoc.xdoc")
--
-- The tree (xd.tree): a list of nodes, each with `above`, `below` and `lead` (points):
--   { t = "par", text = <Inlines>, st = <style> }       one paragraph of a text block
--   { t = "rule", w = <stroke> }                         a horizontal rule: a box of xd.RULE + w points
--   { t = "cols", cols = { { width = <pt or nil>, valign = <"center" or nil>, items = <nodes> }, .. }, gutter = <pt> }
--   { t = "group", items = <nodes>, keep = <bool> }
--   { t = "break" }                                     a page break (what follows has no space above)
--   { t = "box", items = <nodes>, width = <pt or nil>, height = <pt or nil>, stroke = {t, r, b, l}, inset = {t, r, b, l},
--     valign = <"top", "center" or "bottom"> }    a ruled box (lib/typst/xdoc.typ: a block with stroke and inset)
--   { t = "fill", w = <weight> }                        space that fills the page, shared by weight (a page's own
--                                                       blocks only; the blocks next to it lose their space toward it)
-- `lead` is the space above a node that opens its container (a column, a group, the page): typst drops a block's
-- space above there, so every engine sets it as explicit space instead; between two nodes the larger of the one's
-- `below` and the other's `above` applies (typst, \addvspace, LibreOffice alike).
local M = {}

-- A rule's line box, besides its stroke: LibreOffice gives a paragraph with a top border its exact line height plus
-- the border's width; the smallest exact line is one twip.
M.RULE = 0.05

-- The frontmatter as written ($FORMBOOK_META, which fb render sets for both pandoc engines): strings stay strings.
function M.meta()
  local path = os.getenv("FORMBOOK_META")
  local f = path and io.open(path, "r")
  if not f then error("xdoc: no $FORMBOOK_META (render with fb render)", 0) end
  local m = pandoc.json.decode(f:read("a"), false)
  f:close()
  return m
end

-- The value at a dotted path ("a.b"; "." the context itself), or nil; "a.b|text": the text when there is
-- none (lib/typst/xdoc.typ lookup alike).
function M.lookup(ctx, path)
  local bar = path:find("|", 1, true)
  if bar then
    local v = M.lookup(ctx, path:sub(1, bar - 1))
    if v == nil then return path:sub(bar + 1) end
    return v
  end
  if path == "." then return ctx["."] end
  local v = ctx
  for k in path:gmatch("[^.]+") do
    if type(v) ~= "table" then return nil end
    -- a list item by its index from 0 ("signature.lines.0"; lib/typst/xdoc.typ lookup)
    if v[1] ~= nil and k:match("^%d+$") then v = v[tonumber(k) + 1] else v = v[k] end
  end
  return v
end

local function str(v)
  if type(v) == "number" and v == math.floor(v) then return string.format("%d", v) end
  return tostring(v)
end

-- Whether a frontmatter value is set (lib/typst/xdoc.typ is-set): present and not false, "" or an empty list or map.
function M.is_set(v)
  return v ~= nil and v ~= pandoc.json.null and v ~= false and v ~= ""
    and not (type(v) == "table" and next(v) == nil)
end

-- The paragraphs of a text template (lib/typst/xdoc.typ `expand`): "{path}" alone with a list value gives one per
-- item; otherwise every {path} is replaced by its value; each is then split at "<br>". A missing value is an error,
-- or gives no paragraph when `optional` (an empty string too).
function M.expand(tpl, ctx, optional, keep_newlines)
  local out = {}
  -- a value's newline starts a line of its own, as "<br>" does (a YAML block scalar's last one dropped); a markdown
  -- block keeps them (`keep_newlines`: it splits at blank lines; lib/typst/xdoc.typ expand alike)
  local function val(x)
    local s = str(x)
    if keep_newlines then return s end
    return (s:gsub("\n+$", ""):gsub("\r\n", "\n"):gsub("\n", "<br>"))
  end
  local whole = tpl:match("^{([^{}]+)}$")
  local v = whole and M.lookup(ctx, whole)
  if type(v) == "table" then -- a list (an empty one gives no paragraph, as in typst)
    for _, x in ipairs(v) do out[#out + 1] = val(x) end
  else
    local missing = false
    local s = tpl:gsub("{([^{}]+)}", function(p)
      local x = M.lookup(ctx, p)
      -- an optional block whose field is empty prints nothing, as one whose field is missing
      if x == nil or (optional and x == "") then
        if optional then missing = true; return "" end
        error("xdoc: missing required metadata field `" .. p .. "`", 0)
      end
      return val(x)
    end)
    if not missing then out[1] = s end
  end
  local lines = {}
  for _, s in ipairs(out) do
    local from = 1
    while true do
      local a, b = s:find("<br>", from, true)
      if not a then lines[#lines + 1] = s:sub(from); break end
      lines[#lines + 1] = s:sub(from, a - 1)
      from = b + 1
    end
  end
  return lines
end

-- A frontmatter string as inlines: markdown (CommonMark with smart punctuation, as typst's cmarker reads it), or the
-- plain words when it does not read as one paragraph (a value such as "(573) 751-7017").
function M.inlines(s)
  -- a value that reads as a thematic break ("______", a signature line) is its characters (lib/typst/xdoc.typ md alike)
  local t = s:gsub("%s", "")
  if #t >= 3 and (t:match("^_+$") or t:match("^%-+$") or t:match("^%*+$")) then s = s:gsub("[-_*]", "\\%0") end
  -- a value that starts like a block ("* Pro hac vice", "1. ", "# ", "> ") is text: its marker escaped
  -- (lib/typst/xdoc.typ md alike)
  s = s:gsub("^(%s*)([-*+>#])(%s)", "%1\\%2%3"):gsub("^(%s*)([-*+>#])$", "%1\\%2")
    :gsub("^(%s*)(%d+)([.)])(%s)", "%1%2\\%3%4"):gsub("^(%s*)(%d+)([.)])$", "%1%2\\%3")
  local ok, d = pcall(pandoc.read, s, "commonmark_x+smart")
  if ok and #d.blocks == 1 and (d.blocks[1].t == "Para" or d.blocks[1].t == "Plain") then
    return d.blocks[1].content
  end
  local out = pandoc.Inlines({})
  for w in s:gmatch("%S+") do
    if #out > 0 then out:insert(pandoc.Space()) end
    out:insert(pandoc.Str(w))
  end
  return out
end

-- Inlines in capitals (a style's `upper`); a footnote's text keeps its case (typst's upper() leaves the note, which
-- it sets at the foot of the page, alone).
function M.upper(inlines)
  return inlines:walk({ traverse = "topdown", Note = function(n) return n, false end,
    Str = function(x) return pandoc.Str(pandoc.text.upper(x.text)) end })
end

local function num(x) return tonumber(x) or 0 end

local function copy(t)
  local o = {}
  for k, v in pairs(t) do o[k] = v end
  return o
end

-- The context of an item of a list: its fields (a map item), "." (the item) and "#" (its number from 1, given its
-- index `i` from 1) over the outer context.
function M.item_ctx(ctx, it, i)
  local c = copy(ctx)
  if type(it) == "table" then for k, v in pairs(it) do c[k] = v end end
  c["."] = it
  if i then c["#"] = i end
  return c
end

-- The weight of a fill block (`fill: true` is 1).
function M.fill_weight(b)
  return b.fill == true and 1 or tonumber(b.fill) or 1
end

-- A page's own blocks (front, closing) whose fills a page break does not follow are an error (lib/typst/xdoc.typ
-- check-fills): a fill shares out the rest of its page, which only a break ends (the cover always ends in one).
function M.check_fills(list)
  local function has_fill(bs)
    for _, b in ipairs(bs or {}) do
      if b.fill ~= nil or (type(b.blocks) == "table" and has_fill(b.blocks)) then return true end
    end
    return false
  end
  local tail = {}
  for _, b in ipairs(list or {}) do
    if b["break"] ~= nil then tail = {} else tail[#tail + 1] = b end
  end
  if has_fill(tail) then error("xdoc: a fill must be followed by a {break: true} on its page", 0) end
end



-- The checks a court's rules ask of the body (layout.yaml `checks`; lib/typst/xdoc.typ check-body): `footnotes: false`
-- no footnote; `sections`, those level-1 headings (by the start of their text, any case) present and in that order.
function M.check(spec, blocks)
  local c = spec.checks or {}
  if c.footnotes == false then
    local note = false
    blocks:walk({ Note = function() note = true end })
    if note then error("xdoc: the court allows no footnote (layout.yaml checks.footnotes)", 0) end
  end
  local heads = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then heads[#heads + 1] = pandoc.text.lower(pandoc.utils.stringify(b.content)) end
  end
  local at = 1
  for _, s in ipairs(c.sections or {}) do
    local want, found = pandoc.text.lower(s), nil
    for i = at, #heads do
      if heads[i]:sub(1, #want) == want then found = i; break end
    end
    if not found then error("xdoc: the section `" .. s .. "` is missing or out of order (layout.yaml checks.sections)", 0) end
    at = found + 1
  end
end

-- A table of contents a frontmatter field switches (layout.yaml `contents.when`): none when the field is not set
-- (`contents.default` when the frontmatter lacks it; lib/typst/xdoc.typ alike). Changes the layout for this run.
function M.switch_contents(spec, meta)
  local c = spec.contents
  local v = c and c["when"] and M.lookup(meta, c["when"])
  if v == nil and c then v = c.default end
  if c and c["when"] and not M.is_set(v) then
    spec.contents = nil
  end
end
-- The paragraphs of a markdown value (a `{markdown: "{field}"}` block; lib/typst/xdoc.typ md-paragraphs): split at
-- its blank lines, each paragraph's lines joined by a space.
function M.md_paragraphs(ps)
  local out = {}
  for _, s in ipairs(ps) do
    s = s:gsub("\r", "") .. "\n\n"
    for p in s:gmatch("(.-)\n[ \t]*\n") do
      p = p:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[ \t]*\n[ \t]*", " ")
      if p ~= "" then out[#out + 1] = p end
    end
  end
  return out
end
-- The nodes of a block list (lib/typst/xdoc.typ `blocks`, rule for rule). `page`: the list is a page's own (the
-- cover, front, closing, or an each or when in one), where a fill may stand.
function M.tree(spec, list, ctx, first, page)
  local out = {}
  for _, b in ipairs(list or {}) do
    local lead = first and num(b.above) or 0
    local above = first and 0 or num(b.above)
    local below = num(b.below)
    if b.text ~= nil or b.markdown ~= nil then
      local ps = b.text ~= nil and M.expand(tostring(b.text), ctx, b.optional)
        or M.md_paragraphs(M.expand(tostring(b.markdown), ctx, b.optional, true))
      -- `lines`: the style of a value of more than one line, a paragraph per line, its `above` over it and over the
      -- value after it (lib/typst/xdoc.typ blocks alike)
      local ml, opens = {}, {}
      if b.lines and b.text ~= nil then
        ps = {}
        for _, v in ipairs(M.expand(tostring(b.text), ctx, b.optional, true)) do
          local t = v:gsub("\r\n", "\n"):gsub("\n+$", "")
          local multi = t:find("\n", 1, true) ~= nil
          local j = 0
          for l in (t .. "\n"):gmatch("(.-)\n") do
            j = j + 1
            ps[#ps + 1] = l
            ml[#ps], opens[#ps] = multi, j == 1
          end
        end
      end
      for i, s in ipairs(ps) do
        local text = M.inlines(s)
        local bs, gap = b, num(b.gap)
        if b.lines and b.text ~= nil then
          if ml[i] then bs = copy(b); for k, v in pairs(b.lines) do bs[k] = v end end
          if i > 1 and opens[i] and (ml[i] or ml[i - 1]) then gap = num(b.lines.above) end
        end
        if b.heading then
          -- a layout heading (a certificate's title): its level's style, kept with what follows, `head` its level
          -- (bookmarked and in the contents, never numbered: lib/typst/xdoc.typ <xd-lh>)
          local st = copy(M.heading(spec, b.heading))
          st.keep = true
          if st.upper then text = M.upper(text) end
          out[#out + 1] = { t = "par", text = text, title = M.inlines(s), st = st, head = b.heading, lead = 0,
            above = first and 0 or num(st.above), below = num(st.below) }
        else
          if bs.upper then text = M.upper(text) end
          out[#out + 1] = { t = "par", text = text, st = bs, lead = i == 1 and lead or 0,
            above = i == 1 and above or gap, below = i == #ps and below or 0 }
        end
      end
      if #ps > 0 then first = false end
    elseif b.rule ~= nil then
      out[#out + 1] = { t = "rule", w = num(b.rule), lead = lead, above = above, below = below }
      first = false
    elseif b.columns ~= nil then
      -- a list of columns, or one column per item of a list (`each`), each with its context
      -- (`per_row`: that many columns a row, the rows `row_gap` apart; a short last row keeps the widths; `widths`: the
      -- width of the column at each place in a row, the places it does not give shared alike)
      local rows = {}
      if b.columns.each ~= nil then
        local items = M.lookup(ctx, b.columns.each)
        if items == nil then error("xdoc: missing required metadata field `" .. b.columns.each .. "`", 0) end
        local n = tonumber(b.columns.per_row) or #items
        local ws = b.columns.widths or {}
        if b.columns.split ~= nil then
          -- `split`: two columns, the first holding the first N items (N the frontmatter field `split` names, or a
          -- number; half of them, rounded up, without it), the second the rest, the items of a column `gap` apart
          -- (lib/typst/xdoc.typ blocks alike)
          local s = b.columns.split
          local k = tonumber(type(s) == "string" and M.lookup(ctx, s) or s) or math.ceil(#items / 2)
          k = math.min(k, #items)
          local parts = { {}, {} }
          for i, it in ipairs(items) do table.insert(parts[i <= k and 1 or 2], it) end
          local cols = {}
          for j, part in ipairs(parts) do
            local c = copy(ctx)
            c.__split = part
            cols[j] = { width = tonumber(ws[j]) or b.columns.width, valign = b.columns.valign,
              items = M.tree(spec, { { each = "__split", gap = b.columns.gap, blocks = b.columns.blocks } }, c, true) }
          end
          rows[1] = cols
          n = 0
        end
        for i = 1, (n > 0 and #items or 0), math.max(n, 1) do
          local cols = {}
          for j = i, i + n - 1 do
            local it = items[j]
            cols[#cols + 1] = { width = tonumber(ws[j - i + 1]) or b.columns.width, valign = b.columns.valign,
              items = it ~= nil and M.tree(spec, b.columns.blocks, M.item_ctx(ctx, it, j), true) or {} }
          end
          rows[#rows + 1] = cols
        end
      else
        local cols = {}
        for _, c in ipairs(b.columns) do
          -- a `repeat` column: its text once a line, as many lines as the row's tallest other column is high
          cols[#cols + 1] = { width = c.width, valign = c.valign, items = c["repeat"] and {} or M.tree(spec, c.blocks, ctx, true),
            ["repeat"] = c["repeat"] and { text = M.inlines(tostring(c["repeat"])), st = c } or nil }
        end
        rows[1] = cols
      end
      local gap = b.columns.each ~= nil and num(b.columns.row_gap) or 0
      for ri, cols in ipairs(rows) do
        out[#out + 1] = { t = "cols", cols = cols, gutter = num(b.gutter), lead = ri == 1 and lead or 0,
          above = ri == 1 and above or gap, below = ri == #rows and below or 0 }
      end
      first = false
    elseif b.each ~= nil then
      local items = M.lookup(ctx, b.each)
      if items == nil then error("xdoc: missing required metadata field `" .. b.each .. "`", 0) end
      for i, it in ipairs(items) do
        if i > 1 and b.between then
          -- in the context of the item before (its fields decide a `when`), the item after as `next` ("when:
          -- next.versus"; lib/typst/xdoc.typ blocks alike)
          local bctx = M.item_ctx(ctx, items[i - 1], i - 1)
          bctx.next = it
          for _, n in ipairs(M.tree(spec, b.between, bctx, false, page)) do out[#out + 1] = n end
        end
        local ictx = M.item_ctx(ctx, it, i)
        local bl = b.blocks
        if i == 1 and #bl > 0 then
          bl = copy(bl)
          bl[1] = copy(bl[1])
          bl[1].above = math.max(num(b.above), num(bl[1].above))
        elseif i > 1 and #bl > 0 and num(b.gap) > 0 then
          -- `gap`: the least space between two items (above the first block of every item after the first)
          bl = copy(bl)
          bl[1] = copy(bl[1])
          bl[1].above = math.max(num(b.gap), num(bl[1].above))
        end
        for _, n in ipairs(M.tree(spec, bl, ictx, first and i == 1, page)) do out[#out + 1] = n end
      end
      if #items > 0 then first = false end
    elseif b.when ~= nil or b.unless ~= nil then
      -- the blocks when the field is set (`when`) or not (`unless`): false, "" and an empty list are not set; a
      -- field the frontmatter lacks has the block's `default`
      local v = M.lookup(ctx, b.when ~= nil and b.when or b.unless)
      if v == nil then v = b.default end
      -- `is`: set when the value is that one (compared as text)
      local set
      if b["is"] ~= nil then set = v ~= nil and str(v) == str(b["is"]) else set = M.is_set(v) end
      if set == (b.when ~= nil) then
        for _, n in ipairs(M.tree(spec, b.blocks, ctx, first, page)) do out[#out + 1] = n end
        first = false
      end
    elseif b.box ~= nil then
      -- a ruled box: its blocks `inset` from its edges, `stroke` on its sides (one number, or per side)
      local function sides(v)
        if type(v) == "table" then
          return { t = num(v.top), r = num(v.right), b = num(v.bottom), l = num(v.left) }
        end
        return { t = num(v), r = num(v), b = num(v), l = num(v) }
      end
      out[#out + 1] = { t = "box", items = M.tree(spec, b.box, ctx, true), width = tonumber(b.width),
        height = tonumber(b.height), stroke = sides(b.stroke), inset = sides(b.inset), valign = b.valign or "top",
        lead = lead, above = above, below = below }
      first = false
    elseif b.fill ~= nil then
      if not page then
        error("xdoc: a fill is set in a page's own blocks (cover, front, closing), not in a column or group", 0)
      end
      out[#out + 1] = { t = "fill", w = M.fill_weight(b), lead = 0, above = 0, below = 0 }
      first = false
    elseif b["break"] ~= nil then
      out[#out + 1] = { t = "break", lead = 0, above = 0, below = 0 }
      first = false
    elseif b.group ~= nil then
      out[#out + 1] = { t = "group", items = M.tree(spec, b.group, ctx, true), keep = b.keep ~= false,
        lead = lead, above = above, below = below }
      first = false
    else
      error("xdoc: unknown block " .. pandoc.json.encode(b), 0)
    end
  end
  -- the blocks next to a fill lose their space toward it (typst drops weak spacing beside fractional spacing)
  for i, n in ipairs(out) do
    if n.t == "fill" then
      if out[i - 1] then out[i - 1].below = 0 end
      if out[i + 1] then out[i + 1].above, out[i + 1].lead = 0, 0 end
    end
  end
  return out
end

-- A Str's text with the URL in it (http://, https://, www.) cut into the pieces a line may end between: after a slash
-- not followed by another (after "https://", not inside it), a dot before an ASCII letter or digit, a hyphen before a
-- letter, a "?", "!" or "&" before a letter or digit (lib/typst/xdoc.typ url-pieces): the text before the URL, the
-- pieces; nil when the text holds no URL.
function M.url_pieces(s)
  local at = s:find("https?://") or s:find("www%.")
  if not at then return nil end
  local pre, url = s:sub(1, at - 1), s:sub(at)
  local stop = url:find("[<>]")
  local post = ""
  if stop then url, post = url:sub(1, stop - 1), url:sub(stop) end
  local cs = {}
  for _, cp in utf8.codes(url) do cs[#cs + 1] = utf8.char(cp) end
  local pieces, cur = {}, ""
  for i, c in ipairs(cs) do
    cur = cur .. c
    local nx = cs[i + 1]
    if nx and ((c == "/" and nx ~= "/") or (c == "." and nx:find("^[A-Za-z0-9]$")) or (c == "-" and nx:find("^%a$"))
      or ((c == "?" or c == "!" or c == "&") and nx:find("^[A-Za-z0-9]$"))) then
      pieces[#pieces + 1] = cur; cur = ""
    end
  end
  if cur ~= "" then pieces[#pieces + 1] = cur end
  return pre, pieces, post
end


-- The paper (layout.yaml `paper`: letter, the default, or legal): its width and height in points.
M.PAPER = { letter = { 612, 792 }, legal = { 612, 1008 } }
function M.paper(spec)
  local p = M.PAPER[spec.paper or "letter"]
  if not p then error("xdoc: paper `" .. tostring(spec.paper) .. "`: letter or legal", 0) end
  return p[1], p[2]
end
-- The pitch of a style: body, single (the default) or a number of points.
function M.pitch(spec, p)
  if p == nil or p == "single" then return spec.pitch.single end
  if p == "body" then return spec.pitch.body end
  return tonumber(p)
end

-- The level-n heading style (the last one for deeper levels).
function M.heading(spec, n)
  local hs = spec.heading or {}
  if #hs == 0 then return { bold = true } end
  return hs[math.min(n, #hs)]
end

-- The layout headings of a tree (text blocks with `heading`), in order, inside groups and columns too.
function M.layout_heads(nodes)
  local out = {}
  local function walk(ns)
    for _, n in ipairs(ns or {}) do
      if n.head then out[#out + 1] = n end
      if n.items then walk(n.items) end
      if n.cols then for _, c in ipairs(n.cols) do walk(c.items) end end
    end
  end
  walk(nodes)
  return out
end

-- The headings of the document in order, for the contents (n = 1, 2, ..; lib/typst/xdoc.typ queries them in place):
-- the layout headings of the pages before the tables (`before`), the body sections set before the tables (`pre`; after
-- the contents and the layout's blocks between the tables, `between`, when `late`),
-- the body's (`main`), the closing's layout headings, the tail's, the after_tail's; a body heading's `label` its
-- number (heading_labels, which counts only the body's).
function M.all_heads(spec, main, closing, rest, after, pre, before, between, late)
  local labels = M.heading_labels(spec, (function()
    local all = pandoc.Blocks({})
    all:extend(pre or {}); all:extend(main); all:extend(rest)
    return all
  end)())
  local out, bi = {}, 0
  local function body(bs)
    for _, b in ipairs(bs) do
      if b.t == "Header" then
        bi = bi + 1
        out[#out + 1] = { n = #out + 1, level = b.level, content = b.content, label = labels[bi] }
      end
    end
  end
  local function layout(nodes)
    for _, h in ipairs(M.layout_heads(nodes)) do
      out[#out + 1] = { n = #out + 1, level = h.head, content = h.title, layout = h }
    end
  end
  -- `late`: the body sections set before the tables come after the contents and `between` (place: between)
  layout(before)
  if not late then body(pre or {}) end
  layout(between)
  if late then body(pre or {}) end
  body(main); layout(closing); body(rest); layout(after)
  return out
end

-- The body blocks less the last, and the last (or nil): the paragraph kept whole with the closing (layout.yaml
-- keep_with_closing; lib/typst/xdoc.typ split-last), when the body ends in a paragraph that calls no footnote.
function M.last_para(spec, blocks)
  local last = blocks[#blocks]
  if not spec.keep_with_closing or not last or last.t ~= "Para" then return blocks, nil end
  local note = false
  last:walk({ Note = function() note = true end })
  if note then return blocks, nil end
  local rest = pandoc.Blocks({})
  for i = 1, #blocks - 1 do rest:insert(blocks[i]) end
  return rest, last
end

-- A count in a typst numbering pattern of one counting symbol (lib/typst/xdoc.typ heading-label uses typst's
-- numbering()): the text before and after the first of 1, a, A, i, I kept; a and A count bijectively (z, aa),
-- i and I in Roman numerals.
function M.numbering(pattern, n)
  local at = pattern:find("[1aAiI]")
  if not at then return pattern end
  local sym, pre, post = pattern:sub(at, at), pattern:sub(1, at - 1), pattern:sub(at + 1)
  local s
  if sym == "1" then
    s = string.format("%d", n)
  elseif sym == "a" or sym == "A" then
    s = ""
    local k = n
    while k > 0 do
      k = k - 1
      s = string.char(97 + k % 26) .. s
      k = k // 26
    end
  else
    local r, k = "", n
    for _, p in ipairs({ { 1000, "m" }, { 900, "cm" }, { 500, "d" }, { 400, "cd" }, { 100, "c" }, { 90, "xc" },
      { 50, "l" }, { 40, "xl" }, { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }) do
      while k >= p[1] do r = r .. p[2]; k = k - p[1] end
    end
    s = r
  end
  if sym == "A" or sym == "I" then s = s:upper() end
  return pre .. s .. post
end

-- The width of a numbered level's label box: `label_box`, else a `hang` over 0 (the title's later lines hung under the
-- title), else nil (the label before the title after a space; lib/typst/xdoc.typ label-width).
function M.label_width(st)
  if st.label_box then return tonumber(st.label_box) end
  if (tonumber(st.hang) or 0) > 0 then return tonumber(st.hang) end
  return nil
end

-- The label of every heading of the blocks, in order (1, 2, .. as xd.headings numbers them with depth 9; nil for a
-- level whose style numbers nothing): typst's heading counter (from (0): a heading steps its level and drops the
-- deeper ones, or pads the levels up to its own with 1s), the level style's `number_prefix` and `number` pattern
-- (lib/typst/xdoc.typ heading-label).
function M.heading_labels(spec, blocks)
  local counts, out, i = { 0 }, {}, 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      i = i + 1
      local l = math.min(b.level, 9)
      if #counts >= l then
        counts[l] = counts[l] + 1
        for j = #counts, l + 1, -1 do counts[j] = nil end
      else
        while #counts < l do counts[#counts + 1] = 1 end
      end
      local st = M.heading(spec, b.level)
      if st.number then out[i] = (st.number_prefix or "") .. M.numbering(st.number, counts[l]) end
    end
  end
  return out
end

-- The words of the body before the tail heading (`{body_words}` in a block; lib/typst/xdoc.typ plain-words): the
-- sample's markdown after its frontmatter, cut at the tail heading, split at white space; a word holds an ASCII letter
-- or digit (so a footnote definition's "[^1]:" counts, a lone dash does not).
local USPACE = { "\u{00A0}", "\u{1680}", "\u{2000}", "\u{2001}", "\u{2002}", "\u{2003}", "\u{2004}", "\u{2005}",
  "\u{2006}", "\u{2007}", "\u{2008}", "\u{2009}", "\u{200A}", "\u{2028}", "\u{2029}", "\u{202F}", "\u{205F}",
  "\u{3000}", "\u{0085}" }
function M.plain_words(src, at)
  local s = src:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1)
  if at then
    local cut = ("\n" .. s):find("\n# +" .. at:gsub("%p", "%%%0"))
    if cut then s = s:sub(1, cut - 1) end
  end
  for _, u in ipairs(USPACE) do s = s:gsub(u, " ") end
  local n = 0
  for w in s:gmatch("%S+") do if w:find("[A-Za-z0-9]") then n = n + 1 end end
  return n
end

-- The frontmatter with the computed fields: `body_words` (M.plain_words of the sample pandoc reads).
function M.context(spec, meta)
  local path = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local f = path and io.open(path, "r")
  if f and meta.body_words == nil then
    meta.body_words = M.plain_words(f:read("a"), spec.tail and spec.tail.at)
  end
  if f then f:close() end
  return meta
end

-- A table of the body (a pipe table; lib/typst/xdoc.typ body-table): a rule, then each row as columns of equal width
-- `table.gutter` apart, its cells one paragraph each in the `table` style (`head` over it for the header rows, bold by
-- default), a rule between two rows and after the last, `table.pad` between a rule and a row; `table.above` and
-- `table.below` around the whole. No cell spans, no alignment (cmarker sets neither); a cell holds text only
-- (fb-595.54.14).
function M.table_nodes(spec, tbl)
  local t = spec.table or {}
  local stroke, pad = tonumber(t.stroke) or 0.5, num(t.pad)
  local function style(head)
    local st = { pitch = t.pitch, size = t.size }
    if head then for k, v in pairs(t.head or { bold = true }) do st[k] = v end end
    return st
  end
  local rows = {}
  for _, r in ipairs(tbl.head.rows) do rows[#rows + 1] = { r, true } end
  for _, b in ipairs(tbl.bodies) do
    for _, r in ipairs(b.head) do rows[#rows + 1] = { r, true } end
    for _, r in ipairs(b.body) do rows[#rows + 1] = { r, false } end
  end
  local n = #tbl.colspecs
  local out = { { t = "rule", w = stroke, lead = 0, above = num(t.above), below = pad } }
  for i, rh in ipairs(rows) do
    local cols = {}
    for j = 1, n do
      local c = rh[1].cells[j]
      local text = pandoc.Inlines({})
      for _, b in ipairs(c and c.contents or {}) do
        if b.t ~= "Plain" and b.t ~= "Para" then error("xdoc: a table cell holds text only", 0) end
        if #text > 0 then text:insert(pandoc.Space()) end
        text:extend(b.content)
      end
      cols[j] = { items = { { t = "par", text = text, st = style(rh[2]), lead = 0, above = 0, below = 0 } } }
    end
    out[#out + 1] = { t = "cols", cols = cols, gutter = num(t.gutter), lead = 0, above = 0, below = 0 }
    out[#out + 1] = { t = "rule", w = stroke, lead = 0, above = pad, below = i == #rows and num(t.below) or pad }
  end
  return out
end

-- A footnote mark attached to the word before it: typst (cmarker) sets "system. [^1]" as "system.¹", one word, where
-- pandoc keeps the space, a place to break the line that typst does not have. The space before a note goes
-- (fb-595.54.14).
function M.attach_notes(blocks)
  return blocks:walk({
    Inlines = function(list)
      local out = pandoc.Inlines({})
      for i, el in ipairs(list) do
        local nxt = list[i + 1]
        if not ((el.t == "Space" or el.t == "SoftBreak") and nxt and nxt.t == "Note") then out:insert(el) end
      end
      return out
    end,
  })
end

-- Ordered lists as typst's markdown reader (cmarker, CommonMark) reads them: only "1." and "1)" start a list there, so a
-- list pandoc reads with letters, roman numerals or "(1)" is paragraphs, each starting with its marker as written.
local LIST_SYM = { LowerAlpha = "a", UpperAlpha = "A", LowerRoman = "i", UpperRoman = "I", Decimal = "1",
  DefaultStyle = "1", Example = "1" }
function M.commonmark_lists(blocks)
  return blocks:walk({ OrderedList = function(l)
    local a = l.listAttributes
    local style, delim = a.style or "DefaultStyle", a.delimiter or "DefaultDelim"
    if LIST_SYM[style] == "1" and delim ~= "TwoParens" then return nil end
    local sym = LIST_SYM[style] or "1"
    local pat = delim == "TwoParens" and ("(" .. sym .. ")") or delim == "OneParen" and (sym .. ")") or (sym .. ".")
    -- a tight list (its items on consecutive lines) is one paragraph there, its items joined by a soft break
    local out, acc = pandoc.Blocks({}), nil
    local function flush()
      if acc then out:insert(pandoc.Para(acc)) end
      acc = nil
    end
    for k, item in ipairs(l.content) do
      local label = pandoc.Inlines({ pandoc.Str(M.numbering(pat, a.start + k - 1)), pandoc.Space() })
      for j, b in ipairs(item) do
        if j == 1 and b.t == "Plain" and #item == 1 then
          if acc then acc:insert(pandoc.SoftBreak()) else acc = pandoc.Inlines({}) end
          acc:extend(label)
          acc:extend(b.content)
        elseif j == 1 and (b.t == "Para" or b.t == "Plain") then
          flush()
          label:extend(b.content)
          out:insert(pandoc.Para(label))
        else
          flush()
          out:insert(b)
        end
      end
    end
    flush()
    return out
  end })
end


-- No line break at a space before a closing mark (". . .", "word ,", "x )"): typst never breaks there, even after a
-- space (Unicode LB13: no break before a full stop, comma, colon, semicolon, "!", "?", a closing bracket or a slash:
-- " /s/"), LaTeX and LibreOffice did at any space of a spaced ellipsis. Such a space becomes `glue()`, a no-break
-- space of the engine (LaTeX \nobreakspace: xengine.lua turns a U+00A0 after a period back into a space; Word U+00A0).
M.NO_BREAK_BEFORE = "^[%.,:;!%?%)%]}/]"
function M.bind_punct(l, glue)
  for i = 1, #l - 1 do
    local a, b = l[i], l[i + 1]
    if (a.t == "Space" or a.t == "SoftBreak") and b.t == "Str" and b.text:find(M.NO_BREAK_BEFORE) then l[i] = glue() end
  end
  return l
end

-- Links as their text (layout.yaml `links: false`, a court that bars hyperlinks): every link of the blocks but a
-- keyed authority's (toa:), which xd.mark has read (lib/typst/xdoc.typ alike).
function M.unlink(spec, blocks)
  if spec.links ~= false then return blocks end
  return blocks:walk({ Link = function(l)
    if not l.target:find("^toa:") then return l.content end
  end })
end

-- The token after a section or pilcrow sign ("§ 75–1–102(1)(a)–(b)", "§ 807-1-A4") is never broken: typst boxes the
-- sign with it (lib/typst/xengine.typ "[§¶] \S+"), while LaTeX and LibreOffice break after its hyphens and dashes.
-- `hold(pieces)` gives what replaces the token's inlines (up to the next space or footnote: a note held in a LaTeX
-- \mbox is lost); the sign and its space as before.
function M.hold_sign_tokens(l, hold)
  local out, i = pandoc.Inlines({}), 1
  local function space(x) return x and (x.t == "Space" or (x.t == "Str" and x.text == "\u{00A0}")) end
  while i <= #l do
    local el = l[i]
    out:insert(el)
    if el.t == "Str" and (el.text:find("\u{00A7}$") or el.text:find("\u{00B6}$")) and space(l[i + 1]) then
      out:insert(l[i + 1])
      local j, pieces = i + 2, pandoc.Inlines({})
      while j <= #l and l[j].t ~= "Space" and l[j].t ~= "SoftBreak" and l[j].t ~= "LineBreak" and l[j].t ~= "Note" do
        pieces:insert(l[j])
        j = j + 1
      end
      if #pieces > 0 then out:extend(hold(pieces)) end
      i = j
    else
      i = i + 1
    end
  end
  return out
end
-- A doubled section or pilcrow sign stays with the number after it ("§§ 3146.2c", "¶¶ 4-8"), in every engine: a no-break
-- space (lib/typst/xdoc.typ boxes the signs with their number; xengine binds a single sign only).
function M.bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end


-- The body sections set before the tables (layout.yaml `body_before_tables`; lib/typst/xdoc.typ split-head), and the
-- rest: `count: N`, the blocks before the body's (N+1)th level-1 heading; `until: <text>`, the blocks before the first
-- level-1 heading that starts with it; `marker: <text>`, the blocks before a paragraph that is that text alone (the
-- paragraph dropped; the text literal, "{{contents}}"). A count or heading may read a field ("{before_toc}",
-- "{body_start}"); a missing or empty one, or a split the body does not hold, sets nothing before the tables.
function M.split_head(spec, blocks, meta)
  local b = spec.body_before_tables
  local pre, main = pandoc.Blocks({}), pandoc.Blocks({})
  if not b then return pre, blocks end
  local function value(v)
    local ps = M.expand(tostring(v), meta, true)
    return ps[1] ~= nil and ps[1] ~= "" and ps[1] or nil
  end
  local at, drop
  if b.marker then
    local m = tostring(b.marker) -- literal text ("{{contents}}")
    for i, x in ipairs(blocks) do
      if m and (x.t == "Para" or x.t == "Plain") and pandoc.utils.stringify(x) == m then at, drop = i, true; break end
    end
  elseif b["until"] then
    local u = value(b["until"])
    for i, x in ipairs(blocks) do
      if u and x.t == "Header" and x.level == 1 and pandoc.utils.stringify(x.content):sub(1, #u) == u then
        at = i; break
      end
    end
  elseif b.count then
    local n, seen = tonumber(value(b.count)), 0
    for i, x in ipairs(blocks) do
      if n and x.t == "Header" and x.level == 1 then
        seen = seen + 1
        if seen == n + 1 then at = i; break end
      end
    end
  else
    error("xdoc: body_before_tables needs count, until or marker", 0)
  end
  if not at or at == 1 and not drop then return pre, blocks end
  for i, x in ipairs(blocks) do
    if i < at then pre:insert(x) elseif i > at or not drop then main:insert(x) end
  end
  return pre, main
end
-- The body blocks before the tail heading (`tail.at`, a level-1 heading that starts with it), and the rest.
function M.split_tail(spec, blocks)
  local main, rest = pandoc.Blocks({}), pandoc.Blocks({})
  local at = spec.tail and spec.tail.at
  local into = main
  for _, b in ipairs(blocks) do
    if at and into == main and b.t == "Header" and b.level == 1
      and pandoc.utils.stringify(b.content):find("^" .. at) then
      into = rest
    end
    into:insert(b)
  end
  return main, rest
end

-- ---------------------------------------------------------------------------------------------------------------
-- Contents and authorities (lib/typst/xdoc.typ contents-pages, authorities-pages)
-- ---------------------------------------------------------------------------------------------------------------

-- The entries of the frontmatter's table of authorities, in order, numbered k = 1, 2, .. as typst numbers them:
-- { k, group, cite, find, pages }.
-- Whether the frontmatter's authorities are keyed (a map {key: {kind, name, cite, sort}}), not a list of groups.
function M.is_keyed(meta)
  local au = meta.authorities
  return type(au) == "table" and au[1] == nil and next(au) ~= nil
end

-- The sort key of a keyed authority (lib/typst/xdoc.typ sort-key): its `sort`, else its name and citation, in lower
-- case, letters, digits and spaces only.
function M.sort_key(e)
  local s = e.sort or ((e.name or "") .. " " .. (e.cite or ""))
  return (pandoc.text.lower(tostring(s)):gsub("[^a-z0-9 ]", ""))
end

-- The keyed authorities grouped by layout.yaml authorities.kinds (lib/typst/xdoc.typ keyed-entries): every entry,
-- group by group, sorted by sort key then key, numbered k from 1: { k, key, group, kind, name, cite }; and by key.
function M.keyed(spec, meta)
  local kinds = spec.authorities and spec.authorities.kinds
  -- (no map without kinds: a layout without the keyed table leaves the links as they are)
  if not M.is_keyed(meta) or not kinds then return {}, nil end
  local known = {}
  for _, g in ipairs(kinds) do known[g.kind] = true end
  for key, e in pairs(meta.authorities) do
    if not known[e.kind] then
      error("xdoc: authority `" .. key .. "` has kind `" .. tostring(e.kind)
        .. "`, which no group of layout.yaml authorities.kinds lists", 0)
    end
  end
  local out, by = {}, {}
  for gi, g in ipairs(kinds) do
    local es = {}
    for key, e in pairs(meta.authorities) do
      if e.kind == g.kind then es[#es + 1] = { key = key, sk = M.sort_key(e), e = e } end
    end
    table.sort(es, function(a, b) if a.sk ~= b.sk then return a.sk < b.sk end return a.key < b.key end)
    for _, x in ipairs(es) do
      local n = { k = #out + 1, key = x.key, group = gi, kind = x.e.kind, name = x.e.name, cite = x.e.cite }
      out[#out + 1] = n
      by[x.key] = n
    end
  end
  return out, by
end

-- The markdown of a keyed authority's row (lib/typst/xdoc.typ keyed-text).
function M.keyed_text(g, e)
  if not M.is_set(e.name) then return tostring(e.cite) end
  if g.italic then return "*" .. e.name .. "* " .. tostring(e.cite) end
  return e.name .. ", " .. tostring(e.cite)
end

function M.authority_entries(meta)
  local out = {}
  if M.is_keyed(meta) then return out end
  for gi, g in ipairs(meta.authorities or {}) do
    for _, e in ipairs(g.entries or {}) do
      -- `finds`: several strings that cite the entry; `find` the first of them (lib/typst/xdoc.typ alike)
      local finds = e.finds or (e.find and { e.find }) or {}
      out[#out + 1] = { k = #out + 1, group = gi, cite = e.cite, find = e.find or finds[1], finds = finds, pages = e.pages }
    end
  end
  return out
end

local CONTAINERS = { Emph = true, Strong = true, Underline = true, Strikeout = true, SmallCaps = true, Span = true,
  Link = true, Quoted = true, Superscript = true, Subscript = true }

-- Every occurrence of an authority's `find` text in the blocks, marked right after the text element it ends in (typst
-- marks the end of the word the match ends in): `mark(k, note, after, find, before, upto)` gives the inline to insert (`note`:
-- inside a footnote; `after`: the text of the run from the end of the match on; `before`: when fewer than 16 letters
-- and digits follow in the run, up to 40 characters of the run before the match, else ""; `upto`: a keyed
-- authority's first word, where its mark is, else nil: the find's end). Matches are found within one run of words and spaces (typst
-- matches text the same way: not across italics), and come out in document order (a footnote's where its mark is).
function M.mark(blocks, entries, mark, keyed)
  local mark_blocks
  -- `list` with `m` after its first word (into italics, bold, quotes), and that word: a keyed authority's page is
  -- its citation's first word's (lib/typst/xdoc.typ after-first-word)
  local function after_first_word(list, m)
    local out, placed, word = pandoc.Inlines({}), false, nil
    for _, el in ipairs(list) do
      if placed then out:insert(el)
      elseif el.t == "Str" then out:insert(el); out:insert(m); placed, word = true, el.text
      elseif el.content and type(el.content) ~= "string" and el.t ~= "Note" then
        local inner
        inner, placed, word = after_first_word(el.content, m)
        el.content = inner
        out:insert(el)
      else out:insert(el) end
    end
    return out, placed, word
  end
  local function mark_inlines(list, note)
    local out = pandoc.Inlines({})
    local run = {} -- the current run: { el, text } of Str, Space, SoftBreak
    local function flush()
      if #run == 0 then return end
      local text, ends = "", {}
      for i, r in ipairs(run) do
        text = text .. r.text
        ends[i] = #text
      end
      local hits = {} -- run element index -> { {k, after}, .. } in order of their end
      local found = {}
      for _, e in ipairs(entries) do
        for _, fd in ipairs(e.finds or (e.find and { e.find }) or {}) do
          local from = 1
          while fd ~= "" do
            local a, b = text:find(fd, from, true)
            if not a then break end
            -- a find that ends in a letter or digit ends where the word does ("Art. V" is not in "Art. VII"; lib/typst/xdoc.typ
            -- with-marks \b)
            if not (fd:find("%w$") and text:sub(b + 1, b + 1):find("^%w")) then
              found[#found + 1] = { s = a, e = b, k = e.k, after = text:sub(b + 1), find = fd }
            end
            from = b + 1
          end
        end
      end
      table.sort(found, function(x, y) if x.e ~= y.e then return x.e < y.e end return x.k < y.k end)
      -- the words before a match too when few follow it in the run (a footnote mark or the paragraph's end cuts it: the
      -- citation alone, "6.855(1)", would be found at an earlier occurrence), back to the end of the match before it at
      -- most (the needles are found in document order, each after the one before)
      local prev = 0
      for _, f in ipairs(found) do
        f.before = #M.norm(f.after) < 16 and text:sub(math.max(prev + 1, f.s - 40), f.s - 1) or ""
        prev = f.e
      end
      for _, f in ipairs(found) do
        for i = 1, #run do
          if ends[i] >= f.e then
            hits[i] = hits[i] or {}
            table.insert(hits[i], f)
            break
          end
        end
      end
      for i, r in ipairs(run) do
        out:insert(r.el)
        for _, f in ipairs(hits[i] or {}) do out:insert(mark(f.k, note, f.after, f.find, f.before)) end
      end
      run = {}
    end
    for li, el in ipairs(list) do
      if el.t == "Str" then
        run[#run + 1] = { el = el, text = el.text:gsub("\u{00A0}", " ") }
      elseif el.t == "Space" or el.t == "SoftBreak" then
        run[#run + 1] = { el = el, text = " " }
      elseif el.t == "Link" and keyed and el.target:find("^toa:") then
        -- a keyed authority's link: its text, the entry's mark after the first word
        flush()
        local e = keyed[el.target:sub(5)]
        if not e then error("xdoc: the link `" .. el.target .. "` has no entry under the frontmatter's authorities", 0) end
        local content = mark_inlines(el.content, note)
        local rest = pandoc.utils.stringify(content)
        local first = rest:match("^%s*(%S+)") or ""
        -- the needle: the citation and the words after the link (the citation alone is in the table itself)
        local after = pandoc.Inlines({})
        for j = li + 1, #list do if list[j].t ~= "Note" then after:insert(list[j]) end end
        local tail = pandoc.utils.stringify(after):sub(1, 64)
        -- (the find: the whole citation, the fallback a needle that runs over a page end; its mark after the first
        -- word, `first`: a citation over a page end counts on its first word's page, as typst sets it)
        local inl = after_first_word(content, mark(e.k, note, tail, rest, nil, first))
        out:extend(inl)
      else
        flush()
        if el.t == "Note" then
          el.content = mark_blocks(el.content, true)
        elseif CONTAINERS[el.t] then
          el.content = mark_inlines(el.content, note)
        end
        out:insert(el)
      end
    end
    flush()
    return out
  end
  mark_blocks = function(bs, note)
    local out = pandoc.Blocks({})
    for _, b in ipairs(bs) do
      if b.t == "Para" or b.t == "Plain" or b.t == "Header" then
        b.content = mark_inlines(b.content, note)
      elseif b.t == "BlockQuote" or b.t == "Div" then
        b.content = mark_blocks(b.content, note)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        local items = {}
        for _, it in ipairs(b.content) do items[#items + 1] = mark_blocks(it, note) end
        b.content = items
      end
      out:insert(b)
    end
    return out
  end
  return mark_blocks(blocks, false)
end

-- The headings of the blocks to `depth`, in order: { n (1, 2, ..), level, content }.
function M.headings(blocks, depth)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= (depth or 3) then
      out[#out + 1] = { n = #out + 1, level = b.level, content = b.content }
    end
  end
  return out
end

-- Text reduced as the docx engine's page lookup reduces it (tools/fb/src/docxpages.rs norm): lower-case ASCII
-- letters and digits.
function M.norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- The pages of an authority from the page labels of its marks, in order and without repeats ("--" when none; the
-- entry's own `pages` when it has no `find`): typst's dedup; `passim` (layout.yaml authorities.passim) pages or more
-- are "passim" and true (set in italics, as lib/typst/xdoc.typ sets it).
function M.page_list(e, labels, passim)
  if not e.find and not e.key then return e.pages and tostring(e.pages) or "--" end
  local seen, out = {}, {}
  for _, l in ipairs(labels) do
    if not seen[l] then seen[l] = true; out[#out + 1] = l end
  end
  if #out == 0 then return "--" end
  if passim and #out >= tonumber(passim) then return "passim", true end
  return table.concat(out, ", ")
end

-- ---------------------------------------------------------------------------------------------------------------
-- Values the model computes (lib/typst/xdoc.typ count-words, counted-text, computed): `{xd.words}`
-- ---------------------------------------------------------------------------------------------------------------

-- The words of markdown text, whitespace-delimited as a word processor counts them, the markup taken out first, in
-- the steps and order of lib/typst/xdoc.typ count-words (both give the same count).
function M.count_words(src)
  local s = "\n" .. src .. "\n"
  for _, sp in ipairs({ "\u{00A0}", "\u{2002}", "\u{2003}", "\u{2009}", "\u{202F}" }) do
    s = s:gsub(sp, " ")
  end
  s = s:gsub("<!%-%-.-%-%->", " ")
  s = s:gsub("%[%^[^%]]+%]", "")
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")
  s = s:gsub("<br>", " ")
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[-*+][ \t]+", "\n")
  s = s:gsub("\n[ \t]*%d+[.)][ \t]+", "\n")
  s = s:gsub("\\([^\n])", "%1")
  s = s:gsub("%*", "")
  s = s:gsub("([ \t\n\r%(%[\"])_", "%1")
  s = s:gsub("\u{201C}_", "\u{201C}")
  s = s:gsub("_([ \t\n\r%.,;:%)%]\"!%?])", "%1")
  s = s:gsub("_\u{201D}", "\u{201D}")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

-- A count with its thousands grouped ("11,942").
function M.group_digits(n)
  local s = string.format("%d", n)
  return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function starts(s, p) return s:sub(1, #p) == p end

-- The text a word count reads (layout.yaml `words`; lib/typst/xdoc.typ counted-text): the body up to the tail
-- heading, the level-1 sections from `from` through `through` (with `sections`, those whose title starts with one
-- listed), less the `exclude`d ones, and the footnotes they call.
function M.counted_text(spec, body)
  local w = spec.words
  local at = spec.tail and spec.tail.at
  local defs, lines, cur = {}, {}, nil
  for l in (body .. "\n"):gmatch("([^\n]*)\n") do
    l = l:gsub("\r$", "")
    local k, rest = l:match("^%[%^([^%]]+)%]:(.*)$")
    if k then
      cur = k
      defs[k] = rest
    elseif cur and (starts(l, "    ") or starts(l, "\t")) then
      defs[cur] = defs[cur] .. "\n" .. l
    else
      cur = nil
      lines[#lines + 1] = l
    end
  end
  local secs = { { lines = {} } }
  for _, l in ipairs(lines) do
    local head = l:match("^# +(.*)$")
    if head then
      if at and starts(head, at) then break end
      secs[#secs + 1] = { head = head, lines = { l } }
    else
      table.insert(secs[#secs].lines, l)
    end
  end
  local function is(s, p) return s.head ~= nil and starts(s.head, p) end
  local function find(p, what)
    for i, s in ipairs(secs) do if is(s, p) then return i end end
    error("xdoc: words." .. what .. ": no level-1 heading starts with `" .. p .. "`", 0)
  end
  if w.from then secs = { table.unpack(secs, find(w.from, "from")) } end
  if w.through then secs = { table.unpack(secs, 1, find(w.through, "through")) } end
  -- `sections`: only the level-1 sections whose title (lower case, without "*") starts with one listed
  if w.sections and #w.sections > 0 then
    local only = {}
    for _, s in ipairs(secs) do
      local t = s.head and s.head:gsub("%*", ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
      for _, p in ipairs(w.sections) do
        if t and starts(t, tostring(p):lower()) then only[#only + 1] = s; break end
      end
    end
    secs = only
  end
  local kept = {}
  for _, s in ipairs(secs) do
    local out = false
    for _, p in ipairs(w.exclude or {}) do if is(s, p) then out = true end end
    if not out then kept[#kept + 1] = table.concat(s.lines, "\n") end
  end
  local text = table.concat(kept, "\n")
  local parts, called = { text }, {}
  for k in text:gmatch("%[%^([^%]]+)%]") do
    if defs[k] and not called[k] then called[k] = true; parts[#parts + 1] = defs[k] end
  end
  return table.concat(parts, "\n")
end

-- The sample's body as written: the file pandoc reads, without its frontmatter.
function M.sample_body()
  local path = PANDOC_STATE.input_files[1]
  local f = path and io.open(path, "r")
  if not f then error("xdoc: cannot read the sample " .. tostring(path), 0) end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  return e and src:sub(e + 1) or src
end

-- The frontmatter with the values the model computes (`xd.words`); a count over `words.limit` (or the frontmatter
-- field `words.limit_field` names) stops the render; `words.given`: a frontmatter field that states the count instead
-- (lib/typst/xdoc.typ computed alike).
function M.computed(spec, meta)
  -- `constants`: the layout's court constants (a district's name in the generic FRCP base, fb-595.17) as {xd.<key>}
  if spec.constants then
    meta.xd = meta.xd or {}
    for k, v in pairs(spec.constants) do meta.xd[k] = v end
  end
  if not spec.words then return meta end
  local w = spec.words
  local n
  if w.given and M.is_set(meta[w.given]) then n = math.floor(tonumber(meta[w.given])) else
    n = M.count_words(M.counted_text(spec, M.sample_body())) end
  local limit = tonumber(w.limit_field and meta[w.limit_field] or nil) or tonumber(w.limit)
  if limit and n > limit then
    error("xdoc: the body has " .. n .. " words, over the limit of " .. string.format("%d", limit)
      .. " (layout.yaml words.limit)", 0)
  end
  meta.xd = meta.xd or {}
  meta.xd.words = M.group_digits(n)
  return meta
end

return M

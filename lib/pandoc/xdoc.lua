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

-- The value at a dotted path ("a.b"; "." the context itself), or nil.
function M.lookup(ctx, path)
  if path == "." then return ctx["."] end
  local v = ctx
  for k in path:gmatch("[^.]+") do
    if type(v) ~= "table" then return nil end
    v = v[k]
  end
  return v
end

local function str(v)
  if type(v) == "number" and v == math.floor(v) then return string.format("%d", v) end
  return tostring(v)
end

-- The paragraphs of a text template (lib/typst/xdoc.typ `expand`): "{path}" alone with a list value gives one per
-- item; otherwise every {path} is replaced by its value; each is then split at "<br>". A missing value is an error,
-- or gives no paragraph when `optional`.
function M.expand(tpl, ctx, optional)
  local out = {}
  local whole = tpl:match("^{([^{}]+)}$")
  local v = whole and M.lookup(ctx, whole)
  if type(v) == "table" then -- a list (an empty one gives no paragraph, as in typst)
    for _, x in ipairs(v) do out[#out + 1] = str(x) end
  else
    local missing = false
    local s = tpl:gsub("{([^{}]+)}", function(p)
      local x = M.lookup(ctx, p)
      if x == nil then
        if optional then missing = true; return "" end
        error("xdoc: missing required metadata field `" .. p .. "`", 0)
      end
      return str(x)
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

-- Inlines in capitals (a style's `upper`).
function M.upper(inlines)
  return inlines:walk({ Str = function(x) return pandoc.Str(pandoc.text.upper(x.text)) end })
end

local function num(x) return tonumber(x) or 0 end

local function copy(t)
  local o = {}
  for k, v in pairs(t) do o[k] = v end
  return o
end

-- The context of an item of a list: its fields (a map item) and "." (the item) over the outer context.
function M.item_ctx(ctx, it)
  local c = copy(ctx)
  if type(it) == "table" then for k, v in pairs(it) do c[k] = v end end
  c["."] = it
  return c
end

-- The nodes of a block list (lib/typst/xdoc.typ `blocks`, rule for rule).
function M.tree(spec, list, ctx, first)
  local out = {}
  for _, b in ipairs(list or {}) do
    local lead = first and num(b.above) or 0
    local above = first and 0 or num(b.above)
    local below = num(b.below)
    if b.text ~= nil then
      local ps = M.expand(tostring(b.text), ctx, b.optional)
      for i, s in ipairs(ps) do
        local text = M.inlines(s)
        if b.upper then text = M.upper(text) end
        out[#out + 1] = { t = "par", text = text, st = b, lead = i == 1 and lead or 0,
          above = i == 1 and above or 0, below = i == #ps and below or 0 }
      end
      if #ps > 0 then first = false end
    elseif b.rule ~= nil then
      out[#out + 1] = { t = "rule", w = num(b.rule), lead = lead, above = above, below = below }
      first = false
    elseif b.columns ~= nil then
      -- a list of columns, or one column per item of a list (`each`), each with its context
      -- (`per_row`: that many columns a row, the rows `row_gap` apart; a short last row keeps the widths)
      local rows = {}
      if b.columns.each ~= nil then
        local items = M.lookup(ctx, b.columns.each)
        if items == nil then error("xdoc: missing required metadata field `" .. b.columns.each .. "`", 0) end
        local n = tonumber(b.columns.per_row) or #items
        for i = 1, #items, math.max(n, 1) do
          local cols = {}
          for j = i, i + n - 1 do
            local it = items[j]
            cols[#cols + 1] = { width = b.columns.width, valign = b.columns.valign,
              items = it ~= nil and M.tree(spec, b.columns.blocks, M.item_ctx(ctx, it), true) or {} }
          end
          rows[#rows + 1] = cols
        end
      else
        local cols = {}
        for _, c in ipairs(b.columns) do
          cols[#cols + 1] = { width = c.width, valign = c.valign, items = M.tree(spec, c.blocks, ctx, true) }
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
          for _, n in ipairs(M.tree(spec, b.between, ctx, false)) do out[#out + 1] = n end
        end
        local ictx = M.item_ctx(ctx, it)
        local bl = b.blocks
        if i == 1 and #bl > 0 then
          bl = copy(bl)
          bl[1] = copy(bl[1])
          bl[1].above = math.max(num(b.above), num(bl[1].above))
        end
        for _, n in ipairs(M.tree(spec, bl, ictx, first and i == 1)) do out[#out + 1] = n end
      end
      if #items > 0 then first = false end
    elseif b.when ~= nil then
      -- the blocks, when the frontmatter has the field
      if M.lookup(ctx, b.when) ~= nil then
        for _, n in ipairs(M.tree(spec, b.blocks, ctx, first)) do out[#out + 1] = n end
        first = false
      end
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
  return out
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
function M.authority_entries(meta)
  local out = {}
  for gi, g in ipairs(meta.authorities or {}) do
    for _, e in ipairs(g.entries or {}) do
      out[#out + 1] = { k = #out + 1, group = gi, cite = e.cite, find = e.find, pages = e.pages }
    end
  end
  return out
end

local CONTAINERS = { Emph = true, Strong = true, Underline = true, Strikeout = true, SmallCaps = true, Span = true,
  Link = true, Quoted = true, Superscript = true, Subscript = true }

-- Every occurrence of an authority's `find` text in the blocks, marked right after the text element it ends in (typst
-- marks the end of the word the match ends in): `mark(k, note, after)` gives the inline to insert (`note`: inside a footnote; `after`:
-- the text of the run from the end of the match on). Matches are found within one run of words and spaces (typst
-- matches text the same way: not across italics), and come out in document order (a footnote's where its mark is).
function M.mark(blocks, entries, mark)
  local mark_blocks
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
        if e.find and e.find ~= "" then
          local from = 1
          while true do
            local a, b = text:find(e.find, from, true)
            if not a then break end
            found[#found + 1] = { e = b, k = e.k, after = text:sub(b + 1) }
            from = b + 1
          end
        end
      end
      table.sort(found, function(x, y) if x.e ~= y.e then return x.e < y.e end return x.k < y.k end)
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
        for _, f in ipairs(hits[i] or {}) do out:insert(mark(f.k, note, f.after)) end
      end
      run = {}
    end
    for _, el in ipairs(list) do
      if el.t == "Str" then
        run[#run + 1] = { el = el, text = el.text:gsub("\u{00A0}", " ") }
      elseif el.t == "Space" or el.t == "SoftBreak" then
        run[#run + 1] = { el = el, text = " " }
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
-- entry's own `pages` when it has no `find`): typst's dedup.
function M.page_list(e, labels)
  if not e.find then return e.pages and tostring(e.pages) or "--" end
  local seen, out = {}, {}
  for _, l in ipairs(labels) do
    if not seen[l] then seen[l] = true; out[#out + 1] = l end
  end
  if #out == 0 then return "--" end
  return table.concat(out, ", ")
end

return M

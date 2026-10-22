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

-- The value at a dotted path ("a.b"; "." the context itself), or nil; "a.b|text": the text when there is none
-- (lib/typst/xdoc.typ lookup alike).
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

-- A number in a typst numbering pattern of one counting symbol ("I.", "A.", "1.", "(a)", "i."): what is before the
-- symbol, the number in its form, what is after (typst numbering() for these patterns).
local function roman(n)
  local out = ""
  for _, p in ipairs({ { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function alpha(n)
  local out = ""
  while n > 0 do
    n = n - 1
    out = string.char(65 + n % 26) .. out
    n = n // 26
  end
  return out
end

function M.numbering(pattern, n)
  local a = pattern:find("[1IiAa]")
  if not a then error("xdoc: a heading number pattern needs one of 1, I, i, A, a: `" .. pattern .. "`", 0) end
  local sym = pattern:sub(a, a)
  local v = sym == "1" and string.format("%d", n) or sym == "I" and roman(n) or sym == "i" and roman(n):lower()
    or sym == "A" and alpha(n) or alpha(n):lower()
  return pattern:sub(1, a - 1) .. v .. pattern:sub(a + 1)
end

-- The heading numbers (layout.yaml heading styles with `number`, lib/typst/xdoc.typ heading-label): every heading in
-- document order steps typst's heading counter (from (0): level n adds one at n and drops the deeper levels, or pads
-- with 1s up to n), and a level whose style has a `number` pattern shows the count at its level in it. The label goes
-- into the heading's attribute `xd-label`.
function M.number_headings(spec, blocks)
  local numbered = false
  for _, h in ipairs(spec.heading or {}) do if h.number then numbered = true end end
  if not numbered then return end
  local c = { 0 }
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local l = b.level
      if #c >= l then
        c[l] = c[l] + 1
        for k = #c, l + 1, -1 do c[k] = nil end
      else
        while #c < l do c[#c + 1] = 1 end
      end
      local st = M.heading(spec, l)
      if st.number then b.attributes["xd-label"] = M.numbering(st.number, c[l]) end
    end
  end
end

-- The words of the body before the tail heading (`{body_words}` in a block; lib/typst/xdoc.typ count-words): the
-- sample's markdown after its frontmatter, cut at the tail heading, split at white space; a word holds an ASCII letter
-- or digit (so a footnote definition's "[^1]:" counts, a lone dash does not).
local USPACE = { "\u{00A0}", "\u{1680}", "\u{2000}", "\u{2001}", "\u{2002}", "\u{2003}", "\u{2004}", "\u{2005}",
  "\u{2006}", "\u{2007}", "\u{2008}", "\u{2009}", "\u{200A}", "\u{2028}", "\u{2029}", "\u{202F}", "\u{205F}",
  "\u{3000}", "\u{0085}" }
function M.count_words(src, at)
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

-- The frontmatter with the computed fields: `body_words` (M.count_words of the sample pandoc reads).
function M.context(spec, meta)
  local path = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local f = path and io.open(path, "r")
  if f and meta.body_words == nil then
    meta.body_words = M.count_words(f:read("a"), spec.tail and spec.tail.at)
  end
  if f then f:close() end
  return meta
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
    local out = pandoc.Blocks({})
    for k, item in ipairs(l.content) do
      local label = pandoc.Inlines({ pandoc.Str(M.numbering(pat, a.start + k - 1)), pandoc.Space() })
      for j, b in ipairs(item) do
        if j == 1 and (b.t == "Para" or b.t == "Plain") then
          label:extend(b.content)
          out:insert(pandoc.Para(label))
        else
          out:insert(b)
        end
      end
    end
    return out
  end })
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

-- The headings of the blocks to `depth`, in order: { n (1, 2, ..), level, content, row }; `row`, the text of its row in
-- the contents: its number (M.number_headings), a space and its text.
function M.headings(blocks, depth)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= (depth or 3) then
      local label = b.attributes["xd-label"]
      local row = b.content
      if label then
        row = pandoc.Inlines({ pandoc.Str(label), pandoc.Space() })
        row:extend(b.content)
      end
      out[#out + 1] = { n = #out + 1, level = b.level, content = b.content, row = row }
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

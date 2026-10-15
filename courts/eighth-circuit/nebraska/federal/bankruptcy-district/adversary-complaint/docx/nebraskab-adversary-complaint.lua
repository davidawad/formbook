-- Adversary complaint for the United States Bankruptcy Court, District of Nebraska (nebraskab), DOCX engine
-- (docs/DOCX.md): the markdown contract (YAML frontmatter + body) -> a Word document on reference.docx.
-- Mirrors typst/nebraskab-adversary-complaint.typ: court name, the caption in a borderless table (the "In re"
-- block with a rule under it, then the parties with "v."; chapter, case and adversary lines on the right), the
-- title in capitals, numbered allegations from the first heading to the prayer, lettered prayer items, and the
-- signature block kept together. Every case-specific word comes from the sample's frontmatter, never from here.
-- Known limits (see README.md, "Engines"): paragraph numbers are typed by this filter (as in the typst
-- template), not Word list numbering; the caption rule is a paragraph border, not a drawn line.

local NBSP = "\u{a0}"
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local COURT_NAME = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEBRASKA" }
local LETTERS = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p" }
local CONSENT = "consent to the entry of final orders"

-- a metadata value as a list of inlines: a string is "Inlines"; markdown blocks are "Blocks"
local function inlines(v)
  local out = pandoc.Inlines({})
  if v == nil then return out end
  local kind = pandoc.utils.type(v)
  if kind == "Inlines" then
    for _, x in ipairs(v) do out:insert(x) end
  elseif kind == "Blocks" then
    out = pandoc.utils.blocks_to_inlines(v)
  else
    out:insert(pandoc.Str(pandoc.utils.stringify(v)))
  end
  return out
end

-- a metadata list ("List") as Lua values; a single value is a list of one
local function items(v)
  local out = {}
  if v == nil then return out end
  if pandoc.utils.type(v) == "List" then
    for _, x in ipairs(v) do out[#out + 1] = x end
  else
    out[1] = v
  end
  return out
end

-- keep "§" with the number after it: a space beside "§" becomes a no-break space (typst nbsp-sections)
local function nbsp_sections(ins)
  local list = {}
  for i = 1, #ins do list[i] = ins[i] end
  for i = 1, #list do
    if list[i].t == "Space" then
      local prev, nxt = list[i - 1], list[i + 1]
      local after_sect = prev and prev.t == "Str" and prev.text:sub(-2) == "§"
      local before_sect = nxt and nxt.t == "Str" and nxt.text:sub(1, 2) == "§"
      if after_sect or before_sect then list[i] = pandoc.Str(NBSP) end
    end
  end
  return pandoc.Inlines(list)
end

local function upper_inlines(ins)
  return pandoc.Inlines(ins):walk({
    Str = function(s)
      s.text = pandoc.text.upper(s.text)
      return s
    end,
  })
end

-- a paragraph in a named style (Div with custom-style: pandoc applies the style to its paragraphs)
local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function line(style, ins)
  return styled(style, { pandoc.Para(ins) })
end

local function gap(style)
  return styled(style, { pandoc.Para({}) })
end

-- a borderless two-column table: left cell, a 0.25 in gutter, right cell (typst grid, caption-left 3.4 in)
local function grid(left, right)
  local function cell(blocks) return pandoc.Cell(blocks) end
  local body = { attr = pandoc.Attr(), row_head_columns = 0, head = {}, body = {
    pandoc.Row({ cell(left), cell({}), cell(right) }),
  } }
  return pandoc.Table(pandoc.Caption(""),
    { { pandoc.AlignDefault, 3.4 / 6.5 }, { pandoc.AlignDefault, 0.25 / 6.5 }, { pandoc.AlignDefault, 2.85 / 6.5 } },
    pandoc.TableHead({}), { body }, pandoc.TableFoot({}))
end

local function caption(meta)
  local left, right = {}, {}
  left[#left + 1] = line("Single", { pandoc.Str("In re:") })
  for _, v in ipairs(items(meta.in_re)) do left[#left + 1] = line("Single", nbsp_sections(inlines(v))) end
  left[#left + 1] = gap("CaptionRule")
  for k, p in ipairs(items(meta.parties)) do
    if k > 1 then
      left[#left + 1] = gap("CaptionGap")
      left[#left + 1] = line("CaptionIndent", { pandoc.Str("v.") })
      left[#left + 1] = gap("CaptionGap")
    end
    for _, n in ipairs(items(p.names)) do left[#left + 1] = line("Single", inlines(n)) end
    left[#left + 1] = gap("CaptionGap")
    left[#left + 1] = line("CaptionDesignation", inlines(p.designation))
  end

  right[#right + 1] = gap("CaptionGap")
  for _, v in ipairs(items(meta.chapter)) do right[#right + 1] = line("Single", inlines(v)) end
  for _, v in ipairs(items(meta.case_lines)) do right[#right + 1] = line("Single", inlines(v)) end
  right[#right + 1] = gap("DoubleGap")
  right[#right + 1] = line("Single", inlines(meta.adversary_line))
  return grid(left, right)
end

local function signature(meta)
  local right = {}
  right[#right + 1] = line("SingleKeep", { pandoc.Str("Respectfully submitted,") })
  right[#right + 1] = gap("CaptionGap")
  local blocks = items(meta.signature)
  for k, b in ipairs(blocks) do
    if k > 1 then right[#right + 1] = gap("CaptionGap") end
    local lines = items(b)
    for j, l in ipairs(lines) do
      local last = k == #blocks and j == #lines
      right[#right + 1] = line(last and "Single" or "SingleKeep", nbsp_sections(inlines(l)))
    end
  end
  local date = pandoc.Inlines({ pandoc.Str("Dated: ") })
  date:extend(inlines(meta.date))
  return grid({ line("SingleKeep", date) }, right)
end

function Pandoc(doc)
  local meta = doc.meta
  if not pandoc.utils.stringify(doc.blocks):find(CONSENT, 1, true) then
    error("nebraskab-adversary-complaint: the complaint must state consent to the entry of final orders (FRBP 7008(a))", 0)
  end
  doc = doc:walk({ Inlines = nbsp_sections })

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court name, caption, title (Official Form 416; FRBP 9004(b))
  for _, l in ipairs(COURT_NAME) do add(line("Centered", { pandoc.Strong({ pandoc.Str(l) }) })) end
  add(gap("DoubleGap"))
  add(caption(meta))
  add(gap("DoubleGap"))
  add(line("Centered", { pandoc.Strong(upper_inlines(nbsp_sections(inlines(meta.title)))) }))
  add(gap("DoubleGap"))

  -- body: allegations are numbered from the first heading to the prayer; the intro and the prayer are not
  local numbering, n = false, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local title = pandoc.utils.stringify(b.content)
      if b.level == 1 then
        numbering = pandoc.text.upper(title) ~= "PRAYER FOR RELIEF"
        b.content = upper_inlines(b.content)
      end
      add(b)
    elseif b.t == "Para" then
      if numbering then
        n = n + 1
        local ins = pandoc.Inlines({ pandoc.Str(tostring(n) .. "."), TAB })
        ins:extend(b.content)
        b.content = ins
      end
      add(b)
    elseif b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local ins = pandoc.Inlines({ pandoc.Str("(" .. LETTERS[k] .. ")"), TAB })
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then ins:extend(first.content) end
        local blocks = { pandoc.Para(ins) }
        for j = 2, #item do blocks[#blocks + 1] = item[j] end
        add(styled("Lettered", blocks))
      end
    else
      add(b)
    end
  end

  add(gap("DoubleGap"))
  add(signature(meta))

  -- pandoc would put the title and date above the court name (its docx title block); the caption has them
  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end

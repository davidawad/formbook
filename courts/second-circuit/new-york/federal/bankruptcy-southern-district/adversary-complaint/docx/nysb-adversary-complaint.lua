-- nysb adversary complaint, DOCX engine (docs/DOCX.md): markdown -> Word on docx/reference.docx, to the form of
-- typst/nysb-adversary-complaint.typ. Built here, as paragraphs and tables in the custom styles of reference.docx:
-- the counsel block, the court title, the Form 416D caption (a table; the party column has a right rule and a bottom
-- rule, drawn as paragraph borders), the title, a section break (the cover has no page number; the body restarts at 1),
-- the numbered paragraphs (Fed. R. Civ. P. 10(b)), the lettered prayer items, and the signature block (a table).
-- Numbers and letters are written as text (Word's list numbering would not give the same numbers after a break).
-- Known limits (see the PR and the README "Engines" section): the caption is a table in Word, so its rules and the
-- footnote placement follow Word's table layout; the pagination is LibreOffice's when the docx is checked.

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'

local function custom(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para(style, inlines)
  return custom(style, { pandoc.Para(inlines) })
end

-- a metadata value as inlines (YAML strings are markdown; a plain string becomes one Str)
local function to_inlines(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "table" and v.t == "MetaInlines" then return pandoc.Inlines(v) end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function is_true(v)
  return v ~= nil and pandoc.utils.stringify(v) == "true"
end

local function join(a, b)
  local out = pandoc.Inlines({})
  for _, x in ipairs(a) do out:insert(x) end
  for _, x in ipairs(b) do out:insert(x) end
  return out
end

-- a table without rules, the column widths as fractions of the text width
local function grid(widths, rows)
  local colspecs = {}
  for i, w in ipairs(widths) do colspecs[i] = { pandoc.AlignDefault, w } end
  local body = {}
  for _, r in ipairs(rows) do
    local cells = {}
    for _, blocks in ipairs(r) do cells[#cells + 1] = pandoc.Cell(blocks) end
    body[#body + 1] = pandoc.Row(cells)
  end
  return pandoc.Table(pandoc.Caption(), colspecs, pandoc.TableHead(), { pandoc.TableBody(body) }, pandoc.TableFoot())
end

local function cover(meta)
  local out = {}
  local n_sub = 0
  -- counsel (LBR 9004-1(a)(4)): one single-spaced line per item, a blank line between the firms
  local groups = meta.counsel or {}
  for gi, group in ipairs(groups) do
    for li, line in ipairs(group) do
      local style = (li == #group and gi < #groups) and "Single Gap" or "Single"
      out[#out + 1] = para(style, to_inlines(line))
    end
  end
  if meta.counsel_for then
    out[#out + 1] = para("Counsel For", { pandoc.Emph(to_inlines(meta.counsel_for)) })
  end
  out[#out + 1] = para("Court Name First", { pandoc.Str("UNITED STATES BANKRUPTCY COURT") })
  out[#out + 1] = para("Court Name Last", { pandoc.Str("SOUTHERN DISTRICT OF NEW YORK") })

  -- the caption (Form 416D): parties on the left with a right rule, the case data on the right
  local left = {}
  local function party(p, note_on_last)
    local names = p.names or {}
    for i, n in ipairs(names) do
      local inl = to_inlines(n)
      if i == #names and note_on_last and p.note then
        inl:insert(pandoc.Note({ pandoc.Para(to_inlines(p.note)) }))
      end
      left[#left + 1] = { "Caption Name", inl }
    end
    left[#left + 1] = { "Caption Designation", to_inlines(p.designation) }
  end
  local c = meta.caption
  party(c.debtors, true)
  for k, p in ipairs(c.parties or {}) do
    if k > 1 then left[#left + 1] = { "Caption Against", pandoc.Inlines({ pandoc.Str("against") }) } end
    party(p, false)
  end
  local last = left[#left]
  left[#left] = { "Caption End", last[2] }
  local left_blocks = {}
  for _, item in ipairs(left) do left_blocks[#left_blocks + 1] = para(item[1], item[2]) end

  local right_blocks = {
    para("Caption Right Gap", { pandoc.Str("Chapter " .. pandoc.utils.stringify(meta.chapter)) }),
    para("Single", { pandoc.Str("Case No. " .. pandoc.utils.stringify(meta.case_number)) }),
  }
  if is_true(meta.jointly_administered) then
    right_blocks[#right_blocks + 1] = para("Caption Right Gap", { pandoc.Str("(Jointly Administered)") })
  end
  right_blocks[#right_blocks + 1] = para("Caption Right", { pandoc.Str("Adv. Pro. No. " .. pandoc.utils.stringify(meta.adv_proc_no)) })
  out[#out + 1] = grid({ 3.35 / 6.5, 3.15 / 6.5 }, { { left_blocks, right_blocks } })

  out[#out + 1] = para("Cover Title", to_inlines(meta.title))
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr>' .. SECT_COVER .. '</w:pPr></w:p>')
  return out
end

-- the signature block: the date on the left, the firm and the signer on the right (typst: 2.8 in and 0.2 in gap)
local function signature(meta)
  local sig = meta.signature
  local right = {}
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = para("Signature Right", to_inlines(l)) end
  local signer = pandoc.utils.stringify(sig.signer)
  right[#right + 1] = para("Signature Gap", { pandoc.Str("By: /s/ " .. signer) })
  right[#right + 1] = para("Signature Right", { pandoc.Str(signer) })
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = para("Signature Right", to_inlines(l)) end
  local left = { para("Signature Left", { pandoc.Str("Dated: " .. pandoc.utils.stringify(meta.date)) }) }
  return grid({ 2.8 / 6.5, 3.7 / 6.5 }, { { left, right } })
end

local function letter(i)
  return "(" .. string.char(96 + i) .. ")"
end

function Pandoc(doc)
  local meta = doc.meta
  local body = {}
  local n = 0
  local n_sub = 0
  local last_div = nil

  local function add_numbered(inl)
    n = n + 1
    local d = custom("Num Para", { pandoc.Para(join({ pandoc.Str(tostring(n) .. ".") }, join({ TAB }, inl))) })
    body[#body + 1] = d
    last_div = d
  end

  local function add_unnumbered(inl)
    local d = custom("Body Para", { pandoc.Para(inl) })
    body[#body + 1] = d
    last_div = d
  end

  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local inl = b.content
      -- "^" marks an unnumbered paragraph (the WHEREFORE clause and the opening paragraph)
      local first = inl[1]
      if first and first.t == "Str" and first.text:sub(1, 1) == "^" then
        local rest = pandoc.Inlines({})
        if #first.text > 1 then rest:insert(pandoc.Str(first.text:sub(2))) end
        for i = 2, #inl do rest:insert(inl[i]) end
        if rest[1] and rest[1].t == "Space" then rest:remove(1) end
        add_unnumbered(rest)
      else
        add_numbered(inl)
      end
    elseif b.t == "Header" then
      -- headings: level 2 is lettered (A., B.) within its level-1 section, as in the template
      local label = nil
      if b.level == 1 then
        n_sub = 0
      elseif b.level == 2 then
        n_sub = n_sub + 1
        label = string.char(64 + n_sub) .. "."
      end
      local content = pandoc.Inlines({})
      if label then content:insert(pandoc.Str(label)); content:insert(TAB) end
      for _, x in ipairs(b.content) do content:insert(x) end
      body[#body + 1] = pandoc.Header(b.level, content)
      last_div = nil
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        local inl = (first and (first.t == "Plain" or first.t == "Para")) and first.content or pandoc.Inlines({})
        local lab = b.t == "OrderedList" and letter(i) or "\u{2022}"
        local d = custom("List Item", { pandoc.Para(join({ pandoc.Str(lab) }, join({ TAB }, inl))) })
        body[#body + 1] = d
        last_div = d
      end
    else
      body[#body + 1] = b
      last_div = nil
    end
  end

  -- the last body block keeps with the signature block, so the signature never stands alone
  if last_div then
    local s = last_div.attr.attributes["custom-style"]
    local map = { ["Body Para"] = "Body Last", ["Num Para"] = "Num Last", ["List Item"] = "List Last" }
    if map[s] then last_div.attr.attributes["custom-style"] = map[s] end
  end

  local blocks = cover(meta)
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = signature(meta)

  -- title, date and author are not printed by pandoc's docx writer; the cover prints them where the form does
  doc.meta = pandoc.Meta({})
  doc.blocks = blocks
  return doc
end

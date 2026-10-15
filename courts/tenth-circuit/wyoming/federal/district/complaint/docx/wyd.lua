-- D. Wyo. filing (wyd), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx
-- (build-reference.sh). The caption, attorney block, title, signature and certificate are built here from the
-- frontmatter, in the same order and with the same rules as typst/wyd-<doc type>.typ; the body keeps its
-- markdown structure, and the numbered allegations (Fed. R. Civ. P. 10(b)) are numbered here, as the typst
-- template numbers them. Page numbers come from the reference's footer.
-- The only part that differs between the two copies (complaint/docx/wyd.lua, motion-brief/docx/wyd.lua) is CFG.

local CFG = {
  kind = "complaint",
  court_name = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF WYOMING" },
  numbered = true,            -- complaint: numbered allegations; motion brief: unnumbered paragraphs
  designation_indent = false, -- "Plaintiff," flush under the party name (complaint); one inch (motion brief)
  letter_items = true,        -- complaint lists are lettered (a), (b); motion brief lists are numbered 1., 2.
  roman_headings = false,     -- motion brief: "I." and "A." headings hang; the complaint centers every heading
  jury_legend = true,         -- complaint: JURY TRIAL DEMANDED in the caption when frontmatter jury_demand is set
  date_key = "date",          -- complaint: "Dated: <date>"; motion brief: the frontmatter "dated" line as written
  certificate = false,        -- motion brief: certificate of service from the frontmatter
  separator = "vs.",          -- the caption row between the parties
  case_on_sep = false,        -- complaint: "Case No." at the top of the right column; motion brief: level with the separator
}

local function custom(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function blank(style)
  return custom({ pandoc.Para({}) }, style or "Single")
end

local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

local function xml_text(s)
  return pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. s .. "</w:t></w:r>")
end

-- a metadata value (YAML string, MetaInlines or MetaBlocks) as a list of inlines
local function inlines_of(v)
  local out = pandoc.List({})
  if v == nil then return out end
  if type(v) == "string" then
    out:insert(pandoc.Str(v))
    return out
  end
  if v.t == "MetaBlocks" then
    for _, b in ipairs(v) do
      if b.content then for _, x in ipairs(b.content) do out:insert(x) end end
    end
  end
  -- MetaInlines (its Lua value has no tag) or a plain list of inlines
  for _, x in ipairs(pandoc.Plain(v).content) do out:insert(x) end
  return out
end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- a borderless table; rows is a list of rows, each a list of cells, each cell a list of blocks
local function grid(rows, widths)
  local colspecs = {}
  for i, w in ipairs(widths) do colspecs[i] = { pandoc.AlignDefault, w } end
  local body = {}
  for _, r in ipairs(rows) do
    local cells = {}
    for _, c in ipairs(r) do cells[#cells + 1] = pandoc.Cell(c) end
    body[#body + 1] = pandoc.Row(cells)
  end
  return pandoc.Table(pandoc.Caption(), colspecs, pandoc.TableHead({}), { { attr = pandoc.Attr(), row_head_columns = 0, head = {}, body = body } }, pandoc.TableFoot({}))
end

-- the attorney information block (LR 10.1(b)): one column per firm group, each line single spaced
local function attorney_block(meta)
  local groups = meta.attorney or {}
  if #groups == 0 then return nil end
  local cells, widths = {}, {}
  for g, group in ipairs(groups) do
    local blocks = {}
    for _, line in ipairs(group) do
      blocks[#blocks + 1] = custom({ pandoc.Para(inlines_of(line)) }, "Single")
    end
    cells[g] = blocks
    widths[g] = 1 / #groups
  end
  return grid({ cells }, widths)
end

-- the caption (Fed. R. Civ. P. 10(a)): party names and designations, a ")" column, and the case number
-- and jury legend on the right, as in the typst caption() grid
local function caption(meta)
  local rows = {}   -- { inlines, indent }
  local sep_row = nil
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      sep_row = #rows + 2
      rows[#rows + 1] = { pandoc.List({}), false }
      rows[#rows + 1] = { pandoc.List({ pandoc.Str(CFG.separator) }), false }
      rows[#rows + 1] = { pandoc.List({}), false }
    end
    for _, n in ipairs(p.names) do rows[#rows + 1] = { inlines_of(n), false } end
    rows[#rows + 1] = { inlines_of(p.designation), true }
  end
  local right = {}
  local case_no = plain(meta.case_number)
  if case_no == "" then case_no = "____________" end
  right[(CFG.case_on_sep and sep_row) or 1] = { pandoc.Str("Case No. " .. case_no) }
  if CFG.jury_legend and meta.jury_demand then
    right[3] = { pandoc.Strong({ pandoc.Str("JURY TRIAL DEMANDED") }) }
  end
  local body = {}
  for i, r in ipairs(rows) do
    local name_style = (r[2] and CFG.designation_indent) and "SingleIndent" or "Single"
    body[i] = {
      { custom({ pandoc.Para(r[1]) }, name_style) },
      { custom({ pandoc.Para({ pandoc.Str(")") }) }, "Single") },
      { custom({ pandoc.Para(right[i] or pandoc.List({})) }, "Single") },
    }
  end
  return grid(body, { 3.1 / 6.5, 0.35 / 6.5, 3.05 / 6.5 })
end

-- heading: complaint headings are centered (level 1 in capitals); motion-brief "I." and "A." headings hang
local function heading(h)
  local title = pandoc.utils.stringify(h.content)
  if CFG.roman_headings then
    local first = h.content[1]
    local second = h.content[2]
    local numbered = first and first.t == "Str" and (first.text:match("^[IVXL]+%.$") or first.text:match("^[A-Z]%.$"))
    if numbered then
      if second and second.t == "Space" then
        local rest = pandoc.List({ first, tab() })
        for i = 3, #h.content do rest:insert(h.content[i]) end
        local style = h.level == 1 and "HeadingFlush1" or "HeadingFlush2"
        return custom({ pandoc.Para(rest) }, style)
      end
    end
  end
  local inl = pandoc.List({})
  if h.level == 1 then
    inl:insert(pandoc.Strong({ pandoc.Str(title:upper()) }))
  else
    inl:insert(pandoc.Strong(h.content))
  end
  return custom({ pandoc.Para(inl) }, "CenteredHeading")
end

-- a numbered or lettered item of a list, with its label as text and a hanging indent
local function list_items(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local inl = pandoc.List({})
    for _, b in ipairs(item) do
      if b.content then
        if #inl > 0 then inl:insert(pandoc.Space()) end
        for _, x in ipairs(b.content) do inl:insert(x) end
      end
    end
    local label
    if CFG.letter_items then
      label = "(" .. string.char(string.byte("a") + i - 1) .. ")"
    else
      label = tostring(i) .. "."
    end
    local lead = pandoc.List({ xml_text(label), tab() })
    for _, x in ipairs(inl) do lead:insert(x) end
    out[#out + 1] = custom({ pandoc.Para(lead) }, CFG.letter_items and "Lettered" or "NumberedItem")
  end
  return out
end

-- the body: numbered paragraphs in the complaint (not before the first heading, not WHEREFORE, not in the prayer)
local function body(blocks)
  local out = {}
  local seen_heading, para_no, in_prayer = false, 0, false
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      seen_heading = true
      in_prayer = pandoc.utils.stringify(b.content):lower():find("prayer", 1, true) ~= nil
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" then
      for _, blk in ipairs(list_items(b)) do out[#out + 1] = blk end
    elseif b.t == "Para" then
      local text = pandoc.utils.stringify(b)
      local numbered = CFG.numbered and seen_heading and not in_prayer and not text:match("^WHEREFORE")
      if numbered then
        para_no = para_no + 1
        local inl = pandoc.List({ xml_text(tostring(para_no) .. "."), tab() })
        for _, x in ipairs(b.content) do inl:insert(x) end
        out[#out + 1] = pandoc.Para(inl)
      else
        out[#out + 1] = b
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

local function signature(meta, out)
  local sig = meta.signature or {}
  local dated = meta[CFG.date_key]
  local dated_text
  if CFG.date_key == "date" then dated_text = "Dated: " .. plain(dated) else dated_text = plain(dated) end
  out:insert(blank("KeepFlush"))
  out:insert(custom({ pandoc.Para({ pandoc.Str(dated_text) }) }, "KeepFlush"))
  out:insert(blank("KeepFlush"))
  out:insert(custom({ pandoc.Para({ pandoc.Str("Respectfully submitted,") }) }, "SigIndent"))
  out:insert(blank("Keep"))
  out:insert(blank("Keep"))
  local first = pandoc.List({ pandoc.Str("/s/ " .. plain(sig.signer)) })
  out:insert(custom({ pandoc.Para(first) }, "SigIndent"))
  for _, l in ipairs(sig.lines or {}) do out:insert(custom({ pandoc.Para(inlines_of(l)) }, "SigIndent")) end
  out:insert(blank("Keep"))
  out:insert(blank("Keep"))
  for _, l in ipairs(sig.role or {}) do out:insert(custom({ pandoc.Para(inlines_of(l)) }, "SigIndent")) end
end

local function certificate(meta, out)
  local c = meta.certificate
  if not c then return end
  out:insert(blank("KeepFlush"))
  out:insert(custom({ pandoc.Para({ pandoc.Strong({ pandoc.Str("CERTIFICATE OF SERVICE") }) }) }, "CenteredHeading"))
  out:insert(blank("Keep"))
  out:insert(custom({ pandoc.Para(inlines_of(c.text)) }, "KeepBody"))
  out:insert(blank("Keep"))
  for _, l in ipairs(c.served or {}) do out:insert(custom({ pandoc.Para(inlines_of(l)) }, "Served")) end
  out:insert(blank("KeepFlush"))
  out:insert(custom({ pandoc.Para({ pandoc.Str("/s/ " .. plain(c.signer)) }) }, "SigIndent"))
end

function Pandoc(doc)
  local meta = doc.meta
  local out = pandoc.List({})

  -- first page: attorney block, court name, caption, title (typst first-page())
  local att = attorney_block(meta)
  if att then out:insert(att) end
  out:insert(blank("Single"))
  out:insert(custom({ pandoc.Para({ pandoc.Strong({ pandoc.Str(CFG.court_name[1]) }) }) }, "Centered"))
  out:insert(custom({ pandoc.Para({ pandoc.Strong({ pandoc.Str(CFG.court_name[2]) }) }) }, "Centered"))
  out:insert(blank("Single"))
  out:insert(caption(meta))
  out:insert(blank("Single"))
  out:insert(custom({ pandoc.Para({ pandoc.Strong({ pandoc.Str(plain(meta.title):upper()) }) }) }, "CenteredHeading"))
  out:insert(blank("Flush"))

  for _, b in ipairs(body(doc.blocks)) do out:insert(b) end

  signature(meta, out)
  if CFG.certificate then certificate(meta, out) end

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end

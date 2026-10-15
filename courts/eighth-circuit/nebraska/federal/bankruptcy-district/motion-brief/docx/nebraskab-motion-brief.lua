-- Motion or brief for the United States Bankruptcy Court, District of Nebraska (nebraskab), DOCX engine
-- (docs/DOCX.md): the markdown contract (YAML frontmatter + body) -> a Word document on reference.docx.
-- Mirrors typst/nebraskab-motion-brief.typ: court name, the caption in a borderless table (the "In re" block
-- with a rule under it, the parties with "v.", intervenors after them; the case lines, then the title in bold
-- capitals on the right), sections numbered I., II. (## headings) and subsections A., B. (### headings) restarting
-- under each section, the signature block kept together, and the CM/ECF certificate of service on its own page.
-- Every case-specific word comes from the sample's frontmatter, never from here.
-- Known limits (see README.md, "Engines"): section and subsection letters are typed by this filter (as in the
-- typst template), not Word list numbering; the caption rule is a paragraph border, not a drawn line.

local NBSP = "\u{a0}"
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local COURT_NAME = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEBRASKA" }
local CERTIFICATE_TEXT = "I hereby certify that on "
local CERTIFICATE_END = ", I electronically filed the foregoing document with the Clerk of the Court using the CM/ECF system which sent notification of said filing to all CM/ECF participants."

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

-- Roman numerals for section numbers (I., II., ...), as typst's numbering("I.", n)
local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
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
  for _, p in ipairs(items(meta.intervenors)) do
    left[#left + 1] = gap("DoubleGap")
    for _, n in ipairs(items(p.names)) do left[#left + 1] = line("Single", inlines(n)) end
    left[#left + 1] = gap("CaptionGap")
    left[#left + 1] = line("CaptionDesignation", inlines(p.designation))
  end

  right[#right + 1] = gap("CaptionGap")
  for _, v in ipairs(items(meta.case_lines)) do right[#right + 1] = line("Single", inlines(v)) end
  right[#right + 1] = gap("DoubleGap")
  right[#right + 1] = line("Single", inlines(meta.adversary_line))
  right[#right + 1] = gap("DoubleGap")
  right[#right + 1] = gap("DoubleGap")
  right[#right + 1] = line("CaptionTitle", upper_inlines(inlines(meta.title)))
  return grid(left, right)
end

local function signature(meta)
  local sig = meta.signature
  local right = {}
  right[#right + 1] = line("SingleKeep", inlines(sig.party))
  right[#right + 1] = gap("CaptionGap")
  local lines = items(sig.lines)
  for j, l in ipairs(lines) do
    right[#right + 1] = line(j == #lines and "Single" or "SingleKeep", nbsp_sections(inlines(l)))
  end
  return grid({}, right)
end

local function certificate(meta)
  local cert = meta.certificate
  if not cert then
    error("nebraskab-motion-brief: the frontmatter must give the certificate of service (certificate.date, certificate.signer)", 0)
  end
  local text = pandoc.Inlines({ pandoc.Str(CERTIFICATE_TEXT) })
  text:extend(inlines(cert.date))
  text:insert(pandoc.Str(CERTIFICATE_END))
  local signed = pandoc.Inlines({ pandoc.Str("/s/ ") })
  signed:extend(inlines(cert.signer))
  local right = {
    line("SingleKeep", signed),
    gap("CaptionGap"),
    line("Single", inlines(cert.signer)),
  }
  return {
    styled("CertificateTitle", { pandoc.Para({ pandoc.Str("CERTIFICATE OF SERVICE") }) }),
    pandoc.Para(text),
    gap("DoubleGap"),
    gap("DoubleGap"),
    grid({}, right),
  }
end

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ Inlines = nbsp_sections })

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court name, caption, title (FRBP 9004(b))
  for _, l in ipairs(COURT_NAME) do add(line("Centered", { pandoc.Strong({ pandoc.Str(l) }) })) end
  add(gap("DoubleGap"))
  add(caption(meta))
  add(gap("DoubleGap"))

  -- body: level 2 headings are sections (I., II.), level 3 are subsections (A., B., restarting per section);
  -- paragraphs are not numbered (a brief's numbering is typed by the author)
  local sec, sub = 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 2 then
      sec, sub = sec + 1, 0
      local ins = pandoc.Inlines({ pandoc.Str(roman(sec) .. "."), pandoc.Space() })
      ins:extend(upper_inlines(b.content))
      b.content = ins
      add(b)
    elseif b.t == "Header" and b.level == 3 then
      sub = sub + 1
      local ins = pandoc.Inlines({ pandoc.Str(string.char(64 + sub) .. "."), TAB })
      ins:extend(b.content)
      b.content = ins
      add(b)
    elseif b.t == "Header" and b.level == 1 then
      b.content = upper_inlines(b.content)
      add(b)
    else
      add(b)
    end
  end

  add(gap("DoubleGap"))
  add(signature(meta))
  for _, b in ipairs(certificate(meta)) do add(b) end

  -- pandoc would put the title and date above the court name (its docx title block); the caption has them
  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end

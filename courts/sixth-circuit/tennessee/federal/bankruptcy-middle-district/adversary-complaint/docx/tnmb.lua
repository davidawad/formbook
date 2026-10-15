-- Part of the tnmb DOCX filter; CFG is set per doc type.
local CFG = { numbered = true, sig_gap = true, caption_w = { 3.7 / 6.5, 0.3 / 6.5, 2.5 / 6.5 } }
-- tnmb (Middle District of Tennessee, bankruptcy), DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on reference.docx. The cover (court title, caption table, title), the signature block and the
-- certificate of service are built here as paragraphs in the reference's styles; the body keeps its markdown
-- structure. Page numbers come from the reference's footer (LBR 5005-3(b)).
-- Only frontmatter-driven content: no case words live in this file.

local function text(s) return pandoc.Str(s) end
local NBSP = pandoc.Str("\u{00A0}")

local function style(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

local function para(name, inl)
  return style(name, { pandoc.Para(inl) })
end

local function gap()
  return style("Gap", { pandoc.Para({ NBSP }) })
end

-- a frontmatter value (markdown inlines, a string, or blocks) as a list of inlines
local function inlines(v)
  if v == nil then return pandoc.List({}) end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" then return pandoc.List(v) end
  if ty == "Blocks" then return pandoc.utils.blocks_to_inlines(v) end
  return pandoc.List({ text(tostring(v)) })
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- caption (LBR 9004-2): the debtor and the parties on the left, a ")" column, the case number, chapter,
-- judge and adversary number on the right; one table row per line, as in the typst grid.
local function caption_table(meta)
  local c = meta.caption
  local left = { { text("IN RE:") }, { NBSP } }
  for _, d in ipairs(c.debtor or {}) do left[#left + 1] = inlines(d) end
  left[#left + 1] = { text("Debtor.") }
  left[#left + 1] = { NBSP }
  for k, p in ipairs(c.parties or {}) do
    if k > 1 then
      left[#left + 1] = { text("v.") }
      left[#left + 1] = { NBSP }
    end
    for _, n in ipairs(p.names or {}) do left[#left + 1] = inlines(n) end
    left[#left + 1] = inlines(p.designation)
    left[#left + 1] = { NBSP }
  end
  local adv = plain(meta.adv_proc_no)
  if adv == "" then adv = "________" end
  local right = {
    { text("Case No. " .. plain(meta.case_number)) },
    { text("Chapter " .. plain(meta.chapter)) },
    { text("Judge " .. plain(meta.judge)) },
    { NBSP },
    { text("Adv. Proc. No. " .. adv) },
  }
  local n = math.max(#left, #right)
  local function cell(inl) return pandoc.Cell({ para("Single", inl) }) end
  local rows = {}
  for i = 1, n do
    rows[#rows + 1] = pandoc.Row({
      cell(left[i] or { NBSP }),
      cell({ text(")") }),
      cell(right[i] or { NBSP }),
    })
  end
  local specs = {
    { pandoc.AlignDefault, CFG.caption_w[1] },
    { pandoc.AlignDefault, CFG.caption_w[2] },
    { pandoc.AlignDefault, CFG.caption_w[3] },
  }
  return pandoc.Table(pandoc.Caption({}), specs, pandoc.TableHead({}), { pandoc.TableBody(rows) }, pandoc.TableFoot({}))
end

local function cover(meta)
  local out = {}
  local function add(b) out[#out + 1] = b end
  add(para("Centered", { pandoc.Strong({ text("IN THE UNITED STATES BANKRUPTCY COURT") }) }))
  add(para("Centered", { pandoc.Strong({ text("FOR THE MIDDLE DISTRICT OF TENNESSEE") }) }))
  if meta.division then
    add(para("Centered", { pandoc.Strong({ text(plain(meta.division):upper()) }) }))
  end
  add(gap())
  add(caption_table(meta))
  add(gap())
  for _, line in ipairs(meta.title or {}) do
    add(para("Centered", { pandoc.Strong({ text(plain(line):upper()) }) }))
  end
  add(style("GapTight", { pandoc.Para({ NBSP }) }))
  return out
end

local function signature(meta)
  local out = {}
  if meta.signature then
    if CFG.sig_gap then out[#out + 1] = style("GapSig", { pandoc.Para({ NBSP }) }) end
    out[#out + 1] = para("Signature", { text("Respectfully submitted,") })
    out[#out + 1] = gap()
    for _, line in ipairs(meta.signature) do
      out[#out + 1] = para("Signature", inlines(line))
    end
  end
  return out
end

local function starts_unnumbered(b)
  return b.t == "Para" and b.content[1] ~= nil and b.content[1].t == "Str" and b.content[1].text == "§"
end

local function letter(i) return string.char(64 + i) end

local function number_run(label)
  return pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. label .. '</w:t></w:r><w:r><w:tab/></w:r>')
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  addall(cover(meta))

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and starts_unnumbered(b) then
      -- "§ " marks an unnumbered paragraph (the marker is dropped)
      local inl = pandoc.List({})
      for i = 3, #b.content do inl:insert(b.content[i]) end
      add(pandoc.Para(inl))
    elseif b.t == "Para" and CFG.numbered then
      n = n + 1
      local inl = pandoc.List({ number_run(n .. ".") })
      inl:extend(b.content)
      add(style("Allegation", { pandoc.Para(inl) }))
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local inl = pandoc.List({ number_run(letter(i) .. ".") })
          inl:extend(first.content)
          local rest = pandoc.List({ style("ListItem", { pandoc.Para(inl) }) })
          for j = 2, #item do rest:insert(item[j]) end
          addall(rest)
        else
          addall(item)
        end
      end
    else
      add(b)
    end
  end

  addall(signature(meta))

  if meta.certificate then
    add(pandoc.Header(1, { text("Certificate of Service") }))
    add(pandoc.Para(inlines(meta.certificate.text)))
    for _, addressee in ipairs(meta.certificate.recipients or {}) do
      for _, line in ipairs(addressee) do
        add(para("Recipient", inlines(line)))
      end
      add(gap())
    end
  end

  doc.meta = {}
  doc.blocks = out
  return doc
end

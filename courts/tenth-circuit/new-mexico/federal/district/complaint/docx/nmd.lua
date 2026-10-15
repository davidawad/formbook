-- D.N.M. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors ../typst/nmd-complaint.typ: court title, caption table, case number, title, lead-in, numbered allegations,
-- lettered list items, signature block. The styles are the NMD ... styles defined in reference.docx (build-reference.sh).
-- Allegation numbers are typed text followed by a tab (the typst template types them too), so they do not renumber
-- by themselves in Word if a paragraph is added; see README.md, Engines.

local function upper(s) return string.upper(s) end
local function str(v) return pandoc.utils.stringify(v) end
local function need(meta, key)
  assert(meta[key] ~= nil, "nmd.lua: the sample's frontmatter must give '" .. key .. "'")
  return meta[key]
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function para(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- borderless table; colfracs are column widths as fractions of the text width (the "Table" style has no borders)
local function grid(colfracs, rows)
  local specs = {}
  for i, f in ipairs(colfracs) do specs[i] = { pandoc.AlignDefault, f } end
  return pandoc.Table(pandoc.Caption({}), specs, pandoc.TableHead({}), { pandoc.TableBody(rows) }, pandoc.TableFoot({}))
end

local function court_block(meta)
  local inl = pandoc.Inlines({})
  for i, l in ipairs(need(meta, "court")) do
    if i > 1 then inl:insert(pandoc.LineBreak()) end
    inl:insert(pandoc.Str(upper(str(l))))
  end
  return para("NMDCourt", inl)
end

-- caption: each party name and designation is a row with a ")" mark in the second column; the "v." lines are rows
-- too; the case number sits beside the first row, as in the typst grid
local function caption_table(meta)
  local rows = {}
  local function row(style, inl, third)
    rows[#rows + 1] = pandoc.Row({
      pandoc.Cell({ para(style, inl) }),
      pandoc.Cell({ para("NMDSingle", { pandoc.Str(")") }) }),
      third or pandoc.Cell({ para("NMDSingle", {}) }),
    })
  end
  local case = pandoc.Inlines({ pandoc.Str("Case No. ") })
  case:extend(need(meta, "case_number"))
  local first = true
  local function add(style, inl)
    row(style, inl, first and pandoc.Cell({ para("NMDCaseNo", case) }) or nil)
    first = false
  end
  for k, p in ipairs(need(meta, "caption").parties) do
    if k > 1 then add("NMDCaptionIndent", { pandoc.Str("v.") }) end
    for _, n in ipairs(p.names) do add("NMDSingle", n) end
    add("NMDCaptionIndent", p.designation)
  end
  return grid({ 3.3 / 6.5, 0.3 / 6.5, 2.9 / 6.5 }, rows)
end

-- signature block: the firm, then each attorney block (complaint: separated by "and"), then the attorneys' line
local function sig_cell(sig, lead, and_sep)
  local ps = {}
  local function p(style, inl) ps[#ps + 1] = para(style, inl) end
  if lead then p("NMDSigStart", { pandoc.Str(lead) }) end
  for i, l in ipairs(sig.firm) do
    local style = "NMDSig"
    if i == 1 then style = lead and "NMDSigGap" or "NMDSigStart" end
    p(style, l)
  end
  for k, b in ipairs(sig.blocks) do
    if k > 1 and and_sep then p("NMDSigGap", { pandoc.Str("and") }) end
    for i, l in ipairs(b) do p(i == 1 and "NMDSigGap" or "NMDSig", l) end
  end
  p("NMDSigGap", sig.attorneys_for)
  return pandoc.Cell(ps)
end

local function signature_table(meta, and_sep)
  local sig = need(meta, "signature")
  local left = { para("NMDSigStart", {}) }
  if meta.date then
    local dated = pandoc.Inlines({ pandoc.Str("Dated: ") })
    dated:extend(meta.date)
    left = { para("NMDSigStart", dated) }
  end
  return grid({ 3.3 / 6.5, 3.2 / 6.5 }, { pandoc.Row({ pandoc.Cell(left), sig_cell(sig, nil, and_sep) }) })
end

-- body: "^ " marks an unnumbered paragraph (the request for relief, the jury demand); a list is lettered;
-- every other paragraph is a numbered allegation (Fed. R. Civ. P. 10(b)); headings pass through (their styles)
local function body(blocks)
  local out, n = {}, 0
  for _, b in ipairs(blocks) do
    local c = b.content
    if b.t == "Para" and c[1] and c[1].t == "Str" and c[1].text == "^" and c[2] and c[2].t == "Space" then
      local rest = {}
      for i = 3, #c do rest[#rest + 1] = c[i] end
      out[#out + 1] = pandoc.Para(rest)
    elseif b.t == "Para" then
      n = n + 1
      local inl = { pandoc.Str(n .. "."), TAB }
      for _, x in ipairs(c) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "NMDNumbered" }))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local start = (b.t == "OrderedList" and b.listAttributes.start) or 1
      for i, item in ipairs(b.content) do
        local marker = (b.t == "BulletList") and "\u{2022}" or string.char(96 + start + i - 1) .. "."
        local first = item[1]
        local inl = { pandoc.Str(marker), TAB }
        if first and (first.t == "Para" or first.t == "Plain") then
          for _, x in ipairs(first.content) do inl[#inl + 1] = x end
        end
        local style = (i == #b.content) and "NMDListLast" or "NMDList"
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
        for j = 2, #item do out[#out + 1] = item[j] end
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = { court_block(meta), caption_table(meta), para("NMDTitle", need(meta, "brief_title")) }
  if meta.lead_in then out[#out + 1] = pandoc.Para(meta.lead_in) end
  for _, b in ipairs(body(doc.blocks)) do out[#out + 1] = b end
  out[#out + 1] = signature_table(meta, true)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

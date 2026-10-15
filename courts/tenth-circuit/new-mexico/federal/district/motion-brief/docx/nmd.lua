-- D.N.M. motion with its supporting brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx. Mirrors ../typst/nmd-motion-brief.typ: court title, caption table, case number, title, body (not
-- numbered), signature block, certificate of service. The styles are the NMD ... styles defined in reference.docx.

local function upper(s) return string.upper(s) end
local function str(v) return pandoc.utils.stringify(v) end
local function need(meta, key)
  assert(meta[key] ~= nil, "nmd.lua: the sample's frontmatter must give '" .. key .. "'")
  return meta[key]
end

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

-- signature block: "Respectfully submitted," then the firm, then each attorney block, then the attorneys' line
local function signature_table(meta)
  local sig = need(meta, "signature")
  local ps = {}
  local function p(style, inl) ps[#ps + 1] = para(style, inl) end
  p("NMDSigStart", { pandoc.Str("Respectfully submitted,") })
  for _, l in ipairs(sig.firm) do p("NMDSigGap", l) end
  for _, b in ipairs(sig.blocks) do
    for i, l in ipairs(b) do p(i == 1 and "NMDSigGap" or "NMDSig", l) end
  end
  p("NMDSigGap", sig.attorneys_for)
  return grid({ 3.3 / 6.5, 3.2 / 6.5 }, { pandoc.Row({
    pandoc.Cell({ para("NMDSigStart", {}) }),
    pandoc.Cell(ps),
  }) })
end

-- certificate of service: the statement, the served lists (each list one block of single lines), the signature
local function certificate(meta)
  local cert = need(meta, "certificate")
  local out = { para("NMDTitle", { pandoc.Str("CERTIFICATE OF SERVICE") }), pandoc.Para(cert.text) }
  for _, b in ipairs(cert.served) do
    for i, l in ipairs(b) do out[#out + 1] = para(i == 1 and "NMDSingleGap" or "NMDSingle", l) end
  end
  for i, l in ipairs(cert.signed) do
    out[#out + 1] = para(i == 1 and "NMDCertSigned" or "NMDCertSignedNext", l)
  end
  return out
end

-- body: each paragraph is kept as it is (the motion's paragraphs are not numbered); bullets are "•" items
local function body(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local inl = { pandoc.Str("\u{2022}"), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          for _, x in ipairs(first.content) do inl[#inl + 1] = x end
        end
        local style = (i == #b.content) and "NMDListLast" or "NMDList"
        out[#out + 1] = para(style, inl)
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
  for _, b in ipairs(body(doc.blocks)) do out[#out + 1] = b end
  out[#out + 1] = signature_table(meta)
  for _, b in ipairs(certificate(meta)) do out[#out + 1] = b end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

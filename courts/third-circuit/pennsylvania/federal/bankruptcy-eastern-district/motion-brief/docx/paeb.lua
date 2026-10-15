-- PAEB motion with memorandum of law, DOCX engine (docs/DOCX.md). Builds from the sample's frontmatter what the
-- typst template (typst/paeb-motion-brief.typ) builds: the court lines, the caption (a borderless three-column
-- table: party names, colons, chapter / case no. / adversary no.), the title, the lead-in, the optional consent
-- statement (L.B.R. 9014-3(b)(2)), the memorandum paragraphs (not numbered), the headings and lists as they are,
-- the flush lead-in quotes, the signature block and the optional certificate of service. Page setup, fonts and
-- paragraph styles come from reference.docx (build-reference.sh). Limits: see ../README.md, "Engines".

local TEXT_W = 9360          -- 6.5 in, twips
local CAP_W = { 4896, 504, 3960 }  -- caption: party 3.4 in, colon 0.35 in, case 2.75 in (typst caption-cols)
local DESIG_IND = 1728       -- 1.2 in: "Plaintiff," and "Defendant." under the names (typst designation-indent)
local SIG_LEFT = 4320        -- 3 in: "Dated" column (typst signature-block grid)
local ROW_GAP = 120          -- 6 pt between caption rows (typst row-gutter 0.5em)

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value as inline content (keeps italics and bold written in the frontmatter)
local function inl(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  return { pandoc.Str(str(v)) }
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function rpr(f)
  local x = ""
  if f.b then x = x .. "<w:b/><w:bCs/>" end
  if f.i then x = x .. "<w:i/><w:iCs/>" end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function with(f, k)
  local g = {}
  for key, v in pairs(f) do g[key] = v end
  g[k] = true
  return g
end

local function run(text, f)
  return "<w:r>" .. rpr(f or {}) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- inline elements (already parsed by pandoc) as Word runs, keeping italics and bold
local function runs(inls, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(inls or {}) do
    if el.t == "Str" then out[#out + 1] = run(el.text, f)
    elseif el.t == "Space" or el.t == "SoftBreak" then out[#out + 1] = run(" ", f)
    elseif el.t == "Emph" then out[#out + 1] = runs(el.content, with(f, "i"))
    elseif el.t == "Strong" then out[#out + 1] = runs(el.content, with(f, "b"))
    elseif el.t == "Span" then out[#out + 1] = runs(el.content, f)
    elseif el.t == "Quoted" then
      local q1, q2 = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then q1, q2 = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(q1, f) .. runs(el.content, f) .. run(q2, f)
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
  return table.concat(out)
end

-- a paragraph with a paragraph style, direct paragraph properties (in schema order after the style)
local function p(style, inner, ppr)
  return "<w:p><w:pPr>" .. (style and ('<w:pStyle w:val="' .. style .. '"/>') or "") .. (ppr or "")
    .. "</w:pPr>" .. inner .. "</w:p>"
end

local function sp(after)
  return '<w:spacing w:before="0" w:after="' .. after .. '" w:line="240" w:lineRule="auto"/>'
end

local function spacer(ppr)
  return p("BodyText", "", ppr)
end

local function cell(w, xml, tcpr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (tcpr or "") .. "</w:tcPr>" .. xml .. "</w:tc>"
end

local function row(cells)
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
end

-- a borderless table with fixed column widths and the given rows
local function table_xml(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local none = ""
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    none = none .. '<w:' .. side .. ' w:val="nil"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblBorders>' .. none
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid)
    .. "</w:tblGrid>" .. table.concat(rows) .. "</w:tbl>"
end

-- caption rows as in caption-rows() of the typst template: (party cell, case cell, party cell indented?)
local function caption_rows(m)
  local rows = {}
  local function add(l, r, indent) rows[#rows + 1] = { l = l, r = r, indent = indent } end
  add("IN RE:", "Chapter " .. str(m.chapter))
  add(str(m.debtor.name), "Case No. " .. str(m.case_number))
  if str(m.debtor.designation) ~= "" then add(str(m.debtor.designation), "", true) end
  add("", "")
  for k, party in ipairs(m.parties) do
    if k > 1 then
      add("", "")
      add("v.", "")
      add("", "")
    end
    for j, name in ipairs(party.names) do
      local case = (k == 1 and j == 1) and ("Adv. Proc. No. " .. str(m.adversary_number)) or ""
      add(str(name), case)
    end
    if str(party.designation) ~= "" then add(str(party.designation), "", true) end
  end
  return rows
end

local function caption_table(m)
  local trs = {}
  for _, r in ipairs(caption_rows(m)) do
    local left_ppr = sp(ROW_GAP) .. (r.indent and ('<w:ind w:left="' .. DESIG_IND .. '" w:firstLine="0"/>') or '<w:ind w:firstLine="0"/>')
    local ppr = sp(ROW_GAP) .. '<w:ind w:firstLine="0"/>'
    trs[#trs + 1] = row({
      cell(CAP_W[1], p("Single", run(r.l, {}), left_ppr)),
      cell(CAP_W[2], p("Single", run(":", {}), ppr)),
      cell(CAP_W[3], p("Single", run(r.r, {}), ppr)),
    })
  end
  return table_xml(CAP_W, trs)
end

local function roman(n)
  local vals = { 10, "x", 9, "ix", 5, "v", 4, "iv", 1, "i" }
  local out = ""
  for i = 1, #vals, 2 do
    while n >= vals[i] do
      out = out .. vals[i + 1]
      n = n - vals[i]
    end
  end
  return out
end

-- lettered or roman items, as the typst enum with the sample's list_numbering: "(a)" or "(i)"
local function list_items(list, use_roman, out)
  for i, item in ipairs(list.content) do
    local marker = "(" .. (use_roman and roman(i) or string.char(96 + i)) .. ")"
    local inls = pandoc.List({ pandoc.Str(marker), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      for _, e in ipairs(first.content) do inls:insert(e) end
    end
    out[#out + 1] = pandoc.Div({ pandoc.Para(inls) }, pandoc.Attr("", {}, { ["custom-style"] = "ListItem" }))
    for k = 2, #item do out[#out + 1] = item[k] end
  end
end

-- the memorandum: paragraphs as they are (not numbered), block quotes flush (the typst lead-in quotes),
-- headings and lists as they are
local function body_blocks(blocks, use_roman)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "BlockQuote" then
      for _, c in ipairs(b.content) do
        if c.t == "Para" or c.t == "Plain" then
          out[#out + 1] = pandoc.Div({ pandoc.Para(c.content) }, pandoc.Attr("", {}, { ["custom-style"] = "BodyFlush" }))
        end
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      list_items(b, use_roman, out)
    else
      out[#out + 1] = b
    end
  end
  -- the last piece stays on the page with the signature block (typst: one unbreakable block)
  local last = out[#out]
  if last then
    if last.t == "Para" then
      out[#out] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" }))
    elseif last.t == "Div" and last.attr.attributes["custom-style"] == "ListItem" then
      last.attr.attributes["custom-style"] = "ListItemKeep"
    end
  end
  return out
end

-- signature block (typst: signature-block): "Dated" at left, the firm, "By: /s/" and the lines at right
local function signature(m)
  local s = m.signature
  local left = p("Single", run("Dated: " .. str(s.date), {}), sp(0))
  local right = {}
  right[#right + 1] = p("Single", run(str(s.firm), {}), sp(ROW_GAP))
  right[#right + 1] = p("Single", run("By: /s/ " .. str(s.signer), {}), sp(0))
  for _, line in ipairs(s.lines or {}) do
    right[#right + 1] = p("Single", run(str(line), {}), sp(0))
  end
  return table_xml({ SIG_LEFT, TEXT_W - SIG_LEFT }, {
    row({
      cell(SIG_LEFT, left),
      cell(TEXT_W - SIG_LEFT, table.concat(right)),
    }),
  })
end

-- certificate of service (typst: certificate): kept together, one unbreakable block
local function certificate(m)
  local c = m.certificate
  local KN = "<w:keepNext/>"
  local x = {}
  x[#x + 1] = spacer(KN)
  x[#x + 1] = p("CenteredBody", run("CERTIFICATE OF SERVICE", { b = true }), KN)
  x[#x + 1] = spacer(KN)
  x[#x + 1] = p("BodyText", run("I, " .. str(c.signer) .. ", hereby certify that I served a true and correct copy of the foregoing document upon the following parties in the manner indicated:", {}), KN)
  x[#x + 1] = spacer(KN)
  x[#x + 1] = p("Single", run(str(c.method) .. ":", {}), KN .. sp(ROW_GAP))
  for k, block in ipairs(c.served or {}) do
    if k > 1 then x[#x + 1] = spacer(KN) end
    for _, line in ipairs(block) do
      x[#x + 1] = p("Single", run(str(line), {}), KN .. sp(0))
    end
  end
  x[#x + 1] = spacer(KN)
  x[#x + 1] = table_xml({ SIG_LEFT, TEXT_W - SIG_LEFT }, {
    row({
      cell(SIG_LEFT, p("Single", run("Date: " .. str(c.date), {}), sp(0))),
      cell(TEXT_W - SIG_LEFT, p("Single", run("By: /s/ " .. str(c.signer), {}), sp(0))),
    }),
  })
  return table.concat(x)
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end

  -- cover: court (two lines, bold capitals), caption, title, lead-in, consent (typst: court-title, caption,
  -- title, lead-in, consent-block)
  raw(p("Centered", run(string.upper(str(m.court)), { b = true }), sp(0)))
  raw(p("Centered", run(string.upper(str(m.district)), { b = true }), sp(0)))
  raw(spacer())
  raw(caption_table(m))
  raw(spacer())
  raw(p("CenteredBody", runs(inl(m.title), { b = true })))
  raw(spacer())
  if m.lead_in then out[#out + 1] = pandoc.Para(inl(m.lead_in)) end
  if m.consent then out[#out + 1] = pandoc.Para(inl(m.consent)) end

  for _, b in ipairs(body_blocks(doc.blocks, str(m.list_numbering):find("i%)") ~= nil)) do
    out[#out + 1] = b
  end
  raw(spacer())
  raw(signature(m))
  if m.certificate then raw(certificate(m)) end
  raw(p("Single", "", sp(0)))  -- a paragraph after the last table, as Word writes it
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

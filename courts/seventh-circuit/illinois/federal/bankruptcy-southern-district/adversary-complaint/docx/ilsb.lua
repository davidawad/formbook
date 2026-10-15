-- S.D. Ill. adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx. Mirrors typst/ilsb-adversary-complaint.typ: court title, caption (a table with a right and a
-- bottom rule on the party column), title, lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b) via FRBP 7010),
-- prayer items A., B., ..., signature and attorney block (L.R. 9011(A)), and the Summary of Exhibits.
-- Every case word comes from the YAML frontmatter. No coordinates, no forced line breaks.
-- Known limits (see the README "Engines" section): the caption and signature blocks are Word tables whose
-- borders are not verified against the typst layout; page numbers are the footer fields of reference.docx.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- inlines from strings, single inline elements and inline lists (meta values), in order
local function cat(...)
  local out = pandoc.List({})
  for _, x in ipairs({ ... }) do
    if type(x) == "string" then
      out:insert(pandoc.Str(x))
    elseif x and x.t and not tostring(x.t):find("^Meta") then
      out:insert(x)
    elseif x then
      out:extend(x)
    end
  end
  return out
end

local function style(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- one paragraph in a named style (Centered, Single, Half, Gap, Prayer, Exhibit)
local function line(name, inl)
  return style(name, { pandoc.Para(inl) })
end

local function gap(name)
  return style(name or "Gap", { pandoc.Para({}) })
end

local function page_break()
  return style("PageBreak", { pandoc.Para({ pandoc.RawInline("openxml", '<w:r><w:br w:type="page"/></w:r>') }) })
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines as openxml runs: bold and italic are kept (case names), other markup is reduced to its text
local function runs(inls, bold, italic)
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" or t == "Space" or t == "SoftBreak" then
      local text = t == "Str" and el.text or " "
      local rpr = ""
      if bold or italic then
        rpr = "<w:rPr>" .. (bold and "<w:b/><w:bCs/>" or "") .. (italic and "<w:i/><w:iCs/>" or "") .. "</w:rPr>"
      end
      out[#out + 1] = '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, bold, true)
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, true, italic)
    elseif t == "Span" or t == "Link" then
      out[#out + 1] = runs(el.content, bold, italic)
    elseif t == "Note" then
      -- footnotes are not used in the caption or the signature block
    else
      out[#out + 1] = runs({ pandoc.Str(pandoc.utils.stringify(el)) }, bold, italic)
    end
  end
  return table.concat(out)
end

-- Div(custom-style) paragraphs as openxml paragraphs (for table cells)
local function ox(blocks)
  local out = {}
  for _, d in ipairs(blocks) do
    local sty = d.attributes["custom-style"]
    local para = d.t == "Div" and d.content[1] or d
    out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="' .. sty .. '"/></w:pPr>' .. runs(para.content, false, false) .. '</w:p>'
  end
  return table.concat(out)
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- widths in twips; rows = list of rows; a cell is { xml = <paragraphs>, tcpr = <tcPr children after tcW> }
local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local out = {
    '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
      .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>',
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>',
  }
  for _, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for i, c in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. c.tcpr .. '</w:tcPr>' .. c.xml .. '</w:tc>'
    end
    out[#out + 1] = '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return table.concat(out)
end

-- the caption (Form 416 as S.D. Ill. uses it): In re:, debtors, parties on the left, rule right and bottom;
-- case number, chapter and adversary number on the right
local function caption(meta)
  local left = pandoc.List({ line("Single", { pandoc.Str("In re:") }) })
  for _, n in ipairs(meta.debtors or {}) do left:insert(line("Single", n)) end
  left:insert(line("Single", meta.debtor_designation or {}))
  left:insert(line("Single", {}))
  for k, p in ipairs(meta.caption.parties or {}) do
    if k > 1 then left:insert(line("Single", { pandoc.Str("v.") })) end
    for _, n in ipairs(p.names or {}) do left:insert(line("Single", n)) end
    left:insert(line("Single", p.designation or {}))
  end

  local adv = plain(meta.adversary_no)
  local right = pandoc.List({
    line("Single", cat("Case No. ", meta.bankruptcy_case_no)),
    line("Single", cat("Chapter ", meta.chapter)),
    style("Half", { pandoc.Para({}) }),
    line("Single", cat("Adversary No. ", adv ~= "" and meta.adversary_no or string.rep("_", 10))),
  })

  local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return table_xml({ 5184, 4176 }, {
    {
      { xml = ox(left), tcpr = RULE .. '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/></w:tcMar>' },
      { xml = ox(right), tcpr = '<w:tcMar><w:left w:w="504" w:type="dxa"/></w:tcMar>' },
    },
  })
end

-- signature block: "Dated" at the left; "Respectfully submitted," and the signer at the right (L.R. 9011(A))
local function signature(meta)
  local sig = meta.signature
  if not sig then return pandoc.List({}) end
  local left = pandoc.List({ line("Single", cat("Dated: ", meta.date)) })

  local right = pandoc.List({ line("Single", { pandoc.Str("Respectfully submitted,") }), gap("Half") })
  for _, n in ipairs(sig.party or {}) do right:insert(line("Single", n)) end
  right:insert(gap("Half"))
  right:insert(line("Single", cat("/s/ ", sig.signer)))
  right:insert(line("Single", sig.signer or {}))
  right:insert(line("Single", sig.signer_title or {}))

  local out = pandoc.List({ gap("Gap") })
  out:insert(pandoc.RawBlock("openxml", table_xml({ 4032, 5328 }, {
    {
      { xml = ox(left), tcpr = '<w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar>' },
      { xml = ox(right), tcpr = '<w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>' },
    },
  })))
  return out
end

-- the attorney block sits under the signature block, at the margin (L.R. 9011(A))
local function attorney(meta)
  local out = pandoc.List({ gap("Gap") })
  for _, n in ipairs(meta.signature and meta.signature.attorney or {}) do
    out:insert(line("Single", n))
  end
  return out
end

local function numbered(k, inl)
  return pandoc.Para(cat(k .. ".", TAB, inl))
end

function Pandoc(doc)
  local meta = doc.meta
  local M = {
    title = meta.title, division = meta.division, debtors = meta.debtors,
    debtor_designation = meta.debtor_designation, bankruptcy_case_no = meta.bankruptcy_case_no,
    chapter = meta.chapter, adversary_no = meta.adversary_no, caption = meta.caption,
    lead_in = meta.lead_in, date = meta.date, signature = meta.signature,
    exhibits = meta.exhibits, exhibits_service = meta.exhibits_service,
  }
  -- the docx writer would print title and date from the metadata; the cover below prints them instead
  doc.meta = pandoc.Meta({})

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover: court title (Form 416), caption, title, lead-in
  add(line("Centered", { pandoc.Strong({ pandoc.Str("IN THE UNITED STATES BANKRUPTCY COURT") }) }))
  add(line("Centered", { pandoc.Strong({ pandoc.Str("FOR THE SOUTHERN DISTRICT OF ILLINOIS") }) }))
  if plain(M.division) ~= "" then
    add(line("Centered", { pandoc.Strong({ pandoc.Str(plain(M.division):upper()) }) }))
  end
  add(gap())
  add(pandoc.RawBlock("openxml", caption(M)))
  add(gap())
  add(line("Centered", { pandoc.Strong({ pandoc.Str(plain(M.title):upper()) }) }))
  add(gap())
  if M.lead_in then add(pandoc.Para(M.lead_in)) end

  -- body: headings as written; paragraphs numbered by the template; prayer items lettered
  local n, prayer = 0, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      prayer = false
      add(b)
    elseif b.t == "Para" then
      local letter_mark = prayer and b.content[1] and b.content[1].t == "Str" and b.content[1].text:match("^[A-Z]%.$")
      if pandoc.utils.stringify(b):match("^WHEREFORE") then
        prayer = true
        add(b)
      elseif letter_mark then
        -- "A. text" is a prayer item (pandoc reads a single capital and a period as a list only with two spaces)
        local rest = pandoc.List({})
        for i = 3, #b.content do rest:insert(b.content[i]) end
        add(line("Prayer", cat(b.content[1].text, TAB, rest)))
      else
        n = n + 1
        add(numbered(n, b.content))
      end
    elseif b.t == "OrderedList" and prayer and tostring(b.listAttributes.style) == "UpperAlpha" then
      local start = b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local first = item[1]
        local content = cat(string.char(64 + start + i - 1) .. ".", TAB)
        if first and (first.t == "Para" or first.t == "Plain") then content:extend(first.content) end
        add(line("Prayer", content))
        for j = 2, #item do add(item[j]) end
      end
    else
      add(b)
    end
  end

  addall(signature(M))
  addall(attorney(M))

  -- Summary of Exhibits: the last page of the filing (Admin. Guide, adversary complaint; Electronic Filing Rules, Rule 6)
  if M.exhibits and #M.exhibits > 0 then
    add(page_break())
    add(line("Centered", { pandoc.Strong({ pandoc.Str("SUMMARY OF EXHIBITS") }) }))
    add(gap())
    for _, ex in ipairs(M.exhibits) do
      add(line("Exhibit", cat({ pandoc.Strong({ pandoc.Str(plain(ex.label)) }) }, TAB, ex.description)))
    end
    if M.exhibits_service then
      add(gap())
      add(line("Centered", { pandoc.Strong({ pandoc.Str("CERTIFICATE OF SERVICE") }) }))
      add(gap("Half"))
      add(pandoc.Para(M.exhibits_service))
    end
  end

  doc.blocks = out
  return doc
end

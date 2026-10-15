-- Adversary complaint, U.S. Bankruptcy Court, E.D. California (caeb), DOCX engine (docs/DOCX.md).
-- The markdown contract -> a Word document on docx/reference.docx. The cover (counsel block, court title,
-- caption, title of the paper), the numbered allegations (FRCP 10(b), applied by FRBP 7010), the lettered relief
-- items, and the signature blocks are built here in the custom styles of the reference; the body keeps its
-- markdown structure. Mirrors typst/caeb-adversary-complaint.typ. Everything case-specific comes from the
-- sample's frontmatter, never from this file.
-- Known differences (see README "Engines"): single-spaced lines are exact 14 pt, not the typst leading; the
-- numbered lines are a header frame, so text after a single-spaced block can sit between two numbers.

local NBSP = "\u{00A0}"

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function sp(before, after, line, rule)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. line .. '" w:lineRule="' .. rule .. '"/>'
end

-- a single raw paragraph: style, direct pPr (after pStyle), text, bold
local function para(style, text, ppr, bold)
  local body = (text ~= nil and text ~= "") and run(text, bold) or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. body .. '</w:p>'
end

-- one single-spaced line with `after` points of space below it (the typst v(pitch * 0.5) gaps)
local function line(text, after, bold)
  return para("Single", text, sp(0, after or 0, 280, "exact"), bold)
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

-- section sign joined to its number: "§ 9-406" never splits across lines (typst nbsp-sections)
local function nbsp_sections(inl)
  local out = pandoc.List({})
  for i, el in ipairs(inl) do
    if el.t == "Space" and i > 1 and inl[i - 1].t == "Str" and inl[i - 1].text == "§" then
      out:insert(pandoc.Str(NBSP))
    else
      out:insert(el)
    end
  end
  return out
end

local function div(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- raw paragraphs of a cell (string list) in the Single style; the last one gets `after` points below it
local function cell_lines(items, after)
  local s = ""
  for i, t in ipairs(items) do
    s = s .. line(t, (i == #items) and after or 0)
  end
  return s
end

local function borderless_table(rows, widths)
  local grid = {}
  local total = 0
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'; total = total + w end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. rows .. '</w:tbl>'
end

local function cell(w, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- the caption (FRBP 9004(b); typst caption()): debtors above a party box ruled right and bottom; the case
-- numbers and the title of the paper in the right column, beside both
local CAP_L, CAP_R = 4464, 4536
local function caption(cap, title, jury)
  local debtors = cell_lines(cap.debtors and (function()
    local t = {}
    for _, d in ipairs(cap.debtors) do t[#t + 1] = plain(d) end
    return t
  end)() or {}, 0)

  local parties = ""
  for k, p in ipairs(cap.parties) do
    if k > 1 then parties = parties .. line("v.", 0) end
    for _, n in ipairs(p.names or {}) do parties = parties .. line(plain(n), 0) end
    parties = parties .. line(plain(p.designation), 120)
  end

  -- right column: case number, chapter, adversary number, DCN, then the title and the jury demand
  local right = {}
  for _, c in ipairs(cap["case-lines"] or {}) do right[#right + 1] = plain(c) end
  right = cell_lines(right, 240)
  local ch = {}
  for _, c in ipairs(cap["chapter-lines"] or {}) do ch[#ch + 1] = plain(c) end
  right = right .. cell_lines(ch, 240)
  right = right .. line("Adv. Proc. No.: " .. plain(cap.adversary), 240)
  if cap.dcn and plain(cap.dcn) ~= "" then right = right .. line("DCN: " .. plain(cap.dcn), 240) end
  right = right .. para("Single", plain(title):upper(), sp(0, 240, 280, "exact"), true)
  if jury then right = right .. para("Single", "DEMAND FOR JURY TRIAL", sp(0, 0, 280, "exact"), true) end

  local rows = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_L, debtors, '<w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar>')
    .. cell(CAP_R, right, '<w:vMerge w:val="restart"/><w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>')
    .. '</w:tr>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_L, parties, '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders><w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar>')
    .. cell(CAP_R, para("Single", ""), '<w:vMerge/><w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>')
    .. '</w:tr>'
  return raw(borderless_table(rows, { CAP_L, CAP_R }))
end

-- the signature block (typst signature-block()): "Dated" at left; "Respectfully submitted," and the firm, then
-- "By: /s/" and the typed name, then the lines under it; kept on one page (cantSplit)
local function signature(date, sig)
  local right = line("Respectfully submitted,", 240)
  right = right .. cell_lines(sig.firm and (function()
    local t = {}
    for _, f in ipairs(sig.firm) do t[#t + 1] = plain(f) end
    return t
  end)() or {}, 240)
  local signer = plain(sig.signer)
  right = right .. line("By: /s/ " .. signer, 0)
  right = right .. line(signer, 0)
  for _, l in ipairs(sig.lines or {}) do right = right .. line(plain(l), 0) end
  local left = line(date and ("Dated: " .. date) or "", 0)
  local rows = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(3744, left) .. cell(288, para("Single", "")) .. cell(4968, right) .. '</w:tr>'
  return raw(borderless_table(rows, { 3744, 288, 4968 }))
end

local function spacer(points)
  return raw(para("Allegation", "", sp(0, 0, points * 20, "exact")))
end

local function is_caret(inl)
  return inl[1] and inl[1].t == "Str" and inl[1].text == "^"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  local cap = meta.caption
  if cap == nil then error("caeb: the frontmatter needs a caption block", 0) end
  local jury = plain(meta.jury_demand) == "true"

  -- counsel block (LBR 9004-1(b)): upper left, single spaced, italic lines kept as written
  for _, l in ipairs(meta.counsel or {}) do add(div("Single", { pandoc.Para(l) })) end

  -- court title (FRBP 9004(b)(1)): bold, centered, upper case, double spaced
  for i, t in ipairs(meta.court or {}) do
    add(raw(para("Centered", plain(t):upper(), i == 1 and sp(240, 0, 480, "exact") or nil, true)))
  end

  add(caption(cap, meta.brief_title, jury))

  -- the cover ends its page (typst cover(): pagebreak()); the first text after it starts page 2: a page break
  -- run opens the first body paragraph (Word and LibreOffice put the break on the line before it)
  local pending = true
  local function brk(inl)
    if pending then
      pending = false
      table.insert(inl, 1, pandoc.RawInline("openxml", '<w:r><w:br w:type="page"/></w:r>'))
    end
    return inl
  end

  if meta.lead_in then
    add(pandoc.Div({ pandoc.Para(brk(pandoc.List(meta.lead_in))) }, pandoc.Attr("", {}, { ["custom-style"] = "LeadIn" })))
  end

  -- body: each paragraph is numbered 1, 2, ... (FRCP 10(b)); headings, lists and quotations are not;
  -- a paragraph beginning "^" is an unnumbered lead-in (WHEREFORE)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local content = nbsp_sections(b.content)
      if is_caret(content) then
        table.remove(content, 1)
        if content[1] and content[1].t == "Space" then table.remove(content, 1) end
        add(div("LeadIn", { pandoc.Para(brk(content)) }))
      else
        n = n + 1
        local inl = pandoc.List({ pandoc.Str(n .. "."), TAB })
        inl:extend(content)
        add(div("Allegation", { pandoc.Para(brk(inl)) }))
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local blocks = pandoc.List({})
        for j, x in ipairs(item) do
          if j == 1 and (x.t == "Para" or x.t == "Plain") then
            local inl = pandoc.List({ pandoc.Str("(" .. string.char(96 + i) .. ")"), TAB })
            inl:extend(brk(nbsp_sections(x.content)))
            blocks:insert(pandoc.Para(inl))
          else
            blocks:insert(x)
          end
        end
        add(div("Relief", blocks))
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        local blocks = pandoc.List({})
        for j, x in ipairs(item) do
          if j == 1 and (x.t == "Para" or x.t == "Plain") then
            local inl = pandoc.List({ pandoc.Str("\u{2022}"), TAB })
            inl:extend(nbsp_sections(x.content))
            blocks:insert(pandoc.Para(inl))
          else
            blocks:insert(x)
          end
        end
        add(div("Relief", blocks))
      end
    elseif b.t == "Header" then
      local h = b
      h.content = brk(nbsp_sections(h.content))
      add(h)
    else
      add(b)
    end
  end

  -- signature blocks (typst: v(pitch), then each block with v(pitch) after it), kept together
  if meta.signature then
    add(spacer(24))
    for _, sig in ipairs(meta.signature) do
      add(signature(plain(meta.date), sig))
      add(spacer(24))
    end
  end

  doc.meta.date = nil
  doc.blocks = out
  return doc
end

-- wvnd complaint, DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/wvnd-complaint.typ: court title, caption (parties left, civil action number right, rule beneath),
-- the title, the unnumbered lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)), lettered prayer items,
-- the signature block kept together (Fed. R. Civ. P. 11(a); LR Gen P 5.03(c)). Nothing case-specific is written here:
-- every word comes from the sample's frontmatter or body.
-- Known differences: the number-to-text gap is a tab stop at 0.85 in (typst: 0.25 in after the number).

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

local function xesc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function run(text)
  return '<w:r><w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

local BR = "<w:r><w:br/></w:r>"
local TAB = "<w:r><w:tab/></w:r>"

-- a paragraph of a named style; inner is run XML; ppr is optional direct pPr (in schema order)
local function px(style_id, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style_id .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (inner or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- the caption: party column (3.6 in) | gutter (0.25 in) | civil action number column, no borders
local function caption_xml(meta)
  local left = {}
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names or {}) do
      left[#left + 1] = px("Single", run(plain(name)), '<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/>')
    end
    left[#left + 1] = px("Single", run(plain(side.designation)), '<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:firstLine="0"/>')
    if i < #sides then
      left[#left + 1] = px("Single", run("v."), '<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/>')
    end
  end
  local right_inner = run("Civil Action No. " .. plain(meta.case_number))
  if meta.judge ~= nil then right_inner = right_inner .. BR .. run("Judge: " .. plain(meta.judge)) end
  local right = px("Single", right_inner)
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5184"/><w:gridCol w:w="360"/><w:gridCol w:w="3816"/></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="5184" w:type="dxa"/></w:tcPr>' .. table.concat(left)
    .. '</w:tc><w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr>' .. px("Single", "")
    .. '</w:tc><w:tc><w:tcPr><w:tcW w:w="3816" w:type="dxa"/><w:vAlign w:val="bottom"/></w:tcPr>' .. right
    .. "</w:tc></w:tr></w:tbl>"
  return tbl
end

local function court_title_xml(meta)
  local inner = run("UNITED STATES DISTRICT COURT") .. BR .. run("FOR THE NORTHERN DISTRICT OF WEST VIRGINIA")
  if meta.division ~= nil then inner = inner .. BR .. run(plain(meta.division)) end
  return px("CourtTitle", inner, '<w:spacing w:before="0" w:after="480" w:line="480" w:lineRule="exact"/>')
end

-- signature block after the last paragraph: "Dated:" at the left, the party and "By Counsel," at the middle
local function signature_xml(sig)
  local lines = {}
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = plain(l) end
  local has_email, has_phone = false, false
  for _, l in ipairs(lines) do
    if l:find("@", 1, true) then has_email = true end
    if l:match("%(?%d%d%d%)?[ .-]?%d%d%d[ .-]?%d%d%d%d") then has_phone = true end
  end
  assert(has_email, "wvnd-complaint: the signature lines need an e-mail address (Fed. R. Civ. P. 11(a))")
  assert(has_phone, "wvnd-complaint: the signature lines need a telephone number (Fed. R. Civ. P. 11(a))")
  local out = {}
  out[#out + 1] = px("SigDate", run("Dated: " .. plain(sig.date)))
  out[#out + 1] = px("SigParty", run(plain(sig.party)) .. BR .. run("By Counsel,"),
    '<w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/>')
  out[#out + 1] = px("SigLine", run("s/ " .. plain(sig.signer)), '<w:spacing w:before="480" w:after="120" w:line="240" w:lineRule="auto"/>')
  for _, l in ipairs(lines) do
    out[#out + 1] = px("SigLine", run(l))
  end
  return table.concat(out)
end

local function paragraph_with_prefix(inlines, prefix_xml)
  table.insert(inlines, 1, pandoc.RawInline("openxml", prefix_xml))
  return pandoc.Para(inlines)
end

function Pandoc(doc)
  local meta = doc.meta
  assert(meta.case_number, "wvnd-complaint: frontmatter needs case_number")
  assert(meta.caption, "wvnd-complaint: frontmatter needs caption (a list of sides)")
  assert(meta.title, "wvnd-complaint: frontmatter needs title (Fed. R. Civ. P. 10(a))")
  assert(meta.signature, "wvnd-complaint: frontmatter needs signature")

  local out = {}
  out[#out + 1] = raw(court_title_xml(meta))
  out[#out + 1] = raw(caption_xml(meta))
  out[#out + 1] = raw(px("Rule", ""))
  out[#out + 1] = raw(px("DocTitle", run(plain(meta.title))))
  if meta.lead_in ~= nil then
    out[#out + 1] = raw(px("BodyText", run(plain(meta.lead_in))))
  end

  local n = 0
  local function unnumbered(inl)
    -- an unnumbered paragraph (the introduction, notes outside the allegations)
    return pandoc.Para(inl)
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "DefinitionList" then
      -- pandoc reads a line starting "~ " as a definition: the paragraph before it becomes a term. The term is
      -- an allegation (numbered) unless it starts "~"; each definition is an unnumbered paragraph.
      for _, item in ipairs(b.content) do
        local term, defs = item[1], item[2]
        if term[1] and term[1].t == "Str" and term[1].text == "~" then
          table.remove(term, 1)
          if term[1] and term[1].t == "Space" then table.remove(term, 1) end
          out[#out + 1] = unnumbered(term)
        else
          n = n + 1
          out[#out + 1] = paragraph_with_prefix(term, run(tostring(n) .. ".") .. TAB)
        end
        for _, d in ipairs(defs) do
          for _, db in ipairs(d) do
            if db.t == "Para" or db.t == "Plain" then
              out[#out + 1] = unnumbered(db.content)
            else
              out[#out + 1] = db
            end
          end
        end
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local first = b.content[1]
      if first and first.t == "Str" and first.text == "~" then
        -- an unnumbered paragraph (the introduction, notes outside the allegations)
        table.remove(b.content, 1)
        if b.content[1] and b.content[1].t == "Space" then table.remove(b.content, 1) end
        out[#out + 1] = pandoc.Para(b.content)
      else
        -- a numbered paragraph (Fed. R. Civ. P. 10(b)); the counter runs through the whole complaint
        n = n + 1
        out[#out + 1] = paragraph_with_prefix(b.content, run(tostring(n) .. ".") .. TAB)
      end
    elseif b.t == "OrderedList" then
      -- prayer and other lettered lists: (a), (b), ...
      for i, item in ipairs(b.content) do
        local first = item[1]
        local inl = first and first.content or pandoc.Inlines({})
        local letter = "(" .. LETTERS:sub(i, i) .. ")"
        local para = paragraph_with_prefix(inl, run(letter) .. TAB)
        out[#out + 1] = pandoc.Div({ para }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered Item" }))
      end
    else
      out[#out + 1] = b
    end
  end

  -- the last paragraph keeps with the signature, so a signature never stands alone on a page
  if out[#out] and out[#out].t == "Para" then
    out[#out] = pandoc.Div({ out[#out] }, pandoc.Attr("", {}, { ["custom-style"] = "Body Keep With Next" }))
  end
  out[#out + 1] = raw(signature_xml(meta.signature))
  -- pandoc would print the metadata title and date above the body; the caption, title and date are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

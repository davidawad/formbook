-- utb adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/utb-adversary-complaint.typ: the cover (counsel block, court title, Form 416D caption as a table,
-- title), numbered allegations (Fed. R. Civ. P. 10(b)) with the complaint's lead-in and the WHEREFORE paragraph
-- unnumbered, lettered prayer items, the signature block and the verification. Styles (EB Garamond 12 pt,
-- 24 pt exact line pitch, indents, headings) and the page number footer come from reference.docx.
-- Metadata values are taken as plain text (pandoc.utils.stringify): no markup in the cover fields.
-- Known limits: the caption and signature are tables (Word and LibreOffice draw table rules a little
-- differently); allegation numbers are typed text, not Word list numbering, so they do not renumber on edit.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- one paragraph of OpenXML in a named style; bold and extra paragraph properties are optional
local function xp(text, style, opts)
  opts = opts or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>' .. (opts.ppr or "")
  local rpr = opts.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local run = ""
  if text ~= "" then
    run = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. run .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- a block-level paragraph (a RawBlock, so pandoc writes it as given)
local function P(...)
  return raw(xp(...))
end

-- a borderless table with a left column, a gutter and a right column; cells are lists of paragraph XML
local function two_col(left, right, w1, gutter, w2, left_cell_rules)
  local lrules = left_cell_rules or ""
  local tc1 = '<w:tc><w:tcPr><w:tcW w:w="' .. w1 .. '" w:type="dxa"/>' .. lrules .. '</w:tcPr>' .. table.concat(left) .. "</w:tc>"
  local tc2 = '<w:tc><w:tcPr><w:tcW w:w="' .. gutter .. '" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
  local tc3 = '<w:tc><w:tcPr><w:tcW w:w="' .. w2 .. '" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. "</w:tc>"
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (w1 + gutter + w2) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. w1 .. '"/><w:gridCol w:w="' .. gutter .. '"/><w:gridCol w:w="' .. w2 .. '"/></w:tblGrid>'
    .. "<w:tr>" .. tc1 .. tc2 .. tc3 .. "</w:tr></w:tbl>"
end

-- Form 416D caption: the debtor, then the parties (and any third-party claim) on the left, the case numbers and
-- the judge on the right. The left column has a right rule and a bottom rule, as in the typst caption.
local function caption(m)
  local left = { xp("In re:", "Single"), xp("", "Single") }
  for _, d in ipairs(m.caption.debtors) do left[#left + 1] = xp(plain(d), "Single") end
  left[#left + 1] = xp("", "Single")
  left[#left + 1] = xp(plain(m.caption.debtor_designation), "Single")
  left[#left + 1] = xp("", "Single")
  local groups = {}
  for _, p in ipairs(m.caption.parties) do groups[#groups + 1] = p end
  if m.caption.third_party then
    for _, p in ipairs(m.caption.third_party) do groups[#groups + 1] = p end
  end
  for k, p in ipairs(groups) do
    if k > 1 then
      left[#left + 1] = xp("v.", "Single")
      left[#left + 1] = xp("", "Single")
    end
    for _, n in ipairs(p.names) do left[#left + 1] = xp(plain(n), "Single") end
    left[#left + 1] = xp("", "Single")
    left[#left + 1] = xp(plain(p.designation), "Single")
    left[#left + 1] = xp("", "Single")
  end
  local bk = plain(m.case.bankruptcy_number)
  if bk == "" then bk = "________" end
  local adv = plain(m.case.adversary_number)
  if adv == "" then adv = "________" end
  local ind = '<w:ind w:left="216"/>'
  local right = {
    xp("Bankruptcy No. " .. bk, "Single", { ppr = ind }),
    xp("Chapter " .. plain(m.case.chapter), "Single", { ppr = ind }),
    xp("", "Single", { ppr = ind }),
    xp("Adversary Proceeding No. " .. adv, "Single", { ppr = ind }),
    xp("", "Single", { ppr = ind }),
    xp("Hon. " .. plain(m.case.judge), "Single", { ppr = ind }),
  }
  local rules = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="144" w:type="dxa"/><w:bottom w:w="120" w:type="dxa"/></w:tcMar>'
  return two_col(left, right, 4752, 360, 4248, rules)
end

-- cover: counsel block (single lines), court title, caption, title. A gap is an empty Normal paragraph: one exact
-- 24 pt line, as typst's v(pitch).

local function cover(m)
  local out = {}
  for _, c in ipairs(m.counsel) do out[#out + 1] = P(plain(c), "Single") end
  out[#out + 1] = P("", "Normal")
  local titles = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF UTAH" }
  if m.division and plain(m.division) ~= "" then
    titles[#titles + 1] = plain(m.division):upper() .. " DIVISION"
  end
  for _, t in ipairs(titles) do out[#out + 1] = P(t, "Centered", { bold = true }) end
  out[#out + 1] = P("", "Normal")
  out[#out + 1] = raw(caption(m))
  out[#out + 1] = P("", "Normal")
  out[#out + 1] = P(plain(m.title):upper(), "Centered", { bold = true })
  out[#out + 1] = P("", "Normal")
  return out
end

-- the signature block: "DATED ..." on the left, the firm and the signer on the right
local function signature(m)
  local s = m.signature
  local left = { xp("DATED " .. plain(s.date) .. ".", "Single") }
  local right = { xp(plain(s.firm), "Single"), xp("", "Single"), xp("/s/ " .. plain(s.signer), "Single") }
  for _, l in ipairs(s.lines) do right[#right + 1] = xp(plain(l), "Single") end
  return { P("", "Normal"), raw(two_col(left, right, 4608, 288, 4464)) }
end

-- the verification (28 U.S.C. section 1746), when the complaint is verified
local function verification(m)
  local v = m.verification
  if not v then return {} end
  local out = {
    pandoc.Header(1, { pandoc.Str("VERIFICATION") }),
    P("I, " .. plain(v.declarant) .. ", declare under penalty of perjury under the laws of the United States of America that I am "
      .. plain(v.title) .. " of " .. plain(v.entity) .. ", that I have read the foregoing " .. plain(m.title)
      .. ", and that the factual allegations in it are true and correct to the best of my knowledge, information, and belief.",
      "BodyText"),
    P("", "Normal"),
  }
  local left = { xp("Executed on " .. plain(v.date) .. ", at " .. plain(v.place) .. ".", "Single") }
  local right = { xp("", "Single"), xp(plain(v.declarant), "Single"), xp(plain(v.title) .. ", " .. plain(v.entity), "Single") }
  out[#out + 1] = raw(two_col(left, right, 4608, 288, 4464))
  return out
end

local function styled(block, style)
  return pandoc.Div({ block }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local TAB = '<w:r><w:tab/></w:r>'

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  for _, b in ipairs(cover(m)) do out[#out + 1] = b end

  -- the body: the complaint's lead-in (before the first heading) and the WHEREFORE paragraph are unnumbered;
  -- every other paragraph after a heading is a numbered allegation; a paragraph "A. ..." is a prayer item.
  local seen_heading = false
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      seen_heading = true
      out[#out + 1] = b
    elseif b.t == "Para" then
      local first, second = b.content[1], b.content[2]
      local text = pandoc.utils.stringify(b)
      if first and first.t == "Str" and first.text:match("^%u%.$") and second and second.t == "Space" then
        local content = { pandoc.Str(first.text), pandoc.RawInline("openxml", TAB) }
        for i = 3, #b.content do content[#content + 1] = b.content[i] end
        out[#out + 1] = styled(pandoc.Para(content), "Prayer")
      elseif text:match("^WHEREFORE") or not seen_heading then
        out[#out + 1] = b
      else
        n = n + 1
        local content = { pandoc.Str(n .. "."), pandoc.RawInline("openxml", TAB) }
        for _, x in ipairs(b.content) do content[#content + 1] = x end
        out[#out + 1] = styled(pandoc.Para(content), "Allegation")
      end
    else
      out[#out + 1] = b
    end
  end

  for _, b in ipairs(signature(m)) do out[#out + 1] = b end
  for _, b in ipairs(verification(m)) do out[#out + 1] = b end
  -- metadata is consumed by the cover; pandoc must not write a Title or author block of its own
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

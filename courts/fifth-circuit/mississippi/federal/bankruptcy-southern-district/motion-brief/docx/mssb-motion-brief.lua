-- Motion with memorandum (memorandum brief in support) for the U.S. Bankruptcy Court, S.D. Mississippi (mssb), docx
-- engine: what the Word output adds to pandoc's conversion, so that it reads and breaks as typst/mssb-motion-brief.typ
-- does: the court name and caption (FRBP 9004(b)), the title and docket reference (Miss. Bankr. L.R.
-- 5005-1(a)(2)(I), 9004-1(b)), the headings, quotations and address blocks, the signature block (L.R.
-- 5005-1(a)(2)(H)(i), 9011-1) and the certificate of service on a new page after it. pandoc writes the paragraphs that
-- may carry footnotes (styles Body Text, Body Keep, Quote and their Note variants, from docx/reference.xml) and the
-- notes (Footnote Text). Everything printed comes from the sample's frontmatter and body: no case text lives here.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap: one blank single line
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 5184, 360   -- typst caption-left 3.6 in, caption-gutter 0.25 in
local SIG_INDENT = 4680                  -- typst signature-indent 3.25 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function need(v, msg)
  if v == nil or plain(v) == "" then error("mssb-motion-brief: " .. msg) end
  return v
end

-- A single-pitch paragraph: o = { keep, brk, before, after, line, left, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = o.keep == "next" and "<w:keepNext/>" or xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
  '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
local CELL_MAR = '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
local LOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

local function tc(w, body, pr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption (one table: names | case facts and designations, a blank single line between the
-- blocks), title and docket reference
-- ---------------------------------------------------------------------------

local function caption(meta)
  local c = need(meta.caption, "frontmatter needs caption (debtor, case_number, chapter, parties, adversary_number)")
  local right_w = TEXTW - CAP_LEFT
  local rows = {}
  local function stack(list, jc)
    local out = {}
    for _, s in ipairs(list) do out[#out + 1] = p(xe.inl(s), { jc = jc }) end
    return table.concat(out)
  end
  local function row(left, right, jc)
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(CAP_LEFT, stack(left)) ..
      tc(right_w, stack(right, jc), '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>') .. '</w:tr>'
  end
  local function spacer()
    rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="' .. GAP .. '" w:hRule="exact"/></w:trPr>' ..
      tc(TEXTW, p("", { line = GAP }), '<w:gridSpan w:val="2"/>') .. '</w:tr>'
  end
  row(c.debtor.names, { "CASE NO. " .. plain(c.case_number), c.chapter })
  spacer()
  for k, party in ipairs(c.parties) do
    if k > 1 then
      spacer()
      row({ "V." }, { "ADV. PROC. NO. " .. plain(c.adversary_number) })
      spacer()
    end
    row(party.names, { party.designation }, "right")
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. NO_BORDERS .. CELL_MAR .. LOOK ..
    '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. right_w .. '"/></w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>'
end

local function cover(meta)
  local court = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF MISSISSIPPI" }
  if plain(meta.division) ~= "" then court[#court + 1] = pandoc.text.upper(plain(meta.division)) end
  local out = {}
  for k, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = k == #court and GAP or 0 })
  end
  out[#out + 1] = caption(meta)
  local title = need(meta.title, "frontmatter needs title: every content of the paper goes in the caption (5005-1(a)(2)(I); FRBP 9004(b)(4))")
  local docket = need(meta.related_docket, "frontmatter needs related_docket (Miss. Bankr. L.R. 9004-1(b))")
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(title)), { b = true }), { jc = "center", before = GAP })
  out[#out + 1] = p(xe.runs("(Dkt. # ") .. xe.inl(docket) .. xe.runs(")"), { jc = "center", after = GAP })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A heading, one line at the double pitch, kept with the block after it: level 1 centered bold capitals, level 2
-- bold at the left, level 3 bold italic at the left. `brk`: it starts a new page (the certificate).
local function heading(el, brk)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  local props = { xe.style("Heading" .. lvl), xe.KEEP }
  if brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(0, 0, BODY)
  props[#props + 1] = xe.ind(0, nil, 0)
  props[#props + 1] = xe.jc(lvl == 1 and "center" or "left")
  return xe.para(props, xe.inl(content, { b = true, i = lvl == 3 }))
end

-- Lines set with hard breaks (an address block): one paragraph a line, kept together, a blank single line around
-- them (typst address-block).
local function address(inlines, keep)
  local lines, cur = {}, pandoc.Inlines({})
  for _, x in ipairs(inlines) do
    if x.t == "LineBreak" then
      lines[#lines + 1] = cur
      cur = pandoc.Inlines({})
    else
      cur:insert(x)
    end
  end
  lines[#lines + 1] = cur
  local out = {}
  for i, l in ipairs(lines) do
    local last = i == #lines
    out[#out + 1] = p(xe.inl(l), { before = i == 1 and GAP or 0, after = last and GAP or 0,
      keep = (not last or keep) and true or nil })
  end
  return table.concat(out)
end

-- The signature block: the date line at the left; the party, "/s/" and the counsel lines in the right half; one
-- block a double line below the text.
local function signature(meta)
  local s = need(meta.signature, "frontmatter needs signature")
  local lines = {}
  if plain(s.party) ~= "" then lines[#lines + 1] = xe.inl(s.party) end
  lines[#lines + 1] = xe.runs("/s/ ") .. xe.inl(s.signer)
  for _, l in ipairs(s.counsel) do lines[#lines + 1] = xe.inl(l) end
  local out = { p(xe.inl(s.date), { before = BODY, keep = true }) }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { left = SIG_INDENT, before = i == 1 and BODY or 0, keep = i < #lines or nil })
  end
  return table.concat(out)
end

local function has_note(inlines)
  for _, x in ipairs(inlines) do
    if x.t == "Note" then return true end
  end
  return false
end

-- A paragraph pandoc writes in `style`; one that anchors a footnote and is not kept takes the style's Note variant
-- (no widow control), as typst sets it.
local function div(style, inlines)
  if has_note(inlines) and style ~= "Body Keep" then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function has_break(inlines)
  for _, x in ipairs(inlines) do
    if x.t == "LineBreak" then return true end
  end
  return false
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- Two more of typst's rules (Unicode line breaking): no break between a section sign or pilcrow and its number,
-- also when the sign ends a word ("(¶ 5)"), nor at a space before a period, comma, colon or semicolon (". . ."):
-- that space becomes a no-break space.
local function binds(l)
  for i = 1, #l - 1 do
    local a, b = l[i], l[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local nxt = l[i + 2]
      if (a.text:sub(-2) == "\u{00A7}" or a.text:sub(-2) == "\u{00B6}") or (nxt and nxt.t == "Str" and nxt.text:find("^[.,:;]")) then
        l[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return l
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = binds })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local out = { xe.raw(cover(meta)) }
  local blocks = doc.blocks
  -- the block the signature follows: the one before the certificate heading, or the last
  local cert
  for i, b in ipairs(blocks) do
    if not cert and b.t == "Header" and plain(b.content):upper():sub(1, 11) == "CERTIFICATE" then cert = i end
  end
  local sign_after = cert and cert - 1 or #blocks
  for i, b in ipairs(blocks) do
    local keep = i == sign_after
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b, i == cert))
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("mssb-motion-brief.lua: unsupported block in a quotation: " .. q.t) end
        out[#out + 1] = div("Quote", q.content)
      end
    elseif (b.t == "Para" or b.t == "Plain") and has_break(b.content) then
      out[#out + 1] = xe.raw(address(b.content, keep))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = div(keep and "Body Keep" or "Body Text", b.content)
    else
      error("mssb-motion-brief.lua: unsupported block " .. b.t)
    end
    if keep then out[#out + 1] = xe.raw(signature(meta)) end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

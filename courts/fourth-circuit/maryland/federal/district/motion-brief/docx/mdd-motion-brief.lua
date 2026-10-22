-- mdd-motion-brief.lua (docx engine): the D. Md. memorandum as Word paragraphs, so that it reads and breaks as
-- typst/mdd-motion-brief.typ does: the court lines, the short caption (first plaintiff and first defendant only,
-- LR-102.2.a; a table whose party column has a right rule, the case number beside it), the title; the body (every
-- paragraph indented, headings, lists numbered 1., 2., ... with a hanging indent, footnotes); the signature block
-- (LR-102.1.b.i) and the certificate of service (optional), kept together. toc: true is refused: the table of
-- contents (LR-105.4) is not built for docx (BLOCKED, see README). Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line, 230 a
-- footnote line), the spaces between blocks those of the typst template, and the break rules of typst on every run.
-- A paragraph that carries a footnote is left to pandoc in Body Text (the same layout), so that pandoc writes the
-- note. pandoc reads the sample without fancy lists (reference.xml pandoc-from), so "A. Grant ..." stays a
-- paragraph, as typst reads it.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap-half
local HEAD_ABOVE = 395                   -- typst heading-above, 19.75 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local LABEL = 900                        -- typst item-label, 0.625 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAD = 4896, 288      -- typst caption-left 3.4 in, caption-pad 0.2 in
local DESIG = 2592                       -- typst designation-indent, 1.8 in
local CASE_TOP = 72                      -- typst case-top, 3.6 pt
local SIG_LEFT = 4896                    -- typst sig-left, 3.4 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless one-row table that never splits: cells = { { width, paragraphs, tcBorders } }.
local function tbl(cells)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      table.concat(c[2]) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court lines, short caption, title
-- ---------------------------------------------------------------------------

local function caption(meta)
  local parties = meta.caption.parties
  if #parties ~= 2 then
    error("mdd-motion-brief: LR-102.2.a: the short caption names the first plaintiff and the first defendant only")
  end
  local left = {}
  local function add(x, o)
    o = o or {}
    o.right = CAP_PAD
    left[#left + 1] = p(x, o)
  end
  for k, party in ipairs(parties) do
    if k > 1 then add(xe.runs("v."), { jc = "center", before = GAP, after = GAP }) end
    for _, n in ipairs(party.names) do add(xe.inl(n)) end
    -- the last designation keeps the caption's bottom padding (typst: pad(bottom: gap-half))
    add(xe.inl(party.designation), { before = GAP, left = DESIG, after = k == #parties and GAP or 0 })
  end
  local right = { p(xe.runs("Case No. " .. plain(meta.case_number)), { before = CASE_TOP, left = CAP_PAD }) }
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return tbl({ { CAP_LEFT, left, rule }, { TEXTW - CAP_LEFT, right } })
end

local function cover(meta)
  local out = {}
  for _, c in ipairs(meta.court) do out[#out + 1] = p(xe.inl(c), { jc = "center" }) end
  -- typst: the caption stands a double line below the court lines
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = caption(meta)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.brief_title)), { b = true }),
    { jc = "center", before = BODY, after = GAP, line = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (LR-102.1.b.i) and certificate of service: kept together (typst: one unbreakable block)
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = { "/s/ " .. plain(sig.name), sig.name, sig.bar }
  for _, f in ipairs(sig.firm) do lines[#lines + 1] = f end
  for _, a in ipairs(sig.address) do lines[#lines + 1] = a end
  for _, l in ipairs({ "Telephone: " .. plain(sig.phone), "Facsimile: " .. plain(sig.fax), sig.email, sig.role }) do
    lines[#lines + 1] = l
  end
  local cert = meta.certificate
  local right = {}
  for i, l in ipairs(lines) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and BODY or 0, keep = cert ~= nil }) end
  local left = { p(meta.date and (xe.runs("Dated: ") .. xe.inl(meta.date)) or "", { before = BODY, keep = cert ~= nil }) }
  out[#out + 1] = tbl({ { SIG_LEFT, left }, { TEXTW - SIG_LEFT, right } })
  if cert then
    out[#out + 1] = xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(HEAD_ABOVE, 0, BODY), xe.ind(0, nil, 0),
      xe.jc("center") }, xe.runs("CERTIFICATE OF SERVICE", { b = true }))
    out[#out + 1] = p(xe.inl(cert.text), { line = BODY, first = INDENT, keep = true })
    out[#out + 1] = p(xe.runs("/s/ _______________________"), { before = BODY, keep = true })
    out[#out + 1] = p(xe.inl(cert.signer))
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, kept with the text: level 1 centered bold capitals, level 2 bold hanging, level 3 bold
-- italic. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  local lvl = math.min(b.level, 3)
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local ind = lvl == 2 and xe.ind(INDENT, INDENT, nil) or xe.ind(0, nil, 0)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(HEAD_ABOVE, 0, BODY), ind,
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A space before a footnote mark is not printed (typst sets the mark against the word).
local function tight_notes(inl)
  for i = #inl - 1, 1, -1 do
    if inl[i].t == "Space" and inl[i + 1].t == "Note" then inl:remove(i) end
  end
  return inl
end

-- A doubled sign stays with its number ("§§ 1983"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  local meta = doc.meta
  if meta.toc and plain(meta.toc) == "true" then
    error("mdd-motion-brief: LR 105.4: the table of contents is not built for the docx engine (BLOCKED); a memorandum over fifteen pages needs one")
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = tight_notes })
  local out = cover(meta)
  local res = {}
  local function flush()
    for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
    out = {}
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local n = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
        if has_note(item[1]) then
          local c = pandoc.Inlines({ pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
          c:extend(item[1].content)
          out[#out + 1] = pandoc.Div({ pandoc.Para(c):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = "List Item Indented" })
        else
          out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
            { line = BODY, left = INDENT + LABEL, hanging = LABEL })
        end
        n = n + 1
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if has_note(b) then
        out[#out + 1] = pandoc.Div({ pandoc.Para(b.content):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = "Body Text Note" })
      else
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
      end
    else
      error("mdd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  flush()
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

-- Motion (with memorandum brief) for the U.S. Bankruptcy Court, N.D. Mississippi (msnb), docx engine: what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/msnb-motion-brief.typ does: the court name
-- and caption (FRBP 9004(b)), the title, the headings, the numbered paragraphs (one count through the paper), the
-- lettered items, the signature block, OF COUNSEL (ULR 5005-1(L)(i), 9011-1(a)) and the certificate of service with
-- its signature (ULR 9004-1(c)). pandoc writes the paragraphs that may carry footnotes (styles Body Para, Item and
-- their Keep and Note variants, from docx/reference.xml) and the notes (Footnote Text). Everything printed comes from
-- the sample's frontmatter and body: no case text lives here.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap: one blank single line
local TEXTW = 9360                       -- 6.5 in
local CAP_RIGHT = 4320                   -- typst caption-right 3 in
local ROLE_INDENT = 1440                 -- typst role-indent 1 in
local SIG_INDENT = 3960                  -- typst signature-indent 2.75 in
local TITLE_INDENT = 720                 -- typst signer-title-indent 0.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function need(v, msg)
  if v == nil or plain(v) == "" then error("msnb-motion-brief: " .. msg) end
  return v
end

-- A single-pitch paragraph: o = { keep, before, after, line, left, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
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
-- Cover: court name, caption (one bold table: "IN RE:", the names with the case number beside the last, the
-- designation with the chapter; a blank single line between the blocks), title
-- ---------------------------------------------------------------------------

local function caption(meta)
  local d = need(meta.debtor, "frontmatter needs debtor (names, role, chapter)")
  local left_w = TEXTW - CAP_RIGHT
  local B = { b = true }
  local rows = {}
  local function row(l, r, lo)
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(left_w, p(l, lo)) ..
      tc(CAP_RIGHT, p(r, { jc = "right" })) .. '</w:tr>'
  end
  local function spacer()
    rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="' .. GAP .. '" w:hRule="exact"/></w:trPr>' ..
      tc(TEXTW, p("", { line = GAP }), '<w:gridSpan w:val="2"/>') .. '</w:tr>'
  end
  row(xe.runs("IN RE:", B), "")
  spacer()
  for i, n in ipairs(d.names) do
    row(xe.inl(n, B), i == #d.names and xe.runs("CASE NO. " .. plain(need(meta.case_number, "frontmatter needs case_number")), B) or "")
  end
  spacer()
  row(xe.inl(d.role, B), d.chapter and xe.runs("CHAPTER " .. plain(d.chapter), B) or "", { left = ROLE_INDENT })
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. NO_BORDERS .. CELL_MAR .. LOOK ..
    '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. left_w .. '"/><w:gridCol w:w="' .. CAP_RIGHT .. '"/></w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>'
end

local function cover(meta)
  local court = { "IN THE UNITED STATES BANKRUPTCY COURT", "NORTHERN DISTRICT OF MISSISSIPPI" }
  local out = {}
  for k, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = k == #court and GAP or 0 })
  end
  out[#out + 1] = caption(meta)
  local title = need(meta.title, "frontmatter needs title (FRBP 9004(b))")
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(title)), { b = true }), { jc = "center", before = GAP, after = GAP })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature blocks
-- ---------------------------------------------------------------------------

-- "Respectfully submitted,", the party, "By:" and the signer, the signer's title in the right half, a double line
-- below the text; then OF COUNSEL and the counsel lines flush left.
local function signature(meta)
  local s = need(meta.signature, "frontmatter needs signature")
  local out = {
    p(xe.runs("Respectfully submitted,"), { left = SIG_INDENT, before = BODY, keep = true }),
    p(xe.inl(s.firm, { b = true }), { left = SIG_INDENT, before = GAP, keep = true }),
    p(xe.runs("By: ") .. xe.inl(s.signer, { i = true, u = true }), { left = SIG_INDENT, before = GAP, keep = true }),
    p(xe.inl(s.title), { left = SIG_INDENT + TITLE_INDENT }),
  }
  local counsel = meta.counsel or {}
  if #counsel > 0 then
    out[#out + 1] = p(xe.runs("OF COUNSEL:"), { before = BODY, keep = true })
    for i, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l), { keep = i < #counsel or nil }) end
  end
  return table.concat(out)
end

-- The certificate's signature: its lines single-spaced in the right half, kept together, a double line above.
local function cert_signature(blocks)
  local out = {}
  for i, b in ipairs(blocks) do
    if b.t ~= "Para" and b.t ~= "Plain" then error("msnb-motion-brief.lua: unsupported block in a signature: " .. b.t) end
    out[#out + 1] = p(xe.inl(b.content), { left = SIG_INDENT, before = i == 1 and BODY or 0, keep = i < #blocks or nil })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A heading, one line at the double pitch, kept with the block after it: level 1 centered bold underlined capitals,
-- level 2 bold at the left, level 3 bold italic at the left.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3, u = lvl == 1 }))
end

local function has_note(inlines)
  for _, x in ipairs(inlines) do
    if x.t == "Note" then return true end
  end
  return false
end

-- A paragraph pandoc writes in `style` ("Body Para" or "Item"): the Keep variant before the signature, else the Note
-- variant when it anchors a footnote (no widow control), as typst sets it.
local function div(style, inlines, keep)
  if keep then style = style .. " Keep" elseif has_note(inlines) then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- Two more of typst's rules (Unicode line breaking): no break between a section sign or pilcrow and its number,
-- also when the sign ends a word, nor at a space before a period, comma, colon or semicolon: that space becomes a
-- no-break space.
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

local function item_inlines(item)
  if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
    error("msnb-motion-brief.lua: a list item must be one paragraph")
  end
  return item[1].content
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = binds })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local out = { xe.raw(cover(meta)) }
  local blocks = doc.blocks
  -- the block the signature follows: the one before the certificate heading, or the last; the certificate's own
  -- signature: from its first paragraph that starts with "/s/" or "s/"
  local cert, cert_sig
  for i, b in ipairs(blocks) do
    if not cert and b.t == "Header" and plain(b.content):upper() == "CERTIFICATE OF SERVICE" then cert = i end
  end
  if cert then
    for i = cert + 1, #blocks do
      local b = blocks[i]
      if not cert_sig and (b.t == "Para" or b.t == "Plain") and plain(b.content):gsub("\u{200B}", ""):match("^/?s/ ") then cert_sig = i end
    end
  end
  local sign_after = cert and cert - 1 or #blocks
  local n = 0
  for i, b in ipairs(blocks) do
    if cert_sig and i >= cert_sig then
      if i == cert_sig then
        local rest = {}
        for k = cert_sig, #blocks do rest[#rest + 1] = blocks[k] end
        out[#out + 1] = xe.raw(cert_signature(rest))
      end
      goto continue
    end
    do
      local keep = i == sign_after
      if b.t == "Header" then
        out[#out + 1] = xe.raw(heading(b))
      elseif b.t == "OrderedList" then
        for k, item in ipairs(b.content) do
          n = n + 1
          local inls = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
          inls:extend(item_inlines(item))
          out[#out + 1] = div("Body Para", inls, keep and k == #b.content)
        end
      elseif b.t == "BulletList" then
        for k, item in ipairs(b.content) do
          local inls = pandoc.Inlines({ pandoc.Str(string.char(96 + k) .. "."), TAB })
          inls:extend(item_inlines(item))
          out[#out + 1] = div("Item", inls, keep and k == #b.content)
        end
      elseif b.t == "Para" or b.t == "Plain" then
        out[#out + 1] = div("Body Para", b.content, keep)
      else
        error("msnb-motion-brief.lua: unsupported block " .. b.t)
      end
      if keep then out[#out + 1] = xe.raw(signature(meta)) end
    end
    ::continue::
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

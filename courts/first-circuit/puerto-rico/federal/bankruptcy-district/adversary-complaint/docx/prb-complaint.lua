-- prb adversary complaint, docx engine: what the Word output adds to pandoc's conversion, so that it reads and
-- breaks as typst/prb-adversary-complaint.typ does (README "Engines"): the court lines, the caption (parties on the
-- left with a right and bottom rule and a rule under the debtor, the case and adversary numbers on the right), the
-- title, "TO THE HONORABLE COURT:" and the lead-in, the numbered paragraphs (FRCP 10(b)), the unnumbered prayer
-- lead-in, the lettered prayer items and the signature block (LBR 1005-1(c)). Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file. Body paragraphs stay pandoc paragraphs (in the
-- reference's styles); the rest is written as WordprocessingML.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local HALF = 138                         -- typst half-gap
local RULE_W = 15                        -- the rule under the debtor, 0.75 pt: LibreOffice adds a paragraph border's width to
                                         -- its line, typst draws it over the line box: the space after it is less by that
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288   -- typst caption-left 3.4 in, caption-gutter 0.2 in
local CAP_PAD = 200                      -- typst caption-pad 10 pt
local RIGHT_PAD = 216                    -- typst right-pad 0.15 in
local SIG = 4320                         -- typst sig-indent 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, jc, keep, rule } (rule: a rule below the line).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.rule then
    props[#props + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>'
  end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Court lines and caption
-- ---------------------------------------------------------------------------

local function upper(m)
  return pandoc.Inlines(m):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function caption(meta)
  assert(meta.bankruptcy_case, "prb-complaint: LBR 1005-1(a) requires bankruptcy_case in the frontmatter")
  assert(meta.chapter, "prb-complaint: LBR 1005-1(a) requires chapter in the frontmatter")
  -- the caption stands a double line below the court lines: the space on the first line of each column (Word sets
  -- no space above a table)
  local left = { p(xe.runs("In re:"), { before = BODY }) }
  for _, n in ipairs(meta.debtor.names) do left[#left + 1] = p(xe.inl(n)) end
  left[#left + 1] = p(xe.inl(meta.debtor.designation), { rule = true })
  for k, party in ipairs(meta.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for i, n in ipairs(party.names) do
      left[#left + 1] = p(xe.inl(n), { before = (k == 1 and i == 1) and (HALF - RULE_W) or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local adv = plain(meta.adversary)
  local right = {
    p(xe.runs("Bankr. Case No. ") .. xe.inl(meta.bankruptcy_case), { before = BODY }),
    p(xe.inl(meta.chapter)),
    p(xe.runs("Adv. Proceeding No. ") .. (adv == "" and xe.runs("__________") or xe.inl(meta.adversary))),
  }
  local B = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  local R = '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  local rw = TEXTW - CAP_LEFT - CAP_GUTTER
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders>' .. B .. R .. '</w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcPr>' .. p("", { before = BODY }) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. rw .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. RIGHT_PAD .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature block: one chain of kept lines, never split across a page
-- ---------------------------------------------------------------------------

local function signature(sig)
  assert(sig and sig.signer, "prb-complaint: the frontmatter needs signature.signer (LBR 5005-4(b)(2)(C)(ii))")
  local lines = {
    { body = xe.runs("Respectfully submitted,"), before = BODY },
    { body = xe.inl(sig.date), before = SINGLE },
    { body = xe.runs("/s/ ") .. xe.inl(sig.signer), before = SINGLE, left = SIG },
  }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { body = xe.inl(l), left = SIG } end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l.body, { before = l.before, left = l.left, keep = i < #lines }))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body size and pitch, at the margin, bold (level 1 in capitals, level 3 italic too); kept with
-- the text.
local function heading(el)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("left") }, xe.inl(content, { b = true, i = el.level == 3 }))
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- The prayer's lead-in ("**WHEREFORE**, ...") is not numbered, nor a paragraph marked "(unnumbered) " (the marker
-- is dropped), as the typst template does.
local function unnumbered(c)
  local first = c[1]
  if first and first.t == "Strong" and first.content[1] and first.content[1].t == "Str"
    and first.content[1].text:match("^WHEREFORE") then
    return c
  end
  if first and first.t == "Str" and first.text == "(unnumbered)" then
    local rest = pandoc.Inlines({})
    for i = 3, #c do rest:insert(c[i]) end
    return rest
  end
  return nil
end

local function body_blocks(blocks)
  local out = {}
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      local u = unnumbered(b.content)
      if u then
        out[#out + 1] = styled("Body Text", u)
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inl:extend(b.content)
        out[#out + 1] = styled("Numbered Paragraph", inl)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- lettered items: the letter half an inch in, a tab to the text, which hangs at one inch
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local inl = pandoc.Inlines({})
          if k == 1 then
            inl:insert(pandoc.Str(b.t == "OrderedList" and (string.char(64 + j) .. ".") or "\u{2022}"))
            inl:insert(TAB)
          end
          inl:extend(ib.content)
          out[#out + 1] = styled("Lettered Item", inl)
        end
      end
    else
      error("prb-complaint.lua: unsupported block " .. b.t)
    end
  end
  return out
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space); a doubled section sign stays with its number (a no-break space, as
-- xe binds a single one). None of these shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

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
  assert(meta.signature, "prb-complaint: the frontmatter needs a signature block (LBR 1005-1(c))")
  doc = pandoc.Pandoc(doc.blocks):walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = xe.inlines })
  local out = {}
  for _, l in ipairs(meta.court) do out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true }) end
  out[#out + 1] = caption(meta)
  -- the title stands a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { before = BODY, after = SINGLE, jc = "center", keep = true })
  out[#out + 1] = p(xe.runs("TO THE HONORABLE COURT:", { b = true }), { line = BODY, keep = true })
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  if meta.lead_in then blocks[#blocks + 1] = styled("Body Text", meta.lead_in) end
  for _, b in ipairs(body_blocks(doc.blocks)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta.signature)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

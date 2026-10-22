-- prb motion brief (memorandum of law in support of a motion), docx engine: what the Word output adds to pandoc's
-- conversion, so that it reads and breaks as typst/prb-motion-brief.typ does (README "Engines"): the court lines,
-- the caption (parties on the left with a right and bottom rule and a rule under the debtor, the case and adversary
-- numbers on the right), the title, "TO THE HONORABLE COURT:" and the lead-in, the body (headings; paragraphs and
-- quotations stay pandoc's, so pandoc writes their footnotes), the response-time NOTICE (LBR 9013-1(c)), the
-- certificate of service (LBR 9013-3(a)) when the frontmatter has one, and the signature block (LBR 1005-1(c)).
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
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

local function upper(m)
  return pandoc.Inlines(m):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Caption
-- ---------------------------------------------------------------------------

local function caption(meta)
  assert(meta.bankruptcy_case, "prb-motion-brief: LBR 1005-1(a) requires bankruptcy_case in the frontmatter")
  assert(meta.chapter, "prb-motion-brief: LBR 1005-1(a) requires chapter in the frontmatter")
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
-- Notice (LBR 9013-1(c)), certificate of service, signature: each one block that never splits across a page
-- ---------------------------------------------------------------------------

-- Paragraphs kept together: each kept with the next, the last one ends the chain.
local function chain(lines, out)
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l.body, { before = l.before, left = l.left, jc = l.jc, line = l.line,
      keep = i < #lines }))
  end
end

-- LBR 9013-1(c)(1): the response-time notice, in its own words (the period from LBR 9013-1(c)(2))
local DAYS = { ["14"] = "fourteen (14)", ["21"] = "twenty-one (21)", ["30"] = "thirty (30)" }
local function response_notice(meta, out)
  local days = plain(meta.response_days or "14")
  assert(DAYS[days], "prb-motion-brief: LBR 9013-1(c)(2) gives a response period of 14, 21 or 30 days (response_days)")
  local text = "Within " .. DAYS[days] .. " days after service as evidenced by the certification, and an additional three (3) days pursuant to Fed. R. Bank. P. 9006(f) if you were served by mail, any party against whom this paper has been served, or any other party to the action who objects to the relief sought herein, shall serve and file an objection or other appropriate response to this paper with the clerk\u{2019}s office of the United States Bankruptcy Court for the District of Puerto Rico. If no objection or other response is filed within the time allowed herein, the paper will be deemed unopposed and may be granted unless: (i) the requested relief is forbidden by law; (ii) the requested relief is against public policy; or (iii) in the opinion of the court, the interest of justice requires otherwise."
  -- the notice's text keeps its lines together (typst: one unbreakable block)
  out[#out + 1] = xe.raw(p(xe.runs("NOTICE", { b = true }), { before = BODY, jc = "center", keep = true }))
  out[#out + 1] = xe.raw(xe.para({ xe.LINES, xe.spacing(SINGLE, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs(text)))
end

local function signature(sig, out)
  assert(sig and sig.signer, "prb-motion-brief: the frontmatter needs signature.signer (LBR 5005-4(b)(2)(C)(ii))")
  local lines = {
    { body = xe.runs("Respectfully submitted,"), before = BODY },
    { body = xe.inl(sig.date), before = SINGLE },
    { body = xe.runs("/s/ ") .. xe.inl(sig.signer), before = SINGLE, left = SIG },
  }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { body = xe.inl(l), left = SIG } end
  chain(lines, out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body size and pitch, at the margin, bold (level 1 in capitals, level 3 italic too); kept with
-- the text.
local function heading(el)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.raw(xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("left") }, xe.inl(content, { b = true, i = el.level == 3 })))
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A body paragraph: pandoc writes it (and its footnotes) in "Body Text"; a paragraph that carries a footnote mark
-- in "Body Text Note" (no widow control).
local function body_par(inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = has_note(inlines) and "Body Text Note" or "Body Text" })
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
  assert(meta.signature, "prb-motion-brief: the frontmatter needs a signature block (LBR 1005-1(c))")
  doc = pandoc.Pandoc(doc.blocks):walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = xe.inlines })
  local out = {}
  for _, l in ipairs(meta.court) do
    out[#out + 1] = xe.raw(p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true }))
  end
  out[#out + 1] = xe.raw(caption(meta))
  -- the title stands a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = xe.raw(p(xe.inl(meta.title, { b = true }), { before = BODY, after = SINGLE, jc = "center", keep = true }))
  out[#out + 1] = xe.raw(p(xe.runs("TO THE HONORABLE COURT:", { b = true }), { line = BODY, keep = true }))
  if meta.lead_in then out[#out + 1] = body_par(meta.lead_in) end

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content)
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
    else
      error("prb-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  response_notice(meta, out)
  if meta.certificate then
    out[#out + 1] = xe.raw(xe.para({ xe.LINES, xe.spacing(BODY, 0, BODY), xe.ind(0, nil, 0), xe.jc("left") },
      xe.runs("CERTIFICATE OF SERVICE:", { b = true }) .. xe.runs(" ") .. xe.inl(meta.certificate)))
  end
  signature(meta.signature, out)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

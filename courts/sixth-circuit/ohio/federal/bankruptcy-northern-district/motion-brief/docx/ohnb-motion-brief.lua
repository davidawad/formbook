-- N.D. Ohio bankruptcy motion with memorandum, docx engine (docs/DOCX.md). Mirrors typst/ohnb-motion-brief.typ on the
-- cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in exact
-- line boxes of the typst pitch, the spaces between blocks those of the typst template, the break rules of typst on
-- every run. The court lines (centred bold capitals), the caption table (the parties at the left, a column of ")",
-- the case, chapter, judge and adversary numbers at the right; FRBP 9004(b), 7010), the bold centred title; the
-- motion up to the first "# MEMORANDUM" heading and the memorandum, each ending in its last chunk kept with a
-- signature block (LBR 5005-1(c)); the NOTICE OF MOTION (LBR 9013-1(a)(2)) and the CERTIFICATE OF SERVICE (LBR
-- 9013-3), each kept on one page. The footer (the centred page number) and the section are the filter's
-- ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL). Nothing case-specific is written here: every string comes from the sample's
-- YAML frontmatter.
local xe = require("docx.xengine")

local BODY, SINGLE, BLANK = 480, 276, 276  -- typst pitch-body 24 pt, pitch-single 13.8 pt, blank 13.8 pt
local INDENT = 720                         -- typst para-indent 0.5 in
local CAP_W = { 5040, 432, 3888 }          -- typst cap-left 3.5 in, cap-mid 0.3 in, cap-right 2.7 in
local SIG_INDENT = 4680                    -- typst sig-indent 3.25 in

local NOTICE_TEXT = "Any objection to this motion must be filed within 14 days, or such other time as specified by applicable "
  .. "Federal Rule of Bankruptcy Procedure or statute or as the Court may order, from the date of service as set forth on "
  .. "the certificate of service below, if the relief sought is opposed. The Court is authorized to grant the relief "
  .. "requested without further notice unless a timely objection is filed."

local function need(meta, key)
  if meta[key] == nil then error("ohnb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function upper(x)
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, line, left, first, jc, keep, lines }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A centred bold heading on the body pitch, kept with the next paragraph (typst head()).
local function head(runs, before)
  return p(runs, { before = before or 0, line = BODY, keep = true, jc = "center" })
end

-- Break opportunities as typst has them (UAX #14): none inside a token of adjacent parentheses ("727(a)(2)(A)"): a
-- word joiner between ")" and "("; one after a slash before a letter ("Debtors/Defendants"), where LibreOffice keeps
-- the word whole: a zero-width space after it. Neither shows in the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break after a doubled sign ("§§ 727(a)"; typst boxes the token): the space becomes a no-break space.
local function bind_spaces(l)
  for i = 1, #l - 1 do
    local s = l[i]
    if s.t == "Str" and l[i + 1].t == "Space" and (s.text:find("§§$") or s.text:find("¶¶$")) then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- ---------------------------------------------------------------------------
-- caption (FRBP 9004(b), 7010; typst caption())
-- ---------------------------------------------------------------------------

local function cell(w, xml)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. xml .. "</w:tc>"
end

local function caption(meta)
  local out = {}
  local court = items(need(meta, "court"))
  if meta.division ~= nil then court[#court + 1] = meta.division end
  for _, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true })
  end
  -- the blank single line above the caption (Word has no space before a table: an empty paragraph that tall)
  out[#out + 1] = p("", { line = BLANK, keep = true })

  -- a designation may be empty: a blank row, as typst's
  local function line(x) local s = pandoc.utils.stringify(x); return s == "" and "" or xe.inl(x) end
  local left = {}
  for _, d in ipairs(items(need(meta, "debtor-caption"))) do left[#left + 1] = xe.inl(d) end
  left[#left + 1] = xe.runs("Debtor.")
  local parties = meta.parties
  if parties ~= nil then
    for _, s in ipairs({ "", "____________________________________", "" }) do
      left[#left + 1] = s == "" and "" or xe.runs(s)
    end
    for _, x in ipairs(items(need(parties, "plaintiffs"))) do left[#left + 1] = xe.inl(upper(x)) end
    left[#left + 1] = line(need(parties, "plaintiff-designation"))
    for _, s in ipairs({ "", "v.", "" }) do left[#left + 1] = s == "" and "" or xe.runs(s) end
    for _, x in ipairs(items(need(parties, "defendants"))) do left[#left + 1] = xe.inl(upper(x)) end
    left[#left + 1] = line(need(parties, "defendant-designation"))
  end

  local right = { xe.runs("Case No. ") .. xe.inl(need(meta, "case-number")), "" }
  if meta.chapter ~= nil then right[#right + 1] = xe.runs("Chapter ") .. xe.inl(meta.chapter); right[#right + 1] = "" end
  if meta.judge ~= nil then right[#right + 1] = xe.runs("Judge ") .. xe.inl(meta.judge); right[#right + 1] = "" end
  if meta["adversary-number"] ~= nil then
    right[#right + 1] = xe.runs("Adv. Pro. No. ") .. xe.inl(meta["adversary-number"])
  end

  local total = CAP_W[1] + CAP_W[2] + CAP_W[3]
  local t = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' }
  for _, w in ipairs(CAP_W) do t[#t + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  t[#t + 1] = "</w:tblGrid>"
  for i = 1, math.max(#left, #right) do
    t[#t + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
      .. cell(CAP_W[1], p(left[i] or "")) .. cell(CAP_W[2], p(xe.runs(")"), { jc = "center" }))
      .. cell(CAP_W[3], p(right[i] or "")) .. "</w:tr>"
  end
  t[#t + 1] = "</w:tbl>"
  out[#out + 1] = table.concat(t)

  out[#out + 1] = p(xe.inl(need(meta, "title"), { b = true }), { before = BLANK, jc = "center" })
  -- one blank single line between the title and the body
  out[#out + 1] = p("", { line = BLANK })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- signature blocks (LBR 5005-1(c); typst signature()): single lines 3.25 in from the margin, kept together
-- ---------------------------------------------------------------------------

-- single lines (an empty item a blank single line), kept together (the last one too with `all`); `before` above
-- the first
local function lines(list, before, left, all)
  local out, gap = {}, before or 0
  for k, l in ipairs(list) do
    if l == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(l, { before = gap, left = left, keep = all or k < #list })
      gap = 0
    end
  end
  return table.concat(out)
end

local function signature(meta)
  local sig = need(meta, "signature")
  local list = { xe.runs("Respectfully submitted,"), "", xe.runs("s/ ") .. xe.inl(need(sig, "signer")),
    xe.inl(need(sig, "signer-name-printed")) }
  for _, l in ipairs(items(need(sig, "lines"))) do list[#list + 1] = xe.inl(l) end
  return lines(list, BLANK, SIG_INDENT)
end

-- ---------------------------------------------------------------------------
-- notice of motion and certificate of service (LBR 9013-1(a)(2), 9013-3; typst certificate()), each kept whole
-- ---------------------------------------------------------------------------

local function certificate(meta)
  local svc = need(meta, "service")
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = head(xe.runs("NOTICE OF MOTION", { b = true }), BLANK)
  out[#out + 1] = p(xe.runs(NOTICE_TEXT), { line = BODY, first = INDENT, lines = true })
  out[#out + 1] = head(xe.runs("CERTIFICATE OF SERVICE", { b = true }), BLANK)
  local cert = pandoc.Inlines({ pandoc.Str("I hereby certify that on ") })
  cert:extend(pandoc.Inlines(need(svc, "date")))
  cert:insert(pandoc.Str(", a true copy of the foregoing "))
  cert:extend(pandoc.Inlines(need(svc, "document")))
  cert:insert(pandoc.Str(" was served "))
  cert:extend(pandoc.Inlines(need(svc, "method-ecf")))
  cert:insert(pandoc.Space())
  cert:extend(pandoc.Inlines(need(svc, "method-mail")))
  out[#out + 1] = p(xe.inl(cert), { line = BODY, first = INDENT, keep = true })
  local ent = {}
  for _, e in ipairs(items(svc.entities)) do ent[#ent + 1] = xe.inl(e) end
  out[#out + 1] = lines(ent, 0, 0, true) -- kept with the signature after them
  out[#out + 1] = lines({ xe.runs("s/ ") .. xe.inl(need(sig, "signer")), xe.inl(need(sig, "signer-name-printed")) },
    BLANK, SIG_INDENT)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- page furniture: the centred page number, its single line ending 0.5 in above the bottom edge (typst footer-foot)
-- ---------------------------------------------------------------------------

local function furniture()
  local field = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText>'
    .. '</w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
  local function write(env, text)
    local path = os.getenv(env)
    if not path or path == "" then return end
    local w = assert(io.open(path, "w"))
    w:write(text)
    w:close()
  end
  write("FORMBOOK_FOOTERS", "rIdOhnbFooter\t" .. p(field, { jc = "center" }) .. "\n")
  write("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdOhnbFooter"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>')
end

-- ---------------------------------------------------------------------------
-- body: headings centred bold (levels 1 and 2 in capitals) on the body pitch, level 1 a blank single line below what
-- precedes it; paragraphs in Body Text; the last paragraph of each part kept with its signature
-- ---------------------------------------------------------------------------

local function part(out, blocks, from, to, meta)
  local last = nil
  for i = from, to do
    local b = blocks[i]
    if b.t == "Para" or b.t == "Plain" then last = i end
  end
  for i = from, to do
    local b = blocks[i]
    if b.t == "Header" then
      local c = b.level <= 2 and upper(b.content) or b.content
      out:insert(xe.raw(head(xe.inl(c, { b = true }), b.level == 1 and BLANK or 0)))
    elseif b.t == "Para" or b.t == "Plain" then
      out:insert(pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = i == last and "Body Text Keep" or "Body Text" }))
    else
      error("ohnb-motion-brief: unsupported block " .. b.t, 0)
    end
  end
  out:insert(xe.raw(signature(meta)))
end

local function finish(doc)
  local meta = doc.meta
  local at = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and pandoc.utils.stringify(b):sub(1, 10) == "MEMORANDUM" then
      at = i
      break
    end
  end
  if at == nil then error("ohnb-motion-brief: the sample needs a '# MEMORANDUM' heading", 0) end

  local out = pandoc.Blocks({})
  out:insert(xe.raw(caption(meta)))
  part(out, doc.blocks, 1, at - 1, meta)
  part(out, doc.blocks, at, #doc.blocks, meta)
  out:insert(xe.raw(certificate(meta)))
  furniture()
  -- The frontmatter was consumed above; pandoc would otherwise write its title block at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind_spaces }, { Pandoc = finish } }

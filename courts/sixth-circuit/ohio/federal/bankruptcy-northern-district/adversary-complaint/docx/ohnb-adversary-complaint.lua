-- N.D. Ohio bankruptcy adversary complaint, docx engine (docs/DOCX.md). Mirrors typst/ohnb-adversary-complaint.typ on
-- the cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch, the spaces between blocks those of the typst template, the break rules of
-- typst on every run. The court lines (centred bold capitals), the caption table (the parties at the left, a column
-- of ")", the case, chapter, judge and adversary numbers at the right; FRBP 9004(b), 7010), the bold centred title,
-- the body (headings centred bold capitals; paragraphs double spaced with a 0.5 in first-line indent), the last
-- chunk kept with the signature block (LBR 5005-1(c)), single-spaced from the middle of the line. The footer (the
-- centred page number) and the section are the filter's ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL). Nothing case-specific
-- is written here: every string comes from the sample's YAML frontmatter.
local xe = require("docx.xengine")

local BODY, SINGLE, BLANK = 480, 276, 276  -- typst pitch-body 24 pt, pitch-single 13.8 pt, blank 13.8 pt
local CAP_W = { 5040, 432, 3888 }          -- typst cap-left 3.5 in, cap-mid 0.3 in, cap-right 2.7 in
local SIG_INDENT = 4680                    -- typst sig-indent 3.25 in

local function need(meta, key)
  if meta[key] == nil then error("ohnb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
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

-- A paragraph: o = { before, line, left, jc, keep, b }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Break opportunities as typst has them (UAX #14): none inside a token of adjacent parentheses ("157(b)(2)(A)"): a word
-- joiner between ")" and "("; one after a slash before a letter ("and/or"), where LibreOffice keeps the word whole: a
-- zero-width space after it. Neither shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break after a doubled sign ("§§ 1107(a)"; typst boxes the token): the space becomes a no-break space.
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

  local left = {}
  for _, d in ipairs(items(need(meta, "debtor-caption"))) do left[#left + 1] = xe.inl(d) end
  for _, s in ipairs({ "", "Debtor.", "", "____________________________________", "" }) do
    left[#left + 1] = s == "" and "" or xe.runs(s)
  end
  for _, x in ipairs(items(need(meta, "plaintiffs"))) do left[#left + 1] = xe.inl(upper(x)) end
  for _, s in ipairs({ "Plaintiff,", "", "v.", "" }) do left[#left + 1] = s == "" and "" or xe.runs(s) end
  for _, x in ipairs(items(need(meta, "defendants"))) do left[#left + 1] = xe.inl(upper(x)) end
  left[#left + 1] = xe.runs("Defendant.")

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
-- signature block (LBR 5005-1(c); typst signature()): single lines 3.25 in from the margin, kept together
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local list = { xe.runs("Respectfully submitted,"), "", xe.runs("s/ ") .. xe.inl(need(sig, "signer")),
    xe.inl(need(sig, "signer-name-printed")) }
  for _, l in ipairs(items(need(sig, "lines"))) do list[#list + 1] = xe.inl(l) end
  local out, gap = {}, BLANK
  for k, l in ipairs(list) do
    if l == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(l, { before = gap, left = SIG_INDENT, keep = k < #list })
      gap = 0
    end
  end
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
-- body: headings centred bold capitals on the body pitch, kept with the next block; paragraphs in Body Text, the
-- last one kept with the signature
-- ---------------------------------------------------------------------------

local function finish(doc)
  local meta = doc.meta
  local out = pandoc.Blocks({})
  out:insert(xe.raw(caption(meta)))
  local last = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" then last = i end
  end
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local c = b.level <= 2 and upper(b.content) or b.content
      out:insert(xe.raw(p(xe.inl(c, { b = true }), { line = BODY, keep = true, jc = "center" })))
    elseif b.t == "Para" or b.t == "Plain" then
      out:insert(pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = i == last and "Body Text Keep" or "Body Text" }))
    else
      error("ohnb-adversary-complaint: unsupported block " .. b.t, 0)
    end
  end
  out:insert(xe.raw(signature(meta)))
  furniture()
  -- The frontmatter was consumed above; pandoc would otherwise write its title block at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind_spaces }, { Pandoc = finish } }

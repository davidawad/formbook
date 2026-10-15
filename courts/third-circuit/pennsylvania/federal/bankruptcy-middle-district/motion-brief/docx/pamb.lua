-- pamb (U.S. Bankruptcy Court, M.D. Pa.) DOCX engine: the markdown contract -> a Word document on reference.docx.
-- Builds, from the sample's frontmatter, what typst/pamb-<kind>.typ builds: the court title, the caption (a
-- borderless table with the rule and the vertical line), the title, the Statement of Jurisdiction (adversary), the
-- signature block, the certificate of service and the word-count certificate (motion). The body keeps its markdown
-- structure; allegations are numbered by hand (number, tab, text) so the numbers sit where the template puts them;
-- brief headings get their I., A., 1., a. labels. Page numbers come from the footer of reference.docx.
-- Known limits (BLOCKED, see the README "Engines" section): no page count check (the typst template stops a brief
-- over 15 pages; the docx cannot be counted here), no TOC or TOA, and the caption and signature text is plain
-- (no markdown inside those cells).

local CFG = { kind = "motion" } -- this copy: "motion"; the adversary-complaint copy sets "adversary"
local ADV = CFG.kind == "adversary"
local LINE = 480                    -- 24 pt, twips (the typst line pitch)

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- plain text as inlines, spaces kept (a literal string from this file)
local function S(s)
  local out = pandoc.Inlines({})
  local words = {}
  for w in s:gmatch("%S+") do words[#words + 1] = w end
  if s:match("^%s") then out:insert(pandoc.Space()) end
  for i, w in ipairs(words) do
    if i > 1 then out:insert(pandoc.Space()) end
    out:insert(pandoc.Str(w))
  end
  if s:match("%s$") and #words > 0 then out:insert(pandoc.Space()) end
  return out
end

-- a metadata value as inlines (markdown kept: italics etc.)
local function inl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "table" and v.t == "MetaInlines" then return pandoc.Inlines(v) end
  return S(pandoc.utils.stringify(v))
end

-- a metadata value as plain text (for the raw XML cells)
local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- concatenate inline pieces; a Lua string is literal text
local function cat(...)
  local out = pandoc.Inlines({})
  for _, part in ipairs({ ... }) do
    if type(part) == "string" then part = S(part) end
    for _, x in ipairs(part) do out:insert(x) end
  end
  return out
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para(inlines)
  return pandoc.Para(inlines)
end

local function raw_block(xml) return pandoc.RawBlock("openxml", xml) end
local function tab() return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") end

-- an empty paragraph of an exact height (twips), for the typst v() gaps
local function gap(twips)
  return raw_block('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

local function page_break()
  return raw_block('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- ---------------------------------------------------------------------------
-- raw WordprocessingML for the two-column cells (caption, signature grid)
-- ---------------------------------------------------------------------------

local function run(text, bold, under)
  local rpr = (bold and "<w:b/><w:bCs/>" or "") .. (under and '<w:u w:val="single"/>' or "")
  return "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "") ..
    '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- one single-spaced paragraph; o: keep, border (bottom rule), before, after, left (twips), jc, runs (xml)
local function xpara(text, o)
  o = o or {}
  local p = {}
  if o.keep then p[#p + 1] = "<w:keepNext/>" end
  if o.border then p[#p + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>' end
  p[#p + 1] = string.format('<w:spacing w:before="%d" w:after="%d" w:line="240" w:lineRule="auto"/>', o.before or 0, o.after or 0)
  p[#p + 1] = string.format('<w:ind w:left="%d" w:firstLine="0"/>', o.left or 0)
  if o.jc then p[#p + 1] = '<w:jc w:val="' .. o.jc .. '"/>' end
  local body = o.runs or run(text or "", o.bold, o.under)
  return "<w:p><w:pPr>" .. table.concat(p) .. "</w:pPr>" .. body .. "</w:p>"
end

-- a two-column table with no borders (sig grid), or the caption table (rule right and bottom of the left cell)
local function xgrid(left, right, caption)
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
  local lb = caption and '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' or none
  local wl = caption and 4680 or 4752
  local wr = caption and 4680 or 4608
  local lm = caption and '<w:tcMar><w:right w:w="312" w:type="dxa"/></w:tcMar>' or ""
  local rm = caption and '<w:tcMar><w:left w:w="312" w:type="dxa"/></w:tcMar>' or ""
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>' .. none ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/><w:tblLook w:val="0000"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. wl .. '"/><w:gridCol w:w="' .. wr .. '"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. wl .. '" w:type="dxa"/><w:tcBorders>' .. lb .. "</w:tcBorders>" .. lm .. "</w:tcPr>" .. left .. "</w:tc>" ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. wr .. '" w:type="dxa"/>' .. rm .. "</w:tcPr>" .. right .. "</w:tc>" ..
    "</w:tr></w:tbl>"
end

local function caption_xml(m)
  local d = m.debtor
  local L, R = {}, {}
  L[#L + 1] = xpara("IN RE:", { after = 240 })
  local names = d.name
  for i, n in ipairs(names) do
    L[#L + 1] = xpara(plain(n), { left = 720, after = (i == #names) and 240 or 0 })
  end
  L[#L + 1] = xpara("", { border = true, after = 240 })
  if ADV then
    local sides = m.caption
    for si, side in ipairs(sides) do
      for _, n in ipairs(side.names) do L[#L + 1] = xpara(plain(n)) end
      L[#L + 1] = xpara(plain(side.designation), { left = 2592, after = (si < #sides) and 240 or 0 })
      if si < #sides then L[#L + 1] = xpara("v.", { jc = "center", after = 240 }) end
    end
  else
    L[#L + 1] = xpara("Debtor")
  end
  R[#R + 1] = xpara(plain(d.chapter), { after = 240 })
  R[#R + 1] = xpara("Case No. " .. plain(d.case_number), { after = 240 })
  if ADV then
    local adv = plain(m.adversary_number)
    if adv == "" then
      R[#R + 1] = xpara("", { runs = run("Adversary No. ") .. run(string.rep("\u{00A0}", 30), false, true) })
    else
      R[#R + 1] = xpara("Adversary No. " .. adv)
    end
  end
  return xgrid(table.concat(L), table.concat(R), true)
end

-- signature block (right column of a grid, 3.3 in in); the left column gets "Dated" or the certificate date
local function sig_right(lines)
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = xpara(l.text, { keep = i < #lines, before = l.before or 0, left = 0 })
  end
  return table.concat(out)
end

local function signature_xml(m)
  local sig = m.signature
  local signer = plain(sig.signer)
  local lines = {}
  if ADV then
    lines[#lines + 1] = { text = "Respectfully submitted," }
    lines[#lines + 1] = { text = plain(sig.firm), before = 480 }
    lines[#lines + 1] = { text = "/s/ " .. signer, before = 480 }
    lines[#lines + 1] = { text = signer }
    if sig.id then lines[#lines + 1] = { text = plain(sig.id) } end
  else
    lines[#lines + 1] = { text = "Respectfully Submitted," }
    lines[#lines + 1] = { text = "By: /s/ " .. signer, before = 480 }
  end
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { text = plain(l) } end
  local left = ""
  if ADV and m.date then left = xpara("Dated: " .. plain(m.date), { keep = true }) end
  return xgrid(left, sig_right(lines), false)
end

-- ---------------------------------------------------------------------------
-- body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

-- headings get their labels (motion); ordered lists become numbered paragraphs (adversary and motion)
local function transform(blocks, number_heads)
  local res, hc = {}, { 0, 0, 0, 0 }
  for _, b in ipairs(blocks) do
    if b.t == "Header" and number_heads then
      local L = math.min(b.level, 4)
      hc[L] = hc[L] + 1
      for k = L + 1, 4 do hc[k] = 0 end
      local lab
      if L == 1 then lab = roman(hc[1]) .. "."
      elseif L == 2 then lab = string.char(64 + hc[2]) .. "."
      elseif L == 3 then lab = hc[3] .. "."
      else lab = string.char(96 + hc[4]) .. "." end
      local c = pandoc.Inlines({ pandoc.Str(lab), tab() })
      for _, x in ipairs(b.content) do c:insert(x) end
      res[#res + 1] = pandoc.Header(b.level, c, b.attr)
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local num = b.start + i - 1
        local bl = {}
        for _, x in ipairs(item) do bl[#bl + 1] = x end
        local first = bl[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local c = pandoc.Inlines({ pandoc.Str(num .. "."), tab() })
          for _, x in ipairs(first.content) do c:insert(x) end
          bl[1] = pandoc.Para(c)
        else
          table.insert(bl, 1, pandoc.Para({ pandoc.Str(num .. "."), tab() }))
        end
        for k, x in ipairs(bl) do
          if x.t == "Plain" then bl[k] = pandoc.Para(x.content) end
        end
        res[#res + 1] = pandoc.Div(bl, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" }))
      end
    else
      res[#res + 1] = b
    end
  end
  return res
end

local function need(m, k)
  if m[k] == nil then error("pamb: missing required metadata field `" .. k .. "`", 0) end
  return m[k]
end

local function court_title(m, first_page)
  local out = {}
  for _, line in ipairs(need(m, "court")) do
    out[#out + 1] = styled(first_page and "Court Title Page" or "Court Title", inl(line))
    first_page = false
  end
  return out
end

-- ---------------------------------------------------------------------------
-- the document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(list) for _, b in ipairs(list) do out[#out + 1] = b end end

  -- ---- first page: court, caption, title (typst: court-title, caption-table, title) ----
  need(m, "debtor")
  if ADV then need(m, "caption") end
  addall(court_title(m, false))
  add(gap(LINE))
  add(raw_block(caption_xml(m)))
  add(gap(LINE))
  add(styled("Caption Title", inl(need(m, "title"))))

  -- ---- adversary: the Statement of Jurisdiction (FRBP 7008(a)) ----
  if ADV then
    local j = need(m, "jurisdiction")
    local d = need(m, "debtor")
    add(styled("Centered Bold", S("Statement of Jurisdiction")))
    add(para(cat("This adversary proceeding arises in and relates to the ", inl(d.chapter), " case of ",
      inl(d.name[1]), ", Case No. ", plain(d.case_number), ", pending in the United States Bankruptcy Court for the ",
      inl(j.district), ".")))
    add(para(inl(need(j, "core"))))
    add(para(inl(need(j, "consent"))))
  end

  -- ---- the body; the last paragraph (the prayer) stays with the signature ----
  local body = transform(doc.blocks, not ADV)
  local last = body[#body]
  if last and (last.t == "Para" or last.t == "Plain") then
    body[#body] = pandoc.Div({ pandoc.Para(last.content) }, pandoc.Attr("", {}, { ["custom-style"] = "Prayer" }))
  end
  addall(body)

  -- ---- signature block (typst: signature-block) ----
  add(gap(LINE))
  add(raw_block(signature_xml(m)))

  -- ---- motion: certificate of service (L.B.R. 9013-3) and word-count certificate (L.B.R. 9013-2(b)) ----
  if not ADV then
    local cos = need(m, "certificate_of_service")
    addall(court_title(m, true))
    add(gap(LINE))
    add(raw_block(caption_xml(m)))
    add(gap(LINE))
    add(styled("Centered Bold", S("Certificate of Service")))
    add(para(cat("The undersigned certifies that on ", plain(cos.date), ", the undersigned caused a true and correct copy of ",
      inl(need(m, "title")), " to be served ", plain(cos.method), ", on the following persons:")))
    for _, s in ipairs(cos.served) do
      add(styled("Served Line", inl(s.name)))
      add(styled("Served Line", inl(s.address)))
      add(styled("Served Last", cat("Represents: ", inl(s.represents))))
    end
    local signer = plain(cos.signer)
    add(gap(LINE))
    add(raw_block(xgrid(xpara("Date: " .. plain(cos.date), { keep = true }),
      sig_right({ { text = "/s/ " .. signer }, { text = signer } }), false)))

    local n = m.word_count
    if n ~= nil then
      add(styled("Centered Bold Page", S("Certificate of Compliance with Word-Count Limit")))
      add(para(cat("The undersigned certifies that this brief contains ", plain(n),
        " words, as counted by the word-processing system used to prepare it, and complies with the 5,000-word limit of L.B.R. 9013-2(b).")))
      add(gap(LINE))
      add(raw_block(xgrid("", sig_right({ { text = "/s/ " .. plain(need(m, "signature").signer) },
        { text = plain(need(m, "signature").signer) } }), false)))
    end
  end

  doc.blocks = out
  -- the title, date and the rest of the frontmatter are printed above (or are not printed); pandoc must not add a title block
  doc.meta = pandoc.Meta({})
  return doc
end

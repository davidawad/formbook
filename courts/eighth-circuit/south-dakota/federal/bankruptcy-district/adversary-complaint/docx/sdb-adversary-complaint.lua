-- Adversary complaint for the United States Bankruptcy Court, District of South Dakota (sdb), docx engine: what the
-- Word output adds to pandoc's conversion, so that it reads and breaks as typst/sdb-adversary-complaint.typ does:
-- the court name and the ")" caption (Bankr. D.S.D. R. 9004-2(a), 7010-2; FRBP 7010, Form 416D), the title, the
-- lead-in, the numbered allegations (FRCP 10(b)), the headings, the prayer items and the signature block
-- (R. 9004-1(a)(5)). Everything printed comes from the sample's frontmatter and body: no case text lives in this
-- file. The caption is an OOXML table, one row per line.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 276, the single-spaced 13.8 pt line), the spaces between
-- blocks those of the typst template (240 a paragraph gap, 360 the section gap), and the break rules of typst on
-- every run.

local xe = require("docx.xengine")

local LINE = 276                         -- typst pitch-single, 13.8 pt
local PARA_GAP, SECTION_GAP = 240, 360   -- typst para-gap 12 pt, section-gap 18 pt
local LABEL = 720                        -- typst label-box, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAD, CAP_PAREN = 4752, 288, 432 -- typst caption-left 3.3 in, caption-pad 0.2 in, caption-paren 0.3 in
local SIG_INDENT = 4680                  -- typst sig-indent, 3.25 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, left, hanging, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, LINE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- ---------------------------------------------------------------------------
-- Caption: court name, then one table row per line (party, ")" mark, numbers), as the typst grid
-- ---------------------------------------------------------------------------

local function caption(meta)
  local rows = {}
  local function row(l, r, jc) rows[#rows + 1] = { l or "", r or "", jc } end
  -- Rule 9004-2(a)(1)-(5): full debtor name, EIN, last four of SSN/TIN, names used (aka / fka)
  row(xe.runs("In re:"), xe.runs("Bankr. No. " .. plain(meta.bankr_no)))
  row("", xe.runs("Chapter " .. plain(meta.chapter)))
  row("", "")
  for _, d in ipairs(meta.debtors) do
    row(xe.inl(d.name), "")
    if d.ssn_last4 then row(xe.runs("SSN xxx-xx-" .. plain(d.ssn_last4)), "") end
    if d.ein then row(xe.runs("EIN " .. plain(d.ein)), "") end
    if d.tin_last4 then row(xe.runs("TIN xx-xxx" .. plain(d.tin_last4)), "") end
    for _, a in ipairs(d.aka or {}) do row(xe.runs("aka " .. plain(a)), "") end
    for _, a in ipairs(d.fka or {}) do row(xe.runs("fka " .. plain(a)), "") end
    row("", "")
  end
  row(xe.runs(#meta.debtors > 1 and "Debtors." or "Debtor."), "", "right")
  row("", "")
  -- Plaintiffs, then the adversary number on the first plaintiff row (Form 416D)
  local adv_done = false
  for _, pl in ipairs(meta.plaintiffs) do
    for _, n in ipairs(pl.names) do
      if not adv_done then
        row(xe.inl(n), xe.runs("Adv. No. " .. plain(meta.adversary_no)))
        adv_done = true
      else
        row(xe.inl(n), "")
      end
    end
    row(xe.inl(pl.designation), "", "right")
    row("", "")
  end
  row(xe.runs("v."), "")
  row("", "")
  for _, df in ipairs(meta.defendants) do
    for _, n in ipairs(df.names) do row(xe.inl(n), "") end
    row(xe.inl(df.designation), "", "right")
  end

  local widths = { CAP_LEFT, CAP_PAREN, TEXTW - CAP_LEFT - CAP_PAREN }
  local trs = {}
  for _, r in ipairs(rows) do
    trs[#trs + 1] = '<w:tr>' ..
      '<w:tc><w:tcPr><w:tcW w:w="' .. widths[1] .. '" w:type="dxa"/><w:tcMar><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar></w:tcPr>' .. p(r[1], { jc = r[3] }) .. '</w:tc>' ..
      '<w:tc><w:tcPr><w:tcW w:w="' .. widths[2] .. '" w:type="dxa"/></w:tcPr>' .. p(xe.runs(")")) .. '</w:tc>' ..
      '<w:tc><w:tcPr><w:tcW w:w="' .. widths[3] .. '" w:type="dxa"/></w:tcPr>' .. p(r[2]) .. '</w:tc></w:tr>'
  end
  local out = {
    p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }),
    -- typst: the caption grid stands a section gap below the court name and above the title
    p(xe.runs("DISTRICT OF SOUTH DAKOTA", { b = true }), { jc = "center", after = SECTION_GAP }),
    '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
      '<w:gridCol w:w="' .. widths[1] .. '"/><w:gridCol w:w="' .. widths[2] .. '"/><w:gridCol w:w="' .. widths[3] ..
      '"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>',
  }
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: one centered bold line at the single pitch, a section gap above and a paragraph gap below, as written
-- (the Heading 1 style's capitals off); kept with the text after them.
local function heading(content, level)
  local runs = xe.inl(content, { b = true })
  runs = runs:gsub("<w:r>(<w:[^r])", "<w:r><w:rPr></w:rPr>%1")
  runs = runs:gsub("<w:rPr>(.-)</w:rPr>", function(x)
    local at = x:find("<w:sz", 1, true) or x:find("<w:u ", 1, true) or x:find("<w:bdr", 1, true) or (#x + 1)
    return "<w:rPr>" .. x:sub(1, at - 1) .. '<w:caps w:val="0"/>' .. x:sub(at) .. "</w:rPr>"
  end)
  return xe.para({ xe.style("Heading" .. math.min(level, 5)), xe.KEEP, xe.spacing(SECTION_GAP, PARA_GAP, LINE),
    xe.ind(0, nil, 0), xe.jc("center") }, runs)
end

-- A paragraph whose label stands in a box of LABEL at `left` (a tab to the hanging indent), the text hanging after it.
local function labeled(label, body, left, keep)
  return p(xe.runs(label .. "\t") .. body, { left = left + LABEL, hanging = LABEL, before = PARA_GAP,
    after = PARA_GAP, keep = keep })
end

-- An unnumbered paragraph (the lead-in, the WHEREFORE clause): first line indented by LABEL.
local function indented(body, keep)
  return p(body, { first = LABEL, before = PARA_GAP, after = PARA_GAP, keep = keep })
end

-- The signature block: "DATED <date>." at the left, the signer and firm lines at the middle of the page; one block
-- (typst: an unbreakable block a section gap below the text).
local function signature(sig)
  local out = { p(xe.runs("DATED ") .. xe.inl(sig.date) .. xe.runs("."), { before = SECTION_GAP, keep = true }) }
  local lines = { xe.runs("/s/ ") .. xe.inl(sig.signer), xe.inl(sig.signer) }
  for _, l in ipairs(sig.firm or {}) do lines[#lines + 1] = xe.inl(l) end
  lines[#lines + 1] = xe.inl(sig.role)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { left = SIG_INDENT, before = i == 1 and SECTION_GAP or 0, keep = i < #lines })
  end
  return out
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A section sign or pilcrow written against the word before it ("USC§ 523"): typst sets "§ 523" as one box, which
-- may start a line, so the sign takes a zero-width space before it and a no-break space after it.
local function signs(l)
  for i = 1, #l - 1 do
    local a, b = l[i], l[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local pre, sign = a.text:match("^(.-[^%s])(\u{00A7})$")
      if not pre then pre, sign = a.text:match("^(.-[^%s])(\u{00B6})$") end
      if pre then
        l[i] = pandoc.Str(pre .. "\u{200B}" .. sign)
        l[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return l
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  assert(meta.debtors and #meta.debtors > 0, "R. 9004-2(a): the caption needs at least one debtor")
  for _, d in ipairs(meta.debtors) do
    assert(d.ssn_last4 or d.ein or d.tin_last4,
      "R. 9004-2(a)(2)-(4): each debtor needs an EIN, the last four of an SSN, or the last four of a TIN: " .. plain(d.name))
  end

  local out = caption(meta)
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = SECTION_GAP, after = SECTION_GAP })
  if meta.lead_in then out[#out + 1] = indented(xe.inl(meta.lead_in)) end

  -- Every paragraph is numbered from 1 (FRCP 10(b)), except after a PRAYER heading; the last paragraph or prayer
  -- item stays with the signature block.
  local n, numbered = 0, true
  local blocks = doc.blocks
  for bi, b in ipairs(blocks) do
    local last = bi == #blocks
    if b.t == "Header" then
      numbered = not pandoc.utils.stringify(b.content):find("PRAYER", 1, true)
      out[#out + 1] = heading(b.content, b.level)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and ((start + i - 1) .. ".") or "\u{2022}"
        local inl = {}
        for _, blk in ipairs(item) do inl[#inl + 1] = xe.inl(blk.content) end
        out[#out + 1] = labeled(lab, table.concat(inl, xe.runs(" ")), LABEL, last and i == #b.content)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if numbered then
        n = n + 1
        out[#out + 1] = labeled(n .. ".", xe.inl(b.content), 0, last)
      else
        out[#out + 1] = indented(xe.inl(b.content), last)
      end
    else
      error("sdb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  for _, s in ipairs(signature(meta.signature)) do out[#out + 1] = s end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

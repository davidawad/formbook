-- D. Utah motion to dismiss with memorandum, DOCX engine (docs/DOCX.md). The form is ../typst/utd-motion-brief.typ,
-- carried by reference.docx (styles, footer, page size and margins; built by build-reference.sh). This filter adds
-- what the markdown cannot say: the cover (counsel block, court title, caption with the judge), the heading labels
-- ("I.", "A."), the lists (numbered "1.", bulleted), the table of contents and table of authorities, the page breaks
-- before the contents and before the memorandum, and the signature block. No case text is in this file: every
-- string comes from the frontmatter or the body.
-- Known limits (BLOCKED, see the PR): the table of contents and table of authorities list the headings and the
-- authorities WITHOUT page numbers (a TOC field and TA/TOA fields need a field update, and LibreOffice does not
-- honor TA/TOA fields; the page numbers cannot be cached without a rendered layout). The caption and signature are
-- Word tables (borders and row heights differ slightly between Word and LibreOffice).

local function fail(msg) error("utd-motion-brief: " .. msg, 0) end

local function need(meta, key)
  if meta[key] == nil then fail("missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function xesc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local PAGE_BREAK = pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
local SPACER = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="520"/></w:pPr></w:p>')
local HALF = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="260"/></w:pPr></w:p>')

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- a plain paragraph as WordprocessingML (inside the cover, contents and signature tables)
local function xpara(s, style, ppr_extra, bold, italic)
  local rpr = ""
  if bold or italic then rpr = "<w:rPr>" .. (bold and "<w:b/><w:bCs/>" or "") .. (italic and "<w:i/><w:iCs/>" or "") .. "</w:rPr>" end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or '') .. '</w:pPr>'
    .. (s ~= "" and ('<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. xesc(s) .. '</w:t></w:r>') or '') .. '</w:p>'
end

local function borderless_table(widths, cells)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local tcs = {}
  for i, c in ipairs(cells) do
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. c.tcpr .. '</w:tcPr>' .. c.body .. '</w:tc>'
  end
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblW w:w="' .. (widths[1] + widths[2]) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. table.concat(tcs) .. '</w:tr></w:tbl>')
end

-- Caption (typst: caption-table()): parties on the left, the designation indented 1.8 in, a rule on the right and
-- the bottom; case number, title and judges on the right.
local function caption(meta)
  local sides = need(meta, "caption")
  local left = {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do left[#left + 1] = xpara(text(n), "Single") end
    left[#left + 1] = xpara(text(side.designation), "Single", '<w:ind w:left="2592"/>')
    if i < #sides then left[#left + 1] = xpara("v.", "Centered", '<w:spacing w:before="260" w:after="260"/>') end
  end
  local right = { xpara("Case No. " .. text(need(meta, "case_number")), "Single") }
  right[#right + 1] = xpara(string.upper(text(need(meta, "brief_title"))), "Single", '<w:spacing w:before="260"/>', true)
  if meta.judge ~= nil then right[#right + 1] = xpara("Judge " .. text(meta.judge), "Single", '<w:spacing w:before="260"/>') end
  if meta.magistrate ~= nil then right[#right + 1] = xpara("Magistrate Judge " .. text(meta.magistrate), "Single") end
  return borderless_table({ 5460, 3900 }, {
    {
      tcpr = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
        .. '<w:tcMar><w:right w:w="312" w:type="dxa"/><w:bottom w:w="260" w:type="dxa"/></w:tcMar>',
      body = table.concat(left),
    },
    {
      tcpr = '<w:tcMar><w:left w:w="312" w:type="dxa"/><w:top w:w="60" w:type="dxa"/></w:tcMar>',
      body = table.concat(right),
    },
  })
end

-- Cover (typst: cover()): counsel block at the upper left (the role in italics), the court title, the caption.
-- No page break after it: the motion starts on the first page.
local function cover(meta)
  local out = {}
  for _, l in ipairs(need(meta, "counsel")) do out[#out + 1] = styled("Single", { pandoc.Str(text(l)) }) end
  out[#out + 1] = styled("Single", { pandoc.Emph({ pandoc.Str(text(need(meta, "counsel_role"))) }) })
  out[#out + 1] = HALF
  for _, l in ipairs(need(meta, "court")) do
    out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str(string.upper(text(l))) }) }) },
      pandoc.Attr("", {}, { ["custom-style"] = "Centered" }))
  end
  out[#out + 1] = HALF
  out[#out + 1] = caption(meta)
  return out
end

-- Signature (typst: signature-block()): "DATED:" and the date at left; the firm, "/s/", the signer and the lines at right.
local function signature(meta)
  local sig = need(meta, "signature")
  local left = { xpara("DATED: " .. text(need(meta, "date")), "Single") }
  local right = {}
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = xpara(text(l), "Single") end
  right[#right + 1] = xpara("/s/ " .. text(sig.signer), "Single", '<w:spacing w:before="260"/>')
  right[#right + 1] = xpara(text(sig.signer), "Single")
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = xpara(text(l), "Single") end
  return borderless_table({ 4752, 4608 }, {
    { tcpr = '', body = table.concat(left) },
    { tcpr = '', body = table.concat(right) },
  })
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

local function heading_label(level, c)
  if level == 2 then return roman(c[2]) .. "." end
  if level == 3 then return string.char(64 + c[3]) .. "." end
  if level == 4 then return tostring(c[4]) .. "." end
  return ""
end

local function hanging(label, blocks)
  local out = {}
  for i, b in ipairs(blocks) do
    if (b.t == "Para" or b.t == "Plain") and i == 1 then
      local inl = { pandoc.Str(label), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = styled("Hanging", inl)
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- Table of contents (typst: toc-section()): a TOC field whose cached result is the heading list. Page numbers are
-- not cached (BLOCKED, see the header): they need a field update in Word or LibreOffice.
local function toc_xml(entries)
  local ps = {}
  for i, e in ipairs(entries) do
    local runs = ""
    if i == 1 then
      runs = runs .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    if e.label ~= "" then runs = runs .. '<w:r><w:t xml:space="preserve">' .. xesc(e.label) .. '</w:t></w:r><w:r><w:tab/></w:r>' end
    runs = runs .. '<w:r><w:t xml:space="preserve">' .. xesc(e.text) .. '</w:t></w:r>'
    if i == #entries then runs = runs .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    ps[#ps + 1] = '<w:p><w:pPr><w:pStyle w:val="' .. e.style .. '"/></w:pPr>' .. runs .. '</w:p>'
  end
  return table.concat(ps)
end

local function toc_block(entries)
  local head = '<w:p><w:pPr><w:pStyle w:val="Centered"/></w:pPr><w:r><w:rPr><w:b/><w:bCs/></w:rPr><w:t>TABLE OF CONTENTS</w:t></w:r></w:p>'
  local spacer = '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="260"/></w:pPr></w:p>'
  return pandoc.RawBlock("openxml", head .. spacer .. toc_xml(entries))
end

local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

-- Table of authorities (typst: toa-section()): the authorities linked in the body, grouped by kind, sorted by name.
-- No page numbers (BLOCKED, see the header).
local function toa_block(authorities, used)
  local out = {}
  out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="Centered"/></w:pPr><w:r><w:rPr><w:b/><w:bCs/></w:rPr><w:t>TABLE OF AUTHORITIES</w:t></w:r></w:p>'
  out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="260"/></w:pPr></w:p>'
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for _, key in ipairs(used) do
      local a = authorities[key]
      if a ~= nil and text(a.kind) == g[1] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      return string.lower(text(x.a.name ~= nil and x.a.name or x.a.cite)) < string.lower(text(y.a.name ~= nil and y.a.name or y.a.cite))
    end)
    if #members > 0 then
      out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="TOAGroup"/></w:pPr><w:r><w:t>' .. xesc(g[2]) .. '</w:t></w:r></w:p>'
      for _, m in ipairs(members) do
        local runs = ""
        if m.a.name ~= nil then
          local nm = xesc(text(m.a.name))
          if g[1] == "case" then
            runs = runs .. '<w:r><w:rPr><w:i/><w:iCs/></w:rPr><w:t xml:space="preserve">' .. nm .. '</w:t></w:r>'
          else
            runs = runs .. '<w:r><w:t xml:space="preserve">' .. nm .. '</w:t></w:r>'
          end
          runs = runs .. '<w:r><w:t xml:space="preserve">, </w:t></w:r>'
        end
        runs = runs .. '<w:r><w:t xml:space="preserve">' .. xesc(text(m.a.cite)) .. '</w:t></w:r>'
        out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="TOAEntry"/></w:pPr>' .. runs .. '</w:p>'
      end
    end
  end
  return pandoc.RawBlock("openxml", table.concat(out))
end

local function is_list(b)
  return b ~= nil and (b.t == "OrderedList" or b.t == "BulletList")
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "counsel", "counsel_role", "brief_title", "signature", "date" }) do
    need(meta, k)
  end
  local authorities = meta.authorities or {}

  -- Authority links (toa:KEY): record the keys in document order, then keep the link text only.
  local used, seen = {}, {}
  doc = doc:walk({
    Link = function(el)
      if el.target:match("^toa:") then
        local key = el.target:sub(5)
        if authorities[key] == nil then fail("link `" .. el.target .. "` has no entry under `authorities:`") end
        if not seen[key] then seen[key] = true; used[#used + 1] = key end
        return el.content
      end
      return nil
    end,
  })

  -- The memorandum must start the body (typst: split at `# MEMORANDUM OF LAW`).
  local memo_at = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and string.upper(text(b.content)) == "MEMORANDUM OF LAW" then memo_at = i end
  end
  if memo_at == nil then fail("the body needs a `# MEMORANDUM OF LAW` heading (DUCivR 7-1(a)(1)(B))") end

  -- Pass 1: heading labels and the table of contents entries.
  local c = { 0, 0, 0, 0 }
  local labels, entries = {}, {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lv = b.level
      if lv == 1 then c = { 0, 0, 0, 0 } end
      if lv >= 2 and lv <= 4 then
        c[lv] = c[lv] + 1
        for j = lv + 1, 4 do c[j] = 0 end
        labels[i] = heading_label(lv, c)
      else
        labels[i] = ""
      end
      local t = text(b.content)
      local style = (lv == 1) and "TOCEntry1" or ((lv == 2) and "TOCEntry2" or "TOCEntry3")
      entries[#entries + 1] = {
        level = lv, label = labels[i], style = style,
        text = (lv == 1) and string.upper(t) or t,
      }
    end
  end

  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end

  -- Pass 2: the motion, the contents, the memorandum, the signature.
  for i, b in ipairs(doc.blocks) do
    if i == memo_at then
      out[#out + 1] = PAGE_BREAK
      out[#out + 1] = toc_block(entries)
      out[#out + 1] = PAGE_BREAK
      out[#out + 1] = toa_block(authorities, used)
      out[#out + 1] = PAGE_BREAK
    end
    if b.t == "Header" then
      local content = b.content
      if labels[i] ~= "" then
        local inl = { pandoc.Str(labels[i]), TAB }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        content = inl
      end
      out[#out + 1] = pandoc.Header(b.level, content, b.attr)
    elseif b.t == "OrderedList" then
      for i2, item in ipairs(b.content) do
        for _, x in ipairs(hanging(tostring(i2) .. ".", item)) do out[#out + 1] = x end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, x in ipairs(hanging("\u{2022}", item)) do out[#out + 1] = x end
      end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.Para({})
  out[#out + 1] = signature(meta)

  -- the cover is built here: pandoc must not print the title or date from the metadata again
  local m = pandoc.Meta({})
  for k, v in pairs(meta) do
    if k ~= "title" and k ~= "date" then m[k] = v end
  end
  return pandoc.Pandoc(out, m)
end

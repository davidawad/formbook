-- U.S. District Court for the District of Hawaii: motion with memorandum in support, docx engine (pandoc filter).
-- The same markdown contract as typst/hid-motion-brief.typ, for the parts a docx can carry: the caption (counsel
-- block, court title, caption box with "Judge:"), the motion paragraphs and signature, the memorandum's
-- headings numbered I. / A. / 1. (written here), the body and footnotes (pandoc's), the signature at its end and
-- the certificate of service. NOT produced: the table of contents and the table of authorities (BLOCKED, see
-- README.md "Engines"), the certificate of compliance (LR 7.4(e)), and the typst roman/arabic page numbering.
-- Styles come from reference.docx (make-reference.sh). Not rendered on the build box (no LibreOffice).

local COURT = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF HAWAII" }
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function sval(m)
  if m == nil then return "" end
  return pandoc.utils.stringify(m)
end

-- One WordprocessingML paragraph: style id, extra pPr children (after pStyle), run properties.
local function rp(text, style, ppr_extra, rpr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or "") .. '</w:pPr><w:r>'
    .. (rpr or "") .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r></w:p>'
end

local BOLD = "<w:rPr><w:b/></w:rPr>"
local ITALIC = "<w:rPr><w:i/></w:rPr>"
local RIGHT = '<w:jc w:val="right"/>'
local PAGE_BREAK = "<w:pageBreakBefore/>"

-- A one-row table: cols = { {w=twips, paras=xml, borders=xml}, ... }; cell margin in twips.
local function tbl(cols, margin)
  local grid, cells = {}, {}
  for _, c in ipairs(cols) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c.w .. '" />'
    cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.w .. '" w:type="dxa" />' .. (c.borders or "")
      .. '</w:tcPr>' .. c.paras .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" /><w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:left w:w="' .. margin .. '" w:type="dxa" /><w:right w:w="' .. margin .. '" w:type="dxa" /></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" /></w:tblPr><w:tblGrid>' .. table.concat(grid)
    .. '</w:tblGrid><w:tr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

local function caption(meta)
  local out = {}
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end

  -- LR 10.2(b): counsel, upper left, single-spaced, in columns.
  if meta.counsel and meta.counsel.columns then
    local cols, n = {}, #meta.counsel.columns
    for _, col in ipairs(meta.counsel.columns) do
      local ps = {}
      for _, line in ipairs(col) do ps[#ps + 1] = rp(sval(line), "CourtCounsel") end
      cols[#cols + 1] = { w = math.floor(9360 / n), paras = table.concat(ps) }
    end
    raw(tbl(cols, 0))
  end
  raw(rp("", "CourtSingle"))
  if meta.counsel_for then raw(rp(sval(meta.counsel_for), "CourtSingle", nil, ITALIC)) end
  raw(rp("", "CourtSingle"))

  -- LR 10.2(c)(1): court title.
  raw(rp(COURT[1], "CourtCenter"))
  raw(rp(COURT[2], "CourtCenter"))
  raw(rp("", "CourtSingle"))

  -- Caption box: parties at left, rule at right and bottom; number, title and judge at right.
  local left = {}
  for i, p in ipairs(meta.parties or {}) do
    for _, name in ipairs(p.names) do left[#left + 1] = rp(sval(name), "CourtSingle") end
    left[#left + 1] = rp("", "CourtSingle")
    left[#left + 1] = rp(sval(p.designation), "CourtSingle", RIGHT, ITALIC)
    left[#left + 1] = rp("", "CourtSingle")
    if i < #meta.parties then
      left[#left + 1] = rp("v.", "CourtSingle")
      left[#left + 1] = rp("", "CourtSingle")
    end
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000" />'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000" /></w:tcBorders>'
  local right = {
    rp("", "CourtSingle"),
    rp("No. " .. sval(meta.case_number), "CourtSingle"),
    rp("", "CourtSingle"),
    rp(string.upper(sval(meta.title)), "CourtSingle", nil, BOLD),
    rp("", "CourtSingle"),
    rp("Judge: " .. sval(meta.judge), "CourtSingle"),
  }
  if meta.hearing then right[#right + 1] = rp("Hearing: " .. sval(meta.hearing), "CourtSingle") end
  if meta.trial_date then right[#right + 1] = rp("Trial Date: " .. sval(meta.trial_date), "CourtSingle") end
  raw(tbl({
    { w = 4680, paras = table.concat(left), borders = rule },
    { w = 4680, paras = table.concat(right) },
  }, 115))
  raw(rp("", "CourtSingle"))
  return out
end

-- Dated line at left; signature blocks at right (LR 7.8 statement is in the motion paragraphs).
local function signature_lines(sig_lines)
  local ps = {}
  for _, line in ipairs(sig_lines) do
    if line == "" then ps[#ps + 1] = rp("", "CourtSignature")
    else ps[#ps + 1] = rp(line, "CourtSignature") end
  end
  return table.concat(ps)
end

local function signature(meta)
  local out = {}
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end
  if meta.date then raw(rp(sval(meta.date), "CourtSingle")) end
  raw(rp("", "CourtSingle"))
  local sig = meta.signature
  if sig and sig.blocks then
    for bi, b in ipairs(sig.blocks) do
      local lines = {}
      for _, line in ipairs(b.lines) do lines[#lines + 1] = sval(line) end
      raw(signature_lines(lines))
      if bi < #sig.blocks then raw(rp("", "CourtSingle")) end
    end
  end
  return out
end

local function with_style(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

function Pandoc(doc)
  local meta = doc.meta
  local out = caption(meta)
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end

  -- The motion (unnumbered paragraphs, from the frontmatter), then its signature.
  for _, m in ipairs(meta.motion or {}) do
    out[#out + 1] = with_style({ pandoc.Para(pandoc.utils.stringify(m)) }, "Court Unnumbered")
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end

  -- The memorandum starts on a new page. Its headings: I. (level 1), A. (level 2), 1. (level 3).
  raw(rp("MEMORANDUM IN SUPPORT OF MOTION", "CourtCenter", PAGE_BREAK))
  raw(rp("", "CourtSingle"))
  local r, a, k = 0, 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      r, a, k = r + 1, 0, 0
      local inl = { pandoc.Str(ROMAN[r] .. "."), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Header(1, inl)
    elseif b.t == "Header" and b.level == 2 then
      a, k = a + 1, 0
      local inl = { pandoc.Str(string.char(64 + a) .. "."), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Header(2, inl)
    elseif b.t == "Header" and b.level == 3 then
      k = k + 1
      local inl = { pandoc.Str(k .. "."), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Header(3, inl)
    else
      out[#out + 1] = b
    end
  end

  -- Signature at the end of the memorandum, then the certificate of service on its own page.
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local svc = meta.service
  if svc and svc.certificate then
    raw(rp("CERTIFICATE OF SERVICE", "CourtCenter", PAGE_BREAK))
    raw(rp("", "CourtSingle"))
    out[#out + 1] = with_style({ pandoc.Para(
      "I hereby certify that on " .. sval(svc.date) .. ", the foregoing document was filed electronically through the CM/ECF system, which will send notice of the filing to all counsel of record."
    ) }, "Court Unnumbered")
    raw(rp("", "CourtSingle"))
    local lines = {}
    for _, line in ipairs(svc.signature or {}) do lines[#lines + 1] = sval(line) end
    raw(signature_lines(lines))
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

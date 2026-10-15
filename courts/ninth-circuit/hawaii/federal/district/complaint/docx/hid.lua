-- U.S. District Court for the District of Hawaii: complaint, docx engine (pandoc filter, one copy per doc type).
-- The same markdown contract as typst/hid-complaint.typ. The caption (counsel block, court title, caption box),
-- the numbering of the allegations and roman headings, the lettered prayer and the signature block are written
-- here; the body text stays pandoc's. Styles come from reference.docx (make-reference.sh). Not rendered on the
-- build box (no LibreOffice); see README.md "Engines" for what is set and what is not checked.

local COURT = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF HAWAII" }
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }

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

-- A borderless (or bordered per cell) one-row table. cols: { {w=twips, paras=xml, borders=xml}, ... }.
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

  -- Caption box: parties at left, rule at right and bottom; case number and title at right.
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
    rp("Civil No. " .. sval(meta.case_number), "CourtSingle"),
    rp("", "CourtSingle"),
    rp(string.upper(sval(meta.title)), "CourtSingle", nil, BOLD),
  }
  raw(tbl({
    { w = 4680, paras = table.concat(left), borders = rule },
    { w = 4680, paras = table.concat(right) },
  }, 115))
  raw(rp("", "CourtSingle"))
  return out
end

local function signature(meta)
  local out = {}
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end
  local sig = meta.signature
  if meta.date then raw(rp(sval(meta.date), "CourtSingle")) end
  raw(rp("", "CourtSingle"))
  if sig and sig.blocks then
    for bi, b in ipairs(sig.blocks) do
      local ps = {}
      for _, line in ipairs(b.lines) do
        if sval(line) == "" then ps[#ps + 1] = rp("", "CourtSignature")
        else ps[#ps + 1] = rp(sval(line), "CourtSignature") end
      end
      raw(table.concat(ps))
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
  local n, r = 0, 0

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 2 then
      r = r + 1
      local inl = { pandoc.Str(ROMAN[r] .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Header(2, inl)
    elseif b.t == "Para" then
      n = n + 1
      local inl = { pandoc.Str(n .. "."), pandoc.Space() }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Para(inl)
    elseif b.t == "BlockQuote" then
      -- "> text": the unnumbered WHEREFORE paragraph.
      out[#out + 1] = with_style(b.content, "Court Unnumbered")
    elseif b.t == "BulletList" then
      -- "- item": lettered a., b., ... (the prayer for relief).
      for i, item in ipairs(b.content) do
        local letter = string.char(96 + i) .. "."
        local first = item[1]
        local rest = {}
        for j = 2, #item do rest[#rest + 1] = item[j] end
        local inl = { pandoc.Str(letter), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        if first and first.t == "Plain" or (first and first.t == "Para") then
          for _, x in ipairs(first.content) do inl[#inl + 1] = x end
        end
        local blocks = { pandoc.Para(inl) }
        for _, x in ipairs(rest) do blocks[#blocks + 1] = x end
        out[#out + 1] = with_style(blocks, "Court Lettered")
      end
    else
      out[#out + 1] = b
    end
  end

  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

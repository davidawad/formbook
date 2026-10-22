-- ACCA brief, DOCX engine (docs/DOCX.md): the markdown contract as a Word document that breaks every line and page
-- where the typst render (typst/acca-*.typ, the reference) does: the shared cross-engine layout model
-- (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"). pandoc writes the body (paragraphs, headings,
-- footnotes) in the styles of docx/reference.xml; this filter writes the Appendix A caption, the block quotations,
-- the signature block, the optional appendix and the Certificate of Service from the YAML frontmatter, and the
-- document's section (FORMBOOK_FINAL) with its two footers (FORMBOOK_FOOTERS): "Panel X" at the foot of page 1,
-- the page number, centered, on every later page. Nothing here is case-specific: every string comes from the
-- frontmatter or CFG. Word may paginate slightly differently from the LibreOffice PDF that is checked.

-- The only part that differs between the two doc types (typst: brief-title, default-recipient).
local CFG = {
  brief_title = "BRIEF ON BEHALF OF APPELLANT",
  default_recipient = "the Government Appellate Division",
}
local COURT_LINE = "IN THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS"
local ADDRESS_LINE = "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS"

-- The typst template's numbers, in twips (20 x pt).
local BODY = 656          -- pitch-body: 32.8 pt, double-spaced 14 pt
local SINGLE = 320        -- pitch-single: 16 pt
local INDENT = 720        -- para-indent: 0.5 in
local TEXT_W = 9360       -- 6.5 in
local GUTTER = 432        -- caption-gutter: 0.3 in
local COL = (TEXT_W - GUTTER) / 2
local SIG_GAP = 160       -- sig-gap: 8 pt
local SP_COURT = 336      -- space-court: 16.8 pt
local SP_TIGHT = 56       -- space-tight: 2.8 pt
local SP_CAPTION = 280    -- space-caption: 14 pt
local SP_ADDRESS = { 392, 168 }  -- space-address: 19.6 / 8.4 pt
local SP_SIGNATURE = 672  -- space-signature: 33.6 pt
local SP_TITLE = 280      -- space-title: 14 pt
local RULE_BOX = 120      -- rule-box: 6 pt
-- the page: letter, 1 in margins, the bottom one 4 pt more (typst page-margin-bottom); the footer line box ends
-- where typst's does (footer-descent 30 % of the bottom margin: 37.2 pt above the page's foot)
local SECT = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1520" w:left="1440" '
  .. 'w:header="720" w:footer="744" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:titlePg/>'

local xe = require("docx.xengine")
local runs, para, raw, ind, jc = xe.runs, xe.para, xe.raw, xe.ind, xe.jc
local KEEP, BREAK = xe.KEEP, xe.BREAK
local stringify = pandoc.utils.stringify

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

local function need(meta, key)
  if meta[key] == nil then error("acca-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- a YAML list of inline values as a Lua list of plain strings
local function items(v)
  local out = {}
  if v == nil then return out end
  for _, x in ipairs(v) do out[#out + 1] = plain(x) end
  return out
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- One single-spaced line (typst line-par): the space above it, its left indent, its run properties.
local function line(text, o)
  o = o or {}
  return para({ o.keep and KEEP or "", xe.spacing(o.before or 0, o.after or 0, SINGLE),
    ind(o.left or 0, nil, 0, o.right), o.jc and jc(o.jc) or "" }, runs(text, o.r or {}))
end

-- A rule under a box of RULE_BOX (typst rule): an empty paragraph of that exact height with a bottom border.
local function rule(before, left, right)
  return para({ KEEP, '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>',
    xe.spacing(before, 0, RULE_BOX), ind(left, nil, 0, right) }, "")
end

-- A column of lines (typst lines-block); "" is a gap between signers. All kept together.
local function lines_block(lines, left)
  local out, gap = {}, 0
  local n = 0
  for _, l in ipairs(lines) do if l ~= "" then n = n + 1 end end
  local k = 0
  for _, l in ipairs(lines) do
    if l == "" then gap = SIG_GAP else
      k = k + 1
      out[#out + 1] = line(l, { before = gap, left = left, keep = k < n })
      gap = 0
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Caption (Appendix A)
-- ---------------------------------------------------------------------------

local function caption(meta)
  local app = need(meta, "appellant")
  local trial = need(meta, "trial")
  local function cell(width, right, body)
    local mar = right > 0 and ('<w:tcMar><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>') or ""
    return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. mar .. "</w:tcPr>" .. body .. "</w:tc>"
  end
  local left = line("UNITED STATES")
    .. line("Appellee", { before = SP_TIGHT, left = 1728 })
    .. line("v.", { before = SP_CAPTION, left = 1152 })
    .. line(plain(app.rank), { before = SP_CAPTION })
    .. line(plain(app.name), { r = { b = true } })
    .. line(plain(app.service))
    .. line("Appellant", { before = SP_TIGHT, left = 1728 })
  local judge = trial.judge and (", " .. plain(trial.judge) .. " presiding") or ""
  local right = line(CFG.brief_title, { r = { b = true } })
    .. line("Docket No. " .. plain(need(meta, "docket")), { before = SP_CAPTION })
    .. line("Tried at " .. plain(trial.place) .. ", on " .. plain(trial.dates) .. ", before a "
      .. plain(trial["court-type"]) .. " court-martial appointed by " .. plain(trial.convening) .. judge .. ".",
      { before = SP_CAPTION })
  local nil_borders = {}
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    nil_borders[#nil_borders + 1] = "<w:" .. side .. ' w:val="nil"/>'
  end
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. "<w:tblBorders>" .. table.concat(nil_borders) .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. (COL + GUTTER) .. '"/><w:gridCol w:w="' .. COL .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(COL + GUTTER, GUTTER, left) .. cell(COL, 0, right) .. "</w:tr></w:tbl>"
  return line(COURT_LINE, { after = SP_COURT, jc = "center" }) .. tbl
    .. line(ADDRESS_LINE, { before = SP_ADDRESS[1], after = SP_ADDRESS[2], left = 1080, right = 1080, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Closing: signature block, appendix, certificate of service
-- ---------------------------------------------------------------------------

local function signature(meta)
  return rule(SP_SIGNATURE, 0, TEXT_W - 4320) .. lines_block(items(need(meta, "signature")), 0)
end

local function title(text)
  return para({ KEEP, BREAK, xe.spacing(0, SP_TITLE, SINGLE), ind(0, nil, 0), jc("center") }, runs(text, { b = true }))
end

local function closing(meta)
  local out = {}
  if meta.appendix and #meta.appendix > 0 then
    out[#out + 1] = title("Appendix")
    for _, item in ipairs(items(meta.appendix)) do out[#out + 1] = line(item) end
  end
  out[#out + 1] = title("Certificate of Service")
  local cert = need(meta, "certificate")
  local method = cert.method and plain(cert.method) or "sent via electronic submission"
  local recipient = cert.recipient and plain(cert.recipient) or CFG.default_recipient
  out[#out + 1] = para({ KEEP, xe.spacing(0, 0, BODY), ind(0, nil, INDENT) },
    runs("I certify that a copy of the foregoing was " .. method .. " to " .. recipient .. " on "
      .. plain(need(cert, "date")) .. "."))
  out[#out + 1] = rule(SP_SIGNATURE, 4320, 0) .. lines_block(items(need(cert, "signature")), 4320)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- A block quotation (typst: single-spaced, indented both sides, 12.6 pt above and between its paragraphs,
-- 19.6 pt below): its paragraphs in Block Text, the last in Block Text Last.
local function quote(b)
  local out = {}
  for i, p in ipairs(b.content) do
    out[#out + 1] = pandoc.Div({ p }, { ["custom-style"] = i == #b.content and "Block Text Last" or "Block Text" })
  end
  return out
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

function Pandoc(doc)
  local meta = doc.meta
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "BlockQuote" then
      for _, x in ipairs(quote(b)) do body[#body + 1] = x end
    else
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
  end
  body = pandoc.Pandoc(body):walk({ Inlines = xe.inlines }).blocks
  -- The last paragraph stays with the signature block (typst: the tail is kept with it, unless it refers to a note).
  local last = body[#body]
  if last and last.t == "Para" and not has_note(last) then
    body[#body] = pandoc.Div({ last }, { ["custom-style"] = "Body Keep" })
  end

  local out = { raw(caption(meta)) }
  for _, b in ipairs(body) do out[#out + 1] = b end
  out[#out + 1] = raw(signature(meta))
  out[#out + 1] = raw(closing(meta))

  -- The footers: "Panel X" flush right on page 1 (Appendix A), the page number centered on the others.
  local function footer(jcv, body_runs)
    return '<w:p><w:pPr><w:pStyle w:val="Footer"/>' .. xe.spacing(0, 0, SINGLE) .. ind(0, nil, 0) .. jc(jcv)
      .. "</w:pPr>" .. body_runs .. "</w:p>"
  end
  local page = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>2</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
  local panel = meta.panel and runs(plain(meta.panel)) or ""
  write_file("FORMBOOK_FOOTERS", "rIdAccaPanel\t" .. footer("right", panel) .. "\n"
    .. "rIdAccaPage\t" .. footer("center", page) .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdAccaPage"/>'
    .. '<w:footerReference w:type="first" r:id="rIdAccaPanel"/>' .. SECT .. "</w:sectPr>")

  -- No break inside a token of adjacent parentheses ("922(B)(2)"): typst boxes it (lib/typst/xengine.typ),
  -- LibreOffice would break between ")" and "(" (Unicode line breaking allows it); a word joiner forbids it.
  local function wj(s) return (s:gsub("%)%(", ")\u{2060}(")) end
  doc.blocks = pandoc.Blocks(out):walk({
    Str = function(el) el.text = wj(el.text); return el end,
    RawBlock = function(el) el.text = wj(el.text); return el end,
  })
  doc.meta = pandoc.Meta({})   -- pandoc prints no title block: the caption is the filter's
  return doc
end

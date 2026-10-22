-- ca7 brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The cover, table of contents, table of authorities, signature block and certificates are written here as
-- paragraphs in the "CA ..." styles of reference.docx (raw WordprocessingML, one paragraph per call to P);
-- the body keeps its markdown structure. Headings get their labels (I. A. 1. a.) as text, with a tab.
-- Sections (cover: no number; front matter: lower roman; body: arabic from 1) and the footers are written by
-- docx/render.sh, which also fills the page numbers of the TOC and TOA from a first pass (DOCX_MANIFEST and
-- DOCX_PAGEMAP, see docx/pagemap.awk). The answering and reply copies differ only in CFG (fb-595.54.4: the cross-engine
-- layout model, with the typst template's spaces in CFG.tw); the opening brief's copy is the one they were ported from.

local CFG = {
  kind = "answering-brief",
  case_no = true,          -- "No. 26-1864" on the cover (the reply prints the number alone)
  answering = true,        -- Argument point headings centered; A./1./a./(1) outside the Argument
  off_out = 1,             -- label indent in half inches: level - off (typst label-indent), outside the Argument
  off_in = 2,              -- ... and inside the Argument
  toc_depth = 4,
  word_limit = 14000,      -- Cir. R. 32(c)
  face = "Times New Roman", -- the typeface the template sets (typst font-family)
  size = 12, fn = 11,      -- body and footnote size in points (typst: 12 pt body, 11 pt footnotes)
  court = {{{"IN THE UNITED STATES COURT OF APPEALS FOR THE SEVENTH CIRCUIT", true}}},
  court_rule = false,      -- a short rule under the court line
  double_top = false,      -- a double rule above the court line
  double_bottom = false,   -- a double rule at the foot of the cover
  district = "lines",      -- "lines": district case and judge on two lines; "joined": "X; Y"; "paren": "No. X (Y)"
  cover_grid = false,      -- counsel in two columns (opening, reply); false: in the right half, a paragraph a line
  lines_italic = false,    -- the firm's lines on the cover are roman (typst sets them as given)
  phone_last = true,       -- the telephone line goes with the last counsel group
  counsel_for = false,     -- a "counsel_for" line after the counsel (opening)
  cover_role = true,       -- the role line under the counsel (answering)
  cover_date = true,       -- the date at the foot of the cover
  toc_front = true,        -- the table of authorities is listed in the table of contents
  toc_certs = true,        -- the certificates are listed in the table of contents
  toc_cert_title = nil,    -- the certificate of compliance's title in the table of contents (nil: the heading, in capitals)
  cert_heading = "Certificate of Compliance with Type-Volume Limit, Typeface Requirements, and Type-Style Requirements",
  cert = {
    "1. This document complies with the page and word limitation of Fed. R. App. P. 32(a)(7)(B) and Circuit Rule 32(c) and, excluding the portions of the filing exempted by Fed. R. App. P. 32(f), contains {words} words (including footnotes).",
    "2. This document complies with the typeface requirements and the type-style requirements of Fed. R. App. P. 32(a)(5) and (6) and Circuit Rule 32(b) because it has been prepared in a proportionally spaced typeface, {typeface}, in {size}-point text and {fn}-point footnotes.",
  },
  cert_form_sig = false,   -- a signature line with its caption (opening, reply) instead of the signers block
  sig = "signers",         -- "signers": "/s/ Name" over "Name (No. X)"; "single": "s/ Name" over NAME, then the firm
  slash = "/s/ ",          -- the signature mark before a signer's name
  dated = "",              -- before the date under the signature ("Dated: " in the reply)
  svc = "answering",       -- "answering" | "reply" | "opening": the service certificate's wording
  svc_break = true,        -- the service certificate starts a new page (answering, reply; typst pagebreak)
  cover_counts = false,    -- the cover counts as page i (reply): the contents are ii
  underline_pages = false, -- "Page(s)" over the authorities not underlined (typst toa-section)
  keep_rule = "source",    -- the last paragraph stays with the signature unless the markdown ends with a heading or note
  -- The typst template's line boxes and spaces, in twips (20 x pt): the single pitch (17 pt); the space below a
  -- section heading (13.2 pt); above the first authorities group and below every group head (9.6 pt, 2.4 pt);
  -- [signers-block] 10.8 pt between signers, 7.2 pt before the firm's lines, 12 pt above the block in a
  -- certificate; 9.6 pt before the date [signature-block] and before each group served [certificate-of-service];
  -- the right half of the text block (234 pt), the 0.5 em step of the cover's address lines and its 6 pt between
  -- paragraphs.
  tw = {single = 340, sect_after = 264, toa_first = 192, toa_after = 48, signer_gap = 216, lines_gap = 144,
    cert_signers = 240, date_gap = 192, svc_group = 192, half = 4680, step = 120, para = 120},
}

local TOA_GROUPS = {
  {"case", "Cases:"}, {"constitution", "Constitutional Provisions:"}, {"statute", "Statutes:"},
  {"regulation", "Regulations:"}, {"rule", "Rules:"}, {"other", "Other Authorities:"},
}

-- The cross-engine layout model (lib/docx/xengine.lua): the break rules of typst on every run (a no-break hyphen
-- before a digit, pandoc's abbreviation no-break spaces undone, a section sign bound to its number).
local xe = require("docx.xengine")
-- Before the page number of a table row: three no-break spaces, so the leader is never shorter than that.
local LEAD = pandoc.Str("\u{00A0}\u{00A0}\u{00A0}")
local TEXTW = 9360
local ITAL_FROM = 4
local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local LB = pandoc.LineBreak()
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="RIDROMAN"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function fail(msg) error("ca7 " .. CFG.kind .. ": " .. msg, 0) end

-- a metadata value as inlines
local function minl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then return pandoc.Inlines({pandoc.Str(v)}) end
  if v.t == nil then return pandoc.Inlines(v) end   -- a list of inlines (YAML strings are read as Markdown)
  return pandoc.Inlines(pandoc.utils.stringify(v))
end

-- whether the brief has a certificate of service: every answering brief has a service block; the others say so
local function has_svc(meta)
  if meta.service == nil then return false end
  if CFG.svc == "answering" then return true end
  return meta.service.certificate == true
end

local function need(meta, k)
  if meta[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function upper_il(il)
  return pandoc.Plain(il):walk({Str = function(e) return pandoc.Str(e.text:upper()) end}).content
end

local function cat(...)
  local out = pandoc.Inlines({})
  for _, x in ipairs({...}) do
    if type(x) == "string" then out:insert(pandoc.Str(x))
    elseif x.t == nil then out:extend(pandoc.Inlines(x))   -- a plain list of inlines
    else out:insert(x) end
  end
  return out
end

-- inline content as WordprocessingML runs (emphasis, strong, small caps, line breaks, raw openxml)
local function xesc(s) return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
-- Break opportunities as typst has them, where LibreOffice and Word have others: a word joiner between ")" and "("
-- (no break inside "32(a)(5)": typst boxes the token, TeX breaks at spaces only), a zero-width space after a slash
-- that a digit does not follow (a line may end after "Meta/", as Unicode line breaking lets typst end it).
local function typst_breaks(text)
  return (text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1"))
end
local function run(text, f)
  local rpr = (f.b and "<w:b/>" or "") .. (f.i and "<w:i/>" or "") .. (f.sc and "<w:smallCaps/>" or "")
    .. (f.u and '<w:u w:val="single"/>' or "")
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. xesc(typst_breaks(text)) .. "</w:t></w:r>"
end
local function inl_xml(il, f, out)
  for _, el in ipairs(il) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then inl_xml(el.content, {b = f.b, i = true, sc = f.sc, u = f.u}, out)
    elseif t == "Strong" then inl_xml(el.content, {b = true, i = f.i, sc = f.sc, u = f.u}, out)
    elseif t == "SmallCaps" then inl_xml(el.content, {b = f.b, i = f.i, sc = true, u = f.u}, out)
    elseif t == "Underline" then inl_xml(el.content, {b = f.b, i = f.i, sc = f.sc, u = true}, out)
    elseif t == "Span" or t == "Link" then inl_xml(el.content, f, out)
    elseif t == "RawInline" then
      if el.format == "openxml" then out[#out + 1] = el.text end
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
end

-- one paragraph as WordprocessingML (an XML string): style, inlines, optional extra pPr elements in schema order
local function P_xml(style, il, extra)
  local out = {}
  inl_xml(xe.inlines(pandoc.Inlines(il)), {}, out)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. "</w:pPr>" .. table.concat(out) .. "</w:p>"
end
local function P(style, il, extra) return pandoc.RawBlock("openxml", P_xml(style, il, extra)) end
local function raw_p(xml) return pandoc.RawBlock("openxml", xml) end
local KEEP = "<w:keepNext/>"
local NOKEEP = '<w:keepNext w:val="0"/>'   -- against a style that keeps with the next paragraph
-- the empty paragraph that ends a section takes no room (it would push a full page's last line on)
local SECT_LINE = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
local BREAK_BEFORE = "<w:pageBreakBefore/>"
-- a section heading that opens a page has no space above it (typst drops it at the top of a page; Word keeps it
-- after a section or page break)
-- single-spaced line boxes with the given spaces above and below (twips)
local function SP(before, after)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. CFG.tw.single .. '" w:lineRule="exact"/>'
end
local TOP = SP(0, CFG.tw.sect_after)

local function rule(style) return raw_p('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>') end
local function gap() return raw_p('<w:p><w:pPr><w:pStyle w:val="CAGap"/></w:pPr></w:p>') end

-- a borderless two-column table of paragraphs (XML strings); rows: list of {xml, xml}. The columns are typst's
-- grid: two halves of the text width less the gutter, the gutter a right margin of the left cell (CFG.tw.cols).
local function grid(rows)
  local COLS = CFG.tw.cols
  local out = {'<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. COLS[1][1] .. '"/><w:gridCol w:w="' .. COLS[2][1] .. '"/></w:tblGrid>'}
  for _, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for c = 1, 2 do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. COLS[c][1] .. '" w:type="dxa"/><w:tcMar><w:right w:w="'
        .. COLS[c][2] .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. (row[c] or '<w:p/>') .. '</w:tc>'
    end
    out[#out + 1] = '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return raw_p(table.concat(out))
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local vals = {{1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"}, {100, "C"}, {90, "XC"},
    {50, "L"}, {40, "XL"}, {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"}}
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- printed label of a numbered heading (levels 2 to 5); see the typst template, label scheme
local function label_for(level, n, in_arg)
  local point_roman = (not CFG.answering) or in_arg
  if level == 2 then return point_roman and (roman(n) .. ".") or (string.char(64 + n) .. ".") end
  if level == 3 then return point_roman and (string.char(64 + n) .. ".") or (tostring(n) .. ".") end
  if level == 4 then return point_roman and (tostring(n) .. ".") or (string.char(96 + n) .. ".") end
  if level == 5 then return point_roman and (string.char(96 + n) .. ".") or ("(" .. n .. ")") end
  fail("headings deeper than level 5 are not supported")
end

-- label indent steps (half inches) for a heading
local function steps_for(level, in_arg)
  return level - (in_arg and CFG.off_in or CFG.off_out)
end

-- a whole link text, for the search in the PDF (no cut)
local function norm_text(s)
  return (s:gsub("\u{2060}", ""):gsub("\u{200B}", ""):gsub("\u{00A0}", " "):lower():gsub("%s+", " "):gsub("^ ", ""):gsub(" $", ""))
end

-- the search key of a heading or an authority in the PDF text: lower case, at most about 30 characters
local function search_key(s)
  s = s:gsub("\u{2060}", ""):gsub("\u{200B}", ""):gsub("\u{00A0}", " "):lower():gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
  if #s > 30 then s = s:sub(1, 30):match("^(.*)%s%S*$") or s:sub(1, 30) end
  return s
end

-- ---------------------------------------------------------------------------
-- page numbers from a first pass (docx/render.sh): DOCX_PAGEMAP, DOCX_MANIFEST
-- ---------------------------------------------------------------------------

local PM = {H = {}, S = {}, T = {}}
local pm_path = os.getenv("DOCX_PAGEMAP")
local have_pm = pm_path ~= nil and pm_path ~= ""
if have_pm then
  local f = io.open(pm_path, "r")
  if not f then fail("cannot read the page map " .. pm_path) end
  for line in f:lines() do
    local k, a, b = line:match("^(%u)\t([^\t]*)\t(.*)$")
    if k == "H" then PM.H[tonumber(a)] = b
    elseif k == "S" then PM.S[a] = b
    elseif k == "T" then PM.T[a] = b
    end
  end
  f:close()
end
-- the page for a key of the page map: "0" on the first pass, the first pass's value afterwards
local function pm_get(tbl, key, what)
  if not have_pm then return "0" end
  local v = tbl[key]
  if v == nil then fail("no page for " .. what .. " in the page map") end
  return v
end

-- ---------------------------------------------------------------------------
-- cover (FRAP 32(a)(2); typst cover-body)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  if CFG.case_no then
    add(P("CACentered", {pandoc.Strong(cat("No. ", minl(need(meta, "case_number"))))}))   -- typst: all bold
  else
    add(P("CACentered", minl(need(meta, "case_number"))))
  end
  if CFG.double_top then add(rule("CADoubleRule")) end
  -- the court: a list of paragraphs, each a list of lines {text, bold}
  for _, para in ipairs(CFG.court) do
    local il = pandoc.Inlines({})
    for i, t in ipairs(para) do
      if i > 1 then il:insert(LB) end
      local s = pandoc.Str(t[1])
      il:insert(t[2] and pandoc.Strong({s}) or s)
    end
    add(P("CACentered", il, KEEP))   -- the bold parts are Strong (CFG.court); the rest is roman
  end
  if CFG.court_rule then add(rule("CARule")) end
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(P("CACentered", minl(name))) end
    add(P("CACaption", minl(side.designation)))
    if i < #sides then add(P("CACentered", pandoc.Inlines({pandoc.Str("v.")}))) end
  end
  add(rule("CARule"))
  add(P("CACentered", minl(need(meta, "proceeding"))))
  if meta.district_court_case ~= nil or meta.judge ~= nil then
    local dc, jd = meta.district_court_case, meta.judge
    if CFG.district == "lines" then
      if dc ~= nil then add(P("CACentered", minl(dc))) end
      if jd ~= nil then add(P("CACentered", minl(jd))) end
    elseif CFG.district == "joined" then
      local il = pandoc.Inlines({})
      if dc ~= nil then il:extend(minl(dc)) end
      if dc ~= nil and jd ~= nil then il:insert(pandoc.Str("; ")) end
      if jd ~= nil then il:extend(minl(jd)) end
      add(P("CACentered", il))
    else   -- "paren": No. X (Judge)
      local il = pandoc.Inlines({})
      if dc ~= nil then il:extend(cat("No. ", minl(dc))) end
      if dc ~= nil and jd ~= nil then il:insert(pandoc.Str(" ")) end
      if jd ~= nil then il:extend(cat("(", minl(jd), ")")) end
      add(P("CACentered", il))
    end
  end
  add(rule("CARule"))
  add(P("CACentered", {pandoc.Strong(upper_il(minl(need(meta, "brief_title"))))}))
  add(rule("CARule"))
  -- counsel (FRAP 32(a)(2)(F)): name, office address, telephone number
  local groups = need(meta, "counsel")
  local function group_il(gi, g)
    local il = pandoc.Inlines({})
    for _, n in ipairs(g.names) do il:extend(minl(n)); il:insert(LB) end
    for _, l in ipairs(g.lines or {}) do
      local t = minl(l)
      il:insert(CFG.lines_italic and pandoc.Emph(t) or t)
      il:insert(LB)
    end
    if CFG.phone_last and gi == #groups and meta.phone ~= nil then il:insert(pandoc.Emph(minl(meta.phone))); il:insert(LB) end
    il:remove(#il)   -- the last line break
    return il
  end
  if CFG.cover_grid then
    -- two columns: the groups marked `column: right` go on the right, the others on the left (in order);
    -- without marks the groups fill the cells in pairs
    local split = false
    for _, g in ipairs(groups) do if plain(g.column) == "right" then split = true end end
    local left, right = {}, {}
    for gi, g in ipairs(groups) do
      if split then
        if plain(g.column) == "right" then right[#right + 1] = gi else left[#left + 1] = gi end
      else
        if gi % 2 == 1 then left[#left + 1] = gi else right[#right + 1] = gi end
      end
    end
    -- typst cover-body: each column a stack of groups (the names, then the lines, as given), 8.4 pt after each;
    -- `counsel_note` closes the right column. A paragraph a line.
    local function column(gis, note)
      local x = {}
      for k, gi in ipairs(gis) do
        local g = groups[gi]
        local il = {}
        for _, n in ipairs(g.names) do il[#il + 1] = minl(n) end
        for _, l in ipairs(g.lines or {}) do il[#il + 1] = CFG.lines_italic and {pandoc.Emph(minl(l))} or minl(l) end
        for li, t in ipairs(il) do
          x[#x + 1] = P_xml("CACounsel", t, KEEP .. ((k > 1 and li == 1) and SP(CFG.tw.cell_gap, 0) or ""))
        end
      end
      if note ~= nil then
        x[#x + 1] = P_xml("CACounsel", {pandoc.Emph(minl(note))}, KEEP .. (#gis > 0 and SP(CFG.tw.cell_gap, 0) or ""))
      end
      return #x > 0 and table.concat(x) or nil
    end
    add(gap())
    add(grid({{column(left), column(right, meta.counsel_note)}}))
  else
    -- typst cover-body: in the right half, each group a block (the names, then its lines 0.5 em in; the last group
    -- also the telephone), then the role 6 pt below, in italics; a paragraph a line, so a wrapped line keeps its step
    add(gap())
    local step = '<w:ind w:left="' .. (CFG.tw.half + CFG.tw.step) .. '" w:firstLine="0"/>'
    for gi, g in ipairs(groups) do
      local lines = {}
      for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = minl(l) end
      if CFG.phone_last and gi == #groups and meta.phone ~= nil then lines[#lines + 1] = minl(meta.phone) end
      for ni, n in ipairs(g.names) do
        add(P("CACaption", minl(n), KEEP .. ((gi > 1 and ni == 1) and SP(CFG.tw.para, 0) or "")))
      end
      for _, t in ipairs(lines) do add(P("CACaption", CFG.lines_italic and {pandoc.Emph(t)} or t, KEEP .. step)) end
    end
    if CFG.cover_role and meta.role ~= nil then
      add(P("CACaption", {pandoc.Emph(minl(meta.role))}, SP(CFG.tw.para, 0)))
    end
  end
  if CFG.counsel_for and meta.counsel_for ~= nil then add(gap()); add(P("CACaption", minl(meta.counsel_for))) end
  if CFG.cover_grid and CFG.cover_role and meta.role ~= nil then add(gap()); add(P("CACaption", {pandoc.Emph(minl(meta.role))})) end
  if CFG.double_bottom then add(rule("CADoubleRule")) end
  if CFG.cover_date and meta.date ~= nil then add(gap()); add(P("CACentered", minl(meta.date))) end
  local cover_sect = SECT_COVER
  if CFG.cover_counts then cover_sect = cover_sect:gsub("</w:sectPr>", '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>') end
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. cover_sect .. '</w:pPr></w:p>'))
  return B
end

-- ---------------------------------------------------------------------------
-- signature and certificates
-- ---------------------------------------------------------------------------

-- the signature block: "Respectfully submitted," then the signers, then the firm's lines and the date
local function signature(meta, keep_all, head)
  local sig = need(meta, "signature")
  local B = {}
  if head then B[#B + 1] = P("CASigHead", {pandoc.Str("Respectfully submitted,")}, KEEP) end
  if CFG.sig == "signers" then
    -- typst signers-block: "/s/ Name" over "Name (No. X)", 10.8 pt between signers, then 7.2 pt and the firm's lines
    -- as given; under "Respectfully submitted," in the right half, in a certificate at the margin, 12 pt below the
    -- text. A paragraph a line; all kept together.
    local ind = '<w:ind w:left="' .. (head and CFG.tw.half or 0) .. '" w:firstLine="0"/>'
    for si, s in ipairs(sig.signers) do
      local before = si > 1 and CFG.tw.signer_gap or (head and 0 or CFG.tw.cert_signers)
      B[#B + 1] = P("CASignature", cat(pandoc.Str(CFG.slash), minl(s.name)), KEEP .. SP(before, 0) .. ind)
      local il = minl(s.name)
      if s.number ~= nil then il = cat(il, " (No. ", minl(s.number), ")") end
      B[#B + 1] = P("CASignature", il, KEEP .. ind)
    end
    for li, l in ipairs(sig.lines or {}) do
      local last = li == #(sig.lines) and not (head and meta.date ~= nil)
      B[#B + 1] = P("CASignature", minl(l), (last and NOKEEP or KEEP) .. (li == 1 and SP(CFG.tw.lines_gap, 0) or "") .. ind)
    end
    if head and meta.date ~= nil then
      B[#B + 1] = P("CASignature", cat(CFG.dated, minl(meta.date)),
        NOKEEP .. SP(CFG.tw.date_gap, 0) .. '<w:ind w:left="0" w:firstLine="0"/>')
    end
    return B
  else
    -- typst signature-block: CFG.tw.sig_gap after "Respectfully submitted,", the signer twice, the lines 0.5 em in
    B[#B + 1] = P("CASignature", cat(pandoc.Str(CFG.slash .. plain(sig.signer)), LB, pandoc.Str(plain(sig.signer):upper())),
      KEEP .. (head and SP(CFG.tw.sig_gap, 0) or ""))
    for li, l in ipairs(sig.lines or {}) do
      local last = li == #(sig.lines) and not (head and meta.date ~= nil)
      B[#B + 1] = P("CASignature", minl(l), (last and NOKEEP or KEEP)
        .. '<w:ind w:left="' .. (CFG.tw.half + CFG.tw.step) .. '" w:firstLine="0"/>')
    end
  end
  -- the date at the margin, CFG.tw.date_gap below
  if head and meta.date ~= nil then
    B[#B + 1] = P("CASignature", cat(CFG.dated, minl(meta.date)),
      NOKEEP .. SP(CFG.tw.date_gap, 0) .. '<w:ind w:left="0" w:firstLine="0"/>')
  end
  return B
end

-- a signature line with its caption (opening and reply): "/s/ Name" over "Signature", date over "Date"
local function form_sig_line(sig_name, date_il)
  -- typst form-sig-line: CFG.tw.form_sig above; the right column starts (text width + 1 em) / 2 in, at a left tab
  local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. CFG.tw.form_col .. '"/></w:tabs>'
  return {
    P("CACounsel", cat(pandoc.Str(CFG.slash .. sig_name), TAB, date_il), KEEP .. tabs .. SP(CFG.tw.form_sig, 0)),
    P("CACounsel", cat(pandoc.Str("Signature"), TAB, pandoc.Str("Date")), tabs),
  }
end

local function certificate_of_compliance(meta, words, out)
  out[#out + 1] = P("CASection", {pandoc.Str(CFG.cert_heading)}, BREAK_BEFORE .. TOP)
  local function sub(s)
    return (s:gsub("{words}", group_digits(words)):gsub("{typeface}", meta.typeface ~= nil and plain(meta.typeface) or CFG.face)
      :gsub("{size}", tostring(CFG.size)):gsub("{fn}", tostring(CFG.fn)))
  end
  out[#out + 1] = P("CACertificate", {pandoc.Str(sub(CFG.cert[1]))})
  out[#out + 1] = P("CACertificate", {pandoc.Str(sub(CFG.cert[2]))})
  if CFG.cert_form_sig then
    for _, b in ipairs(form_sig_line(plain(meta.signature.signer), minl(meta.date))) do out[#out + 1] = b end
  else
    for _, b in ipairs(signature(meta, false)) do out[#out + 1] = b end
  end
end

local function certificate_of_service(meta, out)
  local svc = need(meta, "service")
  out[#out + 1] = P("CASection", {pandoc.Str("Certificate of Service")}, CFG.svc_break and (BREAK_BEFORE .. TOP) or nil)   -- no space above at the top of a page
  if CFG.svc == "answering" then
    local il = cat("I hereby certify that on ", minl(need(meta, "date")), ", the foregoing ",
      minl(need(meta, "brief_title")), " was submitted for filing with the Clerk of Court of the United States Court of Appeals for the Seventh Circuit ",
      svc.method or "using the CM/ECF system", (svc.served_by ~= nil and (" and served by " .. plain(svc.served_by)) or ""),
      " on the following counsel of record:")
    out[#out + 1] = P("CACertificate", il, SP(0, 0))   -- the groups bring their own space
    -- typst certificate-of-service: each group 0.5 in in, 9.6 pt above, never split, its lines as given; the last
    -- group travels with the signers
    local groups = svc.counsel or {}
    for gi, g in ipairs(groups) do
      local gil = pandoc.Inlines({})
      for _, n in ipairs(g.names) do gil:extend(minl(n)); gil:insert(LB) end
      for _, l in ipairs(g.lines or {}) do gil:extend(minl(l)); gil:insert(LB) end
      gil:remove(#gil)
      out[#out + 1] = P("CACounsel", gil, (gi == #groups and KEEP or "") .. '<w:keepLines/>'
        .. SP(CFG.tw.svc_group, 0) .. '<w:ind w:left="720" w:firstLine="0"/>')
    end
    for _, b in ipairs(signature(meta, false)) do out[#out + 1] = b end
  elseif CFG.svc == "reply" then
    out[#out + 1] = P("CACertificate", cat("I hereby certify that on ", minl(need(meta, "date")),
      ", I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the Seventh Circuit by using the CM/ECF system, which will send notice of such filing to all registered CM/ECF users."))
    if svc.paper_copies ~= nil then
      out[#out + 1] = P("CACertificate", cat("Pursuant to Circuit Rule 31(b), upon notice of this Court’s acceptance of the electronic brief for filing, I certify that I will cause ",
        plain(svc.paper_copies), " copies of the above-named brief to be delivered to the Clerk of the Court."))
    end
    local unreg = svc.unregistered or {}
    if #unreg > 0 then
      out[#out + 1] = P("CACertificate", {pandoc.Strong({pandoc.Str("Service on case participants who are not registered for electronic filing:")})})
      out[#out + 1] = P("CACertificate", {pandoc.Str("I certify that I served the foregoing on this date by hand delivery, mail, third-party commercial carrier, or, having obtained prior consent, by email, to the following unregistered participants:")})
      for _, u in ipairs(unreg) do out[#out + 1] = P("CACounsel", cat(minl(u.name), ", ", minl(u.address)), SP(CFG.tw.unreg_gap, 0) .. '<w:ind w:left="720" w:firstLine="0"/>') end
    end
    for _, b in ipairs(form_sig_line(plain(meta.signature.signer), minl(meta.date))) do out[#out + 1] = b end
  else
    out[#out + 1] = P("CACertificate", cat("Pursuant to Federal Rule of Appellate Procedure 25, I hereby certify that on ",
      minl(svc.date), ", I electronically filed the foregoing ", minl(need(meta, "brief_title")),
      " via the Court’s CM/ECF system, and service was accomplished on counsel of record by that means."))
    for _, b in ipairs(form_sig_line(plain(meta.signature.signer), minl(svc.date))) do out[#out + 1] = b end
  end
end

-- ---------------------------------------------------------------------------
-- the filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta

  -- every toa: citation in document order, as a needle for the page map (docx/pagemap.awk): the link text and the
  -- words after it in its paragraph (up to a footnote mark or a quotation), so that the same words elsewhere in the
  -- brief, unlinked, are not taken for it. Kind B (body) moves the search on; N (in a footnote) is searched from the
  -- page the body has reached.
  local needles = {}
  local scan_blocks
  local function scan(inls, kind)
    for i, el in ipairs(inls) do
      if el.t == "Link" and el.target:match("^toa:") then
        local rest = {}
        for j = i + 1, math.min(#inls, i + 12) do
          local t = inls[j].t
          if t == "Note" or t == "Quoted" or t == "Link" then break end
          rest[#rest + 1] = inls[j]
        end
        local lt = norm_text(plain(pandoc.Inlines(el.content)))
        local tail = norm_text(plain(pandoc.Inlines(rest)))
        if #tail > 20 then tail = tail:sub(1, 20):match("^(.*)%s%S*$") or "" end
        local text = lt
        if tail ~= "" then text = lt .. (tail:match("^[%.,;:%)]") and "" or " ") .. tail end
        needles[#needles + 1] = {key = el.target:sub(5), kind = kind, text = text}
      elseif el.t == "Note" then
        scan_blocks(el.content, "N")
      elseif el.content ~= nil and type(el.content) == "table" and el.t ~= "Code" then
        scan(el.content, kind)
      end
    end
  end
  scan_blocks = function(blocks, kind)
    for _, b in ipairs(blocks) do
      if b.t == "Para" or b.t == "Plain" or b.t == "Header" then scan(b.content, kind)
      elseif b.t == "BlockQuote" or b.t == "Div" then scan_blocks(b.content, kind)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, kind) end
      end
    end
  end
  scan_blocks(doc.blocks, "B")

  -- every toa: citation: the authority key, and the distinct link texts (searched in the PDF on pass 1)
  local hits, texts, order = {}, {}, {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      local auth = meta.authorities or {}
      if auth[key] == nil then fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
      hits[key] = true
      texts[key] = texts[key] or {}
      local t = plain(pandoc.Inlines(el.content))
      if not texts[key][t] then texts[key][t] = true; texts[key][#texts[key] + 1] = t end
      return el.content
    end,
  })
  local auth = meta.authorities or {}

  -- Cir. R. 32(c): the words of the body, footnotes included (pandoc's stringify leaves the notes out)
  local function count_words(s)
    local n = 0
    s = s:gsub("\u{00A0}", " ")   -- pandoc puts no-break spaces after "No." and "v."; the source has plain spaces
    for _ in s:gmatch("%S+") do n = n + 1 end
    return n
  end
  local words = 0
  for _, blk in ipairs(doc.blocks) do words = words + count_words(pandoc.utils.stringify(blk)) end
  doc:walk({Note = function(nt) words = words + count_words(pandoc.utils.stringify(nt.content)) end})
  if words > CFG.word_limit then
    fail("the brief has " .. words .. " words; Circuit Rule 32(c) allows " .. CFG.word_limit)
  end
  -- the break rules of typst on the text pandoc writes itself (body, footnotes), after the count: they write some
  -- characters as raw runs, which stringify leaves out
  doc = doc:walk({Inlines = xe.inlines})
  -- and typst's break opportunities around parentheses and slashes (typst_breaks, above)
  doc = doc:walk({Str = function(s)
    local t = typst_breaks(s.text)
    if t ~= s.text then return pandoc.Str(t) end
  end})

  -- the body: headings get their labels; the addendum is not produced by this engine
  local heads, body = {}, {}
  local counters, in_arg = {0, 0, 0, 0, 0, 0}, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = plain(b.content)
      if b.level == 1 and text:lower():match("^%s*addendum%s*$") then
        fail("the DOCX engine does not yet render an addendum (FRAP 28(f)); see the Engines section of the README")
      end
      if b.level == 1 then
        in_arg = text:lower():match("^%s*argument%s*$") ~= nil
        counters = {0, 0, 0, 0, 0, 0}
      end
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      local idx = #heads + 1
      local h = {level = b.level, title = b.content, idx = idx}
      if b.level == 1 then
        h.label, h.steps, h.centered = "", 0, false
        body[#body + 1] = P("CASection", b.content, KEEP .. (#body == 0 and TOP or ""))
      else
        h.label = label_for(b.level, counters[b.level], in_arg)
        h.steps = steps_for(b.level, in_arg)
        h.centered = CFG.answering and in_arg and b.level == 2
        if h.centered then
          body[#body + 1] = P("CAPoint", cat(h.label, " ", b.content), KEEP)
        else
          body[#body + 1] = P("CAHeadL" .. b.level .. "S" .. h.steps, cat(h.label, TAB, b.content), KEEP)
        end
      end
      -- the page map finds a heading by its label and title at the start of a line
      h.key = search_key(h.label ~= "" and (h.label .. " " .. text) or text)
      heads[idx] = h
    else
      body[#body + 1] = b
    end
  end

  -- the last paragraph stays with the signature block (typst keeps them together). CFG.keep_rule "source": unless
  -- the markdown's last block (after the last blank line) is a heading or a footnote definition, read from the source
  -- as typst reads it; "body": unless the body ends with a heading (typst sets the footnote definitions apart)
  local function keeps_tail()
    local f = PANDOC_STATE.input_files[1]
    local h = f and io.open(f, "r")
    if not h then return true end
    local src = h:read("a")
    h:close()
    src = src:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1):gsub("%s+$", "")
    local tail, pos = src, 1
    while true do
      local s, e = src:find("\n[ \t]*\n", pos)
      if not s then break end
      tail, pos = src:sub(e + 1), e
    end
    return #tail > 0 and tail:sub(1, 1) ~= "#" and tail:sub(1, 2) ~= "[^"
  end
  if #body > 0 and body[#body].t == "Para" and (CFG.keep_rule == "body" or keeps_tail()) then
    body[#body] = pandoc.Div({body[#body]}, pandoc.Attr("", {}, {["custom-style"] = "CA Body Last"}))
  end

  -- manifest for the first pass of docx/render.sh
  local man_path = os.getenv("DOCX_MANIFEST")
  if man_path ~= nil and man_path ~= "" then
    local f = assert(io.open(man_path, "w"))
    for _, h in ipairs(heads) do f:write(string.format("H\t%d\t%d\t%s\n", h.idx, h.level, h.key)) end
    f:write("S\ttoa\troman\ttable of authorities\n")
    f:write("S\tcc\tbody\tcertificate of compliance\n")
    if has_svc(meta) then f:write("S\tcs\tbody\tcertificate of service\n") end
    for _, n in ipairs(needles) do f:write(string.format("C\t%s\t%s\t%s\n", n.key, n.kind, n.text)) end
    f:close()
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- front matter, section 1: the cover (no page number)
  addall(cover(meta))

  -- section 2 (lower roman): the table of contents
  add(P("CASection", {pandoc.Str("Table of Contents")}, TOP))
  add(P("CATocPage", {pandoc.Str("Page")}))
  local function folio_il(v)
    if v == "passim" then return {pandoc.Emph({pandoc.Str("passim")})} end
    return {pandoc.Str(v)}
  end
  if CFG.toc_front then add(P("CATocTop", cat(pandoc.Str("TABLE OF AUTHORITIES"), LEAD, TAB, folio_il(pm_get(PM.S, "toa", "the table of authorities"))))) end
  for _, h in ipairs(heads) do
    if h.level <= CFG.toc_depth then
      local page = pm_get(PM.H, h.idx, "heading " .. h.idx)
      if h.level == 1 then
        add(P("CATocTop", cat(upper_il(h.title), LEAD, TAB, folio_il(page))))
      else
        local s = h.centered and 0 or (CFG.toc_off and (h.level - CFG.toc_off) or h.steps)
        add(P("CATocS" .. s, cat(h.label, TAB, h.title, LEAD, TAB, folio_il(page))))
      end
    end
  end
  if CFG.toc_certs then
    add(P("CATocTop", cat(pandoc.Str(CFG.toc_cert_title or CFG.cert_heading:upper()), LEAD, TAB, folio_il(pm_get(PM.S, "cc", "the certificate of compliance")))))
    if has_svc(meta) then
      add(P("CATocTop", cat(pandoc.Str("CERTIFICATE OF SERVICE"), LEAD, TAB, folio_il(pm_get(PM.S, "cs", "the certificate of service")))))
    end
  end

  -- table of authorities (its own page)
  add(P("CASection", {pandoc.Str("Table of Authorities")}, BREAK_BEFORE .. TOP))
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = {key = key, a = a} end
    end
    local function sk(a)
      local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
      return (s:lower():gsub("[^a-z0-9 ]", ""))
    end
    table.sort(members, function(x, y) return sk(x.a) < sk(y.a) end)
    if #members > 0 then
      local head = {pandoc.Str(g[2])}
      if first then
        local pg = pandoc.Str("Page(s)")
        head[#head + 1] = TAB; head[#head + 1] = pandoc.Strong({CFG.underline_pages and pandoc.Underline({pg}) or pg})
      end
      -- the first group 9.6 pt below the heading, the others 12 pt (the style) below the last entry
      add(P("CAToaGroup", head, first and SP(CFG.tw.toa_first, CFG.tw.toa_after) or nil))
      first = false
      for _, m in ipairs(members) do
        local il = pandoc.Inlines({})
        if m.a.name ~= nil then
          local nm = minl(m.a.name)
          if g[1] == "case" then il:insert(pandoc.Emph(nm)) else il:extend(nm) end
          il:insert(pandoc.Str(",")); il:insert(LB)
        end
        il:extend(minl(m.a.cite))
        il:insert(LEAD)
        il:insert(TAB)
        il:extend(folio_il(pm_get(PM.T, m.key, "authority " .. m.key)))
        add(P("CAToaEntry", il))
      end
    end
  end
  local roman_sect = SECT_ROMAN
  if CFG.cover_counts then roman_sect = roman_sect:gsub(' w:start="1"', '') end   -- the count goes on from the cover
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. roman_sect .. '</w:pPr></w:p>'))

  -- section 3 (arabic from 1): the body, the signature block, the certificates
  addall(body)
  addall(signature(meta, true, true))

  local certs = {}
  certificate_of_compliance(meta, words, certs)
  addall(certs)
  if has_svc(meta) then certificate_of_service(meta, out) end

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({})   -- pandoc would print the date and title as a block at the top
  return doc
end

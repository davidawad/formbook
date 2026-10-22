-- ca7 brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The cover, table of contents, table of authorities, signature block and certificates are written here as
-- paragraphs in the "CA ..." styles of reference.docx (raw WordprocessingML, one paragraph per call to P);
-- the body keeps its markdown structure. Headings get their labels (I. A. 1. a.) as text, with a tab.
-- Sections (cover: no number; front matter: lower roman; body: arabic from 1) are section breaks naming the
-- footers fb render writes (rIdFtrNone, rIdFtrPage); this filter writes the last section to FORMBOOK_FINAL.
-- The TOC and TOA page numbers: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page
-- of every heading and citation in that PDF (the needles this filter writes to FORMBOOK_NEEDLES), and renders
-- again with those pages (FORMBOOK_PAGES) until they settle. Word may paginate slightly differently from the
-- LibreOffice PDF the page numbers come from (docs/DOCX.md). Styles: docx/reference.xml. The only part of this file that differs between the three copies is CFG.

local CFG = {
  kind = "reply-brief",
  case_no = false,         -- the reply prints the case number alone on the cover
  answering = false,       -- I. A. 1. a. at every level (typst label scheme)
  off_out = 1,             -- label indent in half inches: level - off (typst label-indent: level - 1)
  off_in = 1,
  toc_depth = 3,           -- point headings and their sub-headings only
  word_limit = 7000,       -- Cir. R. 32(c): a reply brief
  face = "Times New Roman", -- the typeface reference.xml sets (typst font-family); the certificate names it
  software = "Microsoft Word", -- the program the .docx is made for (typst names Typst)
  size = 12, fn = 11,      -- body and footnote size in points (typst: 12 pt body, 11 pt footnotes)
  court = {{{"In the United States Court of Appeals", false}}, {{"FOR THE SEVENTH CIRCUIT", true}}},
  court_rule = false,
  double_top = false,
  double_bottom = true,    -- a double rule at the foot of the cover
  district = "paren",      -- "No. X (Y)"
  cover_grid = true,       -- counsel in two columns; `column: right` puts a group on the right
  lines_italic = true,
  phone_last = false,
  counsel_for = false,
  cover_role = false,
  cover_date = false,
  toc_front = false,       -- the typst contents list the body headings only
  toc_certs = false,
  cert_heading = "Certificate of Compliance",
  cert = {
    "I certify that this brief complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B), as modified by Cir. R. 32(c). Excluding the parts of the brief exempted by Fed. R. App. P. 32(f), this brief contains {words} words.",
    "I further certify that this brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6), as modified by Cir. R. 32(b). This brief has been prepared in a proportionally spaced typeface using {software} in {size}-point {typeface} for the body text and {fn}-point {typeface} for the footnotes.",
  },
  cert_form_sig = true,
  sig = "single",
  slash = "/s/ ",
  dated = "Dated: ",
  svc = "reply",
  svc_break = true,
  cover_counts = true,     -- the cover counts as page i: the contents are ii (typst reply)
}

local TOA_GROUPS = {
  {"case", "Cases:"}, {"constitution", "Constitutional Provisions:"}, {"statute", "Statutes:"},
  {"regulation", "Regulations:"}, {"rule", "Rules:"}, {"other", "Other Authorities:"},
}

local TEXTW = 9360
local ITAL_FROM = 4
local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local LB = pandoc.LineBreak()
local PAGE_SETUP = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
-- a section's properties: the footer fb render writes (rIdFtrNone: empty, rIdFtrPage: the centered PAGE field),
-- the page setup and the page numbering
local function sect_pr(footer, pgnum)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/><w:type w:val="nextPage"/>'
    .. PAGE_SETUP .. (pgnum or "") .. '</w:sectPr>'
end

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
local function run(text, f)
  local rpr = (f.b and "<w:b/>" or "") .. (f.i and "<w:i/>" or "") .. (f.sc and "<w:smallCaps/>" or "")
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end
local function inl_xml(il, f, out)
  for _, el in ipairs(il) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then inl_xml(el.content, {b = f.b, i = true, sc = f.sc}, out)
    elseif t == "Strong" then inl_xml(el.content, {b = true, i = f.i, sc = f.sc}, out)
    elseif t == "SmallCaps" then inl_xml(el.content, {b = f.b, i = f.i, sc = true}, out)
    elseif t == "Span" or t == "Link" then inl_xml(el.content, f, out)
    elseif t == "RawInline" then
      if el.format == "openxml" then out[#out + 1] = el.text end
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
end

-- one paragraph as WordprocessingML (an XML string): style, inlines, optional extra pPr elements in schema order
local function P_xml(style, il, extra)
  local out = {}
  inl_xml(il, {}, out)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. "</w:pPr>" .. table.concat(out) .. "</w:p>"
end
local function P(style, il, extra) return pandoc.RawBlock("openxml", P_xml(style, il, extra)) end
local function raw_p(xml) return pandoc.RawBlock("openxml", xml) end
local KEEP = "<w:keepNext/>"
local BREAK_BEFORE = "<w:pageBreakBefore/>"

local function rule(style) return raw_p('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>') end
local function gap() return raw_p('<w:p><w:pPr><w:pStyle w:val="CAGap"/></w:pPr></w:p>') end

-- a borderless two-column table of paragraphs (XML strings); rows: list of {xml, xml}
local function grid(rows)
  local out = {'<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="115" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="4680"/></w:tblGrid>'}
  for _, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for c = 1, 2 do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/></w:tcPr>' .. (row[c] or '<w:p/>') .. '</w:tc>'
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

-- ---------------------------------------------------------------------------
-- needles and pages (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60   -- a needle is a prefix of the text (letters and digits only)
local PASSIM = 7        -- an authority cited on this many pages or more is "passim" (typst passim-threshold)

-- letters and digits only, lower case: fb render normalizes the PDF text the same way
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- a needle: { id, kind, needle, fallback }; kind B (body, in document order: moves the search on) or N (inside a
-- footnote: searched from the page the body has reached, moves nothing)
local needles = {}
local function need_at(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = {id = id, kind = kind, needle = long, fallback = short}
end

-- the pages of the previous pass: id -> { page, label }; empty on the first pass
local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = {page = tonumber(page) or 0, label = lab} end
  end
  f:close()
end

-- the printed page of a needle: a placeholder of the final width on the first pass
local function label_of(id)
  local l = labels[id]
  if l then return l.label end
  return "00"
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- cover (FRAP 32(a)(2); typst cover-body)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  if CFG.case_no then
    add(P("CACentered", cat({pandoc.Strong({pandoc.Str("No. ")})}, minl(need(meta, "case_number")))))
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
    add(P("CACoverCourt", il))
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
    for _, g in ipairs(groups) do if g.column == "right" then split = true end end
    local left, right = {}, {}
    for gi, g in ipairs(groups) do
      if split then
        if g.column == "right" then right[#right + 1] = gi else left[#left + 1] = gi end
      else
        if gi % 2 == 1 then left[#left + 1] = gi else right[#right + 1] = gi end
      end
    end
    local rows = {}
    for r = 1, math.max(#left, #right) do
      local lc = left[r] and P_xml("CACounsel", group_il(left[r], groups[left[r]]), KEEP) or nil
      local rc = right[r] and P_xml("CACounsel", group_il(right[r], groups[right[r]]), KEEP) or nil
      if r == #right and meta.counsel_note ~= nil then
        rc = P_xml("CACounsel", cat(group_il(right[r], groups[right[r]]), LB, pandoc.Emph(minl(meta.counsel_note))), KEEP)
      end
      rows[#rows + 1] = {lc, rc}
    end
    add(gap())
    add(grid(rows))
  else
    for gi, g in ipairs(groups) do
      add(gap())
      add(P("CACaption", group_il(gi, g), KEEP))
    end
  end
  if CFG.counsel_for and meta.counsel_for ~= nil then add(gap()); add(P("CACaption", minl(meta.counsel_for))) end
  if CFG.cover_role and meta.role ~= nil then add(gap()); add(P("CACaption", {pandoc.Emph(minl(meta.role))})) end
  if CFG.double_bottom then add(rule("CADoubleRule")) end
  if CFG.cover_date and meta.date ~= nil then add(gap()); add(P("CACentered", minl(meta.date))) end
  -- the cover's section: no page number; lower roman from 1 when the cover counts as page i
  add(raw_p('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr("rIdFtrNone", CFG.cover_counts and '<w:pgNumType w:fmt="lowerRoman" w:start="1"/>' or nil) .. '</w:pPr></w:p>'))
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
    for _, s in ipairs(sig.signers) do
      local il = cat(pandoc.Str(CFG.slash), minl(s.name))
      il:insert(LB); il:extend(minl(s.name))
      if s.number ~= nil then il:extend(cat(" (No. ", minl(s.number), ")")) end
      B[#B + 1] = P("CASignature", il, KEEP)
    end
    local lines = sig.lines or {}
    for _, l in ipairs(lines) do B[#B + 1] = P("CASignature", {pandoc.Emph(minl(l))}, KEEP) end
  else
    local il = cat(pandoc.Str(CFG.slash .. plain(sig.signer)), LB, pandoc.Str(plain(sig.signer):upper()))
    for _, l in ipairs(sig.lines or {}) do il:insert(LB); il:insert(pandoc.Emph(minl(l))) end
    B[#B + 1] = P("CASignature", il, KEEP)
  end
  if head and meta.date ~= nil then B[#B + 1] = P("CASignature", cat(CFG.dated, minl(meta.date)), keep_all and "" or nil) end
  return B
end

-- a signature line with its caption (opening and reply): "s/ Name" over "Signature", date over "Date"
local function form_sig_line(sig_name, date_il)
  local left = cat(pandoc.Str(CFG.slash .. sig_name), LB, pandoc.Str("Signature"))
  local right = cat(date_il, LB, pandoc.Str("Date"))
  return {gap(), grid({{P_xml("CACounsel", left), P_xml("CACounsel", right)}})}
end

local function certificate_of_compliance(meta, words, out)
  out[#out + 1] = P("CASection", {pandoc.Str(CFG.cert_heading)}, BREAK_BEFORE)
  local function sub(s)
    return (s:gsub("{words}", group_digits(words)):gsub("{typeface}", CFG.face):gsub("{software}", meta.software ~= nil and plain(meta.software) or CFG.software)
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
  out[#out + 1] = P("CASection", {pandoc.Str("Certificate of Service")}, CFG.svc_break and BREAK_BEFORE or nil)
  if CFG.svc == "answering" then
    local il = cat("I hereby certify that on ", minl(need(meta, "date")), ", the foregoing ",
      minl(need(meta, "brief_title")), " was submitted for filing with the Clerk of Court of the United States Court of Appeals for the Seventh Circuit ",
      svc.method or "using the CM/ECF system", (svc.served_by ~= nil and (" and served by " .. plain(svc.served_by)) or ""),
      " on the following counsel of record:")
    out[#out + 1] = P("CACertificate", il)
    for _, g in ipairs(svc.counsel or {}) do
      local gil = pandoc.Inlines({})
      for _, n in ipairs(g.names) do gil:extend(minl(n)); gil:insert(LB) end
      for _, l in ipairs(g.lines or {}) do gil:insert(pandoc.Emph(minl(l))); gil:insert(LB) end
      gil:remove(#gil)
      out[#out + 1] = P("CACounsel", gil, '<w:ind w:left="720" w:firstLine="0"/>')
    end
    for _, b in ipairs(signature(meta, false)) do out[#out + 1] = b end
  elseif CFG.svc == "reply" then
    out[#out + 1] = P("CACertificate", cat("I hereby certify that on ", minl(need(meta, "date")),
      ", I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the Seventh Circuit by using the CM/ECF system, which will send notice of such filing to all registered CM/ECF users."))
    if svc.paper_copies ~= nil then
      out[#out + 1] = P("CACertificate", cat("Pursuant to Circuit Rule 31(b), upon notice of this Court's acceptance of the electronic brief for filing, I certify that I will cause ",
        plain(svc.paper_copies), " copies of the above-named brief to be delivered to the Clerk of the Court."))
    end
    local unreg = svc.unregistered or {}
    if #unreg > 0 then
      out[#out + 1] = P("CACertificate", {pandoc.Strong({pandoc.Str("Service on case participants who are not registered for electronic filing:")})})
      out[#out + 1] = P("CACertificate", {pandoc.Str("I certify that I served the foregoing on this date by hand delivery, mail, third-party commercial carrier, or, having obtained prior consent, by email, to the following unregistered participants:")})
      for _, u in ipairs(unreg) do out[#out + 1] = P("CACounsel", cat(minl(u.name), ", ", minl(u.address)), '<w:ind w:left="720" w:firstLine="0"/>') end
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
  load_pages()
  local meta = doc.meta
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

  -- citations, in document order: each `toa:` link is an occurrence and a needle (kind N inside a footnote)
  local hits, occurrences = {}, {}
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        if auth[key] == nil then fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
        hits[key] = true
        occurrences[#occurrences + 1] = {key = key, id = "T:" .. (#occurrences + 1)}
        local rest = {}
        for j = i + 1, #list do rest[#rest + 1] = list[j] end
        need_at(occurrences[#occurrences].id, in_note and "N" or "B", plain(el.content), pandoc.utils.stringify(rest))
      elseif el.t == "Note" then
        scan_blocks(el.content, true)
      elseif el.content and type(el.content) ~= "string" then
        scan_inlines(el.content, in_note)
      end
    end
  end
  scan_blocks = function(list, in_note)
    for _, b in ipairs(list) do
      if b.t == "Para" or b.t == "Plain" then
        scan_inlines(b.content, in_note)
      elseif b.t == "BlockQuote" or b.t == "Div" then
        scan_blocks(b.content, in_note)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
      end
    end
  end

  -- the body: headings get their labels and needles; the addendum is not produced by this engine. The body's
  -- page 1 is the page of its first block.
  local blocks = doc.blocks
  local body_id = "S:body"
  if blocks[1] and blocks[1].t ~= "Header" then
    need_at(body_id, "B", pandoc.utils.stringify(blocks[1]):sub(1, NEEDLE_MAX), "")
  end
  local heads, body = {}, {}
  local counters, in_arg = {0, 0, 0, 0, 0, 0}, false
  for bi, b in ipairs(blocks) do
    if b.t == "Header" then
      local text = plain(b.content)
      if b.level == 1 and text:lower():match("^%s*addendum%s*$") then
        fail("the DOCX engine does not yet render an addendum (FRAP 28(f)); see the Engines section of the README")
      end
      if b.level > 5 then fail("headings deeper than level 5 are not supported") end
      if b.level == 1 then
        in_arg = text:lower():match("^%s*argument%s*$") ~= nil
        counters = {0, 0, 0, 0, 0, 0}
      end
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      local id = "H:" .. (#needles + 1)
      if bi == 1 then body_id = id end
      local nxt = blocks[bi + 1] and pandoc.utils.stringify(blocks[bi + 1]):sub(1, 40) or ""
      local h = {level = b.level, title = b.content, id = id}
      if b.level == 1 then
        h.label, h.steps, h.centered = "", 0, false
        need_at(id, "B", text, nxt)
        body[#body + 1] = P("CASection", b.content, KEEP)
      else
        h.label = label_for(b.level, counters[b.level], in_arg)
        h.steps = steps_for(b.level, in_arg)
        h.centered = CFG.answering and in_arg and b.level == 2
        need_at(id, "B", h.label .. " " .. text, nxt)
        if h.centered then
          body[#body + 1] = P("CAPoint", cat(h.label, " ", b.content), KEEP)
        else
          body[#body + 1] = P("CAHeadL" .. b.level .. "S" .. h.steps, cat(h.label, TAB, b.content), KEEP)
        end
      end
      heads[#heads + 1] = h
    else
      scan_blocks({b}, false)
      body[#body + 1] = b
    end
  end
  body = pandoc.Pandoc(body):walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  }).blocks

  -- the last paragraph stays with the signature block (typst keeps them together)
  if #body > 0 and body[#body].t == "Para" then
    body[#body] = pandoc.Div({body[#body]}, pandoc.Attr("", {}, {["custom-style"] = "CA Body Last"}))
  end

  -- the needles, in document order: the table of authorities first, then the body's, then the certificates'
  need_at("C:compliance", "B", CFG.cert_heading, CFG.cert[1]:sub(1, 30))
  if has_svc(meta) then need_at("C:service", "B", "Certificate of Service", "I hereby certify") end
  table.insert(needles, 1, {id = "S:toc", kind = "B", needle = norm("Table of Contents"), fallback = norm("Table of Contents")})
  table.insert(needles, 2, {id = "S:toa", kind = "B", needle = norm("Table of Authorities"), fallback = norm("Table of Authorities")})
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({n.id, n.kind, n.needle, n.fallback}, "\t") end
  -- how fb render labels pages: the cover is page i (cover_counts) or the contents are, the body and the
  -- certificates from the body's first block (1, 2 ...)
  nl[#nl + 1] = CFG.cover_counts and "#section\tS:cover\tlower-roman\t" or "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  if CFG.cover_counts then
    table.insert(nl, 1, table.concat({"S:cover", "B", norm(plain(need(meta, "case_number"))), norm(plain(need(meta, "case_number")))}, "\t"))
  end
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", '<w:pgNumType w:fmt="decimal" w:start="1"/>'))

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- front matter, section 1: the cover (no page number)
  addall(cover(meta))

  -- section 2 (lower roman): the table of contents
  add(P("CASection", {pandoc.Str("Table of Contents")}))
  add(P("CAToaGroup", {TAB, pandoc.Strong({pandoc.Str("Page")})}))
  local function folio_il(v)
    if v == "passim" then return {pandoc.Emph({pandoc.Str("passim")})} end
    return {pandoc.Str(v)}
  end
  if CFG.toc_front then add(P("CATocTop", cat(pandoc.Str("TABLE OF AUTHORITIES"), TAB, folio_il(label_of("S:toa"))))) end
  for _, h in ipairs(heads) do
    if h.level <= CFG.toc_depth then
      local page = label_of(h.id)
      if h.level == 1 then
        add(P("CATocTop", cat(upper_il(h.title), TAB, folio_il(page))))
      else
        local s = h.centered and 0 or h.steps
        add(P("CATocS" .. s, cat(h.label, TAB, h.title, TAB, folio_il(page))))
      end
    end
  end
  if CFG.toc_certs then
    add(P("CATocTop", cat(pandoc.Str(CFG.toc_cert_title or CFG.cert_heading:upper()), TAB, folio_il(label_of("C:compliance")))))
    if has_svc(meta) then
      add(P("CATocTop", cat(pandoc.Str("CERTIFICATE OF SERVICE"), TAB, folio_il(label_of("C:service")))))
    end
  end

  -- table of authorities (its own page)
  add(P("CASection", {pandoc.Str("Table of Authorities")}, BREAK_BEFORE))
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
      if first then head[#head + 1] = TAB; head[#head + 1] = pandoc.Strong({pandoc.Str("Page(s)")}) end
      add(P("CAToaGroup", head))
      first = false
      for _, m in ipairs(members) do
        local il = pandoc.Inlines({})
        if m.a.name ~= nil then
          local nm = minl(m.a.name)
          if g[1] == "case" then il:insert(pandoc.Emph(nm)) else il:extend(nm) end
          il:insert(pandoc.Str(",")); il:insert(LB)
        end
        il:extend(minl(m.a.cite))
        il:insert(TAB)
        -- the distinct pages of the authority, in page order; passim from PASSIM pages
        local pages, seen = {}, {}
        for oi, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels[o.id]
            local p = l and l.page or -oi
            if not seen[p] then
              seen[p] = true
              pages[#pages + 1] = {page = l and l.page or 0, label = l and l.label or "00"}
            end
          end
        end
        table.sort(pages, function(x, y) return x.page < y.page end)
        if #pages >= PASSIM then
          il:insert(pandoc.Emph({pandoc.Str("passim")}))
        else
          local ls = {}
          for _, p in ipairs(pages) do ls[#ls + 1] = p.label end
          il:insert(pandoc.Str(table.concat(ls, ", ")))
        end
        add(P("CAToaEntry", il))
      end
    end
  end
  -- the end of the front matter: lower roman, the count going on from the cover when the cover counts
  add(raw_p('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr("rIdFtrPage", CFG.cover_counts and '<w:pgNumType w:fmt="lowerRoman"/>' or '<w:pgNumType w:fmt="lowerRoman" w:start="1"/>')
    .. '</w:pPr></w:p>'))

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

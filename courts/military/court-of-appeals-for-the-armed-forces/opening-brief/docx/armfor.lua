-- CAAF briefs, DOCX engine (docs/DOCX.md): the markdown contract -> Word, on docx/reference.docx.
-- Mirrors ../typst/armfor-*.typ (the typst template is the reference for the form):
--   cover (Rule 24(a) form), index of brief and table of authorities (roman front matter),
--   the body (arabic from 1, headings numbered as typst numbers them), signature block kept with
--   the last paragraph, certificates of compliance and of filing and service.
-- Environment:
--   ARMFOR_KIND    opening-brief | petition-supplement (the doc type; picks the cover line, limits, certificates)
--   ARMFOR_ITEMS   pass 1: write the page-search items to this file (H = heading, T = authority link)
--   ARMFOR_PAGES   pass 2: read one body page per item (same order) and print the index and table page numbers
-- Pages are found by render.sh from a first pass (pdftotext on the LibreOffice PDF). Without ARMFOR_PAGES
-- the page columns hold "0"; the body does not depend on them (the front matter is a separate section).

local KIND = os.getenv("ARMFOR_KIND") or "opening-brief"
local ITEMS_OUT = os.getenv("ARMFOR_ITEMS")
local PAGES_IN = os.getenv("ARMFOR_PAGES")

local CFG = {
  ["opening-brief"] = {
    word_limit = 13000, limit_rule = "Rule 24(b)(1)",
    cover_title = function(meta) return "BRIEF ON BEHALF OF " .. string.upper(stringify(meta.filer_role)) end,
    cover_par = 112, cover_gap = 224, cover_name_gap = 84,
    required = { {"issue"}, {"statement of statutory jurisdiction"}, {"statement of the case"},
      {"statement of facts"}, {"summary of argument"}, {"argument", true}, {"conclusion", true} },
    comp_heading = "Certificate of Compliance with Rule 24(b)",
    comp_text = function(n) return "This brief complies with the type-volume limitation of Rule 24(b) because: This brief contains "
      .. n .. " words. This brief complies with the typeface and type style requirements of Rule 37." end,
  },
  ["petition-supplement"] = {
    word_limit = 9000, limit_rule = "Rule 21(b)",
    cover_title = function() return "SUPPLEMENT TO PETITION FOR GRANT OF REVIEW" end,
    cover_par = 168, cover_gap = 336, cover_name_gap = 84,
    required = { {"issue"}, {"statement of statutory jurisdiction"}, {"statement of the case"},
      {"statement of facts"}, {"argument", true} },
    comp_heading = "Certificate of Compliance",
    comp_text = function(n) return "The undersigned counsel hereby certifies that: (1) this supplement complies with the type-volume limitation of Rule 21(b) because it contains "
      .. n .. " words; and (2) this supplement complies with the style requirements of Rule 37." end,
  },
}
local C = CFG[KIND] or error("armfor: unknown ARMFOR_KIND " .. KIND)
local PASS_NAME = { ["opening-brief"] = "armfor-opening-brief", ["petition-supplement"] = "armfor-petition-supplement" }
local TAG = PASS_NAME[KIND] or "armfor"

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

function stringify(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function rpr(o)
  local t = ""
  if o.b then t = t .. "<w:b/><w:bCs/>" end
  if o.i then t = t .. "<w:i/><w:iCs/>" end
  if o.u then t = t .. '<w:u w:val="single"/>' end
  if t == "" then return "" end
  return "<w:rPr>" .. t .. "</w:rPr>"
end

-- a text run (o: b, i, u)
local function R(text, o) return '<w:r>' .. rpr(o or {}) .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>' end
local TAB = '<w:r><w:tab/></w:r>'
local PLAIN_TABS = '<w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs>'

-- paragraph properties in schema order: keepNext, keepLines, tabs, spacing, ind, jc
local function pp(o)
  local s = ""
  if o.keep then s = s .. "<w:keepNext/><w:keepLines/>" end
  if o.tabs then s = s .. o.tabs end
  s = s .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>',
    o.before or 0, o.after or 0, o.line or 240, o.rule or "auto")
  if o.ind then s = s .. o.ind end
  if o.jc then s = s .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return s
end

local function P(o, inner)
  return '<w:p><w:pPr>' .. pp(o) .. '</w:pPr>' .. (inner or "") .. '</w:p>'
end

-- an empty line of exact height h (twips): the typst "v(...)" spacers
local function spacer(h)
  return P({ line = h, rule = "exact" }, "")
end

local DOT_TABS = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs>'
local PAGE_BREAK = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function roman(n)
  local vals = { {1000, "m"}, {900, "cm"}, {500, "d"}, {400, "cd"}, {100, "c"}, {90, "xc"}, {50, "l"},
    {40, "xl"}, {10, "x"}, {9, "ix"}, {5, "v"}, {4, "iv"}, {1, "i"} }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function letter(n) return string.char(64 + n) end
local function lower_letter(n) return string.char(96 + n) end

-- ---------------------------------------------------------------------------
-- headings: labels as typst numbers them (Argument: I. A. 1. a.; elsewhere A. 1. a. (1))
-- ---------------------------------------------------------------------------

local function label_for(level, inarg, n)
  if level == 1 then return nil end
  if inarg then
    if level == 2 then return string.upper(roman(n)) .. "." end
    if level == 3 then return letter(n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    if level == 5 then return lower_letter(n) .. "." end
  else
    if level == 2 then return letter(n) .. "." end
    if level == 3 then return tostring(n) .. "." end
    if level == 4 then return lower_letter(n) .. "." end
    if level == 5 then return "(" .. n .. ")" end
  end
  error(TAG .. ": headings deeper than level 5 are not supported")
end

local function lower_trim(s) return string.lower((s:gsub("^%s+", ""):gsub("%s+$", ""))) end

-- ---------------------------------------------------------------------------
-- the markdown body: headings, authority links, footnotes
-- ---------------------------------------------------------------------------

local function heading_model(blocks)
  local heads, counters, inarg = {}, { 0, 0, 0, 0, 0 }, false
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local text = stringify(b.content)
      if b.level == 1 then
        inarg = lower_trim(text) == "argument"
        for k = 1, 5 do counters[k] = 0 end
      else
        counters[b.level] = counters[b.level] + 1
        for k = b.level + 1, 5 do counters[k] = 0 end
      end
      local label = label_for(b.level, inarg and b.level >= 2, counters[b.level])
      local first = inarg and 3 or 2
      heads[#heads + 1] = {
        level = b.level, text = text, label = label, inarg = inarg, block = b,
        point = inarg and b.level == 2,
        -- label position: Hang k puts the label at 0.5 in times k (typst label-indent)
        pos = (b.level >= 2 and not (inarg and b.level == 2)) and (b.level - first + 1) or nil,
      }
    end
  end
  return heads
end

-- authority links in document order (footnotes included)
local function link_occurrences(doc)
  local links = {}
  doc:walk({
    Link = function(l)
      if l.target:sub(1, 4) == "toa:" then links[#links + 1] = { key = l.target:sub(5), text = stringify(l.content) } end
    end,
  })
  return links
end

local function word_count(doc)
  local n = 0
  doc:walk({
    Str = function(s) if s.text:find("%w") then n = n + 1 end end,
  })
  return n
end

-- ---------------------------------------------------------------------------
-- front matter
-- ---------------------------------------------------------------------------

local function need(meta, key)
  if meta[key] == nil then error(TAG .. ": missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function cover(meta)
  local out = {}
  local function line(text, o) out[#out + 1] = P(o, R(text, o.r)) end
  local par = C.cover_par
  line("IN THE UNITED STATES COURT OF APPEALS", { jc = "center", after = par, r = { b = true } })
  line("FOR THE ARMED FORCES", { jc = "center", after = C.cover_gap, r = { b = true } })
  -- caption: each side's names, its lines and its role; "v." between the sides
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    if i > 1 then line("v.", { jc = "center", before = par, after = par }) end
    local names = side.names or {}
    for j, n in ipairs(names) do
      line(stringify(n), { jc = "center", after = (j < #names) and C.cover_name_gap or 0 })
    end
    for _, l in ipairs(side.lines or {}) do line(stringify(l), { jc = "center" }) end
    line(stringify(side.role), { jc = "center", after = par, r = { i = true } })
  end
  out[#out + 1] = spacer(C.cover_gap)
  line(C.cover_title(meta), { jc = "center", after = C.cover_gap, r = { b = true } })
  line(stringify(need(meta, "crim_app_dkt")), { jc = "center", after = 0 })
  line(stringify(need(meta, "uscaaf_dkt")), { jc = "center", after = C.cover_gap })
  line("TO THE JUDGES OF THE UNITED STATES COURT OF APPEALS FOR THE ARMED FORCES:", { jc = "left", after = C.cover_gap })
  -- counsel block: a two-column table placed at the bottom of the text area (floating)
  local groups = need(meta, "counsel")
  local rows = {}
  for i = 1, #groups, 2 do rows[#rows + 1] = { groups[i], groups[i + 1] } end
  local function cell(g, right)
    if g == nil then return '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/></w:tcPr><w:p/></w:tc>' end
    local ps = {}
    local names = g.names or {}
    for _, n in ipairs(names) do ps[#ps + 1] = P({ after = 0 }, R(stringify(n))) end
    for _, l in ipairs(g.lines or {}) do ps[#ps + 1] = P({ after = 0 }, R(stringify(l), { i = true })) end
    ps[#ps] = ps[#ps]:gsub('w:after="0"', 'w:after="336"', 1)
    return '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
  end
  local trs = {}
  for _, r in ipairs(rows) do
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(r[1], false) .. cell(r[2], true) .. '</w:tr>'
  end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  local tbl = '<w:tbl><w:tblPr><w:tblpPr w:leftFromText="0" w:rightFromText="0" w:vertAnchor="margin" w:horzAnchor="margin" w:tblpX="0" w:tblpYSpec="bottom"/>'
    .. '<w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblBorders>' .. none .. '</w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="4680"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
  out[#out + 1] = tbl
  return out
end

-- a section break paragraph: ends the section above it
local function section_break(fmt, footer)
  local ref = footer and '<w:footerReference w:type="default" r:id="rId100"/>' or ''
  local num = fmt and string.format('<w:pgNumType w:fmt="%s" w:start="1"/>', fmt) or ''
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:sectPr>' .. ref
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. num .. '</w:sectPr></w:pPr></w:p>'
end

-- sort key of an authority: its name when it has one, else its cite
local function authority_list(meta)
  local auth = meta.authorities or {}
  local list = {}
  for k, a in pairs(auth) do
    list[#list + 1] = { key = k, kind = stringify(a.kind), cite = stringify(a.cite),
      name = a.name and stringify(a.name) or nil }
  end
  return list
end

local TOA_GROUPS = {
  { "constitution", "Constitutional Provisions" },
  { "scotus", "Supreme Court of the United States" },
  { "caaf", "Court of Appeals for the Armed Forces and Court of Military Appeals" },
  { "service", "Service Courts of Criminal Appeals" },
  { "other-court", "State and Other Federal Court Cases" },
  { "statute", "Statutes" },
  { "rule", "Rules and Other Authorities" },
  { "other", "Other Authorities" },
}
local CASE_KINDS = { scotus = true, caaf = true, service = true, ["other-court"] = true }

local function toa_section(meta, occ, pages_of)
  local out = {}
  out[#out + 1] = P({ keep = true, jc = "center", before = 420, after = 308, tabs = DOT_TABS }, R("Table of Cases, Statutes, and Other Authorities", { b = true }))
  local hits = {}
  for _, o in ipairs(occ) do hits[o.key] = true end
  local auth = meta.authorities or {}
  for _, o in ipairs(occ) do
    if auth[o.key] == nil then error(TAG .. ": link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter") end
  end
  local list = authority_list(meta)
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for _, a in ipairs(list) do
      if a.kind == g[1] and hits[a.key] then members[#members + 1] = a end
    end
    table.sort(members, function(x, y)
      return string.lower(x.name or x.cite) < string.lower(y.name or y.cite)
    end)
    if #members > 0 then
      local head = R(g[2], { b = true })
      if first then head = head .. TAB .. R("Page(s)", { b = true, u = true }) end
      out[#out + 1] = P({ keep = true, before = first and 280 or 392, after = 56, tabs = PLAIN_TABS }, head)
      first = false
      for _, a in ipairs(members) do
        local pages = pages_of[a.key]
        local text
        if #pages >= 7 then text = R("passim", { i = true }) else text = R(table.concat(pages, ", ")) end
        local name = ""
        if a.name then
          name = R(a.name, { i = CASE_KINDS[a.kind] or false }) .. R(", ")
        end
        out[#out + 1] = P({ keep = false, before = 196, after = 0, tabs = DOT_TABS,
          ind = '<w:ind w:left="504" w:hanging="504"/>' },
          name .. R(a.cite) .. TAB .. text)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- back matter: signature block and certificates
-- ---------------------------------------------------------------------------

local SIG_IND = '<w:ind w:left="4680" w:firstLine="0"/>'

local function signature_block(meta, keep_first)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = P({ keep = true, before = 392, after = 140, ind = SIG_IND }, R("/s/ " .. stringify(sig.signer)))
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do
    out[#out + 1] = P({ keep = (i < #lines) or (meta.date ~= nil), ind = SIG_IND }, R(stringify(l)))
  end
  if meta.date ~= nil then
    out[#out + 1] = spacer(224)
    out[#out + 1] = P({ ind = SIG_IND }, R("Dated: " .. stringify(meta.date)))
  end
  return table.concat(out)
end

local function certificate_of_compliance(meta, n)
  local out = {}
  out[#out + 1] = P({ keep = true, jc = "center", before = 420, after = 308, tabs = DOT_TABS }, R(C.comp_heading, { b = true }))
  out[#out + 1] = P({ keep = true, before = 0, after = 280 }, R(C.comp_text(n)))
  out[#out + 1] = spacer(336)
  out[#out + 1] = signature_block({ signature = need(meta, "signature") }, false)
  return table.concat(out)
end

local function certificate_of_service(meta)
  local svc = need(meta, "service")
  local out = {}
  out[#out + 1] = P({ keep = true, jc = "center", before = 420, after = 308 }, R("Certificate of Filing and Service", { b = true }))
  out[#out + 1] = P({ keep = true, before = 0, after = 280 }, R("I certify that a copy of the foregoing was electronically filed with the Court and electronically served on "
    .. stringify(svc["served-on"]) .. " on " .. stringify(need(meta, "date")) .. "."))
  out[#out + 1] = spacer(336)
  out[#out + 1] = signature_block({ signature = need(meta, "signature") }, false)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the document
-- ---------------------------------------------------------------------------

local function check_structure(heads)
  local titles = {}
  for _, h in ipairs(heads) do if h.level == 1 then titles[#titles + 1] = lower_trim(h.text) end end
  local i = 1
  for _, req in ipairs(C.required) do
    local found = false
    while i <= #titles and not found do
      local t = titles[i]
      if req[2] then found = (t == req[1]) else found = (t:find(req[1], 1, true) ~= nil) end
      i = i + 1
    end
    if not found then
      error(TAG .. ": required section `" .. req[1] .. "` is missing or out of order (" .. C.limit_rule:gsub("%(.*", "") .. ")")
    end
  end
  for _, h in ipairs(heads) do
    if lower_trim(h.text):find("standard of review", 1, true) then return end
  end
  error(TAG .. ": no heading names the standard of review (Rule 24(a), Argument)")
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "crim_app_dkt", "uscaaf_dkt", "caption", "counsel", "signature", "date", "service" }) do need(meta, k) end
  local blocks = doc.blocks
  -- authority links become plain text (the table of authorities is ours); after the occurrences are taken
  local heads = heading_model(blocks)
  check_structure(heads)

  -- length (the typst count: body markdown, footnotes and headings included)
  local words = word_count(pandoc.Pandoc(blocks))
  if words > C.word_limit then
    error(TAG .. ": the document has " .. words .. " words; " .. C.limit_rule .. " allows " .. C.word_limit)
  end

  -- authority occurrences in order; pass 1 writes the search items, pass 2 reads the pages
  local occ = link_occurrences(doc)
  if ITEMS_OUT then
    local f = assert(io.open(ITEMS_OUT, "w"))
    for _, h in ipairs(heads) do
      f:write("H\t" .. h.text .. "\n")
    end
    for _, o in ipairs(occ) do f:write("T\t" .. o.text .. "\n") end
    f:close()
  end
  blocks = pandoc.Pandoc(blocks):walk({ Link = function(l)
    if l.target:sub(1, 4) == "toa:" then return pandoc.Span(l.content) end
    return nil
  end }).blocks
  local pages = {}
  if PAGES_IN then
    local f = assert(io.open(PAGES_IN, "r"), "armfor: cannot read " .. PAGES_IN)
    for l in f:lines() do pages[#pages + 1] = l end
    f:close()
    if #pages ~= #heads + #occ then
      error(TAG .. ": " .. #pages .. " pages for " .. (#heads + #occ) .. " search items")
    end
  end
  local function page_of(i) return pages[i] or "0" end
  local pages_of = {}
  for j, o in ipairs(occ) do
    local p = page_of(#heads + j)
    pages_of[o.key] = pages_of[o.key] or {}
    local seen = false
    for _, q in ipairs(pages_of[o.key]) do if q == p then seen = true end end
    if not seen then pages_of[o.key][#pages_of[o.key] + 1] = p end
  end
  for _, v in pairs(pages_of) do
    table.sort(v, function(x, y) return tonumber(x) < tonumber(y) end)
  end

  -- ---- front matter: cover (no footer), index and authorities (roman) ----
  local front = {}
  for _, b in ipairs(cover(meta)) do front[#front + 1] = b end
  front[#front + 1] = section_break(nil, false)

  front[#front + 1] = P({ keep = true, jc = "center", before = 0, after = 308 }, R("Index of Brief", { b = true }))
  front[#front + 1] = P({ jc = "right", after = 0, before = 0 }, R("Page", { b = true, u = true }))
  for i, h in ipairs(heads) do
    if h.level <= 4 then
      local p = page_of(i)
      local xml
      if h.level == 1 then
        xml = P({ before = 168, after = 0, tabs = DOT_TABS, ind = '<w:ind w:left="720" w:hanging="720"/>' },
          R(h.text) .. TAB .. R(p))
      elseif h.point then
        xml = P({ before = 98, after = 0, tabs = DOT_TABS, ind = '<w:ind w:left="720" w:hanging="720"/>' },
          R(h.label) .. TAB .. R(h.text) .. TAB .. R(p))
      else
        local left = 720 * (h.pos + 1)
        xml = P({ before = 98, after = 0, tabs = DOT_TABS, ind = string.format('<w:ind w:left="%d" w:hanging="720"/>', left) },
          R(h.label) .. TAB .. R(h.text) .. TAB .. R(p))
      end
      front[#front + 1] = xml
    end
  end
  front[#front + 1] = PAGE_BREAK
  for _, b in ipairs(toa_section(meta, occ, pages_of)) do front[#front + 1] = b end
  front[#front + 1] = section_break("lowerRoman", true)

  -- ---- body (arabic from 1; the final section of the document) ----
  local body = {}
  local hi = 0
  local last_is_para = false
  local first_h1 = true
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      hi = hi + 1
      local h = heads[hi]
      local content = { pandoc.Strong(b.content) }
      if h.level == 1 then
        -- the first heading of the body starts a page: no space above it (as typst)
        local style = first_h1 and "Section Head Top" or "Section Head"
        first_h1 = false
        body[#body + 1] = pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
      elseif h.point then
        local inl = { pandoc.Strong({ pandoc.Str(h.label), pandoc.Space() }) }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        body[#body + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong(inl) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Point Head" }))
      else
        local inl = { pandoc.Strong({ pandoc.Str(h.label) }), pandoc.RawInline("openxml", TAB) }
        inl[#inl + 1] = pandoc.Strong(b.content)
        body[#body + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Hang " .. h.pos }))
      end
      last_is_para = false
    else
      body[#body + 1] = b
      last_is_para = (b.t == "Para")
    end
  end
  -- the signature block never stands alone: the last paragraph is kept with it
  if last_is_para then
    local b = body[#body]
    body[#body] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Keep Body" }))
  end

  -- the body document: its blocks, then the signature, then the certificates
  local tail = {}
  tail[#tail + 1] = raw(signature_block(meta, true))
  tail[#tail + 1] = raw(PAGE_BREAK)
  tail[#tail + 1] = raw(certificate_of_compliance(meta, words))
  if meta.service.certificate then
    tail[#tail + 1] = raw(PAGE_BREAK)
    tail[#tail + 1] = raw(certificate_of_service(meta))
  end

  local all = {}
  for _, b in ipairs(front) do
    if type(b) == "string" then all[#all + 1] = raw(b) else all[#all + 1] = b end
  end
  for _, b in ipairs(body) do all[#all + 1] = b end
  for _, b in ipairs(tail) do all[#all + 1] = b end
  return pandoc.Pandoc(all, {})
end


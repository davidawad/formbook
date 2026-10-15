-- AFCCA brief, DOCX engine (docs/DOCX.md). The markdown sample -> a Word document on reference.docx, to the form
-- of typst/afcca-opening-brief.typ. Identical in the opening-brief and answering-brief folders.
--
-- What the filter builds (the typst template's parts, in order):
--   caption page (court line, caption table, counsel block, and the TO THE HONORABLE line when not indexed);
--   with `index: true`: a section break, the table of contents and the table of authorities (lower-case roman
--   pages, the caption page unnumbered), a section break, then the body from page 1;
--   the body (headings numbered I./A./1./a. in the roman sections, as typst computes them), the signature block,
--   and the certificate on a new page.
-- Page references in the table of contents and table of authorities are PAGEREF fields to bookmarks written
-- beside each heading and each citation. Word and LibreOffice compute them on layout; the cached result is "1".
-- Known limits (BLOCKED, see the README "Engines" section): a table of authorities lists one page reference per
-- citation, so two citations on one page print that page twice (typst lists each page once); "passim" is printed
-- at 7 or more citations (typst: 7 or more pages).

local ROMAN = {
  ["assignments of error"] = true, ["assignment of error"] = true, ["issues presented"] = true,
  ["argument"] = true, ["additional arguments"] = true, ["reply argument"] = true,
}
local CHAINED = { ["assignments of error"] = true, ["assignment of error"] = true, ["issues presented"] = true }
local UNNUMBERED = {
  ["standard of review"] = true, ["law and analysis"] = true, ["law & analysis"] = true, ["additional facts"] = true,
}
local TOC_DEPTH = 4
local PASSIM = 7
local GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

-- Cached page labels for the PAGEREF fields (written by docx/render.sh from the first-pass PDF): "name<TAB>label".
local PAGES = {}
local pages_file = os.getenv("AFCCA_PAGES")
if pages_file and pages_file ~= "" then
  local fh = assert(io.open(pages_file, "r"))
  for line in fh:lines() do
    local n, l = line:match("^([^\t]+)\t(.*)$")
    if n then PAGES[n] = l end
  end
  fh:close()
end
-- Pass 1 writes the heading and citation texts that render.sh searches for (AFCCA_TARGETS).
local targets_file = os.getenv("AFCCA_TARGETS")
local head_targets, hit_targets = {}, {}

local function norm(s)
  local t = s:lower():gsub("^%s+", ""):gsub("%s+$", "")
  return t
end
local function text_of(x) return pandoc.utils.stringify(x) end
local function need(meta, key)
  if meta[key] == nil then error("afcca.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function para(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end
local function raw(x) return pandoc.RawInline("openxml", x) end
local TAB = raw('<w:r><w:tab/></w:r>')
local LB = pandoc.LineBreak()
local function bm_start(id, name)
  return raw(string.format('<w:bookmarkStart w:id="%d" w:name="%s"/>', id, name))
end
local function bm_end(id) return raw(string.format('<w:bookmarkEnd w:id="%d"/>', id)) end
local function pageref(name)
  return raw(string.format('<w:fldSimple w:instr=" PAGEREF %s \\h "><w:r><w:t>%s</w:t></w:r></w:fldSimple>', name, PAGES[name] or "1"))
end

-- Section breaks: the caption page (unnumbered, index only), the front matter (lower-case roman from ii), and the
-- body (the final section, decimal from 1, set in reference.docx).
local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local FOOTER = '<w:footerReference w:type="default" r:id="rIdAfccaFooter"/>'
local function section_break(sectpr_inner)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'
    .. '<w:rPr><w:sz w:val="2"/></w:rPr><w:sectPr>' .. FOOTER .. PG .. sectpr_inner .. '</w:sectPr></w:pPr></w:p>')
end

local function roman_upper(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- The printed label of a numbered sub-heading (typst heading-label): I. / A. / 1. / a.
local function label_for(level, n)
  if level == 2 then return roman_upper(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return tostring(n) .. "." end
  if level == 5 then return string.char(96 + n) .. "." end
  error("afcca.lua: headings deeper than level 5 are not supported")
end

local function as_inlines(v)
  if type(v) == "string" then return { pandoc.Str(v) } end
  return pandoc.Inlines(v)
end

function Pandoc(doc)
  local meta = doc.meta
  local index = meta.index == true
  local authorities = meta.authorities or {}
  local sig = meta.signature
  local cert = meta.certificate
  local blocks = doc.blocks

  -- ---------------------------------------------------------------- caption page
  local caption = {}
  local lhs, rhs, paren = {}, {}, {}
  local first = true
  for _, side in ipairs(need(meta, "caption")) do
    if not first then lhs[#lhs + 1] = para("CaptionVersus", { pandoc.Str("v.") }) end
    first = false
    for _, n in ipairs(side.names) do lhs[#lhs + 1] = para("CaptionLine", as_inlines(n)) end
    lhs[#lhs + 1] = para("CaptionDesignation", as_inlines(side.designation))
  end
  rhs = {
    para("CaptionTitle", as_inlines(need(meta, "brief_title"))), para("CaptionLine", {}),
    para("CaptionLine", as_inlines(need(meta, "panel"))), para("CaptionLine", {}),
    para("CaptionLine", as_inlines(need(meta, "case_number"))), para("CaptionLine", {}),
    para("CaptionLine", as_inlines(need(meta, "date"))),
  }
  for _ = 1, #lhs do paren[#paren + 1] = para("CaptionLine", { pandoc.Str(")") }) end
  local tbl = pandoc.Table(
    pandoc.Caption(),
    { { pandoc.AlignDefault, 0.54 }, { pandoc.AlignDefault, 0.06 }, { pandoc.AlignDefault, 0.40 } },
    pandoc.TableHead({}),
    { pandoc.TableBody({ pandoc.Row({ pandoc.Cell(lhs), pandoc.Cell(paren), pandoc.Cell(rhs) }) }) },
    pandoc.TableFoot({})
  )
  caption[#caption + 1] = para("CourtLine", { pandoc.Str("IN THE UNITED STATES AIR FORCE COURT OF CRIMINAL APPEALS") })
  caption[#caption + 1] = tbl
  if meta.counsel then
    for _, group in ipairs(meta.counsel) do
      caption[#caption + 1] = para("Spacer", {})
      local inl = {}
      for i, line in ipairs(group) do
        if i > 1 then inl[#inl + 1] = LB end
        for _, x in ipairs(as_inlines(line)) do inl[#inl + 1] = x end
      end
      caption[#caption + 1] = para("CounselBlock", inl)
    end
  end
  local honorable = "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES AIR FORCE COURT OF CRIMINAL APPEALS:"
  if not index then
    caption[#caption + 1] = para("Honorable", { pandoc.Str(honorable) })
  end

  local out = {}
  for _, b in ipairs(caption) do out[#out + 1] = b end
  if index then
    out[#out + 1] = section_break('<w:pgNumType w:fmt="decimal" w:start="1"/><w:titlePg/>')
  end

  -- ---------------------------------------------------------------- headings (numbering as typst computes it)
  local counters = { 0, 0, 0, 0, 0, 0 }
  local roman_sec, cur_sec = false, ""
  local bm_id = 100
  local heads = {}            -- {level, label, content, name} for the table of contents
  local function heading(h)
    local L = h.level
    local key = norm(text_of(h.content))
    for k = L + 1, 6 do counters[k] = 0 end
    local unnum = UNNUMBERED[key] == true
    if L == 1 then roman_sec = ROMAN[key] == true; cur_sec = key end
    if not unnum then counters[L] = counters[L] + 1 end
    local label = nil
    if L >= 2 and roman_sec and not unnum then label = label_for(L, counters[L]) end
    bm_id = bm_id + 1
    local name = "_Head" .. bm_id
    local bs, be = bm_start(bm_id, name), bm_end(bm_id)
    local content = h.content
    head_targets[#head_targets + 1] = { name = name, text = text_of(content) }
    if L <= TOC_DEPTH then heads[#heads + 1] = { level = L, label = label, content = content, name = name } end
    local with_bm = { bs }
    for _, x in ipairs(content) do with_bm[#with_bm + 1] = x end
    with_bm[#with_bm + 1] = be
    if L == 1 then
      return para("SectionHeading", with_bm)
    elseif label and L == 2 then
      local style = CHAINED[cur_sec] and "PointHeadingChained" or "PointHeading"
      local inl = { pandoc.Str(label), LB }
      for _, x in ipairs(with_bm) do inl[#inl + 1] = x end
      return para(style, inl)
    elseif label then
      local body = with_bm
      if L >= 4 then body = { pandoc.Emph(with_bm) } end
      local inl = { pandoc.Str(label), TAB }
      for _, x in ipairs(body) do inl[#inl + 1] = x end
      return para("SubHeading" .. math.min(L, 5), inl)
    else
      return para(roman_sec and "UnnumberedHeadingCentered" or "UnnumberedHeadingLeft", with_bm)
    end
  end

  local body = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then body[#body + 1] = heading(b) else body[#body + 1] = b end
  end

  -- ---------------------------------------------------------------- citations (toa: links -> bookmarks)
  local hits = {}             -- {key, name} in document order
  local hit_id = 5000
  local bodydoc = pandoc.Pandoc(body):walk({
    Link = function(l)
      if l.target:sub(1, 4) == "toa:" then
        local key = l.target:sub(5)
        if authorities[key] == nil then
          error("afcca.lua: link `" .. l.target .. "` has no entry under `authorities:` in the frontmatter")
        end
        hit_id = hit_id + 1
        local name = "_Hit" .. hit_id
        hits[#hits + 1] = { key = key, name = name }
        hit_targets[#hit_targets + 1] = { name = name, text = text_of(l.content) }
        local inl = { bm_start(hit_id, name) }
        for _, x in ipairs(l.content) do inl[#inl + 1] = x end
        inl[#inl + 1] = bm_end(hit_id)
        return inl
      end
      return l.content
    end,
  })
  body = bodydoc.blocks

  -- ---------------------------------------------------------------- table of contents and authorities
  local front = {}
  if index then
    front[#front + 1] = para("SectionHeading", { pandoc.Str("Table of Contents") })
    front[#front + 1] = para("TocPageLabel", { pandoc.Str("Page") })
    for _, hd in ipairs(heads) do
      local lvl = hd.level
      local inl = {}
      if hd.label then inl[#inl + 1] = pandoc.Str(hd.label); inl[#inl + 1] = TAB end
      for _, x in ipairs(hd.content) do inl[#inl + 1] = x end
      inl[#inl + 1] = TAB
      inl[#inl + 1] = pageref(hd.name)
      front[#front + 1] = para("TocEntry" .. lvl, inl)
    end

    front[#front + 1] = para("SectionHeadingBreak", { pandoc.Str("Table of Authorities") })
    for gi, g in ipairs(GROUPS) do
      local members = {}
      for key, a in pairs(authorities) do
        local kind = text_of(a.kind)
        local used = false
        for _, h in ipairs(hits) do if h.key == key then used = true; break end end
        if kind == g[1] and used then members[#members + 1] = { key = key, a = a } end
      end
      if #members > 0 then
        local function sort_key(m)
          local s = m.a.sort and text_of(m.a.sort) or ((m.a.name and text_of(m.a.name) or "") .. " " .. text_of(m.a.cite))
          return s:lower():gsub("[^a-z0-9 ]", "")
        end
        table.sort(members, function(x, y) return sort_key(x) < sort_key(y) end)
        local head = { pandoc.Str(g[2]) }
        if gi == 1 or not front.toa_first_done then
          front.toa_first_done = true
          head[#head + 1] = TAB
          head[#head + 1] = pandoc.Strong({ pandoc.Underline({ pandoc.Str("Page(s)") }) })
        end
        front[#front + 1] = para("ToaGroup", head)
        for _, m in ipairs(members) do
          local inl = {}
          if m.a.name then
            local nm = as_inlines(m.a.name)
            if text_of(m.a.kind) == "case" then nm = { pandoc.Emph(nm) } end
            for _, x in ipairs(nm) do inl[#inl + 1] = x end
            inl[#inl + 1] = pandoc.Str(",")
            inl[#inl + 1] = LB
          end
          for _, x in ipairs(as_inlines(m.a.cite)) do inl[#inl + 1] = x end
          inl[#inl + 1] = TAB
          local n = 0
          for _, h in ipairs(hits) do if h.key == m.key then n = n + 1 end end
          if n >= PASSIM then
            inl[#inl + 1] = pandoc.Emph({ pandoc.Str("passim") })
          else
            local first_p = true
            for _, h in ipairs(hits) do
              if h.key == m.key then
                if not first_p then inl[#inl + 1] = pandoc.Str(", ") end
                first_p = false
                inl[#inl + 1] = pageref(h.name)
              end
            end
          end
          front[#front + 1] = para("ToaEntry", inl)
        end
      end
    end
    front[#front + 1] = section_break('<w:pgNumType w:fmt="lowerRoman" w:start="2"/>')
    front.toa_first_done = nil
  end

  for _, b in ipairs(front) do out[#out + 1] = b end

  -- ---------------------------------------------------------------- body, signature and certificate
  if index then
    out[#out + 1] = para("HonorableTop", { pandoc.Str(honorable) })
  end
  for _, b in ipairs(body) do out[#out + 1] = b end
  if sig ~= nil then
    local closing = sig.closing and text_of(sig.closing) or "Respectfully submitted,"
    if closing ~= "" then out[#out + 1] = para("SignatureClosing", { pandoc.Str(closing) }) end
    local inl = { pandoc.Strong(as_inlines(sig.signer)) }
    for _, line in ipairs(sig.lines) do
      inl[#inl + 1] = LB
      for _, x in ipairs(as_inlines(line)) do inl[#inl + 1] = x end
    end
    out[#out + 1] = para(closing ~= "" and "SignatureBlock" or "SignatureBlockAlone", inl)
  end
  if cert ~= nil then
    out[#out + 1] = para("SectionHeadingBreak", { pandoc.Str("Certificate of Filing and Service") })
    local inl = { pandoc.Str("I certify that the original and copies of the foregoing were ") }
    for _, x in ipairs(as_inlines(cert.method)) do inl[#inl + 1] = x end
    inl[#inl + 1] = pandoc.Str(" to the Court and served on ")
    for _, x in ipairs(as_inlines(cert.recipient)) do inl[#inl + 1] = x end
    inl[#inl + 1] = pandoc.Str(" on ")
    for _, x in ipairs(as_inlines(cert.date)) do inl[#inl + 1] = x end
    inl[#inl + 1] = pandoc.Str(".")
    out[#out + 1] = para("CertificateBody", inl)
    local sinl = { pandoc.Strong(as_inlines(cert.signer)) }
    for _, line in ipairs(cert.lines) do
      sinl[#sinl + 1] = LB
      for _, x in ipairs(as_inlines(line)) do sinl[#sinl + 1] = x end
    end
    out[#out + 1] = para("SignatureBlockAlone", sinl)
  end

  if targets_file and targets_file ~= "" then
    local function clean(s) return (s:gsub("[\t\r\n]", " ")) end
    local fh = assert(io.open(targets_file, "w"))
    fh:write("I\tindex\t", index and "1" or "0", "\n")
    for _, t in ipairs(head_targets) do fh:write("H\t", t.name, "\t", clean(t.text), "\n") end
    for _, t in ipairs(hit_targets) do fh:write("T\t", t.name, "\t", clean(t.text), "\n") end
    fh:close()
  end
  -- Line breaks inside a citation: typst keeps ")(" tokens and "§ N" together. Word joiner and no-break space here.
  local function fix(s) return (s:gsub("%)%(", ")\u{2060}(")) end
  return pandoc.Pandoc(out, pandoc.Meta({})):walk({
    Str = function(el) el.text = fix(el.text); return el end,
    Inlines = function(ins)
      local res = {}
      for _, x in ipairs(ins) do
        if x.t == "Space" and #res > 0 and res[#res].t == "Str" and res[#res].text:sub(-2) == "\u{00A7}" then
          res[#res + 1] = pandoc.Str("\u{00A0}")
        else
          res[#res + 1] = x
        end
      end
      return res
    end,
  })
end

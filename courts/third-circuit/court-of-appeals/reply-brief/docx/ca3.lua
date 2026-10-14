-- U.S. Court of Appeals for the Third Circuit: pandoc filter for the docx engine (one copy per doc type).
-- The same content as the typst and LaTeX templates of this doc type, from the same markdown contract.
-- The cover, the headings, the signature blocks and the certificates are written as WordprocessingML
-- paragraphs; the body paragraphs stay pandoc's. Styles come from reference.docx (EB Garamond 14 pt,
-- double spaced). Known gaps (docs/DOCX.md, and the BLOCKED list in README.md): the table of contents and
-- the table of authorities are fields/lists without page numbers, and the footer page numbers are absent.
-- The only line that differs between the copies is TYPE.

local TYPE = "reply" -- "opening" | "answering" | "reply"

local LIMIT = ({ opening = 13000, answering = 13000, reply = 6500 })[TYPE]
local SCHEME = (TYPE == "opening") and "opening" or "argument"
local PREPARED_WITH = "Microsoft Word (docx engine)"

local TOA_GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("ca3-" .. TYPE .. ": missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- One WordprocessingML paragraph. opts: jc (alignment), ind_left (twips), bold, pstyle, before_break,
-- keep_next, line (240 = single, 480 = double), after (twips).
local function para(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.pstyle then ppr = ppr .. '<w:pStyle w:val="' .. opts.pstyle .. '"/>' end
  if opts.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if opts.before_break then ppr = ppr .. "<w:pageBreakBefore/>" end
  ppr = ppr .. '<w:spacing w:before="0" w:after="' .. (opts.after or 0) .. '" w:line="' .. (opts.line or 240) .. '" w:lineRule="auto"/>'
  if opts.ind_left then ppr = ppr .. '<w:ind w:left="' .. opts.ind_left .. '"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local rpr = opts.bold and "<w:rPr><w:b/></w:rPr>" or ""
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr><w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r></w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return string.upper(out)
end

local function label_for(level, n, in_arg)
  if SCHEME == "opening" or in_arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    if level == 5 then return string.char(96 + n) .. "." end
  else
    if level == 2 then return string.char(64 + n) .. "." end
    if level == 3 then return tostring(n) .. "." end
    if level == 4 then return string.char(96 + n) .. "." end
    if level == 5 then return "(" .. n .. ")" end
  end
  error("ca3-" .. TYPE .. ": headings deeper than level 5 are not supported")
end

local function count_words(src)
  local s = src
  s = s:gsub("<!%-%-.-%-%->", " ")
  s = s:gsub("%[%^[^%]]+%]:", " ")
  s = s:gsub("%[%^[^%]]+%]", "")
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("^#+[ \t]+", "")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[-*+][ \t]+", "\n")
  s = s:gsub("\n[ \t]*%d+[.)][ \t]+", "\n")
  s = s:gsub("%*", "")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function body_source()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local body = src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n(.*)$") or src
  local s = body:find("\n#[ \t]+[Aa]ddendum[ \t]*\r?\n")
  if s then return body:sub(1, s) end
  return body
end

local function body_words(meta)
  local n = count_words(body_source())
  if TYPE == "opening" then
    n = n + count_words(text(need(meta, "related_cases")))
  end
  return n
end

-- Plain text for a metadata string list item (name lines, counsel lines).
local function lines_of(list)
  local out = {}
  for _, v in ipairs(list or {}) do out[#out + 1] = text(v) end
  return out
end

-- The cover, centered and single spaced.
local function cover(meta)
  local out = {}
  local function c(s, bold) out[#out + 1] = raw(para(s, { jc = "center", bold = bold })) end
  c("No. " .. text(need(meta, "case_number")), true)
  c("")
  if TYPE == "opening" then
    c("IN THE UNITED STATES COURT OF APPEALS FOR THE THIRD CIRCUIT", true)
  else
    c("IN THE UNITED STATES COURT OF APPEALS", true)
    c("FOR THE THIRD CIRCUIT", true)
  end
  c("")
  for i, side in ipairs(need(meta, "caption")) do
    for _, n in ipairs(side.names) do c(text(n)) end
    c(text(side.designation))
    if i < #need(meta, "caption") then c("v.") end
  end
  c("")
  c(text(need(meta, "proceeding")))
  if meta.district_court_case then c(TYPE == "answering" and ("D.C. No. " .. text(meta.district_court_case)) or
    (TYPE == "opening" and ("(" .. text(meta.district_court_case) .. ")") or ("No. " .. text(meta.district_court_case)))) end
  if meta.judge then c(TYPE == "opening" and ("(" .. text(meta.judge) .. ")") or text(meta.judge)) end
  c("")
  c(string.upper(text(need(meta, "brief_title"))), true)
  if meta.appendix then c(text(meta.appendix)) end
  c("")
  for _, g in ipairs(need(meta, "counsel")) do
    for _, n in ipairs(g.names) do c(text(n), false) end
    for _, l in ipairs(lines_of(g.lines)) do c(l) end
    c("")
  end
  c(text(need(meta, "phone")))
  if meta.counsel_for then c(text(meta.counsel_for)) end
  out[#out + 1] = raw(para("", { before_break = false }))
  return out
end

-- Signature lines in the right half of the page (indent 3 inches), single spaced.
local function signature(meta, respect, with_date)
  local sig = need(meta, "signature")
  local out = {}
  local function s(t) out[#out + 1] = raw(para(t, { ind_left = 4320, keep_next = true })) end
  if respect then s("Respectfully submitted,"); s("") end
  s("/s/ " .. text(sig.signer))
  if TYPE ~= "opening" then s(string.upper(text(sig.signer))) end
  for _, l in ipairs(lines_of(sig.lines)) do s(l) end
  if with_date and meta.date then s(""); s(text(meta.date)) end
  return out
end

local function heading_xml(level, label, title, centered)
  local jc = (level == 1 or centered) and "center" or nil
  local t = (label ~= "" and (label .. " ") or "") .. title
  return raw(para(string.upper(level == 1 and title or t), {
    pstyle = "Heading" .. math.min(level, 5), jc = jc, keep_next = true, before_break = false, line = 240, after = 240,
  }))
end

local function certificates(meta, words)
  local out = {}
  local function cert(title, body_paras, sig_fn)
    out[#out + 1] = raw(para(string.upper(title), { pstyle = "Heading1", jc = "center", before_break = true, line = 240, after = 240, keep_next = true }))
    for _, p in ipairs(body_paras) do out[#out + 1] = raw(para(p, { line = 480, after = 0 })) end
    for _, x in ipairs(sig_fn()) do out[#out + 1] = x end
  end
  if TYPE == "opening" then
    cert("Certificate of Compliance", {
      "This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f).",
      "This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because it has been prepared in a proportionally spaced typeface using " .. PREPARED_WITH .. " in font size 14, font style EB Garamond.",
    }, function() return signature(meta, false, true) end)
    cert("Certification of Bar Membership", {
      "I certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court, or has filed an application for admission under 3d Cir. L.A.R. 46.1.",
    }, function() return signature(meta, false, true) end)
    local body = { "I certify that the text of the E-Brief and the text of the hard copies of this brief are identical." }
    if meta.virus_software then body[#body + 1] = "I certify that a virus check was performed on the PDF file of this brief. The virus software used was " .. text(meta.virus_software) .. "." end
    cert("Certification of Text of E-Brief and Virus Check", body, function() return signature(meta, false, true) end)
    local service = meta.service and meta.service.certificate
    if service == nil or service == true then
      cert("Certificate of Service", {
        "I, " .. text(need(meta, "signature").signer) .. ", counsel for the filer and a member of the bar of this Court, certify that, on " .. text(need(meta, "date")) .. ", the brief and all accompanying appendices were filed electronically through the appellate CM/ECF system with the Clerk of Court. I further certify that all parties required to be served have been served.",
      }, function() return signature(meta, false, true) end)
    end
  elseif TYPE == "answering" then
    cert("Certificate of Bar Membership", {
      "I hereby certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court.",
    }, function() return signature(meta, false, false) end)
    cert("Electronic-Filing Certification", {
      "I hereby certify that the text of the electronically filed brief is identical to the text in the paper copies. I also certify that a virus detection program has been run on the electronic file and that no virus was detected. The virus detection program used, and its version, is ____________________.",
    }, function() return signature(meta, false, false) end)
    cert("Certificate of Compliance", {
      "1. This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f). The count includes " .. tostring(meta.manual_image_words or 0) .. " words counted by hand in any visual images.",
      "2. This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because it has been prepared in a proportionally spaced typeface using " .. PREPARED_WITH .. " in 14-point, EB Garamond.",
    }, function() return signature(meta, false, false) end)
    if meta.service then
      local svc = meta.service
      local paras = { "I certify that on " .. text(svc.date) .. " I caused the foregoing " .. text(need(meta, "brief_title")) .. " to be served by " .. text(svc.method) .. " on the following:" }
      for _, u in ipairs(svc.to or {}) do paras[#paras + 1] = text(u.name) .. ", " .. text(u.address) end
      cert("Certificate of Service", paras, function() return signature(meta, false, false) end)
    end
  else -- reply
    cert("Certificate of Compliance", {
      "The undersigned counsel certifies pursuant to L.A.R. 46.1(e) that counsel is a member in good standing of the bar of this Court.",
      "This brief complies with the type-volume limitation of FRAP 32(a)(7)(B)(ii) because it contains " .. group_digits(words) .. " words, including headings, footnotes, and quotations, and excluding the items exempted by FRAP 32(f). It is prepared in " .. text(meta.typeface or "14-point, proportionally spaced serif type") .. " and complies with the typeface and type-style requirements of FRAP 32(a)(5) and (6).",
      "The text of the electronic document is identical to the paper copies. Pursuant to L.A.R. 31.1(c), this electronic document was scanned for viruses using " .. text(need(meta, "virus_scanner")) .. " prior to filing and found to be virus free.",
    }, function() return signature(meta, false, false) end)
    local svc = meta.service
    if svc then
      local paras = { "I hereby certify that the foregoing brief was electronically filed on this date with the Clerk of the Court for the United States Court of Appeals for the Third Circuit by using the appellate CM/ECF system. Participants in the case who are registered CM/ECF users will be served by the appellate CM/ECF system." }
      local unreg = svc.unregistered or {}
      if #unreg > 0 then
        paras[#paras + 1] = "Service on Case Participants Who Are NOT Registered for Electronic Filing: I certify that I served the foregoing document on this date by hand delivery, mail, third party commercial carrier for delivery within 3 calendar days, or, having obtained prior consent, by email to the following unregistered case participants (list each name and mailing/email address):"
        for _, u in ipairs(unreg) do paras[#paras + 1] = text(u.name) .. ", " .. text(u.address) end
      end
      cert("Certificate of Service", paras, function() return signature(meta, false, false) end)
    end
  end
  return out
end

-- Table of contents (a TOC field; Word fills it on update) and table of authorities (names only).
local function front_matter(meta)
  local out = {}
  out[#out + 1] = raw(para("Table of Contents", { pstyle = "Heading1", jc = "center", before_break = true, line = 240, after = 240 }))
  out[#out + 1] = raw('<w:p><w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-5" \\h </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>Update field to show the table of contents.</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
  out[#out + 1] = raw(para("Table of Authorities", { pstyle = "Heading1", jc = "center", before_break = true, line = 240, after = 240 }))
  local authorities = meta.authorities or {}
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for k, a in pairs(authorities) do
      if a.kind and pandoc.utils.stringify(a.kind) == g[1] then
        local name = a.name and text(a.name) or ""
        members[#members + 1] = { a = a, sort = string.lower(name .. " " .. text(a.cite)) }
      end
    end
    table.sort(members, function(x, y) return x.sort < y.sort end)
    if #members > 0 then
      out[#out + 1] = raw(para(g[2], { bold = true, keep_next = true, after = 120 }))
      for _, m in ipairs(members) do
        local s = (m.a.name and (text(m.a.name) .. ", ") or "") .. text(m.a.cite)
        out[#out + 1] = raw(para(s, { ind_left = 360, after = 120 }))
      end
    end
  end
  return out
end

function Link(el)
  -- A table-of-authorities link is ordinary text in the docx (its page is not written here: see README.md).
  if el.target:sub(1, 4) == "toa:" then return el.content end
  return nil
end

function Pandoc(doc)
  local meta = doc.meta
  local words = body_words(meta)
  if words > LIMIT then
    error("ca3-" .. TYPE .. ": the brief has " .. words .. " words; the limit is " .. LIMIT)
  end
  local blocks = doc.blocks
  local addendum_at = nil
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 and string.lower(pandoc.utils.stringify(b.content)) == "addendum" then
      addendum_at = i
      break
    end
  end
  local body_end = addendum_at and (addendum_at - 1) or #blocks
  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end
  for _, b in ipairs(front_matter(meta)) do out[#out + 1] = b end

  out[#out + 1] = raw("<w:p><w:r><w:br w:type=\"page\"/></w:r></w:p>")
  local counts = { 0, 0, 0, 0, 0 }
  local in_arg = false
  local placed = false
  for i = 1, body_end do
    local b = blocks[i]
    if b.t == "Header" then
      local title = text(b.content)
      if b.level == 1 then
        counts = { 0, 0, 0, 0, 0 }
        in_arg = (SCHEME == "argument") and (string.lower(title) == "argument")
        if string.lower(title) == "statement of the case" then
          out[#out + 1] = heading_xml(1, "", "Statement of Related Cases")
          if meta.related_cases then out[#out + 1] = raw(para(text(meta.related_cases), { line = 480 })) end
          placed = true
        end
        out[#out + 1] = heading_xml(1, "", title)
      else
        counts[b.level] = counts[b.level] + 1
        for k = b.level + 1, 5 do counts[k] = 0 end
        local lab = label_for(b.level, counts[b.level], in_arg)
        out[#out + 1] = heading_xml(b.level, lab, title, SCHEME == "argument" and in_arg and b.level == 2)
      end
    else
      out[#out + 1] = b
    end
  end
  if SCHEME == "opening" and not placed then
    error("ca3-" .. TYPE .. ": the body needs a `# Statement of the Case` heading")
  end
  for _, x in ipairs(signature(meta, true, true)) do out[#out + 1] = x end
  for _, x in ipairs(certificates(meta, words)) do out[#out + 1] = x end
  if addendum_at then
    out[#out + 1] = raw(para("Addendum", { pstyle = "Heading1", jc = "center", before_break = true, line = 240, after = 240 }))
    for i = addendum_at + 1, #blocks do out[#out + 1] = blocks[i] end
  end
  doc.blocks = out
  return doc
end

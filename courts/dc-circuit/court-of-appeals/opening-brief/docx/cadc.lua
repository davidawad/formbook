-- cadc.lua: pandoc filter for the D.C. Circuit Word template (docx/reference.docx). Run by tools/render-docx.sh.
--
-- Builds the cover, the certificate of parties, the contents and authorities lists, the signature and the
-- certificates from the frontmatter, in the order of typst/cadc-opening-brief.typ. Word cannot number a table of
-- contents or of authorities without a field update, so both lists are written without page numbers: their page
-- references are BLOCKED for this engine (see ../README.md, "Engines"). The body is pandoc's own output.

local WORD_LIMIT = 13000

local function stringify(x)
  return pandoc.utils.stringify(x)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- A centered (or left) paragraph of plain text, in the body's exact line pitch.
local function raw_para(text, opts)
  opts = opts or {}
  local jc = opts.align or "left"
  local bold = opts.bold and "<w:b/>" or ""
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:keepNext/><w:jc w:val="' .. jc ..
    '"/><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/></w:pPr><w:r><w:rPr>' ..
    bold .. '</w:rPr><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r></w:p>')
end

local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function blank()
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/></w:pPr></w:p>')
end

local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    local notes = {}
    local bare = pandoc.Pandoc({ b }):walk({
      Note = function(note)
        notes[#notes + 1] = note
        return {}
      end,
    })
    for _ in stringify(bare.blocks):gmatch("%S+") do
      n = n + 1
    end
    for _, note in ipairs(notes) do
      n = n + count_words(note.content)
    end
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function cover(meta)
  local out = {}
  local function add(t, o)
    out[#out + 1] = raw_para(t, o)
  end
  add(stringify(meta.oral_argument):upper(), { align = "center", bold = true })
  out[#out + 1] = blank()
  add("No. " .. stringify(meta.case_number), { align = "center" })
  out[#out + 1] = blank()
  add("UNITED STATES COURT OF APPEALS", { align = "center" })
  add("FOR THE DISTRICT OF COLUMBIA CIRCUIT", { align = "center" })
  out[#out + 1] = blank()
  for i, side in ipairs(meta.caption) do
    if i > 1 then
      add("v.", { align = "center" })
      out[#out + 1] = blank()
    end
    for _, n in ipairs(side.names) do
      add(stringify(n), { align = "center" })
    end
    add(stringify(side.designation), { align = "center" })
    out[#out + 1] = blank()
  end
  add(stringify(meta.proceeding), { align = "center" })
  if meta.district_court_case then add(stringify(meta.district_court_case), { align = "center" }) end
  if meta.judge then add(stringify(meta.judge), { align = "center" }) end
  out[#out + 1] = blank()
  add(stringify(meta.brief_title):upper(), { align = "center", bold = true })
  out[#out + 1] = blank()
  for _, g in ipairs(meta.counsel) do
    for _, n in ipairs(g.names) do
      add(stringify(n))
    end
    for _, l in ipairs(g.lines) do
      add(stringify(l))
    end
    out[#out + 1] = blank()
  end
  if meta.date then add(stringify(meta.date)) end
  out[#out + 1] = page_break()
  return out
end

local function signature(meta)
  local out = {}
  out[#out + 1] = blank()
  if meta.date then out[#out + 1] = raw_para(stringify(meta.date)) end
  out[#out + 1] = raw_para("Respectfully submitted,")
  out[#out + 1] = raw_para("s/ " .. stringify(meta.signature.signer))
  out[#out + 1] = raw_para(stringify(meta.signature.signer))
  for _, l in ipairs(meta.signature.lines) do
    out[#out + 1] = raw_para(stringify(l))
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local authorities = meta.authorities or {}
  local cited = {}
  local doc2 = pandoc.Pandoc(doc.blocks, meta):walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then
        return nil
      end
      if authorities[key] == nil then
        error("cadc.lua: cited authority `" .. key .. "` is not in the authorities registry")
      end
      cited[key] = true
      return el.content
    end,
  })

  local body, add = {}, {}
  local target = body
  for _, b in ipairs(doc2.blocks) do
    if b.t == "Header" and b.level == 1 and stringify(b.content) == "Addendum" then
      target = add
    else
      target[#target + 1] = b
    end
  end
  local words = count_words(body)
  if words > WORD_LIMIT then
    error("cadc.lua: body is " .. words .. " words; the limit is " .. WORD_LIMIT)
  end

  local out = cover(meta)
  out[#out + 1] = pandoc.Header(1, { pandoc.Str("CERTIFICATE AS TO PARTIES, RULINGS, AND RELATED CASES, AND RULE 26.1 DISCLOSURE") })
  out[#out + 1] = pandoc.Para({ pandoc.Str("Pursuant to Circuit Rule 28(a)(1) and Federal Rule of Appellate Procedure 26.1, the undersigned counsel certifies as follows:") })
  local parts = { { "A. Parties and Amici", meta.certificate.parties }, { "B. Rulings Under Review", meta.certificate.rulings },
    { "C. Related Cases", meta.certificate.related }, { "Rule 26.1 Disclosure", meta.certificate.disclosure } }
  for _, p in ipairs(parts) do
    out[#out + 1] = pandoc.Para({ pandoc.Strong({ pandoc.Str(p[1]) }) })
    for _, b in ipairs(p[2]) do
      out[#out + 1] = b
    end
  end
  out[#out + 1] = page_break()

  out[#out + 1] = pandoc.Header(1, { pandoc.Str("TABLE OF CONTENTS") })
  -- Contents without page numbers (BLOCKED: fields are not updated by LibreOffice here; see README).
  for _, b in ipairs(body) do
    if b.t == "Header" and (b.level == 1 or b.level == 2) then
      out[#out + 1] = raw_para(stringify(b.content))
    end
  end
  out[#out + 1] = page_break()

  out[#out + 1] = pandoc.Header(1, { pandoc.Str("TABLE OF AUTHORITIES") })
  local kinds = { "case", "constitution", "statute", "regulation", "rule", "other" }
  local titles = { case = "Cases", constitution = "Constitutional Provisions", statute = "Statutes",
    regulation = "Regulations", rule = "Rules", other = "Other Authorities" }
  for _, k in ipairs(kinds) do
    local keys = {}
    for key in pairs(cited) do
      if stringify(authorities[key].kind) == k then keys[#keys + 1] = key end
    end
    if #keys > 0 then
      table.sort(keys, function(p, q)
        local a, b = authorities[p], authorities[q]
        local sp = stringify(a.sort or a.name or a.cite)
        local sq = stringify(b.sort or b.name or b.cite)
        if sp == sq then return p < q end
        return sp < sq
      end)
      out[#out + 1] = pandoc.Para({ pandoc.Strong({ pandoc.Str(titles[k]) }) })
      for _, key in ipairs(keys) do
        local a = authorities[key]
        local line = a.name and (stringify(a.name) .. ", " .. stringify(a.cite)) or stringify(a.cite)
        out[#out + 1] = raw_para(line)
      end
    end
  end
  out[#out + 1] = page_break()

  for _, b in ipairs(body) do
    out[#out + 1] = b
  end
  for _, b in ipairs(signature(meta)) do
    out[#out + 1] = b
  end

  out[#out + 1] = page_break()
  out[#out + 1] = pandoc.Header(1, { pandoc.Str("CERTIFICATE OF COMPLIANCE") })
  out[#out + 1] = pandoc.Para({ pandoc.Str("This document complies with the type-volume limitations of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by the Federal Rules of Appellate Procedure and this Court's rules, this document contains " .. group_digits(words) .. " words, as calculated by my word processing software.") })
  out[#out + 1] = pandoc.Para({ pandoc.Str("This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because this document has been prepared in a proportionally spaced typeface, 14-point TeX Gyre Schola, using " .. stringify(meta.word_processor) .. ".") })
  out[#out + 1] = raw_para("/s/ " .. stringify(meta.signature.signer), { align = "right" })
  out[#out + 1] = raw_para(stringify(meta.signature.signer), { align = "right" })

  out[#out + 1] = page_break()
  out[#out + 1] = pandoc.Header(1, { pandoc.Str("CERTIFICATE OF SERVICE") })
  out[#out + 1] = pandoc.Para({ pandoc.Str("I hereby certify that, on " .. stringify(meta.date) .. ", the foregoing document was served through the Court's ECF system on counsel for all parties.") })
  out[#out + 1] = raw_para("/s/ " .. stringify(meta.signature.signer), { align = "right" })
  out[#out + 1] = raw_para(stringify(meta.signature.signer), { align = "right" })

  if #add > 0 then
    out[#out + 1] = page_break()
    for _, b in ipairs(add) do
      out[#out + 1] = b
    end
  end
  return pandoc.Pandoc(out, meta)
end

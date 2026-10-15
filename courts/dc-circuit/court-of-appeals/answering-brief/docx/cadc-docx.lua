-- cadc-docx.lua: pandoc filter for the D.C. Circuit answering-brief DOCX (docx/reference.docx). Run by pandoc from the
-- court directory (see README, "Engines"). Pandoc does not render the YAML frontmatter, so this filter builds the cover,
-- the certificate of parties, the signature blocks and the certificates from it, with the custom styles of
-- reference.docx (Cover Line, Single Line, Signature Block, Counsel Block). Links `toa:KEY` become plain text.
--
-- Not built here, and reported as BLOCKED in the README: the table of contents and the table of authorities (their page
-- numbers need a layout pass; LibreOffice cannot run on the box that built this), the roman page numbering of the front
-- matter (the footer counts every page), and "keep the signature with the last paragraph" (no keep-with-next on a block).

local WORD_LIMIT = 13000

local function stringify(x)
  return pandoc.utils.stringify(x)
end

local function upper_inlines(inl)
  local doc = pandoc.Pandoc({ pandoc.Plain(inl) }):walk({
    Str = function(s)
      return pandoc.Str(s.text:upper())
    end,
  })
  return doc.blocks[1].content
end

local function style(name)
  return pandoc.Attr("", {}, { ["custom-style"] = name })
end

local function styled(name, blocks)
  return pandoc.Div(blocks, style(name))
end

local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function lines(parts)
  -- Inline parts separated by line breaks (one paragraph, as the typst signature block).
  local out = {}
  for i, p in ipairs(parts) do
    if i > 1 then
      out[#out + 1] = pandoc.LineBreak()
    end
    for _, x in ipairs(p) do
      out[#out + 1] = x
    end
  end
  return out
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
    local text = stringify(bare.blocks):gsub("\u{00A0}", " ")
    for _ in text:gmatch("%S+") do
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

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

local function label(level, in_arg, n)
  if in_arg then
    if level == 2 then return roman(n):upper() .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    return string.char(96 + n) .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return tostring(n) .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

-- Body headings: numbered as the typst template (Argument: I. / A. / 1. / a.; elsewhere A. / 1. / a. / (1)).
local function number_headings(blocks, numbered)
  local out = {}
  local cnt = { 0, 0, 0, 0, 0 }
  local in_arg = false
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = b.level
      if level == 1 then
        in_arg = stringify(b.content):lower():match("^%s*(.-)%s*$") == "argument"
      end
      local content = b.content
      if numbered then
        cnt[level] = cnt[level] + 1
        for j = level + 1, 5 do
          cnt[j] = 0
        end
        if level >= 2 then
          content = { pandoc.Str(label(level, in_arg, cnt[level])), pandoc.Space() }
          for _, x in ipairs(b.content) do
            content[#content + 1] = x
          end
        end
      end
      out[#out + 1] = pandoc.Header(level, content)
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- The signature block (typst signature-block; certificates use the first line only, form-sig-line).
local function sig_block(sig, all_lines)
  local parts = {}
  local first = { pandoc.Str("/s/ ") }
  for _, x in ipairs(sig.signer) do
    first[#first + 1] = x
  end
  parts[#parts + 1] = first
  parts[#parts + 1] = { pandoc.Strong(upper_inlines(sig.signer)) }
  local ls = sig.lines or {}
  if all_lines then
    for _, l in ipairs(ls) do
      parts[#parts + 1] = { pandoc.Emph(l) }
    end
  elseif #ls > 0 then
    parts[#parts + 1] = { pandoc.Emph(ls[1]) }
  end
  return styled("Signature Block", { pandoc.Para(lines(parts)) })
end

function Pandoc(doc)
  local meta = doc.meta
  local authorities = meta.authorities or {}
  local cited = {}

  -- Links to the table of authorities are plain text in the .docx (the table itself is BLOCKED, see above).
  local blocks = pandoc.Pandoc(doc.blocks, meta):walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then
        return nil
      end
      if authorities[key] == nil then
        error("cadc-docx.lua: cited authority `" .. key .. "` is not in the authorities registry")
      end
      cited[key] = true
      return el.content
    end,
  }).blocks

  -- Split at `# Addendum`; the word count is the body before it.
  local body, add = {}, {}
  local target = body
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 and stringify(b.content):lower():match("^%s*(.-)%s*$") == "addendum" then
      target = add
    else
      target[#target + 1] = b
    end
  end
  local words = count_words(body)
  if words > WORD_LIMIT then
    error("cadc-docx.lua: body is " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. WORD_LIMIT)
  end

  local out = {}
  local function add_all(list)
    for _, b in ipairs(list) do
      out[#out + 1] = b
    end
  end

  -- ---- cover (FRAP 32(a)(2)) ----
  if meta.oral_argument then
    out[#out + 1] = styled("Single Line", { pandoc.Para({ pandoc.Strong(meta.oral_argument) }) })
  end
  out[#out + 1] = styled("Cover Line", { pandoc.Para({ pandoc.Strong({ pandoc.Str("No. " .. stringify(meta.case_number)) }) }) })
  out[#out + 1] = styled("Cover Line", {
    pandoc.Para({
      pandoc.Strong({ pandoc.Str("UNITED STATES COURT OF APPEALS"), pandoc.LineBreak(), pandoc.Str("FOR THE DISTRICT OF COLUMBIA CIRCUIT") }),
    }),
  })
  for i, side in ipairs(meta.caption) do
    for _, n in ipairs(side.names) do
      out[#out + 1] = styled("Cover Line", { pandoc.Para(n) })
    end
    out[#out + 1] = styled("Counsel Block", { pandoc.Para(side.designation) })
    if i < #meta.caption then
      out[#out + 1] = styled("Cover Line", { pandoc.Para({ pandoc.Str("v.") }) })
    end
  end
  out[#out + 1] = styled("Cover Line", { pandoc.Para(meta.proceeding) })
  if meta.district_court_case or meta.judge then
    local tail = {}
    if meta.district_court_case then
      for _, x in ipairs(meta.district_court_case) do
        tail[#tail + 1] = x
      end
    end
    if meta.district_court_case and meta.judge then
      tail[#tail + 1] = pandoc.Str("; ")
    end
    if meta.judge then
      for _, x in ipairs(meta.judge) do
        tail[#tail + 1] = x
      end
    end
    out[#out + 1] = styled("Cover Line", { pandoc.Para(tail) })
  end
  out[#out + 1] = styled("Cover Line", { pandoc.Para({ pandoc.Strong(upper_inlines(meta.brief_title)) }) })
  for gi, g in ipairs(meta.counsel) do
    local parts = {}
    for _, n in ipairs(g.names) do
      parts[#parts + 1] = n
    end
    local ls = g.lines or {}
    for _, l in ipairs(ls) do
      parts[#parts + 1] = { pandoc.Emph(l) }
    end
    if gi == #meta.counsel and meta.phone then
      parts[#parts + 1] = { pandoc.Emph(meta.phone) }
    end
    out[#out + 1] = styled("Counsel Block", { pandoc.Para(lines(parts)) })
  end
  out[#out + 1] = page_break()

  -- ---- certificate of parties, rulings and related cases (D.C. Cir. R. 28(a)(1)) ----
  out[#out + 1] = pandoc.Header(1, { pandoc.Str("Certificate of Parties, Rulings, and Related Cases") })
  add_all(meta.certificate_of_parties)
  if meta.statutes_and_regulations then
    out[#out + 1] = pandoc.Header(1, { pandoc.Str("Statutes and Regulations") })
    add_all(meta.statutes_and_regulations)
  end
  out[#out + 1] = page_break()

  -- ---- the brief ----
  add_all(number_headings(body, true))
  local sig = meta.signature
  out[#out + 1] = styled("Signature Block", { pandoc.Para({ pandoc.Str("Respectfully submitted,") }) })
  out[#out + 1] = sig_block(sig, true)
  out[#out + 1] = page_break()

  -- ---- certificate of compliance (FRAP 32(g)) ----
  out[#out + 1] = pandoc.Header(1, { pandoc.Str("Certificate of Compliance") })
  out[#out + 1] = styled("Single Line", {
    pandoc.Para({
      pandoc.Str("I HEREBY CERTIFY pursuant to Fed. R. App. P. 32(g) that this brief contains " .. group_digits(words)
        .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f) and D.C. Circuit Rule 32(e)(1), and therefore complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B). This brief has been prepared in 14-point TeX Gyre Schola, a proportionally spaced typeface."),
    }),
  })
  out[#out + 1] = sig_block(sig, false)

  -- ---- certificate of service (FRAP 25(d)), when service.certificate is true ----
  local svc = meta.service
  if svc and svc.certificate then
    out[#out + 1] = page_break()
    out[#out + 1] = pandoc.Header(1, { pandoc.Str("Certificate of Service") })
    local t = { pandoc.Str("I HEREBY CERTIFY that I have caused a copy of the foregoing ") }
    for _, x in ipairs(svc.document) do t[#t + 1] = x end
    t[#t + 1] = pandoc.Str(" to be served by electronic means, through the Court’s CM/ECF system, upon ")
    for _, x in ipairs(svc.served_upon) do t[#t + 1] = x end
    t[#t + 1] = pandoc.Str(", on this ")
    for _, x in ipairs(svc.date) do t[#t + 1] = x end
    t[#t + 1] = pandoc.Str(".")
    out[#out + 1] = styled("Single Line", { pandoc.Para(t) })
    out[#out + 1] = sig_block(sig, false)
  end

  -- ---- addendum (D.C. Cir. R. 28(a)(5)) ----
  if #add > 0 then
    out[#out + 1] = page_break()
    add_all(number_headings(add, false))
  end

  doc.blocks = out
  return doc
end

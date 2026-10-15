-- New York Court of Appeals answering brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on docx/reference.docx, in the form of typst/ny-answering-brief.typ. The cover, the disclosure
-- statement, the contents, the table of authorities and the certificates are built here; the body keeps its
-- markdown structure (its headings carry their own letters and numerals, as in the markdown).
-- Sections: cover (empty footer, no number); everything else on one continuing page count, so the disclosure
-- statement is page 2 as in the typst form. Known limits (BLOCKED, see README "Engines"): the table of
-- contents is a TOC field (page numbers after a field update); the table of authorities has no page
-- references (a TOA field is not honoured by LibreOffice).


-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("ny-answering: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- a metadata value (markdown) as a plain list of inlines (pandoc.utils.type: Inlines, Blocks or a string)
local function inl(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "string" then return { pandoc.Str(v) } end
  local ty = pandoc.utils.type(v)
  if ty == "Blocks" then return pandoc.utils.blocks_to_inlines(v) end
  if ty == "Inlines" then
    for _, i in ipairs(v) do out[#out + 1] = i end
  end
  return out
end

-- a metadata value (markdown blocks) as a plain list of blocks
local function blocks(v)
  local out = {}
  if v == nil then return out end
  if pandoc.utils.type(v) == "Blocks" then
    for _, b in ipairs(v) do out[#out + 1] = b end
  else
    out[1] = pandoc.Plain(inl(v))
  end
  return out
end

local function cat(...)
  local out = {}
  for _, l in ipairs({ ... }) do
    for _, i in ipairs(l) do out[#out + 1] = i end
  end
  return out
end

local function plain_of(v)
  return pandoc.utils.stringify(pandoc.Inlines(inl(v)))
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(pandoc.Inlines(inlines)) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- a borderless table; each cell is a list of blocks
local function columns(widths, cells)
  local aligns = {}
  for i = 1, #widths do aligns[i] = pandoc.AlignDefault end
  return pandoc.utils.from_simple_table(pandoc.SimpleTable({}, aligns, widths, {}, { cells }))
end

-- a section end: an empty paragraph carrying the section properties (footer rId; page numbers continue)
local function section_end(footer_rid)
  return pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:sectPr>'
    .. '<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '</w:sectPr></w:pPr></w:p>')
end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- typst's count-words on the body markdown: footnote definitions removed, then whitespace-delimited tokens
local function body_words(body)
  local s = body:gsub("(\n?)%[%^[^%]]+%]:[^\n]*", "%1")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

-- the markdown after the frontmatter (the second line of "---")
local function body_markdown()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("ny-answering: no input file to count words from", 0) end
  local h = io.open(f, "r")
  if not h then error("ny-answering: cannot read " .. f, 0) end
  local text = h:read("a")
  h:close()
  local first, second = text:find("\n%-%-%-[ \t]*\r?\n")
  if not first then error("ny-answering: the sample must start with a YAML frontmatter block", 0) end
  return text:sub(second + 1)
end

-- ---------------------------------------------------------------------------
-- parts
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  out[#out + 1] = styled("Centered", { pandoc.Str("Court of Appeals") })
  out[#out + 1] = styled("Centered", { pandoc.Str("of the State of New York") })
  out[#out + 1] = styled("Centered", inl(need(meta, "apl_docket")))
  out[#out + 1] = styled("Centered", inl(need(meta, "county_clerk_index")))
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do out[#out + 1] = styled("Centered", inl(n)) end
    out[#out + 1] = styled("Centered", inl(side.designation))
    if i < #sides then out[#out + 1] = styled("Centered", { pandoc.Emph({ pandoc.Str("--against--") }) }) end
  end
  out[#out + 1] = styled("CoverTitle", inl(need(meta, "brief_title")))
  out[#out + 1] = styled("Centered", inl(need(meta, "proceeding")))
  local cells, widths = {}, {}
  for _, g in ipairs(need(meta, "counsel")) do
    local col = {}
    for _, n in ipairs(g.names) do col[#col + 1] = styled("Single", inl(n)) end
    for _, l in ipairs(g.lines or {}) do col[#col + 1] = styled("Single", { pandoc.Emph(inl(l)) }) end
    cells[#cells + 1] = col
  end
  for i = 1, #cells do widths[i] = 1 / #cells end
  out[#out + 1] = columns(widths, cells)
  out[#out + 1] = styled("Centered", inl(need(meta, "phone")))
  if meta.date then out[#out + 1] = styled("Centered", inl(meta.date)) end
  out[#out + 1] = section_end("rId100")
  return out
end

-- the disclosure statement (500.1(f)): only when given; the page starts the front matter
local function disclosure(meta, first)
  local out = {}
  if not meta.disclosure then return out end
  out[#out + 1] = styled(first and "FrontHeading" or "FrontHeadingBreak", { pandoc.Str("DISCLOSURE STATEMENT") })
  for _, b in ipairs(blocks(meta.disclosure)) do out[#out + 1] = b end
  return out
end

local function table_of_contents(first)
  local out = {}
  out[#out + 1] = styled(first and "FrontHeading" or "FrontHeadingBreak", { pandoc.Str("TABLE OF CONTENTS") })
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. '<w:r><w:t>Table of contents: update fields (Word: select all, then F9) to show the page numbers.</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
  return out
end

local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

-- the registry in a stable order (the file order is not kept by the metadata: sorted by key)
local function table_of_authorities(meta, first)
  local out = {}
  local auths = meta.authorities
  if not auths then return out end
  out[#out + 1] = styled(first and "FrontHeading" or "FrontHeadingBreak", { pandoc.Str("TABLE OF AUTHORITIES") })
  local keys = {}
  for k, _ in pairs(auths) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for _, k in ipairs(keys) do
      if plain_of(auths[k].kind) == g[1] then members[#members + 1] = auths[k] end
    end
    if #members > 0 then
      out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str(g[2]) }) }) },
        pandoc.Attr("", {}, { ["custom-style"] = "Single" }))
      for _, a in ipairs(members) do
        local name = inl(a.name)
        if plain_of(a.kind) == "case" then name = { pandoc.Emph(name) } end
        out[#out + 1] = styled("Authority", cat(name, { pandoc.Str(", ") }, inl(a.cite)))
      end
    end
  end
  return out
end

-- the signature block (typst signature-block): "Respectfully submitted," then the signer, indented
local function signature_block(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = styled("Signature", { pandoc.Str("Respectfully submitted,") })
  out[#out + 1] = styled("Signature", { pandoc.Str("") })
  out[#out + 1] = styled("Signature", inl(sig.signer))
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = styled("Signature", { pandoc.Emph(inl(l)) }) end
  if meta.date then out[#out + 1] = styled("Signature", inl(meta.date)) end
  return out
end

local function signer_block(meta)
  local out = {}
  out[#out + 1] = styled("Signature", { pandoc.Str("") })
  out[#out + 1] = styled("Signature", inl(need(meta, "signature").signer))
  if meta.date then out[#out + 1] = styled("Signature", inl(meta.date)) end
  return out
end

local function certificate_of_compliance(meta, words)
  local out = {}
  out[#out + 1] = styled("FrontHeadingBreak", { pandoc.Str("CERTIFICATE OF COMPLIANCE") })
  out[#out + 1] = pandoc.Para({ pandoc.Str("I certify that this brief complies with the word limit of 22 NYCRR 500.13(c)(1), that it contains "
    .. group_digits(words) .. " words in the body of the brief, excluding the caption, tables and signature block, and that the count was made by the word-processing system used to prepare it.") })
  for _, b in ipairs(signer_block(meta)) do out[#out + 1] = b end
  return out
end

local function certificate_of_service(meta)
  local svc = meta.service
  if not svc then return {} end
  local out = {}
  out[#out + 1] = styled("FrontHeadingBreak", { pandoc.Str("CERTIFICATE OF SERVICE") })
  out[#out + 1] = pandoc.Para(cat({ pandoc.Str("I certify that on the date below I served copies of this brief on counsel for all parties by ") },
    inl(svc.method), { pandoc.Str(".") }))
  for _, u in ipairs(svc.unregistered or {}) do
    out[#out + 1] = styled("Signature", { pandoc.Str("") })
    out[#out + 1] = styled("Single", inl(u.name))
    out[#out + 1] = styled("Single", inl(u.address))
  end
  for _, b in ipairs(signer_block(meta)) do out[#out + 1] = b end
  return out
end

-- ---------------------------------------------------------------------------
-- the document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "apl_docket", "county_clerk_index", "caption", "proceeding", "brief_title",
                       "counsel", "phone", "signature" }) do
    need(meta, k)
  end

  -- citations: `[text](toa:key)` keeps its text; the key must be in the authorities registry
  local authorities = meta.authorities or {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if authorities[key] == nil then
        error("ny-answering: link `toa:" .. key .. "` has no entry under `authorities:`", 0)
      end
      return el.content
    end,
  })

  local words = body_words(body_markdown())

  local out = {}
  local function add_all(list) for _, b in ipairs(list) do out[#out + 1] = b end end

  add_all(cover(meta))

  -- front matter: disclosure (if any), contents, authorities; the first one starts the section
  local first = true
  if meta.disclosure then add_all(disclosure(meta, true)); first = false end
  add_all(table_of_contents(first))
  add_all(table_of_authorities(meta, false))
  out[#out + 1] = section_end("rId101")

  -- body, its signature, the certificates
  add_all(doc.blocks)
  add_all(signature_block(meta))
  add_all(certificate_of_compliance(meta, words))
  add_all(certificate_of_service(meta))

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end

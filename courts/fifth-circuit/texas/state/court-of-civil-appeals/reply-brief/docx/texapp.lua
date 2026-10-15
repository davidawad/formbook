-- Texas Court of Appeals, Fifth District at Dallas: briefs, DOCX engine (docs/DOCX.md).
-- The markdown contract -> a Word document on reference.docx (build-reference.sh). Form: typst/texapp-<doc>.typ.
-- Built here as Word-native paragraphs: the cover (from the frontmatter), the contents (a TOC field whose cached
-- result is written with the page numbers from docx/render.sh), and the page breaks. The body keeps its markdown
-- structure; a body paragraph under 100 characters is not indented (the typst rule).
-- Content-agnostic: every case word comes from the frontmatter; the court lines are the court's own form.
-- Environment (set by docx/render.sh only): TEXAPP_TOC_LIST writes "level<TAB>text" per contents entry;
-- TEXAPP_TOC_PAGES reads one page number per entry (placeholders "0" if unset).

local COURT_LINES = { "IN THE COURT OF APPEALS", "FOR THE FIFTH DISTRICT OF TEXAS", "AT DALLAS" }
local SHORT_PARAGRAPH = 100

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a string as inlines: words with spaces between them (no line breaks)
local function words(s)
  local out, first = {}, true
  for w in s:gmatch("%S+") do
    if not first then out[#out + 1] = pandoc.Space() end
    out[#out + 1] = pandoc.Str(w)
    first = false
  end
  return out
end

local function bold(s)
  return { pandoc.Strong(words(s)) }
end

local function para(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- an empty paragraph in a named style (rules, spacing, page breaks)
local function empty(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function cover(meta)
  local b = {}
  local function add(x) b[#b + 1] = x end
  local function centered(inlines) add(para("Centered", inlines)) end
  local function gap(style) add(empty(style)) end
  local function rule() add(empty("Rule")) end

  centered(words("No. " .. plain(meta.case_number)))
  gap("Gap02"); rule(); gap("Gap02")
  for _, line in ipairs(COURT_LINES) do centered(bold(line)) end
  gap("Gap02"); rule(); gap("Gap025")
  if meta.caption then
    centered(bold(plain(meta.caption)))
    gap("Gap025")
  end
  centered(bold(string.upper(plain(meta.appellant))))
  centered(words("Appellant,"))
  gap("Gap025")
  centered(words("v."))
  gap("Gap025")
  centered(bold(string.upper(plain(meta.appellee))))
  centered(words("Appellee."))
  gap("Gap025"); rule(); gap("Gap02")
  centered(words("On Appeal from the " .. plain(meta.trial_court) .. ", " .. plain(meta.county) .. " County, Texas"))
  centered(words("Trial Court Cause No. " .. plain(meta.trial_cause)))
  gap("Gap02"); rule(); gap("Gap02")
  centered(bold(string.upper(plain(meta.brief_title))))
  gap("Gap025"); rule(); gap("Gap04")
  add(para("Cover Counsel", words("Respectfully submitted,")))
  gap("Gap025")
  if meta.counsel then
    for _, line in ipairs(meta.counsel) do
      add(para("Cover Counsel", words(plain(line))))
    end
  end
  return b
end

local FIELD_BEGIN = '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
local FIELD_END = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'

-- the contents: a TOC field whose cached result is the entries with their page numbers
local function contents(entries)
  local pages = {}
  local pf = os.getenv("TEXAPP_TOC_PAGES")
  if pf then
    local h = assert(io.open(pf, "r"), "texapp.lua: cannot read " .. pf)
    for line in h:lines() do pages[#pages + 1] = line end
    h:close()
  end
  local listf = os.getenv("TEXAPP_TOC_LIST")
  if listf then
    local h = assert(io.open(listf, "w"), "texapp.lua: cannot write " .. listf)
    for _, e in ipairs(entries) do h:write(e.level, "\t", e.text, "\n") end
    h:close()
  end
  local b = { para("TOC Title", bold("TABLE OF CONTENTS")) }
  if #entries == 0 then
    b[#b + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' .. FIELD_BEGIN .. FIELD_END .. '</w:p>')
    return b
  end
  for i, e in ipairs(entries) do
    local page = pages[i] or "0"
    local xml = '<w:p><w:pPr><w:pStyle w:val="TOC' .. e.level .. '"/></w:pPr>'
      .. (i == 1 and FIELD_BEGIN or '')
      .. '<w:r><w:t xml:space="preserve">' .. xesc(e.text) .. '</w:t></w:r>'
      .. '<w:r><w:tab/></w:r><w:r><w:t>' .. xesc(page) .. '</w:t></w:r>'
      .. (i == #entries and FIELD_END or '')
      .. '</w:p>'
    b[#b + 1] = pandoc.RawBlock("openxml", xml)
  end
  return b
end

function Pandoc(doc)
  local entries, body = {}, {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level <= 2 then
        entries[#entries + 1] = { level = b.level, text = (pandoc.utils.stringify(b.content):gsub("[\t\n]", " ")) }
      end
      body[#body + 1] = b
    elseif b.t == "Para" and #pandoc.utils.stringify(b) < SHORT_PARAGRAPH then
      body[#body + 1] = para("Body Flush", b.content)
    else
      body[#body + 1] = b
    end
  end

  local out = cover(doc.meta)
  for _, b in ipairs(contents(entries)) do out[#out + 1] = b end
  out[#out + 1] = empty("PageBreak")
  for _, b in ipairs(body) do out[#out + 1] = b end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

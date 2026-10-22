-- Supreme Court of the United States: brief on the merits (booklet format), LaTeX engine.
-- Mirrors typst/merits-brief.typ: cover (Rule 34.1), questions presented and parties pages, roman front
-- matter (TOC, TOA), arabic body, signature block (Rule 34.3), certificate of word count (Rule 33.1(h)).
-- Authority citations are tagged in the markdown as links to toa:<key>; each tag gets a label on its page.
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): lib/latex/xengine.lua gives the body and every
-- metadata value typst's break opportunities, lib/latex/xeschola.lua the vendored Schola's advances; template.tex
-- sets the spaces and line boxes.

local xe = require("latex.xengine")
local xs = require("latex.xeschola")

local meta = nil
local word_limit = 13000  -- Rule 33.1(g)(v): brief on the merits for a petitioner or appellant
local auth_by_key = {}
local auth_list = {}
local ncite = 0
local toc = {}
local words = 0

local stringify = pandoc.utils.stringify

-- A line may end after a slash before a letter, as typst breaks a web address (Unicode line breaking).
local function slash_breaks(inlines)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "Str" and el.text:find("/%a") then
      local rest = el.text
      while true do
        local s = rest:find("/%a")
        if not s then break end
        out:insert(pandoc.Str(rest:sub(1, s)))
        out:insert(pandoc.RawInline("latex", "\\allowbreak{}"))
        rest = rest:sub(s + 1)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end
local function xinl(l) return slash_breaks(xe.inlines(l)) end

-- A list that typst's markdown reader does not make ("b. The ...": pandoc reads letters as list markers; a value
-- "(202) 683-9135" as an example list): its paragraphs, each with its marker as written.
local function unlist(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" and (b.listAttributes.style == "LowerAlpha" or b.listAttributes.style == "UpperAlpha"
        or b.listAttributes.delimiter == "TwoParens") then
      local a = b.listAttributes
      for k, item in ipairs(b.content) do
        local n = a.start + k - 1
        local lab = tostring(n)
        if a.style == "LowerAlpha" then lab = string.char(96 + n)
        elseif a.style == "UpperAlpha" then lab = string.char(64 + n) end
        lab = a.delimiter == "TwoParens" and ("(" .. lab .. ")") or a.delimiter == "OneParen" and (lab .. ")") or (lab .. ".")
        for j, c in ipairs(item) do
          if j == 1 and (c.t == "Para" or c.t == "Plain") then
            local il = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
            il:extend(c.content)
            out[#out + 1] = pandoc.Para(il)
          else
            out[#out + 1] = c
          end
        end
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- Inline markdown in a metadata value -> LaTeX. Strings, inline lists and block lists are accepted.
local function tex(v)
  if v == nil then return "" end
  local t = pandoc.utils.type(v)
  local blocks
  if t == "string" then
    blocks = pandoc.read(v, "markdown").blocks
  elseif t == "Inlines" then
    blocks = { pandoc.Plain(v) }
  elseif t == "Blocks" then
    blocks = v
  else
    blocks = { pandoc.Plain(stringify(v)) }
  end
  blocks = unlist(blocks)
  for i, b in ipairs(blocks) do if b.t == "Para" then blocks[i] = pandoc.Plain(b.content) end end
  local s = pandoc.write(pandoc.Pandoc(blocks):walk({ Inlines = xinl }):walk(xs.filter), "latex")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(key)
  if meta[key] == nil then error("brief.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- Citation tags: a link to toa:<key> in the body keeps its text, with a label right after its first word (typst:
-- tag-after-first-word, so a citation that runs over a page end is listed at the page where it starts).
local function mark_first(inlines, mark)
  local out, done = pandoc.Inlines({}), false
  for _, el in ipairs(inlines) do
    if not done and el.t == "Str" then
      out:insert(el)
      out:insert(mark)
      done = true
    elseif not done and el.t ~= "Note" and el.content ~= nil and type(el.content) == "table" then
      local inner, d = mark_first(el.content, mark)
      el.content = inner
      out:insert(el)
      done = d
    else
      out:insert(el)
    end
  end
  return out, done
end

local function cite_link(el)
  local target = el.target
  if target:sub(1, 4) ~= "toa:" then return nil end
  local key = target:sub(5)
  local a = auth_by_key[key]
  if a == nil then error("brief.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
  ncite = ncite + 1
  local lab = "toa" .. ncite
  a.labels[#a.labels + 1] = lab
  local mark = pandoc.RawInline("latex", "\\toacite{" .. lab .. "}")
  local out, done = mark_first(el.content, mark)
  if not done then out:insert(1, mark) end
  return out
end

-- Front matter ----------------------------------------------------------------------------------

-- The cover (typst: cover): centred lines, the counsel in two columns at the foot of the page.
local function cover()
  local out = {}
  local function add(s) out[#out + 1] = s end
  local function line(above, s) add("\\scotusline{" .. above .. "}{" .. s .. "}") end
  add("\\thispagestyle{empty}")
  line(0, tex(need("docket")))
  line(64.8, "IN THE")
  line(2.4, "Supreme Court of the United States")
  add("\\scotusrule{7.2}")
  for i, c in ipairs(need("caption")) do line(i == 1 and 7.2 or 0, tex(c)) end
  add("\\scotusrule{7.2}")
  line(7.2, tex(need("proceeding")))
  line(7.2, "\\textbf{" .. tex(need("brief_title")) .. "}")
  add("\\par\\vfill")
  local groups = {}
  for _, g in ipairs(need("counsel")) do
    local ls = {}
    for _, n in ipairs(g.names) do ls[#ls + 1] = "\\noindent " .. tex(n) .. "\\par" end
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = "\\noindent\\emph{" .. tex(l) .. "}\\par" end
    groups[#groups + 1] = table.concat(ls, "\n")
  end
  for i = 1, #groups, 2 do
    if i > 1 then add("\\par\\vspace{10.8bp}") end
    add("\\scotuscounsel{" .. groups[i] .. "}{" .. (groups[i + 1] or "") .. "}")
  end
  add("\\clearpage")
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function heading_tex(level, title, outlined)
  local tag = "toc" .. (#toc + 1)
  local lab = ""
  if outlined then
    toc[#toc + 1] = { level = level, title = title, tag = tag }
    lab = "\\label{" .. tag .. "}"
  end
  if level == 1 then return "\\scotussection{" .. title .. "}{" .. lab .. "}" end
  if level == 2 then return "\\scotuspoint{10.8}{8.4}{" .. title .. "}{" .. lab .. "}" end
  return "\\scotuspoint{9.6}{7.2}{" .. title .. "}{" .. lab .. "}"
end

-- Questions presented and parties: front pages after the cover (Rule 24.1(a), (b)); roman page numbers from here.
local function front_pages()
  local qs = need("questions")
  local out = { "\\pagenumbering{roman}\\setcounter{page}{1}",
    heading_tex(1, #qs == 1 and "Question Presented" or "Questions Presented", true) }
  for i, q in ipairs(qs) do
    if i > 1 then out[#out + 1] = "\\scotuspar" end
    out[#out + 1] = "\\noindent " .. tex(q) .. "\\par"
  end
  out[#out + 1] = "\\clearpage"
  out[#out + 1] = heading_tex(1, "Parties to the Proceedings", true)
  out[#out + 1] = "\\noindent " .. tex(need("parties")) .. "\\par"
  if meta.disclosure then
    out[#out + 1] = heading_tex(1, "Corporate Disclosure Statement", true)
    out[#out + 1] = "\\noindent " .. tex(meta.disclosure) .. "\\par"
  end
  out[#out + 1] = "\\clearpage"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local function toc_block()
  local out = { heading_tex(1, "Table of Contents", false),
    "\\par\\begingroup\\footnotesize\\noindent\\hfill Page\\par\\endgroup" }
  for _, h in ipairs(toc) do
    if h.level <= 3 then
      out[#out + 1] = "\\tocrow{" .. string.format("%.1f", (h.level - 1) * 0.3) .. "in}{" .. h.title .. "}{\\pageref{"
        .. h.tag .. "}}"
    end
  end
  out[#out + 1] = "\\clearpage"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

local GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

local function toa_block()
  local out = { heading_tex(1, "Table of Authorities", false) }
  for _, a in ipairs(auth_list) do
    if #a.labels == 0 then error("brief.lua: authority `" .. a.key .. "` is listed in the frontmatter but never cited") end
  end
  for _, sec in ipairs(GROUPS) do
    local items = {}
    for _, a in ipairs(auth_list) do
      if a.kind == sec[1] then items[#items + 1] = a end
    end
    if #items > 0 then
      table.sort(items, function(x, y) return x.sortkey < y.sortkey end)
      out[#out + 1] = "\\toaheading{" .. sec[2] .. "}"
      for _, a in ipairs(items) do
        out[#out + 1] = "\\toaline{" .. a.entry .. "}{\\toapages{" .. table.concat(a.labels, ",") .. "}}"
      end
    end
  end
  out[#out + 1] = "\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}"
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

-- typst: signature-block (14.4 bp above, "Respectfully submitted," 24 bp above the signer, the date 9.6 bp below
-- the lines), never split.
local function signature_tex()
  local sig = need("signature")
  local out = { "\\par\\addvspace{14.4bp}\\vbox{\\scotusleft{0}{Respectfully submitted,}", "\\addvspace{24bp}",
    "\\scotusleft{0}{" .. tex(sig.signer) .. "}" }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = "\\scotusleft{0}{" .. tex(l) .. "}" end
  if meta.date then out[#out + 1] = "\\scotusleft{9.6}{" .. tex(meta.date) .. "}" end
  out[#out + 1] = "}"
  return table.concat(out, "\n")
end

local function certificate()
  local out = {
    "\\clearpage\\thispagestyle{empty}",
    heading_tex(1, "Certificate of Compliance", false),
    "\\noindent " .. tex("I certify that this brief complies with the word limit of Supreme Court Rule 33.1(g), "
      .. group_digits(word_limit) .. " words for a brief on the merits for a petitioner or appellant, and that it "
      .. "contains " .. group_digits(words) .. " words, excluding the parts that Rule 33.1(d) excludes.") .. "\\par",
    signature_tex(),
  }
  return pandoc.RawBlock("latex", table.concat(out, "\n"))
end

-- Words of the markdown source, counted as the typst template counts them (count-words).
local function count_words(md)
  local s = "\n" .. md
  s = s:gsub("<!%-%-.-%-%->", " ")
  s = s:gsub("\n%[%^[^%]]*%]:", "\n ")
  s = s:gsub("%[%^[^%]]*%]", "")
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[%-%*%+][ \t]+", "\n")
  s = s:gsub("\n[ \t]*%d+[%.%)][ \t]+", "\n")
  s = s:gsub("\\(.)", "%1")
  s = s:gsub("%*", "")
  s = s:gsub("([%s%(%[\"])_", "%1")
  s = s:gsub("_([%s%.,;:%)%]\"!%?])", "%1")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function counted_source()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local pos = src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n()")
  if not pos then error("brief.lua: the sample must start with a YAML frontmatter block") end
  return src:sub(pos)
end

local function prepare_authorities()
  local keys = {}
  for k in pairs(meta.authorities or {}) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local a = meta.authorities[k]
    local kind = stringify(a.kind)
    local name = tex(a.name or "")
    if kind == "case" then name = "\\emph{" .. name .. "}" end
    local cite = (a.cite and stringify(a.cite) ~= "") and tex(a.cite) or ""
    local rec = {
      key = k,
      kind = kind,
      entry = cite == "" and name or (name .. ", " .. cite),
      sortkey = stringify(a.sort or a.name or ""):lower(),
      labels = {},
    }
    auth_list[#auth_list + 1] = rec
    auth_by_key[k] = rec
  end
end

function Pandoc(doc)
  meta = doc.meta
  prepare_authorities()
  words = count_words(counted_source())
  if words > word_limit then
    error("brief.lua: body is " .. words .. " words, over the Rule 33.1(g) limit of " .. word_limit)
  end
  local body = doc:walk({ Link = cite_link })
  body.blocks = unlist(body.blocks)
  body = body:walk({ BlockQuote = function(q) q.content = unlist(q.content); return q end })
  -- the break rules of typst and the vendored Schola's advances on the body text
  body = body:walk({ Inlines = xinl }):walk(xs.filter)

  local blocks = { cover(), front_pages() }
  local rest = {}
  local prev = nil
  for _, b in ipairs(body.blocks) do
    if b.t == "Header" then
      if b.level > 3 then error("brief.lua: headings deeper than level 3 are not supported") end
      local title = pandoc.write(pandoc.Pandoc({ pandoc.Plain(b.content) }), "latex"):gsub("^%s+", ""):gsub("%s+$", "")
      rest[#rest + 1] = pandoc.RawBlock("latex", heading_tex(b.level, title, true))
    else
      -- 0.75 em between two paragraphs; next to a heading, the heading's own space
      if prev and prev.t ~= "Header" and b.t == "Para" and prev.t == "Para" then
        rest[#rest + 1] = pandoc.RawBlock("latex", "\\scotuspar")
      end
      local note = false
      if b.t == "Para" then b:walk({ Note = function() note = true end }) end
      if note then
        -- typst keeps two lines of a paragraph together by their height alone; when a line's footnote does not fit,
        -- that line moves on and the one before it stays behind alone: no widow or orphan rule for this paragraph
        rest[#rest + 1] = pandoc.RawBlock("latex", "\\widowpenalty=0 \\clubpenalty=0 ")
        rest[#rest + 1] = b
        rest[#rest + 1] = pandoc.RawBlock("latex", "\\widowpenalty=10000 \\clubpenalty=10000 ")
      else
        rest[#rest + 1] = b
      end
    end
    prev = b
  end
  blocks[#blocks + 1] = toc_block()
  blocks[#blocks + 1] = toa_block()
  for _, b in ipairs(rest) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = pandoc.RawBlock("latex", signature_tex())
  blocks[#blocks + 1] = certificate()
  return pandoc.Pandoc(blocks, doc.meta)
end

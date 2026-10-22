-- cadc.lua: pandoc filter for the D.C. Circuit LaTeX template (latex/template.tex). Run by fb render.
--
-- Writes the whole brief into $body$, in the order and with the spacing of typst/cadc-opening-brief.typ (the layout
-- commands are in template.tex):
--   * the cover, the certificate as to parties (Circuit Rule 28(a)(1)), the table of contents (two-pass, the .toc
--     file), the table of authorities (two-pass, the .aux file: every citation, a link to toa:KEY, marks its page; a
--     key not in `authorities:` stops the build), the glossary;
--   * the body (headings as \dchone / \dchtwo / \dchthree), the signature block, kept with the last paragraph;
--   * the certificates of compliance (the word count of the typst template: the markdown source before
--     `# Addendum`, so every engine certifies the same number; over the limit stops the build) and service;
--   * the addendum (`# Addendum` and after), after the certificates.
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the inline rules of lib/latex/xengine.lua run over
-- the body and over every metadata value.

local WORD_LIMIT = 13000 -- FRAP 28.1(e)(2)(A)(i), 32(a)(7)(B)(i); Circuit Rule 32(e)
local TYPEFACE = "TeX Gyre Schola" -- the typst template's font-family

local xe = require("latex.xengine")
local stringify = pandoc.utils.stringify

local function raw(s) return pandoc.RawBlock("latex", s) end

-- An ellipsis character (…) as one unit, as typst and Word set it (template.tex \dcellipsis).
local function ellipsis(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(l) do
    if el.t == "Str" and el.text:find("\u{2026}", 1, true) then
      local rest = el.text
      while true do
        local s, e = rest:find("\u{2026}", 1, true)
        if not s then break end
        if s > 1 then out:insert(pandoc.Str(rest:sub(1, s - 1))) end
        out:insert(pandoc.RawInline("latex", "\\dcellipsis{}"))
        rest = rest:sub(e + 1)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end

-- The glyphs whose advance differs between the Type 1 tgschola of TeX Live (the Adobe New Century Schoolbook widths)
-- and the TeX Gyre Schola 2.609 OpenType that typst and LibreOffice set (fonts/tex-gyre-schola): set in a box of the
-- OpenType advance, in thousandths of an em (regular and italic, bold and bold italic): template.tex \dcg.
local WIDE = {
  ["("] = { 483, 519, "(" }, [")"] = { 483, 519, ")" }, ["*"] = { 420, 483, "*" }, ["+"] = { 780, 800, "+" },
  ["/"] = { 447, 462, "/" }, ["<"] = { 788, 810, "<" }, ["="] = { 780, 800, "=" }, [">"] = { 788, 810, ">" },
  ["["] = { 452, 482, "[" }, ["]"] = { 452, 482, "]" }, ["\\"] = { 447, 462, "\\textbackslash{}" },
  ["{"] = { 465, 498, "\\{" }, ["}"] = { 465, 498, "\\}" }, ["|"] = { 225, 245, "\\textbar{}" },
}

local function wide_glyphs(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(l) do
    if el.t == "Str" and el.text:find("[%(%)%*%+/<=>%[%]\\{}|]") then
      local buf = ""
      for _, c in utf8.codes(el.text) do
        local ch = utf8.char(c)
        local w = WIDE[ch]
        if w then
          if buf ~= "" then out:insert(pandoc.Str(buf)); buf = "" end
          out:insert(pandoc.RawInline("latex", string.format("\\dcg{%d}{%d}{%s}", w[1], w[2], w[3])))
        else
          buf = buf .. ch
        end
      end
      if buf ~= "" then out:insert(pandoc.Str(buf)) end
    else
      out:insert(el)
    end
  end
  return out
end

local function inlines(l)
  return wide_glyphs(xe.inlines(ellipsis(l)))
end

-- Meta inlines (or a plain string) to LaTeX, through the cross-engine inline rules.
local function tex(x)
  if x == nil then return "" end
  if type(x) == "string" then
    local blocks = pandoc.read(x, "markdown+smart").blocks
    x = blocks[1] and blocks[1].content or pandoc.Inlines({})
  end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines(pandoc.Inlines(x))) }), "latex")
  return (s:gsub("%s+$", ""))
end

-- Meta blocks (a markdown text of paragraphs) to LaTeX.
local function tex_blocks(x)
  local blocks
  if type(x) == "string" then blocks = pandoc.read(x, "markdown+smart").blocks
  elseif pandoc.utils.type(x) == "Blocks" then blocks = x
  else blocks = { pandoc.Para(x) } end
  blocks = pandoc.Pandoc(blocks):walk({ Inlines = inlines }).blocks
  return (pandoc.write(pandoc.Pandoc(blocks), "latex"):gsub("%s+$", ""))
end

local function plain(x)
  if x == nil then return "" end
  if type(x) == "string" then return x end
  return stringify(x)
end

local function need(m, key)
  if m[key] == nil then error("cadc.lua: missing required metadata field `" .. key .. "`") end
  return m[key]
end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Words (FRAP 32(f)): the typst template's count of the markdown source (count-words)
-- ---------------------------------------------------------------------------

local function count_md(md)
  md = md:gsub("<!%-%-.-%-%->", " ")
  local lines = {}
  for line in (md .. "\n"):gmatch("(.-)\r?\n") do
    line = line:gsub("^%[%^[^%]]+%]:", " ")       -- footnote definition labels
    line = line:gsub("^#+[ \t]+", "")             -- heading markers
    line = line:gsub("^>[ \t]?", "")              -- quotation markers
    line = line:gsub("^[ \t]*[-*+][ \t]+", "")    -- list markers are not words
    line = line:gsub("^[ \t]*%d+[.)][ \t]+", "")
    lines[#lines + 1] = line
  end
  local s = table.concat(lines, "\n")
  s = s:gsub("%[%^[^%]]+%]", "")                 -- footnote references
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")      -- links keep their text
  s = s:gsub("\\(.)", "%1")
  s = s:gsub("%*", "")
  local n = 0
  for w in s:gmatch("%S+") do
    if w:gsub("_", "") ~= "" then n = n + 1 end
  end
  return n
end

-- The markdown body of the input file (the frontmatter dropped), up to an "# Addendum" heading.
local function source_body()
  local f = PANDOC_STATE.input_files[1] and io.open(PANDOC_STATE.input_files[1], "r")
  if not f then error("cadc.lua: cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
  local a = src:find("\n# Addendum[ \t]*\r?\n")
  if a then src = src:sub(1, a) end
  return src
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block is
-- not a heading and not a footnote definition.
local function keep_last(src)
  local text = src:gsub("%s+$", "")
  local cut = 1
  for e in text:gmatch("\n[ \t]*\n()") do cut = e end
  local tail = text:sub(cut)
  return tail ~= "" and tail:sub(1, 1) ~= "#" and tail:sub(1, 2) ~= "[^"
end

-- Markers such as (A) or I. that open a paragraph are text, as written (typst's markdown reader knows only "1." and
-- "1)" as list markers); pandoc reads them as list items, which would be renumbered.
local function roman(n)
  local out = ""
  for _, p in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function marker(style, n)
  if style == "UpperAlpha" then return string.char(64 + n)
  elseif style == "LowerAlpha" then return string.char(96 + n)
  elseif style == "UpperRoman" then return roman(n)
  elseif style == "LowerRoman" then return roman(n):lower()
  end
  return tostring(n)
end

local function ordered_list(l)
  local a = l.listAttributes
  if (a.style == "Decimal" or a.style == "DefaultStyle") and a.delimiter ~= "TwoParens" then return nil end
  local out = {}
  for i, item in ipairs(l.content) do
    local lab = marker(a.style, a.start + i - 1)
    if a.delimiter == "TwoParens" then lab = "(" .. lab .. ")"
    elseif a.delimiter == "OneParen" then lab = lab .. ")"
    else lab = lab .. "." end
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local x = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
      x:extend(first.content)
      item[1] = pandoc.Para(x)
    end
    for _, b in ipairs(item) do out[#out + 1] = b end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover [cover-body]
-- ---------------------------------------------------------------------------

local GAP = 10 -- typst cover-gap; caption 1.12 x, title and date 1.4 x

local function cover(m)
  local out = { "\\thispagestyle{empty}\\begingroup\\dccover\\centering\\parindent=0pt\\relax" }
  local function add(s) out[#out + 1] = s end
  local function gap(x) add(string.format("\\dcgap{%.2f}", x)) end
  add("{\\bfseries\\MakeUppercase{" .. tex(need(m, "oral_argument")) .. "}\\par}")
  gap(GAP)
  add("No. " .. tex(need(m, "case_number")) .. "\\par")
  gap(GAP)
  add("UNITED STATES COURT OF APPEALS\\par")
  gap(2.8)
  add("FOR THE DISTRICT OF COLUMBIA CIRCUIT\\par")
  gap(GAP * 1.12)
  for i, side in ipairs(need(m, "caption")) do
    if i > 1 then gap(5.6); add("v.\\par"); gap(5.6) end
    for _, n in ipairs(side.names) do add(tex(n) .. "\\par") end
    gap(4.2)
    add(tex(side.designation) .. "\\par")
  end
  gap(GAP * 1.12)
  add(tex(need(m, "proceeding")) .. "\\par")
  if m.district_court_case then gap(4.2); add(tex(m.district_court_case) .. "\\par") end
  if m.judge then gap(4.2); add(tex(m.judge) .. "\\par") end
  gap(GAP * 1.4)
  add("{\\bfseries\\MakeUppercase{" .. tex(need(m, "brief_title")) .. "}\\par}")
  gap(GAP * 1.4)
  local groups = need(m, "counsel")
  local function group(g)
    if not g then return "" end
    local ls = {}
    for _, n in ipairs(g.names) do ls[#ls + 1] = tex(n) .. "\\par" end
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = "\\emph{" .. tex(l) .. "}\\par" end
    return table.concat(ls, " ")
  end
  for i = 1, #groups, 2 do
    if i > 1 then gap(8.4) end
    add("\\dccounselrow{" .. group(groups[i]) .. "}{" .. group(groups[i + 1]) .. "}")
  end
  if m.date then gap(GAP * 1.4); add("{\\leftskip=0pt\\rightskip=0pt plus 1fil\\relax\\noindent " .. tex(m.date) .. "\\par}") end
  add("\\endgroup\\clearpage")
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- Certificate as to parties, tables, glossary
-- ---------------------------------------------------------------------------

local function certificate(m)
  local c = need(m, "certificate")
  local out = { "\\pagenumbering{roman}\\setcounter{page}{1}\\normalsize",
    "\\dchone{CERTIFICATE AS TO PARTIES, RULINGS, AND RELATED CASES, AND RULE 26.1 DISCLOSURE}",
    tex("Pursuant to Circuit Rule 28(a)(1) and Federal Rule of Appellate Procedure 26.1, the undersigned counsel certifies as follows:") .. "\\par" }
  for _, p in ipairs({ { "A. Parties and Amici", c.parties }, { "B. Rulings Under Review", c.rulings },
    { "C. Related Cases", c.related }, { "Rule 26.1 Disclosure", c.disclosure } }) do
    out[#out + 1] = "\\par\\addvspace{11.2bp}\\noindent\\textbf{" .. p[1] .. "}\\par\\nobreak"
    out[#out + 1] = tex_blocks(p[2])
  end
  out[#out + 1] = "\\clearpage"
  return table.concat(out, "\n")
end

local KINDS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "regulation", "Regulations" },
  { "rule", "Rules" },
  { "other", "Other Authorities" },
}

-- Sort key as typst's: case-insensitive, digit runs compared by value (8 digits).
local function sort_key(a)
  local k = plain(a.sort or a.name or a.cite)
  return (k:lower():gsub("%d+", function(d) return string.rep("0", math.max(0, 8 - #d)) .. d end))
end

local function toa(auths, cited)
  local out = { "\\dchone{TABLE OF AUTHORITIES}" }
  local first = true
  for _, g in ipairs(KINDS) do
    local members = {}
    for key, a in pairs(auths) do
      if cited[key] and plain(a.kind) == g[1] then members[#members + 1] = { key = key, a = a, sort = sort_key(a) } end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      out[#out + 1] = "\\toagroup{" .. (first and "4bp" or "16bp") .. "}{" .. g[2] .. "}"
      first = false
      for _, mem in ipairs(members) do
        local a = mem.a
        local text = tex(a.cite)
        if a.name then
          text = (g[1] == "case" and ("\\emph{" .. tex(a.name) .. "}") or tex(a.name)) .. ", " .. text
        end
        out[#out + 1] = "\\toaitem{" .. mem.key .. "}{" .. text .. "}"
      end
    end
  end
  out[#out + 1] = "\\clearpage"
  return table.concat(out, "\n")
end

local function glossary(m)
  if not m.glossary then return nil end
  local out = { "\\dchone{GLOSSARY}\\begingroup\\dcsingle" }
  for i, g in ipairs(m.glossary) do
    out[#out + 1] = (i > 1 and "\\par\\addvspace{5bp}" or "\\par") ..
      "\\noindent\\hangindent=1in\\relax\\hangafter=1\\relax\\makebox[1in][l]{" .. tex(g.abbr) .. "}" .. tex(g.meaning) .. "\\par"
  end
  out[#out + 1] = "\\endgroup\\clearpage"
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- Signature and certificates
-- ---------------------------------------------------------------------------

local function signature(m, keep)
  local sig = need(m, "signature")
  local out = { (keep and "\\par\\nobreak\\addvspace{12bp}\\nobreak" or "\\par\\addvspace{12bp}") ..
    "\\begingroup\\dcsingle\\interlinepenalty=10000\\relax\\parindent=0pt\\relax" }
  local function add(s) out[#out + 1] = s end
  add("\\noindent\\makebox[\\dcsigcol][l]{" .. (m.date and tex(m.date) or "") .. "}Respectfully submitted,\\par\\nobreak")
  add("\\leftskip=\\dcsigcol\\relax\\addvspace{7bp}")
  add(tex("/s/ " .. plain(sig.signer)) .. "\\par\\nobreak " .. tex(sig.signer) .. "\\par\\nobreak\\addvspace{1bp}")
  local ls = {}
  for _, l in ipairs(sig.lines or {}) do ls[#ls + 1] = "\\emph{" .. tex(l) .. "}\\par" end
  add(table.concat(ls, "\\nobreak "))
  add("\\endgroup")
  return table.concat(out, "\n")
end

local function certsig(m)
  local s = tex(need(m, "signature").signer)
  return "\\dccertsig{" .. tex("/s/ " .. plain(need(m, "signature").signer)) .. "\\par\\nobreak " .. s .. "}"
end

local function certificates(m, words)
  local out = {
    "\\clearpage\\dchone{CERTIFICATE OF COMPLIANCE}",
    "\\noindent " .. tex("This document complies with the type-volume limitations of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by the Federal Rules of Appellate Procedure and this Court's rules, this document contains " .. group_digits(words) .. " words, as calculated by my word processing software.") .. "\\par",
    "\\addvspace{11.2bp}\\noindent " .. tex("This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because this document has been prepared in a proportionally spaced typeface, 14-point " .. TYPEFACE .. ", using " .. plain(need(m, "word_processor")) .. ".") .. "\\par",
    certsig(m),
    "\\clearpage\\dchone{CERTIFICATE OF SERVICE}",
    tex("I hereby certify that, on " .. plain(need(m, "date")) .. ", the foregoing document was served through the Court's ECF system on counsel for all parties.") .. "\\par",
    certsig(m),
  }
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

local function heading(b)
  local t = tex(b.content)
  if b.level == 1 then return raw("\\dchone{" .. t .. "}") end
  if b.level == 2 then return raw("\\dchtwo{" .. t .. "}") end
  return raw("\\dchthree{" .. t .. "}")
end

function Pandoc(doc)
  local m = doc.meta
  local auths = m.authorities or {}
  for _, k in ipairs({ "case_number", "oral_argument", "caption", "proceeding", "brief_title", "counsel", "date",
    "word_processor", "certificate", "signature" }) do
    need(m, k)
  end
  local src = source_body()
  local words = count_md(src)
  if words > WORD_LIMIT then
    error("cadc.lua: body is " .. words .. " words; FRAP 28.1(e)(2)(A)(i) allows " .. WORD_LIMIT)
  end

  -- citations: a link to toa:<key> marks its page; then the cross-engine inline rules over the body text
  local cited = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if key == nil then return el.content end
      if auths[key] == nil then error("cadc.lua: cited authority `" .. key .. "` is not in the authorities registry") end
      cited[key] = true
      local out = pandoc.Inlines({ pandoc.RawInline("latex", "\\toamark{" .. key .. "}") })
      out:extend(el.content)
      return out
    end,
  })
  doc = doc:walk({ Inlines = inlines })
  doc = doc:walk({ OrderedList = ordered_list })

  -- split at `# Addendum`
  local body, add = {}, nil
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and stringify(b.content) == "Addendum" then
      add = {}
    elseif add then
      add[#add + 1] = b.t == "Header" and heading(b) or b
    else
      body[#body + 1] = b.t == "Header" and heading(b) or b
    end
  end

  local out = {}
  local function put(x) out[#out + 1] = type(x) == "string" and raw(x) or x end
  put(cover(m))
  put(certificate(m))
  put("\\dchoneplain{TABLE OF CONTENTS}\\dcTOC\\clearpage")
  put(toa(auths, cited))
  local g = glossary(m)
  if g then put(g) end

  -- body (arabic from 1); the last paragraph is not broken and stays with the signature block (typst: one
  -- unbreakable block, unless the last markdown block is a heading or a footnote definition)
  put("\\pagenumbering{arabic}\\setcounter{page}{1}\\normalsize")
  local n = #body
  local keep = keep_last(src) and n > 0 and body[n].t == "Para"
  for i = 1, n do
    if i == n and keep then
      put("\\begingroup\\interlinepenalty=10000\\relax")
      put(body[i])
      put("\\par\\endgroup")
    else
      put(body[i])
    end
  end
  put(signature(m, keep))
  put(certificates(m, words))
  if add then
    put("\\clearpage\\normalsize")
    for _, b in ipairs(add) do put(b) end
  end
  return pandoc.Pandoc(out, doc.meta)
end

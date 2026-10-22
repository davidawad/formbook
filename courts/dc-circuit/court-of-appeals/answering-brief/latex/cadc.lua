-- D.C. Circuit answering brief, LaTeX engine: the parts of the typst template (typst/cadc-answering-brief.typ) that
-- pandoc cannot write itself. Read by fb render as a pandoc filter, next to template.tex.
--
-- Builds from the frontmatter: the cover, the certificate of parties, rulings and related cases (page ii), the table
-- of contents and the table of authorities (both two-pass, see template.tex), the signature block, the certificates
-- and the addendum (D.C. Cir. R. 28(a)(5), after `# Addendum`). Headings get their labels here (I., A., 1., a. in the
-- Argument; A., 1., a., (1) elsewhere) and become \briefhead / \briefpoint / \briefsub commands. Each citation of an
-- authority (a link to toa:<key>) gets a page mark.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the inline rules of lib/latex/xengine.lua run over
-- the body and over every metadata value; every space between blocks is an \addvspace in bp, as typst spaces them.
local WORD_LIMIT = 13000 -- FRAP 32(a)(7)(B)(i): principal brief (appellee's brief included)
local TYPEFACE = "TeX Gyre Schola" -- the typst template's font (tgschola here is the same face)

local xe = require("latex.xengine")
local stringify = pandoc.utils.stringify

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- An ellipsis character (…) as one glyph-wide unit, as typst and Word set it (template.tex \briefellipsis); pandoc
-- would write \ldots, three periods narrower than the glyph.
local function ellipsis(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(l) do
    if el.t == "Str" and el.text:find("\u{2026}", 1, true) then
      local rest = el.text
      while true do
        local s, e = rest:find("\u{2026}", 1, true)
        if not s then break end
        if s > 1 then out:insert(pandoc.Str(rest:sub(1, s - 1))) end
        out:insert(pandoc.RawInline("latex", "\\briefellipsis{}"))
        rest = rest:sub(e + 1)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end

-- The glyphs whose advance differs between the vendored TeX Gyre Schola (OpenType, which typst and LibreOffice set)
-- and TeX Live's tgschola (Type 1): each is set centered in a box of the OpenType advance (template.tex \cadcg),
-- units per 1000 em for regular, italic, bold and bold italic, as typst measures them.
local GLYPH = {
  ["("] = { 483, 483, 519, 519 }, [")"] = { 483, 483, 519, 519 },
  ["["] = { 452, 452, 482, 482 }, ["]"] = { 452, 452, 482, 482 },
  ["/"] = { 447, 447, 462, 462 }, ["*"] = { 420, 420, 483, 483 }, ["+"] = { 780, 780, 800, 800 },
}

-- The f-ligatures: LibreOffice sets TeX Gyre Schola's (OpenType liga, on by default and not to be turned off from a
-- .docx), so typst sets them too (typst/cadc-answering-brief.typ) and so does this engine, as the T1 font's ligature
-- glyphs (the same advances); xengine.sty turns TeX's own ligature program off, so they are written out (longest
-- first), inside the word's ActualText span.
local LIGATURES = { { "ffi", "1E" }, { "ffl", "1F" }, { "ff", "1B" }, { "fi", "1C" }, { "fl", "1D" } }

-- The word as UTF-16BE hex, for its ActualText: the PDF text of a word with boxed glyphs is the word itself, without
-- the gaps the boxes leave around the narrower Type 1 glyphs (pdftotext would read ")(" as ") (").
local function utf16hex(s)
  local out = {}
  for _, c in utf8.codes(s) do
    if c >= 0x10000 then
      c = c - 0x10000
      out[#out + 1] = string.format("%04X%04X", 0xD800 + (c >> 10), 0xDC00 + (c & 0x3FF))
    else
      out[#out + 1] = string.format("%04X", c)
    end
  end
  return table.concat(out)
end

local function glyphs(l)
  -- adjacent words are one word ("(1833)" from a citation link and the ")." after it)
  local merged = pandoc.Inlines({})
  for _, el in ipairs(l) do
    local prev = merged[#merged]
    if el.t == "Str" and prev and prev.t == "Str" then
      merged[#merged] = pandoc.Str(prev.text .. el.text)
    else
      merged:insert(el)
    end
  end
  local out = pandoc.Inlines({})
  -- one piece of a word: its boxed glyphs inside a span that carries its text
  local function piece(text)
    if not text:find("[%(%)%[%]/%*%+]") and not text:find("f[fil]") then
      out:insert(pandoc.Str(text))
      return
    end
    out:insert(pandoc.RawInline("latex", "\\cadcspan{" .. utf16hex(text) .. "}"))
    local buf = ""
    local function flush()
      if buf ~= "" then out:insert(pandoc.Str(buf)); buf = "" end
    end
    local i = 1
    while i <= #text do
      local lig
      for _, l in ipairs(LIGATURES) do
        if text:sub(i, i + #l[1] - 1) == l[1] then lig = l; break end
      end
      if lig then
        flush()
        out:insert(pandoc.RawInline("latex", "\\char\"" .. lig[2] .. "{}"))
        i = i + #lig[1]
      else
        local ch = text:sub(i, i)
        local w = GLYPH[ch]
        if w then
          flush()
          out:insert(pandoc.RawInline("latex", string.format("\\cadcg{%s}{%d}{%d}{%d}{%d}",
            (ch == "[" or ch == "]") and ("{" .. ch .. "}") or ch, w[1], w[2], w[3], w[4])))
        else
          buf = buf .. ch
        end
        i = i + 1
      end
    end
    flush()
    out:insert(pandoc.RawInline("latex", "\\cadcend{}"))
  end
  for _, el in ipairs(merged) do
    if el.t == "Str" then
      piece(el.text)
    else
      out:insert(el)
    end
  end
  return out
end

local function inlines(l)
  return glyphs(xe.inlines(ellipsis(l)))
end

-- Meta inlines (or a plain string) to LaTeX, through the cross-engine inline rules.
local function tex(x)
  if x == nil then return "" end
  if type(x) == "string" then
    local blocks = pandoc.read(x, "markdown+smart").blocks
    x = blocks[1] and blocks[1].content or pandoc.Inlines({})
  end
  if pandoc.utils.type(x) == "Blocks" then
    x = x[1] and x[1].content or pandoc.Inlines({})
  end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines(pandoc.Inlines(x))) }), "latex")
  return (s:gsub("%s+$", ""))
end

-- The template's own words, through the same inline rules as the body (an outer space is kept as "\ ").
local function words_tex(s)
  local t = tex(s)
  if s:sub(1, 1) == " " then t = "\\ " .. t end
  if s:sub(-1) == " " then t = t .. "\\ " end
  return t
end

-- A metadata value of several paragraphs (the certificate of parties): each paragraph through tex(), `gap` bp apart.
local function paras(x, gap)
  local blocks
  if pandoc.utils.type(x) == "Blocks" then blocks = x
  elseif pandoc.utils.type(x) == "Inlines" then blocks = { pandoc.Para(x) }
  else blocks = pandoc.read(stringify(x), "markdown+smart").blocks end
  local out = {}
  for _, b in ipairs(blocks) do
    if b.content then out[#out + 1] = tex(b.content) .. "\\par" end
  end
  return table.concat(out, "\\addvspace{" .. gap .. "bp}\n")
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

local function raw(s) return pandoc.RawBlock("latex", s) end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function letter(n, lower) return string.char((lower and 96 or 64) + n) end

-- Sort key as typst's: lower case, letters, digits and spaces only.
local function sort_key(a)
  local k = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  return (k:lower():gsub("[^a-z0-9 ]", ""))
end

-- 13000 -> "13,000"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Words (FRAP 32(f)): the typst template's count of the markdown source, so every engine certifies the same number
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
  local a = src:find("\n#[ \t]+[Aa][Dd][Dd][Ee][Nn][Dd][Uu][Mm][ \t]*\r?\n")
  if a then src = src:sub(1, a) end
  return src
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block of
-- the text before the footnote definitions is not a heading and holds no footnote.
local function keep_last(src)
  local text = src:gsub("%s+$", "")
  local d = text:find("\n\n%[%^[^%]]+%]:")
  if d then text = text:sub(1, d - 1) end
  local cut = 1
  for e in text:gmatch("\n[ \t]*\n()") do cut = e end
  local tail = text:sub(cut)
  if tail == "" or tail:sub(1, 1) == "#" then return false end
  if tail:find("[^", 1, true) then return false end
  return true
end

-- ---------------------------------------------------------------------------
-- Headings: labels and the table-of-contents entry (see template.tex)
-- ---------------------------------------------------------------------------

local TOC_DEPTH = 4

local function heading_label(level, n, in_argument)
  if in_argument then
    if level == 2 then return roman(n) .. "."
    elseif level == 3 then return letter(n, false) .. "."
    elseif level == 4 then return tostring(n) .. "."
    elseif level == 5 then return letter(n, true) .. "."
    end
  else
    if level == 2 then return letter(n, false) .. "."
    elseif level == 3 then return tostring(n) .. "."
    elseif level == 4 then return letter(n, true) .. "."
    elseif level == 5 then return "(" .. n .. ")"
    end
  end
  error("cadc.lua: headings deeper than level 5 are not supported")
end

-- The label's indent in half inches (typst label-indent): the Argument's point headings are centered, so their
-- sub-headings start at the first step.
local function label_steps(level, in_argument)
  local first = in_argument and 3 or 2
  return level - first + 1
end

local function inches(steps) return (steps * 0.5) .. "in" end

local function heading(h, counts, state)
  local lvl = h.level
  if lvl > 5 then error("cadc.lua: headings deeper than level 5 are not supported") end
  local title = tex(h.content)
  if lvl == 1 then
    state.in_argument = plain(h.content):lower():match("^%s*(.-)%s*$") == "argument"
    for j = 2, 5 do counts[j] = 0 end
    return raw(string.format("\\briefhead{%s}\\addcontentsline{toc}{brieftoc}{\\MakeUppercase{%s}}", title, title))
  end
  counts[lvl] = counts[lvl] + 1
  for j = lvl + 1, 5 do counts[j] = 0 end
  local label = heading_label(lvl, counts[lvl], state.in_argument)
  local toc = ""
  if lvl <= TOC_DEPTH then
    local ind = label_steps(lvl, state.in_argument)
    if state.in_argument and lvl == 2 then ind = 0 end
    toc = string.format("\\addcontentsline{toc}{briefn}{{%s}{%s}{%s}}", inches(ind), label, title)
  end
  if state.in_argument and lvl == 2 then
    return raw(string.format("\\briefpoint{%s}{%s}%s", label, title, toc))
  end
  local style = lvl >= 4 and "\\bfseries\\itshape" or "\\bfseries"
  return raw(string.format("\\briefsub{%s}{%s}{%s}{%s}%s",
    inches(label_steps(lvl, state.in_argument)), label, style, title, toc))
end

-- The addendum's headings: unnumbered; level 1 a section heading, level 2 bold at the margin and listed in the
-- addendum's own table of contents (file adt), deeper ones bold at the margin.
local function addendum_heading(h)
  local title = tex(h.content)
  if h.level == 1 then return raw("\\briefhead{" .. title .. "}") end
  if h.level == 2 then
    return raw("\\briefplain{" .. title .. "}\\addcontentsline{adt}{briefaddn}{{0in}{}{" .. title .. "}}")
  end
  return raw("\\briefplain{" .. title .. "}")
end

-- Markers such as (A) that open a paragraph are text, as written (typst's markdown reader knows only "1." and "1)"
-- as list markers); pandoc reads them as list items, which would be renumbered.
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
  if (a.style == "Decimal" or a.style == "DefaultStyle") and a.delimiter ~= "TwoParens" then
    return { l }
  end
  local out = {}
  for i, item in ipairs(l.content) do
    local lab = marker(a.style, a.start + i - 1)
    if a.delimiter == "TwoParens" then lab = "(" .. lab .. ")"
    elseif a.delimiter == "OneParen" then lab = lab .. ")"
    else lab = lab .. "." end
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inl = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
      inl:extend(first.content)
      item[1] = pandoc.Para(inl)
    end
    for _, b in ipairs(item) do table.insert(out, b) end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover, tables, signature and certificates
-- ---------------------------------------------------------------------------

-- The right half of the text (typst pad(left: 50%)): ragged right.
local HALF = "\\leftskip=0.5\\linewidth\\rightskip=0pt plus 1fil\\relax"

-- typst cover-body: the gap between the parts is 1 em (14 bp), or less when the cover would not fit one page.
local function cover(m)
  local out = {}
  local function add(s) out[#out + 1] = s end
  local gap = "\\briefgap{14}"
  add("\\thispagestyle{empty}\\begingroup\\briefsingle\\centering\\parskip=4.9bp\\relax")
  if m.oral_argument then
    add("{\\raggedright\\noindent\\bfseries " .. tex(m.oral_argument) .. "\\par}\\briefgap{8.4}")
  end
  add("{\\bfseries No.\\ " .. tex(need(m, "case_number")) .. "\\par}")
  add(gap .. "\\briefdouble" .. gap)
  add("{\\bfseries UNITED STATES COURT OF APPEALS\\\\FOR THE DISTRICT OF COLUMBIA CIRCUIT\\par}")
  add(gap .. "\\briefrulesmall" .. gap)
  local sides = need(m, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. "\\par") end
    add("{" .. HALF .. "\\noindent " .. tex(side.designation) .. "\\par}")
    if i < #sides then add("\\briefgap{4.2}v.\\par\\briefgap{4.2}") end
  end
  add(gap .. "\\briefrulesmall" .. gap)
  add(tex(need(m, "proceeding")) .. "\\par")
  if m.district_court_case or m.judge then
    local x = ""
    if m.district_court_case then x = tex(m.district_court_case) end
    if m.district_court_case and m.judge then x = x .. "; " end
    if m.judge then x = x .. tex(m.judge) end
    add(x .. "\\par")
  end
  add(gap .. "\\briefrulesmall" .. gap)
  add("{\\bfseries\\MakeUppercase{" .. tex(pandoc.text.upper(plain(need(m, "brief_title")))) .. "}\\par}")
  add(gap .. "\\briefrulesmall" .. gap)
  -- Counsel (FRAP 32(a)(2)(F)): name, office address, telephone number, at the right half; 7 bp between groups.
  local groups = need(m, "counsel")
  local blocks = {}
  for gi, g in ipairs(groups) do
    local ls = {}
    for _, n in ipairs(g.names) do ls[#ls + 1] = tex(n) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = need(m, "phone") end
    for _, l in ipairs(lines) do ls[#ls + 1] = "\\hspace*{0.5em}\\emph{" .. tex(l) .. "}" end
    blocks[#blocks + 1] = "\\noindent " .. table.concat(ls, "\\newline ") .. "\\par"
  end
  add("{" .. HALF .. "\\parskip=7bp\\relax\\interlinepenalty=10000\\relax " .. table.concat(blocks, "\n") .. "}")
  add(gap .. "\\briefdouble")
  add("\\par\\endgroup")
  return table.concat(out, "\n")
end

-- Certificate of parties, rulings and related cases (D.C. Cir. R. 28(a)(1)); statutes and regulations (28(a)(5)).
local function certificate_of_parties(m)
  local out = { "\\briefhead{Certificate of Parties, Rulings, and Related Cases}",
    "\\begin{briefcert}" .. paras(need(m, "certificate_of_parties"), 14) .. "\\end{briefcert}" }
  if m.statutes_and_regulations then
    out[#out + 1] = "\\briefhead{Statutes and Regulations}"
    out[#out + 1] = "\\begin{briefcert}" .. paras(m.statutes_and_regulations, 14) .. "\\end{briefcert}"
  end
  return table.concat(out, "\n")
end

-- Table of authorities: groups of the authorities cited in the body, in typst's order.
local TOA_GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

local function toa(auths, cited)
  local out = { "\\briefhead{Table of Authorities}" }
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auths) do
      if plain(a.kind) == g[1] and cited[key] then
        table.insert(members, { key = key, a = a, sort = sort_key(a) })
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      table.insert(out, (first and "\\toagroupfirst{" or "\\toagroup{") .. g[2] .. "}")
      first = false
      for _, mem in ipairs(members) do
        local cite = tex(mem.a.cite)
        if mem.a.name then
          local name = (g[1] == "case") and ("\\emph{" .. tex(mem.a.name) .. "}") or tex(mem.a.name)
          table.insert(out, "\\toaitem{" .. mem.key .. "}{" .. name .. "}{" .. cite .. "}")
        else
          table.insert(out, "\\toaitemnoname{" .. mem.key .. "}{" .. cite .. "}")
        end
      end
    end
  end
  return table.concat(out, "\n")
end

-- The signature block (typst signature-block): kept whole, and with the brief's last paragraph when `keep`.
local function signature(m, keep)
  local sig = need(m, "signature")
  local lines = { words_tex("/s/ ") .. tex(sig.signer), tex(pandoc.text.upper(plain(sig.signer))) }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = "\\hspace*{0.5em}\\emph{" .. tex(l) .. "}" end
  return (keep and "\\par\\nobreak\\addvspace{19.6bp}\\nobreak" or "\\par\\addvspace{19.6bp}") ..
    "\\begingroup\\briefsingle\\interlinepenalty=10000\\relax\\parindent=0pt\\relax" .. HALF ..
    " Respectfully submitted,\\par\\nobreak\\vspace{16.8bp}\\nobreak\n" ..
    table.concat(lines, "\\newline ") .. "\\par\\endgroup"
end

-- A certificate's signature (typst form-sig-line): at the right half, the first signature line only.
local function sig_foot(m)
  local sig = need(m, "signature")
  local lines = { words_tex("/s/ ") .. tex(sig.signer), tex(pandoc.text.upper(plain(sig.signer))) }
  if sig.lines and sig.lines[1] then lines[#lines + 1] = "\\hspace*{0.5em}\\emph{" .. tex(sig.lines[1]) .. "}" end
  return "\\par\\nobreak\\addvspace{22.4bp}\\nobreak\\begingroup\\briefsingle\\interlinepenalty=10000\\relax" .. HALF ..
    "\\noindent " .. table.concat(lines, "\\newline ") .. "\\par\\endgroup"
end

local function certificate_of_compliance(words)
  return "\\clearpage\n\\briefhead{Certificate of Compliance}\n\\begin{briefcert}" ..
    words_tex("I HEREBY CERTIFY pursuant to Fed. R. App. P. 32(g) that this brief contains " .. group_digits(words) ..
      " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f) and D.C. Circuit Rule 32(e)(1), and therefore complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B). This brief has been prepared in 14-point " ..
      TYPEFACE .. ", a proportionally spaced typeface.") .. "\\par\\end{briefcert}"
end

local function certificate_of_service(m)
  local svc = need(m, "service")
  return "\\clearpage\n\\briefhead{Certificate of Service}\n\\begin{briefcert}" ..
    words_tex("I HEREBY CERTIFY that I have caused a copy of the foregoing ") .. tex(svc.document) ..
    words_tex(" to be served by electronic means, through the Court\u{2019}s CM/ECF system, upon ") ..
    tex(svc.served_upon) .. words_tex(", on this ") .. tex(svc.date) .. ".\\par\\end{briefcert}"
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local auths = m.authorities or {}
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature",
    "certificate_of_parties" }) do
    need(m, k)
  end

  local words = count_md(source_body())
  if words > WORD_LIMIT then
    error("cadc.lua: the brief has " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. WORD_LIMIT)
  end

  -- citations: a link to toa:<key> marks its page; then the cross-engine inline rules over the body text
  local cited = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if key == nil then return el.content end
      if auths[key] == nil then error("cadc.lua: link `toa:" .. key .. "` has no entry under `authorities:`") end
      cited[key] = true
      local out = pandoc.Inlines({ pandoc.RawInline("latex", "\\toamark{" .. key .. "}") })
      out:extend(el.content)
      return out
    end,
  })
  -- section headings print in capitals: their words are capitals already for the ActualText of a boxed glyph
  doc = doc:walk({
    Header = function(h)
      if h.level == 1 then return h:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }) end
    end,
  })
  doc = doc:walk({ Inlines = inlines })
  doc = doc:walk({ OrderedList = ordered_list })

  -- headings; the addendum (after `# Addendum`) apart
  local counts = { 0, 0, 0, 0, 0 }
  local state = { in_argument = false }
  local blocks, add_blocks = {}, nil
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^%s*addendum%s*$") then
      add_blocks = {}
    elseif add_blocks then
      add_blocks[#add_blocks + 1] = b.t == "Header" and addendum_heading(b) or b
    elseif b.t == "Header" then
      blocks[#blocks + 1] = heading(b, counts, state)
    else
      blocks[#blocks + 1] = b
    end
  end

  local out = {}
  local function add(b) table.insert(out, b) end

  -- the cover (page i, not printed), then lower-case roman numbering: the certificate of parties is page ii
  add(raw("\\pagenumbering{roman}\\setcounter{page}{1}"))
  add(raw(cover(m)))
  add(raw("\\clearpage"))
  add(raw(certificate_of_parties(m)))
  add(raw("\\clearpage\\briefhead{Table of Contents}\n\\briefTOCpage\n\\briefTOC{toc}"))
  add(raw("\\clearpage"))
  add(raw(toa(auths, cited)))

  -- body (arabic from 1); the last paragraph is not broken and stays with the signature block (typst: one
  -- unbreakable block, unless the brief's last markdown block is a heading or holds footnotes)
  add(raw("\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}\\normalsize"))
  local n = #blocks
  local keep = keep_last(source_body()) and n > 0 and blocks[n].t == "Para"
  for i = 1, n do
    if i == n and keep then
      add(raw("\\begingroup\\interlinepenalty=10000\\relax"))
      add(blocks[i])
      add(raw("\\par\\endgroup"))
    else
      add(blocks[i])
    end
  end
  add(raw(signature(m, keep)))

  -- certificates (FRAP 32(g); FRAP 25(d))
  add(raw(certificate_of_compliance(words) .. "\n" .. sig_foot(m)))
  local svc = m.service and m.service.certificate
  if svc == true or (svc ~= nil and plain(svc) == "true") then
    add(raw(certificate_of_service(m) .. "\n" .. sig_foot(m)))
  end

  -- the addendum (D.C. Cir. R. 28(a)(5)): pages Add-1 ..., its heading in the brief's contents, its own contents
  if add_blocks then
    add(raw("\\clearpage\\renewcommand\\thepage{Add-\\arabic{page}}\\setcounter{page}{1}" ..
      "\\briefhead{Addendum}\\addcontentsline{toc}{briefadd}{ADDENDUM}" ..
      "\\briefhead{Table of Contents}\\briefTOC{adt}\\clearpage\\normalsize"))
    for _, b in ipairs(add_blocks) do add(b) end
  end

  return pandoc.Pandoc(out, doc.meta)
end

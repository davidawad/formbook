-- U.S. Court of Appeals for the Third Circuit: pandoc filter for the LaTeX engine (one copy per doc type).
-- The same content and layout as the typst template of this doc type (typst/ca3-*.typ), from the same markdown
-- contract (../README.md). It writes raw LaTeX for the cover, the disclosure, the headings, the tables, the
-- signature blocks and the certificates; template.tex defines the macros it calls.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the inline rules of lib/latex/xengine.lua run over
-- the body and over every metadata value; every space between blocks is an \addvspace in bp, as typst spaces them.
-- Nothing here is case-specific. The only line that differs between the copies is TYPE.

local TYPE = "reply" -- "opening" | "answering" | "reply"

local LIMIT = ({ opening = 13000, answering = 13000, reply = 6500 })[TYPE]
-- "opening": I. A. 1. a. everywhere. "argument": the Argument has I. A. 1. a. (its level 2 is a centered
-- point heading); elsewhere A. 1. a. (1).
local SCHEME = (TYPE == "opening") and "opening" or "argument"
-- The typst template's face (named in the certificate of compliance).
local FACE = ({ opening = "Times New Roman", answering = "TeX Gyre Schola", reply = "Times New Roman" })[TYPE]
local TOC_DEPTH = 4

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

-- TeX Gyre Schola: the vendored OpenType face (2.609, which typst and Word set) has wider brackets, parentheses,
-- slashes and operators than TeX Live's Type 1 tgschola (2009): per mille of the em, how much wider (roman, italic,
-- bold, bold italic). A word that holds them is set in a box that much wider, its characters spread evenly across it
-- (template.tex \xgt), so every line holds the same width in every engine and no gap is wide enough to read as a space.
local WIDE = FACE == "TeX Gyre Schola" and {
  ["("] = { 150, 150, 130, 112 }, [")"] = { 150, 150, 130, 112 }, ["*"] = { -80, -80, -17, -17 },
  ["+"] = { 174, 174, 194, 194 }, ["/"] = { 169, -159, 184, 184 }, ["<"] = { 182, 182, 204, 204 },
  ["="] = { 174, 174, 194, 194 }, [">"] = { 182, 182, 204, 204 }, ["["] = { 119, 119, 93, 75 },
  ["\\"] = { -159, -159, -144, -144 }, ["]"] = { 119, 119, 93, 75 }, ["{"] = { 132, 132, 109, 91 },
  ["|"] = { -381, -381, -361, -361 }, ["}"] = { 132, 132, 109, 91 },
} or {}

local ESC = {
  ["\\"] = "\\textbackslash{}", ["{"] = "\\{", ["}"] = "\\}", ["#"] = "\\#", ["$"] = "\\$", ["%"] = "\\%",
  ["&"] = "\\&", ["_"] = "\\_", ["~"] = "\\textasciitilde{}", ["^"] = "\\textasciicircum{}", ["["] = "{[}",
  ["]"] = "{]}", ["<"] = "\\textless{}", [">"] = "\\textgreater{}", ["|"] = "\\textbar{}",
}

-- The f-ligatures: LibreOffice sets TeX Gyre Schola's (OpenType liga, on by default and not to be turned off from a
-- .docx), so the typst template sets them too and so does this engine, as the T1 font's ligature glyphs (the same
-- advances); xengine.sty turns TeX's own ligature program off, so they are written out (longest first), and the word
-- is marked with its own text (ActualText), so that the PDF text reads "ffi", not the ligature character.
local LIGATURES = FACE == "TeX Gyre Schola" and { { "ffi", "1E" }, { "ffl", "1F" }, { "ff", "1B" }, { "fi", "1C" },
  { "fl", "1D" } } or {}

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

-- One word (plain characters, `escape` them for LaTeX or not) as \xgt and/or with its ligatures, or nil when it holds
-- neither a wide character nor a ligature.
local function wide_word(text, escape)
  local d, any, lig, chars = { 0, 0, 0, 0 }, false, false, {}
  local cs = {}
  for _, c in utf8.codes(text) do cs[#cs + 1] = utf8.char(c) end
  local i = 1
  while i <= #cs do
    local hit
    for _, l in ipairs(LIGATURES) do
      if table.concat(cs, "", i, math.min(#cs, i + #l[1] - 1)) == l[1] then hit = l; break end
    end
    if hit then
      lig = true
      chars[#chars + 1] = "\\char\"" .. hit[2] .. "{}"
      i = i + #hit[1]
    else
      local ch = cs[i]
      if WIDE[ch] then
        any = true
        for k = 1, 4 do d[k] = d[k] + WIDE[ch][k] end
      end
      chars[#chars + 1] = escape and (ESC[ch] or ch) or ch
      i = i + 1
    end
  end
  if not any and not lig then return nil end
  local body = any and ("\\xgt{" .. table.concat(d, "}{") .. "}{\\hss " .. table.concat(chars, "\\hss ") .. "\\hss}")
    or table.concat(chars)
  if lig then body = "\\xeat{" .. utf16hex(text) .. "}{" .. body .. "}" end
  return body
end

local function wide(l)
  if next(WIDE) == nil then return l end
  local out = pandoc.Inlines({})
  for _, el in ipairs(l) do
    local w = el.t == "Str" and wide_word(el.text, true)
    if w then out:insert(pandoc.RawInline("latex", w)) else out:insert(el) end
  end
  return out
end

-- The same for text this filter writes itself (labels, certificate wording): every word of plain characters.
local function gl(s)
  if next(WIDE) == nil then return s end
  return (s:gsub("%S+", function(w)
    if (w:find("[%(%)%[%]/]") or w:find("f[fil]")) and not w:find("[\\{}]") then return wide_word(w, false) end
  end))
end

local function inlines(l)
  return wide(xe.inlines(ellipsis(l)))
end

-- Meta inlines (or a plain string) to LaTeX, through the cross-engine inline rules.
local function tex(x)
  if x == nil then return "" end
  if type(x) == "string" then
    local blocks = pandoc.read(x, "markdown+smart").blocks
    x = blocks[1] and blocks[1].content or pandoc.Inlines({})
  end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines(pandoc.Inlines(x))) }), "latex")
  return (s:gsub("%s*\n%s*", " "):gsub("%s+$", ""))
end

local function plain(x)
  if x == nil then return "" end
  if type(x) == "string" then return x end
  return stringify(x)
end

local function need(m, key)
  if m[key] == nil then error("ca3-" .. TYPE .. ": missing required metadata field `" .. key .. "`") end
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

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- Sort key as typst's: the name and citation, lower case, letters, digits and spaces only.
local function sort_key(a)
  local k = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  return (k:lower():gsub("[^a-z0-9 ]", ""))
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
  if not f then error("ca3-" .. TYPE .. ": cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
  local a = src:find("\n#[ \t]+[Aa][Dd][Dd][Ee][Nn][Dd][Uu][Mm][ \t]*\r?\n")
  if a then src = src:sub(1, a) end
  return src
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block (of
-- the text from the Statement of the Case on, in the opening brief) is not a heading and not a footnote definition.
local function keep_last(src)
  local text = src
  if TYPE == "opening" then
    local s = ("\n" .. text):lower():find("\n#[ \t]+statement of the case[ \t]*\n")
    if s then text = text:sub(s) end
  end
  text = text:gsub("%s+$", "")
  local cut = 1
  for e in text:gmatch("\n[ \t]*\n()") do cut = e end
  local tail = text:sub(cut)
  return tail ~= "" and tail:sub(1, 1) ~= "#" and tail:sub(1, 2) ~= "[^"
end

-- ---------------------------------------------------------------------------
-- Headings: labels and the table-of-contents entry (see template.tex)
-- ---------------------------------------------------------------------------

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

-- The label's indent in half inches (typst label-indent): the opening brief steps from the margin; the others center
-- the Argument's point headings, so their sub-headings start at the first step, and elsewhere start one step in.
local function label_steps(level, in_arg)
  if SCHEME == "opening" or in_arg then return level - 2 end
  return level - 1
end

local function inches(steps) return (steps * 0.5) .. "in" end

local function section_head(title, toc)
  local s = "\\briefhead{" .. title .. "}"
  if toc then s = s .. "\\addcontentsline{toc}{brieftoc}{\\MakeUppercase{" .. title .. "}}" end
  return s
end

local function heading(h, counts, state)
  local lvl = h.level
  if lvl > 5 then error("ca3-" .. TYPE .. ": headings deeper than level 5 are not supported") end
  local title = tex(h.content)
  if lvl == 1 then
    -- in capitals before the inline rules, as typst's upper() sets them (no ligature survives in capitals)
    title = tex(h.content:walk({ Str = function(s) s.text = pandoc.text.upper(s.text); return s end }))
    state.in_arg = SCHEME == "argument" and plain(h.content):lower():match("^%s*(.-)%s*$") == "argument"
    for j = 2, 5 do counts[j] = 0 end
    return raw(section_head(title, true))
  end
  counts[lvl] = counts[lvl] + 1
  for j = lvl + 1, 5 do counts[j] = 0 end
  local label = gl(label_for(lvl, counts[lvl], state.in_arg))
  local point = state.in_arg and lvl == 2
  local toc = ""
  if lvl <= TOC_DEPTH then
    local ind = point and 0 or label_steps(lvl, state.in_arg)
    toc = string.format("\\addcontentsline{toc}{briefn}{{%s}{%s}{%s}}", inches(ind), label, title)
  end
  if point then
    return raw(string.format("\\briefpoint{%s}{%s}%s", label, title, toc))
  end
  local style = lvl >= 4 and "\\bfseries\\itshape" or "\\bfseries"
  return raw(string.format("\\briefsub{%s}{%s}{%s}{%s}%s",
    inches(label_steps(lvl, state.in_arg)), label, style, title, toc))
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
-- Cover (typst cover-body)
-- ---------------------------------------------------------------------------

local GAP = "\\briefgap{14}"
local GAP3 = "\\briefgap{4.2}"

-- One counsel group: names, then the lines half an em in (italic in the answering and reply briefs); the last group
-- carries the phone and then (opening and answering briefs) the party counsel act for.
local function counsel_lines(m, g, last)
  local out = {}
  local function line(x, italic) out[#out + 1] = "\\hspace*{0.5em}" .. (italic and ("\\emph{" .. x .. "}") or x) end
  for _, n in ipairs(g.names) do out[#out + 1] = tex(n) end
  local italic = TYPE ~= "opening"
  for _, l in ipairs(g.lines or {}) do line(tex(l), italic) end
  if last then
    line(tex(need(m, "phone")), italic)
    if TYPE ~= "reply" and m.counsel_for then line(tex(m.counsel_for), true) end
  end
  return table.concat(out, "\\newline ")
end

local function cover(m)
  local out = {}
  local function add(s) out[#out + 1] = s end
  add("\\thispagestyle{empty}\\begingroup\\briefsingle\\centering\\parskip=4.9bp\\relax")
  add("{\\bfseries No.\\ " .. tex(need(m, "case_number")) .. "\\par}")
  add(GAP .. "\\brieffull" .. GAP)
  if TYPE == "opening" then
    add("{\\bfseries IN THE UNITED STATES COURT OF APPEALS FOR THE~THIRD~CIRCUIT\\par}")
  else
    add("{\\bfseries IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE THIRD CIRCUIT\\par}")
  end
  add(GAP .. "\\briefrulesmall" .. GAP)
  local sides = need(m, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. "\\par") end
    add(tex(side.designation) .. "\\par") -- centered under the names (typst)
    if i < #sides then add(GAP3 .. "v.\\par" .. GAP3) end
  end
  add(GAP .. "\\briefrulesmall" .. GAP)
  add(tex(need(m, "proceeding")) .. "\\par")
  if TYPE == "opening" then
    if m.district_court_case then add("(" .. tex(m.district_court_case) .. ")\\par") end
    if m.judge then add("(" .. tex(m.judge) .. ")\\par") end
  elseif TYPE == "answering" then
    if m.district_court_case or m.judge then
      local parts = {}
      if m.district_court_case then parts[#parts + 1] = "D.C. No. " .. tex(m.district_court_case) end
      if m.judge then parts[#parts + 1] = tex(m.judge) end
      add(table.concat(parts, "; ") .. "\\par")
    end
  else
    if m.district_court_case then add("No. " .. tex(m.district_court_case) .. "\\par") end
    if m.judge then add(tex(m.judge) .. "\\par") end
  end
  add(GAP .. "\\briefrulesmall" .. GAP)
  add("{\\bfseries\\MakeUppercase{" .. tex(need(m, "brief_title")) .. "}\\par}")
  if TYPE == "opening" and m.appendix then add(tex(m.appendix) .. "\\par") end
  add(GAP .. "\\briefrulesmall" .. GAP)
  local groups = need(m, "counsel")
  if TYPE == "reply" and #groups > 1 then
    -- two to a row across the full width (typst grid: 1fr 1fr, 14 pt between the columns and the rows)
    for r = 1, #groups, 2 do
      local function col(gi)
        if not groups[gi] then return "\\begin{minipage}[t]{\\dimexpr(\\linewidth-14bp)/2\\relax}\\mbox{}\\end{minipage}" end
        return "\\begin{minipage}[t]{\\dimexpr(\\linewidth-14bp)/2\\relax}\\briefsingle\\raggedright\\parindent=0pt\\relax "
          .. counsel_lines(m, groups[gi], gi == #groups) .. "\\par\\end{minipage}"
      end
      if r > 1 then add("\\par\\addvspace{14bp}") end
      add("{\\briefnatural\\noindent" .. col(r) .. "\\hfill" .. col(r + 1) .. "\\par}")
    end
  else
    local blocks = {}
    for gi, g in ipairs(groups) do
      blocks[#blocks + 1] = "\\noindent " .. counsel_lines(m, g, gi == #groups) .. "\\par"
    end
    add("{\\leftskip=3.25in\\rightskip=0pt plus 1fil\\relax\\parskip=7bp\\relax " .. table.concat(blocks, "\n") .. "}")
  end
  add("\\par\\endgroup")
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

local TOA_GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

local function toc()
  return "\\briefhead{Table of Contents}\n\\briefTOCpage{\\underline{Page}}\n\\briefTOC"
end

local function toa(auths, cited)
  local out = { section_head("Table of Authorities", TYPE ~= "opening") }
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auths) do
      if plain(a.kind) == g[1] and cited[key] then table.insert(members, { key = key, a = a, sort = sort_key(a) }) end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      if first then
        table.insert(out, "\\toagroupfirst{" .. g[2] .. "}{\\underline{" .. gl("Page(s)") .. "}}")
      else
        table.insert(out, "\\toagroup{" .. g[2] .. "}")
      end
      first = false
      for _, mem in ipairs(members) do
        local cite = tex(mem.a.cite)
        if mem.a.name then
          local name = g[1] == "case" and ("\\emph{" .. tex(mem.a.name) .. "}") or tex(mem.a.name)
          table.insert(out, "\\toaitem{" .. mem.key .. "}{" .. name .. "}{" .. cite .. "}")
        else
          table.insert(out, "\\toaitemnoname{" .. mem.key .. "}{" .. cite .. "}")
        end
      end
    end
  end
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- Signature and certificates
-- ---------------------------------------------------------------------------

local SIGLINE = gl(TYPE == "answering" and "s/ " or "/s/ ")

-- The brief's signature block (typst signature-block): kept whole, and with the brief's last paragraph when `keep`.
local function signature(m, keep)
  local sig = need(m, "signature")
  local out = { (keep and "\\par\\nobreak\\addvspace{19.6bp}\\nobreak" or "\\par\\addvspace{19.6bp}") ..
    "\\begingroup\\briefsingle\\interlinepenalty=10000\\relax\\parindent=0pt\\relax" }
  local lines = { SIGLINE .. tex(sig.signer) }
  if TYPE ~= "opening" then lines[#lines + 1] = "\\MakeUppercase{" .. tex(sig.signer) .. "}" end
  for _, l in ipairs(sig.lines or {}) do
    lines[#lines + 1] = TYPE == "opening" and tex(l) or ("\\hspace*{0.5em}\\emph{" .. tex(l) .. "}")
  end
  out[#out + 1] = "{\\leftskip=3.25in\\relax Respectfully submitted,\\par\\nobreak\\vspace{16.8bp}\\nobreak"
  out[#out + 1] = table.concat(lines, "\\newline ") .. "\\par}"
  if m.date then out[#out + 1] = "\\nobreak\\vspace{11.2bp}\\nobreak " .. tex(m.date) .. "\\par" end
  out[#out + 1] = "\\endgroup"
  return table.concat(out, "\n")
end

-- The signature under a certificate: opening (typst certificate-signature) and answering (cert-signature) in the
-- right half; the reply (form-sig-line) two columns, the right one starting (text width + 14 pt) / 2 in.
local function cert_signature(m)
  local sig = need(m, "signature")
  if TYPE == "reply" then
    return "\\par\\nobreak\\addvspace{22.4bp}\\nobreak\\begingroup\\briefsingle\\noindent\\makebox[241bp][l]{/s/ " ..
      tex(sig.signer) .. "}" .. (m.date and tex(m.date) or "") .. "\\par\\nobreak" ..
      "\\noindent\\makebox[241bp][l]{Signature}Date\\par\\endgroup"
  end
  local lines = { SIGLINE .. tex(sig.signer) }
  if TYPE == "answering" then lines[#lines + 1] = tex(sig.signer) end
  for _, l in ipairs(sig.lines or {}) do
    lines[#lines + 1] = TYPE == "opening" and tex(l) or ("\\emph{" .. tex(l) .. "}")
  end
  local out = "\\par\\nobreak\\addvspace{" .. (TYPE == "opening" and "19.6" or "22.4") .. "bp}\\nobreak" ..
    "\\begingroup\\briefsingle\\interlinepenalty=10000\\relax\\parindent=0pt\\relax{\\leftskip=3.25in\\relax " ..
    table.concat(lines, "\\newline ") .. "\\par}"
  if TYPE == "opening" and m.date then out = out .. "\\nobreak\\vspace{11.2bp}\\nobreak " .. tex(m.date) .. "\\par" end
  return out .. "\\endgroup"
end

-- A certificate on its own page: its heading (in the contents of the answering and reply briefs), double-spaced
-- paragraphs with the first line indented, then the signature.
local function cert(m, title, paras)
  local out = { "\\clearpage", section_head(title, TYPE ~= "opening"), "\\begin{briefcert}" }
  for _, p in ipairs(paras) do out[#out + 1] = gl(p) .. "\\par" end
  out[#out + 1] = "\\end{briefcert}"
  out[#out + 1] = cert_signature(m)
  return table.concat(out, "\n")
end

-- A served person's line: half an inch in, no first-line indent, 9.8 bp above.
local function served(u)
  return "\\addvspace{9.8bp}{\\leftskip=0.5in\\relax\\noindent " .. tex(u.name) .. ", " .. tex(u.address) .. "\\par}"
end

local FRAP = "Fed.\\ R.\\ App.\\ P."

local function certificates(m, words)
  local out = {}
  local n = group_digits(words)
  if TYPE == "opening" then
    local using = m.prepared_with and (" using " .. tex(m.prepared_with)) or ""
    out[#out + 1] = cert(m, "Certificate of Compliance", {
      "This brief complies with the type-volume limitation of " .. FRAP .. " 32(a)(7)(B) because it contains " .. n ..
        " words, excluding the parts of the brief exempted by " .. FRAP .. " 32(f).",
      "This brief complies with the typeface requirements of " .. FRAP .. " 32(a)(5) and the type-style requirements of " ..
        FRAP .. " 32(a)(6) because it has been prepared in a proportionally spaced typeface" .. using ..
        " in font size 14, font style " .. FACE .. ".",
    })
    out[#out + 1] = cert(m, "Certification of Bar Membership", {
      "I certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court, or has filed an application for admission under 3d Cir. L.A.R. 46.1.",
    })
    local e = { "I certify that the text of the E-Brief and the text of the hard copies of this brief are identical." }
    if m.virus_software then
      e[#e + 1] = "I certify that a virus check was performed on the PDF file of this brief. The virus software used was " ..
        tex(m.virus_software) .. "."
    end
    out[#out + 1] = cert(m, "Certification of Text of E-Brief and Virus Check", e)
    local svc = m.service and m.service.certificate
    if svc == nil or svc == true or plain(svc) == "true" then
      out[#out + 1] = cert(m, "Certificate of Service", {
        "I, " .. tex(need(m, "signature").signer) .. ", counsel for the filer and a member of the bar of this Court, certify that, on " ..
          tex(need(m, "date")) .. ", the brief and all accompanying appendices were filed electronically through the appellate CM/ECF system with the Clerk of Court. I further certify that all parties required to be served have been served.",
      })
    end
  elseif TYPE == "answering" then
    out[#out + 1] = cert(m, "Certificate of Bar Membership", {
      "I hereby certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court.",
    })
    out[#out + 1] = cert(m, "Electronic-Filing Certification", {
      "I hereby certify that the text of the electronically filed brief is identical to the text in the paper copies. I also certify that a virus detection program has been run on the electronic file and that no virus was detected. The virus detection program used, and its version, is " ..
        string.rep("\\_", 20) .. ".",
    })
    out[#out + 1] = cert(m, "Certificate of Compliance", {
      "1. This brief complies with the type-volume limitation of " .. FRAP .. " 32(a)(7)(B) because it contains " .. n ..
        " words, excluding the parts of the brief exempted by " .. FRAP .. " 32(f). The count includes " ..
        plain(m.manual_image_words or "0") .. " words counted by hand in any visual images.",
      "2. This brief complies with the typeface requirements of " .. FRAP .. " 32(a)(5) and the type-style requirements of " ..
        FRAP .. " 32(a)(6) because it has been prepared in a proportionally spaced typeface, 14-point " .. FACE .. ".",
    })
    if m.service then
      local svc = m.service
      local p = "I certify that on " .. tex(svc.date) .. " I caused the foregoing " .. tex(need(m, "brief_title")) ..
        " to be served by " .. tex(svc.method) .. " on the following:"
      for _, u in ipairs(svc.to or {}) do p = p .. "\\par\n" .. served(u) end
      out[#out + 1] = cert(m, "Certificate of Service", { p })
    end
  else
    out[#out + 1] = cert(m, "Certificate of Compliance", {
      "The undersigned counsel certifies pursuant to L.A.R. 46.1(e) that counsel is a member in good standing of the bar of this Court.",
      "This brief complies with the type-volume limitation of FRAP 32(a)(7)(B)(ii) because it contains " .. n ..
        " words, including headings, footnotes, and quotations, and excluding the items exempted by FRAP 32(f). It is prepared in " ..
        tex(m.typeface or "14-point, proportionally spaced serif type") ..
        " and complies with the typeface and type-style requirements of FRAP 32(a)(5) and (6).",
      "The text of the electronic document is identical to the paper copies. Pursuant to L.A.R. 31.1(c), this electronic document was scanned for viruses using " ..
        tex(need(m, "virus_scanner")) .. " prior to filing and found to be virus free.",
    })
    local svc = m.service and m.service.certificate
    if svc == true or (svc ~= nil and plain(svc) == "true") then
      local paras = { "I hereby certify that the foregoing brief was electronically filed on this date with the Clerk of the Court for the United States Court of Appeals for the Third Circuit by using the appellate CM/ECF system. Participants in the case who are registered CM/ECF users will be served by the appellate CM/ECF system." }
      local unreg = m.service.unregistered or {}
      if #unreg > 0 then
        paras[#paras + 1] = "\\textbf{Service on Case Participants Who Are NOT Registered for Electronic Filing:}"
        local p = "I certify that I served the foregoing document on this date by hand delivery, mail, third party commercial carrier for delivery within 3 calendar days, or, having obtained prior consent, by email to the following unregistered case participants (list each name and mailing/email address):"
        for _, u in ipairs(unreg) do p = p .. "\\par\n" .. served(u) end
        paras[#paras + 1] = p
      end
      out[#out + 1] = cert(m, "Certificate of Service", paras)
    end
  end
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local auths = m.authorities or {}
  local required = { "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature" }
  if TYPE == "opening" then required[#required + 1] = "related_cases" end
  if TYPE == "reply" then required[#required + 1] = "virus_scanner" end
  for _, k in ipairs(required) do need(m, k) end

  local src = source_body()
  local words = count_md(src)
  if TYPE == "opening" then words = words + count_md(plain(m.related_cases)) end
  if words > LIMIT then
    error("ca3-" .. TYPE .. ": the brief has " .. words .. " words; the limit is " .. LIMIT)
  end

  -- citations: a link to toa:<key> marks its page; then the cross-engine inline rules over the body text
  local cited = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if key == nil then return el.content end
      if auths[key] == nil then error("ca3-" .. TYPE .. ": link `toa:" .. key .. "` has no entry under `authorities:`") end
      cited[key] = true
      local out = pandoc.Inlines({ pandoc.RawInline("latex", "\\toamark{" .. key .. "}") })
      out:extend(el.content)
      return out
    end,
  })
  doc = doc:walk({ Inlines = inlines })
  doc = doc:walk({ OrderedList = ordered_list })

  -- the body: headings become the template's heading macros; the opening brief's related-cases statement goes before
  -- the Statement of the Case (L.A.R. 28.1(a)(2))
  local counts = { 0, 0, 0, 0, 0 }
  local state = { in_arg = false }
  local blocks = {}
  local placed = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower() == "addendum" then
      error("ca3-" .. TYPE .. ": an addendum is set by the typst engine only (see ../README.md)")
    end
    if b.t == "Header" then
      if TYPE == "opening" and b.level == 1 and plain(b.content):lower() == "statement of the case" then
        blocks[#blocks + 1] = raw(section_head("Statement of Related Cases", true))
        blocks[#blocks + 1] = pandoc.Para(inlines(pandoc.Inlines(m.related_cases)))
        placed = true
      end
      blocks[#blocks + 1] = heading(b, counts, state)
    else
      blocks[#blocks + 1] = b
    end
  end
  if TYPE == "opening" and not placed then
    error("ca3-" .. TYPE .. ": the body needs a `# Statement of the Case` heading")
  end

  local out = {}
  local function add(b) table.insert(out, b) end
  add(raw(cover(m)))
  add(raw("\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}"))
  if m.disclosure then
    -- single spaced, 14 bp between paragraphs, no indent (typst disclosure-section)
    add(raw("\\briefhead{Corporate Disclosure Statement}\\begingroup\\briefsingle\\parindent=0pt\\relax\\parskip=14bp\\relax"))
    local d = m.disclosure
    local dblocks = pandoc.utils.type(d) == "Blocks" and d or { pandoc.Para(pandoc.Inlines(d)) }
    for _, p in ipairs(dblocks) do
      if p.t == "Para" then add(pandoc.Para(inlines(p.content))) else add(p) end
    end
    add(raw("\\par\\endgroup\\clearpage"))
  end
  add(raw(toc()))
  add(raw("\\clearpage"))
  add(raw(toa(auths, cited)))
  add(raw("\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}\\normalsize"))
  local n = #blocks
  local keep = keep_last(src) and n > 0 and blocks[n].t == "Para"
  for i = 1, n do
    local b = blocks[i]
    local noted = false
    if b.t == "Para" then pandoc.Pandoc({ b }):walk({ Note = function() noted = true end }) end
    if noted and not (i == n and keep) then
      -- typst moves the line that holds a footnote reference to the next page with its note, even when that leaves
      -- it a widow; a paragraph with a footnote has no widow penalty here (the page builder then takes the later of
      -- two equally good breaks, as typst does)
      add(raw("\\begingroup\\widowpenalty=0\\relax"))
      add(b)
      add(raw("\\par\\endgroup"))
    elseif i == n and keep then
      add(raw("\\begingroup\\interlinepenalty=10000\\relax"))
      add(blocks[i])
      add(raw("\\par\\endgroup"))
    else
      add(blocks[i])
    end
  end
  add(raw(signature(m, keep)))
  add(raw(certificates(m, words)))
  return pandoc.Pandoc(out, doc.meta)
end

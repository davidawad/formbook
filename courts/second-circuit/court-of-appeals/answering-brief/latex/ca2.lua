-- Second Circuit brief, LaTeX engine: the parts of the typst template (typst/ca2-<doc>.typ) that pandoc
-- cannot write itself. Read by tools/render-latex.sh as a pandoc filter, next to template.tex.
--
-- Builds from the frontmatter: the cover, the corporate disclosure page (if any), the table of
-- contents and the table of authorities (both two-pass, see template.tex), the signature block and
-- the certificates. Headings get their labels here (I., A., 1., a. in the Argument; A., 1., a., (1)
-- elsewhere) and become \briefhead / \briefpoint / \briefsub commands. Each citation of an authority
-- (a link to toa:<key>) gets a page mark.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the inline rules of lib/latex/xengine.lua run over
-- the body and over every metadata value; every space between blocks is an \addvspace in bp, as typst spaces them.
--
-- DOC selects the wording and layout of the doc type's own template: "opening", "answering" or "reply".
local DOC = "answering"
local WORD_LIMIT = ({ opening = 14000, answering = 14000, reply = 7000 })[DOC]   -- Local Rule 32.1(a)(4)

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

local function inlines(l)
  return xe.inlines(ellipsis(l))
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

local function plain(x)
  if x == nil then return "" end
  if type(x) == "string" then return x end
  return stringify(x)
end

local function need(m, key)
  if m[key] == nil then error("ca2.lua: missing required metadata field `" .. key .. "`") end
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

-- Sort key as typst's: case-insensitive, digit runs compared by value.
local function sort_key(a)
  local k = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  k = k:lower():gsub("%d+", function(d) return string.rep("0", math.max(0, 10 - #d)) .. d end)
  return (k:gsub("[^a-z0-9 ]", ""))
end

-- 11622 -> "11,622"
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
  if not f then error("ca2.lua: cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
  local a = src:find("\n#[ \t]+[Aa][Dd][Dd][Ee][Nn][Dd][Uu][Mm][ \t]*\r?\n")
  if a then src = src:sub(1, a) end
  return src
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block of
-- the text (opening: footnote definitions taken out first; answering and reply: the text before the definitions) is
-- not a heading and (answering, reply) holds no footnote.
local function keep_last(src)
  local text = src
  if DOC == "opening" then text = ("\n" .. text):gsub("\n%[%^[^%]]+%]:[^\n]*", "\n") end
  text = text:gsub("%s+$", "")
  if DOC ~= "opening" then
    local d = text:find("\n\n%[%^[^%]]+%]:")
    if d then text = text:sub(1, d - 1) end
  end
  local cut = 1
  for e in text:gmatch("\n[ \t]*\n()") do cut = e end
  local tail = text:sub(cut)
  if tail == "" or tail:sub(1, 1) == "#" then return false end
  if DOC ~= "opening" and tail:find("[^", 1, true) then return false end
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
  error("ca2.lua: headings deeper than level 5 are not supported")
end

-- The label's indent in half inches (typst label-indent): opening and answering center the Argument's point headings,
-- so their sub-headings start at the first step; the reply sets its point headings at the margin.
local function label_steps(level, in_argument)
  if DOC == "reply" then return level - 2 end
  local first = in_argument and 3 or 2
  return level - first + 1
end

local function inches(steps) return (steps * 0.5) .. "in" end

local function heading(h, counts, state)
  local lvl = h.level
  if lvl > 5 then error("ca2.lua: headings deeper than level 5 are not supported") end
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
    if DOC ~= "reply" and state.in_argument and lvl == 2 then ind = 0 end
    toc = string.format("\\addcontentsline{toc}{briefn}{{%s}{%s}{%s}}", inches(ind), label, title)
  end
  if state.in_argument and lvl == 2 and DOC ~= "reply" then
    return raw(string.format("\\briefpoint{%s}{%s}%s", label, title, toc))
  end
  local style = lvl >= 4 and "\\bfseries\\itshape" or "\\bfseries"
  local text = title
  if DOC == "reply" and state.in_argument and lvl == 2 then text = "\\MakeUppercase{" .. title .. "}" end
  return raw(string.format("\\briefsub{%s}{%s}{%s}{%s}%s",
    inches(label_steps(lvl, state.in_argument)), label, style, text, toc))
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

-- One counsel group (typst cover-body / counsel-group): names, then the lines half an em in, italic.
local function counsel_lines(g, phone, phone_italic)
  local out = {}
  for _, n in ipairs(g.names) do out[#out + 1] = tex(n) end
  for _, l in ipairs(g.lines or {}) do out[#out + 1] = "\\hspace*{0.5em}\\emph{" .. tex(l) .. "}" end
  if phone then
    out[#out + 1] = "\\hspace*{0.5em}" .. (phone_italic and ("\\emph{" .. tex(phone) .. "}") or tex(phone))
  end
  return table.concat(out, "\\newline ")
end

-- The cover's line boxes: single spacing; the reply's are set closer (typst pitch-cover, 17 pt), or its four counsel
-- groups would push the cover onto a second page.
local COVER = DOC == "reply" and "\\briefpitch{17}" or "\\briefsingle"

local function cover(m)
  local out = {}
  local function add(s) out[#out + 1] = s end
  local gap = "\\briefgap{14}"
  local gap3 = "\\briefgap{4.2}"
  add("\\thispagestyle{empty}\\begingroup" .. COVER .. "\\centering\\parskip=4.9bp\\relax")
  -- Local Rule 32.1(a)(1): docket number "in type at least one inch high" (72 pt = 1 in).
  local weight = DOC == "reply" and "" or "\\bfseries"
  add("{\\briefdocketsize" .. weight .. " " .. tex(need(m, "case_number")) .. "\\par}")
  add(gap)
  if DOC == "opening" then
    add("\\briefdouble" .. gap)
    add("{\\bfseries IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE SECOND CIRCUIT\\par}")
  elseif DOC == "answering" then
    add("{\\bfseries IN THE\\\\United States Court of Appeals for the Second Circuit\\par}")
  else
    add("In the United States Court of Appeals for the Second Circuit\\par")
  end
  add(gap)
  if DOC ~= "reply" then add("\\briefrulesmall" .. gap) end
  local sides = need(m, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. "\\par") end
    if DOC == "opening" then
      add("{\\leftskip=0.5\\linewidth\\rightskip=0pt plus 1fil\\relax\\noindent " .. tex(side.designation) .. "\\par}")
    elseif DOC == "answering" then
      add(tex(side.designation) .. "\\par")
    else
      add("{\\leftskip=0pt plus 1fil\\rightskip=0pt\\relax\\noindent " .. tex(side.designation) .. "\\par}")
    end
    if i < #sides then
      local sep = ({ opening = "-v-", answering = "\\textendash{} v. \\textendash{}", reply = "v." })[DOC]
      add(gap3 .. sep .. "\\par" .. gap3)
    end
  end
  add(gap)
  if DOC ~= "reply" then add("\\briefrulesmall" .. gap) end
  if DOC == "reply" then
    local proc = "\\MakeUppercase{" .. tex(need(m, "proceeding")) .. "}"
    if m.district_court_case or m.judge then
      local parts = {}
      if m.district_court_case then parts[#parts + 1] = "No. " .. tex(m.district_court_case) end
      if m.judge then parts[#parts + 1] = tex(m.judge) end
      proc = proc .. "\\\\\\MakeUppercase{" .. table.concat(parts, ", ") .. "}"
    end
    add(proc .. "\\par")
  else
    add(tex(need(m, "proceeding")) .. "\\par")
    if DOC == "opening" and (m.district_court_case or m.judge) then
      local dc = ""
      if m.district_court_case then dc = "D.C. No. " .. tex(m.district_court_case) end
      if m.district_court_case and m.judge then dc = dc .. "; " end
      if m.judge then dc = dc .. tex(m.judge) end
      add(dc .. "\\par")
    elseif DOC == "answering" and m.district_court_case then
      add("Case No. " .. tex(m.district_court_case) .. (m.judge and (" (" .. tex(m.judge) .. ")") or "") .. "\\par")
    end
  end
  add(gap)
  if DOC ~= "reply" then add("\\briefrulesmall" .. gap) end
  add("{\\bfseries\\MakeUppercase{" .. tex(need(m, "brief_title")) .. "}\\par}")
  add(gap)
  if DOC ~= "reply" then add("\\briefrulesmall" .. gap) end
  local groups = need(m, "counsel")
  if DOC == "reply" then
    -- two columns of counsel (typst grid: 1fr 1fr, a half-inch gutter): the first half of the groups stacked on the
    -- left, the rest on the right, 15.4 bp between groups
    local half = math.ceil(#groups / 2)
    local function column(first, last)
      local parts = {}
      for gi = first, last do
        parts[#parts + 1] = "\\noindent " .. counsel_lines(groups[gi], groups[gi].phone, false) .. "\\par"
      end
      return "\\begin{minipage}[t]{\\dimexpr(\\linewidth-0.5in)/2\\relax}" .. COVER .. "\\raggedright\\parindent=0pt" ..
        "\\parskip=15.4bp\\relax " .. table.concat(parts, "\n") .. "\\end{minipage}"
    end
    add("{\\briefnatural\\noindent" .. column(1, half) .. "\\hfill" .. column(half + 1, #groups) .. "\\par}")
    if m.counsel_for then add(gap .. "\\emph{" .. tex(m.counsel_for) .. "}\\par") end
  else
    local left = DOC == "opening" and "0.5\\linewidth" or "0.35\\linewidth"
    local blocks = {}
    for gi, g in ipairs(groups) do
      local phone = gi == #groups and m.phone or nil
      blocks[#blocks + 1] = "\\noindent " .. counsel_lines(g, phone, true) .. "\\par"
    end
    add("{\\leftskip=" .. left .. "\\rightskip=0pt plus 1fil\\relax\\parskip=7bp\\relax " .. table.concat(blocks, "\n") .. "}")
  end
  if DOC == "opening" then add(gap .. "\\briefdouble") end
  add("\\par\\endgroup")
  return table.concat(out, "\n")
end

local function disclosure(m)
  return "\\briefhead{Corporate Disclosure Statement}\n" .. tex(m.disclosure) .. "\n\\clearpage"
end

-- Table of contents: the entries come from the .toc file (addcontentsline, see the headings above).
local function toc()
  local page = DOC == "reply" and "Page" or "\\underline{Page}"
  return "\\briefhead{Table of Contents}\n\\briefTOCpage{" .. page .. "}\n\\briefTOC"
end

-- Table of authorities: groups of the authorities cited in the body, in typst's order.
local TOA_GROUPS = {
  { { "case" }, "Cases:" },
  { { "constitution" }, "Constitutional Provisions:" },
  { { "statute" }, "Statutes:" },
  { { "regulation" }, "Regulations:" },
  { { "rule" }, "Rules:" },
  { { "other" }, "Other Authorities:" },
}
if DOC == "reply" then
  TOA_GROUPS = {
    { { "case" }, "Cases:" },
    { { "constitution" }, "Constitutional Provisions:" },
    { { "statute" }, "Statutes:" },
    { { "regulation", "rule" }, "Rules & Regulations:" },
    { { "other" }, "Other Authorities:" },
  }
end

local function toa(auths, cited)
  local out = { "\\briefhead{Table of Authorities}" }
  if DOC ~= "reply" then out[#out + 1] = "\\addcontentsline{toc}{brieftoc}{TABLE OF AUTHORITIES}" end
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auths) do
      local kind = plain(a.kind)
      local hit = false
      for _, k in ipairs(g[1]) do if k == kind then hit = true end end
      if hit and cited[key] then table.insert(members, { key = key, a = a, sort = sort_key(a) }) end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      local title = g[2]:gsub("&", "\\&")
      if first then
        local head = DOC == "reply" and "Page(s)" or "\\underline{Page(s)}"
        table.insert(out, "\\toagroupfirst{" .. title .. "}{" .. head .. "}")
      else
        table.insert(out, "\\toagroup{" .. title .. "}")
      end
      first = false
      for _, mem in ipairs(members) do
        local cite = tex(mem.a.cite)
        if mem.a.name then
          local name = (plain(mem.a.kind) == "case") and ("\\emph{" .. tex(mem.a.name) .. "}") or tex(mem.a.name)
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
  local out = { (keep and "\\par\\nobreak\\addvspace{19.6bp}\\nobreak" or "\\par\\addvspace{19.6bp}") ..
    "\\begingroup\\briefsingle\\interlinepenalty=10000\\relax\\parindent=0pt\\relax" }
  local function add(s) out[#out + 1] = s end
  if DOC == "answering" then
    local x = {}
    if m.date then x[#x + 1] = "Dated: " .. tex(m.date) end
    if m.city then x[#x + 1] = tex(m.city) end
    if #x > 0 then add(table.concat(x, "\\newline ") .. "\\par\\nobreak\\vspace{16.8bp}\\nobreak") end
  elseif DOC == "reply" then
    add("Dated: " .. tex(need(m, "date")) .. "\\par\\nobreak\\vspace{16.8bp}\\nobreak")
  end
  local left = DOC == "answering" and "0.35\\linewidth" or "0.5\\linewidth"
  add("{\\leftskip=" .. left .. "\\relax Respectfully submitted,\\par\\nobreak\\vspace{16.8bp}\\nobreak")
  local sigline = DOC == "opening" and "s/ " or "/s/ "
  local name = DOC == "answering" and tex(sig.signer) or ("\\MakeUppercase{" .. tex(sig.signer) .. "}")
  local lines = { sigline .. tex(sig.signer), name }
  for _, l in ipairs(sig.lines or {}) do
    lines[#lines + 1] = (DOC == "reply" and "" or "\\hspace*{0.5em}") .. "\\emph{" .. tex(l) .. "}"
  end
  add(table.concat(lines, "\\newline ") .. "\\par")
  if DOC == "reply" and m.counsel_for then add("\\nobreak\\vspace{8.4bp}\\nobreak\\emph{" .. tex(m.counsel_for) .. "}\\par") end
  add("}")
  if DOC == "opening" and m.date then add("\\nobreak\\vspace{11.2bp}\\nobreak " .. tex(m.date) .. "\\par") end
  add("\\endgroup")
  return table.concat(out, "\n")
end

-- A certificate's signature and date line (typst form-sig-line); the reply's "Dated:" and signer block.
local function sig_foot(m, signer, date)
  if DOC == "reply" then
    return "\\par\\nobreak\\addvspace{22.4bp}\\nobreak\\begingroup\\briefsingle\\noindent Dated: " .. tex(need(m, "date")) ..
      "\\par\\nobreak\\vspace{16.8bp}\\nobreak\\noindent /s/ " .. tex(signer) .. "\\newline " .. tex(signer) .. "\\par\\endgroup"
  end
  local s = (DOC == "opening" and "s/ " or "/s/ ") .. tex(signer)
  return "\\briefsigfoot{" .. s .. "}{" .. (date and tex(date) or "") .. "}"
end

local TYPEFACE = "Times New Roman"   -- the typst template's font (newtx here is its metric twin)

local function certificate_of_compliance(m, words)
  local n = group_digits(words)
  local body
  if DOC == "opening" then
    body = "1. This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) and Local Rule 32.1(a) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f): this document contains " .. n .. " words.\\par\n" ..
      "2. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because: this document has been prepared in a proportionally spaced typeface using " .. TYPEFACE .. " in 14-point type.\\par\n"
  elseif DOC == "answering" then
    local using = m.software and (tex(m.software) .. " in 14-point " .. (m.typeface and tex(m.typeface) or TYPEFACE))
      or ("14-point " .. (m.typeface and tex(m.typeface) or TYPEFACE))
    body = "This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) and Local Rule 32.1(a)(4)(A) because this brief contains " .. n .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f).\\par\n" ..
      "This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because this brief has been prepared in a proportionally spaced typeface using " .. using .. ".\\par\n"
  else
    body = "This brief complies with the type-volume limitation set forth in Local Rule 32.1(a)(4)(B) because it contains " .. n .. " words, excluding the parts of the brief exempted by Federal Rule of Appellate Procedure 32(f).\\par\n" ..
      "This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and the type-style requirements of Federal Rule of Appellate Procedure 32(a)(6) because it was prepared in a proportionally spaced typeface using " .. tex(need(m, "typeface_software")) .. " in " .. tex(need(m, "typeface")) .. " 14-point font.\\par\n"
  end
  body = body:gsub("Fed%. R%. App%. P%.", "Fed.\\ R.\\ App.\\ P."):gsub("\\par\n(.)", "\\par\\addvspace{14bp}\n%1")
  local head = "\\briefhead{Certificate of Compliance}"
  if DOC == "answering" then head = head .. "\\addcontentsline{toc}{brieftoc}{CERTIFICATE OF COMPLIANCE}" end
  return "\\clearpage\n" .. head .. "\n\\begin{briefcert}" .. body .. "\\end{briefcert}\n" ..
    sig_foot(m, need(m, "signature").signer, m.date)
end

local function certificate_of_service(m)
  local svc = need(m, "service")
  local head = "\\briefhead{Certificate of Service}"
  if DOC == "answering" then head = head .. "\\addcontentsline{toc}{brieftoc}{CERTIFICATE OF SERVICE}" end
  local out = { "\\clearpage\n" .. head .. "\n\\begin{briefcert}" }
  if DOC == "opening" then
    table.insert(out, "I certify that on " .. tex(svc.date) .. ", I served one copy of the foregoing " .. tex(m.brief_title) ..
      " on the following counsel of record, by the method stated:\\par")
    for _, p in ipairs(svc.parties) do
      table.insert(out, "\\addvspace{9.8bp}{\\leftskip=0.5in\\relax\\interlinepenalty=10000\\relax " .. tex(p.name) ..
        "\\newline " .. tex(p.address) .. "\\newline\\emph{" .. tex(p.method) .. "}\\par}")
    end
    table.insert(out, "\\end{briefcert}")
    table.insert(out, sig_foot(m, svc.signer or need(m, "signature").signer, svc.date))
  elseif DOC == "answering" then
    table.insert(out, "I hereby certify that on " .. tex(need(m, "date")) .. ", a true and correct copy of the foregoing was served via " ..
      tex(svc.method or "ACMS") .. " to all counsel of record or parties pro se.\\par")
    local unreg = svc.unregistered or {}
    if #unreg > 0 then
      table.insert(out, "\\addvspace{14bp}The following case participants are NOT registered for electronic filing and were served by mail or another method (name and address):\\par")
      for _, u in ipairs(unreg) do
        table.insert(out, "\\addvspace{9.8bp}{\\leftskip=0.5in\\relax " .. tex(u.name) .. ", " .. tex(u.address) .. "\\par}")
      end
    end
    table.insert(out, "\\end{briefcert}")
    table.insert(out, sig_foot(m, need(m, "signature").signer, m.date))
  else
    table.insert(out, "I hereby certify that, on " .. tex(need(m, "date")) .. ", I electronically filed the foregoing " .. tex(m.brief_title) ..
      " with the United States Court of Appeals for the Second Circuit using the Court\u{2019}s electronic filing system, which will serve copies on all registered counsel.\\par")
    table.insert(out, "\\end{briefcert}")
    table.insert(out, sig_foot(m, need(m, "signature").signer, nil))
  end
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local auths = m.authorities or {}
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "signature" }) do
    need(m, k)
  end

  local words = count_md(source_body())
  if words > WORD_LIMIT then
    error("ca2.lua: the brief has " .. words .. " words; Local Rule 32.1(a)(4) allows " .. WORD_LIMIT)
  end

  -- citations: a link to toa:<key> marks its page; then the cross-engine inline rules over the body text
  local cited = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if key == nil then return el.content end
      if auths[key] == nil then error("ca2.lua: link `toa:" .. key .. "` has no entry under `authorities:`") end
      cited[key] = true
      local out = pandoc.Inlines({ pandoc.RawInline("latex", "\\toamark{" .. key .. "}") })
      out:extend(el.content)
      return out
    end,
  })
  doc = doc:walk({ Inlines = inlines })
  doc = doc:walk({ OrderedList = ordered_list })

  -- headings
  local counts = { 0, 0, 0, 0, 0 }
  local state = { in_argument = false }
  local blocks = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then blocks[#blocks + 1] = heading(b, counts, state) else blocks[#blocks + 1] = b end
  end

  local out = {}
  local function add(b) table.insert(out, b) end

  -- front matter: the cover (no number), then lower-case roman numbering
  add(raw(cover(m)))
  add(raw("\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}"))
  if m.disclosure then add(raw(disclosure(m))) end
  add(raw(toc()))
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
  add(raw(certificate_of_compliance(m, words)))
  local svc = m.service and m.service.certificate
  if DOC == "opening" or svc == true or (svc ~= nil and plain(svc) == "true") then add(raw(certificate_of_service(m))) end

  return pandoc.Pandoc(out, doc.meta)
end

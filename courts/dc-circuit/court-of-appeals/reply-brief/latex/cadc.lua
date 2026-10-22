-- D.C. Circuit reply brief, LaTeX engine: the parts of the typst template (typst/cadc-reply-brief.typ) that pandoc
-- cannot write itself. Read by fb render as a pandoc filter, next to template.tex.
--
-- Builds from the frontmatter: the cover, the table of contents and the table of authorities (both two-pass, see
-- template.tex), the signature block and the certificates. Headings get their labels here (I., A., 1., a. in the
-- Argument; A., 1., a., (1) elsewhere) and become \briefhead / \briefsub commands. Each citation of an authority (a
-- link to toa:<key>) gets a page mark. The word count is the typst template's count of the markdown source; the build
-- stops over the reply limit, FRAP 28.1(e)(2)(C).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the inline rules of lib/latex/xengine.lua run over
-- the body and over every metadata value; every space between blocks is an \addvspace in bp, as typst spaces them.
local WORD_LIMIT = 6500   -- FRAP 28.1(e)(2)(C): reply = half of 13,000 (Cir. R. 32(e)(1))
local TYPEFACE = "Times New Roman"   -- the typst template's font (newtx here is its metric twin)

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

-- typst's sort-key: the sort field, else name and citation; lower case, letters, digits and spaces only.
local function sort_key(a)
  local k = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  return (k:lower():gsub("[^a-z0-9 ]", ""))
end

-- 2175 -> "2,175"
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

-- The markdown body of the input file (the frontmatter dropped).
local function source_body()
  local f = PANDOC_STATE.input_files[1] and io.open(PANDOC_STATE.input_files[1], "r")
  if not f then error("cadc.lua: cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
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

-- The label's indent (typst label-indent): level 2 at the margin, each deeper level half an inch further in.
local function inches(level) return ((level - 2) * 0.5) .. "in" end

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
    toc = string.format("\\addcontentsline{toc}{briefn}{{%s}{%s}{%s}}", inches(lvl), label, title)
  end
  local style = lvl >= 4 and "\\bfseries\\itshape" or "\\bfseries"
  return raw(string.format("\\briefsub{%s}{%s}{%s}{%s}%s", inches(lvl), label, style, title, toc))
end

-- ---------------------------------------------------------------------------
-- Cover, tables, signature and certificates
-- ---------------------------------------------------------------------------

-- The cover (typst cover-body): centered, single-spaced, 4.9 bp between paragraphs and a gap between parts: 14 bp,
-- and around a rule the space typst's rule blocks take (16 bp each side of a short rule, 17.9 bp of the double rule).
local function cover(m)
  local out = {}
  local function add(s) out[#out + 1] = s end
  local gap = "\\briefgap{16}"
  local gap2 = "\\briefgap{17.9}"
  add("\\thispagestyle{empty}\\begingroup\\briefsingle\\centering\\parskip=4.9bp\\relax")
  -- Circuit Rule 28(a)(8): the oral-argument statement, in capitals, at the top of the front cover.
  if m.oral_argument then add("{\\bfseries\\MakeUppercase{" .. tex(m.oral_argument) .. "}\\par}\\briefgap{8.4}") end
  add("{\\bfseries No. " .. tex(need(m, "case_number")) .. "\\par}")
  add(gap2 .. "\\briefdouble" .. gap2)
  add("{\\bfseries IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE DISTRICT OF COLUMBIA CIRCUIT\\par}")
  add(gap .. "\\briefrulesmall" .. gap)
  local sides = need(m, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. "\\par") end
    add("{\\leftskip=3.25in\\rightskip=0pt plus 1fil\\relax\\noindent " .. tex(side.designation) .. "\\par}")
    if i < #sides then add("\\briefgap{4.2}v.\\par\\briefgap{4.2}") end
  end
  add(gap .. "\\briefrulesmall" .. gap)
  add(tex(need(m, "proceeding")) .. "\\par")
  if m.district_court_case or m.judge then
    local dc = ""
    if m.district_court_case then dc = "D.C. No. " .. tex(m.district_court_case) end
    if m.district_court_case and m.judge then dc = dc .. "; " end
    if m.judge then dc = dc .. tex(m.judge) end
    add(dc .. "\\par")
  end
  add(gap .. "\\briefrulesmall" .. gap)
  add("{\\bfseries\\MakeUppercase{" .. tex(need(m, "brief_title")) .. "}\\par}")
  add(gap .. "\\briefrulesmall" .. gap)
  -- Counsel (FRAP 32(a)(2)): name, office address, telephone number, from the middle of the text width; the
  -- telephone number is the last line of the last group.
  local groups = need(m, "counsel")
  local blocks = {}
  for gi, g in ipairs(groups) do
    local ls = {}
    for _, n in ipairs(g.names) do ls[#ls + 1] = tex(n) end
    local more = {}
    for _, l in ipairs(g.lines or {}) do more[#more + 1] = l end
    if gi == #groups then more[#more + 1] = need(m, "phone") end
    for _, l in ipairs(more) do ls[#ls + 1] = "\\hspace*{0.5em}\\emph{" .. tex(l) .. "}" end
    blocks[#blocks + 1] = "\\noindent " .. table.concat(ls, "\\newline ") .. "\\par"
  end
  add("{\\leftskip=3.25in\\rightskip=0pt plus 1fil\\relax\\parskip=7bp\\relax\\interlinepenalty=10000\\relax " ..
    table.concat(blocks, "\n") .. "}")
  add(gap2 .. "\\briefdouble")
  add("\\par\\endgroup")
  return table.concat(out, "\n")
end

-- Table of contents: the entries come from the .toc file (addcontentsline, see the headings above).
local function toc()
  return "\\briefhead{Table of Contents}\n\\briefTOCpage{\\underline{Page}}\n\\briefTOC"
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
      if plain(a.kind) == g[1] and cited[key] then table.insert(members, { key = key, a = a, sort = sort_key(a) }) end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      if first then
        table.insert(out, "\\toagroupfirst{" .. g[2] .. "}{\\underline{Page(s)}}")
      else
        table.insert(out, "\\toagroup{" .. g[2] .. "}")
      end
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
  local out = { (keep and "\\par\\nobreak\\addvspace{19.6bp}\\nobreak" or "\\par\\addvspace{19.6bp}") ..
    "\\begingroup\\briefsingle\\interlinepenalty=10000\\relax\\parindent=0pt\\relax" }
  local function add(s) out[#out + 1] = s end
  add("{\\leftskip=3.25in\\relax Respectfully submitted,\\par\\nobreak\\vspace{16.8bp}\\nobreak")
  local lines = { "/s/ " .. tex(sig.signer), tex(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = "\\hspace*{0.5em}\\emph{" .. tex(l) .. "}" end
  add(table.concat(lines, "\\newline ") .. "\\par}")
  if m.date then add("\\nobreak\\vspace{11.2bp}\\nobreak " .. tex(m.date) .. "\\par") end
  add("\\endgroup")
  return table.concat(out, "\n")
end

local function sig_foot(m)
  return "\\briefsigfoot{/s/ " .. tex(need(m, "signature").signer) .. "}{" .. (m.date and tex(m.date) or "") .. "}"
end

-- Certificate of Compliance (FRAP 32(g)(1); FRAP 28.1(e)(2)(C); Cir. R. 32(e)(1)).
local function certificate_of_compliance(m, words)
  local images = m.manual_image_words and tex(m.manual_image_words) or "0"
  return "\\clearpage\n\\briefhead{Certificate of Compliance}\n\\begin{briefcert}" ..
    "I hereby certify that this brief complies with the type-volume limitation of Fed. R. App. P. 28.1(e)(2)(C) and Circuit Rule 32(e)(1). Excluding the parts of the document exempted by Fed. R. App. P. 32(f), this brief contains " ..
    group_digits(words) .. " words, including " .. images .. " words manually counted in any visual images.\\par\\addvspace{14bp}\n" ..
    "This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6): it is prepared in a proportionally spaced serif typeface (" ..
    TYPEFACE .. "), 14-point.\\par\n\\end{briefcert}\n" .. sig_foot(m)
end

-- Certificate of Service (FRAP 25(d)): only when service.certificate is true.
local function certificate_of_service(m)
  local svc = need(m, "service")
  local out = { "\\clearpage\n\\briefhead{Certificate of Service}\n\\begin{briefcert}" }
  table.insert(out, "I hereby certify that on this date I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the District of Columbia Circuit using the appellate CM/ECF system, which will send notice of the filing to all counsel of record.\\par")
  local unreg = svc.unregistered or {}
  if #unreg > 0 then
    table.insert(out, "\\addvspace{14bp}\\textbf{Service on Participants Who Are NOT Registered for Electronic Filing:}\\par")
    table.insert(out, "\\addvspace{14bp}I certify that I served the foregoing on this date by hand delivery, mail, or third-party commercial carrier for delivery within 3 calendar days to the following unregistered participants (list each name and mailing address):\\par")
    for _, u in ipairs(unreg) do
      table.insert(out, "\\addvspace{9.8bp}{\\leftskip=0.5in\\relax\\interlinepenalty=10000\\relax " .. tex(u.name) .. ", " ..
        tex(u.address) .. "\\par}")
    end
  end
  table.insert(out, "\\end{briefcert}")
  table.insert(out, sig_foot(m))
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local auths = m.authorities or {}
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature" }) do
    need(m, k)
  end

  local words = count_md(source_body())
  if words > WORD_LIMIT then
    error("cadc.lua: the brief has " .. words .. " words; FRAP 28.1(e)(2)(C) allows " .. WORD_LIMIT .. " for a reply brief")
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
  doc = doc:walk({ Inlines = inlines })
  -- quotations: 12.6 bp between two of their paragraphs, none next to a list (typst: the quotation's paragraph
  -- spacing; a list item's block spacing is zero)
  doc = doc:walk({
    BlockQuote = function(q)
      local out = {}
      for i, b in ipairs(q.content) do
        local prev = q.content[i - 1]
        local function list(x) return x.t == "BulletList" or x.t == "OrderedList" end
        if prev and not list(prev) and not list(b) then out[#out + 1] = raw("\\par\\addvspace{12.6bp}") end
        out[#out + 1] = b
      end
      q.content = out
      return q
    end,
  })

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
  add(raw(toc()))
  add(raw("\\clearpage"))
  add(raw(toa(auths, cited)))

  -- body (arabic from 1); the last paragraph is not broken and stays with the signature block (typst: one
  -- unbreakable block, unless the brief's last markdown block is a heading or a footnote definition)
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

  -- certificates (FRAP 32(g); FRAP 25(d)), each on its own page
  add(raw(certificate_of_compliance(m, words)))
  local svc = m.service and m.service.certificate
  if svc == true or (svc ~= nil and plain(svc) == "true") then add(raw(certificate_of_service(m))) end

  return pandoc.Pandoc(out, doc.meta)
end

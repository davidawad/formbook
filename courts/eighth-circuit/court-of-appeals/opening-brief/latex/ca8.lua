-- Eighth Circuit brief, LaTeX engine: the markdown contract (../README.md) -> the macros in template.tex.
-- Mirrors ../typst/ca8-<kind>.typ: the same front matter order (cover, summary of the case, corporate
-- disclosure statement, table of contents, table of authorities), the same length check, the same
-- certificates. Front matter, TOA entries and certificates are built here as raw LaTeX; the body keeps
-- its markdown structure, with headings turned into the template's heading macros and each citation
-- (a link to toa:<key>) followed by a record of its page.

-- The only part that differs between the three copies (each copy is the same filter with its own CFG).
local CFG = {
  kind = "opening-brief",
  word_limit = 13000,                    -- FRAP 32(a)(7)(B)(i); the reply is half of it (32(a)(7)(B)(ii))
  sections = true,                       -- FRAP 28(a)(4)-(9) order and the standard of review (opening only)
  toa_colons = true,                     -- group titles "Cases:" (opening) or "Cases" (reply, answering)
  toa_outline = true,                    -- the table of authorities is listed in the table of contents
  district = { prefix = "Case No. ", sep = "; ", judge = true },
  sig_lines = "indent-emph",             -- signature lines: "indent-emph", "emph" or "plain"
  service = "long",                      -- "long": 8th Cir. CM/ECF wording (opening); "short": the exemplar's wording
  summary_title = "Summary of the Case",
}

local TOA_GROUPS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "regulation", "Regulations" },
  { "rule", "Rules" },
  { "other", "Other Authorities" },
}
if CFG.toa_colons then
  for _, g in ipairs(TOA_GROUPS) do g[2] = g[2] .. ":" end
end

-- FRAP 28(a)(4)-(9), in this order: each entry is a list of alternative Lua patterns for the
-- lower-cased title of a level-1 heading.
local REQUIRED_SECTIONS = {
  { "^jurisdictional statement", "^statement of jurisdiction", "^statement of the jurisdiction" },
  { "^statement of the issues", "^statement of issues", "^issues$" },
  { "^statement of the case", "^statement of case" },
  { "^summary of the argument", "^summary of argument" },
  { "^argument$" },
  { "^conclusion$" },
}
if not CFG.sections then REQUIRED_SECTIONS = {} end

local SERVICE_TEXT = {
  long = "I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the Eighth Circuit by using the appellate CM/ECF system, which will send notification of such filing to all counsel of record.",
  short = "the foregoing brief was filed with the Clerk of Court for the U.S. Court of Appeals for the Eighth Circuit through the CM/ECF system, which will send a notification of such filing to all counsel of record.",
}

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function trim(s)
  local t = s:gsub("^%s+", "")
  t = t:gsub("%s+$", "")
  return t
end

local function latex_of(blocks)
  return trim(pandoc.write(pandoc.Pandoc(blocks), "latex"))
end

-- A metadata value (markdown inlines or blocks, or a plain string) as LaTeX.
local function tex(v)
  if v == nil then return "" end
  if type(v) == "string" then return latex_of({ pandoc.Plain({ pandoc.Str(v) }) }) end
  if type(v) == "boolean" then return tostring(v) end
  if v.t == "MetaInlines" then return latex_of({ pandoc.Plain(v) }) end
  if v.t == "MetaBlocks" then return latex_of(v) end
  if v.t == "MetaString" then return latex_of({ pandoc.Plain({ pandoc.Str(v) }) }) end
  return latex_of({ pandoc.Plain({ pandoc.Str(pandoc.utils.stringify(v)) }) })
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function inlines_tex(inl)
  return latex_of({ pandoc.Plain(inl) })
end

-- plain heading text for a PDF bookmark (characters that would end a macro argument are escaped)
local function bookmark_text(inl)
  return (plain(inl):gsub("([#%%&_$])", "\\%1"))
end

local function raw(s)
  return pandoc.RawBlock("latex", s)
end

local function fail(msg)
  error("ca8-" .. CFG.kind .. ": " .. msg, 0)
end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- Lua patterns cannot alternate, so each required section lists its alternatives.
local function matches_any(title, pats)
  for _, p in ipairs(pats) do
    if title:match(p) then return true end
  end
  return false
end

-- ---------------------------------------------------------------------------
-- Word count (typst's count-words, line by line, on the markdown source)
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return nil end
  local h = io.open(f, "r")
  if not h then return nil end
  local text = h:read("a")
  h:close()
  -- drop the YAML frontmatter, then stop at the addendum
  local lines = {}
  local dashes = 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    elseif line:match("^#%s+[Aa]ddendum%s*$") then
      break
    else
      lines[#lines + 1] = line
    end
  end
  -- the oral argument statement is not counted (FRAP 32(f))
  local kept = {}
  local skipping = false
  for _, line in ipairs(lines) do
    if line:match("^#%s+.*[Oo]ral [Aa]rgument") then
      skipping = true
    elseif skipping and line:match("^#%s") then
      skipping = false
    end
    if not skipping then kept[#kept + 1] = line end
  end
  local n = 0
  for _, line in ipairs(kept) do
    local s = line
    s = s:gsub("^%[%^[^%]]+%]:", " ")
    s = s:gsub("%[%^[^%]]*%]", "")
    s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
    s = s:gsub("^#+%s+", "")
    s = s:gsub("^>%s?", "")
    s = s:gsub("^%s*[-*+]%s+", "")
    s = s:gsub("^%s*%d+[.)]%s+", "")
    s = s:gsub("\\(.)", "%1")
    s = s:gsub("%*", "")
    s = s:gsub("_", "")
    for _ in s:gmatch("%S+") do n = n + 1 end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Pandoc entry point
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local used = {}           -- authorities cited, by key
  local auth = {}           -- authorities from the frontmatter, by key
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
    end
  end

  -- a citation is a link to toa:<key>; the page it lands on is recorded at shipout
  local function link_filter(el)
    local key = el.target:match("^toa:(.+)$")
    if not key then return nil end
    if not auth[key] then
      fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
    used[key] = true
    local out = pandoc.List(el.content)
    out:insert(pandoc.RawInline("latex", "\\toarecord{" .. key .. "}"))
    return out
  end
  local function cites(blocks)
    return pandoc.Pandoc(blocks):walk({ Link = link_filter }).blocks
  end

  -- split off the addendum (everything after a level-1 "Addendum" heading)
  local main, addendum = {}, nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^addendum%s*$") then
      addendum = { table.unpack(doc.blocks, i + 1) }
      break
    end
    main[#main + 1] = b
  end

  -- summary of the case: a level-1 section (8th Cir. R. 28A(i)(1)), or the frontmatter `summary`
  local summary = nil
  local body = {}
  do
    local i = 1
    while i <= #main do
      local b = main[i]
      local h = b.t == "Header" and b.level == 1 and plain(b.content):lower() or nil
      if h and not summary and (h:match("^summary of the case") or h:match("^summary of case")) then
        local s = {}
        i = i + 1
        while i <= #main and not (main[i].t == "Header" and main[i].level == 1) do
          s[#s + 1] = main[i]
          i = i + 1
        end
        summary = s
      else
        body[#body + 1] = b
        i = i + 1
      end
    end
  end
  if not summary and meta.summary then
    local s = meta.summary
    if s.t == "MetaBlocks" then summary = s else summary = { pandoc.Plain(s) } end
  end
  if summary then summary = cites(summary) end

  -- ---- headings: section order and the standard of review (FRAP 28(a)(8)(B)) ----
  if CFG.sections then
    local titles = {}
    for _, b in ipairs(body) do
      if b.t == "Header" and b.level == 1 then
        titles[#titles + 1] = trim(plain(b.content):lower())
      end
    end
    local pos = 0
    for _, pats in ipairs(REQUIRED_SECTIONS) do
      local found = nil
      for k = pos + 1, #titles do
        if matches_any(titles[k], pats) then found = k break end
      end
      if not found then fail("needs a section matching `" .. pats[1] .. "` (in this order; FRAP 28)") end
      pos = found
    end
    local std = false
    for _, b in ipairs(doc.blocks) do
      if b.t == "Header" and b.level >= 2 and plain(b.content):lower():match("standard") then std = true end
    end
    if not std and pandoc.utils.stringify(doc.blocks):lower():match("standard of review") then std = true end
    if not std then fail("FRAP 28(a)(8)(B) requires a statement of the applicable standard of review") end
  end

  -- ---- length: FRAP 32(a)(7) ----
  local words = source_words() or 0
  if words > CFG.word_limit then
    fail("the brief has " .. words .. " words; FRAP 32(a)(7)(B) allows " .. CFG.word_limit)
  end

  -- ---- body: headings become macros, the rest is kept as markdown ----
  local inarg = false
  local body_blocks = {}
  for _, b in ipairs(cites(body)) do
    if b.t == "Header" then
      for _, ib in ipairs(b.content) do
        if ib.t == "Link" and ib.target:match("^toa:") then
          fail("citation links (toa:) are not allowed in headings; the table of contents would list them as authorities")
        end
      end
      if b.level == 1 then
        local t = trim(plain(b.content):lower())
        inarg = (t == "argument" or t == "reply argument")
        body_blocks[#body_blocks + 1] = raw((inarg and "\\inargumenttrue" or "\\inargumentfalse")
          .. "\\BriefSection{" .. inlines_tex(b.content) .. "}{" .. bookmark_text(b.content) .. "}")
      else
        body_blocks[#body_blocks + 1] = raw("\\BriefSub{" .. b.level .. "}{" .. inlines_tex(b.content)
          .. "}{" .. bookmark_text(b.content) .. "}")
      end
    else
      body_blocks[#body_blocks + 1] = b
    end
  end

  -- signature block (FRAP 32(d)): signer, further lines, date, and what follows it
  local sig = meta.signature
  local sig_lines = ""
  local extra = ""
  if sig then
    for _, l in ipairs(sig.lines or {}) do
      if CFG.sig_lines == "indent-emph" then
        sig_lines = sig_lines .. "\\\\\\hspace*{0.5em}\\emph{" .. tex(l) .. "}"
      elseif CFG.sig_lines == "emph" then
        sig_lines = sig_lines .. "\\\\\\emph{" .. tex(l) .. "}"
      else
        sig_lines = sig_lines .. "\\\\" .. tex(l)
      end
    end
    for _, a in ipairs(sig.also or {}) do
      sig_lines = sig_lines .. "\\\\[0.8em]\\textsc{" .. tex(a.name) .. "}"
      for _, l in ipairs(a.lines or {}) do sig_lines = sig_lines .. "\\\\" .. tex(l) end
    end
    if sig.note then
      extra = "\\par\\addvspace{0.8em}\\noindent\\begin{BriefSingleSpace}" .. tex(sig.note) .. "\\end{BriefSingleSpace}"
    end
  end
  local sig_tex = ""
  if sig then
    sig_tex = "\\BriefSignature{" .. tex(sig.signer) .. "}{" .. sig_lines .. "}{" .. tex(meta.date) .. "}{" .. extra .. "}"
  end
  -- the brief's last paragraph is kept on the page with the signature block
  local last = body_blocks[#body_blocks]
  if last and (last.t == "Para" or last.t == "Plain") then
    table.insert(body_blocks, #body_blocks, raw("\\begin{BriefKeep}"))
    body_blocks[#body_blocks + 1] = raw(sig_tex .. "\\end{BriefKeep}")
  else
    body_blocks[#body_blocks + 1] = raw(sig_tex)
  end

  -- ---- front matter ----
  local front = {}
  local function add(x) front[#front + 1] = x end

  -- cover (FRAP 32(a)(2)): case number, caption, proceeding, title, counsel
  local caption = {}
  for i, side in ipairs(meta.caption or {}) do
    local names = {}
    for _, n in ipairs(side.names or {}) do names[#names + 1] = tex(n) end
    if i > 1 then caption[#caption + 1] = "\\CaptionVs" end
    caption[#caption + 1] = "\\CaptionSide{" .. table.concat(names, "\\\\") .. "}{" .. tex(side.designation) .. "}"
  end
  local proceeding = tex(meta.proceeding)
  if meta.district_court_case or (CFG.district.judge and meta.judge) then
    local d = {}
    if meta.district_court_case then d[#d + 1] = CFG.district.prefix .. tex(meta.district_court_case) end
    if CFG.district.judge and meta.judge then d[#d + 1] = tex(meta.judge) end
    proceeding = proceeding .. "\\par " .. table.concat(d, CFG.district.sep)
  end
  local groups = meta.counsel or {}
  local counsel = {}
  local width = "\\dimexpr(\\linewidth-0.25in*(" .. #groups .. "-1))/" .. #groups .. "\\relax"
  for gi, g in ipairs(groups) do
    local names = {}
    for _, n in ipairs(g.names or {}) do names[#names + 1] = tex(n) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = tex(l) end
    if gi == #groups and meta.phone then lines[#lines + 1] = tex(meta.phone) end
    if gi > 1 then counsel[#counsel + 1] = "\\hspace{0.25in}" end
    counsel[#counsel + 1] = "\\CounselCell{" .. width .. "}{" .. table.concat(names, "\\\\") .. "}{"
      .. table.concat(lines, "\\\\") .. "}"
  end
  add(raw("\\BriefCover{" .. tex(meta.case_number) .. "}{" .. table.concat(caption) .. "}{"
    .. proceeding .. "}{" .. tex(meta.brief_title) .. "}{\\begin{CounselRow}" .. table.concat(counsel)
    .. "\\end{CounselRow}}"))
  add(raw("\\clearpage\\pagenumbering{roman}"))

  if summary then
    add(raw("\\BriefFrontHeading{" .. CFG.summary_title .. "}"))
    for _, b in ipairs(summary) do add(b) end
    add(raw("\\clearpage"))
  end

  if meta.disclosure then
    add(raw("\\BriefFrontHeading{Corporate Disclosure Statement}\\begin{BriefSingleSpace}"
      .. "\\setlength{\\parskip}{1em}\\setlength{\\parindent}{0pt}"))
    add(raw(tex(meta.disclosure)))
    add(raw("\\end{BriefSingleSpace}\\clearpage"))
  end

  add(raw("\\BriefTOC\\clearpage"))

  -- table of authorities: the cited authorities, grouped and sorted (FRAP 28(a)(3))
  local toa = {}
  if CFG.toa_outline then
    toa[#toa + 1] = raw("\\BriefSection{Table of Authorities}{Table of Authorities}")
  else
    toa[#toa + 1] = raw("\\BriefFrontHeading{Table of Authorities}")
  end
  local first = true
  local seen_key = {}
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      local function sortkey(k)
        local a = auth[k]
        local s = a.sort and plain(a.sort) or ""
        if s == "" then s = plain(a.name) .. " " .. plain(a.cite) end
        return (s:lower():gsub("[^a-z0-9 ]", ""))
      end
      table.sort(members, function(x, y) return sortkey(x) < sortkey(y) end)
      toa[#toa + 1] = raw("\\BriefToaGroup{" .. g[2] .. "}{" .. (first and "1em" or "1.4em") .. "}{"
        .. (first and "1" or "0") .. "}")
      first = false
      for _, k in ipairs(members) do
        local a = auth[k]
        local name = ""
        if a.name then
          local n = tex(a.name)
          if g[1] == "case" then n = "\\emph{" .. n .. "}" end
          name = n .. ",\\\\"
        end
        toa[#toa + 1] = raw("\\BriefToaEntry{" .. k .. "}{" .. name .. "}{" .. tex(a.cite) .. "}")
        seen_key[k] = true
      end
    end
  end
  for key in pairs(used) do
    if not seen_key[key] then fail("internal: `" .. key .. "` is cited but not listed") end
  end
  for _, b in ipairs(toa) do add(b) end
  add(raw("\\clearpage\\pagenumbering{arabic}"))

  -- certificates (FRAP 32(g); Form 6): the compliance certificate, then service when asked for
  local certs = {}
  if sig then
    certs[#certs + 1] = raw("\\clearpage\\BriefCertCompliance{" .. group_digits(words) .. "}{"
      .. tex(meta.word_processor) .. "}{" .. tex(meta.typeface) .. "}{" .. tex(meta.virus_check or CFG.virus) .. "}")
    certs[#certs + 1] = raw("\\BriefFormSig{" .. tex(sig.signer) .. "}{" .. tex(sig["for"]) .. "}{" .. tex(meta.date) .. "}")
  end
  if meta.service and meta.service.certificate then
    local text = "I hereby certify that on " .. tex(meta.date) .. ", " .. SERVICE_TEXT[CFG.service]
    local unreg = meta.service.unregistered or {}
    if #unreg > 0 then
      text = text .. "\\par I further certify that on the same date I served the foregoing by mail on the following persons who are not registered for electronic filing:"
      for _, u in ipairs(unreg) do text = text .. "\\par\\hspace*{0.5in}" .. tex(u.name) .. "\\\\" .. tex(u.address) end
    end
    certs[#certs + 1] = raw("\\clearpage\\BriefServiceCert{" .. text .. "}")
    if sig then
      certs[#certs + 1] = raw("\\BriefFormSig{" .. tex(sig.signer) .. "}{" .. tex(sig["for"]) .. "}{" .. tex(meta.date) .. "}")
    end
  end

  local result = {}
  for _, b in ipairs(front) do result[#result + 1] = b end
  for _, b in ipairs(body_blocks) do result[#result + 1] = b end
  for _, b in ipairs(certs) do result[#result + 1] = b end
  if addendum then
    result[#result + 1] = raw("\\clearpage\\renewcommand{\\thepage}{Add-\\arabic{page}}\\setcounter{page}{1}\\BriefSection{Addendum}{Addendum}")
    for _, b in ipairs(cites(addendum)) do result[#result + 1] = b end
  end

  doc.blocks = result
  return doc
end

-- lib/front.lua: the brief as one markdown text, from the sample: the cover, the front matter (disclosure,
-- certifications) and the back matter (signature, certificate of compliance, certificate of service) written from
-- the frontmatter, around the body; mirrors bap8-*.typ (cover-body, certifications, certificates). Loaded by
-- brief.lua (dofile), which reads the text with pandoc and lays it out (fb-595.68.1: were docx/render.sh and
-- docx/front.jq; the text is the one they wrote, so the document is too).
--   M.assemble(meta, source, kind) -> markdown, word count
-- meta: the frontmatter as written ($FORMBOOK_META, fb render); source: the sample's text; kind: the folder name
-- (the reply brief has the shorter word limit).
local M = {}

local json_null = pandoc.json and pandoc.json.null

-- jq's view of a value: nil and JSON null are null
local function null(v) return v == nil or v == json_null end
-- jq's `a // b`: b when a is null or false
local function alt(v, d)
  if null(v) or v == false then return d end
  return v
end
-- jq's string interpolation of a value
local function str(v)
  if null(v) then return "null" end
  if type(v) == "boolean" then return v and "true" or "false" end
  if type(v) == "number" then
    if v == math.floor(v) then return string.format("%d", v) end
    return tostring(v)
  end
  return v
end
local function list(v) return null(v) and {} or v end

-- ---- the sample: its frontmatter block and its body lines ----

local function lines_of(text)
  local out = {}
  for l in (text:gsub("\n$", "") .. "\n"):gmatch("(.-)\n") do out[#out + 1] = l end
  if text == "" then out = {} end
  return out
end

local function body_lines(source)
  local ls = lines_of(source)
  if ls[1] ~= "---" then error("brief.lua: the sample must start with a YAML frontmatter block", 0) end
  for i = 2, #ls do
    if ls[i] == "---" then
      local body = {}
      for j = i + 1, #ls do body[#body + 1] = ls[j] end
      return body
    end
  end
  error("brief.lua: the frontmatter is not closed", 0)
end

-- ---- word count: the typst template's count-words, rule for rule; the oral argument statement is not counted
-- (FRAP 32(f)) ----

local UNICODE_SPACES = {"\u{0085}", "\u{00A0}", "\u{1680}", "\u{2028}", "\u{2029}", "\u{202F}", "\u{205F}", "\u{3000}"}
for c = 0x2000, 0x200A do UNICODE_SPACES[#UNICODE_SPACES + 1] = utf8.char(c) end

-- `f` on every line of `text` (a perl /m substitution)
local function per_line(text, f)
  return (("\n" .. text):gsub("\n([^\n]*)", function(l) return "\n" .. f(l) end):sub(2))
end

local function count_words(body)
  local kept, skip = {}, false
  for _, l in ipairs(body) do
    if l:match("^#[ \t]+") and (l:match("[Oo]ral [Aa]rgument")) then
      skip = true
    else
      if skip and l:match("^#[ \t]") then skip = false end
      if not skip then kept[#kept + 1] = l end
    end
  end
  local s = #kept > 0 and (table.concat(kept, "\n") .. "\n") or ""
  s = s:gsub("<!%-%-.-%-%->", " ")
  s = per_line(s, function(l) return (l:gsub("^%[%^[^%]]+%]:", " ")) end)   -- footnote definition labels
  s = s:gsub("%[%^[^%]]+%]", "")                                           -- footnote references
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")                               -- links keep their text
  s = per_line(s, function(l)
    local hashes, rest = l:match("^(#+)[ \t]+(.*)$")
    if hashes and #hashes <= 6 then return rest end
    return l
  end)
  s = per_line(s, function(l) return (l:gsub("^>[ \t]?", "")) end)
  s = per_line(s, function(l)                                              -- list markers are not words
    local a = l:gsub("^[ \t]*[%-%*%+][ \t]+", "", 1)
    if a ~= l then return a end
    return (l:gsub("^[ \t]*%d+[%.%)][ \t]+", "", 1))
  end)
  s = s:gsub("\\([^\n])", "%1")                                            -- backslash escapes
  s = s:gsub("%*", "")
  s = s:gsub("^_", ""):gsub("([%s%(%[\"])_", "%1"):gsub("\u{201C}_", "\u{201C}")
  s = s:gsub("_([%s%.,;:%)%]\"!%?])", "%1"):gsub("_\u{201D}", "\u{201D}"):gsub("_(\n?)$", "%1")
  for _, sp in ipairs(UNICODE_SPACES) do s = s:gsub(sp, " ") end
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---- the last body paragraph is kept with the signature block (typst: block(breakable: false, ...)) ----

local function keep_last(body)
  local last = #body
  while last > 0 and body[last]:match("^[ \t]*$") do last = last - 1 end
  local start = last
  while start > 1 and body[start - 1]:match("[^ \t]") do start = start - 1 end
  local first = body[start] or ""
  local keep = not (first:match("^#") or first:match("^%[%^") or first:match("^<!%-%-") or first:match("^>")
    or first:match("^:::") or first:match("^[%-%*%+] ") or first:match("^%d+[%.%)] "))
  local out = {}
  for i = 1, start - 1 do out[#out + 1] = body[i] end
  if keep then out[#out + 1] = '::: {custom-style="BodyKeep"}' end
  for i = start, last do out[#out + 1] = body[i] end
  if keep then out[#out + 1] = ":::" end
  for i = last + 1, #body do out[#out + 1] = body[i] end
  return #out > 0 and (table.concat(out, "\n") .. "\n") or ""
end

-- ---- the cover, the front matter and the back matter, as pandoc markdown ----

local function div(s, b) return '::: {custom-style="' .. s .. '"}\n' .. b .. "\n:::\n\n" end
local NB = "\u{00A0}"
local function gap() return div("CoverGap", NB) end
local function rule(s) return div(s, NB) end
local function hard(xs) return table.concat(xs, "\\\n") end
-- a literal value: no smart dashes from markdown (typst prints the case number as it is)
local function lit(s) return (str(s):gsub("%-", "\\-")) end
local function raw(x) return "```{=openxml}\n" .. x .. "\n```\n\n" end
-- a page break in a paragraph of a 1 pt line, so the next page starts at its top (typst pagebreak)
local PAGEBREAK = raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')
local PGSZ = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
-- the footer the numbered sections name (brief.lua gives it to fb render, FORMBOOK_FOOTERS)
M.FOOTER_ID = "rIdBapPage"
local function section_end(footer, fmt)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>'
    .. (footer and ('<w:footerReference w:type="default" r:id="' .. M.FOOTER_ID .. '"/>') or "")
    .. PGSZ
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "")
    .. "</w:sectPr></w:pPr></w:p>")
end
-- the lines of a block of text: blank lines dropped, a leading "- " or "* " taken off
local function text_lines(t)
  local out = {}
  for l in (str(t) .. "\n"):gmatch("(.-)\n") do
    if l:match("%S") then out[#out + 1] = (l:gsub("^%s*[%-%*]%s+", "", 1)) end
  end
  return out
end
local function map_join(xs, f)
  local out = {}
  for i, x in ipairs(xs) do out[#out + 1] = f(x, i) end
  return table.concat(out)
end
local function uc(s) return (str(s):upper()) end

local function sig_lines(m)
  local xs = {"/s/ " .. str(m.signature.signer), "Attorney for " .. str(alt(m.signature["for"], ""))}
  if m.date ~= nil then xs[#xs + 1] = "Dated: " .. str(m.date) end
  return xs
end
local function formsig(m) return div("FormSig", hard(sig_lines(m))) end

local function cover(m)
  local caption = list(m.caption)
  local counsel = list(m.counsel)
  local dist = ""
  if m.district_court_case ~= nil or m.judge ~= nil then
    dist = div("CoverCenter", (m.district_court_case ~= nil and ("Underlying case: " .. str(m.district_court_case)) or "")
      .. ((m.district_court_case ~= nil and m.judge ~= nil) and "; " or "")
      .. (m.judge ~= nil and str(m.judge) or ""))
  end
  return div("CoverCenter", "**BAP No. " .. lit(m.case_number) .. "**")
    .. gap() .. rule("DoubleRule") .. gap()
    .. div("CoverCenter", "**UNITED STATES BANKRUPTCY APPELLATE PANEL FOR THE EIGHTH CIRCUIT**")
    .. gap() .. rule("ShortRule") .. gap()
    .. map_join(caption, function(c, i)
      return map_join(c.names, function(n) return div("CoverCenter", str(n)) end)
        .. div("CoverIndent", str(c.designation))
        .. (i < #caption and (gap() .. div("CoverCenter", "v\\.") .. gap()) or "")
    end)
    .. gap() .. rule("ShortRule") .. gap()
    .. div("CoverCenter", str(m.proceeding))
    .. dist
    .. gap() .. rule("ShortRule") .. gap()
    .. div("CoverCenter", "**" .. uc(m.brief_title) .. "**")
    .. gap() .. rule("ShortRule") .. gap()
    .. map_join(counsel, function(c, i)
      local ls = {}
      for _, l in ipairs(list(alt(c.lines, {}))) do ls[#ls + 1] = l end
      if i == #counsel then ls[#ls + 1] = alt(m.phone, json_null); ls[#ls + 1] = alt(m.email, json_null) end
      return map_join(c.names, function(n) return div("CoverIndent", str(n)) end)
        .. map_join(ls, function(l) return div("CoverStep", "*" .. str(l) .. "*") end)
    end)
    .. rule("DoubleRule")
    .. section_end(false, nil)
end

local function cert_interested(m)
  return div("FrontHeading", "Certification of Interested Parties")
    .. div("Single", "BAP No. " .. lit(m.case_number))
    .. div("Single", "The undersigned, counsel of record for " .. str(alt(m.signature["for"], "")) .. ", certifies that the following listed party (or parties) has (have) an interest in the outcome of this appeal. These representations are made to enable the judges of the panel to evaluate possible disqualification or recusal.")
    .. map_join(text_lines(m.interested_parties), function(l) return div("BulletItem", l) end)
    .. formsig(m)
    .. PAGEBREAK
    .. div("FrontHeading", "Certification of Related Cases")
    .. map_join(text_lines(m.related_cases), function(l) return div("Single", l) end)
    .. formsig(m)
end

local function front(m)
  local disclosure = ""
  if m.disclosure ~= nil then
    disclosure = div("FrontHeading", "Disclosure Statement")
      .. map_join(text_lines(m.disclosure), function(l) return div("Single", l) end)
      .. PAGEBREAK
  end
  return disclosure .. cert_interested(m) .. PAGEBREAK
    .. '::: {custom-style="TOCPlaceholder"}\n@@TOC@@\n:::\n\n'
    .. PAGEBREAK
    .. '::: {custom-style="TOAPlaceholder"}\n@@TOA@@\n:::\n\n'
end

local function back(m, words)
  local svc = alt(m.service, {})
  local unreg = list(alt(svc.unregistered, {}))
  local out = div("SigHead", "Respectfully submitted,")
    .. div("SigName", hard({"/s/ " .. str(m.signature.signer), uc(m.signature.signer)}))
    .. (#list(alt(m.signature.lines, {})) > 0 and div("SigLines", hard(m.signature.lines)) or "")
    .. (m.date ~= nil and div("SigDate", str(m.date)) or "")
    .. PAGEBREAK
    .. div("FrontHeading", "Certificate of Compliance")
    .. div("Single", "1\\. This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g):")
    .. div("CertBox", "CHECKBOXMARK this brief contains " .. words .. " words.")
    .. div("Single", "2\\. This brief complies with the typeface requirements of Fed. R. Bankr. P. 8015(a)(5) and the type-style requirements of Fed. R. Bankr. P. 8015(a)(6) because:")
    .. div("CertBox", "CHECKBOXMARK this brief has been prepared in a proportionally spaced typeface using " .. str(m.word_processor) .. " in 14-point " .. str(m.typeface) .. " roman type.")
    .. div("FormSig", hard(sig_lines(m)))
  if alt(svc.certificate, false) or #unreg > 0 then
    out = out .. PAGEBREAK
      .. div("FrontHeading", "Certificate of Service")
      .. div("Single", "I hereby certify that on " .. str(alt(m.date, "\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_")) .. ", I electronically filed the foregoing with the Clerk of the United States Bankruptcy Appellate Panel for the Eighth Circuit by using the CM/ECF system, which will send notification of such filing to all counsel of record.")
    if #unreg > 0 then
      out = out .. div("Single", "I further certify that on the same date I served one paper copy of the foregoing by mail on the following persons who are not registered for electronic filing (L.R. BAP 8th Cir. 8014A(c)):")
        .. map_join(unreg, function(u) return div("ServiceAddress", str(u.name) .. ", " .. str(u.address)) end)
    end
    out = out .. div("FormSig", hard(sig_lines(m)))
  end
  return out
end

-- The whole brief as markdown, and its word count (FRBP 8015(a)(7)(B)).
function M.assemble(meta, source, kind)
  local body = body_lines(source)
  local words = count_words(body)
  local limit = kind == "reply-brief" and 6500 or 13000   -- FRBP 8015(a)(7)(B)(ii): half the principal limit
  if words > limit then
    error("brief.lua: the brief has " .. words .. " words; FRBP 8015(a)(7)(B) allows " .. limit, 0)
  end
  local md = cover(meta) .. "\n" .. front(meta) .. section_end(true, "lowerRoman") .. "\n"
    .. keep_last(body) .. "\n\n" .. back(meta, group_digits(words)) .. "\n"
  return md, words
end

-- The authority keys in the order the body first cites them (`(toa:key)` in the markdown).
function M.cited_keys(source)
  local keys, seen = {}, {}
  for k in table.concat(body_lines(source), "\n"):gmatch("%(toa:([A-Za-z0-9_]+)%)") do
    if not seen[k] then seen[k] = true; keys[#keys + 1] = k end
  end
  return keys
end

return M

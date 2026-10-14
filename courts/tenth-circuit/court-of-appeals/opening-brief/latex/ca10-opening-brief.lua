-- Pandoc filter for the LaTeX engine (opening-brief/latex/template.tex). Mirrors typst/ca10-opening-brief.typ:
--   * section headings become \ctensection / \ctenpoint / \ctensub with the printed label the typst
--     template gives them (Argument: I. A. 1. a.; elsewhere A. 1. a. (1)), and each heading goes to the TOC;
--   * every toa: link gets a \label per hit, and the table of authorities is written here as TeX
--     (\ctentoaentry lists the pages in the template, two passes resolve them);
--   * the body word count (footnotes excluded) is formatted for the certificate of compliance.

local WORD_LIMIT = 13000
local TOC_ROMAN_LIMIT = 4

local function roman(n)
  local vals = { {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"}, {100, "C"}, {90, "XC"}, {50, "L"},
    {40, "XL"}, {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"} }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

-- Inline content (or a plain Lua string) to LaTeX, escaped.
local function tex(inl)
  if type(inl) == "string" then inl = { pandoc.Str(inl) } end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inl) }), "latex")
  return (s:gsub("%s+$", ""))
end

-- Plain text of inline content, as a LaTeX-escaped string with no formatting (safe for \addcontentsline).
local function plain_tex(inl, upper)
  local s = pandoc.utils.stringify(inl)
  return tex({ pandoc.Str(upper and s:upper() or s) })
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local in_arg = false
local counts = { 0, 0, 0, 0, 0 }
local hits = {}       -- key -> number of citations so far
local authorities_used = {}

local function label_for(level)
  local n = counts[level]
  if in_arg then
    if level == 2 then return roman(n) .. "."
    elseif level == 3 then return string.char(64 + n) .. "."
    elseif level == 4 then return tostring(n) .. "."
    elseif level == 5 then return string.char(96 + n) .. "."
    end
  else
    if level == 2 then return string.char(64 + n) .. "."
    elseif level == 3 then return tostring(n) .. "."
    elseif level == 4 then return string.char(96 + n) .. "."
    elseif level == 5 then return "(" .. tostring(n) .. ")"
    end
  end
  error("ca10-opening-brief: headings deeper than level 5 are not supported")
end

-- Left edge of a sub-heading's label, in inches: the typst template's label-indent().
local function label_indent(level)
  local first = in_arg and 3 or 2
  return (level - first + 1) * 0.5
end

function Header(h)
  local text = tex(h.content)
  local plain = plain_tex(h.content, h.level == 1)
  if h.level == 1 then
    in_arg = pandoc.utils.stringify(h.content):lower():match("^%s*(.-)%s*$") == "argument"
    for l = 2, 5 do counts[l] = 0 end
    counts[1] = counts[1] + 1
    return pandoc.RawBlock("latex", "\\ctensection{" .. text .. "}{" .. plain .. "}")
  end
  for l = h.level + 1, 5 do counts[l] = 0 end
  counts[h.level] = counts[h.level] + 1
  local label = label_for(h.level)
  if in_arg and h.level == 2 then
    return pandoc.RawBlock("latex", "\\ctenpoint{" .. label .. "}{" .. text .. "}{" .. plain .. "}")
  end
  local style = h.level >= 4 and "\\bfseries\\itshape" or "\\bfseries"
  return pandoc.RawBlock("latex", "\\ctensub{" .. string.char(96 + h.level) .. "}{" .. label_indent(h.level) .. "}{" .. label ..
    "}{" .. text .. "}{" .. plain .. "}{" .. style .. "}")
end

-- toa: links become the cited text followed by a label, one per citation (the pages are read back in TeX).
function Link(l)
  if not l.target:match("^toa:") then return nil end
  local key = l.target:sub(5)
  hits[key] = (hits[key] or 0) + 1
  authorities_used[key] = true
  local out = pandoc.List(l.content)
  out:insert(pandoc.RawInline("latex", "\\label{cten-toa-" .. key .. "-" .. hits[key] .. "}"))
  return out
end

-- Body words: text of the body, footnotes and markup removed; the typst count-words() rule.
local function body_words(blocks)
  local doc = pandoc.Pandoc(blocks):walk({
    Note = function() return {} end,
  })
  local n = 0
  for _ in pandoc.utils.stringify(doc):gmatch("%S+") do n = n + 1 end
  return n
end

local function authority_sort_key(a)
  local name = a.name and pandoc.utils.stringify(a.name) or ""
  return (name .. " " .. pandoc.utils.stringify(a.cite)):lower():gsub("[^a-z0-9 ]", "")
end

local GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

local function toa_tex(authorities)
  local out = {}
  local first = true
  for key in pairs(hits) do
    if not authorities[key] then
      error("ca10-opening-brief: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if a.kind and pandoc.utils.stringify(a.kind) == g[1] and hits[key] then
        table.insert(members, { key = key, a = a, sort = authority_sort_key({ name = a.name, cite = a.cite }) })
      end
    end
    table.sort(members, function(x, y) return x.sort < y.sort end)
    if #members > 0 then
      table.insert(out, "\\ctentoagroup{" .. g[2] .. "}{" .. (first and "1" or "0") .. "}")
      first = false
      for _, m in ipairs(members) do
        local name = ""
        if m.a.name then
          name = tex(m.a.name)
          if g[1] == "case" then name = "\\emph{" .. name .. "}" end
        end
        table.insert(out, "\\ctentoaentry{" .. name .. "}{" .. tex(m.a.cite) .. "}{" .. m.key .. "}{" ..
          hits[m.key] .. "}")
      end
    end
  end
  return table.concat(out, "\n")
end

function Pandoc(doc)
  local words = body_words(doc.blocks)
  if words > WORD_LIMIT then
    error("ca10-opening-brief: the brief has " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. WORD_LIMIT)
  end
  doc.meta.words = pandoc.MetaInlines({ pandoc.Str(group_digits(words)) })
  doc.meta.word_limit = pandoc.MetaInlines({ pandoc.Str(group_digits(WORD_LIMIT)) })
  local authorities = {}
  for k, a in pairs(doc.meta.authorities or {}) do authorities[k] = a end
  doc.meta.toa = pandoc.MetaBlocks({ pandoc.RawBlock("latex", toa_tex(authorities)) })
  doc.meta.oral_requested = pandoc.MetaBool(pandoc.utils.stringify(doc.meta.oral_argument or "") == "requested")
  local att = {}
  for i, a in ipairs(doc.meta.attachments or {}) do
    table.insert(att, "\\ctenattachment{" .. tex(a) .. "}{" .. i .. "}")
  end
  doc.meta.attachments_tex = pandoc.MetaBlocks({ pandoc.RawBlock("latex", table.concat(att, "\n")) })
  return doc
end

-- cadc.lua: pandoc filter for the D.C. Circuit answering-brief LaTeX template (latex/template.tex). Run by fb render.
--
-- What it does, and nothing more (layout lives in template.tex). Same rules as typst/cadc-answering-brief.typ:
--   1. Splits the brief at `# Addendum` (the heading is dropped): the rest goes to meta `addendum`.
--   2. Counts the words of the body (footnote text included, addendum excluded) and stops the build over the
--      limit (FRAP 32(a)(7)(B)(i)). Meta `words_fmt` is the count with commas.
--   3. Turns every link whose target is `toa:KEY` into \dc@toacite{KEY}{text}: the text is set as written and the
--      page where the citation starts goes to the aux file (template.tex). A key not in `authorities:` stops the build.
--   4. Numbers the body headings as the typst template does (Argument: I. / A. / 1. / a.; elsewhere A. / 1. / a. / (1))
--      and emits them as \dc@toc / \dc@hpoint / \dc@hsub / \dc@hone calls. Addendum headings are unnumbered.
--   5. Builds the table of authorities in the six groups of the typst template (cited keys only, meta `toa`).
--      Page numbers come from the aux file, read back in the next pass.
--   6. Converts every frontmatter string to LaTeX (markdown in the YAML is kept: italics, \* for asterisks).
--   7. Marks the last paragraph of the brief as samepage (meta `keep_last`), so the signature block stays with it.

local WORD_LIMIT = 13000

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function latex_of(blocks)
  return trim(pandoc.write(pandoc.Pandoc(blocks), "latex"))
end

local function latex_inlines(inl)
  return latex_of({ pandoc.Plain(inl) })
end

local function meta_latex(v)
  local kind = pandoc.utils.type(v)
  if kind == "string" then
    return latex_of(pandoc.read(v, "markdown").blocks)
  elseif kind == "Inlines" then
    return latex_inlines(v)
  elseif kind == "Blocks" then
    return latex_of(v)
  end
  return latex_inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function raw_meta(s)
  return pandoc.MetaBlocks({ pandoc.RawBlock("latex", s) })
end

-- Converts a metadata tree: lists and maps stay lists and maps; booleans stay booleans; leaves become raw LaTeX.
local function conv(v)
  local kind = pandoc.utils.type(v)
  if kind == "boolean" then
    return v
  elseif kind == "List" or (kind == "table" and v[1] ~= nil) then
    local out = {}
    for i, x in ipairs(v) do
      out[i] = conv(x)
    end
    return pandoc.MetaList(out)
  elseif kind == "Map" or kind == "table" then
    local out = {}
    for k, x in pairs(v) do
      out[k] = conv(x)
    end
    return pandoc.MetaMap(out)
  end
  return raw_meta(meta_latex(v))
end

-- Words of a list of blocks: whitespace-delimited, footnote text included, markup not counted.
local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    local notes = {}
    local bare = pandoc.Pandoc({ b }):walk({
      Note = function(note)
        notes[#notes + 1] = note
        return {}
      end,
    })
    -- smart punctuation puts no-break spaces after "No." and "Jan."; they separate words here as they do in the typst count.
    local text = pandoc.utils.stringify(bare.blocks):gsub("\u{00A0}", " ")
    for _ in text:gmatch("%S+") do
      n = n + 1
    end
    for _, note in ipairs(notes) do
      n = n + count_words(note.content)
    end
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

-- Printed label of a numbered heading (typst heading-label).
local function label(level, in_arg, n)
  if in_arg then
    if level == 2 then return roman(n):upper() .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    return string.char(96 + n) .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return tostring(n) .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

-- Left edge of a heading's label, in inches (typst label-indent): half an inch per level below the first.
local function indent(level, in_arg)
  local first = in_arg and 3 or 2
  return (level - first + 1) * 0.5
end

local function inches(x)
  return string.format("%gin", x)
end

-- The six groups of the table of authorities, in the typst template's order.
local groups = {
  { kind = "case", title = "Cases:" },
  { kind = "constitution", title = "Constitutional Provisions:" },
  { kind = "statute", title = "Statutes:" },
  { kind = "regulation", title = "Regulations:" },
  { kind = "rule", title = "Rules:" },
  { kind = "other", title = "Other Authorities:" },
}

-- typst sort-key: lower case, letters, digits and spaces only.
local function sort_key(a)
  local s
  if a.sort then
    s = pandoc.utils.stringify(a.sort)
  else
    s = (a.name and pandoc.utils.stringify(a.name) or "") .. " " .. pandoc.utils.stringify(a.cite)
  end
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function toa_blocks(authorities, cited)
  local out = {}
  local first = true
  for _, g in ipairs(groups) do
    local members = {}
    for key in pairs(cited) do
      local a = authorities[key]
      if a and pandoc.utils.stringify(a.kind) == g.kind then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(p, q)
        if p.sort == q.sort then
          return p.key < q.key
        end
        return p.sort < q.sort
      end)
      out[#out + 1] = pandoc.RawBlock("latex", "\\dc@toagroup{" .. g.title .. "}{" .. (first and 1 or 0) .. "}")
      first = false
      for _, m in ipairs(members) do
        local a = m.a
        local cite = latex_inlines(a.cite)
        local line = cite
        if a.name then
          local name = latex_inlines(a.name)
          if g.kind == "case" then
            name = "\\emph{" .. name .. "}"
          end
          line = name .. ",\\newline " .. cite
        end
        out[#out + 1] = pandoc.RawBlock("latex", "\\dc@toaline{" .. m.key .. "}{" .. line .. "}")
      end
    end
  end
  return out
end

-- Inlines with every string in capitals (the table of contents must not use \\MakeUppercase: hyperref reads it).
local function upper_inlines(inl)
  local doc = pandoc.Pandoc({ pandoc.Plain(inl) }):walk({
    Str = function(s)
      return pandoc.Str(s.text:upper())
    end,
  })
  return doc.blocks[1].content
end

-- Body headings to LaTeX. numbered = the brief body (typst numbering); otherwise the addendum (unnumbered).
local function heading_blocks(blocks, numbered)
  local out = {}
  local cnt = { 0, 0, 0, 0, 0 }
  local in_arg = false
  for _, b in ipairs(blocks) do
    if b.t ~= "Header" then
      out[#out + 1] = b
    else
      local level = b.level
      if level > 5 then
        error("cadc.lua: headings deeper than level 5 are not supported")
      end
      local title = latex_inlines(b.content)
      if level == 1 then
        in_arg = trim(pandoc.utils.stringify(b.content)):lower() == "argument"
      end
      local code
      if numbered then
        cnt[level] = cnt[level] + 1
        for j = level + 1, 5 do
          cnt[j] = 0
        end
        if level == 1 then
          code = "\\dc@hone{" .. title .. "}" .. "\\dc@toc{0in}{}{" .. latex_inlines(upper_inlines(b.content)) .. "}\\nobreak"
        elseif level == 2 and in_arg then
          local lab = label(level, in_arg, cnt[level])
          code = "\\dc@hpoint{" .. lab .. "}{" .. title .. "}" .. "\\dc@toc{0in}{" .. lab .. "}{" .. title .. "}\\nobreak"
        else
          local lab = label(level, in_arg, cnt[level])
          local ind = inches(indent(level, in_arg))
          code = "\\dc@hsub{" .. level .. "}{" .. ind .. "}{" .. lab .. "}{" .. title .. "}"
          if level <= 4 then
            code = code .. "\\dc@toc{" .. ind .. "}{" .. lab .. "}{" .. title .. "}\\nobreak"
          end
        end
      else
        if level == 1 then
          code = "\\dc@hone{" .. title .. "}"
        elseif level == 2 then
          code = "\\dc@adtoc{" .. title .. "}\\dc@hplain{" .. title .. "}"
        else
          code = "\\dc@hplain{" .. title .. "}"
        end
      end
      out[#out + 1] = pandoc.RawBlock("latex", code)
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local authorities = meta.authorities or {}
  local cited = {}
  local seen_missing = {}

  -- Every citation: the registry key is recorded; the text is set as written.
  local doc2 = pandoc.Pandoc(doc.blocks, meta):walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then
        return nil
      end
      if authorities[key] == nil and not seen_missing[key] then
        seen_missing[key] = true
        error("cadc.lua: cited authority `" .. key .. "` is not in the authorities registry")
      end
      cited[key] = true
      local out = { pandoc.RawInline("latex", "\\dc@toacite{" .. key .. "}{") }
      for _, x in ipairs(el.content) do
        out[#out + 1] = x
      end
      out[#out + 1] = pandoc.RawInline("latex", "}")
      return out
    end,
  })

  -- Split at `# Addendum`.
  local body, add = {}, {}
  local target = body
  for _, b in ipairs(doc2.blocks) do
    if b.t == "Header" and b.level == 1 and trim(pandoc.utils.stringify(b.content)):lower() == "addendum" then
      target = add
    else
      target[#target + 1] = b
    end
  end

  local words = count_words(body)
  if words > WORD_LIMIT then
    error("cadc.lua: body is " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. WORD_LIMIT)
  end

  -- Headings, then the samepage mark on the last paragraph (the signature block is kept with it).
  body = heading_blocks(body, true)
  local last = body[#body]
  local keep_last = false
  if last and (last.t == "Para" or last.t == "Plain") then
    -- The heading just before the last paragraph goes into the group too (a heading never stands alone).
    local start = #body
    local prev = body[#body - 1]
    if prev and prev.t == "RawBlock" and prev.text:match("^\\dc@h") then
      start = #body - 1
    end
    table.insert(body, start, pandoc.RawBlock("latex", "\\begin{samepage}"))
    keep_last = true
  end

  -- Frontmatter to LaTeX. The counsel's telephone goes on the last counsel group (typst cover-body).
  local converted = {}
  for k in pairs(meta) do
    if k ~= "authorities" then
      converted[k] = conv(meta[k])
    end
  end
  if converted.counsel and meta.phone then
    local groups_out = {}
    local n = #converted.counsel
    for i, g in ipairs(converted.counsel) do
      local lines = {}
      for j, x in ipairs(g.lines or {}) do
        lines[j] = x
      end
      if i == n then
        lines[#lines + 1] = raw_meta(meta_latex(meta.phone))
      end
      groups_out[i] = pandoc.MetaMap({ names = g.names, lines = pandoc.MetaList(lines) })
    end
    converted.counsel = pandoc.MetaList(groups_out)
  end
  -- The certificates of compliance and service print only the first signature line (typst form-sig-line).
  if converted.signature and converted.signature.lines then
    local sig = {}
    for k, v in pairs(converted.signature) do
      sig[k] = v
    end
    sig.line1 = converted.signature.lines[1]
    converted.signature = pandoc.MetaMap(sig)
  end
  for k, v in pairs(converted) do
    doc2.meta[k] = v
  end

  doc2.meta.words_fmt = raw_meta(group_digits(words))
  doc2.meta.keep_last = keep_last
  doc2.meta.toa = pandoc.MetaBlocks(toa_blocks(authorities, cited))
  doc2.meta.addendum = pandoc.MetaBlocks(heading_blocks(add, false))
  return pandoc.Pandoc(body, doc2.meta)
end

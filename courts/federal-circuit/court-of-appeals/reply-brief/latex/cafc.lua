-- cafc.lua: pandoc filter for the cafc LaTeX template (latex/template.tex). Run by latex/render.sh.
--
-- What it does, and nothing more (layout lives in template.tex):
--   1. Splits the document at `# Addendum`: the body stays in the body, the rest goes to meta `addendum`.
--   2. Marks the Argument for the heading macros: \ca@argtrue before `# Argument` (or `# Reply Argument`),
--      \ca@argfalse before any other level-1 heading, so level-2 to level-5 headings get the Argument's labels.
--   3. Turns every link whose target is `toa:KEY` into \ca@toacite{KEY}{text}: the text is set as written and
--      the page where the citation starts is recorded in the aux file (template.tex, \ca@toahit).
--   4. Builds the table of authorities from the `authorities:` registry, in the six groups of the typst template,
--      cases alphabetized, only the authorities the body cites. Page numbers come from the aux file.
--   5. Counts the words of the body (footnotes included, the addendum excluded) for the certificate of compliance.
--   6. Keeps the last paragraph of the body with the signature block (meta keep_signature).
--
-- A link to a key that is not in `authorities:` stops the build, as in the typst template.

local function text(x)
  return pandoc.utils.stringify(x)
end

-- A section or pilcrow sign stays with the number after it, as in the typst template ("§ 1331" is not split).
local function bind_signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}" or a.text == "\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- LaTeX for inline content (a list of inlines), trimmed.
local function latex(x)
  if x == nil then
    return ""
  end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(bind_signs(x)) }), "latex")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local cited = {} -- keys in order of first citation
local seen = {}

local function link_filter(el)
  local key = el.target:match("^toa:(.+)$")
  if not key then
    return nil
  end
  if not seen[key] then
    seen[key] = true
    cited[#cited + 1] = key
  end
  local out = { pandoc.RawInline("latex", "\\ca@toacite{" .. key .. "}{") }
  for _, x in ipairs(el.content) do
    out[#out + 1] = x
  end
  out[#out + 1] = pandoc.RawInline("latex", "}")
  return out
end

-- The six groups of the table of authorities, in order (as in the typst template).
local groups = {
  { kind = "case", title = "Cases:" },
  { kind = "constitution", title = "Constitutional Provisions:" },
  { kind = "statute", title = "Statutes:" },
  { kind = "regulation", title = "Regulations:" },
  { kind = "rule", title = "Rules:" },
  { kind = "other", title = "Other Authorities:" },
}

-- Same sort key as the typst template: lower case, letters, digits and spaces only.
local function sort_key(a)
  local s = a.sort and text(a.sort) or (text(a.name or "") .. " " .. text(a.cite))
  return s:lower():gsub("[^a-z0-9 ]", "")
end

local function toa_block(authorities)
  local out = {}
  for _, g in ipairs(groups) do
    local members = {}
    for _, key in ipairs(cited) do
      local a = authorities[key]
      if a and text(a.kind) == g.kind then
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
      out[#out + 1] = (#out == 0 and "\\ca@toagroupfirst{" or "\\ca@toagroup{") .. g.title .. "}"
      for _, m in ipairs(members) do
        local a = m.a
        local name = ""
        if a.name then
          name = latex(a.name)
          if g.kind == "case" then
            name = "\\emph{" .. name .. "},\\\\ "
          else
            name = name .. ",\\\\ "
          end
        end
        out[#out + 1] = "\\ca@toaline{" .. m.key .. "}{" .. name .. latex(a.cite) .. "}"
      end
    end
  end
  return table.concat(out, "\n")
end

-- Word count of the brief: whitespace-delimited words of the body text, footnote text included, footnote
-- reference marks and list markers not counted (FRAP 32(f) exclusions are left to the author).
local function words_in(s)
  s = s:gsub("\194\160", " ") -- pandoc makes the space after a section sign non-breaking; the source has a plain one
  local n = 0
  for _ in s:gmatch("%S+") do
    n = n + 1
  end
  return n
end

-- Each list item and quotation is counted on its own: stringify would run one item into the next.
local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        n = n + count_words(item)
      end
    elseif b.t == "BlockQuote" then
      n = n + count_words(b.content)
    else
      n = n + words_in(text(b))
      pandoc.Pandoc({ b }):walk({
        Note = function(note)
          n = n + count_words(note.content)
        end,
      })
    end
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

function Pandoc(doc)
  local body, add, in_add = {}, {}, false
  for _, b in ipairs(doc.blocks) do
    if not in_add and b.t == "Header" and b.level == 1 and text(b.content):lower() == "addendum" then
      in_add = true
    elseif in_add then
      add[#add + 1] = b
    else
      body[#body + 1] = b
    end
  end

  doc.meta.words_fmt = pandoc.MetaInlines({ pandoc.Str(group_digits(count_words(body))) })
  -- pandoc templates read `interest.for` as a keyword, so the template gets it as a flat field.
  if doc.meta.interest and doc.meta.interest["for"] then
    doc.meta.interest_for = doc.meta.interest["for"]
  end

  local function mark_arguments(blocks)
    local out, in_arg = {}, false
    for _, b in ipairs(blocks) do
      if b.t == "Header" and b.level == 1 then
        local title = text(b.content):lower()
        local is_arg = title == "argument" or title == "reply argument"
        if is_arg then
          out[#out + 1] = pandoc.RawBlock("latex", "\\ca@argtrue")
        elseif in_arg then
          out[#out + 1] = pandoc.RawBlock("latex", "\\ca@argfalse")
        end
        in_arg = is_arg
      end
      out[#out + 1] = b
    end
    return out
  end

  -- Link conversion runs over the body first, then the addendum, so `cited` keeps document order.
  local bodyd = pandoc.Pandoc(body):walk({ Link = link_filter, Inlines = bind_signs })
  local addd = pandoc.Pandoc(add):walk({ Link = link_filter, Inlines = bind_signs })

  local authorities = doc.meta.authorities or {}
  for _, key in ipairs(cited) do
    if not authorities[key] then
      error("cafc.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end

  -- Headings followed directly by another heading (`# Argument` and its first point heading) share a samepage
  -- group with it, so they never part at a page end.
  local keep = {}
  for i = 1, #bodyd.blocks - 1 do
    local a, b = bodyd.blocks[i], bodyd.blocks[i + 1]
    if a.t == "Header" and b.t == "Header" then
      keep[i] = true
    end
  end
  local joined = {}
  for i, b in ipairs(bodyd.blocks) do
    if keep[i] and not keep[i - 1] then
      joined[#joined + 1] = pandoc.RawBlock("latex", "\\begin{samepage}")
    end
    joined[#joined + 1] = b
    if keep[i - 1] and not keep[i] then
      joined[#joined + 1] = pandoc.RawBlock("latex", "\\end{samepage}")
    end
  end
  bodyd.blocks = joined

  -- The last paragraph of the brief and the signature block (added by the template) are one samepage group,
  -- so the signature never stands alone on a page. A heading or a footnote definition at the end is not kept.
  local last = bodyd.blocks[#bodyd.blocks]
  -- reply: the signature block (about 25 lines with three signers) is kept whole by the template (\needspace, minipage);
  -- the last paragraph is not joined to it, because the two do not fit on one page at 14 pt (see README).

  -- reply brief: the counsel groups two to a row, as the typst grid sets them
  do
    local cells = {}
    for _, g in ipairs(doc.meta.counsel or {}) do
      local lines = {}
      for _, n in ipairs(g.names or {}) do
        lines[#lines + 1] = latex(n)
      end
      for _, x in ipairs(g.lines or {}) do
        lines[#lines + 1] = latex(x)
      end
      cells[#cells + 1] = "\\raggedright " .. table.concat(lines, "\\\\\n")
    end
    local rows = {}
    for i = 1, #cells, 2 do
      rows[#rows + 1] = cells[i] .. (cells[i + 1] and (" & " .. cells[i + 1]) or "")
    end
    doc.meta.counsel_grid = pandoc.MetaBlocks({
      pandoc.RawBlock("latex", "\\begin{tabular}{@{}p{0.42\\linewidth}@{\\hspace{0.16\\linewidth}}p{0.42\\linewidth}@{}}\n" .. table.concat(rows, " \\\\[1em]\n") .. "\n\\end{tabular}"),
    })
  end
  doc.blocks = mark_arguments(bodyd.blocks)
  doc.meta.addendum = pandoc.MetaBlocks(addd.blocks)
  doc.meta.toa = pandoc.MetaBlocks({ pandoc.RawBlock("latex", toa_block(authorities)) })
  return doc
end

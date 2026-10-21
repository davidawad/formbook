-- cadc.lua: pandoc filter for the D.C. Circuit LaTeX template (latex/template.tex). Run by fb render.
--
-- What it does, and nothing more (layout lives in template.tex):
--   1. Splits the brief at `# Addendum` (the heading is dropped): the rest goes to meta `addendum`.
--   2. Counts the words of the body (footnote text included, addendum excluded) and stops the build over the
--      limit, as the typst template does. Meta `words_fmt` is the count with commas.
--   3. Turns every link whose target is `toa:KEY` into \dc@toacite{KEY}{text}: the text is set as written and the
--      page where the citation starts goes to the aux file (template.tex). A key not in `authorities:` stops the build.
--   4. Builds the table of authorities in the six groups of the typst template (cases first, cited keys only,
--      meta `toa`). Page numbers come from the aux file, read back in the next pass.

local WORD_LIMIT = 13000

local function stringify(x)
  return pandoc.utils.stringify(x)
end

-- A meta value as LaTeX: a plain string, inlines or blocks. Trimmed.
local function tex(v)
  if v == nil then
    return ""
  end
  local blocks
  if type(v) == "string" then
    blocks = pandoc.read(v, "markdown").blocks
  elseif v.t == "MetaBlocks" then
    blocks = v
  else
    blocks = { pandoc.Plain(v) }
  end
  local s = pandoc.write(pandoc.Pandoc(blocks), "latex")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
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
    for _ in stringify(bare.blocks):gmatch("%S+") do
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

-- The six groups of the table of authorities, in the typst template's order.
local groups = {
  { kind = "case", title = "Cases" },
  { kind = "constitution", title = "Constitutional Provisions" },
  { kind = "statute", title = "Statutes" },
  { kind = "regulation", title = "Regulations" },
  { kind = "rule", title = "Rules" },
  { kind = "other", title = "Other Authorities" },
}

local function toa_blocks(authorities, cited)
  local out = {}
  for _, g in ipairs(groups) do
    local members = {}
    for key in pairs(cited) do
      local a = authorities[key]
      if a and stringify(a.kind) == g.kind then
        local sort = a.sort or a.name or a.cite
        members[#members + 1] = { key = key, a = a, sort = stringify(sort) }
      end
    end
    if #members > 0 then
      table.sort(members, function(p, q)
        if p.sort == q.sort then
          return p.key < q.key
        end
        return p.sort < q.sort
      end)
      out[#out + 1] = pandoc.RawBlock("latex", "\\dc@toagroup{" .. g.title .. "}")
      for _, m in ipairs(members) do
        local a = m.a
        local line = tex(a.cite)
        if a.name then
          local name = tex(a.name)
          if g.kind == "case" then
            line = "\\emph{" .. name .. "}, " .. line
          else
            line = name .. ", " .. line
          end
        end
        out[#out + 1] = pandoc.RawBlock("latex", "\\dc@toaline{" .. m.key .. "}{" .. line .. "}")
      end
    end
  end
  return out
end

function Pandoc(doc)
  local authorities = doc.meta.authorities or {}
  local cited = {}
  local seen_missing = {}

  -- Every citation: the registry key is recorded; the text is set as written.
  local doc2 = pandoc.Pandoc(doc.blocks, doc.meta):walk({
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
    if b.t == "Header" and b.level == 1 and stringify(b.content) == "Addendum" then
      target = add
    else
      target[#target + 1] = b
    end
  end

  local words = count_words(body)
  if words > WORD_LIMIT then
    error("cadc.lua: body is " .. words .. " words; the limit is " .. WORD_LIMIT)
  end
  doc2.meta.words_fmt = pandoc.MetaInlines({ pandoc.Str(group_digits(words)) })
  doc2.meta.toa = pandoc.MetaBlocks(toa_blocks(authorities, cited))
  doc2.meta.addendum = pandoc.MetaBlocks(add)
  return pandoc.Pandoc(body, doc2.meta)
end

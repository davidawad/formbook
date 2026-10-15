-- cadc.lua: pandoc filter for the D.C. Circuit reply-brief LaTeX template (latex/template.tex). Run by latex/render.sh.
--
-- What it does, and nothing more (layout lives in template.tex):
--   1. Takes the word count from meta `words` (render.sh computes it as typst does, from the source) and stops the
--      build over the reply limit, FRAP 28.1(e)(2)(C). Meta `words_fmt` is the count with commas.
--   2. Turns every link whose target is `toa:KEY` into \dc@toacite{KEY}{text}: the text is set as written and the
--      page where the citation starts goes to the aux file (template.tex). A key not in `authorities:` stops the build.
--   3. Builds the table of authorities in the six groups of the typst template (cases first, cited keys only,
--      sorted as the typst sort key; meta `toa`). Page numbers come from the aux file, read back in the next pass.
--   4. Before each level-1 heading writes \dc@setarg{1} if the heading is "Argument" (it sets the heading labels),
--      else \dc@setarg{0}.
--   5. Keeps the last block of the brief with the signature block (meta `tail`), as the typst template does.
--   6. Adds the telephone number to the last counsel group (typst: the phone is the last line of the counsel block).

local WORD_LIMIT = 6500

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

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
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

-- typst's sort-key: the sort field, else name and citation; lower case, letters, digits and spaces only.
local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function toa_blocks(authorities, cited)
  local out = {}
  for _, g in ipairs(groups) do
    local members = {}
    for key in pairs(cited) do
      local a = authorities[key]
      if a and stringify(a.kind) == g.kind then
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
      out[#out + 1] = pandoc.RawBlock("latex", "\\dc@toagroup{" .. g.title .. "}")
      for _, m in ipairs(members) do
        local a = m.a
        local content = tex(a.cite)
        if a.name then
          local name = tex(a.name)
          if g.kind == "case" then
            name = "\\emph{" .. name .. "}"
          end
          content = name .. ", " .. content
        end
        out[#out + 1] = pandoc.RawBlock("latex", "\\dc@toaline{" .. m.key .. "}{" .. content .. "}")
      end
    end
  end
  return out
end

local function is_argument(h)
  return stringify(h.content):lower():match("^%s*(.-)%s*$") == "argument"
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

  -- Level-1 headings: the argument flag goes before each one (heading labels depend on it).
  local body = {}
  for _, b in ipairs(doc2.blocks) do
    if b.t == "Header" and b.level == 1 then
      body[#body + 1] = pandoc.RawBlock("latex", is_argument(b) and "\\dc@setarg{1}" or "\\dc@setarg{0}")
    end
    if b.t ~= "Header" then
      body[#body + 1] = pandoc.RawBlock("latex", "\\dc@afterheadfalse")
    end
    body[#body + 1] = b
  end

  local words = tonumber(stringify(doc.meta.words or ""))
  if not words then
    error("cadc.lua: no word count; render.sh passes it as meta `words`")
  end
  if words > WORD_LIMIT then
    error("cadc.lua: the brief is " .. words .. " words; FRAP 28.1(e)(2)(C) allows " .. WORD_LIMIT .. " for a reply")
  end

  -- The last block stays with the signature block, unless it is a heading.
  local tail = {}
  local last = body[#body]
  if last and last.t ~= "Header" and last.t ~= "RawBlock" then
    tail = { last }
    body[#body] = nil
  end

  local meta = doc2.meta
  meta.words_fmt = pandoc.MetaInlines({ pandoc.Str(group_digits(words)) })
  meta.toa = pandoc.MetaBlocks(toa_blocks(authorities, cited))
  meta.tail = pandoc.MetaBlocks(tail)
  local cs = meta.counsel
  if cs and #cs > 0 and meta.phone then
    local g = cs[#cs]
    if g.lines == nil then
      g.lines = pandoc.MetaList({})
    end
    table.insert(g.lines, meta.phone)
  end
  return pandoc.Pandoc(body, meta)
end

-- ca9.lua: pandoc filter for the ca9 reply-brief LaTeX template (latex/template.tex). Run by fb render.
-- Copied from ../../latex/ca9.lua (the principal brief) with the reply brief's word limit and the counsel telephone
-- of each group (the last group takes the brief's `phone` when it has none, as the typst cover does).
--
-- What it does, and nothing more (layout lives in template.tex):
--   1. Splits the document at `# Addendum`: the body stays in the body, the rest goes to meta `addendum`.
--   2. Marks the Argument for the heading macros: \ca@argtrue before `# Argument`, \ca@argfalse before any
--      other level-1 heading, so level-2 to level-5 headings get the Argument's labels (CA9-CONT-012).
--   3. Turns every link whose target is `toa:KEY` into \ca@toacite{KEY}{text}: the text is set as written and
--      the page where the citation starts is recorded in the aux file (template.tex, \ca@toahit).
--   4. Builds the table of authorities from the `authorities:` registry, in the six groups of the template,
--      cases alphabetized, only the authorities the body cites (meta `toa`). Page numbers come from the aux file.
--
-- A link to a key that is not in `authorities:` stops the build, as in the typst template.

local function text(x)
  return pandoc.utils.stringify(x)
end

-- Cross-engine line breaking (docs/EVAL-LOOP.md, "Cross-engine gate"): the shared inline rules of the layout model
-- (lib/latex/xengine.lua: ligature characters as commands, break opportunities as typst and Word have them, a section
-- sign bound to its number), run over the body and over every metadata value the template sets.
local xe_inlines = require("latex.xengine").inlines

-- An ellipsis (U+2026) as typst and Word set it: Times New Roman's one glyph, 1 em wide, its three dots spread across it.
-- T1 newtx has no such glyph, and \ldots would put three periods into the PDF text; the dots are set in a 1 em box
-- marked with the character as its text (ActualText), so the text reads as the other engines'.
local ELLIPSIS = "\\pdfliteral page{/Span<</ActualText<FEFF2026>>>BDC}\\makebox[1em][s]{\\hfil.\\hfil.\\hfil.\\hfil}"
  .. "\\pdfliteral page{EMC}"
local function inlines_filter(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(xe_inlines(l)) do
    if el.t == "Str" and el.text:find("\u{2026}", 1, true) then
      local s = el.text
      while true do
        local i, j = s:find("\u{2026}", 1, true)
        if not i then break end
        if i > 1 then out:insert(pandoc.Str(s:sub(1, i - 1))) end
        out:insert(pandoc.RawInline("latex", ELLIPSIS))
        s = s:sub(j + 1)
      end
      if s ~= "" then out:insert(pandoc.Str(s)) end
    else
      out:insert(el)
    end
  end
  return out
end

-- LaTeX for inline content (a meta value or a list of inlines), trimmed.
local function latex(x)
  if x == nil then
    return ""
  end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines_filter(x)) }), "latex")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local LIMIT = 7000 -- Cir. R. 32-1(b): a reply brief may not exceed half of 14,000 words

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

-- The six groups of the table of authorities, in order (Circuit Rule 28-2.6 style; grouping per exemplar).
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

-- The sort keys, from the metadata as written: the inline rules bind a section sign to its number with a no-break
-- space, which the key drops, so "10 U.S.C. § 12406" would sort after "10 U.S.C. §§ 251-255" (typst and docx sort the plain text).
local sort_keys = {}

local function toa_block(authorities)
  local out = {}
  for _, g in ipairs(groups) do
    local members = {}
    for _, key in ipairs(cited) do
      local a = authorities[key]
      if a and text(a.kind) == g.kind then
        members[#members + 1] = { key = key, a = a, sort = sort_keys[key] or sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(p, q)
        if p.sort == q.sort then
          return p.key < q.key
        end
        return p.sort < q.sort
      end)
      out[#out + 1] = "\\ca@toagroup{" .. g.title .. "}"
      for _, m in ipairs(members) do
        local a = m.a
        local name = ""
        if a.name then
          name = latex(a.name)
          -- [toa-section]: the name, a comma, and the citation on the next line
          if g.kind == "case" then
            name = "\\emph{" .. name .. "},\\newline "
          else
            name = name .. ",\\newline "
          end
        end
        out[#out + 1] = "\\ca@toaline{" .. m.key .. "}{" .. name .. latex(a.cite) .. "}"
      end
    end
  end
  return table.concat(out, "\n")
end

-- Word count of the brief (CA9-LEN-001, CA9-CERT-002): whitespace-delimited words of the body text, footnote text
-- included, footnote reference marks and list markers not counted, the addendum excluded.
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

local function meta_text(v, default)
  if v == nil then
    return default
  end
  return text(v)
end

-- Flags the template tests with $if(...)$: one per Form 8 box, per Form 17 box, and the service certificate.
local function derive_flags(meta)
  local basis = meta_text(meta.word_limit_basis, "standard")
  local function flag(name, on)
    meta[name] = pandoc.MetaBool(on and true or false)
  end
  for _, k in ipairs({ "standard", "cross-appeal", "amicus", "death-penalty", "longer-joint", "longer-multiple",
    "longer-response-to-joint", "court-order", "motion-to-exceed" }) do
    flag("basis_" .. k:gsub("-", "_"), basis == k)
  end
  flag("basis_longer", basis == "longer-joint" or basis == "longer-multiple" or basis == "longer-response-to-joint")
  local status = meta.related_cases and meta_text(meta.related_cases.status, "none") or "none"
  flag("rc_none", status == "none")
  flag("rc_other_briefs", status == "other-briefs")
  flag("rc_pending", status == "pending")
  local svc = meta.service and meta.service.certificate
  flag("service_certificate", svc == true or (svc ~= nil and text(svc) == "true"))
  if meta.manual_image_words == nil then
    meta.manual_image_words = pandoc.MetaInlines({ pandoc.Str("0") })
  end
  if meta.court_order_date == nil then
    meta.court_order_date = pandoc.MetaInlines({ pandoc.Str("__________") })
  end
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

  -- metadata the template sets (cover, signature, certificates) breaks like the body
  for key, a in pairs(doc.meta.authorities or {}) do sort_keys[key] = sort_key(a) end
  doc.meta = pandoc.Pandoc({}, doc.meta):walk({ Inlines = inlines_filter }).meta
  local words = count_words(body)
  if words > LIMIT then
    error("ca9.lua: the brief has " .. words .. " words; Cir. R. 32-1(b) allows " .. LIMIT)
  end
  local groups = doc.meta.counsel
  if groups and #groups > 0 and groups[#groups].phone == nil then
    groups[#groups].phone = doc.meta.phone
  end
  doc.meta.words_fmt = pandoc.MetaInlines({ pandoc.Str(group_digits(words)) })
  derive_flags(doc.meta)

  local function mark_arguments(blocks)
    local out, in_arg = {}, false
    for _, b in ipairs(blocks) do
      if b.t == "Header" and b.level == 1 then
        local is_arg = text(b.content):lower() == "argument"
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
  local bodyd = pandoc.Pandoc(body):walk({ Link = link_filter, Inlines = inlines_filter })
  local addd = pandoc.Pandoc(add):walk({ Link = link_filter, Inlines = inlines_filter })

  local authorities = doc.meta.authorities or {}
  for _, key in ipairs(cited) do
    if not authorities[key] then
      error("ca9.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end

  -- Block quotations: 14 bp between their paragraphs (typst: the quote's paragraph spacing), as the template's
  -- quote environment sets above and below them.
  local function quote_seps(d)
    return d:walk({
      BlockQuote = function(q)
        local out = {}
        for i, b in ipairs(q.content) do
          if i > 1 then out[#out + 1] = pandoc.RawBlock("latex", "\\ca@qsep") end
          out[#out + 1] = b
        end
        q.content = out
        return q
      end,
    })
  end
  bodyd = quote_seps(bodyd)
  addd = quote_seps(addd)
  -- The signature never stands alone: the brief's last paragraph cannot be broken across pages and is kept with
  -- the signature block (typst: the last paragraph and the signature in one unbreakable block; Word: keep with
  -- next). Headings keep with what follows by their own penalties (template.tex).
  local n = #bodyd.blocks
  if n > 0 and bodyd.blocks[n].t == "Para" then
    table.insert(bodyd.blocks, n, pandoc.RawBlock("latex", "\\begingroup\\interlinepenalty=10000\\relax"))
    table.insert(bodyd.blocks, pandoc.RawBlock("latex", "\\par\\endgroup"))
  end
  doc.blocks = mark_arguments(bodyd.blocks)
  doc.meta.addendum = pandoc.MetaBlocks(addd.blocks)
  doc.meta.toa = pandoc.MetaBlocks({ pandoc.RawBlock("latex", toa_block(authorities)) })
  return doc
end

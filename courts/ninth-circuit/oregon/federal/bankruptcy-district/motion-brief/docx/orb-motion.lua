-- Motion with memorandum, docx engine (docs/DOCX.md). Mirrors typst/orb-motion-brief.typ: the cover and the ruled
-- caption (docx/lib/orb-common.lua) with the body following on page 1, the LBR 9013-1(b)(2) notice when the sample
-- has one, unnumbered body paragraphs (the first-line indent), "~" paragraphs without the indent, numbered list items
-- (1., 2., ...), headings, the last chunk kept with the date and the signature block, and the certificate of service
-- on its own page. The footer and the section are the filter's (orb-common furniture()); no shell (were
-- docx/build-reference.sh and render.sh).
local DIR = PANDOC_SCRIPT_FILE:match("^(.*)[/\\]") or "."
local C = dofile(DIR .. "/lib/orb-common.lua")
local xe = C.xe

-- The body blocks, in the order and with the styles of the typst body-text(); keep_at: the index of the block kept
-- with the signature; brk: the first block opens a page.
local function body(blocks, out, state, keep_at, brk)
  for i, b in ipairs(blocks) do
    local keep = i == keep_at
    if b.t == "Header" then
      out:insert(C.heading(b.level, b.content, false, brk and xe.BREAK or nil))
    elseif b.t == "Para" or b.t == "Plain" then
      local t = C.tilde(b)
      if t then
        out:insert(C.para(t, "Body Flush", nil, keep, brk))
      else
        out:insert(C.para(b.content, "Body Text", nil, keep, brk))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        state.item = state.item + 1
        local first = item[1]
        if #item ~= 1 or (first.t ~= "Para" and first.t ~= "Plain") then
          error("orb-motion.lua: a list item must be one paragraph")
        end
        out:insert(C.para(first.content, "Body Numbered", state.item .. ".", keep and k == #b.content, brk and k == 1))
      end
    else
      error("orb-motion.lua: unsupported block " .. b.t)
    end
    brk = false
  end
end

-- a meta value written as markdown (pandoc has read it as blocks)
local function blocks_of(v)
  if v == nil then return {} end
  local ty = pandoc.utils.type(v)
  if ty == "Blocks" then return v end
  if ty == "Inlines" then return { pandoc.Para(v) } end
  return pandoc.read(pandoc.utils.stringify(v), "commonmark+smart").blocks
end

local function finish(doc)
  local meta = doc.meta
  local more = {}
  if meta.hearing then
    more[#more + 1] = { xe.runs("DATE OF HEARING: ") .. xe.inl(meta.hearing.date),
      xe.runs("TIME OF HEARING: ") .. xe.inl(meta.hearing.time) }
  end

  local out = pandoc.Blocks({})
  -- the body follows on page 1 under a blank double line (typst v(blank))
  out:insert(xe.raw(C.cover(meta, C.caption_right(meta, more)) .. C.p("", { line = C.BLANK })))

  local state = { item = 0 }
  if meta.notice then body(blocks_of(meta.notice), out, state) end
  body(doc.blocks, out, state, C.last_block(doc.blocks))
  out:insert(xe.raw(C.signature(meta)))
  if meta.certificate then body(blocks_of(meta.certificate), out, state, nil, true) end

  C.furniture()
  -- The frontmatter was consumed above; pandoc would otherwise write its title block at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = C.break_rules, Inlines = C.bind_spaces }, { Pandoc = finish } }

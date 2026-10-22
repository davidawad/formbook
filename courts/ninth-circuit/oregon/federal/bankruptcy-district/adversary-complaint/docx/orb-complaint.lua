-- Adversary complaint, docx engine (docs/DOCX.md). Mirrors typst/orb-adversary-complaint.typ: the cover and the ruled
-- caption (docx/lib/orb-common.lua), a page break, the lead-in, numbered allegations (FRCP 10(b) through FRBP 7010; the
-- number is typed, as the typst counter does), headings, unnumbered "~" paragraphs (the WHEREFORE lead-in), lettered
-- prayer items (A., B., ...), the last of them kept with the date and the signature block. The footer and the
-- section are the filter's (orb-common furniture()); no shell (were docx/build-reference.sh and render.sh).
local DIR = PANDOC_SCRIPT_FILE:match("^(.*)[/\\]") or "."
local C = dofile(DIR .. "/lib/orb-common.lua")
local xe = C.xe
local LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function finish(doc)
  local meta = doc.meta
  local more = {}
  if meta.subtitle then more[#more + 1] = { xe.inl(meta.subtitle) } end
  if meta.jury_demand then more[#more + 1] = { xe.runs("DEMAND FOR JURY TRIAL") } end

  local out = pandoc.Blocks({})
  out:insert(xe.raw(C.cover(meta, C.caption_right(meta, more))))
  -- the body opens page 2 (typst pagebreak()): the break goes with its first block
  local brk = true
  if meta.lead_in then out:insert(C.para(meta.lead_in, "Body Text", nil, false, true)); brk = false end

  local last = C.last_block(doc.blocks)
  local n, letter = 0, 0
  for i, b in ipairs(doc.blocks) do
    local keep = i == last
    if b.t == "Header" then
      out:insert(C.heading(b.level, b.content, true, brk and xe.BREAK or nil))
    elseif b.t == "Para" or b.t == "Plain" then
      local t = C.tilde(b)
      if t then
        out:insert(C.para(t, "Body Text", nil, keep, brk))
      else
        n = n + 1
        out:insert(C.para(b.content, "Body Numbered", n .. ".", keep, brk))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        letter = letter + 1
        local first = item[1]
        if #item ~= 1 or (first.t ~= "Para" and first.t ~= "Plain") then
          error("orb-complaint.lua: a prayer item must be one paragraph")
        end
        out:insert(C.para(first.content, "Body Numbered", LETTERS:sub(letter, letter) .. ".", keep and k == #b.content,
          brk and k == 1))
      end
    else
      error("orb-complaint.lua: unsupported block " .. b.t)
    end
    brk = false
  end
  out:insert(xe.raw(C.signature(meta)))

  C.furniture()
  -- The frontmatter was consumed above; pandoc would otherwise write its title block at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = C.break_rules, Inlines = C.bind_spaces }, { Pandoc = finish } }

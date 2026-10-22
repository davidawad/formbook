-- waed motion with memorandum, docx engine. Mirrors typst/waed-motion-brief.typ (LCivR 7(b)(1), 7(i)(1), 10(a),
-- 10(d)); rules and conventions are in ../README.md. The cover (counsel, the court's name, the caption with the
-- hearing), the table of contents, the headings, the memorandum (not numbered), the signature block and the
-- certificate of service on its own page are built here as WordprocessingML; the pleading paper (numbered lines,
-- rules, the footer with the title and page number) and the cover's blocks are docx/lib/pleading.lua. Font, size and
-- the paragraph styles are docx/reference.xml (fb render builds the reference document from it). Content-agnostic:
-- every case-specific word comes from the sample's frontmatter, never from this file.
--
-- The contents' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this
-- filter writes ($FORMBOOK_NEEDLES: each listed heading with the words after it, in document order) in the
-- LibreOffice PDF and passes their pages back ($FORMBOOK_PAGES) until they settle (were docx/render.sh and
-- toc-pagemap.awk). Pages are numbered from 1 through the whole filing (LCivR 10(a)(2)).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (640 twips a numbered line, 320 a single line), and the break rules of typst
-- on every run.

local xe = require("docx.xengine")
local P = dofile(PANDOC_SCRIPT_FILE:match("^(.*/)") .. "lib/pleading.lua")
local BODY = P.BODY
local stringify = pandoc.utils.stringify
P.set_face(1229)                         -- Liberation Mono: every advance 1229/2048 em (the typst face)

local TOC_TAB = 864                      -- typst toc-tab 0.6 in
local TOC_COL = 720                      -- typst toc-col 0.5 in
local NEEDLE_MAX = 60

local function txt(v) return P.txt(v) end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function needle(id, text, context)
  local n = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  -- no shorter fallback: the heading alone would be found in the contents
  needles[#needles + 1] = table.concat({ id, "B", n, n }, "\t")
end

local pages = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, page = l:match("^([^\t]+)\t([^\t]*)\t")
    if id then pages[id] = page end
  end
  f:close()
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function upper(c)
  return c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- Headings (typst heading-block): bold at the margin on the numbered lines, kept with the next block; level 1 in
-- capitals, level 3 bold italic.
local function heading(level, c, brk)
  if level == 1 then c = upper(c) end
  return P.p(xe.inl(c, { b = true, i = level >= 3 }),
    { style = "Heading" .. level, keep = true, brk = brk, line = BODY })
end

-- A heading's label ("I.", "A.", "1.") and the rest of its title, as typst label-re splits them.
local function split_label(c)
  local first = c[1]
  if first and first.t == "Str" and c[2] and c[2].t == "Space" then
    local t = first.text
    if t:match("^[IVXLC]+%.$") or t:match("^[A-Z]%.$") or t:match("^%d+%.$") then
      local rest = pandoc.Inlines({})
      for i = 3, #c do rest:insert(c[i]) end
      return t, rest
    end
  end
  return "", c
end

-- The table of contents (typst contents): the title, a blank numbered line, one row a numbered line per heading of
-- levels 1 and 2: the label in its box, the title wrapping before the page column, a dot leader to the page.
local function contents(entries)
  local out = { P.p(xe.runs("TABLE OF CONTENTS", { b = true }), { brk = true, line = BODY, after = BODY, jc = "center" }) }
  for _, e in ipairs(entries) do
    local lab, rest = split_label(e.title)
    if e.level == 1 then rest = upper(rest) end
    local ind = (e.level - 1) * TOC_TAB
    out[#out + 1] = P.p(xe.runs(lab .. "\t") .. xe.inl(rest) .. xe.runs(xe.LEAD) .. xe.runs(pages[e.id] or "0"),
      { line = BODY, tabs = xe.leader_tab(P.TEXTW), left = ind + TOC_TAB, hanging = TOC_TAB, right = TOC_COL })
  end
  return table.concat(out)
end

-- The body blocks as paragraphs; brk: the first starts a page.
local function body(blocks, entries, outlined, brk)
  local out = {}
  for i, b in ipairs(blocks) do
    local br = brk and i == 1
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      if outlined and level <= 2 then
        local id = "H:" .. (#entries + 1)
        local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
        local head = level == 1 and stringify(b.content):upper() or stringify(b.content)
        needle(id, head, nxt)
        entries[#entries + 1] = { id = id, level = level, title = b.content }
      end
      out[#out + 1] = heading(level, b.content, br)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = xe.para({ xe.style("BodyText"), br and xe.BREAK or "" }, xe.inl(b.content))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        out[#out + 1] = xe.para({ xe.style("ListLetter"), (br and k == 1) and xe.BREAK or "" },
          xe.runs(string.char(64 + k) .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)))
      end
    else
      error("motion-brief.lua: unsupported block " .. b.t)
    end
  end
  return out
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  P.furniture()

  -- the cover: counsel, the court's name single spaced, the caption with the hearing (LCivR 7(i)(1))
  local x = { P.counsel(P.items(m.counsel)), P.court(m.division, true) }
  local right = { "Case No. " .. txt(m.case_number), m.brief_title }
  local bold, gaps = { [2] = true }, { [2] = true }
  if m.hearing then
    gaps[#right + 1] = true
    right[#right + 1] = "Hearing date: " .. txt(m.hearing.date)
    if m.hearing.type then right[#right + 1] = m.hearing.type end
    if m.hearing.judge then right[#right + 1] = m.hearing.judge end
  end
  x[#x + 1] = P.caption(m.caption.parties, right, bold, gaps)

  -- the memorandum, then the certificate of service (not listed) on its own page after the signature block
  local main, cert = {}, nil
  for _, b in ipairs(doc.blocks) do
    if not cert and b.t == "Header" and b.level == 1 and stringify(b.content):upper() == "CERTIFICATE OF SERVICE" then
      cert = {}
    end
    if cert then cert[#cert + 1] = b else main[#main + 1] = b end
  end
  -- the table of contents on a page of its own between the cover and the memorandum
  local entries = {}
  local text = body(main, entries, true, m.toc and true or false)
  if m.toc then x[#x + 1] = contents(entries) end
  for _, s in ipairs(text) do x[#x + 1] = s end

  local sig = m.signature
  local lines = { "Respectfully submitted," }
  local firm = P.items(sig.firm)
  for _, l in ipairs(firm) do lines[#lines + 1] = l end
  lines[#lines + 1] = "By s/" .. txt(sig.signer)
  for _, l in ipairs(P.items(sig.lines)) do lines[#lines + 1] = l end
  x[#x + 1] = P.p("", { line = P.SINGLE })
  x[#x + 1] = P.signature("DATED " .. txt(m.date), lines, { 2, 2 + #firm })
  if cert then
    for _, s in ipairs(body(cert, entries, false, true)) do x[#x + 1] = s end
  end

  P.write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { P.inline_filter, { Pandoc = finish } }

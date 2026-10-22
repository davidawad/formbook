-- waed complaint, docx engine. Mirrors typst/waed-complaint.typ (LCivR 10(a), 10(d); Fed. R. Civ. P. 10(a), (b));
-- rules and conventions are in ../README.md. The cover (counsel, the court's name, the caption), the headings, the
-- numbered allegations (Fed. R. Civ. P. 10(b)), the lettered relief items and the signature block are built here as
-- WordprocessingML; the pleading paper (numbered lines, rules, the footer with the title and page number) and the
-- cover's blocks are docx/lib/pleading.lua. Font, size and the paragraph styles are docx/reference.xml (fb render
-- builds the reference document from it). Numbers and letters are typed text, as the typst template types them.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (640 twips a numbered line, 320 a single line), and the break rules of typst
-- on every run.

local xe = require("docx.xengine")
local P = dofile(PANDOC_SCRIPT_FILE:match("^(.*/)") .. "lib/pleading.lua")
local BODY = P.BODY

local function txt(v) return P.txt(v) end

-- Headings (typst heading-block): one numbered line each, kept with the next block; level 1 centred bold capitals,
-- level 2 centred bold, level 3 bold italic at the margin.
local function heading(b)
  local level = math.min(b.level, 3)
  local c = b.content
  if level == 1 then c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end }) end
  return P.p(xe.inl(c, { b = true, i = level >= 3 }),
    { style = "Heading" .. level, keep = true, line = BODY, jc = level >= 3 and "left" or "center" })
end

local function body(blocks)
  local out, n = {}, 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = xe.para({ xe.style("NumberedParagraph") }, xe.runs(n .. ".\t") .. xe.inl(b.content))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        out[#out + 1] = xe.para({ xe.style("ListLetter") },
          xe.runs(string.char(64 + k) .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)))
      end
    else
      error("complaint.lua: unsupported block " .. b.t)
    end
  end
  return out
end

local function finish(doc)
  local m = doc.meta
  P.furniture()
  local x = { P.counsel(P.items(m.counsel)), P.court(m.division) }
  local right = { "Case No. " .. txt(m.case_number), m.brief_title }
  local bold, gaps = { [2] = true }, { [2] = true }
  if m.jury_demand then
    right[#right + 1] = "DEMAND FOR JURY TRIAL"
    bold[3], gaps[3] = true, true
  end
  x[#x + 1] = P.caption(m.caption.parties, right, bold, gaps)
  for _, s in ipairs(body(doc.blocks)) do x[#x + 1] = s end

  -- the signature block, a blank single line below the text
  local sig = m.signature
  local lines = { "Respectfully submitted," }
  local firm = P.items(sig.firm)
  for _, l in ipairs(firm) do lines[#lines + 1] = l end
  lines[#lines + 1] = "/s/ " .. txt(sig.signer)
  lines[#lines + 1] = sig.signer
  for _, l in ipairs(P.items(sig.lines)) do lines[#lines + 1] = l end
  x[#x + 1] = P.p("", { line = P.SINGLE })
  x[#x + 1] = P.signature("DATED " .. txt(m.date), lines, { 2, 2 + #firm })
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { P.inline_filter, { Pandoc = finish } }

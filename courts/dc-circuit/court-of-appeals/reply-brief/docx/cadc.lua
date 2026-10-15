-- cadc.lua: pandoc filter for the D.C. Circuit reply-brief DOCX engine (docx/reference.docx). Run by the pandoc
-- command in docs/EVAL-LOOP.md ("Engines"): pandoc --reference-doc=docx/reference.docx --lua-filter=docx/cadc.lua.
--
-- What it does, and nothing more (the page layout and styles live in reference.docx):
--   1. Heading labels, as the typst and LaTeX templates print them: under "Argument" I. / A. / 1. / a.; elsewhere
--      A. / 1. / a. / (1). Level 1 is unnumbered. The label is a run, a tab, then the heading text (the tab stop is in
--      the Heading 2 to 5 styles of reference.docx).
--   2. Every link whose target is `toa:KEY` is unwrapped to its text (a Word hyperlink to "toa:KEY" is not a link).
--      A key not in `authorities:` stops the build.
-- Not done here (see docs/DOCX.md and ../README.md "Engines"): the cover, the table of contents and authorities, and
-- the certificates are not generated in the .docx; the word limit is checked by typst and LaTeX only.

local function stringify(x)
  return pandoc.utils.stringify(x)
end

local function is_argument(h)
  return stringify(h.content):lower():match("^%s*(.-)%s*$") == "argument"
end

local counts = { 0, 0, 0, 0, 0, 0 }
local in_arg = false

-- Roman and letter labels, as the typst template (heading-label): under "Argument" I. / A. / 1. / a.;
-- elsewhere A. / 1. / a. / (1).
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
local function letter(n)
  return string.char(64 + n)
end
local function lower_letter(n)
  return string.char(96 + n)
end
local function heading_label(level)
  local n = counts[level]
  if in_arg then
    if level == 2 then return (ROMAN[n] or tostring(n)) .. "." end
    if level == 3 then return letter(n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    if level == 5 then return lower_letter(n) .. "." end
  else
    if level == 2 then return letter(n) .. "." end
    if level == 3 then return tostring(n) .. "." end
    if level == 4 then return lower_letter(n) .. "." end
    if level == 5 then return "(" .. tostring(n) .. ")" end
  end
  error("cadc.lua: headings deeper than level 5 are not supported")
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

function Pandoc(doc)
  local authorities = doc.meta.authorities or {}
  local seen_missing = {}
  local blocks = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      in_arg = is_argument(b)
      for i = 2, 5 do
        counts[i] = 0
      end
    elseif b.t == "Header" and b.level >= 2 and b.level <= 5 then
      counts[b.level] = counts[b.level] + 1
      for i = b.level + 1, 5 do
        counts[i] = 0
      end
      local content = pandoc.List({ pandoc.Str(heading_label(b.level)), TAB })
      content:extend(b.content)
      b.content = content
    end
    blocks[#blocks + 1] = b
  end
  local doc2 = pandoc.Pandoc(blocks, doc.meta):walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then
        return nil
      end
      if authorities[key] == nil and not seen_missing[key] then
        seen_missing[key] = true
        error("cadc.lua: cited authority `" .. key .. "` is not in the authorities registry")
      end
      return el.content
    end,
  })
  return doc2
end

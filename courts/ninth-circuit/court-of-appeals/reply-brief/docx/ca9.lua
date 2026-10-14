-- ca9.lua (docx engine): what the Word output adds to pandoc's default conversion, in the form of
-- docs/DOCX.md "Use the Word-native feature when one exists":
--   * heading labels as the typst template prints them (I., A., 1., a. in the Argument; A., 1., a., (1)
--     elsewhere), before the heading text, so the outline numbering reads the same;
--   * table-of-authorities links (toa:...) shown as their text: no TA/TOA fields are built (BLOCKED, see README).
-- The cover, the tables of contents and authorities, the statement of related cases and the certificates
-- are not built for docx yet (BLOCKED, see README "Engines").
local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function label(level, n, in_arg)
  if in_arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    return string.char(96 + n) .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

local in_arg = false
local counts = { 0, 0, 0, 0, 0, 0 }

function Header(el)
  if el.level > 5 then error("ca9.lua: headings deeper than level 5 are not supported") end
  counts[el.level] = counts[el.level] + 1
  for k = el.level + 1, 6 do counts[k] = 0 end
  if el.level == 1 then
    in_arg = pandoc.utils.stringify(el.content):lower():match("^%s*(.-)%s*$") == "argument"
    return el
  end
  local lab = label(el.level, counts[el.level], in_arg)
  if in_arg and el.level == 2 then lab = roman(counts[2]) .. "." end
  table.insert(el.content, 1, pandoc.Space())
  table.insert(el.content, 1, pandoc.Str(lab))
  return el
end

function Link(el)
  if el.target:sub(1, 4) == "toa:" then return el.content end
  return nil
end

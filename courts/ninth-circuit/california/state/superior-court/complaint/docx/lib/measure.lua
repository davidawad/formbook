-- docx/lib/measure.lua: how many lines a run of text takes in a column, from the advances of the vendored face (the
-- typst template sets Liberation Serif, the metric twin of the Times New Roman the docx names), broken first fit at
-- spaces as typst ("simple") and LibreOffice break ragged text, with no kerning (lib/typst/xengine.typ sets none).
-- Word cannot place a paragraph on the next numbered line of the pleading paper after a block whose height it
-- alone knows (the caption's party column wraps), so the filter counts that block's lines itself and sets the space
-- after it; the typst template measures the same space from its own layout.
--   local measure = dofile(<docx dir> .. "/lib/measure.lua")
--   measure.lines(text, width_pt, size_pt, face)   face: "regular" | "bold" | "italic" | "bolditalic"
local M = {}

local FILES = {
  regular = "LiberationSerif-Regular.ttf",
  bold = "LiberationSerif-Bold.ttf",
  italic = "LiberationSerif-Italic.ttf",
  bolditalic = "LiberationSerif-BoldItalic.ttf",
}

-- The repo root: fb render puts <root>/lib/?.lua first on LUA_PATH.
local function root()
  for entry in package.path:gmatch("[^;]+") do
    local r = entry:match("^(.*)/lib/%?%.lua$")
    if r then return r end
  end
  error("measure.lua: no <repo>/lib/?.lua on LUA_PATH (fb render sets it)")
end

local faces = {}

-- The advance (in em) of each code point, from the font's cmap (format 4, Windows Unicode BMP) and hmtx.
local function load(face)
  if faces[face] then return faces[face] end
  local path = root() .. "/fonts/liberation-serif/" .. assert(FILES[face], "measure.lua: no face " .. tostring(face))
  local f = assert(io.open(path, "rb"))
  local s = f:read("a")
  f:close()
  local tables = {}
  local n = string.unpack(">I2", s, 5)
  for i = 0, n - 1 do
    local rec = 13 + i * 16
    local off = string.unpack(">I4", s, rec + 8)
    tables[s:sub(rec, rec + 3)] = off + 1
  end
  local upem = string.unpack(">I2", s, tables.head + 18)
  local nhm = string.unpack(">I2", s, tables.hhea + 34)
  local c = tables.cmap
  local sub
  for i = 0, string.unpack(">I2", s, c + 2) - 1 do
    local pid, eid, off = string.unpack(">I2I2I4", s, c + 4 + i * 8)
    if pid == 3 and eid == 1 then sub = c + off end
  end
  assert(sub and string.unpack(">I2", s, sub) == 4, "measure.lua: no format 4 cmap in " .. path)
  local segx2 = string.unpack(">I2", s, sub + 6)
  local ends = sub + 14
  local starts = ends + segx2 + 2
  local deltas = starts + segx2
  local ranges = deltas + segx2
  local function glyph(cp)
    for i = 0, segx2 / 2 - 1 do
      local e = string.unpack(">I2", s, ends + 2 * i)
      if cp <= e then
        local st = string.unpack(">I2", s, starts + 2 * i)
        if cp < st then return 0 end
        local delta = string.unpack(">i2", s, deltas + 2 * i)
        local ro = string.unpack(">I2", s, ranges + 2 * i)
        if ro == 0 then return (cp + delta) % 65536 end
        local g = string.unpack(">I2", s, ranges + 2 * i + ro + 2 * (cp - st))
        if g == 0 then return 0 end
        return (g + delta) % 65536
      end
    end
    return 0
  end
  local cache = {}
  local function adv(cp)
    local a = cache[cp]
    if a then return a end
    local g = glyph(cp)
    if g >= nhm then g = nhm - 1 end
    a = string.unpack(">I2", s, tables.hmtx + 4 * g) / upem
    cache[cp] = a
    return a
  end
  faces[face] = adv
  return adv
end

-- The width of a string in points.
function M.width(text, size, face)
  local adv = load(face or "regular")
  local w = 0
  for _, cp in utf8.codes(text) do w = w + adv(cp) end
  return w * size
end

-- The number of lines `text` takes in a column `width` points wide (an empty text: one line).
function M.lines(text, width, size, face)
  local space = M.width(" ", size, face)
  local n, line = 1, nil
  for word in text:gmatch("[^ ]+") do
    local w = M.width(word, size, face)
    if line == nil then
      line = w
    elseif line + space + w <= width then
      line = line + space + w
    else
      n, line = n + 1, w
    end
  end
  return n
end

return M

-- Finds the printed page of each TOC heading and each table-of-authorities entry in the first-pass PDF.
-- Usage: pandoc lua docx/pages.lua search.tsv page-1.txt ... page-N.txt   (docx/render.sh)
--   search.tsv  lines "toc<TAB>index<TAB>heading phrase" (capitals for level 1, as typed otherwise) and
--               "toa<TAB>key<TAB>phrase|phrase" (lower case, from ksb.lua)
--   page-N.txt  the text of page N of the first-pass PDF (one line, from pdftotext)
-- Prints "toc<TAB>index<TAB>page" and "toa<TAB>key<TAB>page,page". Pages are physical pages: the cover is page 1,
-- and the body starts on the page of the first TOC heading. A heading that is not found prints "?".
-- Headings are matched case-sensitively (so "Legal Conclusion" does not match CONCLUSION); authorities in lower case.

local function nws(s)
  local t = (s:gsub("[ \t\r\n]+", " "))
  t = (t:gsub("^ ", ""))
  t = (t:gsub(" $", ""))
  return t
end

local toc_ph, toa_key, toa_ph = {}, {}, {}
local toc_n, toa_n = 0, 0
for line in io.lines(arg[1]) do
  local kind, a, b = line:match("^(%a+)\t([^\t]*)\t(.*)$")
  if kind == "toc" then
    toc_n = toc_n + 1
    toc_ph[tonumber(a)] = b
  elseif kind == "toa" then
    toa_n = toa_n + 1
    toa_key[toa_n] = a
    toa_ph[a] = b
  end
end

local raw, low, np = {}, {}, 0
for i = 2, #arg do
  local f = assert(io.open(arg[i], "r"))
  local text = f:read("a") or ""
  f:close()
  np = i - 1
  raw[np] = nws(text)
  low[np] = raw[np]:lower()
end

local function find(hay, needle)
  return needle ~= "" and hay:find(needle, 1, true) ~= nil
end

local toa_page = 0
for p = 1, np do
  if find(low[p], "table of authorities") then toa_page = p break end
end

local cur, body = toa_page + 1, 0
for i = 1, toc_n do
  local ph = nws(toc_ph[i] or "")
  local found = 0
  for p = cur, np do
    if find(raw[p], ph) then found = p break end
  end
  if found == 0 then
    print("toc\t" .. i .. "\t?")
  else
    print("toc\t" .. i .. "\t" .. found)
    cur = found
    if body == 0 then body = found end
  end
end

for k = 1, toa_n do
  local key = toa_key[k]
  local list = {}
  for p = body, np do
    for phrase in (toa_ph[key] .. "|"):gmatch("([^|]*)|") do
      if find(low[p], phrase:lower()) then
        list[#list + 1] = tostring(p)
        break
      end
    end
  end
  print("toa\t" .. key .. "\t" .. (#list > 0 and table.concat(list, ",") or "?"))
end

-- Finds the printed page label of each TOC heading and each citation in a rendered PDF's text.
-- Usage: pandoc lua pages.lua <pdf.txt> <list.tsv>      (pdf.txt from pdftotext; list.tsv from ca6-opening-brief.lua)
-- list.tsv lines: "h<n>\tfront|body\t<heading text>" and "k<k>\tbody\t<citation text>".
-- Front headings (TOA, oral argument) are matched as whole lines on roman-numbered pages, because their titles
-- also appear, with dot leaders, in the table of contents. Body headings and citations are matched in document
-- order as substrings of the page text on pages whose footer is arabic (or Add-n): the first match after the
-- previous one, then the rest of the same page, then later pages. Exits 1 when an item is not found.
local pdf_path, list_path = arg[1], arg[2]

-- Whitespace is dropped altogether: a line break may fall inside a citation (after a hyphen, or after "§").
local function norm(s)
  s = s:gsub('\194\160', ''):gsub('%s+', '')
  return s:lower()
end

-- Pages: the PDF text is split at form feeds; a page's label is its last non-empty line.
local pages = {}
do
  local text = io.open(pdf_path, 'r'):read('a')
  for chunk in (text .. '\f'):gmatch('(.-)\f') do
    local lines = {}
    for line in (chunk .. '\n'):gmatch('(.-)\n') do
      local t = line:gsub('^%s+', ''):gsub('%s+$', '')
      if t ~= '' then lines[#lines + 1] = t end
    end
    if #chunk:gsub('%s', '') > 0 then
      local label = lines[#lines] or ''
      pages[#pages + 1] = { label = label, text = norm(chunk), lines = lines }
    end
  end
end

local function is_roman(label) return label:match('^[ivxlc]+$') ~= nil end
local function is_body(label) return label:match('^%d+$') ~= nil or label:match('^Add%-%d+$') ~= nil end

local out = {}
local function fail(tag, text)
  io.stderr:write('pages.lua: not found: ' .. tag .. '  ' .. text .. '\n')
  os.exit(1)
end

local cursor = { h = { 1, 1 }, k = { 1, 1 } }   -- headings and citations each advance their own cursor
local items = {}
for line in io.lines(list_path) do
  local tag, where, text = line:match('^([^\t]+)\t([^\t]+)\t(.*)$')
  if tag then items[#items + 1] = { tag = tag, where = where, text = norm(text) } end
end

for _, it in ipairs(items) do
  local found
  if it.where == 'front' then
    for i, p in ipairs(pages) do
      if is_roman(p.label) then
        for _, l in ipairs(p.lines) do
          if norm(l) == it.text then found = p.label break end
        end
      end
      if found then break end
    end
  else
    -- order: this page from the cursor, this page from its start, then the following body pages
    local c = cursor[it.tag:sub(1, 1)]
    local order = {}
    order[#order + 1] = { c[1], c[2] }
    if c[1] <= #pages then order[#order + 1] = { c[1], 1 } end
    for i = c[1] + 1, #pages do order[#order + 1] = { i, 1 } end
    for _, o in ipairs(order) do
      local p = pages[o[1]]
      if p and is_body(p.label) then
        local at = p.text:find(it.text, o[2], true)
        if at then
          found = p.label
          c[1], c[2] = o[1], at + #it.text
          break
        end
      end
    end
  end
  if not found then fail(it.tag, it.text) end
  out[#out + 1] = it.tag .. ' ' .. found
end
io.write(table.concat(out, '\n'), '\n')

-- Finds the printed page label of each TOC heading and each citation in a rendered PDF's text.
-- Usage: pandoc lua pages.lua <pdf.txt> <list.tsv>      (pdf.txt from pdftotext; list.tsv from ca6-reply-brief.lua)
-- list.tsv lines: "h<n>\tbody\t<label and heading text>" and "k<k>\tbody\t<citation text>".
-- Headings are matched as the start of a line of a body page (the label, if any, is part of the line), so the
-- word "argument" in the text of the introduction is not the heading. Citations are matched in document order as
-- substrings of the page text: the first match after the previous one, then the rest of the same page, then later
-- pages. Body pages are those whose footer is arabic. Exits 1 when an item is not found.
local pdf_path, list_path = arg[1], arg[2]

-- Whitespace is dropped altogether: a line break may fall inside a citation (after a hyphen, or after "§").
local function norm(s)
  s = s:gsub('\194\160', ''):gsub('\226\129\160', ''):gsub('%s+', '')
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

local function is_body(label) return label:match('^%d+$') ~= nil end

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

-- The pages to search, from the cursor: this page after the cursor, then the following body pages.
local function candidates(c)
  local order = { { c[1], c[2] } }
  for i = c[1], #pages do
    if i > c[1] then order[#order + 1] = { i, 1 } end
  end
  return order
end

for _, it in ipairs(items) do
  local found
  local c = cursor[it.tag:sub(1, 1)]
  if it.tag:sub(1, 1) == 'h' then
    -- a heading: a whole line that begins the heading text (the first line of a wrapped heading)
    for _, o in ipairs(candidates(c)) do
      local p = pages[o[1]]
      if p and is_body(p.label) then
        local pos = 0
        for _, l in ipairs(p.lines) do
          pos = pos + 1
          local nl = norm(l)
          if #nl >= math.min(#it.text, 6) and it.text:sub(1, #nl) == nl and (o[1] > c[1] or pos >= o[2]) then
            found = p.label
            c[1], c[2] = o[1], 1
            break
          end
        end
      end
      if found then break end
    end
  else
    for _, o in ipairs(candidates(c)) do
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
  io.write(it.tag, ' ', found, '\n')
end

-- ca5-docx.lua: pandoc filter for the Fifth Circuit briefs, docx engine (see ../docx/README in ../README.md).
-- Citations ([text](toa:key)) become plain text: the table of authorities is not built in the docx yet
-- (BLOCKED, see README "Engines"). The certificate word count placeholder {{words}} is filled from the
-- body: the words of the main sections (not the front statements, the tables or the certificates).

local FRONT = { ['certificate of interested persons'] = true, ['statement regarding oral argument'] = true }

local function norm(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')):lower() end

local function commas(n)
  local s = tostring(n)
  local k
  repeat
    s, k = s:gsub('^(%d+)(%d%d%d)', '%1,%2')
  until k == 0
  return s
end

function Pandoc(doc)
  local words, in_body = 0, false
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' and b.level == 1 then
      local t = norm(pandoc.utils.stringify(b.content))
      in_body = not FRONT[t] and t:sub(1, 14) ~= 'certificate of'
    elseif in_body then
      for _ in pandoc.utils.stringify(b):gmatch('%S+') do words = words + 1 end
    end
  end
  local count = commas(words)
  local blocks = pandoc.Pandoc(doc.blocks):walk({
    Link = function(l)
      if l.target:sub(1, 4) == 'toa:' then return l.content end
    end,
    Str = function(s)
      if s.text:find('{{words}}', 1, true) then
        return pandoc.Str((s.text:gsub('{{words}}', count)))
      end
    end,
  })
  return blocks
end

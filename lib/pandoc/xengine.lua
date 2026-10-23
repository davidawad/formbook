-- lib/pandoc/xengine.lua: the engine-neutral inline rules of the cross-engine layout model (docs/EVAL-LOOP.md,
-- "Cross-engine gate"), shared by lib/latex/xengine.lua and lib/docx/xengine.lua. fb render puts lib/ on LUA_PATH:
--   local common = require("pandoc.xengine")
local M = {}

-- A run of hyphens as typst's markdown reader (CommonMark smart punctuation) sets it: k hyphens are em dashes when
-- k is a multiple of 3, else en dashes when it is even, else as many em dashes as leave one or two en dashes
-- ("----" is two en dashes). pandoc takes em dashes first ("—-"), so its em dashes and the en dash or hyphen after
-- them are counted back to k. (The shared document model's engines, lib/latex/xdoc.lua and lib/docx/xdoc.lua.)
local EM, EN = "\u{2014}", "\u{2013}"

local function dashes(k)
  if k % 3 == 0 then return EM:rep(k // 3) end
  if k % 2 == 0 then return EN:rep(k // 2) end
  if k % 3 == 2 then return EM:rep((k - 2) // 3) .. EN end
  return EM:rep((k - 4) // 3) .. EN:rep(2)
end

function M.dashes(inlines)
  for x, s in ipairs(inlines) do
    if s.t == "Str" and s.text:find(EM, 1, true) then
      local out, i, n = "", 1, #s.text
      while i <= n do
        local a = s.text:find(EM, i, true)
        if not a then out = out .. s.text:sub(i); break end
        out = out .. s.text:sub(i, a - 1)
        local j, m = a, 0
        while s.text:sub(j, j + 2) == EM do j, m = j + 3, m + 1 end
        local k = 3 * m
        if s.text:sub(j, j + 2) == EN then
          k, j = k + 2, j + 3
        elseif s.text:sub(j, j) == "-" then
          k, j = k + 1, j + 1
        end
        out, i = out .. dashes(k), j
      end
      inlines[x] = pandoc.Str(out)
    end
  end
  return inlines
end

-- A section or pilcrow sign stays with the number after it, as in the typst template ("§ 1331" is not split;
-- lib/typst/xengine.typ boxes them).
function M.bind_signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}" or a.text == "\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- pandoc's smart reading puts a no-break space after an abbreviation ("v. Jones", "ed. 2020"); typst's markdown
-- reader does not, so the space after a period is an ordinary one again (the engines must break lines alike).
function M.unabbrev(inlines)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "Str" and el.text:find(".\u{00A0}", 1, true) then
      local rest = el.text
      while true do
        local s = rest:find(".\u{00A0}", 1, true)
        if not s then break end
        out:insert(pandoc.Str(rest:sub(1, s)))
        out:insert(pandoc.Space())
        rest = rest:sub(s + 3)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end

return M

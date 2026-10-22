-- lib/pandoc/xengine.lua: the engine-neutral inline rules of the cross-engine layout model (docs/EVAL-LOOP.md,
-- "Cross-engine gate"), shared by lib/latex/xengine.lua and lib/docx/xengine.lua. fb render puts lib/ on LUA_PATH:
--   local common = require("pandoc.xengine")
local M = {}

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

-- Inside a URL ("https://..", "www...") a line may end after every slash not followed by another, in every engine alike: a
-- zero-width space after each (lib/typst/xdoc.typ sets the same; typst breaks after some of them by itself, pdfTeX after
-- none, LibreOffice before a letter only). Hyphens break alike already.
function M.urls(inlines)
  return inlines:walk({ Str = function(s)
    if not (s.text:find("://", 1, true) or s.text:find("^%(?www%.")) then return nil end
    return pandoc.Str((s.text:gsub("/([^/])", "/\u{200B}%1")))
  end })
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

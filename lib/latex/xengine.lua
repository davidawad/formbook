-- lib/latex/xengine.lua: the inline rules of the cross-engine layout model for a LaTeX template that loads
-- lib/latex/xengine.sty (docs/EVAL-LOOP.md, "Cross-engine gate"). fb render puts lib/ on LUA_PATH; a court filter
-- runs it over the body and over every metadata value the template sets:
--   local xe = require("latex.xengine")
--   ... doc:walk({ Inlines = xe.inlines }) ...
-- The template turns ligatures off, so the characters the writer would spell as ligatures (``, --, ---) are written as
-- commands, and the places where typst and Word may break a line inside a word (Unicode line breaking) are the
-- places TeX may break it:
--   * pandoc's smart reading puts a no-break space after an abbreviation ("v. Jones"); typst's does not: a space;
--   * a hyphen before a digit does not end a line ("ER-178-82"), any other may (xengine.sty makes that free);
--   * a line may end before or after an em dash, and after an en dash;
--   * a section or pilcrow sign stays with its number (lib/pandoc/xengine.lua).
local common = require("pandoc.xengine")
local M = {}

local RAW = {
  ["\u{201C}"] = "\\textquotedblleft{}",
  ["\u{201D}"] = "\\textquotedblright{}",
  ["\u{2018}"] = "\\textquoteleft{}",
  ["\u{2014}"] = "\\allowbreak\\textemdash\\allowbreak{}",
  ["\u{2013}"] = "\\textendash\\allowbreak{}",
}

local function raw(s)
  return pandoc.RawInline("latex", s)
end

function M.texify(inlines)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out:insert(pandoc.Str(q[1]))
      out:extend(el.content)
      out:insert(pandoc.Str(q[2]))
    else
      out:insert(el)
    end
  end
  local res = pandoc.Inlines({})
  local last = "" -- the last character of the previous Str (pandoc may keep the no-break space apart)
  for _, el in ipairs(out) do
    if el.t ~= "Str" then last = "" end
    if el.t == "Str" then
      local buf = ""
      local function flush()
        if buf ~= "" then res:insert(pandoc.Str(buf)) end
        buf = ""
      end
      local chars = { last }
      for _, c in utf8.codes(el.text) do chars[#chars + 1] = utf8.char(c) end
      for i, c in ipairs(chars) do
        if i == 1 then goto continue end
        if RAW[c] then
          flush()
          res:insert(raw(RAW[c]))
        elseif c == "\u{00A0}" and i > 1 and chars[i - 1] == "." then
          flush()
          res:insert(pandoc.Space())
        elseif c == "\u{200B}" then
          -- a break opportunity of no width
          flush()
          res:insert(raw("\\hskip0pt\\relax{}"))
        elseif c == "-" and chars[i + 1] and chars[i + 1]:match("^%d$") then
          flush()
          res:insert(raw("\\mbox{-}"))
        else
          buf = buf .. c
        end
        ::continue::
      end
      flush()
      last = chars[#chars]
    else
      res:insert(el)
    end
  end
  return res
end

-- The inline filter of the body and of every metadata value the template sets.
function M.inlines(l)
  return M.texify(common.bind_signs(l))
end

return M

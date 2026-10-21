-- LuaTeX pre-linebreak filter that marks the last legal inter-word break
-- before a word would overrun the available line width.  This approximates
-- Word's greedy line selection; TeX still performs the final glue setting.
local M = {}
local node = node
local id = node.id
local glyph_id, glue_id, kern_id, penalty_id =
  id("glyph"), id("glue"), id("kern"), id("penalty")
local interword = {
  [node.subtype("spaceskip")] = true,
  [node.subtype("xspaceskip")] = true,
}
local callback_name = "formbook.word_compat.greedy"
local enabled = false

local function next_word_width(n)
  local width = 0
  while n do
    if n.id == glyph_id then
      width = width + n.width
    elseif n.id == kern_id then
      width = width + n.kern
    elseif n.id == glue_id or n.id == penalty_id then
      break
    else
      break
    end
    n = n.next
  end
  return width
end

local function greedy(head, groupcode)
  if groupcode ~= "main" and groupcode ~= "hbox" then return head end
  local width, line_width = 0, tex.hsize
  local n = head
  while n do
    if n.id == glue_id and interword[n.subtype] then
      local following = next_word_width(n.next)
      if width + n.width + following > line_width then
        local p = node.new("penalty")
        p.penalty = -10000
        head = node.insert_after(head, n, p)
        width = 0
      else
        width = width + n.width
      end
    elseif n.id == glyph_id then
      width = width + n.width
    elseif n.id == kern_id then
      width = width + n.kern
    end
    n = n.next
  end
  return head
end

function M.enable()
  if not luatexbase or not luatexbase.add_to_callback then
    error("word-compat requires luatexbase callback management")
  end
  if not enabled then
    luatexbase.add_to_callback("pre_linebreak_filter", greedy, callback_name)
    enabled = true
  end
end

function M.disable()
  if enabled and luatexbase and luatexbase.remove_from_callback then
    luatexbase.remove_from_callback("pre_linebreak_filter", callback_name)
    enabled = false
  end
end

return M

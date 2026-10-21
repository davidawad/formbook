-- LuaTeX pre-linebreak filter that reproduces Word's greedy line selection (fb-w0vj): a word stays
-- on the line when the line fits with its inter-word spaces at `theta` x their natural width
-- (Word 2013+ compresses spaces to about 0.76; older compatibility modes use 1.0). It forces a break
-- in front of the space before the first word that does not fit, so the space is discarded at the
-- break and TeX only sets the glue of the chosen lines. Calibration and residuals: docs/EVAL-LOOP.md,
-- "Word compatibility". NOT YET COMPILED: no lualatex in the calibration box (see EVAL-LOOP.md).
local M = {}
local node = node
local id = node.id
local glyph_id, glue_id, kern_id, penalty_id, hlist_id =
  id("glyph"), id("glue"), id("kern"), id("penalty"), id("hlist")
local interword = {
  [node.subtype("spaceskip")] = true,
  [node.subtype("xspaceskip")] = true,
  [0] = true, -- userskip: a font space set without \spaceskip
}
local callback_name = "formbook.word_compat.greedy"
local enabled = false
local theta = 1.0

local function width_of(n)
  if n.id == glyph_id then return n.width end
  if n.id == kern_id then return n.kern end
  if n.id == hlist_id then return n.width end
  return 0
end

local function next_word_width(n)
  local width = 0
  while n and n.id ~= glue_id and n.id ~= penalty_id do
    width = width + width_of(n)
    n = n.next
  end
  return width
end

local function greedy(head, groupcode)
  if groupcode ~= "" and groupcode ~= "vbox" and groupcode ~= "vtop" and groupcode ~= "insert"
    and groupcode ~= "vcenter" then
    return head
  end
  local line_width = tex.hsize - tex.leftskip.width - tex.rightskip.width
  -- the first line carries the paragraph indent box, so it is measured like any other node
  local width = 0
  local n = head
  while n do
    if n.id == glue_id and interword[n.subtype] then
      local following = next_word_width(n.next)
      if width + n.width * theta + following > line_width then
        local p = node.new("penalty")
        p.penalty = -10000
        head = node.insert_before(head, n, p)
        width = 0
      else
        width = width + n.width * theta
      end
    elseif n.id == penalty_id and n.penalty <= -10000 then
      width = 0
    else
      width = width + width_of(n)
    end
    n = n.next
  end
  return head
end

function M.enable(shrink)
  theta = shrink or 1.0
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

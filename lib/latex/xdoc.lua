-- lib/latex/xdoc.lua: the shared document model (fb-595.54.12) in LaTeX. A folder's latex/xdoc.lua, written by
-- `fb engines gen` from typst/layout.yaml, is `return require("latex.xdoc")(<layout>)`; its latex/template.tex (also
-- generated) loads lib/latex/xengine.sty and sets the sizes, pitches, footnotes, lists and page number. Every block
-- lib/typst/xdoc.typ sets is written here from the same tree (lib/pandoc/xdoc.lua), in bp (= typst's pt):
--   par    a paragraph in a group: its line boxes (\xe@lines), indents, alignment, face; \nobreak after it when kept;
--   rule   \hrule of the stroke with a depth of the rule's line box (lib/pandoc/xdoc.lua RULE);
--   cols   an \hbox of \vtop columns (each starts at its top: \vskip 0pt), never split;
--   group  a \vtop, never split.
-- Spaces are \addvspace (the larger of the space below one block and above the next, dropped at a page break);
-- the space that opens a container (`lead`) is an explicit \vskip. The body is pandoc's (paragraphs, footnotes,
-- lists), with the headings, quotations and tail paragraphs set here; a paragraph that anchors a footnote has no
-- widow or club penalty (typst may move its last line alone with the note, as lib/docx/xdoc.lua allows too).
local xe = require("latex.xengine")
local xd = require("pandoc.xdoc")

local function bp(x)
  local s = string.format("%.4f", tonumber(x) or 0):gsub("0+$", ""):gsub("%.$", "")
  return s .. "bp"
end

local function raw(s) return pandoc.RawBlock("latex", s) end

-- Italic and bold as font switches: \emph and \textbf add an italic correction after the text, which typst and
-- Word do not (a line holding two of them came out 0.7 pt wider).
local function wrap(open, content)
  local l = pandoc.Inlines({ pandoc.RawInline("latex", open) })
  l:extend(content)
  l:insert(pandoc.RawInline("latex", "}"))
  return pandoc.Span(l)
end

local function switches(inlines)
  return inlines:walk({
    Emph = function(e) return wrap("{\\itshape ", e.content) end,
    Strong = function(e) return wrap("{\\bfseries ", e.content) end,
  })
end

-- Inlines as LaTeX (the cross-engine inline rules first: lib/latex/xengine.lua).
local function tex(inlines)
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(switches(xe.inlines(inlines))) }), "latex")
  return (s:gsub("\n+$", ""))
end

return function(spec)
  local TEXTW = 612 - spec.margin.left - spec.margin.right

  local function lines(st)
    return "\\xe@lines{" .. (st.size or spec.size) .. "}{" .. xd.pitch(spec, st.pitch) .. "}"
  end

  local function open(n)
    local s = "\\par"
    if (tonumber(n.lead) or 0) > 0 then s = s .. "\\vskip" .. bp(n.lead) .. "\\relax" end
    if (tonumber(n.above) or 0) > 0 then s = s .. "\\addvspace{" .. bp(n.above) .. "}" end
    return s
  end

  local function close(n, keep)
    local s = keep and "\\nobreak" or ""
    if (tonumber(n.below) or 0) > 0 then s = s .. "\\addvspace{" .. bp(n.below) .. "}" end
    return s
  end

  local function par(n)
    local st = n.st
    local l, r, h = tonumber(st.left) or 0, tonumber(st.right) or 0, tonumber(st.hang) or 0
    local skips
    if st.align == "center" then
      skips = "\\leftskip=" .. bp(l) .. " plus 1fil\\rightskip=" .. bp(r) .. " plus 1fil\\parfillskip=0pt"
    elseif st.align == "right" then
      skips = "\\leftskip=" .. bp(l) .. " plus 1fil\\rightskip=" .. bp(r) .. "\\parfillskip=0pt"
    else
      skips = "\\leftskip=" .. bp(l) .. "\\rightskip=" .. bp(r) .. " plus 1fil\\parfillskip=0pt plus 1fil"
    end
    local body = tex(n.text)
    if st.underline then body = "\\underline{" .. body .. "}" end
    local face = (st.bold and "\\bfseries" or "") .. (st.italic and "\\itshape" or "")
    return open(n) .. "\\begingroup\\noindent" .. lines(st) .. skips .. "\\relax"
      .. (h > 0 and ("\\hangindent=" .. bp(h) .. "\\hangafter=1\\relax") or "") .. face .. " " .. body
      .. "\\par\\endgroup" .. close(n, st.keep)
  end

  local emit

  local function rule(n)
    return open(n) .. "\\hrule height " .. bp(n.w) .. " depth " .. bp(xd.RULE) .. close(n)
  end

  local function vtop(width, items)
    return "\\vtop{\\hsize=" .. bp(width) .. "\\linewidth=\\hsize\\vskip0pt " .. emit(items, true) .. "}"
  end

  local function columns(n)
    local fixed, flex = 0, 0
    for i, c in ipairs(n.cols) do
      if c.width then fixed = fixed + c.width else flex = flex + 1 end
      if i > 1 then fixed = fixed + n.gutter end
    end
    local parts = {}
    for i, c in ipairs(n.cols) do
      if i > 1 then parts[#parts + 1] = "\\hskip" .. bp(n.gutter) end
      parts[#parts + 1] = vtop(c.width or (TEXTW - fixed) / math.max(flex, 1), c.items)
    end
    return open(n) .. "\\hbox to " .. bp(TEXTW) .. "{" .. table.concat(parts) .. "\\hss}" .. close(n)
  end

  local function group(n)
    return open(n) .. vtop(TEXTW, n.items) .. close(n)
  end

  -- The nodes as LaTeX; in a container (`inner`) the last node has no space below (typst drops it there).
  emit = function(items, inner)
    local out = {}
    for k, n in ipairs(items) do
      if inner and k == #items then
        local m = {}
        for a, b in pairs(n) do m[a] = b end
        m.below = 0
        n = m
      end
      if n.t == "par" then out[#out + 1] = par(n)
      elseif n.t == "rule" then out[#out + 1] = rule(n)
      elseif n.t == "cols" then out[#out + 1] = columns(n)
      else out[#out + 1] = group(n) end
    end
    return table.concat(out, "%\n")
  end

  local function heading(b)
    local st = {}
    for k, v in pairs(xd.heading(spec, b.level)) do st[k] = v end
    st.keep = true
    local text = b.content
    if st.upper then text = xd.upper(text) end
    return par({ t = "par", text = text, st = st, lead = 0, above = st.above, below = st.below })
  end

  local function has_note(inlines)
    for _, el in ipairs(inlines) do if el.t == "Note" then return true end end
    return false
  end

  local function para(inlines)
    local p = pandoc.Para(switches(inlines:walk({ Inlines = xe.inlines })))
    if not has_note(inlines) then return { p } end
    return { raw("\\begingroup\\widowpenalty=0\\clubpenalty=0\\relax"), p, raw("\\par\\endgroup") }
  end

  -- The body blocks; `gap` the space between two paragraphs (0 in the body, the tail's gap in the tail).
  local function body(blocks, gap)
    local out = pandoc.Blocks({})
    local q = spec.quote or {}
    local prev
    for _, b in ipairs(blocks) do
      if b.t == "Header" then
        out:insert(raw(heading(b)))
      elseif b.t == "Para" or b.t == "Plain" then
        if prev == "Para" and gap > 0 then out:insert(raw("\\par\\addvspace{" .. bp(gap) .. "}")) end
        out:extend(para(b.content))
      elseif b.t == "BlockQuote" then
        out:insert(raw("\\par\\addvspace{" .. bp(q.above) .. "}\\begingroup\\leftskip=" .. bp(q.left or spec.indent)
          .. "\\rightskip=" .. bp(q.right or spec.indent) .. " plus 1fil\\parindent=0pt" .. lines(q)))
        for i, p in ipairs(b.content) do
          if p.t ~= "Para" and p.t ~= "Plain" then error("xdoc: a quotation holds paragraphs only", 0) end
          if i > 1 and (tonumber(q.gap) or 0) > 0 then out:insert(raw("\\par\\addvspace{" .. bp(q.gap) .. "}")) end
          out:extend(para(p.content))
        end
        out:insert(raw("\\par\\endgroup\\addvspace{" .. bp(q.below) .. "}"))
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        out:insert(switches(b:walk({ Inlines = xe.inlines })))
      else
        error("xdoc: unsupported block " .. b.t, 0)
      end
      prev = b.t == "Plain" and "Para" or b.t
    end
    return out
  end

  return {
    {
      Pandoc = function(doc)
        local meta = xd.meta()
        local main, rest = xd.split_tail(spec, doc.blocks)
        local out = pandoc.Blocks({})
        local first = pandoc.Blocks({})
        if (spec.page_number and spec.page_number.from or 1) > 1 then first:insert(raw("\\thispagestyle{empty}")) end
        out:extend(first)
        out:insert(raw(emit(xd.tree(spec, spec.front, meta, true), false)))
        out:extend(body(main, 0))
        out:insert(raw(emit(xd.tree(spec, spec.closing, meta, false), false)))
        if #rest > 0 then
          local t = spec.tail
          out:insert(raw("\\par\\addvspace{" .. bp(t.above) .. "}" .. lines(t) .. "\\setlength{\\parindent}{"
            .. bp(t.indent) .. "}"))
          out:extend(body(rest, tonumber(t.gap) or 0))
        end
        return pandoc.Pandoc(out, doc.meta)
      end,
    },
  }
end

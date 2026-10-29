-- lib/latex/xdoc.lua: the shared document model (fb-595.54.12) in LaTeX. A folder's latex/xdoc.lua, written by
-- `fb engines gen` from typst/layout.yaml, is `return require("latex.xdoc")(<layout>)`; its latex/template.tex (also
-- generated) loads lib/latex/xengine.sty and sets the sizes, pitches, footnotes, lists and page number. Every block
-- lib/typst/xdoc.typ sets is written here from the same tree (lib/pandoc/xdoc.lua), in bp (= typst's pt):
--   par    a paragraph in a group: its line boxes (\xe@lines), indents, alignment, face; \nobreak after it when kept;
--   rule   \hrule of the stroke with a depth of the rule's line box (lib/pandoc/xdoc.lua RULE);
--   cols   an \hbox of \vtop columns (each starts at its top: \vskip 0pt), never split;
--   group  a \vtop, never split.
--   box    a ruled \vbox: its blocks inset from its edges, the rules inside its width and height.
--   fill   \vskip 0pt plus <weight>fill (typst v(1fr)), after an empty rule so it stays at the top of a page.
-- Spaces are \addvspace (the larger of the space below one block and above the next, dropped at a page break);
-- the space that opens a container (`lead`) is an explicit \vskip. The body is pandoc's (paragraphs, footnotes,
-- lists), with the headings, quotations and tail paragraphs set here; a paragraph that anchors a footnote has no
-- widow or club penalty (typst may move its last line alone with the note, as lib/docx/xdoc.lua allows too).
local xe = require("latex.xengine")
local xd = require("pandoc.xdoc")
local common = require("pandoc.xengine")
local xs = require("latex.xeschola")

-- The face's glyph filter (layout latex_glyphs, gen.rs): "schola" writes the glyphs whose TeX Live advances differ
-- from the vendored Schola's at its advances (lib/latex/xeschola.lua), after the other inline rules.
local glyphs = nil
local function faced(x)
  if glyphs == "schola" then return x:walk(xs.filter) end
  return x
end

local function bp(x)
  local s = string.format("%.4f", tonumber(x) or 0):gsub("0+$", ""):gsub("%.$", "")
  return s .. "bp"
end

local function raw(s) return pandoc.RawBlock("latex", s) end

-- Italic and bold as font switches: \emph and \textbf add an italic correction after the text, which typst and Word
-- do not (a line holding two of them came out 0.7 pt wider).
local function wrap(open, content)
  local l = pandoc.Inlines({ pandoc.RawInline("latex", open) })
  l:extend(content)
  l:insert(pandoc.RawInline("latex", "}"))
  return pandoc.Span(l)
end

-- An ellipsis as the template's \xd@ellipsis (three periods kerned to the face's ellipsis advance, read as "…" in the
-- PDF text): pandoc's \ldots sets spaced dots, wider than the glyph typst and Word set.
local function ellipses(s)
  if not s.text:find("\u{2026}", 1, true) then return nil end
  local out = pandoc.Inlines({})
  local rest = s.text
  while true do
    local a, b = rest:find("\u{2026}", 1, true)
    if not a then break end
    if a > 1 then out:insert(pandoc.Str(rest:sub(1, a - 1))) end
    out:insert(pandoc.RawInline("latex", "\\xd@ellipsis{}"))
    rest = rest:sub(b + 1)
    -- typst and LibreOffice may end a line after an ellipsis that a word follows ("\u{2026}presents"): so may TeX
    if rest:find("^%w") then out:insert(pandoc.RawInline("latex", "\\hskip0pt\\relax{}")) end
  end
  if rest ~= "" then out:insert(pandoc.Str(rest)) end
  return out
end

-- A URL as its pieces with \\allowbreak between them (lib/pandoc/xdoc.lua url_pieces): it breaks only there, as typst and
-- Word break it.
local function urls(s)
  local pre, pieces, post = xd.url_pieces(s.text)
  if not pre then return nil end
  local out = pandoc.Inlines({})
  if pre ~= "" then out:insert(pandoc.Str(pre)) end
  for i, p in ipairs(pieces) do
    if i > 1 then out:insert(pandoc.RawInline("latex", "\\allowbreak{}")) end
    out:insert(pandoc.Str(p))
  end
  if post ~= "" then out:insert(pandoc.Str(post)) end
  return out
end

-- Characters pdfLaTeX's face lacks (lib/latex/xdoc.sty \xd@glyph): the PDF text's code point, a glyph of the face, and the
-- typst face's advances (regular, bold, italic, bold italic; em) it is centred in. The glyphs are Type 1 (newtx's TS1
-- glyphs are bitmaps: Type 3): T1 and newtxmath's symbols (txsys). Liberation Serif's (Times New Roman's;
-- typst measure() at 1000 pt), the faces' default as for a page list's width; a layout may give `latex_specials`.
local TIMES_SPECIALS = {
  ["\u{02BB}"] = { "02BB", "\\textquoteleft", 0.333, 0.333, 0.333, 0.333 }, -- okina
  ["\u{00B4}"] = { "00B4", "\\'{}", 0.333, 0.333, 0.333, 0.333 },
  ["\u{2192}"] = { "2192", "$\\rightarrow$", 1, 1, 1, 1 },
  ["\u{2212}"] = { "2212", "$-$", 0.564, 0.5698, 0.6748, 0.606 },
  ["\u{2502}"] = { "2502", "\\textbar", 0.7085, 0.7085, 0.6157, 0.6157 },
}
local SPECIALS = {} -- the layout's (set below, per filter run)

-- A Str with the characters of SPECIALS as \xd@glyph, or nil when it holds none.
local function specials(s)
  local out, buf, hit = pandoc.Inlines({}), "", false
  for _, cp in utf8.codes(s.text) do
    local c = utf8.char(cp)
    local g = SPECIALS[c]
    if g then
      if buf ~= "" then out:insert(pandoc.Str(buf)) end
      buf, hit = "", true
      out:insert(pandoc.RawInline("latex", "\\xd@glyph{" .. g[1] .. "}{" .. g[2] .. "}{" .. g[3] .. "}{" .. g[4] .. "}{" .. g[5]
        .. "}{" .. g[6] .. "}"))
    else
      buf = buf .. c
    end
  end
  if not hit then return nil end
  if buf ~= "" then out:insert(pandoc.Str(buf)) end
  return out
end

-- typst breaks a line after a slash inside a word before a letter ("cgi/viewcontent", "CM/ECF"), as lib/docx/xdoc.lua
-- lets LibreOffice (a zero-width space): an \allowbreak there. Not in "/s/" (neither engine breaks there).
local function slashes(s)
  local out = pandoc.Inlines({})
  local rest = s.text
  while true do
    local a = rest:find("[^%s/]/%a")
    if not a then break end
    out:insert(pandoc.Str(rest:sub(1, a + 1)))
    out:insert(pandoc.RawInline("latex", "\\allowbreak{}"))
    rest = rest:sub(a + 2)
  end
  if #out == 0 then return nil end
  if rest ~= "" then out:insert(pandoc.Str(rest)) end
  return out
end

-- No break after a hyphen before a closing mark ("full[-]time", "-)", "-”"): Unicode line breaking never breaks before
-- one; TeX breaks after every explicit hyphen (lib/latex/xengine.sty).
local function closing_hyphens(s)
  local out, rest = pandoc.Inlines({}), s.text
  while true do
    local a
    for _, p in ipairs({ "%-[%]%)}\"',.;:!?]", "%-\u{201D}", "%-\u{2019}" }) do
      local x = rest:find(p)
      if x and (not a or x < a) then a = x end
    end
    if not a then break end
    if a > 1 then out:insert(pandoc.Str(rest:sub(1, a - 1))) end
    out:insert(pandoc.RawInline("latex", "\\mbox{-}"))
    rest = rest:sub(a + 1)
  end
  if #out == 0 then return nil end
  if rest ~= "" then out:insert(pandoc.Str(rest)) end
  return out
end

-- A Str that is not a URL: its hyphens before a closing mark, its slashes inside a word, its ellipses.
local function plain(s)
  local out = pandoc.Inlines({})
  for _, x in ipairs(closing_hyphens(s) or { s }) do
    if x.t ~= "Str" then out:insert(x)
    else
      local l = slashes(x)
      if l then out:extend(l:walk({ Str = function(y) return ellipses(y) end })) else out:extend(ellipses(x) or { x }) end
    end
  end
  return out
end

-- A run of asterisks between spaces ("* * *", an omission): pdftotext reads pdfTeX's as one word "***" (typst's and
-- LibreOffice's as three), so each asterisk before a space is an /ActualText span of itself and the space.
local function asterisks(l)
  local out = pandoc.Inlines({})
  local function star(x) return x and x.t == "Str" and x.text:match("^%*+$") end
  for i, x in ipairs(l) do
    if star(x) and l[i + 1] and l[i + 1].t == "Space" and (star(l[i + 2]) or star(l[i - 2]) and l[i - 1].t == "Space") then
      local hex = ((x.text .. " "):gsub(".", function(c) return string.format("%04X", c:byte()) end))
      out:insert(pandoc.RawInline("latex", "\\pdfliteral page{/Span<</ActualText<FEFF" .. hex .. ">>>BDC}"))
      out:insert(x)
      out:insert(pandoc.RawInline("latex", "\\pdfliteral page{EMC}"))
    else
      out:insert(x)
    end
  end
  return out
end

-- typst never breaks between an em dash and a quotation mark next to it (UAX #14 QU); xengine's em dash allows a break
-- on either side, so the side a quotation mark is on loses it.
local EMDASH = "\\allowbreak\\textemdash\\allowbreak{}"
local ENDASH = "\\textendash\\allowbreak{}"
local QUOTES = { ["\\textquotedblleft{}"] = true, ["\\textquotedblright{}"] = true, ["\\textquoteleft{}"] = true }
-- whether the element at the end (`last`) or start of `el` is a quotation mark
local function quote_at(el, last)
  if not el then return false end
  if el.t == "RawInline" then return QUOTES[el.text] or false end
  if el.t ~= "Str" or el.text == "" then return false end
  local c = el.text:match(last and (utf8.charpattern .. "$") or ("^" .. utf8.charpattern))
  return c == "\u{201C}" or c == "\u{201D}" or c == "\u{2018}" or c == "\u{2019}" or c == '"' or c == "'"
end

local function dash_quotes(l)
  for i, el in ipairs(l) do
    if el.t == "RawInline" and el.text == EMDASH then
      local before, after = quote_at(l[i - 1], true), quote_at(l[i + 1], false)
      if before or after then
        l[i] = pandoc.RawInline("latex", (before and "" or "\\allowbreak") .. "\\textemdash" .. (after and "{}" or "\\allowbreak{}"))
      end
    elseif el.t == "RawInline" and el.text == ENDASH and quote_at(l[i + 1], false) then
      -- an en dash breaks after itself only, and not before a quotation mark either (fb-595.54.14)
      l[i] = pandoc.RawInline("latex", "\\textendash{}")
    end
  end
  return l
end

-- The cross-engine inline rules (lib/latex/xengine.lua) on inlines whose URLs are cut into their pieces first (its
-- unbreakable hyphen before a digit would join two pieces: "election-|2024"), no break before a closing mark
-- (xd.bind_punct), hyphen runs as CommonMark sets them (lib/pandoc/xengine.lua dashes), no break between an em dash and a
-- quotation mark (dash_quotes), spaced asterisks read as written (asterisks).
local function texify(inlines)
  -- a space that does not break (\nobreak: no break at the glue after a penalty), the body's \spaceskip when justified
  local glue = function() return pandoc.RawInline("latex", "\\nobreak\\space{}") end
  -- the token after a section or pilcrow sign in one \mbox, as typst boxes it (xd.hold_sign_tokens)
  local function mbox(p)
    local out = pandoc.Inlines({ pandoc.RawInline("latex", "\\mbox{") })
    out:extend(p)
    out:insert(pandoc.RawInline("latex", "}"))
    return out
  end
  local held = xd.hold_sign_tokens(common.dashes(inlines):walk({ Str = urls }), mbox)
  return asterisks(dash_quotes(xe.inlines(xd.bind_punct(held, glue):walk({ Str = specials }))))
end

local function switches(inlines)
  return inlines:walk({
    -- a hard line break inside the paragraph (\\ under \raggedright ends it: the next line indented, the club
    -- penalty again); \hfill outranks a justified line's fil spaces, as typst does not justify the line before it
    LineBreak = function() return pandoc.RawInline("latex", "\\hfill\\break{}") end,
    Str = function(s) return urls(s) or plain(s) end,
    -- emphasis toggles italics (lib/latex/xdoc.sty \xd@em), as typst's emph does
    Emph = function(e) return wrap("{\\xd@em ", e.content) end,
    Strong = function(e) return wrap("{\\bfseries ", e.content) end,
  })
end

-- Inlines as LaTeX (the cross-engine inline rules first: lib/latex/xengine.lua); `plain`: without the face's glyph
-- filter (a PDF bookmark).
local function tex(inlines, plain)
  -- (every list of inlines: a quotation inside italics too, as the body's walk does)
  local doc = pandoc.Pandoc({ pandoc.Plain(switches(texify(pandoc.Inlines(inlines):walk({ Inlines = texify })))) })
  local s = pandoc.write(plain and doc or faced(doc), "latex")
  return (s:gsub("\n+$", ""))
end

-- Underlined inlines that may break (\xd@ulp's second argument): each word (the pieces between spaces, in their
-- italics or bold) in \xd@ul, the spaces between them \xd@ulsp.
local function underlined(inlines)
  local out, word = pandoc.Inlines({}), pandoc.Inlines({})
  local function close()
    if #word == 0 then return end
    out:insert(pandoc.RawInline("latex", "\\xd@ul{"))
    out:extend(word)
    out:insert(pandoc.RawInline("latex", "}"))
    word = pandoc.Inlines({})
  end
  local function walk(list, wrap)
    for _, el in ipairs(list) do
      if el.t == "Space" or el.t == "SoftBreak" then
        close()
        out:insert(pandoc.RawInline("latex", "\\allowbreak\\xd@ulsp{}"))
      elseif el.t == "Emph" or el.t == "Strong" or el.t == "Span" or el.t == "Quoted" or el.t == "Link" then
        local t = el.t
        walk(el.content, function(x)
          local w = t == "Quoted" and pandoc.Quoted(el.quotetype, { x }) or t == "Link" and x
            or pandoc[t]({ x })
          return wrap(w)
        end)
      else
        word:insert(wrap(el))
      end
    end
  end
  walk(inlines, function(x) return x end)
  close()
  return out
end

return function(spec)
  -- the characters the face lacks: the layout's, or Times New Roman's unless the face is another one (Schola, Heros)
  SPECIALS = spec.latex_specials or ((spec.latex_glyphs or spec.face_advances) and {} or TIMES_SPECIALS)
  glyphs = spec.latex_glyphs
  -- the text width, with the face's bias (the generated template widens the text block by it: gen.rs latex_bias)

  local function lines(st)
    return "\\xe@lines{" .. (st.size or spec.size) .. "}{" .. xd.pitch(spec, st.pitch) .. "}"
  end

  local function open(n)
    local s = "\\par"
    -- the space that opens a container is kept at the top of a page too (typst v()): an empty rule before it
    if (tonumber(n.lead) or 0) > 0 then s = s .. "\\hrule height0pt\\relax\\vskip" .. bp(n.lead) .. "\\relax" end
    if (tonumber(n.above) or 0) > 0 then s = s .. "\\addvspace{" .. bp(n.above) .. "}" end
    return s
  end

  local function close(n, keep)
    local s = keep and "\\nobreak" or ""
    if (tonumber(n.below) or 0) > 0 then s = s .. "\\addvspace{" .. bp(n.below) .. "}" end
    return s
  end

  -- justified text (layout.yaml justify): the body's spaces stretch (\xd@justtrue: the generated template's
  -- selectfont hook); a block of the layout, a heading or a table row stays ragged
  local RAGGED = spec.justify and "\\xd@justfalse\\spaceskip=0pt\\relax" or ""

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
    -- an empty paragraph is a line of its pitch, as Word sets it (typst: an empty box in the line)
    local body = #n.text == 0 and "\\mbox{}" or tex(n.text)
    -- underlined: whole when it fits the line, else word by word (it may break: lib/latex/xdoc.sty \\xd@ulp)
    if st.underline then body = "\\xd@ulp{" .. body .. "}{" .. tex(underlined(n.text)) .. "}" end
    local face = (st.bold and "\\bfseries" or "") .. (st.italic and "\\itshape" or "")
    local start = (tonumber(st.indent) or 0) > 0 and ("\\parindent=" .. bp(st.indent) .. "\\relax\\indent")
      or "\\noindent"
    -- a kept block (a heading) is never split, as Word's keepLines and typst's unbreakable block
    local whole = st.keep and "\\interlinepenalty=10000" or ""
    return open(n) .. "\\begingroup" .. RAGGED .. whole .. start .. lines(st) .. skips .. "\\relax"
      .. (h > 0 and ("\\hangindent=" .. bp(h) .. "\\hangafter=1\\relax") or "") .. face .. " " .. (n.prefix or "") .. body
      .. "\\par\\endgroup" .. close(n, st.keep)
  end

  local emit

  local function rule(n)
    -- a rule of 0 is its line box alone (no width, nothing drawn)
    return open(n) .. "\\hrule height " .. bp(n.w) .. " depth " .. bp(xd.RULE) .. (n.w > 0 and "" or " width 0pt")
      .. close(n)
  end

  -- `width` in bp, or a TeX dimension (the container's \hsize, an expression of it)
  local function vtop(width, items)
    local w = type(width) == "string" and width or bp(width)
    -- an empty rule of the column's width first: an empty column keeps its width (a \vtop is as wide as its widest line)
    return "\\vtop{\\hsize=" .. w .. "\\linewidth=\\hsize\\hrule height0pt width\\hsize\\vskip0pt " .. emit(items, true) .. "}"
  end

  -- Each column is set in a box first (scratch boxes 0, 2, ..., local to the group), so a column centered in the
  -- row (`valign: center`) starts half the difference between the row's depth and its own lower.
  local function columns(n)
    local fixed, flex = 0, 0
    for i, c in ipairs(n.cols) do
      if c.width then fixed = fixed + c.width else flex = flex + 1 end
      if i > 1 then fixed = fixed + n.gutter end
    end
    local set, rep, row = {}, {}, {}
    local has_rep = false
    for _, c in ipairs(n.cols) do if c["repeat"] then has_rep = true end end
    for i, c in ipairs(n.cols) do
      local b = 2 * (i - 1)
      -- a column without a width shares what the container (\\hsize: the text, or a column holding this row) leaves
      local width = c.width or ("\\dimexpr(\\hsize-" .. bp(fixed) .. ")/" .. math.max(flex, 1) .. "\\relax")
      if c["repeat"] then
        -- a `repeat` column: its text once a line, as many lines as the tallest other column (\dimen2) is high at its
        -- pitch (typst: ceil(height / pitch - 0.01)), set after the others
        local r = c["repeat"]
        local p = xd.pitch(spec, r.st.pitch)
        rep[#rep + 1] = "\\dimen4=\\dimexpr\\dimen2+" .. bp(p) .. "-0.01bp\\relax\\@tempcnta=\\dimen4 \\dimen4="
          .. bp(p) .. "\\@tempcntb=\\dimen4 \\divide\\@tempcnta by\\@tempcntb \\setbox" .. b .. "=\\vtop{\\hsize="
          .. (type(width) == "string" and width or bp(width)) .. "\\linewidth=\\hsize\\vskip0pt\\loop\\ifnum\\@tempcnta>0 "
          .. par({ t = "par", text = r.text, st = r.st, lead = 0, above = 0, below = 0 })
          .. "\\advance\\@tempcnta-1 \\repeat}\\ifdim\\dp" .. b .. ">\\dimen0 \\dimen0=\\dp" .. b .. "\\fi"
      else
        set[#set + 1] = "\\setbox" .. b .. "=" .. vtop(width, c.items)
          .. "\\ifdim\\dp" .. b .. ">\\dimen0 \\dimen0=\\dp" .. b .. "\\fi"
          .. (has_rep and ("\\ifdim\\dimexpr\\ht" .. b .. "+\\dp" .. b .. ">\\dimen2 \\dimen2=\\dimexpr\\ht" .. b .. "+\\dp"
            .. b .. "\\relax\\fi") or "")
      end
      if i > 1 then row[#row + 1] = "\\hskip" .. bp(n.gutter) end
      local drop = c.valign == "center" and ("\\vskip\\dimexpr(\\dimen0-\\dp" .. b .. ")/2\\relax") or ""
      row[#row + 1] = "\\vtop{\\vskip0pt" .. drop .. "\\unvbox" .. b .. "}"
    end
    for _, r in ipairs(rep) do set[#set + 1] = r end
    return open(n) .. "\\begingroup\\dimen0=0pt " .. (#rep > 0 and "\\dimen2=0pt " or "") .. table.concat(set, "%\n")
      .. "%\n\\hbox to\\hsize{" .. table.concat(row) .. "\\hss}\\endgroup" .. close(n)
  end

  local function group(n)
    -- the container's width: the text's, or the column's that holds it
    return open(n) .. vtop("\\hsize", n.items) .. close(n)
  end

  -- A ruled box: the blocks in a \vbox `inset` from the box's edges (at its `height` when given, set at its valign),
  -- the rules inside its width and height; the vertical rules run its whole height (\vrule in an \hbox). Its width
  -- is the container's (\hsize) unless given.
  local function rbox(n)
    local s, i = n.stroke, n.inset
    local W = n.width and bp(n.width) or "\\hsize"
    local fil = { top = { "", "\\vfil" }, center = { "\\vfil", "\\vfil" }, bottom = { "\\vfil", "" } }
    local f = fil[n.valign] or fil.top
    local h = n.height and (" to\\dimexpr" .. bp(n.height) .. "-" .. bp(s.t) .. "-" .. bp(s.b) .. "\\relax") or ""
    local inner = "\\vbox" .. h .. "{\\kern\\dimexpr" .. bp(i.t) .. "-" .. bp(s.t) .. "\\relax" .. f[1]
      .. "\\hbox to\\hsize{\\kern\\dimexpr" .. bp(i.l) .. "-" .. bp(s.l) .. "\\relax\\vbox{\\hsize=\\dimexpr\\dimen0-"
      .. bp(i.l) .. "-" .. bp(i.r) .. "\\relax\\linewidth=\\hsize\\vskip0pt " .. emit(n.items, true) .. "}\\hss}" .. f[2]
      .. "\\kern\\dimexpr" .. bp(i.b) .. "-" .. bp(s.b) .. "\\relax}"
    return open(n) .. "\\begingroup\\dimen0=" .. W .. "\\relax\\hbox to\\dimen0{\\vrule width" .. bp(s.l)
      .. "\\vbox{\\hsize=\\dimexpr\\dimen0-" .. bp(s.l) .. "-" .. bp(s.r) .. "\\relax\\hrule height" .. bp(s.t)
      .. "\\relax" .. inner .. "\\hrule height" .. bp(s.b) .. "\\relax}\\vrule width" .. bp(s.r) .. "}\\endgroup"
      .. close(n)
  end

  -- Every heading in document order is numbered (hn): its page goes to the .aux (\xd@hmark), and it is a bookmark;
  -- bodyn counts the body's headings alone (their labels, xd.heading_labels).
  local hn, bodyn = 0, 0
  local function mark_of(level, content)
    hn = hn + 1
    return "\\xd@hmark{" .. hn .. "}\\pdfbookmark[" .. (level - 1) .. "]{"
      .. tex(pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(content)) }), true) .. "}{xd.h." .. hn .. "}"
  end

  -- The nodes as LaTeX; in a container (`inner`) the last node has no space below (typst drops it there). A layout
  -- heading (`head`: a certificate's title) gets its heading mark.
  emit = function(items, inner)
    local out = {}
    for k, n in ipairs(items) do
      if inner and k == #items then
        local m = {}
        for a, b in pairs(n) do m[a] = b end
        m.below = 0
        n = m
      end
      if n.t == "par" and n.head then
        local m = {}
        for a, b in pairs(n) do m[a] = b end
        m.prefix = mark_of(n.head, n.title or n.text)
        out[#out + 1] = par(m)
      elseif n.t == "par" then out[#out + 1] = par(n)
      elseif n.t == "break" then out[#out + 1] = "\\clearpage"
      -- a fill: glue of the order above \raggedbottom's, after an empty rule so it stays at the top of a page too
      elseif n.t == "fill" then out[#out + 1] = "\\par\\hrule height0pt\\relax\\vskip0pt plus " .. n.w .. "fill\\relax"
      elseif n.t == "rule" then out[#out + 1] = rule(n)
      elseif n.t == "cols" then out[#out + 1] = columns(n)
      elseif n.t == "box" then out[#out + 1] = rbox(n)
      -- blocks set only when the body runs past `over` pages (when: xd.pages; the pages from the .aux, xdoc.sty)
      elseif n.t == "if" then out[#out + 1] = "\\ifnum\\xd@bodypages>" .. string.format("%d", n.over) .. "\\relax\n"
        .. emit(n.items, false) .. "%\n\\fi"
      else out[#out + 1] = group(n) end
    end
    return table.concat(out, "%\n")
  end

  -- `first`: the heading opens the tail, whose own space above replaces the heading's (typst drops a block's space
  -- above at the start of a container).
  -- Every heading in document order is numbered (hn): its page goes to the .aux (\xd@hmark), and it is a bookmark.
  -- A numbered heading's label (xd.heading_labels, by heading number) with its text: in a box `w` wide
  -- (xd.label_width), else before the text after a space.
  local labels = {}
  local function labeled(w, lab, text)
    local l
    if w then
      l = pandoc.Inlines({ pandoc.RawInline("latex", "\\hbox to" .. bp(w) .. "{"), pandoc.Str(lab),
        pandoc.RawInline("latex", "\\hfil}") })
    else
      l = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
    end
    l:extend(text)
    return l
  end

  local function heading(b, first)
    local st = {}
    for k, v in pairs(xd.heading(spec, b.level)) do st[k] = v end
    st.keep = true
    local text = b.content
    if st.upper then text = xd.upper(text) end
    local mark = mark_of(b.level, b.content)
    local above = first and 0 or st.above
    bodyn = bodyn + 1
    local lab = labels[bodyn]
    if lab and st.label_line then
      -- the label on a line of its own, then the title
      return par({ t = "par", text = pandoc.Inlines({ pandoc.Str(lab) }), st = st, lead = 0, above = above, below = 0,
        prefix = mark }) .. par({ t = "par", text = text, st = st, lead = 0, above = 0, below = st.below })
    elseif lab then
      local w = xd.label_width(st)
      text = labeled(w, lab, text)
      if w then st.hang = w end
    end
    return par({ t = "par", text = text, st = st, lead = 0, above = above, below = st.below, prefix = mark })
  end

  -- The title of a table (contents, authorities): the level-1 heading style, on a new page.
  local function table_title(t)
    local st = {}
    for k, v in pairs(xd.heading(spec, 1)) do st[k] = v end
    for k, v in pairs(t.style or {}) do st[k] = v end
    st.keep = true
    local text = xd.inlines(t.title)
    if st.upper then text = xd.upper(text) end
    -- `break: false` (the contents on the cover's page): no page of its own, its heading's space above
    local own = t["break"] ~= false
    return (own and "\\clearpage" or "") .. par({ t = "par", text = text, st = st, lead = 0, above = own and 0 or st.above,
      below = st.below })
  end

  -- A row of a table: the text wraps before a page column of `col` bp (wider when the page list is: `fit`), `hang`
  -- under its first line, `left` in (lib/latex/xdoc.sty \xd@row).
  local function row(above, left, hang, col, text, pages, fit)
    local c = "\\setlength{\\xe@col}{" .. bp(col) .. "}"
    if fit then c = c .. "\\setbox0=\\hbox{" .. pages .. "}\\ifdim\\wd0>\\xe@col\\setlength{\\xe@col}{\\wd0}\\fi" end
    return "\\begingroup" .. RAGGED .. "\\leftskip=" .. bp(left) .. "\\relax" .. c .. "\\xd@row{" .. bp(above) .. "}{" .. bp(hang)
      .. "}{" .. text .. "}{" .. pages .. "}\\endgroup"
  end

  local function contents(c, heads)
    local out = { table_title(c), lines(c) }
    for _, h in ipairs(heads) do
      if h.level <= (c.depth or 3) then
        -- the heading's text without its authority marks (typst marks the body, not the contents)
        local text = h.content:walk({ RawInline = function(r)
          if r.text:find("xd@amark", 1, true) then return {} end
        end })
        -- a numbered heading's row carries its label (in the level's label box, the later lines under the title)
        local st, hang = xd.heading(spec, h.level), tonumber(c.hang) or 0
        if h.label then
          text = labeled(st.label_box, h.label, text)
          if st.label_box then hang = st.label_box end
        end
        out[#out + 1] = row(c.above, (h.level - 1) * (tonumber(c.step) or 0), hang, c.col or 36,
          tex(text), "\\xd@hpage{" .. h.n .. "}", false)
      end
    end
    return table.concat(out, "%\n")
  end

  -- Keyed authorities (layout authorities.kinds): the cited entries of each group, in order, their pages from the
  -- marks of their links (passim for `passim` pages or more); `page_heading` on the first group's line, at the right.
  local function keyed_authorities(a, meta, cited)
    if not a.kinds then
      error("xdoc: the frontmatter's authorities are keyed (a map): layout.yaml authorities.kinds names their groups", 0)
    end
    local out = { table_title(a), lines(a) }
    local gst = a.group or { bold = true }
    local entries = xd.keyed(spec, meta)
    local first = true
    for gi, g in ipairs(a.kinds) do
      local members = {}
      for _, e in ipairs(entries) do if e.group == gi and cited[e.k] then members[#members + 1] = e end end
      if #members > 0 then
        local title = xd.inlines(g.title)
        if gst.upper then title = xd.upper(title) end
        if first and a.page_heading then
          title:insert(pandoc.RawInline("latex", "\\hfill "))
          title:extend(xd.inlines(a.page_heading))
        end
        out[#out + 1] = par({ t = "par", text = title, st = setmetatable({ keep = true }, { __index = gst }),
          lead = 0, above = gst.above, below = gst.below })
        first = false
        for _, e in ipairs(members) do
          local pages = a.passim and ("\\xd@apagesp{" .. e.k .. "}{" .. a.passim .. "}") or ("\\xd@apages{" .. e.k .. "}")
          out[#out + 1] = row(a.above, 0, tonumber(a.hang) or 0, a.col or 56, tex(xd.inlines(xd.keyed_text(g, e))),
            pages, true)
        end
      end
    end
    return table.concat(out, "%\n")
  end

  local function authorities(a, meta)
    local out = { table_title(a), lines(a) }
    local gst = a.group or { bold = true }
    local entries = xd.authority_entries(meta)
    local k = 0
    for _, g in ipairs(meta.authorities) do
      -- the group's heading in the group style, in capitals when it says (typst inl)
      local title = xd.inlines(g.heading)
      if gst.upper then title = xd.upper(title) end
      out[#out + 1] = par({ t = "par", text = title, st = setmetatable({ keep = true }, { __index = gst }),
        lead = 0, above = gst.above, below = gst.below })
      for _ = 1, #(g.entries or {}) do
        k = k + 1
        local e = entries[k]
        local list = a.passim and ("\\xd@apagesp{" .. k .. "}{" .. a.passim .. "}") or ("\\xd@apages{" .. k .. "}")
        local pages = e.find and list or tex(xd.inlines(e.pages and tostring(e.pages) or "--"))
        out[#out + 1] = row(a.above, 0, tonumber(a.hang) or 0, a.col or 56, tex(xd.inlines(e.cite)), pages, true)
      end
    end
    return table.concat(out, "%\n")
  end

  -- a footnote anywhere in the paragraph (inside emphasis or a link too)
  local function has_note(inlines)
    local found = false
    pandoc.Inlines(inlines):walk({ Note = function() found = true end })
    return found
  end

  local function para(inlines)
    local p = faced(pandoc.Para(switches(inlines:walk({ Inlines = texify }))))
    -- (layout.yaml footnote.widows: the widow and club penalties kept, as typst keeps them then)
    if not has_note(inlines) or (spec.footnote and spec.footnote.widows) then return { p } end
    return { raw("\\begingroup\\widowpenalty=0\\clubpenalty=0\\relax"), p, raw("\\par\\endgroup") }
  end

  -- The body blocks; `gap` the space between two paragraphs (0 in the body, the tail's gap in the tail); `around`
  -- the body's paragraph_gap, between two paragraphs, a paragraph and a list, two lists (typst: paragraph spacing, a
  -- list a block of that space; next to a heading or quotation its own space), `prev` the kind of the block before
  -- these (a call after another). Returns the blocks and the kind of the last.
  local function body(blocks, gap, first, around, prev)
    local out = pandoc.Blocks({})
    local q = spec.quote or {}
    local function flow(t) return t == "Para" or t == "OrderedList" or t == "BulletList" end
    local function sep()
      if (tonumber(around) or 0) > 0 and flow(prev) then out:insert(raw("\\par\\addvspace{" .. bp(around) .. "}")) end
    end
    for k, b in ipairs(blocks) do
      if b.t == "Header" then
        out:insert(raw(heading(b, first and k == 1)))
      elseif b.t == "Para" or b.t == "Plain" then
        if prev == "Para" and gap > 0 then out:insert(raw("\\par\\addvspace{" .. bp(gap) .. "}")) end
        sep()
        out:extend(para(b.content))
      elseif b.t == "Table" then
        -- a table of the body (lib/pandoc/xdoc.lua table_nodes): its rules and rows as the layout's blocks
        out:insert(raw(emit(xd.table_nodes(spec, b), false)))
      elseif b.t == "BlockQuote" then
        out:insert(raw("\\par\\addvspace{" .. bp(q.above) .. "}\\begingroup\\leftskip=" .. bp(q.left or spec.indent)
          .. "\\rightskip=" .. bp(q.right or spec.indent) .. (spec.justify and "" or " plus 1fil") .. "\\parindent=0pt" .. lines(q)))
        for i, p in ipairs(b.content) do
          if i > 1 and (tonumber(q.gap) or 0) > 0 then out:insert(raw("\\par\\addvspace{" .. bp(q.gap) .. "}")) end
          if p.t == "Para" or p.t == "Plain" then
            out:extend(para(p.content))
          elseif p.t == "OrderedList" or p.t == "BulletList" then
            -- a list in the quotation: its pitch (the group's), the gap around it; a list resets \leftskip and
            -- \rightskip, so its first level's margins take the quotation's indents (enumitem, local to the group)
            local li = tonumber(spec.list_indent or spec.indent) or 0
            out:insert(raw("\\setlist[1]{leftmargin=" .. bp((tonumber(q.left or spec.indent) or 0) + li) .. ",rightmargin="
              .. bp(q.right or spec.indent) .. "}"))
            out:insert(faced(switches(p:walk({ Inlines = texify }))))
          else
            error("xdoc: a quotation holds paragraphs and lists only", 0)
          end
        end
        out:insert(raw("\\par\\endgroup\\addvspace{" .. bp(q.below) .. "}"))
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        sep()
        -- a list right after a heading stays with it (the list's own \@beginparpenalty would allow a break)
        local held = prev == "Header"
        if held then out:insert(raw("\\begingroup\\@beginparpenalty=10000\\relax")) end
        out:insert(faced(switches(b:walk({ Inlines = texify }))))
        if held then out:insert(raw("\\endgroup")) end
      else
        error("xdoc: unsupported block " .. b.t, 0)
      end
      prev = b.t == "Plain" and "Para" or b.t
    end
    return out, prev
  end

  return {
    {
      Pandoc = function(doc)
        local meta = xd.computed(spec, xd.context(spec, xd.meta()))
        xd.check_fills(spec.front)
        xd.check_fills(spec.closing)
        xd.check_fills(spec.after_tail)
        local _, keyed = xd.keyed(spec, meta)
        local cited = {}
        local blocks = xd.mark(xd.attach_notes(xd.commonmark_lists(doc.blocks)):walk({ Inlines = xd.bind_double_signs }),
          xd.authority_entries(meta),
          function(k) cited[k] = true; return pandoc.RawInline("latex", "\\xd@amark{" .. k .. "}") end, keyed)
        xd.check(spec, doc.blocks)
        xd.switch_contents(spec, meta)
        -- links as their text when the court bars hyperlinks (layout.yaml links: false)
        blocks = xd.unlink(spec, blocks)
        local main, rest = xd.split_tail(spec, blocks)
        -- the body sections set before the tables (body_before_tables)
        local pre
        pre, main = xd.split_head(spec, main, meta)
        labels = xd.heading_labels(spec, blocks)
        -- the closing and after_tail trees now: their layout headings are rows of the contents
        local cnodes = xd.tree(spec, spec.closing, meta, false, true)
        local anodes = xd.tree(spec, spec.after_tail, meta, false, true)
        local bnodes = xd.tree(spec, spec.before_tables, meta, true, true)
        -- the layout's blocks between the contents and the authorities, and the body sections set there (place: between)
        local wnodes = xd.tree(spec, spec.between_tables, meta, true, true)
        local late = spec.body_before_tables and spec.body_before_tables.place == "between"
        local heads = xd.all_heads(spec, main, cnodes, rest, anodes, pre, bnodes, wnodes, late)
        local out = pandoc.Blocks({})
        local first = pandoc.Blocks({})
        -- the tables numbered apart (page_number.front): the cover unnumbered, the tables from i, the body from 1
        local front = spec.page_number and spec.page_number.front
        local TEX_FMT = { ["lower-roman"] = "roman", ["upper-roman"] = "Roman", decimal = "arabic" }
        -- page_number.cover: the cover counted in the tables' numbering (counted: unprinted; numbered: printed)
        local cmode = front and spec.page_number.cover
        local hidden = front and cmode ~= "numbered"
        if (spec.page_number and spec.page_number.from or 1) > 1 or hidden then first:insert(raw("\\thispagestyle{empty}")) end
        if cmode then first:insert(raw("\\pagenumbering{" .. TEX_FMT[front] .. "}")) end
        out:extend(first)
        -- a running footer (page_number.text with frontmatter fields, lines at "<br>"): \xd@foot, the lines the
        -- generated template's footer stacks, each a line box of the single pitch (lib/typst/xdoc.typ footer-lines)
        local pt = spec.page_number and spec.page_number.text
        if xd.is_running(pt) then
          local p = tonumber(spec.pitch.single)
          local al = spec.page_number.align or "center"
          local ls = {}
          for _, pieces in ipairs(xd.footer_lines(pt, meta)) do
            local il = pandoc.Inlines({})
            for _, x in ipairs(pieces) do
              if x.lit then
                for sp, w in x.lit:gmatch("(%s*)(%S*)") do
                  if sp ~= "" then il:insert(pandoc.Space()) end
                  if w ~= "" then il:insert(pandoc.Str(w)) end
                end
              elseif x.field then il:extend(xd.inlines(x.field))
              else il:insert(pandoc.RawInline("latex", x.key == "page" and "\\thepage{}" or "\\pageref*{xd@lastpage}")) end
            end
            ls[#ls + 1] = "\\setbox0\\hbox to\\textwidth{" .. (al ~= "left" and "\\hfil " or "") .. tex(il)
              .. (al ~= "right" and "\\hfil" or "") .. "}\\ht0=" .. bp(0.8 * p) .. "\\dp0=" .. bp(0.2 * p) .. "\\box0 "
          end
          out:insert(raw("\\expandafter\\gdef\\csname xd@foot\\endcsname{" .. table.concat(ls) .. "}"))
        end
        -- justified text: the body's spaces stretch from here (each block of the layout sets RAGGED in its group)
        if spec.justify then out:insert(raw("\\xd@justtrue\\selectfont")) end
        -- a cover numbered apart is unnumbered on every page it runs to (typst: no page label before the tables)
        -- the body sections before the tables on the cover's page (body_before_tables.place: cover, fb-595.92)
        local oncover = #pre > 0 and spec.body_before_tables.place == "cover"
        if oncover and (front or not spec.cover or spec.before_tables) then
          error("xdoc: body_before_tables.place: cover needs a cover numbered with the body (no page_number.front) and no before_tables", 0)
        end
        if spec.cover then
          -- a coloured cover (cover_fill): its pages' colour, the pages after it uncoloured
          local fill = spec.cover_fill and spec.cover_fill:gsub("^#", ""):upper()
          out:insert(raw((fill and ("\\pagecolor[HTML]{" .. fill .. "}") or "") .. (hidden and "\\pagestyle{empty}" or "")
            .. emit(xd.tree(spec, spec.cover, meta, true, true), false)))
          if oncover then out:extend((body(pre, 0, nil, spec.paragraph_gap))) end
          out:insert(raw(((spec.contents and spec.contents["break"] == false) and "" or "\\clearpage")
            .. (fill and "\\nopagecolor" or "") .. (hidden and "\\pagestyle{plain}" or "")))
        end
        -- without tables (or pages before them) the body follows the cover at once, numbered from 1 (typst: the tables'
        -- numbering unused)
        local tables = spec.contents or spec.authorities or spec.before_tables or spec.between_tables or #pre > 0
        if front and not cmode then out:insert(raw("\\pagenumbering{" .. (tables and TEX_FMT[front] or "arabic") .. "}")) end
        -- the pages before the tables, numbered with them: the layout's before_tables, the body sections set before them
        if spec.before_tables then out:insert(raw(emit(bnodes, false) .. "\\clearpage")) end
        if #pre > 0 and not late and not oncover then
          out:extend((body(pre, 0, nil, spec.paragraph_gap)))
          out:insert(raw("\\clearpage"))
        end
        -- the tables in a group: their line boxes end with them
        if spec.contents then out:insert(raw("\\begingroup" .. contents(spec.contents, heads) .. "\\par\\endgroup")) end
        if spec.between_tables then out:insert(raw("\\clearpage" .. emit(wnodes, false))) end
        if #pre > 0 and late then
          out:insert(raw("\\clearpage"))
          out:extend((body(pre, 0, nil, spec.paragraph_gap)))
        end
        if spec.authorities and meta.authorities then
          out:insert(raw("\\begingroup" .. (xd.is_keyed(meta) and keyed_authorities(spec.authorities, meta, cited)
            or authorities(spec.authorities, meta)) .. "\\par\\endgroup"))
        end
        if tables then
          out:insert(raw("\\clearpage" .. (front and "\\pagenumbering{arabic}" or "")))
        end
        -- the body's first page, for its page count (when: xd.pages, words.limit_pages; lib/latex/xdoc.sty)
        local paged_body = xd.uses_pages(spec)
        if paged_body then out:insert(raw("\\xd@pmark{start}")) end
        out:insert(raw(emit(xd.tree(spec, spec.front, meta, true, true), false)))
        -- the last paragraph kept whole on the page of the closing (keep_with_closing): no break in it or after it
        local kept
        main, kept = xd.last_para(spec, main)
        local mblocks, mlast = body(main, 0, nil, spec.paragraph_gap)
        out:extend(mblocks)
        if kept then
          out:insert(raw("\\par\\begingroup\\interlinepenalty=10000\\relax"))
          out:extend((body({ kept }, 0, nil, spec.paragraph_gap, mlast)))
          out:insert(raw("\\par\\endgroup\\nobreak"))
        end
        out:insert(raw(emit(cnodes, false)))
        -- the body's last page (the closing's), and the word limit of a body past words.limit_pages pages
        if paged_body then
          out:insert(raw("\\xd@pmark{end}"))
          if meta.xd and meta.xd.words_over then
            out:insert(raw("\\ifnum\\xd@bodypages>" .. string.format("%d", tonumber(spec.words.limit_pages))
              .. "\\relax\\PackageError{xdoc}{" .. meta.xd.words_over .. "}{}\\fi"))
          end
        end
        if #rest > 0 then
          local t = spec.tail
          out:insert(raw((t["break"] and "\\clearpage" or "") .. "\\par\\addvspace{" .. bp(t.above) .. "}" .. lines(t) .. "\\setlength{\\parindent}{"
            .. bp(t.indent) .. "}"))
          out:extend(body(rest, tonumber(t.gap) or 0, true))
        end
        -- the blocks after the tail (layout after_tail)
        if #anodes > 0 then out:insert(raw(emit(anodes, false))) end
        -- the last page, for a page-number text's {pages} (the generated template: \pageref*{xd@lastpage})
        if spec.page_number and spec.page_number.text then out:insert(raw("\\label{xd@lastpage}")) end
        return pandoc.Pandoc(out, doc.meta)
      end,
    },
  }
end

-- scb motion brief, docx engine. Mirrors typst/scb-motion-brief.typ; rules and conventions are in ../README.md.
-- Built here: the court title and the caption (")" column: party names, ")" on every row, the case information on the
-- right; Fed. R. Bankr. P. 9004(b)), the SC LBR 7012-1 notice page when the frontmatter has `notice`, the motion's
-- title, the facts numbered 1, 2, 3 ... inside the section named by `numbered_section` (argument prose is not
-- numbered), headings labelled A., B. (level 3) and 1., 2. (level 4), lettered lists a), b), block quotations, and the
-- signature block ("/s/" and the typed name; SC LBR 9011-4); the last two blocks stay on one page with it. Font,
-- footnotes and the page number are styles and section settings in docx/reference.xml (fb render builds the reference
-- document from it). Content-agnostic: every case word comes from the sample's frontmatter, except the rule text of
-- the notice, which is the SC LBR 7012-1 text copied from the typst template.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 324 a single line and a footnote line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local NOTICE = [[A motion to dismiss is a request that one or more issues in a case be decided without holding a trial. Motions to dismiss are governed by Rule 12, Federal Rules of Civil Procedure. Your complaint, or the portions of your complaint that the motion seeks to dismiss, may be dismissed if the court finds that the complaint does not contain sufficient allegations to state a claim upon which the court can grant relief. If you wish to oppose the motion to dismiss, you must file with the court and serve on the other party a written response within the time period set forth in a notice that will be separately mailed to you by the Clerk of Court. If you file a written response, a hearing will be held at the location and time set forth in the notice from the Clerk of Court. If you fail to file a timely written response to the motion, the court will consider the motion unopposed and may grant the motion without holding a hearing. This will result in the termination of the proceeding, or some part thereof, in favor of the moving party.]]

local BODY, SINGLE = 480, 324              -- typst pitch-body 24 pt, pitch-single 16.2 pt
local PARA_INDENT = 720                    -- typst para-indent 0.5 in
local NUMBER_BOX = 720                     -- typst number-box 0.5 in (a tab stop after the indent)
local LIST_INDENT, LETTER_BOX = 720, 576   -- typst list-indent 0.5 in, letter-box 0.4 in
local QUOTE_INDENT = 720                   -- typst quote-indent 0.5 in
local CAP_LEFT, CAP_PAREN = 4176, 360      -- typst caption-left 2.9 in, caption-paren 0.25 in
local TEXTW = 9360                         -- 6.5 in of text
local CAP_PAD, DESIGNATION_PAD = 216, 173  -- typst caption-pad 0.15 in, designation-pad 0.12 in
local VERSUS = 576                         -- typst versus-indent 0.4 in
local H3_BOX, H4_BOX = 720, 720            -- typst h3-box, h4-box 0.5 in
local SIG_LEFT = 4680                      -- typst sig-left 3.25 in
local CAPTION_ABOVE = 240                  -- typst caption-above 12 pt
local TITLE_ABOVE, TITLE_BELOW = 480, 240  -- typst title-above 24 pt, title-below 12 pt
local NOTICE_ABOVE, NOTICE_BELOW = 240, 240 -- typst notice-above, notice-below 12 pt
local HEADING_ABOVE = 240                  -- typst heading-above 12 pt
local QUOTE_ABOVE, QUOTE_BELOW, QUOTE_GAP = 240, 240, 216 -- typst quote-above, quote-below 12 pt, quote-gap 10.8 pt
local SIG_ABOVE, SIG_GAP = 480, 240        -- typst signature-above 24 pt, sig-gap 12 pt

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph: o = { style, keep, pbb, tab, before, after, line, left, hanging, first, right, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.pbb then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = nil
  if not o.hanging then first = o.first or 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function cell(width, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. inner .. '</w:tc>'
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption
-- ---------------------------------------------------------------------------

local function court_title(m, pbb)
  local out = {}
  for i, l in ipairs(items(m.court)) do out[#out + 1] = p(xe.inl(l), { jc = "center", pbb = pbb and i == 1 }) end
  return table.concat(out)
end

-- One row per printed line. Left: names ("~" right-aligned, ">" indented); middle: ")"; right: case data.
local function caption(m)
  local rows = {}
  -- The left entries as written (fb render's $FORMBOOK_META): pandoc reads ">v." as a quotation and drops its marker.
  local raw = {}
  local f = os.getenv("FORMBOOK_META")
  local h = f and io.open(f, "r")
  if h then
    local j = pandoc.json.decode(h:read("a"), false)
    h:close()
    for i, r in ipairs(j.caption.rows) do raw[i] = r[1] end
  end
  for i, r in ipairs(m.caption.rows) do
    local left, right = txt(r[1]), r[2]
    if raw[i] then left = raw[i] end
    local lp
    if left:sub(1, 1) == "~" then
      lp = p(xe.runs(left:sub(2)), { jc = "right", right = DESIGNATION_PAD })
    elseif left:sub(1, 1) == ">" then
      lp = p(xe.runs(left:sub(2)), { left = VERSUS })
    else
      lp = p(xe.inl(r[1]))
    end
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(CAP_LEFT, lp) .. cell(CAP_PAREN, p(xe.runs(")")))
      .. cell(TEXTW - CAP_LEFT - CAP_PAREN, p(xe.inl(right), { left = CAP_PAD })) .. '</w:tr>'
  end
  return xe.para({ xe.spacing(0, 0, CAPTION_ABOVE) }, "")
    .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT
    .. '"/><w:gridCol w:w="' .. CAP_PAREN .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_PAREN) .. '"/></w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

-- A centered bold title line on the body pitch, kept with the text after it.
local function title(text, before, after)
  return p(xe.runs(text, { b = true }), { keep = true, before = before, after = after, line = BODY, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Signature block (SC LBR 9011-4). The motion has "Respectfully submitted,"; the notice does not.
-- ---------------------------------------------------------------------------

local function signature(sig, respectfully)
  local x = {}
  local first = true
  local function line(body, gap)
    x[#x + 1] = p(body, { before = first and SIG_ABOVE or gap, left = SIG_LEFT, keep = true })
    first = false
  end
  if respectfully then line(xe.runs("Respectfully submitted,"), 0) end
  line(xe.inl(sig.firm), SIG_GAP)
  line(xe.runs("/s/ ") .. xe.inl(sig.signer), SIG_GAP)
  for _, l in ipairs(items(sig.lines)) do line(xe.inl(l), 0) end
  line(xe.inl(sig.role), 0)
  x[#x + 1] = p(xe.inl(sig.date), { before = SIG_GAP })
  return table.concat(x)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

-- A body paragraph: written here, or (one that anchors a footnote) left to pandoc in a "... Note" style, the label
-- typed before its text; o as p() for the paragraph written here.
local function body(label, inlines, o, note_style)
  if has_note(inlines) then
    local inl = pandoc.Inlines({})
    if label then inl:insert(pandoc.RawInline("openxml", xe.runs(label .. "\t"))) end
    inl:extend(inlines)
    return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = note_style })
  end
  return xe.raw(p((label and xe.runs(label .. "\t") or "") .. xe.inl(inlines), o))
end

local function kind(b)
  if b.t == "Header" then return "heading" end
  if b.t == "BlockQuote" then return "quote" end
  if b.t == "BulletList" or b.t == "OrderedList" then return "list" end
  if b.t == "Para" or b.t == "Plain" then return "para" end
  error("scb-motion-brief.lua: unexpected block " .. b.t)
end

-- The markdown blocks as units (typst chunks: a list item is one); each unit = { kind, block or item, index }.
local function units(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    local k = kind(b)
    if k == "list" then
      local n = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        out[#out + 1] = { k = k, item = item, n = b.t == "OrderedList" and n or nil }
        n = n + 1
      end
    else
      out[#out + 1] = { k = k, b = b }
    end
  end
  return out
end

local function motion(blocks, prefix, out)
  local us = units(blocks)
  local numbered = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local n = 0
  for i, u in ipairs(us) do
    local keep = i >= #us - 1
    local b = u.b
    if u.k == "heading" then
      local level = math.min(b.level, 4)
      if level <= 2 then numbered = prefix ~= nil and txt(b.content):sub(1, #prefix) == prefix end
      counts[level] = counts[level] + 1
      for q = level + 1, 6 do counts[q] = 0 end
      if level <= 2 then
        out[#out + 1] = xe.raw(p(xe.inl(b.content, { b = true }), { style = "Heading2", keep = true,
          before = HEADING_ABOVE, line = BODY, jc = "center" }))
      elseif level == 3 then
        out[#out + 1] = xe.raw(p(xe.runs(string.char(64 + counts[3]) .. ".\t", { b = true }) .. xe.inl(b.content, { b = true }),
          { style = "Heading3", keep = true, before = HEADING_ABOVE, line = BODY, left = H3_BOX, hanging = H3_BOX }))
      else
        out[#out + 1] = xe.raw(p(xe.runs(counts[4] .. ".\t", { b = true }) .. xe.inl(b.content, { b = true }),
          { style = "Heading4", keep = true, before = HEADING_ABOVE, line = BODY, left = PARA_INDENT + H4_BOX,
            hanging = H4_BOX }))
      end
    elseif u.k == "quote" then
      for j, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("scb-motion-brief.lua: a block quotation must hold paragraphs") end
        out[#out + 1] = body(nil, q.content, { keep = keep, before = j == 1 and QUOTE_ABOVE or QUOTE_GAP,
          left = QUOTE_INDENT, right = QUOTE_INDENT }, "Block Text")
      end
    elseif u.k == "list" then
      local label = u.n and (string.char(96 + u.n) .. ")") or "\u{2022}"
      out[#out + 1] = body(label, pandoc.utils.blocks_to_inlines(u.item), { keep = keep, line = BODY,
        left = LIST_INDENT + LETTER_BOX, hanging = LETTER_BOX }, "List Letter Note")
    else
      local after_quote = i > 1 and us[i - 1].k == "quote"
      if numbered then
        n = n + 1
        out[#out + 1] = body(n .. ".", b.content, { keep = keep, line = BODY, first = PARA_INDENT,
          tab = PARA_INDENT + NUMBER_BOX, before = after_quote and QUOTE_BELOW or 0 }, "Numbered Note")
      else
        out[#out + 1] = body(nil, b.content, { keep = keep, line = BODY, first = PARA_INDENT,
          before = after_quote and QUOTE_BELOW or 0 }, "Body Text Note")
      end
    end
  end
  return out
end

local function finish(doc)
  local m = doc.meta
  local sig = m.signature
  local out = {}
  if m.notice then
    out[#out + 1] = xe.raw(court_title(m, false) .. caption(m)
      .. title("NOTICE REQUIRED BY SC LBR 7012-1", NOTICE_ABOVE, NOTICE_BELOW)
      .. p(xe.runs("TO: ") .. xe.inl(m.notice.addressee), { line = BODY })
      .. p(xe.runs(NOTICE), { line = BODY, first = PARA_INDENT })
      .. signature(sig, false))
  end
  out[#out + 1] = xe.raw(court_title(m, m.notice ~= nil) .. caption(m)
    .. title(txt(m.title):upper(), TITLE_ABOVE, TITLE_BELOW))
  motion(doc.blocks, m.numbered_section and txt(m.numbered_section) or nil, out)
  out[#out + 1] = xe.raw(signature(sig, true))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }

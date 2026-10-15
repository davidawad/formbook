-- gamb.lua (docx engine): the adversary complaint as Word paragraphs (typst: gamb-adversary-complaint.typ).
-- pandoc writes the body with docx/reference.docx; this filter writes what the template sets by hand:
--   * the court lines, the Form 416D caption (a table: the parties on the left, the case information on the right,
--     a rule on the right and bottom of the party column), and the title;
--   * the paragraphs after the first heading, numbered 1, 2, ...; the "(a)" sub-items as hanging labels (render.sh
--     reads "(a)" as text, not as a list);
--   * the WHEREFORE paragraph, the date line and the signature blocks, kept together (keepNext).
-- Every number, name and address comes from the sample's frontmatter. Word may paginate slightly differently
-- from the LibreOffice PDF (docs/DOCX.md).

local stringify = pandoc.utils.stringify

local TEXT_W = 9360      -- the text width, 6.5 in, in twips
local CAP_LEFT = 5184    -- the party column of the caption, 3.6 in
local CAP_RIGHT = TEXT_W - CAP_LEFT
local SIG_LEFT = 4752    -- the signature column, 3.3 in from the left margin
local TAB_RUN = "<w:r><w:tab/></w:r>"

-- ---------------------------------------------------------------------------
-- XML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- A text run; o.b bold, o.i italic.
local function run(text, o)
  o = o or {}
  local x = (o.b and "<w:b/><w:bCs/>" or "") .. (o.i and "<w:i/><w:iCs/>" or "")
  if x ~= "" then x = "<w:rPr>" .. x .. "</w:rPr>" end
  return "<w:r>" .. x .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- A paragraph. o: keep (keepNext), tabs (a tab-stop position, twips), before, after (twips), line (240 single, 480
-- double), rule ("auto" or "exact"), left, right, first or hanging (indents), jc. The properties are in the schema's
-- order: keep, tabs, spacing, indent, justification.
local function P(o, body)
  local x = ""
  if o.keep then x = "<w:keepNext/><w:keepLines/>" end
  if o.tab then x = x .. '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  x = x .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>',
    o.before or 0, o.after or 0, o.line or 240, o.rule or "auto")
  if o.left or o.right or o.first or o.hanging then
    x = x .. "<w:ind"
    if o.left then x = x .. ' w:left="' .. o.left .. '"' end
    if o.right then x = x .. ' w:right="' .. o.right .. '"' end
    if o.first then x = x .. ' w:firstLine="' .. o.first .. '"' end
    if o.hanging then x = x .. ' w:hanging="' .. o.hanging .. '"' end
    x = x .. "/>"
  end
  if o.jc then x = x .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. x .. "</w:pPr>" .. (body or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- Inlines as Word runs (bold, italic and quotation marks kept; a footnote or a link keeps its text).
local function inl(list, o)
  o = o or {}
  local out = {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, o)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", o)
    elseif t == "Emph" then
      out[#out + 1] = inl(el.content, { b = o.b, i = true })
    elseif t == "Strong" then
      out[#out + 1] = inl(el.content, { b = true, i = o.i })
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], o) .. inl(el.content, o) .. run(q[2], o)
    elseif t == "Link" or t == "Span" then
      out[#out + 1] = inl(el.content, o)
    else
      out[#out + 1] = run(stringify(el), o)
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Caption and title (GAMB-CAP-001 to GAMB-CAP-003)
-- ---------------------------------------------------------------------------

local function court_lines(m)
  local out = {}
  for i, l in ipairs(m.court) do
    out[#out + 1] = P({ after = (i == #m.court) and 480 or 0, jc = "center" }, run(stringify(l), { b = true }))
  end
  return table.concat(out)
end

-- The party column: "In re:" before the debtor, "v." between the plaintiffs and the defendant, the role under
-- each party (typst: caption()).
local function party_lines(parties)
  local out = {}
  for i, p in ipairs(parties) do
    if i > 1 and stringify(parties[i - 1].kind) ~= "debtor" then
      out[#out + 1] = P({ before = 240, after = 240, left = 1728 }, run("v."))
    end
    if stringify(p.kind) == "debtor" then
      out[#out + 1] = P({ after = 240 }, run("In re:"))
    end
    for _, n in ipairs(p.names) do
      out[#out + 1] = P({}, run(stringify(n)))
    end
    out[#out + 1] = P({ left = 3168 }, run(stringify(p.role)))
  end
  return table.concat(out)
end

local function caption(m)
  local adv = stringify(m.adversary_number)
  local left = party_lines(m.parties) .. P({ after = 240 })
  local right = P({ before = 60, after = 240, left = 504 }, run("Bankruptcy Case No. " .. stringify(m.case_number)))
    .. P({ after = 240, left = 504 }, run("Chapter " .. stringify(m.chapter)))
    .. P({ after = 240, left = 504 }, run("Adversary Proceeding No. " .. (adv == "" and "________" or adv)))
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_RIGHT .. '"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders></w:tcPr>' .. left .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_RIGHT .. '" w:type="dxa"/></w:tcPr>' .. right .. "</w:tc>"
    .. "</w:tr></w:tbl>"
end

local function title(m)
  return P({ before = 480, after = 240, left = 468, right = 468, jc = "center" },
    run(string.upper(stringify(m.title)), { b = true }))
end

-- ---------------------------------------------------------------------------
-- Body (GAMB-CONT-002)
-- ---------------------------------------------------------------------------

-- A chunk that starts with a lettered label, "(a)" or "(iv)": a sub-item.
local function is_label(el)
  return el ~= nil and el.t == "Str" and el.text:match("^%([%w]+%)$") ~= nil
end

-- A lettered sub-item: the label at half an inch, a tab, then the text from one inch; the lines after the first
-- start at one inch. Double-spaced like the body (typst: the grid in the body() block).
local function sub_item(b)
  local rest = b.content
  local i = 2
  if rest[i] and (rest[i].t == "Space" or rest[i].t == "SoftBreak") then i = i + 1 end
  local tail = {}
  for j = i, #rest do tail[#tail + 1] = rest[j] end
  return raw(P({ tab = 1440, line = 480, rule = "exact", left = 1440, hanging = 720 },
    run(rest[1].text) .. TAB_RUN .. inl(tail)))
end

-- The signature blocks: "Respectfully submitted," then one block per attorney (LBR 9011-1(b)); kept together.
local function signature(m)
  local out = { P({ keep = true, before = 480, after = 480 }, run(stringify(m.date))) }
  out[#out + 1] = P({ keep = true, after = 480, left = SIG_LEFT }, run("Respectfully submitted,"))
  -- one unbreakable run for all attorneys (typst: one block); a space follows each attorney's block
  local lines = {}
  for _, s in ipairs(m.signature) do
    local block = { "/s/ " .. stringify(s.signer), stringify(s.signer), stringify(s.bar) }
    for _, l in ipairs(s.firm) do block[#block + 1] = stringify(l) end
    block[#block + 1] = stringify(s.phone)
    block[#block + 1] = stringify(s.email)
    for i, l in ipairs(block) do
      lines[#lines + 1] = { text = l, gap = i == #block }
    end
    lines[#lines + 1] = { text = stringify(s.role), italic = true, gap = true }
  end
  for i, l in ipairs(lines) do
    local last = i == #lines
    out[#out + 1] = P({ keep = not last, after = l.gap and 480 or 0, left = SIG_LEFT }, run(l.text, { i = l.italic }))
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local blocks = {}
  local function add(x) blocks[#blocks + 1] = x end

  add(raw(court_lines(m)))
  add(raw(caption(m)))
  add(raw(title(m)))

  -- paragraphs after the first heading are numbered; a paragraph before it is the unnumbered lead-in
  local seen, k = false, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      seen = true
      add(b)
    elseif b.t == "Para" and is_label(b.content[1]) then
      add(sub_item(b))
    elseif b.t == "Para" and seen then
      k = k + 1
      local content = { pandoc.Str(k .. "."), pandoc.RawInline("openxml", TAB_RUN) }
      for _, x in ipairs(b.content) do content[#content + 1] = x end
      add(pandoc.Para(content))
    else
      add(b)
    end
  end

  -- the WHEREFORE paragraph stays with the signature (typst: sticky)
  add(raw(P({ keep = true, before = 0, after = 0, line = 480, rule = "exact", first = 720 },
    run(stringify(m.wherefore)))))
  add(raw(signature(m)))
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

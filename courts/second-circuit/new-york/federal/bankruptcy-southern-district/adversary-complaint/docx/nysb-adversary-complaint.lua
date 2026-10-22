-- nysb adversary complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it
-- reads and breaks as typst/nysb-adversary-complaint.typ does: the cover (counsel, LBR 9004-1(a)(4); the court; the
-- Form 416D caption, a table whose party column has a right and a bottom rule, the debtors' note marked "*" on their
-- last name; the title) in a section without a page number, then the body numbered from 1: the numbered paragraphs (Fed.
-- R. Civ. P. 10(b); a paragraph marked "^" is not numbered), the headings (level 1 centered capitals, level 2 lettered
-- A., B., ... in each level 1 section), the prayer items lettered (a), (b), ..., and the signature block (a table).
-- Numbers and letters are typed text, as the typst template types them. Every case word comes from the frontmatter
-- and the body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. fb render
-- (tools/fb/src/docxpass.rs) writes the footers the sections name (rIdFtrNone, rIdFtrPage, the cover note's from
-- FORMBOOK_FOOTERS) and the last section
-- (FORMBOOK_FINAL).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276                -- typst pitch-body, pitch-single
local TEXTW = 9360                           -- typst text-width: 6.5 in
local CAP_LEFT, CAP_GUTTER = 4824, 288       -- typst caption-left 3.35 in, caption-gutter 0.2 in
local CAP_INSET = 216                        -- typst caption-inset 0.15 in
local RULE = 15                              -- the 0.75 pt bottom rule LibreOffice adds to the cell's height (typst
                                             -- strokes take no room): the cell's bottom padding is that much less
local SIG_LEFT, SIG_GUTTER = 4032, 288       -- typst sig-left 2.8 in, sig-gutter 0.2 in
local GROUP_GAP = 138                        -- typst group-gap (half a single line)
local PARTY_GAP = 138                        -- typst party-gap (half a single line)
local BLOCK_GAP = 276                        -- typst block-gap (a blank single line)
local TITLE_ABOVE = 276                      -- typst title-above
local FOOTER = 735                           -- the page number's line 36.75 pt above the page foot (typst footer-descent 30 %)
local NOTE_CLEAR = 130                       -- the cover note's rule to its text: 6.5 pt, where the typst render sets its
                                             -- footnote separator above the note
-- the cover note's mark: "*" raised as a footnote mark is (typst: a footnote numbered "*")
local NOTE_MARK = '<w:r><w:rPr><w:vertAlign w:val="superscript"/></w:rPr><w:t>*</w:t></w:r>'
local COURT = { "UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF NEW YORK" } -- Form 416D; Fed. R. Bankr. P. 9004(b)

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
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

-- Paragraph properties: o = { style, keep, before, after, line, left, hanging, first, jc, tab }; single pitch by default.
local function props(o)
  local pr = {}
  if o.style then pr[#pr + 1] = xe.style(o.style) end
  if o.keep then pr[#pr + 1] = xe.KEEP end
  if o.tab then pr[#pr + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  pr[#pr + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  pr[#pr + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  pr[#pr + 1] = xe.jc(o.jc or "left")
  if o.sect then pr[#pr + 1] = o.sect end
  return pr
end

local function p(body, o)
  return xe.para(props(o or {}), body or "")
end

-- A section's properties: its footer (fb render's rIdFtrNone or rIdFtrPage, or the cover's note) and the footer's
-- distance from the page foot, the page numbers, letter paper with 1-inch margins.
local function sect_pr(footer, start, distance)
  local pg = start and ('<w:pgNumType w:fmt="decimal" w:start="' .. start .. '"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. (distance or FOOTER) .. '" w:gutter="0"/>' .. pg .. '</w:sectPr>'
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A one-row table without rules or cell padding: the opening up to the first cell's paragraphs, a cell break, and the
-- close; cells = { { width, tcPr children } }.
local function tbl_open(cells)
  local grid = {}
  for _, c in ipairs(cells) do grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
end
local function tc_open(c)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[2] or "") .. '</w:tcPr>'
end
local TC_CLOSE, TBL_CLOSE = '</w:tc>', '</w:tr></w:tbl>'
-- ---------------------------------------------------------------------------
-- The cover: counsel, the court, the caption, the title; its section has no page number. The debtors' note (their
-- tax-identification numbers, as in the exemplar) is marked "*" on their last name and set at the foot of the cover,
-- in the cover section's footer: a Word footnote would take a number, and LibreOffice cannot number the body's notes
-- from 1 again after it (typst: a footnote numbered "*", the body's notes counted from 1).
-- ---------------------------------------------------------------------------

local function cover(m)
  local x = {}
  local function add(s) x[#x + 1] = s end
  for k, g in ipairs(items(m.counsel)) do
    for i, l in ipairs(items(g)) do add(p(xe.inl(l), { before = (k > 1 and i == 1) and GROUP_GAP or 0 })) end
  end
  if m.counsel_for then add(p(xe.inl(m.counsel_for, { i = true }), { before = GROUP_GAP })) end
  add(p(xe.runs(COURT[1], { b = true }), { before = BLOCK_GAP, jc = "center" }))
  add(p(xe.runs(COURT[2], { b = true }), { jc = "center" }))
  -- Word has no space before a table: the court's last line would take it as space after; an empty line box of the
  -- gap's height does the same and keeps the court lines plain.
  add(xe.para({ xe.spacing(0, 0, BLOCK_GAP) }, ""))

  -- the caption: the party column (right and bottom rules), the case data
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  local left = { CAP_LEFT, '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/><w:bottom w:w="' .. (CAP_INSET - RULE) .. '" w:type="dxa"/></w:tcMar>' }
  local right = { TEXTW - CAP_LEFT, '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + CAP_INSET) .. '" w:type="dxa"/></w:tcMar>' }
  add(tbl_open({ left, right }) .. tc_open(left))
  local c = m.caption
  local note
  local function party(pt, above)
    local names = items(pt.names)
    for i, n in ipairs(names) do
      local mark = ""
      if i == #names and pt.note then
        note = pt.note
        mark = NOTE_MARK
      end
      add(p(xe.inl(n) .. mark, { before = i == 1 and above or 0 }))
    end
    add(p(xe.inl(pt.designation), { jc = "right" }))
  end
  party(c.debtors, 0)
  local sep = c.separator and plain(c.separator) or "against"
  for k, pt in ipairs(items(c.parties)) do
    if k > 1 then add(p(xe.runs(sep), { before = PARTY_GAP, jc = "center" })) end
    party(pt, PARTY_GAP)
  end
  add(TC_CLOSE .. tc_open(right))
  add(p(xe.runs("Chapter " .. plain(m.chapter))))
  add(p(xe.runs("Case No. " .. plain(m.case_number)), { before = BLOCK_GAP }))
  if m.jointly_administered == true then add(p(xe.runs("(Jointly Administered)"))) end
  add(p(xe.runs("Adv. Pro. No. " .. plain(m.adv_proc_no)), { before = BLOCK_GAP }))
  add(TC_CLOSE .. TBL_CLOSE)

  -- the cover's footer: the note under a rule 30 % of the measure long (typst's footnote separator), its last line
  -- at the foot of the text (footer distance 1440); without a note, no footer
  local footer, distance = "rIdFtrNone", FOOTER
  if note then
    footer, distance = "rIdFtrNote", 1440
    local rule_line = xe.para({ '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>',
      xe.spacing(0, NOTE_CLEAR, 20), xe.ind(0, nil, 0, TEXTW - TEXTW * 3 // 10) }, "")
    local text = p(NOTE_MARK .. xe.runs(" ") .. xe.inl(note), { keep = true })
    write_file("FORMBOOK_FOOTERS", footer .. "\t" .. rule_line .. text .. "\n")
  end
  -- the title, a blank single line below the caption (Word has no space after a table: the title takes it before);
  -- it ends the cover's section
  add(p(xe.inl(m.title, { b = true }), { before = TITLE_ABOVE, jc = "center", sect = sect_pr(footer, nil, distance) }))
  return table.concat(x)
end



-- ---------------------------------------------------------------------------
-- Signature block: "Dated:" at the left; the firm, "By: /s/" and the signer's lines at the right; the row never
-- splits. The double line above it is the last paragraph's space after (Body Keep, Lettered Keep).
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local left = { SIG_LEFT }
  local right = { TEXTW - SIG_LEFT, '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>' }
  local out = { tbl_open({ left, right }), tc_open(left), p(xe.runs("Dated: ") .. xe.inl(m.date), { keep = true }),
    TC_CLOSE, tc_open(right) }
  for _, l in ipairs(items(sig.firm)) do out[#out + 1] = p(xe.inl(l), { keep = true }) end
  out[#out + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = BLOCK_GAP, keep = true })
  out[#out + 1] = p(xe.inl(sig.signer), { keep = true })
  for _, l in ipairs(items(sig.lines)) do out[#out + 1] = p(xe.inl(l), { keep = true }) end
  out[#out + 1] = TC_CLOSE .. TBL_CLOSE
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function labelled(style, label, content)
  local inl = pandoc.Inlines({ pandoc.Str(label), TAB })
  inl:extend(content)
  return styled(style, inl)
end

-- Headings on the body pitch, kept with what follows: level 1 centered bold capitals; level 2 bold, its letter in a
-- half-inch box (a tab), the title hanging after it.
local function heading(level, label, content)
  if level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return xe.raw(xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(content, { b = true })))
  end
  return xe.raw(xe.para({ xe.style("Heading2"), xe.KEEP, '<w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs>',
    xe.spacing(0, 0, BODY), xe.ind(720, 720), xe.jc("left") }, xe.runs(label .. "\t", { b = true }) .. xe.inl(content, { b = true })))
end

-- "^" at the start of a paragraph: not numbered (the opening paragraph, the WHEREFORE clause).
local function unmarked(inl)
  local first = inl[1]
  if not (first and first.t == "Str" and first.text:sub(1, 1) == "^") then return nil end
  local rest = pandoc.Inlines({})
  if #first.text > 1 then rest:insert(pandoc.Str(first.text:sub(2))) end
  for i = 2, #inl do rest:insert(inl[i]) end
  if rest[1] and rest[1].t == "Space" then rest:remove(1) end
  return rest
end

local function body(blocks)
  -- the last paragraph or list item keeps with the signature block
  local last = 0
  for i, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" or b.t == "OrderedList" or b.t == "BulletList" then last = i end
  end
  local out = {}
  local n, sub = 0, 0
  for i, b in ipairs(blocks) do
    local keep = i == last
    if b.t == "Header" then
      local level = math.min(b.level, 2)
      if level == 1 then sub = 0 else sub = sub + 1 end
      out[#out + 1] = heading(level, string.char(64 + math.max(sub, 1)) .. ".", b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      local rest = unmarked(b.content)
      if rest then
        out[#out + 1] = styled(keep and "Body Keep" or "Body Text", rest)
      else
        n = n + 1
        out[#out + 1] = labelled(keep and "Body Keep" or "Body Number", n .. ".", b.content)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and ("(" .. string.char(96 + k) .. ")") or "\u{2022}"
        out[#out + 1] = labelled((keep and k == #b.content) and "Lettered Keep" or "Lettered", label,
          pandoc.utils.blocks_to_inlines(item))
      end
    else
      error("nysb-adversary-complaint.lua: unexpected block " .. b.t)
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there): the space becomes a no-break space, as wide. A space before a footnote mark is dropped, as the typst
-- template does (its markdown renderer trims it). A doubled section sign or pilcrow stays with its number ("§§ 544":
-- the typst template boxes it): a no-break space after it.
local function inline_rules(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    local a = l[i]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  local out = pandoc.Inlines({})
  for i, el in ipairs(l) do
    local nxt = l[i + 1]
    if not (el.t == "Space" and nxt and nxt.t == "Note") then out:insert(el) end
  end
  return out
end

local function finish(doc)
  local m = doc.meta
  local out = pandoc.Blocks(body(doc.blocks))
  out = out:walk({ Inlines = xe.inlines })
  out:insert(1, xe.raw(cover(m)))
  out:insert(xe.raw(signature(m)))
  -- the body's section: the page number centered, from 1
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", 1))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = inline_rules }, { Pandoc = finish } }

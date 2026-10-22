-- nmib-motion-brief.lua (docx engine, Bankruptcy Court of the Northern Mariana Islands, motion with a memorandum of
-- law): the memorandum as Word paragraphs, so that it reads and breaks as typst/nmib-motion-brief.typ does: the cover
-- (counsel block, court title, caption table with the hearing data, LBR 5005-1(b)), the table of contents and the
-- table of authorities with their pages, the body (headings labelled A., 1., a.) and the signature block. Every case
-- word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered line, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES: the contents' title, each heading with the words after it, each `toa:` link with the words
-- after it) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle. Three
-- sections: the cover (no number), the tables (roman from i) and the memorandum (arabic from 1; FORMBOOK_FINAL). Each
-- names a footer of FORMBOOK_FOOTERS: the numbers 1 to 24 in a frame on the page where typst draws them, the three
-- pleading rules the height of the page (VML lines) and, after the cover, the page number 6 pt under the last
-- numbered line. Word may paginate slightly differently from LibreOffice.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 240            -- typst pitch, pitch-single
local DROP = 192                         -- typst single-drop: 0.8 x (24 - 12) pt
local LINES = 24                         -- typst lines-per-page
local TOP = 2160                         -- typst top-margin, 1.5 in
local TEXTW = 8928                       -- typst text-width, 6.2 in
local NUMCOL = 1224                      -- typst number-col, 1.3 in - 0.45 in
local INDENT = 720                       -- typst para-indent, 0.5 in
local TAB = 720                          -- typst heading-tab, 0.5 in
local DESIG = 1440                       -- typst designation-indent, 1 in
local CAP_HALF = 4464                    -- the caption's columns, 1fr each (3.1 in)
local CAP_PAD = 240                      -- typst caption-pad, 12 pt
local CAP_FOOT = 225                     -- typst pitch-single below the party column, less the 0.75 pt rule Word adds
local SIG_COL, SIG_LINE = 4608, 3744     -- typst sig-col 3.2 in, sig-line 2.6 in
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-col 36 pt, toa-col 72 pt
local FOOT_SZ = 22                       -- typst footer-size, 11 pt
local FOOTER = 1800                      -- the page number's 12 pt line ends 90 pt above the page foot (typst footer-gap 6 pt under line 24)
local PASSIM = 7                         -- typst passim-threshold
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

local function list(m)
  local out = {}
  for _, v in ipairs(m or {}) do out[#out + 1] = v end
  return out
end

-- A paragraph: o = { before, line, left, right, first, hanging, tabs, jc, keep, lines, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- One single line; an empty item is a blank single line (typst: single).
local function single(text, o)
  o = o or {}
  local t = plain(text)
  return p(t == "" and "" or xe.inl(text, o.r), o)
end

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Footers and sections
-- ---------------------------------------------------------------------------

-- The pleading rules (typst pleading-rules): a double rule 0.2 in and 0.16 in left of the text, a single rule 0.1 in
-- right of it, the full height of the page; VML lines placed on the page, behind the text.
local function vline(x)
  return '<w:r><w:pict><v:line xmlns:v="urn:schemas-microsoft-com:vml" from="' .. x .. 'pt,0" to="' .. x ..
    'pt,792pt" strokeweight="0.75pt" strokecolor="black" style="position:absolute;' ..
    'mso-position-horizontal-relative:page;mso-position-vertical-relative:page;z-index:-1"/></w:pict></w:r>'
end
local RULES_VML = vline(79.2) .. vline(82.08) .. vline(547.2)

local function sz(x) return '<w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/><w:szCs w:val="' .. FOOT_SZ .. '"/></w:rPr>' .. x end
local PAGE = '<w:r>' .. sz('<w:fldChar w:fldCharType="begin"/>') .. '</w:r><w:r>' ..
  sz('<w:instrText xml:space="preserve"> PAGE </w:instrText>') .. '</w:r><w:r>' ..
  sz('<w:fldChar w:fldCharType="separate"/>') .. '</w:r><w:r>' .. sz('<w:t>1</w:t>') .. '</w:r><w:r>' ..
  sz('<w:fldChar w:fldCharType="end"/>') .. '</w:r>'

-- The numbers 1 to 24, one per numbered line, in a frame ending 0.45 in left of the text (typst line-numbers);
-- then the page number line (empty on the cover).
local function footer(numbered)
  local out = {}
  local nf = '<w:framePr w:w="' .. NUMCOL .. '" w:hSpace="0" w:wrap="around" w:vAnchor="page" w:hAnchor="page" ' ..
    'w:x="0" w:y="' .. TOP .. '"/>'
  for i = 1, LINES do
    out[#out + 1] = xe.para({ nf, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("right") }, xe.runs(tostring(i)))
  end
  out[#out + 1] = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
    RULES_VML .. (numbered and PAGE or ""))
  return table.concat(out)
end

local function sect_pr(footer_id, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer_id .. '"/>' ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="1440" w:bottom="2160" w:left="1872" ' ..
    'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' .. pg .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(footer_id, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' ..
    sect_pr(footer_id, fmt) .. '</w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

-- The text of a block's inlines in order, with each `toa:` link marked: { {text}, {link = key, text}, ... }.
local function pieces(inlines, out)
  out = out or {}
  for _, el in ipairs(inlines) do
    if el.t == "Link" and el.target:match("^toa:") then
      out[#out + 1] = { link = el.target:sub(5), text = stringify(el.content) }
    elseif el.t == "Str" then
      out[#out + 1] = { text = el.text }
    elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then
      out[#out + 1] = { text = " " }
    elseif el.content and type(el.content) ~= "string" then
      pieces(el.content, out)
    else
      out[#out + 1] = { text = stringify(el) }
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function two_col(lw, left_pr, left, right_pr, right)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    lw .. '"/><w:gridCol w:w="' .. (TEXTW - lw) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(lw, left_pr, left) .. cell(TEXTW - lw, right_pr, right) .. '</w:tr></w:tbl>'
end

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function cover(meta, out)
  for i, l in ipairs(list(meta.counsel)) do out[#out + 1] = single(l, { before = i == 1 and DROP or 0 }) end
  out[#out + 1] = single("")
  out[#out + 1] = p(xe.inl(meta.counsel_role, { i = true }))
  for i, l in ipairs(list(meta.court)) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }), { jc = "center", before = i == 1 and BODY or 0 })
  end
  local left = {}
  for i, side in ipairs(list(meta.caption)) do
    if i > 1 then
      left[#left + 1] = single("")
      left[#left + 1] = p(xe.runs("v."), { jc = "center" })
      left[#left + 1] = single("")
    end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = single(n) end
    left[#left + 1] = single("")
    left[#left + 1] = single(side.designation, { left = DESIG })
  end
  local right = {
    single("Case No. " .. plain(meta.case_number)),
    single("Chapter " .. plain(meta.chapter)),
    single(""),
    p(xe.runs(pandoc.text.upper(plain(meta.brief_title)), { b = true })),
  }
  -- LBR 5005-1(b)(2): the hearing date and time and the presiding judge, when the paper is set for hearing
  local hearing = meta.hearing or {}
  local first = true
  for _, kv in ipairs({ { "date", "Hearing Date:" }, { "time", "Hearing Time:" }, { "judge", "Judge:" } }) do
    if hearing[kv[1]] ~= nil then
      if first then right[#right + 1] = single("") end
      first = false
      right[#right + 1] = p(xe.runs(kv[2] .. " ") .. xe.inl(hearing[kv[1]]))
    end
  end
  -- a numbered line above the caption (Word has no space around a table)
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = two_col(CAP_HALF,
    RULES .. '<w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>',
    left, '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>', right)
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities: rows with a dot leader to the page column
-- ---------------------------------------------------------------------------

local function table_head(title, col_label, brk)
  return {
    p(xe.runs(pandoc.text.upper(title), { b = true }), { jc = "center", line = BODY, keep = true, brk = brk }),
    p(xe.runs(col_label, { b = true }), { jc = "right", before = DROP, keep = true }),
  }
end

local function row(text, page, left, hanging, col, page_o)
  return p(text .. xe.runs(xe.LEAD) .. xe.runs(page, page_o), { lines = true, tabs = xe.leader_tab(TEXTW),
    before = SINGLE, left = left, hanging = hanging, right = col })
end

local function contents(entries, out)
  for _, x in ipairs(table_head("Table of Contents", "Page")) do out[#out + 1] = x end
  for _, e in ipairs(entries) do
    local ind = math.max(e.level - 2, 0) * TAB
    local text = e.level == 1 and xe.runs(pandoc.text.upper(plain(e.title))) or
      (xe.runs(e.label .. "\t") .. xe.inl(e.title))
    out[#out + 1] = row(text, labels[e.id] or "0", ind + TAB, TAB, TOC_COL)
  end
end

local GROUPS = {
  { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" },
  { "local", "Local Bankruptcy Rules" }, { "other", "Other Authorities" },
}

local function authorities(meta, hits, out)
  for _, x in ipairs(table_head("Table of Authorities", "Page(s)", true)) do out[#out + 1] = x end
  local auth = meta.authorities or {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if hits[key] and plain(a.kind) == g[1] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      local kx = plain(x.a.name ~= nil and x.a.name or x.a.cite):lower()
      local ky = plain(y.a.name ~= nil and y.a.name or y.a.cite):lower()
      return kx < ky
    end)
    if #members > 0 then
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = BODY, keep = true })
      for _, m in ipairs(members) do
        local text = ""
        if m.a.name ~= nil then text = xe.inl(m.a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        text = text .. xe.inl(m.a.cite)
        local pages, seen = {}, {}
        for _, id in ipairs(hits[m.key]) do
          local l = labels[id] or "0"
          if not seen[l] then
            seen[l] = true
            pages[#pages + 1] = l
          end
        end
        local passim = #pages >= PASSIM
        out[#out + 1] = row(text, passim and "passim" or table.concat(pages, ", "), TAB, TAB, TOA_COL,
          passim and { i = true } or nil)
      end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Heading labels: level 2 "A.", level 3 "1.", level 4 "a."; a level 1 heading starts the lettering again.
local ctr = { 0, 0, 0, 0 }
local function label(level)
  if level == 1 then
    for i = 2, 4 do ctr[i] = 0 end
    return ""
  end
  level = math.min(level, 4)
  ctr[level] = ctr[level] + 1
  for i = level + 1, 4 do ctr[i] = 0 end
  if level == 2 then return string.char(64 + ctr[2]) .. "." end
  if level == 3 then return tostring(ctr[3]) .. "." end
  return string.char(96 + ctr[4]) .. "."
end

-- Headings: numbered lines, a numbered line above (none where the memorandum starts), kept with the text: level 1
-- centered bold capitals; deeper levels bold, the label in a half-inch box at its level's indent, the lines after the
-- first hanging after it.
local function heading(b, lab, first)
  local o = { line = BODY, keep = true, before = first and 0 or BODY }
  if b.level == 1 then
    o.jc = "center"
    return p(xe.runs(pandoc.text.upper(stringify(b.content)), { b = true }), o)
  end
  o.left, o.hanging = math.max(b.level - 2, 0) * TAB + TAB, TAB
  return p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(b.content, { b = true }), o)
end

-- The signature block: "Dated:" at the left; at the right "Respectfully submitted," and for each signer a signature
-- line, the name and the role. A numbered line above it, inside the table (typst: inside the block).
local function signature(meta, out)
  local right = { single("Respectfully submitted,") }
  local s = meta.signature or {}
  local signers = s.signer ~= nil and { s } or list(s)
  local u = { u = true }
  for _, sg in ipairs(signers) do
    right[#right + 1] = single("")
    right[#right + 1] = single("")
    right[#right + 1] = p(xe.runs("/s/\t", u), { tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. SIG_LINE .. '"/></w:tabs>' })
    right[#right + 1] = single(sg.signer)
    for _, l in ipairs(list(sg.lines)) do right[#right + 1] = single(l) end
  end
  local top = '<w:tcMar><w:top w:w="' .. (BODY + DROP) .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = two_col(TEXTW - SIG_COL, top, { p(xe.runs("Dated: ") .. xe.inl(meta.date)) }, top, right)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1334(b)"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local auth = meta.authorities or {}
  local blocks = doc.blocks

  -- the needles, in document order: the contents (roman from i), the memorandum's first words (arabic from 1),
  -- each heading with its label and the words after it, each `toa:` link with the words after it
  need("S:front", "TABLE OF CONTENTS", "Page")
  -- the memorandum starts at its first block: its own needle, or the first heading's (a needle is searched after the
  -- one before it, so the same place cannot be found twice)
  local body_id = "H:1"
  if blocks[1] and blocks[1].t ~= "Header" then
    body_id = "S:body"
    need(body_id, stringify(blocks[1]):sub(1, 60))
  end
  local entries, hits, h_n, t_n = {}, {}, 0, 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      local lab = label(b.level)
      b.attr = pandoc.Attr("", {}, { { "label", lab } })
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      need(id, (lab ~= "" and (lab .. " ") or "") .. stringify(b.content), nxt)
      if b.level <= 4 then entries[#entries + 1] = { id = id, level = b.level, label = lab, title = b.content } end
    elseif b.content and (b.t == "Para" or b.t == "Plain") then
      local ps = pieces(b.content)
      for k, x in ipairs(ps) do
        if x.link then
          if auth[x.link] == nil then
            error("nmib-motion-brief: link `toa:" .. x.link .. "` has no entry under `authorities:`", 0)
          end
          t_n = t_n + 1
          local id = "T:" .. t_n
          local after = {}
          for j = k + 1, #ps do after[#after + 1] = ps[j].text end
          need(id, x.text, table.concat(after):sub(1, 60))
          hits[x.link] = hits[x.link] or {}
          hits[x.link][#hits[x.link] + 1] = id
        end
      end
    end
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, "B", n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:front\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdNmibCover\t" .. footer(false) .. "\nrIdNmibPage\t" .. footer(true) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdNmibPage", "decimal"))

  blocks = blocks:walk({ Str = breaks })
  local out = {}
  cover(meta, out)
  out[#out + 1] = section_end("rIdNmibCover")
  contents(entries, out)
  authorities(meta, hits, out)
  out[#out + 1] = section_end("rIdNmibPage", "lowerRoman")
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b, b.attr.attributes["label"] or "", i == 1)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("nmib-motion-brief.lua: a list item holds one paragraph")
        end
        local lab = b.t == "OrderedList" and ((b.listAttributes.start + j - 1) .. ".") or "\u{2022}"
        out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = INDENT, hanging = INDENT })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    else
      error("nmib-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end

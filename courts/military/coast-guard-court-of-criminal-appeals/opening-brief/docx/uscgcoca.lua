-- uscgcoca brief, docx engine (docs/DOCX.md): the typst template ../typst/uscgcoca-*.typ as Word paragraphs, on the
-- cross-engine layout model (docs/EVAL-LOOP.md, "Cross-engine gate"; lib/docx/xengine.lua), so the LibreOffice PDF
-- breaks every line and page where the typst render does. pandoc writes the body text (paragraphs, block
-- quotations, footnotes) with docx/reference.xml's styles; this filter writes the caption (two columns as a table),
-- the headings, the lists, the signature (R. 14) and the certificates of compliance (R. 17.3) and service
-- (R. 17.2(a)(5)), every paragraph with exact line spacing at the typst pitches and the typst spaces, in twips
-- (1 pt = 20). The last section (letter, 1 in margins, the page number footer) goes to FORMBOOK_FINAL.
-- No case-specific text, no forced line breaks.

local xe = require("docx.xengine")
local para, raw, ind, jc, runs, inl = xe.para, xe.raw, xe.ind, xe.jc, xe.runs, xe.inl
local KEEP, LINES, BREAK = xe.KEEP, xe.LINES, xe.BREAK

-- typst parameters, in twips
local BODY = 560        -- pitch-body: 28 pt, double-spaced (R. 17.1)
local SINGLE = 300      -- pitch-single: 15 pt (R. 17.1: at least 15-point spacing)
local INDENT = 720      -- para-indent
local SP_H1 = 240       -- sp-h1: above a section heading
local SP_H = 160        -- sp-h: above an issue or sub-heading
local SP_QUOTE = 120    -- sp-quote (Block Text in reference.xml)
local SP_CAPTION = 240  -- sp-caption
local SP_DESIG = 80     -- sp-desig
local SP_BLOCK = 360    -- sp-block
local SP_CERT = 120     -- sp-cert
local SIG_LEFT = 4608   -- sig-left: 3.2 in
local SIG_RULE = 4032   -- sig-rule: 2.8 in
local RULE_H = 200      -- a rule's block: 10 pt
local TEXT_W = 9360     -- 6.5 in
local GUTTER = 576      -- col-gutter: 0.4 in
local COL = (TEXT_W - GUTTER) // 2
local ADDRESS_IN = 936  -- the address line is centered in 5.2 in

local COURT_NAME = "IN THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS"
local ADDRESS = "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS"
local WORD_LIMIT = "20,000"
local DEFAULT_RECIPIENT = "the Court and opposing counsel"
-- the default title is the only line that differs between the doc-type folders (typst: brief-title)
local DEFAULT_TITLE = "ASSIGNMENTS OF ERROR AND BRIEF ON BEHALF OF APPELLANT"

local stringify = pandoc.utils.stringify

-- A frontmatter value as typst prints it: typst reads the YAML as plain strings, so no smart quotes, no
-- abbreviation no-break spaces and no markdown.
local function plain(v)
  if v == nil then return "" end
  local s = type(v) == "string" and v or stringify(v)
  s = s:gsub("\u{2019}", "'"):gsub("\u{2018}", "'"):gsub("\u{201C}", '"'):gsub("\u{201D}", '"'):gsub("\u{00A0}", " ")
  return s
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then return v end
  return { v }
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- one single-spaced line block (typst line-block): `before` above it, `left` in, aligned `al`
local function line(before, body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = KEEP end
  props[#props + 1] = xe.spacing(before, o.after or 0, o.line or SINGLE)
  props[#props + 1] = ind(o.left or 0, nil, 0, o.right)
  if o.al then props[#props + 1] = jc(o.al) end
  return para(props, body)
end

-- a rule at the foot of a block of RULE_H (typst rule-block): an empty exact-height paragraph with a bottom border
local function rule(right, keep)
  return para({ keep and KEEP or "", '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>',
    xe.spacing(0, 0, RULE_H), ind(0, nil, 0, right) }, "")
end

-- a table of columns with no borders and no cell margins (typst grid): `cells` hold paragraph XML; the gutter is a
-- column of its own
local function grid(cells)
  local x = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. COL .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="' .. COL .. '"/></w:tblGrid>' }
  for r = 1, #cells, 2 do
    local function tc(w, body)
      return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. "</w:tc>"
    end
    x[#x + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. tc(COL, cells[r])
      .. tc(GUTTER, para({ xe.spacing(0, 0, 20) }, "")) .. tc(COL, cells[r + 1] or para({ xe.spacing(0, 0, 20) }, "")) .. "</w:tr>"
  end
  x[#x + 1] = "</w:tbl>"
  return table.concat(x)
end

-- the caption (typst caption-block)
local function caption(m)
  local out = {}
  out[#out + 1] = line(0, runs(COURT_NAME, { b = true }), { al = "center", after = SP_CAPTION })
  local left = {}
  for i, side in ipairs(items(m.caption)) do
    if i > 1 then left[#left + 1] = line(SP_CAPTION, runs("v."), { left = 864 }) end
    for j, n in ipairs(items(side.names)) do
      left[#left + 1] = line((i > 1 and j == 1) and SP_CAPTION or 0, runs(plain(n)))
    end
    left[#left + 1] = line(SP_DESIG, runs(plain(side.designation)), { left = 576 })
  end
  local right = {}
  if m.date then right[#right + 1] = line(0, runs(plain(m.date))) end
  local title = m.brief_title and pandoc.text.upper(plain(m.brief_title)) or DEFAULT_TITLE
  right[#right + 1] = line(m.date and SP_CAPTION or 0, runs(title, { b = true }))
  local docket = { (m.docket_label and plain(m.docket_label) or "Docket No.") .. " " .. plain(m.case_number) }
  for _, l in ipairs(items(m.case_lines)) do docket[#docket + 1] = plain(l) end
  for j, l in ipairs(docket) do right[#right + 1] = line(j == 1 and SP_CAPTION or 0, runs(l)) end
  if m.proceeding then right[#right + 1] = line(SP_CAPTION, runs(plain(m.proceeding))) end
  out[#out + 1] = grid({ table.concat(left), table.concat(right) })
  out[#out + 1] = rule(0)
  out[#out + 1] = line(SP_CAPTION, runs(ADDRESS), { al = "center", left = ADDRESS_IN, right = ADDRESS_IN })
  return raw(table.concat(out))
end

-- a signature block (typst signer-block): the line, the signer, the signer's lines; `left` in, `right` the end of the
-- line; every line kept with the next but the last
local function signer(s, left, right, before, keep_last)
  local lines = { plain(s.signer) }
  for _, l in ipairs(items(s.lines)) do lines[#lines + 1] = plain(l) end
  local out = { para({ KEEP, '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>',
    xe.spacing(before, 0, RULE_H), ind(left, nil, 0, right) }, "") }
  for k, l in ipairs(lines) do
    out[#out + 1] = line(0, runs(l), { left = left, keep = k < #lines or keep_last })
  end
  return table.concat(out)
end

local function signature(m)
  local sigs = items(m.signature)
  if #sigs == 1 then
    return raw(signer(sigs[1], SIG_LEFT, TEXT_W - SIG_LEFT - SIG_RULE, SP_BLOCK))
  end
  local cells = {}
  for _, s in ipairs(sigs) do cells[#cells + 1] = signer(s, 0, COL - SIG_RULE, 0, true) end
  -- the space above the block: an empty 1 twip paragraph kept with the table (Word keeps no space above a table)
  return raw(para({ KEEP, xe.spacing(SP_BLOCK - 1, 0, 1) }, "") .. grid(cells))
end

-- the R. 17.3 word count, as typst counts it: the markdown body after the frontmatter, footnote labels removed,
-- every whitespace-separated token with a letter or digit
local function count_words()
  local f = io.open(PANDOC_STATE.input_files[1], "r")
  if not f then return 0 end
  local src = f:read("a")
  f:close()
  local body = src:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1)
  body = body:gsub("%[%^[^%]]+%]:?", " ")
  local n = 0
  for w in body:gmatch("%S+") do
    if w:find("%w") or w:find("[\195-\201][\128-\191]") then n = n + 1 end
  end
  return n
end

local function heading(b)
  local before, al = SP_H, "left"
  if b.level == 1 then before, al = SP_H1, "center" elseif b.level >= 3 then al = "center" end
  return raw(para({ KEEP, xe.spacing(before, 0, SINGLE), ind(0, nil, 0), jc(al),
    '<w:outlineLvl w:val="' .. (math.min(b.level, 9) - 1) .. '"/>' }, inl(b.content, { b = true })))
end

-- a list as rows: the label in a half-inch box, the text hanging after it (typst list-row); `left`/`right` the
-- indents of the block it is in, `line` its pitch
local function list_rows(b, left, right, line_tw, first_before, last_after)
  local out = {}
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  local delim = b.t == "OrderedList" and b.listAttributes.delimiter or "Period"
  for k, item in ipairs(b.content) do
    local lab = "\u{2022}"
    if b.t == "OrderedList" then
      lab = delim == "OneParen" and (n .. ")") or delim == "TwoParens" and ("(" .. n .. ")") or (n .. ".")
    end
    local body = {}
    for _, blk in ipairs(item) do
      if blk.t == "Para" or blk.t == "Plain" then body[#body + 1] = blk.content end
    end
    for j, content in ipairs(body) do
      local before = (k == 1 and j == 1) and first_before or 0
      local after = (k == #b.content and j == #body) and last_after or 0
      local text = (j == 1 and runs(lab .. "\t") or "") .. inl(content)
      -- no firstLine beside a hanging indent: LibreOffice lets w:firstLine="0" cancel w:hanging
      local indent = j == 1 and ind(left + INDENT, INDENT, nil, right) or ind(left + INDENT, nil, 0, right)
      out[#out + 1] = para({ xe.spacing(before, after, line_tw), indent }, text)
    end
    n = n + 1
  end
  return raw(table.concat(out))
end

local function blockquote(b)
  local out = {}
  for k, c in ipairs(b.content) do
    if c.t == "OrderedList" or c.t == "BulletList" then
      out[#out + 1] = list_rows(c, INDENT, INDENT, SINGLE, k == 1 and SP_QUOTE or 0, k == #b.content and SP_QUOTE or 0)
    else
      out[#out + 1] = pandoc.Div({ c }, { ["custom-style"] = "Block Text" })
    end
  end
  return out
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

function Pandoc(doc)
  local m = doc.meta
  local out = { caption(m) }
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      body[#body + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(blockquote(b)) do body[#body + 1] = x end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      body[#body + 1] = list_rows(b, 0, nil, BODY, 0, 0)
    else
      body[#body + 1] = b
    end
  end
  body = pandoc.Pandoc(body):walk({ Inlines = xe.inlines }).blocks
  if m.signature then
    -- the last paragraph stays with the signature (typst: the tail block is kept with it)
    local last = body[#body]
    if last and last.t == "Para" and not has_note(last) then
      body[#body] = raw(para({ KEEP, xe.spacing(0, 0, BODY), ind(0, nil, INDENT) }, inl(last.content)))
    end
  end
  for _, b in ipairs(body) do out[#out + 1] = b end
  if m.signature then out[#out + 1] = signature(m) end

  -- the certificates, on a new page
  local words = m.word_count and plain(m.word_count) or tostring(count_words())
  local cert = m.certificate or {}
  local x = {}
  x[#x + 1] = line(0, runs("CERTIFICATE OF COMPLIANCE", { b = true }), { al = "center", after = SP_CERT, keep = true })
  x[#x + 1] = para({ xe.spacing(0, 0, BODY), ind(0, nil, INDENT) }, runs("This brief contains " .. words
    .. " words, excluding the parts exempted by Rule 17.3, and so complies with the " .. WORD_LIMIT
    .. "-word limit of Rule 17.3."))
  x[#x + 1] = line(SP_BLOCK, runs("CERTIFICATE OF SERVICE", { b = true }), { al = "center", after = SP_CERT, keep = true })
  x[#x + 1] = para({ xe.spacing(0, 0, BODY), ind(0, nil, INDENT) }, runs("I certify that a copy of the foregoing was "
    .. (cert.method and plain(cert.method) or "delivered") .. " to "
    .. (cert.recipient and plain(cert.recipient) or DEFAULT_RECIPIENT) .. " on "
    .. (m.date and plain(m.date) or "__________") .. "."))
  local certifier = cert.signer
  if not certifier then
    local sigs = items(m.signature)
    certifier = sigs[#sigs] or { signer = "", lines = {} }
  end
  x[#x + 1] = signer(certifier, SIG_LEFT, TEXT_W - SIG_LEFT - SIG_RULE, SP_BLOCK)
  -- the first paragraph of the certificates breaks the page
  x[1] = x[1]:gsub("<w:keepNext/><w:keepLines/>", "<w:keepNext/><w:keepLines/>" .. BREAK, 1)
  out[#out + 1] = raw(table.concat(x))

  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="708" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>')

  doc.blocks = out
  doc.meta.date = nil -- the date is the caption's and the certificate's, not a pandoc title block
  doc.meta.title = nil
  return doc
end

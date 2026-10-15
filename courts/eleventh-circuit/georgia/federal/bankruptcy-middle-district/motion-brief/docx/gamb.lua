-- gamb.lua (docx engine): the motion with memorandum as Word paragraphs (typst: gamb-motion-brief.typ).
-- pandoc writes the body with docx/reference.docx; this filter writes what the template sets by hand:
--   * the court lines, the Form 416D caption (a table: the parties on the left, the case information on the right,
--     a rule on the right and bottom of the party column), and the title;
--   * the date line and the signature blocks, kept together (keepNext);
--   * the certificate of service (LBR 9013-3(a)): its statement, the parties served through CM/ECF and by mail, and
--     the attorney's signature.
-- The headings are the author's own (no numbering is added). Every name, date and address comes from the sample's
-- frontmatter. Word may paginate slightly differently from the LibreOffice PDF (docs/DOCX.md).

local stringify = pandoc.utils.stringify

local TEXT_W = 9360      -- the text width, 6.5 in, in twips
local CAP_LEFT = 5184    -- the party column of the caption, 3.6 in
local CAP_RIGHT = TEXT_W - CAP_LEFT
local SIG_LEFT = 4752    -- the signature column, 3.3 in from the left margin

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

-- A paragraph. o: keep (keepNext), before, after (twips), line (240 single, 480 double), rule ("auto" or "exact"),
-- left, right, first (indents), jc. The properties are in the schema's order: keep, spacing, indent, justification.
local function P(o, body)
  local x = ""
  if o.keep then x = "<w:keepNext/><w:keepLines/>" end
  x = x .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>',
    o.before or 0, o.after or 0, o.line or 240, o.rule or "auto")
  if o.left or o.right or o.first then
    x = x .. "<w:ind"
    if o.left then x = x .. ' w:left="' .. o.left .. '"' end
    if o.right then x = x .. ' w:right="' .. o.right .. '"' end
    if o.first then x = x .. ' w:firstLine="' .. o.first .. '"' end
    x = x .. "/>"
  end
  if o.jc then x = x .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. x .. "</w:pPr>" .. (body or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
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

-- The party column: "In re:" before the debtor, "v." between the plaintiffs and the defendants, the role under
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
-- Signature and certificate of service (GAMB-SIG-001, GAMB-SERV-001)
-- ---------------------------------------------------------------------------

-- The attorneys' signature lines, one block per attorney (LBR 9011-1(b)); the role line only when it is not empty.
-- The whole run is kept together (typst: one unbreakable block); the last line ends the run.
local function attorney_blocks(m)
  local lines = {}
  for _, s in ipairs(m.signature) do
    local block = { "/s/ " .. stringify(s.signer), stringify(s.signer), stringify(s.bar) }
    for _, l in ipairs(s.firm) do block[#block + 1] = stringify(l) end
    block[#block + 1] = stringify(s.phone)
    block[#block + 1] = stringify(s.email)
    local role = stringify(s.role)
    if role ~= "" then block[#block + 1] = role end
    for i, l in ipairs(block) do
      -- the role line is italic; a space follows each attorney's block
      lines[#lines + 1] = { text = l, italic = (role ~= "" and i == #block), gap = (i == #block) }
    end
  end
  local out = {}
  for i, l in ipairs(lines) do
    local last = i == #lines
    out[#out + 1] = P({ keep = not last, after = l.gap and 480 or 0, left = SIG_LEFT },
      run(l.text, { i = l.italic }))
  end
  return table.concat(out)
end

-- The signature blocks: the date line, then the attorneys (typst: signature-block()).
local function signature(m)
  return P({ keep = true, before = 480, after = 480 }, run(stringify(m.dated))) .. attorney_blocks(m)
end

-- The certificate: the statement (double-spaced, first-line indent), the parties served through CM/ECF and by first-class
-- mail, and the attorney's signature (LBR 9013-3(a)); one block in the template (typst: breakable: false).
local function certificate(m)
  local svc = m.service
  local out = {}
  out[#out + 1] = P({ keep = true, before = 480, after = 240, jc = "center" }, run("Certificate of Service", { b = true }))
  out[#out + 1] = P({ keep = true, line = 480, rule = "exact", first = 720 }, run("I certify that on "
    .. stringify(svc.date) .. " I filed the foregoing with the Clerk of Court using the CM/ECF system, which will send"
    .. " notification of the filing to the parties listed below who are registered CM/ECF users. I further certify that"
    .. " I served by first-class United States mail, postage prepaid, the parties listed below who are not registered"
    .. " CM/ECF users."))
  out[#out + 1] = P({ keep = true, before = 240 }, run("Served through CM/ECF:", { b = true }))
  for _, l in ipairs(svc.ecf) do out[#out + 1] = P({ keep = true }, run(stringify(l))) end
  out[#out + 1] = P({ keep = true, before = 240 }, run("Served by first-class mail:", { b = true }))
  for _, l in ipairs(svc.mail) do out[#out + 1] = P({ keep = true }, run(stringify(l))) end
  out[#out + 1] = P({ keep = true, before = 480, after = 0 }, "")
  return table.concat(out) .. attorney_blocks(m)
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
  for _, b in ipairs(doc.blocks) do add(b) end

  -- the signature blocks follow the body; the date line keeps with them
  add(raw(signature(m)))
  add(raw(certificate(m)))
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

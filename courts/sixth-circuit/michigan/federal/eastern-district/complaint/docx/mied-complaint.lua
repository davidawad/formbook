-- E.D. Mich. complaint, docx engine. Mirrors typst/mied-complaint.typ: the court title (Fed. R. Civ. P. 10(a)), the
-- caption (a table: the parties single-spaced in a column closed by a rule at its right and foot, each designation
-- set in, "v." between the parties; at the right the case number and the judge), the title of the paper, the
-- lead-in, the body (paragraphs numbered 1, 2, ... (Fed. R. Civ. P. 10(b)); a list's items lettered A., B., ...;
-- headings centred) and the signature block, kept on one page with the last paragraph. Numbers and letters are typed
-- text, as the typst template types them. Every case word comes from the frontmatter. The footer (the 12 pt page
-- number, centred) and the last section are written for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); font, body
-- styles, headings and margins are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the body, 322 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE, FOOT = 644, 322, 276      -- typst pitch-body, pitch-single, pitch-footer
local TW = 9360                               -- the text width: 6.5 in
local CAP_LEFT, CAP_GAP = 4752, 360           -- typst caption-left 3.3 in, caption-gap 0.25 in
local CAP_INSET = 200                         -- typst caption-inset 10 pt
local CAP_RIGHT_INSET = 144                   -- typst caption-right-inset 0.1 in
local RULE = 15                               -- LibreOffice sets the 0.75 pt foot rule below the cell (a typst stroke
                                              -- takes no room): the cell padding below is that much less
local DESIGNATION = 1440                      -- typst designation-indent 1 in
local SIG_LEFT = 4608                         -- typst sig-left 3.2 in
local CAPTION_ABOVE = 644                     -- typst caption-above
local TITLE_ABOVE, TEXT_ABOVE = 644, 322      -- typst title-above, text-above
local SIG_ABOVE = 644                         -- typst sig-above
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("mied complaint docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  if not o.style or o.left or o.hanging or o.first then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  end
  if not o.style or o.jc then props[#props + 1] = xe.jc(o.jc or "left") end
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- ---------------------------------------------------------------------------
-- Footer and section (LR 5.1(a)(2))
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_P = xe.para({ xe.spacing(0, 0, FOOT), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdMiedFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Page one: court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local RULE_XML = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function cover(m)
  local out = {}
  local court = { "UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF MICHIGAN" }
  if m.division then court[#court + 1] = txt(m.division):upper() end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end

  -- the party column: names, a blank line, the designation set in; "v." with a blank line above and below
  local left = {}
  local gap = 0
  local function add(body, o)
    o = o or {}
    o.before = gap
    left[#left + 1] = p(body, o)
    gap = 0
  end
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then
      gap = gap + SINGLE
      add(xe.runs("v."))
      gap = gap + SINGLE
    end
    for _, n in ipairs(items(party.names)) do add(line(n)) end
    gap = gap + SINGLE
    add(line(party.designation), { left = DESIGNATION })
  end
  local right = { p(xe.runs("Case No. " .. txt(m.case_number))) }
  if m.judge then right[#right + 1] = p(line(m.judge)) end
  for _, j in ipairs(items(m.judges)) do right[#right + 1] = p(line(j)) end

  local cap_right = TW - CAP_LEFT - CAP_GAP
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/>'
    .. '<w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. NOLOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GAP
    .. '"/><w:gridCol w:w="' .. cap_right .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. RULE_XML .. '/>'
    .. '<w:right ' .. RULE_XML .. '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. (CAP_INSET - RULE) .. '" w:type="dxa"/>'
    .. '<w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_GAP .. '" w:type="dxa"/></w:tcPr>' .. p("") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. cap_right .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_RIGHT_INSET
    .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  out[#out + 1] = p(line(m.brief_title, { b = true }), { jc = "center", before = TITLE_ABOVE, after = TEXT_ABOVE })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body and signature
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- The body as raw paragraphs; the last one (a paragraph or a list's last item) is kept with the signature.
local function body(blocks)
  local out = {}
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      out[#out + 1] = xe.raw(p(xe.inl(level == 1 and upper(b.content) or b.content),
        { style = "Heading" .. level, keep = true, pitch = BODY }))
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      local label = n .. ".\t"
      local content = b.content
      out[#out + 1] = function(keep)
        return p(xe.runs(label) .. xe.inl(content), { style = "NumberedParagraph", keep = keep, pitch = BODY })
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local content = pandoc.utils.blocks_to_inlines(item)
        out[#out + 1] = function(keep)
          return p(xe.runs(string.char(64 + i) .. ".\t") .. xe.inl(content), { style = "Lettered", keep = keep, pitch = BODY })
        end
      end
    else
      error("mied-complaint.lua: unexpected block " .. b.t)
    end
  end
  for i, x in ipairs(out) do
    if type(x) == "function" then out[i] = xe.raw(x(i == #out)) end
  end
  return out
end

-- The signature block (typst signature-block): single-spaced from SIG_LEFT, kept on one page.
local function signature(m)
  local sig = m.signature
  local lines = { xe.runs("Respectfully submitted,"), "", xe.runs("/s/ " .. txt(sig.signer)), line(sig.signer) }
  for _, l in ipairs(items(sig.lines)) do lines[#lines + 1] = line(l) end
  local out = {}
  local gap = SIG_ABOVE
  for i, l in ipairs(lines) do
    if l == "" then gap = gap + SINGLE else
      out[#out + 1] = p(l, { before = gap, left = SIG_LEFT, keep = i < #lines })
      gap = 0
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("600.735(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 1331"; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("^[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  check(m.caption ~= nil and m.caption.parties ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.brief_title ~= nil, "Fed. R. Civ. P. 10(a): the title of the paper is required")
  check(m.signature ~= nil and m.signature.signer ~= nil, "Fed. R. Civ. P. 11(a): the signature block needs a signer")
  write_file("FORMBOOK_FOOTERS", "rIdMiedFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  if m.lead_in then out:insert(xe.raw(p(xe.inl(m.lead_in), { style = "BodyText", pitch = BODY }))) end
  out:extend(body(doc.blocks))
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

-- S.D. Ohio motion and memorandum, docx engine. Mirrors typst/ohsd-motion-brief.typ: the court title (centred bold
-- single lines), the caption (a table: the parties on the left, ruled on the right and below; the case number, the
-- judge, the title of the paper and the legend on the right; Fed. R. Civ. P. 10(a)), the motion's paragraph and its own
-- signature (undated) when the sample asks for it, the memorandum from a new page (the heading named by
-- new_page_before), the body (paragraphs, numbered 1, 2, ... only when the sample is numbered; headings: level 1
-- centred capitals, 2 bold, 3 bold italic), the signature block kept on one page with the last paragraph, and the
-- certificate of service (S.D. Ohio Civ. R. 5.2), kept whole. Every case word comes from the frontmatter. The footer
-- (the page number, centred; Civ. R. 5.1(a)) and the last section are written for fb render ($FORMBOOK_FOOTERS,
-- $FORMBOOK_FINAL); font, body styles, headings and margins are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local TW = 9360                               -- typst text-width: 6.5 in
local CAP_LEFT, CAP_GUTTER = 4752, 288        -- typst caption-left 3.3 in, caption-gutter 0.2 in
local CAP_PAD = 200                           -- typst caption-pad 10 pt
local CAP_RULE = 6                            -- typst caption-rule 0.75 pt (eighths of a point)
local CAP_RULE_TW = 15                        -- the same rule in twips: LibreOffice sets a cell's bottom rule below
                                              -- the whole row (typst adds it below the grid), and gives a cell's
                                              -- bottom margin to the whole row, so the party column's padding is
                                              -- its last line's space after, less the rule
local CAP_RIGHT_INSET = 144                   -- typst caption-right-inset 0.1 in
local CAPTION_ABOVE = 240                     -- typst caption-above 12 pt
local TITLE_ABOVE = 240                       -- typst title-above 12 pt
local TEXT_ABOVE = 480                        -- typst text-above 24 pt
local SIG_ABOVE, SIG_GAP = 480, 240           -- typst sig-above 24 pt, sig-gap 12 pt
local SIG_COL = 4464                          -- typst sig-col 3.1 in
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("ohsd motion-brief docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tab, style, page }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.page then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
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
-- Footer and section (Civ. R. 5.1(a))
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_P = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdOhsdFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Page one: court title, caption
-- ---------------------------------------------------------------------------

local function tc(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>"
    .. paras .. "</w:tc>"
end

local function cover(m)
  local out = {}
  local court = { "UNITED STATES DISTRICT COURT", "SOUTHERN DISTRICT OF OHIO" }
  if m.division then court[#court + 1] = txt(m.division) end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end

  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k == 2 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(line(n)) end
    left[#left + 1] = p(line(party.designation), { after = k == #m.caption.parties and CAP_PAD - CAP_RULE_TW or 0 })
  end
  local right = { p(xe.runs("Case No. " .. txt(m.case_number))) }
  if m.judge then right[#right + 1] = p(line(m.judge)) end
  right[#right + 1] = p(xe.inl(m.brief_title, { b = true }), { before = TITLE_ABOVE })
  if m.legend then right[#right + 1] = p(xe.runs(txt(m.legend):upper(), { b = true }), { before = TITLE_ABOVE }) end

  local rule = 'w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local borders = '<w:tcBorders><w:bottom ' .. rule .. '<w:right ' .. rule .. '</w:tcBorders>'
  local right_w = TW - CAP_LEFT - CAP_GUTTER
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. right_w .. '"/>'
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. tc(CAP_LEFT, table.concat(left), borders .. '<w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. tc(CAP_GUTTER, p(""))
    .. tc(right_w, table.concat(right), '<w:tcMar><w:left w:w="' .. CAP_RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>')
    .. "</w:tr></w:tbl>"
  out[#out + 1] = space(TEXT_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature and certificate
-- ---------------------------------------------------------------------------

-- The signature block (typst signature-block): "Dated:" and the date at the left of the first line (a tab), then
-- "Respectfully submitted," and the signer's lines from SIG_COL; kept on one page.
local function signature(m, dated)
  local date = (dated and m.date) and ("Dated: " .. txt(m.date)) or ""
  local lines = { p(xe.runs(date .. "\t") .. xe.runs("Respectfully submitted,"),
    { before = SIG_ABOVE, left = SIG_COL, hanging = SIG_COL, tab = SIG_COL, keep = true }) }
  local sig = items(m.signature.lines)
  for k, l in ipairs(sig) do
    lines[#lines + 1] = p(line(l), { before = k == 1 and SIG_GAP or 0, left = SIG_COL, keep = k < #sig })
  end
  return table.concat(lines)
end

-- The certificate of service (typst certificate): heading, text and signer's lines kept on one page.
local function certificate(m)
  local c = m.certificate
  local out = { space(BODY),
    p(xe.runs("CERTIFICATE OF SERVICE"), { style = "Heading1", keep = true, pitch = BODY }),
    p(xe.inl(c.text), { style = "BodyText", keep = true, pitch = BODY }) }
  local lines = items(c.lines)
  for k, l in ipairs(lines) do
    out[#out + 1] = p(line(l), { before = k == 1 and SIG_ABOVE or 0, left = SIG_COL, keep = k < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- A paragraph that starts with a capital letter and a full stop ("A. "): its letter and the rest.
local function letter_of(inlines)
  local first = inlines[1]
  if first and first.t == "Str" and first.text:match("^[A-Z]%.$") and inlines[2] and inlines[2].t == "Space" then
    return first.text, pandoc.Inlines({ table.unpack(inlines, 3) })
  end
end

-- The body as raw paragraphs; the last one is kept with the signature. `after_first`: raw xml set after the first
-- paragraph (the motion's own signature).
local function body(blocks, m, after_first)
  local numbered = m.numbered == true
  local unnumbered = {}
  for _, t in ipairs(items(m.unnumbered)) do unnumbered[txt(t)] = true end
  local new_page = m.new_page_before and txt(m.new_page_before) or nil
  local out = {}
  local numnow = numbered
  local n = 0
  local function lettered(label, content)
    return function(keep)
      return p(xe.runs(label .. "\t") .. xe.inl(content), { style = "Lettered", keep = keep, pitch = BODY })
    end
  end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      local title = stringify(b.content)
      numnow = numbered and not unnumbered[title]
      out[#out + 1] = p(xe.inl(level == 1 and upper(b.content) or b.content),
        { style = "Heading" .. level, keep = true, pitch = BODY, page = title == new_page })
    elseif b.t == "Para" or b.t == "Plain" then
      local label, rest = letter_of(b.content)
      if label then
        out[#out + 1] = lettered(label, rest)
      elseif numnow then
        n = n + 1
        local lab, content = n .. ".\t", b.content
        out[#out + 1] = function(keep)
          return p(xe.runs(lab) .. xe.inl(content), { style = "NumberedParagraph", keep = keep, pitch = BODY })
        end
      else
        local content = b.content
        out[#out + 1] = function(keep)
          return p(xe.inl(content), { style = "BodyText", keep = keep, pitch = BODY })
        end
      end
      if i == 1 and after_first then out[#out + 1] = after_first end
    elseif b.t == "OrderedList" then
      -- "A.  text" read as a list: the author's letters
      local start = b.listAttributes.start
      for j, item in ipairs(b.content) do
        out[#out + 1] = lettered(string.char(64 + start + j - 1) .. ".", pandoc.utils.blocks_to_inlines(item))
      end
    else
      error("motion-brief.lua: unexpected block " .. b.t)
    end
  end
  check(type(out[#out]) == "function", "the body must end with a paragraph (the signature is set with it)")
  for i, x in ipairs(out) do
    if type(x) == "function" then x = x(i == #out) end
    out[i] = xe.raw(x)
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or", "CM/ECF"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after
-- it. Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("¶¶ 31"; the typst template boxes them): no-break spaces.
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
  check(txt(m.case_number) ~= "", "Fed. R. Civ. P. 10(a): the case number is required")
  check(m.brief_title ~= nil, "Fed. R. Civ. P. 10(a): the title of the paper is required")
  check(m.signature ~= nil and m.signature.lines ~= nil, "Fed. R. Civ. P. 11(a): the signature block is required")
  write_file("FORMBOOK_FOOTERS", "rIdOhsdFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local after_first = m.motion_signature == true and signature(m, false) or nil
  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  out:extend(body(doc.blocks, m, after_first))
  out:insert(xe.raw(signature(m, true)))
  if m.certificate then out:insert(xe.raw(certificate(m))) end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }

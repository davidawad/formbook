-- msnb adversary complaint, docx engine: what the Word output adds to pandoc's conversion, so that it reads and breaks
-- as typst/msnb-adversary-complaint.typ does: the counsel block, the court title, the caption (Fed. R. Bankr. P.
-- 7010, 9004(b)), the title, the allegations numbered consecutively (Fed. R. Civ. P. 10(b)), the lettered sub-items,
-- the WHEREFORE lead-in and the prayer with the markdown's own numbers, headings and the signature block. Every
-- paragraph is written here (raw WordprocessingML); everything printed comes from the sample's frontmatter and body:
-- no case text lives in this file.
--
-- The document is read again from the sample, as the typst template reads it: CommonMark with smart punctuation
-- (cmarker), a "[^n]:" line escaped first so it stays text (the template sets no footnotes; was docx/render.sh's
-- sed), the frontmatter strings as written ($FORMBOOK_META).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap: one blank single line
local TEXTW = 9360                       -- 6.5 in
local INDENT, LABEL = 720, 720           -- typst para-indent, label-box (0.5 in)
local ITEM = 1440                        -- typst item-indent (1 in)
local CAP_LEFT = 4680                    -- typst caption-left 3.25 in
local SIG_INDENT = 4680                  -- typst signature-indent 3.25 in
local READER = "commonmark+smart+yaml_metadata_block"

local function read_file(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function need(v, what)
  if v == nil or v == pandoc.json.null or v == "" then error("msnb-adversary-complaint: frontmatter needs " .. what) end
  return v
end

local function list(v)
  if v == nil or v == pandoc.json.null then return {} end
  return v
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- Two more of typst's rules (Unicode line breaking): no break between a section sign or pilcrow and its number,
-- also when the sign ends a word, nor at a space before a period, comma, colon or semicolon (". . ."): that space
-- becomes a no-break space.
local function binds(l)
  for i = 1, #l - 1 do
    local a, b = l[i], l[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local nxt = l[i + 2]
      if (a.text:sub(-2) == "\u{00A7}" or a.text:sub(-2) == "\u{00B6}") or (nxt and nxt.t == "Str" and nxt.text:find("^[.,:;]")) then
        l[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return l
end

-- A frontmatter string as typst's inl() reads it (cmarker: CommonMark, smart punctuation), as runs.
local function md(s, o)
  local blocks = pandoc.read(s, READER).blocks
  local out = pandoc.Inlines({})
  for _, b in ipairs(blocks) do
    if b.content then out:extend(b.content) end
  end
  out = out:walk({ Str = breaks })
  return xe.inl(binds(out), o)
end

-- A single-pitch paragraph: o = { keep, before, after, left, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A body paragraph at the double pitch: the label at `at`, a tab to the end of its box, the text, the lines after
-- the first at the margin (typst labeled); without a label, the first line indented (typst unnumbered).
local function body_para(label, at, content, keep)
  local props = {}
  if keep then props[#props + 1] = xe.KEEP end
  if label then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. (at + LABEL) .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(0, 0, BODY)
  props[#props + 1] = xe.ind(0, nil, at)
  props[#props + 1] = xe.jc("left")
  local lead = label and (xe.runs(label) .. "<w:r><w:tab/></w:r>") or ""
  return xe.raw(xe.para(props, lead .. xe.inl(content)))
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption, title
-- ---------------------------------------------------------------------------

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
  '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
local CELL_MAR = '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
local LOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

local function tc(w, body, pr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- The caption (typst caption): party names left, the designations and numbers flush right, a rule under the debtor
-- row, blank single lines between the rows; one table, every line a single-pitch line, bold.
local function caption(meta)
  local right_w = TEXTW - CAP_LEFT
  local rows = {}
  local function stack(items, jc)
    local out = {}
    for _, s in ipairs(items) do out[#out + 1] = p(s, { jc = jc }) end
    return table.concat(out)
  end
  local function row(left, right)
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(CAP_LEFT, stack(left)) ..
      tc(right_w, stack(right, "right")) .. '</w:tr>'
  end
  local function spacer(rule)
    local border = rule and '<w:tcBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders>' or ""
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. GAP .. '" w:hRule="exact"/></w:trPr>' ..
      tc(TEXTW, p("", {}), '<w:gridSpan w:val="2"/>' .. border) .. '</w:tr>'
  end
  local B = { b = true }
  local debtor = {}
  for i, n in ipairs(need(meta.debtor, "debtor").names) do debtor[i] = md((i == 1 and "IN RE: " or "") .. n, B) end
  row(debtor, { xe.runs("NO. " .. need(meta.case_number, "case_number"), B) })
  spacer(true)
  local pl = {}
  for i, n in ipairs(need(meta.plaintiffs, "plaintiffs")) do pl[i] = md(n, B) end
  row(pl, { xe.runs(#pl > 1 and "PLAINTIFFS" or "PLAINTIFF", B) })
  spacer()
  spacer()
  row({ xe.runs("VS.", B) }, { xe.runs("ADVERSARY NO. " .. need(meta.adv_number, "adv_number"), B) })
  spacer()
  spacer()
  local df = {}
  for i, n in ipairs(need(meta.defendants, "defendants")) do df[i] = md(n, B) end
  local label = meta.defendants_label
  if label == nil or label == pandoc.json.null then label = "DEFENDANT" end
  row(df, { xe.runs(label, B) })
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. NO_BORDERS .. CELL_MAR .. LOOK ..
    '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. right_w .. '"/></w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>'
end

local function cover(meta)
  local out = {}
  local counsel = list(meta.counsel)
  for i, l in ipairs(counsel) do out[#out + 1] = p(md(l), { after = i == #counsel and GAP or 0 }) end
  local court = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE NORTHERN DISTRICT OF MISSISSIPPI" }
  for k, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = k == #court and 2 * GAP or 0 })
  end
  out[#out + 1] = caption(meta)
  local title = pandoc.text.upper(need(meta.title, "title"))
  out[#out + 1] = p(xe.runs(title, { b = true }), { jc = "center", before = 2 * GAP, after = GAP })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature
-- ---------------------------------------------------------------------------

-- The date line at the paragraph indent; the firm (bold), the signature line and the title in the right half; the
-- signer's counsel block flush left; one block, a blank single line below the text (typst signature).
local function signature(meta)
  local s = need(meta.signature, "signature")
  local out = {}
  local function add(body, o)
    o.keep = true
    out[#out + 1] = p(body, o)
  end
  if meta.dated ~= nil and meta.dated ~= pandoc.json.null then
    add(xe.runs("DATED: ") .. md(meta.dated), { left = INDENT, before = GAP })
  end
  add(md(need(s.firm, "signature.firm"), { b = true }), { left = SIG_INDENT, before = GAP })
  add(xe.runs("By: ") .. xe.runs("/s/ ", { u = true }) .. md(need(s.signer, "signature.signer"), { u = true }),
    { left = SIG_INDENT, before = 2 * GAP })
  add(md(need(s.title, "signature.title")), { left = SIG_INDENT + INDENT })
  for i, l in ipairs(list(s.lines)) do add(md(l), { before = i == 1 and 2 * GAP or 0 }) end
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(0, 0, BODY),
    xe.ind(0, nil, 0), xe.jc("center") }, xe.inl(content, { b = true })))
end

local function item_inlines(item)
  local content = pandoc.Inlines({})
  for k, blk in ipairs(item) do
    if k > 1 then content:insert(pandoc.Space()) end
    if blk.content then content:extend(blk.content) end
  end
  return content
end

function Pandoc(_)
  local src = read_file(PANDOC_STATE.input_files[1])
  if not src then error("msnb-adversary-complaint.lua: cannot read the sample") end
  local meta = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)
  -- A "[^n]:" line would be read as a link definition and dropped: escaped, it stays text, as in typst.
  src = src:gsub("\n%[%^(%w+)%]:", "\n\\[^%1]:")
  local doc = pandoc.read(src, READER, PANDOC_READER_OPTIONS)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = binds })

  local out = { xe.raw(cover(meta)) }
  local blocks = doc.blocks
  local n = 0
  local prev = nil
  for bi, b in ipairs(blocks) do
    local last = bi == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      out[#out + 1] = body_para(nil, INDENT, item_inlines(b.content), last)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_para(n .. ".", INDENT, b.content, last)
    elseif b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = body_para("(" .. string.char(96 + i) .. ")", ITEM, item_inlines(item), last and i == #b.content)
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local label
        if prev and prev.t == "BlockQuote" then
          label = (start + i - 1) .. "."
        else
          n = n + 1
          label = n .. "."
        end
        out[#out + 1] = body_para(label, INDENT, item_inlines(item), last and i == #b.content)
      end
    else
      error("msnb-adversary-complaint.lua: unsupported block " .. b.t)
    end
    prev = b
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

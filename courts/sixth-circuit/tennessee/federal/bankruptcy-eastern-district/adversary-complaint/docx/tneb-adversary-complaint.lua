-- tneb adversary complaint, docx engine (docs/DOCX.md). Mirrors typst/tneb-adversary-complaint.typ on the cross-engine
-- layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in exact line boxes of
-- the typst pitch, the spaces between blocks those of the typst template, the break rules of typst on every run.
-- The cover (court, district, the caption with its ")" column, the title), the lead-in, the headings, the numbered
-- allegations (FRCP 10(b) through FRBP 7010; the number is typed, as the typst counter does), the unnumbered WHEREFORE
-- paragraph, the lettered prayer, the last item kept with the dated line and the signature block. Every case-specific
-- word comes from the sample's frontmatter. The page number (LBR 9004-1(a): at the bottom from page 2) and the
-- section are written to $FORMBOOK_FOOTERS and $FORMBOOK_FINAL (fb render, tools/fb/src/docxpass.rs).
-- Twips = 20 x pt: 480 a double line (LBR 9004-1(a)), 276 a single line.
local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276  -- typst pitch-body 24 pt, pitch-single 13.8 pt
local BLANK_TITLE = 276        -- typst blank-title 13.8 pt: around the caption, under the title
local BLANK_BODY = 480         -- typst blank-body 24 pt: the dated line to the signature lines
local CAP_LEFT, CAP_MID, CAP_RIGHT = 4680, 432, 4248 -- typst caption-left 3.25 in, caption-mid 0.3 in, the rest of 6.5 in
local SIG_INDENT = 4680        -- typst sig-indent 3.25 in
local LETTERS = "abcdefghijklmnopqrstuvwxyz"

-- A paragraph: o = { before, after, line, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function list(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function empty(v)
  return v == nil or pandoc.utils.stringify(v) == ""
end

-- One caption cell: a single-spaced line (an empty entry still takes its line).
local function cell(w, v, jc)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>'
    .. p(empty(v) and "" or xe.inl(v), { jc = jc }) .. '</w:tc>'
end

-- The caption (typst caption-row()): the party column, a ")" column, the case information; a borderless table.
local function caption(meta)
  local rows = {}
  for _, r in ipairs(list(meta.caption)) do
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(CAP_LEFT, r.left)
      .. cell(CAP_MID, ")", "center") .. cell(CAP_RIGHT, r.right) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (CAP_LEFT + CAP_MID + CAP_RIGHT) .. '" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_MID .. '"/><w:gridCol w:w="'
    .. CAP_RIGHT .. '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- The court title (bold centred single lines), a blank single line, the caption, the title (typst cover()).
local function cover(meta)
  local out = {}
  local function centred(runs) out[#out + 1] = p(runs, { jc = "center", keep = true }) end
  centred(xe.runs("IN THE ", { b = true }) .. xe.inl(meta.court, { b = true }))
  centred(xe.inl(meta.district, { b = true }))
  if not empty(meta.division) then
    centred(xe.runs(pandoc.text.upper(pandoc.utils.stringify(meta.division)), { b = true }))
  end
  -- the blank single line above the caption (Word has no space before a table: an empty paragraph that tall)
  out[#out + 1] = p("", { keep = true })
  out[#out + 1] = caption(meta)
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { before = BLANK_TITLE, after = BLANK_TITLE, jc = "center" })
  return table.concat(out)
end

-- A body paragraph (typst body-par): the first line indented; `label` and a tab to the text 1 in in, if any.
local function para(content, label, keep)
  local inl = pandoc.Inlines({})
  local style = keep and "Body Text Keep" or "Body Text"
  if label then
    inl:insert(pandoc.Str(label))
    inl:insert(pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
    style = keep and "Body Numbered Keep" or "Body Numbered"
  end
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
end

-- The dated line on the double pitch, a blank double line, then the single lines 3.25 in from the margin: the lead
-- line, a blank single line, the signer, the rest; all kept together (typst signature()).
local function signature(sig)
  local out = {}
  if sig.dated then
    out[#out + 1] = xe.para({ xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 720), xe.jc("left") }, xe.inl(sig.dated))
  end
  local lines, befores = {}, {}
  local above = BLANK_BODY
  if sig.lead then lines[#lines + 1] = xe.inl(sig.lead); befores[#lines] = above; above = BLANK_TITLE end
  if sig.by then lines[#lines + 1] = xe.inl(sig.by); befores[#lines] = above; above = 0 end
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = xe.inl(l); befores[#lines] = above; above = 0 end
  for k, l in ipairs(lines) do
    out[#out + 1] = p(l, { before = befores[k], left = SIG_INDENT, keep = k < #lines })
  end
  return table.concat(out)
end

-- No break after a doubled sign ("§§ 544"; typst boxes the token): the space becomes a no-break space.
local function bind_doubled(l)
  for i = 1, #l - 1 do
    local s = l[i]
    if s.t == "Str" and l[i + 1].t == "Space" and (s.text:find("§§$") or s.text:find("¶¶$")) then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- The page number centred at the foot from page 2 (LBR 9004-1(a)): a single line whose foot is 0.5 in above the
-- bottom edge (typst footer-foot); page 1 takes fb render's empty footer (rIdFtrNone) through titlePg.
local function furniture()
  local field = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>2</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
  local function write(env, text)
    local path = os.getenv(env)
    if not path or path == "" then return end
    local w = assert(io.open(path, "w"))
    w:write(text)
    w:close()
  end
  write("FORMBOOK_FOOTERS", "rIdTnebPage\t" .. p(field, { jc = "center" }) .. "\n")
  write("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdTnebPage"/>'
    .. '<w:footerReference w:type="first" r:id="rIdFtrNone"/><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:titlePg/></w:sectPr>')
end

local function finish(doc)
  local meta = doc.meta
  local out = pandoc.Blocks({})
  out:insert(xe.raw(cover(meta)))
  if meta.lead_in then
    local li = meta.lead_in
    if pandoc.utils.type(li) == "Blocks" then li = pandoc.utils.blocks_to_inlines(li) end
    out:insert(para(pandoc.Inlines(li)))
  end

  -- the body as paragraphs, the last of them (the last prayer item) kept with the signature
  local body = {}
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      body[#body + 1] = { raw = p(xe.inl(b.content, { b = true }), { line = BODY, keep = true, jc = "center" }) }
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):match("^WHEREFORE") then
        body[#body + 1] = { content = b.content }
      else
        n = n + 1
        body[#body + 1] = { content = b.content, label = n .. "." }
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Para" and item[1].t ~= "Plain") then
          error("tneb-adversary-complaint.lua: a prayer item must be one paragraph")
        end
        body[#body + 1] = { content = item[1].content, label = "(" .. LETTERS:sub(k, k) .. ")" }
      end
    else
      error("tneb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  for i, x in ipairs(body) do
    if x.raw then out:insert(xe.raw(x.raw))
    else out:insert(para(x.content, x.label, i == #body)) end
  end
  if meta.signature then out:insert(xe.raw(signature(meta.signature))) end

  furniture()
  -- The frontmatter was consumed above; pandoc would otherwise write its title block at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Inlines = bind_doubled }, { Pandoc = finish } }

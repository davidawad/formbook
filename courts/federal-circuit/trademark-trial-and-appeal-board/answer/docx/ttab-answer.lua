-- Pandoc Lua filter for the TTAB inter partes paper (docx engine).
-- Builds the caption, title, signature block and certificate of service from the YAML frontmatter
-- (same contract as the typst engine, ../README.md), numbers the paragraphs, and sets headings, block quotations
-- and drafting notes ("**[...]**" paragraphs). Requirement IDs refer to ../rules.md.
--
-- Cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph has
-- exact line spacing at the typst template's pitch (typst/ttab-answer.typ: pitch-double 27.6 pt = 552 twips,
-- pitch-single 13.8 pt = 276 twips) and the typst spaces between blocks (twips = 20 x pt). Where typst collapses
-- two spaces to the larger, the larger is written on one side only.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local SINGLE = 276          -- typst pitch-single
local SIG = 4680            -- typst sig-indent, 3.25 in
local INDENT = 720          -- typst para-indent
local KEEP = xe.KEEP

local function need(meta, key)
  if meta[key] == nil then error("ttab-answer.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function list_of(v)
  local out = {}
  if v then for _, l in ipairs(v) do out[#out + 1] = l end end
  return out
end

-- One single-spaced paragraph: o = { before, after, left, first, jc, keep, border, rpr (xe.rpr options) }
local function line(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = KEEP end
  if o.border then
    props[#props + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>'
  end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  if o.jc then props[#props + 1] = xe.jc(o.jc) end
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

local function T(s, o) return xe.runs(s, o) end
local function I(v, o) return xe.inl(v, o) end

local function caption(meta)
  local kind = meta.kind and stringify(meta.kind) or 'opposition'
  local label = (kind == 'cancellation') and 'Cancellation No.' or 'Opposition No.'
  local pl, df = need(meta, 'plaintiff'), need(meta, 'defendant')
  local left = {}
  for _, l in ipairs(list_of(need(meta, 'matter'))) do left[#left + 1] = line(I(l)) end
  left[#left + 1] = line(I(pl.name), { before = 144 })
  left[#left + 1] = line(I(pl.role), { left = 720 })
  left[#left + 1] = line(T('v.', { i = true }), { left = 360 })
  left[#left + 1] = line(I(df.name))
  left[#left + 1] = line(I(df.role), { left = 720 })
  local head = line(T('IN THE UNITED STATES PATENT AND TRADEMARK OFFICE', { b = true }), { jc = 'center', keep = true }) ..
               line(T('BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD', { b = true }), { jc = 'center', keep = true, after = 276 })
  -- the left cell 64 % of the text width (typst caption-col); 8.4 pt between its text and its right rule
  -- (caption-gutter), 10.8 pt between its last line and its bottom rule; the number 13.2 pt after the rule,
  -- on the line of the "v." between the parties
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="5990"/><w:gridCol w:w="3370"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="5990" w:type="dxa"/><w:tcBorders>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="216" w:type="dxa"/><w:right w:w="168" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="3370" w:type="dxa"/></w:tcPr>' ..
    line(T(label .. ' ') .. I(need(meta, 'proceeding_number')),
      { left = 264, before = (#list_of(meta.matter) + 2) * SINGLE + 144 }) ..
    '</w:tc></w:tr></w:tbl>'
  local title = line(I(need(meta, 'title'), { b = true, u = true }), { jc = 'center', keep = true, before = 336, after = 216 })
  return xe.raw(head .. tbl .. title)
end

local function signature(meta)
  local sg = need(meta, 'signature')
  local k = { keep = true, left = SIG }
  local out = {}
  out[#out + 1] = line(T('Dated: ') .. I(sg.date), { keep = true, before = 384 })
  out[#out + 1] = line(T('Respectfully submitted,'), { keep = true, left = SIG, before = 120 })
  out[#out + 1] = line(I(sg.firm, { b = true }), { keep = true, left = SIG, before = 72 })
  out[#out + 1] = line(I(sg.esign), { keep = true, left = SIG, before = 264, border = true })
  out[#out + 1] = line(I(sg.name), { keep = true, left = SIG, before = 80 })
  local rest = { sg.title }
  for _, l in ipairs(list_of(sg.lines)) do rest[#rest + 1] = l end
  for i, l in ipairs(rest) do
    out[#out + 1] = line(I(l), { keep = i < #rest, left = SIG })
  end
  return xe.raw(table.concat(out))
end

local function certificate(meta)
  local sv = meta.service
  if not sv then return nil end
  local method = sv.method and stringify(sv.method) or 'email'
  local by = (method == 'email') and 'by email' or method
  local out = {}
  out[#out + 1] = xe.para({ KEEP, xe.BREAK, xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc('center') },
    T('CERTIFICATE OF SERVICE', { b = true, u = true }))
  out[#out + 1] = line(T('I hereby certify that on ') .. I(sv.date) .. T(', a true and complete copy of the foregoing ') ..
    I(sv.paper) .. T(' was served ' .. by .. ' on:'), { before = 288, first = INDENT })
  for n, r in ipairs(list_of(sv.recipients)) do
    local lines = { T(stringify(r.name) .. ', ') .. I(r.role) }
    for _, l in ipairs(list_of(r.lines)) do lines[#lines + 1] = I(l) end
    lines[#lines + 1] = I(r.email)
    for i, l in ipairs(lines) do
      local before = (i == 1) and (n == 1 and 200 or 240) or 0
      out[#out + 1] = line(l, { keep = i < #lines, left = INDENT, before = before })
    end
  end
  out[#out + 1] = line(I(sv.esign), { keep = true, left = SIG, before = 360, border = true })
  out[#out + 1] = line(I(sv.name), { keep = true, left = SIG, before = 80 })
  out[#out + 1] = line(I(sv.title), { left = SIG })
  return xe.raw(table.concat(out))
end

-- A paragraph that is a single Strong whose text starts with "[" is a drafting note (TTAB-TOOL-002).
local function is_marker(block)
  if block.t ~= 'Para' or #block.content ~= 1 or block.content[1].t ~= 'Strong' then return false end
  return stringify(block.content[1]):sub(1, 1) == '['
end

local HEAD = {
  [1] = { before = 384, after = 240, jc = 'center', rpr = { b = true } },
  [2] = { before = 312, after = 216, rpr = { b = true } },
  [3] = { before = 264, after = 192, rpr = { b = true, i = true } },
}

local convert

local function blocks_of(list, out)
  for _, b in ipairs(list) do convert(b, out) end
end

convert = function(b, out)
  if b.t == 'Header' then
    local h = HEAD[b.level] or HEAD[3]
    out[#out + 1] = xe.raw(line(I(b.content, h.rpr),
      { keep = true, before = h.before, after = h.after, jc = h.jc, outline = b.level - 1 }))
  elseif b.t == 'OrderedList' then
    local n = b.listAttributes.start or 1
    for _, item in ipairs(b.content) do
      local first = item[1]
      if first and (first.t == 'Plain' or first.t == 'Para') then
        local il = pandoc.Inlines({ pandoc.Str(n .. '.'), pandoc.Str('\u{00A0}\u{00A0}') })
        il:extend(first.content)
        item[1] = pandoc.Para(il)
      end
      blocks_of(item, out)
      n = n + 1
    end
  elseif b.t == 'BulletList' then
    for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
  elseif b.t == 'BlockQuote' then
    local paras = b.content
    for i, p in ipairs(paras) do
      local il = (p.t == 'Para' or p.t == 'Plain') and p.content or pandoc.Inlines({ pandoc.Str(stringify(p)) })
      out[#out + 1] = xe.raw(line(I(il), { left = 1440, before = (i == 1) and 216 or 168,
        after = (i == #paras) and 240 or 0, keep = false }):gsub('<w:ind w:left="1440"', '<w:ind w:left="1440" w:right="1440"'))
    end
  elseif is_marker(b) then
    out[#out + 1] = xe.raw(line(I(b.content[1].content, { i = true }), { keep = true, before = 216, after = 216 }))
  elseif b.t == 'Plain' then
    out[#out + 1] = pandoc.Para(b.content)
  else
    out[#out + 1] = b
  end
end

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ Inlines = xe.inlines })
  local body = {}
  blocks_of(doc.blocks, body)
  -- the signature block never stands alone on a page: the last paragraph is kept with it (typst: one block)
  local last = body[#body]
  local keep_last = doc.blocks[#doc.blocks] and doc.blocks[#doc.blocks].t == 'Para' and last and last.t == 'Para'
  local out = pandoc.List()
  out:insert(caption(meta))
  for i, b in ipairs(body) do
    if i == #body and keep_last then
      out:insert(xe.raw(xe.para({ KEEP, xe.spacing(0, 0, 552), xe.ind(0, nil, INDENT) }, I(b.content))))
    else
      out:insert(b)
    end
  end
  out:insert(signature(meta))
  local cert = certificate(meta)
  if cert then out:insert(cert) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

-- Pandoc Lua filter for the TTAB notice of appearance (docx engine).
-- Builds the caption, title, the generated appearance / attorney / power-of-attorney / correspondence paragraphs,
-- the correspondence block, the signature blocks and the certificate of service from the YAML frontmatter (same
-- contract as the typst engine, ../README.md). Requirement IDs refer to ../rules.md.
--
-- The generated paragraphs are the same markdown string as typst/ttab-notice-of-appearance.typ `generated-md`
-- (keep the two in step), read by pandoc and set in the body style, so both engines break the lines alike.
--
-- Cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): exact line spacing at
-- the typst pitches (double 27.6 pt = 552 twips, single 13.8 pt = 276 twips) and the typst spaces between blocks
-- (twips = 20 x pt). Where typst collapses two spaces to the larger, the larger is written on one side only.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local SINGLE = 276          -- typst pitch-single
local SIG = 4680            -- typst sig-indent, 3.25 in
local INDENT = 720          -- typst para-indent
local BLOCK = 1440          -- typst block-indent, 1 in
local KEEP = xe.KEEP
local NB = "\u{00A0}"

local function need(meta, key)
  if meta[key] == nil then error("ttab-notice-of-appearance.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function list_of(v)
  local out = {}
  if v then for _, l in ipairs(v) do out[#out + 1] = l end end
  return out
end

local function S(v) if v == nil then return nil end return stringify(v) end
local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
local function clean(s) return trim((trim(s):gsub("[,.;:]+$", ""))) end        -- typst clean
local function clean_name(s) return trim((trim(s):gsub("[,;:]+$", ""))) end    -- typst clean-name
local function is_true(v) return v == true or S(v) == "true" end

local function join_names(xs)
  if #xs <= 2 then return table.concat(xs, " and ") end
  return table.concat(xs, ", ", 1, #xs - 1) .. ", and " .. xs[#xs]
end

-- One single-spaced paragraph: o = { before, after, left, first, jc, keep, border, line }
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
  -- The block lines (caption, correspondence, signatures, certificate) are short single lines: a plain hyphen there,
  -- not xe's no-break hyphen, which LibreOffice draws from a fallback face because Times New Roman has no U+2011
  -- glyph (DEF-FONT-002). Body paragraphs keep the no-break hyphen.
  body = body:gsub('</w:t><w:noBreakHyphen/><w:t xml:space="preserve">', '-')
  return xe.para(props, body)
end

local function T(s, o) return xe.runs(s, o) end
-- inline markdown string (a frontmatter value) as runs: pandoc's meta values are already Inlines
local function I(v, o) return xe.inl(v, o) end
local function IS(s, o) return xe.inl(pandoc.read(s, "commonmark+smart").blocks[1].content, o) end

local function party_of(meta)
  local side = meta.appearing_for and S(meta.appearing_for) or "defendant"
  if side ~= "plaintiff" and side ~= "defendant" then
    error("ttab-notice-of-appearance.lua: `appearing_for` must be plaintiff or defendant")
  end
  local p = need(meta, side)
  return { label = clean(S(p.role)), name = clean_name(S(p.name)) }
end

local function title_of(meta)
  if meta.title then return S(meta.title) end
  local parts = {}
  if is_true(meta.power_of_attorney) then parts[#parts + 1] = "POWER OF ATTORNEY" end
  parts[#parts + 1] = "NOTICE OF APPEARANCE"
  if meta.correspondence then parts[#parts + 1] = "CHANGE OF CORRESPONDENCE ADDRESS" end
  local joined
  if #parts <= 2 then joined = table.concat(parts, " AND ")
  else joined = table.concat(parts, ", ", 1, #parts - 1) .. " AND " .. parts[#parts] end
  return pandoc.text.upper(party_of(meta).label) .. "’S " .. joined
end

-- typst generated-md, character for character
local function generated_md(meta)
  local party = party_of(meta)
  local counsel = need(meta, "counsel")
  local atts = list_of(need(counsel, "attorneys"))
  if #atts == 0 then error("ttab-notice-of-appearance.lua: `counsel.attorneys` is empty") end
  local nm = {}
  for _, a in ipairs(atts) do nm[#nm + 1] = S(a.name) end
  local names = join_names(nm)
  local of_firm = counsel.firm and (" of " .. S(counsel.firm)) or ""
  local verb = (#atts == 1) and "appears" or "appear"
  local CFR = "37" .. NB .. "C.F.R. §"
  local paras = {}
  paras[#paras + 1] = "Please take notice that " .. names .. of_firm .. " hereby " .. verb .. " as counsel for " ..
    party.label .. " " .. party.name .. " (“" .. party.label .. "”) in the above-captioned proceeding, pursuant to " ..
    CFR .. " 2.17(b) and TBMP § 114.03."
  local ss = {}
  for _, a in ipairs(atts) do
    local s = S(a.name) .. " is an attorney as defined in " .. CFR .. " 11.1"
    if a.bar then
      local b = a.bar
      s = s .. ", an active member in good standing of the bar of the highest court of " .. S(b.state)
      local paren = {}
      if b.admitted then paren[#paren + 1] = "admitted " .. S(b.admitted) end
      if b.number then paren[#paren + 1] = "Bar No. " .. S(b.number) end
      if #paren > 0 then s = s .. " (" .. table.concat(paren, "; ") .. ")" end
    end
    ss[#ss + 1] = s .. "."
  end
  paras[#paras + 1] = table.concat(ss, " ")
  if is_true(meta.power_of_attorney) then
    local s = party.label .. " hereby appoints " .. names .. of_firm .. " to represent " .. party.label ..
      " in this proceeding, with full power of substitution and revocation, and to transact all business in the" ..
      " United States Patent and Trademark Office in connection therewith. " .. CFR .. " 2.17(b)(1)(i), (c);" ..
      " TBMP § 114.03."
    if is_true(meta.revoke_prior) then
      s = s .. " This power of attorney revokes any previous power of attorney given by " .. party.label ..
        " in this proceeding. " .. CFR .. " 2.19(a)(4)."
    end
    paras[#paras + 1] = s
  end
  if meta.correspondence then
    paras[#paras + 1] = party.label .. " requests that all correspondence from the Board in this proceeding be directed to," ..
      " and all service on " .. party.label .. " be made on, " .. party.label .. "’s counsel at the following address" ..
      " (" .. CFR .. "§ 2.18(a)(2), 2.119(b); TBMP §§ 117.01, 117.07):"
  end
  return table.concat(paras, "\n\n")
end

local function caption(meta)
  local kind = meta.kind and S(meta.kind) or 'opposition'
  local label = (kind == 'cancellation') and 'Cancellation No.' or 'Opposition No.'
  local pl, df = need(meta, 'plaintiff'), need(meta, 'defendant')
  local left = {
    line(I(pl.name), { before = 144 }),
    line(I(pl.role), { left = 720 }),
    line(T('v.', { i = true }), { left = 360, before = 276 }),
    line(I(df.name), { before = 276 }),
    line(I(df.role), { left = 720 }),
  }
  local right = { line(T(label .. ' ') .. I(need(meta, 'proceeding_number')), { left = 264, before = 144 }) }
  for i, l in ipairs(list_of(meta.matter)) do
    right[#right + 1] = line(I(l), { left = 264, before = (i == 1) and 276 or 0 })
  end
  local head = line(T('IN THE UNITED STATES PATENT AND TRADEMARK OFFICE', { b = true }), { jc = 'center', keep = true }) ..
               line(T('BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD', { b = true }), { jc = 'center', keep = true, after = 276 })
  -- the left cell 58 % of the text width (typst caption-col); 8.4 pt between its text and its right rule
  -- (caption-gutter), 10.8 pt between its last line and its bottom rule; the right lines 13.2 pt after the rule
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="5429"/><w:gridCol w:w="3931"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="5429" w:type="dxa"/><w:tcBorders>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="216" w:type="dxa"/><w:right w:w="168" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="3931" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  local title = line(IS(title_of(meta), { b = true }), { jc = 'center', keep = true, before = 336, after = 216 })
  return xe.raw(head .. tbl .. title)
end

local function correspondence(meta, followed_by_body)
  local c = meta.correspondence
  local ls = { S(c.name) }
  if c.firm then ls[#ls + 1] = S(c.firm) end
  for _, l in ipairs(list_of(c.lines)) do ls[#ls + 1] = S(l) end
  if c.phone then ls[#ls + 1] = "Telephone: " .. S(c.phone) end
  local em = {}
  for _, e in ipairs(list_of(c.emails)) do em[#em + 1] = S(e) end
  if #em > 0 then ls[#ls + 1] = "Email: " .. table.concat(em, "; ") end
  local out = {}
  for i, l in ipairs(ls) do
    -- 6 pt above; 13.8 pt below unless the signature block (19.2 pt above) follows, which then wins
    out[#out + 1] = line(IS(l), { keep = i < #ls, left = BLOCK, before = (i == 1) and 120 or 0,
      after = (i == #ls and followed_by_body) and 276 or 0 })
  end
  return xe.raw(table.concat(out))
end

local function sig_group(heading, s, out, last_keep)
  out[#out + 1] = line(I(heading, { b = true }), { keep = true, left = SIG, before = 276 })
  out[#out + 1] = line(T('By: ') .. I(s.esign), { keep = true, left = SIG, before = 264, border = true })
  out[#out + 1] = line(I(s.name), { keep = true, left = SIG, before = 80 })
  local rest = { s.title }
  for _, l in ipairs(list_of(s.lines)) do rest[#rest + 1] = l end
  for i, l in ipairs(rest) do
    out[#out + 1] = line(I(l), { keep = last_keep or i < #rest, left = SIG })
  end
end

local function signature(meta)
  local sg = need(meta, 'signature')
  if is_true(meta.power_of_attorney) and not meta.party_signature then
    error("ttab-notice-of-appearance.lua: a power of attorney must be signed by the party (37 CFR 2.17(c)(2)); add `party_signature`")
  end
  local out = {}
  out[#out + 1] = line(T('Dated: ') .. I(sg.date), { keep = true, before = 384 })
  out[#out + 1] = line(T('Respectfully submitted,'), { keep = true, left = SIG, before = 120 })
  if meta.party_signature then sig_group(meta.party_signature.party, meta.party_signature, out, true) end
  sig_group(sg.firm, sg, out, false)
  return xe.raw(table.concat(out))
end

local function certificate(meta)
  local sv = meta.service
  if not sv then return nil end
  local method = sv.method and S(sv.method) or 'email'
  local by = (method == 'email') and 'by email' or method
  local paper = sv.paper and I(sv.paper) or IS(title_of(meta))
  local out = {}
  out[#out + 1] = xe.para({ KEEP, xe.BREAK, xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc('center') },
    T('CERTIFICATE OF SERVICE', { b = true, u = true }))
  out[#out + 1] = line(T('I hereby certify that on ') .. I(sv.date) .. T(', a true and complete copy of the foregoing ') ..
    paper .. T(' was served ' .. by .. ' on:'), { before = 288, first = INDENT })
  for n, r in ipairs(list_of(sv.recipients)) do
    local lines = { T(S(r.name) .. ', ') .. I(r.role) }
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

local function convert(b, out)
  if b.t == 'BulletList' then
    for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
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
  local generate = not (meta.generate == false or S(meta.generate) == "false")
  local body = {}
  for _, b in ipairs(doc:walk({ Inlines = xe.inlines }).blocks) do convert(b, body) end
  local out = pandoc.List()
  out:insert(caption(meta))
  if generate then
    local gen = pandoc.read(generated_md(meta), "commonmark+smart")
    gen = gen:walk({ Inlines = xe.inlines })
    for _, b in ipairs(gen.blocks) do out:insert(b) end
    if meta.correspondence then out:insert(correspondence(meta, #body > 0)) end
    for _, b in ipairs(body) do out:insert(b) end
  else
    for _, b in ipairs(body) do out:insert(b) end
    if meta.correspondence then out:insert(correspondence(meta, false)) end
  end
  out:insert(signature(meta))
  local cert = certificate(meta)
  if cert then out:insert(cert) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

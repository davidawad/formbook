-- Bankr. N.D. Okla. adversary complaint, docx engine (docs/DOCX.md).
-- Mirrors typst/oknb-adversary-complaint.typ: court title, caption (In re + parties in a 3.6 in left column with
-- right and bottom 0.75 pt borders; Case No., Chapter, Adv. No. in the right column), document title, generated
-- Jurisdiction and Venue (FRBP 7008(a)), numbered body paragraphs (FRBP 7010 / FRCP 10(b)), headings, lists,
-- unnumbered Prayer for Relief, optional jury demand (FRBP 9015), and signature block (LBR 9004-1(C)).
-- Every case-specific word comes from $FORMBOOK_META and the sample body; nothing case-specific lives here.

local xe = require("docx.xengine")

local BODY, SINGLE = 490, 286             -- typst 1.345em / 0.495em leading + 0.695em Times New Roman line box
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT, CAP_GUT = 5184, 360       -- 3.6 in left column, 0.25 in gutter
local CAP_RIGHT = TEXTW - CAP_LEFT        -- 4176 twips (includes 0.25 in gutter + 0.1 in left inset = 504 twips)
local SIG_LEFT, SIG_GUT = 3744, 288       -- 2.6 in date column, 0.2 in gutter
local SIG_RIGHT = TEXTW - SIG_LEFT        -- 5616 twips
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function slurp(path)
  local f = assert(io.open(path, "r"))
  local s = f:read("a")
  f:close()
  return s
end

local function read_meta()
  local path = os.getenv("FORMBOOK_META")
  if not path then error("oknb-adversary-complaint.lua: FORMBOOK_META is not set (render with fb render)", 0) end
  return pandoc.json.decode(slurp(path), false)
end

local function body_text()
  local src = slurp(PANDOC_STATE.input_files[1]):gsub("\r\n", "\n")
  local _, e = src:find("^%-%-%-\n.-\n%-%-%-[ \t]*\n")
  if not e then error("oknb-adversary-complaint.lua: the sample must start with a YAML frontmatter block", 0) end
  return src:sub(e + 1)
end

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
local function str(v) return v == nil and "" or tostring(v) end

local function list(v)
  local out = {}
  for _, x in ipairs(v or {}) do out[#out + 1] = x end
  return out
end

-- Break rules matching typst: break after slash before non-digit, keep doubled §/¶ with number.
local function breaks(s)
  return pandoc.Str((s.text:gsub("/([^%d%s])", "/\u{200B}%1")))
end

local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function fix(inlines)
  local d = pandoc.Pandoc({ pandoc.Plain(inlines) })
  d = d:walk({ Str = breaks }):walk({ Inlines = bind_double_signs }):walk({
    Inlines = function(l) return xe.nobreak_hyphens(xe.bind_signs(xe.unabbrev(l))) end
  })
  return d.blocks[1].content
end

-- Inline markdown as typst's cmarker reads it (CommonMark, smart punctuation).
local function md_inlines(s)
  local doc = pandoc.read(s, "commonmark+smart")
  local out = pandoc.Inlines({})
  for i, b in ipairs(doc.blocks) do
    if b.t ~= "Para" and b.t ~= "Plain" then
      error("oknb-adversary-complaint.lua: expected inline block, got " .. b.t .. ": " .. s, 0)
    end
    if i > 1 then out:insert(pandoc.Space()) end
    out:extend(b.content)
  end
  return fix(out)
end

-- Parse a chunk together with any footnote definitions it references.
local function md_chunk(s, defs_map)
  local refs = {}
  for r in s:gmatch("%[%^([^%]]+)%]") do
    if defs_map[r] and not refs[r] then
      refs[r] = true
    end
  end
  local extra = {}
  for r in pairs(refs) do
    extra[#extra + 1] = defs_map[r]
  end
  local full = #extra > 0 and (s .. "\n\n" .. table.concat(extra, "\n\n")) or s
  local doc = pandoc.read(full, "markdown+smart-fancy_lists")
  return doc:walk({ Inlines = function(l) return fix(l) end }).blocks
end

local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.keep_lines then props[#props + 1] = xe.LINES end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

local function styled(inlines, style)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, document title
-- ---------------------------------------------------------------------------

local function caption_table(meta)
  local cap = meta.caption or {}
  local left_paras = {}
  if cap.in_re then
    left_paras[#left_paras + 1] = p(xe.runs("In re:"))
    for _, name in ipairs(list(cap.in_re.names)) do
      left_paras[#left_paras + 1] = p(xe.inl(md_inlines(str(name))))
    end
    left_paras[#left_paras + 1] = p(xe.inl(md_inlines(str(cap.in_re.designation))), { after = 127 })
  end
  local parties = list(cap.parties)
  for k, party in ipairs(parties) do
    if k > 1 then
      left_paras[#left_paras + 1] = p(xe.runs("v."))
    end
    for _, name in ipairs(list(party.names)) do
      left_paras[#left_paras + 1] = p(xe.inl(md_inlines(str(name))))
    end
    left_paras[#left_paras + 1] = p(xe.inl(md_inlines(str(party.designation))))
  end
  if #left_paras == 0 then left_paras[1] = p("") end

  local right_paras = {
    p(xe.runs("Case No. " .. str(meta.case_number))),
    p(xe.runs("Chapter " .. str(meta.chapter))),
    p(xe.runs("Adv. No. " .. str(meta.adversary_number))),
  }

  local left_pr = '<w:tcBorders><w:right ' .. RULE .. '/><w:bottom ' .. RULE .. '/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="145" w:type="dxa"/></w:tcMar>'
  local right_pr = '<w:tcMar><w:left w:w="' .. (CAP_GUT + 144) .. '" w:type="dxa"/></w:tcMar>'

  return xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_RIGHT .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. left_pr .. '</w:tcPr>'
    .. table.concat(left_paras) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_RIGHT .. '" w:type="dxa"/>' .. right_pr .. '</w:tcPr>'
    .. table.concat(right_paras) .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

local function cover(meta)
  local out = {}
  out[#out + 1] = xe.raw(p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center", keep = true }))
  out[#out + 1] = xe.raw(p(xe.runs("NORTHERN DISTRICT OF OKLAHOMA", { b = true }),
    { jc = "center", keep = true, after = BODY - SINGLE }))
  out[#out + 1] = caption_table(meta)
  -- title-block: v(body-leading) above, height: pitch (480), v(body-leading * 0.5) below
  out[#out + 1] = xe.raw(p(xe.inl(md_inlines(str(meta.title)), { b = true }),
    { jc = "center", line = 286, before = 220, after = 620 }))
  return out
end

-- ---------------------------------------------------------------------------
-- Generated Jurisdiction and Venue (FRBP 7008(a)) and optional Jury Demand
-- ---------------------------------------------------------------------------

local function jurisdiction_md(meta)
  local j = meta.jurisdiction or {}
  local c = meta.core or {}
  local p1 = "This adversary proceeding relates to the chapter " .. str(meta.chapter)
    .. " bankruptcy case of " .. str(j.case_name) .. ", Case No. " .. str(meta.case_number)
    .. ", which was commenced by the filing of a voluntary petition on " .. str(j.petition_date)
    .. " and is pending in the United States Bankruptcy Court for the Northern District of Oklahoma."
  local p2 = "The Court has jurisdiction under 28 U.S.C. §§ 1334(b) and 157(a) and (b)(1)."
  local p3
  if c.is_core then
    p3 = "This is a core proceeding under 28 U.S.C. § 157(b)(2)" .. str(c.subsection) .. "."
  else
    p3 = "This is a non-core proceeding under 28 U.S.C. § 157(c)(1)."
  end
  local p3b = c.consent
    and "Plaintiff does consent to the entry of final orders or judgment by the Bankruptcy Court."
    or "Plaintiff does not consent to the entry of final orders or judgment by the Bankruptcy Court."
  local p4 = "Venue is proper in this district under 28 U.S.C. §§ 1408 and 1409(a)."
  return "# Jurisdiction and Venue\n\n" .. table.concat({ p1, p2, p3 .. " " .. p3b, p4 }, "\n\n")
end

local function jury_md(meta)
  if meta.jury_demand then
    return "\n\n# Demand for Jury Trial\n\nPlaintiff demands a trial by jury on all claims so triable, as provided by Fed. R. Civ. P. 38 and 39, made applicable by Fed. R. Bankr. P. 9015."
  end
  return ""
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 9004-1(C))
-- ---------------------------------------------------------------------------

local function signature_block(meta)
  local s = meta.signature or {}
  local sig_line = 264
  local left = { p(xe.runs("Dated: " .. str(meta.date)), { line = sig_line }) }
  local right = {
    p(xe.runs("Respectfully submitted,"), { line = sig_line, after = 110 }),
    p(xe.inl(md_inlines(str(s.firm))), { line = sig_line, after = 110 }),
    p(xe.inl(md_inlines("By: /s/ " .. str(s.signer))), { line = sig_line }),
    p(xe.inl(md_inlines(str(s.signer) .. " (" .. str(s.bar_number) .. ")")), { line = sig_line }),
  }
  for _, addr in ipairs(list(s.address)) do
    right[#right + 1] = p(xe.inl(md_inlines(str(addr))), { line = sig_line })
  end
  right[#right + 1] = p(xe.inl(md_inlines("Telephone: " .. str(s.telephone))), { line = sig_line })
  right[#right + 1] = p(xe.inl(md_inlines("Email: " .. str(s.email))), { line = sig_line })
  right[#right + 1] = p(xe.inl(md_inlines("Attorneys for " .. str(s["for"]))), { line = sig_line })

  local right_pr = '<w:tcMar><w:left w:w="' .. SIG_GUT .. '" w:type="dxa"/></w:tcMar>'
  return xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. SIG_LEFT .. '"/><w:gridCol w:w="' .. SIG_RIGHT .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. SIG_LEFT .. '" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. SIG_RIGHT .. '" w:type="dxa"/>' .. right_pr .. '</w:tcPr>'
    .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

-- ---------------------------------------------------------------------------
-- Body chunks
-- ---------------------------------------------------------------------------

local function letters(k)
  local s = ""
  while k > 0 do
    local r = (k - 1) % 26
    s = string.char(97 + r) .. s
    k = (k - 1 - r) // 26
  end
  return "(" .. s .. ")"
end

function Pandoc(_)
  local meta = read_meta()
  local out = cover(meta)

  local full = jurisdiction_md(meta) .. "\n\n" .. body_text() .. jury_md(meta)
  full = full:gsub("\r\n", "\n")

  local defs_map = {}
  for line in full:gmatch("[^\n]+") do
    local k = line:match("^%[%^([^%]]+)%]:")
    if k then defs_map[k] = line end
  end

  local chunks = {}
  local pos = 1
  while pos <= #full do
    local a, b = full:find("\n[ \t]*\n", pos)
    local chunk = a and full:sub(pos, a - 1) or full:sub(pos)
    local t = trim(chunk)
    if t ~= "" and not t:match("^%[%^") then
      chunks[#chunks + 1] = t
    end
    if not a then break end
    pos = b + 1
  end

  local para_num = 0
  local numbered = true
  for idx, t in ipairs(chunks) do
    local hashes, htext = t:match("^(#+)%s*(.*)$")
    if hashes then
      local lvl = #hashes
      if htext:match("^Prayer") then numbered = false end
      if lvl == 1 then
        local up = pandoc.text.upper(htext)
        -- Typst: block(height: pitch 480, above: body-leading 323, below: 0) at 16.8pt (sz 34)
        -- Previous line is 490 twips (167 line + 323 par.spacing); so before=123 matches typst baseline gap (613 twips),
        -- and line=480, after=187 matches 667 twips down to next paragraph.
        local bef = idx == 1 and 200 or 320
        out[#out + 1] = xe.raw(p(xe.inl(md_inlines(up), { b = true, sz = 34 }),
          { jc = "center", line = 530, before = bef, after = 180, keep = true }))
      elseif lvl == 2 then
        -- Typst: 14.4pt (sz 29) bold centered
        out[#out + 1] = xe.raw(p(xe.inl(md_inlines(htext), { b = true, sz = 29 }),
          { jc = "center", line = 490, before = 280, after = 90, keep = true }))
      else
        out[#out + 1] = xe.raw(p(xe.inl(md_inlines(htext), { b = true, i = true, sz = 24 }),
          { jc = "left", line = 480, before = 323, after = 93, keep = true }))
      end
    elseif t:match("^%d+%.[ \t]") or t:match("^[-*+][ \t]") then
      local blocks = md_chunk(t, defs_map)
      for _, b in ipairs(blocks) do
        if b.t == "OrderedList" or b.t == "BulletList" then
          local bullet = b.t == "BulletList"
          for j, item in ipairs(b.content) do
            local lab = bullet and "\u{2022}" or letters(j)
            local inl = pandoc.Inlines({ pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
            for _, sub in ipairs(item) do
              if sub.t == "Para" or sub.t == "Plain" then inl:extend(sub.content) end
            end
            out[#out + 1] = styled(inl, "List Alpha")
          end
        else
          out[#out + 1] = b
        end
      end
    else
      local blocks = md_chunk(t, defs_map)
      for _, b in ipairs(blocks) do
        if b.t == "Para" or b.t == "Plain" then
          if numbered then
            para_num = para_num + 1
            local inl = pandoc.Inlines({ pandoc.Str(para_num .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
            inl:extend(b.content)
            local st = para_num < 10 and "Numbered 1" or (para_num < 100 and "Numbered 2" or "Numbered 3")
            out[#out + 1] = styled(inl, st)
          else
            out[#out + 1] = styled(b.content, "Body Flush")
          end
        elseif b.t == "BlockQuote" then
          for _, qb in ipairs(b.content) do
            if qb.t == "Para" or qb.t == "Plain" then
              out[#out + 1] = pandoc.BlockQuote({ pandoc.Para(qb.content) })
            else
              out[#out + 1] = qb
            end
          end
        else
          out[#out + 1] = b
        end
      end
    end
  end

  out[#out + 1] = signature_block(meta)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

-- Bankr. N.D. Okla. motion with memorandum, docx engine (docs/DOCX.md).
-- Mirrors typst/oknb-motion-brief.typ: court title, caption (In re and/or parties in a 3.6 in left column with
-- right and bottom 0.75 pt borders; Case No., Chapter, optional Adv. No. in the right column), document title,
-- LBR 9013-1(B) NOTICE OF OPPORTUNITY FOR HEARING box + response-time paragraph, numbered headings (I., A., 1.),
-- body paragraphs with footnotes, single-spaced unbreakable tables, block quotations, lists, signature block
-- (LBR 9004-1(C)), and certificate of service (LBR 9013-1(G)(2), 5005-1(E)).
-- Every case-specific word comes from $FORMBOOK_META and the sample body; nothing case-specific lives here.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 286             -- double-spaced 24 pt, single-spaced 14.3 pt
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT, CAP_GUT = 5184, 360       -- 3.6 in left column, 0.25 in gutter
local CAP_RIGHT = TEXTW - CAP_LEFT        -- 4176 twips
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
  if not path then error("oknb-motion-brief.lua: FORMBOOK_META is not set (render with fb render)", 0) end
  return pandoc.json.decode(slurp(path), false)
end

local function body_text()
  local src = slurp(PANDOC_STATE.input_files[1]):gsub("\r\n", "\n")
  local _, e = src:find("^%-%-%-\n.-\n%-%-%-[ \t]*\n")
  if not e then error("oknb-motion-brief.lua: the sample must start with a YAML frontmatter block", 0) end
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

local function md_inlines(s)
  local doc = pandoc.read(s, "commonmark+smart")
  local out = pandoc.Inlines({})
  for i, b in ipairs(doc.blocks) do
    if b.t ~= "Para" and b.t ~= "Plain" then
      error("oknb-motion-brief.lua: expected inline block, got " .. b.t .. ": " .. s, 0)
    end
    if i > 1 then out:insert(pandoc.Space()) end
    out:extend(b.content)
  end
  return fix(out)
end

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
  if o.page_break then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

local function styled(inlines, style)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, document title, LBR 9013-1(B) notice box
-- ---------------------------------------------------------------------------

local function caption_table(meta)
  local cap = meta.caption or {}
  local left_paras = {}
  local parties = list(cap.parties)
  if cap.in_re then
    left_paras[#left_paras + 1] = p(xe.runs("In re:"))
    for _, name in ipairs(list(cap.in_re.names)) do
      left_paras[#left_paras + 1] = p(xe.inl(md_inlines(str(name))))
    end
    local desig_after = #parties > 0 and 127 or 0
    left_paras[#left_paras + 1] = p(xe.inl(md_inlines(str(cap.in_re.designation))), { after = desig_after })
  end
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
  }
  if meta.adversary_number ~= nil then
    right_paras[#right_paras + 1] = p(xe.runs("Adv. No. " .. str(meta.adversary_number)))
  end

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

local function notice_block(meta)
  local days = str(meta.response_days)
  local body_txt = "Your rights may be affected. You should read this document carefully and consult your attorney about your rights and the effect of this document. If you do not want the Court to grant the requested relief, or you wish to have your views considered, you must file a written response or objection to the requested relief with the Clerk of the United States Bankruptcy Court for the Northern District of Oklahoma, 224 South Boulder, Tulsa, Oklahoma 74103 no later than "
    .. days .. " days from the date of filing of this request for relief. You should also serve a file-stamped copy of your response or objection to the undersigned movant/movant's attorney [and others who are required to be served] and file a certificate of service with the Court. If no response or objection is timely filed, the Court may grant the requested relief without a hearing or further notice. The "
    .. days .. " day period includes the three (3) days allowed for mailing provided for in Fed. R. Bankr. P. 9006(f)."

  local box_pr = '<w:tcBorders><w:top ' .. RULE .. '/><w:left ' .. RULE .. '/><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>'
    .. '<w:tcMar><w:top w:w="140" w:type="dxa"/><w:left w:w="200" w:type="dxa"/><w:bottom w:w="140" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  local box_paras = {
    p(xe.runs("NOTICE OF OPPORTUNITY FOR HEARING", { b = true }), { jc = "center", after = 80 }),
    p(xe.inl(md_inlines(body_txt))),
  }
  local box = xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. TEXTW .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. box_pr .. '</w:tcPr>'
    .. table.concat(box_paras) .. '</w:tc></w:tr></w:tbl>')

  local calc_txt = "The moving party shall calculate the appropriate response time. If a response time is prescribed by applicable statute, rule, or order, the moving party shall add to the prescribed response time unless service is accomplished by hand delivery, the three (3) days required for mailing under Bankruptcy Rule 9006(f). If a response time is not prescribed by applicable statute, rule, or order, the response time shall be fourteen (14) days, which includes the three (3) days required for mailing under Bankruptcy Rule 9006(f)."
  local calc = xe.raw(p(xe.inl(md_inlines(calc_txt)), { before = 120, after = 360, keep_lines = true }))
  return { box, calc }
end

local function cover(meta)
  local out = {}
  out[#out + 1] = xe.raw(p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center", keep = true }))
  out[#out + 1] = xe.raw(p(xe.runs("NORTHERN DISTRICT OF OKLAHOMA", { b = true }),
    { jc = "center", keep = true, after = BODY - SINGLE }))
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = xe.raw(p(xe.inl(md_inlines(str(meta.title)), { b = true }),
    { jc = "center", line = BODY, before = 80, after = 60, keep_lines = true }))
  if meta.notice_of_opportunity then
    for _, b in ipairs(notice_block(meta)) do out[#out + 1] = b end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Headings (I., A., 1.) and Tables
-- ---------------------------------------------------------------------------

local function roman(n)
  local map = {
    { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" },
    { 100, "C" }, { 90, "XC" }, { 50, "L" }, { 40, "XL" },
    { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" },
  }
  local out = {}
  for _, pair in ipairs(map) do
    while n >= pair[1] do out[#out + 1] = pair[2]; n = n - pair[1] end
  end
  return table.concat(out)
end

local function cell_inlines(cell)
  local out = pandoc.Inlines({})
  for i, blk in ipairs(cell.contents or {}) do
    if blk.t == "Para" or blk.t == "Plain" then
      if i > 1 then out:insert(pandoc.Space()) end
      out:extend(blk.content)
    end
  end
  return out
end

local function render_table(tbl)
  local ncols = #tbl.colspecs
  local all_rows = {}
  for _, r in ipairs((tbl.head and tbl.head.rows) or {}) do all_rows[#all_rows + 1] = r end
  for _, bd in ipairs(tbl.bodies or {}) do
    for _, r in ipairs(bd.head or {}) do all_rows[#all_rows + 1] = r end
    for _, r in ipairs(bd.body or {}) do all_rows[#all_rows + 1] = r end
  end
  for _, r in ipairs((tbl.foot and tbl.foot.rows) or {}) do all_rows[#all_rows + 1] = r end

  local widths
  if ncols == 4 then
    widths = { 2240, 2560, 2120, 2440 }
  else
    widths = {}
    local w = math.floor(TEXTW / ncols)
    for i = 1, ncols do widths[i] = w end
    widths[ncols] = widths[ncols] + (TEXTW - w * ncols)
  end

  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end

  local trs = {}
  for ri, r in ipairs(all_rows) do
    local tcs = {}
    local keep_next = ri < #all_rows
    for ci, c in ipairs(r.cells or {}) do
      local align = tbl.colspecs[ci] and tbl.colspecs[ci][1] or "AlignDefault"
      local jc = align == "AlignRight" and "right" or (align == "AlignCenter" and "center" or "left")
      local inl = cell_inlines(c)
      local para_xml = p(xe.inl(inl), { jc = jc, line = SINGLE, keep = keep_next, keep_lines = true })
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. (widths[ci] or 2000) .. '" w:type="dxa"/></w:tcPr>'
        .. para_xml .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end

  local borders = '<w:tblBorders><w:top ' .. RULE .. '/><w:left ' .. RULE .. '/><w:bottom ' .. RULE .. '/>'
    .. '<w:right ' .. RULE .. '/><w:insideH ' .. RULE .. '/><w:insideV ' .. RULE .. '/></w:tblBorders>'
  local mar = '<w:tblCellMar><w:top w:w="100" w:type="dxa"/><w:left w:w="100" w:type="dxa"/>'
    .. '<w:bottom w:w="100" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tblCellMar>'

  return xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. borders
    .. '<w:tblLayout w:type="fixed"/>' .. mar
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>')
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 9004-1(C)) and Certificate of Service (LBR 9013-1(G)(2))
-- ---------------------------------------------------------------------------

local function signature_block(meta)
  local s = meta.signature or {}
  local sig_line = SINGLE
  local left = { p(xe.runs("Dated: " .. str(meta.date)), { line = sig_line }) }
  local right = {
    p(xe.runs("Respectfully submitted,"), { line = sig_line, after = 122 }),
    p(xe.inl(md_inlines(str(s.firm))), { line = sig_line, after = 122 }),
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

local function certificate_block(meta)
  local c = meta.certificate or {}
  local served = list(c.served)
  local out = {}
  out[#out + 1] = xe.raw(p(xe.runs("CERTIFICATE OF SERVICE", { b = true }),
    { jc = "center", page_break = true, line = SINGLE, after = 161, keep = true }))

  local txt = "I certify that on " .. str(c.date) .. ", I served a true and correct copy of the "
    .. str(c.document) .. ", by " .. str(c.method)
    .. (#served > 0 and ", on the parties listed below" or "")
    .. ". Parties registered to receive electronic notice through the Court\u{2019}s CM/ECF system were served by the Notice of Electronic Filing (LBR 5005-1(E))."
  out[#out + 1] = styled({ pandoc.Str(txt) }, "Body Text")

  for _, s in ipairs(served) do
    out[#out + 1] = xe.raw(p(xe.inl(md_inlines(str(s))), { left = 720, line = SINGLE, after = 161 }))
  end
  out[#out + 1] = xe.raw(p(xe.runs("/s/ " .. str((meta.signature or {}).signer)),
    { line = SINGLE, keep_lines = true }))
  return out
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

  local full = body_text():gsub("\r\n", "\n")
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

  local c1, c2, c3 = 0, 0, 0
  for _, t in ipairs(chunks) do
    local hashes, htext = t:match("^(#+)%s*(.*)$")
    if hashes then
      local lvl = #hashes
      if lvl == 1 then
        c1 = c1 + 1; c2 = 0; c3 = 0
        local lab = roman(c1) .. ". "
        out[#out + 1] = xe.raw(p(xe.inl(md_inlines(lab .. htext), { b = true, sz = 34 }),
          { jc = "center", line = 620, before = 160, after = 80, keep = true }))
      elseif lvl == 2 then
        c2 = c2 + 1; c3 = 0
        local lab = string.char(64 + c2) .. ".\t"
        out[#out + 1] = xe.raw(p(xe.runs(lab, { b = true, sz = 29 }) .. xe.inl(md_inlines(htext), { b = true, sz = 29 }),
          { left = 720, hanging = 720, tabs = '<w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs>',
            line = 588, before = 240, after = 120, keep = true }))
      else
        c3 = c3 + 1
        local lab = c3 .. ".\t"
        out[#out + 1] = xe.raw(p(xe.runs(lab, { b = true, i = true, sz = 24 }) .. xe.inl(md_inlines(htext), { b = true, i = true, sz = 24 }),
          { left = 1440, hanging = 720, tabs = '<w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>',
            line = 480, before = 240, after = 120, keep = true }))
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
          out[#out + 1] = styled(b.content, "Body Text")
        elseif b.t == "BlockQuote" then
          for _, qb in ipairs(b.content) do
            if qb.t == "Para" or qb.t == "Plain" then
              out[#out + 1] = styled(qb.content, "Block Text")
            else
              out[#out + 1] = qb
            end
          end
        elseif b.t == "Table" then
          out[#out + 1] = render_table(b)
        else
          out[#out + 1] = b
        end
      end
    end
  end

  out[#out + 1] = signature_block(meta)
  for _, b in ipairs(certificate_block(meta)) do out[#out + 1] = b end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

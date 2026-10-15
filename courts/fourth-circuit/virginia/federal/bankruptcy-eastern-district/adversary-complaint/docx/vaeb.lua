-- E.D. Va. Bankruptcy pleadings (vaeb), DOCX engine (docs/DOCX.md): the markdown contract (YAML frontmatter and
-- body) becomes a Word document on docx/reference.docx. It mirrors typst/vaeb-adversary-complaint.typ and
-- typst/vaeb-motion-brief.typ, which share this layout: the counsel block and the court title on page 1, the caption
-- (a borderless three-column table: party column, column of ")" marks, bankruptcy and adversary numbers), the title,
-- the body (paragraphs under the sections named in numbered_sections are numbered 1, 2, ...; ordered lists are
-- lettered (a), (b), ...; bullets stay bullets), the signature block and the certificate of service.
-- Every case word comes from the frontmatter. The same file is in docx/ of both doc types; `kind` selects the checks.
-- Layout values are in docx/reference.docx (built by docx/build-reference.sh); this file only writes paragraphs.

local TW = 9360                              -- text width: 6.5 in, in twips
local CAP_LEFT, CAP_PAREN = 4896, 432        -- caption columns: 3.4 in, 0.3 in
local CAP_RIGHT = TW - CAP_LEFT - CAP_PAREN  -- 2.8 in
local SIG_DATE, SIG_GAP = 3888, 288          -- signature columns: 2.7 in, 0.2 in
local SIG_RIGHT = TW - SIG_DATE - SIG_GAP    -- 3.6 in
local GAP = 324                              -- v(body-leading): 16.2 pt
local GAP_S = 204                             -- the gap after a single-spaced block: v(16.2 pt) less the 6 pt a single line carries below
local HALF = 162                             -- v(body-leading * 0.5): 8.1 pt
local INDENT = 720                           -- 0.5 in: paragraph indent and the address indent
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function check(cond, msg)
  if not cond then error("vaeb docx: " .. msg, 0) end
end

-- ---------------------------------------------------------------------------
-- Metadata to text and runs
-- ---------------------------------------------------------------------------

local function text_of(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- a metadata value as inlines (markdown in the frontmatter keeps its italics)
local function inlines_of(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == nil or v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function with(flags, key, val)
  local t = {}
  for k, v in pairs(flags) do t[k] = v end
  t[key] = val
  return t
end

-- run properties in schema order: bold, italic, underline
local function rpr(f)
  local x = ""
  if f.b then x = x .. "<w:b/><w:bCs/>" end
  if f.i then x = x .. "<w:i/><w:iCs/>" end
  if f.u then x = x .. '<w:u w:val="single"/>' end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function run(text, f)
  return "<w:r>" .. rpr(f or {}) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local QUOTES = {
  SingleQuote = { "\u{2018}", "\u{2019}" },
  DoubleQuote = { "\u{201C}", "\u{201D}" },
}

local function runs(inlines, f)
  f = f or {}
  local out = {}
  for _, il in ipairs(inlines) do
    local t = il.t
    if t == "Str" then
      out[#out + 1] = run(il.text, f)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "Emph" then
      out[#out + 1] = runs(il.content, with(f, "i", true))
    elseif t == "Strong" then
      out[#out + 1] = runs(il.content, with(f, "b", true))
    elseif t == "Quoted" then
      local q = QUOTES[il.quotetype]
      out[#out + 1] = run(q[1], f) .. runs(il.content, f) .. run(q[2], f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(il), f)
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Raw WordprocessingML: paragraphs, spacers, borderless tables
-- ---------------------------------------------------------------------------

-- a paragraph; o.style is a paragraph style id, o.before/o.after in twips, o.line an exact line height (twips),
-- o.indent (left) in twips
local function p(content, o)
  o = o or {}
  local pp = ""
  if o.style then pp = pp .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep then pp = pp .. "<w:keepNext/>" end
  if o.before or o.after or o.line then
    local line = o.line and (' w:line="' .. o.line .. '" w:lineRule="exact"') or ""
    pp = pp .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '"' .. line .. "/>"
  end
  if o.indent then pp = pp .. '<w:ind w:left="' .. o.indent .. '" w:firstLine="0"/>' end
  local ppr = pp ~= "" and ("<w:pPr>" .. pp .. "</w:pPr>") or ""
  return "<w:p>" .. ppr .. (content or "") .. "</w:p>"
end

-- an empty paragraph of exact height h (twips): the v(...) gaps of the typst template
local function gap(h)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. h
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- rows of cells (each cell: paragraphs as a string); no borders, no cell insets
local function grid(widths, rows)
  local total, cols = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(cols) .. "</w:tblGrid>" }
  for _, row in ipairs(rows) do
    local cells = {}
    for i, cell in ipairs(row) do
      cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>'
        .. (cell ~= "" and cell or p("", { style = "Single" })) .. "</w:tc>"
    end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

local function single_line(inl, o)
  o = o or {}
  o.style = o.style or "Single"
  return p(runs(inl, o.bold and { b = true } or {}), o)
end

-- ---------------------------------------------------------------------------
-- Page one: counsel, court, caption, title (LBR 5005-1(C)(5); FRBP 7010, Form 416)
-- ---------------------------------------------------------------------------

local function court_title(meta)
  return {
    p(run("IN THE UNITED STATES BANKRUPTCY COURT", { b = true }), { style = "Centered" }),
    p(run("FOR THE EASTERN DISTRICT OF VIRGINIA", { b = true }), { style = "Centered" }),
    p(runs(inlines_of(meta.division)), { style = "Centered" }),
  }
end

-- the caption rows: left = {xml, indent}; the right column is numbered as in the typst template
local function caption(meta)
  local left = {
    { run("In re:"), 0 },
    { runs(inlines_of(meta.debtor.name)) .. run(","), INDENT },
    { run("Debtor."), INDENT },
    { "", 0 },
  }
  local party_start = #left
  for k, party in ipairs(meta.parties) do
    if k > 1 then left[#left + 1] = { run("v."), 360 } end
    for _, n in ipairs(party.names) do
      left[#left + 1] = { runs(inlines_of(n)), 0 }
    end
    left[#left + 1] = { runs(inlines_of(party.designation)), INDENT }
  end
  local adv_row = party_start + 1 -- 0-based index of the row that carries "Adversary Proceeding"
  local adv_number = text_of(meta.adversary_number)
  local rows = {}
  for i = 0, #left - 1 do
    local right = ""
    if i == 0 then
      right = run("Chapter " .. text_of(meta.debtor.chapter))
    elseif i == 1 then
      right = run("Case No. " .. text_of(meta.debtor.case_number))
    elseif i == adv_row then
      right = run("Adversary Proceeding")
    elseif i == adv_row + 1 then
      if adv_number ~= "" then
        right = run("Case No. " .. adv_number)
      else
        right = run("Case No. ") .. run(string.rep("\u{00A0}", 37), { u = true })
      end
    end
    rows[#rows + 1] = {
      p(left[i + 1][1], { style = "Single", indent = left[i + 1][2] }),
      p(run(")"), { style = "Single" }),
      p(right, { style = "Single", indent = 216 }),
    }
  end
  return grid({ CAP_LEFT, CAP_PAREN, CAP_RIGHT }, rows)
end

local function cover(meta)
  local out = {}
  for _, c in ipairs(meta.counsel) do
    out[#out + 1] = single_line(inlines_of(c))
  end
  out[#out + 1] = gap(GAP_S)
  for _, x in ipairs(court_title(meta)) do out[#out + 1] = x end
  out[#out + 1] = gap(GAP_S)
  out[#out + 1] = caption(meta)
  out[#out + 1] = gap(GAP_S)
  out[#out + 1] = p(run(string.upper(text_of(meta.title)), { b = true }), { style = "Centered" })
  -- no gap after the title: the body line that follows is an exact 24 pt line already (typst: v(body-leading))
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

-- the signature block: one row, the date at left and the firm, "/s/" and the signer's lines at right.
-- The space above it (8.2 pt, so the block sits 24 pt below the text above, as in typst) is paragraph
-- spacing inside the row, not an empty paragraph before the table (LibreOffice drops those).
local SIG_TOP = 164

local function signature(meta)
  local sig = meta.signature
  local firm = sig.firm or {}
  local motion = text_of(meta.kind) == "motion-brief"
  local lines = {} -- { run xml, space before (twips) }
  if motion then
    lines[#lines + 1] = { run("Respectfully submitted,"), 0 }
  end
  -- typst: v(body-leading * 0.5) after "Respectfully submitted," (before the firm, or before the "/s/" line)
  local gap_next = motion and HALF or 0
  for _, f in ipairs(firm) do
    lines[#lines + 1] = { runs(inlines_of(f)), gap_next }
    gap_next = 0
  end
  local signer = text_of(sig.signer)
  lines[#lines + 1] = { run((#firm > 0 and "By: /s/ " or "/s/ ") .. signer), gap_next }
  for _, l in ipairs(sig.lines or {}) do
    lines[#lines + 1] = { runs(inlines_of(l)), 0 }
  end
  lines[1][2] = lines[1][2] + SIG_TOP
  local right = {}
  for _, l in ipairs(lines) do
    right[#right + 1] = p(l[1], { style = "Single", before = l[2] })
  end
  local date = ""
  if meta.date ~= nil then date = "Date: " .. text_of(meta.date) end
  return { grid({ SIG_DATE, SIG_GAP, SIG_RIGHT }, {
    { p(run(date), { style = "Single", before = SIG_TOP }), "", table.concat(right) },
  }) }
end

local function service(meta)
  local s = meta.service
  if s == nil then return {} end
  local mailed = s.mailed or {}
  -- typst: the block starts v(body-leading) below the text above; its heading is one 7.8 pt line
  local out = {
    p(run("CERTIFICATE OF SERVICE", { b = true }), { style = "Centered", keep = true, before = GAP_S, line = 276 }),
  }
  local tail = #mailed > 0 and " and a copy mailed to the following:" or "."
  out[#out + 1] = p(run("I hereby certify that on the " .. text_of(s.date)
    .. ", I caused a copy of the foregoing to be served by electronic means through the ECF system" .. tail),
    { style = "BodyText" })
  -- the service list: two columns, row by row, each address single spaced; a row is 12 pt from the next
  -- (typst row-gutter), which is 6 pt after its last line, since a single line carries 6 pt below it
  local last_row = math.ceil(#mailed / 2)
  local rows = {}
  for i = 1, #mailed, 2 do
    local row = (i + 1) / 2
    local cells = {}
    for _, j in ipairs({ i, i + 1 }) do
      local addr = mailed[j]
      if addr then
        local lines = {}
        for k, line in ipairs(addr) do
          lines[#lines + 1] = p(runs(inlines_of(line)), { style = "Single", indent = INDENT,
            after = k == #addr and row < last_row and 120 or 0 })
        end
        cells[#cells + 1] = table.concat(lines)
      else
        cells[#cells + 1] = ""
      end
    end
    rows[#rows + 1] = { cells[1], "", cells[2] }
  end
  if #rows > 0 then
    out[#out + 1] = grid({ 4464, 432, 4464 }, rows)
  end
  -- typst: v(body-leading) after the list, then the signature, right aligned in a 3.2 in block
  local signer = text_of(s.signer)
  out[#out + 1] = p(run("/s/ " .. signer), { style = "Single", indent = TW - 4608, before = #mailed > 0 and GAP_S or 0 })
  out[#out + 1] = p(run(signer), { style = "Single", indent = TW - 4608 })
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function letter(i)
  if i <= 26 then return "(" .. string.char(96 + i) .. ")" end
  return "(" .. i .. ")"
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- blocks -> blocks: numbering of the named sections, lettered lists
local function transform(blocks, numbered, counter, nums)
  local out = {}
  local in_numbered = false
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        in_numbered = numbered[string.upper(pandoc.utils.stringify(b.content))] == true
      end
      out[#out + 1] = b
    elseif b.t == "Para" and in_numbered then
      counter.n = counter.n + 1
      local inl = { pandoc.Str(counter.n .. "."), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      local start = (b.t == "OrderedList" and b.listAttributes and b.listAttributes.start) or 1
      for i, item in ipairs(b.content) do
        local mark = b.t == "OrderedList" and letter(start + i - 1) or "\u{2022}"
        local first = item[1]
        local rest = {}
        for j = 2, #item do rest[#rest + 1] = item[j] end
        if first and (first.t == "Plain" or first.t == "Para") then
          local inl = { pandoc.Str(mark), TAB }
          for _, x in ipairs(first.content) do inl[#inl + 1] = x end
          out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered" }))
        end
        for _, x in ipairs(transform(rest, {}, counter, nums)) do out[#out + 1] = x end
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

local function all_text(blocks)
  local t = {}
  for _, b in ipairs(blocks) do t[#t + 1] = pandoc.utils.stringify(b) end
  return table.concat(t, "\n")
end

function Pandoc(doc)
  local meta = doc.meta
  local kind = text_of(meta.kind)
  check(kind == "adversary-complaint" or kind == "motion-brief", "frontmatter kind must be adversary-complaint or motion-brief")
  check(meta.counsel ~= nil and #meta.counsel > 0, "LBR 5005-1(C)(5): counsel, State Bar number and address are required on page 1")
  check(meta.division ~= nil, "FRBP 7010 (Form 416): the division of the court is required in the caption")
  check(meta.debtor ~= nil and meta.debtor.name ~= nil and meta.debtor.chapter ~= nil and meta.debtor.case_number ~= nil,
    "LBR 5005-1(C)(2): the debtor's name, chapter and case number must appear on the document")
  check(meta.parties ~= nil and #meta.parties > 0, "FRCP 10(a): the caption must name the parties")
  check(meta.title ~= nil, "FRCP 10(a): the title of the paper is required")
  local text = all_text(doc.blocks)
  local upper_text = string.upper(text)
  if kind == "adversary-complaint" then
    check(string.find(upper_text, "JURISDICTION AND VENUE", 1, true), "FRBP 7008(a): a jurisdiction statement is required")
    check(string.find(string.lower(text), "core", 1, true), "FRBP 7008(a): the complaint must say whether the proceeding is core or non-core")
    check(string.find(upper_text, "PRAYER FOR RELIEF", 1, true), "FRBP 7008(a): the complaint must demand the relief sought")
  else
    check(string.find(upper_text, "WHEREFORE", 1, true), "LBR 9013-1(C): the motion must state the relief sought")
    if meta.summary_judgment == true then
      check(string.find(upper_text, "STATEMENT OF UNDISPUTED MATERIAL FACTS", 1, true),
        "LBR 7056-1(C): a summary judgment memorandum must include a Statement of Undisputed Material Facts")
      check(meta.numbered_sections ~= nil and #meta.numbered_sections > 0,
        "LBR 7056-1(C): the Statement of Undisputed Material Facts must be in numbered paragraphs")
    end
  end

  local numbered = {}
  for _, s in ipairs(meta.numbered_sections or {}) do
    numbered[string.upper(text_of(s))] = true
  end
  local body = transform(doc.blocks, numbered, { n = 0 }, {})
  -- the closing paragraph (the prayer, or the WHEREFORE clause) stays with the signature block: a signature
  -- alone at the top of a page is a defect (style "Closing" is keep-with-next in reference.docx)
  local last = body[#body]
  if last and last.t == "Para" then
    body[#body] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "Closing" }))
  end

  local blocks = {}
  local function raw(list)
    for _, x in ipairs(list) do blocks[#blocks + 1] = pandoc.RawBlock("openxml", x) end
  end
  raw(cover(meta))
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  raw(signature(meta))
  raw(service(meta))
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

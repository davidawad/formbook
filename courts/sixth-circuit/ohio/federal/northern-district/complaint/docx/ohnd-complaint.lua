-- N.D. Ohio complaint (ohnd), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/ohnd-complaint.typ:
--   * a 0.5 in spacer at the top of page 1 (the 1 1/2 in first-page top margin, L.R. 10.1);
--   * court title (Single, centered bold), caption as a borderless table (party column, a column of ")" marks,
--     "Case No." and "Judge:" at the right), the title centered bold, all from the sample's frontmatter;
--   * body paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b)); a paragraph beginning with the marker
--     <!--u--> is unnumbered (the WHEREFORE clause); a paragraph that is only bold text is an unnumbered label;
--   * markdown ordered lists lettered A., B., ... (the template's enum);
--   * signature block at 3.5 in (Signature style), kept with the last paragraph; the jury demand if asked.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter.
-- Known differences (see README.md, "Engines"): a party name that wraps across lines gets one ")" per name, not one per
-- wrapped line, because a Word table row does not know its wrap count.

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return (s:gsub('"', "&quot;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or a single value) as a Lua list of strings
local function strings(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then
    for _, item in ipairs(v) do out[#out + 1] = text(item) end
  else
    out[1] = text(v)
  end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("ohnd-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one paragraph. opts: style, ind (left twips), first (first-line twips), jc, keepNext, rpr (run properties XML),
-- line (exact twips; overrides the style's line pitch), before, after
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.keepLines then ppr = ppr .. "<w:keepLines/>" end
  if opts.line then
    ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0)
      .. '" w:line="' .. opts.line .. '" w:lineRule="exact"/>'
  elseif opts.before or opts.after then
    ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) .. '"/>'
  end
  if opts.ind or opts.first then
    ppr = ppr .. '<w:ind w:left="' .. (opts.ind or 0) .. '" w:firstLine="' .. (opts.first or 0) .. '"/>'
  end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local run = ""
  if s ~= nil and s ~= "" then
    run = '<w:r>' .. (opts.rpr and ('<w:rPr>' .. opts.rpr .. '</w:rPr>') or '')
      .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
  end
  return '<w:p>' .. (ppr ~= "" and ('<w:pPr>' .. ppr .. '</w:pPr>') or '') .. run .. '</w:p>'
end

local BOLD = "<w:b/><w:bCs/>"

-- one single-spaced line of blank space at the body's double pitch (a v(body-pitch) of the typst template)
local function blank_line(keep)
  return p("", { style = "Single", line = 552, keepNext = keep })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- a table: widths in twips; rows[r][c] = cell XML (paragraphs)
local function table_xml(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for c, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/></w:tcPr>' .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- caption (Fed. R. Civ. P. 10(a)); widths as typst: party column 3.3 in, ")" column 0.3 in, the rest
-- ---------------------------------------------------------------------------

local CAP_W = { 4752, 432, 4176 }

local function caption(meta)
  local out = {}
  -- the first page's top margin is 1 1/2 in: a 0.5 in spacer above the court title (typst: v(first-page-top - margin))
  out[#out + 1] = p("", { style = "Single", line = 720 })
  local court = { "UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF OHIO" }
  if meta.division ~= nil then court[#court + 1] = string.upper(text(meta.division)) end
  for _, l in ipairs(court) do
    out[#out + 1] = p(l, { style = "Centered", rpr = BOLD })
  end
  out[#out + 1] = blank_line()

  local c = need(meta, "caption")
  local rows = {}
  for k, side in ipairs(need(c, "parties")) do
    if k > 1 then
      rows[#rows + 1] = { t = "", indent = 0 }
      rows[#rows + 1] = { t = "v.", indent = 1080 }
      rows[#rows + 1] = { t = "", indent = 0 }
    end
    for _, n in ipairs(strings(side.names)) do rows[#rows + 1] = { t = n, indent = 0 } end
    rows[#rows + 1] = { t = text(side.designation), indent = 2160 }
  end
  -- the right column: "Case No." on the first row, "Judge:" two rows lower (typst: the rowspan cell)
  local judge = meta.judge ~= nil and text(meta.judge) or ""
  local trs = {}
  for i, r in ipairs(rows) do
    local right = ""
    if i == 1 then right = "Case No. " .. text(need(meta, "case_number")) end
    if i == 3 then right = "Judge: " .. judge end
    trs[#trs + 1] = {
      p(r.t, { style = "Single", ind = r.indent }),
      p(r.t == "" and "" or ")", { style = "Single" }),
      p(right, { style = "Single", ind = (i <= 3) and 432 or 0 }),
    }
  end
  out[#out + 1] = table_xml(CAP_W, trs)

  out[#out + 1] = blank_line()
  out[#out + 1] = p(text(need(meta, "title")), { style = "Centered", rpr = BOLD })
  out[#out + 1] = blank_line()
  return out
end

-- ---------------------------------------------------------------------------
-- signature block (Fed. R. Civ. P. 11; L.R. 10.1 details in the lines of the frontmatter)
-- ---------------------------------------------------------------------------

local function signature(meta, keep_first)
  local sig = need(meta, "signature")
  local out = { p("Respectfully submitted,", { style = "Signature", keepNext = true }), p("", { style = "Single", keepNext = true }) }
  local lines = strings(need(sig, "lines"))
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { style = "Signature", keepNext = i < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- body
-- ---------------------------------------------------------------------------

local UNNUMBERED = "<!--u-->"

-- true when the paragraph starts with the unnumbered marker; the marker is removed from the paragraph
local function strip_marker(para)
  local first = para.content[1]
  if first and first.t == "RawInline" and first.format:match("html") and first.text == UNNUMBERED then
    table.remove(para.content, 1)
    return true
  end
  return false
end

-- a paragraph whose only content is bold text: an unnumbered run-in label of the template
local function is_label(para)
  return #para.content == 1 and para.content[1].t == "Strong"
end

local function letter(n)
  return string.char(64 + n)
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  if meta.lead_in ~= nil then
    out[#out + 1] = pandoc.RawBlock("openxml", p(text(meta.lead_in), { style = "BodyText" }))
  end
  -- the caption carries the title; pandoc would otherwise write the metadata title again
  meta.title = nil

  local n = 0
  local body = {}
  local unnumbered = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "RawBlock" and b.format:match("html") and b.text == UNNUMBERED then
      -- a block comment on its own line: the paragraph that follows it is unnumbered (pandoc splits the line)
      unnumbered = true
    elseif b.t == "Para" then
      if unnumbered or strip_marker(b) then
        unnumbered = false
        body[#body + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "BodyText" }))
      elseif is_label(b) then
        body[#body + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Label" }))
      else
        n = n + 1
        table.insert(b.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
        table.insert(b.content, 1, pandoc.Str(n .. "."))
        body[#body + 1] = b
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes and b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local para = pandoc.Para(first.content)
          table.insert(para.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
          table.insert(para.content, 1, pandoc.Str(letter(start + i - 1) .. "."))
          body[#body + 1] = pandoc.Div({ para }, pandoc.Attr("", {}, { ["custom-style"] = "Enum" }))
          for j = 2, #item do body[#body + 1] = item[j] end
        else
          for _, sub in ipairs(item) do body[#body + 1] = sub end
        end
      end
    else
      body[#body + 1] = b
    end
  end
  -- the last paragraph is kept with the signature block (the signature never stands alone)
  for k = #body, 1, -1 do
    if body[k].t == "Para" then
      body[k] = pandoc.Div({ body[k] }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" }))
      break
    end
  end
  for _, b in ipairs(body) do out[#out + 1] = b end

  if meta.jury_demand ~= nil and meta.jury_demand ~= false then
    out[#out + 1] = pandoc.RawBlock("openxml", p("JURY DEMAND", { style = "Centered", keepNext = true, rpr = BOLD }))
    out[#out + 1] = pandoc.RawBlock("openxml", p("Plaintiff demands a trial by jury on all issues so triable.",
      { style = "BodyKeep" }))
  end
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta))
  return pandoc.Pandoc(out, meta)
end

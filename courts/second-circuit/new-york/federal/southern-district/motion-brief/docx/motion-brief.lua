-- S.D.N.Y. memorandum of law (motion brief), DOCX engine: the markdown contract -> Word, on reference.docx.
-- Mirrors typst/nysd-motion-brief.typ (see ../README.md, "Engines"). Built as openxml in the reference's styles:
-- the counsel block, the caption, the tables of contents and authorities (page numbers come from a first
-- pass, see render.sh and pages.awk), the signature block and the certificate of compliance. Built as text:
-- heading labels (I., A., 1., a.), bullets, and the "toa:" links (plain text; the page is in the table).
-- Four sections: cover (no number), tables (roman), body (arabic from 1), certificate (no number).
-- Pass 1 (env NYSD_MB_DATA set): page numbers are placeholders and the search keys are written to that file.
-- Pass 2 (env NYSD_MB_PAGES set): page numbers are read from that file.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end
local function plain(v)
  if v == nil then return "" end
  return (pandoc.utils.stringify(v):gsub("\194\160", " "))
end
local function raw(xml) return pandoc.RawBlock("openxml", xml) end
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function run(text, o)
  o = o or {}
  local rpr = ""
  if o.b then rpr = rpr .. "<w:b/>" end
  if o.i then rpr = rpr .. "<w:i/>" end
  return '<w:r>' .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "") .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- paragraph properties, in schema order: pStyle, keepNext, pageBreakBefore, tabs, spacing, ind, jc, sectPr
local function ppr(o)
  local x = ""
  if o.style then x = x .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keepNext then x = x .. '<w:keepNext/>' end
  if o.pbb then x = x .. '<w:pageBreakBefore/>' end
  if o.tabs then x = x .. '<w:tabs>' .. o.tabs .. '</w:tabs>' end
  x = x .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '" w:line="' .. (o.line or 276) .. '" w:lineRule="' .. (o.rule or "auto") .. '"/>'
  if o.ind then x = x .. '<w:ind ' .. o.ind .. '/>' else x = x .. '<w:ind w:firstLine="0"/>' end
  if o.jc then x = x .. '<w:jc w:val="' .. o.jc .. '"/>' end
  if o.sect then x = x .. o.sect end
  return '<w:pPr>' .. x .. '</w:pPr>'
end
local function para(o, body)
  return '<w:p>' .. ppr(o) .. (body or "") .. '</w:p>'
end
local function blank(o)
  return para(o or {}, "")
end

local BORDER = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local NOBORDER = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/></w:tcBorders>'
local function cell(width, borders, margins, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. borders .. margins .. '</w:tcPr>' .. inner .. '</w:tc>'
end
local function table_xml(widths, rows)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'; total = total + w end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. rows .. '</w:tbl>'
end

-- a section break: the paragraph that ends a section carries its sectPr
local function sect_break(footer_id, pgnum)
  local s = '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer_id .. '"/>' .. (pgnum or "")
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
  return raw(para({ sect = s }, ""))
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do while n >= v[1] do s = s .. v[2]; n = n - v[1] end end
  return s
end

local TOA_GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "regulation", "Regulations" }, { "other", "Other Authorities" } }
local PASSIM = 7

-- pass 2 input: "H<TAB>idx<TAB>page" for each TOC heading, "A<TAB>key<TAB>p1,p2,..." for each authority
local function read_pages(path)
  local hs, as = {}, {}
  local f = assert(io.open(path, "r"))
  for line in f:lines() do
    local kind, a, b = line:match("^(%u)\t([^\t]*)\t(.*)$")
    if kind == "H" then hs[tonumber(a)] = b
    elseif kind == "A" then as[a] = b end
  end
  f:close()
  return hs, as
end

function Pandoc(doc)
  local meta = doc.meta
  local DATA_OUT = os.getenv("NYSD_MB_DATA")
  local PAGES_IN = os.getenv("NYSD_MB_PAGES")
  local hpage, apages = {}, {}
  if PAGES_IN and PAGES_IN ~= "" then hpage, apages = read_pages(PAGES_IN) end

  -- authority hits, in document order (notes included)
  local hits = {}
  doc:walk({
    Link = function(l)
      if l.target:sub(1, 4) == "toa:" then hits[#hits + 1] = { key = l.target:sub(5), text = plain(l.content) } end
    end,
  })
  local authorities, ak = {}, {}
  if meta.authorities then
    for k, v in pairs(meta.authorities) do
      authorities[k] = { kind = plain(v.kind), name = v.name and plain(v.name) or nil, cite = plain(v.cite) }
      ak[#ak + 1] = k
    end
  end
  for _, h in ipairs(hits) do
    if not authorities[h.key] then
      error("nysd-motion-brief: link `toa:" .. h.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end

  -- headings and their labels (typst numbering: level 2 "I.", 3 "A.", 4 "1.", 5 "a.")
  local cnt = { 0, 0, 0, 0, 0, 0 }
  local heads = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      cnt[b.level] = cnt[b.level] + 1
      for k = b.level + 1, 5 do cnt[k] = 0 end
      local label = ""
      if b.level == 2 then label = roman(cnt[2]) .. "."
      elseif b.level == 3 then label = string.char(64 + cnt[3]) .. "."
      elseif b.level == 4 then label = tostring(cnt[4]) .. "."
      elseif b.level == 5 then label = string.char(96 + cnt[5]) .. "." end
      heads[#heads + 1] = { level = b.level, text = plain(b.content), label = label }
    end
  end
  local toc = {}
  for _, h in ipairs(heads) do if h.level <= 4 then toc[#toc + 1] = h end end

  if DATA_OUT then
    local f = assert(io.open(DATA_OUT, "w"))
    local first = ""
    for _, b in ipairs(doc.blocks) do if b.t == "Para" then first = plain(b); break end end
    f:write("B\t" .. first:sub(1, 40) .. "\n")
    for _, h in ipairs(toc) do
      local s = h.text
      if h.level == 1 then s = s:upper() end
      f:write("H\t" .. s .. "\n")
    end
    for _, h in ipairs(hits) do f:write("A\t" .. h.key .. "\t" .. h.text .. "\n") end
    f:close()
  end

  -- body blocks: labelled headings, bullets as paragraphs, links as plain text
  local body = {}
  local hi = 0
  local last_para = nil
  for i, b in ipairs(doc.blocks) do if b.t == "Para" then last_para = i end end
  for i, b in ipairs(doc.blocks) do
    if i == last_para then
      body[#body + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Body Keep" }))
    elseif b.t == "Header" then
      hi = hi + 1
      local content = {}
      local lab = heads[hi].label
      if lab ~= "" then content[#content + 1] = pandoc.Str(lab); content[#content + 1] = TAB end
      for _, x in ipairs(b.content) do content[#content + 1] = x end
      body[#body + 1] = pandoc.Header(b.level, content)
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for j, ib in ipairs(item) do
          if j == 1 and (ib.t == "Para" or ib.t == "Plain") then
            local content = { pandoc.Str("\226\128\162"), TAB }
            for _, x in ipairs(ib.content) do content[#content + 1] = x end
            body[#body + 1] = pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Bullet" }))
          else
            body[#body + 1] = ib
          end
        end
      end
    else
      body[#body + 1] = b
    end
  end
  body = pandoc.Pandoc(body):walk({
    Link = function(l)
      if l.target:sub(1, 4) == "toa:" then return l.content end
    end,
  }).blocks

  local blocks = {}
  local function push(b) blocks[#blocks + 1] = b end

  -- cover (section 1, no page number)
  for _, l in ipairs(meta.counsel) do push(raw(para({}, run(plain(l))))) end
  push(raw(blank()))
  for _, l in ipairs(meta.court) do push(raw(para({ style = "Centered" }, run(plain(l):upper(), { b = true })))) end
  push(raw(blank()))
  local sides = meta.caption
  local lx, rx = "", ""
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do lx = lx .. para({}, run(plain(n))) end
    lx = lx .. para({ ind = 'w:left="2592" w:firstLine="0"' }, run(plain(side.designation)))
    if i < #sides then lx = lx .. para({ style = "Centered", before = 240, after = 240 }, run("v.")) end
  end
  for _, l in ipairs(meta.legends or {}) do rx = rx .. para({}, run(plain(l))) end
  rx = rx .. para({ before = 240, after = 240 }, "")
  rx = rx .. para({}, run((meta["file-label"] and plain(meta["file-label"]) or "No.") .. " " .. plain(meta.case_number)))
  if meta.judge then rx = rx .. para({}, run(plain(meta.judge))) end
  rx = rx .. para({ before = 240, after = 240 }, "")
  rx = rx .. para({}, run(plain(meta.title):upper(), { b = true }))
  push(raw(table_xml({ 4680, 4680 }, '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(4680, BORDER, '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="240" w:type="dxa"/><w:right w:w="288" w:type="dxa"/></w:tcMar>', lx)
    .. cell(4680, NOBORDER, '<w:tcMar><w:top w:w="72" w:type="dxa"/><w:left w:w="288" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>', rx)
    .. '</w:tr>')))
  push(sect_break("rIdNysdFtrNone"))

  -- table of contents (section 2, roman numerals)
  push(raw(para({ style = "Centered" }, run("TABLE OF CONTENTS", { b = true }))))
  push(raw(para({ jc = "right", before = 240 }, run("Page", { b = true }))))
  for i, h in ipairs(toc) do
    local ind = (h.level >= 2) and ((h.level - 2) * 720) or 0
    local title = h.text
    if h.level == 1 then title = title:upper() end
    local lab = ""
    if h.label ~= "" then lab = run(h.label) .. '<w:r><w:tab/></w:r>' end
    local tabs = '<w:tab w:val="left" w:pos="' .. (ind + 720) .. '"/><w:tab w:val="right" w:leader="dot" w:pos="9360"/>'
    push(raw(para({ tabs = tabs, before = 120, ind = 'w:left="' .. (ind + 720) .. '" w:right="720" w:hanging="720"' },
      lab .. run(title) .. '<w:r><w:tab/></w:r>' .. run(hpage[i] or "0"))))
  end

  -- table of authorities (on a new page)
  push(raw(para({ style = "Centered", pbb = true }, run("TABLE OF AUTHORITIES", { b = true }))))
  push(raw(para({ jc = "right", before = 240 }, run("Page(s)", { b = true }))))
  local used = {}
  for _, h in ipairs(hits) do used[h.key] = true end
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for _, k in ipairs(ak) do
      if authorities[k].kind == g[1] and used[k] then members[#members + 1] = k end
    end
    table.sort(members, function(x, y)
      return (authorities[x].name or authorities[x].cite):lower() < (authorities[y].name or authorities[y].cite):lower()
    end)
    if #members > 0 then
      push(raw(para({ keepNext = true, before = 240, after = 120 }, run(g[2], { b = true }))))
      for _, k in ipairs(members) do
        local a = authorities[k]
        local x = ""
        if a.name then
          x = (g[1] == "case") and run(a.name, { i = true }) or run(a.name)
          x = x .. run(", ")
        end
        local pl = apages[k] or "0"
        local _, n = pl:gsub(",", ",")
        local pg = (n + 1 >= PASSIM) and run("passim", { i = true }) or run(pl)
        x = x .. run(a.cite) .. '<w:r><w:tab/></w:r>' .. pg
        local tabs = '<w:tab w:val="right" w:leader="dot" w:pos="9360"/>'
        push(raw(para({ tabs = tabs, before = 120, ind = 'w:left="504" w:hanging="504"' }, x)))
      end
    end
  end
  push(sect_break("rIdNysdFtrNum", '<w:pgNumType w:fmt="lowerRoman" w:start="1"/>'))

  -- body (section 3, arabic from 1)
  for _, b in ipairs(body) do push(b) end
  local sig = meta.signature
  local place = meta.place and plain(meta.place) or "New York, New York"
  local rightx = ""
  for _, l in ipairs(sig.firm or {}) do rightx = rightx .. para({}, run(plain(l), { b = true })) end
  rightx = rightx .. para({ before = 240, after = 240 }, "")
  rightx = rightx .. para({}, run("s/ " .. plain(sig.signer)))
  rightx = rightx .. para({}, run(plain(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do rightx = rightx .. para({}, run(plain(l))) end
  push(raw(blank({ before = 480, keepNext = true })))
  push(raw(table_xml({ 4752, 4608 }, '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(4752, NOBORDER, '<w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>',
      para({ keepNext = true }, run("Dated: " .. place)) .. para({ keepNext = true }, run(plain(meta.date))))
    .. cell(4608, NOBORDER, '<w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>', rightx)
    .. '</w:tr>')))
  push(sect_break("rIdNysdFtrNum", '<w:pgNumType w:fmt="decimal" w:start="1"/>'))

  -- certificate of compliance (section 4, no page number: the reference's final section)
  push(raw(para({ style = "Centered", after = 240 }, run("CERTIFICATE OF COMPLIANCE", { b = true }))))
  local count = plain(meta.word_count)
  push(raw(para({ style = "BodyText", line = 480, rule = "exact", ind = 'w:firstLine="720"' }, run("1. This memorandum complies with the word-count limit of Local Civil Rule 7.1(c) because it contains " .. count .. " words, excluding the caption, table of contents, table of authorities, signature block and this certificate, as counted by the word-processing program used to prepare it."))))
  push(raw(para({ style = "BodyText", line = 480, rule = "exact", ind = 'w:firstLine="720"' }, run("2. This memorandum complies with the formatting requirements of Local Civil Rule 7.1(b) because it is printed in EB Garamond, 12-point type, with one-inch margins on all sides, and is double-spaced except for headings, footnotes and block quotations."))))
  push(raw(blank({ before = 480 })))
  push(raw(table_xml({ 4752, 4608 }, '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(4752, NOBORDER, '<w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>',
      para({}, run("Dated: " .. place)) .. para({}, run(plain(meta.date))))
    .. cell(4608, NOBORDER, '<w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>',
      para({}, run("Respectfully submitted,")) .. para({ before = 480 }, run("s/ " .. plain(sig.signer))))
    .. '</w:tr>')))

  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

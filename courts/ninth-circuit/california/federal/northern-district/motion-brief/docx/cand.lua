-- N.D. Cal. motion or brief, docx engine. pandoc writes only the body; this filter adds what the typst template
-- builds from the frontmatter: counsel block with the role line, court title, caption, case number, title of the
-- paper, and the signature block. Court text is the court's own; every case value comes from the frontmatter.
-- Paragraph styles come from docx/reference.docx (Single Spaced, Single Centered Bold, Caption Designation,
-- Signature Block). Not built, and recorded as BLOCKED in README (Engines): the hearing date and time on the
-- cover, the table of contents and table of authorities (fields, not text), the paper title and case number in
-- the footer, and the caption rules (typst draws a box).

local function str(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

-- a MetaList of strings (or one string) as a Lua array of strings
local function strs(x)
  local out = {}
  if x == nil then return out end
  if pandoc.utils.type(x) == "List" then
    for _, v in ipairs(x) do out[#out + 1] = str(v) end
  else
    out[#out + 1] = str(x)
  end
  return out
end

local function line(text, style)
  return pandoc.Div({ pandoc.Para({ pandoc.Str(text) }) },
    pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function blank()
  return line("", "Single Spaced")
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- counsel block, role line (italic), then the court title
  for _, l in ipairs(strs(meta.counsel)) do add(line(l, "Single Spaced")) end
  if meta.counsel_role then
    add(pandoc.Div({ pandoc.Para({ pandoc.Emph({ pandoc.Str(str(meta.counsel_role)) }) }) },
      pandoc.Attr("", {}, { ["custom-style"] = "Single Spaced" })))
  end
  add(blank())
  for _, l in ipairs(strs(meta.court)) do add(line(l, "Single Centered Bold")) end
  add(blank())

  -- caption: each party's names, then its designation; "v." between parties
  local parties = meta.caption
  if parties and parties.parties then parties = parties.parties end
  local n = 0
  if parties then
    for _, p in ipairs(parties) do
      if n > 0 then add(line("v.", "Single Centered Bold")) add(blank()) end
      n = n + 1
      for _, nm in ipairs(strs(p.names)) do add(line(nm, "Single Spaced")) end
      add(line(str(p.designation), "Caption Designation"))
      add(blank())
    end
  end
  if meta.case_number then add(line("Case No. " .. str(meta.case_number), "Single Spaced")) end
  add(blank())
  if meta.brief_title then add(line(str(meta.brief_title), "Single Centered Bold")) end
  add(blank())

  -- body, as written (unnumbered: the typst template numbers only headings)
  for _, b in ipairs(doc.blocks) do add(b) end

  -- signature block: date on the left, then the signing block on the right
  add(blank())
  if meta.date then add(line("Dated: " .. str(meta.date), "Single Spaced")) end
  add(blank())
  add(line("Respectfully submitted,", "Signature Block"))
  add(blank())
  local sig = meta.signature
  if sig then
    for _, l in ipairs(strs(sig.preamble)) do add(line(l, "Signature Block")) end
    if sig.preamble then add(blank()) end
    if sig.signer then
      add(line("By: /s/ " .. str(sig.signer), "Signature Block"))
      add(line(str(sig.signer), "Signature Block"))
    end
    for _, l in ipairs(strs(sig.lines)) do add(line(l, "Signature Block")) end
  end

  meta.date = nil -- the date is written above, not as a pandoc title-block Date
  return pandoc.Pandoc(out, meta)
end

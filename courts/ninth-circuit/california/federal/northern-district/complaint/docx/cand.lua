-- N.D. Cal. complaint, docx engine. pandoc writes only the body; this filter adds what the typst template
-- builds from the frontmatter: counsel block, court title, caption, case number, title of the paper, jury
-- demand legend, numbered allegations (Fed. R. Civ. P. 10(b): every body paragraph, as in the typst template),
-- lettered prayer items, and the signature block. Court text is the court's own; every case value comes from
-- the markdown frontmatter. Paragraph styles come from docx/reference.docx (Single Spaced, Single Centered Bold,
-- Caption Designation, Signature Block). Not built: the caption rules (typst draws a box), the paper title and case number in the
-- footer (see README, Engines). Cover and signature lines carry no line numbers (suppressLineNumbers in the styles).

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

  -- counsel block (single spaced), then the court title (Civil L.R. 3-4(a)(1), (a)(3))
  for _, l in ipairs(strs(meta.counsel)) do add(line(l, "Single Spaced")) end
  add(blank())
  add(line("UNITED STATES DISTRICT COURT", "Single Centered Bold"))
  add(line("NORTHERN DISTRICT OF CALIFORNIA", "Single Centered Bold"))
  if meta.division then add(line(string.upper(str(meta.division)), "Single Centered Bold")) end
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
  if meta.legend then add(line(string.upper(str(meta.legend)), "Single Centered Bold")) end
  if meta.jury_demand then add(line("DEMAND FOR JURY TRIAL", "Single Centered Bold")) end
  add(blank())

  -- unnumbered lead-in, then the body: body paragraphs are numbered 1, 2, ... (Fed. R. Civ. P. 10(b))
  if meta.lead_in then add(pandoc.Para(pandoc.utils.type(meta.lead_in) == "Inlines" and meta.lead_in or { pandoc.Str(str(meta.lead_in)) })) end
  local k = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      k = k + 1
      local inl = pandoc.Inlines({ pandoc.Str(k .. "."), pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>") })
      for _, x in ipairs(b.content) do inl:insert(x) end
      add(pandoc.Para(inl))
    elseif b.t == "OrderedList" then
      -- prayer items are lettered (a), (b), ... as in the typst template
      b.listAttributes.style = "LowerAlpha"
      b.listAttributes.delimiter = "TwoParens"
      add(b)
    else
      add(b)
    end
  end

  -- signature block (single spaced, right half), then the date on the left
  add(blank())
  if meta.date then add(line("Dated: " .. str(meta.date), "Single Spaced")) end
  add(blank())
  local sig = meta.signature
  if sig then
    for _, l in ipairs(strs(sig.firm)) do add(line(l, "Signature Block")) end
    add(blank())
    if sig.signer then
      add(line("By: /s/ " .. str(sig.signer), "Signature Block"))
      add(line(str(sig.signer), "Signature Block"))
    end
    for _, l in ipairs(strs(sig.lines)) do add(line(l, "Signature Block")) end
  end

  meta.date = nil -- the date is written above, not as a pandoc title-block Date
  return pandoc.Pandoc(out, meta)
end

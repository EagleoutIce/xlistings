-- l3build configuration for xlistings; code-link is a separate package with
-- its own configuration in code-link/build.lua
module = "xlistings"
dofile("build-upload.lua")

-- sources and documentation
sourcefiles  = {"xlistings.sty", "langs/xlistings-*.cfg"}
installfiles = {"xlistings.sty", "xlistings-*.cfg"} -- globbed in the unpack dir, hence flat
tdsroot      = "latex"
packtdszip   = false
docfiles     = {"xlistings-doc.tex", "xlistings.ist"}
typesetfiles = {"xlistings-doc.tex"}
typesetopts  = "-shell-escape -interaction=nonstopmode"
-- xlistings.sty does not load code-link, only the manual uses it
typesetdeps  = {"code-link"}
indexstyle   = "xlistings.ist"
textfiles    = {"README.md", "LICENSE"}

-- version bookkeeping: 'l3build tag <version>' rewrites the package
-- identification; the documentation reads version and date from the package
tagfiles = {"xlistings.sty"}

function update_tag(file, content, tagname, tagdate)
  if string.match(file, "%.sty$") then
    return string.gsub(content,
      "\\ProvidesPackage{xlistings}%[%d%d%d%d/%d%d/%d%d v%S+",
      "\\ProvidesPackage{xlistings}[" .. string.gsub(tagdate, "%-", "/")
        .. " v" .. tagname, 1)
  end
  return content
end

-- \LoadLanguages looks into the current directory first, so it finds the flat
-- copy of the language files; every check writes build/test/<name>.pdf as well
testfiledir = "tests"
checkengines = {"pdftex", "xetex", "luatex"}
stdengine    = "pdftex"
checkformat  = "latex"

checkconfigs = {"tests/config-xlistings"}

-- A leaked color is invisible to the style traces of the .lvt files, so the pdf
-- checks keep the color every piece of text is drawn in and nothing else.
local function xlst_pdf_colors(content)
  local result = ""
  local color = "?"
  local stream = false
  for line in string.gmatch(content, "([^\n]*)\n") do
    if stream then
      if string.match(line, "endstream") then
        stream = false
      else
        -- pdfTeX writes one operator per line, xdvipdfmx puts a whole line
        -- of operators on one line, so walk the tokens
        local operands = {}
        for token in string.gmatch(line, "%S+") do
          if string.match(token, "^[%d%.]+$") then
            operands[#operands + 1] = token
          else
            if string.match(token, "^[rg]*[gk]$") then
              color = table.concat(operands, " ") .. " " .. token
            elseif string.match(token, "T[Jj]$") then
              result = result .. color .. " [TEXT]\n"
            end
            operands = {}
          end
        end
      end
    elseif string.match(line, "^stream$") then
      stream = true
    end
  end
  return result
end

function rewrite_pdf(source, result, engine, errlevels)
  local input = assert(io.open(source, "rb"))
  local content = input:read("a") .. "\n"
  input:close()
  local output = assert(io.open(result, "w"))
  output:write(xlst_pdf_colors(content))
  output:close()
end

-- metadata for 'l3build upload'; ctanPath only applies to the first upload,
-- afterwards CTAN keeps the package where it put it
uploadconfig = {
  pkg               = "xlistings",
  -- 'l3build upload <version>' overrides this
  version           = package_version("xlistings.sty",
                        "\\ProvidesPackage{xlistings}%[%d%d%d%d/%d%d/%d%d v(%S+)"),
  author            = "Florian Sihler",
  uploader          = "Florian Sihler",
  email             = "florian.sihler@uni-ulm.de",
  license           = "lppl1.3c",
  summary           = "Opinionated extensions to the listings package",
  ctanPath          = "/macros/latex/contrib/xlistings",
  repository        = "https://github.com/EagleoutIce/xlistings",
  bugtracker        = "https://github.com/EagleoutIce/xlistings/issues",
  support           = "https://github.com/EagleoutIce/xlistings/issues",
  home              = "https://github.com/EagleoutIce/xlistings",
  topic             = {"listing"},
  update            = true,
  announcement_file = "ctan-announce.txt",
  note_file         = "ctan-note.txt",
  description       = [[
The xlistings package extends listings with an easier front-end for code
blocks: language-sensitive highlighting of numbers (including hexadecimal
literals, exponents and type suffixes), a drop-in minted environment,
per-language wrapper macros and environments, non-selectable line numbers
based on accsupp, language badges, and opinionated definitions for a set of
common languages that are loaded on demand.

The separate package code-link links the code in xlistings blocks to where it
is defined or documented.]],
}

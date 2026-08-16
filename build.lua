-- l3build configuration for xlistings
module = "xlistings"

-- sources and documentation
sourcefiles  = {"xlistings.sty", "langs/*.cfg"}
installfiles = {"xlistings.sty", "*.cfg"} -- globbed in the unpack dir, hence flat
tdsroot      = "latex"
docfiles     = {"xlistings-doc.tex"}
typesetfiles = {"xlistings-doc.tex"}
textfiles    = {"README.md", "LICENSE"}

-- \LoadLanguages looks into the current directory first, so it finds the flat
-- copy of the language files; every check writes build/test/<name>.pdf as well
testfiledir = "tests"
checkengines = {"pdftex"}
stdengine    = "pdftex"
checkformat  = "latex"

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
      elseif string.match(line, "^[%d%.]+ [%d%. ]*[a-zA-Z]*[gk] ") then
        color = string.match(line, "^([%d%. ]*[a-zA-Z]*[gk]) ")
      elseif string.match(line, "T[Jj]") then
        result = result .. color .. " [TEXT]\n"
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

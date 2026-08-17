-- l3build configuration for xlistings
module = "xlistings"

-- sources and documentation
sourcefiles  = {"xlistings.sty", "langs/xlistings-*.cfg"}
installfiles = {"xlistings.sty", "xlistings-*.cfg"} -- globbed in the unpack dir, hence flat
tdsroot      = "latex"
packtdszip   = true -- ship a ready-made TDS tree alongside the flat archive
docfiles     = {"xlistings-doc.tex"}
typesetfiles = {"xlistings-doc.tex"}
textfiles    = {"README.md", "LICENSE"}

-- version bookkeeping: 'l3build tag <version>' rewrites the package
-- identification and the title of the documentation in one go
tagfiles = {"xlistings.sty", "xlistings-doc.tex"}

function update_tag(file, content, tagname, tagdate)
  if string.match(file, "%.sty$") then
    return string.gsub(content,
      "\\ProvidesPackage{xlistings}%[%d%d%d%d/%d%d/%d%d v%S+",
      "\\ProvidesPackage{xlistings}[" .. string.gsub(tagdate, "%-", "/")
        .. " v" .. tagname, 1)
  elseif string.match(file, "%-doc%.tex$") then
    return string.gsub(content, "\\title{\\T{xlistings} v%S-}",
      "\\title{\\T{xlistings} v" .. tagname .. "}", 1)
  end
  return content
end

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

-- l3build's own '--dry-run' is not offline: it only skips the second POST, the
-- archive is still sent to CTAN's validate endpoint (and '--debug' posts it to
-- httpbin.org). The 'curl_debug' switch that would suppress this is a local
-- captured before build.lua is read, so it cannot be set from here. Instead we
-- wrap 'upload': under '--dry-run' we build the very same curl request, which
-- runs all of l3build's field validation and writes the .curlopt file, and
-- print it rather than send it. A plain 'l3build upload' is left untouched.
-- Note that redefining the global 'upload' is not enough: 'l3build-stdmain'
-- captures the function into 'target_list' before build.lua is read, so the
-- entry in that table has to be replaced as well.
local l3build_upload = target_list.upload.func
function upload(tagnames)
  if not options["dry-run"] then
    return l3build_upload(tagnames)
  end
  local uploadfile = ctanzip .. ".zip"
  if not fileexists(uploadfile) then
    error("Missing zip file '" .. uploadfile .. "'. \z
      Maybe you forgot to run 'l3build ctan' first?")
  end
  -- the same fields 'upload()' fills in before it validates
  uploadconfig.announcement = options["message"] or uploadconfig.announcement
    or file_contents(uploadconfig.announcement_file)
  uploadconfig.note = uploadconfig.note or file_contents(uploadconfig.note_file)
  uploadconfig.email = options["email"] or uploadconfig.email
  uploadconfig.version = (tagnames or {})[1] or uploadconfig.version
  print("Dry run: validating locally, nothing is sent to CTAN.")
  local request = construct_ctan_post(uploadfile)
  print("Would have posted:")
  print(request .. "https://ctan.org/submit/validate")
  print("Dry run finished, no request was sent.")
  return 0
end
target_list.upload.func = upload

-- metadata for 'l3build upload'; ctanPath only applies to the first upload,
-- afterwards CTAN keeps the package where it put it
uploadconfig = {
  pkg               = "xlistings",
  version           = "1.0.0", -- 'l3build upload 1.0.0' overrides this
  author            = "Florian Sihler",
  uploader          = "Florian Sihler",
  email             = "vogeldeseises@gmail.com",
  license           = "lppl1.3c",
  summary           = "Opinionated extensions to the listings package",
  ctanPath          = "/macros/latex/contrib/xlistings",
  repository        = "https://github.com/EagleoutIce/xlistings",
  bugtracker        = "https://github.com/EagleoutIce/xlistings/issues",
  support           = "https://github.com/EagleoutIce/xlistings/issues",
  home              = "https://github.com/EagleoutIce/xlistings",
  topic             = {"listing"},
  update            = false, -- first upload: a new package, not an update
  announcement_file = "ctan-announce.txt",
  description       = [[
The xlistings package extends listings with an easier front-end for code
blocks: language-sensitive highlighting of numbers (including hexadecimal
literals, exponents and type suffixes), a drop-in minted environment,
per-language wrapper macros and environments, non-selectable line numbers
based on accsupp, language badges, and opinionated definitions for a set of
common languages that are loaded on demand.]],
}

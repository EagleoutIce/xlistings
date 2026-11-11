-- l3build configuration for code-link, a separate package from xlistings. Its
-- sources stay in the repository root next to those of xlistings; this directory
-- only holds what is specific to its release.
module  = "code-link"
maindir = ".." -- shared build/, so that the dependency on xlistings is found
dofile("../build-upload.lua")

sourcefiledir = ".."
docfiledir    = ".."
sourcefiles   = {"code-link.sty"}
installfiles  = {"code-link.sty"}
tdsroot       = "latex"
packtdszip    = false
docfiles      = {"code-link-doc.tex", "code-link.ist"}
-- the manual uses minted, which needs -shell-escape and Pygments
typesetfiles  = {"code-link-doc.tex"}
typesetopts   = "-shell-escape -interaction=nonstopmode"
-- code-link.sty does not load xlistings, only the manual and one test use it
typesetdeps   = {".."}
checkdeps     = {".."}
-- the manual shows the tables of bench/run.sh
supportdir       = "../bench"
typesetsuppfiles = {"bench-summary.tex", "bench-results-*.tex"}
indexstyle    = "code-link.ist"
textfiles     = {"README.md", "LICENSE"}

-- 'l3build tag <version>' rewrites the package identification
tagfiles = {"code-link.sty"}

function update_tag(file, content, tagname, tagdate)
  return string.gsub(content,
    "\\ProvidesExplPackage{code%-link}{%d%d%d%d/%d%d/%d%d}{v%S+}",
    "\\ProvidesExplPackage{code-link}{" .. string.gsub(tagdate, "%-", "/")
      .. "}{v" .. tagname .. "}", 1)
end

testfiledir  = "../tests/code-link"
testdir      = maindir .. "/build/test-tests/config-code-link"
-- minted.lua has the tests that need -shell-escape and Pygments
checkconfigs = {"build", "minted"}
checkengines = {"pdftex", "xetex", "luatex"}
stdengine    = "pdftex"
checkformat  = "latex"
-- the first run writes the .aux file, the second one links
checkruns    = 2

-- metadata for 'l3build upload'; ctanPath only applies to the first upload,
-- afterwards CTAN keeps the package where it put it
uploadconfig = {
  pkg               = "code-link",
  -- 'l3build upload <version>' overrides this
  version           = package_version("../code-link.sty",
                        "\\ProvidesExplPackage{code%-link}{%d%d%d%d/%d%d/%d%d}{v(%S+)}"),
  author            = "Florian Sihler",
  uploader          = "Florian Sihler",
  email             = "florian.sihler@uni-ulm.de",
  license           = "lppl1.3c",
  summary           = "Link code in listings to where it is defined",
  ctanPath          = "/macros/latex/contrib/code-link",
  repository        = "https://github.com/EagleoutIce/xlistings",
  bugtracker        = "https://github.com/EagleoutIce/xlistings/issues",
  support           = "https://github.com/EagleoutIce/xlistings/issues",
  home              = "https://github.com/EagleoutIce/xlistings",
  topic             = {"listing", "hyper"},
  update            = true,
  announcement_file = "ctan-announce.txt",
  note_file         = "ctan-note.txt",
  description       = [[
The code-link package collects definitions while a document is typeset and
links every occurrence of them in listings, xlistings and minted blocks. It
works with any of these three and needs none of them in particular. It is the
companion of the separate package xlistings.]],
}

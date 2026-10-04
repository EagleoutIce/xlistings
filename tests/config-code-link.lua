-- the tests of code-link: listings, xlistings and the plain (backend-less) rules
testfiledir  = "tests/code-link"
checkengines = {"pdftex", "xetex", "luatex"}
stdengine    = "pdftex"
checkformat  = "latex"
-- the first run writes the .aux file, the second one links
checkruns    = 2

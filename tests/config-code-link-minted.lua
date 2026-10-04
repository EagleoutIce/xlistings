-- the minted tests of code-link: they need -shell-escape and Pygments
testfiledir  = "tests/code-link-minted"
checkengines = {"pdftex", "xetex", "luatex"}
stdengine    = "pdftex"
checkformat  = "latex"
checkruns    = 2
checkopts    = "-shell-escape -interaction=batchmode"

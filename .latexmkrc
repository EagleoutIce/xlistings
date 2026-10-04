@default_files = ('xlistings-doc.tex', 'code-link-doc.tex');
$pdf_mode = 1;
$pdf_update_method = 1;
$out_dir = 'build';
$postscript_mode = 0;
$dvi_mode = 0;
$makeindex = "makeindex -s ../xlistings.ist %O -o %D %S";
# the manual of code-link uses minted (Pygments), the benchmark tables are in bench/
$pdflatex = 'pdflatex -interaction=nonstopmode %O -shell-escape %S';
ensure_path('TEXINPUTS', './bench//');

#!/bin/sh
# Writes bench/bench-results-<backend>.tex and bench/bench-summary.tex: every
# case of bench/cases.txt is measured in two pdfTeX runs (the strings are only
# known after the .aux file was read), and this is repeated CL_BENCH_REPEAT
# times (default 5). The table shows the average of the repetitions.
#   CL_BENCH_RUNS      listings typeset per measurement (default 3)
#   CL_BENCH_BACKENDS  default "listings xlistings minted"
set -eu
cd "$(dirname "$0")/.."

runs=${CL_BENCH_RUNS:-3}
repeat=${CL_BENCH_REPEAT:-5}
backends=${CL_BENCH_BACKENDS:-listings xlistings minted}
pool_size=${pool_size:-60000000}
max_strings=${max_strings:-6000000}
hash_extra=${hash_extra:-6000000}
# main_memory sits in the format, only these two grow it at run time
extra_mem_top=${extra_mem_top:-40000000}
extra_mem_bot=${extra_mem_bot:-40000000}
export pool_size max_strings hash_extra extra_mem_top extra_mem_bot
export TEXINPUTS="./:"

# BusyBox date ignores %N
now() {
   t=$(date +%s%N)
   case $t in
      *[!0-9]* | ?????????? ) perl -MTime::HiRes=time -e 'printf "%.0f\n", time * 1e9' ;;
      *) echo "$t" ;;
   esac
}

: > bench/summary.tmp

for backend in $backends; do
   out=bench/bench-results-$backend.tex
   raw=bench/raw.tmp
   # Pygments splits \command into pieces, so minted has no command cases
   if [ "$backend" = minted ]; then
      grep -v '^#' bench/cases.txt | grep -v '|command$' > bench/cases.run
   else
      grep -v '^#' bench/cases.txt > bench/cases.run
   fi
   cases=$(grep -c . bench/cases.run)
   : > "$raw"
   i=0
   while [ "$i" -lt "$cases" ]; do
      i=$((i + 1))
      r=0
      while [ "$r" -lt "$repeat" ]; do
         r=$((r + 1))
         rm -f bench/measure.aux bench/bench-plain.tex
         for pass in 1 2; do
            start=$(now)
            if ! pdflatex -interaction=nonstopmode -halt-on-error -shell-escape \
               -output-directory=bench -jobname=measure \
               "\\def\\cbbackend{$backend}\\def\\cbpass{$pass}\\def\\cbruns{$runs}\\def\\cbonly{$i}\\def\\cbcases{bench/cases.run}\\input{bench/measure.tex}" \
               > bench/measure.stdout 2>&1
            then
               echo "bench: case $i ($backend, pass $pass) failed, last lines of bench/measure.log:" >&2
               tail -n 40 bench/measure.log >&2 || tail -n 40 bench/measure.stdout >&2
               exit 1
            fi
            # the wall time of the whole linked run, process start included, in tenths of a ms
            run=$(( ($(now) - start) / 100000 ))
         done
         echo "$i|$(cat bench/bench-stat.txt)|$run" >> "$raw"
      done
   done
   # label|kind|strings|tokens|plain|linked|register|assemble|run, in tenths of a ms
   awk -F'|' '
      { n[$1]++; label[$1] = $2; kind[$1] = $3; strings[$1] = $4; tokens[$1] = $5
        plain[$1] += $6; linked[$1] += $7; reg[$1] += $8; asm[$1] += $9; run[$1] += $10; if ($1 > last) last = $1 }
      function ms(x) { return sprintf("\\qty{%.1f}{\\milli\\second}", x / 10) }
      # the overhead in percent of the whole run
      function pct(x, t) { return sprintf("%s (\\qty{%.0f}{\\percent})", ms(x), t > 0 ? 100 * x / t : 0) }
      END {
         print "% written by bench/run.sh, do not edit"
         print "\\begin{tabular}{@{}lrrrrrrrrr@{}}"
         print "   \\toprule"
         print "   \\textbf{Case} & \\textbf{Strings} & \\textbf{Tokens} & \\textbf{Plain} & \\textbf{Linked} & \\textbf{Extra} & \\textbf{Register} & \\textbf{Assemble} & \\textbf{Overhead} & \\textbf{Run} \\\\"
         print "   \\midrule"
         for (i = 1; i <= last; i++) {
            p = plain[i] / n[i]; l = linked[i] / n[i]; r = reg[i] / n[i]; a = asm[i] / n[i]; t = run[i] / n[i]
            e = l - p; if (e < 0) e = 0
            printf "   %s & %s & %s & %s & %s & %s & %s & %s & %s & %s \\\\\n", label[i], strings[i], tokens[i], ms(p), ms(l), ms(e), ms(r), ms(a), pct(r + a + e, t), ms(t)
         }
         print "   \\bottomrule"
         print "\\end{tabular}"
      }' "$raw" > "$out.new"
   mv "$out.new" "$out"
   echo "wrote $out"
   # the cases with 1000 strings: what a listing costs, and what a run pays once
   awk -F'|' -v backend="$backend" '
      $4 == 1000 && $5 == 500 { c = $1 "|" $3; n[c]++; kind[c] = $3; extra[c] += $7 - $6; fixed[c] += $8 + $9; run[c] += $10 }
      END { for (c in n) printf "%s|%s|%.1f|%.1f|%.1f\n", backend, kind[c], extra[c] / n[c] / 10, fixed[c] / n[c] / 10, run[c] / n[c] / 10 }
   ' "$raw" >> bench/summary.tmp
   rm -f "$raw" bench/cases.run
done

# averages over the cases with 1000 strings, per kind of string
summary=bench/bench-summary.tex
{
   echo '% written by bench/run.sh, do not edit'
   for kind in word command; do
      awk -F'|' -v kind="$kind" '
         $2 == kind && $1 != "minted" { n++; e += $3; f += $4; r += $5 }
         END { if (n) printf "\\def\\cb%sExtra{%.0f}\n\\def\\cb%sFixed{%.0f}\n\\def\\cb%sRun{%.0f}\n\\def\\cb%sPct{%.0f}\n", kind, e / n, kind, f / n, kind, r / n, kind, (r > 0 ? 100 * (e + f) / r : 0) }
      ' bench/summary.tmp
   done
   awk -F'|' '
      $1 == "minted" { n++; e += $3; f += $4; r += $5 }
      END { if (n) printf "\\def\\cbmintedExtra{%.0f}\n\\def\\cbmintedFixed{%.0f}\n\\def\\cbmintedRun{%.0f}\n\\def\\cbmintedPct{%.0f}\n", e / n, f / n, r / n, (r > 0 ? 100 * (e + f) / r : 0) }
   ' bench/summary.tmp
} > "$summary"
echo "wrote $summary"
rm -f bench/summary.tmp bench/measure.stdout bench/bench-stat.txt bench/bench-plain.tex bench/sample.txt bench/bench-row.tex

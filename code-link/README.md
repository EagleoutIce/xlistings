# code-link

[![made-with-latex](https://img.shields.io/badge/Made%20with-LaTeX-1f425f.svg)](https://www.latex-project.org/) [![LPPL 1.3c](https://img.shields.io/badge/License-LPPL%201.3c-yellow.svg)](https://www.latex-project.org/lppl.txt) [![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

`code-link` links the code in your listings to the place where it is defined or
documented. It works with `xlistings`, with `listings`, and with `minted`, and
it needs none of them in particular. It is the companion of
[xlistings](https://ctan.org/pkg/xlistings), a separate package. Its manual is [code-link-doc](https://github.com/EagleoutIce/xlistings/blob/gh-pages/build/code-link-doc.pdf). The
benchmark of its cost is in `bench/` of the [repository](https://github.com/EagleoutIce/xlistings).

```latex
\usepackage{listings}
\usepackage{hyperref}
\usepackage[underline]{code-link}

\CodeLinkAnchor[command]{mymacro}  % target + registration
\begin{lstlisting}
\mymacro{x}                        % becomes a link from the second run on
\end{lstlisting}
```

Originally, the functionality was tightly intertwined and written by Florian Sihler for the [tikzpingus][] documentation, the extraction was assisted by [Claude](https://claude.ai/code).
`l3build check` runs the tests, the tests of the [minted][] backend need `-shell-escape` and Pygments.

[listings]: https://ctan.org/pkg/listings
[minted]: https://ctan.org/pkg/minted
[tikzpingus]: https://github.com/eagleoutice/tikzpingus

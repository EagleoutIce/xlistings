# xlistings &mdash; An extension to listings

[![made-with-latex](https://img.shields.io/badge/Made%20with-LaTeX-1f425f.svg)](https://www.latex-project.org/) [![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

This package extends on the [listings][] package, providing an easier front-end to create code blocks of selected languages, support for number highlighting, highlighting, non-selectable line numbers,[^1] and more.
While it is not compatible with the [minted][] package, it provides a similar interface for code highlighting that can be used as a partial drop-in replacement (see the [documentation](https://github.com/EagleoutIce/xlistings/blob/gh-pages/build/xlistings-doc.pdf)).

The following describes a list of improvements over the [listings][] package:

- Highlighting of numbers in code blocks: `10_234 + x1 * 0x34 - x2`, including
  hexadecimal digits, exponents, and language sensitive type suffixes
  (`0xdeadBEEF`, `1e10`, `10L` in Java, `3j` in Python, `10n` in TypeScript)
- Support for the `\begin{minted}{<lang>} . . . \end{minted}` environment
- Wrapper macros like `\bjava{int i}` and `\cjava{int i}` and environments like `\begin{plainjava}`
- `\xlstb{<lang>}{<code>}` for languages whose name cannot be part of a command
  name, e.g. `\xlstb{x86}{mov eax, 0x10}`
- Language sensitive override: `\xlstlangoverride{latex}{morekeywords=[5]{\\xlstsetstyle}}`
- Support for ([accsupp](https://ctan.org/pkg/accsupp) based) non-selectable line numbers and characters
- Support for blacklisting line numbers with `\xlstblacklistlinenumbers`
- Support for umlauts and UTF-8 encoding (with the [listingsutf8](https://ctan.org/pkg/listingsutf8) package)
- Provides `autogobble` to remove leading spaces (with the [lstautogobble](https://ctan.org/pkg/lstautogobble) package)
- Comfort key `add to literate` to add elements to the literate list
- `\LoadLanguages{<lang>}` to load a language or multiple languages on demand
- Opinionated language overwrites (see the [langs/](langs/) folder)
- Opinionated default literates such as `:ldots:`, `:lan:`, `:to:`, and `:c:`

The package is set up for [l3build](https://ctan.org/pkg/l3build): `l3build check`
runs the tests in `tests/` and fails if a highlight changes unexpectedly. Each
test states the sequence of styles it expects, and the resulting
`build/test/<name>.pdf` shows the verdict together with the typeset sample, so
the highlighting can also be inspected visually. A colour that leaks past its
segment is invisible to such a trace, so `tests/colorbleed.pvt` additionally
compares the pdf, reduced to the colour every piece of text is drawn in.

[^1]: If a number is truly non-selectable depends on the viewer used. To ensure that they can not be selected would require images, which we currently do not create/use.

[listings]: https://ctan.org/pkg/listings
[minted]: https://ctan.org/pkg/minted
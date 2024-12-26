# xlistings &mdash; An extension to listings

This package extends on the [listings][] package, providing an easier front-end to create code blocks of selected languages, support for number highlighting, highlighting, non-selectable line numbers,[^1] and more.
While it is not compatible with the [minted][] package, it provides a similar interface for code highlighting that can be used as a partial drop-in replacement.

The following describes a list of improvements over the [listings][] package:

- Highlighting of numbers in code blocks: 10_234 + x1 * 0x34 - x2
- Support for the `\begin{minted}{<lang>} . . . \end{minted}` environment
- Wrapper macros like `\bjava{int i}` and `\cjava{int i}` and environments like `\begin{plainjava}`
- Language sensitive override: `\xlstlangoverride{latex}{morekeywords=[5]{\xlstsetstyle}}`
- Support for ([accsupp](https://ctan.org/pkg/accsupp) based) non-selectable line numbers and characters
- Support for blacklisting line numbers with `\xlstblacklistlinenumbers`
- Support for umlauts and UTF-8 encoding (with the [listingsutf8](https://ctan.org/pkg/listingsutf8) package)
- Provides `autogobble` to remove leading spaces (with the [lstautogobble](https://ctan.org/pkg/lstautogobble) package)
- Comfort key add to literate to add elements to the literate list
- `\LoadLanguages{<lang>}` to load a language or multiple languages on demand
- Opinionated language overwrites (see the [langs/](langs/) folder)
- Opinionated default literates such as `:ldots:`, `:lan:`, `:to:`, and `:c:`

[^1]: If a number is truly non-selectable depends on the viewer used. To ensure that they can not be selected would require images, which we currently do not create/use.

[listings]: https://ctan.org/pkg/listings
[minted]: https://ctan.org/pkg/minted
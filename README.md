# xlistings &mdash; An extension to listings

**Work in Progress**

This package extends on the [listings](https://ctan.org/pkg/listings) package, providing an easier front-end to create code blocks of selected languages, support for number highlighting, highlighting, non-selectable line numbers,[^1] and more.
While it is not compatible with the [minted](https://ctan.org/pkg/minted) package, it provides a similar interface for code highlighting that can be used as a partial drop-in replacement.

[^1]: If a number is truly non-selectable depends on the viewer used. To ensure that they can not be selected would require images, which we currently do not create/use.

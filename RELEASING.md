# Releasing xlistings and code-link

This repository contains two separate CTAN packages, each with its own version and release. The sources of both are in the root, the release configuration of `code-link` is in `code-link/`.

Neither package loads the other, only the manuals and the tests of `code-link` with `xlistings` use both. `l3build` in the repository root works on `xlistings`, in `code-link/` on `code-link`, and `sh both.sh` runs the same command for both:

```sh
l3build tag 1.2.0         # in the root for xlistings, in code-link/ for code-link
sh both.sh check          # test both
sh both.sh ctan           # one archive per package
sh both.sh upload --dry-run  # validate locally, nothing is sent
sh both.sh upload         # each package with the version it declares
```

Update `ctan-announce.txt` and `ctan-note.txt` (the note to the CTAN team) of a package before uploading it. Name git tags `xlistings-v1.2.0` and `code-link-v1.2.0`. The first upload of `code-link` needs `update = false` in `code-link/build.lua`, set it to `true` once CTAN has accepted the package.

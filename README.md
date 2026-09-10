# Mathapedia LaTeX + PSTricks Docker Image

```
docker pull ghcr.io/mathapedia/latex:latest
```

A batteries-included TeX Live image for papers that use **PSTricks** (which
needs the `latex -> dvips -> ps2pdf` route) as well as TikZ/pgfplots, BibTeX/
Biber, IEEEtran, and the tooling the
[Mathapedia boilerplates](https://github.com/Mathapedia/boilerplates) rely on.

Previously published as `pyramation/pstricks-latex` on Docker Hub; that name
still works but new tags land on GHCR.

## What's inside

| | |
|---|---|
| Base | Ubuntu 22.04, TeX Live 2021 (Debian packages) |
| Engines | `latex`, `pdflatex`, `xelatex`, `dvips`, `dvisvgm`, Ghostscript (`ps2pdf`) |
| Packages | `texlive-pstricks`, `-pictures` (TikZ/pgfplots), `-latex-extra`, `-science`, `-publishers` (IEEEtran), `-bibtex-extra`, `-formats-extra`, `-lang-all` |
| Build tooling | `latexmk`, `bibtex`, `biber`, `chktex`, `latexindent`, `latexdiff`, `rtf2latex2e` |
| Extras | Node.js, `make`, `git`, `python3` |

## Using it

Mount your `tex/` directory at `/usr/src` (the working directory):

```bash
# PSTricks documents: latex -> dvips -> ps2pdf, with bibtex reruns handled by latexmk
docker run --rm -v "$PWD/tex:/usr/src" ghcr.io/mathapedia/latex \
  latexmk -pdfps -interaction=nonstopmode -halt-on-error paper.tex

# Plain documents (no PSTricks)
docker run --rm -v "$PWD/tex:/usr/src" ghcr.io/mathapedia/latex \
  latexmk -pdf -interaction=nonstopmode -halt-on-error paper.tex

# Interactive shell
docker run --rm -it -v "$PWD/tex:/usr/src" ghcr.io/mathapedia/latex bash
```

For a complete authoring project (Makefile with `build`/`watch`/`preview`/
`lint`/`svg`, CI, VS Code config) scaffold one with pgpm:

```bash
pgpm init workspace --repo Mathapedia/boilerplates
```

## Repo Makefile

| Target | What it does |
|---|---|
| `make build` | Build the image locally as `ghcr.io/mathapedia/latex:latest` |
| `make check` | Smoke-test that every tool/package the boilerplate needs is present |
| `make pstricks` | Compile `tex/test.tex` via the PSTricks route |
| `make ssh` | Interactive shell with `tex/` mounted |
| `make buildx` | Multi-arch (amd64 + arm64) build and push |
| `make push-legacy` | Also push under the old `pyramation/pstricks-latex` name |

Override the image used by the run targets with `RUN_IMAGE=...`.

## Publishing

`.github/workflows/build-docker.yml` builds the image on every push and PR,
runs `make check` and compiles the test document, then (not on PRs) pushes
multi-arch images to GHCR:

- `main` -> `ghcr.io/mathapedia/latex:latest` and `:sha-<short>`
- tag `vX.Y.Z` -> `:X.Y.Z` and `:X.Y`

## PSTricks notes

PSTricks emits raw PostScript, so `pdflatex` cannot render it. Use the DVI
route (`latexmk -pdfps`, or `latex && dvips && ps2pdf`). If you see
"unknown token" or PostScript errors:

- make sure you're going through `dvips`, not `pdflatex`;
- pass `-dALLOWPSTRANSPARENCY` to `ps2pdf` when mixing TikZ opacity with PSTricks;
- load `geometry`/`hyperref` with the `dvips` option.

## Notes

- **From Word (`.doc`/`.docx`)**: export RTF from Google Docs, then
  `rtf2latex2e file.rtf`.
- **Diffs**: `latexdiff old.tex new.tex > diff.tex` and compile as usual.

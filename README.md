# Idris 2 Community Tutorial

This project is an mdbook based off of Stefan Höck's [idris2-tutorial](https://github.com/stefan-hoeck/idris2-tutorial). At present, it's largely just a direct port, but will evolve as the community maintains it.

This book is rendered automatically from the `main` branch with GitHub pages, which can be viewed at <https://idris-community.github.io/idris2-tutorial/>. The [summary page](src/SUMMARY.md) can also be used as a table of contents for direct viewing in GitHub, though the rendered version is much preferable.

## Dependencies and Building

Building this mdbook is slightly complicated, as highlight.js has no support for idris, we are using [katla](https://github.com/idris-community/katla) to perform the highlighting, and injecting that highlighting into the Markdown before mdbook has a chance to see it using the [build-book](scripts/build-book) Raku script.

### Idris Dependencies

This project requires [pack](https://github.com/stefan-hoeck/idris2-pack) and [katla](https://github.com/idris-community/katla) to build.

After either installing pack from your distro's package manager or following the [quick installation](https://github.com/stefan-hoeck/idris2-pack?tab=readme-ov-file#quick-installation) directions in pack's readme, you can install katla with:

```sh
pack install-app katla
```

### Raku Dependencies

This project requires [Raku](https://rakudo.org/) and the `File::Temp`, `Shell::Command`, and `paths` modules to build.

I recommend installing raku and [zef](https://github.com/ugexe/zef) through your distro's package manger. If your package manger has lacks either zef or raku, installation through [rakubrew](https://rakubrew.org/) is an option, and if your package manager has raku but lacks zef, zef can be quite easily [installed from source](https://github.com/ugexe/zef?tab=readme-ov-file#installation).

Once you have zef up and running, the dependencies for this project can be installed with:

```sh
zef install File::Temp Shell::Command paths
```

### mdbook

Many distros have mdbook in their package manager, this is the recommended way to install it. If your distro lacks mdbook, or if the version it packages proves to be too old to build this project, after setting up a Rust toolchain with [rustup](https://rustup.rs/), you can install mdbook from source with:

``` sh
cargo install mdbook
```

### Building

Once you have all the dependencies in place, simply run:

> [!IMPORTANT]
> The `build-book` script assumes that the Idris code in the project has already been built, and will not function properly if the Idris build directory is not populated, as the build files are required by katla to provide syntax highlighting.
>
>Run `pack build` after a clean checkout or making any changes to Idris files to ensure that the build directory is up to date before running the `build-book` script.

``` sh
./scripts/build-book
```

from this project's root directory, and the rendered book will be available in the `book` directory. I recommend using a simple static file server such as `python -m http.server`to view the rendered book in your browser, simply opening the files directly in your browser is unlikely to work.

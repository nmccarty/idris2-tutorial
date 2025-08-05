# Where to get Help

There are several resources available online and in print, where you can find
help and documentation about the Idris programming language. Here is a
non-comprehensive list of them:

* [Type-Driven Development with Idris](https://www.manning.com/books/type-driven-development-with-idris)

  *The* Idris book! This describes in great detail the core concepts for using
  Idris and dependent types to write robust and concise code. It uses Idris 1 in
  its examples, so parts of it have to be slightly adjusted when using Idris 2.
  There is also a [list of required
  updates](https://idris2.readthedocs.io/en/latest/typedd/typedd.html).

* [A Crash Course in Idris 2](https://idris2.readthedocs.io/en/latest/tutorial/index.html)

  The official Idris 2 tutorial. A comprehensive but dense explanation of all
  features of Idris 2. I find this to be useful as a reference, and as such it
  is highly accessible. However, it is not an introduction to functional
  programming or type-driven development in general.

* [The Idris 2 GitHub Repository](https://github.com/idris-lang/Idris2)

  Look here for detailed installation instructions and some introductory
  material. There is also a [wiki](https://github.com/idris-lang/Idris2/wiki),
  where you can find a [list of editor
  plugins](https://github.com/idris-lang/Idris2/wiki/The-Idris-editor-experience),
  a [list of community
  libraries](https://github.com/idris-lang/Idris2/wiki/Libraries), a [list of
  external
  backends](https://github.com/idris-lang/Idris2/wiki/External-backends), and
  other useful information.

* [The Idris 2 Discord Channel](https://discord.gg/UX68fDs2jc)

  If you get stuck with a piece of code, want to ask about some obscure language
  feature, want to promote your new library, or want to just hang out with other
  Idris programmers, this is the place to go. The discord channel is pretty
  active and *very* friendly towards newcomers.

* The Idris REPL

  Finally, a lot of useful information can be provided by Idris itself. I tend
  to have at least one REPL session open all the time when programming in Idris.
  My editor (neovim) is set up to use the [language server for Idris
  2](https://github.com/idris-community/idris2-lsp), which is incredibly useful.
  In the REPL,

  * use `:t` to inspect the type of an expression or meta variable (hole): `:t
    foldl`,
  * use `:ti` to inspect the type of a function including implicit arguments:
    `:ti foldl`,
  * use `:m` to list all meta variables (holes) in scope,
  * use `:doc` to access the documentation of a top level function (`:doc the`),
    a data type plus all its constructors and available hints (`:doc Bool`), a
    language feature (`:doc case`, `:doc let`, `:doc interface`, `:doc record`,
    or even `:doc ?`), or an interface (`:doc Uninhabited`),
  * use `:module` to import a module from one of the available packages:
    `:module Data.Vect`,
  * use `:browse` to list the names and types of all functions exported by a
    loaded module: `:browse Data.Vect`,
  * use `:help` to get a list of other commands plus a short description for
    each.

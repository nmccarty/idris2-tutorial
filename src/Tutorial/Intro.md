# Introduction

Many of the Markdown files [making up this book](https://github.com/idris-community/idris2-tutorial) (those with a `.md` file extension) are _literate_ Idris files, consisting of a mixture of Markdown and Idris code, and can be type checked and built just like regular code by the Idris compiler. You can identify a document as a literate Idris document if it contains a `module` declaration, like so:

```idris
module Tutorial.Intro
```

Even though this file (`src/Tutorial/Intro.md`) has no actual code in it, by including that `module` declaration, it qualifies as a literate Idris file. A module name consists of a list of identifiers separated by dots and must reflect the folder structure plus the module file's name, starting from the source directory. For instance, as this file's path, from the root of the `src` directory is `Tutorial/Intro.md`, it's module name _must_ be `Tutorial.Intro`.

Before starting this book, make sure you have the Idris compiler installed on your computer. While it is technically possible to work through this book without it, we recommend that you have the _pack_ package manager installed and have a skeleton package setup as described in the [Getting Started with pack and Idris2](../Appendices/Install.md) appendix, as such a setup is assumed.

Later in the book, you will encounter various exercises. The solutions to these exercises can be found as regular Idris files in the `src/Solutions` directory of the [git repository](https://github.com/idris-community/idris2-tutorial/tree/main/src/Solutions), or in syntax highlight form in the "Exercise Solutions" section at the bottom of the navigation sidebar.

<!-- vi: filetype=idris2:syntax=markdown
-->

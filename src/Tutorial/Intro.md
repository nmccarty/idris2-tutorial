# Introduction

Welcome to my Idris 2 tutorial. I'll try and treat as many aspects of the Idris
2 programming language as possible here.  All `.md` files in here are literate
Idris files: They consist of Markdown (hence the `.md` ending), which is being
pretty printed by GitHub together with Idris code blocks, which can be type
checked and built by the Idris compiler (more on this later).  Note, however,
that regular Idris source files use an `.idr` ending, and that you go with that
file type unless you end up writing much more prose than code as I do at the
moment. Later in this tutorial, you'll have to solve some exercises, the
solutions of which can be found in the `src/Solutions` subfolder. There, I use
regular `.idr` files.

Before we begin, make sure to install the Idris compiler on your system.
Throughout this tutorial, I assume you installed the *pack* package manager and
setup a skeleton package as described [here](../Appendices/Install.md). It is
certainly possible to follow along with just the Idris compiler installed by
other means, but some adjustments will be necessary when starting REPL sessions
or building executables.

Every Idris source file should typically start with a module name plus some
necessary imports, and this document is no exception:

```idris
module Tutorial.Intro
```

A module name consists of a list of identifiers separated by dots and must
reflect the folder structure plus the module file's name.

<!-- vi: filetype=idris2:syntax=markdown
-->

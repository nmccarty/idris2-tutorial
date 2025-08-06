# Functional Programming in Idris 2

The goal of this project is quickly explained: To become a more or less
comprehensive guide to the Idris programming language, with a lot of
introductory material targeted at newcomers to functional programming.

The content will be organized in several parts, with the part about the core
language features being the main guide to functional programming in Idris. Every
part consists of several chapters, each trying to cover in depth a certain
aspect of the Idris programming language and its core libraries. Most chapters
come with (sometimes lots of) exercises, with solutions available in directory
`src/Solutions`.

Right now, even the part about core language features is not yet finished, but
is being actively developed and tried on several of my own students, some of
which are completely new to functional programming.

The source for this book is available on GitHub at
[idris-community/idris2-tutorial](https://github.com/idris-community/idris2-tutorial)

## Part 1: Core Language Features

This part tries to give a solid introduction to the Idris programming language.
If you are new to functional programming, make sure to follow these chapters in
order and *solve all the exercises*.

If you already used other pure functional programming languages like Haskell,
you might go through the introductory material (Functions Part 1, Algebraic Data
Types, and Interfaces) pretty quickly, as most of this stuff will already be
familiar to you.

## Part 2: Appendices

The appendices can be used as references for the topics at hand. I plan to
eventually have a concise reference on Idris syntax, typical error messages, the
module system, interactive editing and possibly others.

## Prerequisites

At the moment, this project is being actively developed and evolved against the
main branch of the Idris 2 repository.  It is being tested nightly on GitHub and
built against the latest version of [pack's package
collection](https://github.com/stefan-hoeck/idris2-pack-db).

In order to follow along with this tutorial, it is strongly suggested to install
Idris via the pack package manager as described
[here](src/Appendices/Install.md).

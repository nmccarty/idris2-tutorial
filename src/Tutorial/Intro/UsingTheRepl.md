# Using the REPL

Idris comes with a useful REPL (an acronym for *Read Evaluate Print Loop*),
which we will use for tinkering with small ideas, and for quickly experimenting
with the code we just wrote.  In order to start a REPL session, run the
following command in a terminal:

```repl
pack repl
```

Idris should now be ready to accept you commands:

```repl
     ____    __     _         ___
    /  _/___/ /____(_)____   |__ \
    / // __  / ___/ / ___/   __/ /     Version 0.5.1-3c532ea35
  _/ // /_/ / /  / (__  )   / __/      https://www.idris-lang.org
 /___/\__,_/_/  /_/____/   /____/      Type :? for help

Welcome to Idris 2.  Enjoy yourself!
Main>
```

We can go ahead and enter some simple arithmetic expressions. Idris will
*evaluate* these and print the result:

```repl
Main> 2 * 4
8
Main> 3 * (7 + 100)
321
```

Since every expression in Idris has an associated *type*, we might want to
inspect these as well:

```repl
Main> :t 2
2 : Integer
```

Here `:t` is a command of the Idris REPL (it is not part of the Idris
programming language), and it is used to inspect the type
of an expression.

```repl
Main> :t 2 * 4
2 * 4 : Integer
```

Whenever we perform calculations with integer literals without being explicit
about the types we want to use, Idris will use `Integer` as a default. `Integer`
is an arbitrary precision signed integer type. It is one of the *primitive
types* built into the language. Other primitives include fixed precision signed
and unsigned integral types (`Bits8`, `Bits16`, `Bits32` `Bits64`, `Int8`,
`Int16`, `Int32`, and `Int64`), double precision (64 bit) floating point numbers
(`Double`), unicode characters (`Char`) and strings of unicode characters
(`String`).  We will use many of these in due time.

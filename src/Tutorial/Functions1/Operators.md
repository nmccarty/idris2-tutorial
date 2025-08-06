# Operators

```idris
module Tutorial.Functions1.Operators
```

In Idris, infix operators like `.`, `*` or `+` are not built into the language,
but are just regular Idris function with some special support for using them in
infix notation.  When we don't use operators in infix notation, we have to wrap
them in parentheses.

As an example, let us define a custom operator for sequencing functions of type
`Bits8 -> Bits8`:

```idris
infixr 4 >>>

(>>>) : (Bits8 -> Bits8) -> (Bits8 -> Bits8) -> Bits8 -> Bits8
f1 >>> f2 = f2 . f1

foo : Bits8 -> Bits8
foo n = 2 * n + 3

test : Bits8 -> Bits8
test = foo >>> foo >>> foo >>> foo
```

In addition to declaring and defining the operator itself, we also have to
specify its fixity: `infixr 4 >>>` means, that `(>>>)` associates to the right
(meaning, that `f >>> g >>> h` is to be interpreted as `f >>> (g >>> h)`) with a
priority of `4`. You can also have a look at the fixity of operators exported by
the *Prelude* in the REPL:

```repl
Tutorial.Functions1> :doc (.)
Prelude.. : (b -> c) -> (a -> b) -> a -> c
  Function composition.
  Totality: total
  Fixity Declaration: infixr operator, level 9
```

When you mix infix operators in an expression, those with a higher priority bind
more tightly. For instance, `(+)` is left associated with a priority of 8, while
`(*)` is left associated with a priority of 9. Hence, `a * b + c` is the same as
`(a * b) + c` instead of `a * (b + c)`.

## Operator Sections

Operators can be partially applied just like regular functions. In this case,
the whole expression has to be wrapped in parentheses and is called an *operator
section*. Here are two examples:

```repl
Tutorial.Functions1> testSquare (< 10) 5
False
Tutorial.Functions1> testSquare (10 <) 5
True
```

As you can see, there is a difference between `(< 10)` and `(10 <)`. The first
tests, whether its argument is less than 10, the second, whether 10 is less than
its argument.

One exception where operator sections will not work is with the *minus* operator
`(-)`. Here is an example to demonstrate this:

```idris
applyToTen : (Integer -> Integer) -> Integer
applyToTen f = f 10
```

This is just a higher-order function applying the number ten to its function
argument. This works very well in the following example:

```repl
Tutorial.Functions1> applyToTen (* 2)
20
```

However, if we want to subtract five from ten, the following will fail:

```repl
Tutorial.Functions1> applyToTen (- 5)
Error: Can't find an implementation for Num (Integer -> Integer).

(Interactive):1:12--1:17
 1 | applyToTen (- 5)
```

The problem here is, that Idris treats `- 5` as an integer literal instead of an
operator section. In this special case, we therefore have to use an anonymous
function instead:

```repl
Tutorial.Functions1> applyToTen (\x => x - 5)
5
```

## Infix Notation for Non-Operators

In Idris, it is possible to use infix notation for regular binary functions, by
wrapping them in backticks.  It is even possible to define a precedence (fixity)
for these and use them in operator sections, just like regular operators:

```idris
infixl 8 `plus`

infixl 9 `mult`

plus : Integer -> Integer -> Integer
plus = (+)

mult : Integer -> Integer -> Integer
mult = (*)

arithTest : Integer
arithTest = 5 `plus` 10 `mult` 12

arithTest' : Integer
arithTest' = 5 + 10 * 12
```

## Operators exported by the *Prelude*

Here is a list of important operators exported by the *Prelude*.  Most of these
are *constrained*, that is they work only for types implementing a certain
*interface*. Don't worry about this right now. We will learn about interfaces in
due time, and the operators behave as they intuitively should.  For instance,
addition and multiplication work for all numeric types, comparison operators
work for almost all types in the *Prelude* with the exception of functions.

* `(.)`: Function composition
* `(+)`: Addition
* `(*)`: Multiplication
* `(-)`: Subtraction
* `(/)`: Division
* `(==)` : True, if two values are equal
* `(/=)` : True, if two values are not equal
* `(<=)`, `(>=)`, `(<)`, and `(>)` : Comparison operators
* `($)`: Function application

The most special of the above is the last one. It has a priority of 0, so all
other operators bind more tightly.  In addition, function application binds more
tightly, so this can be used to reduce the number of parentheses required. For
instance, instead of writing `isTriple 3 4 (2 + 3 * 1)` we can write `isTriple 3
4 $ 2 + 3 * 1`, which is exactly the same. Sometimes, this helps readability,
sometimes, it doesn't. The important thing to remember is that `fun $ x y` is
just the same as `fun (x y)`.

<!-- vi: filetype=idris2:syntax=markdown
-->

# Compile-Time Computations

```idris
module Tutorial.Dependent.Comptime

import Tutorial.Dependent.LengthIndexedLists

%default total
```

In the last section - especially in some of the exercises - we started more and more to use compile time computations to describe the types of our functions and values. This is a very powerful concept, as it allows us to compute output types from input types. Here's an example:

It is possible to concatenate two `List`s with the `(++)` operator. Surely, this should also be possible for `Vect`. But `Vect` is indexed by its length, so we have to reflect in the types exactly how the lengths of the inputs affect the lengths of the output. Here's how to do this:

```idris
(++) : Vect m a -> Vect n a -> Vect (m + n) a
(++) []        ys = ys
(++) (x :: xs) ys = x :: (xs ++ ys)
```

Note, how we keep track of the lengths at the type-level, again ruling out certain common programming errors like inadvertently dropping some values.

We can also use type-level computations as patterns on the input types. Here is an alternative type and implementation for `drop`, which you implemented in the exercises by using a `Fin n` argument:

```idris
drop' : (m : Nat) -> Vect (m + n) a -> Vect n a
drop' 0     xs        = xs
drop' (S k) (_ :: xs) = drop' k xs
```

Note that changing the order from `(m + n)` to `(n + m)` in the second parameter will cause an error at the second `xs`:

```repl
While processing right hand side of drop'. Can't solve constraint between: plus n 0 and n.
```

You will learn why in the next section.

## Limitations

After all the examples and exercises in this section you might have come to the conclusion that we can use arbitrary expressions in the types and Idris will happily evaluate and unify all of them for us.

I'm afraid that's not even close to the truth. The examples in this section were hand-picked because they are known to *just work*. The reason being, that there was always a direct link between our own pattern matches and the implementations of functions we used at compile time.

For instance, here is the implementation of addition of natural numbers:

```idris
add : Nat -> Nat -> Nat
add Z     n = n
add (S k) n = S $ add k n
```

As you can see, `add` is implemented via a pattern match on its *first* argument, while the second argument is never inspected. Note, how this is exactly how `(++)` for `Vect` is implemented: There, we also pattern match on the first argument, returning the second unmodified in the `Nil` case, and prepending the head to the result of appending the tail in the *cons* case. Since there is a direct correspondence between the two pattern matches, it is possible for Idris to unify `0 + n` with `n` in the `Nil` case, and `(S k) + n` with `S (k + n)` in the *cons* case.

Here is a simple example, where Idris will not longer be convinced without some help from us:

```idris
failing "Can't solve constraint"
  reverse : Vect n a -> Vect n a
  reverse []        = []
  reverse (x :: xs) = reverse xs ++ [x]
```

When we type-check the above, Idris will fail with the following error message: "Can't solve constraint between: plus n 1 and S n." Here's what's going on: From the pattern match on the left hand side, Idris knows that the length of the vector is `S n`, for some natural number `n` corresponding to the length of `xs`. The length of the vector on the right hand side is `n + 1`, according to the type of `(++)` and the lengths of `xs` and `[x]`. Overloaded operator `(+)` is implemented via function `Prelude.plus`, that's why Idris replaces `(+)` with `plus` in the error message.

As you can see from the above, Idris can't verify on its own that `1 + n` is the same thing as `n + 1`. It can accept some help from us, though. If we come up with a *proof* that the above equality holds (or - more generally - that our implementation of addition for natural numbers is *commutative*), we can use this proof to *rewrite* the types on the right hand side of `reverse`. Writing proofs and using `rewrite` will require some in-depth explanations and examples. Therefore, these things will have to wait until another chapter.

## Unrestricted Implicits

In functions like `replicate`, we pass a natural number `n` as an explicit, unrestricted argument from which we infer the length of the vector to return. In some circumstances, `n` can be inferred from the context. For instance, in the following example it is tedious to pass `n` explicitly:

```idris
ex4 : Vect 3 Integer
ex4 = zipWith (*) (replicate 3 10) (replicate 3 11)
```

The value `n` is clearly derivable from the context, which can be confirmed by replacing it with underscores:

```idris
ex5 : Vect 3 Integer
ex5 = zipWith (*) (replicate _ 10) (replicate _ 11)
```

We therefore can implement an alternative version of `replicate`, where we pass `n` as an implicit argument of *unrestricted* quantity:

```idris
replicate' : {n : _} -> a -> Vect n a
replicate' = replicate n
```

Note how, in the implementation of `replicate'`, we can refer to `n` and pass it as an explicit argument to `replicate`.

Deciding whether to pass potentially inferable arguments to a function implicitly or explicitly is a question of how often the arguments actually *are* inferable by Idris. Sometimes it might even be useful to have both versions of a function. Remember, however, that even in case of an implicit argument we can still pass the value explicitly:

```idris
ex6 : Vect ? Bool
ex6 = replicate' {n = 2} True
```

In the type signature above, the question mark (`?`) means, that Idris should try and figure out the value on its own by unification. This forces us to specify `n` explicitly on the right hand side of `ex6`.

### Pattern Matching on Implicits

The implementation of `replicate'` makes use of function `replicate`, where we could pattern match on the explicit argument `n`. However, it is also possible to pattern match on implicit, named arguments of non-zero quantity:

```idris
replicate'' : {n : _} -> a -> Vect n a
replicate'' {n = Z}   _ = Nil
replicate'' {n = S _} v = v :: replicate'' v
```

<!-- vi: filetype=idris2:syntax=markdown
-->

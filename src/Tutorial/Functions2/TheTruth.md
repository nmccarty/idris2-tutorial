# The Truth about Function Arguments

```idris
module Tutorial.Functions2.TheTruth

%default total
```

So far, when we defined a top level function, it looked something like the following:

```idris
zipEitherWith : (a -> b -> c) -> Either e a -> Either e b -> Either e c
zipEitherWith f (Right va) (Right vb) = Right (f va vb)
zipEitherWith f (Left e)   _          = Left e
zipEitherWith f _          (Left e)   = Left e
```

Function `zipEitherWith` is a generic higher-order function combining the values stored in two `Either`s via a binary function. If either of the `Either` arguments is a `Left`, the result is also a `Left`.

This is a *generic function* with *type parameters* `a`, `b`, `c`, and `e`. However, there is a more verbose type for `zipEitherWith`, which is visible in the REPL when entering `:ti zipEitherWith` (the `i` here tells Idris to include `implicit` arguments). You will get a type similar to this:

```idris
zipEitherWith' :  {0 a : Type}
               -> {0 b : Type}
               -> {0 c : Type}
               -> {0 e : Type}
               -> (a -> b -> c)
               -> Either e a
               -> Either e b
               -> Either e c
```

In order to understand what's going on here, we will have to talk about named arguments, implicit arguments, and quantities.

## Named Arguments

In a function type, we can give each argument a name. Like so:

```idris
fromMaybe : (deflt : a) -> (ma : Maybe a) -> a
fromMaybe deflt Nothing = deflt
fromMaybe _    (Just x) = x
```

Here, the first argument is given name `deflt`, the second `ma`. These names can be reused in a function's implementation, as was done for `deflt`, but this is not mandatory: We are free to use different names in the implementation. There are several reasons, why we'd choose to name our arguments: It can serve as documentation, but it also allows us to pass the arguments to a function in arbitrary order when using the following syntax:

```idris
extractBool : Maybe Bool -> Bool
extractBool v = fromMaybe { ma = v, deflt = False }
```

Or even :

```idris
extractBool2 : Maybe Bool -> Bool
extractBool2 = fromMaybe { deflt = False }
```

The arguments in a record's constructor are automatically named in accordance with the field names:

```idris
record Dragon where
  constructor MkDragon
  name      : String
  strength  : Nat
  hitPoints : Int16

gorgar : Dragon
gorgar = MkDragon { strength = 150, name = "Gorgar", hitPoints = 10000 }
```

For the use cases described above, named arguments are merely a convenience and completely optional. However, Idris is a *dependently typed* programming language: Types can be calculated from and depend on values. For instance, the *result type* of a function can *depend* on the *value* of one of its arguments. Here's a contrived example:

```idris
IntOrString : Bool -> Type
IntOrString True  = Integer
IntOrString False = String

intOrString : (v : Bool) -> IntOrString v
intOrString False = "I'm a String"
intOrString True  = 1000
```

If you see such a thing for the first time, it can be hard to understand what's going on here. First, function `IntOrString` computes a `Type` from a `Bool` value: If the argument is `True`, it returns type `Integer`, if the argument is `False` it returns `String`. We use this to calculate the return type of function `intOrString` based on its boolean argument `v`: If `v` is `True`, the return type is (in accordance with `IntOrString True = Integer`) `Integer`, otherwise it is `String`.

Note, how in the type signature of `intOrString`, we *must* give the argument of type `Bool` a name (`v`) in order to reference it in the result type `IntOrString v`.

You might wonder at this moment, why this is useful and why we would ever want to define a function with such a strange type. We will see lots of very useful examples in due time! For now, suffice to say that in order to express dependent function types, we need to name at least some of the function's arguments and refer to them by name in the types of other arguments.

## Implicit Arguments

Implicit arguments are arguments, the values of which the compiler should infer and fill in for us automatically. For instance, in the following function signature, we expect the compiler to infer the value of type parameter `a` automatically from the types of the other arguments (ignore the 0 quantity for the moment; I'll explain it in the next subsection):

```idris
maybeToEither : {0 a : Type} -> Maybe a -> Either String a
maybeToEither Nothing  = Left "Nope"
maybeToEither (Just x) = Right x

-- Please remember, that the above is
-- equivalent to the following:
maybeToEither' : Maybe a -> Either String a
maybeToEither' Nothing  = Left "Nope"
maybeToEither' (Just x) = Right x
```

As you can see, implicit arguments are wrapped in curly braces, unlike explicit named arguments, which are wrapped in parentheses. Inferring the value of an implicit argument is not always possible. For instance, if we enter the following at the REPL, Idris will fail with an error:

```repl
Tutorial.Functions2> show (maybeToEither Nothing)
Error: Can't find an implementation for Show (Either String ?a).
```

Idris is unable to find an implementation of `Show (Either String a)` without knowing what `a` actually is. Note the question mark in front of the type parameter: `?a`. If this happens, there are several ways to help the type checker. We could, for instance, pass a value for the implicit argument explicitly. Here's the syntax to do this:

```repl
Tutorial.Functions2> show (maybeToEither {a = Int8} Nothing)
"Left "Nope""
```

As you can see, we use the same syntax as shown above for explicit named arguments and the two forms of argument passing can be mixed.

We could also specify the type of the whole expression using utility function `the` from the *Prelude*:

```repl
Tutorial.Functions2> show (the (Either String Int8) (maybeToEither Nothing))
"Left "Nope""
```

It is instructive to have a look at the type of `the`:

```repl
Tutorial.Functions2> :ti the
Prelude.the : (0 a : Type) -> a -> a
```

Compare this with the identity function `id`:

```repl
Tutorial.Functions2> :ti id
Prelude.id : {0 a : Type} -> a -> a
```

The only difference between the two: In case of `the`, the type parameter `a` is an *explicit* argument, while in case of `id`, it is an *implicit* argument. Although the two functions have almost identical types (and implementations!), they serve quite different purposes: `the` is used to help type inference, while `id` is used whenever we'd like to return an argument without modifying it at all (which, in the presence of higher-order functions, happens surprisingly often).

Both ways to improve type inference shown above are used quite often, and must be understood by Idris programmers.

## Multiplicities

Finally, we need to talk about the zero multiplicity, which appeared in several of the type signatures in this section. Idris 2, unlike its predecessor Idris 1, is based on a core language called *quantitative type theory* (QTT): Every variable in Idris 2 is associated with one of three possible multiplicities:

- `0`, meaning that the variable is *erased* at runtime.
- `1`, meaning that the variable is used *exactly once* at runtime.
- *Unrestricted* (the default), meaning that the variable is used an arbitrary number of times at runtime.

We will not talk about the most complex of the three, multiplicity `1`, here. We are, however, often interested in multiplicity `0`: A variable with multiplicity `0` is only relevant at *compile time*. It will not make any appearance at runtime, and the computation of such a variable will never affect a program's runtime performance.

In the type signature of `maybeToEither` we see that type parameter `a` has multiplicity `0`, and will therefore be erased and is only relevant at compile time, while the `Maybe a` argument has *unrestricted* multiplicity.

It is also possible to annotate explicit arguments with multiplicities, in which case the argument must again be put in parentheses. For an example, look again at the type signature of `the`.

## Underscores

It is often desirable, to only write as little code as necessary and let Idris figure out the rest. We have already learned about one such occasion: Catch-all patterns. If a variable in a pattern match is not used on the right hand side, we can't just drop it, as this would make it impossible for Idris to know, which of several arguments we were planning to drop, but we can use an underscore as a placeholder instead:

```idris
isRight : Either a b -> Bool
isRight (Right _) = True
isRight _         = False
```

But when we look at the type signature of `isRight`, we will note that type parameters `a` and `b` are also only used once, and are therefore of no importance. Let's get rid of them:

```idris
isRight' : Either _ _ -> Bool
isRight' (Right _) = True
isRight' _         = False
```

In the detailed type signature of `zipEitherWith`, it should be obvious for Idris that the implicit arguments are of type `Type`. After all, all of them are later on applied to the `Either` type constructor, which is of type `Type -> Type -> Type`. Let's get rid of them:

```idris
zipEitherWith'' :  {0 a : _}
                -> {0 b : _}
                -> {0 c : _}
                -> {0 e : _}
                -> (a -> b -> c)
                -> Either e a
                -> Either e b
                -> Either e c
```

Consider the following contrived example:

```idris
foo : Integer -> String
foo n = show (the (Either String Integer) (Right n))
```

Since we wrap an `Integer` in a `Right`, it is obvious that the second argument in `Either String Integer` is `Integer`. Only the `String` argument can't be inferred by Idris. Even better, the `Either` itself is obvious! Let's get rid of the unnecessary noise:

```idris
foo' : Integer -> String
foo' n = show (the (_ String _) (Right n))
```

Please note, that using underscores as in `foo'` is not always desirable, as it can quite drastically obfuscate the written code. Always use a syntactic convenience to make code more readable, and not to show people how clever you are.

<!-- vi: filetype=idris2:syntax=markdown
-->

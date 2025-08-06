# Alternative Syntax for Data Definitions

```idris
module Tutorial.DataTypes.AltSyntax
```

While the examples in the section about parameterized data types are short and
concise, there is a slightly more verbose but much more general form for writing
such definitions, which makes it much clearer what's going on.  In my opinion,
this more general form should be preferred in all but the most simple data
definitions.

Here are the definitions of `Option`, `Validated`, and `Seq` again, using this
more general form (I put them in their own *namespace*, so Idris will not
complain about identical names in the same source file):

```idris
-- GADT is an acronym for "generalized algebraic data type"
namespace GADT
  data Option : Type -> Type where
    Some : a -> Option a
    None : Option a

  data Validated : Type -> Type -> Type where
    Invalid : e -> Validated e a
    Valid   : a -> Validated e a

  data Seq : Type -> Type where
    Nil  : Seq a
    (::) : a -> GADT.Seq a -> Seq a
```

Here, `Option` is clearly declared as a type constructor (a function of type
`Type -> Type`), while `Some` is a generic function of type `a -> Option a`
(where `a` is a *type parameter*) and `None` is a nullary generic function of
type `Option a` (`a` again being a type parameter).  Likewise for `Validated`
and `Seq`. Note, that in case of `Seq` we had to disambiguate between the
different `Seq` definitions in the recursive case. Since we will usually not
define several data types with the same name in a source file, this is not
necessary most of the time.

# Interfaces

Function overloading - the definition of functions with the same name but different implementations - is a concept found in many programming languages. Idris natively supports overloading of functions: Two functions with the same name can be defined in different modules or namespaces, and Idris will try to disambiguate between these based on the types involved. Here is an example:

```idris
module Tutorial.Interfaces

%default total

namespace Bool
  export
  size : Bool -> Integer
  size True  = 1
  size False = 0

namespace Integer
  export
  size : Integer -> Integer
  size = id

namespace List
  export
  size : List a -> Integer
  size = cast . length
```

Here, we defined three different functions called `size`, each in its own namespace. We can disambiguate between these by prefixing them with their namespace:

```repl
Tutorial.Interfaces> :t Bool.size
Tutorial.Interfaces.Bool.size : Bool -> Integer
```

However, this is usually not necessary:

```idris
mean : List Integer -> Integer
mean xs = sum xs `div` size xs
```

As you can see, Idris can disambiguate between the different `size` functions, since `xs` is of type `List Integer`, which unifies only with `List a`, the argument type of `List.size`.

<!-- vi: filetype=idris2:syntax=markdown
-->

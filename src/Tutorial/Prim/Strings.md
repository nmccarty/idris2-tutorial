# Working with Strings

```idris
module Tutorial.Prim.Strings

import Data.Bits
import Data.String

%default total
```

Module `Data.String` in *base* offers a rich set of functions for working with strings. All these are based on the following primitive operations built into the compiler:

- `prim__strLength`: Returns the length of a string.
- `prim__strHead`: Extracts the first character from a string.
- `prim__strTail`: Removes the first character from a string.
- `prim__strCons`: Prepends a character to a string.
- `prim__strAppend`: Appends two strings.
- `prim__strIndex`: Extracts a character at the given position from a string.
- `prim__strSubstr`: Extracts the substring between the given positions.

Needless to say, not all of these functions are total. Therefore, Idris must make sure that invalid calls do not reduce during compile time, as otherwise the compiler would crash. If, however we force the evaluation of a partial primitive function by compiling and running the corresponding program, this program will crash with an error:

```repl
Tutorial.Prim> prim__strTail ""
prim__strTail ""
Tutorial.Prim> :exec putStrLn (prim__strTail "")
Exception in substring: 1 and 0 are not valid start/end indices for ""
```

Note, how `prim__strTail ""` is not reduced at the REPL and how the same expression leads to a runtime exception if we compile and execute the program. Valid calls to `prim__strTail` are reduced just fine, however:

```idris
tailExample : prim__strTail "foo" = "oo"
tailExample = Refl
```

## Pack and Unpack

Two of the most important functions for working with strings are `unpack` and `pack`, which convert a string to a list of characters and vice versa. This allows us to conveniently implement many string operations by iterating or folding over the list of characters instead. This might not always be the most efficient thing to do, but unless you plan to handle very large amounts of text, they work and perform reasonably well.

## String Interpolation

Idris allows us to include arbitrary string expressions in a string literal by wrapping them in curly braces, the first of which has to be escaped with a backslash. For instance:

```idris
interpEx1 : Bits64 -> Bits64 -> String
interpEx1 x y = "\{show x} + \{show y} = \{show $ x + y}"
```

This is a very convenient way to assemble complex strings from values of different types. In addition, there is interface `Interpolation`, which allows us to use values in interpolated strings without having to convert them to strings first:

```idris
data Element = H | He | C | N | O | F | Ne

Formula : Type
Formula = List (Element,Nat)

Interpolation Element where
  interpolate H  = "H"
  interpolate He = "He"
  interpolate C  = "C"
  interpolate N  = "N"
  interpolate O  = "O"
  interpolate F  = "F"
  interpolate Ne = "Ne"

Interpolation (Element,Nat) where
  interpolate (_, 0) = ""
  interpolate (x, 1) = "\{x}"
  interpolate (x, k) = "\{x}\{show k}"

Interpolation Formula where
  interpolate = foldMap interpolate

ethanol : String
ethanol = "The formulat of ethanol is: \{[(C,2),(H,6),(O, the Nat 1)]}"
```

## Raw and Multiline String Literals

In string literals, we have to escape certain characters like quotes, backslashes or new line characters. For instance:

```idris
escapeExample : String
escapeExample = "A quote: \". \nThis is on a new line.\nA backslash: \\"
```

Idris allows us to enter raw string literals, where there is no need to escape quotes and backslashes, by pre- and postfixing the wrapping quote characters with the same number of hash characters. For instance:

```idris
rawExample : String
rawExample = #"A quote: ". A blackslash: \"#

rawExample2 : String
rawExample2 = ##"A quote: ". A blackslash: \"##
```

With raw string literals, it is still possible to use string interpolation, but the opening curly brace has to be prefixed with a backslash and the same number of hashes as are being used for opening and closing the string literal:

```idris
rawInterpolExample : String
rawInterpolExample = ##"An interpolated "string": \##{rawExample}"##
```

Finally, Idris also allows us to conveniently write multiline strings. These can be pre- and postfixed with hashes if we want raw multiline string literals, and they also can be combined with string interpolation. Multiline literals are opened and closed with triple quote characters. Indenting the closing triple quotes allows us to indent the whole multiline literal. Whitespace used for indentation will not appear in the resulting string. For instance:

```idris
multiline1 : String
multiline1 = """
  And I raise my head and stare
  Into the eyes of a stranger
  I've always known that the mirror never lies
  People always turn away
  From the eyes of a stranger
  Afraid to see what hides behind the stare
  """

multiline2 : String
multiline2 = #"""
  An example for a simple expression:
  "foo" ++ "bar".
  This is reduced to "\#{"foo" ++ "bar"}".
  """#
```

Make sure to look at the example strings at the REPL to see the effect of interpolation and raw string literals and compare it with the syntax we used.

<!-- vi: filetype=idris2:syntax=markdown
-->

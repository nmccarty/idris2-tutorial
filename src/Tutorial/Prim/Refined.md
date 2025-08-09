# Refined Primitives

```idris
module Tutorial.Prim.Refined

import Data.Bits
import Data.String

%default total
```

We often do not want to allow all values of a type in a certain context. For instance, `String` as an arbitrary sequence of UTF-8 characters (several of which are not even printable), is too general most of the time. Therefore, it is usually advisable to rule out invalid values early on, by pairing a value with an erased proof of validity.

We have learned how we can write elegant predicates, with which we can proof our functions to be total, and from which we can - in the ideal case - derive other, related predicates. However, when we define predicates on primitives they are to a certain degree doomed to live in isolation, unless we come up with a set of primitive axioms (implemented most likely using `believe_me`), with which we can manipulate our predicates.

## Use Case: ASCII Strings

String encodings is a difficult topic, so in many low level routines it makes sense to rule out most characters from the beginning. Assume therefore, we'd like to make sure the strings we accept in our application only consist of ASCII characters:

```idris
isAsciiChar : Char -> Bool
isAsciiChar c = ord c <= 127

isAsciiString : String -> Bool
isAsciiString = all isAsciiChar . unpack
```

We can now *refine* a string value by pairing it with an erased proof of validity:

```idris
record Ascii where
  constructor MkAscii
  value : String
  0 prf : isAsciiString value === True
```

It is now *impossible* to at runtime or compile time create a value of type `Ascii` without first validating the wrapped string. With this, it is already pretty easy to safely wrap strings at compile time in a value of type `Ascii`:

```idris
hello : Ascii
hello = MkAscii "Hello World!" Refl
```

And yet, it would be much more convenient to still use string literals for this, without having to sacrifice the comfort of safety. To do so, we can't use interface `FromString`, as its function `fromString` would force us to convert *any* string, even an invalid one. However, we actually don't need an implementation of `FromString` to support string literals, just like we didn't require an implementation of `Num` to support integer literals. What we really need is a function named `fromString`. Now, when string literals are desugared, they are converted to invocations of `fromString` with the given string value as its argument. For instance, literal `"Hello"` gets desugared to `fromString "Hello"`. This happens before type checking and filling in of (auto) implicit values. It is therefore perfectly fine, to define a custom `fromString` function with an erased auto implicit argument as a proof of validity:

```idris
fromString : (s : String) -> {auto 0 prf : isAsciiString s === True} -> Ascii
fromString s = MkAscii s prf
```

With this, we can use (valid) string literals for coming up with values of type `Ascii` directly:

```idris
hello2 : Ascii
hello2 = "Hello World!"
```

In order to at runtime create values of type `Ascii` from strings of an unknown source, we can use a refinement function returning some kind of failure type:

```idris
test : (b : Bool) -> Dec (b === True)
test True  = Yes Refl
test False = No absurd

ascii : String -> Maybe Ascii
ascii x = case test (isAsciiString x) of
  Yes prf   => Just $ MkAscii x prf
  No contra => Nothing
```

### Disadvantages of Boolean Proofs

For many use cases, what we described above for ASCII strings can take us very far. However, one drawback of this approach is that we can't safely perform any computations with the proofs at hand.

For instance, we know it will be perfectly fine to concatenate two ASCII strings, but in order to convince Idris of this, we will have to use `believe_me`, because we will not be able to proof the following lemma otherwise:

```idris
0 allAppend :  (f : Char -> Bool)
            -> (s1,s2 : String)
            -> (p1 : all f (unpack s1) === True)
            -> (p2 : all f (unpack s2) === True)
            -> all f (unpack (s1 ++ s2)) === True
allAppend f s1 s2 p1 p2 = believe_me $ Refl {x = True}

namespace Ascii
  export
  (++) : Ascii -> Ascii -> Ascii
  MkAscii s1 p1 ++ MkAscii s2 p2 =
    MkAscii (s1 ++ s2) (allAppend isAsciiChar s1 s2 p1 p2)
```

The same goes for all operations extracting a substring from a given string: We will have to implement according rules using `believe_me`. Finding a reasonable set of axioms to conveniently deal with refined primitives can therefore be challenging at times, and whether such axioms are even required very much depends on the use case at hand.

## Use Case: Sanitized HTML

Assume you write a simple web application for scientific discourse between registered users. To keep things simple, we only consider unformatted text input here. Users can write arbitrary text in a text field and upon hitting Enter, the message is displayed to all other registered users.

Assume now a user decides to enter the following text:

```html
<script>alert("Hello World!")</script>
```

Well, it could have been (much) worse. Still, unless we take measures to prevent this from happening, this might embed a JavaScript program in our web page we never intended to have there! What I described here, is a well known security vulnerability called [cross-site scripting](https://en.wikipedia.org/wiki/Cross-site_scripting). It allows users of web pages to enter malicious JavaScript code in text fields, which will then be included in the page's HTML structure and executed when it is being displayed to other users.

We want to make sure, that this cannot happen on our own web page. In order to protect us from this attack, we could for instance disallow certain characters like `'<'` or `'>'` completely (although this might not be enough!), but if our chat service is targeted at programmers, this will be overly restrictive. An alternative is to escape certain characters before rendering them on the page.

```idris
escape : String -> String
escape = concat . map esc . unpack
  where esc : Char -> String
        esc '<'  = "&lt;"
        esc '>'  = "&gt;"
        esc '"'  = "&quot;"
        esc '&'  = "&amp;"
        esc '\'' = "&apos;"
        esc c    = singleton c
```

What we now want to do is to store a string together with a proof that is was properly escaped. This is another form of existential quantification: "Here is a string, and there once existed another string, which we passed to `escape` and arrived at the string we have now". Here's how to encode this:

```idris
record Escaped where
  constructor MkEscaped
  value    : String
  0 origin : String
  0 prf    : escape origin === value
```

Whenever we now embed a string of unknown origin in our web page, we can request a value of type `Escaped` and have the very strong guarantee that we are no longer vulnerable to cross-site scripting attacks. Even better, it is also possible to safely embed string literals known at compile time without the need to escape them first:

```idris
namespace Escaped
  export
  fromString : (s : String) -> {auto 0 prf : escape s === s} -> Escaped
  fromString s = MkEscaped s s prf

escaped : Escaped
escaped = "Hello World!"
```

<!-- vi: filetype=idris2:syntax=markdown
-->

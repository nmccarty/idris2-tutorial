# Working with Files

```idris
module Tutorial.IO.Files

import Data.List1
import Data.String
import Data.Vect

import System.File

%default total
```

Module `System.File` from the *base* library exports utilities necessary to work with file handles and read and write from and to files. When you have a file path (for instance "/home/hock/idris/tutorial/tutorial.ipkg"), the first thing we will typically do is to try and create a file handle (of type `System.File.File` by calling `fileOpen`).

Here is a program for counting all empty lines in a Unix/Linux-file:

```idris
covering
countEmpty : (path : String) -> IO (Either FileError Nat)
countEmpty path = openFile path Read >>= either (pure . Left) (go 0)
  where covering go : Nat -> File -> IO (Either FileError Nat)
        go k file = do
          False <- fEOF file | True => closeFile file $> Right k
          Right "\n" <- fGetLine file
            | Right _  => go k file
            | Left err => closeFile file $> Left err
          go (k + 1) file
```

In the example above, I invoked `(>>=)` without starting a *do block*. Make sure you understand what's going on here. Reading concise functional code is important in order to understand other people's code. Have a look at function `either` at the REPL, try figuring out what `(pure . Left)` does, and note how we use a curried version of `go` as the second argument to `either`.

Function `go` calls for some additional explanations. First, note how we used the same syntax for pattern matching intermediary results as we also saw for `let` bindings. As you can see, we can use several vertical bars to handle more than one additional pattern. In order to read a single line from a file, we use function `fGetLine`. As with most operations working with the file system, this function might fail with a `FileError`, which we have to handle correctly. Note also, that `fGetLine` will return the line including its trailing newline character `'\n'`, so in order to check for empty lines, we have to match against `"\n"` instead of the empty string `""`.

Finally, `go` is not provably total and rightfully so. Files like `/dev/urandom` or `/dev/zero` provide infinite streams of data, so `countEmpty` will never terminate when invoked with such a file path.

## Safe Resource Handling

Note, how we had to manually open and close the file handle in `countEmpty`. This is error-prone and tedious. Resource handling is a big topic, and we definitely won't be going into the details here, but there is a convenient function exported from `System.File`: `withFile`, which handles the opening, closing and handling of file errors for us.

```idris
covering
countEmpty' : (path : String) -> IO (Either FileError Nat)
countEmpty' path = withFile path Read pure (go 0)
  where covering go : Nat -> File -> IO (Either FileError Nat)
        go k file = do
          False <- fEOF file | True => pure (Right k)
          Right "\n" <- fGetLine file
            | Right _  => go k file
            | Left err => pure (Left err)
          go (k + 1) file
```

Go ahead, and have a look at the type of `withFile`, then have a look how we use it to simplify the implementation of `countEmpty'`. Reading and understanding slightly more complex function types is important when learning to program in Idris.

### Interface `HasIO`

When you look at the `IO` functions we used so far, you'll notice that most if not all of them actually don't work with `IO` itself but with a type parameter `io` with a constraint of `HasIO`. This interface allows us to *lift* a value of type `IO a` into another context. We will see use cases for this in later chapters, especially when we talk about monad transformers. For now, you can treat these `io` parameters as being specialized to `IO`.

<!-- vi: filetype=idris2:syntax=markdown
-->

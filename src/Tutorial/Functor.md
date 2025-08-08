# Functor and Friends

Programming, like mathematics, is about abstraction. We try to model parts of the real world, reusing recurring patterns by abstracting over them.

In this chapter, we will learn about several related interfaces, which are all about abstraction and therefore can be hard to understand at the beginning. Especially figuring out *why* they are useful and *when* to use them will take time and experience. This chapter therefore comes with tons of exercises, most of which can be solved with only a few short lines of code. Don't skip them. Come back to them several times until these things start feeling natural to you. You will then realize that their initial complexity has vanished.

```idris hide
module Tutorial.Functor

import Data.List1
import Data.String
import Data.Vect

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->

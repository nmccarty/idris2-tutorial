# Primitives

In the topics we covered so far, we hardly ever talked about primitive types in Idris. They were around and we used them in some computations, but I never really explained how they work and where they come from, nor did I show in detail what we can and can't do with them.

```idris hide
module Tutorial.Prim

import Data.Bits
import Data.String

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->

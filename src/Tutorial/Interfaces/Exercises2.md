# Exercises part 2

1. Implement interfaces `Equals`, `Comp`, `Concat`, and `Empty` for pairs, constraining your implementations as necessary. (Note, that multiple constraints can be given sequentially like other function arguments: `Comp a => Comp b => Comp (a,b)`.)

2. Below is an implementation of a binary tree. Implement interfaces `Equals` and `Concat` for this type.

   ```idris
   data Tree : Type -> Type where
     Leaf : a -> Tree a
     Node : Tree a -> Tree a -> Tree a
   ```

# Exercises part 2

Implement the following functions in a provably total way without "cheating". Note: It is not necessary to implement these in a tail recursive way.

<!-- textlint-disable terminology -->

1. Implement function `depth` for rose trees. This should return the maximal number of `Node` constructors from the current node to the farthest child node. For instance, the current node should be at depth one, all its direct child nodes are at depth two, their immediate child nodes at depth three and so on.

2. Implement interface `Eq` for rose trees.

3. Implement interface `Functor` for rose trees.

4. For the fun of it: Implement interface `Show` for rose trees.

5. In order not to forget how to program with dependent types, implement function `treeToVect` for converting a rose tree to a vector of the correct size.

   Hint: Make sure to follow the same recursion scheme as in the implementation of `treeSize`. Otherwise, this might be very hard to get to work.

<!-- textlint-enable -->

# Exercises part 3

1. As we have seen in the examples above, `IO` actions working with file handles often come with the risk of failure. We can therefore simplify things by writing some utility functions and a custom *bind* operator to work with these nested effects. In a new namespace `IOErr`, implement the following utility functions and use these to further cleanup the implementation of `countEmpty'`:

   ```idris
   pure : a -> IO (Either e a)

   fail : e -> IO (Either e a)

   lift : IO a -> IO (Either e a)

   catch : IO (Either e1 a) -> (e1 -> IO (Either e2 a)) -> IO (Either e2 a)

   (>>=) : IO (Either e a) -> (a -> IO (Either e b)) -> IO (Either e b)

   (>>) : IO (Either e ()) -> Lazy (IO (Either e a)) -> IO (Either e a)
   ```

2. Write a function `countWords` for counting the words in a file. Consider using `Data.String.words` and the utilities from exercise 1 in your implementation.

3. We can generalize the functionality used in `countEmpty` and `countWords`, by implementing a helper function for iterating over the lines in a file and accumulating some state along the way. Implement `withLines` and use it to reimplement `countEmpty` and `countWords`:

   ```idris
   covering
   withLines :  (path : String)
             -> (accum : s -> String -> s)
             -> (initialState : s)
             -> IO (Either FileError s)
   ```

4. We often use a `Monoid` for accumulating values. It is therefore convenient to specialize `withLines` for this case. Use `withLines` to implement `foldLines` according to the type given below:

   ```idris
   covering
   foldLines :  Monoid s
             => (path : String)
             -> (f    : String -> s)
             -> IO (Either FileError s)
   ```

5. Implement function `wordCount` for counting the number of lines, words, and characters in a text document. Define a custom record type together with an implementation of `Monoid` for storing and accumulating these values and use `foldLines` in your implementation of `wordCount`.

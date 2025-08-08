# Exercises part 1

In these exercises, you are going to implement some small command-line applications. Some of these will potentially run forever, as they will only stop when the user enters a keyword for quitting the application. Such programs are no longer provably total. If you added the `%default total` pragma at the top of your source file, you'll need to annotate these functions with `covering`, meaning that you covered all cases in all pattern matches but your program might still loop due to unrestricted recursion.

1. Implement function `rep`, which will read a line of input from the terminal, evaluate it using the given function, and print the result to standard output:

   ```idris
   rep : (String -> String) -> IO ()
   ```

2. Implement function `repl`, which behaves just like `rep` but will repeat itself forever (or until being forcefully terminated):

   ```idris
   covering
   repl : (String -> String) -> IO ()
   ```

3. Implement function `replTill`, which behaves just like `repl` but will only continue looping if the given function returns a `Right`. If it returns a `Left`, `replTill` should print the final message wrapped in the `Left` and then stop.

   ```idris
   covering
   replTill : (String -> Either String String) -> IO ()
   ```

4. Write a program, which reads arithmetic expressions from standard input, evaluates them using `eval`, and prints the result to standard output. The program should loop until users stops it by entering "done", in which case the program should terminate with a friendly greeting. Use `replTill` in your implementation.

5. Implement function `replWith`, which behaves just like `repl` but uses some internal state to accumulate values. At each iteration (including the very first one!), the current state should be printed to standard output using function `dispState`, and the next state should be computed using function `next`. The loop should terminate in case of a `Left` and print a final message using `dispResult`:

   ```idris
   covering
   replWith :  (state      : s)
            -> (next       : s -> String -> Either res s)
            -> (dispState  : s -> String)
            -> (dispResult : res -> s -> String)
            -> IO ()
   ```

6. Use `replWith` from Exercise 5 to write a program for reading natural numbers from standard input and printing the accumulated sum of these numbers. The program should terminate in case of invalid input and if a user enters "done".

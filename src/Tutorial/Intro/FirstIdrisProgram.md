# A First Idris Program

```idris
module Tutorial.Intro.FirstIdrisProgram
```

While we will often start with the REPL for tinkering with small parts of the Idris language, for reading some documentation, or for inspecting the content of an Idris module, lets go ahead and will write a minimal Idris program to get started with the language.

Here comes the mandatory *Hello World*:

```idris
main : IO ()
main = putStrLn "Hello World!"
```

We will inspect the code above in some detail in a moment, but first we'd like to compile and run it. If you have checked out this books source code, you can run the following from the root directory:

```sh
pack -o hello exec src/Tutorial/Intro/FirstIdrisProgram.md
```

This will create an executable called `hello` in the `build/exec` directory, which can be invoked from the command-line like so (without the dollar prefix; this is used here to distinguish the terminal command from its output):

```sh
$ build/exec/hello
Hello World!
```

The pack program requires an `.ipkg` to be in scope (in the current directory or one of its parent directories), which provides other settings like the source directory to use (`src` in our case). The optional `-o` option provides a name to use for the executable to be generated. Pack comes up with a name of its own it this is not provided. Type `pack help` for a list of available command-line options and commands, and `pack help <cmd>` for help with a specific command.

You can also load this source file in a REPL session and invoke function `main` from there:

```sh
pack repl src/Tutorial/Intro/FirstIdrisProgram.md
```

```repl
Tutorial.Intro> :exec main
Hello World!
```

Go ahead and try both ways of building and running `main` on your system!

<!-- vi: filetype=idris2:syntax=markdown
-->

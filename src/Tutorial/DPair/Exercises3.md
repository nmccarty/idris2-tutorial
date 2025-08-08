# Exercises part 3

The challenges presented here all deal with enhancing our table editor in several interesting ways. Some of them are more a matter of style and less a matter of learning to write dependently typed programs, so feel free to solve these as you please. Exercises 1 to 3 should be considered to be mandatory.

1. Add support for storing Idris types `Integer` and `Nat` in CSV columns

2. Add support for `Fin n` to CSV columns. Note: We need runtime access to `n` in order for this to work.

3. Add support for optional types to CSV columns. Since missing values should be encoded by empty strings, it makes no sense to allow for nested optional types, meaning that types like `Maybe Nat` should be allowed while `Maybe (Maybe Nat)` should not.

   Hint: There are several ways to encode these, one being to add a boolean index to `ColType`.

4. Add a command for printing the whole table. Bonus points if all columns are properly aligned.

5. Add support for simple queries: Given a column number and a value, list all rows where entries match the given value.

   This might be a challenge, as the types get pretty interesting.

6. Add support for loading and saving tables from and to disk. A table should be stored in two files: One for the schema and one for the CSV content.

   Note: Reading files in a provably total way can be pretty hard and will be a topic for another day. For now, just use function `readFile` exported from `System.File` in base for reading a file as a whole. This function is partial, because it will not terminate when used with an infinite input stream such as `/dev/urandom` or `/dev/zero`. It is important to *not* use `assert_total` here. Using partial functions like `readFile` might well impose a security risk in a real world application, so eventually, we'd have to deal with this and allow for some way to limit the size of accepted input. It is therefore best to make this partiality visible and annotate all downstream functions accordingly.

You can find an implementation of these additions in the solutions. A small example table can be found in folder `resources`.

Note: There are of course tons of projects to pursue from here, such as writing a proper query language, calculating new rows from existing ones, accumulating values in a column, concatenating and zipping tables, and so on. We will stop for now, probably coming back to this in later examples.

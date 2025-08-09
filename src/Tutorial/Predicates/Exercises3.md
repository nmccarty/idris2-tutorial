# Exercises part 3

1. Implement the following utility functions for `Union`:

   ```idris
   project : (0 t : Type) -> (prf : Has t ts) => Union ts -> Maybe t

   project1 : Union [t] -> t

   safe : Err [] a -> a
   ```

2. Implement the following two functions for embedding an open union in a larger set of possibilities. Note the unerased implicit in `extend`!

   ```idris
   weaken : Union ts -> Union (ts ++ ss)

   extend : {m : _} -> {0 pre : Vect m _} -> Union ts -> Union (pre ++ ts)
   ```

3. Find a general way to embed a `Union ts` in a `Union ss`, so that the following is possible:

   ```idris
   embedTest :  Err [NoNat,NoColType] a
             -> Err [FileError, NoColType, OutOfBounds, NoNat] a
   embedTest = mapFst embed
   ```

4. Make `handle` more powerful, by letting the handler convert the error in question to an `f (Err rem a)`.

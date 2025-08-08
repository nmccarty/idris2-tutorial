# Exercises part 3

1. `Applicative` extends `Functor`, because every `Applicative` is also a `Functor`. Proof this by implementing `map` in terms of `pure` and `(<*>)`.

2. `Monad` extends `Applicative`, because every `Monad` is also an `Applicative`. Proof this by implementing `(<*>)` in terms of `(>>=)` and `pure`.

3. Implement `(>>=)` in terms of `join` and other functions in the `Monad` hierarchy.

4. Implement `join` in terms of `(>>=)` and other functions in the `Monad` hierarchy.

5. There is no lawful `Monad` implementation for `Validated e`. Why?

6. In this slightly extended exercise, we are going to simulate CRUD operations on a data store. We will use a mutable reference (imported from `Data.IORef` from the *base* library) holding a list of `User`s paired with a unique ID of type `Nat` as our user data base:

   ```idris
   DB : Type
   DB = IORef (List (Nat,User))
   ```

   Most operations on a database come with a risk of failure: When we try to update or delete a user, the entry in question might no longer be there. When we add a new user, a user with the given email address might already exist. Here is a custom error type to deal with this:

   ```idris
   data DBError : Type where
     UserExists        : Email -> Nat -> DBError
     UserNotFound      : Nat -> DBError
     SizeLimitExceeded : DBError
   ```

   In general, our functions will therefore have a type similar to the following:

   ```idris
   someDBProg : arg1 -> arg2 -> DB -> IO (Either DBError a)
   ```

   We'd like to abstract over this, by introducing a new wrapper type:

   ```idris
   record Prog a where
     constructor MkProg
     runProg : DB -> IO (Either DBError a)
   ```

   We are now ready to write us some utility functions. Make sure to follow the following business rules when implementing the functions below:

   - Email addresses in the DB must be unique. (Consider implementing `Eq Email` to verify this).

   - The size limit of 1000 entries must not be exceeded.

   - Operations trying to lookup a user by their ID must fail with `UserNotFound` in case no entry was found in the DB.

   You'll need the following functions from `Data.IORef` when working with mutable references: `newIORef`, `readIORef`, and `writeIORef`. In addition, functions `Data.List.lookup` and `Data.List.find` might be useful to implement some of the functions below.

   1. Implement interfaces `Functor`, `Applicative`, and `Monad` for `Prog`.

   2. Implement interface `HasIO` for `Prog`.

   3. Implement the following utility functions:

      ```idris
      throw : DBError -> Prog a

      getUsers : Prog (List (Nat,User))

      -- check the size limit!
      putUsers : List (Nat,User) -> Prog ()

      -- implement this in terms of `getUsers` and `putUsers`
      modifyDB : (List (Nat,User) -> List (Nat,User)) -> Prog ()
      ```

   4. Implement function `lookupUser`. This should fail with an appropriate error, if a user with the given ID cannot be found.

      ```idris
      lookupUser : (id : Nat) -> Prog User
      ```

   5. Implement function `deleteUser`. This should fail with an appropriate error, if a user with the given ID cannot be found. Make use of `lookupUser` in your implementation.

      ```idris
      deleteUser : (id : Nat) -> Prog ()
      ```

   6. Implement function `addUser`. This should fail, if a user with the given `Email` already exists, or if the data banks size limit of 1000 entries is exceeded. In addition, this should create and return a unique ID for the new user entry.

      ```idris
      addUser : (new : User) -> Prog Nat
      ```

   7. Implement function `updateUser`. This should fail, if the user in question cannot be found or a user with the updated user's `Email` already exists. The returned value should be the updated user.

      ```idris
      updateUser : (id : Nat) -> (mod : User -> User) -> Prog User
      ```

   8. Data type `Prog` is actually too specific. We could just as well abstract over the error type and the `DB` environment:

      ```idris
      record Prog' env err a where
        constructor MkProg'
        runProg' : env -> IO (Either err a)
      ```

      Verify, that all interface implementations you wrote for `Prog` can be used verbatim to implement the same interfaces for `Prog' env err`. The same goes for `throw` with only a slight adjustment in the function's type.

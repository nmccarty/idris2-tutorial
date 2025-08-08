# Exercises part 2

```idris
module Tutorial.DataTypes.Exercises2
```

1. Implement an equality test for `Title` (you can use the equality operator `(==)` for comparing two `String`s):

   ```idris
   total
   eqTitle : Title -> Title -> Bool
   ```

2. For `Title`, implement a simple test to check, whether a custom title is being used:

   ```idris
   total
   isOther : Title -> Bool
   ```

3. Given our simple `Credentials` type, there are three ways for authentication to fail:

   - An unknown username was used.
   - The password given does not match the one associated with the username.
   - An invalid key was used.

   Encapsulate these three possibilities in a sum type called `LoginError`, but make sure not to disclose any confidential information: An invalid username should be stored in the corresponding error value, but an invalid password or key should not.

4. Implement function `showError : LoginError -> String`, which can be used to display an error message to the user who unsuccessfully tried to login into our web application.

<!-- vi: filetype=idris2:syntax=markdown
-->

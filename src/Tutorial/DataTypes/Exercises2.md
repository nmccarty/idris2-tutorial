# Sum Type Exercises

```idris
module Tutorial.DataTypes.Exercises2

import Tutorial.DataTypes.SumTypes
```

The solutions to these exercises can be found in [`src/Solutions/DataTypes.idr`](../../Solutions/DataTypes.md).

## Exercise 1

Implement an equality test for `Title` (you can use the equality operator `(==)` for comparing two `String`s):

```idris
total
eqTitle : Title -> Title -> Bool
```

## Exercise 2

Implement a simple test for `Title` to check whether or not a custom title is being used:

```idris
total
isOther : Title -> Bool
```

## Exercise 3

Given our simple `Credentials` type, there are three ways for authentication to fail:

- An unknown username was used.
- The password given does not match the one associated with the username.
- An invalid key was used.

Encapsulate these three possibilities in a sum type called `LoginError`. Make sure not to disclose any confidential information, an invalid username should be stored in the corresponding error value, but an invalid password or key should not.

## Exercise 4

Implement the following function , which can be used to display an error message to the user after they unsuccessfully tried to login into our web application:

```idris hide
-- Hidden forward declaration to make this module compile so we can have syntax
-- highlighting
data LoginError : Type
```

```idris
total
showError : LoginError -> String
```

<!-- vi: filetype=idris2:syntax=markdown
-->

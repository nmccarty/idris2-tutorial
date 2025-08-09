# Conclusion

Predicates allow us to describe contracts between types and to refine the values we accept as valid function arguments. They allow us to make a function safe and convenient to use at runtime *and* compile time by using them as auto implicit arguments, which Idris should try to construct on its own if it has enough information about the structure of a function's arguments.

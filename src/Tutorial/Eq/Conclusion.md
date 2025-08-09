# Conclusion

The concept of *types as propositions, values as proofs* is a very powerful tool for writing provably correct programs. We will therefore spend some more time defining data types for describing contracts between values, and values of these types as proofs that the contracts hold. This will allow us to describe necessary pre- and postconditions for our functions, thus reducing the need to return a `Maybe` or other failure type, because due to the restricted input, our functions can no longer fail.

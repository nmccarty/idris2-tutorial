# Use Case: Nucleic Acids

```idris
module Tutorial.DPair.DNA

import Data.DPair
import Data.Either
import Data.HList
import Data.List
import Data.List1
import Data.Singleton
import Data.String
import Data.Vect

import Text.CSV

%default total
```

We'd like to come up with a small, simplified library for running computations on nucleic acids: RNA and DNA. These are built from five types of nucleobases, three of which are used in both types of nucleic acids and two bases specific for each type of acid. We'd like to make sure that only valid bases are in strands of nucleic acids. Here's a possible encoding:

```idris
data BaseType = DNABase | RNABase

data Nucleobase : BaseType -> Type where
  Adenine  : Nucleobase b
  Cytosine : Nucleobase b
  Guanine  : Nucleobase b
  Thymine  : Nucleobase DNABase
  Uracile  : Nucleobase RNABase

NucleicAcid : BaseType -> Type
NucleicAcid = List . Nucleobase

RNA : Type
RNA = NucleicAcid RNABase

DNA : Type
DNA = NucleicAcid DNABase

encodeBase : Nucleobase b -> Char
encodeBase Adenine  = 'A'
encodeBase Cytosine = 'C'
encodeBase Guanine  = 'G'
encodeBase Thymine  = 'T'
encodeBase Uracile  = 'U'

encode : NucleicAcid b -> String
encode = pack . map encodeBase
```

It is a type error to use `Uracile` in a strand of DNA:

```idris
failing "Mismatch between: RNABase and DNABase."
  errDNA : DNA
  errDNA = [Uracile, Adenine]
```

Note, how we used a variable for nucleobases `Adenine`, `Cytosine`, and `Guanine`: These are again universally quantified, and client code is free to choose a value here. This allows us to use these bases in strands of DNA *and* RNA:

```idris
dna1 : DNA
dna1 = [Adenine, Cytosine, Guanine]

rna1 : RNA
rna1 = [Adenine, Cytosine, Guanine]
```

With `Thymine` and `Uracile`, we are more restrictive: `Thymine` is only allowed in DNA, while `Uracile` is restricted to be used in RNA strands. Let's write parsers for strands of DNA and RNA:

```idris
readAnyBase : Char -> Maybe (Nucleobase b)
readAnyBase 'A' = Just Adenine
readAnyBase 'C' = Just Cytosine
readAnyBase 'G' = Just Guanine
readAnyBase _   = Nothing

readRNABase : Char -> Maybe (Nucleobase RNABase)
readRNABase 'U' = Just Uracile
readRNABase c   = readAnyBase c

readDNABase : Char -> Maybe (Nucleobase DNABase)
readDNABase 'T' = Just Thymine
readDNABase c   = readAnyBase c

readRNA : String -> Maybe RNA
readRNA = traverse readRNABase . unpack

readDNA : String -> Maybe DNA
readDNA = traverse readDNABase . unpack
```

Again, in case of the bases appearing in both kinds of strands, users of the universally quantified `readAnyBase` are free to choose what base type they want, but they will never get a `Thymine` or `Uracile` value.

We can now implement some simple calculations on sequences of nucleobases. For instance, we can come up with the complementary strand:

```idris
complementRNA' : RNA -> RNA
complementRNA' = map calc
  where calc : Nucleobase RNABase -> Nucleobase RNABase
        calc Guanine  = Cytosine
        calc Cytosine = Guanine
        calc Adenine  = Uracile
        calc Uracile  = Adenine

complementDNA' : DNA -> DNA
complementDNA' = map calc
  where calc : Nucleobase DNABase -> Nucleobase DNABase
        calc Guanine  = Cytosine
        calc Cytosine = Guanine
        calc Adenine  = Thymine
        calc Thymine  = Adenine
```

Ugh, code repetition! Not too bad here, but imagine there were dozens of bases with only few specialized ones. Surely, we can do better? Unfortunately, the following won't work:

```idris
complementBase' : Nucleobase b -> Nucleobase b
complementBase' Adenine  = ?what_now
complementBase' Cytosine = Guanine
complementBase' Guanine  = Cytosine
complementBase' Thymine  = Adenine
complementBase' Uracile  = Adenine
```

All goes well with the exception of the `Adenine` case. Remember: Parameter `b` is universally quantified, and the *callers* of our function can decide what `b` is supposed to be. We therefore can't just return `Thymine`: Idris will respond with a type error since callers might want a `Nucleobase RNABase` instead. One way to go about this is to take an additional unerased argument (explicit or implicit) representing the base type:

```idris
complementBase : (b : BaseType) -> Nucleobase b -> Nucleobase b
complementBase DNABase Adenine  = Thymine
complementBase RNABase Adenine  = Uracile
complementBase _       Cytosine = Guanine
complementBase _       Guanine  = Cytosine
complementBase _       Thymine  = Adenine
complementBase _       Uracile  = Adenine
```

This is again an example of a dependent *function* type (also called a [*pi type*](https://en.wikipedia.org/wiki/Dependent_type#%CE%A0_type)): The input and output types both *depend* on the *value* of the first argument. We can now use this to calculate the complement of any nucleic acid:

```idris
complement : (b : BaseType) -> NucleicAcid b -> NucleicAcid b
complement b = map (complementBase b)
```

Now, here is an interesting use case: We'd like to read a sequence of nucleobases from user input, accepting two strings: The first telling us, whether the user plans to enter a DNA or RNA sequence, the second being the sequence itself. What should be the type of such a function? Well, we're describing computations with side effects, so something involving `IO` seems about right. User input almost always needs to be validated or translated, so something might go wrong and we need an error type for this case. Finally, our users can decide whether they want to enter a strand of RNA or DNA, so this distinction should be encoded as well.

Of course, it is always possible to write a custom sum type for such a use case:

```idris
data Result : Type where
  UnknownBaseType : String -> Result
  InvalidSequence : String -> Result
  GotDNA          : DNA -> Result
  GotRNA          : RNA -> Result
```

This has all possible outcomes encoded in a single data type. However, it is lacking in terms of flexibility. If we want to handle errors early on and just extract a strand of RNA or DNA, we need yet another data type:

```idris
data RNAOrDNA = ItsRNA RNA | ItsDNA DNA
```

This might be the way to go, but for results with many options, this can get cumbersome quickly. Also: Why come up with a custom data type when we already have the tools to deal with this at our hands?

Here is how we can encode this with a dependent pair:

```idris
namespace InputError
  public export
  data InputError : Type where
    UnknownBaseType : String -> InputError
    InvalidSequence : String -> InputError

readAcid : (b : BaseType) -> String -> Either InputError (NucleicAcid b)
readAcid b str =
  let err = InvalidSequence str
   in case b of
        DNABase => maybeToEither err $ readDNA str
        RNABase => maybeToEither err $ readRNA str

getNucleicAcid : IO (Either InputError (b ** NucleicAcid b))
getNucleicAcid = do
  baseString <- getLine
  case baseString of
    "DNA" => map (MkDPair _) . readAcid DNABase <$> getLine
    "RNA" => map (MkDPair _) . readAcid RNABase <$> getLine
    _     => pure $ Left (UnknownBaseType baseString)
```

Note, how we paired the type of nucleobases with the nucleic acid sequence. Assume now we implement a function for transcribing a strand of DNA to RNA, and we'd like to convert a sequence of nucleobases from user input to the corresponding RNA sequence. Here's how to do this:

```idris
transcribeBase : Nucleobase DNABase -> Nucleobase RNABase
transcribeBase Adenine  = Uracile
transcribeBase Cytosine = Guanine
transcribeBase Guanine  = Cytosine
transcribeBase Thymine  = Adenine

transcribe : DNA -> RNA
transcribe = map transcribeBase

printRNA : RNA -> IO ()
printRNA = putStrLn . encode

transcribeProg : IO ()
transcribeProg = do
  Right (b ** seq) <- getNucleicAcid
    | Left (InvalidSequence str) => putStrLn $ "Invalid sequence: " ++ str
    | Left (UnknownBaseType str) => putStrLn $ "Unknown base type: " ++ str
  case b of
    DNABase => printRNA $ transcribe seq
    RNABase => printRNA seq
```

By pattern matching on the first value of the dependent pair we could determine, whether the second value is an RNA or DNA sequence. In the first case, we had to transcribe the sequence first, in the second case, we could invoke `printRNA` directly.

In a more interesting scenario, we would *translate* the RNA sequence to the corresponding protein sequence. Still, this example shows how to deal with a simplified real world scenario: Data may be encoded differently and coming from different sources. By using precise types, we are forced to first convert values to the correct format. Failing to do so leads to a compile time exception instead of an error at runtime or - even worse - the program silently running a bogus computation.

## Dependent Records vs Sum Types

Dependent records as shown for `AnyVect a` are a generalization of dependent pairs: We can have an arbitrary number of fields and use the values stored therein to calculate the types of other values. For very simple cases like the example with nucleobases, it doesn't matter too much, whether we use a `DPair`, a custom dependent record, or even a sum type. In fact, the three encodings are equally expressive:

```idris
Acid1 : Type
Acid1 = (b ** NucleicAcid b)

record Acid2 where
  constructor MkAcid2
  baseType : BaseType
  sequence : NucleicAcid baseType

data Acid3 : Type where
  SomeRNA : RNA -> Acid3
  SomeDNA : DNA -> Acid3
```

It is trivial to write lossless conversions between these encodings, and with each encoding we can decide with a simple pattern match, whether we currently have a sequence of RNA or DNA. However, dependent types can depend on more than one value, as we will see in the exercises. In such cases, sum types and dependent pairs quickly become unwieldy, and you should go for an encoding as a dependent record.

<!-- vi: filetype=idris2:syntax=markdown
-->

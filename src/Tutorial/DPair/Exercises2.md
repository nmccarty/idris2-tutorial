# Exercises part 2

Sharpen your skills in using dependent pairs and dependent records! In exercises 2 to 7 you have to decide yourself, when a function should return a dependent pair or record, when a function requires additional arguments, on which you can pattern match, and what other utility functions might be necessary.

1. Proof that the three encodings for nucleobases are *isomorphic* (meaning: of the same structure) by writing lossless conversion functions from `Acid1` to `Acid2` and back. Likewise for `Acid1` and `Acid3`.

2. Sequences of nucleobases can be encoded in one of two directions: [*Sense* and *antisense*](<https://en.wikipedia.org/wiki/Sense_(molecular_biology)>). Declare a new data type to describe the sense of a sequence of nucleobases, and add this as an additional parameter to type `Nucleobase` and types `DNA` and `RNA`.

3. Refine the types of `complement` and `transcribe`, so that they reflect the changing of *sense*. In case of `transcribe`, a strand of antisense DNA is converted to a strand of sense RNA.

4. Define a dependent record storing the base type and sense together with a sequence of nucleobases.

5. Adjust `readRNA` and `readDNA` in such a way that the *sense* of a sequence is read from the input string. Sense strands are encoded like so: "5´-CGGTAG-3´". Antisense strands are encoded like so: "3´-CGGTAG-5´".

6. Adjust `encode` in such a way that it includes the sense in its output.

7. Enhance `getNucleicAcid` and `transcribeProg` in such a way that the sense and base type are stored together with the sequence, and that `transcribeProg` always prints the *sense* RNA strand (after transcription, if necessary).

8. Enjoy the fruits of your labour and test your program at the REPL.

Note: Instead of using a dependent record, we could again have used a sum type of four constructors to encode the different types of sequences. However, the number of constructors required corresponds to the *product* of the number of values of each type level index. Therefore, this number can grow quickly and sum type encodings can lead to lengthy blocks of pattern matches in these cases.

# Exercises part 3

1. Define a record type for time spans by pairing a `UnitOfTime` with an integer
representing the duration of the time span in the given unit of time. Define
also a function for converting a time span to an `Integer` representing the
duration in seconds.

2. Implement an equality check for time spans: Two time spans should be
considered equal, if and only if they correspond to the same number of seconds.

3. Implement a function for pretty printing time spans: The resulting string
should display the time span in its given unit, plus show the number of seconds
in parentheses, if the unit is not already seconds.

4. Implement a function for adding two time spans. If the two time spans use
different units of time, use the smaller unit of time to ensure a lossless
conversion.

# Mathematical, comparison, and logical operators

`TimeSeries` supports common mathematical (such as `.+`), comparison
(such as `.==`) , and logic (such as `.&`) operators.
The operations are only calculated on values that share a `timestamp`.
All of the operations must be treat as dot-call.

## Mathematical

Mathematical operators create a `TimeArray` object where values are
computed on shared timestamps when two T`imeArray` objects are provided.
Operations between a single `TimeArray` and `Int` or `Float` are also
supported. The number can precede the `TimeArray` object or vice versa
(e.g. `cl .+ 2` or `2 .+ cl`). Broadcasting single-column arrays over
multiple columns to perform operations is also supported.

The exclusion of `/` and `^` from this logic are special cases. In
matrix operations `/` has been confused with being equivalent to the
inverse, and because of the confusion base has excluded it. It is
likewise excluded here. Base uses `^` to indicate matrix
self-multiplication, and so it is not implemented in this context.

| Operator | Description                            |
|----------|----------------------------------------|
| `.+`     | arithmetic element-wise addition       |
| `.-`     | arithmetic element-wise subtraction    |
| `.*`     | arithmetic element-wise multiplication |
| `./`     | arithmetic element-wise division       |
| `.^`     | arithmetic element-wise exponentiation |
| `.%`     | arithmetic element-wise remainder      |

## Comparison

Comparison operators create a `TimeArray` of type `Bool`. Values are
compared on shared timestamps when two `TimeArray` objects are provided.
Broadcasting single-column arrays over multiple columns to perform
comparisons is supported, as are comparisons between a single `TimeArray`
and `Int`, `Float`, or `Bool` values. The semantics of an non-dot
operators (`>`) is unclear, and such operators are not supported.

| Operator | Description                                   |
|----------|-----------------------------------------------|
| `.>`     | element-wise greater-than comparison          |
| `.<`     | element-wise less-than comparison             |
| `.==`    | element-wise equivalent comparison            |
| `.>=`    | element-wise greater-than or equal comparison |
| `.<=`    | element-wise less-than or equal comparison    |
| `.!=`    | element-wise not-equivalent comparison        |

## Logic

Logical operators are defined for `TimeArrays` of type `Bool` and return a
`TimeArray` of type `Bool`. Values are computed on shared timestamps when
two `TimeArray` objects are provided. Operations between a single
`TimeArray` and `Bool` are also supported.

| Operator   | Description              |
|------------|--------------------------|
| `.&`       | element-wise logical AND |
| `.\|`      | element-wise logical OR  |
| `.!`, `.~` | element-wise logical NOT |
| `.⊻`       | element-wise logical XOR |

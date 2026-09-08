# `bin.luau`

`bin.luau` builds numbers from raw bits. It uses the `buffer` library. The
module does not use Luau type annotations.

## Use

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bin = require(ReplicatedStorage.essence.bin.bin)

local one = Bin.fromWords(0x00000000, 0x3FF00000) --> 1
```

## Functions

| Function | Description |
|---|---|
| `Bin.fromWords(lo, hi)` | Returns the IEEE-754 double that has `hi` as its high 32 bits and `lo` as its low 32 bits. |

### `Bin.fromWords(lo, hi)`

The function writes `lo` at byte 0 and `hi` at byte 4 of an 8-byte buffer, then
reads the buffer as one double. The `buffer` library always uses little-endian
byte order, so `hi` holds the sign bit, the exponent, and the top 20 bits of the
mantissa. `lo` holds the low 32 bits of the mantissa.

The low word comes first because that is the order of the bytes in memory.

| `hi` | `lo` | Result |
|---|---|---|
| `0x3FF00000` | `0x00000000` | `1` |
| `0x40000000` | `0x00000000` | `2` |
| `0x7FF00000` | `0x00000000` | `inf` |
| `0x00000000` | `0x00000001` | `5e-324`, the smallest subnormal value |

Give both arguments as integers in the range from `0` through `0xFFFFFFFF`.
`buffer.writeu32` does not report an error for other values. It truncates a
fractional value toward zero, and it keeps only the low 32 bits of the result.
`Bin.fromWords(-1, 0)` is the same as `Bin.fromWords(0xFFFFFFFF, 0)`.

The module has no function for the opposite direction yet. To read the words of
a double, use `buffer.writef64` and `buffer.readu32` directly.

## Test

The module has no test file yet.

# `math.luau`

`math.luau` provides scalar math functions and `Vector3` operations. The module
does not use Luau type annotations.

## Use

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Math = require(ReplicatedStorage.essence.math.math)

local root = Math.sqrt(9)
local direction = Math.Vector.normalize(Vector3.new(3, 0, 4))
```

All trigonometric functions use radians.

## Constants

| Name | Value | Description |
|---|---:|---|
| `Math.Pi` | `3.141592653589793` | The ratio of a circle's circumference to its diameter. |
| `Math.Tau` | `6.283185307179586` | One full turn in radians. This value equals `2π`. |
| `Math.HalfPi` | `1.5707963267948966` | One quarter-turn in radians. This value equals `π/2`. |
| `Math.QuarterPi` | `0.7853981633974483` | One eighth-turn in radians. This value equals `π/4`. |
| `Math.InverseTau` | `0.15915494309189535` | The reciprocal of `τ`. |
| `Math.PiLo` | `1.2246467991473532e-16` | The part of `π` that `Math.Pi` cannot hold. `Math.atan2` uses it to keep accuracy near the negative `x` axis. |
| `Math.Inf` | `inf` | Positive infinity. |
| `Math.NaN` | `nan` | A value that is not equal to itself. Use `Math.isNan` to test for it. |
| `Math.Sqrt2` | `1.4142135623730951` | The square root of `2`. `Math.log` uses it to center the mantissa. |

## Scalar functions

| Function | Description |
|---|---|
| `Math.max(a, b)` | Returns the larger value. Returns `a` when the values are equal. |
| `Math.min(a, b)` | Returns the smaller value. Returns `a` when the values are equal. |
| `Math.clamp(n, a, b)` | Limits `n` to the inclusive range from `a` through `b`. The function reports an error when `a > b`. |
| `Math.abs(n)` | Returns the absolute value of `n`. |
| `Math.isNan(n)` | Returns `true` only when `n` is NaN. |
| `Math.isInf(n)` | Returns `true` only when `n` is `inf` or `-inf`. |
| `Math.pow(x, n)` | Returns `x ^ n`. It supports negative and fractional exponents. |
| `Math.factorial(n)` | Returns `n!`. The input must be a non-negative integer. |
| `Math.sum(a, b, f)` | Returns the sum of `f(i)` for `i` from `a` through `b`, with unit steps. An empty range returns `0`. |
| `Math.product(a, b, f)` | Returns the product of `f(i)` for `i` from `a` through `b`, with unit steps. An empty range returns `1`. |
| `Math.floor(n)` | Returns the largest integer that is not greater than `n`. It preserves positive and negative infinity. |
| `Math.sign(n)` | Returns `-1`, `0`, or `1` for a negative, zero, or positive input. It returns NaN for NaN. |
| `Math.lerp(a, b, t)` | Returns `a + t(b - a)`. The function does not limit `t` to the range from `0` through `1`. A value outside that range extrapolates. |
| `Math.frexp(n)` | Splits `n` into a mantissa `m` and an exponent `e`, where `n = m × 2ᵉ` and `0.5 ≤ |m| < 1`. It returns the two values in that order. See the limits below. |

`Math.frexp` gives the same result as the C function of the same name. Zero,
NaN, and `±inf` return the input and an exponent of `0`. Normal and subnormal
values return an exact mantissa and exponent. The tests compare it against
`math.frexp` for each of these groups.

### Numerical functions

`Math.integrate(f, a, b, n)` uses the midpoint rule with `n` equal-width
samples. The sample count must be a positive integer. If `f` is twice
differentiable, the absolute error has this upper limit:

```text
|b-a|³ max|f''(x)| / (24n²)
```

`Math.derive(f, n)` uses a central difference. It uses
`h = 6×10⁻⁶ max(|n|, 1)`. If `f` is three times differentiable, the truncation
error has this upper limit on `[n-h, n+h]`:

```text
h² max|f'''(x)| / 6
```

Floating-point roundoff is not part of this limit.

`Math.sqrt(n)` supports every non-negative IEEE-754 double, including
subnormal values and positive infinity. It returns NaN for a negative input.
The maximum relative error is `2×10⁻¹⁵` for a positive, finite input.

`Math.sqrt` splits the input with `Math.frexp` and makes the exponent even. It
then refines a quadratic estimate of `1/√m` with Newton's method.
`calculate-constants.py` calculates the three coefficients of that estimate.

### Logarithms

| Function | Description |
|---|---|
| `Math.log(n)` | Returns the natural logarithm of `n`. The maximum relative error is `3×10⁻¹⁶` for a positive, finite input. |
| `Math.log1p(n)` | Returns `ln(1 + n)`. The maximum relative error is `3×10⁻¹⁶` for `n > -1`. |

`Math.log` returns `-inf` for `0`, and NaN for a negative input. It follows
fdlibm `e_log.c`.

Use `Math.log1p(n)` and not `Math.log(1 + n)` for a small `n`. The addition
`1 + n` rounds away the low bits of `n`. The logarithm cannot put them back.
`Math.log1p(1e-17)` is `1e-17`, but
`Math.log(1 + 1e-17)` is `0`.

### Hyperbolic functions

`Math.atanh(n)` returns the inverse hyperbolic tangent of `n`:

```text
artanh(n) = ½ln((1+n)/(1-n))
```

The maximum relative error is `3×10⁻¹⁶` for `|n| < 1`. The function returns
`±inf` for `n = ±1`, and NaN for `|n| > 1`. It calls `Math.log1p`, because the
direct quotient loses the low bits of a small `n`.

### Trigonometric functions

| Function | Description |
|---|---|
| `Math.sin(n)` | Returns the sine of `n`. For `|n| ≤ π`, the maximum absolute error is `1.1×10⁻¹¹`. |
| `Math.cos(n)` | Returns the cosine of `n`. For `|n| ≤ π`, the maximum absolute error is `1.1×10⁻¹¹`. |
| `Math.tan(n)` | Returns `sin(n) / cos(n)`. The error has no finite uniform limit near a pole. |
| `Math.csc(n)` | Returns `1 / sin(n)`. The error has no finite uniform limit near a pole. |
| `Math.cot(n)` | Returns `1 / tan(n)`. The error has no finite uniform limit near a pole. |
| `Math.atan(n)` | Returns the arctangent of `n`. The maximum absolute error is `3×10⁻¹⁶` radians for a finite IEEE-754 double. |
| `Math.atan2(y, x)` | Returns the angle of the point `(x, y)` from the positive `x` axis. See the table of special cases below. |

Range reduction in `sin` and `cos` causes more floating-point error as the
input magnitude increases.

#### `Math.atan2(y, x)`

The result is in the range from `-π` through `π`. The signs of both arguments
select the quadrant, so `Math.atan2` gives the correct angle where
`Math.atan(y / x)` cannot. The `y` argument comes first, as it does in C.

```luau
local angle = Math.atan2(1, -1) --> 2.356..., which is 3π/4
```

`Math.atan2` handles these special cases:

| Case | Result |
|---|---|
| `x` or `y` is NaN | NaN |
| `y = 0`, `x > 0` | `y`, which keeps the sign of the zero |
| `y = 0`, `x < 0` | `π`. C returns `-π` for a negative zero. This module returns `π` for both signs of zero. |
| `x = 0`, `y ≠ 0` | `π/2` for `y > 0`, `-π/2` for `y < 0` |
| both arguments infinite | `±π/4` or `±3π/4`, by quadrant |
| `x` infinite, `y` finite | `0` or `±π`, by the sign of `x` and `y` |
| `y` infinite, `x` finite | `±π/2`, by the sign of `y` |

The implementation follows fdlibm `e_atan2.c`. It calls `Math.atan` for the
general case, so it has the error bound of `Math.atan` plus the error of the
division `y / x`.

## Vector functions

The `Math.Vector` table operates on Roblox `Vector3` values.

| Function | Description |
|---|---|
| `Math.Vector.add(a, b)` | Returns `a + b`. |
| `Math.Vector.subtract(a, b)` | Returns `a - b`. |
| `Math.Vector.sMult(s, v)` | Multiplies vector `v` by scalar `s`. The scalar is the first argument. |
| `Math.Vector.sDiv(s, v)` | Divides vector `v` by scalar `s`. The scalar is the first argument. |
| `Math.Vector.dot(a, b)` | Returns the dot product of `a` and `b`. |
| `Math.Vector.magnitude(v)` | Returns the magnitude of `v`. |
| `Math.Vector.sqmagnitude(v)` | Returns the square of the magnitude of `v`. Use it to compare lengths, because it does not call `Math.sqrt`. |
| `Math.Vector.normalize(v)` | Returns a unit vector in the direction of `v`. The function reports an error for the zero vector. |
| `Math.Vector.project(v, n)` | Projects `v` onto `n`. The function reports an error when `n` is the zero vector. |
| `Math.Vector.reject(v, n)` | Removes the component of `v` that is parallel to `n`. The function reports an error when `n` is the zero vector. |

`Math.cross(a, b)` returns the cross product as a `Vector3`. It is on the `Math`
table, and not on the `Math.Vector` table:

```luau
local n = Math.cross(Vector3.xAxis, Vector3.yAxis) --> 0, 0, 1
```

`Math.cross` calls `Vector3.new`. It is the only function in the module that
builds a Roblox value, so it is the only function that Lune cannot run. The
other functions read the `X`, `Y`, and `Z` fields, which lets the tests use a
plain table.

The module reserves `Math.Matrix` for matrix operations. It does not contain
functions in this version.

## Test

Run the math tests from the repository root:

```sh
lune run tests/math.luau
```

## Benchmark

`benchmarks/` holds [Benchmarkr](https://github.com/jerr3n/benchmarkr) suites
for this module. They compare each function against the Luau builtin that does
the same work. `benchmarks/README.md` tells you how to run them.

## Styleguide

### Functions
Use this shape for most functions:

```luau
--[[
$f(n)=r$                                              - part a
f(n)=r                                                - part b
Some function                                         - part c
https://en.wikipedia.org/wiki/Wikipedia:Example       - part d
]]
function Math.example(n)
    -- ...
    return r
end
```

Part A is LaTeX. It renders as inline math in documentation and in editor hovers.

Part B is the same expression in Unicode. It is readable as-is in a plain editor.

Part C is an **optional** prose comment.

Part D is a reference link. See the rules below.

Omit A and B when the function has no conventional notation.

- Use `r` for the result. Name a single argument `n`. Write constants in
  PascalCase (`Math.HalfPi`). Write functions in lowercase (`Math.sin`).
- If a function is approximate, part C must state its error bound and its valid
  domain.
- If you implement an obscure method, link a reference in part D. Use Wikipedia
  where a suitable article exists. Otherwise use whatever actually explains the
  method. See `Math.sin`.
- Do not comment what the code already says. Do comment why you made a
  non-obvious choice. For example: where a magic constant comes from, why you
  chose one formulation over an equivalent-looking one, or which numerical
  hazard you avoid.

Keep the aligned `- part x` labels in the example. They make the four slots easy
to see at a glance. That is the point of a template.

### Code

Keep variables to a minimum. Calculate most values at runtime. Use as few static
inline values as you can. A helper program is acceptable, but not preferred.

Do not use typing. Do not add types to your functions. Types are forbidden.

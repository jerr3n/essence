# Benchmarks

These suites measure the math module with
[Benchmarkr](https://github.com/jerr3n/benchmarkr), a Roblox Studio plugin.
Each suite compares an Essence function against the Luau builtin that does the
same work, or against the direct formula that the function replaces.

## Run

Build and install Benchmarkr:

```sh
git clone https://github.com/jerr3n/benchmarkr
cd benchmarkr
rokit install
mkdir -p build
rojo build -o build/Benchmarkr.rbxm
```

Install `build/Benchmarkr.rbxm` as a local plugin from the Plugins folder of
Roblox Studio.

Then, from this repository:

```sh
rojo serve
```

Connect Studio to the server. `default.project.json` maps `benchmarks/` into
`ServerStorage.benchmarks`, and `src/shared` into `ReplicatedStorage`. Open the
**⏱ Benchmarkr** widget, select one suite in Explorer, and click **▶ Run**.

## Suites

| File | Compares | Question it answers |
|---|---|---|
| `sqrt.luau` | `Math.sqrt`, `math.sqrt`, `n ^ 0.5` | What does the Newton refinement cost against one machine instruction? |
| `frexp.luau` | `Math.frexp`, `math.frexp` | `Math.sqrt` and `Math.log` both call it, so how much of their cost is this? |
| `log.luau` | `Math.log`, `math.log` | What does the seven-term polynomial cost after the split? |
| `log1p.luau` | `Math.log1p`, `Math.log(1 + n)`, `math.log(1 + n)` | What does the accuracy of `log1p` cost for a small input? |
| `atanh.luau` | `Math.atanh`, `0.5 * math.log((1 + n) / (1 - n))` | Same question, for the function that has no builtin. |
| `atan.luau` | `Math.atan`, `math.atan`, `Math.atan2`, `math.atan2` | What does Luau cost against native code for one well-formed function? |
| `trig.luau` | `Math.sin`, `math.sin`, `Math.cos`, `math.cos` | What does the Taylor sum cost? It calls `Math.factorial` on every term. |
| `vector.luau` | `Math.Vector` against the `Vector3` properties | Where does the time in `normalize` go, and is `sqmagnitude` worth it? |

## How the suites work

Every suite has the same shape:

- `BeforeAll` fills one input array with `Random.new(20260912)`. The seed is
  fixed, so two runs measure the same numbers.
- `ParameterGenerator` returns that array. It allocates nothing, because
  Benchmarkr calls it before every case.
- Each case loops over all inputs and adds the results together. One call to a
  function of this kind is below the resolution of the timer, and the sum stops
  the compiler from removing the work.
- Every case in a suite reads the same array, so the comparison is fair.

The inputs cover the full exponent range of a double where the cost of a
function changes with the exponent, and they cross each argument reduction
threshold where a function has them.

`vector.luau` puts the two halves of `Vector.normalize` in profiler scopes. The
scopes are two separate loops, and not one loop with two scopes, because a pair
of profiler calls for every vector would cost more than the work it measures.

## Read the results

Compare P50 first. P10 and P90 show whether a case is stable. Benchmarkr reports
the time it observes and subtracts nothing, so the loop and the profiler are
part of every number. Compare cases against each other, and not against a
different machine.

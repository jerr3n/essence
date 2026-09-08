# libEssence

> This project is licensed under Apache-2.0, chosen because Roblox's Terms of Use (Creator Terms § 2(b)(iv)) require creators to be authorized to sublicense all parts of published content, which copyleft licenses do not permit. If those terms change, future versions may be released under a copyleft license. Existing releases remain under Apache-2.0.

A stdlib for roblox.

Essence gives you scalar math, `Vector3` math, and bit-level number tools. The
library uses plain Luau. It has no dependencies, and it uses no type
annotations. See [CONTRIBUTING.md](CONTRIBUTING.md) for the reason.

## Modules

| Module | Path | Description |
|---|---|---|
| `math` | `src/shared/essence/math/math.luau` | Constants, scalar functions, numerical methods, trigonometry, and `Vector3` operations. See the [module README](src/shared/essence/math/README.md). |
| `bin` | `src/shared/essence/bin/bin.luau` | Builds an IEEE-754 double from two 32-bit words. See the [module README](src/shared/essence/bin/README.md). |

`src/shared/essence/main.luau` is an empty placeholder. It does not export
anything yet.

## Install

### With Wally

Add Essence to the `[dependencies]` section of your `wally.toml`:

```toml
[dependencies]
Essence = "jerr3n/essence@0.0.3"
```

Then run `wally install`.

### Without Wally

Copy the `src/shared/essence` folder into your own source tree. The modules
require each other by relative path, so keep the folder structure.

## Use

`default.project.json` maps `src/shared` into `ReplicatedStorage`. With that
map, a script gets a module like this:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Math = require(ReplicatedStorage.essence.math.math)

local root = Math.sqrt(9)
local direction = Math.Vector.normalize(Vector3.new(3, 0, 4))
```

Each module README shows the functions of that module.

## Repository layout

```text
src/shared/essence/     library source
    main.luau           placeholder
    bin/bin.luau        bit-level number tools
    math/math.luau      math module
tests/                  test scripts, one file per module
default.project.json    Rojo project file
wally.toml              Wally package file
```

## Build

Build a place file with [Rojo](https://rojo.space):

```sh
rojo build -o essence.rbxlx
```

Or start a live-sync server for Roblox Studio:

```sh
rojo serve
```

## Test

The tests run under [Lune](https://lune-org.github.io/docs). They use plain
`assert` calls, and no test framework. Run them from the repository root:

```sh
lune run tests/math.luau
```

Each test file prints one line when every assertion passes.

## Contribute

Read [CONTRIBUTING.md](CONTRIBUTING.md) first. The two rules that surprise most
new contributors:

1. Do not add type annotations.
2. Write documentation in [ASD-STE100](https://www.asd-ste100.org) English.

The math module has its own styleguide for comments and code. It is at the end
of the [math README](src/shared/essence/math/README.md).

## License

Apache-2.0. See the note at the top of this file.

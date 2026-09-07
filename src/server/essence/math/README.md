# `math.luau`

## Styleguide

Functions should usually have this shape:

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

Part A is LaTeX, it renders as inline math in documentation and editor hovers.

Part B is the same expression in Unicode, readable as-is in a plain editor.

Part C is an **optional** prose comment.

Part D is a reference link, see below.

Omit A and B when the function has no conventional notation.

- `r` denotes the result. A single argument is named `n`. Constants are
  PascalCase (`Math.HalfPi`); functions are lowercase (`Math.sin`).
- If a function is approximate, part C must state its error bound and valid
  domain.
- If you implement an obscure method, link a reference in part D — Wikipedia
  where a suitable article exists, otherwise whatever actually explains it.
  See `Math.sin`.
- Don't comment what the code already says. Do comment why a non-obvious
  choice was made: a magic constant's origin, why one formulation was picked
  over an equivalent-looking one, a numerical hazard being avoided.

The aligned `- part x` labels in the example are worth keeping — they make the four slots visually obvious at a glance, which is the whole point of a template.
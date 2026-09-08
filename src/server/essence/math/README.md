# `math.luau`

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

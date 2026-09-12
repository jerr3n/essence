import math

e = 0
for i in range(18):
    e += 1/math.factorial(i)

print(f"euler's number - {e}")

def atan(x, terms):
    result = 0

    for k in range(terms):
        result += ((-1) ** k * x ** (2 * k + 1)) / (2 * k + 1)

    return result

pi = 4 * (
    4 * atan(1 / 5, 20)
    - atan(1 / 239, 20)
)
print(pi)

# The seed of Math.sqrt. It is the quadratic polynomial with the smallest
# maximum relative error against 1/sqrt(m) on [0.5, 2), which is the range of
# the mantissa after Math.sqrt makes the exponent even. The Remez exchange
# algorithm finds it: solve for the polynomial that makes the error alternate
# between +E and -E at four points, then move the points to the extrema of the
# new error curve, and repeat.


def solve(matrix, rhs):
    n = len(rhs)
    a = [row[:] + [rhs[i]] for i, row in enumerate(matrix)]

    for i in range(n):
        pivot = max(range(i, n), key=lambda r: abs(a[r][i]))
        a[i], a[pivot] = a[pivot], a[i]

        for r in range(n):
            if r != i:
                factor = a[r][i] / a[i][i]
                for c in range(i, n + 1):
                    a[r][c] -= factor * a[i][c]

    return [a[i][n] / a[i][i] for i in range(n)]


def remez(f, lo, hi, samples=200000, passes=40):
    points = [lo + (hi - lo) * i / 3 for i in range(4)]

    for _ in range(passes):
        matrix = []
        rhs = []

        for i, x in enumerate(points):
            # p(x) - f(x) = (-1)^i * E * f(x) makes the error relative.
            matrix.append([1, x, x * x, -(-1) ** i * f(x)])
            rhs.append(f(x))

        c = solve(matrix, rhs)[:3]

        def error(x):
            return (c[0] + x * (c[1] + x * c[2]) - f(x)) / f(x)

        # The endpoints are always extrema. The others are the points where the
        # error curve turns.
        grid = [lo + (hi - lo) * i / samples for i in range(samples + 1)]
        errors = [error(x) for x in grid]
        found = [lo]

        for i in range(1, samples):
            low = errors[i] <= errors[i - 1] and errors[i] <= errors[i + 1]
            high = errors[i] >= errors[i - 1] and errors[i] >= errors[i + 1]
            if low or high:
                found.append(grid[i])

        found.append(hi)

        if len(found) != 4:
            break

        points = found

    return c, max(abs(e) for e in errors)


seed, error = remez(lambda m: 1 / math.sqrt(m), 0.5, 2.0)
print(f"1/sqrt seed - {seed}")
print(f"1/sqrt seed maximum relative error - {error}")

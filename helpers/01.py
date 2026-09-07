from decimal import Decimal, getcontext

N = 13
getcontext().prec = 60
PI = Decimal("3.14159265358979323846264338327950288419716939937510582097494")
TAU = 2 * PI

c, v = [], TAU
c.append(v)
for k in range(N - 1):
    v = -v * TAU * TAU / ((2*k + 2) * (2*k + 3))
    c.append(v)

for x in c:
    print(f"\t{float(x):.17g},")s
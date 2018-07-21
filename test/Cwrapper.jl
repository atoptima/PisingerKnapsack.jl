const PKCI = PisingerKnapsackCInterface

profits = [1, 2, 3, 4, 5, 6]
double_profits = [1.5, 2.5, 3.5, 4.5, 5.5, 6.5]
weights = [5, 5, 5, 5, 5, 5]
capacity = 15

(z, s) = PKCI.minknap(profits, weights, capacity)
@show z
@show s

# (z, s) = PKCI.doubleminknap(double_profits, weights, capacity)
# @show z
# @show s

ubitems = [1, 1, 1, 1, 1, 2]

(z, s) = PKCI.bouknap(profits, weights, ubitems, capacity)
@show z
@show s

# (z, s) = PKCI.doublebouknap(double_profits, weights, ubitems, capacity)
# @show z
# @show s

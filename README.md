
# PisingerKnapsack

Please note that **Pisinger's algorithms may be used for academic, non-commercial purposes only.**

This package provides a Julia interface to some [Pisinger's algorithms](http://hjemmesider.diku.dk/~pisinger/codes.html){:target="_blank"}.

## Installation

This package is not registered in the Julia Package Manager.


## Algorithms

- [Minknap algorithm](http://hjemmesider.diku.dk/~pisinger/minknap.c){:target="_blank"}

```julia
    minknap(costs::Vector{Real}, weights::Vector{Real}, capacity::Real)
```

- [Bouknap algorithm](http://hjemmesider.diku.dk/~pisinger/bouknap.c){:target="_blank"}

```julia
    bouknap(costs::Vector, weights::Vector, itemub::Vector, capacity::Real)
```
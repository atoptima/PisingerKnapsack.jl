#include <math.h>
#include <limits.h>
#include <stdio.h>
#include "minknap.h"

int rfloor(double a) {
    int r = floor(a + a * 1e-10 + 1e-6);
    if (r < a - 1 + 1e-6) {
        r += 1;
    }
    return r;
}

double doubleminknap(int n, double *p, int *w, int *x, int c) {
    double maxReducedCost = INT_MIN;
    int item;
    for (item = 0; item < n; item++) {
        if (maxReducedCost < p[item]) {
            maxReducedCost = p[item];
        }
    }
    int scaledProfit[n];
    double scalingFactor = INT_MAX / (n + 1) / maxReducedCost;
    for (item = 0; item < n; item++) {
        scaledProfit[item] = rfloor(scalingFactor * p[item]);
    }
    return minknap(n, scaledProfit, w, x, c) / scalingFactor;
}

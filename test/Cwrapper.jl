@testset "C wrapper" begin
    profits = [1, 2, 3, 4, 5, 6]
    weights = [5, 5, 5, 5, 5, 5]
    capacity = 15

    (z, s) = minknap(profits, weights, capacity)
    @test z == 15
    @test s == [0, 0, 0, 1, 1, 1]

    double_profits = [1.5, 2.5, 3.5, 4.5, 5.5, 6.5]

    (z, s) = minknap(double_profits, weights, capacity)
    @test z == 16.5
    @test s == [0, 0, 0, 1, 1, 1]

    ubitems = [1, 1, 1, 1, 1, 2]

    (z, s) = bouknap(profits, weights, ubitems, capacity)
    @test z == 17
    @test s == [0, 0, 0, 0, 1, 2]

    capacities = [5, 15]

    (z, s) = mulknap(profits, weights, capacities)
    @test z == 18
    @test s == [0, 0, 2, 2, 2, 1]
end

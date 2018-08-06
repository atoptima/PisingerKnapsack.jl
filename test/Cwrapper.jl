@testset "C wrapper" begin
    profits = Int[1, 2, 3, 4, 5, 6]
    weights = Int[5, 5, 5, 5, 5, 5]
    capacity = 15

    (z, s) = PKCI.minknap(profits, weights, capacity)
    @test z == 15
    @test s == Int32[0, 0, 0, 1, 1, 1]

    double_profits = [1.5, 2.5, 3.5, 4.5, 5.5, 6.5]

    (z, s) = PK.doubleminknap(double_profits, weights, capacity)
    @test z == 16.5
    @test s == Int32[0, 0, 0, 1, 1, 1]

    ubitems = Vector{Int}([1, 1, 1, 1, 1, 2])

    (z, s) = PKCI.bouknap(profits, weights, ubitems, capacity)
    @test z == 17
    @test s == Int32[0, 0, 0, 0, 1, 2]
end

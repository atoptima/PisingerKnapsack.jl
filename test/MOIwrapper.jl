@testset "MOI wrapper" begin
	c = [1, 2, 3]
	w = [3.0, 5.0, 10.0]
	C = 7.0

	numvariables = length(c)

	optimizer = PisingerKnapsack.PisingerKnapsackOptimizer()

	# create the variables in the problem
	x = MOI.addvariables!(optimizer, numvariables)

	# set the objective function
	objective_function = MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(c, x), 0)
	MOI.set!(optimizer, MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Int64}}(), objective_function)
	MOI.set!(optimizer, MOI.ObjectiveSense(), MOI.MaxSense)

	# add the knapsack constraint
	knapsack_function = MOI.ScalarAffineFunction(MOI.ScalarAffineTerm.(w, x), 0.0)
	MOI.addconstraint!(optimizer, knapsack_function, MOI.LessThan(C))

	# add integrality constraints
	for i in 1:numvariables
	    MOI.addconstraint!(optimizer, MOI.SingleVariable(x[i]), MOI.ZeroOne())
	end

	MOI.optimize!(optimizer)

	termination_status = MOI.get(optimizer, MOI.TerminationStatus())
	objvalue = MOI.canget(optimizer, MOI.ObjectiveValue()) ? MOI.get(optimizer, MOI.ObjectiveValue()) : NaN
	if termination_status != MOI.Success
	     error("Solver terminated with status $termination_status")
	end

	@assert MOI.get(optimizer, MOI.ResultCount()) > 0

	result_status = MOI.get(optimizer, MOI.PrimalStatus())
	if result_status != MOI.FeasiblePoint
	    error("Solver ran successfully did not return a feasible point. The problem may be infeasible.")
	end
	primal_variable_result = MOI.get(optimizer, MOI.VariablePrimal(), x)

	@test termination_status == MOI.Success
	@test objvalue == 2
	@test primal_variable_result == [0.0, 1.0, 0.0]
end
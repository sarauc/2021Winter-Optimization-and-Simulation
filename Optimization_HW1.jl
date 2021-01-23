# HW1
# A.
using PyPlot
clf()

x1 = collect(0:0.1:2)
x2a = 1 .- 0.5 .*x1
x2b = ifelse.(2 .-2 .*x1 .>=0, 2 .-2 .*x1, NaN)
fig = figure()
ax = fig.add_subplot(1,1,1)
ax.fill_between(x1, x2a, color="red", label=L"x_{2} \leq 1 - \frac{1}{2}x_{1}",alpha=0.6)
ax.fill_between(x1, x2b, where=x2b .>=0, color="blue", label=L"x_{2} \leq 2 - 2x_{1}", alpha=0.4)
ax.legend(loc="upper right")
ax.set_xlabel(L"x_{1}")
ax.set_ylabel(L"x_{2}")
ax.grid(true)
ax.axis("scaled")

println("a guess solution: x1 = 1, x2 = 0 \n
because it is very likely that a corner solution will generate the max utility\n
and between the 2 corners, (1,0) has higher utility.")

# B: solve the problem with inequalities
using JuMP, GLPK
myModel = Model(with_optimizer(GLPK.Optimizer))
@variable(myModel, x1>=0)
@variable(myModel, x2>=0)
@constraint(myModel, 0.5*x1+x2<=1)
@constraint(myModel, 2*x1+x2<=2)
@objective(myModel, Max, x1+0.25*x2)

print(myModel)

optimize!(myModel)
println("Objective value: ", JuMP.objective_value(myModel))
println("x1: ", JuMP.value(x1))
println("x2: ", JuMP.value(x2))

# C: standard form
using JuMP, GLPK
myModel2 = Model(with_optimizer(GLPK.Optimizer))
@variable(myModel2, x1>=0)
@variable(myModel2, x2>=0)
@variable(myModel2, s1>=0)
@variable(myModel2, s2>=0)
@constraint(myModel2, 0.5*x1+x2+s1+0*s2==1)
@constraint(myModel2, 2*x1+x2+0*s1+s2==2)
@objective(myModel2, Max, x1+0.25*x2+0*s1+0*s2)

print(myModel2)

# D: solve the above problem in the standard form
optimize!(myModel2)
println("Objective value: ", JuMP.objective_value(myModel2))
println("x1: ", JuMP.value(x1))
println("x2: ", JuMP.value(x2))

# E: Compare
println("")
println("The result for B and D are the same.")

# F: objective function changed to x1+x2
myModelNew = Model(with_optimizer(GLPK.Optimizer))
@variable(myModelNew, x1>=0)
@variable(myModelNew, x2>=0)
@constraint(myModelNew, 0.5*x1+x2<=1)
@constraint(myModelNew, 2*x1+x2<=2)
@objective(myModelNew, Max, x1+x2)

println("-----First method-----")
print(myModelNew)

optimize!(myModelNew)

println("Objective value: ", JuMP.objective_value(myModelNew))
println("x1: ", JuMP.value(x1))
println("x2: ", JuMP.value(x2))

myModel2New = Model(with_optimizer(GLPK.Optimizer))
@variable(myModel2New, x1>=0)
@variable(myModel2New, x2>=0)
@variable(myModel2New, s1>=0)
@variable(myModel2New, s2>=0)
@constraint(myModel2New, 0.5*x1+x2+s1+0*s2==1)
@constraint(myModel2New, 2*x1+x2+0*s1+s2==2)
@objective(myModel2New, Max, x1+x2+0*s1+0*s2)

println("-----Standard Form-----")
print(myModel2New)

# D: solve the above problem in the standard form
optimize!(myModel2New)

println("Objective value: ", JuMP.objective_value(myModel2New))
println("x1: ", JuMP.value(x1))
println("x2: ", JuMP.value(x2))






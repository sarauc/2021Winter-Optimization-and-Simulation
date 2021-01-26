# Question 1
# A and B
using JuMP, GLPK, LinearAlgebra
c = [0; 1]
A = [-1 1;
     -0.5 1;
     1 1;
     0.5 1]
b = [1;2;9;6]
m,n = size(A)
x1_b = [0;0]

m1 = Model(with_optimizer(GLPK.Optimizer))
@variable(m1, x[j=1:n] >= x1_b[j])
for i=1:m
    @constraint(m1, sum(A[i,j]*x[j] for j=1:n) <=b[i])
end
@objective(m1, Max, x[2])
print(m1)

optimize!(m1)
println("The objective value is: ", JuMP.objective_value(m1))
println("The optimal solution:\n", JuMP.value.(x))

# C and D
using PyPlot
clf();

x1 = collect(-4:0.1:12);
x2a = 1 .+x1;
x2b = 2 .+0.5 .*x1
x2c = 9 .-x1
x2d = 6 .-0.5 .*x1
x2e = 4 .+0 .*x1

fig = figure()
ax = fig.add_subplot(1,1,1);
ax.plot(x1,x2a,color="red",linewidth=2,alpha=0.6, label=L"x_{2} \leq 1 + x_{1}")
ax.plot(x1,x2b,color="blue",linewidth=2,alpha=0.4, label=L"x_{2} \leq 2 + \frac{1}{2}x_{1}")
ax.plot(x1,x2c,color="yellow",linewidth=2,alpha=0.4, label=L"x_{2} \leq 9 - x_{1}")
ax.plot(x1,x2d,color="green",linewidth=2,alpha=0.4, label=L"x_{2} \leq 6 - \frac{1}{2}x_{1}")
ax.plot(x1,x2e,color="black",linewidth=4,alpha=0.4, label=L"x_{3} = 4")

ax.legend(loc="upper right");
ax.set_xlabel(L"x_{1}");
ax.set_ylabel(L"x_{2}");
ax.grid(true);
ax.axis("scaled");

# D
println("Among the corner solutions that the four constraint lines intersect, (4,4) is the highest in x2,
\nwhich maximizes objective function of x2")

# Question 2
# A and B

m2 = Model(with_optimizer(GLPK.Optimizer))
@variable(m2, x[j=1:2] >= 0)
@constraint(m2, 2*x[1]+3*x[2] <=9)
@constraint(m2, x[1] <=3)
@constraint(m2, x[2] <=2)
@objective(m2, Max, 6*x[1]+4*x[2])

print(m2)

optimize!(m2)
println("The objective value is: ", JuMP.objective_value(m2))
println("The optimal solution:\n", JuMP.value.(x))


# C and D
clf();

x1 = collect(0:0.1:4.5);
x2a = 3 .-2/3 .*x1;
x2b = 5.5 .-1.5 .*x1 # objective function at optimum
x2c = 2 .- 0 .*x1
x1d = 3 .- 0 .*x1

fig = figure()
ax = fig.add_subplot(1,1,1);
ax.fill_between(x1,x2a,color="red",linewidth=2,alpha=0.6)
ax.plot(x1,x2b,color="black",linewidth=4,alpha=0.4, label=L"x_{2} = \frac{22}{4} - \frac{6}{4}x_{1}")
ax.plot(x1,x2c, color="blue",linewidth=2,alpha=0.6, label=L"x_{2} \leq 2")
ax.plot(x1d,x1, color="green",linewidth=2,alpha=0.6, label=L"x_{1} \leq 3")

ax.legend(loc="upper right");
ax.set_xlabel(L"x_{1}");
ax.set_ylabel(L"x_{2}");
ax.grid(true);
ax.axis("scaled");

# D
println("Among the 4 corner solutions, (3,1) has the largest objective value while moving away from x1=3 would decrease the value.")

# Question 3

c = [0; 0; 0; 0; -1.005; 0; 0; -1.015; 0; 0; 0; 0; 1.002]
A = [1 0 0 0 0 1 0 0 -1 0 0 0 0;
     -1.005 1 0 0 0 0 1 0 1.002 -1 0 0 0;
     0 -1.005 1 0 0 0 0 1 0 1.002 -1 0 0;
     0 0 -1.005 1 0 -1.015 0 0 0 0 1.002 -1 0;
     0 0 0 -1.005 1 0 -1.015 0 0 0 0 1.002 -1]
b = [250; 50; -225; 175; -150]
m,n = size(A)
x1_b = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0]
x2_b = [100;100;100;100;100]

myModel = Model(with_optimizer(GLPK.Optimizer))
@variable(myModel, x[j=1:n] >=x1_b[j])
for i = 1:m
    @constraint(myModel, sum(A[i, j]*x[j] for j=1:n) == b[i])
end
for j = 1:5
    @constraint(myModel, x[j] <=x2_b[j])
end
@objective(myModel, Max, sum(c[j]*x[j] for j=1:n))
print(myModel)


# Solve the model
using DataFrames, DataFramesMeta
optimize!(myModel)
println("")
println("The objective value is: ", JuMP.objective_value(myModel))
println("The optimal solution is: \n", JuMP.value.(x)) # Why use a dot before (x)?
result = DataFrame(Jul2013="100K", Aug2013="100K", Sep2013="0", Oct2013="100K", Nov2013="1.76K", Dec2013="0")
push!(result, ["150.00K", "50.50K", "102.30K", "0", "0", "0"])

println("--------Final result--------")
println(result)
println("Note: the first row represents the amount of borrowing with monthly credit and the other with 3-month zero-coupon bond.")
println("")
println("The max wealth at the end of 2013 is: ", JuMP.objective_value(myModel)+400, "K")
println("")
println("For the company to achieve balance for each of the 6 months and gain max wealth at the year end, 
\nit will have to borrow 100K of monthly loan and issue 150K 3-month zero-coupon bond in July 2013. 
\nIn Aug 2013, it will borrow another 100K monthly loan and issue 50.50K bond, 
\nand it will earn invested funds from last month, but meanwhile it has to pay out monthly debt from last month.
\nIn Sep 2013, as the company is generating positive net cash flow itself, it only needs to issue 102.3K bonds to payout
\ndebt from last month. In the last three months, no bonds can be issued any more as the payback period exceeds assumed horizon.
\nIn the last month, no loan in any form should be borrowed and the company will earn a end-of-year wealth of 294.4K")



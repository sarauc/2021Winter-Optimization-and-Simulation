# Week 1 Summary: Use Julia to define and solve 
# Plot constraints function
using PyPlot
clf();

x1 = collect(0:0.1:2);
x2a = 1 .- 0.5.*x1;
x2b = ifelse.(2 .- 2 .*x1 .>= 0, 2 .- 2 .*x1, NaN);
fig = figure();
ax = fig.add_subplot(1,1,1);
ax.fill_between(x1,x2a,facecolor="red",color="red",where=x2a .>= 0,linewidth=2,alpha=0.6);
ax.fill_between(x1,x2b,facecolor="blue",color="blue",where=x2b .>= 0,linewidth=2,alpha=0.4);
ax.legend([L"x_{2} \leq 1 - \frac{1}{2}x_{1}",L"x_{2} \leq 2 - 2x_{1}"],loc="upper right");
ax.set_xlabel(L"x_{1}");
ax.set_ylabel(L"x_{2}");
ax.grid(true);
ax.axis("scaled");


using JuMP, GLPK
# define problem
myModel = Model(with_optimizer(GLPK.Optimizer))
@variable(myModel, x1 >= 0) # This is to declare variable, x1 here can take any other name 
@variable(myModel, x2 >= 0)
@constraint(myModel, 0.5*x1+x2<=1)
@constraint(myModel, 2*x1+x2<=2)
@objective(myModel, Max, 0.25*x1+x2)
print(myModel)


# solve problem
optimize!(myModel)
println("Objective value is: ", JuMP.objective_value(myModel)) # must call optimize function before retrieving values
println("x1 = ", JuMP.value(x1))
println("x2 = ", JuMP.value(x2))


# Plot feasible region and the indifference curve with max utility
using PyPlot
clf();

x1 = collect(0:0.1:2);
x2a = 1 .- 0.5*x1;
x2b = ifelse.(2 .- 2*x1 .>=0, 2 .- 2*x1, NaN);
x2c = 1 .- 0.25*x1;

fig, ax = subplots();
ax.fill_between(x1,x2a,color="red",linewidth=2,label=L"x_{2} \leq 1 - \frac{1}{2}x_{1}",alpha=0.3); #declare legend
ax.legend(loc="upper right");
ax.fill_between(x1,x2b,color="blue",linewidth=2,label=L"x_{2} \leq 2 - 2x_{1}",alpha=0.3);
ax.legend(loc="upper right");
ax.plot(x1,x2c,color="black",linewidth=2,label=L"x_{2} = 1 - \frac{1}{4}x_{1}",alpha=1);
ax.legend(loc="upper right");
ax.grid(true);




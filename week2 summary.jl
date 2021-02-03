import Pkg
Pkg.add("DataFrames")
Pkg.add("DataFramesMeta")
Pkg.add("Combinatorics")


using JuMP, GLPK, LinearAlgebra

c = [-1.1; -1; 0; 0; 0] # coefficients of objective function
A = [5/3 1 1 0 0;
     8/7 1 0 1 0;
     3/7 1 0 0 1] # coefficients of constraints function in standard form
b = [5; 4; 3] # RHS of constraints

m,n = size(A) # m is the no of constraints and n is the number of variables
x1_b = [0; 0; 0; 0; 0] # x[j=1:n] >= x1_b[j=1:n]

# set up problem
myModel = Model(with_optimizer(GLPK.Optimizer))
@variable(myModel, x[j=1:n] >=x1_b[j]) # assign j value in x[] (create x_1 to x_n) and use j value in x1_b[].
for i = 1:m   
    @constraint(myModel, sum(A[i,j] *x[j] for j=1:n) == b[i])
end
@objective(myModel, Min, sum(c[j]*x[j] for j=1:n))

print(myModel)

# Question: @variable(myModel, x[j] >=x1_b[j] for j=1:n) does not work?
# @objective(myModel, Min, sum(c[j=1:n]*x[j])) does not work?


# Search Method
using DataFrames, DataFramesMeta, Combinatorics
# Find all basic solutions
combs = collect(combinations(1:n, m)) # all combinations of m variables from n variables
result = DataFrame(comb_1=NaN, comb_2=NaN, comb_3=NaN, x_B_1=NaN, x_B_2=NaN, x_B_3=NaN, z=NaN) # Store results

for i in 1:length(combs)
    comb = combs[i]
    B = A[:, comb]
    c_B = c[comb]
    x_B = inv(B)*b # Find value for each x
# Check feasibility of basic solution: If feasible, calculate utility  
    if minimum(x_B) > 0 
        z = dot(c_B,x_B)
    else
        z = Inf
    end
    
    if i==1
        result[1,:] = [comb[1], comb[2], comb[3], x_B[1], x_B[2], x_B[3], z] # This is to replace the original row of NaN
    else
        push!(result, [comb[1], comb[2], comb[3], x_B[1], x_B[2], x_B[3], z]) # Insert new row to the DF at the end of last row
    end
end
# Sort rows
sort(result, :z)


# Among the 10 basic solutions, there are 5 feasible basic solutions and one optimal feasible basic solution
# The optimal basic solution is when x=[1.4; 2.4; 0.2667; 0; 0] and has utility of -3.94
# My remaining question is why choose m among n at the very beginning?? 

# Simplex Method
using JuMP, GLPK
# Set up model 
newModel = Model(with_optimizer(GLPK.Optimizer))


@variable(newModel, x[i=1:n] >=x1_b[i])
for i=1:m
    @constraint(newModel, sum(A[i,j]*x[j] for j=1:n) == b[i])
end
    @objective(newModel, Min, sum(c[j]*x[j] for j=1:n))
println("The optimization problem to be solved is:")
print(newModel)
println(" ")
println("The rank of the matrix A: ",rank(A))
println("The number of linear restrictions: ", m)
println("The number of variables: ",n)
println("Number of basic solutions n!/m!(n-m)!: ",factorial(n)/(factorial(m)*factorial(n-m)))

# Step 1 - initial assignment of basic and non-basic variables

## indices of matrix A
### iB: basic variables index
### iK: non-basic variables index

iB = collect(3:5);
iK = collect(1:2);

## construct matrix [B K]
B = A[:,iB];
K = A[:,iK];

println("List of indices for the basic variables:\n",iB)
println("List of indices for the non-basic variables:\n",iK)
println("A is: \n",A)
println("B is: \n",B)
println("K is: \n",K)

## compute xB, xK, and objective function z
cB = c[iB];
cK = c[iK];

xB = inv(B)*b;
xK = [0;0];

println("The updated B matrix is:\n",B)
println("The updated K matrix is:\n",K)
println("The updated solution for the basic variable, xB is:\n",xB)
println("The updated solution for the non-basic variable, xK is:\n",xK)
println("The updated coefficient vector for the objective function, cB, is: \n",cB)
println("The updated coefficient vector for the objective function, cK, is: \n",cK)
println("The updated objective function value, z, is:\n",[cB; cK]'*[xB;xK])

# Step 2 - Determine non-basic variable to enter the basis
cc = (cK'-cB'*inv(B)*K) # coefficients for xk in relation to objective value z: if negative, then the corresponding xk should be moved to xb
indK2B = iK[argmin(cc)]
println(cc)
println("The entering variable has index of ",indK2B)

# Step 3 - Determine basic variable to exit the basis
# As one xk is entered into basis, then one xb has to exit basis into k. And we need to decide how much of xk should be entered into basis
## ratio test
y = inv(B)*A;
a = inv(B)*b./y[:,indK2B]; # note: things might change (min/max) when we change to maximizing problem. 
a = ifelse.(a.<0,Inf,a)
indB2K = iB[argmin(a)];
println(a)
println("The exiting variable has index of ",indB2K)


# Step 4 - Pivoting: update indices
iB[argmin(ifelse.(a.<0,Inf,a))] = indK2B;
iK[argmin(cc)] = indB2K;
println("List of indices for the basic variables:\n",iB)
println("List of indices for the non-basic variables:\n",iK)

B = A[:,iB];
K = A[:,iK];

cB = c[iB];
cK = c[iK];

println("The updated B matrix is:\n",B)
println("The updated K matrix is:\n",K)
println("The updated coefficient vector for the objective function, cB, is:\n",cB)
println("The updated coefficient vector for the objective function, cK, is:\n",cK)

xB = inv(B)*b;
xK = [0;0];

println("The updated solution for the basic variable, xB is:\n",xB)
println("The updated solution for the non-basic variable, xK is:\n",xK)
println("The updated objective function value, z, is:\n",[cB; cK]'*[xB;xK])

# Step 5 - restart process
cc = (cK'.-cB'*inv(B)*K);
indK2B = iK[argmin(cc)[2]];

println(cc)
println("The entering variable has index of ",indK2B)

y = inv(B)*A;
a = inv(B)*b./y[:,indK2B];
indB2K = iB[argmin(ifelse.(a.<0,Inf,a))];

println(a)
println("The exiting variable has index of ",indB2K)

# Update indices
iB[argmin(ifelse.(a.<0,Inf,a))] = indK2B;
iK[argmin(cc)[2]] = indB2K;
println("List of indices for the basic variables: ",iB)
println("List of indices for the non-basic variables: ",iK)

B = A[:,iB];
K = A[:,iK];

cB = c[iB];
cK = c[iK];

println("The updated B matrix is: \n",B)
println("The updated K matrix is: \n",K)
println("The updated coefficient vector for the objective function, cB, is: \n",cB)
println("The updated coefficient vector for the objective function, cK, is: \n",cK)

xB = inv(B)*b;
xK = [0;0];

println("xB equals: ",xB)
println("xK equals: ",xK)
println("The objective function value, z, is: ",[cB; cK]'*[xB;xK])

cc = (cK'.-cB'*inv(B)*K);
indK2B = iK[argmin(cc)[2]];

println(cc)
println("The entering variable has index of ",indK2B)

y = inv(B)*A;
a = inv(B)*b./y[:,indK2B];
indB2K = iB[argmin(ifelse.(a.<0,Inf,a))];

println(a)
println("The exiting variable has index of ",indB2K)

# Update indices
iB[argmin(ifelse.(a.<0,Inf,a))] = indK2B;
iK[argmin(cc)[2]] = indB2K;
println("List of indices for the basic variables: ",iB)
println("List of indices for the non-basic variables: ",iK)

B = A[:,iB];
K = A[:,iK];

cB = c[iB];
cK = c[iK];

println("The updated B matrix is: \n",B)
println("The updated K matrix is: \n",K)
println("The updated coefficient vector for the objective function, cB, is: \n",cB)
println("The updated coefficient vector for the objective function, cK, is: \n",cK)

xB = inv(B)*b;
xK = [0;0];

println("xB equals: ",xB)
println("xK equals: ",xK)
println("The objective function value, z, is: ",[cB; cK]'*[xB;xK])

cc = (cK'-cB'*inv(B)*K);
cc # as the result are both positive, it means neither could further reduces the value

# Graphical representation
using PyPlot
x1 = collect(0:0.1:7)
x2a = ifelse.(5 .- 5/3 .* x1 .>=0,5 .-5/3 .* x1,NaN)
x2b = ifelse.(4 .- 8/7 .* x1 .>=0,4 .-8/7 .* x1,NaN)
x2c = ifelse.(3 .- 3/7 .* x1 .>=0,3 .-3/7 .* x1,NaN)
x2z = ifelse.(3.94 .- 1.1 .* x1 .>=0,3.94 .- 1.1 .* x1,NaN)

fig, ax = subplots()
ax.fill_between(x1,x2a,color="red"  ,linewidth=2,label=L"x_{2} \leq 5 - \frac{5}{3} x_{1}",alpha=0.3)
ax.fill_between(x1,x2b,color="blue" ,linewidth=2,label=L"x_{2} \leq 4 - \frac{8}{7} x_{1}",alpha=0.3)
ax.fill_between(x1,x2c,color="green",linewidth=2,label=L"x_{2} \leq 3 - \frac{3}{7} x_{1}",alpha=0.3)
ax.plot(x1,x2z,color="black",linewidth=2,label=L"x_{2} = 3.94 - 1.1 x_{1}",alpha=0.4)
ax.legend(loc="upper right");
ax.grid("on");



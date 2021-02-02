using JuMP, GLPK, LinearAlgebra
using DataFrames, DataFramesMeta, Combinatorics
using PyPlot

# Question 1
c = [-3; 4; 0; 0]
A = [-1 1 1 0;
     -1 2 0 1]
b = [0; 2]
m, n = size(A)
x_lb = [0;0;0;0;0]

# b) Search method
combs = collect(combinations(1:n, m))
result = DataFrame(comb_1=NaN,comb_2=NaN,x_B_1=NaN,x_B_2=NaN,z=NaN)

for i in 1:length(combs)
    comb = combs[i,]
    B = A[:, comb]
    c_B = c[comb]
    x_B = inv(B)*b

    if minimum(x_B)>0
        z = dot(c_B, x_B)
    else 
        z = Inf
    end
    if i==1
        result = DataFrame(comb_1=comb[1],comb_2=comb[2],x_B_1=x_B[1],x_B_2=x_B[2],z=z)
    else
        push!(result, ([comb[1],comb[2],x_B[1],x_B[2],z]))
    end
end
sort(result,:z,rev=false)

# c) Simplex method
# Step 1 - initial assignment of basic and non-basic variables

## indices of matrix A
### iB: basic variables index
### iK: non-basic variables index

iB = collect(1:2)
iK = collect(3:4) # initiating

## construct matrix [B K]
B = A[:,iB]
K = A[:,iK]

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
cc = (cK'-cB'*inv(B)*K);
println(cc)
println("In the scenario of maximising objective function, negative coefficients for both xk indicate that\n
neither should be added to the basis. Therefore, the optimal solution is:\nx1 = 2.0, x2 = 2.0, x3 = 0, x4 = 0\nz=2.0")

# d) Julia LP Solver
m1 = Model(with_optimizer(GLPK.Optimizer))
@variable(m1, x1 >=1)
@variable(m1, 0 <=x2 <=3)
@constraint(m1, -x1+x2 <=0)
@constraint(m1, -x1+2*x2 <=2)
@objective(m1, Max, -3*x1+4*x2)

optimize!(m1)
println("The optimal objective value: ", JuMP.objective_value(m1))
println("The optimal x1 = ", JuMP.value.(x1))
println("The optimal x2 = ", JuMP.value.(x2))

# a) plot linear constraints and objective function at optimal level
x1 = collect(0:0.1:3)
x2a = x1
x2b = 1 .+ 0.5 .*x1
x2c = 3 .+ 0 .*x1
x1d = 1 .+ 0 .*x1
x2e = 0.5 .+ 0.75 .*x1

fig, ax = subplots()
ax.plot(x1,x2a,color="red",linewidth=2,label=L"x_{2} \leq x_{1}",alpha=0.3)
ax.plot(x1,x2b,color="blue",linewidth=2,label=L"x_{2} \leq 1 + 0.5x_{1}",alpha=0.3)
ax.plot(x1,x2c,color="green",linewidth=2,label=L"x_{2} \leq 3",alpha=0.3)
ax.plot(x1d,x1,color="yellow",linewidth=2,label=L"x_{1} \geq 1",alpha=0.3)
ax.plot(x1,x2e,color="black",linewidth=4,label=L"x_{2} = 0.5 + 0.75x_{1}",alpha=0.6)
ax.legend(loc="upper right")
ax.grid("on")

# Question 2
# a) problem modelling 
m2 = Model(with_optimizer(GLPK.Optimizer))
@variable(m2, usd2eur >= 0)
@variable(m2, usd2gbp >= 0)
@variable(m2, usd2jpy >= 0)
@variable(m2, eur2usd >= 0)
@variable(m2, eur2gbp >= 0)
@variable(m2, eur2jpy >= 0)
@variable(m2, gbp2usd >= 0)
@variable(m2, gbp2eur >= 0)
@variable(m2, gbp2jpy >= 0)
@variable(m2, jpy2usd >= 0)
@variable(m2, jpy2eur >= 0)
@variable(m2, jpy2gbp >= 0)
@variable(m2, 0 <=D <=10000)
@constraint(m2, D+usd2eur+usd2gbp+usd2jpy-0.87063*eur2usd-1.42796*gbp2usd-1.0/133.333*jpy2usd == 1)
@constraint(m2, eur2usd+eur2gbp+eur2jpy-1.0/0.87063*usd2eur-1.0/0.60972*gbp2eur-1.0/116.144*jpy2eur == 0)
@constraint(m2, gbp2usd+gbp2eur+gbp2jpy-1.0/1.42796*usd2gbp-0.60970*eur2gbp-1.0/190.476*jpy2gbp == 0)
@constraint(m2, jpy2usd+jpy2eur+jpy2gbp-133.330*usd2jpy-116.140*eur2jpy-190.480*gbp2jpy == 0)
@objective(m2, Max, D)



# b) solve 
optimize!(m2)
usd2eur = JuMP.value.(usd2eur)
usd2gbp = JuMP.value.(usd2gbp)
usd2jpy = JuMP.value.(usd2jpy)
eur2usd = JuMP.value.(eur2usd)
eur2gbp = JuMP.value.(eur2gbp)
eur2jpy = JuMP.value.(eur2jpy)
gbp2usd = JuMP.value.(gbp2usd)
gbp2eur = JuMP.value.(gbp2eur)
gbp2jpy = JuMP.value.(gbp2jpy)
jpy2usd = JuMP.value.(jpy2usd)
jpy2eur = JuMP.value.(jpy2eur)
jpy2gbp = JuMP.value.(jpy2gbp)

usd_buy = eur2usd+gbp2usd+jpy2usd
usd_sell = usd2eur+usd2gbp+usd2jpy
eur_buy = usd2eur+gbp2eur+jpy2eur
eur_sell = eur2usd+eur2gbp+eur2jpy
gbp_buy = usd2gbp+eur2gbp+jpy2gbp
gbp_sell = gbp2usd+gbp2eur+gbp2jpy
jpy_buy = usd2jpy+eur2jpy+gbp2jpy
jpy_sell = jpy2usd+jpy2eur+jpy2gbp

println("The optimal objective value: ", JuMP.objective_value(m2))
println("The optimal usd2eur = ", usd2eur)
println("The optimal usd2gbp = ", usd2gbp)
println("The optimal usd2jpy = ", usd2jpy)
println("The optimal eur2usd = ", eur2usd)
println("The optimal eur2gbp = ", eur2gbp)
println("The optimal eur2jpy = ", eur2jpy)
println("The optimal gbp2usd = ", gbp2usd)
println("The optimal gbp2eur = ", gbp2eur)
println("The optimal gbp2jpy = ", gbp2jpy)
println("The optimal jpy2usd = ", jpy2usd)
println("The optimal jpy2eur = ", jpy2eur)
println("The optimal jpy2gbp = ", jpy2gbp)

result = DataFrame(USD = [usd_buy, usd_sell], 
                   EUR = [eur_buy, eur_sell], 
                   GBP = [gbp_buy, gbp_sell], 
                   JPY = [jpy_buy, jpy_sell])
println("Note: the first line refers to buy amount and the second refers to the sell amount")
println("The final arbitrage profit is 10000 USD")
result



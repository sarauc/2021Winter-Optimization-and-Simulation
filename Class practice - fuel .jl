# Class practice W4
using JuMP, GLPK, LinearAlgebra
using DataFrames, DataFramesMeta, Combinatorics
using PyPlot

# define model
m1 = Model(with_optimizer(GLPK.Optimizer))
@variable(m1, AH >= 0)
@variable(m1, AL >= 0)
@variable(m1, BH >= 0)
@variable(m1, BL >= 0)
@variable(m1, CH >= 0)
@variable(m1, CL >= 0)
@variable(m1, DH >= 0)
@variable(m1, DL >= 0)
@variable(m1, EH >= 0)
@variable(m1, EL >= 0)
@variable(m1, H >= 0)
@variable(m1, L >= 0)
@variable(m1, sA >= 0)
@variable(m1, sB >= 0)
@variable(m1, sC >= 0)
@variable(m1, sD >= 0)
@variable(m1, sE >= 0)
@constraint(m1, AH+AL+sA == 2000)
@constraint(m1, BH+BL+sB == 2000)
@constraint(m1, CH+CL+sC == 2000)
@constraint(m1, DH+DL+sD == 2000)
@constraint(m1, EH+EL+sE == 2000)
@constraint(m1, 70*AH+80*BH+85*CH+90*DH+99*EH >= 93*H)
@constraint(m1, 70*AL+80*BL+85*CL+90*DL+99*EL >= 85*L)
@constraint(m1, AH+BH+CH+DH+EH == H)
@constraint(m1, AL+BL+CL+DL+EL == L)
@objective(m1, Max, 37.5*H+28.5*L+9*sA+12.5*sB+12.5*sC+27.5*sD+27.5*sE)


optimize!(m1)
rev = JuMP.objective_value(m1)
h = JuMP.value.(H)
l = JuMP.value.(L)
s1 = JuMP.value.(sA)
s2 = JuMP.value.(sB)
s3 = JuMP.value.(sC)
s4 = JuMP.value.(sD)
s5 = JuMP.value.(sE)

println("Total revenue: ", rev)
println("AH: ", JuMP.value.(AH))
println("BH: ", JuMP.value.(BH))
println("CH: ", JuMP.value.(CH))
println("DH: ", JuMP.value.(DH))
println("EH: ", JuMP.value.(EH))
println("AL: ", JuMP.value.(AL))
println("BL: ", JuMP.value.(BL))
println("CL: ", JuMP.value.(CL))
println("DL: ", JuMP.value.(DL))
println("EL: ", JuMP.value.(EL))
println("High produced and sold: ", h)
println("Low produced and sold: ", l)
println("unused 1: ", s1)
println("unused 2: ", s2)
println("unused 3: ", s3)
println("unused 4: ", s4)
println("unused 5: ", s5)
println("contribution of stock 1 to revenue: ", s1*9.0/rev*100,"%")
println("contribution of stock 2 to revenue: ", s2*12.5/rev*100,"%")
println("contribution of stock 3 to revenue: ", s3*12.5/rev*100,"%")
println("contribution of stock 4 to revenue: ", s4*27.5/rev*100,"%")
println("contribution of stock 5 to revenue: ", s5*27.5/rev*100,"%")
println("contribution of high fuel to revenue: ", h*37.5/rev*100,"%")
println("contribution of low fuel to revenue: ", l*28.5/rev*100,"%")


















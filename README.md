# LinQuadOptInterface.jl

LinQuadOptInterface (LQOI) is designed to make it easier for low-level wrapper designed to bridge low-level Integer Linear and Quadratic solvers to implement the MOI interface. It provides access to many MathOptInterface functionalities mainly related to problem modifications: 

1. add constraints/variables 1-by-1 and in batches 
2. remove constraints/variables
3. change constraint coefficients 
4. change constraint type
5. change constraint rhs
6. change variable bounds and type

## LinQuadOptInterface Instance

In the MOI `Instance` made available by LinQuadOptInterface.jl all these modification are caried out by the low-level solver own functionalities and hence it differs from MathOptInterfaceUtilities' `Instance`. The latter will keep all problem data in the julia level and typically push to a low-level solver the complete problem at once.

Here the data in the julia level is minimal, basically only references to constraints and variables.

## Current uses

This package is currently used to implement `MathOptInterfaceXpress.jl`, `MathOptInterfaceCPLEX.jl`, `MathOptInterfaceGurobi.jl` and `MathOptInterfaceGLPK.jl`. The last one being only a linear solver.

All these solver have in common a low-level API which supports most of these modifications.

## Other possible uses

This package is only recommended if a solver low-level API which supports most of these modifications.

If a solver low-level API does not support most of these modifications, then following the example of `MathOptInterfaceSCS.jl` and `MathOptInterfaceECOS.jl` might be a better idea.

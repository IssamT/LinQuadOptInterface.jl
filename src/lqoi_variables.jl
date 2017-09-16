#=
    Helper functions
=#
getcol(m::LinQuadSolverInstance, ref::VarRef) = m.variable_mapping[ref]
getcol(m::LinQuadSolverInstance, v::SinVar) = getcol(m, v.variable)

#=
    Get number of variables
=#

function MOI.getattribute(m::LinQuadSolverInstance, ::MOI.NumberOfVariables)
    return lqs_getnumcols(m.inner)
end
MOI.cangetattribute(m::LinQuadSolverInstance, ::MOI.NumberOfVariables) = true

#=
    Get variable references
=#

function MOI.getattribute(m::LinQuadSolverInstance, ::MOI.ListOfVariableReferences)
    return m.variable_references
end
MOI.cangetattribute(m::LinQuadSolverInstance, ::MOI.ListOfVariableReferences) = true

#=
    Add a variable to the LinQuadSolverInstance
Returns a MathOptInterface VariableReference. So we need to increment the
variable reference counter in the m.variablemapping, and store the column number
in the dictionary
=#

function MOI.addvariable!(m::LinQuadSolverInstance)
    lqs_newcols!(m.inner, 1)
    # assumes we add columns linearly
    m.last_variable_reference += 1
    ref = MOI.VariableReference(m.last_variable_reference)
    m.variable_mapping[ref] = MOI.getattribute(m, MOI.NumberOfVariables())
    push!(m.variable_references, ref)
    push!(m.variable_primal_solution, NaN)
    push!(m.variable_dual_solution, NaN)
    return ref
end

function MOI.addvariables!(m::LinQuadSolverInstance, n::Int)
    previous_vars = MOI.getattribute(m, MOI.NumberOfVariables())
    lqs_newcols!(m.inner, n)
    variable_references = MOI.VariableReference[]
    sizehint!(variable_references, n)
    for i in 1:n
        # assumes we add columns linearly
        m.last_variable_reference += 1
        ref = MOI.VariableReference(m.last_variable_reference)
        push!(variable_references, ref)
        m.variable_mapping[ref] = previous_vars + i
        push!(m.variable_references, ref)
        push!(m.variable_primal_solution, NaN)
        push!(m.variable_dual_solution, NaN)
    end
    return variable_references
end

#=
    Check if reference is valid
=#

function MOI.isvalid(m::LinQuadSolverInstance, ref::MOI.VariableReference)
    if haskey(m.variable_mapping.refmap, ref.value)
        column = m.variable_mapping.refmap[ref.value]
        if column > 0 && column <= MOI.getattribute(m, MOI.NumberOfVariables())
            return true
        end
    end
    return false
end

#=
    Delete a variable
=#

function MOI.delete!(m::LinQuadSolverInstance, ref::MOI.VariableReference)
    col = m.variable_mapping[ref]
    lqs_delcols!(m.inner, col, col)
    deleteat!(m.variable_references, col)
    deleteat!(m.variable_primal_solution, col)
    deleteat!(m.variable_dual_solution, col)

    deleteref!(m.variable_mapping, col, ref)
    # deleting from a dict without the key does nothing
    delete!(cmap(m).upper_bound, ref)
    delete!(cmap(m).lower_bound, ref)
    delete!(cmap(m).fixed_bound, ref)
    delete!(cmap(m).interval_bound, ref)

end
MOI.candelete(m::LinQuadSolverInstance, ref::MOI.VariableReference) = true

#=
    MIP starts
=#
function MOI.setattribute!(m::LinQuadSolverInstance, ::MOI.VariablePrimalStart, ref::MOI.VariableReference, val::Float64)
    lqs_addmipstarts!(m.inner, [getcol(m, ref)], [val])
end
MOI.cansetattribute(m::LinQuadSolverInstance, ::MOI.VariablePrimalStart, ::MOI.VariableReference) = true

function MOI.setattribute!(m::LinQuadSolverInstance, ::MOI.VariablePrimalStart, refs::Vector{MOI.VariableReference}, vals::Vector{Float64})
    lqs_addmipstarts!(m.inner, getcol.(m, refs), vals)
end
MOI.cansetattribute(m::LinQuadSolverInstance, ::MOI.VariablePrimalStart, ::Vector{MOI.VariableReference}) = true
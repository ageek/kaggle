changedPlansMatrix <- function(current,target)
{
  if (length(dim(current)) > 0)
    return( current[,"A"] != target["A"] | 
              current[,"B"] != target["B"] | 
              current[,"C"] != target["C"] | 
              current[,"D"] != target["D"] | 
              current[,"E"] != target["E"] | 
              current[,"F"] != target["F"] |
              current[,"G"] != target["G"]
    )
  else
    return( current["A"] != target["A"] | 
              current["B"] != target["B"] | 
              current["C"] != target["C"] | 
              current["D"] != target["D"] | 
              current["E"] != target["E"] | 
              current["F"] != target["F"] |
              current["G"] != target["G"]
    )
}
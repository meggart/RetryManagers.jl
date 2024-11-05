module RetryManagers
import Distributed
export RetryManager
launchfile = joinpath(@__DIR__,"launchuntilsuccess.sh")

function get_exename(oldexe)
    return `bash $launchfile $oldexe`
end

struct RetryManager <: Distributed.ClusterManager
    parent::Distributed.ClusterManager
end
RetryManager(np::Integer=Sys.CPU_THREADS;restrict=true) = RetryManager(Distributed.LocalManager(np,restrict))


Distributed.kill(m::RetryManager,pid::Int, config::Distributed.WorkerConfig; kwargs...) = 
    Distributed.kill(m.parent,pid,config;kwargs...)
Distributed.launch(m::RetryManager,args...;kwargs...) = Distributed.launch(m.parent,args...;kwargs...)
Distributed.manage(m::RetryManager,args...;kwargs...) = Distributed.manage(m.parent,args...;kwargs...)
function Distributed.default_addprocs_params(m::RetryManager)
    d = Distributed.default_addprocs_params(m.parent)
    oldexe = get(d, :exename,joinpath(Sys.BINDIR, Distributed.julia_exename()))
    d[:exename] = get_exename(oldexe)
    d
end

end
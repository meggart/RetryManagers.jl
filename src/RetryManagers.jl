module RetryManagers
import Distributed
export RetryManager, LocalScratchManager
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


scratchlaunchfile = joinpath(@__DIR__,"localjulia.sh")

function get_scratchname()
    sd = splitpath(Sys.BINDIR)
    oldbase = joinpath(sd[1:end-2]...)
    jlname = sd[end-1]
    @show oldbase
    @show jlname
    return `bash $scratchlaunchfile $oldbase $jlname`
end

struct LocalScratchManager <: Distributed.ClusterManager
    parent::Distributed.ClusterManager
end
LocalScratchManager(np::Integer=Sys.CPU_THREADS;restrict=true) = LocalScratchManager(Distributed.LocalManager(np,restrict))


Distributed.kill(m::LocalScratchManager,pid::Int, config::Distributed.WorkerConfig; kwargs...) = 
    Distributed.kill(m.parent,pid,config;kwargs...)
Distributed.launch(m::LocalScratchManager,args...;kwargs...) = Distributed.launch(m.parent,args...;kwargs...)
Distributed.manage(m::LocalScratchManager,args...;kwargs...) = Distributed.manage(m.parent,args...;kwargs...)
function Distributed.default_addprocs_params(m::LocalScratchManager)
    d = Distributed.default_addprocs_params(m.parent)
    d[:exename] = get_scratchname()
    d
end
end
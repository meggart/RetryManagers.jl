# RetryManagers

[![Build Status](https://github.com/fgans/RetryManagers.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/fgans/RetryManagers.jl/actions/workflows/CI.yml?query=branch%3Amain)

RetryManagers is a tiny package thats wraps different implementations of `ClusterManager`s. It modifes their process launch scripts so that launching the julia process is repeated until successful. This can help on some systems where launching many julia processes at the same time can lead to random segfaults. Simply wrap the respective ClusterManager in a `RetryManager` by calling `RetryManager(manager)` 

### Usage

LocalManager:

````julia
using Distributed, RetryManagers
addprocs(RetryManager(3))

pmap(_->myid(),1:10)

rmprocs(workers())
````

SlurmManager:

````julia
using ClusterManagers, Distributed, RetryManagers

addprocs(RetryManager(SlurmManager(5)),partition="work",t="00:5:00")

pmap(_->myid(),1:10)

rmprocs(workers())
````

SlurmClusterManager:

````julia
using Distributed, SlurmClusterManager, RetryManager
addprocs(RetryManager(SlurmManager()))
````


#!/bin/bash
julia -e"using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); include(\"src/app.jl\")"

using RateTables
using Documenter

DocMeta.setdocmeta!(RateTables, :DocTestSetup, :(using RateTables); recursive=true)

makedocs(;
    modules=[RateTables],
    authors="Oskar Laverny <oskar.laverny@univ-amu.fr> and contributors",
    sitename="RateTables.jl",
    format=Documenter.HTML(;
        canonical="https://lrnv.github.io/RateTables.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lrnv/RateTables.jl",
    devbranch="main",
)

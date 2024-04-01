
using ZipFile, HMD, DataFrames, CSV


# unzip function from https://www.mortality.org/File/GetDocument/hmd.v6/zip/by_statistic/death_rates.zip
function unzip(file,exdir="")
    fileFullPath = isabspath(file) ?  file : joinpath(pwd(),file)
    basePath = dirname(fileFullPath)
    outPath = (exdir == "" ? basePath : (isabspath(exdir) ? exdir : joinpath(pwd(),exdir)))
    isdir(outPath) ? "" : mkdir(outPath)
    zarchive = ZipFile.Reader(fileFullPath)
    for f in zarchive.files
        fullFilePath = joinpath(outPath,f.name)
        if (endswith(f.name,"/") || endswith(f.name,"\\"))
            mkdir(fullFilePath)
        else
            write(fullFilePath, read(f))
        end
    end
    close(zarchive)
end

# let's first unzip the zip file : 
zip_path = joinpath(@__DIR__, "death_rates.zip")
unzip(zip_path, joinpath(@__DIR__, "..", "data", "death_rates"))

# make dataframes: 
death_rates = Dict{String, DataFrames.DataFrame}()
countries = Dict{String,String}()
for file in readdir(joinpath(@__DIR__,"death_rates", "Mx_1x1"))
    path = joinpath(@__DIR__,"death_rates", "Mx_1x1",file)
    country_code = first(split(file,"."))
    country_name = first(split(readline(path),", Death rates"))
    df = read_HMD(path,verbose=true)
    push!(death_rates,country_code => df)
    push!(countries,country_code => country_name)
end

# check spacings: 
for country_code in keys(death_rates)

    # check for years and add them if not availiables: 
    availiable_years = sort(unique(death_rates[country_code].Year))

    for year in minimum(availiable_years):maximum(availiable_years)
        if !(year ∈ availiable_years)
            # then this year is missing. 
            # we could simply add a bunch of rows in the dataframe
            # rows that strictly copy the previous rows. 
            subset_previous_year = filter(row -> row.Year == year-1, death_rates["NLD"])
            subset_previous_year.Year .+= 1
            death_rates[country_code] = vcat(death_rates[country_code], subset_previous_year)
        end
    end

    sort!(death_rates[country_code])
    # Final check: 
    tr_Male   = HMD.transform(death_rates[country_code], :Male)
    tr_Female = HMD.transform(death_rates[country_code], :Female)
    @assert all(diff(parse.(Int64, names(tr_Male)[2:end])) .== 1)
    @assert all(diff(parse.(Int64, names(tr_Female)[2:end])) .== 1)
    @assert all(diff(tr_Male.Age) .== 1)
    @assert all(diff(tr_Female.Age) .== 1)
end

# save files : 
for code in keys(countries)
    path = joinpath(@__DIR__, "..", "data", "qx", "$(code).$(countries[code]).csv")
    CSV.write(path,death_rates[code])
end
using Genie, Genie.Requests, Dates
include("ode.jl")

spring_constant = 4
damping_constant = 0.1
weight_mass = 0.1

app_page = read(open("site.html", "r"), String)


route(() -> app_page, "/")


route("/constants", method = POST) do 
    # Update the spring contstants in a separate request to make the htmx part simpler
    global spring_constant  = parse(Float64, postpayload(:const))
    global damping_constant = parse(Float64, postpayload(:damp))
    global weight_mass      = parse(Float64, postpayload(:mass))
end


route("/run", method = POST) do 
    y_initial = parse(Float64, postpayload(:height))
    return animate_system(SpringSystem(spring_constant, damping_constant, y_initial, weight_mass))
end


up(8888, async=false)


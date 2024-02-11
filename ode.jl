using DifferentialEquations, PlotlyJS, Interpolations

struct SpringSystem
    spring_constant     ::Float64
    damping_constant    ::Float64
    y_initial           ::Float64
    speed_initial       ::Float64
    weight_mass         ::Float64
    max_time            ::Float64
end
# Assume static initial condition & end time of 10 seconds
SpringSystem(s,d,y,w) = SpringSystem(s,d,y,0,w,10)


function solve_system(s::SpringSystem)
    function spring!(du,u,p,t)
        du[1] = u[2]
        du[2] = (-s.spring_constant * u[1] - s.damping_constant * u[2])/s.weight_mass
    end
    u0 = [s.y_initial, s.speed_initial]
    tspan = (0, s.max_time)
    prob = ODEProblem(spring!, u0, tspan)

    return solve(prob,Tsit5())
end


function animate_system(s::SpringSystem)
    height = 600
    width = 600

    sol = solve_system(s)
    times = sol.t
    y = sol[1, :]

    # Interpolate for higher density timestamps - helps animation
    interp_linear = linear_interpolation(times, y)
    t_dense = 0:0.05:s.max_time
    y_dense = interp_linear.(t_dense)
    delays = "[" * join([i == 1 ? 0 : t_dense[i] - t_dense[i-1] for i in eachindex(t_dense)], ", ") * "]"

    p = plot(scatter(x=times, y=y), Layout(
            width=width, height=height, xaxis_title="Time (s)", yaxis_title="Displacement", yaxis_range=[-300,200]
        ))
    # Return the HTML string that plotly generates directly
    buf = IOBuffer()
    PlotlyBase.to_html(buf, p.plot)
    html = String(take!(buf))

    # If we strip out the width dimension in plotly, it will automatically adjust to 100% of the outer div
    # Height will default to 450px if not specified so we leave that at our initial setting
    plot_html = replace(html, "width:$width;" => "", """\"width\":$width""" => "")

    # Update the animation "frames" through a js function call
    script = """
    <script>
        function moveSpring() {
            animateSpring($delays, $y_dense)
        }
    </script>
    """

    return script * plot_html
end

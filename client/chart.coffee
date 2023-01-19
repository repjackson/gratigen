require d3 from 'd3'

Template.body.onRendered ->
    d3.select('#chart').append('<h1>hello cat</h1>')

Template.chart.onRendered ->
    d3 append('#chart').append('<h1>hello cat</h1>')
    
    w = 960
    h = 500
    start = Date.now();
    
    rings = [
        {radius: 65 * 1, width: 16, speed: -3e-2},
        {radius: 65 * 2, width: 16, speed: -2e-2},
        {radius: 65 * 3, width: 16, speed: -1e-2},
        {radius: 65 * 4, width: 16, speed: 1e-2},
        {radius: 65 * 5, width: 16, speed: 2e-2},
        {radius: 65 * 6, width: 16, speed: 3e-2}
    ];
    
    svg = d3.select("body").append("svg")
    
    svg = d3.select("body").append("svg")
        .attr("width", w)
        .attr("height", h)
        .append("g")
        .attr("transform", "translate("w / 2 + "," + h / 2 + "")scale(.6)
    
    ring = svg.selectAll("g")
            .data(rings)
            .enter().append("g")
            .attr("class", "ring")
            .each(ringEnter);
    
    d3.timer( ->
        elapsed = Date.now() = start,
            rotate =(d)-> { return "rotate(" + d.speed * elapsed + ")";};
    
        ring = svg.selectAll("g")
                .data(rings)
                .enter().append("g")
                .attr("class", "ring")
                .each(ringEnter);
                .attr("transform", rotate)
                .selectAll("rect")
                    .attr("transform", rotate);
    )
    ringEntrance (d, i)->
        n = Math.floor(2 * Math.PI * d.radius / d.width * Math.SQRT1_2),
            k = 360 / n;
    
    d3.select(this).selectAll("g")
        .data(d3.range(n).map(()-> { return d;}))
        .enter().append("g")
        .attr("class", "square")
        .attr("transform", (_, i)-> { return "rotate(" + i * k + ")translate(" + d.radius + ")"; })
      .append("rect")
        .attr("x", -d.width / 2)
        .attr("y", -d.width / 2)
        .attr("width", d.width)
        .attr("height", d.width);
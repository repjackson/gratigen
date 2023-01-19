Template.chart.helpers
    doD3Stuff: ()->
    # // all your on render code here
    # //Width and height
    w = 600;
    h = 350;

    # //Define key, to be used when binding data
    key = (d) {
    return d.index;
    };

    # //Create SVG selement
    svg = d3.select("#obTable")
    .attr("width", w)
    .attr("height", h);

    dataset = require('../data/ob.json');
    # // dataset = Bars.find({}).fetch();


    # //Select…
    table = svg.selectAll('table').append('table')
    .style("border-collapse", "collapse")
    .style("border", "2px black solid");
    // .data(dataset, key);

    console.log(table);

    rows = table.selectAll('tr')
    .data(dataset, key)
    .enter()
    .append('tr');

    console.log(rows);

    rows.selectAll('td')
    .data(d){ console.log(d); return d;} )
    .enter()
    .append('td')
    .text(d) {console.log("here"); return d;})
    .style("border", "1px black solid")
    .style("padding", "10px")
    .style("font-size","12px");
}
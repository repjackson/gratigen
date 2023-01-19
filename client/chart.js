var outerWidth = '100vw';
var outerHeight = '100vh';
var margin = {top: 25, right: 25, bottom: 25, left: 25};

var svg = d3.select('body').append('svg')
            .attr('width', outerWidth)
            .attr('height', outerHeight);

var div = d3.select('body').append('div')
            .attr('class', 'tooltip')
            .style('opacity', 0)

var color = d3.scaleOrdinal(d3.schemeCategory20);

var projection = d3.geoMercator().scale(305);
var path = d3.geoPath().projection(projection)

d3.json('https://d3js.org/world-50m.v1.json', drawMap)
d3.json('https://raw.githubusercontent.com/FreeCodeCamp/ProjectReferenceData/master/meteorite-strike-data.json', parse);

var mousedownX;
var mousedownY;
var mouseClicked = false;
var mouse = [];
var transform = [];

function parse(data) {
  var parsedData = [];
  for (var i = 0; i < data.features.length; ++i) {
    if (data.features[i].geometry === null) continue;
    else {
      let temp = data.features[i].properties;
      temp.location = data.features[i].geometry.coordinates;
      parsedData.push(temp);
    }
  }
  render(parsedData);
}

function render(data) {
  svg.on('mousedown', mouseDown)
     .on('mousemove', drag)
     .on('mouseup', mouseUp)

  var points = svg.append('g').raise()
                  .attr('class', 'meteor')
                  .selectAll('circle').data(data)
                  .enter().append('circle')
                    .attr('r', d => Math.pow(d.mass, 1/5))
                    .attr('fill', d => color(d.recclass))
                    .attr('cx', d => projection(d.location)[0])
                    .attr('cy', d => projection(d.location)[1])
                    .on('mouseover', addDiv)
                    .on('mouseout', removeDiv)

  window.setTimeout(() => d3.select('.meteor').raise(), 250);
}



function addDiv(d) {
  var html = '';
  Object.keys(d).map(function(e) {
    if (d[e]) {
      html += `${e}: ${d[e]} </br>`
    }
  })
  div.transition()
     .duration(100)
     .style('opacity', 0.85)
  div.html(html)
     .style('left', `${d3.event.pageX}px`)
     .style('top', `${d3.event.pageY}px`)
}
function removeDiv(d) {
  div.transition().style('opacity', 0);
}

function drawMap(data) {
  svg.append('g').attr('class', 'map')
     .selectAll('path')
       .data(topojson.feature(data, data.objects.countries).features)
       .enter().append('path')
        .attr('fill', '#e2c776')
        .attr('d', path)
        .attr('stroke', '#fcdcb5')
}

function mouseDown(e) {
  mouseClicked = true;
  mouse = [d3.mouse(this)[0],d3.mouse(this)[1]];
  transform = getTranslate(document.querySelector('.map'));
}
function mouseUp(e) {
  mouseClicked = false;
}
function getTranslate(el) {
  var transformString = el.style.transform || '(0,0)';
  var split = transformString.slice(transformString.indexOf('(')+1).split(',');
  return [parseInt(split[0]), parseInt(split[1].slice(0, split[1].length-1))]
}

function drag(e) {
  if (mouseClicked) {
    var map = document.querySelector('.map');
    var body = document.querySelector('svg');
    var newPos = d3.mouse(body);
    map.style.transform = `translate(${newPos[0]-mouse[0]+transform[0]}px, ${newPos[1]-mouse[1]+transform[1]}px)`
    d3.select('.meteor')
      .attr('style', `transform: translate(${newPos[0]-mouse[0]+transform[0]}px, ${newPos[1]-mouse[1]+transform[1]}px)`)

  }
}

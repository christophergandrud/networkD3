HTMLWidgets.widget({

  name: "chordDiagram",
  type: "output",

  initialize: function(el, width, height) {

    var diameter = Math.min(parseInt(width),parseInt(height));

    d3.select(el).append('h1');
    d3.select(el).append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");
    return d3.layout.chord();

  },

  resize: function(el, width, height, chord) {
    var diameter = Math.min(parseInt(width),parseInt(height));
    var s = d3.select(el).selectAll("svg");
    s.attr("width", width).attr("height", height);
    //chord.size([360, diameter/2 - parseInt(s.attr("margin"))]);
    var svg = d3.select(el).selectAll("svg").select("g");
    svg.attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");
  },

  renderValue: function(el, x, chord) {
    // x is a list with a matrix and a title

    // Returns an event handler for fading a given chord group.
  function fade(opacity) {
    return function(g, i) {
        s.selectAll(".chord path")
        .filter(function(d) { return d.source.index != i && d.target.index != i; })
        .transition()
        .style("opacity", opacity);
      };
    }

    var s = d3.select(el).select("g");
    var diameter = Math.min(parseInt(s.attr("width")),parseInt(s.attr("height")));

    chord.matrix(JSON.parse(x.matrix));

    var innerRadius = Math.min(x.options.width, x.options.height) * .41;
    var outerRadius = innerRadius * 1.1;

    var fill = d3.scale.ordinal()
    .domain(d3.range(4))
    .range(["#000000", "#FFDD89", "#957244", "#F26223"]);

    s.append("g").selectAll("path")
    .data(chord.groups)
    .enter().append("path")
    .style("fill", function(d) { return fill(d.index); })
    .style("stroke", function(d) { return fill(d.index); })
    .attr("d", d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius))
    .on("mouseover", fade(.1))
    .on("mouseout", fade(1));

  },
});

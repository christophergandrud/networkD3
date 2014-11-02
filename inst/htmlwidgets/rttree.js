// Called by widget bindings to register a new type of widget. The definition
// object can contain the following properties:
// - name (required) - A string indicating the binding name, which will be
//   used by default as the CSS classname to look for.
// - initialize (optional) - A function(el) that will be called once per
//   widget element; if a value is returned, it will be passed as the third
//   value to renderValue.
// - renderValue (required) - A function(el, data, initValue) that will be
//   called with data. Static contexts will cause this to be called once per
//   element; Shiny apps will cause this to be called multiple times per
//   element, as the data changes.

HTMLWidgets.widget({

  name: "rttree",
  type: "output",

  initialize: function(el, width, height) {

     diameter = Math.min(width,height);

     d3.select(el).append("svg")
      .attr("width", diameter)
      .attr("height", diameter)
      .append("g")
      .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");

    return d3.layout.tree();

  },

  renderValue: function(el, x, tree) {
    // x is a list with two elements, options and root; root must already be a
    // JSON array with the d3Tree root data

    tree.size([360, diameter/2 - x.options.margin ])
        .separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; });

    // select the svg group element and remove existing children
    var s = d3.select(el).selectAll("svg")
               .attr("pointer-events", "all")
               .call(d3.behavior.zoom().on("zoom", redraw));

    var svg = d3.select(el).selectAll("g");
    svg.selectAll("*").remove();

    function redraw() {
        svg.attr("transform", "translate(" + d3.event.translate + ")"
                 + " scale(" + d3.event.scale + ")");
    }

    var root = JSON.parse(x.root);
    var nodes = tree.nodes(root),
        links = tree.links(nodes);

    var diagonal = d3.svg.diagonal.radial()
                     .projection(function(d) { return [d.y, d.x / 180 * Math.PI]; });

    // draw links
    var link = svg.selectAll(".link")
                  .data(links)
                  .enter().append("path")
                  .style("fill", "none")
                  .style("stroke", "#ccc")
                  .style("opacity", "0.55")
                  .style("stroke-width", "1.5px")
                  .attr("d", diagonal);

    // draw nodes
    var node = svg.selectAll(".node")
                  .data(nodes)
                  .enter().append("g")
                  .attr("class", "node")
                  .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })
                  .on("mouseover", mouseover)
                  .on("mouseout", mouseout);

    // node circles
    node.append("circle")
        .attr("r", 4.5)
        .style("fill", x.options.nodeColour)
        .style("opacity", x.options.opacity)
        .style("stroke", x.options.nodeStroke)
        .style("stroke-width", "1.5px");

    // node text
    node.append("text")
        .attr("dy", ".31em")
        .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
        .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
        .style("font", x.options.fontSize + "px serif")
        .style("opacity", x.options.opacity)
        .style("fill", x.options.textColour)
        .text(function(d) { return d.name; });

    // mouseover event handler
    function mouseover() {
      d3.select(this).select("circle").transition()
        .duration(750)
        .attr("r", 9)
      d3.select(this).select("text").transition()
        .duration(750)
        .attr("dy", ".31em")
        .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
        .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
        .style("stroke-width", ".5px")
        .style("font", "25px serif")
        .style("opacity", 1);
    }

    // mouseout event handler
    function mouseout() {
      d3.select(this).select("circle").transition()
        .duration(750)
        .attr("r", 4.5)
      d3.select(this).select("text").transition()
        .duration(750)
        .attr("dy", ".31em")
        .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
        .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
        .style("font", x.options.fontSize + "px serif")
        .style("opacity", x.options.opacity);
    }


  },
});

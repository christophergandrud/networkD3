HTMLWidgets.widget({

  name: "radialNetwork",
  type: "output",

  initialize: function(el, width, height) {

    var diameter = Math.min(parseInt(width),parseInt(height));
    d3.select(el).append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")"
                         + " scale("+diameter/800+","+diameter/800+")");
    return d3.layout.tree();

  },

  resize: function(el, width, height, tree) {
    var diameter = Math.min(parseInt(width),parseInt(height));
    var s = d3.select(el).selectAll("svg");
    s.attr("width", width).attr("height", height);
    tree.size([360, diameter/2 - parseInt(s.attr("margin"))]);
    var svg = d3.select(el).selectAll("svg").select("g");
    svg.attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")"
                         + " scale("+diameter/800+","+diameter/800+")");

  },

  renderValue: function(el, x, tree) {
    // x is a list with two elements, options and root; root must already be a
    // JSON array with the d3Tree root data

    var s = d3.select(el).selectAll("svg");
    var diameter = Math.min(parseInt(s.attr("width")),parseInt(s.attr("height")));
    s.attr("margin", x.options.margin);
    tree.size([360, diameter/2 - parseInt(s.attr("margin"))])
        .separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; });

    // select the svg group element and remove existing children
    s.attr("pointer-events", "all").selectAll("*").remove();
    s.append("g")
     .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")"
                         + " scale("+diameter/800+","+diameter/800+")");

    var svg = d3.select(el).selectAll("g");

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
        .style("font", x.options.fontSize + "px " + x.options.fontFamily)
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
        .style("font", "25px " + x.options.fontFamily)
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
        .style("font", x.options.fontSize + "px " + x.options.fontFamily)
        .style("opacity", x.options.opacity);
    }


  },
});

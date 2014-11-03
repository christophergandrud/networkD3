HTMLWidgets.widget({

  name: "tree",
  type: "output",

  initialize: function(el, width, height) {

     d3.select(el).append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(0,0)");

    return d3.layout.cluster();

  },

  renderValue: function(el, x, tree) {
    // x is a list with two elements, options and root; root must already be a
    // JSON array with the d3Tree root data

  tree.size([x.options.height, x.options.width - x.options.margin]);

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

    var diagonal = d3.svg.diagonal()
                     .projection(function(d) { return [d.y, d.x]; });

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
                  .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
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
        .attr("dx", function(d) { return d.children ? -8 : 8; })
        .attr("dy", 3)
        .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
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
        .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
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
        .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
        .style("font", x.options.fontSize + "px serif")
        .style("opacity", x.options.opacity);
    }


  },
});

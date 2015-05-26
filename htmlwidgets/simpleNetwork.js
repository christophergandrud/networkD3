HTMLWidgets.widget({

  name: "simpleNetwork",

  type: "output",

  initialize: function(el, width, height) {

     d3.select(el).append("svg")
      .attr("width", width)
      .attr("height", height);

    return d3.layout.force();
  },

  resize: function(el, width, height, force) {

     d3.select(el).select("svg")
      .attr("width", width)
      .attr("height", height);

     force.size([width, height]).resume();
  },

  renderValue: function(el, x, force) {

    // convert links data frame to d3 friendly format
    var links = HTMLWidgets.dataframeToD3(x.links);

    // compute the nodes from the links
    var nodes = {};
    links.forEach(function(link) {
            link.source = nodes[link.source] || (nodes[link.source] = {name: link.source});
            link.target = nodes[link.target] || (nodes[link.target] = {name: link.target});
      link.value = +link.value;
    });

    // get the width and height
    var width = el.offsetWidth;
    var height = el.offsetHeight;

    // create d3 force layout
    force
      .nodes(d3.values(nodes))
      .links(links)
      .size([width, height])
      .linkDistance(x.options.linkDistance)
      .charge(x.options.charge)
      .on("tick", tick)
      .start();

    // select the svg element and remove existing children
    var svg = d3.select(el).select("svg");
    svg.selectAll("*").remove();

    // draw links
    var link = svg.selectAll(".link")
      .data(force.links())
      .enter().append("line")
      .style("stroke", x.options.linkColour)
      .style("opacity", x.options.opacity)
      .style("stroke-width", "1.5px");

    // draw nodes
    var node = svg.selectAll(".node")
      .data(force.nodes())
      .enter().append("g")
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on("click", click)
      .on("dblclick", dblclick)
      .call(force.drag);

    // node circles
    node.append("circle")
      .attr("r", 8)
      .style("fill", x.options.nodeColour)
      .style("stroke", "#fff")
      .style("opacity", x.options.opacity)
      .style("stroke-width", "1.5px");

    // node text
    node.append("text")
      .attr("x", 12)
      .attr("dy", ".35em")
      .style("font", x.options.fontSize + "px serif")
      .style("fill", x.options.textColour)
      .style("opacity", x.options.opacity)
      .style("pointer-events", "none")
      .text(function(d) { return d.name; });

    // tick event handler
    function tick() {
      link
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
        node.attr("transform", function(d) {
          return "translate(" + d.x + "," + d.y + ")";
        });
    }

    // mouseover event handler
    function mouseover() {
      d3.select(this).select("circle").transition()
      .duration(750)
      .attr("r", 16);
    }

    // mouseout event handler
    function mouseout() {
      d3.select(this).select("circle").transition()
      .duration(750)
      .attr("r", 8);
    }

    // click event handler
    function click() {
      d3.select(this).select("text").transition()
        .duration(750)
        .attr("x", 22)
        .style("stroke-width", ".5px")
        .style("opacity", 1)
        .style("fill", x.options.nodeClickColour)
        .style("font", x.options.clickTextSize + "px serif");
      d3.select(this).select("circle").transition()
        .duration(750)
        .style("fill", x.options.nodeClickColour)
        .attr("r", 16)
    }

    // double-click event handler
    function dblclick() {
      d3.select(this).select("circle").transition()
        .duration(750)
        .attr("r", 6)
        .style("fill", x.options.nodeClickColour);
        d3.select(this).select("text").transition()
        .duration(750)
        .attr("x", 12)
        .style("stroke", "none")
        .style("fill", x.options.nodeClickColour)
        .style("stroke", "none")
        .style("opacity", x.options.opacity)
        .style("font", x.options.fontSize + "px serif");
    }
  },
});

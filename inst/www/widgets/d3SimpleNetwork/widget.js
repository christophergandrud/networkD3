HTMLWidgets.widget({
  
  name: "d3SimpleNetwork",
  
  type: "output",
  
  initialize: function(el) {
    return d3.layout.force();
  },
  
  renderValue: function(el, data, force) {
     
    // compute the nodes from the links
    var links = JSON.parse(data.links);
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
      .linkDistance(data.options.linkDistance)
      .charge(data.options.charge)
      .on("tick", tick)
      .start();

    // select the svg element
    var svg = d3.select(el)
      .attr("width", width)
      .attr("height", height);

    // draw links
    var link = svg.selectAll(".link")
      .data(force.links())
      .enter().append("line")
      .attr("class", "link");

    // draw nodes
    var node = svg.selectAll(".node")
      .data(force.nodes())
      .enter().append("g")
      .attr("class", "node")
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on("click", click)
      .on("dblclick", dblclick)
      .call(force.drag);

    // node circles
    node.append("circle")
      .attr("r", 8)
      .style("fill", data.options.nodeColour);

    // node text
    node.append("text")
      .attr("x", 12)
      .attr("dy", ".35em")
      .style("fill", data.options.textColour)
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
        .style("fill", data.options.nodeClickColour)
        .style("font", data.options.clickTextSize + "px serif");
      d3.select(this).select("circle").transition()
        .duration(750)
        .style("fill", data.options.nodeClickColour)
        .attr("r", 16)
    }

    // double-click event handler
    function dblclick() {
      d3.select(this).select("circle").transition()
        .duration(750)
        .attr("r", 6)
        .style("fill", data.options.nodeClickColour);
        d3.select(this).select("text").transition()
        .duration(750)
        .attr("x", 12)
        .style("stroke", "none")
        .style("fill", data.options.nodeClickColour)
        .style("stroke", "none")
        .style("opacity", data.options.opacity)
        .style("font", data.options.fontSize + "px serif");
    }
  },
  
  // sync size changes to the force layout
  resize: function(el, width, height, force) {  
     force.size([width, height]).resume();
  },
  
});


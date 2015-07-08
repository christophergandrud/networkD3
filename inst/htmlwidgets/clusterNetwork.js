HTMLWidgets.widget({

  name: "clusterNetwork",
  type: "output",

  initialize: function(el, width, height) {

    d3.select(el).append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g");
    
    return d3.layout.cluster();

  },

  resize: function(el, width, height, tree) {
    
    var s = d3.select(el).selectAll("svg")
      .attr("width", width)
      .attr("height", height);
    
    var margins = s.attr("margins");
    
    var top = parseInt(margins.top),
      right = parseInt(margins.right),
      bottom = parseInt(margins.bottom),
      left = parseInt(margins.left);

    height = height - top - bottom;
    width = width - right - left;

    if (s.attr("treeOrientation") == "horizontal") {
      tree.size([height, width]); 
    } else {
      tree.size([width, height]);
    }
    
    var svg = d3.select(el).selectAll("svg").select("g")
      .attr("transform", "translate(" + left + "," + top + ")");

  },

  renderValue: function(el, x, tree) {

    var s = d3.select(el).selectAll("svg")
      .attr("margins", x.options.margins)
      .attr("treeOrientation", x.options.treeOrientation);

    var top = parseInt(x.options.margins.top),
      right = parseInt(x.options.margins.right),
      bottom = parseInt(x.options.margins.bottom),
      left = parseInt(x.options.margins.left);

    var height = parseInt(s.attr("height")) - top - bottom,
      width = parseInt(s.attr("width")) - right - left;
    
    if (s.attr("treeOrientation") == "horizontal") {
      tree.size([height, width]); 
    } else {
      tree.size([width, height]);
    }

    var zoom = d3.behavior.zoom();

    var svg = d3.select(el).select("svg");
    svg.selectAll("*").remove();

    svg = svg
      .append("g").attr("class","zoom-layer")
      .append("g")
      .attr("transform", "translate(" + left + "," + top + ")");
      
    if (x.options.zoom) {
       zoom.on("zoom", function() {
         d3.select(el).select(".zoom-layer").attr("transform",
           "translate(" + d3.event.translate + ")"+
           " scale(" + d3.event.scale + ")");
       });

       d3.select(el).select("svg")
         .attr("pointer-events", "all")
         .call(zoom);
 
     } else {
       zoom.on("zoom", null);
     }

    var root = JSON.parse(x.root);
    
    var xs = [];   
    var ys = [];   
    function getXYfromJSONTree(node){           
       xs.push(node.x);          
       ys.push(node.y);           
       if(typeof node.children != 'undefined') {                   
          for (var j in node.children) {                           
             getXYfromJSONTree(node.children[j]);                   
          }           
       }   
    }   
    var ymax = Number.MIN_VALUE;   
    var ymin = Number.MAX_VALUE;
    
    getXYfromJSONTree(root);          
    var nodes = tree.nodes(root);           
    var links = tree.links(nodes);           
    nodes.forEach( function(d,i){                   
      if(typeof xs[i] != 'undefined') {                           
         d.x = xs[i];                   
      }                   
      if(typeof ys[i] != 'undefined') {                           
         d.y = ys[i];                   
      }           
    });           
    nodes.forEach( function(d) {                   
      if(d.y > ymax)
         ymax = d.y;
      if(d.y < ymin)                           
         ymin = d.y;           
    });
    
    if (s.attr("treeOrientation") == "horizontal") {
      fxinv = d3.scale.linear().domain([ymin, ymax]).range([0, width]);
      fx = d3.scale.linear().domain([ymax, ymin]).range([0, width]);
    } else {
      fxinv = d3.scale.linear().domain([ymin, ymax]).range([0, height]);
      fx = d3.scale.linear().domain([ymax, ymin]).range([0, height]);
    }

    // draw links
    var link = svg.selectAll(".link")
      .data(links)
      .enter().append("path")
      .style("fill", "none")
      .style("stroke", "#ccc")
      .style("opacity", "0.55")
      .style("stroke-width", "1.5px");
      
    if (x.options.linkType == "elbow") {
      if (s.attr("treeOrientation") == "horizontal") {
        link.attr("d", function(d, i) {
          return "M" + fx(d.source.y) + "," + d.source.x
            + "V" + d.target.x + "H" + fx(d.target.y);
        });
      } else {
        link.attr("d", function(d, i) {
          return "M" + d.source.x + "," + fx(d.source.y)
            + "H" + d.target.x + "V" + fx(d.target.y);
        });
      }
    } else {
      if (s.attr("treeOrientation") == "horizontal") {
        link.attr("d", d3.svg.diagonal()
          .projection(function(d) { return [fx(d.y), d.x]; }));
      } else {
        link.attr("d", d3.svg.diagonal()
          .projection(function(d) { return [d.x, fx(d.y)]; }));
      }
    }

    // draw nodes
    var node = svg.selectAll(".node")
      .data(nodes)
      .enter().append("g")
      .attr("class", "node")
      .on("mouseover", mouseover)
      .on("mouseout", mouseout);
      
    if (s.attr("treeOrientation") == "horizontal") {
      node.attr("transform", function(d) { return "translate(" + fx(d.y) + "," + d.x + ")"; });
    } else {
      node.attr("transform", function(d) { return "translate(" + d.x + "," + fx(d.y) + ")"; });
    }

    // node circles
    node.append("circle")
      .attr("r", 4.5)
      .style("fill", x.options.nodeColour)
      .style("opacity", x.options.opacity)
      .style("stroke", x.options.nodeStroke)
      .style("stroke-width", "1.5px");

    // node text
    node.append("text")
      .attr("transform", "rotate(" + x.options.textRotate + ")")
      .style("font", x.options.fontSize + "px serif")
      .style("opacity", function(d) { return d.textOpacity; })
      .style("fill", function(d) { return d.textColour; })
      .text(function(d) { return d.name; });
      
    if (s.attr("treeOrientation") == "horizontal") {
      node.select("text")
        .attr("dx", function(d) { return d.children ? -8 : 8; })
        .attr("dy", ".31em")
        .attr("text-anchor", function(d) { return d.children ? "end" : "start"; });
    } else {
      node.select("text")
        .attr("x", function(d) { return d.children ? -8 : 8; })
        .attr("dy", ".31em")
        .attr("text-anchor", "start");
    }

    // mouseover event handler
    function mouseover() {
      d3.select(this).select("circle").transition()
        .duration(750)
        .attr("r", 9);
        
      d3.select(this).select("text").transition()
        .duration(750)
        .style("stroke-width", ".5px")
        .style("font", "25px serif")
        .style("opacity", 1);
    }

    // mouseout event handler
    function mouseout() {
      d3.select(this).select("circle").transition()
        .duration(750)
        .attr("r", 4.5);
        
      d3.select(this).select("text").transition()
        .duration(750)
        .style("font", x.options.fontSize + "px serif")
        .style("opacity", x.options.opacity);
    }

  },
});

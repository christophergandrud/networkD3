var spaceForFuncNames = 240, // interpret the diameter of the pie as the width of the svg minus this number, which provides space for the text around the pie
    rotationHorizontalOffset = 340,
    rotationVerticalOffset = 160
    
HTMLWidgets.widget({
  name: "bundle",
  type: "output",
  initialize: function(el, width, height) {
    return {el: el, width: width, height: height}
  },
  renderValue: function(el, x, instance) {        
    // clear canvas in case renderValue is called several times per initialization
    $(el).html("")
    
    var min = instance.width
    if (min > instance.height) min = instance.height
    var diameter = min - spaceForFuncNames   
    
    var el = instance.el,    
    radius = diameter / 2,
    bonusBarLength = 0.5;     
    
    var svg = d3.select(el).append("svg") // if moving this to initialize:, make sure renderValue: deletes the <g> element directly below the svg at the start! (to reset rotation)
	.attr("width", instance.width)
	.attr("height", instance.height - 5)
    var g = svg.append("g")
	.attr("transform", "translate(" + min / 2 + "," + min / 2 + ")")
    
    var classes = JSON.parse(x.data)

    // create layout
    var cluster = d3.layout.cluster()
	.size([360, radius])
	.sort(null)
	.value(function(d) { return d.size; });
    var nodes = cluster.nodes(packageHierarchy(classes)),
	links = packageImports(nodes);
    var bundle = d3.layout.bundle();
    var line = d3.svg.line.radial()
	.interpolate("bundle")
	.tension(0.85)
	.radius(function(d) { return d.y; })
	.angle(function(d) { return d.x / 180 * Math.PI; });
    var link = g.append("g").attr("class", "gLink").selectAll(".link"),
	node = g.append("g").attr("class", "gNode").selectAll(".node");
        
    var arc = d3.svg.arc()
      .innerRadius(radius - 5)
      .outerRadius(radius + 5)
      .startAngle(function(d){return findStartAngle(d.data.children);})
      .endAngle(function(d){return findEndAngle(d.data.children);});
      
    var path = g.append("g").attr("class", "gPath").selectAll("path");    
    // Chrome 15 bug: <http://code.google.com/p/chromium/issues/detail?id=98951>
    var div = d3.select("#bundle")
	.style("width", diameter + "px")
	.style("height", diameter + "px")
	.style("position", "absolute");
    // use data and created layouts to form the meat of the svg
    link = link
	.data(bundle(links))
	.enter().append("path")
	.each(function(d) { d.source = d[0], d.target = d[d.length - 1]; })
	.attr("class", "link")
	.attr("d", line);
    node = node
	.data(nodes.filter(function(n) { return !n.children; }))
	.enter().append("g")
	.attr("class", "node")
	.attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + (d.y + 8) + ",0)" })
	.append("text").text(function(d) { return d.key; })	
	.attr("id", function(d,i) {
	  return d.key;
	  })
	.attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
	.attr("transform", function(d) { return d.x < 180 ? null : "rotate(180)"; })
	.attr("dy", ".31em")
	.on("mouseover", mouseovered)
	.on("mouseout", mouseouted)     
  
    // Lazily construct the package hierarchy from class names.
    function packageHierarchy(classes) {
      var map = {};
      function find(name, data) {
        var node = map[name], i;
        if (!node) {
        node = map[name] = data || {name: name, children: []};
        if (name.length) {
          node.parent = find(name.substring(0, i = name.lastIndexOf(".")));
          node.parent.children.push(node);
          node.key = name.substring(i + 1);
          }
        }
        return node;    
      }

      classes.forEach(function(d) {
        find(d.name, d);
      });

      return map[""];
    }
    // Return a list of imports for the given array of nodes.
    function packageImports(nodes) {
      var map = {},
	  imports = [];
      // Compute a map from name to node.
      nodes.forEach(function(d) {
	map[d.name] = d;
      });
      // For each import, construct a link from the source to target node.
      nodes.forEach(function(d) {
	if (d.imports) d.imports.forEach(function(i) {
	  imports.push({source: map[d.name], target: map[i]});
	});
      });
      return imports;
    }
    function findStartAngle(children) {
	var min = children[0].x;
	children.forEach(function(d){
	  if (d.x < min)
	      min = d.x;
    });
    return degToRad(min - bonusBarLength);
    }
    function findEndAngle(children) {
	var max = children[0].x;
	children.forEach(function(d){
	  if (d.x > max)
	      max = d.x;
    });
    return degToRad(max + bonusBarLength);
    }
    function degToRad(degrees){
      return degrees * (Math.PI/180);
    }
    d3.select(self.frameElement).style("height", diameter + "px");
    
    function mouseovered(d) {
      node
	  .each(function(n) { n.target = n.source = false; });
      link
	  .classed("link--target", function(l) { if (l.target === d) return l.source.source = true; })
	  .classed("link--source", function(l) { if (l.source === d) return l.target.target = true; })
	  .filter(function(l) { return l.target === d || l.source === d; })
	  .each(function() { this.parentNode.appendChild(this); });
      node
	  .classed("node--target", function(n) { return n.target; })
	  .classed("node--source", function(n) { return n.source; })
	  .classed("node--hovered", function(n) { return n === d});
    }
    function mouseouted(d) {
      link
	  .classed("link--target", false)
	  .classed("link--source", false);
      node
	  .classed("node--target", false)
	  .classed("node--source", false)
	  .classed("node--hovered", false);      
    }
    
    // rotation
    
    g.insert("svg:path", "g")
	.attr("class", "arc")
	.attr("id", "circleThatCatchesRotationClicks")
	.attr("d", d3.svg.arc().outerRadius(radius).innerRadius(0).startAngle(0).endAngle(2 * Math.PI))
	.on("mousedown", mousedown);
    
    var rotate = 0, m0
    d3.select(window)
	.on("mousemove", mousemove)
	.on("mouseup", mouseup);
    function mouse(e) {
      return [e.pageX - radius, e.pageY - radius];
    }
    function mousedown() {
      m0 = mouse(d3.event);
      d3.event.preventDefault();
    }
    function mousemove() {
      if (m0) {
	var m1 = mouse(d3.event),
	    dm = Math.atan2(cross(m0, m1), dot(m0, m1)) * 180 / Math.PI;
	g.attr("transform", "translate(" + min / 2 + "," + min / 2 + ")rotate(" + (dm + rotate) + ")")
      }
    }
    function mouseup() {
      if (m0) {
	var m1 = mouse(d3.event),
	    dm = Math.atan2(cross(m0, m1), dot(m0, m1)) * 180 / Math.PI;
	rotate += dm;
	if (rotate > 360) rotate -= 360;
	else if (rotate < 0) rotate += 360;
	m0 = null;
	    g.attr("transform", "translate(" + min / 2 + "," + min / 2 + ")rotate(" + rotate + ")")
	  .selectAll("g.node text")
	    //.attr("dx", function(d) { return (d.x + rotate) % 360 < 180 ? 8 : -8; })
	    .attr("text-anchor", function(d) { return (d.x + rotate) % 360 < 180 ? "start" : "end"; })
	    .attr("transform", function(d) { return (d.x + rotate) % 360 < 180 ? null : "rotate(180)"; });
      }
    }
    
//     function cross(a, b) {
//       return (a[0]) * (b[1]) - (a[1]) * (b[0]);
//     }
//     function dot(a, b) {
//       return (a[0]) * b[0] + (a[1]) * (b[1]);
//     }
    // hack: translate any click location to the left and up to simulate center location
    function cross(a, b) {
      return (a[0] - rotationHorizontalOffset) * (b[1] - rotationVerticalOffset) - (a[1] - rotationVerticalOffset) * (b[0] - rotationHorizontalOffset);
    }
    function dot(a, b) {
      return (a[0] - rotationHorizontalOffset) * (b[0] - rotationHorizontalOffset) + (a[1] - rotationVerticalOffset) * (b[1] - rotationVerticalOffset);
    }
    
    // endrotation
        
  },
  resize: function(el, width, height, force) {
    //for resizing I need to rework the svg to use viewbox
    //d3.select(el).select("svg")
    //.attr("width", width)
    //.attr("height", height);
    //force.size([width, height]).resume();
  }
})

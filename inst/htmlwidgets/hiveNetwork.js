HTMLWidgets.widget({

  name: "hiveNetwork",

  type: "output",

  initialize: function(el, width, height) {

    var svg = d3.select(el).append("svg")
        .attr("width", width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    return svg;
  },

  resize: function(el, width, height, instance) {

    //d3.select(el).select("svg")
    //    .attr("width", width)
    //    .attr("height", height + height * 0.05);
    //this.renderValue(el, instance.x, instance);
  },

  renderValue: function(el, x, svg) {

    // Convert radians to degrees
    function degrees(radians) {
      return radians / Math.PI * 180 - 90;
    }

    // get the width and height
    var width = el.offsetWidth;
    var height = el.offsetHeight;
    var innerRadius = 40;
    var outerRadius = Math.min(width, height)/2 - 20;
    
    var angle = d3.scale.ordinal().domain(d3.range(4)).rangePoints([0, 2 * Math.PI]),
        radius = d3.scale.linear().range([innerRadius, outerRadius]),
        color = d3.scale.category10().domain(d3.range(20));
    
    // alias options
    // var options = x.options;

    // convert links and nodes data frames to d3 friendly format
    var tmp = HTMLWidgets.dataframeToD3(x.links);
    var nodes = HTMLWidgets.dataframeToD3(x.nodes);
    
    // create links associative array from nodes
    var links = Array(tmp.length);
    for (var i = 0; i < tmp.length; i++) {
        // s = {"x" : nodes[tmp[i].source].Nodeaxis, "y" : nodes[tmp[i].source].Noderadius};
        // t = {"x" : nodes[tmp[i].target].Nodeaxis, "y" : nodes[tmp[i].target].Noderadius};
        links[i] = { "source" : nodes[tmp[i].source], "target" : nodes[tmp[i].target] };
    }
    
    // map elements
    svg.selectAll(".axis")
        .data(d3.range(3))
        .enter().append("line")
        .attr("class", "axis")
        .attr("transform", function(d) { return "rotate(" + degrees(angle(d)) + ")"; })
        .attr("x1", radius.range()[0])
        .attr("x2", radius.range()[1])
        .style("stroke", '#000')
        .style('stroke-width', '2px');

    svg.selectAll(".link")
        .data(links)
        .enter().append("path")
        .attr("class", "link")
        .attr("d", d3.hive.link()
        .angle(function(d) { return angle(d.x); })
        .radius(function(d) { return radius(d.y); }))
        // .style("stroke", function(d) { return color(d.target.x); })
        .style("stroke", "#000")
        .style('stroke-width', '0.5px')
        .style("fill", "none");
        
    svg.selectAll(".node")
        .data(nodes)
        .enter().append("circle")
        .attr("class", "node")
        .attr("transform", function(d) { return "rotate(" + degrees(angle(d.x)) + ")"; })
        .attr("cx", function(d) { return radius(d.y); })
        .attr("r", 5)
        .style("fill", function(d) { return color(d.x); })
        .style("stroke", '#000')
        .style("fill", function(d) { return color(d.Nodecolour); })
        
        .on("mouseenter", function(d) {
          d3.select(this)
            .transition()
            .duration(50)
            .style("stroke-width", 3)
            .attr("r", 10)
          
          d3.selectAll(".link")
            .data(links)
            .style("stroke-width", function (dl) {
                if(dl.source == d){
                  return 5;
                } else if(dl.target == d){
                  return 5;
                } else {
                  return 0.5;
                }
            })
            .style("stroke", function (dl) {
                if(dl.source == d){
                  return color(d.x);
                } else if(dl.target == d){
                  return color(d.x);
                } else {
                  return "#000";
                }
            });
        })
        
        .on("mouseleave", function(){
            d3.select(this)
              .transition()
              .duration(50)
              .style("stroke-width", 1.5)
              .attr("r", 5)
            
            d3.selectAll(".link")
              .style("stroke-width", 0.5)
              .style("stroke", "#000")
        });
  },
});

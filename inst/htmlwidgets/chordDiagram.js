HTMLWidgets.widget({

  name: "chordDiagram",
  type: "output",

  initialize: function(el, width, height) {

    var diameter = Math.min(parseInt(width),parseInt(height));

    d3.select(el).append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");

    return d3.layout.chord();
  },

  resize: function(el, width, height, chord) {
    var diameter = Math.min(parseInt(width),parseInt(height));
    d3.select(el).selectAll("svg")
      .attr("width", width).attr("height", height);
    d3.select(el).selectAll("svg").select("g")
      .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");
  },

  renderValue: function(el, x, chord) {

    // Returns an event handler for fading a given chord group.
    function fade(opacity) {
      return function(g, i) {
        s.selectAll(".chord path")
          .filter(function(d) { return d.source.index != i && d.target.index != i; })
          .transition()
          .style("opacity", opacity);
      };
    }

    var para = document.createElement("style");
    para.innerHTML = ".chord path { fill-opacity: "+x.options.initial_opacity+"; stroke: #000; stroke-width: .5px; }"
    document.getElementsByTagName("head")[0].appendChild(para);

    chord.padding(x.options.padding)
        .sortSubgroups(d3.descending)
        .matrix(x.matrix);

    var s = d3.select(el).select("g");
    var diameter = Math.min(parseInt(s.attr("width")),parseInt(s.attr("height")));
    var innerRadius = Math.min(x.options.width, x.options.height) * .41;
    var outerRadius = innerRadius * 1.1;

    var fill = x.options.colour_scale
          ?d3.scale.ordinal().domain(x.matrix.length).range(x.options.colour_scale)
          :(x.matrix.length>10?d3.scale.category20():d3.scale.category10());

    s.append("g").selectAll("path")
      .data(chord.groups)
      .enter().append("g")
      .attr("class", "pie-slice")
      .append("path")
      .style("fill", function(d) {
        return fill(d.index);
        })
      .style("stroke", function(d) { return fill(d.index); })
      .attr("d", d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius))
      .on("mouseover", fade(.1))
      .on("mouseout", fade(1));

    if(x.options.labels){
    d3.selectAll(".pie-slice")
    .append("text")
    .text(function(d) { return x.options.labels[d.index]; })
    .attr("transform", function(d){
        return "rotate("+((d.endAngle+d.startAngle)/2* 180 / Math.PI - 90)+")"+"translate("+(outerRadius+15)+",0)";
    });
  }

    var ticks = s.append("g").selectAll("g")
      .data(chord.groups)
      .enter().append("g").selectAll("g")
      .data(groupTicks)
      .enter().append("g")
      .attr("transform", function(d) {
        return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
            + "translate(" + outerRadius + ",0)";
      });

    ticks.append("line")
      .attr("x1", 1)
      .attr("y1", 0)
      .attr("x2", 5)
      .attr("y2", 0)
      .style("stroke", "#000");

    ticks.append("text")
      .attr("x", 8)
      .attr("dy", ".35em")
      .attr("transform", function(d) { return d.angle > Math.PI ? "rotate(180)translate(-16)" : null; })
      .style("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
      .style("font", x.options.font_size + "px " + x.options.font_family)
      .text(function(d) { return d.label; });

    s.append("g")
      .attr("class", "chord")
      .selectAll("path")
      .data(chord.chords)
      .enter().append("path")
      .attr("d", d3.svg.chord().radius(innerRadius))
      .style("fill", function(d) { return fill(d.target.index); })
      .style("fill-opacity", x.initial_opacity);

    function groupTicks(d) {
      var k = (d.endAngle - d.startAngle) / d.value;
      return d3.range(0, d.value, 1000).map(function(v, i) {
        return {
          angle: v * k + d.startAngle,
          label: i % 5 ? null : v / 1000 + "k"
        };
      });
    }

  },
});

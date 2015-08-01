HTMLWidgets.widget({

  name: "chordDiagram",
  type: "output",

  initialize: function(el, width, height) {

    var diameter = Math.min(parseInt(width),parseInt(height));
    d3.select(el).append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")"
                         + " scale("+diameter/800+","+diameter/800+")");
    return d3.layout.chord();

  },

  resize: function(el, width, height, chord) {
    var diameter = Math.min(parseInt(width),parseInt(height));
    var s = d3.select(el).selectAll("svg");
    s.attr("width", width).attr("height", height);
    chord.size([360, diameter/2 - parseInt(s.attr("margin"))]);
    var svg = d3.select(el).selectAll("svg").select("g");
    svg.attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")"
                         + " scale("+diameter/800+","+diameter/800+")");

  },

  renderValue: function(el, x, chord) {
    // x is a list with a matrix and a title

    var s = d3.select(el).selectAll("svg");
    var diameter = Math.min(parseInt(s.attr("width")),parseInt(s.attr("height")));
    
    chord.matrix(x.matrix);
    
  },
});


HTML.Widgets.widget({

    name: "treeNetwork",

    type: "output",

    initialize: function(el, width, height) {
        d3.select(el).append("svg")
            .attr("width", width)
            .attr("height", height);

        return d3.layout.tree();
    },

    resize: function(el, width, height, tree) {
        d3.select(el).select("svg")
            .attr("width", width)
            .attr("height", height);

        tree.size([width, height]).resume();
    },

    renderValue: function(el, x, tree) {

        // alias options
        var option = x.options;

        // get the width and height
        var width = el.offsetWidth;
        var height = el.offsetHeight;

        // create d3 tree layout
        tree
            .size([360, options.diameter / 2 - 120])
            .separation(function(a, b) {
                return (a.parent == b.parent ? 1 : 2) / a.depth; });

        //convert links and nodes from list to d3 friendly format
        var nodes = tree.nodes(HTMLWidgets.listToD3(x.root)),
            links = tree.links(nodes);

        // select the svg element and remove existing children
        var svg = d3.select(el).select("svg");
        svg.selectAll("*").remove();

        var diagonal = d3.svg.diagonal.radial()
            .projection(function(d) { return [d.y, d.x / 180 * Math.PI]; });

        var link = svg.selectAll(".link")
            .data(links)
            .enter().append("path")
            .attr("class", "link")
            .attr("d", diagonal);

        var node = svg.selectAll(".node")
            .data(nodes)
            .enter().append("g")
            .attr("class", "node")
            .attr("transform", function(d) { return "rotate(" + (d.x - 90) +
                ")translate(" + d.y + ")"; })
            .on("mouseover", mouseover)
            .on("mouseout", mouseout);

        node.append("circle")
            .attr("r", 4.5)
            .style("fill", "options.nodeColour");

        node.append("text")
            .attr("dy", ".31em")
            .attr("text-anchor", function(d) { return d.x < 180 ?
                "start" : "end"; })
            .attr("transform", function(d) { return d.x < 180 ?
                "translate(8)" : "rotate(180)translate(-8)"; })
            .style("fill", "options.textColour")
            .text(function(d) { return d.name; });

        function mouseover() {
            d3.select(this).select("circle").transition()
                .duration(750)
                .attr("r", 9);
            d3.select(this).select("text").transition()
                .duration(750)
                .attr("dy", ".31em")
                .attr("text-anchor", function(d) { return d.x < 180 ?
                    "start" : "end"; })
                .attr("transform", function(d) { return d.x < 180 ?
                    "translate(8)" : "rotate(180)translate(-8)"; })
                .style("stroke-width", ".5px")
                .style("font", options.fontsizeBig + "px serif")
                .style("opacity", 1);
        }

        function mouseout() {
            d3.select(this).select("circle").transition()
                .duration(750)
                .attr("r", 4.5);
            d3.select(this).select("text").transition()
                .duration(750)
                .attr("dy", ".31em")
                .attr("text-anchor", function(d) { return d.x < 180 ?
                    "start" : "end"; })
                .attr("transform", function(d) { return d.x < 180 ?
                    "translate(8)" : "rotate(180)translate(-8)"; })
                .style("font", options.fontsize + "px serif")
                .style("opacity", options.opacity);
        }

        d3.select(self.frameElement)
            .style("height", options.diameter - 150 + "px");

    },
});

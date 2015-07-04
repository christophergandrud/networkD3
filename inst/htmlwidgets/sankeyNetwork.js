HTMLWidgets.widget({

    name: "sankeyNetwork",

    type: "output",

    initialize: function(el, width, height) {

        d3.select(el).append("svg")
            .attr("width", width)
            .attr("height", height + height * 0.05);

        return {
          sankey: d3.sankey(),
          x: null
        };
    },

    resize: function(el, width, height, instance) {

        d3.select(el).select("svg")
            .attr("width", width)
            .attr("height", height + height * 0.05);

        this.renderValue(el, instance.x, instance);
    },

    renderValue: function(el, x, instance) {

        // save the x in our instance (for calling back from resize)
        instance.x = x;

        // alias sankey and options
        var sankey = instance.sankey;
        var options = x.options;

        // convert links and nodes data frames to d3 friendly format
        var links = HTMLWidgets.dataframeToD3(x.links);
        var nodes = HTMLWidgets.dataframeToD3(x.nodes);

        // get the width and height
        var width = el.offsetWidth;
        var height = el.offsetHeight;

        var color = eval(options.colourScale);

        var formatNumber = d3.format(",.0f"),
        format = function(d) { return formatNumber(d); }

        // create d3 sankey layout
        sankey
            .nodes(d3.values(nodes))
            .links(links)
            .size([width, height])
            .nodeWidth(options.nodeWidth)
            .nodePadding(options.nodePadding)
            .layout(32);

        // select the svg element and remove existing childern
        var svg = d3.select(el).select("svg");
        svg.selectAll("*").remove();

        // draw path
        var path = sankey.link();

        // draw links
        var link = svg.selectAll(".link")
            .data(sankey.links())
            .enter().append("path")
            .attr("class", "link")
            .attr("d", path)
            .style("stroke-width", function(d) { return Math.max(1, d.dy); })
            .style("fill", "none")
            .style("stroke", "#000")
            .style("stroke-opacity", 0.2)
            .sort(function(a, b) { return b.dy - a.dy; })
            .on("mouseover", function(d) {
                d3.select(this)
                .style("stroke-opacity", 0.5);
            })
            .on("mouseout", function(d) {
                d3.select(this)
                .style("stroke-opacity", 0.2);
            });

        // draw nodes
        var node = svg.selectAll(".node")
            .data(sankey.nodes())
            .enter().append("g")
            .attr("class", "node")
            .attr("transform", function(d) { return "translate(" +
                                            d.x + "," + d.y + ")"; })
            .call(d3.behavior.drag()
            .origin(function(d) { return d; })
            .on("dragstart", function() { this.parentNode.appendChild(this); })
            .on("drag", dragmove));


        link.append("title")
            .text(function(d) { return d.source.name + d.target.name +
                "\\n" + format(d.value); });

        node.append("rect")
            .attr("height", function(d) { return d.dy; })
            .attr("width", sankey.nodeWidth())
            .style("fill", function(d) {
                return d.color = color(d.name.replace(/ .*/, "")); })
            .style("stroke", function(d) { return d3.rgb(d.color).darker(2); })
            .style("opacity", 0.9)
            .style("cursor", "move")
            .append("title")
            .text(function(d) { return d.name + "\\n" + format(d.value); });

        node.append("svg:text")
            .attr("x", -6)
            .attr("y", function(d) { return d.dy / 2; })
            .attr("dy", ".35em")
            .attr("text-anchor", "end")
            .attr("transform", null)
            .text(function(d) { return d.name; })
            .style("font", options.fontSize + "px " + x.options.fontFamily)
            .filter(function(d) { return d.x < width / 2; })
            .attr("x", 6 + sankey.nodeWidth())
            .attr("text-anchor", "start");

        function dragmove(d) {
            d3.select(this).attr("transform", "translate(" + d.x + "," +
            (d.y = Math.max(0, Math.min(height - d.dy, d3.event.y))) + ")");
            sankey.relayout();
            link.attr("d", path);
        }
    },
});

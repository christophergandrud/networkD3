HTML.Widgets.widget({

    name: "treeNetwork",

    type: "output",

    initialize: function(el, width, height) {
        d3.select(el).append("svg")
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform",
            "translate(" + diameter / 2 + "," + diameter / 2 + ")");

        return d3.layout.tree();
    },

    resize: function(el, width, height, tree) {

    },

    renderValue: function(el, x, tree) {

        // alias options
        var option = x.options;

        //convert links and nodes from list to d3 friendly format
        var links =
        var nodes =

        // get the width and height
        var width = el.offsetWidth;
        var height = el.offsetHeight;

        // create d3 tree layout
        tree
            .

    },
});

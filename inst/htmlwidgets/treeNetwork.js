HTMLWidgets.widget({

  name: 'treeNetwork',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(x) {

        var svg = d3.select(el)
                    .append("svg")
                    .style("width", "100%")
                    .style("height", "100%");

        var duration = 800;

        var root = d3.stratify()
                     .id(function(d){ return d.nodeId; })
                     .parentId(function(d){ return d.parentId; })
                     (x.data);

        function mouseover(d) {
          return eval(x.options.mouseover)
        }

        function mouseout(d) {
          return eval(x.options.mouseout)
        }

        function symbolgen(name) {
          name = name == 'undefined' ? 'Circle' : name;
          name = name.charAt(0).toUpperCase() + name.substr(1).toLowerCase();
          name = ["Circle", "Cross", "Diamond", "Square", "Star", "Triangle", "Wye"].indexOf(name) == -1 ? "Circle" : name;
          return d3.symbol().type(d3['symbol' + name]);
        }

        var directions = {
          "down": {
            tree: (x.options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([width, height]),
            linkgen: d3.linkVertical().x(function(d) { return d.x; }).y(function(d) { return d.y; }),
            nodegen: function(d) { return "translate(" + d.x + "," + d.y + ")"; }
          },
          "left": {
            tree: (x.options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([height, width]),
            linkgen: d3.linkHorizontal().x(function(d) { return width - d.y; }).y(function(d) { return d.x; }),
            nodegen: function(d) { return "translate(" + (width - d.y) + "," + d.x + ")"; }
          },
          "up": {
            tree: (x.options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([width, height]),
            linkgen: d3.linkVertical().x(function(d) { return d.x; }).y(function(d) { return height - d.y; }),
            nodegen: function(d) { return "translate(" + d.x + "," + (height - d.y) + ")"; }
          },
          "right": {
            tree: (x.options.treeType === "tidy" ? d3.tree() : d3.cluster()).size([height, width - 100]),
            linkgen: d3.linkHorizontal().x(function(d) { return d.y; }).y(function(d) { return d.x; }),
            nodegen: function(d) { return "translate(" + d.y + "," + d.x + ")"; }
          },
          "radial": {
            tree: (x.options.treeType === "tidy" ? d3.tree() : d3.cluster())
                    .size([2 * Math.PI, Math.min(width,height) / 2])
                    .separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; }),
            linkgen: d3.linkRadial().angle(function(d) { return d.x; }).radius(function(d) { return d.y; }),
            nodegen: function(d) { return "translate(" + [(d.y = +d.y) * Math.cos(d.x -= Math.PI / 2), d.y * Math.sin(d.x)] + ")"; }
          }
        };

        // radial type needs to be centered on the canvas
        if (x.options.direction == "radial") {
          g = svg.append("g").attr("transform", "translate(" + (width / 2 + 40) + "," + (height / 2 + 90) + ")");
        } else {
          g = svg.append("g");
        }

        var tree = directions[x.options.direction].tree,
            linkgen = directions[x.options.direction].linkgen,
            nodegen = directions[x.options.direction].nodegen;

        if (x.options.linkType === "elbow") {
          var linkgen = function unobj(d) { return d3.line().curve(d3.curveStepBefore)(Object.keys(d).map(function(key) { return [d[key].y, d[key].x]; })); }
        }

        var linkgrp = g.append("g").attr("class", "linkgrp");
        var nodegrp = g.append("g").attr("class", "nodegrp");

        root.x0 = height / 2;
        root.y0 = 0;

        window.x = x; window.directions = directions; window.tree = tree, window.width = width; window.height = height; // for testing
        update(root);

        function update(source) {
          var treeData = tree(root);

          if (treeData.descendants().reduce(function(a, b) { return typeof b.data.height !== 'undefined' && a; }, true)) {
            var ymax = d3.max(treeData.descendants(), function(d) { return d.data.height || d.height; });
            var ymin = d3.min(treeData.descendants(), function(d) { return d.data.height || d.height; });
            heightToY = d3.scaleLinear().domain([ymax, ymin]).range([0, width]);
            treeData.eachAfter(function(d) { d.y = heightToY(d.data.height || d.height); });
          }

          var nodes = treeData.descendants(),
              links = treeData.links(nodes);

          // Update the links…
          var link = linkgrp.selectAll(".link")
              .data(links, function(d) { return d.target.id; });

          // Enter any new links at the parent's previous position.
          var linkEnter = link.enter().insert("path", "g")
              .attr("class", "link")
              .style("fill", "none")
              .style("stroke", function(d){ return d.target.data.linkColour; })
              .style("stroke-opacity", 0.4)
              .style("stroke-width", function(d){ return d.target.data.linkWidth; })
              .attr("d", function(d) {
                var o = {x: source.x0, y: source.y0};
                return linkgen({source: o, target: o});
              });

          // Transition links to their new position.
          var linkUpdate = linkEnter.merge(link);
          linkUpdate.transition()
              .duration(duration)
              .attr("d", linkgen);

          // Transition exiting nodes to the parent's new position.
          link.exit().transition()
              .duration(duration)
              .attr("d", function(d) {
                var o = {x: source.x, y: source.y};
                return linkgen({source: o, target: o});
              })
              .remove();

          var node = nodegrp.selectAll(".node").data(nodes, function(d,i) { return d.id || (d.id = ++i); });

          nodeEnter = node.enter()
              .append("g")
              //.attr("name", function(d){ return d.data.nodeName; })
              .attr("class", "node")
              .attr("transform", function(d){ return typeof source !== 'undefined' ? nodegen({x: source.x0, y: source.y0}) : nodegen(d); })
              .on("click", click)
              .on("mouseover", mouseover)
              .on("mouseout", mouseout)
              .attr('cursor', function(d){ return d.children || d._children ? "pointer" : "default"; });

          nodeEnter.append("path")
              //.attr("name", function(d){ return d.data.nodeName; })
              //.style("fill", function(d){ return d._children ? d.data.nodeStroke : d.data.nodeColour;})
              .style("fill", function(d){ return d._children ? d.data.nodeStroke : 'white';})
              //.style("fill-opacity", 1e-6)
              .style("opacity", 1e-6)
              .style("stroke", function(d){ return d.data.nodeStroke; })
              .style("stroke-width", "1.5px")
              .attr("d", function(d){ return symbolgen(d.data.nodeSymbol).size(Math.pow(d.data.nodeSize, 2))(); });

          nodeEnter.append("text")
              .attr("transform", "rotate(" + x.options.textRotate + ")")
              .style("font-family", function(d){ return d.data.nodeFont; })
              .style("font-size", "1px")
              .style("opacity", function(d){ return d.data.textOpacity; })
              .style("fill", function(d){ return d.data.textColour; })
              .text(function(d){ return d.data.name; });

          var nodeUpdate = nodeEnter.merge(node);

          nodeUpdate.transition()
              .duration(duration)
              .attr("transform", nodegen);

          nodeUpdate.select("path")
              .transition()
              .duration(duration)
              .style("opacity", 1)
              //.style("fill", function(d){ return d._children ? d.data.nodeStroke : d.data.nodeColour; })
              .style("fill", function(d){ return d._children ? d.data.nodeStroke : 'white'; })
              //.style("fill-opacity", function(d){ return d._children ? 0.8 : 1e-6; })
              //.style("fill-opacity", function(d){ return d._children ? 1 : 1; });

          nodeUpdate.select("text")
              .transition()
              .duration(duration)
              .style("font-size", function(d){ return d.data.nodeFontSize + "px"; });

          var nodeExit = node.exit();

          nodeExit.transition("exittransition")
              .duration(duration)
              .attr("transform", function(d){ return nodegen(source); })
              .remove();

          nodeExit.select('path')
              .transition("exittransition")
              .duration(duration)
              .style('fill', 1e-6)
              .style('fill-opacity', 1e-6)
              //.attr("d", symbolgen().size(1e-6))
              .attr("d", d3.symbol().type(d3.symbolCircle).size(1e-6));

          nodeExit.select('text')
              .transition("exittransition")
              .duration(duration)
              .style('opacity', 1e-6);

          nodes.forEach(function(d){
              d.x0 = d.x;
              d.y0 = d.y;
          });
        }

        function click(d) {
          if (d.children) {
            d._children = d.children;
            d.children = null;
          } else {
            d.children = d._children;
            d._children = null;
          }
          update(d);
        }

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});

HTMLWidgets.widget({

  name: "radialNetwork",
  type: "output",

  initialize: function(el, width, height) {

    var diameter = Math.min(parseInt(width),parseInt(height));
    d3.select(el).select(".tree-container").append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")"
                         + " scale("+diameter/800+","+diameter/800+")");
    return d3.layout.tree();

  },

  resize: function(el, width, height, tree) {
    /*
    diameter = Math.min(parseInt(width),parseInt(height));
    s = d3.select(el).selectAll("svg");
    s.attr("width", width).attr("height", height);
    tree.size([360, diameter/2 - parseInt(s.attr("margin"))]);
    svg = d3.select(el).selectAll("svg").select("g");
    svg.attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")"
                         + " scale("+diameter/800+","+diameter/800+")");
                         
    */

  },

  renderValue: function(el, x, tree) {
    // x is a list with three elements: root, options, tasks   
    
    el = d3.select(el)
    

    var defaults = {
      DURATION : 700, // d3 animation duration
      STAGGERN : 4, // delay for each node
      STAGGERD : 200, // delay for each depth
      NODE_DIAMETER : 4, // diameter of circular nodes
      MIN_ZOOM : 0.5, // minimum zoom allowed
      MAX_ZOOM : 10,  // maximum zoom allowed
      HAS_CHILDREN_COLOR : 'lightsteelblue',
      SELECTED_COLOR : '#a00',  // color of selected node
      ZOOM_INC : 0.04,  // zoom factor per animation frame
      PAN_INC : 3,  //  pan per animation frame
      ROT_INC : 0.3  // rotation per animation frame
    }
    
    // overwrite defaults with x.options if provided
    if( x.options !== "undefined"  && x.options.length > 0 ){
      Object.keys( x.options ).map(function(key){
        defaults[key] = x.options[key]
      })
    }
  
    var counter = 0;  // node ids
    var curNode;  // currently selected node
    var curPath;  // array of nodes in the path to the currently selected node
    
    
    
    
    
    // define the svgBase, attaching a class for styling and the zoomListener
    var svgBase = el.select('svg')
      .on('mousedown', mousedown);
  

      
  
    // size of the diagram
    var width = svgBase.attr("width") - 20
    var height = svgBase.attr("height") - 20;
  
    // current pan, zoom, and rotation
    var curX = width / 2;
    var curY = height / 2;
    var curZ = 1.0; // current zoom
    var curR = 270; // current rotation
    
    // Group which holds all nodes and manages pan, zoom, rotate
    var svgGroup = svgBase.append('g')
      .attr('transform', 'translate(' + curX + ',' + curY + ')');    
  
    // keyboard key codes
    var KEY_PLUS = 187;     // + (zoom in)
    var KEY_MINUS = 189;    // - (zoom out)
    var KEY_SLASH = 191;    // / (slash)
    var KEY_PAGEUP = 33;    // (rotate CCW)
    var KEY_PAGEDOWN = 34;  // (rotate CW)
    var KEY_LEFT = 37;      // left arrow
    var KEY_UP = 38;        // up arrow
    var KEY_RIGHT = 39;     // right arrow
    var KEY_DOWN = 40;      // down arrow
    var KEY_SPACE = 32;     // (expand node)
    var KEY_RETURN = 13;    // (expand tree)
    var KEY_HOME = 36;      // (center root)
    var KEY_END = 35;       // (center selection)
  
    // d3 diagonal projection for use by the node paths
    diagonal= d3.svg.diagonal.radial()
      .projection(function(d) {
          return [d.y, d.x / 180 * Math.PI];
      });
  
    // d3 tree layout
    tree
      // .nodeSize([4.5, 120])
      .size([360, Math.min(width, height) / 2 - 120])
      .separation(function(a, b) {
        return a.depth === 0 ? 1 : (a.parent === b.parent ? 1 : 2) / a.depth;
      });
  
    el // set up document events
      .on('wheel', wheel)  // zoom, rotate
      .on('keydown', keydown)
      .on('keyup', keyup);

    el.selectAll('.button')
      .on('mousedown', tooldown)
      .on('mouseup', toolup);
    el.select('.selection').on('mousedown', switchroot);
    // el.select('.contextmenu').on('mouseup', menuSelection);
  
    // Define the data root
    var root = x.root;
    root.x0 = curY;
    root.y0 = 0;
    selectNode(root); // current selected node
  
    // Collapse all children of root's children before rendering
    // if (root.children) {
    //   root.children.forEach(function(child) {
    //       collapseTree(child);
    //   });
    // }
  
    update(root, true); // Layout the tree initially and center on the root node
  
    // update the tree
    // source - source node of the update
    // transition - whether to do a transition
    function update(source, transition) {
  
      var duration = transition ?
        (d3.event && d3.event.altKey ? defaults.DURATION * 4 : defaults.DURATION) : 0;
  
      // Compute the new tree layout.
      var nodes = tree.nodes(root);
      var links = tree.links(nodes);
  
      // Update the view
      svgGroup.transition().duration(duration)
        .attr('transform',
          'rotate(' + curR + ' ' + curX + ' ' + curY +
          ')translate(' + curX + ' ' + curY +
          ')scale(' + curZ + ')');
  
      // Update the nodesâ€¦
      node = svgGroup.selectAll('g.node')
        .data(nodes, function(d) {
          return d.id || (d.id = ++counter);
        });
  
      // Enter any new nodes at the parent's previous position
      nodeEnter = node.enter().insert('g', ':first-child')
          .attr('class', 'node')
          .attr('transform', 'rotate(' + (source.x0 - 90) + ')translate(' + source.y0 + ')')
          .on('click', click).on('dblclick', dblclick) //.on('contextmenu', showContextMenu);
          // .on('mousedown', suppress);
  
      nodeEnter.append('circle')
        .attr('r', 1e-6)
        .style('fill', function(d) {
          return d._children ? defaults.HAS_CHILDREN_COLOR : 'white';
        });
  
      nodeEnter.append('text')
        .text(function(d) {
          return d.name;
        })
        .style('opacity', 0.9)
        .style('fill-opacity', 0)
        .attr('transform', function() {
            return ((source.x0 + curR) % 360 <= 180 ?
                'translate(8)scale(' :
                'rotate(180)translate(-8)scale('
              ) + reduceZ() + ')';
        });
  
      // update existing graph nodes
  
      // Change the circle fill depending on whether it has children and is collapsed
      node.select('circle')
        .attr('r', defaults.NODE_DIAMETER * reduceZ())
        .style('fill', function(d) {
            return d._children ? defaults.HAS_CHILDREN_COLOR : 'white';
        }).attr('stroke', function(d) {
            return d.selected ? defaults.SELECTED_COLOR : 'steelblue';
        }).attr('stroke-width', function(d) {
            return d.selected ? 3 : 1.5;
        });
  
      node.select('text')
        .attr('text-anchor', function(d) {
            return (d.x + curR) % 360 <= 180 ? 'start' : 'end';
        }).attr('transform', function(d) {
            return ((d.x + curR) % 360 <= 180 ?
                'translate(8)scale(' :
                'rotate(180)translate(-8)scale('
              ) + reduceZ() +')';
        }).attr('fill', function(d) {
            return d.selected ? defaults.SELECTED_COLOR : 'black';
        }).attr('dy', '.35em');
  
      nodeUpdate = node.transition().duration(duration)
        .delay( transition ? function(d, i) {
            return i * defaults.STAGGERN +
              Math.abs(d.depth - curNode.depth) * defaults.STAGGERD; }  : 0)
        .attr('transform', function(d) {
            return 'rotate(' + (d.x - 90) + ')translate(' + d.y + ')';
        });
  
      nodeUpdate.select('circle')
        .attr('r', defaults.NODE_DIAMETER * reduceZ());
        // .style('fill', function(d) {
        //   return d._children ? defaults.HAS_CHILDREN_COLOR : 'white';
        // });
  
      nodeUpdate.select('text')
        .style('fill-opacity', 1);
  
      // Transition exiting nodes to the parent's new position and remove
      nodeExit = node.exit().transition().duration(duration)
        .delay( transition ? function(d, i) {
            return i * defaults.STAGGERN; } : 0)
        .attr('transform', function() {
          return 'rotate(' + (source.x - 90) +')translate(' + source.y + ')';
      }).remove();
  
      nodeExit.select('circle').attr('r', 0);
      nodeExit.select('text').style('fill-opacity', 0);
  
      // Update the links
      link = svgGroup.selectAll('path.link')
        .data(links, function(d) {
          return d.target.id;
        });
  
      // Enter any new links at the parent's previous position
      link.enter().insert('path', 'g')
          .attr('class', 'link')
          .attr('d', function() {
          o = {
              x: source.x0,
              y: source.y0
          };
          return diagonal({
              source: o,
              target: o
          });
      });
  
      // Transition links to their new position
      link.transition().duration(duration)
        .delay( transition ? function(d, i) {
            return i * defaults.STAGGERN +
              Math.abs(d.source.depth - curNode.depth) * defaults.STAGGERD;
              // Math.max(0, d.source.depth - curNode.depth) * defaults.STAGGERD;
            } : 0)
        .attr('d', diagonal);
  
      // Transition exiting nodes to the parent's new position
      link.exit().transition().duration(duration)
          .attr('d', function() {
            o = {
              x: source.x0,
              y: source.y0
            };
            return diagonal({
              source: o,
              target: o
            });
        }).remove();
  
      // Stash the old positions for transition
      nodes.forEach(function(d) {
        d.x0 = d.x;
        d.y0 = d.y;
      });
    } // end update
  
    // Helper functions for collapsing and expanding nodes
  
    // Toggle expand / collapse
    function toggle(d) {
      if (d.children) {
        d._children = d.children;
        d.children = null;
      } else if (d._children) {
        d.children = d._children;
        d._children = null;
      }
    }
  
    function toggleTree(d) {
      if (d.children) {
        collapseTree(d);
      } else {
        expandTree(d);
      }
    }
  
    function expand(d) {
      if (d._children) {
        d.children = d._children;
        d._children = null;
      }
    }
  
    // expand all children, whether expanded or collapsed
    function expandTree(d) {
      if (d._children) {
        d.children = d._children;
        d._children = null;
      }
      if (d.children) {
        d.children.forEach(expandTree);
      }
    }
  
    function collapse(d) {
      if (d.children) {
        d._children = d.children;
        d.children = null;
      }
    }
  
    // collapse all children
    function collapseTree(d) {
      if (d.children) {
        d._children = d.children;
        d.children = null;
      }
      if (d._children) {
        d._children.forEach(collapseTree);
      }
    }
  
    // expand one level of tree
    function expand1Level(d) {
      var q = [d]; // non-recursive
      var cn;
      var done = null;
      while (q.length > 0) {
        cn = q.shift();
        if (done !== null && done < cn.depth) { return; }
        if (cn._children) {
          done = cn.depth;
          cn.children = cn._children;
          cn._children = null;
          cn.children.forEach(collapse);
        }
        if (cn.children) { q = q.concat(cn.children); }
      }
      // no nodes to open
    }
  
    // highlight selected node
    function selectNode(node) {
      if (curNode) {
        delete curNode.selected;
      }
      curNode = node;
      curNode.selected = true;
      curPath = []; // filled in by fullpath
      el.select('.selection').html(fullpath(node));
    }
  
    // for displaying full path of node in tree
    function fullpath(d, idx) {
      idx = idx || 0;
      curPath.push(d);
      return (d.parent ? fullpath(d.parent, curPath.length) : '') +
        '/<span class="nodepath'+(d.name === root.name ? ' highlight' : '')+
        '" data-sel="'+ idx +'" title="Set Root to '+ d.name +'">' +
        d.name + '</span>';
    }
  
    // d3 event handlers
  
    function switchroot() {
      d3.event.preventDefault();
      var pathelms = document.querySelectorAll('.selection .nodepath');
      for (i = 0; i < pathelms.length; i++) {
        pathelms[i].classList.remove('highlight');
      }
      var target = d3.event.target;
      var node = curPath[+target.dataset.sel];
      if (d3.event.shiftKey) {
        if (curNode !== node) {
          selectNode(node);
        }
      } else {
        root = node;
        target.classList.add('highlight');
      }
      update(root, true);
    }
  
    function resize() { // window resize
      oldwidth = width;
      oldheight = height;
      width = window.innerWidth - 20;
      height = window.innerHeight - 20;
      tree.size([360, Math.min(width, height) / 2 - 120]);
      svgBase.attr('width', width).attr('height', height);
      curX += (width - oldwidth) / 2;
      curY += (height - oldheight) / 2;
      svgGroup.attr('transform', 'rotate(' + curR + ' ' + curX + ' ' + curY +
          ')translate(' + curX + ' ' + curY + ')scale(' + curZ + ')');
      update(root);
    }
  
    function click(d) { // select node
      if (d3.event.defaultPrevented || d === curNode) { return; } // suppressed
      d3.event.preventDefault();
      selectNode(d);
      update(d);
    }
  
    function dblclick(d) {  // Toggle children of node
      if (d3.event.defaultPrevented) { return; } // click suppressed
      d3.event.preventDefault();
      if (d3.event.shiftKey) {
        expand1Level(d); // expand node by one level
      } else {
        toggle(d);
      }
      update(d, true);
    }
  
    function tooldown(d) {  // tool button pressed
      d3.event.preventDefault();
      d3.select(d3.event.target).on('mouseout', toolup);
      key = +d3.event.target.dataset.key;
      keydown(Math.abs(key), key < 0 || d3.event.shiftKey);
    }
  
    function toolup() {  // tool button released
      d3.event.preventDefault();
      d3.select(d3.event.target).on('mouseout', null);
      keyup(Math.abs(+d3.event.target.dataset.key));
    }
  
    // right click, show context menu and select this node
    function showContextMenu(d) {
      d3.event.preventDefault();
      el.selectAll('.expcol').text(d.children ? 'Collapse' : 'Expand');
      el.select('.contextmenu').style({
        left: (d3.event.pagex + 3) + 'px',
        top: (d3.event.pagey + 8) + 'px',
        display: 'block'
      });
      el.on('mouseup', hideContextMenu);
      selectNode(d);
      update(d);
    }
    
    function hideContextMenu() {
      el.select('.contextmenu').style('display', 'none');
      el.on('mouseup', null);
    }
  
    function menuSelection() {
      d3.event.preventDefault();
      key = +d3.event.target.dataset.key;
      keydown(Math.abs(key), key < 0 || d3.event.shiftKey);
    }
  
    var startposX, startposY; // initial position on mouse button down for pan
  
    function mousedown() {  // pan
      d3.event.preventDefault();
      if (d3.event.which !== 1 || d3.event.ctrlKey) { return; } // ingore other mouse buttons
      startposX = curX - d3.event.clientX;
      startposY = curY - d3.event.clientY;
      el.on('mousemove', mousemove, true);
      el.on('mouseup', mouseup, true);
    }
  
    function mousemove() {
      d3.event.preventDefault();
      curX = startposX + d3.event.clientX;
      curY = startposY + d3.event.clientY;
      setview();
    }
  
    function mouseup() {
      el.on('mousemove', null);
      el.on('mouseup', null);
    }
  
    var keysdown = [];  // which keys are currently down
    var moveX = 0, moveY = 0, moveZ = 0, moveR = 0; // animations
    var aniRequest = null;
  
    function wheel() {  // mousewheel
      var dz, newZ;
      var slow = d3.event.altKey ? 0.25 : 1;
      if (d3.event.wheelDeltaY !== 0) {  // up-down
        dz = Math.pow(1.2, d3.event.wheelDeltaY * 0.001 * slow);
        newZ = limitZ(curZ * dz);
        dz = newZ / curZ;
        curZ = newZ;
  
        curX -= (d3.event.clientX - curX) * (dz - 1);
        curY -= (d3.event.clientY - curY) * (dz - 1);
        setview();
      }
      if (d3.event.wheelDeltaX !== 0) {  // left-right
        curR = limitR(curR + d3.event.wheelDeltaX * 0.01 * slow);
        update(root);
      }
    }
  
    // keyboard shortcuts
    function keydown(key, shift) {
      if (!key) {
        key = d3.event.which;  // fake key
        shift = d3.event.shiftKey;
      }
      var parch; // parent's children
      var slow = d3.event.altKey ? 0.25 : 1;
      if (keysdown.indexOf(key) >= 0) { return; } // defeat auto repeat
      switch (key) {
        case KEY_PLUS: // zoom in
          moveZ = defaults.ZOOM_INC * slow;
          break;
        case KEY_MINUS: // zoom out
          moveZ = -defaults.ZOOM_INC * slow;
          break;
        case KEY_SLASH: // toggle root to selection
          root = root === curNode ? treeData : curNode;
          update(root, true);
          curPath = []; // filled in by fullpath
          el.select('.selection').html(fullpath(curNode));
          return;
        case KEY_PAGEUP: // rotate counterclockwise
          moveR = -defaults.ROT_INC * slow;
          break;
        case KEY_PAGEDOWN: // zoom out
          moveR = defaults.ROT_INC * slow; // rotate clockwise
          break;
        case KEY_LEFT: // left arrow
          if (shift) { // move selection to parent
            if (!curNode) {
              selectNode(root);
            } else if (curNode.parent) {
              selectNode(curNode.parent);
            }
            update(curNode);
            return;
          }
          moveX = -defaults.PAN_INC * slow;
          break;
        case KEY_UP: // up arrow
          if (shift) { // move selection to previous child
            if (!curNode) {
              selectNode(root);
            } else if (curNode.parent) {
              parch = curNode.parent.children;
              selectNode(parch[(parch.indexOf(curNode) +
                  parch.length - 1) % parch.length]);
            }
            update(curNode);
            return;
          }
          moveY = -defaults.PAN_INC * slow;
          break;
        case KEY_RIGHT: // right arrow
          if (shift) { // move selection to first/last child
            if (!curNode) {
              selectNode(root);
            } else {
              if (curNode.children) {
                selectNode(curNode.children[d3.event.altKey ?
                    curNode.children.length - 1 : 0]);
              }
            }
            update(curNode);
            return;
          }
          moveX = defaults.PAN_INC * slow;
          break;
        case KEY_DOWN: // down arrow
          if (shift) { // move selection to next child
            if (!curNode) {
              selectNode(root);
            } else if (curNode.parent) {
              parch = curNode.parent.children;
              selectNode(parch[(parch.indexOf(curNode) + 1) % parch.length]);
            }
            update(curNode);
            return;
          }
          moveY = defaults.PAN_INC * slow;
          break;
        case KEY_SPACE: // expand/collapse node
          if (!curNode) {
            selectNode(root);
          }
          toggle(curNode);
          update(curNode, true);
          return;
        case KEY_RETURN: // expand/collapse tree
          if (!curNode) {
            selectNode(root);
          }
          if (shift) {
            expandTree(curNode);
          } else {
            expand1Level(curNode);
          }
          update(curNode, true);
          return;
        case KEY_HOME: // reset transform
          if (shift) {
            root = treeData;
          }
          curX = width / 2;
          curY = height / 2;
          curR = limitR(90 - root.x);
          curZ = 1;
          update(root, true);
          return;
        case KEY_END: // zoom to selection
          if (!curNode) { return; }
          curX = width / 2 - curNode.y * curZ;
          curY = height / 2;
          curR = limitR(90 - curNode.x);
          update(curNode, true);
          return;
        default: return;  // ignore other keys
      } // break jumps to here
      keysdown.push(key);
      // start animation if anything happening
      if (keysdown.length > 0 && aniRequest === null) {
        aniRequest = requestAnimationFrame(frame);
      }
    }
  
    function keyup(key) {
      key = key || d3.event.which;
      pos = keysdown.indexOf(key);
      if (pos < 0) { return; }
  
      switch (key) {
        case KEY_PLUS: // zoom out
        case KEY_MINUS: // zoom in
          moveZ = 0;
          break;
        case KEY_PAGEUP: // rotate CCW
        case KEY_PAGEDOWN: // rotate CW
          moveR = 0;
          break;
        case KEY_LEFT: // left arrow
        case KEY_RIGHT: // right arrow
          moveX = 0;
          break;
        case KEY_UP: // up arrow
        case KEY_DOWN: // down arrow
          moveY = 0;
          break;
      }
      keysdown.splice(pos, 1);  // remove key
      if (keysdown.length > 0 || aniRequest === null) { return; }
      cancelAnimationFrame(aniRequest);
      aniRequest = aniTime = null;
    }
  
    var aniTime = null;
  
    // update animation frame
    function frame(frametime) {
      var diff = aniTime ? (frametime - aniTime) / 16 : 0;
      aniTime = frametime;
  
      dz = Math.pow(1.2, diff * moveZ);
      newZ = limitZ(curZ * dz);
      dz = newZ / curZ;
      curZ = newZ;
      curX += diff * moveX - (width / 2- curX) * (dz - 1);
      curY += diff * moveY - (height / 2 - curY) * (dz - 1);
      curR = limitR(curR + diff * moveR);
      setview();
      aniRequest = requestAnimationFrame(frame);
    }
  
    // enforce zoom extent
    function limitZ(z) {
      return Math.max(Math.min(z, defaults.MAX_ZOOM), defaults.MIN_ZOOM);
    }
  
    // keep rotation between 0 and 360
    function limitR(r) {
      return (r + 360) % 360;
    }
  
    // limit size of text and nodes as scale increases
    function reduceZ() {
      return Math.pow(1.1, -curZ);
    }
  
    // set view with no animation
    function setview() {
        svgGroup.attr('transform', 'rotate(' + curR + ' ' + curX + ' ' + curY +
            ')translate(' + curX + ' ' + curY + ')scale(' + curZ + ')');
        svgGroup.selectAll('text')
            .attr('text-anchor', function(d) {
                return (d.x + curR) % 360 <= 180 ? 'start' : 'end';
            })
            .attr('transform', function(d) {
                return ((d.x + curR) % 360 <= 180 ?
                    'translate(8)scale(' :
                    'rotate(180)translate(-8)scale('
                  ) + reduceZ() +')';
            });
        svgGroup.selectAll('circle').attr('r', defaults.NODE_DIAMETER * reduceZ());
    }
    
    
    
    // set up a container for tasks to perform after completion
    //  one example would be add callbacks for event handling
    //  styling
    if (!(typeof x.tasks === "undefined") ){
      if ( (typeof x.tasks.length === "undefined") ||
       (typeof x.tasks === "function" ) ) {
         // handle a function not enclosed in array
         // should be able to remove once using jsonlite
         x.tasks = [x.tasks];
      }
      x.tasks.map(function(t){
        // for each tasks add it to the mermaid.tasks with el
        t.call(el);
      })
    }     
  }
});

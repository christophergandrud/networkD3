> All changes to networkD3 are documented here.

> Additions referenced with relevant [GitHub Issue](https://github.com/christophergandrud/networkD3/issues) or
[Pull Request](https://github.com/christophergandrud/networkD3/pulls) number.
Please see those for more details.

# 0.4

## Major changes

- Highlights links to nodes on hover in `forceNetwork`. pull/#178

- Arrow heads enabled for directed networks in `forceNetwork` with
`arrows = TRUE`. pull/#182.

## Minor changes and bug fixes

- Node titles enclosed in `<pre>` tags. pull/#180

- `simpleNetwork` now an alias of `forceNetwork` rather than separate. pull/#181

- Resolved regression from d3.js V4 upgrade where `forceNetwork` graphs were
not centered in Shiny apps. pull/#179

- Updated URL links in documentation.

# 0.3.1

- Improved examples for d3.js v4+

# 0.3

- Upgraded to d3.js version 4.5.0 from version 3.5.2. HUGE thanks to CJ Yetman
who did basically all of the work for this. #143


# 0.2.14

- Explose `sinksRight` option for `sankeyNetwork` so that users can decide
not to have the last nodes moved to the right border. Thanks to Florian
Breitwieser.

# 0.2.13

- `simpleNetwork`, `forceNetwork`, and `sankeyNetwork` should now work with
`tbl_df` link and node data frames. Thanks to @mexindian for suggesting.

# 0.2.12

- Add resize to sankeyNetwork for flexdashboard. Thanks to Kenton Russell for
adding.

- Fixed a bug where `Source` and `Target` labels were not properly concatenated
in `sankeyNetwork` tooltips. Thanks to Tuija Sonkkila for reporting.

- Improved `igraph_to_networkD3` so that it now handles more general weight
names. Thanks to Maurits Evers for reporting.

# 0.2.11

- `forceNetwork`, `simpleNetwork`, and `sankeyNetwork` generate errors if data
does not appear to be zero-indexed. Thanks to Peter Meissner for prompting this
addition.

- Bug fix for `igraph_to_networkD3` so that it now accepts the value attribute.
Thanks to Louis Goddard.

- Bug fix for `diagonalNetwork` when using hierarchical lists with singular
connections. Thanks to @RohdeK.

- Fix viewbox position when rerendered in shiny. Thanks to @RohdeK.

- Added the `iterations` argument to `sankeyNetwork`, which adjusts the y-axis
positioning. Thanks to @giko45.

# 0.2.10

- Added the function `igraph_to_networkD3` to convert an `igraph` class object
to a list that can be used with networkD3.

- Fixed a bug where `linkColour` was not actually passed to the widget for
`diagonalNetwork` and `radialNetwork`. Thanks to Pierre Formont.

# 0.2.9

- `forceNetwork` now allows you to supply a vector of colours to the
`linkColour`argument. This enables the user to highlight links to specific
nodes. Thanks to Garth Tarr.

- Minor documentation improvements.

# 0.2.8

- Added `NodeGroup` and `LinkGroup` parameters to `sankeyNetwork` so links
can be colourised. Thanks to Edwin de Jonge.

- `fontFamily` is now applied to legends in `forceNetwork`. Thanks to Casey
Shannon.

- Improved bounding behaviour with `forceNetwork`. Now bounds both the links and
nodes. Thanks to Koba Khitalishvili.

# 0.2.7

- Fixed an issue with sankey viewBox sizing.

# 0.2.6

- `sankeyNetwork` fully supports cycles

- `sankeyNetwork` gets same responsive sizing and better fitting introduced
in 0.2.4 for `diagonalNetwork` and `radialNetwork`.

- `sankeyNetwork` gets same full margin control introduced
in 0.2.4 for `diagonalNetwork` and `radialNetwork`.

# 0.2.5

- Added `chordDiagram` to show directed relationships among entities.

# 0.2.4

- More robust margin argument for `diagonalNetwork` and `radialNetwork` allows
for a single value or specification of `top`, `right`, `bottom`, and `left` by
named `vector` or `list`.

- Responsive sizing using the `viewBox` attribute of `svg` for `diagonalNetwork`
and `radialNetwork` should allow for fitting in the container with no fiddling.

## 0.2.3

- Internal improvements to reduce dependencies: no longer depends on RCurl,
plyr, and rjson.

- Updated examples:

 + Using jsonlite makes JSONtoDF obsolete with the `fromJSON` function.

 + All Github data links now use the CDN link from
  [rawgit](https://rawgit.com/), so the examples should be more inline with
  Github raw policies.

## 0.2.2

- `sankeyNetwork` changes:

    + Removes forced font family in favor of inherited from css or specified
    through the `fontFamily` argument.

    + Fixes issue with backslashes in the label for links.

    + Puts unicode right arrow in the tooltip.
    Adds argument to specify units for the tooltip label.

    + Handles cycles by updating this forked repo: <https://github.com/soxofaan/d3-plugin-captain-sankey>.

    + Makes assumptions that `Source` is column 1 and `Target` is column 2 if
    not provided.

## 0.2.1

- Fixed an issue with `forceNetwork` on Firefox. Thanks to @agoldst.

- Fixed an issue where `forceNetwork` node size would not return to
default after mouseover. Thanks to Pascal Pernot.

## 0.2

- Added `dendroNetwork` to create hierarchical cluster network diagrams
(dendrograms).

- `treeNetwork` is DEPRECATED.

- Placed functionality from `treeNetwork` to `radialNetwork`. The new
`radialNetwork` function has the same functionality, but has been renamed to be
more accurately descriptive and avoid confusion with `dendroNetwork`.

- Added `diagonalNetwork`, which creates tree network diagrams using diagonal
instead of radial nodes.

Thanks to Jonathan Owen.

## 0.1.8

- Added `clickAction` argument to `forceNetwork` to allow the user to
pass a JavaScript expression through to be activated on click of a node.
Thanks to Peter Ellis.

- Added `bounded` argument to `forceNetwork` to allow the user to create a
bounding box for the plot. See http://bl.ocks.org/mbostock/1129492.
Thanks to Charles Sese.

- Added `fontFamily` argument to `forceNetwork`, `simpleNetwork`,
`sankeyNetwork`, and `treeNetwork`. Thanks to Peter Ellis.

- Added `opacityNoHover` argument to `forceNetwork` to set the opacity of node
labels when nodes are not hovered over. Thanks to Peter Ellis.

## 0.1.7

- Include `JS` from htmlwidgets, to make it easier for users to pass arbitrary
JS to more arguments.

- Other internal code and documentation improvements.

## 0.1.6

- `fontSize` used for all functions rather than `fontsize`. Thank you to
@Hunter-Github for spotting this inconsistency.

## 0.1.5

- Minor improvement to treeNetwork documentation.
Thanks to Steven Beaupré and MrFlick.

## 0.1.4

- `forceNetwork` gains three new arguments.

    + `legend` allows you to add a node colour legend.

    + `radiusCalculation` and `Nodesize` allow you to vary node radius by
some values.

Thank you to Charles Sese for these additions.

## 0.1.3

- `zoom` argument added to `simpleNetwork` and `forceNetwork` to allow zooming.
Thanks to @timelyportfolio.

- Updated `treeNetwork` URL.

## 0.1.2.2

- Update link in `forceNetwork` example.

## 0.1.2.1

Enhanced flexibility when using data frames manipulated with dplyr/data.table.
Thanks to Kevin Kuo.

## 0.1.2

- Minor internal correction to d3.js version number.

## 0.1.1

- `treeNetwork` added allowing the user to create tree networks. Thanks to
B.W. Lewis.

- Upgrade to d3.js version 3.5.2.

## 0.1

- `sankeyNetwork` added.

- `colourScale` argument added to `forceNetwork` and `sankeyNetwork` to allow
the user to change the node colour scale.
#' Create radial network diagrams.
#'
#' @param List a hierarchical \code{list} object with a root node and children.
#' @param options \code{list} of options for the \code{radialNetwork}.
#' @param tasks \code{list} of \code{htmlwidgets::JS} functions to perform after the 
#'          the radialNetwork is rendered.
#' @param height height for the network graph's frame area in pixels (if
#'   \code{NULL} then height is automatically determined based on context)
#' @param width numeric width for the network graph's frame area in pixels (if
#'   \code{NULL} then width is automatically determined based on context)
#'   
#' @export

radialNetwork <- function(
  List
  , options = list()
  , tasks = NULL
  , width = NULL
  , height = NULL
){
  
  
  # create widget
  htmlwidgets::createWidget(
    name = "radialNetwork",
    x = list(root = List, options = options, tasks = tasks ),
    width = width,
    height = height,
    htmlwidgets::sizingPolicy(#viewer.suppress = TRUE,
                              browser.fill = TRUE,
                              browser.padding = 75,
                              knitr.figure = FALSE,
                              knitr.defaultWidth = 800,
                              knitr.defaultHeight = 500),
    package = "networkD3")
}

#' custom html function for radialNetwork
#' 
#' @import htmltools

radialNetwork_html <- function(id, style, class, ...){
  tags$div(
    id = id, style = style, class = class
    ,htmltools::HTML(
'
<div class="tree-container"></div>

<div class="toolbar">
<div class="tool">
<div class="tlabel">zoom</div>
<div class="tbuttons">
<div class="button" data-key="187" title="Zoom In (+ OR scrollwheel)">+</div>
<div class="button" data-key="189" title="Zoom Out (&minus; OR scrollwheel)">&minus;</div>
</div>
</div>
<div class="tool">
<div class="tlabel">rotate</div>
<div class="tbuttons">
<div class="button" data-key="33" title="Rotate CCW (Page Up OR &#8679;scrollwheel)" style="font-size:0.9em">&#8634;</div>
<div class="button" data-key="34" title="Rotate CW (Page Down OR &#8679;scrollwheel)" style="font-size:0.9em">&#8635;</div>
</div>
</div>
<div class="tool">
<div class="tlabel">select</div>
<div class="tbuttons">
<div class="button" data-key="-38" title="Select Previous (&#8679;&uarr;)" style="font-size:0.9em">&#8613;</div>
<div class="button" data-key="-40" title="Select Next (&#8679;&darr;)" style="font-size:0.9em">&#8615;</div>
</div>
</div>
<div class="tool">
<div class="tlabel">view</div>
<div class="tbuttons">
<div class="button" data-key="36" title="Center Root (Home)">&#8962;</div>
<div class="button" data-key="35" title="Center Selected (End)" style="font-size:0.8em">&#9673;</div>
</div>
</div>
<div class="tool">
<div class="tlabel">toggle</div>
<div class="tbuttons">
<div class="button" data-key="32" title="Toggle Node (Space OR double-click)">1</div>
<div class="button" data-key="13" title="Toggle Level (Return OR &#8679;double-click)">&oplus;</div>
<div class="button" data-key="191" title="Toggle Root (/)">/</div>
</div>
</div>
<div class="tool">
<div class="tlabel" style="text-align:left" title="Change Root">&nbsp;selection</div>
<div class="selection" class="tlabel"></div>
</div>
</div>

<div class="contextmenu">
<div data-key="32"><span class="expcol">Expand</span> Node</div>
<div data-key="13">Expand 1 Level</div>
<div data-key="-13">Expand Full Tree</div>
<div data-key="35">Center This Node</div>
<div data-key="36">Center Root</div>
<div data-key="191">Set Root</div>
</div>
'
    )
  )
}

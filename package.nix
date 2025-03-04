{ pkgs ? import <nixpkgs> {}, displayrUtils }:

pkgs.rPackages.buildRPackage {
  name = "networkD3";
  version = displayrUtils.extractRVersion (builtins.readFile ./DESCRIPTION); 
  src = ./.;
  description = ''Creates 'D3' 'JavaScript' network, tree, dendrogram, and Sankey
    graphs from 'R'.'';
  propagatedBuildInputs = with pkgs.rPackages; [ 
    htmlwidgets
    jsonlite
    magrittr
    igraph
    data_tree
 ];

}

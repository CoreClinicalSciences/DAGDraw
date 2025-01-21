BuildBaseGraph <- function(toData, treatment, response, transportability = FALSE) {
   if(transportability) {
      baseList <- c(treatment, response, "Participation")
   } else {
      baseList <- c(treatment, response)
   }
   
   conditionedNodes <- toData %>%
      filter(conditioned) %>%
      pull(name) %>%
      unique()
   
   unmeasuredNodes <- toData %>%
      filter(unmeasured) %>%
      pull(name) %>%
      unique()
   
   coloredNodes <- c(conditionedNodes, unmeasuredNodes, baseList)
   
   # Create the base graph
   firstGraph <- create_graph() %>%
      add_nodes_from_df_cols(
         df = toData,
         columns = c("name")
      ) %>%
      add_edges_from_table(
         table = toData,
         from_col = name,
         to_col = to,
         from_to_map = label
      ) %>%
      select_nodes() %>%
      set_node_attrs_ws(node_attr = fixedsize, value = FALSE) %>%
      set_node_attrs_ws(node_attr = shape, value = "rectangle") %>%
      set_node_attrs_ws(node_attr = font, value = "Open Sans") %>%
      clear_selection() %>%
      mutate_node_attrs(base = if_else(label %in% baseList, TRUE, FALSE)) %>%
      select_nodes(conditions = base) %>%
      set_node_attrs_ws(node_attr = fillcolor, value = baseNodeFillColor) %>%
      set_node_attrs_ws(node_attr = color, value = baseNodeOutlineColor) %>%
      set_node_attrs_ws(node_attr = fontcolor, value = baseNodeFontColor) %>%
      clear_selection()
   
   # Color the conditioned Nodes if there are any
   if (length(conditionedNodes) > 0) {
      firstGraph <- firstGraph %>%
         mutate_node_attrs(conditioned = if_else(label %in% conditionedNodes, TRUE, FALSE)) %>%
         select_nodes(conditions = conditioned) %>%
         set_node_attrs_ws(node_attr = fillcolor, value = conditionedFillColor) %>%
         set_node_attrs_ws(node_attr = color, value = conditionedOutlineColor) %>%
         set_node_attrs_ws(node_attr = fontcolor, value = conditionedFontColor) %>%
         clear_selection()
   }
   
   if (length(unmeasuredNodes) > 0) {
      firstGraph <- firstGraph %>%
         mutate_node_attrs(unmeasured = if_else(label %in% unmeasuredNodes, TRUE, FALSE)) %>%
         select_nodes(conditions = unmeasured) %>%
         set_node_attrs_ws(node_attr = fillcolor, value = unmeasuredNodeFillColor) %>%
         set_node_attrs_ws(node_attr = color, value = unmeasuredNodeOutlineColor) %>%
         set_node_attrs_ws(node_attr = fontcolor, value = unmeasuredNodeFontColor) %>%
         clear_selection()
   }
   
   # If there are more than the conditioned and base nodes make the color white
   if (length(unique(toData$name)) != length(coloredNodes)) {
      firstGraph <- firstGraph %>%
         mutate_node_attrs(notBase = if_else(label %in% coloredNodes, FALSE, TRUE)) %>%
         select_nodes(conditions = notBase) %>%
         set_node_attrs_ws(node_attr = fillcolor, value = setFillColor) %>%
         set_node_attrs_ws(node_attr = color, value = setOutlineColor) %>%
         set_node_attrs_ws(node_attr = fontcolor, value = setFontColor) %>%
         clear_selection()
   }
   
   return(firstGraph)
}

# creates the legend 
DAGLegend <- function() {
   legendGraph <- create_graph() %>%
      add_node(label = "conditioned",
               node_aes = node_aes(
                  fontcolor = conditionedFontColor,
                  fillcolor = conditionedFillColor,
                  color = conditionedOutlineColor,
                  fixedsize = FALSE,
                  shape = "rectangle"
               )) %>%
      add_node(label = "unmeasured",
               node_aes = node_aes(
                  fontcolor = unmeasuredNodeFontColor,
                  fillcolor = unmeasuredNodeFillColor,
                  color = unmeasuredNodeOutlineColor,
                  shape = "rectangle",
                  fixedsize = FALSE
               ))
   
   return(legendGraph)
}

## Effect Modifiers ---------------------------------------------------

# addEffectModifiersToGraph <- function( graph, effectModifiers ){
#    # Color the effect modifiers
#    if(length(effectModifiers > 0)) {
#       graph <- graph %>%
#          mutate_node_attrs(effectModifier = if_else(label %in% effectModifiers, TRUE, FALSE)) %>%
#          select_nodes(conditions = effectModifier) %>%
#          set_node_attrs_ws(node_attr = color, value = effectModifierOutlineColor) %>%
#          clear_selection()
#    }
#    return(graph)
# }

addEffectModifiersToGraph <- function(graph, effectModifiers) {
   # Return early if no graph or no effect modifiers
   if (is.null(graph) || length(effectModifiers) == 0) {
      return(graph)
   }
   
   # Get all node labels from the graph
   node_labels <- get_node_df(graph)$label
   
   # Filter effectModifiers to only include nodes that exist in the graph
   valid_modifiers <- effectModifiers[effectModifiers %in% node_labels]
   
   if (length(valid_modifiers) > 0) {
      graph <- graph %>%
         mutate_node_attrs(
            effectModifier = if_else(label %in% valid_modifiers, TRUE, FALSE)
         ) %>%
         select_nodes(conditions = effectModifier) %>%
         set_node_attrs_ws(node_attr = color, value = effectModifierOutlineColor) %>%
         clear_selection()
   }
   
   return(graph)
}


## Path Visualization -------------------------------------------------

# Adds an open path (shown in RED)
AddOpenPathToGraph <- function( graph, pathDF, width = 0.3 ) {
   graph <- RemovePathFromGraph(graph, pathDF)
   graph <- AddPathToGraph(graph, pathDF)
   for (i in 1:nrow(pathDF)) {
      graph <- graph %>%
         add_edge(
            from = pathDF$name[i], to = pathDF$to[i],
            edge_aes = edge_aes(
               color = "red",
               arrowhead = "none",
               penwidth = width
            )
         )
   }
   
   return(graph)
}

# Adds a basic edge to graph from a path Data Frame
AddPathToGraph <- function( graph, pathDF ) {
   for (i in 1:nrow(pathDF)) {
      graph <- graph %>%
         add_edge(
            from = pathDF$name[i], to = pathDF$to[i],
         )
   }
   
   return(graph)
}

# Removes all edges on a path from the graph
RemovePathFromGraph <- function( graph, pathDF ) {
   for (i in 1:nrow(pathDF)) {
      graph <- graph %>%
         delete_edge(
            from = pathDF$name[i], to = pathDF$to[i]
         )
   }
   
   return(graph)
}
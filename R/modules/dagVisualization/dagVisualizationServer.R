dagVisualizationServer <- function(
      id, 
      toDataStorage, 
      treatment,
      response, 
      highlightedPathList, 
      isTransportability,
      dagDownloads, 
      backdoorShow, 
      effectModifierShow,
      layout
) {
   moduleServer(id, function(input, output, session) {
      ns <- session$ns
      
      # Reactive values
      reactiveGraph <- reactiveVal(NULL)
      causalPathList <- reactiveVal(NULL)
      showWarning <- reactiveVal(FALSE)
      legendGraph <- reactiveVal(NULL)  
      buttonHighlightStates <- reactiveVal(list())
      
      # Initialize legend
      observe({
         legendGraph(DAGLegend())
         dagDownloads$legend <- legendGraph()
      })
      
      # Render legend
      output$dagLegend <- renderGrViz({
         req(legendGraph())
         render_graph(legendGraph(), layout = "kk")
      })
      
      # Create the simple graph as a reactive
      firstGraphSimple <- reactive({
         BuildBaseGraph(
            toDataStorage$data, 
            treatment(), 
            response(), 
            isTransportability()
         )
      })
      
      # Main observe block
      observe({
         effectModifiers <- FindEffectModifiers(toDataStorage$data, response())
         
         if(!"effectModifier" %in% names(toDataStorage$data)) {
            toDataStorage$data$effectModifier <- FALSE
         }
         
         toDataStorage$data <- toDataStorage$data %>%
            mutate(
               effectModifier = if_else(name %in% effectModifiers, TRUE, FALSE),
               name = as.character(name),
               to = as.character(to)
            ) %>%
            mutate(across(
               where(is.logical),
               ~if_else(is.na(.), FALSE, .)
            ))
         
         firstGraph <- BuildBaseGraph(
            toDataStorage$data, 
            treatment(),
            response(), 
            isTransportability()
         )
         
         dagDownloads$dag <- firstGraph
         
         openPaths <- FindOpenPaths(toDataStorage$data, treatment(), response())
         causalPaths <- FindCausalPaths(openPaths)
         
         conditionedNodes <- toDataStorage$data %>%
            filter(conditioned) %>%
            pull(name) %>%
            unique()
         
         selectionBiasPaths <- FindSelectionBiasPaths(openPaths, conditionedNodes)
         causalPaths <- c(causalPaths, selectionBiasPaths)
         
         # Store previous highlighted paths that are still valid
         currentHighlighted <- highlightedPathList()
         validHighlighted <- currentHighlighted[currentHighlighted %in% causalPaths]
         highlightedPathList(validHighlighted)
         
         output$conditioningWarning <- renderUI({
            if(length(selectionBiasPaths) > 0) {
               p("Warning: You are conditioning on a collider")
            }
         })
         
         fullEdgeDf <- data.frame()
         for (path in causalPaths) {
            edgeDf <- PathStringToDF(path)
            fullEdgeDf <- rbind(fullEdgeDf, edgeDf) %>% unique()
         }
         
         if (nrow(fullEdgeDf) > 0) {
            firstGraph <- AddOpenPathToGraph(firstGraph, fullEdgeDf)
         }
         
         # Add highlighting for paths that are still valid
         if (length(validHighlighted) > 0) {
            highlightedEdgeDf <- data.frame()
            for (path in validHighlighted) {
               edgeDf <- PathStringToDF(path)
               highlightedEdgeDf <- rbind(highlightedEdgeDf, edgeDf) %>% unique()
            }
            if (nrow(highlightedEdgeDf) > 0) {
               firstGraph <- AddOpenPathToGraph(firstGraph, highlightedEdgeDf, 1)
            }
         }
         
         unmeasuredNodes <- toDataStorage$data %>% filter(unmeasured)
         if (any(fullEdgeDf$name %in% unmeasuredNodes$name) ||
             any(fullEdgeDf$to %in% unmeasuredNodes$name)) {
            showWarning(TRUE)
         } else {
            showWarning(FALSE)
         }
         
         simpleGraph <- firstGraphSimple()
         reactiveGraph(firstGraph)
         causalPathList(causalPaths)
         dagDownloads$backdoorDag <- firstGraph
         dagDownloads$dag <- simpleGraph
         
         # Update button highlight states for valid paths
         current_states <- buttonHighlightStates()
         new_states <- list()
         for (path in validHighlighted) {
            if (!is.null(current_states[[path]])) {
               new_states[[path]] <- TRUE
            }
         }
         buttonHighlightStates(new_states)
      })
      
      # Separate observe block for effect modifiers
      observe({
         req(toDataStorage$data)
         req("effectModifier" %in% names(toDataStorage$data))
         
         effectModifiers <- toDataStorage$data %>%
            filter(effectModifier == TRUE) %>%
            pull(name) %>%
            unique()
         
         if (backdoorShow()) {
            baseGraph <- if(effectModifierShow()) {
               addEffectModifiersToGraph(reactiveGraph(), effectModifiers)
            } else {
               reactiveGraph()
            }
            
            output$coloredDag <- renderGrViz({
               req(baseGraph)
               render_graph(
                  baseGraph %>%
                     add_global_graph_attrs("rankdir", "LR", attr_type = "graph"),
                  layout = layout()
               )
            })
            
         } else {
            baseGraph <- if(effectModifierShow()) {
               addEffectModifiersToGraph(firstGraphSimple(), effectModifiers)
            } else {
               firstGraphSimple()
            }
            
            output$coloredDag <- renderGrViz({
               req(baseGraph)
               render_graph(
                  baseGraph %>%
                     add_global_graph_attrs("rankdir", "LR", attr_type = "graph"),
                  layout = layout()
               )
            })
         }
      })
      
      # Initialize path buttons module
      pathButtonsResults <- pathButtonsServer(
         "pathButtons",
         toDataStorage,
         causalPathList,
         reactiveGraph,
         highlightedPathList,
         buttonHighlightStates,
         backdoorShow,
         showWarning
      )
   })
}

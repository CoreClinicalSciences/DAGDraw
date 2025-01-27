ccsLogo <- "www/CCSlogo.png"
dagdrawLogo <- "www/DAGDraw-Logo.png"

getCurrentDag <- function(state) {
   isolate({
      # Get effect modifiers if needed
      if (state$effectModifierShow()) {
         effectModifiers <- state$toDataStorage$data %>%
            filter(effectModifier)
         effectModifiers <- unique(as.list(effectModifiers$name))
         
         # Create base graph
         if (state$backdoorShow()) {
            base_graph <- state$dagDownloads$backdoorDag
         } else {
            base_graph <- state$dagDownloads$dag
         }
         
         # Add effect modifiers
         graph <- addEffectModifiersToGraph(base_graph, effectModifiers)
      } else {
         # Just use the appropriate base graph
         if (state$backdoorShow()) {
            graph <- state$dagDownloads$backdoorDag
         } else {
            graph <- state$dagDownloads$dag
         }
      }
      
      # Add layout direction
      graph <- graph %>%
         add_global_graph_attrs("rankdir", "LR", attr_type = "graph")
      
      return(graph)
   })
}

getDagRCode <- function(toDataStorage, dagDownloads){
   observe({
      dagString <- DataToDag(toDataStorage$data)
      dagDownloads$RCode <- dagString
   })
}

validateState <- function(state) {
   if (!state$appState$initialized) {
      stop("Application state not initialized")
   }
}

setupDowloadHandler <- function(output, state) {
   output$downloadDag <- downloadHandler(
      filename = function() {
         validateState(state)
         paste0("DAGDraw ", format(Sys.time(), "%Y-%m-%d %H%M%S"), ".pdf")
      },
      content = function(file) {
         tempReport <- file.path(tempdir(), "report.Rmd")
         tempImage <- file.path(tempdir(), "dag.png")
         file.copy("dag_download_template.Rmd", tempReport, overwrite = TRUE)
         
         # Get current DAG and save as PNG
         current_graph <- getCurrentDag(state)
         
         # Ensure the graph is oriented top to bottom
         current_graph <- current_graph %>%
            add_global_graph_attrs("rankdir", "TB", attr_type = "graph")
         
         svg_content <- DiagrammeRsvg::export_svg(
            render_graph(current_graph, layout = state$layout())
         )
         
         temp_svg <- tempfile(fileext = ".svg")
         writeLines(svg_content, temp_svg)
         rsvg::rsvg_png(temp_svg, tempImage, width = 1200)
         
         params <- list(
            ccsLogo = normalizePath(ccsLogo),
            dagdrawLogo = normalizePath(dagdrawLogo),
            dagImage = tempImage
         )
         
         rmarkdown::render(tempReport, output_file = file,
                           params = params,
                           envir = new.env(parent = globalenv())
         )
      }
   )
}
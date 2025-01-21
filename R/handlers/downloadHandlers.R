getDagRCode <- function(toDataStorage, dagDownloads){
   observe({
      dagString <- DataToDag(toDataStorage$data)
      dagDownloads$RCode <- dagString
   })
}

setupDownloadHandlers <- function(output, state) {
   # Common validation function
   validateState <- function() {
      if (!state$appState$initialized) {
         stop("Application state not initialized")
      }
   }
   
   # Helper function to get current graph
   getCurrentGraph <- function() {
      # Need to use isolate() since we're inside a downloadHandler
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
   
   # SVG Download Handler
   output$downloadSVG <- downloadHandler(
      filename = function() {
         validateState()
         paste0("dag-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".svg")
      },
      content = function(file) {
         validateState()
         tryCatch({
            current_graph <- getCurrentGraph()
            
            # Convert to SVG using DiagrammeRsvg
            svg_content <- DiagrammeRsvg::export_svg(
               render_graph(current_graph, layout = state$layout())
            )
            
            # Clean up the SVG content (remove px units)
            svg_content <- gsub('px"', '"', svg_content)
            
            # Write to file
            writeLines(svg_content, file)
         }, error = function(e) {
            message(sprintf("Error exporting SVG: %s", e$message))
            stop("Failed to generate SVG download")
         })
      },
      contentType = "image/svg+xml"
   )
   
   # PNG Download Handler
   output$downloadPNG <- downloadHandler(
      filename = function() {
         validateState()
         paste0("dag-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".png")
      },
      content = function(file) {
         validateState()
         tryCatch({
            current_graph <- getCurrentGraph()
            
            # Create temporary SVG file
            temp_svg <- tempfile(fileext = ".svg")
            on.exit(unlink(temp_svg))
            
            # Convert to SVG first
            svg_content <- DiagrammeRsvg::export_svg(
               render_graph(current_graph, layout = state$layout())
            )
            writeLines(svg_content, temp_svg)
            
            # Convert SVG to PNG
            rsvg::rsvg_png(temp_svg, file, width = 1200)
         }, error = function(e) {
            message(sprintf("Error exporting PNG: %s", e$message))
            stop("Failed to generate PNG download")
         })
      },
      contentType = "image/png"
   )
   
   # Legend Download Handler
   output$legendDownload <- downloadHandler(
      filename = function() {
         validateState()
         paste0("dagLegend-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".png")
      },
      content = function(file) {
         validateState()
         tryCatch({
            legend_graph <- DAGLegend()
            
            # Create temporary SVG file
            temp_svg <- tempfile(fileext = ".svg")
            on.exit(unlink(temp_svg))
            
            # Convert to SVG first
            svg_content <- DiagrammeRsvg::export_svg(
               render_graph(legend_graph, layout = "kk")
            )
            writeLines(svg_content, temp_svg)
            
            # Convert SVG to PNG
            rsvg::rsvg_png(temp_svg, file, width = 400)
         }, error = function(e) {
            message(sprintf("Error exporting legend: %s", e$message))
            stop("Failed to generate legend download")
         })
      },
      contentType = "image/png"
   )
}
dagVisualizationUI <- function(id) {
   ns <- NS(id)
   
   tagList(
      shinyjs::useShinyjs(),
      grVizOutput(ns("coloredDag"), width = "100%", height = "500px"),
      uiOutput(ns("conditioningWarning")),
      div(
         style = "position: absolute; top: 0; left: 0; margin: 0; padding: 0;",
         grVizOutput(ns("dagLegend"), height = 125, width = 190)
      ),
      # Add the path buttons UI
      pathButtonsUI(ns("pathButtons"))
   )
}
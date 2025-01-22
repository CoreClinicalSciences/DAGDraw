dagVisualizationUI <- function(id) {
   ns <- NS(id)
   
   tagList(
      shinyjs::useShinyjs(),
      div(
         style = "margin: 75px 0 15px; width: 100%; height: auto;",
         grVizOutput(ns("coloredDag"), width = "auto", height = "75vh"),
      ),
      uiOutput(ns("conditioningWarning")),
      div(
         style = "position: absolute; top: 0; left: 0; z-index: 1; margin: 0; padding: 0;",
         grVizOutput(ns("dagLegend"), height = 70, width = 200)
      ),
      # Add the path buttons UI
      pathButtonsUI(ns("pathButtons"))
   )
}
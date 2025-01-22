dagVisualizationUI <- function(id) {
   ns <- NS(id)
   
   tagList(
      shinyjs::useShinyjs(),
      div(
         style = "margin-top: 25px; width: 100%; height: auto; max-height: 55vh",
         grVizOutput(ns("coloredDag"), width = "auto", height = "55vh"),
      ),
      uiOutput(ns("conditioningWarning")),
      div(
         style = "position: absolute; top: 0; left: 0; margin: 0; padding: 0;",
         grVizOutput(ns("dagLegend"), height = 70, width = 200)
      ),
      # Add the path buttons UI
      pathButtonsUI(ns("pathButtons"))
   )
}
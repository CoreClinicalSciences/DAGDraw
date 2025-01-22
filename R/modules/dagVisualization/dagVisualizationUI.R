dagVisualizationUI <- function(id) {
   ns <- NS(id)
   
   tagList(
      shinyjs::useShinyjs(),
      div(
         style = "position: relative; width: 100%; height: 100%; display: flex; flex-direction: column;",
         div(
            style = "flex: 1; min-height: 0; position: relative;",
            grVizOutput(ns("coloredDag"), width = "100%", height = "100%")
         ),
         uiOutput(ns("conditioningWarning")),
         div(
            style = "position: absolute; top: 0; left: 0; z-index: 1; margin: 0; padding: 0;",
            grVizOutput(ns("dagLegend"), height = 70, width = 200)
         ),
         # pathButtonsUI(ns("pathButtons"))
      )
   )
}
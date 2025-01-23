createDagLegend <- function() {
   tags$div(
      class = "dag-legend",
      style = "position: absolute; top: -25px; left: -5px; z-index: 1; padding: 15px 25px; backdrop-filter: blur(5px); background: #ffffff50; border: 1px solid #e8e8e8; border-radius: 5px;",
      tags$div(
         style = "display: flex; align-items: center; gap: 8px; margin-bottom: 8px;",
         tags$div(style = "width: 24px; height: 24px; background: #605279; border: 2px solid #372f45;"),
         tags$span("Base Node")
      ),
      tags$div(
         style = "display: flex; align-items: center; gap: 8px; margin-bottom: 8px;",
         tags$div(style = "width: 24px; height: 24px; background: lightgrey; border: 2px solid #767372;"),
         tags$span("Unobserved")
      ),
      tags$div(
         style = "display: flex; align-items: center; gap: 8px;",
         tags$div(style = "width: 24px; height: 24px; background: #D8EB79; border: 2px solid #4a5129;"),
         tags$span("Conditioned")
      )
   )
}


dagVisualizationUI <- function(id) {
   ns <- NS(id)
   
   tagList(
      shinyjs::useShinyjs(),
      div(
         style = "position: relative; width: 100%; height: 100%; display: flex; flex-direction: column; padding: 25px 15px 25px",
         div(
            style = "flex: 1; min-height: 0; position: relative;",
            # DAG Legend
            createDagLegend(),
            grVizOutput(ns("coloredDag"), width = "100%", height = "100%")
         ),
         uiOutput(ns("conditioningWarning")),
         uiOutput(ns("unmeasuredWarning"))
      )
   )
}
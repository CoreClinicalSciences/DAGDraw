pathButtonsUI <- function(id) {
   ns <- NS(id)
   tagList(
      uiOutput(ns("openPaths")),
      uiOutput(ns("unmeasuredWarning"))
   )
}
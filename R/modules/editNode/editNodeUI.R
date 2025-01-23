editNodeUI <- function(id) {
  ns <- NS(id)

  editNodeModal <- modalDialog(
    title = "Edit Node",
    fluidPage(
      uiOutput(ns("editNode")),
      uiOutput(ns("errorText"))
    ),
    footer = uiOutput(ns("modalFooterButtons"))
  )

  showModal(editNodeModal)
}
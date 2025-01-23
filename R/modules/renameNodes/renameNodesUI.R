renameNodeUI <- function(id) {
  ns <- NS(id)
  
  renameModal <- modalDialog(
    title = "Rename Nodes",
    fluidPage(
      p("Delete"),
      uiOutput(ns("renaming")),
      uiOutput(ns("errorText"))
    ), 
    footer = tagList(
      modalButton("Cancel"),
      actionButton(ns("renameNodes"), "Update Nodes", class = "btn-primary")
    )
  )
  
  showModal(renameModal)
}

displayNodesUI <- function(id) {
   ns <- NS(id)
   
   tagList(
      div(
         style = "width: 225px; overflow-x: hidden; padding: 0;",
         uiOutput(ns("addNodeForm")),
         div(
            style = "width: 100%; padding: 0;",
            fluidRow(
               div(
                  style = "border-bottom: solid; color: var(--fg); display: flex; align-items: center; gap: 10px;",
                  
                  # Buttons beside the text
                  div(
                     style = "display: flex; gap: 5px;",
                     circleButton(
                        ns("newNode"),
                        icon = icon("add"),
                        size = "xs",
                        style = "border: 1px solid var(--fg);",
                        class = "themeButton"
                     ),
                     circleButton(
                        ns("renameNodes"),
                        icon = icon("edit"),
                        size = "xs",
                        style = "border: 1px solid var(--fg);",
                        class = "themeButton"
                     )
                  ),
                  h2("Nodes", style = "margin: 0;")
               )
            ),
            p("Click on a node card to condition on it",
              style = "color: var(--fg); padding-left: 0; padding-top: 5px"),
            div(
               style = "height: 400px; overflow-y: auto; overflow-x: hidden; padding-left: 0; margin-left: 0;",
               uiOutput(ns("nodeBoxes"))
            )
         )
      )
   )
}
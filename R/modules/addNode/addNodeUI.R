addNodeUI <- function(id) {
   ns <- NS(id)
   
   modalDialog(
      fluidPage(
         tags$p("New Node",
                style = "font-size: 2rem; font-weight: bold; margin-bottom: 20px; text-align: center;"),
         div(
            id = ns("newNode"),
            fluidRow(
               div(
                  class = "label-container",
                  style = "display: flex; align-items: center; gap: 5px;",
                  h5(LabelMandatory("Name"), style = "margin: 0;"),
                  tooltip(
                     bsicons::bs_icon("info-circle-fill", title = "Name Rules"),
                     "Node names can be up to 14 characters, no spaces, and no special characters."
                  )
               )
            ),
            textInput(ns("name"), NULL, ""),
            uiOutput(ns("errorMessage")),
            radioButtons(ns("unmeasured"), tags$h5("Type"),
                         c("Measured" = "measured",
                           "Unmeasured" = "unmeasured"
                         )),
            fluidRow(
               h5(LabelMandatory("Connections")),
               column(6,
                      uiOutput(ns("checkboxGroupTo"))
               ),
               column(6,
                      uiOutput(ns("checkboxGroupFrom"))
               )
            ),
            br(), br(),
            uiOutput(ns("errorText")),
            uiOutput(ns("errorMessage2"))
         )
      ),
      footer = tagList(
         modalButton("Cancel"),
         actionButton(ns("add_node"), "Add Node", class = "btn-primary")
      )
   )
}
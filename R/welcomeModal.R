createWelcomeModal <- function(session) {
   modalDialog(
      tags$p("Welcome to DAGDraw",
             style = "font-size: 2rem; font-weight: bold; margin-bottom: 20px; text-align: center;"),
      h5("Please enter the initial settings for your DAG.",
         tooltip(
            bsicons::bs_icon("info-circle-fill", title = "Name Rules"),
            "Node names can be up to 14 characters, no spaces, and no special characters."
         ),
         style = "margin-top: 5px; margin-bottom: 15px; text-align: left;"),
      textInput("treatmentName", label = TREATMENT),
      textInput("responseName", label = RESPONSE),
      checkboxInput("transportability", "Enable Transportability?", FALSE),
      div(id = "errorMessageContainer",
          style = "color: red; margin-top: 10px; display: none;",
          "The names must follow the naming convention"),
      footer = tagList(
         modalButton("Cancel"),
         actionButton("setNames", "Start")
      )
   )
}

handleWelcomeModal <- function(input, session, state) {
   # Show welcome modal on startup
   observe({
      if (!state$appState$initialized) {
         showModal(createWelcomeModal(session))
      }
   })
   
   # Modal form validation and initialization
   observeEvent(input$setNames, {
      if (CheckNameInput(input$treatmentName)$isValid & CheckNameInput(input$responseName)$isValid) {
         # Update initial state
         state$updateInitialState(input$treatmentName, input$responseName, input$transportability)
         
         removeModal()
      } else {
         shinyjs::runjs("
        $('#errorMessageContainer').show();
        setTimeout(function() {
          $('#errorMessageContainer').fadeOut('slow');
        }, 3000);
      ")
      }
   })
}
coreServer <- function(input, output, session) {
   # Initialize state management
   state <- initializeState(session)
   
   # Show welcome modal on startup
   handleWelcomeModal(input, session, state)
   
   # Initialize modules after state initialized
   observeEvent(state$appState$initialized, {
      req(state$appState$initialized)
      
      displayNodesServer("displayNodes",
                         state$toDataStorage,
                         state$treatment,
                         state$response,
                         state$highlightedPathList,
                         state$updateConditionedNodes
                         )
      
      dagVisualizationServer("openDAG",
                             state$toDataStorage,
                             state$treatment,
                             state$response,
                             state$highlightedPathList,
                             state$isTransportability,
                             state$dagDownloads,
                             state$backdoorShow,
                             state$effectModifierShow,
                             state$layout
                             )
      
      # Handle graph UI rendering
      output$graph <- renderUI({
         dagVisualizationUI("openDAG")
      })
      
      # Add the effect modifier switch conditionally
      output$effectModifierSwitch <- renderUI({
         req(state$isTransportability())
         
         div(class = "effect-modifier-container",
             style = "width: 100%; font-size: 0.95rem;",
             materialSwitch(
                inputId = "showEffectModifiers",
                label = "Show Effect Modifiers",
                status = "primary", 
                right = TRUE
             )
         )
      })
      
      # Update when effect modifier, backdoor toggled
      observe({
         req(state$toDataStorage$data)
         
         if (!is.null(input$showBackdoor)) {
            state$backdoorShow(input$showBackdoor)
         }
         if (!is.null(input$showEffectModifiers)) {
            state$effectModifierShow(input$showEffectModifiers)
         }
      })
      
      # Layout refresh handler
      observeEvent(input$refreshLayout, {
         state$updateLayout()
      })
      
      # Get dag code for clipboard
      getDagRCode(state$toDataStorage, state$dagDownloads)
      
      # Initiate Download Handlers
      setupDownloadHandlers(output, state)
      
      # R Code Copy Handler
      observeEvent(input$downloadRCode, {
         session$sendCustomMessage("copyToClipboard", state$dagDownloads$RCode)
      })
   })
}
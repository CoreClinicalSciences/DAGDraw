displayNodesServer <- function(id, toDataStorage, treatment,
                               response, highlightedPathList, updateConditionedNodes) {
   moduleServer(id, function(input, output, session) {
      ns <- session$ns
      
      observerInitialized <- reactiveVal(FALSE)
      cardList <- reactiveValues(values = c())
      
      # Initialize sub-modules
      addNodeServer("newNode", toDataStorage,
                    treatment, response, highlightedPathList)
      
      renameNodesServer("renameNodes", toDataStorage,
                        treatment, response, highlightedPathList, observerInitialized)
      
      # Modal triggers
      observeEvent(input$newNode, {
         showModal(addNodeUI(ns("newNode")))
      })
      
      observeEvent(input$renameNodes, {
         renameNodeUI(ns("renameNodes"))
      })
      
      # Main layout and interactions
      observe({
         # Get and process display data
         displayData <- prepareDisplayData(toDataStorage$data)
         
         # Render node boxes
         output$nodeBoxes <- renderUI({
            renderNodes(ns, displayData)
         })
         
         # Set up node observers
         observe({
            displayData <- prepareDisplayData(toDataStorage$data)
            displayDataFiltered <- filterConditionalNodes(displayData)
            
            # Create observe events for each filtered node
            lapply(displayDataFiltered$name, function(nodeName) {
               setupNodeObserver(input, cardList, toDataStorage, nodeName, updateConditionedNodes)
            })
         })
         
         # Set up edit button observers
         observe({
            lapply(unique(toDataStorage$data$name), function(nodeName) {
               setupEditButtonObserver(
                  session, input, toDataStorage, treatment, 
                  response, highlightedPathList, observerInitialized,
                  nodeName, ns
               )
            })
         })
      })
   })
}
# Initialize and manage application state
initializeState <- function(session) {
   # Create all reactive values
   appState <- reactiveValues(initialized = FALSE)
   
   toDataStorage <- reactiveValues(data = NULL)
   dagDownloads <- reactiveValues(
      RCode = "This is your R code"
   )
   
   # Initialize UI state values
   effectModifierShow <- reactiveVal(FALSE)
   backdoorShow <- reactiveVal(FALSE)
   layout <- reactiveVal("kk")
   highlightedPathList <- reactiveVal(NULL)
   
   # Add reactive value for conditioned nodes
   conditionedNodes <- reactiveVal(list())
   
   # Create core state values
   treatment <- reactiveVal(NULL)
   response <- reactiveVal(NULL)
   isTransportability <- reactiveVal(FALSE)
   
   # Add current graph state
   currentGraph <- reactiveVal(NULL)
   
   # Function to initialize data structure
   initializeDataStructure <- function(treatmentName, responseName, transportability) {
      if (transportability) {
         data.frame(
            name = I(c(responseName, treatmentName, "Participation")),
            to = I(c(NA, responseName, NA)),
            unmeasured = FALSE,
            conditioned = FALSE,
            base = TRUE,
            effectModifier = FALSE
         )
      } else {
         data.frame(
            name = I(c(responseName, treatmentName)),
            to = I(c(NA, responseName)),
            unmeasured = FALSE,
            conditioned = FALSE,
            base = TRUE,
            effectModifier = FALSE
         )
      }
   }
   
   # Function to update initial state
   updateInitialState <- function(treatmentName, responseName, transportability) {
      treatment(treatmentName)
      response(responseName)
      isTransportability(transportability)
      toDataStorage$data <- initializeDataStructure(treatmentName, responseName, transportability)
      appState$initialized <- TRUE
   }
   
   # Function to update layout
   updateLayout <- function(newLayout) {
      layout(newLayout)
   }
   
   # Function to update conditioned nodes
   # Function to update conditioned nodes
   updateConditionedNodes <- function(nodeName, isConditioned) {
      current <- as.character(unlist(conditionedNodes()))
      
      if (isTRUE(isConditioned)) {
         new_nodes <- unique(c(current, nodeName))
         conditionedNodes(new_nodes)
      } else {
         new_nodes <- setdiff(current, nodeName)
         conditionedNodes(new_nodes)
      }
   }
   
   # Return list of all state objects and functions
   list(
      # Reactive Values
      appState = appState,
      toDataStorage = toDataStorage,
      dagDownloads = dagDownloads,
      
      # Reactive Value Functions
      effectModifierShow = effectModifierShow,
      backdoorShow = backdoorShow,
      layout = layout,
      highlightedPathList = highlightedPathList,
      treatment = treatment,
      response = response,
      isTransportability = isTransportability,
      currentGraph = currentGraph,
      conditionedNodes = conditionedNodes,
      
      # State Management Functions
      updateInitialState = updateInitialState,
      updateLayout = updateLayout,
      updateConditionedNodes = updateConditionedNodes
   )
}
pathButtonsServer <- function(
      id,
      toDataStorage,
      causalPathList,
      reactiveGraph,
      highlightedPathList,
      buttonHighlightStates,
      backdoorShow,
      showWarning
) {
   moduleServer(id, function(input, output, session) {
      ns <- session$ns
      
      # Initialize buttonHighlightStates if it's NULL
      observe({
         if (is.null(buttonHighlightStates())) {
            buttonHighlightStates(list())
         }
      })
      
      # Path buttons
      observe({
         current_states <- buttonHighlightStates()
         if (is.null(current_states)) current_states <- list()
         
         buttons <- lapply(seq_along(causalPathList()), function(i) {
            uniqueId <- paste0("viewPath", i)
            pathData <- PathStringToDF(causalPathList()[i])
            pathData <- unique(c(pathData$name, pathData$to))
            pathData <- toDataStorage$data %>%
               filter(name %in% pathData)
            
            # Check if path exists in current_states
            isHighlighted <- !is.null(current_states) && 
               length(current_states) > 0 &&
               !is.null(current_states[[causalPathList()[i]]])
            
            buttonClass <- if (any(pathData$unmeasured == TRUE)) {
               paste("unmeasuredPath", if(isHighlighted) "highlighted" else "")
            } else {
               paste("measuredPath", if(isHighlighted) "highlighted" else "")
            }
            
            actionButton(
               inputId = ns(uniqueId),
               label = causalPathList()[[i]],
               class = buttonClass
            )
         })
         
         output$openPaths <- renderUI({
            if(backdoorShow()) {
               buttons
            } else {
               p("")
            }
         })
      })
      
      # Button handlers
      buttonList <- reactiveValues(values = c())
      
      observe({
         req(causalPathList())
         lapply(seq_along(causalPathList()), function(i) {
            if (!(i %in% buttonList$values)) {
               buttonList$values <- c(buttonList$values, i)
               
               observeEvent(input[[paste0("viewPath", i)]], {
                  pathString <- causalPathList()[[i]]
                  current_states <- buttonHighlightStates()
                  if (is.null(current_states)) current_states <- list()
                  
                  if (!is.null(current_states[[pathString]])) {
                     current_states[[pathString]] <- NULL
                  } else {
                     current_states[[pathString]] <- TRUE
                  }
                  buttonHighlightStates(current_states)
                  
                  shinyjs::toggleClass(
                     id = ns(paste0("viewPath", i)), 
                     class = "highlighted", 
                     asis = TRUE
                  )
                  
                  edgeDf <- PathStringToDF(pathString)
                  
                  if(pathString %in% highlightedPathList()) {
                     highlightedPathList(
                        highlightedPathList()[highlightedPathList() != pathString]
                     )
                  } else {
                     highlightedPathList(c(highlightedPathList(), pathString))
                  }
                  
                  tempGraph <- RemovePathFromGraph(reactiveGraph(), unique(edgeDf))
                  tempGraph <- AddPathToGraph(tempGraph, unique(edgeDf))
                  
                  highlightedEdgeDf <- data.frame(
                     name = character(),
                     to = character(),
                     stringsAsFactors = FALSE
                  )
                  
                  for (path in highlightedPathList()) {
                     edgeDf <- PathStringToDF(path)
                     highlightedEdgeDf <- rbind(highlightedEdgeDf, edgeDf) %>% unique()
                  }
                  
                  if (nrow(highlightedEdgeDf) > 0) {
                     tempGraph <- AddOpenPathToGraph(tempGraph, highlightedEdgeDf, 1)
                  }
                  
                  if (length(causalPathList()) >= 1) {
                     causalEdgeDf <- data.frame()
                     for (path in causalPathList()) {
                        edgeDf <- PathStringToDF(path)
                        causalEdgeDf <- rbind(causalEdgeDf, edgeDf) %>% unique()
                     }
                     
                     notHighlightedDf <- anti_join(
                        causalEdgeDf,
                        highlightedEdgeDf,
                        by = c("name", "to")
                     )
                     
                     if (nrow(notHighlightedDf) > 0) {
                        tempGraph <- AddOpenPathToGraph(tempGraph, notHighlightedDf)
                     }
                  }
                  
                  reactiveGraph(tempGraph)
               })
            }
         })
      })
      
      # Return reactive values
      return(list(
         buttonHighlightStates = buttonHighlightStates,
         highlightedPathList = highlightedPathList
      ))
   })
}
# renameNodesServer <- function(id, toDataStorage, treatment, response,
#                               highlightedPathList, observerInitialized) {
#    moduleServer(id, function(input, output, session) {
#       ns <- session$ns
#       baseList <- c(treatment(), response(), "Participation")
#       AllInputs <- reactive({NULL})
#       
#       output$renaming <- renderUI({
#          Map(function(node) {
#             uniquUiId <- ns(node)
#             
#             fluidRow(
#                column(1, checkboxInput(paste0(uniquUiId, "remove"), label = NULL)),
#                column(5, h6(node)),
#                column(6, textInput(uniquUiId, NULL, value = node))
#             )
#          }, sort(unique(toDataStorage$data$name)))
#       })
#       
#       # Create observe Event only once
#       if (!observerInitialized()) {
#          observeEvent(input$renameNodes, {
#             # Get all unique node names
#             uniqueNodes <- sort(unique(toDataStorage$data$name))
#             
#             # Create a named vector for checked states
#             checkedStates <- sapply(uniqueNodes, function(n) {
#                checkboxName <- paste0(n, "remove")
#                if (!is.null(input[[checkboxName]])) {
#                   input[[checkboxName]]
#                } else {
#                   FALSE
#                }
#             })
#             names(checkedStates) <- uniqueNodes
#             
#             # Get selected nodes for deletion (preserving names)
#             selectedDelete <- names(checkedStates)[checkedStates]
#             
#             # Check if any selected nodes are in baseList
#             if (length(selectedDelete) > 0 && any(selectedDelete %in% baseList)) {
#                output$errorText <- renderUI({
#                   p("You cannot delete the base nodes",
#                     id = "removeBaseNodesError", class = "errorMessage")
#                })
#                runjs("setTimeout(function() { $('#removeBaseNodesError').fadeOut(); }, 3000);")
#             } else {
#                temp <- toDataStorage$data %>%
#                   filter(!(name %in% selectedDelete)) %>%
#                   mutate(to = if_else(to %in% selectedDelete, NA_character_, to))
#                
#                toDataStorage$data <- temp
#                
#                # Rename Nodes logic continues as before...
#                AllInputs <- reactive({
#                   x <- reactiveValuesToList(input)
#                   data.frame(
#                      names = names(x),
#                      values = unlist(x, use.names = FALSE)
#                   )
#                })
#                
#                temp <- AllInputs() %>%
#                   slice(-1) %>%
#                   filter(names %in% toDataStorage$data$name)
#                
#                newNameList <- temp$values
#                badNameList <- c()
#                
#                # Make sure all new names are unique
#                uniqueNames <- unique(newNameList)
#                uniqueSubmit <- length(uniqueNames) == length(newNameList)
#                
#                # Make sure names follow guidelines
#                for (name in newNameList) {
#                   nameCheck <- CheckNameInput(name)
#                   
#                   if (!(nameCheck$isValid)) {
#                      badNameList <- c(badNameList, name)
#                   }
#                }
#                
#                cleanNamesubmit <- length(badNameList) < 1
#                
#                if (cleanNamesubmit & uniqueSubmit) {
#                   tempToStorage <- toDataStorage$data
#                   
#                   mergedTemp <- tempToStorage %>%
#                      left_join(temp, by = c("name" = "names")) %>%
#                      left_join(temp, by = c("to" = "names"), suffix = c("_name", "_to")) %>%
#                      mutate(
#                         base = case_when(name == treatment() ~ "treatment",
#                                          name == response() ~ "response"),
#                         name = coalesce(values_name, name),
#                         to = coalesce(values_to, to)
#                      ) %>%
#                      select(-c(values_name, values_to))
#                   
#                   # Sets new global variables
#                   tempTreatment <- mergedTemp$name[mergedTemp$base == "treatment"]
#                   tempTreatment <- tempTreatment[!is.na(tempTreatment)][1]
#                   tempResponse <- mergedTemp$name[mergedTemp$base == "response"]
#                   tempResponse <- tempResponse[!is.na(tempResponse)][1]
#                   
#                   treatment(tempTreatment)
#                   response(tempResponse)
#                   
#                   toDataStorage$data <- mergedTemp %>%  mutate(
#                      base = if_else(
#                         name %in% c(treatment(), response(), "participation"),
#                         TRUE, FALSE)
#                   )
#                   
#                   # Remove the modal after the operation
#                   removeModal()
#                } else if (cleanNamesubmit) {
#                   output$errorText <- renderUI({
#                      p("Each node must have a unique name",
#                        id = "uniqueNameError", class = "errorMessage")
#                   })
#                   runjs("setTimeout(function() { $('#uniqueNameError').fadeOut(); }, 3000);")
#                } else {
#                   output$errorText <- renderUI({
#                      column(12,
#                             p("The following nodes don't follow the name rules",
#                               id = "namingError", class = "errorMessage"),
#                             p(paste(badNameList, collapse = ", "), id = "namingError")
#                      )
#                   })
#                   runjs("setTimeout(function() { $('#namingError').fadeOut(); }, 3000);")
#                }
#             }
#          })
#          
#          # Set the flag to TRUE to prevent re-creation
#          observerInitialized(TRUE)
#       }
#    })
# }




renameNodesServer <- function(id, toDataStorage, treatment, response,
                              highlightedPathList, observerInitialized) {
   moduleServer(id, function(input, output, session) {
      ns <- session$ns
      baseList <- c(treatment(), response(), "Participation")
      AllInputs <- reactive({NULL})
      
      output$renaming <- renderUI({
         # Filter out baseList nodes before creating UI elements
         nonBaseNodes <- sort(unique(toDataStorage$data$name[!(toDataStorage$data$name %in% baseList)]))
         
         Map(function(node) {
            uniquUiId <- ns(node)
            
            fluidRow(
               column(1, checkboxInput(paste0(uniquUiId, "remove"), label = NULL)),
               column(5, h6(node)),
               column(6, textInput(uniquUiId, NULL, value = node))
            )
         }, nonBaseNodes)
      })
      
      # Rest of the code remains the same...
      if (!observerInitialized()) {
         observeEvent(input$renameNodes, {
            # Get all unique node names (excluding baseList)
            uniqueNodes <- sort(unique(toDataStorage$data$name[!(toDataStorage$data$name %in% baseList)]))
            
            # Create a named vector for checked states
            checkedStates <- sapply(uniqueNodes, function(n) {
               checkboxName <- paste0(n, "remove")
               if (!is.null(input[[checkboxName]])) {
                  input[[checkboxName]]
               } else {
                  FALSE
               }
            })
            names(checkedStates) <- uniqueNodes
            
            # Get selected nodes for deletion (preserving names)
            selectedDelete <- names(checkedStates)[checkedStates]
            
            # Since baseList nodes are no longer displayed, we can remove this check
            temp <- toDataStorage$data %>%
               filter(!(name %in% selectedDelete)) %>%
               mutate(to = if_else(to %in% selectedDelete, NA_character_, to))
            
            toDataStorage$data <- temp
            
            # Rename Nodes logic continues as before...
            AllInputs <- reactive({
               x <- reactiveValuesToList(input)
               data.frame(
                  names = names(x),
                  values = unlist(x, use.names = FALSE)
               )
            })
            
            temp <- AllInputs() %>%
               slice(-1) %>%
               filter(names %in% toDataStorage$data$name)
            
            newNameList <- temp$values
            badNameList <- c()
            
            # Make sure all new names are unique
            uniqueNames <- unique(newNameList)
            uniqueSubmit <- length(uniqueNames) == length(newNameList)
            
            # Make sure names follow guidelines
            for (name in newNameList) {
               nameCheck <- CheckNameInput(name)
               
               if (!(nameCheck$isValid)) {
                  badNameList <- c(badNameList, name)
               }
            }
            
            cleanNamesubmit <- length(badNameList) < 1
            
            if (cleanNamesubmit & uniqueSubmit) {
               tempToStorage <- toDataStorage$data
               
               mergedTemp <- tempToStorage %>%
                  left_join(temp, by = c("name" = "names")) %>%
                  left_join(temp, by = c("to" = "names"), suffix = c("_name", "_to")) %>%
                  mutate(
                     base = case_when(name == treatment() ~ "treatment",
                                      name == response() ~ "response"),
                     name = coalesce(values_name, name),
                     to = coalesce(values_to, to)
                  ) %>%
                  select(-c(values_name, values_to))
               
               # Sets new global variables
               tempTreatment <- mergedTemp$name[mergedTemp$base == "treatment"]
               tempTreatment <- tempTreatment[!is.na(tempTreatment)][1]
               tempResponse <- mergedTemp$name[mergedTemp$base == "response"]
               tempResponse <- tempResponse[!is.na(tempResponse)][1]
               
               treatment(tempTreatment)
               response(tempResponse)
               
               toDataStorage$data <- mergedTemp %>%  mutate(
                  base = if_else(
                     name %in% c(treatment(), response(), "participation"),
                     TRUE, FALSE)
               )
               
               removeModal()
            } else if (cleanNamesubmit) {
               output$errorText <- renderUI({
                  p("Each node must have a unique name",
                    id = "uniqueNameError", class = "errorMessage")
               })
               runjs("setTimeout(function() { $('#uniqueNameError').fadeOut(); }, 3000);")
            } else {
               output$errorText <- renderUI({
                  column(12,
                         p("The following nodes don't follow the name rules",
                           id = "namingError", class = "errorMessage"),
                         p(paste(badNameList, collapse = ", "), id = "namingError")
                  )
               })
               runjs("setTimeout(function() { $('#namingError').fadeOut(); }, 3000);")
            }
         })
         
         observerInitialized(TRUE)
      }
   })
}
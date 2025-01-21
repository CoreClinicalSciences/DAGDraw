editNodeServer <- function(id, toDataStorage, treatment, response,
                           highlightedPathList, observerInitialized,
                           nodeName) {
   moduleServer(id, function(input, output, session) {
      ns <- session$ns

      nodeVector <- unique(toDataStorage$data$name)
      childrenData <- toDataStorage$data %>% filter(name == nodeName)
      parentData <- toDataStorage$data %>% filter(to == nodeName)

      # Create reactive value to track if node is required
      isRequiredNode <- reactive({
         baseList <- c(treatment(), response(), "Participation")
         nodeName %in% baseList
      })

      output$modalFooterButtons <- renderUI({
         if (isRequiredNode()) {
            # For required nodes, only show Cancel button
            tagList(
               modalButton("Cancel"),
               actionButton(ns(paste0("updateNode", nodeName)), "Update", class = "btn-primary",
                            style = "color: white !important;")
            )
         } else {
            # For non-required nodes, show all buttons
            tagList(
               modalButton("Cancel"),
               actionButton(ns(paste0("removeBtn", nodeName)), "Delete", class = "btn-primary",
                            style = "color: red !important;
                                     background-color: white !important;
                                     border-color: red !important;"),
               actionButton(ns(paste0("updateNode", nodeName)), "Update", class = "btn-primary",
                            style = "color: white !important;")
            )
         }

      })

      output$editNode <- renderUI({
         baseList <- c(treatment(), response(), "Participation")

         if (!(nodeName %in% baseList)) {
            column(12,
                   h2(nodeName),
                   radioButtons(
                      inputId = ns("unmeasuredToggle"),
                      label = "Type",
                      choices =  c(
                         "Measured" = "measured",
                         "Unmeasured" = "unmeasured"),
                      selected = ifelse(any(childrenData$unmeasured, na.rm = TRUE),
                                        "unmeasured", "measured")
                   ),
                   fluidRow(
                      column(6,
                             checkboxGroupInput(
                                inputId = ns(paste0("childUpdate", nodeName)),
                                label = "Children",
                                choiceNames = sort(nodeVector[! nodeVector %in% c(nodeName)]),
                                choiceValues = sort(nodeVector[! nodeVector %in% c(nodeName)]),
                                selected = childrenData$to
                             )
                      ),
                      column(6,
                             checkboxGroupInput(
                                inputId = ns(paste0("parentUpdate", nodeName)),
                                label = "Parents",
                                choiceNames = sort(nodeVector[! nodeVector %in% c(nodeName, response())]),
                                choiceValues = sort(nodeVector[! nodeVector %in% c(nodeName, response())]),
                                selected = parentData$name
                             )
                      )
                   ),
                   br(),
                   uiOutput(ns("errorMessage2"))
            )
         } else {
            column(12,
                   h2(nodeName),
                   p("This is a required node and cannot be edited or deleted.",
                     style = "color: #dc3545; font-weight: bold;")  # Red warning text
            )
         }
      })

      # Prevents people from selecting the same node as parent and child
      observe({
         if (!isRequiredNode()) {  # Only run this for non-required nodes
            selectedChildren <- input[[paste0("childUpdate", nodeName)]]
            selectedParents <- input[[paste0("parentUpdate", nodeName)]]

            overlap <- intersect(selectedChildren, selectedParents)

            output$errorMessage2 <- renderUI({
               if (length(overlap) > 0) {
                  p("A node cannot be both a child and a parent.", class = "errorMessage")
               } else {
                  NULL
               }
            })

            if (length(overlap) > 0) {
               output$modalFooterButtons <- renderUI({
                  tagList(
                     modalButton("Cancel"),
                     actionButton(ns(paste0("removeBtn", nodeName)), "Delete", class = "btn-primary",
                                  style = "color: red !important;
                                     background-color: white !important;
                                     border-color: red !important;")
                  )
               })
            } else {
               output$modalFooterButtons <- renderUI({
                  tagList(
                     modalButton("Cancel"),
                     actionButton(ns(paste0("removeBtn", nodeName)), "Delete", class = "btn-primary",
                                  style = "color: red !important;
                                     background-color: white !important;
                                     border-color: red !important;"),
                     actionButton(ns(paste0("updateNode", nodeName)), "Update", class = "btn-primary",
                                  style = "color: white !important;")
                  )
               })
            }
         }
      })

      # Define a new observeEvent for the edit action button
      observeEvent(input[[paste0("updateNode", nodeName)]], {
         if (!isRequiredNode()) {  # Only allow updates for non-required nodes
            baseList <- c(treatment(), response(), "Participation")

            nodeStateDf <- toDataStorage$data %>%
               select(name, unmeasured, conditioned) %>%
               mutate(
                  conditioned = if_else(name == nodeName, FALSE, conditioned),
                  unmeasured = if_else(name == nodeName, input$unmeasuredToggle == "unmeasured", unmeasured)
               ) %>%
               unique() %>%
               filter(!(is.na(conditioned)))

            UpdatedNode <- data.frame(
               name = nodeName,
               parents = I(list(na.omit(input[[paste0("parentUpdate", nodeName)]]))),
               children = I(list(na.omit(input[[paste0("childUpdate", nodeName)]])))
            )

            LongUpdate <- ToDataLong(UpdatedNode)
            nodeList <- unique(c(toDataStorage$data$name, toDataStorage$data_to))

            temp <- toDataStorage$data %>%
               filter(name != nodeName & to != nodeName) %>%
               bind_rows(LongUpdate)

            nameList <- unique(temp$name)

            aloneDf <- toDataStorage$data %>%
               filter(name %in% setdiff(nodeList, nameList)) %>%
               mutate(to = NA)

            if(nodeName %in% aloneDf$name) {
               aloneDf <- aloneDf %>%
                  mutate(
                     conditioned = FALSE
                  )
            }

            toDataStorage$data <- bind_rows(temp, aloneDf) %>%
               mutate(
                  base = if_else(name %in% baseList, TRUE, FALSE)
               ) %>%
               select(name, to, base) %>%
               left_join(nodeStateDf, by = join_by(name))

            removeModal()
         }
      }, ignoreNULL = TRUE, ignoreInit = TRUE)

      # Define a new observeEvent for the delete action button
      observeEvent(input[[paste0("removeBtn", nodeName)]], {
         if (!isRequiredNode()) {  # Only allow deletion for non-required nodes
            highlightedPathList(NULL)
            nodeList <- unique(toDataStorage$data$name)
            nodeList <- nodeList[nodeList != nodeName]

            temp <- toDataStorage$data %>%
               filter(name != nodeName & to != nodeName)

            nameList <- unique(temp$name)

            aloneDf <- toDataStorage$data %>%
               filter(name %in% setdiff(nodeList, nameList)) %>%
               mutate(to = NA)

            temp <- bind_rows(aloneDf, temp)
            toDataStorage$data <- temp

            removeModal()
         }
      }, ignoreNULL = TRUE, ignoreInit = TRUE)

   })
}
# Styling constants -----------------------------------------------
NODE_BUTTON_STYLE <- "display: inline-block; width: 150px; height: 40px; text-align: center; padding: 0; font-size: 14px; line-height: 40px;"
NODE_CONTAINER_STYLE <- "display: inline-flex; align-items: center; gap: 5px;"
NODE_ROW_STYLE <- "width: 100%; padding-left: 0;"

# UI Element Creation Functions -----------------------------------
createNodeButton <- function(ns, name, class) {
   actionButton(
      ns(name),
      name,
      class = class,
      style = NODE_BUTTON_STYLE
   )
}

createEditButton <- function(ns, name) {
   circleButton(
      ns(paste0("editBtn", name)),
      icon = icon("pencil"),
      size = "xs",
      class = "editButton"
   )
}

# Data Processing Functions --------------------------------------
prepareDisplayData <- function(data) {
   data %>%
      select(-c(to)) %>%
      unique() %>%
      arrange(desc(base), name)
}

filterConditionalNodes <- function(displayData) {
   displayData %>%
      filter(!base & !unmeasured)
}

# Node Rendering Functions ---------------------------------------
renderNodes <- function(ns, displayData) {
   apply(displayData, 1, function(row) {
      fluidRow(
         style = NODE_ROW_STYLE,
         createNodeRow(ns, row, displayData)
      )
   })
}

createNodeRow <- function(ns, row, displayData) {
   if (as.logical(row["base"]) || row["name"] %in% c("Participation")) {
      createBaseNodeRow(ns, row)
   } else if (row["unmeasured"]) {
      createUnmeasuredNodeRow(ns, row)
   } else {
      createMeasuredNodeRow(ns, row, displayData)
   }
}

createBaseNodeRow <- function(ns, row) {
   div(
      style = NODE_CONTAINER_STYLE,
      div(style = "width: 19px;"),
      createNodeButton(ns, row["name"], "baseNode")
   )
}

createUnmeasuredNodeRow <- function(ns, row) {
   div(
      style = NODE_CONTAINER_STYLE,
      createEditButton(ns, row["name"]),
      createNodeButton(ns, row["name"], "unmeasuredNode")
   )
}

createMeasuredNodeRow <- function(ns, row, displayData) {
   nodeState <- displayData %>%
      filter(name == row["name"]) %>%
      select(name, conditioned) %>%
      unique()
   
   classList <- if (nodeState$conditioned) {
      c("measuredNode", "conditioned")
   } else {
      c("measuredNode")
   }
   
   div(
      style = NODE_CONTAINER_STYLE,
      createEditButton(ns, row["name"]),
      createNodeButton(ns, row["name"], classList)
   )
}

# Observer Setup Functions ---------------------------------------------
setupNodeObserver <- function(input, cardList, toDataStorage, nodeName, updateConditionedNodes) {
   if (!(nodeName %in% cardList$values)) {
      cardList$values <- c(cardList$values, nodeName)
      
      observeEvent(input[[nodeName]], {
         
         if (nodeName == "Participation") {
            return()
         }
         
         CanCondition <- toDataStorage$data %>%
            filter(unmeasured == FALSE)
         
         if (nodeName %in% CanCondition$name) {
            temp <- toDataStorage$data %>%
               mutate(
                  conditioned = ifelse(name == nodeName, !conditioned, conditioned)
               )
            
            toDataStorage$data <- temp
            
            # Update the conditioned nodes state
            isNowConditioned <- temp %>%
               filter(name == nodeName) %>%
               pull(conditioned) %>%
               unique() %>%
               first()  # Take just the first value after deduplication
            
            updateConditionedNodes(nodeName, isNowConditioned)
         }
      })
   }
}

setupEditButtonObserver <- function(session, input, toDataStorage, treatment, 
                                    response, highlightedPathList, observerInitialized,
                                    nodeName, ns) {
   if (is.null(session$userData[[paste0("editMode", nodeName)]])) {
      session$userData[[paste0("editMode", nodeName)]] <- reactiveVal(FALSE)
   }
   
   if (is.null(session$userData[[paste0("editObserver", nodeName)]])) {
      session$userData[[paste0("editObserver", nodeName)]] <- TRUE
      
      session$onFlushed(function() {
         observeEvent(input[[paste0("editBtn", nodeName)]], {
            editNodeUI(ns("editNode"))
            editNodeServer(ns("editNode"), toDataStorage, treatment, response,
                           highlightedPathList, observerInitialized, nodeName)
         }, ignoreInit = TRUE)
      }, once = TRUE)
   }
}
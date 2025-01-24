addNodeServer <- function(id, toDataStorage, treatment, response, highlightedPathList) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$checkboxGroupTo <- renderUI({
      checkboxGroupInput(
        inputId = ns("children"),
        label = "Children",
        choiceNames = sort(unique(toDataStorage$data$name)),
        choiceValues = sort(unique(toDataStorage$data$name))
      )
    })

    output$checkboxGroupFrom <- renderUI({

      checkboxGroupInput(
        inputId = ns("parents"),
        label = "Parents",
        choiceNames = sort(unique(toDataStorage$data$name)),
        choiceValues = sort(unique(toDataStorage$data$name))
      )
    })

    
    observe({
      
      text_filled <- CheckNameInput(input$name)
      overlap <- intersect(input$children, input$parents)
      
      
      output$errorMessage <- renderUI({
        p(text_filled$errorMessage, class = "errorMessage")
      })
      
      output$errorMessage2 <- renderUI({
        if (length(overlap) > 0) {
          p("A node cannot be both a child and a parent.", class = "errorMessage")
        } else {
          NULL
        }
      })
      
      checkboxes_filled <- (!is.null(input$parents) &&
                              length(input$parents) > 0) |
        !is.null(input$children) && length(input$children)
      
      mandatoryFilled <- text_filled$isValid &&
        checkboxes_filled && (length(overlap) == 0)
      
      shinyjs::toggleState(id = "add_node", condition = mandatoryFilled)
    })
    
    
    # When new node button is pushed
    observeEvent(input$add_node, {
      # check name doesn't already exist
      if (!(input$name %in% unique(toDataStorage$data$name))) {
        # grab form data
        newToDF <- data.frame(
          name = input$name,
          parents = I(list(input$parents)),
          children = I(list(input$children))
        )

        if (input$unmeasured == "measured"){
          unmeasured <- FALSE
        } else {
          unmeasured <- TRUE
        }

        nodeStateDf <- data.frame(
          name = input$name,
          conditioned = FALSE,
          unmeasured = unmeasured
        )

        # Make it long and set up for merge
        longDF <- ToDataLong(newToDF) %>%
          full_join(nodeStateDf, by = join_by(name))
        
        temp <- toDataStorage$data %>%
          bind_rows(longDF) %>%
          group_by(name) %>%
          mutate(
            unmeasured = if_else(is.na(unmeasured), first(unmeasured), unmeasured),
            conditioned = if_else(is.na(conditioned), first(conditioned), conditioned)
          ) %>%
          ungroup()
        
        nodeList <- unique(c(temp$name, temp$to))
        nameList <- unique(temp$name)
        
        alone_df <- data.frame(
          name = setdiff(nodeList, nameList),
          to = NA,
          unmeasured = unmeasured
        ) %>%
        filter(
          !(is.na(name)) & name != input$name
        )
        
        if (nrow(alone_df) >= 1) {
          temp <- bind_rows(temp, alone_df)
        }
        
        # Set the base variable for x and y
        baseList <- c(treatment(), response(), "participation")
        
        temp <- temp %>%
          mutate(base = name %in% baseList)

        toDataStorage$data <- temp

        highlightedPathList(NULL)

        # Clear the form to start again
        updateTextInput(session, "name", value = "")
        updateCheckboxInput(session, "unmeasured", value = FALSE)
        updateRadioButtons(session, "unmeasured", selected = "measured")
        
        # Get rid of error message
        output$errorText <- renderUI({
          p("")
        })
        
        removeModal()
       } else {
        output$errorText <- renderUI({
          p("Each node must have a unique name",
            id = "errorMessage", class = "errorMessage")
        })

        # Hide after 5 seconds
        runjs("setTimeout(function() { $('#errorMessage').fadeOut(); }, 3000);")
      }
    })
  
  })
}

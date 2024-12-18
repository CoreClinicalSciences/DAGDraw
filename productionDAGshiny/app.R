library(shiny)
library(tidyverse)
library(ggdag)
library(dagitty)
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)
library(shinydashboard)
library(shinyjs)
library(bslib)
library(shinyWidgets)
library(shinytest2)
library(shinyjs)


# Source the module files
source("R/helpers.R")

source("displayNodes/ui.R")
source("displayNodes/server.R")
source("openBackDoorPathsDAG/ui.R")
source("openBackDoorPathsDAG/server.R")
source("nameModal/server.R")
source("RCode/server.R")

# Turn on for production
options(warn = -1)

# Define Theme ------------------------------------------------------------

appTheme <- bs_theme(
   bg = "#ffffff",
   fg = "#000000",
   primary = "#BDDD21",
   secondary = "#462A79",
   success = "#423F85",
   base_font = font_google("Roboto"),
   code_font = font_google("JetBrains Mono"),
   heading_font = font_google("Lato")
)


# Define UI
ui <- page_navbar(
   theme = appTheme,
   title = div(
      style = "display: flex; align-items: center; justify-content: space-between; width: 100%;",
      span("DAGDraw v0.1.1"),
      tags$img(src = "CCSlogo.png", height = "35px", style = "margin-right: 10px; margin-left: 10px;")
   ),
   
   # Include shinyjs for JavaScript functionality
   useShinyjs(),
   tags$script(HTML("
    Shiny.addCustomMessageHandler('copyToClipboard', function(message) {
        const tempTextArea = document.createElement('textarea');
        tempTextArea.value = message;
        document.body.appendChild(tempTextArea);
        tempTextArea.select();
        try {
            document.execCommand('copy');
            alert('R Code copied to clipboard!');
        } catch (err) {
            alert('Unable to copy text. Please try again.');
        }
        document.body.removeChild(tempTextArea);
    });
")),
   
   # Main content layout with two cards: a flexible-width sidebar card and a flexible main content card
   nav_panel(
      "Main",
      fluidRow(
         column(
            width = 3,  # Flexible width for the sidebar
            style = "max-width: 300px;",
            card(
               full_screen = TRUE,
               displayNodesUI("displayNodes")
            )
         ),
         column(
            width = 9,  # Flexible width for main content
            card(
               full_screen = TRUE,
               fluidRow(
               div(
                  style = "width: 90%;",
                  materialSwitch(
                     inputId = "showBackdoor",
                     label = "Show Open Backdoor Paths",
                     status = "primary",
                     right = TRUE
                  ),
                  uiOutput("effectModifierSwitch")
               ),
               div(
                  style = "width: 10%;",
                  actionButton("refreshLayout", NULL, icon = icon("refresh"))
               )
               ),
               div(
                  style = "width: 100%; margin-top: 0px;",
                  uiOutput("graph"))
            )
         )
      )
   ),
   
   # Additional tab
   nav_panel("Version History",
            div(tags$h1("Version History")),
            div(
            tags$ul(
                  tags$li("Version 0.1.1 - Updated copy & paste functions, added tooltips, and revised layout"),
                  tags$li("Version 0.1.0 - Initial Alpha release")))),
   
   # Downloads dropdown menu with downloadButton for each item
   nav_menu(
      "Downloads",
      nav_item(downloadButton("dag", "Download DAG Image", icon = icon("download"))),
      nav_item(downloadButton("backdoorDag", "Download Backdoor DAG", icon = icon("download"))),
      nav_item(downloadButton("legendDownload", "Download DAG Legend", icon = icon("download"))),
      nav_item(actionButton("downloadRCode", "Copy R-Code to Clipboard", icon = icon("copy")))
   )
)

server <- function(input, output, session) {
   
   # Show initial modal
   observe({
      showModal(modalDialog(
         tags$p("Welcome to DAGDraw", 
                style = "font-size: 2rem; font-weight: bold; margin-bottom: 20px; text-align: center;"), # Custom title styling
         h5("Please enter the initial settings for your DAG.",
               # Tooltip beside the Name label
               tooltip(
                  bsicons::bs_icon("info-circle-fill", title = "Name Rules"),
                  "Node names can be up to 14 characters, no spaces, and no special characters."
               ),
           style = "margin-top: 5px; margin-bottom: 15px; text-align: left;"),
         textInput("treatmentName", "Treatment Name", ""),
         textInput("responseName", "Response Name", ""),
         checkboxInput("transportability", "Enable Transportability?", FALSE),
         footer = tagList(
            modalButton("Cancel"),
            actionButton("setNames", "Start")
         )
      ))
   })
   
   # Handle modal form submission
   observeEvent(input$setNames, {
      if (CheckNameInput(input$treatmentName)$isValid & CheckNameInput(input$responseName)$isValid) {
         removeModal()
         
         # Set up reactive values for inputs
         treatment <- reactiveVal(input$treatmentName)
         response <- reactiveVal(input$responseName)
         highlightedPathList <- reactiveVal(NULL)
         isTransportability <- reactiveVal(input$transportability)
         
         if (isTransportability()) {
            toDataStorage <- reactiveValues(
               data = data.frame(
                  name = I(c(response(), treatment(), "Participation")),
                  to = I(c(NA, response(), NA)),
                  unmeasured = FALSE,
                  conditioned = FALSE,
                  base = TRUE,
                  effectModifier = FALSE
               )
            )
            
            # Add the effect modifier switch
            output$effectModifierSwitch <- renderUI(
               materialSwitch(
                  inputId = "showEffectModifiers",
                  label = "Show Effect Modifiers",
                  status = "primary",
                  right = TRUE
               )
            )
            
         } else {
            toDataStorage <- reactiveValues(
               data = data.frame(
                  name = I(c(response(), treatment())),
                  to = I(c(NA, response())),
                  unmeasured = FALSE,
                  conditioned = FALSE,
                  base = TRUE,
                  effectModifier = FALSE
               )
            )
         }
         
         dagDownloads <- reactiveValues(
            dag = NULL,
            backdoorDag = NULL,
            legend = NULL,
            RCode = "This is your R code" # Replace this with your actual R code to be copied
         )
         
         effectModifierShow <- reactiveVal(FALSE)
         openDAGUI("openDAG")
         backdoorShow <- reactiveVal(FALSE)
         layout <- reactiveVal("kk")
         
         observe({
            openDAGUI("openDAG")
            backdoorShow(input$showBackdoor)
            if (!is.null(input$showEffectModifiers)){
               effectModifierShow(input$showEffectModifiers)
            }
            
            output$graph <- renderUI({
               openDAGUI("openDAG")
            })
         })
         
         observeEvent(input$refreshLayout, {
            if (layout() == "kk") {
               layout("tree")
            } else if (layout() == "tree") {
               layout("circle")
            } else {
               layout("kk")
            }
         })
         
         callModule(displayNodesServer, "displayNodes",
                    toDataStorage, treatment, response, highlightedPathList)
         callModule(openDAGServer, "openDAG", toDataStorage,
                    treatment, response, highlightedPathList, isTransportability,
                    dagDownloads, backdoorShow, effectModifierShow, layout)
         callModule(RCodeServer, "RCode", toDataStorage, dagDownloads)
         
         # Handle download buttons
         output$dag <- downloadHandler(
            filename = function() { paste0("dag", ".png") },
            content = function(file) {
               export_graph(dagDownloads$dag, file_name = file, file_type = "png", width = 4000, height = 3000)
            }
         )
         
         output$backdoorDag <- downloadHandler(
            filename = function() { paste0("backdoorDag", ".png") },
            content = function(file) {
               export_graph(dagDownloads$backdoorDag, file_name = file, file_type = "png", width = 4000, height = 3000)
            }
         )
         
         output$legendDownload <- downloadHandler(
            filename = function() { paste0("dagLegend", ".png") },
            content = function(file) {
               export_graph(dagDownloads$legend, file_name = file, file_type = "png", width = 4000, height = 3000)
            }
         )
         
         observeEvent(input$downloadRCode, {
            session$sendCustomMessage("copyToClipboard", dagDownloads$RCode)
         })
         
      } else {
         output$nameError <- renderUI({
            p("The names must follow the naming convention",
              id = "nameError", class = "errorMessage")
         })
         runjs("setTimeout(function() { $('#nameError').fadeOut(); }, 3000);")
      }
   })
}

shinyApp(ui = ui, server = server)
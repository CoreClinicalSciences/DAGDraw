# Header Component
createHeader <- function() {
   div(
      class = "navbar-title-container",
      style = "width: 100%; position: relative; top: 15px",
      span("DAGDraw v1.0.1"),
      tags$img(src = "CCSlogo.png", height = "35px", style = "margin-right: 10px; margin-left: 10px;")
   )
}

# Clipboard JavaScript Handler
createClipboardHandler <- function() {
   tags$script(HTML("
    Shiny.addCustomMessageHandler('copyToClipboard', async function(rCode) {
      
      try {
         await navigator.clipboard.writeText(rCode);
         alert('R Code copied to clipboard!');
      } catch (err) {
         alert('Failed to copy to clipboard. Your browser may not be compatible');
      }
    });
  "))
}

# DAG Options Component
createDagOptions <- function() {
   card(
      style = "flex-shrink: 0;",  # Prevent shrinking
      div(
         h2("DAG Options", style = "margin: 0 0 10px; border-bottom: solid; color: var(--fg); text-align: center;"),
         div(
            style = "width: 100%; margin-bottom: 10px;",
            selectInput(
               inputId = "layoutSelect",
               label = "Select Graph Layout:",
               choices = LAYOUT_OPTIONS,
               selected = DEFAULT_LAYOUT
            )
         ),
         div(
            style = "width: 100%; font-size: 0.95rem;",
            materialSwitch(
               inputId = "showBackdoor",
               label = "Show Backdoor Paths",
               status = "primary",
               right = TRUE
            )
         ),
         div(
            style = "width: 100%;", 
            uiOutput("effectModifierSwitch")
         )
      )
   )
}

# Path Analysis Component
createPathAnalysis <- function() {
   ns <- NS("openDAG")
   card(
      style = "flex: 1; min-height: 0; display: flex; flex-direction: column;",
      h2("Backdoor Paths", style = "margin: 0 0 10px; border-bottom: solid; color: var(--fg); text-align: center;"),
      div(
         style = "flex: 1; display: flex; flex-direction: column; gap: 10px; overflow-y: auto;",
         pathButtonsUI(ns("pathButtons"))
      )
   )
}

# Sidebar Component
createSidebar <- function() {
   column(
      width = 2,
      style = "height: 90vh; display: flex; flex-direction: column;",
      card(
         full_screen = TRUE,
         style = "flex: 1; min-height: 0; display: flex; flex-direction: column;",
         displayNodesUI("displayNodes")
      )
   )
}

# Right Column Component
createRightColumn <- function() {
   column(
      width = 2,
      style = "height: 90vh; display: flex; flex-direction: column; gap: 10px;",
      createDagOptions(),
      createPathAnalysis()
   )
}

# Main Content Component
createMainContent <- function() {
   column(
      width = 8,
      style = "height: 90vh; display: flex;",
      card(
         full_screen = TRUE,
         style = "width: 100%; display: flex; flex-direction: column;",
         div(
            style = "flex: 1; min-height: 0;",
            div(
               style = "height: 100%; display: flex; justify-content: center; align-items: center;",
               uiOutput("graph")
            )
         )
      )
   )
}

# Version History Component
createVersionHistory <- function() {
   div(
      tags$h1("Version History"),
      tags$ul(
         tags$li("Version 1.0.1 - Changed naming restrictions, minor bug fixes"),
         tags$li("Version 1.0.0 - Improved legend UI, and download format"),
         tags$li("Version 0.2.1 - Updated UI, and updated Response/Outcome node functions"),
         tags$li("Version 0.2.0 - Updated UI, and refactored code"),
         tags$li("Version 0.1.1 - Updated copy & paste functions, added tooltips, and revised layout"),
         tags$li("Version 0.1.0 - Initial Alpha release")
      )
   )
}

# Downloads Menu Component
createDownloadsMenu <- function() {
   nav_menu(
      "Downloads",
      nav_item(downloadButton("downloadDag",
                              "Download DAG",
                              style = "padding: 10px 20px; border: 1px solid #462A79; color: #462A79; border-radius: 3px; margin-bottom: 3px;",
                              icon = icon("file-alt"))
               ),
      nav_item(actionButton("downloadRCode",
                            "Copy R-Code to Clipboard",
                            icon = icon("copy"))
               )
   )
}

# Main UI Assembly Function
compileUI <- function(theme) {
   page_navbar(
      theme = theme,
      title = createHeader(),
      useShinyjs(),
      createClipboardHandler(),
      # Custom CSS for download button hover
      tags$style(HTML(
         "#downloadDag:hover {
        background-color: #462A79 !important;
        color: white !important;
      }"
      )),
      
      # Main Panel
      nav_panel(
         "Main",
         fluidRow(
            createSidebar(),
            createMainContent(),
            createRightColumn()
         )
      ),
      
      # Version History Panel
      nav_panel(
         "Version History",
         createVersionHistory()
      ),
      
      # Downloads Menu
      createDownloadsMenu()
   )
}
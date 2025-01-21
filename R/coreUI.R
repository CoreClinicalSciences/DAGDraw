# Define Core UI

compileUI <- function(theme) {
   page_navbar(
      theme = theme,
      # Header with logo
      title = div(
         style = "display: flex; align-items: center; justify-content: space-between; width: 100%;",
         span("DAGDraw v0.1.1"),
         tags$img(src = "CCSlogo.png", height = "35px", style = "margin-right: 10px; margin-left: 10px;")
      ),
      
      # Enable shinyjs and clipboard functionality
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
      
      # Main Panel Layout
      nav_panel(
         "Main",
         fluidRow(
            # Sidebar Column
            column(
               width = 3,
               style = "max-width: 300px;",
               card(
                  full_screen = TRUE,
                  displayNodesUI("displayNodes")
               )
            ),
            # Main Content Column
            column(
               width = 9,
               card(
                  full_screen = TRUE,
                  fluidRow(
                     style = "margin: 15px 0;",
                     column(11, uiOutput("graph")),
                     column(1, actionButton("refreshLayout", NULL, icon = icon("refresh")))
                  ),
                  # DAG Options Accordion
                  accordion(
                     accordion_panel(
                        "DAG Options",
                        div(style = "width: 30%;", uiOutput("effectModifierSwitch")),
                        fluidRow(
                           div(
                              style = "width: 30%;",
                              materialSwitch(
                                 inputId = "showBackdoor",
                                 label = "Show Open Backdoor Paths",
                                 status = "primary",
                                 right = TRUE
                              )
                           )
                        )
                     )
                  )
               )
            )
         )
      ),
      
      # Version History Panel
      nav_panel(
         "Version History",
         div(
            tags$h1("Version History"),
            tags$ul(
               tags$li("Version 0.1.1 - Updated copy & paste functions, added tooltips, and revised layout"),
               tags$li("Version 0.1.0 - Initial Alpha release")
            )
         )
      ),
      
      # Downloads Menu
      nav_menu(
         "Downloads",
         nav_item(downloadButton("downloadSVG", "Download DAG as SVG", icon = icon("download"))),
         nav_item(downloadButton("downloadPNG", "Download DAG as PNG", icon = icon("download"))),
         nav_item(downloadButton("legendDownload", "Download DAG Legend", icon = icon("download"))),
         nav_item(actionButton("downloadRCode", "Copy R-Code to Clipboard", icon = icon("copy")))
      )
   )
}
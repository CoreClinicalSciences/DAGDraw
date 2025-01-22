# Define Core UI

compileUI <- function(theme) {
   page_navbar(
      theme = theme,
      # Header with logo
      title = div(
         class = "navbar-title-container",
         style = "width: 100%; position: relative; top: 15px",
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
               style = "max-width: 300px; height: 100vh;",
               card(
                  full_screen = TRUE,
                  displayNodesUI("displayNodes")
               ),
               # DAG Options Accordion
               card(
                  h2("DAG Options", style = "margin: 0 0 10px; border-bottom: solid; color: var(--fg); text-align: center;"),
                  # Layout dropdown
                  div(
                     style = "width: 100%; margin-bottom: 10px;",
                     selectInput(
                        inputId = "layoutSelect",
                        label = "Layout",
                        choices = c(
                           "Kamada-Kawai" = "kk",
                           "Tree" = "tree",
                           "Circle" = "circle"
                        ),
                        selected = "kk"
                     )
                  ),
                  # EffectModifierSwitch UI element is conditionally rendered based on state logic in the core server 
                  div(style = "width: 100%;", uiOutput("effectModifierSwitch")),
                  fluidRow(
                     div(
                        style = "width: 100%; font-size: 0.95rem;",
                        materialSwitch(
                           inputId = "showBackdoor",
                           label = "Show Open Backdoor Paths",
                           status = "primary",
                           right = TRUE
                        )
                     )
                  ),
               )
            ),
            # Main Content Column
            column(
               width = 9,
               card(
                  full_screen = TRUE,
                  div(
                     # style = "position: relative; width: 100%; height: fit-content",
                     # div(
                     #    style = "position: absolute; top: 15px; right: 35px; z-index: 1;",
                     #    actionButton("refreshLayout", NULL, icon = icon("refresh"))
                     # ),
                     div(
                        style = "margin: 15px 0; width: 100%; height: auto;",
                        uiOutput("graph")
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
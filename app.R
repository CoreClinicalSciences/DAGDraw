## Load required libraries ------------------------------------------------
# Shiny and UI frameworks
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinytest2)
library(shinyjs)
library(bslib)
library(bsicons)

# Data manipulation and visualization
library(tidyverse)

# DAG-specific packages
library(ggdag)
library(dagitty)

# Graph rendering
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

## Source files --------------------------------------------------------

# Style
source("R/styleConstants.R")

# Handlers
source("R/handlers/downloadHandlers.R")
source("R/handlers/graphHandlers.R")
source("R/handlers/pathHandlers.R")

# Utils
source("R/utils/dataUtils.R")
source("R/utils/formUtils.R")
source("R/utils/displayNodesUtils.R")

# Modules
source("R/modules/displayNodes/displayNodesServer.R")
source("R/modules/displayNodes/displayNodesUI.R")
source("R/modules/editNode/editNodeServer.R")
source("R/modules/editNode/editNodeUI.R")
source("R/modules/renameNodes/renameNodesServer.R")
source("R/modules/renameNodes/renameNodesUI.R")
source("R/modules/dagVisualization/dagVisualizationServer.R")
source("R/modules/dagVisualization/dagVisualizationUI.R")
source("R/modules/addNode/addNodeServer.R")
source("R/modules/addNode/addNodeUI.R")
source("R/modules/pathButtons/pathButtonsServer.R")
source("R/modules/pathButtons/pathButtonsUI.R")

# Core components
source("R/coreUI.R")
source("R/coreServer.R")
source("R/welcomeModal.R")
source("R/stateManagement.R")

## Theme Configuration -------------------------------------------------
appTheme <- bs_theme(
   bg = "#ffffff",
   fg = "#000000",
   primary = "#BDDD21",
   secondary = "#462A79",
   success = "#423F85",
   base_font = font_google("Roboto"),
   code_font = font_google("JetBrains Mono"),
   heading_font = font_google("Lato")
) |>
   
   bs_add_rules("
     .conditioned, .highlighted { 
       background-color: var(--bs-secondary) !important;
       color: white !important;
     }
   ")

## Environment Configuration ---------------------------------------------
app_env <- Sys.getenv("R_ENV", "development")
warning_level <- if(app_env == "production") -1 else 1
options(warn = warning_level)

## Compile UI -------------------------------------------------------
coreUI <- compileUI(appTheme)

## Initialize Shiny Application -------------------------------------
# coreServer function from coreServer.R
shinyApp(coreUI, coreServer)

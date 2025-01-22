# General node colors
setFillColor <- "white"
setOutlineColor <- "#423f85"
setFontColor <- "black"

# Base node colors (for treatment and response)
baseNodeFillColor <- "white"
baseNodeOutlineColor <- "black"
baseNodeFontColor <- "black"

# Conditioned node colors
conditionedFillColor <- "#D8EB79"
conditionedOutlineColor <- "#BDDD21"
conditionedFontColor <- "black"

# Unmeasured node colors
unmeasuredNodeFillColor <- "lightgrey"
unmeasuredNodeOutlineColor <- "#767372"
unmeasuredNodeFontColor <- "#767372"

# Effect modifier colors
effectModifierOutlineColor <- "red"

# Bslib theme
appTheme <- bs_theme(
   bg = "#ffffff",
   fg = "#000000",
   primary = "#BDDD21",
   secondary = "#462A79",
   success = "#423F85",
   base_font = font_google("Roboto"),
   code_font = font_google("JetBrains Mono"),
   heading_font = font_google("Lato"),
) |>
   
   bs_add_rules("
     .conditioned { 
         background-color: #D8EB79 !important;
         border-color: #798343 !important;
     }
     
     .highlighted {
         background-color: var(--bs-secondary) !important;
         color: white !important
     }
   
     .unmeasuredNode {
         background-color: lightgrey !important;
         border-color: #767372 !important;
     }
     
     @media screen and (max-width: 768px) {
            .navbar-title-container {
               position: static !important;
               top: 0 !important;
            }
         }
   ")

# In app variable strings
TREATMENT <- "Treatment or Exposure Name"
RESPONSE <- "Response or Outcome Name"
MEASURED <- "Observed"
UNMEASURED <- "Unobserved"


# General node colors
setFillColor <- "white"
setOutlineColor <- "#423f85"
setFontColor <- "black"

# Base node colors (for treatment and response)
baseNodeFillColor <- "#605279"
baseNodeOutlineColor <- "#372f45"
baseNodeFontColor <- "white"

# Conditioned node colors
conditionedFillColor <- "#D8EB79"
conditionedOutlineColor <- "#4a5129"
conditionedFontColor <- "#4a5129"

# Unmeasured node colors
unmeasuredNodeFillColor <- "lightgrey"
unmeasuredNodeOutlineColor <- "#767372"
unmeasuredNodeFontColor <- "#767372"

# Effect modifier colors
effectModifierOutlineColor <- "red"

# In app variable strings
TREATMENT <- "Treatment or Exposure Name"
RESPONSE <- "Response or Outcome Name"
MEASURED <- "Observed"
UNMEASURED <- "Unobserved"

# igraph layout configuration
LAYOUT_OPTIONS <- list(
   "Auto" = "nicely",
   "Circle" = "circle",
   "Fruchterman and Reingold" = "fr",
   "Kamada-Kawai" = "kk",
   "Neato" = "neato",
   "Tree" = "tree"
)

DEFAULT_LAYOUT <- "nicely"
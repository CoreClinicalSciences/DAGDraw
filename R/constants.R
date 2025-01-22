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
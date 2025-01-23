# From a path list filter to the paths going into x
FindCausalPaths <- function( pathList ) {
   causalPaths <- c()
   for (path in pathList) {
      # Finds the first character after a space to see if it is going to ("<") treatment ("x")
      tempSub <- sub("^.*?\\s+(.)", "\\1", path)
      if (substr(tempSub, 1, 1) == "<") {
         causalPaths <- append(causalPaths, path)
      }
   }
   
   return(causalPaths)
}

# Returns a list of all open paths
FindOpenPaths <- function( toData, response, treatment ) {
   toDag <- DataToDag(toData)
   
   conditionedNodes <- toData %>%
      filter(conditioned)
   conditionedNodes <- unique(as.list(conditionedNodes$name))
   
   allPaths <- paths(toDag,
                     from = response,
                     to = treatment,
                     Z = conditionedNodes
   )
   
   openPaths <- allPaths$paths[allPaths$open]
   
   return(openPaths)
}

# From a path list filter to the paths caused by Selection Bias 
# (conditioning on a Collider)
FindSelectionBiasPaths <- function( pathList, conditionedList ) {
   if (length(conditionedList) > 0) {
      selectionBiasPaths <- c()
      for (path in pathList) {
         # Find the children of x
         tempSub <- sub("^.*?\\s+(.)", "\\1", path)
         if (substr(tempSub, 1, 1) != "<") {
            # Check if the path has a conditioned variable
            containsItem <- any(sapply(conditionedList, grepl, path))
            if (containsItem) {
               selectionBiasPaths <- c(selectionBiasPaths, path)
            }
         }
      }
      return(selectionBiasPaths)
   }
}

# Converts a path (string) to a data frame for graphing
PathStringToDF <- function( path ) {
   pathDF <- unlist(strsplit(path, " "))
   
   nodeList <- c()
   directionList <- c()
   
   # Gives us our nodes
   for (s in pathDF) {
      if (s != "<-" & s != "->") {
         nodeList <- append(nodeList, s)
      } else {
         directionList <- append(directionList, s)
      }
   }
   
   # Build the data frame
   columns <- c("name", "to")
   
   edgeDF <- data.frame(matrix(nrow = 0, ncol = length(columns)))
   colnames(edgeDF) <- columns
   
   i <- 1
   for (d in directionList) {
      if (d == "->") {
         edgeDF[nrow(edgeDF) + 1,] = c(nodeList[i], nodeList[i+1])
      } else {
         edgeDF[nrow(edgeDF) + 1,] = c(nodeList[i+1], nodeList[i])
      }
      i <- i + 1
   }
   
   return(edgeDF)
}

FindEffectModifiers <- function( toData, response ) {
   if (c("Participation") %in% toData$name) {
      # Creates a DAG off of toData
      temp <- toData %>% select(name, to) 
      
      connectedNodes <- temp %>% filter(!is.na(to)) %>%
         mutate(
            temp = to,
            to = name,
            name = temp
         ) %>%
         select(name, to)
      
      
      dagObject <- as_tidy_dagitty(connectedNodes)
      
      # Pull the dag and find ancestors of response and "participation"
      dag <- pull_dag(dagObject)
      dagittyObject <- as.dagitty(dag)
      
      responseAncestors <- ancestors(dagittyObject, response)
      responseAncestors <- responseAncestors[!(responseAncestors %in% c(response))]
      
      if (c("Participation") %in% toData$to) {
         participAncestors <- ancestors(dagittyObject, "Participation")
         participAncestors <- participAncestors[!(participAncestors %in% c("Participation"))]
         
         effectModifiers <- intersect(participAncestors, responseAncestors)
         return(effectModifiers)
      }
      
      return(c())
   }
}
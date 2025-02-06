# Checks that name follows the rules:
#    Not an empty value
#    No Special Characters
#    below 24 Characters
#    Isn't graph or node

CheckNameInput <- function( name ) {
   
   error_text <- ""
   
   # Makes sure there is a value
   name_not_null <- (!is.null(name) && name != "")
   
   if(!name_not_null){
      error_text <- "Node must have a name"
      return(list(isValid = FALSE, errorMessage = error_text))
   } else {
      # These words cause issues somewhere else in the code
      name_not_special <- (name != "node" && name != "graph" && name != "newNode")
      
      if(!name_not_special){
         error_text <- 'Name cannot be "node", "newNode", or "graph"'
      }
      
      # No spaces or special characters in the input
      no_space_special_char <- (
         str_length(name) == str_length(str_replace_all(name, " ", "")) &&
            !(grepl("[^A-Za-z0-9_]", name))
      )
      
      if(!no_space_special_char){
         error_text <- "Do not use spaces or special characters in name"
      }
      
      below_char <- str_length(name) <= 24
      
      if(!below_char){
         error_text <- "Name must be below 24 characters"
      }
   }
   
   text_filled <- ((
      name_not_null && name_not_special && no_space_special_char && below_char
   ))
   
   if(text_filled){
      error_text <- ""
   }
   
   return(list(isValid = text_filled, errorMessage = error_text))
}

# Sets up '*' for mandatory fields
LabelMandatory <- function( label ) {
   i <- tagList(
      span("*", class = "MandatoryStar"),
      label
   )
   return(i)
}
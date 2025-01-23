# Converts form data to long format
ToDataLong <- function( toData ) {
   longDF <- toData %>%
      pivot_longer(cols = c(parents, children), names_to = "relation", values_to = "node") %>%
      unnest_longer(node) %>%
      mutate(relation = if_else(relation == "parents", "parent", "child"))
   
   to_df <- longDF %>%
      filter(relation == "child") %>%
      rename(to = node) %>%
      select(name, to)
   
   from_df <- longDF %>%
      filter(relation == "parent") %>%
      rename(to = name, name = node) %>%
      select(name, to)
   
   longDF <- bind_rows(to_df, from_df)
   
   return(longDF)
}

# Turns the toDataStorage data into a dag for analysis (Path finding)
DataToDag <- function( toData ) {
   dag <- toData %>%
      mutate(
         temp = to,
         to = name,
         name = temp
      ) %>%
      filter(!is.na(to)) %>%
      as_tidy_dagitty
   
   # Create the DAG
   # pull_dag flips the to and name (as fixed in the mutate)
   dag <- pull_dag(dag)
   
   return(dag)
}

# Image Utils -----------------------------------------------------------

convertImgToDataUrl <- function(path) {
   # Convert png to data encoded URL
   text_encoded_img <- base64enc::base64encode(path)
   data_url <- paste0("data:image/png;base64,", text_encoded_img)
   data_url
}
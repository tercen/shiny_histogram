
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(rtercen)
 
# devtools::install_github("tercen/rtercen")
  
shinyServer(function(input, output, session) {
  
  dataInput = reactive({getValues(session)})

  output$distPlot <- renderPlot({

    # generate bins based on input$bins from ui.R
    x    <- dataInput()
  
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')

  })

})

getValues = function(session){
  # retreive url query parameters provided by tercen
  query = parseQueryString(session$clientData$url_search)
  
  token = query[["token"]]
  workflowId = query[["workflowId"]]
  stepId = query[["stepId"]]
  
  # create a Tercen client object using the token
  client = rtercen::TercenClient$new(authToken=token)
  # get the cube query defined by your workflow
  query = client$getCubeQuery(workflowId, stepId)
  # execute the query and get the data
  cube = query$execute()
  
  x = cube$sourceTable$getColumn("values")$getValues()$getData()
  return(x)
}

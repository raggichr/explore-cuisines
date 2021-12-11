#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Explore Cuisines"),
    
    # Add theme
    theme = shinythemes::shinytheme("darkly"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput(
                inputId = "cuisine",
                label = "Select cuisine",
                choices = unique(.GlobalEnv$recipes$cuisine)
            ),
            sliderInput(
                inputId = "nb_ingredients",
                label = "Select no. of ingredients:",
                min = 5,
                max = 100,
                value = 20
            )
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabsetPanel(
                    tabPanel("Word Cloud", plotOutput("wc_ingredients")),
                    tabPanel("Plot", plotly::plotlyOutput("plot_top_ingredients")),
                    tabPanel("Table", DT::DTOutput("dt_top_ingredients"))
                )
            )
        )
    )
)

# Run the application 
# shinyApp(ui = ui, server = server)

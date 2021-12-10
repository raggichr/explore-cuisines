#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(d3wordcloud) # devtools::install_github("jbkunst/d3wordcloud")
library(plotly)
library(DT)
library(forcats)
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Explore Cuisines"),
    
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
            ),
            actionButton(inputId = "redraw", label = "Redraw wordcloud"),
            checkboxInput(inputId = "fix", label = "Apply fix", value = F)
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabsetPanel(
                    tabPanel("Word Cloud", d3wordcloudOutput("wc_ingredients")),
                    tabPanel("Plot", plotly::plotlyOutput("plot_top_ingredients")),
                    tabPanel("Table", DT::DTOutput("dt_top_ingredients"))
                )
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$dt_top_ingredients <- DT::renderDT({
        .GlobalEnv$recipes %>%
            filter(.data$cuisine == input$cuisine) %>%
            count(.data$ingredients, name = "nb_recipes") %>%
            arrange(desc(.data$nb_recipes)) %>%
            head(input$nb_ingredients)
    })
    
    rval_top_ingredients <- reactive({
        .GlobalEnv$recipes_enriched %>%
            filter(.data$cuisine == input$cuisine) %>%
            arrange(desc(.data$tf_idf)) %>%
            head(input$nb_ingredients) %>%
            mutate(ingredients = forcats::fct_reorder(.data$ingredients, .data$tf_idf))
    })
    
    output$plot_top_ingredients <- plotly::renderPlotly({
        rval_top_ingredients() %>%
            ggplot(aes(x = .data$ingredients, y = .data$tf_idf)) +
            geom_col() +
            coord_flip()
    })
    
    output$wc_ingredients <- d3wordcloud::renderD3wordcloud({
        dat <- rval_top_ingredients()
        
        input$redraw # FIXME: redraw word cloud when button is clicked
        if(input$fix) shinyjs::runjs("$('#wc_ingredients svg g').empty()") # FIXME: clear the canvas before drawing new cloud
        
        d3wordcloud(dat$ingredients, dat$nb_recipes, tooltip = TRUE)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

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
    
    output$wc_ingredients <- renderPlot({
        dat <- rval_top_ingredients()
        wordcloud::wordcloud(
            words = dat$ingredients, 
            freq = dat$nb_recipes,
            scale=c(2,.25))
    })
}

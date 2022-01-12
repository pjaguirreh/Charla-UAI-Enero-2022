output$graf <- renderPlotly({
  ggplotly(
    datos_votaciones_pob %>% 
      filter(region == input$region) %>% 
      ggplot(aes(x = per_pob2020, y = participacion, label = com_nom)) +
      geom_point(size = 1, col = "grey") +
      geom_smooth(method = "lm", se = FALSE, col = "red") +
      theme_minimal() +
      labs(x = "% Pobreza 2020 (ingresos)",
           y = "% de participación")
  )
})
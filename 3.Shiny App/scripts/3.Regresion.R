output$regresion <- renderUI({
  HTML(
    datos_votaciones_pob %>% 
      filter(region == input$region) %>% 
      lm(participacion ~ per_pob2020, data = .) %>%
      stargazer(type="html", omit.stat = c("adj.rsq", "f", "ser"))
  )
  
})
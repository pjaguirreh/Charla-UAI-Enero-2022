output$mapa <- renderPlotly(
  ggplotly(mapa_comunas %>% 
             mutate(codigo_comuna = as.numeric(codigo_comuna)) %>% 
             left_join(datos_votaciones_pob, by = c("codigo_comuna" = "cod_casen")) %>% 
             filter(com_nom != "ISLA DE PASCUA") %>% 
             filter(region == input$region) %>% 
             ggplot(aes(geometry = geometry, 
                        fill = participacion)) +
             geom_sf() +
             scale_fill_gradientn(name = "Participación", colours = c("red", "green")) +
             theme_minimal() +
             labs(x = NULL, y = NULL)
  )
)
#---------------------------------------------------#
# AUTOR: Pablo Javier Aguirre Hörmann
# GitHub: https://github.com/pjaguirreh
# Twitter: @PAguirreH
# LinkedIn: https://www.linkedin.com/in/pjaguirreh/
#---------------------------------------------------#

# Cargar librerías
library(dplyr)
library(broom)
library(stargazer)
library(ggplot2)
library(plotly)
library(chilemapas)

# Cargar datos
datos_votaciones_pob <- read_csv("../0.datos/BBDDComuna.csv")

##########################
## Interfaz de ususario ##
##########################

ui <- fluidPage(
  
  titlePanel("Nivel de participación (% del padrón) vs Pobreza por ingreso (%)"),
  
  sidebarLayout(
    sidebarPanel(
      
      # Barra de selección de region
      selectInput("region",
                  "Seleccione una región:",
                  sort(unique(datos_votaciones_pob$region)),
                  selected = "Coeficiente GINI (desigualdad)"
      ),
      
      h6("Datos obtenidos desde:"),
      h6("- https://www.servelelecciones.cl/"),
      h6("- http://observatorio.ministeriodesarrollosocial.gob.cl/pobreza-comunal")
      )
    ,
    
    mainPanel(
      h4("Gráfico: Cada punto es una comuna"),
      plotlyOutput("graf", height = "450px"),
      h4("Tabla: Regresión Participacion = b0 + b1*Pobreza"),
      tableOutput("regresion"),
      h4("Mapa"),
      plotlyOutput("mapa")
      
    )
  )
)

##############
## SERVIDOR ##
##############

server <- function(input, output) {
  
  # Generar gráfico principal
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
  
  output$regresion <- renderUI({
    HTML(
    datos_votaciones_pob %>% 
      filter(region == input$region) %>% 
      lm(participacion ~ per_pob2020, data = .) %>%
      stargazer(type="html", omit.stat = c("adj.rsq", "f", "ser"))
    )
    
  })
  
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
  
}

# Ejecutar aplicación
shinyApp(ui = ui, server = server)
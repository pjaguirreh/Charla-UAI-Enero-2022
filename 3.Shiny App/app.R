#---------------------------------------------------#
# AUTOR: Pablo Javier Aguirre Hörmann
# GitHub: https://github.com/pjaguirreh
# Twitter: @PAguirreH
# LinkedIn: https://www.linkedin.com/in/pjaguirreh/
#---------------------------------------------------#

# Definir ruta de trabajo (esto dependerá de donde tengan los archivos en su PC)
setwd("../3.Shiny App")

# Cargar librerías
source("scripts/1.Paquetes.R", encoding = "UTF-8")

# Cargar datos
datos_votaciones_pob <- read_csv("../0.datos/BBDDComuna.csv")

##########################
## Interfaz de ususario ##
##########################

# ACÁ SE DEFINE LA DISTRIBUCIÓN QUE TENDRÁ LA "APP"

ui <- fluidPage(
  
  titlePanel("Nivel de participación (% del padrón) vs Pobreza por ingreso (%)"),
  
  sidebarLayout(
    sidebarPanel(
      
      # Barra de selección de región (menú desplegable)
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
    
    # Acá se define el orden de cada objeto de la "app"
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
  
  # Generar gráfico entre participación y pobreza
  source("scripts/2.Grafico.R", encoding = "UTF-8", local = T)
  
  # Generar tabla de regresión
  source("scripts/3.Regresion.R", encoding = "UTF-8", local = T)
  
  # Generar mapa
  source("scripts/4.Mapa.R", encoding = "UTF-8", local = T)
  
}

# Ejecutar aplicación
shinyApp(ui = ui, server = server)
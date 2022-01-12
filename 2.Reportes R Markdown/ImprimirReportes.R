#---------------------------------------------------#
# AUTOR: Pablo Javier Aguirre Hörmann
# GitHub: https://github.com/pjaguirreh
# Twitter: @PAguirreH
# LinkedIn: https://www.linkedin.com/in/pjaguirreh/
#---------------------------------------------------#

# Definir ruta de trabajo (esto dependerá de donde tengan los archivos en su PC)
setwd("../2.Reportes R Markdown")

# Cargar paquetes
library(readr) # Cargar datos
library(stringr) # Manejo de texto

# Cargar datos
datos_votaciones_pob <- read_csv("../0.datos/BBDDComuna.csv")

# Generar reportes para cada región
# Este es un ciclo/bucle/loop donde en cada iteración se genera un reporte
for (i in unique(datos_votaciones_pob$region)){
  
  # Este paso es para el nombre que tendrá el documento final
  reg_nombre <- str_replace_all(str_to_title(str_remove_all(str_remove_all(i, "DE "), "DEL ")), " ", "")
  
  # Esta es la función que genera el documento en cada iteración
  rmarkdown::render(
    input = "ReporteRegion.Rmd",
    params = list(reg = i),
    output_file = paste0("Reportes/Reporte_", reg_nombre, ".docx")
  )
}

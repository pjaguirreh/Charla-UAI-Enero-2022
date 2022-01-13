#---------------------------------------------------#
# AUTOR: Pablo Javier Aguirre Hörmann
# GitHub: https://github.com/pjaguirreh
# Twitter: @PAguirreH
# LinkedIn: https://www.linkedin.com/in/pjaguirreh/
#---------------------------------------------------#

# Definir ruta de trabajo (esto dependerá de donde tengan los archivos en su PC)
setwd("../1.Análisis")

# Cargar paquetes
library(readr) # Cargar datos
library(dplyr) # Manejo de datos
library(ggplot2) # Visualización de datos
library(stargazer) # Reportar tabla de regresión en archivo output
library(broom) # Reportar resultados de regresión en R
library(chilemapas) # Mapas de Chile

# Cargar datos
datos_votaciones_pob <- read_csv("../0.datos/BBDDComuna.csv")

# Analizar datos disponibles
glimpse(datos_votaciones_pob)

# Distribución en los niveles de participación (histograma)
datos_votaciones_pob %>% 
  ggplot(aes(x = participacion)) +
  geom_histogram(binwidth = 0.01, col = "black") +
  theme_minimal()

# Distribución en los niveles de participación por región (boxplot)
datos_votaciones_pob %>% 
  ggplot(aes(y = reorder(region, -orden_reg), x = participacion)) +
  geom_boxplot() +
  theme_minimal() +
  labs(y = NULL)

# Comunas con mayor y menor participación
datos_votaciones_pob %>% 
  arrange(-participacion) %>% 
  slice(c(1,346)) %>% 
  select(region, com_nom, participacion)

# Distribución en los niveles de pobreza por comuna (histograma)
datos_votaciones_pob %>% 
  ggplot(aes(x = per_pob2020)) +
  geom_histogram(binwidth = 0.01, col = "black") +
  theme_minimal()

# Distribución en los niveles de pobreza por región (boxplot)
datos_votaciones_pob %>% 
  ggplot(aes(y = reorder(region, -orden_reg), x = per_pob2020)) +
  geom_boxplot() +
  theme_minimal() +
  labs(y = NULL)

# Comunas con mayor y menor pobreza
datos_votaciones_pob %>% 
  filter(!is.na(per_pob2020)) %>% 
  arrange(per_pob2020) %>% 
  slice(c(1,344)) %>% 
  select(region, com_nom, per_pob2020)

# Relación entre participación y pobreza comunal a nivel nacional
datos_votaciones_pob %>% 
  ggplot(aes(x = per_pob2020, y = participacion)) +
  geom_point(size = 1, col = "grey") +
  geom_smooth(method = "lm", se = FALSE, col = "red") + # Linea de regresión simple
  theme_minimal() +
  labs(x = "% Pobreza 2020 (ingresos)",
       y = "% de participación",
       title = "Cambio en participación según nivel de pobreza",
       subtitle = "A mayores niveles de pobreza por ingreso, menor participación electoral")

# Regresión simple entre participación y pobreza
datos_votaciones_pob %>% 
  lm(participacion ~ per_pob2020, data = .) %>% 
  tidy()

# Relación entre participación y pobreza comunal a nivel regional
datos_votaciones_pob %>% 
  ggplot(aes(x = per_pob2020, y = participacion)) +
  geom_point(size = 1, col = "grey") +
  geom_smooth(method = "lm", se = FALSE, col = "red") +
  theme_minimal() +
  facet_wrap(vars(region), scale = "free") +
  labs(x = "% Pobreza 2020 (ingresos)",
       y = "% de participación",
       title = "Cambio en participación según nivel de pobreza",
       subtitle = "Existen distintas relaciones a través de las regiones")

# Unir datos de pobreza y participación a "shapefile" de mapa de Chile
datos_mapa <- mapa_comunas %>% 
  mutate(codigo_comuna = as.numeric(codigo_comuna)) %>% 
  left_join(datos_votaciones_pob, by = c("codigo_comuna" = "cod_casen")) %>% 
  filter(com_nom != "ISLA DE PASCUA") 

# Generar mapa
datos_mapa %>% 
  ggplot(aes(geometry = geometry, 
             fill = participacion)) +
  geom_sf(lwd = 0, colour = NA) +
  scale_fill_gradientn(name = "Participación", colours = c("red", "green")) +
  theme_minimal() +
  labs(x = NULL, y = NULL)

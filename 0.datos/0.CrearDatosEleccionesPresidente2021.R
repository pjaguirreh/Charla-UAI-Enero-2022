#---------------------------------------------------#
# AUTOR: Pablo Javier Aguirre Hörmann
# GitHub: https://github.com/pjaguirreh
# Twitter: @PAguirreH
# LinkedIn: https://www.linkedin.com/in/pjaguirreh/
#---------------------------------------------------#

#####################
## CARGAR PAQUETES ##
#####################
library(rjson)
library(readr)
library(readxl)
library(dplyr)
library(stringr)
library(stringi)
library(tictoc)

##############################################################
## EXTRAER INFORMACIÓN DESDE SERVEL (RESULTADOS POR COMUNA) ##
##############################################################

# Lista de comunas para loop
lista_comunas <- fromJSON(file = "https://www.servelelecciones.cl/data/elecciones_presidente/filters/comunas/all.json")

# Data frame que almacenará resultados
vot_comunas <- tibble(com_cod = rep(0, length(lista_comunas)), 
                      com_nom = rep("", length(lista_comunas)), 
                      padron = rep(0, length(lista_comunas)),
                      vot_boric = rep(0, length(lista_comunas)), 
                      vot_kast = rep(0, length(lista_comunas)), 
                      vot_nulo = rep(0, length(lista_comunas)), 
                      vot_blanco = rep(0, length(lista_comunas)))

# Loop de extracción de datos
tic() # Para medir tiempo (inicio)
for (i in seq_along(lista_comunas)){
  print(i) # para hacer seguimiento a proceso
  
  # datos de votación
  detalle_comuna <- fromJSON(file = paste0("https://servelelecciones.cl/data/elecciones_presidente/computo/comunas/",
                                           lista_comunas[[i]]$c,
                                            ".json"))
  
  # datos de padrón electoral
  padron_comuna <- fromJSON(file = paste0("https://servelelecciones.cl/data/participacion/computo/comunas/",
                                          lista_comunas[[i]]$c,
                                          ".json"))
  
  # poner resultados en data frame
  vot_comunas[i,1] <- lista_comunas[[i]]$c
  vot_comunas[i,2] <- lista_comunas[[i]]$d
  vot_comunas[i,3] <- as.numeric(str_remove_all(padron_comuna[[5]][[1]]$c, "\\."))
  vot_comunas[i,4] <- as.numeric(str_remove_all(detalle_comuna[[4]][[1]]$c, "\\."))
  vot_comunas[i,5] <- as.numeric(str_remove_all(detalle_comuna[[4]][[2]]$c, "\\."))
  vot_comunas[i,6] <- as.numeric(str_remove_all(detalle_comuna[[5]][[2]]$c, "\\."))
  vot_comunas[i,7] <- as.numeric(str_remove_all(detalle_comuna[[5]][[3]]$c, "\\."))
}
toc() # Para medir tiempo (fin)

###############################
## COMPLETAR Y ORDENAR DATOS ##
###############################

# Diccionario de región-distrito-comuna
reg_dist_com <- read_csv("Lista_RegionDistritoComuna.csv")

# Ajustes a data frame
datos_votaciones2021 <- vot_comunas %>% 
  rowwise() %>% 
  mutate(vot_validos = sum(vot_boric, vot_kast),
         vot_tot = sum(vot_validos, vot_nulo, vot_blanco),
         participacion = vot_tot/padron) %>% 
  ungroup() %>% 
  left_join(reg_dist_com, by = c("com_nom" = "comuna")) %>% 
  mutate(region = ifelse(is.na(region), "DE MAGALLANES Y DE LA ANTARTICA CHILENA", region),
         distrito = ifelse(is.na(distrito), "DISTRITO 28", distrito),
         orden_reg = case_when(
           region == "DE ARICA Y PARINACOTA" ~ 1,
           region == "DE TARAPACA" ~ 2,
           region == "DE ANTOFAGASTA" ~ 3,
           region == "DE ATACAMA" ~ 4,
           region == "DE COQUIMBO" ~ 5,
           region == "DE VALPARAISO" ~ 6,
           region == "METROPOLITANA DE SANTIAGO" ~ 7,
           region == "DEL LIBERTADOR GENERAL BERNARDO O'HIGGINS" ~ 8,
           region == "DEL MAULE" ~ 9,
           region == "DE ÑUBLE" ~ 10,
           region == "DEL BIOBIO" ~ 11,
           region == "DE LA ARAUCANIA" ~ 12,
           region == "DE LOS RIOS" ~ 13,
           region == "DE LOS LAGOS" ~ 14,
           region == "DE AYSEN DEL GENERAL CARLOS IBAÑEZ DEL CAMPO" ~ 15,
           region == "DE MAGALLANES Y DE LA ANTARTICA CHILENA" ~ 16 
         )) %>% 
  select(region, distrito, com_nom, "cod_servel" = com_cod, everything()) %>% 
  mutate(com_nom = stri_trans_general(com_nom, id = "Latin-ASCII"))

# Datos de pobreza (ingresos) por comuna
pob_com <- read_excel("Estimaciones_de_Tasa_de_Pobreza_por_Ingresos_por_Comunas_2020.xlsx") %>% 
  mutate(`Nombre comuna` = str_to_upper(`Nombre comuna`),
         `Nombre comuna` = stri_trans_general(str = `Nombre comuna`, id = "Latin-ASCII"),
         `Nombre comuna` = case_when(
           `Nombre comuna` == "PAIGUANO" ~ "PAIHUANO",
           `Nombre comuna` == "TREGUACO" ~ "TREHUACO",
           `Nombre comuna` == "MARCHIHUE" ~ "MARCHIGUE",
           TRUE ~ `Nombre comuna`
         )) %>% 
  rename("cod_casen" = `Código`,
         "com_nom" = `Nombre comuna`,
         "per_pob2020" = `Porcentaje de personas en situación de pobreza por ingresos 2020`) %>% 
  select(cod_casen, com_nom, per_pob2020)

# DATA FRAME FINAL
datos_votaciones_pob <- datos_votaciones2021 %>% 
  left_join(pob_com, by = "com_nom") %>% 
  select(region, orden_reg, distrito, com_nom, cod_servel, cod_casen, everything()) 

# EXPORTAR RESULTADO
write_csv(datos_votaciones_pob, "BBDDComuna.csv")

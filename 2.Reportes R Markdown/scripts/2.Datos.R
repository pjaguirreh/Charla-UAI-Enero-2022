datos_votaciones_pob <- read_csv("../0.datos/BBDDComuna.csv")
datos_reg <- datos_votaciones_pob %>% 
  filter(region == params$reg)
reg_tabla <- str_to_title(str_remove_all(str_remove_all(params$reg, "DE "), "DEL "))
tabla <- datos_votaciones_pob %>% 
  group_by(region) %>% 
  summarise(
    vot_tot = sum(vot_tot, na.rm = TRUE),
    padron = sum(padron, na.rm = TRUE),
    orden_reg = mean(orden_reg)
  ) %>% 
  rowwise() %>% 
  mutate(participacion = paste0(round(vot_tot/padron,3)*100, "%"),
         participacion = str_replace_all(participacion, "\\.", ","),
         region = str_remove_all(region, "DE "),
         region = str_remove_all(region, "DEL "),
         region = str_to_title(region)) %>% 
  arrange(orden_reg) %>% 
  select(-orden_reg) %>% 
  rename(
    "Región" = region,
    "N° de votantes" = vot_tot,
    "Tamaño del padrón" = padron,
    "Participación (%)" = participacion
  ) %>% 
  flextable() %>% 
  theme_box() %>% 
  colformat_num(big.mark = ".", decimal.mark = ",") %>% 
  width(j = c(1,2,3,4), width = c(2.5,1.2,1.4,1.2)) %>% 
  fontsize(size = 9, part = "all") %>% 
  align(align = "center", part = "all") %>% 
  padding(padding = 0, part = "body") %>% 
  bg(bg = "light grey", part = "header") %>% 
  bg(~Región == reg_tabla, bg = "yellow")
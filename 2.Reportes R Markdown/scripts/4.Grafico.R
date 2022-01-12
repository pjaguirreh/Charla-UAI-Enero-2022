grafico <- datos_reg %>% 
  ggplot(aes(x = per_pob2020, y = participacion)) +
  geom_point(size = 1, col = "grey") +
  geom_smooth(method = "lm", se = FALSE, col = "red") +
  theme_minimal() +
  labs(x = "% Pobreza 2020 (ingresos)",
       y = "% de participación",
       title = "Cambio en participación según nivel de pobreza")
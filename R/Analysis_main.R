rm(list = ls(all = TRUE))

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Settings ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Libraries
library(tidyverse)
library(ggthemes)
library(brms)
library(dagitty)
library(patchwork)

# Plot Settings
theme_set(
  theme_clean() +
    theme(
      plot.title = element_text(size = 10, hjust = 0.5),
      legend.title = element_blank(), 
      legend.position = "right", 
      legend.background = element_rect(colour = "white"),
      plot.background = element_blank())
)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data preparation ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Load haymeadow data
dat <- read_csv("Data-Raw/Data_sites.csv")
load("Data-Raw/community_matrix.RData")

# Total numnber of sites
nrow(dat)

# Data selection
ausw <- 
  (dat$Delarze == "4.5.1" | dat$Delarze == "4.5.2") &
  !is.na(dat$Delarze) &
  !is.na(dat$Ellenberg_R) 
dat <- dat[ausw,] 
comdat <- comdat[ausw, ]
nrow(dat)

# Elevational range
range(dat$elevation) %>% round()

# Transfrom vairables
dat <- dat %>% 
  mutate(
    EUNIS = ifelse(elevation < 600, "R22", "R23"),
    ndep = (nitrogen_depostion - 10) / 20,
    ele = (elevation - 1000) / 1000,
    temp = (temperature - 10) / 10,
    preci = (precipitation - 1000) / 1000,
    light = (Ellenberg_L - 3.5),
    pH = (Ellenberg_R - 3.3),
    soilN = Ellenberg_N - 3,
    NDVI = (NDVI - 6000) / 1000,
    LUI = landuse_intensity-0.5,
    spec_pool = (species_pool - 250) / 10
  )

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Model definition ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Model description according to http://www.dagitty.net/
conceptualmod <- dagitty('
dag {
bb="-5.227,-3.153,4.663,3.021"
"Landuse intensity" [pos="-2.670,-1.256"]
"Nitrogen deposition" [exposure,pos="-4.317,-2.070"]
"Plant species richness" [outcome,pos="0.747,-1.471"]
"Soil alkalinity" [pos="0.709,-2.095"]
"Soil nutrient content" [pos="-2.795,-1.763"]
"Species pool" [pos="-1.211,-1.085"]
Light [pos="-1.411,-1.427"]
NDVI [pos="-0.974,-1.739"]
Precipitation [pos="-4.229,-1.436"]
Temperature [pos="-4.242,-1.119"]
"Landuse intensity" -> "Nitrogen deposition"
"Landuse intensity" -> "Plant species richness"
"Landuse intensity" -> "Soil nutrient content"
"Landuse intensity" -> Light
"Nitrogen deposition" -> "Plant species richness" [pos="0.173,-2.085"]
"Nitrogen deposition" -> "Soil alkalinity"
"Nitrogen deposition" -> "Soil nutrient content"
"Soil alkalinity" -> "Plant species richness"
"Soil nutrient content" -> "Plant species richness" [pos="-0.538,-2.041"]
"Soil nutrient content" -> NDVI
"Species pool" -> "Plant species richness"
Light -> "Plant species richness"
NDVI -> "Plant species richness"
NDVI -> Light
Precipitation -> "Landuse intensity"
Precipitation -> "Nitrogen deposition"
Precipitation -> NDVI
Temperature -> "Landuse intensity"
Temperature -> "Species pool"
Temperature -> NDVI
}
')

# Plot conceptual model
plot(conceptualmod)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sensitivity (univariate) ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# R2.2, total species richness
r22sr_univar <- brm(
  SR ~ ndep,
  data = dat %>% filter(EUNIS == "R22"),
  family = poisson,
  file = "Modres/main_model/univariate-R22-SR"
) 

# R2.2, number of target species
r22uzl_univar <- brm(
  UZL ~ ndep,
  data = dat %>% filter(EUNIS == "R22"),
  family = poisson,
  file = "Modres/main_model/univariate-R22-UZL"
) 

# R2.3, total species richness
r23sr_univar <- brm(
  SR ~ ndep,
  data = dat %>% filter(EUNIS == "R23"),
  family = poisson,
  file = "Modres/main_model/univariate-R23-SR"
) 

# R23, number of target species
r23uzl_univar <- brm(
  UZL ~ ndep,
  data = dat %>% filter(EUNIS == "R23"),
  family = poisson,
  file = "Modres/main_model/univariate-R23-UZL"
)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Minimal suficient adjustment for total nitgrogen effect----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Which paramter to control for?
adjustmentSets(conceptualmod, "Nitrogen deposition", "Plant species richness")

# R2.2, total species richness
r22sr_minimaladjust <- brm(
  SR ~ ndep + LUI + preci,
  data = dat %>% filter(EUNIS == "R22"),
  family = poisson,
  file = "Modres/main_model/minimaladjust-R22-SR"
) 

# R2.2, number of target species
r22uzl_minimaladjust <- brm(
  UZL ~ ndep + LUI + preci,
  data = dat %>% filter(EUNIS == "R22"),
  family = poisson,
  file = "Modres/main_model/minimaladjust-R22-UZL"
) 

# R2.3, total species richness
r23sr_minimaladjust <- brm(
  SR ~ ndep + LUI + preci,
  data = dat %>% filter(EUNIS == "R23"),
  family = poisson,
  file = "Modres/main_model/minimaladjust-R23-SR"
) 

# R23, number of target species
r23uzl_minimaladjust <- brm(
  UZL ~ ndep + LUI + preci,
  data = dat %>% filter(EUNIS == "R23"),
  family = poisson,
  file = "Modres/main_model/minimaladjust-R23-UZL"
)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Wrong adjustment to estimate total nitgrogen effect----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# R2.2, total species richness
r22sr_minimaladjust_wrong <- brm(
  SR ~ ndep + LUI + preci + pH,
  data = dat %>% filter(EUNIS == "R22"),
  family = poisson,
  file = "Modres/main_model/minimaladjust_wrong-R22-SR"
) 

# R2.2, number of target species
r22uzl_minimaladjust_wrong <- brm(
  UZL ~ ndep + LUI + preci + pH,
  data = dat %>% filter(EUNIS == "R22"),
  family = poisson,
  file = "Modres/main_model/minimaladjust_wrong-R22-UZL"
) 

# R2.3, total species richness
r23sr_minimaladjust_wrong <- brm(
  SR ~ ndep + LUI + preci + pH,
  data = dat %>% filter(EUNIS == "R23"),
  family = poisson,
  file = "Modres/main_model/minimaladjust_wrong-R23-SR"
) 

# R23, number of target species
r23uzl_minimaladjust_wrong <- brm(
  UZL ~ ndep + LUI + preci + pH,
  data = dat %>% filter(EUNIS == "R23"),
  family = poisson,
  file = "Modres/main_model/minimaladjust_wrong-R23-UZL"
)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Changepoint estimation using minimal suficient adjustment for total nitgrogen effect----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Change-point model
changepoint_model <- bf(
  S ~ b0 + b1 * LUI + b2 * preci + betaN * (ndep - ((CL - 10) / 20)) * step(ndep -  ((CL - 10) / 20)),
  b0 + b1 + b2 + betaN + CL ~ 1,
  nl = TRUE,
  family = poisson
)

# Priors
bprior <- 
  prior(normal(3, 1.5), nlpar = "b0") +
  prior(normal(0, 1), nlpar = "b1") +
  prior(normal(0, 1), nlpar = "b2") +
  prior(normal(0, 1), nlpar = "betaN") +
  prior(normal(15, 5), nlpar = "CL")

# R2.2, total species richness
r22sr_changepoint <- brm(
  changepoint_model,
  prior = bprior,
  data = dat %>% filter(EUNIS == "R22") %>% mutate(S = SR),
  file = "Modres/main_model/changepoint-R22-SR"
) 

# R2.2, number of target species
r22uzl_changepoint <- brm(
  changepoint_model,
  prior = bprior,
  data = dat %>% filter(EUNIS == "R22") %>% mutate(S = UZL),
  file = "Modres/main_model/changepoint-R22-UZL"
) 

# R2.3, total species richness
r23sr_changepoint <- brm(
  changepoint_model,
  prior = bprior,
  data = dat %>% filter(EUNIS == "R23") %>% mutate(S = SR),
  file = "Modres/main_model/changepoint-R23-SR"
) 

# R2.3, number of target species
r23uzl_changepoint <- brm(
  changepoint_model,
  prior = bprior,
  data = dat %>% filter(EUNIS == "R23") %>% mutate(S = UZL),
  file = "Modres/main_model/changepoint-R23-UZL"
) 

# Analyse results
print(r22sr_changepoint, digits = 2, robust = TRUE)
print(r22uzl_changepoint, digits = 2, robust = TRUE)
print(r23sr_changepoint, digits = 2, robust = TRUE)
print(r23uzl_changepoint, digits = 2, robust = TRUE)

# Plot R22, total species richness
tymax <- 80
pr22sr <- plot(conditional_effects(r22sr_changepoint), plot = FALSE)[[3]] + 
  ylim(0, tymax) + 
  geom_point(aes(x = ndep, y = S), data = dat %>% filter(EUNIS == "R22") %>% mutate(S = SR), inherit.aes = FALSE, cex = 0.4, col = "grey") +
  annotate(
    geom = "rect", 
    xmin = (summary(r22sr_changepoint, robust = TRUE)$fixed["CL_Intercept", "l-95% CI"] - 10) / 20, 
    xmax = (summary(r22sr_changepoint, robust = TRUE)$fixed["CL_Intercept", "u-95% CI"] - 10) / 20, 
    ymin = 0, ymax = tymax, alpha = .1,fill = "orange") +
  geom_line(
    data = tibble(
      x = rep((summary(r22sr_changepoint, robust = TRUE)$fixed["CL_Intercept", "Estimate"] - 10) / 20, 2),
      y = c(0, tymax)), 
    aes(x = x, y = y),
    col = "orange", inherit.aes = FALSE) +
  labs(
    title = "Lowland hay meadows",
    x = "",
    y = "Total number of species"
  ) +
  scale_x_continuous(breaks = (seq(0,40,10) - 10) / 20, labels = seq(0,40,10), limits = c(-0.5, 1.5))

# Plot R22, target species richness
tymax <- 30
pr22uzl <- plot(conditional_effects(r22uzl_changepoint), plot = FALSE)[[3]] + 
  ylim(0, tymax) + 
  geom_point(aes(x = ndep, y = S), data = dat %>% filter(EUNIS == "R22") %>% mutate(S = UZL), inherit.aes = FALSE, cex = 0.4, col = "grey") +
  annotate(
    geom = "rect", 
    xmin = (summary(r22uzl_changepoint, robust = TRUE)$fixed["CL_Intercept", "l-95% CI"] - 10) / 20, 
    xmax = (summary(r22uzl_changepoint, robust = TRUE)$fixed["CL_Intercept", "u-95% CI"] - 10) / 20, 
    ymin = 0, ymax = tymax, alpha = .1,fill = "orange") +
  geom_line(
    data = tibble(
      x = rep((summary(r22uzl_changepoint, robust = TRUE)$fixed["CL_Intercept", "Estimate"] - 10) / 20, 2),
      y = c(0, tymax)), 
    aes(x = x, y = y),
    col = "orange", inherit.aes = FALSE) +
  labs(
    x = "",
    y = "Number of target species"
  ) +
  scale_x_continuous(breaks = (seq(0,40,10) - 10) / 20, labels = seq(0,40,10), limits = c(-0.5, 1.5))

# Plot R23, total species richness
tymax <- 80
pr23sr <- plot(conditional_effects(r23sr_changepoint), plot = FALSE)[[3]] + 
  ylim(0, tymax) + 
  geom_point(aes(x = ndep, y = S), data = dat %>% filter(EUNIS == "R23") %>% mutate(S = SR), inherit.aes = FALSE, cex = 0.4, col = "grey") +
  annotate(
    geom = "rect", 
    xmin = (summary(r23sr_changepoint, robust = TRUE)$fixed["CL_Intercept", "l-95% CI"] - 10) / 20, 
    xmax = (summary(r23sr_changepoint, robust = TRUE)$fixed["CL_Intercept", "u-95% CI"] - 10) / 20, 
    ymin = 0, ymax = tymax, alpha = .1,fill = "orange") +
  geom_line(
    data = tibble(
      x = rep((summary(r23sr_changepoint, robust = TRUE)$fixed["CL_Intercept", "Estimate"] - 10) / 20, 2),
      y = c(0, tymax)), 
    aes(x = x, y = y),
    col = "orange", inherit.aes = FALSE) +
  labs(
    title = "Mountain hay meadows",
    x = "",
    y = ""
  ) +
  scale_x_continuous(breaks = (seq(0,40,10) - 10) / 20, labels = seq(0,40,10), limits = c(-0.5, 1.5))

# Plot R23, target species richness
tymax <- 30
pr23uzl <- plot(conditional_effects(r23uzl_changepoint), plot = FALSE)[[3]] + 
  ylim(0, tymax) + 
  geom_point(aes(x = ndep, y = S), data = dat %>% filter(EUNIS == "R23") %>% mutate(S = UZL), inherit.aes = FALSE, cex = 0.4, col = "grey") +
  annotate(
    geom = "rect", 
    xmin = (summary(r23uzl_changepoint, robust = TRUE)$fixed["CL_Intercept", "l-95% CI"] - 10) / 20, 
    xmax = (summary(r23uzl_changepoint, robust = TRUE)$fixed["CL_Intercept", "u-95% CI"] - 10) / 20, 
    ymin = 0, ymax = tymax, alpha = .1,fill = "orange") +
  geom_line(
    data = tibble(
      x = rep((summary(r23uzl_changepoint, robust = TRUE)$fixed["CL_Intercept", "Estimate"] - 10) / 20, 2),
      y = c(0, tymax)), 
    aes(x = x, y = y),
    col = "orange", inherit.aes = FALSE) +
  labs(
    x = "",
    y = ""
  ) +
  scale_x_continuous(breaks = (seq(0,40,10) - 10) / 20, labels = seq(0,40,10), limits = c(-0.5, 1.5))

# Make figure
png("Figures/Fig_changepoint_R22vsR23.png", width = 2300, height = 1533, res = 300)
(pr22sr | pr23sr) / (pr22uzl | pr23uzl)  
grid::grid.draw(grid::textGrob(expression(paste("Nitrogen deposition [kg N ", ha^-1, " ", yr^-1, "]")), y = 0.02))
dev.off()
pdf("Figures/Fig_changepoint_R22vsR23.pdf", width = 8, height = 5)
(pr22sr | pr23sr) / (pr22uzl | pr23uzl)  
grid::grid.draw(grid::textGrob(expression(paste("Nitrogen deposition [kg N ", ha^-1, " ", yr^-1, "]")), y = 0.02))
dev.off()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Compare sensitivity estimates ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# R22, total species richness
print(r22sr_univar, digits = 2)
print(r22sr_minimaladjust, digits = 2)
print(r22sr_minimaladjust_wrong, digits = 2)

# R23, total species richness
print(r23sr_univar, digits = 2)
print(r23sr_minimaladjust, digits = 2)
print(r23sr_minimaladjust_wrong, digits = 2)

# R22, number of target species
print(r22uzl_univar, digits = 2)
print(r22uzl_minimaladjust, digits = 2)
print(r22uzl_minimaladjust_wrong, digits = 2)

# R23, number of target species
print(r23uzl_univar, digits = 2)
print(r23uzl_minimaladjust, digits = 2)
print(r23uzl_minimaladjust_wrong, digits = 2)

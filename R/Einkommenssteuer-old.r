#!/usr/bin/env Rscript

# Set Working directory to git root

require(data.table)
library(tidyverse)
# library(REST)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(ggplot2)
library(ggrepel)
library(viridis)
library(hrbrthemes)
library(scales)
library(ragg)

if (rstudioapi::isAvailable()){
    
    # When called in RStudio
    SD <- unlist(str_split(dirname(rstudioapi::getSourceEditorContext()$path),'/'))
    
} else {
    
    #  When called from command line 
    SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
    SD <- unlist(str_split(SD,'/'))
    
}

WD <- paste(SD[1:(length(SD)-1)],collapse='/')
setwd(WD)

# Output folder for SVG

OUTDIR <-'svg'
dir.create( OUTDIR, showWarnings = FALSE, recursive = FALSE, mode = "0777" )

set.seed(42)

EST21 <- data.table (
    Zone = 1:5
  , Begin = c(0,9744,14753,57918,274613)
  , Satz = c(0, 0.14, 0.2397, 0.42, 0.45)
  , Min = c(0,0,950.96,15188.93,106200.86)
  , Faktor = c(0, 995.21e-8, 208.85e-8, 0, 0)
)

EST22 <- data.table (
  Zone = 1:5
  , Begin = c(     0, 10348, 14927,  58597, 277826)
  , Ende  = c( 10348, 14927, 58597, 277826, Inf)
  , s = c(0, 0.14, 0.2397, 0.42, 0.45)
  , C = c(0, 0, 869.32 , -9336.45, -17671.20)
  , p = c(0, 1088.67e-8, 206.43e-8, 0, 0)
  , korr = c(0,10347,14532,0,0)
)

Steuerbetrag <- function (zvE, EST = EST22) {
  
  S <- rep(0,length(zvE))
  B <- rep(0,length(zvE))

  for (z in 1:5) {

    F <- (zvE >= EST$Begin[z] & zvE < EST$Ende[z])
    B[F] <- zvE[F] - EST$korr[z] 
    S[F] <- B[F] * ( EST$p[z] * B[F] + EST$s[z] ) + EST$C[z]
    
  }
 
  return(S)
  
}

ST <- data.table(
  zvE = seq(0,30000, by = 100)
 , Steuer = Steuerbetrag(seq(0,30000, by = 100))
 , Zone = 0
 )

for (z in 1:5) {
  
  F <- (ST$zvE >= EST22$Begin[z] & ST$zvE < EST22$Ende[z])
  ST$Zone[F] = z
  
}

ST$Zone <- factor(ST$Zone, levels = 1:5, labels = paste("Zone", 1:5))

ST %>% ggplot() +
  geom_line(aes( x = zvE, y = Steuer, colour = Zone, group = Zone)) +
  geom_function( fun = Steuerbetrag, color = 'black', linetype = 'dotted' ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(   title = paste( 'Einkommenssteuer' )
          , subtitle = 'Funktion'
          , x = "x"
          , y = "y"
          , caption = paste( "(c) Thomas Arend" )
  )  -> P


ggsave(
  file = paste( OUTDIR, '/Einkommenssteuer.png' , sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 72
)


#!/usr/bin/env Rscript


# (1) 1Die tarifliche Einkommensteuer bemisst sich nach dem zu versteuernden Einkommen. 2
# Sie beträgt ab dem Veranlagungszeitraum 2022 vorbehaltlich der §§ 32b, 32d, 34, 34a, 34b und 34c
# jeweils in Euro für zu versteuernde Einkommen
# 
# 1.
# bis 10 347 Euro (Grundfreibetrag):
#   0;
# 2.
# von 10 348 Euro bis 14 926 Euro:
#   (1088,67 · y + 1400) · y;
# 3.
# von 14 927 Euro bis 58 596 Euro:
#   (206,43 · z + 2397) · z + 869,32;
# 4.
# von 58 597 Euro bis 277 825 Euro:
#   0,42 · x – 9336,45;
# 5.
# von 277 826 Euro an:
#   0,45 · x – 17671,20.

# 3 Die Größe „y“ ist ein Zehntausendstel des den Grundfreibetrag übersteigenden Teils des auf einen vollen Euro-Betrag abgerundeten zu versteuernden Einkommens. 4Die Größe „z“ ist ein Zehntausendstel des 14 926 Euro übersteigenden Teils des auf einen vollen Euro-Betrag abgerundeten zu versteuernden Einkommens. 5Die Größe „x“ ist das auf einen vollen Euro-Betrag abgerundete zu versteuernde Einkommen. 6Der sich ergebende Steuerbetrag ist auf den nächsten vollen Euro-Betrag abzurunden.
# Set Working directory to git root

require(data.table)
library(tidyverse)
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

OUTDIR <-'png/Steuern/'
dir.create( OUTDIR, showWarnings = FALSE, recursive = FALSE, mode = "0777" )

set.seed(42)

EST22 <- data.table (
  Zone = 1:5
  , Begin = c(     0, 10348, 14927,  58597, 277826)
  , Ende  = c( 10347, 14926, 58596, 277825, Inf)
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
 
  return(floor(S))
  
}

M <- 300000
ST <- data.table(
  zvE = seq(0,M, by = 100)
 , Steuer = Steuerbetrag(seq(0,M, by = 100))/seq(0,M, by = 100)
 , Zone = 0
 )

for (z in 1:5) {
  
  F <- (ST$zvE >= EST22$Begin[z] & ST$zvE < EST22$Ende[z])
  ST$Zone[F] = z
  
}

ST$Zone <- factor(ST$Zone, levels = 1:5, labels = paste("Zone", 1:5))

ST %>% ggplot() +
  geom_point(aes( x = zvE, y = Steuer, colour = Zone, group = Zone)) +
#  geom_function( fun = Steuerbetrag, color = 'black', linetype = 'dotted' ) +
  scale_x_continuous(  labels = function ( x ) format( x, big.mark = ".", decimal.mark = ',', scientific = FALSE ) ) +
  scale_y_continuous(  labels = scales::percent ) +
  
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  ) +
  labs(   title = paste( 'Einkommenssteuer als %-Satz des zu versteuernden Einkommens' )
          , subtitle = '2022'
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
  , dpi = 150
)


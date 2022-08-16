#!/usr/bin/env Rscript

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
library( htmltab )

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

OUTDIR <- 'png/Steuern/'
dir.create( OUTDIR, showWarnings = FALSE, recursive = FALSE, mode = "0777" )

bFun <- function(node) {
  x <- XML::xmlValue(node)
  t <- gsub('\\{.*', '', x)
  t <- gsub('\\.', '', t)
  t <- gsub('−', '-', t)
  t <- gsub(' *· 10', 'e', t)
  return(t)
}

set.seed(42)

url <- 'https://www.bundesfinanzministerium.de/Content/DE/Standardartikel/Themen/Schlaglichter/Entlastungen/inflationsausgleichsgesetz-entlastungsbeispiele.html'



for ( J in 1:2) {
  
  ESt = as.data.table( htmltab( url, which = J, bodyFun = bFun, header = 1:3, colNames = c( "zvE", "Einzel", "Splitting" ) ) )
 
  ESt$zvE <- as.numeric(ESt$zvE)
  ESt$Einzel <- as.numeric(ESt$Einzel)
  ESt$Splitting <- as.numeric(ESt$Splitting)
  
    
  ESt %>% filter(zvE <=100000) %>% ggplot() +
    geom_bar(aes( x = zvE, y = Einzel), position = position_dodge(), stat="identity") +
    scale_x_continuous(  labels = function ( x ) format( x, big.mark = ".", decimal.mark = ',', scientific = FALSE ) ) +
    scale_y_continuous(  labels = function ( x ) format( x, big.mark = ".", decimal.mark = ',', scientific = FALSE ) ) +
    expand_limits( x = 0 ) +
    theme_ipsum() +
    theme(  legend.position="right"
            , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
    ) +
    labs(   title = paste( 'Entlastungen des Tarifvorschlags', 2022 + J , 'im Vergleich zum geltenden Tarif 2022' )
          , subtitle = 'Inflationsausgleichsgesetz Vorschlag BMF'
          , x = "Zu versteuerendes Einkommen[€]"
          , y = "Entlastung [€]"
          , caption = paste( "(c) Thomas Arend, Quelle: BMF",url, sep = '' )
  )  -> P


ggsave(
  file = paste( OUTDIR, '/Entlastung_',2022 + J,'.png' , sep='')
  , plot = P
  , device = 'png'
  , bg = "white"
  , width = 1920
  , height = 1080
  , units = "px"
  , dpi = 150
)

}

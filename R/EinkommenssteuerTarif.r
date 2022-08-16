#!/usr/bin/env Rscript
#
#
# Script: MonkeyPox.r
#
# Our World in Data (OWID) 
# Draw diagrams for selected locations
#
# Regression analysis 

# Fit data against an exponetial growth

# Stand: 2022-08-10
#
# ( c ) 2022 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#


MyScriptName <- "Einkommensteuer"

require( data.table )
library( tidyverse )
library( grid )
library( gridExtra )
library( gtable )
library( lubridate )
library( readODS )
library( ggplot2 )
library( ggrepel )
library( viridis )
library( hrbrthemes )
library( scales )
library( ragg )

# library( extrafont )
# extrafont::loadfonts()

# Set Working directory to git root

if ( rstudioapi::isAvailable() ){
 
 # When executed in RStudio
 SD <- unlist( str_split( dirname( rstudioapi::getSourceEditorContext()$path ),'/' ) )
 
} else {
 
 # When executing on command line 
 SD = ( function() return( if( length( sys.parents() ) == 1 ) getwd() else dirname( sys.frame( 1 )$ofile ) ) )()
 SD <- unlist( str_split( SD,'/' ) )
 
}

WD <- paste( SD[1:( length( SD )-1 )],collapse = '/' )

setwd( WD )

source( "R/lib/myfunctions.r" )
source( "R/lib/mytheme.r" )
source( "R/lib/sql.r" )

outdir <- 'png/Progression/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

citation <- "© 2022 by Thomas Arend"

options( 
 digits = 7
 , scipen = 7
 , Outdec = "."
 , max.print = 3000
 )

today <- Sys.Date()
heute <- format( today, "%d %b %Y" )

Einkommen <- RunSQL('select * from Einkommen;')

SQL = paste ( 'select * from Tarifkurve where Jahr > 2018;'
              
)

if ( ! exists( "Tarif" ) ) {
 
  Tarif <- RunSQL(SQL)
  Tarif$Tarifzone <- factor(Tarif$Tarifzone, levels = 0:4, labels = paste('Zone', 0:4))
  Tarif$Jahre <- factor(Tarif$Jahr, levels = 2019:2024, labels = paste('Jahr', 2019:2024))
  
}

Tarif$Eckwert[ Tarif$Eckwert > 400000 ] <- 400000
Tarif$min <- rep(0,nrow(Tarif))

  Tarif %>% filter ( Jahr > 2018 ) %>% ggplot(
    mapping = aes()
  ) +
    geom_line( aes( x = Eckwert, y = Satz, group = Jahr , colour = Jahre), show.legend = TRUE) +
    geom_ribbon( aes( x = Eckwert, ymax = Satz, ymin = min, group = Jahre , fill = Jahre), alpha = 0.3,show.legend = FALSE ) +
    scale_x_continuous( labels = function ( x ) format( x, big.mark = ".", decimal.mark = ',', scientific = FALSE ) ) +
    scale_y_continuous( labels = scales::percent ) +
    theme_ipsum() +
    theme( 
      axis.text.x = element_text(angle = 90)
    )  +
    labs(  title = paste( 'Steuersatz in %' )
           , subtitle = paste( '2022' )
           , x = 'Zu versteuerndes Einkommen'
           , y = 'Steuersatz'
           , colour = 'Jahre' ) -> p1
  
  ggsave(  filename = paste( outdir, MyScriptName, '_Tarif.png', sep = '' )
           , plot = p1
           , path = WD
           , device = 'png'
           , bg = "white"
           , width = 29.7
           , height = 21
           , units = "cm"
           , dpi = 150
  )
  

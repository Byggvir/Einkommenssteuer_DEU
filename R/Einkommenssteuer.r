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

citation <- "© 2022 by Thomas Arend\nQuelle: Our World in Data"

options( 
 digits = 7
 , scipen = 7
 , Outdec = "."
 , max.print = 3000
 )

today <- Sys.Date()
heute <- format( today, "%d %b %Y" )

Einkommen <- RunSQL('select * from Einkommen;')

SQL = paste ( 'select T.Jahr as Jahr, concat("Z",T.Tarifzone) as Tarifzone, E.zvE as zvE,'
              , ' floor(Steuerbetrag(E.zvE,T.UEckwert,T.SteuerBeiUE, T.p, T.Satz)) as Steuerbetrag'
              , ' from Tarifzonen as T join Einkommen as E '
              , ' where T.UEckwert < E.zvE '
              , ' and T.OEckwert >= E.zvE '
              , ' order by E.zvE, T.Jahr;'
)

if ( ! exists( "EST" ) ) {
 
  EST <- RunSQL(SQL)

}

  EST %>%  filter ( zvE <= 60000 | zvE == 200000) %>% ggplot(
    mapping = aes()
  ) +
    geom_step( aes( x = Jahr, y = Steuerbetrag /zvE, group = Tarifzone, colour = Tarifzone )) +
               #, stat = "identity", position = position_dodge() ) +
    expand_limits (y = 0 ) +
    scale_x_continuous( labels = function ( x ) format( x, big.mark = "", decimal.mark = ',', scientific = FALSE ) ) +
    scale_y_continuous( labels = scales::percent ) +
    facet_wrap(vars(zvE)) +
    theme_ipsum() +
    theme( 
      axis.text.x = element_text(angle = 90)
    )  +
    labs(  title = paste( 'Steuerbetrag in % des zu versteuerndem Einkommen' )
           , subtitle = paste( 'Tatsächliche Tarife. 2023 und 2024 aus Eckwerten geschätzt.' )
           , x = 'Jahr'
           , y = 'Steuerbetrag / zvE [%]'
           , colour = 'Tarifzone' ) -> p1
  
  ggsave(  filename = paste( outdir, MyScriptName, '_konstant.png', sep = '' )
           , plot = p1
           , path = WD
           , device = 'png'
           , bg = "white"
           , width = 29.7
           , height = 21
           , units = "cm"
           , dpi = 150
  )
  

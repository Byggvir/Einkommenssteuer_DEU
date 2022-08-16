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

VergleichsJahre <- c(2022,2023)

Einkommen <- RunSQL('select * from Einkommen;')

SQL = paste ( 'select T1.Jahr as Vorjahr, T2.Jahr as Jahr, E.zvE as zvE, '
              , ' floor(Steuerbetrag(E.zvE,T1.UEckwert,T1.SteuerBeiUE, T1.p, T1.USatz)) as Steuerbetrag1,'
              , ' floor(Steuerbetrag(E.zvE,T2.UEckwert,T2.SteuerBeiUE, T2.p, T2.USatz)) as Steuerbetrag2'
              , ' from Tarifzonen as T1 join Einkommen as E '
              , ' join Tarifzonen as T2 on T2.Jahr = T1.Jahr + 1 '
              , ' where T1.UEckwert < E.zvE '
              , ' and T1.OEckwert >= E.zvE '
              , ' and T2.UEckwert < E.zvE '
              , ' and T2.OEckwert >= E.zvE '
              , ' and T2.Jahr > 2018 '
              , ' order by E.zvE, T1.Jahr;'
)

if ( ! exists( "Ersparnis" ) ) {
 
  Ersparnis <- RunSQL(SQL)

}

zvEmax <- 400001

m <- c(max((Ersparnis$Steuerbetrag1 - Ersparnis$Steuerbetrag2)), max((Ersparnis$Steuerbetrag1 - Ersparnis$Steuerbetrag2) / (Ersparnis$zvE - Ersparnis$Steuerbetrag1) ))
scl <- m[2]/m[1]

#    Ersparnis %>% filter( Jahr > 2018 ) %>% ggplot(

Ersparnis %>% filter( Jahr > 2018 & zvE < zvEmax) %>% ggplot(
  mapping = aes()
) +
  geom_line( aes( x = zvE, y = (Steuerbetrag1 - Steuerbetrag2) / (zvE - Steuerbetrag1) , colour = 'Nettoerhöhung [%]')) +
  geom_line( aes( x = zvE, y = (Steuerbetrag1 - Steuerbetrag2) * scl, colour = 'absolute Ersparnis' )) +
  #, stat = "identity", position = position_dodge() ) +
  expand_limits (y = 0 ) +
  scale_x_continuous( labels = function ( x ) format( x, big.mark = ".", decimal.mark = ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = scales::percent,
                      sec.axis = sec_axis(~./scl, name = "Steuerersparnis [€]", labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ))) +
  facet_wrap(vars(Jahr)) +
  theme_ipsum() +
  theme( 
    axis.text.x = element_text(angle = 90)
  )  +
  labs(  title = paste( 'Steuerersparnis absolut und prozentuale Erhöhung des Netto' )
         , subtitle = paste( 'gegenüber dem Vorjahr' )
         , x = 'Zu versteuerndes Einkommen'
         , y = 'relative Ersparnis [%]'
         , colour = 'Tarifzone' ) -> p1

ggsave(  filename = paste( outdir, MyScriptName, '_Ersparnis_1', '.png', sep = '' )
         , plot = p1
         , path = WD
         , device = 'png'
         , bg = "white"
         , width = 29.7
         , height = 21
         , units = "cm"
         , dpi = 150
)

scl <- 1/m[1]

Ersparnis %>% filter( Jahr > 2018 & zvE < zvEmax) %>% ggplot(
      mapping = aes()
  ) +
    geom_line( data = Ersparnis %>% filter(Steuerbetrag1 > 0 & zvE < zvEmax & Jahr > 2018 ), aes( x = zvE, y = (Steuerbetrag1 - Steuerbetrag2) / (Steuerbetrag1) , colour = 'Relative Ersparnis zum alten Netto')) +
    geom_line( aes( x = zvE, y = (Steuerbetrag1 - Steuerbetrag2) * scl, colour = 'absolute Ersparnis' )) +
    #, stat = "identity", position = position_dodge() ) +
    expand_limits (y = 0 ) +
    scale_x_continuous( labels = function ( x ) format( x, big.mark = ".", decimal.mark = ',', scientific = FALSE ) ) +
    scale_y_continuous( labels = scales::percent,
                        sec.axis = sec_axis(~./scl, name = "Steuerersparnis [€]", labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ))) +
    facet_wrap(vars(Jahr)) +
    theme_ipsum() +
    theme( 
      axis.text.x = element_text(angle = 90)
    )  +
    labs(  title = paste( 'Steuerersparnis absolut und relativ zum bisherigen Steuerbetrag' )
           , subtitle = paste( 'gegenüber dem Vorjahr' )
           , x = 'Zu versteuerndes Einkommen'
           , y = 'Relative Ersparnis [%]'
           , colour = 'Tarifzone' ) -> p1
  
  ggsave(  filename = paste( outdir, MyScriptName, '_Ersparnis_2', '.png', sep = '' )
           , plot = p1
           , path = WD
           , device = 'png'
           , bg = "white"
           , width = 29.7
           , height = 21
           , units = "cm"
           , dpi = 150
  )

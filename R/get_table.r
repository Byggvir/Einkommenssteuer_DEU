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
library( RCurl )
library(htmltab)

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

bFun <- function(node) {
  x <- XML::xmlValue(node)
  t <- gsub(' ', '', x)
  t <- gsub(',', '.', t )
  t <- gsub(' bis.*', '', t )
  t <- gsub(' oder mehr', '', t )
  t <- gsub('Insgesamt', '-1', t )
  
return (t)
}

url <- 'https://www.destatis.de/DE/Themen/Staat/Steuern/Lohnsteuer-Einkommensteuer/Tabellen/gde.html'

Statistik <- htmltab( doc = url, which = 1, bodyFun = bFun, header = 1:2, rm_whitespace = TRUE, 
                      colNames = c( 'Von', 'Steuerpflichtige', 'AnteilSteuerpflichtige', 'Betrag', 'AnteilBetrag', 'Steuer', 'AnteilSteuer' ) )

Statistik %>% mutate( Von = as.numeric(Von)
                      , Steuerpflichtige = as.numeric(Steuerpflichtige)
                      , AnteilSteuerpflichtige  = as.numeric(AnteilSteuerpflichtige)
                      , Sumanteil = cumsum(as.numeric(AnteilSteuerpflichtige))
                      , Betrag = as.numeric(Betrag)
                      , AnteilBetrag = as.numeric(AnteilBetrag)
                      , Steuer = as.numeric(Steuer)
                      , cumSteuer = round(cumsum(as.numeric(Steuer)))
                      , AnteilSteuer = as.numeric(AnteilSteuer)
                      , cumAnteilSteuer = cumsum(as.numeric(AnteilSteuer))
                      ) -> S2

# Code to compile Pacific Salmon Explorer data for COSEWIC
# The code was originally written by Eric Hertz at the Pacific Salmon Foundation ehertz@psf.ca 

rm(list = ls(all=TRUE)); #Remove all the objects in the memory
setwd("~/Dropbox (Salmon Watersheds)/X Drive/1_PROJECTS/1_Active/SARA/Deliverables/COSEWIC-compilation/")
library(tidyverse)
library(broom)



#### 1 Read in and manipulateddata

#read in CU level data
cc_file <- read.csv("data/dataset_1part1.Dec072020_CC.csv", header = T)
fraser_file <- read.csv("data/dataset_1part1.Jul282020_Fraser.csv", header = T)
vimi_file <- read.csv("data/dataset_1part1.Jul282021_VIMI.csv", header = T)
nass_file <- read.csv("data/dataset_1part1.Dec092020_Nass.csv", header = T)
skeena_file <- read.csv("data/dataset_1part1.Dec092020_Skeena.csv", header = T)
hg_file <- read.csv("data/dataset_1part1.Oct252021_HG.csv", header = T)
columbia_file <- read.csv("data/dataset_1part1.NOV272019_Columbia.csv", header = T)

# combine files from each region
cu_dat <- rbind(cc_file,fraser_file,vimi_file,nass_file,skeena_file,hg_file,columbia_file)
cu_dat <- select(cu_dat,CUID,Species,Year,LGL.counts,Region)

#check species names
unique(cu_dat$Species)
cu_dat$Species[cu_dat$Species=="River Sockeye"] <- "Sockeye"
cu_dat$Species[cu_dat$Species=="Lake Sockeye"] <- "Sockeye"

names(cu_dat)[names(cu_dat) == "LGL.counts"] <- "Spawner.Abundance"


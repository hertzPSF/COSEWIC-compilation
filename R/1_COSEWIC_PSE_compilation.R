# Code to compile Pacific Salmon Explorer data for COSEWIC
# The code was originally written by Eric Hertz at the Pacific Salmon Foundation ehertz@psf.ca 
library(tidyverse)

rm(list = ls(all=TRUE)); #Remove all the objects in the memory

#setwd("~/Salmon Watersheds Dropbox/Eric Hertz/X Drive/1_PROJECTS/1_Active/SARA/3_Data & Analysis/COSEWIC-compilation")

#### 1 Read in and manipulate data

#read in CU level data
cc_file <- read.csv("data/dataset_1part1.Jun82023_CC.csv", header = T)
fraser_file <- read.csv("data/dataset_1part1.Jul152024_Fraser.csv", header = T)
vimi_file <- read.csv("data/dataset_1part1.Aug292023_VIMI.csv", header = T)
nass_file <- read.csv("data/dataset_1part1.Nov152024_Nass.csv", header = T)
skeena_file <- read.csv("data/dataset_1part1.Nov152024_Skeena.csv", header = T)
hg_file <- read.csv("data/dataset_1part1.Jun82023_HG.csv", header = T)
columbia_file <- read.csv("data/dataset_1part1.Feb122024_Columbia.csv", header = T)
yukon_file <- read.csv("data/yukon_chinook_rr_escape.4Sep2024.csv", header = T)
skeena2_file <- read.csv("data/Sep062024.Winther.Skeena.Chinook.csv", header = T)

columbia_file <- read.csv("data/dataset_1part1.Feb122024_Columbia.csv", header = T) %>%
  #commas in these counts were messing things up
  mutate(LGL.counts = as.integer(gsub(",", "", LGL.counts)), 
         NuSEDS.counts.by.CU = as.integer(gsub(",", "", NuSEDS.counts.by.CU))) 

# drop older Skeena chinook data for CUs with newer data
skeena_file <- skeena_file %>%
  filter(! CUID %in% c(217, 212, 222, 210, 229, 207))

# combine files from each region, switched this to bind_rows to keep the functions in 
  #tidyverse-land. bind_rows has useful warnings.  
cu_dat <- bind_rows(cc_file,fraser_file,vimi_file,nass_file,skeena_file,hg_file,columbia_file,yukon_file,skeena2_file) %>%
  select(CUID, Species, Year, LGL.counts, Region)

#check species names
unique(cu_dat$Species)

#any 0's? in the spawners?
length(filter(cu_dat, LGL.counts==0)$LGL.counts)


cu_dat <- cu_dat %>%
  mutate(Species = ifelse(grepl("Sockeye", Species), "Sockeye", Species),
         Spawner.Abundance = ifelse(LGL.counts==0, NA, LGL.counts)) %>%
  select(-LGL.counts)


write.csv(cu_dat, "Output/CU_Spawner_Abund_20241115.csv", row.names=FALSE)


rm(cc_file, fraser_file, vimi_file, nass_file, skeena_file, hg_file, columbia_file, yukon_file)

#### read in CU decoder
cu_decoder <- read.csv("data/all_regions_cu_du_smu_decoder-Nov-2024.csv", header = T)
  #rename(cuid = ï..cuid) #fix weird special char in colname

#read in other meta-data type files
cu_dq <- read.csv("data/AllRegions_CU_data_quality.csv", header = T)
cu_enh <- read.csv("data/CU_enhancement_levelAug252021.csv", header = T) 
  #rename(cuid = ï..cuid) #fix weird special char in colname
  
cu_sites <- read.csv("data/NuSEDS_cleaned_FULL_CU_IN_streamid_TEMPORARY.csv", header = T) 
  #rename(FULL_CU_IN = ï..FULL_CU_IN) #fix weird special char in colname

# join metadata files to cu_decoder
cu_metadata <- left_join(cu_decoder, cu_dq, by="cuid") %>%
  left_join(., cu_enh, by = "cuid") %>%
  left_join(., cu_sites, by = "FULL_CU_IN") %>%
  select(cuid, cuname.x, cu_acronym, du_number, du_acronym, DU_name, DU_name_short, FULL_CU_IN, spp,
         gen_length, COSEWIC_status, survey_quality, survey_coverage, survey_execution,
         catch_quality, dq_score, cu_enh_rank, Sites,RegionAbbr) %>%
  rename(Region = RegionAbbr)

write.csv(cu_metadata, "Output/CU_Metadata_20241114.csv", row.names=FALSE)


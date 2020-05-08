## This script imports data and performs minimal data cleaning ##

## Import Datasets downloaded from 
## https://knb.ecoinformatics.org/view/doi:10.5063/F11V5C9V
## These are located in the project directory under 'Data/'

SampDat <- read.csv(file = './Data/SampleData.csv')
AbundDat <- read.csv('./Data/InsectAbundanceBiomassData.csv')
plotDat <- read.csv(file = './Data/PlotData.csv')
DataSources <- read.csv(file = './Data/DataSources.csv')

## RDS file to investigate later. Pulled from links in supplement ##
# s1 <- readRDS(file = "aax9931-vanKlink-SM-Data-S1.rds") 
# freshWat <- filter(s1, Realm == "Freshwater")
# rm(s1)

### Extract information from DataSource ###
### This code creates a DF holding most of the information in
### vanLink_freshwater_bugs on GoogleDrive shared folder
# ref_info <- right_join(SampDat, freshWat, c("DataSource_ID" = "Datasource_ID")) %>%
#     distinct(DataSource_ID, SampleArea, NumberOfReplicates, SamplingMethod, GroupInData, OriginalMetric, Datasource_name, Continent, file = "ReferenceInfo.csv")

### Create DF - 'all' which joins AbundanceData.csv to PlotData.csv
### by 'Plot_ID', then pipes that results into another join
### by "DataSource_ID", then filter out just freshwater studies

Freshwater_all <- right_join(AbundDat, plotDat, by = 'Plot_ID') %>%
  right_join(DataSources, by = c("DataSource_ID.x" = "DataSource_ID")) %>%
  filter(Realm == "Freshwater") %>% select(-DataSource_ID.y) %>% rename(DataSource_ID = "DataSource_ID.x")

### Need to update this to pull the google sheets ### Have to work out Oauth problems

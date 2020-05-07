rm(list = ls())
require(dplyr)
require(ggplot2)

## Import Datasets downloaded from 
## https://knb.ecoinformatics.org/view/doi:10.5063/F11V5C9V
## These are located in the project directory under 'Data/'

SampDat <- read.csv(file = 'Data/SampleData.csv')
AbundDat <- read.csv('Data/InsectAbundanceBiomassData.csv')
plotDat <- read.csv(file = 'Data/PlotData.csv')
DataSources <- read.csv(file = 'Data/DataSources.csv')

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

all <- right_join(AbundDat, plotDat, by = 'Plot_ID') %>%
  right_join(DataSources, by = c("DataSource_ID.x" = "DataSource_ID")) %>%
  filter(Realm == "Freshwater")

## Open plotting device. After plot has rendered expand window to 
## fullscreen before exporting for best visual.

### Dataset is split into two for cleaner visualization ##
windows(width = 12, height =12)
ggplot(data = all[1:4929,], aes(x = Year, y = Number, col = InvertebrateGroup)) +
  geom_point() +
  facet_wrap(~Reference, scales = "free") +
  geom_smooth(method = "lm", col = "black")


windows(width = 12, height = 12)
ggplot(data = all[4930:21340,], aes(x = Year, y = Number, col = InvertebrateGroup)) +
  geom_point() +
  facet_wrap(~Reference, scales = "free") +
  geom_smooth(method = "lm", col = "black")

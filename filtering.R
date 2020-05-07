rm(list = ls())
require(dplyr)
require(ggplot2)
SampDat <- read.csv(file = 'SampleData.csv')
AbundDat <- read.csv('InsectAbundanceBiomassData.csv')
plotDat <- read.csv(file = 'PlotData.csv')
DataSources <- read.csv(file = 'DataSources.csv')

s1 <- readRDS(file = "aax9931-vanKlink-SM-Data-S1.rds") 
freshWat <- filter(s1, Realm == "Freshwater")
rm(s1)


ref_info <- right_join(SampDat, freshWat, c("DataSource_ID" = "Datasource_ID")) %>%
    distinct(DataSource_ID, SampleArea, NumberOfReplicates, SamplingMethod, GroupInData, OriginalMetric, Datasource_name, Continent, file = "ReferenceInfo.csv")


#write.csv(ref_info, file = "Ref_Info.csv")
#select(DataSource_ID, SampleArea, NumberOfReplicates, SamplingMethod, GroupInData, OriginalMetric, Datasource_name, Continent) 

all <- right_join(AbundDat, plotDat, by = 'Plot_ID') %>%
  right_join(DataSources, by = c("DataSource_ID.x" = "DataSource_ID")) %>%
  filter(Realm == "Freshwater")

pdf(file = "Freswater1.pdf", width=10/2.54, height=6/2.54)

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

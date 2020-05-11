rm(list = ls())
source("./scripts/install-packages.R")
source("./scripts/datascript.R")
theme_set(theme_mod)

#Freshwater_all contains the full freshwater subsets

#create a group split on individual datasets 
freshwater_lists <- Freshwater_all %>%
  #I don't think this is the correct way to 
  named_group_split(DataSource_ID, InvertebrateGroup)


#### +++++++++++++++++++++++++++++++++++++++++++++ ####
##        DEBUG CODE FOR TESTING         ##
##       PLEASE CHECK                    ##
debugonce(trend_detect)
freshwater_out <- lapply(freshwater_lists, trend_detect, cols_keep = c("DataSource_ID","MetricAB"))

#### ++++++++++++++ END DEBUG ++++++++++++++++++++ ####

# apply trend detect function the list and bind together to data.frame
freshwater_out <- lapply(freshwater_lists, trend_detect, 
                         cols_keep = c("DataSource_ID","MetricAB"), alpha = 0.1) %>%
  bind_rows

#write csv of all the 
write.csv(freshwater_out, file = "./output/trend_detect.csv", row.names = FALSE)


# First attempt at figure

ggplot(freshwater_out, aes(trend)) + geom_bar() + scale_y_continuous(limits = c(0,50),expand = c(0,0))

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

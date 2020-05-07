rm(list = ls())
source("./scripts/install-packages.R")
source("./scripts/datascript.R")

#Freshwater_all contains the full freshwater subsets







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

rm(list = ls())
source("./scripts/install-packages.R")
source("./scripts/datascript.R")
theme_set(theme_mod)

#Freshwater_all contains the full freshwater subsets

#create a group split on individual datasets 
freshwater_lists <- Freshwater_all %>%
  #I don't think this is the correct way to subset, but I can't figure out how else to do it.
  named_group_split(DataSource_ID, Plot_ID)

#### +++++++++++++++++++++++++++++++++++++++++++++ ####
##        DEBUG CODE FOR TESTING         ##
##       PLEASE CHECK                    ##
debug(trend_detect)
freshwater_out <- lapply(freshwater_lists, trend_detect, cols_keep = c("DataSource_ID","MetricAB"))

#### ++++++++++++++ END DEBUG ++++++++++++++++++++ ####

# apply trend detect function the list and bind together to data.frame
freshwater_out <- lapply(freshwater_lists, trend_detect, 
                         cols_keep = c("DataSource_ID","MetricAB"), alpha = 0.1) %>%
  bind_rows

# Bind with vanKlink sheet

df <- vanklink_sheet %>%
  left_join(freshwater_out) %>%
  select(DataSource_ID, category:N) %>%
  mutate(category = as.character(category)) %>%
  filter(!grepl("could not access", category, ignore.case = TRUE),
         !grepl("Swedish", category, ignore.case = TRUE))


#write csv of all the 
write.csv(freshwater_out, file = "./output/trend_detect.csv", row.names = FALSE)

# First attempt at figure
df_summ <- df %>% na.omit %>% group_by(category) %>%
  summarise(pos_count = sum(coef > 0),
            neg_count = -sum(coef < 0),
            pos_perc = round(sum(coef > 0)/length(trend)*100,1),
            neg_perc = round(sum(coef < 0)/length(trend)*100,1)) %>%
  pivot_longer(pos_count:neg_perc,names_to = "trend_ct", values_to = "ct")
  

trens_plot <-   
ggplot(df_summ, aes(x= category)) + geom_bar(data = subset(df_summ,trend_ct == "pos_count"), aes(y = ct), stat = "identity", fill = "#f1a340") +
  geom_bar(data = subset(df_summ, trend_ct == "neg_count"), aes(y = ct), stat = "identity", fill = "#998ec3") +
  geom_hline(yintercept = 0, size = 1.2) +
  geom_text(data = subset(df_summ, trend_ct == "pos_count"), aes(x = category, y = 2, label = ct), vjust = 0 ) +
  geom_text(data = subset(df_summ, trend_ct == "neg_count"), aes(x = category, y = -2, label = -ct), vjust = 1 ) +
  theme(axis.title.y= element_blank(), axis.text.y = element_blank())



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

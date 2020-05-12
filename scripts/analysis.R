rm(list = ls())
source("./scripts/install-packages.R")
source("./scripts/datascript.R")
theme_set(theme_mod)

#Freshwater_all contains the full freshwater subsets

#create a group split on individual datasets 
freshwater_lists <- Freshwater_all %>% #filter(ProtectedArea == "no") %>%
  filter(MetricAB == "abundance") %>%
  #I don't think this is the correct way to subset, but I can't figure out how else to do it.
  named_group_split(DataSource_ID, Plot_ID) 

# apply trend detect function the list and bind together to data.frame
freshwater_out <- lapply(freshwater_lists, trend_detect, 
                         cols_keep = c("DataSource_ID","Plot_ID"), alpha = 0.1) %>%
  bind_rows

# Bind with vanKlink sheet
df <- vanklink_sheet %>%
  left_join(freshwater_out) %>%
  select(DataSource_ID,reference:N) %>%
  mutate(category = as.character(category),
         reference = as.character(reference)) %>%
  rename(title_journal_etc = "title_journal_ect") %>%
  select(DataSource_ID, Plot_ID, reference, author, title_journal_etc, category, trend, coef, coef_se, N) %>%
  filter(!grepl("could not access", category, ignore.case = TRUE),
         !grepl("Swedish", category, ignore.case = TRUE)) %>% data.frame


#write csv of all the 
write.csv(df, file = "./output/trend_detect.csv", row.names = FALSE)

# this should write a sheet to google drive.
# However, my authorization is fucked and rcurl won't let me do this.
# I think this is my DNS doing something weird and throttling our house...but I am not sure.
# trend_sheet <- googlesheets4::sheet_write(df)
#


# First attempt at figure
df_summ <- df %>% na.omit %>% 
  filter(category %in% c("1","2","4")) %>%
           group_by(category) %>%
  summarise(pos_count = sum(coef > 0),
            neg_count = -sum(coef < 0),
            pos_perc = round(sum(coef > 0)/length(trend)*100,1),
            neg_perc = round(sum(coef < 0)/length(trend)*100,1)) %>%
  pivot_longer(pos_count:neg_perc,names_to = "trend_ct", values_to = "ct") %>%
  mutate(category_label = case_when(category == "1" ~ "Restoration",
                                    category == "2" ~ "Natural trend",
                                    category == "4" ~ "Impairment"))
  

trends_plot <-
ggplot(df_summ, aes(x= category_label)) + 
  geom_bar(data = subset(df_summ,trend_ct == "pos_count"), aes(y = ct), stat = "identity", fill = "#f1a340") +
  geom_bar(data = subset(df_summ, trend_ct == "neg_count"), aes(y = ct), stat = "identity", fill = "#998ec3") +
  geom_hline(yintercept = 0, size = 1.2) +
  geom_text(data = subset(df_summ, trend_ct == "pos_count"), aes(x = category_label, y = 2, label = ct), vjust = 0 ) +
  geom_text(data = subset(df_summ, trend_ct == "neg_count"), aes(x = category_label, y = -2, label = -ct), vjust = 1 ) +
  theme(axis.title= element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank())


png(filename = "./output/trend_figure.png", res = 400, height= 5, width = 5, units = "in")
trends_plot
dev.off()


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

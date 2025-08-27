# install library
library(dplyr)
library(tidyverse)
library(readr)
library(ggplot2)
library(lubridate)

# import csv
events <- read_csv("events.csv")

# prepare data
events$timestamp <- as.POSIXct(events$timestamp/1000)
events$date <- as.Date(events$timestamp)
events$time <- format(events$timestamp, "%H:%M:%S")
events$week_day <- wday(events$date, label = TRUE)

# filter
events_cleaned <- events %>%
  select(date, time, week_day, event) %>%
  filter(date >= "2015-07-01" & date <= "2015-07-31")

# save csv
write_csv(events_cleaned, "events_cleaned.csv")

# import csv
events_cleaned <- read_csv("events_cleaned.csv")

# transform data
events_cleaned$week_day <- wday(events_cleaned$date, label = TRUE)
events_cleaned$hour <- hour(events_cleaned$time)

# event by day
# create df
events_by_day <- events_cleaned %>%
  group_by(week_day, event) %>%
  summarise(total_events = n())

# save data
write_csv(events_by_day, "event_by_day.csv")

# create chart
events_by_day_chart <- ggplot(events_by_day,
       aes(x = week_day,
           y = total_events,
           fill = event)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Events by Day",
       x = "Day of Week",
       y = "Total Events") +
  theme_minimal() +
  scale_fill_manual(values = c('lightblue',
                               'gold',
                               'salmon'))

# event by hour
# create df
events_by_hour <- events_cleaned %>%
  group_by(hour, event) %>%
  summarize(total_events = n())

# save
write_csv(events_by_hour, "event_by_hour.csv")

# create chart
events_by_hour_chart <- ggplot(events_by_hour,
       aes(x = hour,
           y = total_events,
           fill = event)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Events by Hour of Day",
       x = "Hour of Day",
       y = "Total Events") +
  theme_minimal() +
  scale_fill_manual(values = c('lightblue',
                               'gold',
                               'salmon'))


# conversion by day
cvr_by_day <- events_cleaned %>%
  filter(event == "view" | event == "transaction") %>%
  group_by(week_day) %>%
  summarize(total_view = sum(event == "view"),
            total_transaction = sum(event == "transaction")) %>%
  mutate(conversion_rate = (total_transaction / total_view)*100) %>%
  arrange(desc(conversion_rate))

# save
write_csv(cvr_by_day, "cvr_by_day.csv")

# create chart
cvr_by_day_chart <- ggplot(cvr_by_day,
       aes(x = week_day,
           y = conversion_rate,
           fill = conversion_rate)) +
  geom_bar(stat = "identity") +
  labs(title = "Conversion Rate by Day of Week",
       x = "Day of Week",
       y = "Conversion Rate") +
  theme_minimal() +
  scale_fill_gradient(low = "pink", high = "red")+
  theme(plot.title = element_text(face = "bold"))

# conversion by hour
cvr_by_hour <- events_cleaned %>%
  filter(event == "view" | event == "transaction") %>%
  group_by(hour) %>%
  summarize(total_view = sum(event == "view"),
            total_transaction = sum(event == "transaction")) %>%
  mutate(conversion_rate = (total_transaction / total_view)*100) %>%
  arrange(desc(conversion_rate))

# save
write_csv(cvr_by_hour, "cvr_by_hour.csv")

# create chart
cvr_by_hour_chart <- ggplot(cvr_by_hour,
       aes(x = hour,
           y = conversion_rate,
           fill = conversion_rate)) +
  geom_bar(stat = "identity") +
  labs(title = "Conversion Rate by Hour of Day",
       x = "Day of Week",
       y = "Conversion Rate") +
  theme_minimal() +
  scale_fill_gradient(low = "pink", high = "red")+
  theme(plot.title = element_text(face = "bold"))


# funnel
cal_funnel <- events_cleaned %>%
  summarize(total_view = sum(event == "view"),
            total_addtocart = sum(event == "addtocart"),
            total_transaction = sum(event == "transaction")) %>%
  mutate(aware_to_consi = (total_addtocart/total_view)*100,
         consi_to_conv = (total_transaction/total_addtocart)*100)

# cvr by day and hour
cvr_by_day_time <- events_cleaned %>%
  select(week_day, hour, event) %>%
  filter(event %in% c("view", "transaction")) %>%
  group_by(week_day, hour) %>%
  summarize(totl_view = sum(event == "view"),
            totl_transaction = sum(event == "transaction")) %>%
  mutate(conv_rate = (totl_transaction/totl_view)*100) %>%
  arrange(desc(conv_rate))

# save
write_csv(cvr_by_day_time, "cvr_by_day_time.csv")

# create chart
ggplot(cvr_by_day_time, 
       aes(x = hour,
           y = conv_rate, 
           color = week_day)) +
  geom_line() +
  geom_point() +
  labs(title = "Conversion Rate by Hour and Day of Week",
       x = "Hour of Day",
       y = "Conversion Rate (%)",
       color = "Day of Week") +
  theme_minimal()

# find lowest cvr (exclude 0)
min_cvr <- cvr_by_day_time %>%
  filter(conv_rate > 0) %>%
  summarize(min_con = min(conv_rate, na.rm = TRUE)) %>%
  pull(min_con) %>%
  head(1)

# cpc base
baseline_cpc <- 0.50

# bid cost
cost_bid <- cvr_by_day_time %>%
  mutate(cost_bid = (conv_rate/min_cvr) * baseline_cpc)

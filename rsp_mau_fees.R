library(tidyverse)
library(lubridate)
library(glue)

# Run the appropriate .Rmd file to create a summary csv'
if (! exists('rsp_mau_csv')) rsp_mau_csv <- 'rsp_active_users.csv'  # or 'rsp_active_user_hours.csv'
if (! exists('rsp_mau_fee')) rsp_mau_fee <- 1

stopifnot (file.exists(rsp_mau_csv)) 
user_stats <- readr::read_csv(rsp_mau_csv)

monthly_fees_long <- user_stats %>% 
  gather(month, nhours, starts_with('20')) %>% 
  group_by(username, product, month) %>% 
  summarise(fee = rsp_mau_fee * (nhours > 0)) 

monthly_fees <- monthly_fees_long %>% 
  spread(month, fee, fill = 0) 

total_fees <- sum(monthly_fees_long$fee)

glue ('Total fees for {min(user_stats$ts_first)} thru {max(user_stats$ts_last)} are ${round(total_fees)}') %>% 
  print()

csv_fee <- 'rsp_mau_fees.csv'
write_csv(monthly_fees, csv_fee )

glue('Data written to {csv_fee}') %>% 
  print()

library(tidyverse)
library(lubridate)
library(scales)

rsp_log_dir <- 'audit/r-sessions'
#rsp_log_dir <- '~/Downloads/r-sessions'; rpt_start_date <- ymd('2020-06-01')
rpt_start_date <- ymd('2020-01-01')
rpt_end_date <- rpt_start_date + months(3) - days(1)
cust_name <- str_split(rsp_log_dir, '/') %>% unlist() %>% rev() %>% head(1)
#username_map <- file.path(rsp_log_dir, 'usernames.Rdata')
rsp_fee <- 125

if(exists('username_map')) {
  if(file.exists(username_map)) {
    user_hash <- readRDS(username_map)
  } else {
    user_hash <- tibble::tribble(~username, ~id)
  }
}


read_log <- function(x) {
  readr::read_csv(x) %>% 
    mutate(logfile = x) %>% 
    mutate(time = as_datetime(timestamp/1e3),
           month = paste(year(time), month(time))) %>% 
    filter(time >= rpt_start_date,
           time <= rpt_end_date) %>% 
    filter(type == "session_start")
}

log_files <- list.files(rsp_log_dir, "*\\.csv", full.names = TRUE)
logs <- map_df(log_files, read_log) 

monthly_stats <- logs %>% 
  group_by(username, month) %>% 
  summarise(session_starts = n(), .groups = 'drop_last') %>% 
  spread(month, session_starts, fill = 0) %>% 
  rowwise() %>% 
  mutate(mau = sum(c_across(starts_with('2020')) > 0))

user_stats <- logs %>% 
  group_by(logfile, username) %>% 
  summarise(n_sessions = n(),
            ts_first = min(time),
            ts_last = max(time)) %>% 
  group_by(username) %>% 
  summarise(end_customer = cust_name,
            product = 'RSP',
            n_sessions = first(n_sessions),
            ts_first = min(ts_first),
            ts_last = max(ts_last)) %>% 
  left_join(monthly_stats, by = 'username')

if(exists('username_map')) {
  new_names <- setdiff(user_stats$username, user_hash$username) %>% sort()
  if (length(new_names) > 0) {
    start_id <- nrow(user_hash)
    user_hash <- user_hash %>% 
      bind_rows(tibble::tibble(username = new_names, 
                                 id = paste0('user', start_id + (1:length(new_names)))))
  }
  user_stats <- user_stats %>% 
    left_join(user_hash, by = 'username') %>% 
    mutate(username = id) %>% 
    select(-id)
  saveRDS(user_hash, file = username_map)
}
message(sprintf('RSP fees due: %d MAU @ $%d = %s', 
                 sum(user_stats$mau), rsp_fee, dollar_format()(sum(user_stats$mau) * rsp_fee)))

csv_mau <- 'rsp_mau_report.csv'
write_csv(user_stats, csv_mau )

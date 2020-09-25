library(tidyverse)
library(lubridate)

log_path = './audit/r-sessions'

named_users <- map_df(list.files(path = log_path, pattern = "\\.csv", full.names = TRUE), readr::read_csv) %>%
    mutate(time = as_datetime(timestamp/1e3),
           month = sprintf('%d-%2.2d', year(time), month(time))) %>%
    filter(type == "session_start") %>% 
    count(month, username)

#find the 6 month mark from today
mark6 <- format(today() - months(6), '%Y-%m')

active_6mo <- named_users %>% filter(month >= mark6) %>% pull(username) %>% unique() %>% length()

min_month <- min(named_users$month) %>% str_split('-') %>% unlist()
max_month <- max(named_users$month) %>% str_split('-') %>% unlist()


no_gaps <- tibble::tibble(yr = rep(min_month[1]:max_month[1], each = 12)) %>% 
    mutate(mo = rep(1:12, nrow(.) / 12),
           month = sprintf('%d-%2.2d', yr, mo, sep='-'),
           username = 'no gaps',
           n = 0) %>% 
    filter(month >= min(named_users$month),
           month <= max(named_users$month)) %>% 
    select(month, username, n)

mau_all <- named_users %>% 
    bind_rows(no_gaps) %>% 
    group_by(month) %>%
    summarise(mau = n() - 1)
    
au_counts <- sprintf('%d (6mo), %s, %s, %s', 
                     active_6mo, 
                     min(named_users$month),
                     max(named_users$month),
                     paste(mau_all$mau, collapse = ', '))

# rstelemetry
tools for extracting telemetry metrics from RStudio pro products

*This is very much a work in (slow) progress*

1. Copy log files to directory with read access. 
2. Run the  .Rmd file below that corresponds with the log file type
3. Run the rsp_mau_fees.R after setting appropriate vars.

| Filename | Description | Inputs | Outputs 
|--------|---------|--------|---------|
| rsp_mau_sessions.Rmd | reads log files from r-sessions=1 | rsp_log_dir <- 'audit/r-sessions' | rsp_mau_sessions.csv |
| rsp_mau_console.Rmd | reads log files from r-console=input | rsp_log_dir <- 'audit/r-console' | rsp_active_user_hours.csv |
| rsp_mau_fees.R | reads one of the above .csv outputs | rsp_mau_csv, fsp_mau_fee | rsp_mau_fees.csv |




default location of audit logs is _/var/lib/rstudio-server/audit/_ (may require admin access)
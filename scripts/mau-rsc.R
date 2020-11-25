#! /usr/local/bin/Rscript

library(httr)

connect_url <- "<CONNECT-URL>"
connect_api_key <- "<CONNECT-API-KEY>"
csv_path <- gsub(" ", "-", paste0("./rsc-user-counts-", Sys.time(), ".csv"))

# Print Debug utility
print_debug <- function(msg) {
  if(debug) cat(msg, "\n")
}

# RSC API Request
get_audit <- function(url) {
  print_debug(paste0("Fetching audit logs from ", url))
  resp <- GET(
    url,
    add_headers(Authorization = paste("Key", connect_api_key))
  )
  print_debug(paste0("Request status: ", resp$status_code))
  payload <- content(resp, encoding = "UTF-8")
  payload$results <- Reduce(rbind, lapply(payload$results, as.data.frame))
  payload
}

if (!interactive()) {
   library(argparser, quietly = TRUE)
  p <- arg_parser("Monthly Active RStudio Connect User Counts")
  p <- add_argument(parser = p, 
                    arg = "--connect-url", 
                    help = "URL for RStudio Connect",
                    type = "character",
                    default = connect_url)
  p <- add_argument(parser = p,
                    arg = "--api-key",
                    help = "RStudio Connect API key for an admin user",
                    type = "character",
                    default = connect_api_key)
  p <- add_argument(parser = p,
                    arg = "--output",
                    help = paste0("Path to write .csv file of user counts"),
                    type = "character",
                    default = csv_path)
  p <- add_argument(parser = p,
                    arg = "--debug",
                    help = "Enable debug output",
                    flag = TRUE)
  
  argv <- parse_args(p)
  
  connect_url <- argv$connect_url
  connect_api_key <- argv$api_key
  csv_path <- argv$output
}

# Request logs from RStudio Connect API
audit_log_url <- paste0(connect_url, "/__api__/v1/audit_logs?ascOrder=false&limit=500")
payload <- get_audit(audit_log_url)
audit_log <- payload$results

while(!is.null(payload$paging[["next"]])) {
  payload <- get_audit(payload$paging[["next"]])
  audit_log <- rbind(audit_log, payload$results)
}

print_debug("Audit Log successfully retrieved")
audit_log

# Parse logs


z

# Unique user / month combinations

# 
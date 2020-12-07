#! /usr/local/bin/Rscript

# Set log file path
log_path <- "/var/lib/rstudio-server/audit/r-sessions/r-sessions.csv"

# Set minimum date - default is 1 year ago
min_date <- as.POSIXct(Sys.Date() - 365)

# Set CSV path for MAU data write
csv_path <- gsub(" ", "-", paste0("./rsp-user-counts-", Sys.time(), ".csv"))

# Set debug value
debug <- FALSE

# Print Debug utility
print_debug <- function(msg) {
  if(debug) cat(msg, "\n")
}

print_dims <- function(dat) {
  dims <- dim(dat)
  print_debug(paste0("Data dimensions: ", paste0(dims[1], " x ", dims[2])))
}

# Parse arguments if run as CLI
if (!interactive()) {
  library(argparser, quietly = TRUE)
  p <- arg_parser("Monthly Active RStudio Server Pro User Counts")
  p <- add_argument(parser = p, 
                    arg = "--log-path", 
                    help = "Path to RStudio Session logs",
                    type = "character",
                    default = log_path)
  p <- add_argument(parser = p,
                    arg = "--min-date",
                    help = "Minimum date to compute monthly counts",
                    type = "character",
                    default = as.character(min_date))
  p <- add_argument(parser = p,
                    arg = "--output",
                    help = "Path to write .csv file of user counts",
                    type = "character",
                    default = csv_path)
  p <- add_argument(parser = p,
                    arg = "--debug",
                    help = "Enable debug output",
                    flag = TRUE)
  
  argv <- parse_args(p)
  
  log_path <- argv$log_path
  min_date <- as.POSIXct(argv$min_date)
  csv_path <- argv$output
  debug <- argv$debug
}


# Read log data
print_debug(paste0("Reading data: ", log_path))
log_data <- read.csv(log_path, stringsAsFactors = FALSE)
print_dims(log_data)

# Convert timestamp from numeric
print_debug("Converting timestamp")
log_data$timestamp <- as.POSIXct(log_data$timestamp / 1000, origin = "1970-01-01")
print_dims(log_data)

# Filter to events >= min_date
print_debug(paste0("Filtering to events >= ", min_date))
log_data <- log_data[log_data$timestamp >= min_date,]
print_dims(log_data)

# Extract month and year
print_debug("Extracting month from timestamp")
log_data$month <- format(log_data$timestamp, format = "%m-%Y")

# Filter only to "session_start" events
print_debug("Filtering to session_start events")
log_data <- log_data[grepl("session_start", log_data$type),]
print_dims(log_data)

# Select only timestamp, month, and username
print_debug("Selecting only timestamp, month, and username")
log_data <- log_data[,c("timestamp", "month", "username")]
print_dims(log_data)

# Count sessions per user per month
print_debug("Counting sessions per user per month")
user_session_counts <- as.data.frame(table(log_data$username, log_data$month))
names(user_session_counts) <- c("user", "month", "sessions")
user_session_counts$active <- user_session_counts$sessions > 0
user_session_counts$product <- "RStudio Server Pro"

# Summarize by unique username and month combinations
print_debug("Summarizing by unique username and month combinations")
monthly_users <- unique(log_data[,c("username", "month")])
print_dims(monthly_users)

# Calculate observations per month, which is equivalent to the number of active 
# users per month
print_debug("Calculating user counts by month")
user_counts <- as.data.frame(table(monthly_users$month))
names(user_counts) <- c("Month", "Active User Count")
print_dims(user_counts)

# Write CSV
print_debug(paste0("Writing user counts data to ", csv_path))
write.csv(user_session_counts, csv_path)

# Print final user counts
user_counts

#! /usr/local/bin/Rscript

# Set log file path
log_path <- "/var/lib/rstudio-server/audit/r-sessions/r-sessions.csv"

# Set minimum date - default is 1 year ago
min_date <- as.POSIXct(Sys.Date() - 365)

# Set debug value
debug <- FALSE

# Print Debug utility
print_debug <- function(msg) {
  if(debug) print(msg)
}

# Parse arguments if run as CLI
if (!interactive()) {
  library(argparser, quietly = TRUE)
  p <- arg_parser("Monthly Active RStudio User Counts")
  p <- add_argument(parser = p, 
                    arg = "--log-path", 
                    help = paste0("Path to RStudio Session logs. Default: ", log_path),
                    type = "character",
                    default = log_path)
  p <- add_argument(parser = p,
                    arg = "--min-date",
                    help = paste0("Minimum date to compute monthly counts. Default: ", min_date),
                    type = "character",
                    default = as.character(min_date))
  p <- add_argument(parser = p,
                    arg = "--debug",
                    help = "Enable debug output",
                    flag = TRUE)
  
  argv <- parse_args(p)
  
  log_path <- argv$log_path
  min_date <- as.POSIXct(argv$min_date)
  debug <- argv$debug
}


# Read log data
print_debug(paste0("Reading data: ", log_path))
log_data <- read.csv(log_path, stringsAsFactors = FALSE)
print_debug(paste0("Data dimensions: ", dim(log_data)))

# Convert timestamp from numeric
print_debug("Converting timestamp")
log_data$timestamp <- as.POSIXct(log_data$timestamp / 1000, origin = "1970-01-01")
print_debug(paste0("Data dimensions: ", dim(log_data)))

# Filter to events >= min_date

log_data <- log_data[log_data$timestamp >= min_date,]

# Extract month and year
log_data$month <- format(log_data$timestamp, format = "%m-%Y")

# Filter only to "session_start" events
log_data <- log_data[grepl("session_start", log_data$type),]

# Summarize by unique username and month combinations
log_data <- unique(log_data[,c("username", "month")])

# Calculate observations per month, which is equivalent to the number of active 
# users per month
user_counts <- as.data.frame(table(log_data$month))
names(user_counts) <- c("Month", "Active User Count")

# Print final user counts
user_counts

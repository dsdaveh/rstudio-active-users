#! /usr/local/bin/Rscript

library(httr)

# Set CSV path for MAU data write
csv_path <- gsub(" ", "-", paste0("./rsc-user-counts-", Sys.time(), ".csv"))

# Set minimum date - default is 1 year ago
min_date <- as.POSIXct(Sys.Date() - 365)

# Set debug value
debug <- FALSE

# Print Debug utility
print_debug <- function(msg) {
  if(debug) cat(msg, "\n")
}


if (!interactive()) {
   library(argparser, quietly = TRUE)
  p <- arg_parser("Monthly Active RStudio Connect User Counts")
  p <- add_argument(parser = p,
                    arg = "--output",
                    help = paste0("Path to write .csv file of user counts"),
                    type = "character",
                    default = csv_path)
  p <- add_argument(parser = p,
                    arg = "--min-date",
                    help = "Minimum date to compute monthly counts",
                    type = "character",
                    default = as.character(min_date))
  p <- add_argument(parser = p,
                    arg = "--debug",
                    help = "Enable debug output",
                    flag = TRUE)
  
  argv <- parse_args(p)
  
  min_date <- as.POSIXct(argv$min_date)
  csv_path <- argv$output
}

# Generate audit logs using the usermanager CLI and read them into R
print_debug("Generating RStudio Connect audit log. Please note that RStudio 
            Connect needs to be stopped in order to generate the audit log")
audit_log <- read.csv(text = system2("/opt/rstudio-connect/bin/usermanager", c("audit", "--csv"), stdout = TRUE, stderr = FALSE),
         stringsAsFactors = FALSE)

# Filter logs
audit_log <- audit_log[audit_log$Action == "user_login", c("UserID", "UserDescription", "Time", "Action")]

# Create month column
audit_log$Time <- as.POSIXct(audit_log$Time)
audit_log$Month <- format(audit_log$Time, format = "%m-%Y")

# Count user and month
user_session_counts <- as.data.frame(table(audit_log$UserDescription, audit_log$Month))
names(user_session_counts) <- c("user", "month", "sessions")

# Unique user / month combinations
monthly_users <- unique(audit_log_data[,c("UserDescription", "Month")])

# Calculate observations per month, which is equivalent to the number of active 
# users per month
user_counts <- as.data.frame(table(monthly_users$Month))
names(user_counts) <- c("Month", "Active User Count")

# Write CSV
write.csv(user_session_counts, csv_path)

# Print final user counts
user_counts
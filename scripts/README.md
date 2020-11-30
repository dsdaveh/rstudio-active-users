# Monthly Active User Counts

The two scripts here will generate counts of monthly active users for RStudio
Server Pro and RStudio Connect.

### Dependencies
#### System
Each script assumes that R and Rscript are installed and available at
`/usr/local/bin/`. If that's not the case, you need to manually specify the path
to `Rscript` before running the script:
```
/path/to/Rscript ./mau-rsp.R
```

If Rscript is available in `/usr/local/bin/`, then you can simply execute the
file:
```
./mau-rsp.R
```

#### R Packages
One primary focus of these scripts is to introduce minimal R dependencies. Each
script can be run interactively without any dependencies, or, if run as a CLI,
there is only a single dependency:
[argparser](https://cran.r-project.org/web/packages/argparser/index.html). This
package itself introduces no additional external dependencies.

In order to install this package and make it available when running the scripts,
execute the following:
```
sudo /path/to/R -e "install.packages('argparser')"
```

### Usage
Each script can either be run as a CLI or run in an interactive R session. If
run as a CLI, the `-h` flag can be used to view help for the various arguments:
```bash
./mau-rsc.R -h
usage: mau-rsc.R [--] [--help] [--debug] [--opts OPTS] [--output
       OUTPUT] [--min-date MIN-DATE]

Monthly Active RStudio Connect User Counts

flags:
  -h, --help      show this help message and exit
  -d, --debug     Enable debug output

optional arguments:
  -x, --opts      RDS file containing argument values
  -o, --output    Path to write .csv file of user counts [default:
                  ./rsc-user-counts-2020-11-30-21:58:05.csv]
  -m, --min-date  Minimum date to compute monthly counts [default:
                  2019-12-01]
```

In order to run the script interactively, start an R session and run through
each line of the script, adjusting the variables as needed.

### Output
Each script will print a table of monthly user counts to `stdout`. It will also
write a csv file containing more specific information about individual user
sessions per month.
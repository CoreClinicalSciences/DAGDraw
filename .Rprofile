# Activate renv first
source("renv/activate.R")

# Then set binary installation for macOS
if (Sys.info()["sysname"] == "Darwin") {
   options(pkgType = "binary")  # Note: pkgType not pkg.type
   Sys.setenv(RENV_CONFIG_PKG_TYPE = "binary")
}

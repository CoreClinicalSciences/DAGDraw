# .Rprofile

# Activate renv first
source("renv/activate.R")

# Then set macOS-specific settings
if (Sys.info()["sysname"] == "Darwin") {
   local({
      # Ensure binaries are used
      options(pkgType = "binary")
      Sys.setenv(RENV_CONFIG_PKG_TYPE = "binary")
      
      # Force renv to use binaries
      assignInNamespace(
         "package_type",
         function(...) "binary",
         ns = "renv"
      )
   })
}

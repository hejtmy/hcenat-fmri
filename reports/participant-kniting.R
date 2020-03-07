rmarkdown::render("reports/participant.Rmd", params=list(code=code), output_dir = "reports/participants", output_file = code) 

codes <- c("HCE_E_10","HCE_E_12","HCE_E_13","HCE_E_14","HCE_E_15","HCE_E_16","HCE_E_17","HCE_E_18","HCE_E_19","HCE_E_2","HCE_E_20","HCE_E_21","HCE_E_22","HCE_E_24","HCE_E_3",
"HCE_E_8","HCE_E_9", "HCE_K_10","HCE_K_11","HCE_K_12","HCE_K_13","HCE_K_14","HCE_K_15","HCE_K_16","HCE_K_19","HCE_K_20","HCE_K_21","HCE_K_22","HCE_K_23","HCE_K_4",
"HCE_K_5","HCE_K_6","HCE_K_7","HCE_K_8","HCE_K_9")

# single participant
rmarkdown::render("reports/participant.Rmd", params=list(code="HCE_E_10", session=1), output_dir = "reports/participants", output_file = code)

# multiple participant
for(code in codes[2:length(codes)]){
  rmarkdown::render("reports/participant.Rmd", params=list(code=code, session=1), output_dir = "reports/participants", output_file = code)
}

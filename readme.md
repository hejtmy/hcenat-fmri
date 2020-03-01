# Analysis overview

Data are loaded for each participant and expected pulses are added. Then events of importance are found and their respective pulses extracted FMRI data are selected based on this selection table


## Data description
Unity data are loaded with 

Unity data can be of three different "classes"
`session` - list with a single session unity data loaded with `read_unity_data`
`participant` - list of length 2 with both sessions. Loaded with `load_participant`
`participants` - named list of all participant files


## Procedure
1. Run the `scripts/preprocess-participants` R script. This processes all the data and saves it into `participants-prepapred.RDa` file
2. Load the `participant-prepared.Rda`

## fMRI getting
to get fmri with the get_fmri function, you need to create a fmri selection table which consists of 

|participant_id|pulse_id|optional_columns|....|....|
|-------|-------|-------|-----|------|


## Matlab procedure
There are some requirements on the matlab code. 
    - SPM package needs to be loaded for the spm_hrf fuciton to work properly. 
    - the saving and loading of preprpocessed data happens from root/exports/hrf. Threfore you should run the matlab code from the root, not from the fMRI folder
    - exports/hrf folder needs to be present, the code does not create it on its own

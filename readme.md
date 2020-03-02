# Analysis overview

Data are loaded for each participant and pulses are added. WE then find the events of importanceand their respective pulses extracted. 

R loads the behavioural data and outputs events with information about fMRI time. Matlab code takes these events and models the hrf expected component timeseries. The final component timeseries can then be modeled as a function of the event hrfs to asses how much they correspond.

## Data description

Unity data can be of three different "classes"
`session` - list with a single session unity data loaded with `read_unity_data`.
`participant` - list of length 2 with both sessions loaded with `load_participant`.
`participants` - named list of all participant files loaded with `load_participants`.

## Procedure
1. Run the `scripts/preprocess-participants` R script. This processes all the data and saves it into `participants-prepapred.RDa` file
2. You can then run `scripts/pulses-output.R` which outputs the pulses events into the exports folder

## Matlab procedure
There are some requirements for the matlab code. 
    - SPM package needs to be loaded for the spm_hrf fuciton to work properly. 
    - the saving and loading of preprpocessed data happens from root/exports/hrf. Threfore you should run the matlab code from the root, not from the fMRI folder
    - exports/hrf folder needs to be present, the code does not create it on its own

In the `fmri/preprocess.m`, change the directory and required parameters (e.g. names of files). Running the `preprocess.m` then saves the prepares hrf timeseries in the exports/hrf.

## Analysis procedure
The analyses on the timeseries can be run in either matlab or r. After simulating and convolving the fmri hrf, there is no other reason to use matlab, as the matrices are not really that big. The procedure then is just a computing timeseries correlations.

The matlab analyses are in the `fmri/analysis` - that saves the final correlation matrices in the exports


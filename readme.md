# Analysis overview

Data are loaded for each participant. Then pulses are added and data resaved so they don't have to be loaded raw every time. We then find the events of importanceand their respective pulses extracted. 

R loads the behavioural data and outputs events with information about fMRI time. Matlab code takes these events and models the hrf expected component timeseries. The final component timeseries can then be modeled as a function of the event hrfs to asses how much they correspond.

## Project structure
folders written in *italics* are not commited, but generated as the scripts run

- data: contains all raw data from both fMRI 
- *exports*: contains preprocessed files as exported by R or matlab functions. Used in analysis
- fMRI: Matlab code to model the HRF responses on given events
- functions: R helper functions
- images: 
- *models*: saved mixed models, as running them takes too long
- reports: knitr and dash reports 
- scripts: data loading, preprocessing, exporting R scripts
- *summaries*: ouput of analytical scripts. Used in reports

## Data description

Unity data can be of three different "classes"
`session` - list with a single session unity data loaded with `read_unity_data`.
`participant` - list of length 2 with both sessions loaded with `load_participant`.
`participants` - named list of all participant files loaded with `load_participants`.

## Preprocessing procedure
1. Run the `scripts/preprocess-participants` R script. This processes all the data and saves it into `participants-prepapred.RDa` file
2. You can then run `scripts/pulses-output.R` which outputs the pulses events into the exports folder. These evens are then used by the matlab's hrf convolutions.
3. Run matlab hrf generation (see below)
4. 

## Matlab HRF modelling procedure
There are some requirements for the matlab code. 

    - SPM package needs to be loaded for the spm_hrf fuciton to work properly (`addpath '------\SDKs\spm12'`)
    - saving and loading of preprpocessed data happens from root/exports/hrf. Threfore you should run the matlab code from the root, not from the fMRI folder
    
1. Open the root folder in matlab and add all matlab code to path `addpath(genpath('.'))`
2. In the `fmri/preprocess.m`, change the directory and required parameters (e.g. names of files). If you are running this for the first time, create 'exports/hrf' folder in the root.
3. Run the `preprocess.m` - it models the hrf timeseries from the behavioural data and saves them into the 'exports/hrf'

## Correlation analysis procedure
The analyses on the timeseries can be run in either matlab or R. After simulating and convolving the fmri hrf, there is no other reason to use matlab, as the matrices are not really that big. The procedure then is just a computing timeseries correlations.

The matlab analyses are in the `fmri/analysis` - that saves the final correlation matrices in the exports
The R analyses used for exporting the online exploration tool are in `reports/hrf-correlations.Rmd`

## Main manuscript analysis
The main analysis for the manuscript uses linear mixed effects and GLM modelling of hrf convolved timeseries.

The 


## Scripts description
- check-things-work.R - short functions and scripts with some sanity checks about behavioral and fMRI data
- load-data.R - loads and restructures the preprocessed participant unity data and all other data (preprocessing table, behavioral, pulses, components etc.) necessary for manuscript-analyses and shifting scripts
- loading.R - helper to load all functions from the function folder
- manuscript-analyses.R - main manuscript analyses. Calculates and outputs mixed effect models and GLMs for all components and events and saves both raw models as well as obtained beta coefficients and contrasts.
- preprocess-participants.R - creates behavioral summaries
- pulses-output.R - analyses behavioral data, finds relevant events (pointing started, movement onset etc) and outputs these events as fmri pulses
- shifting-and-recalculating-analyses.R - similar to main manuscript analyses but with models computed on randomly shifted events to determine if the observed components have behaviorally relevant features


## Notes and FAQ

the pulse start and quest_time_start_fmri do not correspond well
- this is *probably* due to the uneven teleporting. The pulse starts the teleporting and the quest, but the pointing and other aspects of the quest only start after the teleport is finished, therefore later. the pulse in which the quest started therefore precedes the quest pointing by about 2 seconds.

Participatns almost NEVER stop, as the time is very tight. There is very little stillness in learning/trials, leading to situations where some participnats have almost no events whatsoever. Cannot be included int he model.
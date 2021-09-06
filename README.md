# Anomaly Reconstruction

This repository shows developed algorithm of Pattern-based Anomaly Reconstruction
The framework is coded using statistical package R as seen in folder "util" and it calculates anomaly matrix for each case and reconstructs the anomalies with predicting anomaly pattern. 

## Prepared Data1 - 5 artificial logs
We used 5 types of process models including small, medium, large, huge, and wide refered from [1] to generate artificial logs. 

## Prepared Data2 - 2 real-life logs
For the real life logs, we consider the Hospital Billing event log containing events about the billing of medical services that have been obtained from the financial modules of the ERP system of a regional hospital, and the Road Traffic event log which collects events about a road traffic fine management process at a local police authority in Italy.

For all logs, we injected 5 types of anomaly patterns including "insert", "skip", "moved", "replace", and "rework" introduced in [2]. The statistics of datasets are summarised in Table 1 in our paper.


## R-files
- util/vTree.R : function for training a reference model (directly followed graph)
- util/vForest.R : function for calculating anomaly matrix and reconstructing anomalies
- preprocesssing.R : data preprocessing before implementing anomaly reconstruction 
- implementation.R : Implementation of vTree and vForest (= Pattern-based Anomaly Reconstruction)



&#x1F53A; Be careful to correctly set your working directory for each R file as uploaded files contain my own local directory.


## References
[1] Nolle, T., Luettgen, S., Seeliger, A., & Mühlhäuser, M. (2019). Binet: Multi-perspective business process anomaly classification. Information Systems, 101458.

[2] Ko, J., Lee, J., & Comuzzi, M. (2020). AIR-BAGEL: An Interactive Root cause-Based Anomaly Generator for Event Logs. In ICPM Doctoral Consortium/Tools (pp. 35-38).


# Anomaly Reconstruction

This repository shows developed algorithm of Pattern-based Anomaly Reconstruction
The framework is coded using statistical package R as seen in folder "util" and it calculates anomaly matrix for each case and reconstructs the anomalies with predicting anomaly pattern. 

## Prepared Data1 - 5 artificial logs
We used 5 types of process models including small, medium, large, huge, and wide refered from [1] to generate artificial logs. 

## Prepared Data2 - 2 real-life logs
For the real life logs, we consider the Hospital Billing event log containing events about the billing of medical services that have been obtained from the financial modules of the ERP system of a regional hospital, and the Road Traffic event log which collects events about a road traffic fine management process at a local police authority in Italy.

For all logs, we injected 5 types of anomaly patterns including "insert", "skip", "moved", "replace", and "rework" introduced in [2]. Specifically, we have considered the resource behaviour root cause and set the probability of each resource to make a mistake when recording an event to follow an exponential distribution with $\lambda = 0.02$ for all 5 anomaly patterns. The tool also supports the generation of the resource attribute, before injecting anomalies, if this is missing in an event log. While the resource attribute is available in the two real logs, for the artificial logs, in which the resource attribute is missing, we generated it setting 5 departments and 3 resources per each department as parameters in the tool. Regarding the injected anomaly patterns parameters, $M$ for the $insert$ and $rework$ patterns is set to 3 events, $M$ for the $move$ to 5 events for all artificial logs, 10 events for \textit{Hospital Billing} event log, and 15 events for \textit{Road Traffic} event log. Note that, during the anomaly injection process, we store the clean version of the traces injected with anomalies in order to calculate the performance of the proposed trace reconstruction approach.
Finally, after the anomalies have been injected, the cases labelled as anomalous that are executed following a normal trace are removed. These anomalies, in fact, are virtually impossible to identify using only information about activity labels in events. 

The statistics of datasets are summarised in Table 1 presented below.


![image](https://user-images.githubusercontent.com/74713590/168014117-202ad9d9-8cb7-42b1-ae52-ed26a1bab2ad.png)


## The anomaly reconstruction process


## Result 1: Anomaly pattern classification accuracy

## Result 2: Anomalous trace reconstruction accuracy

## Result 3: Reconstruction accuracy for different anomaly patterns



## R-files
- util/vTree.R : function for training a reference model (directly followed graph)
- util/vForest.R : function for calculating anomaly matrix and reconstructing anomalies
- preprocesssing.R : data preprocessing before implementing anomaly reconstruction 
- implementation.R : Implementation of vTree and vForest (= Pattern-based Anomaly Reconstruction)



&#x1F53A; Be careful to correctly set your working directory for each R file as uploaded files contain my own local directory.


## References
[1] Nolle, T., Luettgen, S., Seeliger, A., & Mühlhäuser, M. (2019). Binet: Multi-perspective business process anomaly classification. Information Systems, 101458.

[2] Ko, J., Lee, J., & Comuzzi, M. (2020). AIR-BAGEL: An Interactive Root cause-Based Anomaly Generator for Event Logs. In ICPM Doctoral Consortium/Tools (pp. 35-38).


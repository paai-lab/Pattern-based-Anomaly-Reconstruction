# Anomaly Reconstruction

This repository shows developed algorithm of Pattern-based Anomaly Reconstruction (PBAR).
The framework is coded using statistical package R as seen in folder "util" and it calculates anomaly matrix for each case and reconstructs the anomalies with predicting anomaly pattern. 


## R-files
- util/vTree.R : function for training a reference model (directly followed graph)
- util/vForest.R : function for calculating anomaly matrix and reconstructing anomalies
- preprocesssing.R : data preprocessing before implementing anomaly reconstruction 
- implementation.R : Implementation of vTree and vForest (= Pattern-based Anomaly Reconstruction)

&#x1F53A; Be careful to correctly set your working directory for each R file as uploaded files contain my own local directory.


## Prepared Data1 - 5 artificial logs
We used 5 types of process models including small, medium, large, huge, and wide refered from [1] to generate artificial logs. 


## Prepared Data2 - 2 real-life logs
For the real life logs, we consider the Hospital Billing event log containing events about the billing of medical services that have been obtained from the financial modules of the ERP system of a regional hospital, and the Road Traffic event log which collects events about a road traffic fine management process at a local police authority in Italy.

For all logs, we injected 5 types of anomaly patterns including "insert", "skip", "moved", "replace", and "rework" introduced in [2]. Specifically, we have considered the resource behaviour root cause and set the probability of each resource to make a mistake when recording an event to follow an exponential distribution with <img src="https://render.githubusercontent.com/render/math?math={\color{white} \lambda = 0.02}"> for all 5 anomaly patterns. The tool also supports the generation of the resource attribute, before injecting anomalies, if this is missing in an event log. While the resource attribute is available in the two real logs, for the artificial logs, in which the resource attribute is missing, we generated it setting 5 departments and 3 resources per each department as parameters in the tool. Regarding the injected anomaly patterns parameters, _M_ for the _insert_ and _rework_ patterns is set to 3 events, _M_ for the _move_ to 5 events for all artificial logs, 10 events for _Hospital Billing_ event log, and 15 events for _Road Traffic_ event log. Note that, during the anomaly injection process, we store the clean version of the traces injected with anomalies in order to calculate the performance of the proposed trace reconstruction approach.
Finally, after the anomalies have been injected, the cases labelled as anomalous that are executed following a normal trace are removed. These anomalies, in fact, are virtually impossible to identify using only information about activity labels in events. 

The statistics of datasets are summarised in Table 1 presented below.

<img src="https://user-images.githubusercontent.com/74713590/168015281-5e6085af-43ef-496c-aee5-be7593a07f20.png" width="400" height="150">


## Result 1: Anomaly pattern classification accuracy by our proposed algorithm

<img src="https://user-images.githubusercontent.com/74713590/168016719-54c54162-1a0e-4deb-a899-3852a0af54e7.png" width="350" height="500">


The results regarding the accuracy of PBAR in identifying the correct anomalous pattern for anomalous traces are shown in Table 2. For each log, we show the results obtained at different sample ratios in the clean log <img src="https://render.githubusercontent.com/render/math?math={\color{white} E_c}"> (10%, 25%, 50%, all clean traces) used for calculating the NBGs. Comparing the performance at different sample ratios is important because the graphs <img src="https://render.githubusercontent.com/render/math?math={\color{white} T_k}"> in PBAR may differ based on the absolute number of traces considered. In particular, we expect that the lower the number of traces considered, the less likely the graphs to capture all the normal behaviour in the log and, therefore, the less likely the proposed approach to perform accurately. The results, however, show the robustness of PBAR in respect of the sample ratio: for the artificial logs, there is no difference in the performance obtained at different sample ratios; for the real logs, the differences are minimal and, surprisingly, in some cases the performance at a lower sample ratio of clean traces is more accurate than at a higher one. This may be caused by the existence of inherent anomalies in the real logs, which would be considered as normal behaviour when constructing the NBGs and disrupt PBAR's ability to detect some of the anomalous traces. Sampling may increase the chance of excluding these inherently anomalous and infrequent traces, leading to more accurate NBGs and, therefore, higher performance. This is consistent with what we experienced in our previous research on anomaly detection [3]. In summary, PBAR appears to maintain its ability even with a small sample size of normal traces, which can be helpful for instance when the normal traces are identified manually among unlabelled data by domain experts.

More in detail, since artificial logs are generated from simple process models, as acknowledged by the low frequency distribution of clean trace variants in Table 1, the proposed approach has no particular issues in identifying all the correct patterns with the artificial logs. For the real logs, for which the variability of traces is higher, the results show that the proposed approach works well for identifying the _skip_ anomaly pattern, comparably worse for the _insert_ and _replace_ patterns, and mainly fails to identify the _rework_ pattern. The poor accuracy on the _rework_ pattern may be caused by the existence of reworked activities in clean traces, which would lead PBAR to identify these reworked activities as normal. Regarding the _move_ pattern, if an event is moved (backward or forward) of only one event from its current location in a trace, then the anomaly detection matrix obtained for this pattern looks the same as the one obtained from the _insert_ or the _replace_ patterns, and the heuristic examination to select the correct pattern among the candidates often fails. This  happens more often when clean variants in <img src="https://render.githubusercontent.com/render/math?math={\color{white} E_c}"> are more diverse, i.e., when there are several alternatives for reconstruction, leading to the low performance on the _move_ pattern, particularly in the Hospital Billing log. 



## Result 2: Anomalous trace reconstruction accuracy

<img src="https://user-images.githubusercontent.com/74713590/168027275-0cdd1167-853a-40d5-89ed-27f3a27aab7f.png" width="500" height="300">


Table 3 compares the reconstruction accuracy, calculated using both the classification accuracy and the average distance, and the run time of PBAR and the baselines.  Note that, since DeepAlign is an unsupervised approach, which does not require a case label in the input dataset, for it we show separately the reconstruction accuracy on normal traces and anomalous traces. That is, the unsupervised design may generate errors even in normal traces. Otherwise, since both the proposed approach and the alignment baselines are semi-supervised, i.e., they require a set of clean labelled traces in input, the reconstruction accuracy of both approaches on normal traces is obviously perfect. Finally, note that, for the distance accuracy, we also report the average distance between normal and reconstructed traces before the reconstruction as a reference. More details about the evaluation can be seen in our paper. 



## Result 3: Reconstruction accuracy for different anomaly patterns

<img src="https://user-images.githubusercontent.com/74713590/168027371-e03dd3e1-c7a1-4bdf-87a1-4e3e0b11864c.png" width="500" height="350">

Table 4 breaks down the classification and distance accuracy of PBAR and the baselines by anomaly pattern.
For PBAR, the results mimic the ones of Table 3, with the reconstruction accuracy dropping when reconstructing the _rework_ pattern for real-world logs. DeepAlign is the only method achieving satisfactory performance on this pattern, but it is often not the best choice for reconstructing other patterns.
Note that PBAR's poor performance on the _rework_ pattern in all real-logs and on the _move_ pattern in the Hospital Billing logs stems from the poor performance of the approach in the preceding anomaly detection step. Moreover, note that the _insert_ pattern is often miss-classified as the _replace_ pattern by PBAR, wich explains the poor performance of PBAR on reconstructing the traces affected by the _insert_ pattern.  



## References
[1] Nolle, T., Luettgen, S., Seeliger, A., & Mühlhäuser, M. (2019). Binet: Multi-perspective business process anomaly classification. Information Systems, 101458.

[2] Ko, J., Lee, J., & Comuzzi, M. (2020). AIR-BAGEL: An Interactive Root cause-Based Anomaly Generator for Event Logs. In ICPM Doctoral Consortium/Tools (pp. 35-38).

[3] Ko, J., & Comuzzi, M. (2021). Detecting anomalies in business process event logs using statistical leverage. Information Sciences, 549, 53-67.



## Appendix : The anomaly reconstruction process

In this section, we show how the anomaly detection matrix is used for detecting anomalies and reconstructing them. Note that, as introduced before, we assume that there are 5 possible trace-level anomaly patterns, i.e., _skip_, _insert_, _rework_, _replace_, and _move_, in event logs, and that an individual trace is affected by at most one anomaly pattern. The approach is by design extensible as long as new anomaly patterns that could be explained from the anomaly detection matrix are considered. 

Detecting anomalies is straightforward: a trace is anomalous if its anomaly detection matrix <img src="https://render.githubusercontent.com/render/math?math={\color{white} D^j}"> contains at least one element <img src="https://render.githubusercontent.com/render/math?math={\color{white} d^j_{n,m}=1}">, that is, if at least one activity in a trace could not be replayed correctly according to the procedure described in Alg.2 presented in our paper. 
By design, the values <img src="https://render.githubusercontent.com/render/math?math={\color{white} d^j_{n,m}=1}"> in the anomaly detection <img src="https://render.githubusercontent.com/render/math?math={\color{white} D^j}"> follow specific patterns, which is the property exploited in the trace reconstruction phase. Next we present in detail how each anomaly pattern is detected and reconstructed. 
Then, we discuss how to handle special situations, such as how to deal with an activity label in a trace not present in the anomaly detection matrix or what to do when a  reconstructed trace is still anomalous. 

_Skip pattern._ The skip pattern [see Fig.2(a) below] is clearly identifiable in an anomaly detection matrix when a column has only values equal to 1. Such a column identifies that one activity between <img src="https://render.githubusercontent.com/render/math?math={\color{white} a_{i}}"> and <img src="https://render.githubusercontent.com/render/math?math={\color{white} a_{i %2B 1}}"> has been anomalously skipped. For the reconstruction, the _S_ events inserted are deleted from the trace. A special case is the one in which the procedure mentioned above does not yield an output, i.e., there is no trace in the event log on which the prefix and the suffix of <img src="https://render.githubusercontent.com/render/math?math={\color{white} \sigma_j}"> can be replayed correctly. In this case, PBAR assumes that the activity <img src="https://render.githubusercontent.com/render/math?math={\color{white} a_{i %2B 1} \in \sigma_j}"> is anomalous, it is therefore deleted, and then a new anomaly detection matrix is calculated for the reconstructed trace and the pattern-based analysis is run on it.

Note that, in general, the anomaly detection matrix is recalculated for every reconstructed trace: if this matrix does not signal any anomaly, then the next trace can be considered, i.e., the reconstruction has been successful; if this matrix signals an anomaly, i.e., it contains a value equal to 1, then the pattern-based analysis is run again. To guarantee the convergence of PBAR, this process is stopped after three reconstructions: the trace obtained after the third reconstruction is kept as the reconstructed one even though its anomaly detection matrix still has values set to 1.

An example of the analysis and reconstruction of this pattern is shown in Figure~\ref{fig:vote}, where in the anomalous trace the "Send fine" activity has been skipped.


_Insert pattern._ Figure 2(b) shows the pattern in the anomaly detection matrix identifying the insertion of _S_ unexpected events in a trace between the events <img src="https://render.githubusercontent.com/render/math?math={\color{white} a_i}"> and <img src="https://render.githubusercontent.com/render/math?math={\color{white} a_{i %2B S %2B 1}}">.  For the reconstruction, the _S_ events inserted are deleted from the trace. An example of the detection and reconstruction of this pattern is shown in Figure~2, where  in the anomalous trace the activity "Wrong event" has been inserted at position 2 in the trace. The anomaly detection pattern is clearly identifiable in the anomaly detection matrix. 

_Rework pattern._ The rework pattern is a special case of the insert one in which all the events inserted have the same activity label (see Figure 2(c)). As such, the detection and reconstruction of this pattern is already captured by what described above for the insert pattern.  

_Replace pattern._ From the standpoint of anomaly injection, replacing an activity in a trace is equivalent to skipping it, i.e., deleting an existing activity, and inserting a different one in its place. The anomaly detection and reconstruction heuristic inverts this logic, by first identifying whether an anomalous activity has been inserted in a trace and then checking whether it should be replaced (or simply deleted). Hence [see Figure 2(d)], detecting the replace pattern starts by detecting the insert pattern (with _S_=1) in the anomaly detection matrix. Once the inserted activity has been deleted, the anomaly detection matrix is recalculated, highlighting the skip pattern at position <img src="https://render.githubusercontent.com/render/math?math={\color{white} a_1}">. Then, following the reconstruction of the skip pattern, a correct activity to be inserted at position <img src="https://render.githubusercontent.com/render/math?math={\color{white} a_i}"> is determined. 

_Move pattern._ From an anomaly injection standpoint, the move pattern can be seen as the sequential application of the skip (i.e., an activity is removed from its normal place) and insert (i.e., the same activity is inserted at a different place) patterns. As such, this pattern is identifiable in the anomaly detection matrix through a combination of the insert and skip patterns described above [Figure 2(e)].
A special case is the one in which an activity is moved backward or forward of 1 position only in a trace. In this case, in fact, the pattern associated with the move pattern will be identical to the insert pattern. Because of this reason, when such a pattern occurs, PBAR tries first to reconstruct the trace using the moved pattern logic. If that is not successful, i.e., the reconstructed trace is still anomalous, then the trace is reconstructed using the insert pattern reconstruction logic described above. 

![image](https://user-images.githubusercontent.com/74713590/168016406-b633108d-6788-420f-a349-141bb3961c5c.png)

.. _introduction:

=============
 Introduction
=============

This guide describes how to use the replay functionality with CESM. 
It is assumed the user is already familiar with how to run CESM on their machine. 
Documentation from the original model version can be found in the 
`CESM Quickstart Guide <https://escomp.github.io/CESM/versions/cesm2.1/html/index.html>`_

What is the replay?
===================

The replay is a version of the Incremental Analysis Update (IAU) used for 
performing data assimilation, described in Bloom et al., 1996 and relating to 
work on empirical bias correction such as in Leith 1978 and DelSole and Hou 1999. 
In standard data assimilation cases, the IAU is used to push the model towards 
observations; in the replay, the model is pushed towards a reanalysis. 
This can be useful for determining short-term model biases and evaluating 
model performance (see Schubert et al., 2019), among other use cases. 

The replay is similar to nudging, but is less sensitive to nudging parameters 
and instabilities (Bloom et al., 1996). The difference is in the timing of the 
forcing towards the reanalysis. In the replay, the model runs forward 3 hours 
normally, with no forcing applied. Then, the difference between the model state 
and the reanalysis is measured (here any or all of U,V,T, and Q can be used) 
and saved in the model output. The model then backs up 3 hours to exactly where 
it was before, and runs forward 6 hours, this time with the forcing tendency 
applied based on the 3-hour difference. After 6 hours, the model moves forward 
another 3 hours without forcing, and the process repeats. This procedure allows 
the model to stay tightly constrained to the reanalysis throughout the run, 
assuming the 3-hour model drift is nearly linear. The outputs of the model 
difference from reanalysis at 3-hour increments are the short-term model biases 
from the reanalysis. The stability of the replay performance is assessed 
in Takacs et al., 2018. 

The replay is currently implemented and used at NASA’s Global Modeling and 
Assimilation Office in the GEOS model (Chang et al., 2019). Here we implement 
the same tool in CESM2 using open source code, a simple startup, and adjustable 
replay parameters. Having the replay in multiple models allows for comparison of 
results across models, and the ability to easily assess short-term model drift in CESM. 


Software requirements
=====================

Installing, building and running the replay requires:

| - All of the software requirements for CESM listed on the `CESM Quickstart Guide <https://escomp.github.io/CESM/versions/cesm2.1/html/introduction.html>`_.
|
| - 3-hourly or more frequent reanalysis data interpolated to the 3D CAM grid at your desired resolution. Reanalysis must contain at least U, V, T, and Q. 
|

For instructions on how to properly interpolate the reanalysis to the CAM grid, we suggest 
using the interpolation tools created for the CESM Nudging toolbox. Documentation 
for the interpolation tools can be found in the `CAM Users Guide: 
Nudging <https://ncar.github.io/CAM/doc/build/html/users_guide/physics-modifications-via-the-namelist.html#target-data>`_. 

References
==========

.. container:: csl-bib-body

   .. container:: csl-entry

      Bloom, S. C., Takacs, L. L., Silva, A. M. da, & Ledvina, D.
      (1996). Data Assimilation Using Incremental Analysis Updates.
      *Monthly Weather Review*, *124*\ (6), 1256–1271.
      https://doi.org/10.1175/1520-0493(1996)124%3C1256:DAUIAU%3E2.0.CO;2

   .. container:: csl-entry

      Chang, Y., Schubert, S. D., Koster, R. D., Molod, A. M., & Wang,
      H. (2019). Tendency Bias Correction in Coupled and Uncoupled
      Global Climate Models with a Focus on Impacts over North America.
      *Journal of Climate*, *32*\ (2), 639–661.
      https://doi.org/10.1175/JCLI-D-18-0598.1

   .. container:: csl-entry

      DelSole, T., & Hou, A. Y. (1999). Empirical Correction of a
      Dynamical Model. Part I: Fundamental Issues. *Monthly Weather
      Review*, *127*\ (11), 2533–2545.
      https://doi.org/10.1175/1520-0493(1999)127%3C2533:ECOADM%3E2.0.CO;2

   .. container:: csl-entry

      Leith, C. E. (1978). Objective Methods for Weather Prediction.
      *Annual Review of Fluid Mechanics*, *10*\ (1), 107–128.
      https://doi.org/10.1146/annurev.fl.10.010178.000543

   .. container:: csl-entry

      Schubert, S. D., Chang, Y., Wang, H., Koster, R. D., & Molod, A.
      M. (2019). A Systematic Approach to Assessing the Sources and
      Global Impacts of Errors in Climate Models. *Journal of Climate*,
      *32*\ (23), 8301–8321. https://doi.org/10.1175/JCLI-D-19-0189.1

   .. container:: csl-entry

      Takacs, L. L., Suárez, M. J., & Todling, R. (2018). The Stability
      of Incremental Analysis Update. *Monthly Weather Review*,
      *146*\ (10), 3259–3275. https://doi.org/10.1175/MWR-D-18-0117.1
================================
 Replay to reanalysis in CESM
================================

This document describes how to use the replay functionality with CESM. It is assumed the user is already familiar with how to run CESM on their machine. Documentation from the original model version can be found in the README_CESM.rst file. 

.. sectnum::

.. contents::

What is the replay?
=================

The replay is a version of the Incremental Analysis Update (IAU) used for performing data assimilation, described in Bloom et al., 1996 and relating to work on empirical bias correction such as in Leith 1978 and DelSole and Hou 1999. In standard data assimilation cases, the IAU is used to push the model towards observations; in the replay, the model is pushed towards a reanalysis. This can be useful for determining short-term model biases and evaluating model performance (see Schubert et al., 2019), among other use cases. 

The replay is similar to nudging, but is less sensitive to nudging parameters and instabilities (Bloom et al., 1996). The difference is in the timing of the forcing towards the reanalysis. In the replay, the model runs forward 3 hours normally, with no forcing applied. Then, the difference between the model state and the reanalysis is measured (here any or all of U,V,T, and Q can be used) and saved in the model output. The model then backs up 3 hours to exactly where it was before, and runs forward 6 hours, this time with the forcing tendency applied based on the 3-hour difference. After 6 hours, the model moves forward another 3 hours without forcing, and the process repeats. This procedure allows the model to stay tightly constrained to the reanalysis throughout the run, assuming the 3-hour model drift is nearly linear. The outputs of the model difference from reanalysis at 3-hour increments are the short-term model biases from the reanalysis. The stability of the replay performance is assessed in Takacs et al., 2018. 

The replay is currently implemented and used at NASA’s Global Modeling and Assimilation Office in the GEOS model (Chang et al., 2019). Here we implement the same tool in CESM2 using open source code, a simple startup, and adjustable replay parameters. Having the replay in multiple models allows for comparison of results across models, and the ability to easily assess short-term model drift in CESM. 


Software requirements
=====================

Installing, building and running the replay requires:

* All of the software requirements for CESM listed on the README_CESM.rst

* 3-hourly or more frequent reanalysis data interpolated to the 3D CAM grid at your desired resolution. Reanalysis must contain at least U, V, T, and Q. 

For notes on how to properly interpolate the reanalysis to the CAM grid, we suggest using the interpolation tools created for the CESM Nudging toolbox. Documentation for the interpolation tools can be found in the `CAM Users Guide: Nudging <https://ncar.github.io/CAM/doc/build/html/users_guide/physics-modifications-via-the-namelist.html#target-data>`_. 


Obtaining the model code
========================

The replay version of CESM requires modifications to multiple components of the model (i.e. CAM, CICE, CLM, CIME). However, modifications to all necessary components can be obtained by simply checking out this CESM repository. 

To obtain the replay model you need to do the following:

#. Clone the repository. ::

      git clone https://github.com/sweidy/cesm.git my_replay_sandbox

   This will create a directory ``my_replay_sandbox/`` in your current working directory. It is recommended that you create an entirely new CESM directory for using the replay, since running a non-replay case is not currently possible in the replay verison. 

#. Go into the newly created repository. There is no need to select a tag or model release, as the Externals.cfg file will point to the correct replay branches for each model component. 
   The replay was built from the most recently released version of CESM2 at the time of writing (``cesm2.1.5-rc.01``); the model component versions corresponding to this version are commented out in the **Externals.cfg** file for reference. ::

      cd my_cesm_sandbox

#. Run the script **manage_externals/checkout_externals**. ::

      ./manage_externals/checkout_externals

   The **checkout_externals** script is a package manager that will populate the cesm directory with the relevant versions of each of the components along with the CIME infrastructure code.

At this point you have a working version of the replay!


Running a replay case
=====================

Most of differences between running the replay and a regular CESM case can be managed through namelist definitions set in **user_nl_cam**. You may customize your run as usual, as long as you follow the specifications below:

#. Create a new case using the FHIST_DARTC6 compset [*]_ and the finite volume dynamical core. Any resolution should work, as long as it matches your reanalysis data. You will also need to specify to run an unsupported case. ::

      ./create_newcase --case cases/replay --compset FHIST_DARTC6 --res f19_f19_mg17 --run-unsupported

#. Make any changes to your job submission requests, then run case.setup. ::

      cd cases/replay
      ./case.setup

#. Use a startup run and set the length of your run to double the time of your desired run (because the model backs up and reruns the timesteps). For example, if you want to run a 2-year replay using reanalysis from 1980-1981, use: ::

      ./xmlchange RUN_TYPE="startup"
      ./xmlchange RUN_STARTDATE=1980-01-01
      ./xmlchange STOP_OPTION="nyears"
      ./xmlchange STOP_N=4

#. Adjust the replay namelist parameters in user_nl_cam. At the minimum, you will need to set the replay to true and add directions to your reanalysis data (the four parameters below). An example user_nl_cam file is in this directory as **user_nl_cam_example**. ::

      Replay_Model = .true.
      Replay_Path = '/some/path/to/data/' 
      Replay_File_Template = 'reanalysis_%y%m%d_%s.nc' 
      Replay_Beg_Year = YYYY

#. Often, users want to save the replay tendencies as output to look at what forcing the replay is using to push the model towards the reanalysis. The replay forcings are listed in the history master list as 'UDIFF' (m/s), 'VDIFF' (m/s), 'QDIFF' (kg/kg), and 'SDIFF' (J/kg). These values are the difference between the model and the reanalysis at the replay timestep (3hr, 9hr, 15 hr, 21 hr). To get the tendencies applied by the replay during the nudging step, divide the DIFF output values by 6 hours in seconds. ::

      fincl2 = 'SDIFF:I','UDIFF:I','VDIFF:I','QDIFF:I','U:I','V:I','T':I,'Q:I'
      mfilt=1,3
      nhtfrq = 0,-3

   The way the history files are written is such that there are 3 timesteps in each file. Timestep 1 is all 0 (this is the first pass before the tendency has been calculated). Timesteps 2 and 3 are duplicates, since the model calculates the differences every 6 hours but saves every 3 hours. The relevant information from either timestep 2 or 3 in the h1 files, if you save them as above. And example script to extract the 6-hour differences is in this directory as **extract_tendencies_example.sh**. 

#. Build and submit model as normal.

A complete list of namelist parameters available for the replay are described in the **components/cam/bld/namelist_files/namelist_definition.xml** file. 

.. [*] The replay requires resetting buffer variables to their previous values every time the model backs up. The current setup only resets buffer variables in the FHIST_DARTC6 compset, which is similar to the normal AMIP compsets but with a stub river component and has been used for other data assimilation purposes. A description of the compset is in **components/cam/cime_config/confic_compsets.xml**. 

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

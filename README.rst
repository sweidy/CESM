================================
 Replay to reanalysis in CESM
================================

This document describes how to use the replay functionality with CESM. It is assumed the user is already familiar with 
how to run CESM on their machine. Documentation from the original model version can be found in the README_CESM.rst file. 

.. sectnum::

.. contents::

What is a replay?
=================

Description of replay. 


Software requirements
=====================

Software requirements for installing, building and running the replay
---------------------------------------------------------------------

Installing, building and running the replay requires:

* All of the software requirements for CESM listed on the README_CESM.rst

* 3-hourly or more frequent reanalysis data interpolated to the 3D CAM grid at
your desired resolution. Reanalysis must contain at least U, V, T, and Q. 

For notes on how to properly interpolate the reanalysis to the CAM grid, we 
suggest using the interpolation tools created for the CESM Nudging toolbox. 
Documentation for the interpolation tools can be found in the `CAM Users Guide: Nudging <https://ncar.github.io/CAM/doc/build/html/users_guide/physics-modifications-via-the-namelist.html#target-data>`. 


Obtaining the model code
========================

The replay version of CESM requires modifications to multiple components of the model
(i.e. CAM, CICE, CLM, CIME). However, modifications to all necessary components can be
obtained by simply checking out this CESM repository. 

To obtain the replay model you need to do the following:

#. Clone the repository. ::

      git clone https://github.com/sweidy/cesm.git my_replay_sandbox

   This will create a directory ``my_replay_sandbox/`` in your current working directory.
   It is recommended that you create an entirely new CESM directory for using the replay,
   since running a non-replay case is not currently possible in the replay verison. 

#. Go into the newly created repository. There is no need to select a tag or model release,
   as the Externals.cfg file will point to the correct replay branches for each model component. 
   The replay was built from the most recently released version of CESM2 at the time of writing
   (cesm2.1.5-rc.01); the model component versions corresponding to this version are commented
   out in the Externals.cfg file for reference. ::

      cd my_cesm_sandbox

#. Run the script **manage_externals/checkout_externals**. ::

      ./manage_externals/checkout_externals

   The **checkout_externals** script is a package manager that will
   populate the cesm directory with the relevant versions of each of the
   components along with the CIME infrastructure code.

At this point you have a working version of the replay.


Running a replay case
=====================

Most of differences between running the replay and a regular CESM case can be managed
through namelist definitions set in user_nl_cam. You may customize your run as usual, 
except for the 

#. Create a new case using the FHIST_DARTC6 compset* and the finite volume dynamical core.
   Any resolution should work, as long as it matches your reanalysis data. You will also
   need to specify to run an unsupported case. ::

      ./create_newcase --case cases/replay --compset FHIST_DARTC6 --res f19_f19_mg17 --run-unsupported

#. Make any changes to your job submission requests, then run case.setup. ::

      cd cases/replay
      ./case.setup

#. Use a startup run and set the length of your run to double the time of your desired
   run (because the model backs up and reruns the timesteps). For example, if you want 
   to run a 2-year replay using reanalysis from 1980-1981, use: ::

      ./xmlchange RUN_TYPE="startup"
      ./xmlchange RUN_STARTDATE=1980-01-01
      ./xmlchange STOP_OPTION="nyears"
      ./xmlchange STOP_N=4

#. Adjust the replay namelist parameters in user_nl_cam. At the minimum, you will need to set 
   the replay to true and add directions to your reanalysis data (the four parameters below). 
   An example user_nl_cam file is in this directory as example_user_nl_cam. ::

      Replay_Model = .true.
      Replay_Path = '/some/path/to/data/' 
      Replay_File_Template = 'reanalysis_%y%m%d_%s.nc' 
      Replay_Beg_Year = YYYY

#. Often, users want to save the replay tendencies as output to look at what forcing the replay
   is using to push the model towards the reanalysis. The replay forcings are listed in the history 
   master list as 'UDIFF' (m/s), 'VDIFF' (m/s), 'QDIFF' (kg/kg), and 'SDIFF' (J/kg). These values 
   are the difference between the model and the reanalysis at the replay timestep (3hr, 9hr, 15 hr, 
   21 hr). To get the tendencies applied by the replay during the nudging step, divide the DIFF 
   output values by 6 hours in seconds. ::

      fincl2 = 'SDIFF:I','UDIFF:I','VDIFF:I','QDIFF:I'
      mfilt=1,6
      nhtfrq = 0,-3

   The way the history files are written is such that there are 6 timesteps in each file. Timestep 1 
   and 4 are all 0 (this is the first pass before the tendency has been calculated). Timestep 2/3 (5/6) 
   are duplicates, since the model calculates the differences every 6 hours but saves every 3 hours. So the 
   information you want is from timesteps 2 and 5 (or 3 and 6) in the h1 files, if you save them as above. 

#. Build and submit model as normal.

A complete list of namelist parameters available for the replay are described in the
components/cam/bld/namelist_files/namelist_definition.xml file. 
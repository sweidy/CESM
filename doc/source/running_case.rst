.. _running:

============================
Running a simple replay case
============================

Most of differences between running the replay and a regular CESM case can be managed 
through namelist definitions set in **user_nl_cam**. Example **user_nl_cam** and post-processing
scripts are in the Github repository for the replay: `<https://github.com/sweidy/CESM/>`_. 

#. Create a new case using the FHIST_DARTC6 compset and the finite volume dynamical core. 
   Any resolution should work, as long as it matches your reanalysis data. You will also 
   need to specify to run an unsupported case. ::

      ./create_newcase --case cases/replay --compset FHIST_DARTC6 --res f19_f19_mg17 --run-unsupported

#. Make any changes to your job submission requests, then run case.setup. ::

      cd cases/replay
      ./case.setup

#. Use a startup run and set the length of your run to double the time of your desired run 
   (because the model backs up and reruns the timesteps). For example, if you want to run a 
   2-year replay using reanalysis from 1980-1981, use: ::

      ./xmlchange RUN_TYPE="startup"
      ./xmlchange RUN_STARTDATE=1980-01-01
      ./xmlchange STOP_OPTION="nyears"
      ./xmlchange STOP_N=4

#. Adjust the replay namelist parameters in user_nl_cam. At the minimum, you will need to set 
   the replay to true and add directions to your reanalysis data (the four parameters below). ::

      Replay_Model = .true.
      Replay_Path = '/some/path/to/data/' 
      Replay_File_Template = 'reanalysis_%y%m%d_%s.nc' 
      Replay_Beg_Year = YYYY

#. Often, users want to save the replay tendencies as output to look at what forcing the replay 
   is using to push the model towards the reanalysis. The replay forcings are listed in the history 
   master list as 'UDIFF' (m/s), 'VDIFF' (m/s), 'QDIFF' (kg/kg), and 'SDIFF' (J/kg). These values are 
   the difference between the model and the reanalysis at the replay timestep (3hr, 9hr, 15 hr, 21 hr). 
   To get the tendencies applied by the replay during the nudging step, divide the DIFF output 
   values by 6 hours in seconds. ::

      fincl2 = 'SDIFF:I','UDIFF:I','VDIFF:I','QDIFF:I','U:I','V:I','T':I,'Q:I'
      mfilt=1,3
      nhtfrq = 0,-3

   The way the history files are written is such that there are 3 timesteps in each file. Timestep 1 is all 0 
   (this is the first pass before the tendency has been calculated). Timesteps 2 and 3 are duplicates, since 
   the model calculates the differences every 6 hours but saves every 3 hours. The relevant information from 
   either timestep 2 or 3 in the h1 files, if you save them as above. 

   |

#. Build and submit model as normal.

Additional possible configurations available for the replay are described on the page 
:ref:`Available configurations for the replay`.
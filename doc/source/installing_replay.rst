.. _installing:

=============================
Installing the replay
=============================

The replay version of CESM requires modifications to multiple components of the model 
(i.e. CAM, CICE, CLM, CIME). A detailed description of all SourceMod changes are in the 
:ref:`API <Changes to SourceMods for Replay>`.
However, modifications to all necessary components can be obtained by simply checking out 
this CESM repository. Refer to the original `CESM guide <https://escomp.github.io/CESM/versions/cesm2.1/html/downloading_cesm.html>`_
for troubleshooting porting the model. 

To obtain the replay model you need to do the following:

#. Clone the repository. ::

      git clone https://github.com/sweidy/cesm.git my_replay_sandbox

   This will create a directory ``my_replay_sandbox/`` in your current working directory. 
   It is recommended that you create an entirely new CESM directory for using the replay, 
   since running a non-replay case is not possible in the replay verison due to changes made to the 
   model's time manager.

   |

#. Go into the newly created repository. There is no need to select a tag or model release, 
   as the Externals.cfg file will point to the correct replay branches for each model component. 
   The replay was built from the most recently released version of CESM2 at the time of writing 
   (``cesm2.1.5-rc.01``); the model component versions corresponding to this version are commented 
   out in the **Externals.cfg** file for reference. ::

      cd my_replay_sandbox

#. Run the script **manage_externals/checkout_externals**. ::

      ./manage_externals/checkout_externals

   The **checkout_externals** script is a package manager that will populate the cesm directory 
   with the relevant versions of each of the components along with the CIME infrastructure code.

At this point you have a working version of the replay!


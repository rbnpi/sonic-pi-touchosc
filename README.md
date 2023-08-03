# sonic-pi-touchosc
Example control of Sonic Pi using TouchOSC

This demo program uses TouchOSC to control 5 parameters in a running Sonic Pi program using OSC messages. These are sent from TouchOSC to port 4560 on Sonic Pi, and in the example both Sonic Pi and Touch OSC are assumed to be running on the same host, and signals are therefore sent to and from localhost 127.0.0.1

It also allows Sonic Pi to intialise the controls by responding to OSC signals sent from Sonic Pi to TouchOSC. The SP program has a use_osc command to send to port 5000 on localhost.

The playing part of the SP program consists of a live loop :test at the end of the program which is embedded inside to fx calls, one to set up reverb, and the second to set up a lpf filter and this adjust cutoff. Inside the loop notes are selected from a three-octave range of an :e2 minor_pentatonic scale and played repeatedly. The synth, transpose and pan setting of the notes are adjustable using TouchOSC, as are the :room parameter and the :cutoff parameter of the fx wrappers.

The first part of the SP program sets up the links between SP and TouchOSC, and initialises values of the controls and their data in both programs.
Data retrieved from TouchOSC which is updated every time one of its controls is alterred are stored in the state line in a series of variables which are given intial values in the firest few code lines of the progtram. A function :preset is then set up which sends a series of OSC messages from SP to TouchOSC. This reference the five controls, three faders and two grid switches (grids of switches which are indexed by position in the grid and adjusted to be exclusive, ie when one is switched on (has its data set to 1) then the others in the grid are automatically switched off (data 0). The faders are given values in the range 0->1 and switch 1 is selected for teh two grids. (Note one is set to number from the top, the other from the bottom in the TouchOSC settings)

The preset function is called by name to intialise the controls. A function :parse_sync_address is set up. This appears quite complex but is actually using an undocumneted fiunction inside SP which alows you to parse an event and get the full address data which has produced the event, even though it was triggered using wild cards. Thus if we look for the sync event that matches "/osc*/transpose/*" it will let us retrieve what matches each of the wild cards. You can see further detail about this function in this link https://in-thread.sonic-pi.net/t/how-do-i-access-the-name-of-an-osc-message-once-it-has-been-received/7370/2?u=robin.newman

Each of the five controls used has a separate live_loop set up to handle its operation as far as receiving data from TouchOSC and acting upon it.
These are the loops :oscrs :osctr :oscpan :osccutoff and :oscsyn   In each case real time is evoked to give minimum response time.  Each one starts with a statement of the form `n = sync"/osc*/name"` The loop will wait until an incoming OSC message on port 4560 matches name, where name might be "/cutoff" or /transpose/*" In the case of the slider controls we want the data in n, and since only one iten is sent this will be in n[0]. In the case of the grid switches we just need to make sure that n[0] is equal to 1.0 and then we use the parse_sync_address function to find the number of the switch which has been turned on triggering the event. We then take the data and scale it suitably if necessary, before saving it to the appropriate variable in the time line using a set command.

The main playing loop reads these values on each pass and uses them either directly in the synth command used to play the next note, or in a control statement which adjusts one of the parameters in the fx wrappers, i.e. the room value or the cutoff value.

Hopefully you can get an idea of how TouchOSC can interact with TouchOSC from this example, althouhg much more complex interaction can be achieved.

As far as the TouchOSC side is concerned, it takes a little while to get into setting up templates. Best way to learn is to look at the data for each control in the editor and to experiment. Hoope you enjoy using this resource and experimenting with it.

Robin Newman, August 2023

#test osc control program by Robin Newman August 2023
#use TouchOSC with repository .tosc file to drive this
#TouchOSC running on the same computer as Sonic Pi
#it illustrates techniques for both receiving data from TouchOSC
#and sending data to TouchOSC to initialise sliders, buttons etc

use_debug false #to switch off much of the logging
set :rs,0.5 #initial values for :room paramter
set :tr,0 #initial value for transpose
set :pn,0 #initial pan setting
set :co,95 #initial cutoff value
set :syn, :tri #initial synth

use_osc "localhost",5000 #address of TouchOSC (incoming OSC) set in TouchOSC

define :preset do #function to send data to five TouchOSC controls
  osc "/reverb", 0.5 #reverb slider to half scale
  osc "/transpose/1", 1 #transpose grid switch 1 (bottom one) switched on
  osc "/pan", 0.5 #pan slider to centre (0.5)
  osc "/cutoff",0.5 #cutoff slider to centre (0.5)
  osc "/synth/1",1 #synth grid switch 1 (the top one) switched on
end

preset #call the preset function

#next function lets you extract the osc address which matches a wild card
#eg "/osc*/synth/*" might sync with "/osc:127.0.0.1:5000/synth/2"
#and the function will let you extract the bits matching the *s
define :parse_sync_address do |address| #gets info on wild cards used in sync address
  v= get_event(address).to_s.split(",")[6]
  if v != nil
    #return a list of address elements with wild cards substituted by actual values
    return v[3..-2].split("/")
  else
    return ["error"]
  end
end

live_loop :oscrs do
  use_real_time
  n = sync "/osc*/reverb"
  set :rs,n[0] #synced datga returned in list n. There is one value n[0]
  puts n[0]
end

live_loop :osctr do
  use_real_time
  n = sync "/osc*/transpose/*"
  if n[0]==1.0
    t=parse_sync_address("/osc*/transpose/*")
    #puts t #might return ["osc:127.0.0.1:5000", "transpose", "5"]
    #we want the third element so get t[2]
    t=t[2]
    set :tr, t.to_i - 1 #convert t to an integer and subtract 1 so will give range 0->12
    puts get(:tr)
  end
end

live_loop :oscpan do
  use_real_time
  n = sync "/osc*/pan"
  set :pn,-1 + 2 * n[0] #n[0] contains float 0-->1 convert to range -1 to 1
  puts get(:pn) #pan value stored in state variable :pn
end

live_loop :osccutoff do
  use_real_time
  n = sync "/osc*/cutoff"
  set :co,60 + 70 * n[0] #data in n[0] float range 0->1 Convert to range 60->130
  puts get(:co) #check value stored in state variable :co
end

live_loop :oscsyn do #works same wauy as the osctr live_loop
  use_real_time
  n = sync "/osc*/synth/*"
  if n[0]==1.0
    sn=parse_sync_address("/osc*/synth/*")[2] #get the third element of the parse string
    syn = [:tri,:tb303,:saw,:fm][sn.to_i - 1] #use it to select synth from list
    puts sn.to_i - 1 #check list index
    puts syn
    set :syn,syn
  end
end

#main playing fx and live_loop
with_fx :reverb,room: 0.5,mix: 0.7 do |r| #start fx reverb and store pointer in r
  set :r,r #save r in state variable :r
  with_fx :lpf,cutoff: 130,cutoff_slide: 0.05 do |c| #start fx lpf and store pointer in c
    #note small cutoff_slide to prevent clicks
    set :c,c #store in :c
    live_loop :test do
      use_real_time #get realtime response
      control get(:r),room: get(:rs) #control the reverb room parameter
      control get(:c),cutoff: get(:co) #control the cutoff parameter
      #now play the note with selected synth,transpose and pan settings
      synth get(:syn),note: scale(:e2+get(:tr),:minor_pentatonic,num_octaves: 3).choose,
        release: 0.2,pan: get(:pn)
      sleep 0.2
    end
  end
end

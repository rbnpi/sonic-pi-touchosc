#test osc control program by Robin Newman August 2023
#use TouchOSC with repository .tosc file to drive this
#TouchOSC running on the same computer as Sonic Pi
use_debug false
set :rs,0.5 #initial value
set :tr,0
set :pn,0

define:parse_sync_address do |address| #gets info on wild cards used in sync address
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
  set :rs,n[0]
  puts n[0]
end

live_loop :osctr do
  use_real_time
  n = sync "/osc*/transpose"
  set :tr,n[0] * 12
  set :syn,:tri
  puts get(:tr)
  
end

live_loop :osctpan do
  use_real_time
  n = sync "/osc*/pan"
  set :pn,-1 + 2 * n[0]
  puts get(:pn)
end

live_loop :oscsyn do
  use_real_time
  n = sync "/osc*/synth/*"
  if n[0]==1.0
    sn=parse_sync_address("/osc*/synth/*")[2]
    syn = [:tri,:tb303,:saw,:fm][sn.to_i - 1]
    puts syn
    set :syn,syn
  end
end


with_fx :reverb,room: 0.5,mix: 0.7 do |r|
  set :r,r
  live_loop :test do
    use_real_time
    control get(:r),room: get(:rs)
    synth get(:syn),note: scale(:e2+get(:tr),:minor_pentatonic,num_octaves: 3).choose,
      release: 0.2,pan: get(:pn)
    sleep 0.2
  end
end




---------------------
-- By Flying Papi ---
--------------------- 
local Cart1_Haut = 50
local Cart_Larg = 130
local Init_x = 0
--local Init_y = 20
local Init_y = 20
local Posx = 0
local alpha = 0.8
-- couleurs Fond TitleBox
local fr, fg, fb = 0.1, 0.1, 1
-- couleurs Fond ParamBox
local pr, pg, pb = 0.2, 0.2, 0.2
-- couleurs Texte
local tr,tg,tb = 1,1,1

local Text_Color = "white"
local Line = {
        39, -- Line 1 (12)
        27, -- Line 2 (12)
        15, -- Line 3
        03  -- Line 4
    }

------------------------------
--- Unités pour conversion ---
------------------------------
local System_Fuel = "kg"      -- "kg",lb","gal"
local System_Flow = "kg/s"    -- "kg/s","lbs","pph","gph"
local System_Temp = "C"       -- "C","F","K"

local str,Iter = "",0
local Posx = 0
-----------------
--- Autopilot ---
-----------------
local Mag_Psi = get("sim/flightmodel2/position/mag_psi")
local AP_Hdg_mag = dataref_table("sim/cockpit/autopilot/heading_mag")
local HSI_Sel = dataref_table("sim/cockpit/switches/HSI_selector")

local acf_auth = get("sim/aircraft/view/acf_author")
local acf_desc = get("sim/aircraft/view/acf_descrip")
local acf_tire = dataref_table("sim/flightmodel2/gear/tire_vertical_force_n_mtr")
local acf_gear = dataref_table("sim/aircraft/parts/acf_gear_deploy")
-------------------
-- Flaps & Slats --
-------------------
local angle1 = dataref_table("sim/flightmodel2/wing/flap1_deg")
local angle2 = dataref_table("sim/flightmodel2/wing/flap2_deg")
--
local hdl_flap = get("sim/flightmodel2/controls/flap_handle_deploy_ratio")

--sim/aircraft2/engine/max_power_limited_watts
local fuel_pressure = dataref_table("sim/cockpit2/engine/indicators/fuel_pressure_psi")
local acf_pwr_max   = get("sim/aircraft2/engine/max_power_limited_watts")
local acf_pwr       = dataref_table("sim/cockpit2/engine/indicators/power_watts")
local acf_thr       = dataref_table("sim/flightmodel/engine/ENGN_thro")
local acf_prop      = dataref_table("sim/flightmodel/engine/ENGN_prop")
--
--local acf_mix       = dataref_table("sim/flightmodel/engine/ENGN_mixt")
local acf_mix       = dataref_table("sim/cockpit2/engine/actuators/mixture_ratio")
--
local acf_rpm       = dataref_table("sim/cockpit2/engine/indicators/prop_speed_rpm")
local acf_egt       = dataref_table("sim/flightmodel/engine/ENGN_EGT_c")
local acf_itt       = dataref_table("sim/flightmodel2/engines/ITT_deg_C")
local acf_cht       = dataref_table("sim/flightmodel/engine/ENGN_CHT_c")
local acf_mpr       = dataref_table("sim/cockpit2/engine/indicators/MPR_in_hg")
local acf_N1        = dataref_table("sim/flightmodel2/engines/N1_percent")
local acf_N2        = dataref_table("sim/flightmodel2/engines/N2_percent")
local acf_trq       = dataref_table("sim/cockpit2/engine/indicators/torque_n_mtr")
local acf_gen       = dataref_table("sim/flightmodel/engine/ENGN_gen_amp")
local acf_Oil_Temp  = dataref_table("sim/flightmodel/engine/ENGN_oil_temp_c")
local acf_Oil_Press = dataref_table("sim/flightmodel/engine/ENGN_oil_press_psi")
local acf_Cowl      = dataref_table("sim/cockpit2/engine/actuators/cowl_flap_ratio")

------------------------------------------------------------
--- Propmode 0 = Feat, 1 = Normal, 2 = Beta, 3 = Reverse ---
------------------------------------------------------------
local acf_propmode  = dataref_table("sim/flightmodel/engine/ENGN_propmode")

local acf_hi_oil    = get("sim/aircraft/limits/green_hi_oilT")
local acf_lo_oil    = get("sim/aircraft/limits/green_lo_oilT")
local red_hi_oilP   = get("sim/aircraft/limits/red_hi_oilP")
local red_lo_oilP   = get("sim/aircraft/limits/red_lo_oilP")
-------------------------------
--- Reservoirs et carburant ---
-------------------------------
local acf_num_tanks = get("sim/aircraft/overflow/acf_num_tanks")
local acf_tank_rat  = dataref_table("sim/aircraft/overflow/acf_tank_rat")               -- ratio for each tank
local acf_fuel_qty  = dataref_table("sim/flightmodel/weight/m_fuel")                    -- Fuel Tank Weight - for 9 tanks

local Datarefs = true


if Datarefs then
    ------------------------------------
    --- Zulu Time (UTC) & local time ---
    ------------------------------------
    dataref("l_Time","sim/time/local_time_sec")
    dataref("z_Time","sim/time/zulu_time_sec")
    ---
    dataref("Oat","sim/cockpit2/temperature/outside_air_temp_degc")
    -----------------
    --- Autopilot ---
    -----------------
    dataref("AP_State","sim/cockpit/autopilot/autopilot_state")
    dataref("AP_mode", "sim/cockpit/autopilot/autopilot_mode")
    dataref("YD_mode", "sim/cockpit2/switches/yaw_damper_on")
    dataref("Approach","sim/cockpit2/autopilot/approach_status")
    dataref("HDG_mode","sim/cockpit2/autopilot/heading_mode")
    ----------------
    --- Vitesses ---
    ----------------
    --sim/flightmodel/position/vh_ind_fpm
    --sim/flightmodel/position/vh_ind_fpm2
    --sim/cockpit2/gauges/indicators/vvi_fpm_pilot
    dataref("acf_fpm", "sim/flightmodel/position/vh_ind_fpm")
    ---
    dataref("acf_ias", "sim/flightmodel/position/indicated_airspeed")
    dataref("acf_cas", "sim/cockpit2/gauges/indicators/calibrated_airspeed_kts_pilot")
    dataref("acf_tas", "sim/cockpit2/gauges/indicators/true_airspeed_kts_pilot")
    dataref("acf_gnd", "sim/flightmodel/position/groundspeed")
    dataref("acf_mch", "sim/flightmodel/misc/machno")
    acf_vs  = math.floor(get("sim/aircraft/view/acf_Vs"))
    acf_vso = math.floor(get("sim/aircraft/view/acf_Vso"))
    acf_vfe = math.floor(get("sim/aircraft/view/acf_Vfe"))
    acf_vle = math.floor(get("sim/aircraft/overflow/acf_Vle"))
    acf_vno = math.floor(get("sim/aircraft/view/acf_Vno"))
    acf_vne = math.floor(get("sim/aircraft/view/acf_Vne"))
    acf_vyse= math.floor(get("sim/aircraft/overflow/acf_Vyse"))
    if acf_vno > 400 then acf_vne = acf_vle ; acf_vno = acf_vle end
    if acf_vno == 0 then acf_vno = acf_vne - 20 end
    acf_vmca = tonumber(get("sim/aircraft/overflow/acf_Vmca")) or 0
    if acf_vmca < acf_vs then acf_vmca = acf_vs*1.3 end
    dataref("Stall_Warn","sim/operation/failures/rel_stall_warn")
    -- Altitudes --sim/cockpit2/gauges/indicators/altitude_ft_pilot
    dataref("acf_msl","sim/cockpit2/gauges/indicators/altitude_ft_pilot","readonly")
    dataref("acf_agl","sim/flightmodel/position/y_agl","readonly")
    --dataref("landed","sim/flightmodel/failures/onground_any","readonly")
    dataref("acf_fpm", "sim/flightmodel/position/vh_ind_fpm", "writable")
    -- Divers 
    dataref("paused","sim/time/paused")
    dataref("acf_hdg","sim/flightmodel/position/mag_psi")
    dataref("acf_var","sim/flightmodel/position/magnetic_variation")
--    dataref("acf_fpr", "sim/operation/misc/frame_rate_period")
    dataref("acf_fpr", "sim/time/framerate_period")
    -- local eng_type = dataref_table("sim/aircraft/prop/acf_en_type")
    dataref("park_brake","sim/cockpit2/controls/parking_brake_ratio", "writable")
    --dataref("acf_gear","sim/aircraft/parts/acf_gear_deploy", "writable")
    dataref("hobbsmeter","sim/time/hobbs_time", "writable")
    dataref("acf_flap","sim/flightmodel/controls/flaprat")
    ---------------------------
    -- Speedbrake , Spoilers --
    ---------------------------
    dataref("spl_1","sim/cockpit2/controls/speedbrake_ratio")       -- ratio, where 0.0 is fully retracted, 0.5 is halfway down, and 1.0 is fully down, and -0.5 is speedbrakes ARMED.
    dataref("spl_2","sim/flightmodel2/controls/speedbrake_ratio")
    dataref("spl_3","sim/flightmodel2/wing/spoiler1_deg",0)
    dataref("spl_4","sim/flightmodel2/wing/spoiler2_deg",0)
    dataref("spl_5","sim/cockpit2/annunciators/speedbrake")
    dataref("spl_6","sim/cockpit/warnings/annunciators/speedbrake")
    dataref("spl_7","sim/flightmodel2/wing/spoiler1_deg",0)           -- Deflection of the roll-spoilerfrom set #1 on this wing. Degrees, positive is trailing-edge down.
    dataref("spl_8","sim/flightmodel2/wing/spoiler2_deg",0)           -- Deflection of the roll-spoilerfrom set #1 on this wing. Degrees, positive is trailing-edge down.

end

--

function ACF_Name()
    return string.gsub(string.gsub(AIRCRAFT_FILENAME,".acf",""),"_","%1")
end
--local Icao_Name = PLANE_ICAO
local Icao_Name = PLANE_ICAO or ""
if Icao_Name == "" or Icao_Name == nil then Icao_Name = ACF_Name() end
if Icao_Name == "" then Icao_Name = ACF_Name() end

-------------------------------------------------------------------------
-- Characteristics correction (Externals datas, not standard datarefs) --
-------------------------------------------------------------------------
if ACF_Name() == "CarbonCub"    then Icao_Name = "PA11" end
if ACF_Name() == "A350_xp11"    then Icao_Name = "A350" end
if ACF_Name() == "Bell412"      then Icao_Name = "B412" end
if ACF_Name() == "Car_PC12"     then Icao_Name = "PC12" end

if ACF_Name() == "Aerolite_103" then acf_vfe = 60 end
--
local Flap = {}
local Array = {}
local i
local Flap_Detent = get("sim/aircraft/controls/acf_flap_detents")

if not Flap_Detent or Flap_Detent < 1 then Flap_Detent = 1 end
for i = 1,Flap_Detent do Flap[i] = acf_vfe end

--
if string.lower(ACF_Name()) == "concorde" then Icao_Name = "CONC" end
-- Pilatus PC12
if Icao_Name == "PC12" then acf_vso = 59 ; acf_vs = 68 end
-- Bombardier Challenger 300
if Icao_Name == "CL30" then acf_vso = 90 ; acf_vs = 103 ; Flap = {210,210,175} end
-- De Havilland DHC-3 Otter
if Icao_Name == "DHC3" then acf_vso = 53 ; acf_vs = 66 ; acf_vfe = 83 end
-- De Havilland DHC-6 Twin Otter
if Icao_Name == "DHC6" then acf_vso = 54 ; acf_vs = 60 ; Flap = {103,93,93,85} end
-- Boeing B737-800v
if Icao_Name == "B738" then
  Flap = {250,250,250,210,200,190,175,162}
  Array = {0,1,2,5,10,15,25,30,40,0}
  for i=1,10 do
    set_array("sim/aircraft/controls/acf_flap_dn" ,i-1,Array[i])
    set_array("sim/aircraft/controls/acf_flap2_dn",i-1,Array[i])
  end
end
-- Embraer E175 & E195 (X-Craft)
if Icao_Name == "E170" or Icao_Name == "E190" then
  Flap = {230,215,200,190,180,165}
end
-- Cessna 172
if Icao_Name == "C172" then Flap = {110,85,85} end

-- Cirrus SF50
if Icao_Name == "SF50" then Flap = {190,150} end
-- Mac Donnell MD82
if Icao_Name == "MD82" then Flap = {280,280,240,195,195} end
-- Boeing B747-800
if Icao_Name == "B748" then Flap = {285,265,245,235,210,185} end
-- Airbus A350-900
if Icao_Name == "A359" then Flap = {280,220,212,195,185} end
-- Embraer Family (X-Craft)
if string.find(".E35L.E135.E140.E145.E45X",Icao_Name) then
  Flap = {250,250,200,145}
end
-- PA46 Malibu
if Icao_Name == "PA46" then
  Flap = {168,135,118}
end
-- PA31 Cheyenne
if Icao_Name == "PAY2" then
  Flap = {181,148}
end
-- Carenado Saab 340
if Icao_Name == "SF34" then
  Flap = {175,175,165,140}
  acf_vle = 200
end
-- Cessna 208 Gran Caravan
if Icao_Name == "C208" then
  Flap = {175,150,125}
end
-- Aerobask Phenom 300
if Icao_Name == "E55P" then
  Flap = {180,170,160}
end

----------------------------------------------------------------
--- Customize Aircraft Description (Using AIRCRAFT_FILENAME) ---
----------------------------------------------------------------
function ACF_Desc()
  local Desc = get("sim/aircraft/view/acf_descrip")
  if string.find(AIRCRAFT_PATH,"Laminar Research") then
    return ("Laminar - %s"):format(#Desc> 0 and Desc or string.gsub(AIRCRAFT_FILENAME,".acf",""))
  end

  if AIRCRAFT_FILENAME == "b738.acf" and Desc == "Boeing 737-800X"  then return "Zibomod - Boeing 737-800X" end

  if  AIRCRAFT_FILENAME == "b738_4k.acf"                  then return "Zibomod - Boeing 737-800X 4K"
  elseif  AIRCRAFT_FILENAME == "B38M.acf"                     then return "Jim Miller - Boeing 737 Max-8"
  elseif  AIRCRAFT_FILENAME == "AG-4.acf"                     then return "AG-4 EVTOL v2.0"
  elseif  AIRCRAFT_FILENAME == "DHC-3T_TurboOtter_wheel.acf"  then return "vFliteAir - DHC3 Turbo Otter Wheel"
  elseif  AIRCRAFT_FILENAME == "DHC-3T_TurboOtter_floats.acf" then return "vFliteAir - DHC3 Turbo Otter Float"
  elseif  AIRCRAFT_FILENAME == "DHC-3T_TurboOtter_amphib.acf" then return "vFliteAir - DHC3 Turbo Otter Amphib"
  elseif  AIRCRAFT_FILENAME == "DHC6.acf"                     then return "RWDesigns - DHC6-300 Twin Otter"
  elseif  AIRCRAFT_FILENAME == "DHC6F.acf"                    then return "RWDesigns - DHC6-300 Twin Otter Float"
  elseif  AIRCRAFT_FILENAME == "DHC6G1000.acf"                then return "RWDesigns - DHC6-300 Twin Otter G1000"
  elseif  AIRCRAFT_FILENAME == "DHC6S.acf"                    then return "RWDesigns - DHC6-300 Twin Otter Ski"
  elseif  AIRCRAFT_FILENAME == "DHC6T.acf"                    then return "RWDesigns - DHC6-300 Twin Otter Tundra"
  elseif  AIRCRAFT_FILENAME == "DA62.acf"                     then return "Aerobask - Diamond DA62"
  elseif  AIRCRAFT_FILENAME == "phenom300.acf"                then return "Aerobask - Phenom 300"
  elseif  AIRCRAFT_FILENAME == "akoya.acf"                    then return "Aerobask - Lisa Akoya"
  elseif  AIRCRAFT_FILENAME == "DR401_CDI155.acf"             then return "Aerobask - Robin 401 Cdi 155"
  elseif  AIRCRAFT_FILENAME == "CarbonCub.acf"                then return "Big Tire - Carbon Cub" 
  elseif  AIRCRAFT_FILENAME == "VSL ICON-A5.acf"              then return "VSKYLABS - Icon-A5"
  elseif  AIRCRAFT_FILENAME == "VSL Phoenix.acf"              then return "VSKYLABS - Phoenix U15" 
  elseif  AIRCRAFT_FILENAME == "Bell412.acf"                  then return "X-Trident - Bell 412" 
  elseif  AIRCRAFT_FILENAME == "AS350B3.acf"                  then return "DreamFoil - Ecureuil AS350 B3+" 
  elseif  AIRCRAFT_FILENAME == "Bell 407.acf"                 then return "DreamFoil - Bell 407"
  elseif  AIRCRAFT_FILENAME == "BK-117.acf"                   then return "Kawasaki BK 117 B-2"
  elseif  AIRCRAFT_FILENAME == "S92 VIP.acf"                  then return "Sikorsky S-92A - VIP/Corporate"
  elseif  AIRCRAFT_FILENAME == "S92 SAR.acf"                  then return "Sikorsky S-92A - Search & Rescue"
  elseif  AIRCRAFT_FILENAME == "S92 VIP.acf"                  then return "Sikorsky S-92A - VIP/Corporate"
  elseif  AIRCRAFT_FILENAME == "VH-92.acf"                    then return "Sikorsky S-92A - US Presidential"
  elseif  AIRCRAFT_FILENAME == "S92.acf"                      then return "Sikorsky S-92A - Offshore/Air Taxi"
  elseif  AIRCRAFT_FILENAME == "CH-148.acf"                   then return "Sikorsky CH-148 - Cyclone"
  elseif  AIRCRAFT_FILENAME == "222B.acf"                     then return "CowanSim - Bell 222B"
  elseif  AIRCRAFT_FILENAME == "222UT.acf"                    then return "CowanSim - Bell 222UT"
  elseif  AIRCRAFT_FILENAME == "F4.acf"                       then return "Phantom F-4"
  elseif  AIRCRAFT_FILENAME == "VSL P2006T-G1000.acf"         then return "VSL Tecnam P2006T - G1000"
  elseif  AIRCRAFT_FILENAME == "VSL P2006T.acf"               then return "VSL Tecnam P2006T Analogic"
  elseif  AIRCRAFT_FILENAME == "VSL EuroFOX 220-tundra.acf"   then return "VSL EuroFOX 220 Tundra"
  elseif  AIRCRAFT_FILENAME == "VSL EuroFOX 220.acf"          then return "VSL EuroFOX 220"
  elseif  AIRCRAFT_FILENAME == "VSL EuroFOX 240.acf"          then return "VSL EuroFOX 240"
  else
    return Desc
  end
end
-------------------------
--- Engine parameters ---
-------------------------
local eng_type      = get("sim/aircraft/prop/acf_en_type")
if eng_type > 5 then eng_type = 9 end
local nb_engine     = get("sim/aircraft/engine/acf_num_engines")
local type          = {"Carburetor","Injection","Turbine", "Electric","Jet Low","Jet High","Rocket","Rocket","TurbFix","Engine"}
-----------------------
local Carburetor    = 0
local Injection     = 1
local Turbine       = 2
local Electric      = 3
local Jet_low       = 4
local Jet_high      = 5
local Engine        = 6
-----------------------
local type_engine   = type[eng_type+1]
local Is_Helicopter = get("sim/aircraft2/metadata/is_helicopter") -- Value = 1 if true
------------------------------------------------------------------------
--- Engines type aera if not specified in datarefs (Using Icao_Name) ---
------------------------------------------------------------------------
if string.find(".PA11", Icao_Name) then eng_type = Carburetor end
if string.find(".DR40.EFOX", Icao_Name) then eng_type = Injection end
if string.find(".BE9L.DHC6.D228.D328.PAY2.PA46.B206R.R66.EC35.h500.SF34.PC12", Icao_Name) then eng_type = Turbine end
if string.find(".FA50", Icao_Name) then eng_type = Jet_low end
if string.find(".B738.A319.F4", Icao_Name) then eng_type = Jet_high end
--
local type_engine   = type[eng_type+1]


if Icao_Name == "A319" or Icao_Name == "A321" then
    acf_thr = dataref_table("sim/flightmodel/engine/ENGN_thro_use")
end

logMsg("=== Ligne 315 === Icao_Name = " .. Icao_Name .. " - ICAO = " .. PLANE_ICAO .. " - Eng Type = " .. eng_type .. " ("..type_engine..")")

----------------------------
--- APU & GPU Generators ---
----------------------------
dataref("acf_gpu_amp","sim/cockpit/electrical/gpu_amps")
dataref("acf_apu_amp","sim/cockpit2/electrical/APU_generator_amps")
dataref("acf_apu_n1","sim/cockpit2/electrical/APU_N1_percent")
dataref("acf_apu_egt","sim/cockpit2/electrical/APU_EGT_c")
-------------------------------
--- Répartitions des Masses ---
-------------------------------
local acf_empty_weight  = get("sim/aircraft/weight/acf_m_empty")                        -- Masse à vide
local acf_fuel_max      = get("sim/aircraft/weight/acf_m_fuel_tot")                     -- Capacité Maximale en Carburant
local acf_fuel_flow = dataref_table("sim/cockpit2/engine/indicators/fuel_flow_kg_sec")  -- total fuel flow, kilograms per second
local acf_fuel_pump = dataref_table("sim/cockpit2/fuel/tank_pump_pressure_psi")
dataref("acf_payload","sim/flightmodel/weight/m_fixed")                                 -- Chargement
dataref("acf_max_weight","sim/aircraft/weight/acf_m_max")                               -- Masse Totale tout compris
dataref("acf_actual_weight","sim/flightmodel/weight/m_total")                           -- Total Weight Actual
dataref("acf_fuel_tot","sim/flightmodel/weight/m_fuel_total")
dataref("acf_fuel_burn","sim/cockpit2/fuel/fuel_totalizer_sum_kg")                      -- Total accumulated fuel used by all engines since totalizer initialization
dataref("acf_fuel_init","sim/cockpit2/fuel/fuel_totalizer_init_kg")                     -- Total fuel on board the fuel totalizer was initialized with
---------------------------
-- Fligh Time & traveled --
---------------------------
dataref("flightime","sim/time/total_flight_time_sec")
dataref("traveled","sim/flightmodel/controls/dist")
--set("sim/cockpit2/fuel/fuel_totalizer_init_kg",acf_fuel_tot)
-- Oxygen Bottle in liter --
--dataref("Air_Qty","sim/cockpit2/oxygen/indicators/o2_bottle_rem_liter")
--
--
--
local Iii = 0
local Cu1 = 0
local Cu2 = 0
local E_Fpr = 0
local E_Fps = 30
local Cpt = 30
--
local Air_Cycle = 15             -- nbr de secondes entre 2 prises
local Air_Init = os.clock()
local Air_Maxi = os.clock() + Air_Cycle
local Air_Time = Air_Cycle
local Air_Qty = get("sim/cockpit2/oxygen/indicators/o2_bottle_rem_liter")
local Air_Mark = get("sim/cockpit2/oxygen/indicators/o2_bottle_rem_liter")
local Air_Flow = 0
local Air_Used = 0              -- Qty air respiré


local Battery_Charge = { false, false, false, false, false, false, false, false}
local Last_Charge = {}
  for ii = 0,7 do
    Last_Charge[ii] = get("sim/cockpit/electrical/battery_charge_watt_hr",ii)
  end

function Boutons()
  local ii
  local Diff
  local Watt
  local Text
  local Last
  if button(1) == true then
    if get("sim/graphics/view/view_is_external") > 0 then
      command_once("sim/view/default_view")
    else
      command_once("sim/view/chase")
      set("sim/graphics/view/pilots_head_psi",130)
      set("sim/graphics/view/pilots_head_tet",-25)
    end
  end
--  logMsg("=========================")
  for ii = 0,7 do
    Watt = get("sim/cockpit/electrical/battery_charge_watt_hr",ii)
    Last = Last_Charge[ii]
    Diff = Watt - Last
    if Diff  >= 0 then
      Battery_Charge[ii] = true
    else
      Battery_Charge[ii] = false
    end
--    Text = ("Num %i - Charge %.5f - Last %.5f - Diff %s"):format(ii,Watt,Last, Diff>=0 and "Pos" or "Neg" )
    --logMsg(Text)
    Last_Charge[ii] = get("sim/cockpit/electrical/battery_charge_watt_hr",ii)
  end
end
function Calcul_FPS2()
   if paused ~= 1 then
        Iii = Iii + 1
        Cu1 = Cu1 + acf_fpr
        Cu2 = Cu2 + 1
--

        if Iii % Cpt == 0 then
--            Iii = 0
            E_Fpr = Cu1/Cpt
            E_Fps = 1/E_Fpr
            Cu1 = 0
        end
--
        if os.clock() >= Air_Maxi then
            Air_Time = os.clock() - Air_Init
            Air_Maxi = os.clock() + Air_Cycle
            Air_Init = os.clock()
            --
            Air_Qty = get("sim/cockpit2/oxygen/indicators/o2_bottle_rem_liter")
            Air_Used = Air_Qty - Air_Mark
            Air_Mark = Air_Qty
            Air_Flow = math.abs(Air_Used/Air_Time)
        end
    end
end
local function Duree(value,mode)
    -- Value = 0 < seconds < 99h59h59
    -- mode     nil --> hh:mm:ss 
    --          0   --> short mode  hh:mm if value > 3600
    --                              mm:ss if value < 3600
    -----------------------------------------------------
    local hh,mm,ss
    if value < 0 or value > 100*60*60 - 1 then return "" end 
    hh,mm = math.modf(value / 3600)
    mm,ss = math.modf(mm * 60)
    --
    if mode == 0 then
        if value >= 3600 then
            return string.format('%dh%02d',hh,mm) -- renvoie au format hh:mm
        else
            return string.format('%02d:%02d',mm,ss*60 % 60)
        end
    else
        return string.format('%02dh%02d:%02d',hh,mm,ss*60 % 60) -- renvoie au format hh:mm:ss
    end

end
--
--
local Last_Gforce = 1
local Last_Fpm = 0
local Land_Fpm = 0
local Land_Spd = 0
local Land_Aoa = 0
local Land_Flg = 0
local Land_Clk = os.clock()
local Type_Surface = get("sim/flightmodel/ground/surface_texture_type")
local Type_Terrain = {
  "Etendue d'eau",                -- 01
  "Installation Militaire",       -- 02
  "Piste en Asphalte/Tarmac",     -- 03
  "Piste en herbe",               -- 04 
  "Piste poussiereuse",           -- 05
  "Piste en graviers",            -- 06
  "Type 7",                       -- 07
  "Type 8",                       -- 08
  "Bord de piste",                -- 09
  "Zone anti-Souffle",            -- 10
  "Hors-piste",                   -- 11
  "Appontage",                    -- 12
}
--
local Depart_Vol,Temps_Vol,Cumul_Vol = 0,0,0
local Dirty = false

local Snd_AutoFlap = load_WAV_file(SCRIPT_DIRECTORY .."(Bridget) - AutoFlap.wav")
local Snd_Pushback = load_WAV_file(SCRIPT_DIRECTORY .."(FTB) - Pushback Completed.wav")
local Play_AutoFlap = false
--set_sound_gain(Snd_AutoFlap,1.0)
--set_sound_pitch(Snd_AutoFlap,1.0)

require("graphics")
require("bit")

------------------------
-- Aeroport de départ --
------------------------
local Next_Airport = XPLMFindNavAid( nil, nil, LATITUDE, LONGITUDE, nil, xplm_Nav_Airport)
local Airport_From,Airport_Name
_, _, _, _, _, _,Airport_From,Airport_Name = XPLMGetNavAidInfo(Next_Airport)
local Trajet = Airport_From

---
local Brake = 0

function Scriptname()
  local name = debug.getinfo(2, "S").source:sub(2)
  return name:match("^.+/(.+)$")
end


local Script = Scriptname()
--
local Tick_Over = 0
function Fly_Over_The_Sea()
  if get("sim/flightmodel/ground/surface_texture_type") == 1 then
    Tick_Over = Tick_Over + 1
  else
    Tick_Over = 0
  end
end

function Afficher_Banner()
  -- OpenGL graphics state initialization
  -- use only in do_every_draw()
  XPLMSetGraphicsState(0,0,0,1,1,0,0)

    -----------------------------
    -- Gestion du Temps de Vol --
    -----------------------------
    if Landed() == true then
        Dirty       = false
        Cumul_Vol   = Temps_Vol
    else
        if not Dirty then
            Depart_Vol  = get("sim/time/total_flight_time_sec")
            Dirty       = true
        else
            Temps_Vol = get("sim/time/total_flight_time_sec") - Depart_Vol + Cumul_Vol
        end
    end
    -----------------------------
    -- Parametres atterrissage --
    -----------------------------
    local Total = get("sim/time/total_flight_time_sec") 
    if Landed() == true then
        if Total < 10 then
            Last_Gforce = 1
        else
            Last_Gforce = string.format('%.2f',math.max(Last_Gforce,get("sim/flightmodel/forces/g_nrml")))
        end
        Land_Fpm = math.min(Land_Fpm,tonumber(string.format('%.0f',get("sim/flightmodel/position/vh_ind_fpm"))))
        if Land_Flg == 0  then
            Land_Aoa = tonumber(string.format('%.1f',get("sim/flightmodel2/misc/AoA_angle_degrees")))
            Land_Spd = tonumber(string.format('%.0f',get("sim/flightmodel/position/groundspeed")*1.94384))
            Land_Fpm = tonumber(string.format('%.0f',get("sim/flightmodel/position/vh_ind_fpm")))
            Land_Flg = 1
        end
--        Land_Spd = string.format('%.0f',math.max(acf_gnd*1.94384,Land_Spd))
--        G_Title = "G-Max"
    else
        if get("sim/flightmodel/position/y_agl") > 15 then  -- 15m = 50 ft
            Land_Flg = 0
            Land_Fpm = 0
            Land_Spd = 0
            Land_Aoa = 0
            Last_Gforce = 1 -- string.format('%.2f',get("sim/flightmodel/forces/g_nrml"))
        end
    end

    ---------------------------------
    -- Boucle affichage Info Panel --
    ---------------------------------
    if PPV_Display then
        Posx = Init_x
        Mdl_Infos()
        Mdl_Fps()
        Mdl_Altitude()
        Mdl_Ground()
        Mdl_Heading()
        Mdl_Gear()
        Mdl_Flaps()
        Mdl_Battery()
        if PPV_Engine   then Mdl_Aux() ; Mdl_Moteurs() end
        if PPV_Fuel     then
        --    Mdl_Tank()
            Mdl_Fuel()
        end
        Mdl_Cabin()
--        Mdl_Oxygen()
        if PPV_Multi    then Mdl_Players() end
--        Mdl_Spoilers()
--        Mdl_Weights()
--        Mdl_Vor()
        Largeur_Modules = Posx - Init_x
        Init_x = (SCREEN_WIDTH - Largeur_Modules)/2
        Display_Status_Type()
    end
end

local Alt_Jet   = tonumber(string.format("%.0f",(get("sim/aircraft/overflow/SFC_alt_hi_JET") or 0)/0.3048))
local Alt_Prp   = tonumber(string.format("%.0f",(get("sim/aircraft/overflow/SFC_alt_hi_PRP") or 0)/0.3048))

PPV_Display = false
PPV_Engine  = true
PPV_Battery = true
PPV_Fuel    = true
PPV_Aux     = true
PPV_Press   = Alt_Jet>15000 or Alt_Prp>15000 and true or false
--get("sim/cockpit2/tcas/indicators/tcas_num_acf")
PPV_Multi   = get("sim/cockpit2/tcas/indicators/tcas_num_acf") > 1 and true or false -- Mdl_Players


set_array("sim/cockpit2/switches/landing_lights_switch",0,0)
---[[
if get("sim/graphics/view/window_width") <= 1920 then
  PPV_Battery = false
  PPV_Fuel    = false
  PPV_Aux     = false
end
--]]


do_often("Boutons()")
do_every_frame("Calcul_FPS2()")
do_every_draw("Afficher_Banner()")
do_sometimes("Fly_Over_The_Sea()")

do_on_keystroke( "touche_pressee()" )

create_command("FlyWithLua/FlyingToolBox/Info_Panel/Toggle", "Toggle Info Panel", "PPV_Display = not PPV_Display", "", "")

--------------------------------------
-- Display Flag for Main Info Panel --
--------------------------------------
if PPV_Display  == true then
    add_macro("===== Main Info Panel =====", "PPV_Display = true", "PPV_Display = false", "activate")
else
    add_macro("===== Main Info Panel =====", "PPV_Display = true", "PPV_Display = false", "deactivate")
end
------------------------------------
-- Display Flag for Engine Module --
------------------------------------
if PPV_Engine  == true then
    add_macro("Engine", "PPV_Engine = true", "PPV_Engine = false", "activate")
else
    add_macro("Engine", "PPV_Engine = true", "PPV_Engine = false", "deactivate")
end
-------------------------------------
-- Display Flag for Battery Module --
-------------------------------------
if PPV_Battery  == true then
    add_macro("Battery", "PPV_Battery = true", "PPV_Battery = false", "activate")
else
    add_macro("Battery", "PPV_Battery = true", "PPV_Battery = false", "deactivate")
end
---------------------------------------
-- Display Flag for GPu & APU Module --
---------------------------------------
if PPV_Aux  == true then
    add_macro("GPU & APU", "PPV_Aux = true", "PPV_Aux = false", "activate")
else
    add_macro("GPU & APU", "PPV_Aux = true", "PPV_Aux = false", "deactivate")
end
------------------------------------------
-- Display Flag for Fuel & Tanks Module --
------------------------------------------
if PPV_Fuel  == true then
    add_macro("Fuel & Tanks", "PPV_Fuel = true", "PPV_Fuel = false", "activate")
else
    add_macro("Fuel & Tanks", "PPV_Fuel = true", "PPV_Fuel = false", "deactivate")
end
------------------------------------------
-- Display Flag for Pressurization & O2 --
------------------------------------------
if PPV_Press  == true then
    add_macro("Pressurization & O2", "PPV_Press = true", "PPV_Press = false", "activate")
else
    add_macro("Pressurization & O2", "PPV_Press = true", "PPV_Press = false", "deactivate")
end

add_macro("Heading help", "PPV_Hdg = true", "PPV_Hdg = false", "if (PPV_Hdg == true) then 'activate' else 'deactivate' end")


------------------------------------------
-- Display Flag for Multiplayers Module --
------------------------------------------
if PPV_Multi  == true then
    add_macro("Multiplayers", "PPV_Multi = true", "PPV_Multi = false", "activate")
else
    add_macro("Multiplayers", "PPV_Multi = true", "PPV_Multi = false", "deactivate")
end


--add_macro("Multiplayers", "PPV_Multi = true", "PPV_Multi = false", "if (PPV_Multi == true) then 'activate' else 'deactivate' end")
add_macro("========================","")

local Dragger = get("sim/flightmodel2/position/true_theta") > 5 and get("sim/flightmodel2/position/groundspeed") < 1 and true or false
local TailDragger
if Dragger == true then TailDragger = " Dragger" else TailDragger = "" end


function Find_Dataref(DataRef_Name)
  if XPLMFindDataRef(DataRef_Name ) == nil then
    return nil
  else
    return get(DataRef_Name)
  end
end
function touche_pressee()
    Info_Panel = CKEY..":"..VKEY
end
function Auto_K(value,decimal)
  local Unit = ""
  decimal = decimal or 1 -- default value
  if math.abs(value) >= 1e6  then
    value = value/1e6; Unit = " M"
  elseif math.abs(value) >= 1e3 then
    value = value/1e3 ; Unit = " K"
  end
  return ("%."..decimal.."f%s"):format(value,Unit)
end
function Auto_Float(value)
  local Unit

  if math.abs(value) >= 1e12 then
    value = value/1e12 ; Unit = " T"
  elseif math.abs(value) >= 1e9 then
    value = value/1e9 ; Unit = " G"
  elseif math.abs(value) >= 1e6 then
    value = value/1e6 ; Unit = " M"
  elseif math.abs(value) >= 1e3 then
    value = value/1e3 ; Unit = " k"
  else
    Unit = ""
  end

  return string.sub(tostring(("%.3f"):format(value)),1,5)..Unit
end
function To_Bit(value)
    local len = 24
    local bit = ""
    local div = 2^(len-1)
    local temp = value
    while len > 0 do
        div = 2 ^ (len-1)
        if temp >= div then
            bit = string.format("%s1",bit)
            temp = temp - div
        else
            bit = string.format("%s0",bit)
        end
        len = len -1
        if len % 4 == 0 and len ~= 0 then bit = bit.."." end
    end
    return bit
end
function Display_Auth_Desc()
    local text, offset 
    Text = "Autopilot State: " .. string.format("%06X",Autopilot) .. " - " .. To_Bit(Autopilot)
    --[[
    if acf_auth and acf_desc then
        text = acf_auth.." - "..acf_desc
    else
        text = acf_auth.." "..acf_desc
    end
    --]]
    offset = (SCREEN_WIDTH - measure_string(text,"Helvetica_18"))/2
    Center_Box(1,text)
    glColor4f(0,1,0,1)
    draw_string_Helvetica_18(offset,Init_y - 2,text)
end
function Warning_Message(Level,Text, Fond)
    local Offset
    local Xraas = ""
    local Addtxt
    if XPLMFindDataRef("xraas/ND_alert") ~= nil then
        Xraas = XRAAS_ND_msg_decode(get("xraas/ND_alert"))
        if Xraas ~= nil then Text = string.format("%s (Xraas: %s)",Text,Xraas) end
    end
    
--    Text = Text .. Addtxt
    Offset = (SCREEN_WIDTH - measure_string(Text,"Helvetica_18"))/2
    if Level == 3 then
        glColor4f(1,0,0,1) -- RED
        Center_Box(Cart1_Haut*2 - 2 , Text,"red")
        glColor4f(1,1,1,1) -- RED
    elseif Level == 2 then glColor4f(1,1,0,1) -- Yellow 
    elseif Level == 1 then glColor4f(0,1,0,1) -- Green
    elseif Level == 0 then glColor4f(1,1,1,1) -- White
    else 
        glColor4f(0,0,0,1)
    end
    draw_string_Helvetica_18(Offset,Cart1_Haut*2, Text)
end
function Display_Status_Type()
    local Text = ""
    local Offset 
    local Icao = PLANE_ICAO
    local Name = ACF_Desc()
    local Warning = 0
    local Tail_Rotor = get("sim/operation/failures/rel_trotor") 
    local Canopy = get("sim/cockpit2/switches/canopy_open")
    local Canopy_Ratio = get("sim/flightmodel/controls/canopy_ratio")
    local Throttle = "sim/cockpit2/engine/actuators/throttle_ratio_all"

    local Door_Open = 0
    local Failure = 0
    local Text_Fail = ""
    local ii
    local Autopilot = get("sim/cockpit/autopilot/autopilot_state")      -- Bitfield Status
    local Auto_Text = string.format("Autopilot State: %06X - %s - ",Autopilot, To_Bit(Autopilot)) 
    for ii = 0,9 do
        if get("sim/flightmodel2/misc/door_open_ratio",ii) > 0 then
            Door_Open = Door_Open + 1
        end
        if get("sim/flightmodel/engine/ENGN_running",ii) < 1 and ii < get("sim/aircraft/engine/acf_num_engines") then
            Failure = Failure + 1
            Text_Fail = string.format("%s %d",Text_Fail, ii + 1)
        end
    end
    if Icao == "ICONA5" then
        local Folded = get("sim/flightmodel2/controls/wingsweep_ratio")
        if Folded > 0 then
            Warning = 1 ; Text = string.format(" Folded Wings %.1f%% ",Folded*100)
        end
    elseif Icao =="AKOY" then
        local Akoy_Ratio = get("sim/flightmodel2/misc/custom_slider_ratio",20)
        if Akoy_Ratio > 1e-4 then
            Warning = 1 ; Text = string.format(" Folded Wings %.1f%% ",Akoy_Ratio*100)
        end
    end
    --
    if Canopy_Ratio > 1e-4 then
        if #Text > 0 then Text = Text .. "-" end
        Warning = 1 ; Text = string.format("%s Canopy Open %.1f%% ",Text,Canopy_Ratio*100)
    end
    --
    if Door_Open > 0 then
        if #Text > 0 then Text = string.format("%s-",Text) end
        Warning = 1
        if Door_Open == 1 then
            Text = string.format("%s Door Open ",Text)
        else
            Text = string.format("%s Doors Open: %d ",Text,Door_Open)
        end
    end
    if Failure > 0 then
        Warning = 1
        if Failure == 1 then
            Text = string.format("%s Engine%s is not Running ",Text, Text_Fail)
        else
            Text = string.format("%s Engine(s) not Running: %s ",Text, Text_Fail)
        end
    end
    if Tail_Rotor > 0 then
        Warning = 1
        Text = string.format("%s - Transmission Failure (Code %d)",Text,Tail_Rotor)
    end
    --

    if Warning > 0 then
        Center_Box(1,Text)
        glColor4f(1,1,0,1)
    else
        if #Icao == 0 then
            Text = " ("..Name..") "
        else
            Text = " [".. Icao .."] - ("..Name..") "
        end
        Text = Auto_Text .. Text .. " - " .. Trajet .. " "
        Center_Box(1,Text)
        glColor4f(0,1,0,1)
    end
    
    
    Offset = (SCREEN_WIDTH - measure_string(Text,"Helvetica_18"))/2
    draw_string_Helvetica_18(Offset,Init_y - 19,Text)
end
function Center_Box(y,text,fond)
    local x1,y1,x2,y2,larg,haut
    larg = measure_string(text,"Helvetica_18")
    haut = 18
    x1 = (SCREEN_WIDTH - larg)/2
    y1 = y
    x2 = x1 + larg
    y2 = y1 + haut
    if fond == "red" then
        glColor4f(1,0,0,1) 
    else
        glColor4f(0,0,0,1)
    end
    glRectf(x1,y1,x2,y2)
end
function Mdl_Cabin()
  -------------------------------
  -- Pressurisation de l'avion --
  -------------------------------
  local Max_Altitude  = 12500
  local Allowable     = get("sim/cockpit2/pressurization/actuators/max_allowable_altitude_ft")
  local DumpMode      = get("sim/cockpit2/pressurization/actuators/dump_all_on")
  local Alti_Set      = tonumber(string.format('%.0f',get("sim/cockpit/pressure/cabin_altitude_set_m_msl")))
  local Rate_Set      = tonumber(string.format('%.0f',get("sim/cockpit/pressure/cabin_vvi_set_m_msec")))
  local Valv_Out      = tonumber(string.format('%.0f',get("sim/cockpit2/pressurization/indicators/outflow_valve")))
  local Pilot_felt    = get("sim/cockpit2/oxygen/indicators/pilot_felt_altitude_ft")
  local Alti_Act      = tonumber(string.format('%.0f',get("sim/cockpit/pressure/cabin_altitude_actual_m_msl")))
  local Rate_Act      = tonumber(string.format('%.0f',get("sim/cockpit/pressure/cabin_vvi_actual_m_msec")))
  local Diff_psi      = string.format('%.02f',get("sim/cockpit/pressure/cabin_pressure_differential_psi"))
  local Num_Mode      = tonumber(get("sim/cockpit2/pressurization/actuators/bleed_air_mode"))
  local Is_Helico     = get("sim/aircraft2/metadata/is_helicopter")
  local Txt_Mode      = {"OFF","Left","Both","Right","APU","Auto"}
  local larg          = 140
  local Mode          = "Unkown"
  local Warn_Code,Actual = 0,"Act / Felt"
  local Ln1,Ln2,Ln3,Ln4 = "----","----","----","----"
  local Rn1,Rn2,Rn3,Rn4 = "----","----","----","----"
  local Valve_stat = get("sim/cockpit2/oxygen/actuators/o2_valve_on")

  if Num_Mode >= 0 and Num_Mode <= 5 then Mode = Txt_Mode[Num_Mode+1] end
  
  if DumpMode == 1 then Warn_Code,Title = 1,"Air Dump!" else Title = "Pressurization" end

  if PPV_Press == true or Pilot_felt > Max_Altitude then
    if Pilot_felt > Max_Altitude then Warn_Code = 2 end
      Ln1 = Allowable > 0 and "Max (Set)" or string.format("Setting (%s)", Auto_K(Alti_Set)) 
      Rn1 = Allowable > 0 and string.format("%s (%s)",Auto_K(Allowable),Auto_K(Alti_Set)) or string.format("Diff %.2f",Diff_psi)
      --
      Ln2 = string.format("Rate (%s)",Auto_K(Rate_Set))
      Rn2 = Auto_K(Rate_Act)
      --
      Ln3 = "Act (Felt)"
      Rn3 = string.format("%s (%s)",Auto_K(acf_msl),Auto_K(Pilot_felt))    
      --
      Ln4 = "Bleed Src"
      Rn4 = Mode
      --
      -- function TitleBox(x,larg,text,color,warn,rr,gg,bb)
--      if Is_Helico < 1 then
        if Warn_Code > 1 then
          TitleBox(Posx,larg,Title,nil,Warn_Code,Warning_Level(Max_Altitude,15000,Alti_Act))
        else
          if Valve_stat == 1 then
            TitleBox(Posx,larg,"Open Valve","green")
          else
            TitleBox(Posx,larg,Title,nil,Warn_Code)
          end
        end
--      end
      ParamBox(Posx,Init_y,larg,8, Ln1, Ln2, Ln3, Ln4, Rn1, Rn2, Rn3, Rn4)
  end
end
function Mdl_Oxygen()
    ---------------------------------
    -- Besoins en Oxygene Equipage --
    ---------------------------------
    local warn
    local Valve_Txt = "--"
    local largeur = 100
    local title = "Oxygen"
    local Valve_stat = get("sim/cockpit2/oxygen/actuators/o2_valve_on")
    if Valve_stat == 1 then Valve_Txt = "On" end
    local Plugged = tonumber(string.format('%.0f',get("sim/cockpit2/oxygen/actuators/num_plugged_in_o2")))
    local Bottle_psi = tonumber(string.format('%.0f',get("sim/cockpit2/oxygen/indicators/o2_bottle_pressure_psi")))
    local Pilot_felt = tonumber(string.format('%.0f',get("sim/cockpit2/oxygen/indicators/pilot_felt_altitude_ft")))
    local Endur = "n/a"
    if Air_Flow > 0 then Endur = Duree(Air_Qty / Air_Flow,1) end
    local t1,t2,t3,t4
    local d1,d2,d3,d4
    if Bottle_psi == 0 then
        title = "O2 Alert"
        t1,d1 = "Lim Alt","12500"
        t2,d2 = "Felt Alt",Pilot_felt
        t3,d3 = "Bottle","none"
        t4,d4 = "Plugged",Plugged
    else
        t1,d1 = "Plugged",Plugged
        t2,d2 = "Rem psi",string.format('%.1f',Bottle_psi)
        t3,d3 = "Rem Qty",string.format('%.1f',Air_Qty)
        t4,d4 = "Endur",Endur
    end
    if PPV_Press == true or Pilot_felt >= 12500 or Valve_stat == 1 then
        if Pilot_felt >= 12500 then warn = 1 end
        TitleBox(Posx,largeur,title,nil,warn)
        ParamBox(Posx,Init_y,largeur,8,t1,t2,t3,t4,d1,d2,d3,d4)
    end
end
function Warning_Level(mini, maxi, value)
    ------------------------------------------------
    -- percent = 0...1 -- 0.0 = yellow, 1.0 = red -- 
    ------------------------------------------------
    local swap, percent
    if mini > maxi then swap = maxi ; maxi = mini ; mini = swap end
    if value > maxi then value = maxi end
    if value < mini then value = mini end
    percent = (value - mini)/(maxi - mini)
    return 1,1 - percent,0
end
function Speed_Dial()
    local Spd_Dial  = get("sim/cockpit2/autopilot/airspeed_dial_kts_mach")
    local Is_Mach   = get("sim/cockpit2/autopilot/airspeed_is_mach")
    local Unit
    
    if Is_Mach > 0 then
        Unit = "Mach %0.2f"
    else
        Unit = "Spd %3.0f"
    end
    return string.format(Unit,Spd_Dial)
end
function Mdl_Infos()
-- White if selected, Yellow if Armed, Green if Actived/Captured
-- +----+----+----+-----+-----+-----+------+-----+
-- | FD | AP | YD | HDG | ALT | ATH | TIME | UTC |
-- +----+----+----+-----+-----+-----+------+-----+
-- AP  = Autopilot Mode (Off, FD, AP)
-- YD  = Yaw Damper Mode (Off,On)
-- HDG = Heading Source (Off,HDG,NV1,NV2,GPS)
-- ALT = Vertical Mode (Off,CRZ,CLB,DSC)
-- ATH = Speed Mode (Off,SPD,FLC)
--
    local Wd0,Wd1,Wd2,Wd3,Wd4,Wd5,Wd6,Wd7 = 35,35,50,50,50,50,85,50  -- Width for each box
    local Width = Wd0 + Wd1 + Wd2 + Wd3 + Wd4 + Wd5 + Wd6 + Wd7 -- Total width
    local Color = "white"
    local Engine_Fire   = dataref_table("sim/cockpit2/annunciators/engine_fires") 
    local Total_Time = get("sim/time/total_flight_time_sec")
    local Nav_Stat = dataref_table("sim/cockpit2/autopilot/nav_status")
    local Hdg_Dial = get("sim/cockpit/autopilot/heading_mag")
    local Spd_Dial = get("sim/cockpit2/autopilot/airspeed_dial_kts_mach")
    local Is_Mach  = get("sim/cockpit2/autopilot/airspeed_is_mach")
    local Vvi_Dial = get("sim/cockpit2/autopilot/vvi_dial_fpm")
    local Alt_Dial = tonumber(get("sim/cockpit2/autopilot/altitude_dial_ft"))
    local L_Corner, R_Corner = "",""
    local L_Corner1,L_Corner2 = "",""
    local Pos = Posx
    local Second = get("sim/network/misc/network_time_sec")
    ----------------------------
    -- Alternate FD & AP mode --
    ----------------------------
    local Alternate_FD = 0
    -----------------------------------------------------
    -- Link Concorde by Colimata to standards Datarefs --
    -----------------------------------------------------
    if AIRCRAFT_FILENAME == "CONCORDE_FXP.acf" and XPLMFindDataRef("Colimata/CON_AP_sw_FD1_i") ~= nil then
        if get("Colimata/CON_AP_sw_FD1_i") > 0 or get("Colimata/CON_AP_sw_FD2_i") > 0 then Alternate_FD = 1 end
        if get("Colimata/CON_AP_sw_AP1_i") > 0 or get("Colimata/CON_AP_sw_AP2_i") > 0 then Alternate_FD = 2 end
        set("sim/cockpit2/autopilot/flight_director_mode",Alternate_FD)                     -- Autopilot Flight Director Mode
        set("sim/cockpit/autopilot/altitude",get("Colimata/CON_AP_sw_ALT_select_ft_i"))     -- Autopilot Altitude Select Dial
    end
    -- Concorde Ready for Supersonic Cruise if:
    -- 0.94 < Mach < 1, Altitude  >= 28000 ft, surface_texture_type = 1 (Water)
    local Altitude      = get("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
    local Type_Surface  = get("sim/flightmodel/ground/surface_texture_type")
    local Fpm           = get("sim/flightmodel/position/vh_ind_fpm")
    local Ready         = "Concorde is Ready For Supersonic Cruise"
    if Icao_Name == "CONC" and acf_mch > 0.94 and acf_mch < 1 and Altitude >= 28000 and Fpm >= 0 and Tick_Over > 5 then      
        Warning_Message(2,Ready)
    end


    --------------------
    -- Autopilot Mode --
    --------------------
    -- voir pour lire Dataref "laminar/B738/autopilot/pfd_fd_cmd"
    --
    local Autopilot = get("sim/cockpit/autopilot/autopilot_state")      -- Bitfield Status
    local AP_Stat = get("sim/cockpit/autopilot/autopilot_mode")       -- 0 = Off, 1 = FD, 2 = AP
    local State   = {"--","FD","AP"}
    --
    
    if AP_Stat > 0 then Color = "green" else Color = "white" end
    TitleBox(Posx, Wd0, State[AP_Stat + 1], Color)
    Pos = Pos + Wd0

    ---------------------
    -- Yaw Damper Mode --
    ---------------------

    local YD_mode = get("sim/cockpit2/switches/yaw_damper_on")
    local YD_Stat = "YD"
    if YD_mode > 0 then Color = "green" else Color = "white" end
    TitleBox(Pos, Wd1, YD_Stat, Color)
    Pos = Pos + Wd1

    ------------------
    -- Heading Mode --
    ------------------
    local Nav_Stat = dataref_table("sim/cockpit2/autopilot/nav_status")
    local HSI_Sel   = dataref_table("sim/cockpit/switches/HSI_selector")
    local HDG_Mode  = get("sim/cockpit2/autopilot/heading_mode")
    local HSI_Stat  = "-"
    local HDG_Stat  = "-"
    local HSI_arr   = {"Nav1","Nav2","GPS"}
    local Approach  = get("sim/cockpit2/autopilot/approach_status")
    --
    local Gps_Hdg   = string.format('%03.0f',get("sim/cockpit2/radios/indicators/gps_bearing_deg_mag"))
    local Gps_Nav   = get("sim/cockpit2/radios/indicators/gps_nav_id")
    local Gps_Dst   = string.format('%.1f',get("sim/cockpit2/radios/indicators/gps_dme_distance_nm"))
    local Gps_Time  = Duree(get("sim/cockpit2/radios/indicators/gps_dme_time_min")*60,0)
    local Nv1_Time  = Duree(get("sim/cockpit2/radios/indicators/nav1_dme_time_min")*60,0)
    local Nv2_Time  = Duree(get("sim/cockpit2/radios/indicators/nav2_dme_time_min")*60,0)
    --
--    local Nav_Hdg   = dataref_table("sim/cockpit2/radios/actuators/nav_course_deg_mag_pilot")
    local Nav_Hdg   = dataref_table("sim/cockpit2/radios/indicators/nav_bearing_deg_mag")
    local Nav_Dst   = dataref_table("sim/cockpit2/radios/indicators/nav_dme_distance_nm")
    local Nav1_Id   = get("sim/cockpit2/radios/indicators/nav1_dme_id")
    local Nav2_Id   = get("sim/cockpit2/radios/indicators/nav2_dme_id")
    local Nav1_Crs = get("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot")
    local Nav2_Crs = get("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot")
    --
    HSI_Stat = HSI_arr[HSI_Sel[0]+1]
    if Nav_Stat[0] >= 1 then HDG_Stat = HSI_Stat end
    --
    Color = "white"
    if HSI_Sel[0] == 0 and Nav_Dst[0] > 0 then HDG_Stat = "Nav1"; L_Corner = string.format('(1) %s %03.0f°/%03.0f° %.1f nm %s',Nav1_Id,Nav_Hdg[0],Nav1_Crs,Nav_Dst[0],Nv1_Time) end
    if HSI_Sel[0] == 1 and Nav_Dst[1] > 0 then HDG_Stat = "Nav2"; L_Corner = string.format('(2) %s %03.0f°/%03.0f° %.1f nm %s',Nav2_Id,Nav_Hdg[1],Nav2_Crs,Nav_Dst[1],Nv2_Time) end
    if HSI_Sel[0] == 2 and #Gps_Dst   > 0 then HDG_Stat = "GPS" ; L_Corner = string.format('%s %03.0f° %.1f nm %s',Gps_Nav,Gps_Hdg,Gps_Dst,Gps_Time) end
    if HDG_Mode == 1 then
        HDG_Stat = "HDG"
        L_Corner = string.format('Hdg %03.0f° ',Hdg_Dial)
        L_Corner1 = L_Corner .. string.format('(1) %s %03.0f° %.1f nm ',Nav1_Id,Nav_Hdg[0],Nav_Dst[0])
        L_Corner2 = L_Corner .. string.format('(2) %s %03.0f° %.1f nm' ,Nav2_Id,Nav_Hdg[1],Nav_Dst[1])
        if Nav_Dst[0] > 0 then L_Corner = L_Corner .. string.format('(1) %s %03.0f° %.1f nm ',Nav1_Id,Nav_Hdg[0],Nav_Dst[0]) end
        if Nav_Dst[1] > 0 then L_Corner = L_Corner .. string.format('(2) %s %03.0f° %.1f nm' ,Nav2_Id,Nav_Hdg[1],Nav_Dst[1]) end
        if Nav_Dst[0] > 0 and Nav_Dst[1] > 0 then
            if Second % 10 <= 5 then L_Corner = L_Corner1 else L_Corner = L_Corner2 end
        end
    end
    local Tod = get("sim/cockpit2/radios/indicators/fms_distance_to_tod_pilot")
    if bit.band(Autopilot,0x1000) > 0 then
        HDG_Stat = "FMC"
        L_Corner = string.format('%s %03.0f° %.1f nm %s',Gps_Nav,Gps_Hdg,Gps_Dst,Gps_Time)
    end
    if Tod > 0 then L_Corner = string.format('%s T/D %.0f nm',L_Corner,Tod) end
    if Approach == 1 then HDG_Stat,Color = "LOC","white"  end
    if Approach == 2 then HDG_Stat,Color = "LOC","green"  end
--    if bit.band(Autopilot,0x0100) > 0 then HDG_Stat,Color = "LOC","yellow" end -- HNAV Armed
--    if bit.band(Autopilot,0x0200) > 0 then HDG_Stat,Color = "LOC","green" end -- HNAV Engaged
    if bit.band(Autopilot,0x0800) > 0 then HDG_Stat,Color = "APR","green" end
    if bit.band(Autopilot,0x1000) > 0 then HDG_Stat,Color = "FMC","green" end -- FMS Engaged
    if bit.band(Autopilot,0x0002) > 0 then HDG_Stat,Color = "HDG","green" end -- Heading Hold
    
    -------------------
    -- Vertical Mode --
    -------------------
    local Vnav_Mode = ""
    local RW_Hdg = ""
    if Approach == 2 then
--        TitleBox(Pos, Wd2 + Wd3, "Approach", "green") ; Pos = Pos + Wd2 + Wd3
        TitleBox(Pos, Wd2, "APR", "green") ; Pos = Pos + Wd2
        if HSI_Sel[0] == 0     then RW_Hdg = string.format("%03.0f",Nav1_Crs)
        elseif HSI_Sel[0] == 1 then RW_Hdg = string.format("%03.0f",Nav2_Crs)
        elseif HSI_Sel[0] == 2 then RW_Hdg = string.format("%03.0f",Gps_Hdg)
        else
            RW_Hdg = "HSI=" .. HSI_Sel[0]
        end
        TitleBox(Pos, Wd3, RW_Hdg, "green") ; Pos = Pos + Wd3
    else
      if AP_Stat > 1 then Color = "green" end
      TitleBox(Pos, Wd2, HDG_Stat, Color) ; Pos = Pos + Wd2
      Color = "white"
    if bit.band(Autopilot, 0x0400) > 0 then Vnav_Mode = "G/S" ; Color = "yellow" end -- Glideslope Armed
    if bit.band(Autopilot, 0x0800) > 0 then Vnav_Mode = "G/S" ; Color = "green" end -- Glideslope Engaged
    ---------------------------------------------------------+------------
    -- Specials Datarefs for foreign aircrafts (not standards Datarefs) --
    ----------------------------------------------------------------------
    if Find_Dataref("XCrafts/ERJ_195/VNAV_stat") == 1 or 
      Find_Dataref("XCrafts/ERJ_175/VNAV_stat") == 1 then
      Vnav_Mode = "VNV"; Color = "green"
    end
    local TRS_Sel = {"T/O", "", "aT/O", "", "CON", "CLB", "CRZ" }
    if PLANE_ICAO == "E175" then
      if Find_Dataref("Tekton_FMS/TRS_selection") > 0 then
        Vnav_Mode = TRS_Sel[get("Tekton_FMS/TRS_selection")]
        Color = "cyan"
      end
    end
    --XPLMFindDataRef("Colimata/CON_AP_sw_FD1_i") ~= nil

    TitleBox(Pos, Wd3, Vnav_Mode, Color) ; Pos = Pos + Wd3
    end
    -------------------
    -- Altitude Mode --
    -------------------
    --    local R_Corner = ""
    local Vvi_Mode = get("sim/cockpit2/autopilot/vvi_status")
    local Altitude = tonumber(string.format('%.0f',get("sim/cockpit2/gauges/indicators/altitude_ft_pilot")/10)*10)
    local Alt_Mode = "---"
    local Warn_Flg
    --
    local SFC_Alt_Jet   = tonumber(string.format("%.0f",(get("sim/aircraft/overflow/SFC_alt_hi_JET") or 0)/0.3048))
    local SFC_Alt_Prp   = tonumber(string.format("%.0f",(get("sim/aircraft/overflow/SFC_alt_hi_PRP") or 0)/0.3048))
    --
    if Vvi_Mode == 2 then           -- VS Activated?
        if Vvi_Dial > 0 then        -- Climb Mode
            Alt_Mode = "CLB"
            if Alt_Dial < Altitude then Warn_Flg,Color = 1,"white" else Warn_Flg,Color = nil,"green" end
        elseif Vvi_Dial == 0 then   -- Null Vertical Speed
            Alt_Mode = "---"
            Warn_Flg,Color = nil,"white"
        elseif Vvi_Dial < 0 then    -- Descent Mode
            Alt_Mode = "DSC"
            if Alt_Dial > Altitude then Warn_Flg,Color = 1,"white" else Warn_Flg,Color = nil,"green" end
        end
    else
        Color = "white"
    end
    if Alt_Dial == SFC_Alt_Jet and SFC_Alt_Jet > 0 then
       Alt_Mode,Warn_Flg,Color = "CEIL",nil,"yellow"
    elseif Alt_Dial == SFC_Alt_Prp and SFC_Alt_Prp > 0 then
       Alt_Mode,Warn_Flg,Color = "SFC",nil,"yellow"
    end
    --
    if AP_Stat == 2 and Altitude == Alt_Dial then Alt_Mode,Color = "CRZ","green" end
    local Fmt = "Spd %0.f"
    local Vs_Info = Vvi_Dial ~= 0 and string.format("Vs %.1fk",Vvi_Dial/1000) or "-"
--    if Is_Mach > 0 then Fmt = "Mach %0.2f" end
--    R_Corner = string.format("FL%03.0f Vs %.1fk %s",Alt_Dial/100,Vvi_Dial/1000,Speed_Dial())
    R_Corner = string.format("FL%03.0f %s %s",Alt_Dial/100,Vs_Info,Speed_Dial())
    -- Altitude Mode --
    TitleBox(Pos,Wd4,Alt_Mode,Color,Warn_Flg)
    ----------------
    -- Speed Mode --
    ----------------
    -- Ath_Mode
    Color = "white"
    local ATH_Mode = "---"
    local ATH_Enabled = get("sim/cockpit2/autopilot/autothrottle_enabled")
    if bit.band(Autopilot, 0x0001) > 0 or ATH_Enabled > 0 then ATH_Mode = "ATH" end
    if bit.band(Autopilot, 0x0040) > 0 then ATH_Mode = "FLC" end
    if ATH_Mode == "FLC" then R_Corner = string.format('FL%03.0f - %s',Alt_Dial/100,Speed_Dial()) end
    if ATH_Mode == "SPD" then Color = "green" end
    if ATH_Mode == "FLC" and AP_Mode == 1 then Color = "white" else Color = "green" end


    if get("sim/cockpit2/autopilot/flight_director_mode") > 0 and get("sim/graphics/view/view_is_external") > 0  then
 --       Warning_Message(1,"Autopilot State: " .. string.format("%06X",Autopilot) .. " - " .. To_Bit(Autopilot))
    end
        -- Speed Mode --
        Pos = Pos + Wd4; TitleBox(Pos,Wd5,ATH_Mode,Color)
    if Second % 30 <= 10 then
        Pos = Pos + Wd5; TitleBox(Pos,Wd6,Duree(z_Time,2),"white")
        Pos = Pos + Wd6; TitleBox(Pos,Wd7,"UTC","white")
    elseif Second % 30 <= 20 then
        Pos = Pos + Wd5; TitleBox(Pos,Wd6,Duree(l_Time,2),"white")
        Pos = Pos + Wd6; TitleBox(Pos,Wd7,"LOC","white")
    else
        Pos = Pos + Wd5; TitleBox(Pos,Wd6,Duree(Temps_Vol,2),"white")
        Pos = Pos + Wd6; TitleBox(Pos,Wd7,"FLT","white")
    end

    --
    Display_Status_Type()
    
    local Rotor_Brake   = get("sim/cockpit2/switches/rotor_brake")
    local Rotor_Ratio   = get("sim/cockpit2/switches/rotor_brake_ratio")
    if Rotor_Brake > 0 and Rotor_Ratio > 0.2 then
        Warning_Message(2,string.format(" WARNING - Rotor Brake Activated (Ratio %.1f) ",Rotor_Ratio))
    end
    local Fire = ""
    local Stat = 0
    local ii
    for ii = 0, 7 do
        if Engine_Fire[ii]  == 1 then
            Stat = ii + 1
            Fire = Fire.." Engine Fire "..Stat
        end
    end
    Fire = "======="..Fire.." ======="
    if get("sim/cockpit2/annunciators/engine_fire") > 0 then                  
        Warning_Message(3,Fire)
    end
--]]--
    --
    --
    local Acceleration = get("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot")
    local Accel_Str = ""
    local Next_Airport = XPLMFindNavAid( nil, nil, LATITUDE, LONGITUDE, nil, xplm_Nav_Airport)
    local Airport_Code,Airport_Name,ias
    _, _, _, _, _, _,Airport_Code,Airport_Name = XPLMGetNavAidInfo(Next_Airport)
    if Acceleration > 0.05  then Accel_Str = "+"     end
    if Acceleration > 1.00  then Accel_Str = "++"    end
    if Acceleration > 2.00  then Accel_Str = "+++"   end
    if Acceleration > 4.00  then Accel_Str = "++++"  end
    if Acceleration > 8.00  then Accel_Str = "+++++" end
    if Acceleration < - 0.05 then Accel_Str = "-"     end
    if Acceleration < - 1.00 then Accel_Str = "--"    end
    if Acceleration < - 2.00 then Accel_Str = "---"   end
    if Acceleration < - 4.00 then Accel_Str = "----"  end
    if Acceleration < - 8.00 then Accel_Str = "-----" end

    if Is_Mach > 0 or acf_mch >= 0.9 then
        ias = string.format('%1.3f M %s',acf_mch,Accel_Str)
    else
        ias = string.format('%1.1f KT %s',acf_cas,Accel_Str)
    end
    --[[
    if acf_mch >= 0.7 then
        ias = string.format('%1.3f M %s',acf_mch,Accel_Str)
    else
        ias = string.format('%1.1f KT %s',acf_cas,Accel_Str)
    end
    --]]
    local acf_name = Icao_Name
--    if acf_flap > 0 then vstall = acf_vso else vstall = acf_vs end
    vstall = acf_flap > 0 and acf_vso or acf_vs
    local vitesse = ("%s<%s<IAS<%s<%s"):format(acf_vso, acf_vs, acf_vno, acf_vne) 
--    local vitesse = acf_vso .. "<" .. vstall .."<IAS<" .. acf_vno .. "<" .. acf_vne
    local Airport_Last = string.sub(Trajet,-4)
    local Info_Text
    local Info_Name
    --
    --
    --
    if Landed() == true and acf_cas < 10 then
      if Temps_Vol >= 30 and Airport_Last ~= Airport_Code and #Airport_Code>0 then Trajet = Trajet .." / "..Airport_Code end
      if Second % 10 <= 5 then
        Info_Text = ACF_Desc()
        Info_Name = vitesse
      else
        if Airport_From == Airport_Code then
          Info_Text = Airport_Code
        else
          Info_Text = Airport_From .. " to " .. Airport_Code
        end
        Info_Name = Airport_Name
      end
    else
      Info_Text = ACF_Desc() ; Info_Name = vitesse
      if acf_ias < vstall * 1.5 then Info_Name = string.format('%1.2f Vs (%i)',acf_cas/vstall,vstall) end
    end
    if measure_string(Info_Text) + measure_string(Info_Name) > Width then Info_Text = "("..Icao_Name..") "..ACF_Name() end
    ParamBox(Posx, Init_y, Width, 5, nil , L_Corner, Info_Text, R_Corner, Info_Name)
    -----------------------------------------------
    -- Flight Time (trigged by take off/landing) --
    -----------------------------------------------
    --local Line_2 = "Flight Time"
    --local Line_3 = Duree(Temps_Vol,1)
    local Line_2 = "Avg Speed"
    local Line_3 = Temps_Vol>0 and ("%.1f KT"):format(traveled*1.851851/Temps_Vol) or "--- KT"
    local Color = "white"
    local Taxi_Speed_Limit = 25
    local Vmca = math.ceil(vstall*1.3)
    --
    if Landed() == true and acf_gnd > 1 then
      if acf_cas < Taxi_Speed_Limit then
        Line_2 = "TAXI" ; Line_3 = string.format('<%.0f KT',Taxi_Speed_Limit) ; Color = "white" ; glColor4f(1,1,1,1)
      elseif acf_cas < vstall then
        if Acceleration > 0 then
          Line_2 = "Acceleration" ; Line_3 = "for Take OFF"
        else
          Line_2 = "Roll Out" ; Line_3 = "Landing"
        end
        Color = "yellow" ; glColor4f(1,1,1,1)
      elseif acf_cas < Vmca then
        Line_2 = "TAKE OFF AT" ; Line_3 = string.format('%.0f KT',Vmca) ; Color = "yellow" ; glColor4f(1,1,0,1)
      else
        Line_2 = "READY TO" ; Line_3 = "TAKE OFF" ; Color = "green" ; glColor4f(0,1,0,1)
      end
    else
      glColor4f(1,1,1,1)
    end
    ParamTxt(Posx - Width ,Init_y,2,Width,"L", Line_2, Color)
    ParamTxt(Posx - Width ,Init_y,3,Width,"L", Line_3, Color)
    offset = (Width - measure_string(ias,"Times_Roman_24"))/2
    draw_string_Times_Roman_24(Posx - Width + offset, Init_y + 17,ias)

    -----------------------------------------
    -- Traveled Distance (include taxiing) --
    -----------------------------------------
    ParamTxt(Posx - Width ,Init_y,2,Width,"R","Traveled","white")
    ParamTxt(Posx - Width ,Init_y,3,Width,"R",string.format('%.1f nm',traveled/1851.851),"white")
end
function Mdl_Fps()
    -----------------------------------------
    -- FPS en titre et Vitesses en dessous --
    -----------------------------------------
    local str,Fps,largeur = "","",80
    local cas,tas,gsp,mch,kmh,mph = 0,0,0,0,0,0
    local Framerate = 1/get("sim/time/framerate_period")
    local Framerate = E_Fps
    local Is_Mach  = get("sim/cockpit2/autopilot/airspeed_is_mach")

    if paused == 1 then
        Fps = "Paused"
    else
        Fps = string.format('%.0f Fps',Framerate)
    end
    local Low_Fps = 22
    local Min_Fps = 20
    if Framerate <= Min_Fps then
      TitleBox(Posx,largeur,Fps,nil,2,1,0,0)
    elseif Framerate <= Low_Fps then
      TitleBox(Posx,largeur,Fps,nil,2,1,0.4,0)
    else
      TitleBox(Posx,largeur,Fps)
    end
    local spd,sys -- 0 = mph, 1 = km/h
    sys = 1
    if sys == 0 then 
        spd,ln1 = string.format('%.1f',acf_gnd*2,23694),"MPH"
    else
        spd,ln1 = string.format('%6.1f',acf_gnd*3.6),"Km/h"
    end
    gsp,ln2 = string.format('%.1f',acf_gnd*1.94384),"GS"
    tas,ln3 = string.format('%.1f',acf_tas),"KTAS"

    if Is_Mach > 0 or acf_mch >= 0.9 then
        mch,ln4 = string.format('%.1f',acf_ias),"KIAS"
    else
        mch,ln4 = string.format('%.3f',acf_mch),"M"
    end
    --
    --
    --
    ParamBox(Posx,Init_y,largeur,1,"")
    local offset = 35
    draw_string(Posx - offset, Init_y + 38, ln1,"yellow")
    draw_string(Posx - offset, Init_y + 27, ln2,"yellow")
    draw_string(Posx - offset, Init_y + 16, ln3,"yellow")
    draw_string(Posx - offset, Init_y + 05, ln4,"yellow")
    --
    draw_string(Posx - offset - measure_string(spd) - 2, Init_y + 38, spd)
    draw_string(Posx - offset - measure_string(gsp) - 2, Init_y + 27, gsp)
    draw_string(Posx - offset - measure_string(tas) - 2, Init_y + 16, tas)
    draw_string(Posx - offset - measure_string(mch) - 2, Init_y + 05, mch)
end
function Mdl_Altitude()
    ------------------------
    -- Altitude MSL & AGL --
    ------------------------
    local Lim = 0.5
    local Lim_Fpm = 100
    local Fpm,Format,Warn
    local Width = 180
    local Aoa       = get("sim/flightmodel2/misc/AoA_angle_degrees")
    local Vpa       = get("sim/flightmodel/position/vpath")
    local Oat       = get("sim/cockpit2/temperature/outside_air_temp_degc")
    local Qnh       = tonumber(string.format("%.2f",get("sim/weather/barometer_sealevel_inhg")))
    local Baro      = tonumber(string.format("%.2f",get("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot")))
    local Altitude  = get("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
    local Alt_Dial = get("sim/cockpit2/autopilot/altitude_dial_ft")

    local Trans_Alt = 5000
    local Agl_Alt   = tonumber(string.format('%.2f',get("sim/flightmodel/position/y_agl")*3.28084))
    local inHg_2_hPa = 33.8653075
    --
    if Landed() == true then
        Vpa = "Vpa ----"
    else
        if Vpa < Lim and Vpa > -Lim then Vpa = "Vpa ----" else Vpa = string.format('Vpa %.1f°',Vpa) end 
    end
    if Aoa > Lim and Aoa > 0 then
        Aoa = string.format('Aoa %.1f°',Aoa)
    else
        Aoa = "Aoa ----"
    end 
    if Agl_Alt <= 100 then
      Fpm = acf_fpm < 0 and acf_fpm >= -100 and  ("%i fpm Butter"):format(acf_fpm) or ("%i fpm"):format(acf_fpm) 
    else
      if acf_fpm < Lim_Fpm and acf_fpm > -Lim_Fpm then
        Fpm = string.format('FL%03.0f',acf_msl/100)
      else
        Fpm = string.format('%.1fk fpm (FL%03.0f)',acf_fpm/1000,Alt_Dial/100)
      end
    end
    --
    if Landed() == true then Fpm = "Altitude" end
    --
    if Altitude < 1e1 then
        Format = string.format('%.2f Ft',Altitude)
    elseif Altitude < 1e2 then
        Format = string.format('%.1f Ft',Altitude)
    else
        Format = string.format('%.0f Ft',Altitude)
    end
    --
    TitleBox(Posx,Width,Fpm,"white",Warn)
    ParamBox(Posx,Init_y,Width,5,Format,Aoa,Vpa,string.format('Oat %.1f°C',Oat))
--[[    if Altitude < Trans_Alt and Qnh ~= 29.92 then
        set("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot",Qnh)
        ParamTxt(Posx - Width ,Init_y,2,Width,"R","Auto","yellow")
        ParamTxt(Posx - Width ,Init_y,3,Width,"R","QNH","yellow")
        ParamTxt(Posx - Width ,Init_y,4,Width,"R",string.format('Qnh %.2f',Qnh),"yellow")
    else
        set("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot",29.92)
        ParamTxt(Posx - Width ,Init_y,4,Width,"R","Qnh STD","yellow")
    end
--]]
    if Altitude < Trans_Alt and Baro ~= Qnh then
        ParamTxt(Posx - Width ,Init_y,2,Width,"L","QNH","yellow")
        ParamTxt(Posx - Width ,Init_y,3,Width,"L",string.format("%.2f",Qnh),"yellow")
        ParamTxt(Posx - Width ,Init_y,2,Width,"R","SET","yellow")
        ParamTxt(Posx - Width ,Init_y,3,Width,"R","QNH","yellow")
--        ParamTxt(Posx - Width ,Init_y,4,Width,"R",string.format('Qnh %.2f',Qnh),"yellow")
    end
    if os.clock() % 10 < 5 then
        ParamTxt(Posx - Width ,Init_y,4,Width,"R",string.format('%.2f inHg',Baro),"yellow")
    else
        ParamTxt(Posx - Width ,Init_y,4,Width,"R",string.format('%.0f hPa',Baro*inHg_2_hPa),"yellow")
    end
--    ParamTxt(Posx - Width ,Init_y,4,Width,"R",string.format('Qnh %.2f',Qnh),"yellow")
--]]
end
function All_Landed()
  local Gear = dataref_table("sim/flightmodel2/gear/on_ground")
  if Gear[0] + Gear[1] + Gear[2] > 2 then
    return true
  else
    return false
  end
end
function Ground_Speed()

end
function Mdl_Ground()
  -----------------------------------
  -- Ground Detector or Park Brake --
  -----------------------------------
  local Altitude_Ft = get("sim/flightmodel/position/y_agl")/0.3048
  local str, tit
  local largeur = 120
  local Color = "white"
  local Level = {"RTO","Off","Low","Med","High","Full"}
  local Brake_Ratio = "sim/cockpit2/controls/parking_brake_ratio"
  local Throttle = "sim/cockpit2/engine/actuators/throttle_ratio_all"
  local Threshold = 0.04
  local Auto_Brake = false
  local Theta = "sim/flightmodel/position/theta"
  local Pos_Q = "sim/flightmodel/position/Q"
  local warn
--  local Brake_L = "sim/cockpit2/controls/left_brake_ratio"
--  local Brake_R = "sim/cockpit2/controls/right_brake_ratio"
  local Brake_L = "sim/flightmodel/controls/l_brake_add"
  local Brake_R = "sim/flightmodel/controls/r_brake_add"
  local Spd_Lim = 100
  local Surface = get("sim/flightmodel/ground/surface_texture_type") or 0
--  logMsg(string.format("Surface: %.0f",Surface))
  if Surface > 1 then
    if Landed() == true and acf_gnd < Spd_Lim and AIRCRAFT_FILENAME ~= "autogyre.acf"  then
      if tonumber(get(Throttle)) >= Threshold then
        if get(Brake_Ratio) >= 0 then
          Auto_Brake = true
          set(Brake_Ratio,math.max(0, get(Brake_Ratio) - 0.01))
          set(Brake_L,math.max(0, get(Brake_L) - 0.01))
          set(Brake_R,math.max(0, get(Brake_R) - 0.01))
        end
      else
        --
        if get(Brake_Ratio) < 1 and Prop_Mode(0) == "Norm" and Prop_Mode(1) == "Norm" and Prop_Mode(2) == "Norm" and Prop_Mode(3) == "Norm" then
          Auto_Brake = true
          if XPLMFindDataRef("bp/tug_name") ~= nil then
            if get("bp/tug_name") == "" then
              Color = "green"
              set(Brake_Ratio,math.min(1, get(Brake_Ratio) + 0.01))
            else
              Color = "green"
            end
          else
            set(Brake_Ratio,math.min(1, get(Brake_Ratio) + 0.01))
            set(Brake_L,math.min(1, get(Brake_L) + 0.01))
            set(Brake_R,math.min(1, get(Brake_R) + 0.01))
          end
        end
        --
        --if get(Brake_L) > 0 then set(Brake_L,0) end
        --if get(Brake_R) > 0 then set(Brake_R,0) end
      end
    end
  end
  --[[
--  local Brake
  if tonumber(get(Throttle)) < Threshold and acf_gnd*1.94384 > 0 and Landed() == true and get(Pos_Q) > 0.1 and get(Theta) > 3  then
    Brake = math.min(Brake + 0.01 , 1)
    set(Brake_Ratio, 0)
    set("sim/cockpit2/controls/left_brake_ratio" , Brake)
    set("sim/cockpit2/controls/right_brake_ratio", Brake)
    Auto_Brake = true 
  else
    Brake = math.max(Brake - 0.05 , 0)
    set("sim/cockpit2/controls/left_brake_ratio" , Brake)
    set("sim/cockpit2/controls/right_brake_ratio", Brake)
    Auto_Brake = Brake >= 1 and true or false 
  end
  if tonumber(get(Throttle)) < Threshold and acf_gnd*1.94384 < 10 then
    if get(Brake_Ratio) < 1 then
      set(Brake_Ratio, get(Brake_Ratio) + 0.01)
    else
      set(Brake_Ratio, 1)
    end
    Auto_Brake = false
  end
  --]]
  --
  if Landed() == true then
    if get(Brake_Ratio) == 0 then
      str = "No Brake"
    elseif get(Brake_Ratio) < 1 then
      str = string.format('Brake %d%%',100*get(Brake_Ratio))
    else
      if acf_gnd < 1  then
        str = "Park Brake"
      else
        str = "Auto Brake"
      end
    end
  else
--        if acf_fpm < 50 and acf_fpm > -50 then str = string.format('FL%03.0f',acf_msl/100) else str = string.format('%.0f FPM',acf_fpm) end
    str = "Ground"
  end
    if Auto_Brake == true then
      str = ("Park %.0f%%"):format(get(Brake_Ratio) * 100)
--      str = "ABS Active"
    end
    TitleBox(Posx,largeur,str,Color)
    local Step = 1
    local Agl = ""
    tit = "Ground"
    --
    local Info_Sup,Info_Txt,Info_Inf
    local Force = ""
    if Landed() == true then
      str,tit = "Landed",""
      Agl = string.format('AGL: %.2f Ft',Altitude_Ft)
      if Total_Gear_force() > 0 then Force = string.format('Downforce %.1f',Total_Gear_force()/1000) end
      Info_Sup = Force
      Info_Txt = "Landed"
      Info_Inf = Agl
      --Info_Sup = ("Theta %.1f°"):format(get(Theta))
      --Info_Txt = ("Brk %.d%%"):format(get(Brake_Ratio)*100)
      --Info_Txt = ("Brk %.0f%%"):format(Brake*100)
      Info_Inf = get(Pos_Q) > 0.01 and ("Pos Q %.1f"):format(get(Pos_Q))  or "Pos Q Negative" 
      if AIRCRAFT_FILENAME == "autogyre.acf" then Info_Inf = "Autogyre" end

        if XPLMFindDataRef("bp/tug_name") ~= nil then
          if get("bp/tug_name") ~= ""  then
            Info_Txt = "Pushback"
            Played_Pushback = false
          else
            if Played_Pushback == false then play_sound(Snd_Pushback) end            
            Played_Pushback = true
          end
        end
    else
      if Altitude_Ft < 10 then
        Step = 1e-2
        Info_Txt = string.format('%.2f Ft',Altitude_Ft)
      elseif Altitude_Ft < 100 then
        Step = 1e-1
        Info_Txt = string.format('%.1f Ft',Altitude_Ft)
      elseif Altitude_Ft < 1000 then
        Step = 1
        Info_Txt = string.format('%.0f',Altitude_Ft/Step)*Step.." Ft"
      elseif Altitude_Ft < 5000 then
        Step = 10
        Info_Txt = string.format('%.0f',Altitude_Ft/Step)*Step.." Ft"
      elseif Altitude_Ft < 10000 then
        Step = 100
        Info_Txt = ">"..string.format('%.0f',Altitude_Ft/Step)*Step.." Ft"
      else
        Step = 1000
        Info_Txt = ">"..string.format('%.0f',Altitude_Ft).." Ft"
      end
      Info_Sup = "Radio Altimeter"
    end
    local Lh = ("L: %.0f%%"):format(get("sim/flightmodel/controls/l_brake_add")*100)
    local Rh = ("R: %.0f%%"):format(get("sim/flightmodel/controls/r_brake_add")*100)
    local Brake_Level = get("sim/cockpit2/switches/auto_brake_level")
    Info_Inf = Brake_Level ~= 1 and ("Auto-Brake %s"):format(Level[Brake_Level + 1])  or Info_Inf
    
    
--    ParamBox(Posx,Init_y,120,3,Info_Txt,Info_Sup,Info_Inf)
    ParamBox(Posx,Init_y,120,6,Info_Txt,Lh,Rh,Info_Inf)
end
function Landed()
--    local Status = get("sim/flightmodel/failures/onground_any")
  local Nb_Gear = 0
  for ii = 0,9 do

  end
  local Status = get("sim/flightmodel2/gear/on_ground",0) + get("sim/flightmodel2/gear/on_ground",1) + get("sim/flightmodel2/gear/on_ground",2)

  if Status > 2 then
        return true
    else
        return false
    end
end
function Total_Gear_force()
    local Gear = dataref_table("sim/flightmodel2/gear/tire_vertical_force_n_mtr")
    local Total = 0
    for ii = 0,9 do
        Total = Total + Gear[ii]
    end
    return Total
end
function Total_Grounded()
    local Gear_Grounded = dataref_table("sim/flightmodel2/gear/tire_vertical_force_n_mtr")
    local Total = 0
    
    for ii = 0,9 do
        if Gear_Grounded[ii] > 0 then
            Total = Total + 1
        end
    end
    return Total

end
function Mdl_Heading()
    ----------------------
    -- Affichage du cap --
    ----------------------
    local Hdg_Dial = get("sim/cockpit/autopilot/heading_mag")
    local Hdg_sel = "("..string.format('%03.0f',AP_Hdg_mag[0] % 360).."°)"
    local larg = 120
    local L_Hdg = (AP_Hdg_mag[0] + 270) % 360
    local R_Hdg = (AP_Hdg_mag[0] + 090) % 360
    local Infos, Half = "",""
    local Bank = math.abs(get("sim/flightmodel/position/true_phi"))

    if PPV_Hdg then
        Infos   = string.format('%03.0f° - %s - %03.0f°',L_Hdg,Hdg_sel,R_Hdg)
        Half    = string.format('Half Turn %03.0f°',(AP_Hdg_mag[0] + 180) % 360)
    else
        larg = 80
        Infos = Hdg_sel
        if Bank >= 5 then Half = string.format("Bank %.0f°",Bank) end
    end
    TitleBox(Posx,larg,"Hdg")
    ParamBox(Posx,Init_y,larg,3,string.format('%03.0f',acf_hdg % 360),Infos,Half)
end
function Mdl_Gear()
  ------------------
  -- Landing Gear --
  ------------------    
  local str,Info_Sup,larg = "","",100
  local Info_Inf = "-----"
  local Altitude_Agl_Ft = get("sim/flightmodel/position/y_agl")/0.3048
  local Color = "white"
  local Gear_Handle = tonumber(get("sim/cockpit2/controls/gear_handle_down"))
  local Vle = tonumber(string.format("%.0f",get("sim/aircraft/overflow/acf_Vle")))
  local Vne = tonumber(string.format("%.0f",get("sim/aircraft/view/acf_Vne")))
  local Vno = tonumber(string.format("%.0f",get("sim/aircraft/view/acf_Vno")))
  local Mobile_Gear = get("sim/aircraft/gear/acf_gear_retract")
  --  local acf_gear = dataref_table("sim/aircraft/parts/acf_gear_deploy")
  local T_Box,Warn = "Gear"
  if Mobile_Gear == 0 then Mobile_Gear = false else Mobile_Gear = true end
  if Vno <= 0 then Vno = Vne - 20 end
  if Vle > Vne then Vle = Vne end
  if Vle <= 0  then Vle = Vno end
  -----------------------
  -- Auto Gear Section --
  -----------------------
  local Auto_Gear_Flag = true
  local Safe_Altitude_FT = 1000
  local Safety_Spd_Gear = 1.0
  local Safety_Margin = 30
  local Throttle    = get("sim/cockpit2/engine/actuators/throttle_ratio_all")
  local Variometer  = get("sim/flightmodel/position/vh_ind_fpm")
  local Seaplane    = get("sim/aircraft2/metadata/is_seaplane")
  local Helico      = get("sim/aircraft2/metadata/is_helicopter")

  local Type_Surface = get("sim/flightmodel/ground/surface_texture_type") -- = 1 for water

  if string.find(".A319.A321", PLANE_ICAO) then
    Auto_Gear_Flag = false
  end
  --
  ---
  local Nbr = 1 -- Nombre du train de reference
  if PLANE_ICAO == "T6" then Nbr = 0 end
  vstall = acf_flap > 0 and acf_vso or acf_vs
  ---[[
  if Auto_Gear_Flag == true and Mobile_Gear == true then
    ----------------------------------------------------------------
    -- Auto Gear Down below Safe_Altitude_FT and IAS < Safety Vle --
    ----------------------------------------------------------------
    if acf_ias >= Safety_Spd_Gear * Vle and acf_ias < 1.5*vstall then
      Color = "orange"
      Info_Sup = string.format('(Vle %i)',Vle)
      Info_Inf = ("Locked at %i"):format(Safety_Spd_Gear * Vle)
      if acf_gear[Nbr] < 1 and Altitude_Agl_Ft <= Safe_Altitude_FT then
        -- Color   = "white" ; T_Box   = "<".. Safe_Altitude_FT .. " Ft" ; Warn    = 1
        Color   = "white" ; T_Box   = "> Vle" ; Warn    = 0
      end
    else
      Color = "green"
      Info_Sup = "(Available)"
      Info_Inf = string.format("(Vle %i)",Vle)
      if acf_gear[Nbr] < 1
        and Altitude_Agl_Ft <= Safe_Altitude_FT
        and acf_fpm < -300 and Throttle < 0.5 then
        if Seaplane > 0 and Type_Surface == 1 then
          Color   = "white" ; T_Box   = "Ditching" ; Warn    = 0
        else
          Color   = "white" ; T_Box   = "Auto" ; Warn    = 0
          --command_once("sim/flight_controls/landing_gear_down")
        end
      end
    end
    --------------------------------------------------------
    -- Auto Gear Up if Safety Vle reached (for security)  --
    --------------------------------------------------------
    if acf_gear[Nbr] > 0 then
      if acf_ias >= Safety_Spd_Gear or Altitude_Agl_Ft > Safe_Altitude_FT then
        Color   = "white"
        --T_Box   = "Auto"
        Warn    = 0
        --Info_Inf = "Gear Up..."
        --command_once("sim/flight_controls/landing_gear_up")
        --command_once("sim/flight_controls/pump_gear")
      end
    end
    ----------------------------------
    -- Auto Gear Up for Helicopter  --
    ----------------------------------
    if acf_gear[Nbr] > 0 and Helico > 0 and acf_ias > 60 and  Altitude_Agl_Ft > Safe_Altitude_FT then
      Color   = "white"
      T_Box   = "Safety"
      Warn    = 0
      Info_Inf = "Helicopter run..."
      --command_once("sim/flight_controls/landing_gear_up")
    end
  end
  --]]
  if Mobile_Gear == true then
    if acf_gear[Nbr] == 0 then
      str = "----"
    elseif acf_gear[Nbr] < 1 then
      str = string.format('%d%%',100*acf_gear[Nbr])
    else
      str = "Down"
    end
  else
      str = "Fixed"
  end
    ---
    ---
    ---
    local G_Title = "G-Load"
    local Last_Fpm = tonumber(get("sim/flightmodel/position/vh_ind_fpm"))
    local Txt,Lh,Ld,Rh,Rd
    local Fpm,G_Force,Spd,Aoa

    if Landed() == true then
        if Land_Flg == 0  then
            Land_Aoa = tonumber(string.format('%.1f',get("sim/flightmodel2/misc/AoA_angle_degrees")))
            Land_Spd = tonumber(string.format('%.0f',get("sim/flightmodel/position/groundspeed")*1.94384))
            --Land_Fpm = tonumber(string.format('%.0f',get("sim/flightmodel/position/vh_ind_fpm")))
            Last_Gforce = string.format('%.2f',math.max(Last_Gforce,get("sim/flightmodel/forces/g_nrml")))
            Land_Fpm = math.min(Land_Fpm,tonumber(string.format('%.0f',get("sim/flightmodel/position/vh_ind_fpm"))))
            Land_Flg = 1
        end
--        Land_Spd = string.format('%.0f',math.max(acf_gnd*1.94384,Land_Spd))
--        G_Title = "G-Max"
    else
        if get("sim/flightmodel/position/y_agl") > 5 then
            Land_Flg = 0
            Land_Fpm = 0
            Land_Spd = 0
            Land_Aoa = 0
            Last_Gforce = 1
        end
    end

    if Land_Fpm == 0 then Fpm = nil else Fpm = Land_Fpm .." Fpm" end
    if Land_Spd == 0 then Spd = nil else Spd = Land_Spd .." kt" end
    if Land_Aoa <= 0 then Aoa = nil else Aoa = Land_Aoa .."°" end
    if tonumber(Last_Gforce) == 1 then G_Force = nil else G_Force = Last_Gforce.. " G" end
    --
    --
    --

    if Land_Flg == 1 then
--        if get("sim/flightmodel/failures/onground_any") == 1 and acf_gnd > 10 then T_Box = "On Ground" end
        local Total = Total_Grounded()
        if Total == 0 then
            T_Box = "Gear"
        elseif Total == 1 then
            T_Box = "Gear (1)"
        else
            T_Box = string.format('Gear (%i)',Total)
        end
        local vstall
        if acf_flap > 0 then vstall = acf_vso else vstall = acf_vs end
        if get("sim/flightmodel/failures/onground_all") == 1 and acf_cas < vstall then T_Box,Warn = "Landed",0 end
        TitleBox(Posx,larg,T_Box,Color,Warn)
        if get("sim/time/total_flight_time_sec") < 10 then
            Fpm,Spd,Aoa,G_Force = nil,nil,nil,nil
        end
        if Fpm and Spd and G_Force then
            ParamBox(Posx,Init_y,larg,5,str,Fpm,Aoa,Spd,G_Force)
        else
            ParamBox(Posx,Init_y,larg,3,str,string.format('Gear (%i)',Total_Grounded()),string.format("(Vle %s)",Vle))
        end
    else
        Last_Gforce = get("sim/flightmodel/forces/g_nrml")
        if Last_Gforce >= 2 then
            TitleBox(Posx,larg,"G-Load","yellow",1)
        else
            TitleBox(Posx,larg,T_Box,Color,Warn)
        end
        ParamBox(Posx,Init_y,larg,3, str, Info_Sup, Info_Inf)
    end
end
function Mdl_Flaps()
  -------------------------------------
  -- Affichage des Flaps et Spoilers --
  -------------------------------------
  local Helico      = get("sim/aircraft2/metadata/is_helicopter")
  local Disp_Flaps  = true
  local Icao        = PLANE_ICAO
  local Width       = 100
  local Safe_Altitude_FT  = 10000
  local Safety_Spd_Flap   = 0.99
  local Altitude_Agl_Ft   = get("sim/flightmodel/position/y_agl")/0.3048

  local Flap_Ratio  = get("sim/cockpit2/controls/flap_ratio")
  local Flap_Handle = get("sim/flightmodel2/controls/flap1_deploy_ratio")
  local Flap_Detent = get("sim/aircraft/controls/acf_flap_detents")
  local hdl_flap    = get("sim/flightmodel2/controls/flap_handle_deploy_ratio")
  local Flap_Step   = ("%.0f"):format(Flap_Detent*Flap_Ratio)
  if #Icao < 1 then Icao ="Icao" end
  if string.find(".CONC.VELO", Icao) then Disp_Flaps = false end
  if Helico == 1 then Disp_Flaps = false end

  local arc1,pos,arc2,spl,spl2
  local Color
  local Flaps = "Flaps"
  local Warn
  local Info_Sup, Info_Text, Info_Inf


  if #Flap>1 then
    if Flap_Detent > #Flap then
      Flap_Step = Flap_Detent/#Flap
    else
      Flap_Step = math.min(math.max(Flap_Step or 1,1),Flap_Detent)
    end
  else
    Flap_Step = 1
    Flap[1]= acf_vfe
  end
  --logMsg("Icao_Name: "..Icao_Name.." - Flap_Step = "..Flap_Step.." - Flap_Detent = "..Flap_Detent.." - [Flap] = "..Flap[Flap_Step])

  if acf_ias >= Flap[Flap_Step] * Safety_Spd_Flap then
    Color = "orange"
    Info_Sup = string.format('(Vfe %i)',acf_vfe)
    --Info_Inf = ("Locked at %i"):format(Safety_Spd_Flap * acf_vfe)
    Info_Inf = string.format('(Limit %i)',Flap[Flap_Detent])
  else
    Color = "white"
    Info_Sup = "(Available)"
    if os.clock() % 10 > 5 then
      --Info_Inf = string.format('(Vfe %i)',acf_vfe)
      Info_Inf = string.format('(Vfe %i)',Flap[Flap_Step])
    else
      --Info_Inf = ("Locked at %i"):format(Safety_Spd_Flap * acf_vfe)
      Info_Inf = ("(Limit %i)"):format(Flap[Flap_Detent])
    end
  end
  ------------------
  -- Flaps Status --
  ------------------
  if hdl_flap == 0 then
    Info_Text = "----"
  elseif hdl_flap >= 0.99 then
    Color = "green"
    Info_Text = "Full"
  else
    Color = "green"
    Info_Text = string.format('%4.1f%%',hdl_flap*100)
    Flaps = string.format("Flap %.0f/%d",Flap_Detent*Flap_Ratio,Flap_Detent)
  end
  ------------------------
  -- Auto Flaps Section --
  ------------------------
  if Flap_Handle > 0 then
    Info_Sup = ("Angle %i°"):format(angle1[0]) 
    if acf_ias >= Flap[Flap_Step] *  Safety_Spd_Flap then -- or Altitude_Agl_Ft > Safe_Altitude_FT then
      Flaps = "AutoFlap" ; Color = "white" ; Warn = 1
      if Play_AutoFlap == false then
        play_sound(Snd_AutoFlap)
        Play_AutoFlap = true
      end
      command_once("sim/flight_controls/flaps_up")
      command_once("sim/flight_controls/speed_brakes_up_one")
    end
  else
    Play_AutoFlap = false
  end
  ---------------------------
  -- Spoilers or Airbrakes --
  ---------------------------
  if spl_1 < 0 then
    Info_Inf = "SPL Armed"
  elseif spl_1 <= 0.1 then
    if hdl_flap > 0 then
      if os.clock() % 10 > 5 then
        --Info_Inf = string.format('(Vfe %i)',acf_vfe)
        Info_Inf = ("(Vfe %i)"):format(Flap[Flap_Step])
      else
        --Info_Inf = ("Locked at %i"):format(Safety_Spd_Flap * acf_vfe)
        Info_Inf = ("(Limit %i)"):format(Flap[Flap_Detent])
      end
    end
  else
    if spl_3 > 0 then
      Info_Inf = string.format('SPL %.0f°',spl_3)
      if spl_4 > 0 then Info_Inf = Info_Inf .. string.format('/%.0f°',spl_4) end
    else
      Info_Inf = string.format('SPL %.0f%%',100*spl_2)
    end
  end
  if Disp_Flaps == true then
    TitleBox(Posx, Width, Flaps, Color, Warn)
    ParamBox(Posx, Init_y, Width, 3, Info_Text, Info_Sup, Info_Inf)
  end
end
function Mdl_Moteurs()
    -----------------------
    -- Parametres Moteur --
    -----------------------
    local largeur = 220
    local nb = 0
    local rpm,pwr,trq
    local ln1,ln2,ln3,ln4,ln5
    local mode
    local Min_prp       = get("sim/aircraft/controls/acf_RSC_mingov_prp")
    local Max_prp       = get("sim/aircraft/controls/acf_RSC_redline_prp")
    local Helicopter    = get("sim/aircraft2/metadata/is_helicopter")
    local Engine_Fire   = dataref_table("sim/cockpit2/annunciators/engine_fires")
    local Engine_Ext    = dataref_table("sim/cockpit2/engine/actuators/fire_extinguisher_on")
    local Angle         = dataref_table("sim/cockpit2/engine/actuators/prop_angle_degrees")
    local Thrust    = dataref_table("sim/cockpit2/engine/indicators/thrust_n")

    if Icao_Name=="500E" then
      Helicopter = 1
      eng_type = 2
    end
    local RPM
    local Thr,Thr_L,Thr_R = "","Thr "
    local MXT
    local PRP
    local OIL
    local PSI
    local PWR
    local EGT
    local ITT
    local Title
    local i
    for ii = 0,9 do
--        if get("sim/aircraft/prop/acf_des_rpm_prp",ii) > 0 then nb = nb + 1 end
      if get("sim/aircraft/prop/acf_en_type",ii) > 0 then
        nb = nb + 1
      end
    end
    nb = math.max(1,nb) -- 1 moteur par defaut

    --
    if string.find("S95.h500.GAZL.B407.B206R.DC3.G2CA.500E.P06T",PLANE_ICAO) then nb = 2 end
    if AIRCRAFT_FILENAME =="autogyre.acf" then nb = 2 end
    if AIRCRAFT_FILENAME =="lama.acf" then nb = 2 end
    if AIRCRAFT_FILENAME =="Bombardier_Cl_300.acf" then nb = 2 end

    for i = 0,nb-1 do
--        if Helicopter == 1 and i < 2 then nb = 2 end
        rpm,pwr,trq = string.format('%.0f',acf_rpm[i]/10)*10,acf_pwr[i],0
        mode = ""
        if      acf_propmode[i] == 0 then mode = ".F"
        elseif  acf_propmode[i] == 2 then mode = ".B"
        elseif  acf_propmode[i] == 3 then mode = ".R"
        end
        if acf_rpm[i] < 20 then rpm  = 0 end
        if acf_pwr[i] < 0 then pwr  = 0 end

        local Second = get("sim/network/misc/network_time_sec")

        RPM = string.format('%.0f Rpm%s',rpm,mode)
        Thr = string.format('Thro %.0f%%',100*acf_thr[i])
        MXT = string.format('Mixt %.0f%%',100*acf_mix[i])
        PRP = string.format('Prop %.0f',9.5493*acf_prop[i])
        OILT = string.format('%4.1f',acf_Oil_Temp[i])
        PSI = string.format('%4.1f',acf_Oil_Press[i])
        PWR = string.format('PWR %07.1f HP (%03.1f%%)',pwr/745.7,100*pwr/acf_pwr_max)
        EGT = string.format('EGT %d°C',acf_egt[i])
        ITT = string.format('ITT %d°C',acf_itt[i])
        --
        local COWL = string.format('%.0f%%',100*acf_Cowl[i])
        Thr_L,Thr_R = "Thro ",string.format('%.0f%%',100*acf_thr[i])
        local MXT_L,MXT_R
        local PRP_L,PRP_R = "Prop ",string.format('%.0f%%',100*(acf_prop[i]-Min_prp)/(Max_prp-Min_prp))
--        local PRP_L,PRP_R = "Prop ",string.format('%.0f',9.5493*acf_prop[i])
        if Second %4 >= 2 then
            PRP_L = "Angle"
            PRP_R = ("%.1f°"):format(Angle[i])
        end
        --------------------------
        -- Generator (Amperage) --
        --------------------------
        local GEN = string.format('Gen %.1f A',acf_gen[i])
        local Gen_Stat          = dataref_table("sim/cockpit2/electrical/generator_on")
        local Battery_Charge    = dataref_table("sim/cockpit/electrical/battery_charge_watt_hr")
        local Battery_Amperage  = dataref_table("sim/cockpit2/electrical/battery_amps")
        local Battery_Voltage   = dataref_table("sim/cockpit2/electrical/battery_voltage_actual_volts")

        local Batt_C = "watt"
        local Batt_A = "amp"
        local Batt_V = "volt"
        local GEN_L,GEN_R = "Gen ", string.format('%.1fA',acf_gen[i])
        if acf_gen[i] <= 0 then
            if Gen_Stat[i] > 0 then
                GEN,GEN_R = "On","On"
            else
                Batt_C = ("Batt %sw"):format(Auto_Float(Battery_Charge[i]))
                Batt_A = ("Batt %.1f a"):format(Battery_Amperage[i])
                Batt_V = ("Batt %.1f v"):format(Battery_Voltage[i])
                GEN_R = "Off"
                if Second % 12 <= 3 then
                    GEN = Batt_C
                elseif Second % 12 <= 6 then
                    GEN = Batt_A
                elseif Second % 12 <= 9 then
                    GEN = Batt_V
                else
                    GEN = "Gen Off"
                end
            end
        elseif acf_gen[i] < 10 then
            GEN = string.format('%.1f A',acf_gen[i])
            GEN_R = GEN
        else
            GEN = string.format('Gen %.0f A',acf_gen[i])
            GEN_R = string.format('%.0f A',acf_gen[i])
        end
        --
        local PWR_L,PWR_R = "",""
        --
        if pwr > 1000 then
            PWR_L,PWR_R = string.format('PWR %04.1f HP',math.abs(pwr/745.7)),string.format('%03.1f%%',math.abs(100*pwr)/acf_pwr_max) 
        end
        
        --local PRP_L,PRP_R = "Prop ",string.format('%.0f',9.5493*acf_prop[i])

        if acf_thr[i]  == 0 then Thr_R = "----" else Thr_R = acf_thr[i] < 0.999 and string.format('%.1f%%',100*acf_thr[i]) or "Full" end
        -- Prop, RPM format --
--        if acf_prop[i] == 0 then PRP_R = "-----" else PRP_R = string.format('%.0f',9.5493*acf_prop[i]) end
--        if acf_prop[i] == 0 then PRP_R = "-----" else PRP_R = string.format('%.0f',9.5493*acf_prop[i]) end
        -- Prop, % format --
--        if acf_prop[i] == 0 then PRP_R = "-----" else PRP_R = string.format('%.0f%%',100*(acf_prop[i]-Min_prp)/(Max_prp-Min_prp)) end
        if acf_mix[i]  == 0 then MXT_R = "-----" else MXT_R = string.format('%.0f%%',100*acf_mix[i]) end
        local Joystick = dataref_table("sim/joystick/joy_mapped_axis_value")
        if Helicopter == 1 then
            MXT_L,MXT_R = "Mixt ",string.format('%.0f%%',100*acf_mix[i+2])
            PRP_L = "Coll"
            if Joystick[5] == 1 then PRP_R = "----" else PRP_R = string.format('%.0f%%',100*(1-Joystick[5])) end
        else
            MXT_L,MXT_R = "Mxt ",string.format('%.0f%%',100*acf_mix[i])
        end


        if eng_type == 0 or eng_type == 1 then
            -----------------------------
            -- Carburetor or Injection --
            -----------------------------
            largeur = 70
            Title = string.format('%s %d',type_engine,i+1)
            TitleBox(Posx,largeur,"Cmd")
            ParamBox(Posx,Init_y,largeur,8,Thr_L,PRP_L,MXT_L,"Angle",Thr_R,PRP_R,MXT_R,("%i°"):format(Angle[i]))
            if AIRCRAFT_FILENAME =="autogyre.acf" and i < 2 then
                local Rotor = {"Propeller","Main Rotor"}
                Title = string.format('%s',Rotor[i+1])
            end

            largeur = 155
            TitleBox(Posx,largeur,Title)
            ParamBox(Posx,Init_y,largeur,5,RPM,PWR_L,EGT,PWR_R,GEN_L..GEN_R)
        elseif eng_type == 2 then
            ----------------------------------
            -- Turboprop or Turbofan Engine --
            ----------------------------------
            --[[   Topology
            +------------------------+
            |ln2                  ln4|
            |          LN1           |
            |ln3                  ln5|
            +------------------------+
          --]]

            local Rotor = {"Main Rotor","Tail Rotor"}
            local larg1,larg2 = 70,150
            local mode = ""
            local acf_prop  = dataref_table("sim/cockpit2/engine/indicators/prop_speed_rpm")
            local Max_Prop  = dataref_table("sim/cockpit2/engine/actuators/prop_rotation_speed_rad_sec")
            local Torque    = dataref_table("sim/flightmodel/engine/ENGN_TRQ")
            local Max_Trq   = get("sim/aircraft/controls/acf_trq_max_eng")
            local THRUST = "THS ----"
            if Thrust[i] < -1 or Thrust[i] > 1 then
                THRUST = ("THS %sN"):format(Auto_Float(Thrust[i]))
            end
            local TRQ = ("TRQ %.0f%%"):format(100*Torque[i]/Max_Trq)
            local N1 = "N1"
            if Helicopter > 0 and i < 2 then
                Title = acf_N1[i] >= 1e-1 and string.format('%s (N1 %.1f%%)',Rotor[i+1],acf_N1[i]) or string.format('%s (N1)',Rotor[i+1])
--[[
                if acf_N1[i] >= 1e-1 then 
                    Title = string.format('%s (N1 %.1f%%)',Rotor[i+1],acf_N1[i])
                else
                    Title = string.format('%s (N1)',Rotor[i+1])
                end
--]]
            else
                if acf_N1[i] >= 1e-1 then
                    Title = string.format('%s %d (N1 %.1f%%)',type_engine,i+1,acf_N1[i])
                else
                    Title = string.format('%s %d (N1)',type_engine,i+1)
                end
            end
            if Engine_Ext[i] > 0 then Title,Warn = "=== Extinguisher " .. i+1 .. " ===", 1 end  
            if Engine_Fire[i] > 0 then Title,Warn = "=== Engine Fire " .. i+1 .. " ===", 1 end

            TitleBox(Posx,larg1 + larg2,Title,"white",Warn)
            ParamBox(Posx,Init_y,larg1,8,Thr_L,PRP_L,MXT_L,GEN_L,Thr_R,PRP_R,MXT_R,GEN_R)
            Warn = 0
            --
            ln1 = string.format('%s %d',type_engine,i+1)
--            TitleBox(Posx,150,ln1)
            if      acf_propmode[i] == 0 then mode = ".F"
            elseif  acf_propmode[i] == 2 then mode = ".B"
            elseif  acf_propmode[i] == 3 then mode = ".R"
            end
            ln1 = string.format('%s%s',PRP_R,mode)
            ln1 = acf_prop[i] > 0 and string.format('%.1f%%',(100*acf_prop[i])/(Max_Prop[i]*9.54929658551369)) or "----"


            ln2 = string.format('Thr %3.0f%% - Pwr %6.1f HP',100*acf_thr[i],pwr/745.7)
            if acf_N1[i] <= 1e-2 then
                ln3 = string.format('Mxt %3.0f%% - ITT %4.0f',100*acf_mix[i],acf_itt[i])
            else
                if acf_trq[i] <=0 then trq = 0 else trq = 0.738*acf_trq[i] end 
                ln3 = string.format('Trq %3.0f FTLB - ITT %4.0f',trq,acf_itt[i])
            end
            ParamBox(Posx,Init_y,larg2,5,ln1,THRUST,EGT,TRQ,ITT)
            local Rotation = tonumber(acf_prop[i])
            local Rpm = "" -- Rotation < 100 and string.format("%.2f",Rotation) or string.format("%.0f",Rotation)
            if Rotation <= 0 then
                Rpm = "---"
            elseif Rotation < 10 then
                Rpm = string.format("%.2f",Rotation)
            elseif Rotation < 100 then
                Rpm = string.format("%.1f",Rotation)
            else
                Rpm = string.format("%.0f",Rotation)
            end
            ParamTxt(Posx - larg2 ,Init_y,2,larg2,"R","RPM","white")
            ParamTxt(Posx - larg2 ,Init_y,3,larg2,"R",Rpm,"white")
            --
            if not rawequal(acf_propmode[i],1) then
                ParamTxt(Posx - larg2 ,Init_y,2,larg2,"L",string.upper(Prop_Mode(i)),"white")
                ParamTxt(Posx - larg2 ,Init_y,3,larg2,"L","Mode","white")
            end
        else
            --------------------------
            --- Jet Low & Jet High ---
            --------------------------
          --[[   Topology
            +------------------------+
            |ln2                  ln4|
            |          LN1           |
            |ln3                  ln5|
            +------------------------+
          --]]
            ln1,ln2,ln3,ln4,ln5 = "Idle","----","----","ln_4","ln_5"
            local mode = ""
            if acf_propmode[i] == 3 then mode = ".Rev" end
--            local Aft_On = get("sim/flightmodel2/engines/afterburner_on",i)
            local Aft_Ratio = get("sim/flightmodel2/engines/afterburner_ratio",i)
            local title = string.format('%s %d',type_engine,i+1)
            local Thr,stg = "",""
            local THRUST = "Ths ----"
            if Thrust[i] < -1 or Thrust[i] > 1 then
                THRUST = ("Ths %.1fkN"):format(Thrust[i]/1000)
            end

            largeur = measure_string(title,"Helvetica_18") + 10
            if acf_thr[i] > 0 then
                if Aft_Ratio > 0 then
                    ln1 = string.format('%3.0f%% Aft',100*Aft_Ratio)
                else
                    ln1 = string.format('%3.0f%%',100*acf_thr[i])
                end
            end
            ln1 = ln1..mode
            
            if acf_N1[i] > 1e-1 then
                ln2 = string.format('N1 %.1f%%',acf_N1[i])
            else
                ln1 = "----"
            end
            if acf_N2[i] > 1e-1 then ln3 = string.format('N2 %.1f%%',acf_N2[i]) end
            if acf_egt[i] > 30 then
                largeur = 140
                ln4     = string.format('Egt %.0f°C',acf_egt[i])
            end
            if acf_gen[i] >= 0 then ln5,largeur = GEN,140 end
            TitleBox(Posx,largeur,title)
            ParamBox(Posx,Init_y,largeur,5,ln1,ln2,ln3,THRUST,ln5)
        end
    end
end
function Prop_Mode(ii)
    local mode  = dataref_table("sim/flightmodel/engine/ENGN_propmode")
    if      mode[ii] == 0 then return "Feat"
    elseif  mode[ii] == 1 then return "Norm"
    elseif  mode[ii] == 2 then return "Beta"
    elseif  mode[ii] == 3 then return "Rev"
    else return "Error"
    end
end
function Mdl_Tank()
    -------------------------------
    -- Reservoir(s) de carburant --
    -------------------------------
    local ln = {"","","","","","","","",""}
    local largeur = 90
    if acf_fuel_tot > acf_fuel_init then set("sim/cockpit2/fuel/fuel_totalizer_init_kg",acf_fuel_tot) end 
    local Val,Init,Actu
    Init = string.format('Init %i %s',Conversion_Fuel(acf_fuel_init,"kg",System_Fuel),System_Fuel)
    Actu = string.format('Actu %i %s',Conversion_Fuel(acf_fuel_tot,"kg",System_Fuel),System_Fuel)
    local ii
    for ii = 0,acf_num_tanks-1 do
        Val = Conversion_Fuel(acf_fuel_qty[ii],"kg",System_Fuel)
        if Val == 0 then
            ln[ii] = string.format('%d: %s',ii+1,"Empty")
        else
            ln[ii] = string.format('%d: %08.2f %s',ii+1,Val,System_Fuel)
        end
    end
    local title = ""
    if ln[8] ~= "" then
        title = "Tank 9: "..ln[8]
    else
        title = string.format('Tank %i-%i',1, acf_num_tanks)
    end
    if acf_num_tanks <= 4 then
        TitleBox(Posx,largeur,title)
        ParamBox(Posx,Init_y,largeur,4,ln[0],ln[1],ln[2],ln[3])
    else
        TitleBox(Posx,largeur*2,title)
        ParamBox(Posx,Init_y,largeur,4,ln[0],ln[1],ln[2],ln[3])
        ParamBox(Posx,Init_y,largeur,4,ln[4],ln[5],ln[6],ln[7])
    end
end
function Conversion_Fuel(value,src,dst)
    ---------------------------
    -- Conversion Fuel Unite --
    ---------------------------
    -- value = valeur a convertir
    -- unite source ("kg,lb,gal")
    -- return valeur,unité
    local Unit = "err"
    if src == "kg" and dst == "kg"  then return tonumber(string.format('%f',value))  end
    if src == "kg" and dst == "lb"  then return tonumber(string.format('%f',value*2.205)) end 
    if src == "kg" and dst == "gal" then return tonumber(string.format('%f',value/10.65019))  end
    return 0
end
function Mdl_Fuel()
    -------------------------------------------------------------------------
    -- Gestion du Fuel (% restant, Endurance, Range, Burned, Qty restante) --
    -------------------------------------------------------------------------
    local largeur = 120
    if acf_fuel_tot > acf_fuel_init then set("sim/cockpit2/fuel/fuel_totalizer_init_kg",acf_fuel_tot) end 
--    TitleBox(Posx,largeur,string.format('Fuel %1.1f%%',100*acf_fuel_tot/acf_fuel_max))
-- string.format('GW %s',Display_kg_t(acf_actual_weight))
    TitleBox(Posx,largeur,string.format('GW %s',Display_kg_t(acf_actual_weight)))
    ParamBox(Posx,Init_y,largeur,4,"Endur","Range","Used","Remain")
    --
    local endur,range,burned,remain = "","","",""
    local hh,mm = math.modf(acf_fuel_tot/(Total_Fuel_Flow()*3600))
    --
    if Total_Fuel_Flow() > 1e-3 then
        endur = string.format('%dh%02d',hh,mm*60)
        range = string.format('%.0f nm',(hh + mm) * acf_gnd*1.94384)
    end
    if acf_fuel_burn < 1000 then burned = string.format('%6.2f kg',acf_fuel_burn) else burned = string.format('%6.2f t',acf_fuel_burn/1000) end
    if acf_fuel_tot  < 1000 then remain = string.format('%6.2f kg',acf_fuel_tot)  else remain = string.format('%6.2f t',acf_fuel_tot/1000) end
    --
    draw_string(Posx - measure_string(endur)  - 3, Init_y + 38, endur, "yellow")
    draw_string(Posx - measure_string(range)  - 3, Init_y + 27, range, "yellow")
    draw_string(Posx - measure_string(burned) - 3, Init_y + 16, burned,"yellow")
    draw_string(Posx - measure_string(remain) - 3, Init_y + 05, remain,"yellow")
    
    --
    -- TitleBox
    --
    local last = {0,0,0,0}
    local i,larg = 0,20
    local ratio
    for i = 0,acf_num_tanks-1 do
        tr,tg,tb = 0,0.5,0
        TitleBox(Posx,larg,string.format('%i',i+1))
        tr,tg,tb = 1,1,1
        local Max_Tot = string.format('%f',acf_fuel_max)
        local Qty_Max = string.format('%f',acf_tank_rat[i]*Max_Tot)
        local Qty_Cur = string.format('%.0f%%',100*acf_fuel_qty[i]/Qty_Max)
        ratio = acf_fuel_qty[i]/Qty_Max
            -- couleur de fond --
        if      ratio <= 0.000 then pr,pg,pb = 0,0,0            -- 0% 
        elseif  ratio <= 0.050 then pr,pg,pb = 0.5,0,0          -- 05% --> rouge 
        elseif  ratio <= 0.100 then pr,pg,pb = 0.5,0.25,0       -- 10% --> orange
        elseif  ratio <= 0.150 then pr,pg,pb = 0.5,0.5,0        -- 15% --> jaune
        else                        pr,pg,pb = 0,0.20,0  end

        ParamBox(Posx,Init_y,larg,1,"")
        pr,pg,pb = 0,0.2,0
        PercentBox(Posx,Init_y,larg,ratio)
    end
end
function Mdl_Aux() -- GPU & APU
  --------------------------------------------------
  --- Auxiliary & Ground Power Units (APU & GPU) ---
  --------------------------------------------------
  local largeur = 80
  local Text = "Text"
  local Empty = "----"
  local Bleed = get("sim/cockpit2/bleedair/actuators/apu_bleed")
  local Array_APU = {"Off","On","Start"}
  local Apu_Switch = get("sim/cockpit2/electrical/APU_starter_switch")
  local APU_Text = Array_APU[Apu_Switch+1]
  -- APU Door
  local APU_Door = get("sim/cockpit2/electrical/APU_door")
  if Find_Dataref("laminar/B738/electrical/apu_door") then
    APU_Door = get("laminar/B738/electrical/apu_door")
  elseif Find_Dataref("AirbusFBW/APUFlapOpenRatio") then
    APU_Door = get("AirbusFBW/APUFlapOpenRatio")
  else
    APU_Door = get("sim/cockpit2/electrical/APU_door")
  end
  APU_Door = APU_Door == 1 and "Open" or APU_Door == 0 and "Closed" or  ("%.0f%%"):format(APU_Door*100)
  -- APU Stat
  local APU_Stat = acf_apu_amp>0 and ("%.1f A"):format(acf_apu_amp) or Empty
  -- GPU Stat
  local GPU_Stat = acf_gpu_amp>0 and ("%.1f A"):format(acf_gpu_amp) or Empty 
  -- APU Bleed
  local Bleed = get("sim/cockpit2/bleedair/actuators/apu_bleed")
  if Find_Dataref("AirbusFBW/APUBleedInd") then -- for A319 Toliss
    if get("AirbusFBW/APUBleedInd")>0 and get("AirbusFBW/APUBleedSwitch")>0 then Bleed = 1 end 
  end
  Bleed = Bleed > 0 and "On" or Empty
  -- APU N1 (0% to 100%)
  if Find_Dataref("AirbusFBW/APUN") then
    APU_Nu1 = ("%.0f%%"):format(get("AirbusFBW/APUN"))
  else
    APU_Nu1 = acf_apu_n1>1e-1 and ("%s%%"):format(Auto_Float(acf_apu_n1)) or Empty
  end
  -- APU EGT
  if Find_Dataref("AirbusFBW/APUEGT") then
    APU_Egt = ("%.0f°C"):format(get("AirbusFBW/APUEGT"))
  else
    APU_Egt = acf_apu_egt>0 and ("%.0f°C"):format(acf_apu_egt) or Empty
  end
  -- APU Gen
  local APU_GenL,APU_GenR = "",""
  local APU_Gen = get("sim/cockpit2/electrical/APU_generator_on")
  APU_Gen = APU_Gen>0 and "On" or Empty
  local GetData_L,GetData_R
  local Bus_Data,Bus_Enable
  local L3_Text,R3_Text
  L3_Text = "N1"
  R3_Text = APU_Nu1

  --
  -- Search for Laminar Boeing 738
  --------------------------------
  GetData_L   = "laminar/B738/electrical/apu_genL_status"
  GetData_R   = "laminar/B738/electrical/apu_genR_status"
  Bus_Data    = "laminar/B738/annunciator/apu_gen_off_bus" 
  if Find_Dataref(GetData_L) then
    if get(GetData_L)>0 then APU_GenL = "Left" end
  end
  if Find_Dataref(GetData_R) then
    if get(GetData_R)>0 then APU_GenR = "Right" end
  end
  if Find_Dataref(Bus_Data) then
    Bus_Enable = get(Bus_Data)
    L3_Text = Bus_Enable>0 and os.clock() % 4 <= 2 and "Gen Bus" or "N1"
    R3_Text = Bus_Enable>0 and os.clock() % 4 <= 2 and "Off" or APU_Nu1
  end
  if #APU_GenL>0 then APU_Gen = APU_GenL end 
  if #APU_GenR>0 then APU_Gen = APU_GenR end 
  if #APU_GenL>0 and #APU_GenR>0 then APU_Gen = "Both" end
  --
  -- Search for Zibomod Boeing 738
  --------------------------------
  GetData_L = "laminar/B738/electrical/apu_power_bus1"
  GetData_R = "laminar/B738/electrical/apu_power_bus2"
  if Find_Dataref(GetData_L) then
    if get(GetData_L)>0 then APU_GenL = "Left" end
  end
  if Find_Dataref(GetData_R) then
    if get(GetData_R)>0 then APU_GenR = "Right" end
  end
  if #APU_GenL>0 then APU_Gen = APU_GenL end 
  if #APU_GenR>0 then APU_Gen = APU_GenR end 
  if #APU_GenL>0 and #APU_GenR>0 then APU_Gen = "Both" end

  
  ----
--  local GPU,APU,N1,EGT = "Off","Off","----","----"
--  if acf_gpu_amp > 0.01 then GPU = string.format('%.1f A',acf_gpu_amp) end
--  if acf_apu_amp > 0.01 then APU = string.format('%.1f A',acf_apu_amp) end
--  if acf_apu_n1  > 0.01 then N1  = string.format('%.0f %%',acf_apu_n1) end
  if acf_apu_egt > 0 then EGT = string.format('%.0f°C',acf_apu_egt) end
  --Test--
  Text = acf_apu_n1>1 and ("%.0f%%"):format(acf_apu_n1) or APU_Stat
  if PPV_Aux == true then -- and Apu_Switch>0 or acf_apu_n1>1e-1 or acf_gpu_amp>0 then
    TitleBox(Posx,largeur,"Power")
    ParamBox(Posx,Init_y,largeur,8,"Gpu","Apu","Door","Switch",GPU_Stat,APU_Stat,APU_Door,APU_Text)
    TitleBox(Posx,largeur,"APU")
    ParamBox(Posx,Init_y,largeur,8,"Bleed","Gen",L3_Text,"Egt",Bleed,APU_Gen,R3_Text,APU_Egt)
  end
  -- fin Test --
  --[[
  if acf_apu_n1 > 1 or acf_gpu_amp > 1 then
    if acf_apu_n1 >99 and acf_gpu_amp < 1 then
      TitleBox(Posx,largeur,"APU")
      ParamBox(Posx,Init_y,largeur,8,"Apu","Bleed","N1","Egt",APU_Stat,Bleed,APU_Nu1,APU_Egt)
    else
      Text = acf_apu_n1>1 and ("%.0f%%"):format(acf_apu_n1) or APU_Stat
      TitleBox(Posx,largeur,"Power")
      ParamBox(Posx,Init_y,largeur,8,"Apu","Gpu","Door","Switch",Text,GPU_Stat,APU_Door,Apu_Switch)
    end
  end
  --]]
end
function Mdl_Players()
  --print("Multi = "..os.time() .. " - " .. tostring(PPV_Multi))
    if PPV_Multi then
        local Width = 120
        local Number = get("sim/cockpit2/tcas/indicators/tcas_num_acf")
        --local Idt = dataref_table("sim/cockpit2/tcas/targets/modeC_code")
        local Idt = dataref_table("sim/cockpit2/tcas/targets/modeS_id")
        local Rel_Brg = dataref_table("sim/cockpit2/tcas/indicators/relative_bearing_degs")
        local Rel_Alt = dataref_table("sim/cockpit2/tcas/indicators/relative_altitude_mtrs")
        local Rel_Dst = dataref_table("sim/cockpit2/tcas/indicators/relative_distance_mtrs")
        local Hdg = dataref_table("sim/cockpit2/tcas/targets/position/psi")
        local Ele = dataref_table("sim/cockpit2/tcas/targets/position/ele")
        local Thr = dataref_table("sim/cockpit2/tcas/targets/position/throttle")
        local V_s = dataref_table("sim/cockpit2/tcas/targets/position/vertical_speed")
        local V_x = dataref_table("sim/cockpit2/tcas/targets/position/vx")
        local V_y = dataref_table("sim/cockpit2/tcas/targets/position/vy")
        local V_z = dataref_table("sim/cockpit2/tcas/targets/position/vz")
        local Msc, Nmd
        local Var = get("sim/flightmodel/position/magnetic_variation")
        local Cap, Alt, Spd, Dst, Num
        if Number > 1 then
            for Num = 1,Number-1 do
                Msc = math.sqrt(V_x[Num]^2 + V_y[Num]^2 + V_z[Num]^2)
                Cap = string.format("%3.0f°/%.0f°",(Hdg[Num] + Var) % 360, Rel_Brg[Num])
--                Alt = string.format("%s/%s",Auto_K(Ele[Num]/0.3048),Auto_K(V_s[Num]))
                Alt = string.format("%s/%s",Auto_K(Ele[Num]/0.3048),math.abs(V_s[Num]) > 50 and Auto_K(V_s[Num]) or "---")
                Spd = string.format("%.1f KT",Msc*1.94384)
                Nmd = Rel_Dst[Num]/1851.851851
                Dst = Nmd >= 10 and string.format("%.1f NM",Nmd) or string.format("%.2f NM",Nmd) 
--                TitleBox(Posx,Width,string.format("0x%6X",Idt[Num]))
                TitleBox(Posx,Width,string.format("IA-%02i %i%%",Num,100*Thr[Num]))
                ParamBox(Posx,Init_y,Width,8,"Hdg/Rel","Alt/fpm","Spd","Dist",Cap,Alt,Spd,Dst)
            end
        end
    end
end
function Mdl_Battery()
  ---------------------------
  --- Battery status
  ---------------------------
  local Width = 100
  local Text = "Battery"
  local ii = 0
  local jj = 0
  local Color = "white"
  local Second = ("%i"):format(get("sim/network/misc/network_time_sec"))
  local Index = 0
  local Num = get("sim/aircraft/electrical/num_batteries")
  local Stat, Watt, Volt, Amps
  local Warn
  local Amp_Text
  local Temp

  for Index = 0, Num - 1 do
    if get("sim/cockpit/electrical/battery_array_on",Index) > 0 then ii = ii +1 end
    jj = jj + get("sim/cockpit2/electrical/battery_amps",Index)
  end
  if ii < Num or jj <= 0 then Warn = 1 end
--  Index = Second/2 % Num
  local Beacon

  for Index = 0, Num - 1 do
    Beacon = get("sim/cockpit2/switches/beacon_on")
    Stat = get("sim/cockpit/electrical/battery_array_on",Index) == 1 and "On" or "Off"
    --Watt = ("%f"):format(get("sim/cockpit/electrical/battery_charge_watt_hr",Index))
    Watt = ("%f"):format(get("sim/cockpit/electrical/battery_charge_watt_hr",Index))
    --Watt = get("sim/cockpit/electrical/battery_charge_watt_hr",Index)
    Volt = ("%.1f V"):format(get("sim/cockpit2/electrical/battery_voltage_actual_volts",Index))
    --Amps = ("%.1f"):format(get("sim/cockpit2/electrical/battery_amps",Index))
    Temp = tonumber(("%f"):format(get("sim/cockpit2/electrical/battery_amps",Index))) 
    Amp_Text = Temp<0 and "Dump" or Temp>0 and "Load" or "Stable"
    
    if Stat =="On" then Warn = 0 else Warn = 1 end
    
    if PPV_Battery == true then --or Warn == 1 then -- or Temp~=0 then 
      --if tonumber(Temp) < 0 then Color = "orange" else Color = "white" end
      if Battery_Charge[Index] == false then Color = "orange" else Color = "white" end
      Amps = Temp==0 and "Yes" or math.abs(Temp) < 1 and ("%.3f A"):format(Temp) or math.abs(Temp) < 10 and ("%.2f A"):format(Temp) or  ("%.1f A"):format(Temp)
      TitleBox(Posx,Width,("%s %i"):format(Text, Index + 1),Color,Warn)
      ParamBox(Posx,Init_y,Width,8,"Status","Capacity","Voltage",Amp_Text,Stat,("%s"):format(Auto_Float(Watt)),Volt,Amps)
    end
  end
end
function Total_Fuel_Flow()
    local i,cumul = 0,0
    for i = 0,acf_num_tanks-1 do cumul = acf_fuel_flow[i] + cumul end
    return cumul
end
function Display_kg_t(Val)
    local Fmt, Unit
    if Val < 1000 then Unit = "kg" else Unit = "T" end
    --
    if      Val < 1e1 then Fmt = string.format('%5.3f %s',Val,Unit)
    elseif  Val < 1e2 then Fmt = string.format('%5.2f %s',Val,Unit)
    elseif  Val < 1e3 then Fmt = string.format('%5.1f %s',Val,Unit)
    elseif  Val < 1e4 then Fmt = string.format('%5.3f %s',Val/1000,Unit)
    elseif  Val < 1e5 then Fmt = string.format('%5.2f %s',Val/1000,Unit)
    elseif  Val < 1e6 then Fmt = string.format('%5.1f %s',Val/1000,Unit)
    else
        Fmt = string.format('%6.0f %s',Val/1000,Unit)
    end
    return Fmt
end
function Mdl_Weights()
    local largeur = 100
    local ln1,ln2,ln3,ln4 = "----","----","----","----"
    local ln5,ln6,ln7,ln8 = "----","----","----","----"
    ln1,ln5 = string.format('%s',Display_kg_t(acf_payload)),"Payload"
    ln2,ln6 = string.format('%s',Display_kg_t(acf_max_weight)),"Max"
    ln3,ln7 = string.format('%s',Display_kg_t(acf_actual_weight)),"GWT"
    ln4,ln8 = string.format('%s',Display_kg_t(acf_fuel_max)),"Max Fuel"
    TitleBox(Posx,largeur,"Weight")
    ParamBox(Posx,Init_y,largeur,8,ln1,ln2,ln3,ln4,ln5,ln6,ln7,ln8)
end
function Mdl_Spoilers()
    local largeur = 120
    local spl_txt
    local ln1,ln2,ln3,ln4 = "","","",""
    if spl_1 == -0.5 then
--        spl_txt = "Armed"
    elseif spl_1 == 0 then
--        spl_txt = "Stowed"
    elseif spl_1 == 1 then
--        spl_txt = "Full"
    else
--        spl_txt = "---"
    end
    
    ln1 = string.format('1: %05.2f - 2: %05.2f',spl_1,spl_2)
    ln2 = string.format('3: %05.2f - 4: %05.2f',spl_3,spl_4)
    ln3 = string.format('5: %05.2f - 6: %05.2f',spl_5,spl_6)
    ln4 = string.format('7: %05.2f - 8: %05.2f',spl_7,spl_8)
    TitleBox(Posx,largeur,string.format('%s',"Spoilers"))
    ParamBox(Posx,Init_y,largeur,4,ln1,ln2,ln3,ln4)
end
function Mdl_Vor()
    ------------------------
    -- Vor/Dme Indicators --
    ------------------------
    local Width = 120
    local Nav_Id = get("sim/cockpit2/radios/indicators/nav1_nav_id")
    local Nav_Dst = dataref_table("sim/cockpit2/radios/indicators/nav_dme_distance_nm")
    TitleBox(Posx,Width,"Vor/Dme1")
    ParamBox(Posx,Init_y,Width,8,"Id","Distance","Radial","From/To",Nav_Id,string.format('%.1f nm',Nav_Dst[0]),"----","----")
end
function TitleBox(x,larg,text,color,warn,rr,gg,bb)
    local x1,y1,x2,y2,lg,ht
    lg,ht = larg,Cart1_Haut/2
--    x1 = Posx
    x1 = x
    y1 = Init_y + Cart1_Haut
    x2 = x1 + larg
    y2 = y1 + ht
    if warn == 1 then
        glColor4f(1,0,0,alpha) 
    elseif warn == 2 then
        glColor4f(rr,gg,bb,alpha)
    else
        glColor4f(fr,fg,fb,alpha) 
    end
    graphics.set_width(2)
    glRectf(x1, y1, x2, y2)
    --
    glColor4f(1,1,1,alpha)
--    graphics.draw_rectangle(x1, y1, x2, y2)
    graphics.draw_line(x1, y1, x1, y2)  -- left line
    graphics.draw_line(x2, y1, x2, y2)  -- right line
    graphics.draw_line(x1, y1, x2, y1)  -- bottom
    graphics.draw_line(x1, y2, x2, y2)  -- top
    local offset = (larg - measure_string(text,"Helvetica_18"))/2
    glColor4f(0,0,0,1) 
    draw_string_Helvetica_18(x1 + offset + 2 , y1 + 5 - 2, text)
    draw_string_Helvetica_18(x1 + offset + 1 , y1 + 5 - 1, text)
    --
    if color == "white" then
        glColor4f(1,1,1,alpha)
    elseif color == "yellow" then
        glColor4f(1,1,0,alpha)
    elseif color == "orange" then
        glColor4f(1,0.6,0,alpha)
    elseif color == "red" then
        glColor4f(1,0,0,alpha)
    elseif color == "blue" then
        glColor4f(0,0,1,alpha)
    elseif color == "green" then
        glColor4f(0,1,0,alpha)
    elseif color == "cyan" then
        glColor4f(0,1,1,alpha)
    elseif color == "magenta" then
        glColor4f(1,0,1,alpha)
    elseif color == "black" then
        glColor4f(0,0,0,alpha)
    elseif color == "gray" then
        glColor4f(0.5,0.5,0.5,alpha)
    else
        glColor4f(tr,tg,tb,alpha)
    end
    draw_string_Helvetica_18(x1 + offset, y1 + 5, text)
    graphics.set_width(1)
end
function ParamBox(x,y,larg,nl,tt1,tt2,tt3,tt4,tt5,tt6,tt7,tt8)
    local x1,y1,x2,y2,lg,ht,offset
    lg,ht = larg,Cart1_Haut
    x1 = Posx
    y1 = Init_y 
    x2 = x1 + larg
    y2 = y1 + ht
    --
    local ln1,ln2,ln3,ln4 = 38,26,14,02
    glColor4f(pr, pg, pb, alpha) 
    glRectf(x1, y1, x2, y2)
--
    glColor4f(1.0,1.0,1.0,1.0) 
    graphics.draw_line(x1, y1, x1, y2)  -- left line
    graphics.draw_line(x2, y1, x2, y2)  -- right line
    graphics.draw_line(x1, y1, x2, y1)  -- bottom
    graphics.draw_line(x1, y2, x2, y2)  -- top
--    
    glColor4f(1,1,1,1)
--    draw_string_Helvetica_18(x1 + 3, y1 + 3, Text)
    if nl == 1 then
        if tt1 then
            offset = (larg - measure_string(tt1,"Times_Roman_24"))/2
            draw_string_Times_Roman_24(x1 + offset, y1 + Line[3],tt1)
        end
    elseif nl == 2 then
        draw_string_Times_Roman_24(x1 + 2, y1 + Line[2],tt1)
        draw_string_Times_Roman_24(x1 + 2, y1 + Line[4], tt2)
    elseif nl == 3 then
        -- 1 gros texte (tt1) centré verticalement et 2 petits textes centrés en haut (tt2) et en bas (tt3)
        --
        if tt1 then
            offset = (larg - measure_string(tt1,"Times_Roman_24"))/2
            draw_string_Times_Roman_24(x1 + offset, y1 + Line[3],tt1)
        end
        if tt2 then draw_string(x1 + (larg - measure_string(tt2))/2, y1 + Line[1], tt2,"yellow") end
        if tt3 then draw_string(x1 + (larg - measure_string(tt3))/2, y1 + Line[4], tt3,"yellow") end
    elseif nl == 4 then
        if tt1 then draw_string(x1 + 2, y1 + Line[1], tt1) end
        if tt2 then draw_string(x1 + 2, y1 + Line[2], tt2) end
        if tt3 then draw_string(x1 + 2, y1 + Line[3], tt3) end
        if tt4 then draw_string(x1 + 2, y1 + Line[4], tt4) end
    elseif nl == 5 then
        -- tt1 = gros texte (tt1) centré au milieu
        -- tt2 = (Lh) texte a gauche haut
        -- tt3 = (Ld) texte a gauche bas
        -- tt4 = (Rh) texte a droite haut
        -- tt5 = (Rd) texte a droite bas
        
        if tt1 then
            color = "yellow"
            offset = (larg - measure_string(tt1,"Times_Roman_24"))/2
            draw_string_Times_Roman_24(x1 + offset, y1 + Line[3],tt1)
        end

        if tt2 then draw_string(x1 + 2, y1 + Line[1], tt2,color) end    -- a gauche haut
        if tt3 then draw_string(x1 + 2, y1 + Line[4], tt3,color) end    -- a gauche bas
        if tt4 then draw_string(x1 - 3 + larg - measure_string(tt4), y1 + Line[1], tt4,color) end   -- a droite haut
        if tt5 then draw_string(x1 - 3 + larg - measure_string(tt5), y1 + Line[4], tt5,color) end   -- a droite bas
    elseif nl == 6 then
        -- tt1 = gros texte (tt1) centré au milieu
        -- tt2 = texte a gauche haut
        -- tt3 = texte a droite haut
        -- tt4 = texte centré en bas
      if tt1 then
          color = "yellow"
          offset = (larg - measure_string(tt1,"Times_Roman_24"))/2
          draw_string_Times_Roman_24(x1 + offset, y1 + Line[3],tt1)
      end
      if tt2 then draw_string(x1 + 2, y1 + Line[1], tt2,color) end    -- a gauche haut
      if tt3 then draw_string(x1 - 3 + larg - measure_string(tt3), y1 + Line[1], tt3,color) end   -- a droite haut
      if tt4 then draw_string(x1 + (larg - measure_string(tt4))/2, y1 + Line[4], tt4,color) end

    elseif nl == 7 then

    elseif nl == 8 then
        --- tt1 à tt4 aligné à gauche
        --- tt5 à tt8 aligné à droite
        if tt1 then draw_string(x1 + 2, y1 + Line[1], tt1) end
        if tt2 then draw_string(x1 + 2, y1 + Line[2], tt2) end
        if tt3 then draw_string(x1 + 2, y1 + Line[3], tt3) end
        if tt4 then draw_string(x1 + 2, y1 + Line[4], tt4) end
        --
        local color = "green"
        if tt5 then draw_string(x1 -2 + larg - measure_string(tt5), y1 + Line[1], tt5,color) end
        if tt6 then draw_string(x1 -2 + larg - measure_string(tt6), y1 + Line[2], tt6,color) end
        if tt7 then draw_string(x1 -2 + larg - measure_string(tt7), y1 + Line[3], tt7,color) end
        if tt8 then draw_string(x1 -2 + larg - measure_string(tt8), y1 + Line[4], tt8,color) end
    end
    Posx = Posx + larg
end
function ParamTxt(x1,y1,line,larg,justif,text,color)
    local raw = {39,27,15,03}
    local offset
    line = line or 1
    if line > 0 and line <= 4 then ln = raw[line] end
    if string.upper(justif) == "R"  or justif == 2 then
        draw_string(x1 - 3 + larg - measure_string(text), y1 + ln,text,color)
    elseif  string.upper(justif) == "C"  or justif == 1 then
        draw_string(x1 + (larg - measure_string(text))/2, y1 + ln,text,color)
    else
        draw_string(x1 + 2, y1 + ln, text,color)
    end
end
function PercentBox(x,y,larg,ratio)
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end
    local x1,y1,x2,y2,lg,ht
    lg,ht = larg,Cart1_Haut
    x1 = Posx - larg
    y1 = Init_y 
    x2 = x1 + larg
    y2 = y1 + ht*ratio
    glColor4f(0,0.7,0,1)
    glRectf(x1, y1, x2, y2)
--
    glColor4f(1.0,1.0,1.0,1.0) 
    graphics.draw_line(x1, y1, x1, y2)  -- left line
    graphics.draw_line(x2, y1, x2, y2)  -- right line
    graphics.draw_line(x1, y1, x2, y1)  -- bottom
    graphics.draw_line(x1, y2, x2, y2)  -- top
--    draw_string(x-larg,y+2,string.format('%.2f%%',100*ratio))
    ---------------------------
    -- Affichage Graduations --
    ---------------------------
    local ii,step = 0,8
    local mrk

    for i = 0,1,1/step do
        if ii % 2 == 0 then mrk = 6 else mrk = 3 end
        ii = ii + 1
        graphics.draw_line(x1 + larg - mrk, y1 + ht*i, x2, y1 + ht*i)    
    end
end

------------------------------------------------
-- X-RAAS 2.0 Plugin Integration by Skiselkov --
------------------------------------------------

function XRAAS_ND_msg_decode(dr_value)
	local bit = require 'bit'
	local msg_type = bit.band(dr_value, 0x3f)
	local color_code = bit.band(bit.rshift(dr_value, 6), 0x3)

	local function decode_rwy_suffix(val)
		if val == 1 then
			return "R"
		elseif val == 2 then
			return "L"
		elseif val == 3 then
			return "C"
		else
			return ""
		end
	end

	if msg_type == 1 then
		return "FLAPS", color_code
	elseif msg_type == 2 then
		return "TOO HIGH", color_code
	elseif msg_type == 3 then
		return "TOO FAST", color_code
	elseif msg_type == 4 then
		return "UNSTABLE", color_code
	elseif msg_type == 5 then
		return "TAXIWAY", color_code
	elseif msg_type == 6 then
		return "SHORT RUNWAY", color_code
	elseif msg_type == 7 then
		return "ALTM SETTING", color_code
	elseif msg_type == 8 or msg_type == 9 then
		local msg
		local rwy_ID = bit.band(bit.rshift(dr_value, 8), 0x3f)
		local rwy_suffix = bit.band(bit.rshift(dr_value, 14), 0x3)
		local rwy_len = bit.band(bit.rshift(dr_value, 16), 0xff)

		if msg_type == 8 then
			msg = "APP"
		else
			msg = "ON"
		end
		if rwy_ID == 0 then
			return string.format("%s TAXIWAY", msg), color_code
		elseif rwy_ID == 37 then
			return string.format("%s RWYS", msg), color_code
		else
			if rwy_len == 0 then
				return string.format("%s %02d%s", msg, rwy_ID,
				    decode_rwy_suffix(rwy_suffix)), color_code
			else
				return string.format("%s %02d%s %02d", msg,
				    rwy_ID, decode_rwy_suffix(rwy_suffix),
				    rwy_len), color_code
			end
		end
	elseif msg_type == 10 then
		return "LONG LANDING", color_code
	elseif msg_type == 11 then
		return "DEEP LANDING", color_code
	else
		return nil, nil
	end
end

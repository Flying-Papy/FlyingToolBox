--[[-------------------------------------------
-- Assistant By FlyingPapy --------------------
-----------------------------------------------
-- Part of Flying Toolbox ---------------------
-----------------------------------------------
delete or back-up old version and copy this file into 
"X-Plane 11/Resources/plugins/FlyWithLua/Scripts/" folder
-----------------------
-- User variables
---------------------]]
local Vers_Date = "21.10.17"
local Vers_Num  = "v1.0.3"
local Ftb = require "FTB_lib" -- FlyingToolBox API
-- Display Duration in seconds --
local Delay = 10

-- Foreground Color [0...1] for each channel --
local F_r = 0.0 ;-- red
local F_g = 1.0 ;-- green
local F_b = 0.3 ;-- blue
local F_a = 1.0 ;-- alpha (0 = fully transparent)

-- Background Color [0...1] for each channel--
local B_r = 0.0 ;-- red
local B_g = 0.0 ;-- green
local B_b = 0.0 ;-- blue
local B_a = 0.5 ;-- alpha (0 = fully transparent)

FTB_Assistant = true -- Activated by managed Aircrafts or true for test
-------------------------------------------
-- Don't modify anything below this line --
-------------------------------------------
-- default values for managed aircraft. Set to true if detected
local Airbus_Toliss   = false -- Toliss Airbus A319 & A321
local Boeing_738      = false -- Laminar Boeing 737-800
local Zibomod_738     = false -- Zibomod Boeing 737-800
local B737_Max8       = false -- Zibomod Boeing 737 Max-8
local Airbus_A359_FF  = false -- Flight Factor Airbus A350-900
local Legacy_650      = false -- X-Craft Embraer Legacy 650
local Phenom_300      = false -- Aerobask Phenom 300
local Car_Saab340     = false -- Carenado Saab 340
--
local Chrono        = os.clock() + Delay 
local Line          = {} ; for i=1,10 do Line[i] = "" end
--[[ Line usage
--  1 - Assistant Msg & Version
--  2 - Positive climb or Emergency Gear
--  3 - Fasten Seat Belts
--  4 - Landing Lights
--  5 - Runway Lights
--  6 - Taxi Lights
--  7 - Nav1 Freq Sync
--  8 - Nav2 Freq Sync
--  9 - Flaps Position
-- 10 -
--]]
local Msg_FSB_On    = "Fasten Seat Belts ---> On (< FL100)"
local Msg_FSB_Off   = "Fasten Seat Belts ---> Off (> FL100)"
local Msg_FSB_Auto  = "Fasten Seat Belts ---> Auto"
local Msg_LDG_On    = "Landing Light ------> On (< FL100)"
local Msg_LDG_Off   = "Landing Light ------> Off (> FL100)"
local Msg_RWY_On    = "Runway Light ---> On (Gear Down)"
local Msg_RWY_Off   = "Runway Light ---> Off (Gear Up)"
local Msg_Taxi_On   = "Taxi Light ------> On (Gear Down)"
local Msg_Taxi_Off  = "Taxi Light ------> Off (Gear Up)"
local Aircraft_Desc = "----"
local Msg_Climb     = "Positive Climb Detected ---> Gear Up"

local LIB_DIRECTORY = "FTB/Snd/"
local Snd_Climb     = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Positive Climb - Gear Up.wav")
local Snd_Managed   = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Aircraft Managed.wav")

local Flap_0 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flaps Up.wav")
local Flap_1 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 1.wav")
local Flap_2 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 2.wav")
local Flap_3 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 3.wav")
local Flap_4 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 4.wav")
local Flap_5 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 5.wav")
local Flap_6 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 6.wav")
local Flap_7 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 7.wav")
local Flap_8 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 8.wav")
local Flap_9 = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Flap 9.wav")
local Flap_F = load_WAV_file(SCRIPT_DIRECTORY .. LIB_DIRECTORY .. "Full Flaps.wav")

local Played = false
local Number = 1
local Last_Flap = 0
local Flap_Text = { "Flaps Up", "Flap 1", "Flap 2", "Flap 3", "Flap 4", "Flap 5", "Flap 6", "Flap 7", "Flap 8", "Flap 9", "Full Flaps" }

require("graphics")

dataref("FTB_Desc","sim/aircraft/view/acf_descrip","writable")

-------------------------
--- Primary Functions ---
-------------------------
function Landed()
    local Status = get("sim/flightmodel/failures/onground_any")
    if Status > 0 then
        return true
    else
        return false
    end
end
function Duree(value,mode)
    -- Value = seconds
    local hh,mm,ss
    if value < 0 or value > 100*60*60 - 1 then return "" end

    hh,mm = math.modf(value / 3600)
    mm,ss = math.modf(mm *60)

    if hh < 0 then hh = 0 end
    if mm < 0 then mm = 0 end
--
    if mode == 0 then
        if value >= 3600 then
            return string.format('%dh%02d',hh,mm) -- renvoie au format hh:mm
        else
            return string.format('%02d:%02d',mm,ss*60 % 60)
        end
    elseif mode == 1 then
        return string.format('%dh%02d:%02d',hh,mm,ss*60 % 60) -- renvoie au format h:mm:ss
    else
        return string.format('%02dh%02d:%02d',hh,mm,ss*60 % 60) -- renvoie au format hh:mm:ss
    end

end
function Gear_Down()
    local Gear = dataref_table("sim/aircraft/parts/acf_gear_deploy")
    return Gear[0] + Gear[1] + Gear[2] == 3 and true or false
end
function Gear_Up()
    local Gear = dataref_table("sim/aircraft/parts/acf_gear_deploy")
    return Gear[0] + Gear[1] + Gear[2] == 0 and true or false
end
function Flight_Level(altitude)
    local Get_FL = "sim/cockpit2/gauges/indicators/altitude_ft_stby"
    return altitude and tonumber(("%.f"):format(altitude/100)) or tonumber(("%.f"):format(get(Get_FL)/100))
end
-------------------------------
--- Events Kernel Functions ---
-------------------------------
function FTB_Assistant_CallBack()
  if FTB_Assistant == true then
    if os.clock() < Chrono or get("sim/time/total_flight_time_sec") < Delay  then
      Line[1] = #Aircraft_Type() > 0 and ("%s - Managed by Assistant (%s - %s)"):format(Aircraft_Type(), Vers_Num, Vers_Date) or ""
      if #Aircraft_Type() > 0 and Played == false then
        --set_sound_gain(Snd_Managed,1.0)
        --set_sound_pitch(Snd_Managed,1.0)
        play_sound(Snd_Managed)
        Played = true
      end
    else
      for i=1,10 do Line[i] = "" end
    end        
    ---[[ -- Mettre Landed() == false (true c'est pour tester au sol)
    if Landed() == false and get("sim/time/total_flight_time_sec") > Delay then
      if Airbus_Toliss  == true then Manage_Airbus_Toliss() end
      if Boeing_738     == true then Manage_Boeing_738()    end
      if Zibomod_738    == true then Manage_Zibomod_738()   end
      if Airbus_A359_FF == true then Manage_Airbus_A359_FF()end
      if B737_Max8      == true then Manage_Zibomod_738()   end
      if Legacy_650     == true then Manage_Legacy_650()    end
      if Phenom_300     == true then Manage_Phenom_300()    end
      if Car_Saab340    == true then Manage_Saab340()       end
    else
      Played_Climb = false
    end
    --]]

    Test_Positive_Climb()
    Test_Emergency_Landing()
    Test_Flaps_Position()
  end
end
function Display_Msg()
    local Offset,Radius
    local Msg
    local x1,y1,x2,y2
    local width,height
    local Screen_Width  = get("sim/graphics/view/window_width")
    local Screen_Height = get("sim/graphics/view/window_height")
    -- OpenGL graphics state initialization
    -- use only in do_every_draw()
    XPLMSetGraphicsState(0,0,0,1,1,0,0)

    Msg = " " .. Line[1] .. " "
    for ii = 1,10 do
        Msg = " " .. Line[ii] .. " "
        if #Msg > 2 then
            width    = measure_string(Msg,"Helvetica_18")
            height    = 18
            x1      = (Screen_Width - width)/2
            y1      = Screen_Height - ii*20 - 200
            x2      = x1 + width
            y2      = y1 + height
            Offset = (Screen_Width - measure_string(Msg,"Helvetica_18"))/2
            -- Background Rectangle --
            glColor4f(B_r,B_g,B_b,B_a)
            glRectf(x1,y1,x2,y2)
            -- Foreground Text --
            glColor4f(F_r,F_g,F_b,F_a) -- set Color
            draw_string_Helvetica_18(Offset,Screen_Height - ii*20 + 2 - 200, Msg)
        end
    end

    if FTB_Assistant == true then
        -- Display filled circle outlined
        Radius = 9
        glColor4f(F_r,F_g,F_b,F_a) -- set foreground color
        graphics.draw_filled_circle(Radius*2,Screen_Height - Radius*2,Radius)
        glColor4f(1,1,1,1) -- set white color
        graphics.draw_circle(Radius*2,Screen_Height- Radius*2,Radius,1)
    else
        for i=1,10 do Line[i] = "" end
    end
end
function Test_Positive_Climb()
  -------------------------------
  -- Positive Climb -- Gear Up --
  -------------------------------
  local acf_gear  = dataref_table("sim/aircraft/parts/acf_gear_deploy")
  local Agl_Ft    = get("sim/flightmodel/position/y_agl")/0.3048
  local acf_fpm   = get("sim/flightmodel/position/vh_ind_fpm")
  local acf_ias   = get("sim/flightmodel/position/indicated_airspeed")
  local acf_vso   = get("sim/aircraft/view/acf_Vso")
  local Retract   = get("sim/aircraft/gear/acf_gear_retract")
  --Number = 2
--  if acf_gear[1] > 0 and Altitude_Agl_Ft > 500 and acf_fpm > 500 and acf_ias > acf_vso * 1.5 then
  if Gear_Down() == true
    and Agl_Ft > 100
    and acf_fpm > 300
    and acf_ias > acf_vso * 1.3
    and Retract > 0
    then
    if Played_Climb == false then
      play_sound(Snd_Climb)
      Played_Climb = true
      command_once("sim/flight_controls/landing_gear_up")
      Line[2] = Msg_Climb
      Chrono  = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[2] = "" end
    end
  end
--  if Gear_Down() == false then Played_Climb = false end
end
function Test_Emergency_Landing()
  local Agl_Ft    = get("sim/flightmodel/position/y_agl")/0.3048
  local Fpm       = get("sim/flightmodel/position/vh_ind_fpm")
  local Acf_Vs    = get("sim/aircraft/view/acf_Vs")
  local Acf_Vso   = get("sim/aircraft/view/acf_Vso")
  local Acf_Vle   = get("sim/aircraft/overflow/acf_Vle")
  local Airspeed  = get("sim/flightmodel/position/indicated_airspeed")
  local Throttle  = get("sim/cockpit2/engine/actuators/throttle_ratio_all")
  if Agl_Ft <= 2000 and Fpm < -200 and Airspeed < Acf_Vle and Throttle <= 0.5 then
    if Gear_Down() == false then
      command_once("sim/flight_controls/landing_gear_down")
      command_once("sim/flight_controls/pump_gear")
      Line[2] = "Emergency Landing Gear"
    else
      Line[2] = ""
    end
  end
end
function Test_Flaps_Position()
  local Flap_Deploy = get("sim/cockpit2/controls/flap_handle_deploy_ratio")
  local Flap_Ratio  = get("sim/cockpit2/controls/flap_ratio")
  local Flap_Detent = get("sim/aircraft/controls/acf_flap_detents")
  local Flap_Step, F_Position, Index
  local Number = 9

  if Last_Flap ~= Flap_Deploy then
    if Flap_Ratio == Flap_Deploy then
      Flap_Step = tonumber(("%.1f"):format(Flap_Deploy*Flap_Detent))
      if Flap_Step == 0 then
        Index = 1
        play_sound(Flap_0)
      elseif Flap_Step == Flap_Detent then
        Index = 11
        play_sound(Flap_F)
      else
        Index = Flap_Step + 1
        if      Flap_Step == 1 then play_sound(Flap_1)
        elseif  Flap_Step == 2 then play_sound(Flap_2)
        elseif  Flap_Step == 3 then play_sound(Flap_3)
        elseif  Flap_Step == 4 then play_sound(Flap_4)
        elseif  Flap_Step == 5 then play_sound(Flap_5)
        elseif  Flap_Step == 6 then play_sound(Flap_6)
        elseif  Flap_Step == 7 then play_sound(Flap_7)
        elseif  Flap_Step == 8 then play_sound(Flap_8)
        elseif  Flap_Step == 9 then play_sound(Flap_9)
        end
      end
      F_Position = Flap_Text[Index]
      if F_Position == nil then
        F_Position = ("Flap %.1f%%"):format(Flap_Deploy*100)
      end
      Line[Number] = ("%s"):format(F_Position)
      Chrono  = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
  end
  Last_Flap = Flap_Deploy
end
----------------------
--- Main Functions ---
----------------------
function Aircraft_Type()
  local file = io.open(AIRCRAFT_PATH .. "version.txt", 'r')
  local version = ""
  if file then  version = " v" .. file:read("*all"); file:close() end
  ------------------------------------------
  -- Test for Xcraft - Embraer Legacy 650 --
  ------------------------------------------
  if (AIRCRAFT_FILENAME == "Legacy.acf") and (get("sim/aircraft/view/acf_descrip") == "X-Crafts Legacy 650") then
    --
    local Filename = "Version Notes.txt"
    local file = io.open(AIRCRAFT_PATH .. Filename, 'r')
    local version = ""
    if file then version = file:read() end
    file:close()
    --
    Legacy_650 = true
    FTB_Assistant = true
    Aircraft_Desc = ("%s %s"):format(get("sim/aircraft/view/acf_descrip"), version)
    return Aircraft_Desc
  end
  --------------------------------------------
  -- Test for Aerobask - Embraer Phenom 300 --
  --------------------------------------------
  if AIRCRAFT_FILENAME == "phenom300.acf" then
    --
    local Filename = "skunkcrafts_updater.cfg"
    local PathFile = AIRCRAFT_PATH .. Filename
    local file = io.open(PathFile, 'r')
    local line
    local version = ""
    if file then
      for line in file:lines() do
        if string.match(line,"version|") then
          version = string.gsub(line,"version|","")
          if not string.match(version,"v") then
            version = (" v%s"):format(version)
          end
        end
        if string.match(line,"name|") then
          Aircraft_Desc = ("%s%s"):format(string.gsub(line,"name|",""),version)
        end
      end
    else
      --Aircraft_Desc = "Aerobask - Phenom 300"
      Aircraft_Desc = get("sim/aircraft/view/acf_descrip")
    end
    file:close()
    --
    Phenom_300 = true
    FTB_Assistant = true
    return Aircraft_Desc
  end
    -----------------------------------------------------------
    -- Test for Laminar - B737-800 or Boeing 737-800 Zibomod --
    -----------------------------------------------------------
    if AIRCRAFT_FILENAME == "b738.acf" then -- STD Version
        FTB_Assistant = true
        if get("sim/aircraft/view/acf_descrip") == "Boeing 737-800X" then
            Zibomod_738 = true
            Aircraft_Desc = "Boeing 737-800 Zibomod" .. version
        else
            Boeing_738 = true
            Aircraft_Desc = "Boeing 737-800 Laminar"
        end
        return Aircraft_Desc
    end
    if AIRCRAFT_FILENAME == "b738_4k.acf" then -- 4K Version
        Zibomod_738 = true
        FTB_Assistant = true
        Aircraft_Desc = "Boeing 737-800 Zibomod 4K" .. version
        return Aircraft_Desc
    end
    -----------------------------------------
    -- Test for Laminar - Boeing 737 Max-8 --
    -----------------------------------------
    if AIRCRAFT_FILENAME == "B38M.acf" then
        if get("sim/aircraft/view/acf_descrip") == "Boeing 737-800X" then
            FTB_Assistant = true
            B737_Max8 = true
            Aircraft_Desc = "Boeing 737 Max-8"
        end
        return Aircraft_Desc
    end
    ---------------------------------------------------
    -- Test for Toliss - Standard Airbus A319 & A321 --
    ---------------------------------------------------
    if AIRCRAFT_FILENAME == "a319_StdDef.acf" then
        Airbus_Toliss = true
        FTB_Assistant = true
        Aircraft_Desc = "Airbus A319 Toliss Std Def"
        return Aircraft_Desc
    end
    if AIRCRAFT_FILENAME == "a321_StdDef.acf" then
        Airbus_Toliss = true
        FTB_Assistant = true
        Aircraft_Desc = "Airbus A321 Toliss Std Def"
        return Aircraft_Desc
    end
    ---------------------------------------------------
    -- Test for Toliss - High Def Airbus A319 & A321 --
    ---------------------------------------------------
    if AIRCRAFT_FILENAME == "a319.acf" then
        Airbus_Toliss = true
        FTB_Assistant = true
        Aircraft_Desc = "Airbus A319 Toliss Hi Def"
        return Aircraft_Desc
    end
    if AIRCRAFT_FILENAME == "a321.acf" then
        Airbus_Toliss = true
        FTB_Assistant = true
        Aircraft_Desc = "Airbus A321 Toliss Hi Def"
        return Aircraft_Desc
    end
    -----------------------------------
    -- Test for Carenado - Saab 340B --
    -----------------------------------
    if AIRCRAFT_FILENAME == "SF34.acf" then
        Car_Saab340 = true
        FTB_Assistant = true
        Aircraft_Desc = "Carenado Saab 340B" .. version
      if #FTB_Desc < 1 then FTB_Desc = Aircraft_Desc end
        return Aircraft_Desc
    end
    --------------------------------------------
    -- Test for Flight Factor Airbus A350-900 --
    --------------------------------------------
    if AIRCRAFT_FILENAME == "A350_xp11.acf" then
      Airbus_A359_FF  = true
      FTB_Assistant   = true
      Aircraft_Desc   = "Flight Factor Airbus A350-900"
      if #FTB_Desc < 1 then FTB_Desc = Aircraft_Desc end
      return Aircraft_Desc
    end
  return ""
end
function Manage_Boeing_738()
  local FSB_Off       = "laminar/B738/toggle_switch/seatbelt_sign_up"
  local FSB_On        = "laminar/B738/toggle_switch/seatbelt_sign_dn"
  local FSB_Status    = "laminar/B738/toggle_switch/seatbelt_sign_pos"

  local Light         = dataref_table("sim/cockpit2/switches/generic_lights_switch")
  local LDL_Light     = dataref_table("sim/cockpit2/switches/landing_lights_switch")

  local Taxi_On       = "laminar/B738/toggle_switch/taxi_light_brightness_pos_dn"
  local Taxi_off      = "laminar/B738/toggle_switch/taxi_light_brightness_pos_up"

  local SeatBelt      = get(FSB_Status)
  local Landing_Light = LDL_Light[0] + LDL_Light[1] + LDL_Light[2] + LDL_Light[3]

  if Flight_Level() > 100 then
    ---------------------------------------------------------
    -- Turning Off Fasten Seat Belts if Flight Level > 100 --
    ---------------------------------------------------------
    Number = 3
    if SeatBelt > 0 then
      command_once(FSB_Off)
      Line[Number] = Msg_FSB_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ------------------------------------------------------
    -- Turning Off Landing Lights if Flight Level > 100 --
    ------------------------------------------------------
    if Landing_Light > 0 then
      for ii = 0,3 do LDL_Light[ii] = 0 end
      Line[Number+1] = Msg_LDG_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end

  if Flight_Level() < 100 then
    --------------------------------------------------------
    -- Turning On Fasten Seat Belts if Flight Level < 100 --
    --------------------------------------------------------
    Number = 3
    if SeatBelt < 1 then
      command_once(FSB_On)
      Chrono = os.clock() + Delay
      Line[Number] = Msg_FSB_On
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------------------
    -- Turning On Landing Lights if Flight Level < 100 --
    -----------------------------------------------------
    if Landing_Light < 4 then
      for ii = 0,3 do LDL_Light[ii] = 1 end
      Line[Number+1] = Msg_LDG_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end

  if Gear_Down() == true then
    -------------------------------------------
    -- Turning On Runway Lights if Gear Down --
    -------------------------------------------
    Number = 5
    if Light[2] + Light[3] < 2 then
      Light[2], Light[3] = 1,1
      Line[Number] = Msg_RWY_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------
    -- Turning On Taxi Lights if Gear Down --
    -----------------------------------------
    if Light[4] < 1 then
      command_once(Taxi_On)
      Line[Number+1] = Msg_Taxi_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end
  -------------------------------------------------------
  -- Turning Off Runway Lights & Taxi Light if Gear Up --
  -------------------------------------------------------
  if Gear_Up() == true then
    -- Test Runway Light L & Runway Light R
    if Light[2] + Light[3] > 0 then
      Light[2], Light[3] = 0,0
      Line[4] = Msg_RWY_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[4] = "" end
    end
    -- Test Taxi light
    if Light[4] > 0 then
      command_once(Taxi_off)
      Line[5] = Msg_Taxi_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[5] = "" end
    end
  end
end
function Manage_Zibomod_738()
  local FSB_Off           = "laminar/B738/toggle_switch/seatbelt_sign_up" -- command
  local FSB_On            = "laminar/B738/toggle_switch/seatbelt_sign_dn" -- command
  local FSB_Status        = "laminar/B738/toggle_switch/seatbelt_sign_pos"        -- dataref 0 = Off - 1 = On

  local LDL_Light         = dataref_table("laminar/B738/lights_sw")       -- index 6 & 7
  local LDL_Light_L_On    = "laminar/B738/switch/land_lights_left_on"     -- command
  local LDL_Light_L_Off   = "laminar/B738/switch/land_lights_left_off"    -- command
  local LDL_Light_R_On    = "laminar/B738/switch/land_lights_right_on"    -- command
  local LDL_Light_R_Off   = "laminar/B738/switch/land_lights_right_off"   -- command

  local RWY_Light_L       = "laminar/B738/toggle_switch/rwy_light_left"
  local RWY_Light_R       = "laminar/B738/toggle_switch/rwy_light_right"
  local RWY_Lights        = get(RWY_Light_L) + get(RWY_Light_R)
    
  local SeatBelt          = get(FSB_Status)
  local Landing_Lights    = LDL_Light[6] + LDL_Light[7]
  local Taxi_Light        = dataref_table("laminar/B738/lights_sw")
  local Taxi_On           = "laminar/B738/toggle_switch/taxi_light_brightness_pos_dn"
  local Taxi_Off          = "laminar/B738/toggle_switch/taxi_light_brightness_pos_up"
  local Logo_Light        = "laminar/B738/toggle_switch/logo_light"

  if Flight_Level() > 100 then
    ---------------------------------------------------------
    -- Turning Off Fasten Seat Belts if Flight Level > 100 --
    ---------------------------------------------------------
    Number = 3
    if SeatBelt > 1 then
      if  SeatBelt == 2 then
        Chrono = os.clock() + Delay
        Line[Number] = ("%s / Off (> FL100)"):format(Msg_FSB_Auto)
      else
        Chrono = os.clock() + Delay
        Line[Number] = Msg_FSB_Off
      end
      command_once(FSB_Off)
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ------------------------------------------------------
    -- Turning Off Landing Lights if Flight Level > 100 --
    ------------------------------------------------------
    if Landing_Lights > 0 then
      command_once(LDL_Light_L_Off)
      command_once(LDL_Light_R_Off)
      Line[Number+1] = Msg_LDG_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end

  if Flight_Level() < 100 then
    ---[[
    Number = 7
    local Nav_Freq = get("laminar/B738/nav/mmr_channel")/100
    local Act_Value = get("sim/cockpit2/radios/actuators/nav1_frequency_hz")/100

    local Ils_Vor = get("laminar/B738/nav/nav1_type") + 1
    local Type = {" ILS"," VOR",""," ILS"}
    local Mmr = {"VOR","ILS"}
    local Nav_Mode = get("laminar/B738/nav/mmr_act_mode") + 1
    if Nav_Freq ~= Act_Value then
      --Line[Number] = "Test"
      Line[Number] = ("Active Nav1 is %s %.2f Mhz in pedestal - Set to%s %.2f Mhz"):format( Mmr[Nav_Mode] , Nav_Freq, Type[Ils_Vor] , Act_Value )
    else
      Line[Number] = ""
    end
    --]]
    --------------------------------------------------------
    -- Turning On Fasten Seat Belts if Flight Level < 100 --
    --------------------------------------------------------
    Number = 3
    if SeatBelt < 1 then
      if SeatBelt == 0 then
        Chrono = os.clock() + Delay
        Line[Number] = ("%s / On (< FL100)"):format(Msg_FSB_Auto)
      else
        Chrono = os.clock() + Delay
        Line[Number] = Msg_FSB_On
      end
      command_once(FSB_On)
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------------------
    -- Turning On Landing Lights if Flight Level < 100 --
    -----------------------------------------------------
    if Landing_Lights < 2 then
      command_once(LDL_Light_L_On)
      command_once(LDL_Light_R_On)
      Line[Number+1] = Msg_LDG_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end
  --]]
  ---[[
  if Gear_Down() == true then
    -------------------------------------------
    -- Turning On Runway Lights if Gear Down --
    -------------------------------------------
    Number = 5
    if RWY_Lights < 2 then
      set(RWY_Light_L,1)
      set(RWY_Light_R,1)
      Line[Number] = Msg_RWY_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------
    -- Turning On Taxi Lights if Gear Down --
    -----------------------------------------
    ---[[
    if Taxi_Light[3] < 2 then
      command_once(Taxi_On)
      Line[Number+1] = Msg_Taxi_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
    --]]
  end
  --]]
  if Gear_Up() == true then
    ------------------------------------------
    -- Turning Off Runway Lights if Gear Up --
    ------------------------------------------
    Number = 5
    if RWY_Lights > 0 then
      set(RWY_Light_L,0)
      set(RWY_Light_R,0)
      Line[Number] = Msg_RWY_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ----------------------------------------
    -- Turning Off Taxi Lights if Gear Up --
    ----------------------------------------
    ---[[
    if Taxi_Light[3] > 0 then
      command_once(Taxi_Off)
      Line[Number+1] = Msg_Taxi_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
    --]]
  end
  --]]
end
function Manage_Airbus_Toliss()
  local FSB_Off           = "toliss_airbus/lightcommands/FSBSignOff"  -- command
  local FSB_On            = "toliss_airbus/lightcommands/FSBSignOn"   -- command
  local FSB_Status        = "AirbusFBW/SeatBeltSignsOn"               -- dataref 0 = Off - 1 = On
  local SeatBelt          = get(FSB_Status)

  local LDL_Light         = dataref_table("AirbusFBW/OHPLightSwitches")   -- index 4 & 5
  local LDL_Light_L_On    = "toliss_airbus/lightcommands/LLandLightUp"    -- command
  local LDL_Light_L_Off   = "toliss_airbus/lightcommands/LLandLightDown"  -- command
  local LDL_Light_R_On    = "toliss_airbus/lightcommands/RLandLightUp"    -- command
  local LDL_Light_R_Off   = "toliss_airbus/lightcommands/RLandLightDown"  -- command
  local Landing_Lights    = LDL_Light[4] + LDL_Light[5]

  local RWY_Light_On      = "toliss_airbus/lightcommands/TurnoffLightOn"
  local RWY_Light_Off     = "toliss_airbus/lightcommands/TurnoffLightOff"
  local RWY_Lights        = LDL_Light[6]
    
  local Taxi_Light        = LDL_Light[3]
  local Taxi_On           = "toliss_airbus/lightcommands/NoseLightUp"
  local Taxi_Off          = "toliss_airbus/lightcommands/NoseLightDown"

  if Flight_Level() > 100 then
    ---------------------------------------------------------
    -- Turning Off Fasten Seat Belts if Flight Level > 100 --
    ---------------------------------------------------------
    Number = 3
    if SeatBelt > 0 then
      command_once(FSB_Off)
      Chrono = os.clock() + Delay
      Line[Number] = Msg_FSB_Off
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ------------------------------------------------------
    -- Turning Off Landing Lights if Flight Level > 100 --
    ------------------------------------------------------
    if Landing_Lights > 0 then
      command_once(LDL_Light_L_Off)
      command_once(LDL_Light_R_Off)
      Line[Number+1] = Msg_LDG_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end

  if Flight_Level() < 100 then
    --------------------------------------------------------
    -- Turning On Fasten Seat Belts if Flight Level < 100 --
    --------------------------------------------------------
    Number = 3
    if SeatBelt < 1 then
      command_once(FSB_On)
      Chrono = os.clock() + Delay
      Line[Number] = Msg_FSB_On
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------------------
    -- Turning On Landing Lights if Flight Level < 100 --
    -----------------------------------------------------
    if Landing_Lights < 4 then
      command_once(LDL_Light_L_On)
      command_once(LDL_Light_R_On)
      Line[Number+1] = Msg_LDG_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end

  if Gear_Down() == true then
    -------------------------------------------
    -- Turning On Runway Lights if Gear Down --
    -------------------------------------------
    Number = 5
    if RWY_Lights == 0 then
      command_once(RWY_Light_On)
      Line[Number] = Msg_RWY_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------
    -- Turning On Taxi Lights if Gear Down --
    -----------------------------------------
    if Taxi_Light < 2 then
      command_once(Taxi_On)
      Line[Number+1] = Msg_Taxi_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end
  if Gear_Up() == true then
    ------------------------------------------
    -- Turning Off Runway Lights if Gear Up --
    ------------------------------------------
    Number = 5
    if RWY_Lights > 0 then
      command_once(RWY_Light_Off)
      Line[Number] = Msg_RWY_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ----------------------------------------
    -- Turning Off Taxi Lights if Gear Up --
    ----------------------------------------
    if Taxi_Light > 0 then
      command_once(Taxi_Off)
      Line[Number+1] = Msg_Taxi_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end
end
function Manage_Legacy_650()
  local FSB_Off           = "sim/systems/seatbelt_sign_toggle"  -- command
  local FSB_On            = "sim/systems/seatbelt_sign_toggle"   -- command
  local FSB_Status        = "sim/cockpit2/switches/fasten_seat_belts"               -- dataref 0 = Off - 1 = On
  local SeatBelt          = get(FSB_Status)

  local LDL_Light         = dataref_table("sim/cockpit2/switches/landing_lights_switch")   -- index 1 & 2
  local LDL_Light_L_On    = "toliss_airbus/lightcommands/LLandLightUp"    -- command
  local LDL_Light_L_Off   = "toliss_airbus/lightcommands/LLandLightDown"  -- command
  local LDL_Light_R_On    = "toliss_airbus/lightcommands/RLandLightUp"    -- command
  local LDL_Light_R_Off   = "toliss_airbus/lightcommands/RLandLightDown"  -- command
  local Landing_Lights    = LDL_Light[1] + LDL_Light[2]    -- 10 + 10

--    local RWY_Light_On      = "toliss_airbus/lightcommands/TurnoffLightOn"
--    local RWY_Light_Off     = "toliss_airbus/lightcommands/TurnoffLightOff"
--    local RWY_Lights        = LDL_Light[6]
    
  local Taxi_Light        = get("sim/cockpit2/switches/taxi_light_on")
--    local Taxi_On           = "toliss_airbus/lightcommands/NoseLightUp"
--    local Taxi_Off          = "toliss_airbus/lightcommands/NoseLightDown"

  if Flight_Level() > 100 then
    ---------------------------------------------------------
    -- Turning Off Fasten Seat Belts if Flight Level > 100 --
    ---------------------------------------------------------
    Number = 3
    if SeatBelt > 0 then
      command_once(FSB_Off)
      Chrono = os.clock() + Delay
      Line[Number] = Msg_FSB_Off
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ------------------------------------------------------
    -- Turning Off Landing Lights if Flight Level > 100 --
    ------------------------------------------------------
    if Landing_Lights > 0 then
      set_array("sim/cockpit2/switches/landing_lights_switch",1,0)
      set_array("sim/cockpit2/switches/landing_lights_switch",2,0)
      Line[Number+1] = Msg_LDG_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end

  if Flight_Level() < 100 then
    --------------------------------------------------------
    -- Turning On Fasten Seat Belts if Flight Level < 100 --
    --------------------------------------------------------
    Number = 3
    if SeatBelt < 1 then
      command_once(FSB_On)
      Chrono = os.clock() + Delay
      Line[Number] = Msg_FSB_On
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------------------
    -- Turning On Landing Lights if Flight Level < 100 --
    -----------------------------------------------------
    if Landing_Lights < 20 then
      set_array("sim/cockpit2/switches/landing_lights_switch",1,10)
      set_array("sim/cockpit2/switches/landing_lights_switch",2,10)
      Line[Number+1] = Msg_LDG_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end
    ---[[
--    set_array("sim/cockpit2/switches/landing_lights_switch",0,0)
--    set_array("sim/cockpit2/switches/landing_lights_switch",0,5)

  if Gear_Down() == true then
    -------------------------------------------
    -- Turning On Runway Lights if Gear Down --
    -------------------------------------------
    Number = 5
    if LDL_Light[0] == 0 then
      set_array("sim/cockpit2/switches/landing_lights_switch",0,5)
      Line[Number] = Msg_RWY_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------
    -- Turning On Taxi Lights if Gear Down --
    -----------------------------------------
    if Taxi_Light < 3 then
      set("sim/cockpit2/switches/taxi_light_on",3)
      Line[Number+1] = Msg_Taxi_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end
  if Gear_Up() == true then
    ------------------------------------------
    -- Turning Off Runway Lights if Gear Up --
    ------------------------------------------
    Number = 5
    if LDL_Light[0] == 5 then
      set_array("sim/cockpit2/switches/landing_lights_switch",0,0)
      Line[Number] = Msg_RWY_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ----------------------------------------
    -- Turning Off Taxi Lights if Gear Up --
    ----------------------------------------
    if Taxi_Light > 0 then
      set("sim/cockpit2/switches/taxi_light_on",0)
      Line[Number+1] = Msg_Taxi_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end
  --]]
end
function Manage_Phenom_300()
    local FSB_Status        = "aerobask/lights/sw_signs"
    local SeatBelt          = get(FSB_Status)

    local LDL_Light         = "aerobask/lights/sw_ldg_taxi" 
    local LDL_Light_On      = "aerobask/lights/ldg_taxi_up"     -- command
    local LDL_Light_Off     = "aerobask/lights/ldg_taxi_dn"    -- command
    local Landing_Lights    = get(LDL_Light)

--    local RWY_Light_L       = "laminar/B738/toggle_switch/rwy_light_left"
--    local RWY_Light_R       = "laminar/B738/toggle_switch/rwy_light_right"
--    local RWY_Lights        = get(RWY_Light_L) + get(RWY_Light_R)
    
--    local Taxi_Light        = dataref_table("laminar/B738/lights_sw")
--    local Taxi_On           = "laminar/B738/toggle_switch/taxi_light_brightness_pos_dn"
--    local Taxi_Off          = "laminar/B738/toggle_switch/taxi_light_brightness_pos_up"


    ---[[
    if Flight_Level() > 100 then
        ---------------------------------------------------------
        -- Turning Off Fasten Seat Belts if Flight Level > 100 --
        ---------------------------------------------------------
        if SeatBelt > 0 then
            set(FSB_Status,SeatBelt - 1)
            Chrono = os.clock() + Delay 
            Line[2] = Msg_FSB_Off
        else
            if os.clock() > Chrono then Line[2] = "" end    
        end
        ------------------------------------------------------
        -- Turning Off Landing Lights if Flight Level > 100 --
        ------------------------------------------------------
        ---[[
        if Landing_Lights > 0 then
            command_once(LDL_Light_Off)
            Line[3] = Msg_LDG_Off
            Chrono = os.clock() + Delay 
        else
            if os.clock() > Chrono then Line[3] = "" end    
        end
        --]]
    end
    --]]
    ---[[
    if Flight_Level() < 100 then
        --------------------------------------------------------
        -- Turning On Fasten Seat Belts if Flight Level < 100 --
        --------------------------------------------------------
        if SeatBelt < 2 then
            set(FSB_Status,SeatBelt + 1)
            Chrono = os.clock() + Delay 
            Line[2] = Msg_FSB_On
        else
            if os.clock() > Chrono then Line[2] = "" end    
        end
        -----------------------------------------------------
        -- Turning On Landing Lights if Flight Level < 100 --
        -----------------------------------------------------
        ---[[
        if Landing_Lights < 2 then
            command_once(LDL_Light_On)
            Line[3] = Msg_LDG_On
            Chrono = os.clock() + Delay 
        else
            if os.clock() > Chrono then Line[3] = "" end    
        end
        --]]
    end
    --]]
    --[[
    if Gear_Down() == true then
        -------------------------------------------
        -- Turning On Runway Lights if Gear Down --
        -------------------------------------------
        if RWY_Lights < 2 then
            set(RWY_Light_L,1)
            set(RWY_Light_R,1)
            Line[3] = Msg_RWY_On
            Chrono = os.clock() + Delay 
        else
            if os.clock() > Chrono then Line[3] = "" end    
        end
        -----------------------------------------
        -- Turning On Taxi Lights if Gear Down --
        -----------------------------------------
        --[[
        if Taxi_Light[3] < 2 then
            command_once(Taxi_On)
            Line[4] = Msg_Taxi_On
            Chrono = os.clock() + Delay 
        else
            if os.clock() > Chrono then Line[4] = "" end    
        end
        --]]
    --end
    --]]
    --[[
    if Gear_Up() == true then
        ------------------------------------------
        -- Turning Off Runway Lights if Gear Up --
        ------------------------------------------
        if RWY_Lights > 0 then
            set(RWY_Light_L,0)
            set(RWY_Light_R,0)
            Line[3] = Msg_RWY_Off
            Chrono = os.clock() + Delay 
        else
            if os.clock() > Chrono then Line[3] = "" end    
        end
        ----------------------------------------
        -- Turning Off Taxi Lights if Gear Up --
        ----------------------------------------
        ---[[
        if Taxi_Light[3] > 0 then
            command_once(Taxi_Off)
            Line[4] = Msg_Taxi_Off
            Chrono = os.clock() + Delay 
        else
            if os.clock() > Chrono then Line[4] = "" end    
        end
        --]]
    --end
    --]]
end
function Manage_Saab340()
  local FSB_Status        = "sim/cockpit/switches/fasten_seat_belts"
  local SMO_Status        = "sim/cockpit/switches/no_smoking"
  local SeatBelt          = get(FSB_Status)
  local Smoke             = get(SMO_Status)
  local LDL_Light         = "sim/cockpit2/switches/landing_lights_switch"
  local LDL_Light_On      = "sim/lights/landing_lights_on"     -- command
  local LDL_Light_Off     = "sim/lights/landing_lights_off"    -- command
  local Landing_Lights    = get(LDL_Light,1) + get(LDL_Light,2)

--    local RWY_Light_L       = "sim/cockpit2/switches/"
--    local RWY_Light_R       = "sim/cockpit2/switches/"
--    local RWY_Lights        = get(RWY_Light_L) + get(RWY_Light_R)

  local Taxi_Light        = get("sim/cockpit2/switches/taxi_light_on")
  local Taxi_On           = "sim/lights/taxi_lights_on"
  local Taxi_Off          = "sim/lights/taxi_lights_off"


    ---[[
  if Flight_Level() > 100 then
    ----------------------------------------------------------------------
    -- Turning Off Fasten Seat Belts & No Smoking if Flight Level > 100 --
    ----------------------------------------------------------------------
    if SeatBelt > 0 or Smoke > 0 then
      set(FSB_Status,0)
      set(SMO_Status,0)
      Chrono = os.clock() + Delay
      Line[2] = Msg_FSB_Off
    else
      if os.clock() > Chrono then Line[2] = "" end
    end
    ------------------------------------------------------
    -- Turning Off Landing Lights if Flight Level > 100 --
    ------------------------------------------------------
    ---[[
    if Landing_Lights > 0 then
      command_once(LDL_Light_Off)
      Line[3] = Msg_LDG_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[3] = "" end
    end
    --]]
  end
    --]]
    ---[[
  if Flight_Level() < 100 then
    --------------------------------------------------------
    -- Turning On Fasten Seat Belts if Flight Level < 100 --
    --------------------------------------------------------
    if SeatBelt < 1 or Smoke < 1 then
      set(FSB_Status,1)
      set(SMO_Status,1)
      Chrono = os.clock() + Delay
      Line[2] = Msg_FSB_On
    else
      if os.clock() > Chrono then Line[2] = "" end
    end
    -----------------------------------------------------
    -- Turning On Landing Lights if Flight Level < 100 --
    -----------------------------------------------------
    ---[[
    if Landing_Lights < 1 then
      command_once(LDL_Light_On)
      Line[3] = Msg_LDG_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[3] = "" end
    end
    --]]
  end
    --]]
    ---[[
    if Gear_Down() == true then
      -------------------------------------------
      -- Turning On Runway Lights if Gear Down --
      -------------------------------------------
      --[[
      if RWY_Lights < 2 then
        set(RWY_Light_L,1)
        set(RWY_Light_R,1)
        Line[3] = Msg_RWY_On
        Chrono = os.clock() + Delay
      else
        if os.clock() > Chrono then Line[3] = "" end
      end
      --]]
      -----------------------------------------
      -- Turning On Taxi Lights if Gear Down --
      -----------------------------------------
      ---[[
      if Taxi_Light < 1 then
        command_once(Taxi_On)
        Line[4] = Msg_Taxi_On
        Chrono = os.clock() + Delay
      else
        if os.clock() > Chrono then Line[4] = "" end
      end
      --]]
    end
    --]]
    ---[[
    if Gear_Up() == true then
      ------------------------------------------
      -- Turning Off Runway Lights if Gear Up --
      ------------------------------------------
      --[[
      if RWY_Lights > 0 then
        set(RWY_Light_L,0)
        set(RWY_Light_R,0)
        Line[3] = Msg_RWY_Off
        Chrono = os.clock() + Delay
      else
        if os.clock() > Chrono then Line[3] = "" end
      end
      --]]
      ----------------------------------------
      -- Turning Off Taxi Lights if Gear Up --
      ----------------------------------------
      ---[[
      if Taxi_Light > 0 then
        command_once(Taxi_Off)
        Line[4] = Msg_Taxi_Off
        Chrono = os.clock() + Delay
      else
        if os.clock() > Chrono then Line[4] = "" end
      end
      --]]
    end
    --]]

end
function Manage_Airbus_A359_FF()
  local FSB_Off           = "laminar/B738/toggle_switch/seatbelt_sign_up" -- command
  local FSB_On            = "laminar/B738/toggle_switch/seatbelt_sign_dn" -- command
  local FSB_Status        = "laminar/B738/toggle_switch/seatbelt_sign_pos"        -- dataref 0 = Off - 1 = On

--  local LDL_Light         = dataref_table("laminar/B738/lights_sw")       -- index 6 & 7
  local LDL_Light_L_On    = "laminar/B738/switch/land_lights_left_on"     -- command
  local LDL_Light_L_Off   = "laminar/B738/switch/land_lights_left_off"    -- command
  local LDL_Light_R_On    = "laminar/B738/switch/land_lights_right_on"    -- command
  local LDL_Light_R_Off   = "laminar/B738/switch/land_lights_right_off"   -- command

  local RWY_Light_L       = "laminar/B738/toggle_switch/rwy_light_left"
  local RWY_Light_R       = "laminar/B738/toggle_switch/rwy_light_right"
--  local RWY_Lights        = get(RWY_Light_L) + get(RWY_Light_R)

--  local SeatBelt          = get(FSB_Status)
--  local Landing_Lights    = LDL_Light[6] + LDL_Light[7]
--  local Taxi_Light        = dataref_table("laminar/B738/lights_sw")
  local Taxi_On           = "laminar/B738/toggle_switch/taxi_light_brightness_pos_dn"
  local Taxi_Off          = "laminar/B738/toggle_switch/taxi_light_brightness_pos_up"
  local Logo_Light        = "laminar/B738/toggle_switch/logo_light"
  --[[
  if Flight_Level() > 100 then
    ---------------------------------------------------------
    -- Turning Off Fasten Seat Belts if Flight Level > 100 --
    ---------------------------------------------------------
    Number = 3
    if SeatBelt > 1 then
      if  SeatBelt == 2 then
        Chrono = os.clock() + Delay
        Line[Number] = ("%s / Off (> FL100)"):format(Msg_FSB_Auto)
      else
        Chrono = os.clock() + Delay
        Line[Number] = Msg_FSB_Off
      end
      command_once(FSB_Off)
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ------------------------------------------------------
    -- Turning Off Landing Lights if Flight Level > 100 --
    ------------------------------------------------------
    if Landing_Lights > 0 then
      command_once(LDL_Light_L_Off)
      command_once(LDL_Light_R_Off)
      Line[Number+1] = Msg_LDG_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end

  if Flight_Level() < 100 then
    --[[
    Number = 7
    local Nav_Freq = get("laminar/B738/nav/mmr_channel")/100
    local Act_Value = get("sim/cockpit2/radios/actuators/nav1_frequency_hz")/100

    local Ils_Vor = get("laminar/B738/nav/nav1_type") + 1
    local Type = {" ILS"," VOR",""," ILS"}
    local Mmr = {"VOR","ILS"}
    local Nav_Mode = get("laminar/B738/nav/mmr_act_mode") + 1
    if Nav_Freq ~= Act_Value then
      --Line[Number] = "Test"
      Line[Number] = ("Active Nav1 is %s %.2f Mhz in pedestal - Set to%s %.2f Mhz"):format( Mmr[Nav_Mode] , Nav_Freq, Type[Ils_Vor] , Act_Value )
    else
      Line[Number] = ""
    end
    --]]
    --------------------------------------------------------
    -- Turning On Fasten Seat Belts if Flight Level < 100 --
    --------------------------------------------------------
    --[[
    Number = 3
    if SeatBelt < 1 then
      if SeatBelt == 0 then
        Chrono = os.clock() + Delay
        Line[Number] = ("%s / On (< FL100)"):format(Msg_FSB_Auto)
      else
        Chrono = os.clock() + Delay
        Line[Number] = Msg_FSB_On
      end
      command_once(FSB_On)
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------------------
    -- Turning On Landing Lights if Flight Level < 100 --
    -----------------------------------------------------
    if Landing_Lights < 2 then
      command_once(LDL_Light_L_On)
      command_once(LDL_Light_R_On)
      Line[Number+1] = Msg_LDG_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end
  end

  ---[[
  if Gear_Down() == true then
    -------------------------------------------
    -- Turning On Runway Lights if Gear Down --
    -------------------------------------------
    Number = 5
    if RWY_Lights < 2 then
      set(RWY_Light_L,1)
      set(RWY_Light_R,1)
      Line[Number] = Msg_RWY_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    -----------------------------------------
    -- Turning On Taxi Lights if Gear Down --
    -----------------------------------------
    --[[
    if Taxi_Light[3] < 2 then
      command_once(Taxi_On)
      Line[Number+1] = Msg_Taxi_On
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end

  end

  if Gear_Up() == true then
    ------------------------------------------
    -- Turning Off Runway Lights if Gear Up --
    ------------------------------------------
    Number = 5
    if RWY_Lights > 0 then
      set(RWY_Light_L,0)
      set(RWY_Light_R,0)
      Line[Number] = Msg_RWY_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number] = "" end
    end
    ----------------------------------------
    -- Turning Off Taxi Lights if Gear Up --
    ----------------------------------------
    ---[[
    if Taxi_Light[3] > 0 then
      command_once(Taxi_Off)
      Line[Number+1] = Msg_Taxi_Off
      Chrono = os.clock() + Delay
    else
      if os.clock() > Chrono then Line[Number+1] = "" end
    end

  end
  --]]
end
------------------
-- Main Section --
------------------
Aircraft_Type()

add_macro("Toggle Assistant","FTB_Assistant = not FTB_Assistant")
create_command("FlyWithLua/FlyingToolBox/Assistant/Toggle", "Toggle Assistant", "FTB_Assistant = not FTB_Assistant", "", "")
do_often("FTB_Assistant_CallBack()")
do_every_draw("Display_Msg()")

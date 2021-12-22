----------------------------------
-- Flying Toolbox by FlyingPapy --
----------------------------------
-- v0.96 - 2021/10/18
------------------------------------------------
-- Power Monitoring for VSKYLABS Contraventus --
------------------------------------------------
-- Copy this file in folder
-- ...X-Plane 11/Resources/plugins/FlyWithLua/Scripts
-- Warning: Activated only if battery is on

if PLANE_ICAO ~= "CV002" then return end -- exit if not the right plane

-----------------------------------------------
-- Initalization aera, parameters assignment --
-----------------------------------------------
local FTB_Contraventus  = true  -- activate main display if true
local FTB_Agl           = true  -- activate AGL altitude display if true
local Line              = 0
-- end of user assignment
local Version           = "0.96"
local Init_Y            = 24
local Full              = 300 -- Battery capacity

local Battery   = dataref_table("sim/cockpit/electrical/battery_array_on")
local Capacity  = dataref_table("sim/cockpit/electrical/battery_charge_watt_hr")
local Intensity = dataref_table("sim/cockpit2/electrical/battery_amps")
local Voltage   = dataref_table("sim/cockpit2/electrical/battery_voltage_actual_volts")
local Propeller = dataref_table("sim/cockpit2/engine/indicators/prop_speed_rpm")

function FTB_Contraventus_CallBack()
  if FTB_Contraventus == true then
    if Battery[0] > 0 then FTB_Contraventus_Display(Line) end
  end
end

function CV002_Invert()
  FTB_Contraventus = not FTB_Contraventus
end

function FTB_Contraventus_Display(num_line)
  num_line = num_line or 0    -- default value

  -- OpenGL graphics state initialization
  -- use only in do_every_draw()
  XPLMSetGraphicsState(0, -- inEnableFog
                       0, -- inNumberTexUnits
                       0, -- inEnableLighting
                       1, -- inEnableAlphaTesting
                       1, -- inEnableAlphaBlending
                       0, -- inEnableDepthTesting
                       0  -- inEnableDepthWriting
                      )

  local Y = SCREEN_HIGHT - Init_Y - num_line*25
  local Distance  = get("sim/flightmodel/controls/dist")/1851.851 -- convert meter to nautical
  local Ground    = get("sim/flightmodel/position/y_agl")/0.3048  -- convert meter to feet
  local Landed    = get("sim/flightmodel/failures/onground_all") > 0 and true or false
  local Info_Txt  = "VSKYLABS Contraventus"
  local Remain = 0
  local Mode    = ""

  if Propeller[0] > 1e-1 then
    Info_Txt = Propeller[0] < 10 and ("%s - Prop %.1f rpm"):format(Info_Txt, Propeller[0]) or ("%s - Prop %.0f rpm"):format(Info_Txt, Propeller[0])
  end

  Info_Txt = Capacity[0] < Full and ("%s - Battery %.1f%%"):format(Info_Txt, Capacity[0]*100/Full) or ("%s - Full Battery"):format(Info_Txt)
  
  if Intensity[0] > 0 then
    Mode = "- Charge"
    Remain = (Full - Capacity[0])*60/Intensity[0]/Voltage[0]
    Remain = Remain >= 1 and ("%i min"):format(Remain) or "<1 min" 
    Info_Txt = ("%s %s - [%s]"):format(Info_Txt, Mode, Remain)
  elseif Intensity[0] < 0 then
    Mode = "- Drain"
    Remain = math.abs((Capacity[0])*60/Intensity[0]/Voltage[0])
    Remain = Remain >= 1 and ("%i min"):format(Remain) or "<1 min" 
    Info_Txt = ("%s %s - [%s]"):format(Info_Txt, Mode, Remain)
  end
  
  Info_Txt = ("%s - %.1f nm"):format(Info_Txt, Distance) -- traveled distance
  
  if FTB_Agl == true then
    if Landed == true then
      Info_Txt = ("%s - Landed"):format(Info_Txt)
    else
      if      Ground < 1e1 then Info_Txt = ("%s - %.1f ft AGL"):format(Info_Txt, Ground)
      elseif  Ground < 1e2 then Info_Txt = ("%s - %.0f ft AGL"):format(Info_Txt, Ground)
      elseif  Ground < 1e3 then Info_Txt = ("%s - %.0f0 ft AGL"):format(Info_Txt, Ground/10)
      else    Info_Txt = ("%s - %.0f00 ft AGL"):format(Info_Txt, Ground/100) end
    end
  end

  local Larg_Txt = measure_string(Info_Txt,"Helvetica_18")
  local X = (SCREEN_WIDTH - Larg_Txt)/2

  glColor4f(0,0,0,0.3)
  glRectf(X - 5, Y - 5, X + measure_string(Info_Txt,"Helvetica_18") + 5, Y + 20)
  glColor4f(0,0,0,1) -- set Black for 3D shadow effect
  draw_string_Helvetica_18(X + 1, Y - 1, Info_Txt)

  if Intensity[0] < 0 then
    glColor4f(1,0.4,0.4,1) -- set red for discharge
  elseif Intensity[0] > 0 then
    glColor4f(0.4,1,0.4,1) -- set green for charge
  else
    glColor4f(1,1,1,1) -- set white
  end
  draw_string_Helvetica_18(X, Y, Info_Txt)
end

function Duration(value,mode)
  -- value = 0 < seconds < 99h59:59
  -- optionnal mode = 1 for short format
  -- hh'h'mm if value >= 3600 seconds
  -- mm':'ss if value < 3600 seconds
  ----------------------------
  mode = mode or 0
  local hh,mm,ss
  value = tonumber(value)
  if type(value) == "number" then value = math.floor(value) else return nil end
  if value < 0 or value > 100*60*60 - 1 then return "" end
  ss = value % 60
  hh = math.floor(value / 3600); 
  mm = math.floor(value / 60) % 60 ;
  if mode > 0 then
    if value <= 3600 then
      return ("%02d:%02d"):format(mm, ss) -- short format (< 1h - ex 45:30)
    else
      return ("%02dh%02d"):format(hh, mm) -- in format hh'h'mm (ex 15h30)
    end
  else
    return ("%02dh%02d:%02d"):format(hh, mm, ss) -- in format hh'h'mm:ss (ex 15h30:00)
  end
end

add_macro("VSKYLABS Contraventus","CV002_Invert()")
create_command("FlyWithLua/FlyingToolBox/VSKYLABS-Contraventus/Toggle", "Toggle Monitor", "CV002_Invert()", "", "")

do_every_draw("FTB_Contraventus_CallBack()")

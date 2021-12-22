--------------------------------------------
----------- Created by KAPTEJNLN -----------
--------------------------------------------
----- V2.6.2 Modified by FlyingPapy --------
--------------------------------------------
local FTB_ln_ap1 = DataRef("FTB_ln_nav", "sim/cockpit/autopilot/mode_hnav", "readonly")
local FTB_ln_ap2 = DataRef("FTB_ln_at", "sim/cockpit2/autopilot/autothrottle_on", "readonly")
local FTB_ln_ap3 = DataRef("FTB_ln_flc", "sim/cockpit/autopilot/airspeed_mode", "readonly")
local FTB_ln_ap4 = DataRef("FTB_ln_hdgi", "sim/cockpit/autopilot/heading_mode", "readonly")
local FTB_ln_ap5 = DataRef("FTB_ln_alti","sim/cockpit2/autopilot/altitude_hold_status", "readonly")
local FTB_ln_ap6 = DataRef("FTB_ln_vsi","sim/cockpit2/autopilot/altitude_mode", "readonly")
local FTB_ln_ap7 = DataRef("FTB_ln_app", "sim/cockpit2/autopilot/approach_status", "readonly")
local FTB_ln_ap8 = DataRef("FTB_ln_bc", "sim/cockpit2/autopilot/backcourse_status", "readonly")
local FTB_ln_ap9 = DataRef("FTB_ln_source", "sim/cockpit/switches/HSI_selector", "readonly")
local FTB_ln_ap10 = DataRef("FTB_ln_source2", "sim/cockpit/switches/HSI_selector2", "writable")
local FTB_ln_ap11 = DataRef("FTB_ln_crs", "sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot", "writable")
local FTB_ln_ap12 = DataRef("FTB_ln_crs2", "sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot", "writable")
local FTB_ln_ap13 = DataRef("FTB_ln_co_crs", "sim/cockpit2/radios/actuators/nav1_obs_deg_mag_copilot", "writable")
local FTB_ln_ap14 = DataRef("FTB_ln_co_crs2", "sim/cockpit2/radios/actuators/nav2_obs_deg_mag_copilot", "writable")
local FTB_ln_ap15 = DataRef("FTB_ln_hdg", "sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "writable")
local FTB_ln_ap16 = DataRef("FTB_ln_hdg2", "sim/cockpit2/autopilot/heading_dial_deg_mag_copilot", "writable")
local FTB_ln_ap17 = DataRef("FTB_ln_alt", "sim/cockpit/autopilot/altitude", "writable")
local FTB_ln_ap18 = DataRef("FTB_ln_vs", "sim/cockpit/autopilot/vertical_velocity", "writable")
local FTB_ln_ap19 = DataRef("FTB_ln_mach_on", "sim/cockpit2/autopilot/airspeed_is_mach", "writable")
local FTB_ln_ap20 = DataRef("FTB_ln_mach_set", "sim/cockpit2/autopilot/airspeed_dial_kts_mach", "writable")
local FTB_ln_ap21 = DataRef("FTB_ln_fd", "sim/cockpit2/autopilot/flight_director_mode", "writable")
local FTB_ln_ap22 = DataRef("FTB_ln_yd", "sim/cockpit2/switches/yaw_damper_on", "writable")
local FTB_ln_show_ap = 0
local FTB_ln_fast = 0
MOUSE_WHEEL_CLICKS = 1
local FTB_ln_x = 50 ---- edit (X_cordinate)
local FTB_ln_y = 220 --- edit (Y_cordinate)
local FTB_ln_crs = 0
local FTB_ln_crs2 = 0

-- define FLC speed like 1.4 * vs
local FLC_Speed = math.ceil(get("sim/aircraft/view/acf_Vs")*1.4/10)*10
--local FTB_ln_mach_set = tonumber(("%.0f"):format(get("sim/aircraft/view/acf_Vs") * 1.4))
FTB_ln_mach_set = FLC_Speed
FTB_ln_hdg = get("sim/flightmodel2/position/mag_psi")
FTB_ln_fd = 1

local Alt_hi_Jet = get("sim/aircraft/overflow/SFC_alt_hi_JET")/0.3048
local Alt_hi_Prp = get("sim/aircraft/overflow/SFC_alt_hi_PRP")/0.3048
local Sfc = math.max(Alt_hi_Jet, Alt_hi_Prp)

FTB_ln_alt = Sfc > 0 and Sfc or 9000
FTB_ln_vs = 0 
---
local FTB_ln_init_x = 10
local FTB_ln_init_y = 220

local Version = " Autopilot v2.6.2 "

if XPLMFindDataRef("thranda/autopilot/APComboScroll") ~= nil then
    dataref("FTB_ln_alb_car", "thranda/autopilot/APComboScroll", "writable")
end

if XPLMFindDataRef("Mustang/cockpit/ap/autopilot") ~= nil then
    dataref("FTB_ln_alb_car", "Mustang/cockpit/ap/autopilot", "writable")
end


function FTB_autopilot_set()
	if MOUSE_X > FTB_ln_init_x and MOUSE_X < FTB_ln_init_x + measure_string(Version) and MOUSE_Y > FTB_ln_init_y and MOUSE_Y < FTB_ln_init_y + 20 and MOUSE_STATUS == "down" then
		FTB_ln_show_ap = 1
	end
	if MOUSE_X > FTB_ln_x + 358 and MOUSE_X < FTB_ln_x + 370 and MOUSE_Y > FTB_ln_y and MOUSE_Y < FTB_ln_y + 35 and MOUSE_STATUS == "down" then
		FTB_ln_show_ap = 0
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 66 and MOUSE_X < FTB_ln_x + 84 and MOUSE_Y > FTB_ln_y and MOUSE_Y < FTB_ln_y + 10 and MOUSE_STATUS == "down" then
		FTB_ln_mach_on = 1
--		FTB_ln_mach_set = 0.50 --> can be set to the mach number you want as reset. To activate remove the 2 dashes  (--) to the left of (FTB_ln_mach_set = 0.50)
	end
	if  FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 66 and MOUSE_X < FTB_ln_x + 84 and MOUSE_Y > FTB_ln_y + 10 and MOUSE_Y < FTB_ln_y + 20 and MOUSE_STATUS == "down" then
		FTB_ln_mach_on = 0
		FTB_ln_mach_set = 250 --> can be set to the speed number you want as reset speed.
	end
  	if  FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x and MOUSE_X < FTB_ln_x + 365 and MOUSE_Y > FTB_ln_y - 5 and MOUSE_Y < FTB_ln_y + 27 and MOUSE_STATUS == "down" then
        	FTB_ln_fast = FTB_ln_fast + 1
	end
----------------- source----------------------
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 50 and MOUSE_X < FTB_ln_x + 100 and MOUSE_Y > FTB_ln_y - 20 and MOUSE_Y < FTB_ln_y - 5 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/hsi_select_gps")
		FTB_ln_source2 = 2
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 100 and MOUSE_X < FTB_ln_x + 150 and MOUSE_Y > FTB_ln_y - 20 and MOUSE_Y < FTB_ln_y - 5 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/hsi_select_nav_1")
		FTB_ln_source2 = 0
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 320 and MOUSE_X < FTB_ln_x + 360 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down" then
		command_once("sim/autopilot/hsi_select_nav_2")
		FTB_ln_source2 = 1
	end
-----------------fd engage -------------------
	if FTB_ln_show_ap == 1 and FDI == 0 and MOUSE_X > FTB_ln_x + 10 and MOUSE_X < FTB_ln_x + 25 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/fdir_on")
		FTB_ln_fd = 1
	end
	if FTB_ln_show_ap == 1 and FDI == 1 and MOUSE_X > FTB_ln_x + 10 and MOUSE_X < FTB_ln_x + 25 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/servos_fdir_off")
		FTB_ln_fd = 0
	end
---------------- ap engage -------------
	if FTB_ln_show_ap == 1 and API == 1 and MOUSE_X > FTB_ln_x + 35 and MOUSE_X < FTB_ln_x + 55 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/servos_on")
		FTB_ln_fd = 2
	end
	if FTB_ln_show_ap == 1 and API == 2 and MOUSE_X > FTB_ln_x + 35 and MOUSE_X < FTB_ln_x + 55 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/fdir_servos_down_one")
		FTB_ln_fd = 1
	end
---------------- yaw damper ----------
	if FTB_ln_show_ap == 1 and YDI == 0 and MOUSE_X > FTB_ln_x + 60 and MOUSE_X < FTB_ln_x + 85 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		FTB_ln_yd = 1
	end
	if FTB_ln_show_ap == 1 and YDI == 1 and MOUSE_X > FTB_ln_x + 60 and MOUSE_X < FTB_ln_x + 85 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then 
		FTB_ln_yd = 0
	end
------------- AT -------------------------------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 85 and MOUSE_X < FTB_ln_x + 110 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/autothrottle_toggle")
	end
-------------- FLC ---------------------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 110 and MOUSE_X < FTB_ln_x + 140 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/level_change")
	end
---------------------- heading ------------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 140 and MOUSE_X < FTB_ln_x + 175 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/heading")
	end
------------- nav engage-------------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 175 and MOUSE_X < FTB_ln_x + 210 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/NAV")
	end
---------------- alt hold---------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 210 and MOUSE_X < FTB_ln_x + 235 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/altitude_hold")
	end
---------------- alt arm---------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 210 and MOUSE_X < FTB_ln_x + 239 and MOUSE_Y > FTB_ln_y - 10 and MOUSE_Y < FTB_ln_y + 55 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/altitude_arm")
	end
------------------- VS --------------------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 240 and MOUSE_X < FTB_ln_x + 264 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down"  then
		command_once("sim/autopilot/vertical_speed_pre_sel")
	end
------------------- APP --------------------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 265 and MOUSE_X < FTB_ln_x + 285 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down" then
		command_once("sim/autopilot/approach")
	end
-------------------- BC ------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_fd >= 1 and MOUSE_X > FTB_ln_x + 285 and MOUSE_X < FTB_ln_x + 315 and MOUSE_Y > FTB_ln_y + 26 and MOUSE_Y < FTB_ln_y + 50 and MOUSE_STATUS == "down" then
		command_once("sim/autopilot/back_course")
	end
     	if FTB_ln_show_ap == 1 and MOUSE_STATUS == "drag" and MOUSE_X > FTB_ln_x and MOUSE_X < FTB_ln_x + 10 and MOUSE_Y > FTB_ln_y and MOUSE_Y < FTB_ln_y + 45 then
		FTB_ln_adjust = 1
	end
    	if FTB_ln_show_ap == 1 and MOUSE_STATUS == "up" then
		FTB_ln_adjust = 0
	end
    	if FTB_ln_show_ap == 1 and MOUSE_STATUS == "drag" and FTB_ln_adjust == 1 then
		FTB_ln_x = MOUSE_X
		FTB_ln_y = MOUSE_Y
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x and MOUSE_X < FTB_ln_x + 370 and MOUSE_Y > FTB_ln_y - 25 and MOUSE_Y < FTB_ln_y + 55 then
		RESUME_MOUSE_CLICK = true
	end
end

do_on_mouse_click("FTB_autopilot_set()")

function FTB_adjust()
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x and MOUSE_X < FTB_ln_x + 370 and MOUSE_Y > FTB_ln_y - 2 and MOUSE_Y < FTB_ln_y + 55 then
		RESUME_MOUSE_WHEEL = true
	end
	if FTB_ln_mach_on == 0 and FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 85 and MOUSE_X < FTB_ln_x + 129 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 0 then
		FTB_ln_mach_set = FTB_ln_mach_set + MOUSE_WHEEL_CLICKS	
	end
	if FTB_ln_mach_on == 0 and FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 85 and MOUSE_X < FTB_ln_x + 129 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 1 then
		FTB_ln_mach_set = FTB_ln_mach_set + (MOUSE_WHEEL_CLICKS * 10)	
	end
	if FTB_ln_mach_on == 1 and FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 75 and MOUSE_X < FTB_ln_x + 129 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 0 then
		FTB_ln_mach_set = FTB_ln_mach_set + (MOUSE_WHEEL_CLICKS / 100)
	end
	if FTB_ln_mach_on == 1 and FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 75 and MOUSE_X < FTB_ln_x + 129 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 1 then
		FTB_ln_mach_set = FTB_ln_mach_set + (MOUSE_WHEEL_CLICKS / 10) 
	end
  set("sim/cockpit/autopilot/airspeed",FTB_ln_mach_set)
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 20 and MOUSE_X < FTB_ln_x + 74 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 0 then
		FTB_ln_crs = math.floor((FTB_ln_crs + 0.5) + MOUSE_WHEEL_CLICKS)
		FTB_ln_co_crs = FTB_ln_crs	
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 20 and MOUSE_X < FTB_ln_x + 74 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 1 then
		FTB_ln_crs = math.floor((FTB_ln_crs + 0.5) + (MOUSE_WHEEL_CLICKS * 10))
		FTB_ln_co_crs = FTB_ln_crs
	end 
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 306 and MOUSE_X < FTB_ln_x + 360 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 0 then
		FTB_ln_crs2 = math.floor((FTB_ln_crs2 + 0.5) + MOUSE_WHEEL_CLICKS)
		FTB_ln_co_crs2 = FTB_ln_crs2	
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 306 and MOUSE_X < FTB_ln_x + 360 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 1 then
		FTB_ln_crs2 = math.floor((FTB_ln_crs2 + 0.5) + (MOUSE_WHEEL_CLICKS * 10))
		FTB_ln_co_crs2 = FTB_ln_crs2
	end 
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 130 and MOUSE_X < FTB_ln_x + 185 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 0 then
		FTB_ln_hdg = math.floor((FTB_ln_hdg + 0.5) + MOUSE_WHEEL_CLICKS)
		FTB_ln_hdg2 = FTB_ln_hdg	
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 130 and MOUSE_X < FTB_ln_x + 185 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 1 then
		FTB_ln_hdg = math.floor((FTB_ln_hdg + 0.5) + (MOUSE_WHEEL_CLICKS * 10))
		FTB_ln_hdg2 = FTB_ln_hdg
	end	
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 190 and MOUSE_X < FTB_ln_x + 250 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 0 then
		FTB_ln_alt = FTB_ln_alt + (MOUSE_WHEEL_CLICKS * 100)
		FTB_ln_alb_car = (FTB_ln_alt / 100)	
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 190 and MOUSE_X < FTB_ln_x + 250 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 1 then
		FTB_ln_alt = FTB_ln_alt + (MOUSE_WHEEL_CLICKS * 1000)
		FTB_ln_alb_car = (FTB_ln_alt / 100)	
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 251 and MOUSE_X < FTB_ln_x + 305 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 0 then
		FTB_ln_vs = FTB_ln_vs + (MOUSE_WHEEL_CLICKS * 100)	
	end
	if FTB_ln_show_ap == 1 and MOUSE_X > FTB_ln_x + 251 and MOUSE_X < FTB_ln_x + 305 and MOUSE_Y > FTB_ln_y - 3 and MOUSE_Y < FTB_ln_y + 20 and FTB_ln_fast == 1 then
		FTB_ln_vs = FTB_ln_vs + (MOUSE_WHEEL_CLICKS * 1000)	
	end		 	
end

do_on_mouse_wheel("FTB_adjust()")

function FTB_display()
    
	if FTB_ln_show_ap == 1 and FTB_ln_alti == 0 and FTB_ln_flc == 13 or FTB_ln_alti == 0 and FTB_ln_vsi == 4 then
		command_once("sim/autopilot/altitude_arm")
	end
	if FTB_ln_show_ap == 1 and FTB_ln_crs <= 0 then 
		FTB_ln_crs = FTB_ln_crs + 360
	end
	if FTB_ln_show_ap == 1 and FTB_ln_crs >= 360 then 
		FTB_ln_crs = FTB_ln_crs - 360
	end
	if FTB_ln_show_ap == 1 and FTB_ln_crs2 <= 0 then 
		FTB_ln_crs2 = FTB_ln_crs2 + 360
	end
	if FTB_ln_show_ap == 1 and FTB_ln_crs2 >= 360 then 
		FTB_ln_crs2 = FTB_ln_crs2 - 360
	end
	if FTB_ln_alt <= 0 then 
		FTB_ln_alt = 0
	end
	if FTB_ln_alt >= 99000 then 
		FTB_ln_alt = 99000
	end
end

do_often("FTB_display()")

function FTB_dis()
    local x1,y1,x2,y2,text
    --
    text = Version
    x1 = FTB_ln_init_x
    y1 = FTB_ln_init_y
    x2 = x1 + measure_string(text)
    y2 = y1 + 19
    --
	if FTB_ln_show_ap == 0 and MOUSE_X < x2 and MOUSE_Y < y2 then
		glColor4f(0,0,0,0.5)
--       	glRectf(FTB_ln_init_x, FTB_ln_init_y, FTB_ln_init_x + 90, FTB_ln_init_y + 19)
       	glRectf(x1, y1, x2, y2)
		glColor4f(1,1,1,1)
        graphics.draw_line(x1, y1, x1, y2)  -- left line
        graphics.draw_line(x2, y1, x2, y2)  -- right line
        graphics.draw_line(x1, y1, x2, y1)  -- bottom
        graphics.draw_line(x1, y2, x2, y2)  -- top

        draw_string(FTB_ln_init_x , FTB_ln_init_y + 6, text, "yellow" )
	end
	if FTB_ln_show_ap == 1 then
		glColor4f(0.3,0.3,0.3,1.0)
        	glRectf(FTB_ln_x, FTB_ln_y, FTB_ln_x + 370, FTB_ln_y + 45)
        	glRectf(FTB_ln_x, FTB_ln_y - 20, FTB_ln_x + 150, FTB_ln_y)
    		draw_string(FTB_ln_x + 360, FTB_ln_y + 5, "X", "white" )
		draw_string(FTB_ln_x + 10, FTB_ln_y + 5, "CRS:" ..math.floor(FTB_ln_crs + 0.5), "green" )
		draw_string(FTB_ln_x + 132, FTB_ln_y + 5, "HDG:" ..math.floor(FTB_ln_hdg + 0.5), "green" )
		draw_string(FTB_ln_x + 187, FTB_ln_y + 5, "ALT:" ..math.floor(FTB_ln_alt), "green" )
    		draw_string(FTB_ln_x + 250, FTB_ln_y + 5, "VS:" ..math.floor(FTB_ln_vs), "green" )
    		draw_string(FTB_ln_x + 301, FTB_ln_y + 5, "CRS2:" ..math.floor(FTB_ln_crs2 + 0.5), "green" )
		draw_string(FTB_ln_x + 10, FTB_ln_y - 13, "Autopilot", "white")
	end
	if FTB_ln_show_ap == 1 and FTB_ln_mach_on == 0 then
		draw_string(FTB_ln_x + 65, FTB_ln_y + 5, "SPD:" ..math.floor(FTB_ln_mach_set), "green" )
	end
	if FTB_ln_show_ap == 1 and FTB_ln_mach_on == 1 then
		draw_string(FTB_ln_x + 65, FTB_ln_y + 5, "MACH:0." ..math.floor(FTB_ln_mach_set * 100 + 0.5), "green" )
	end
	if FTB_ln_show_ap == 1 and FTB_ln_source == 2 then
		draw_string(FTB_ln_x + 64, FTB_ln_y + - 13, "Source: GPS", "green" )
	end
	if FTB_ln_show_ap == 1 and FTB_ln_source == 1 then
		draw_string(FTB_ln_x + 64, FTB_ln_y - 13, "Source: CRS2", "yellow" )
	end
	if FTB_ln_show_ap == 1 and FTB_ln_source == 0 then
		draw_string(FTB_ln_x + 64, FTB_ln_y - 13, "Source: CRS1", "yellow" )
	end
  	if FTB_ln_fast == 2 then
		FTB_ln_fast = 0 
	end	
--- display for engage modes (FD below)------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_fd == 1 or FTB_ln_show_ap == 1 and FTB_ln_fd == 2 then
    		draw_string(FTB_ln_x + 10, FTB_ln_y + 30, "FD", "green")
		FDI = 1
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_fd == 0 then
    		draw_string(FTB_ln_x + 10, FTB_ln_y + 30, "FD", "white")
		FDI = 0
	end
-------------ap engage ------------------ 
	if FTB_ln_show_ap == 1 and FTB_ln_fd == 2 then
    		draw_string(FTB_ln_x + 35, FTB_ln_y + 30, "AP", "green")
		API = 2
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_fd == 1 or FTB_ln_show_ap == 1 and FTB_ln_fd == 0 then
    		draw_string(FTB_ln_x + 35, FTB_ln_y + 30, "AP", "white")
		API = 1
	end
-------------- YAW DAMPER ------------------
	if FTB_ln_show_ap == 1 and FTB_ln_yd == 1 then
    		draw_string(FTB_ln_x + 60, FTB_ln_y + 30, "YD", "green")
		YDI = 1
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_yd == 0 then
    		draw_string(FTB_ln_x + 60, FTB_ln_y + 30, "YD", "white")
		YDI = 0
	end
-------------- AT -------------------
	if FTB_ln_show_ap == 1 then
        if FTB_ln_at == 1 or get("sim/cockpit2/autopilot/autothrottle_enabled") > 0 then
    		draw_string(FTB_ln_x + 85, FTB_ln_y + 30, "A/T", "green")
        else
    		draw_string(FTB_ln_x + 85, FTB_ln_y + 30, "A/T", "white")
        end
	end 
--	if FTB_ln_show_ap == 1 and FTB_ln_at == 0 then
--    		draw_string(FTB_ln_x + 85, FTB_ln_y + 30, "A/T", "white")
--	end
-------------- FLC -------------------
	if FTB_ln_show_ap == 1 and FTB_ln_flc == 13 then
    		draw_string(FTB_ln_x + 110, FTB_ln_y + 30, "FLC", "green")
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_flc == 9 or FTB_ln_show_ap == 1 and FTB_ln_flc == 10 then
    		draw_string(FTB_ln_x + 110, FTB_ln_y + 30, "FLC", "white")
	end
-------------- hdg ---------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_hdgi == 11 then
    		draw_string(FTB_ln_x + 140, FTB_ln_y + 30, "HDG", "green")
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_hdgi == 12 or FTB_ln_show_ap == 1 and FTB_ln_hdgi == 9 then
    		draw_string(FTB_ln_x + 140, FTB_ln_y + 30, "HDG", "white")
	end
---------------- nav engage--------------
	if FTB_ln_show_ap == 1 and FTB_ln_nav == 22 then
    		draw_string(FTB_ln_x + 175, FTB_ln_y + 30, "NAV", "green")
	end
	if FTB_ln_show_ap == 1 and FTB_ln_nav == 21 then
    		draw_string(FTB_ln_x + 175, FTB_ln_y + 30, "NAV", "yellow")
	end  
	if FTB_ln_show_ap == 1 and FTB_ln_nav == 9 then
    		draw_string(FTB_ln_x + 175, FTB_ln_y + 30, "NAV", "white")
	end 
-------------- ALT ------------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_alti == 2 then
    		draw_string(FTB_ln_x + 210, FTB_ln_y + 30, "ALT", "green")
		draw_string(FTB_ln_x + 207, FTB_ln_y + 18, "ARM", "white")
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_alti == 1 then
    		draw_string(FTB_ln_x + 210, FTB_ln_y + 30, "ALT", "white")
    		draw_string(FTB_ln_x + 207, FTB_ln_y + 18, "ARM", "yellow")
	end
	if FTB_ln_show_ap == 1 and FTB_ln_fd == 0 or FTB_ln_show_ap == 1 and FTB_ln_alti == 0 then
    		draw_string(FTB_ln_x + 210, FTB_ln_y + 30, "ALT", "white")
		draw_string(FTB_ln_x + 207, FTB_ln_y + 18, "ARM", "white")
	end
--------------- vs ---------------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_vsi == 4 then
    		draw_string(FTB_ln_x + 240, FTB_ln_y + 30, "VS", "green")
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_vsi == 3 or FTB_ln_show_ap == 1 and FTB_ln_vsi >= 5 then
    		draw_string(FTB_ln_x + 240, FTB_ln_y + 30, "VS", "1.0", "1.0", "1.0")
	end
--------------------approach -------------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_app == 2 then
    		draw_string(FTB_ln_x + 265, FTB_ln_y + 30, "APP", "green")
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_app == 1 then
    		draw_string(FTB_ln_x + 265, FTB_ln_y + 30, "APP", "yellow")
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_app == 0 then
    		draw_string(FTB_ln_x + 265, FTB_ln_y + 30, "APP", "1.0", "1.0", "1.0")
	end
--------------- BC -----------------------------------------
	if FTB_ln_show_ap == 1 and FTB_ln_bc == 2 then
    		draw_string(FTB_ln_x + 295, FTB_ln_y + 30, "BC", "green")
	end
	if FTB_ln_show_ap == 1 and FTB_ln_bc == 1 then
    		draw_string(FTB_ln_x + 295, FTB_ln_y + 30, "BC", "yellow")
	end 
	if FTB_ln_show_ap == 1 and FTB_ln_bc == 0 then
    		draw_string(FTB_ln_x + 295, FTB_ln_y + 30, "BC", "1.0", "1.0", "1.0")
	end
---------------- CRS2 engage -------------------------------
	if FTB_ln_show_ap == 1 then
		draw_string(FTB_ln_x + 322, FTB_ln_y + 30, "CRS2", "1.0", "1.0", "1.0")
	end		
end

do_every_draw("FTB_dis()")

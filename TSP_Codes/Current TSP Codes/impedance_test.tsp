charge(4.2, 1.5, 0.11, -1, 2050, 1)
resting(3, 360, 100, 2050, 2)

EIS_control(100,2050,3)
keithley_control()
EIS_control(100,2050,3)
keithley_control()
EIS_control(100,2050,3)
keithley_control()

contador = 0

while true do

	if contador > 3 then
		break
	end
	
	cc_capacity_load(3, -2.25, 500, 100-contador*25, 2050, 0.11, 4)
	resting(3, 360, 100-(contador+1)*25, 2050, 2)
	
	EIS_control(100-(contador+1)*25,2050,3)
	keithley_control()
	EIS_control(100-(contador+1)*25,2050,3)
	keithley_control()
	EIS_control(100-(contador+1)*25,2050,3)
	keithley_control()

	contador = contador + 1
end
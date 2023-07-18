function discharge(voltlimit, discurrent, test_number, SOC) 
	-- (voltaje descargado,corriente de descarga, número de identificación data)
	
	test_state = test_number

	smu.measure.func = smu.FUNC_DC_CURRENT -- Se mide corriente
	smu.measure.sense = smu.SENSE_4WIRE -- Se cambia el sistema de medición a 4-wire para más precisión
	smu.source.func = smu.FUNC_DC_VOLTAGE -- Se alimenta voltaje
	smu.source.offmode = smu.OFFMODE_HIGHZ -- Modo cuando la carga de desconecta para aislar el equipo
	smu.source.level = (voltlimit-0.05) -- Fijar inferior a voltlimit
	smu.measure.terminals = smu.TERMINALS_FRONT
	smu.source.readback = smu.ON
	
	-- definición de variables del proceso
	deltatime = 0
	capacity = 0
	captotal = 0
	voltlimit=voltlimit -- Debe ser mayor que smu.source.level
	aux = 1
	iteration=1
	iteration2=1
	
	smu.source.output=smu.ON -- Se inicia la conexión con la carga
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	while true do
		-- definición de variables por ciclo
		smu.source.ilimit.level=-discurrent
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		-- detección de limite de voltaje
		if volt <= voltlimit then 
			iteration2=(iteration2+1)
			break 
		end
		
		-- capacidad acumulada
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = smu.source.ilimit.level*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			captotal = captotal + capacity
		end
		
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_state) 
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n",curr,volt,capacity,captotal,time2,test_state,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
	end
	
	-- se desconecta la carga del equipo
	smu.source.output=smu.OFF
	
	-- se limpia el buffer
	ExtBuffer.clear()
end

function charge(voltlimit, charcurrent, currlimit, test_number, SOC)

	test_state = test_number

	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=voltlimit --Mismo valor de voltLimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	smu.source.ilimit.level=charcurrent
	
	voltLimit=voltlimit
	
	smu.source.output=smu.ON
	
	display.changescreen(display.SCREEN_USER_SWIPE)
	aux2=1
	deltatime = 0
	capacity = 0
	captotal_carga = 0
	iteration = 1
	iteration2=1
	
	while true do
		
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if curr <= currlimit and curr > 0.0001 then
			iteration2=(iteration2+1)
			break
		end
	
		if aux2 >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh
			captotal_carga = captotal_carga + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal_carga, 'SOC', SOC, 'Test state', test_state)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal_carga,time2,test_state,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt))
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		aux2=aux2+1
		delay(1)
	end
	
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
	
	return captotal_carga
end

function resting(voltlimit, contador_rest, test_number , SOC)

	test_state = test_number

	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=(voltlimit - 0.05) -- Fijar inferior a voltlimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	
	deltatime = 0
	capacity = 0
	captotal = 0
	voltlimit=voltlimit -- Debe ser mayor que smu.source.level
	aux = 1
	smu.source.output=smu.ON
	display.changescreen(display.SCREEN_USER_SWIPE)
	iteration=1
	iteration2=1
	contador = 1
	ncontador = contador_rest
	
	while true do
		smu.source.ilimit.level=-0.0001
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if contador > ncontador then 
			iteration2=(iteration2+1)
			break 
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = smu.source.ilimit.level*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			captotal = captotal + capacity
		end
		
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_state)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal,time2,test_state,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
		contador=contador+1
	end
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
end

function vocbor_measure(voltlimit, test_number, SOC)

	test_state = test_number
	
	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=(voltlimit - 0.05) -- Fijar inferior a voltlimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	
	deltatime = 0
	capacity = 0
	captotal = 0
	voltlimit=voltlimit -- Debe ser mayor que smu.source.level
	aux = 1
	smu.source.output=smu.ON
	display.changescreen(display.SCREEN_USER_SWIPE)
	iteration=1
	iteration2=1
	contador = 1
	ncontador = 1
	
	while true do
		smu.source.ilimit.level=-0.0001
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if contador > ncontador then 
			iteration2=(iteration2+1)
			break 
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = smu.source.ilimit.level*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			captotal = captotal + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_state)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal,time2,test_state,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
		contador=contador+1
	end
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
end

function pulse_test(voltlimit, pulsecurrent, discurrent, test_number_1, test_number_2, test_number_3)

	
	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=(voltlimit - 0.05) -- Fijar inferior a voltlimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	
	deltatime = 0
	capacity = 0
	captotal_pulso = 0
	voltlimit=voltlimit -- Debe ser mayor que smu.source.level
	
	-- Pulso Fuerte --
	test_state = test_number_1
	
	aux = 1
	nciclos = 10
	ciclos=1
	smu.source.output=smu.ON
	
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	iteration=1
	iteration2=1
	while true do
	
		if ciclos > nciclos then
			break
		end
		
		smu.source.ilimit.level=-pulsecurrent
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if volt <= voltlimit then 
			iteration2=(iteration2+1)
			break 
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = smu.source.ilimit.level*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			captotal_pulso = captotal_pulso + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal_pulso, 'SOC', SOC, 'Test state', test_state)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal_pulso,time2,test_state,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
		ciclos = (ciclos+1)
	end
	
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
	
	-- Descarga Nominal --
	test_state = test_number_2
	
	aux = 1
	nciclos = 10
	ciclos=1
	smu.source.output=smu.ON
	
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	iteration=1
	iteration2=1
	while true do
	
		if ciclos > nciclos then
			break
		end
		
		smu.source.ilimit.level=-discurrent
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if volt <= voltlimit then 
			iteration2=(iteration2+1)
			break 
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = smu.source.ilimit.level*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			captotal_pulso = captotal_pulso + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal_pulso, 'SOC', SOC, 'Test state', test_state)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal_pulso,time2,test_state,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
		ciclos = (ciclos+1)
	end
	
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
	
	-- Pulso Fuerte --
	test_state = test_number_3
	
	aux = 1
	nciclos = 10
	ciclos=1
	smu.source.output=smu.ON
	
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	iteration=1
	iteration2=1
	while true do
	
		if ciclos > nciclos then
			break
		end
		
		smu.source.ilimit.level=-pulsecurrent
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if volt <= voltlimit then 
			iteration2=(iteration2+1)
			break 
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = smu.source.ilimit.level*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			captotal_pulso = captotal_pulso + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal_pulso, 'SOC', SOC, 'Test state', test_state)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal_pulso,time2,test_state,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
		ciclos = (ciclos+1)
	end
	
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
	
	return captotal_pulso
end

function capacity_discharge(voltlimit, discurrent, discap, test_number,SOC)
	test_state = test_number
	
	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=(voltlimit - 0.05) -- Fijar inferior a voltlimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	
	deltatime = 0
	capacity = 0
	captotal = 0
	voltlimit=voltlimit -- Debe ser mayor que smu.source.level
	aux = 1
	
	smu.source.output=smu.ON
	
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	iteration=1
	iteration2=1
	while true do
		smu.source.ilimit.level=-discurrent
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if captotal > discap then 
			iteration2 = iteration2 + 1
			break
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = smu.source.ilimit.level*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			captotal = captotal + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_state)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal,time2,test_state,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
	end
	
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
end

function keithley_control() 
	-- Función para cambiar pins que dan el control de la prueba al keithley
	 
	-- Declaramos los pineas como input y output
	-- Se usa el pin 1 como output y el 2 como input
	digio.line[1].mode = digio.MODE_DIGITAL_OUT
	digio.line[2].mode = digio.MODE_DIGITAL_IN
	digio.line[3].mode = digio.MODE_DIGITAL_OUT
	digio.line[4].mode = digio.MODE_DIGITAL_OUT 
	
	-- Se setean los pins para darlo control al keithley
	digio.line[1].state = 1 -- (KEITHLEY TOMA CONTROL) Se configura el out = 1 para que la acción la ejecute el keithley
	delay(2)
	digio.line[3].state = 0 -- (SE DEJA DE ENVIAR LA SEÑAL PARA CONECTAR LA CELDA AL EIS) Enviamos un 1 para activar fuente y Normally Open del Rele
	digio.line[4].state = 1 -- (SE CONECTA LA CELDA AL KEITHLEY )Enviamos un 0 porque no queremos desactivar el Normally Open aún
end

function EIS_control() 
	-- Función para cambiar pins que dan el control de la prueba al EIS

	-- Declaramos los pineas como input y output
	-- Se usa el pin 1 como output y el 2 como input
	digio.line[1].mode = digio.MODE_DIGITAL_OUT
	digio.line[2].mode = digio.MODE_DIGITAL_IN
	digio.line[3].mode = digio.MODE_DIGITAL_OUT
	digio.line[4].mode = digio.MODE_DIGITAL_OUT 
	
	-- Se setean los pins para darle control al EIS
	digio.line[3].state = 1 -- (CELDA CONECTADA AL EIS) Enviamos un 1 para activar fuente y Normally Open del Rele
	digio.line[4].state = 0 -- Enviamos un 0 porque no queremos desactivar el Normally Open aún
	delay(2)
	digio.line[1].state = 0 -- (KEITHLEY DEJA DE OPERAR)Enviamos un 0 para darle la acción al EIS y no al keithley
	print("Señal enviada, EIS tomo control")
	while digio.line[2].state != digio.STATE_HIGH do
		print(digio.line[2].state)
		delay(1)
	end
end
function read_csv(voltlimit, test_number, SOC)
	reset()
	
	-- Creaci�n buffer para guardar datos
	csv_buffer = buffer.make(300000, buffer.STYLE_WRITABLE)
	buffer.write.format(csv_buffer, buffer.UNIT_AMP, buffer.DIGITS_8_5)
	
	-- Se abre el archivo para guardar data
	FileNumber=file.open("/usb1/csv_test_.csv",file.MODE_READ)
	
	contador = 0
	while true do
		
		var = file.read(FileNumber, file.READ_LINE)

		if var == nil then
			print("var nil")
			break
		end
		
		numvar = var + 0 
		print(numvar)
		
		buffer.write.reading(csv_buffer, numvar)
		contador = (contador+1)
	end
	file.close(FileNumber)
	
	ExtBuffer = buffer.make(300000)
	
	keithley_control()
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)
	
	test_state = test_number

	smu.measure.func = smu.FUNC_DC_CURRENT -- Se mide corriente
	smu.measure.sense = smu.SENSE_4WIRE -- Se cambia el sistema de medici�n a 4-wire para m�s precisi�n
	smu.source.func = smu.FUNC_DC_VOLTAGE -- Se alimenta voltaje
	smu.source.offmode = smu.OFFMODE_HIGHZ -- Modo cuando la carga de desconecta para aislar el equipo
	smu.source.level = (voltlimit-0.05) -- Fijar inferior a voltlimit
	smu.measure.terminals = smu.TERMINALS_FRONT
	smu.source.readback = smu.ON
	
	-- definici�n de variables del proceso
	deltatime = 0
	capacity = 0
	captotal = 0
	voltlimit=voltlimit -- Debe ser mayor que smu.source.level
	aux = 1
	iteration=1
	iteration2=1
	
	smu.source.output=smu.ON -- Se inicia la conexi�n con la carga
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	while true do
		
		-- definici�n de variables por ciclo
		smu.source.ilimit.level=csv_buffer[iteration]
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		-- detecci�n de limite de voltaje
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
		
		if iteration > contador then
			print("fin perfil")
			break
		end
		
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
	end
	-- se desconecta la carga del equipo
	smu.source.output=smu.OFF
	
	-- se limpia el buffer
	ExtBuffer.clear()
	file.close(FileNumber)
end
function erratic_load(test_number, SOC_0, cell_captotal, upper_voltlimit, lower_voltlimit,charcurrent)
	
	reset()
	
	--CORRIENTE--
	-- Creación buffer para guardar datos
	csv_buffer = buffer.make(300000, buffer.STYLE_WRITABLE)
	buffer.write.format(csv_buffer, buffer.UNIT_AMP, buffer.DIGITS_8_5)
	
	-- Se abre el archivo para guardar data
	FileNumber=file.open("/usb1/csv_test.csv",file.MODE_READ)
	
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
	
	-- SOC --
	-- Creación buffer para guardar datos SOC
	SOC_buffer = buffer.make(300000, buffer.STYLE_WRITABLE)
	buffer.write.format(SOC_buffer, buffer.UNIT_AMP, buffer.DIGITS_8_5)
	
	-- Se abre el archivo para guardar data
	FileNumber_SOC=file.open("/usb1/SOC_test.csv",file.MODE_READ)
	
	contador_soc = 0
	while true do
		
		var = file.read(FileNumber_SOC, file.READ_LINE)

		if var == nil then
			print("var soc nil")
			break
		end
		
		numvar = var + 0 
		print(numvar)
		
		buffer.write.reading(SOC_buffer, numvar)
		contador_soc = (contador_soc+1)
	end
	file.close(FileNumber_SOC)
	
	
	ExtBuffer = buffer.make(300000)
	
	keithley_control()
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)

	smu.measure.func = smu.FUNC_DC_CURRENT -- Se mide corriente
	smu.measure.sense = smu.SENSE_4WIRE -- Se cambia el sistema de medición a 4-wire para más precisión
	smu.source.func = smu.FUNC_DC_VOLTAGE -- Se alimenta voltaje
	smu.source.offmode = smu.OFFMODE_HIGHZ -- Modo cuando la carga de desconecta para aislar el equipo
	smu.measure.terminals = smu.TERMINALS_FRONT
	smu.source.readback = smu.ON
	
	-- definición de variables del proceso
	deltatime = 0
	capacity = 0
	captotal = 0
	aux = 1
	iteration=1
	iteration2=1
	csv_iteration=1
	SOC = SOC_0
	soc_iteration = 1
	
	smu.source.range=7
	smu.source.output=smu.ON -- Se inicia la conexión con la carga
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	while true do
		
		if SOC <= SOC_buffer[soc_iteration] then 
			charge_load = SOC_buffer[soc_iteration+1]*cell_captotal/100
			while SOC <= SOC_buffer[soc_iteration] do
				smu.source.ilimit.level=charcurrent
				smu.source.level = upper_voltlimit -- Caso carga
			end
			soc_iteration = soc_iteration+2
		else
			smu.source.ilimit.level=csv_buffer[csv_iteration]
			if csv_buffer[csv_iteration] <= 0 then 
				smu.source.level = (lower_voltlimit-0.05) -- Caso descarga
			else
				smu.source.level = upper_voltlimit -- Caso carga
			end
			csv_iteration = csv_iteration + 1
		end
		
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		-- detección de limite de voltaje inferior
		if volt <= lower_voltlimit then 
			iteration2=(iteration2+1)
			break 
		end
		
		-- capacidad acumulada
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			if SOC >= 0 then -- Solo si tengo valores de SOC inicial
				SOC = SOC + (capacity/cell_captotal)*100
			end
			captotal = captotal + capacity
		end
		
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_number) 
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n",curr,volt,capacity,captotal,time2,test_number,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		
		
		if iteration2 > contador then
			print("fin perfil")
			break
		end
		
		iteration=(iteration+1)
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
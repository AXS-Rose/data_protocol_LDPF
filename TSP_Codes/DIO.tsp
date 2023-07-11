-- Declaramos los pineas ocmo input y output
-- Se usa el pin 1 como output y el 2 como input
digio.line[1].mode = digio.MODE_DIGITAL_OUT
digio.line[2].mode = digio.MODE_DIGITAL_IN

-- Partimos enviando un 1
digio.line[1].state = 1

print(digio.line[1].state, digio.line[2].state)

iter = 3
for i = 1, iter do
print(digio.line[1].state, digio.line[2].state)

	-- Enviamos un 0 y esperamos la respuesta
	digio.line[1].state = 0
	delay(1)
	print("Señal enviada")
	while digio.line[2].state != digio.STATE_HIGH do
		print(digio.line[2].state)
		delay(1)
	end

	digio.line[1].state = 1
	print("Hacemos otras cosas")
	delay(10)
	print("a")
	
end

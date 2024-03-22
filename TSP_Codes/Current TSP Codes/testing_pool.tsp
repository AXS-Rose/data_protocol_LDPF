A_total= 2
A_count = 1

B_total = 30
B_count = 1

custom_iteration = 1

for i = 1, A_total do

	cicladoEIS(1, 3, 4.2, 2033, 2.25, 1.5, 0.11, 0.05)
	resting(3, 600, 100, 2033, 2)
	
	for j = 1, B_total do
	
		custom_iteration = custom_profile(100,2033,4.2,3,custom_iteration,0.15,7)
		charge(4.2, 1.5, 1.3, 0.15, 2033, 3)
		
	end
end
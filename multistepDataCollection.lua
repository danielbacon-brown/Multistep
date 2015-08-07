clockStart = os.clock()

--print(proc_num)

measurementOffset = 2 --um  --distance past the grating to measure the field  --can get numerical instabilities if measuring outside region
n_air = 1
n_SU8  = 1.6
lambda_0 = 0.77  --um
period = lambda_0 /n_SU8 * 3/(2*math.sqrt(2))   --um  --should be square
--print('period: '..period)

--Set Parameters:
nLevels=2
nTries = 1000
useFabricabilityCondition = 1   -- whether these simulations are limited in feature size and height
heightFabricabilityLimit = 0.5   --um
spacingFabricabilityLimit = 0.1*period  --um

A=4
B=4

Gu = 2*math.pi/period
--Gv = Gu

--Propogation vectors
--k_0 = 2*math.pi*n_SU8/lambda_0
--k1 = {0,0,k_0}
--k2 = {0,-Gu,math.sqrt(k_0^2-Gu^2)}
--k3 = {-Gu,0,math.sqrt(k_0^2-Gu^2)}
--k4 = {Gu,0,math.sqrt(k_0^2-Gu^2)}
--k5 = {0,Gu,math.sqrt(k_0^2-Gu^2)}




--Create common simulation object
S = S4.NewSimulation()
S:SetLattice({period,0}, {0,period})  --Should yield cubic symmetry 

S:SetNumG(5)  --check for 5 orders

S:AddMaterial("Vacuum", {1,0})
S:AddMaterial("SU8", {1.6^2,0})


S:AddLayer('Front', 0, 'Vacuum')   --first layer

for nL = 1,(nLevels-1),1 do
	S:AddLayer('Grating' .. nL, 1, 'Vacuum')  --grating layers -- the thickness will be updated in the diffraction 
end

S:AddLayer('Interference',4,'SU8')  --layer within which to calculate the diffracted field, to avoid numerical instability (NECESSARY?)
--S:AddLayer('Interference',10,'Vacuum')

S:AddLayer('Back',0,'SU8')   --last layer
--S:AddLayer('Back',0,'Vacuum')   --last layer


S:SetExcitationPlanewave(
	{0,0},  -- incidence angles (spherical coordinates: phi in [0,180], theta in [0,360])
	{1/math.sqrt(2),0},  -- s-polarization amplitude and phase (in degrees)  --y-polarized   {1,0} -> Ey=1
	{1/math.sqrt(2),90})  -- p-polarization amplitude and phase  --x-polarized   % circular polarization  {1,0} -> Ex=1

S:SetFrequency(1/lambda_0)  --frequency in S4 is given in units of inverse length

S:UsePolarizationDecomposition()  --decomposes fields according to material boundaries (improves convergence)
S:SetResolution(16)  --calculates more slowly, but less likely to get nonconverging solution


math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) ) --slightly better random numbers
--math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) ) --slightly better random numbers
proc_num = math.random(1000);  --To get version number, generate number between 1 and 1000 to ensure 2 processes don't have same name
if useFabricabilityCondition then
	maxHeight = heightFabricabilityLimit
	minSpacing = spacingFabricabilityLimit
	fabCondStr = 'Fab_h' .. string.format("%g", maxHeight) .. '_s' .. string.format("%g", math.floor( (minSpacing * 100000) + 0.5) / (100000))
else
	maxHeight = 2*math.pi*lambda_0*(n_SU8-n_air)   --Equivalent to 2pi for thin element approximation
	minSpacing = 0
	fabCondStr = 'Unfab_h' .. string.format("%g", maxHeight) .. '_s' .. string.format("%g", math.floor( (minSpacing * 100000) + 0.5) / (100000))
end

clockStr = os.date('%m-%d-%Y_%H:%M_')
filename = "md_" .. nLevels .. "levels_" .. fabCondStr .. "_" .. nTries .. "tries_" .. clockStr .. "proc" .. proc_num .. ".txt"
print(filename)
print(io.open(filename, "w"))
file = io.open(filename, "w")



for iter = 1,nTries,1 do

	Sa = S:Clone()  --makes a copy of the general simulation object

	--Iteratively generate phase shifts
	possibleThickness = {}
	if nLevels==2 then
		possibleThickness =  {0,maxHeight*math.random()}    --phase shifts for 1 stratum (2 levels)
	elseif nLevels==3 then
		possibleThickness = {0,maxHeight*math.random(),maxHeight*math.random()}  --phase shifts for 2 strata (3 levels)
	elseif nLevels==4 then
		possibleThickness = {0,maxHeight*math.random(),maxHeight*math.random(),maxHeight*math.random()} 
	end
	
	table.sort(possibleThickness)	
	
	totalThickness = possibleThickness[nLevels] --thickness of entire grating
	  
   
   
	for nL = 1,(nLevels-1),1 do
		S:SetLayerThickness('Grating' .. nL, possibleThickness[(nL+1)]-possibleThickness[(nL)] )  --sets thickness of each layer
	end
    
	--xspacing:
	remaining = 1;   --relative distance unclaimed by a block
	spacing_x = {0}  --spacing_x is the cumulative x-value
	for a = 1,(A-1),1 do
		spacing_x[a+1] = math.random()*( (remaining - minSpacing*(A-a)) - (minSpacing) ) + minSpacing+(1-remaining)  --set according to limits of minSpacing
		remaining = 1-spacing_x[a+1]
	end
	spacing_x[A+1] = 1
    
	--yspacing:
	remaining = 1;   --relative distance unclaimed by a block
	spacing_y = {0}  --spacing_x is the cumulative x-value
	for b = 1,(B-1),1 do
		spacing_y[b+1] = math.random()*( (remaining - minSpacing*(B-b)) - (minSpacing) ) + minSpacing+(1-remaining)  --set according to limits of minSpacing
		remaining = 1-spacing_y[b+1]
	end
	spacing_y[B+1] = 1
    
    

    
	--Add blocks to the grating layers
	for a = 1,A,1 do
		for b = 1,B,1 do
			h = math.random(0,nLevels-1)   --index height of this region (can be from 0 to nLevels-1)
			--print(h)
			if h>0  then  --if you need to add at least on block
				centerX = (spacing_x[a]+spacing_x[a+1])/2*period
				centerY = (spacing_y[b]+spacing_y[b+1])/2*period
				halfwidth = (spacing_x[a+1]-spacing_x[a])/2*period
				halfheight = (spacing_y[b+1]-spacing_y[b])/2*period
				for nL = 1,h,1 do --for each layer that needs to be added for this region
					Sa:SetLayerPatternRectangle('Grating' .. nL, 'SU8', {centerX,centerY}, 0, {halfwidth,halfheight} ) 
				end
			end
		end
	end
	
	
	--forw,back = Sa:GetAmplitudes(1.5,4)
	forw,back = Sa:GetEModes(totalThickness + measurementOffset)
	--print(forw)
	--print(back)

--forw,back = Sa:GetAmplitudes('Interference',1.5) --get amplitudes of the transmitted modes
	--print('each forward mode:')
--	for key,value in pairs(forw) do 
--		print(forw[key][1], forw[key][2], forw[key][3], forw[key][4], forw[key][5], forw[key][6] ) 
--	end
	--print('each backward mode:')
	--for key,value in pairs(back) do print(back[key][1], back[key][2], back[key][3], back[key][4], back[key][5], back[key][6] ) end
    
    --write forward modes
    --for key,value in ipairs(forw) do 
--	file:write(forw[key][1], ', ', forw[key][2], ', \r\n')
--    end
--file:write(forw[1][1],',',forw[1][2],',',forw[2][1],',',forw[2][2],',',forw[3][1],',',forw[3][2],',',forw[4][1],',',forw[4][2],',',forw[5][1],',',forw[5][2],',',forw[6][1],',',forw[6][2],',',forw[7][1],',',forw[7][2],',',forw[8][1],',',forw[8][2],',',forw[9][1],',',forw[9][2],',',forw[10][1],',',forw[10][2])
    
	--Write data to file
	for key,value in pairs(forw) do 
		file:write(forw[key][1],',', forw[key][2],',', forw[key][3],',', forw[key][4],',', forw[key][5],',', forw[key][6],',  \r\n' ) 
	end
	
	--Sa:OutputStructurePOVRay('modeltest.pov')
	
--	Gu,Gv = Sa:GetReciprocalLattice()
--	print('Gu ', Gu[1][1]*2*math.pi,' ',Gu[1][2]*2*math.pi, '     Gv ',Gu[2][1]*2*math.pi,' ',Gu[2][2]*2*math.pi ) 
    
    --print Fourier modes
--	glist = S:GetGList()
--	for key,value in pairs(glist) do 
--		print(key, glist[key][1], glist[key][2]) 
--	end
    
end



file:close()


print('Time: ' .. (os.clock()-clockStart) )

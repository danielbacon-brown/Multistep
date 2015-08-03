
--Set Parameters:
nLevels=3

useFabricabilityCondition = 1   -- whether these simulations are limited in feature size and height
heightFabricabilityLimit = 0.5   --um
spacingFabricabilityLimit = 0.1  --um

nTries = 20

n_air = 1
n_SU8  = 1.6

lambda_0 = 0.77  --um

A=4
B=4

if useFabricabilityCondition
	maxHeight = heightFabricabilityLimit
	minSpacing = spacingFabricabilityLimit
	fabCondStr = "Fab_h"+maxHeight+"_s"+minSpacing_
else
	maxHeight = 2*math.pi*lambda_0*(n_SU8-n_air)   --Equivalent to 2pi for thin element approximation
	minSpacing = 0
	fabCondStr = "Unfab_h"+maxHeight+"_s"+minSpacing_
end


filename = "multistepdata_"+nLevels+"levels_" + fabCondStr+"_"+nTries+"tries"
file = io.open(filename, "w")



for iter = 1,numTries,1 do

  

	--Iteratively generate phase shifts
	if nLevels==2 then
		possiblePhaseShift = table.sort( {0,maxShift*math.random()} )   --phase shifts for 1 stratum (2 levels)
	elseif nLevels==3 then
		possiblePhaseShift = table.sort( {0,maxShift*math.random(),maxShift*math.random()} )  --phase shifts for 2 strata (3 levels)
	elseif u==4 then
		possiblePhaseShift = table.sort( {0,maxShift*math.random(),maxShift*math.random(),maxShift*math.random()} )
	end

	math.random(0,1) == 1
    
	--Set each block to one of the values
	phi_m = {}
	for a = 1,A,1
		phi_m[a] = {}
		for b = 1,B,1
			phi_m[a][b] = possiblePhaseShift[ math.random(nLevels) ]
			--phi_m(a,b) = possiblePhaseShift(cellindexes(a,b));  
		end
	end
    
end




S = S4.NewSimulation()
S:SetLattice({0.5334,0}, {0.5334/2,0.5334*math.sqrt(3)/2}) -- 2D hexagonal lattice

S:SetNumG(10)

S:AddMaterial("Vacuum", {1,0})
S:AddMaterial("SU8", {1.6^2,0})
n_TCO = 1.89    --ITO: 1.94 at 532nm   --AZO: 1.89 at 532nm   --FTO: ~2 
k_TCO = 0.046 --at 532nm
S:AddMaterial("ITO", {n_TCO^2-k_TCO^2,2*n_TCO*k_TCO})
S:AddMaterial("glass", {1.5^2,0})


S:AddLayer('Front', 0, 'Vacuum')   --background material

S:AddLayer('Grating', 0.064, 'Vacuum')  --grating layer
S:SetLayerPatternRectangle('Grating', 'SU8', {0,-0.1255/2}, 0, {0.5334/2,0.1255/2})   -- 'Layername', 'MatName', {center}, angle, {halfwidths}
S:SetLayerPatternRectangle('Grating', 'SU8', {0,0.1697/2}, 0, {0.2367/2,0.1697/2})

S:AddLayer('PrInterference', 5, 'SU8')  -- thick SU8 layer

S:AddLayer('ITOlayer', 0.01, 'ITO')

--S:AddLayer('Back',0,'glass') -- substrate
S:AddLayer('Back',0,'SU8')

S:SetExcitationPlanewave(
	{0,0},  -- incidence angles (spherical coordinates: phi in [0,180], theta in [0,360])
	{3150.2,0},  -- s-polarization amplitude and phase (in degrees)
	{293.7,0})  -- p-polarization amplitude and phase     --Helix opt3 has linear pol

S:SetFrequency(1/0.532)

S:UsePolarizationDecomposition()
S:SetResolution(8)


--for z=-2,2,0.1 do
--	print(S:GetEField({0,0,z}))
--	print(S:GetPoyntingFlux('Front',z))
--	print(S:GetEField({0,0,z}))
--	print(S:GetPoyntingFlux('Back',z))
--end

S:OutputStructurePOVRay('HelixPOVrayScript')

os.remove('HelixFieldVolOutput.E')
os.remove('HelixFieldVolOutput.H')

Cx = math.floor(0.5334/0.02)
Cy = math.floor((0.5334*math.sqrt(3)/2)/0.02)
Cx = 25
Cy = 25
Cz = 0.02
print(Cx)
print(Cy)

for z=(0.064+1.064 +1e-6),(0.064+1.064+0.532*2 -1e-6),Cz do
	S:GetFieldPlane(z, {Cx,Cy}, 'FileAppend', 'HelixFieldVolOutput')
	print(z)
end

i = S:GetDiffractionOrder(1, 1)
print(i)

forw,back = S:GetAmplitudes('PrInterference',2.5)
print('each forward mode:')
for key,value in pairs(forw) do print(forw[key][1], forw[key][2]) end
print('each backward mode:')
for key,value in pairs(back) do print(back[key][1], back[key][2]) end
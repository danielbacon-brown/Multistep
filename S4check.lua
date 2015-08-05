--S4check


n_mat=1.6
--n_mat=2
lambda_0 = 0.77
period = 0.51044
--period = lambda_0/n_mat*1
period = lambda_0 /n_mat * 3/(2*math.sqrt(2))   --um  --should be square

S = S4.NewSimulation()
S:SetLattice({period,0}, {0,period})  --Should yield cubic symmetry 

S:SetNumG(5)  --check for 5 orders



S:AddMaterial("Vacuum", {1,0})
S:AddMaterial("SU8", {n_mat^2,0})


S:AddLayer('Front', 0, 'Vacuum')   --first layer
--S:AddLayer('Middle1',lambda_0,'Vacuum')
S:AddLayer('Grating',0.5,'Vacuum')
S:SetLayerPatternRectangle('Grating','SU8',{0,0},0,{0.15,0.15})
S:AddLayer('Middle2', 10, 'SU8')
S:AddLayer('Back',0,'SU8')   --last layer



S:SetExcitationPlanewave(
	{0,0},  -- incidence angles (spherical coordinates: phi in [0,180], theta in [0,360])
	--{1/math.sqrt(2),0},  -- s-polarization amplitude and phase (in degrees)
	--{1/math.sqrt(2),90})  -- p-polarization amplitude and phase     % circular polarization
	{1,0},
	{0,0})
	

S:SetFrequency(1/lambda_0)  --frequency in S4 is given in units of inverse length


S:UsePolarizationDecomposition()  --decomposes fields according to material boundaries (improves convergence)
S:UseNormalVectorBasis()
S:SetResolution(16)

    --print Fourier modes
	glist = S:GetGList()
	for key,value in ipairs(glist) do 
		print(key, glist[key][1], glist[key][2]) 
	end

	
	
Gu = 2*math.pi/period
k_0 = 2*math.pi/lambda_0
k_z = math.sqrt( (n_mat*k_0)^2 - Gu^2)    --zcomponent of the diffracted modes
k_para = Gu  --component of k parallel to surface
znormal=  lambda_0/n_mat     
ztilt = 2*math.pi/ k_z    --offset in z that leads to no phase shift in diffracted orders
print(ztilt)
forw,back = S:GetAmplitudes('Middle2',  ztilt ) --get amplitudes of the transmitted modes, 
	print('each forward mode:')
	for key,value in ipairs(forw) do print(forw[key][1], forw[key][2]) end
	print('each backward mode:')
	for key,value in ipairs(back) do print(back[key][1], back[key][2]) end
	
	
	
	--Orders are:
	--[0,0]
	--[0,-1]
	--[-1,0]
	--[1,0]
	--[0,1]
	
	
	--Need to add 180deg phase shift to s-polarized 
	
	--Assume s-hat is in x-direction and y-hat is in y-direction:
--E_x = {}
--E_y = {}
--E_z = {}
--for m=1,5,1 do  --for each order, set as a table for complex values [a,b] -> a+b*i
--	E_x[m] = {}
--	E_y[m] = {}
--	E_z[m] = {}
--	end

--Normal, undiffracted, 0-order  --assume Es=Ex, Ep=Ey
--E_x[1][1] = forw[1][1] 
--E_x[1][2] = forw[1][2]
--E_y[1][1] = forw[1][1]
--E_y[1][2] = forw[1][2]
--E_z[1][2] = 0;
--E_z[1][2] = 0;	

--For s-polarization diffracting in 1,0 and -1,0 orders (orders 3 and 4)
--Eshat = {0,1,0}  --vector describing direction of E_s
--Ephat = {k_z/k_0,0,k_para/k_0}  --vector describing direction of E_p
	
--E_x[3][1] = 
	
Gu,Gv = S:GetReciprocalLattice()
print('Gu ', Gu[1][1]*2*math.pi,' ',Gu[1][2]*2*math.pi, '     Gv ',Gu[2][1]*2*math.pi,' ',Gu[2][2]*2*math.pi ) 
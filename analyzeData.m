function analyzeData(filenames_common,plottingParams)
%filenames_common is a cell array of filename prefixes that describe the data points that
%need collecting.



%Each set of 5 rows correspond to a single simulation,
%[Exr,Exi,Eyr,Eyi,Ezr,Ezi]
%according to Modes:
%[0,0],
%[0,-1],
%[-1,0],
%[1,0],
%[0,1]


%Structure that define how the plots are made:

numTypes = size(filenames_common,2);
rawData = cell(1,numTypes);  %Makes empty cell array, for raw data
Nsims = zeros(1,numTypes); %Number of simulations for each type of simulation
fullData = cell(1,numTypes);  %cell array for processed data

for fi = 1:size(filenames_common,2)

    disp('doingData')
    thisFilename_common = filenames_common{fi}
    
    txtFiles = dir('*.txt'); %Get all filnames
    fileMatch = ~cellfun(@isempty, regexp({txtFiles.name}, thisFilename_common ));   %returns 1 if regexp is not empty (if a match was found)
    matchFiles = txtFiles(fileMatch);  %List of files that match filename_common
    
    %sizeFiles = size(matchFiles)
    
    rawData{fi} = zeros(0,6);
    for f = 1:length(matchFiles)
        %thisData = csvread(matchFiles(f).name);
        %sizeD = size(thisData);
        addingData = csvread(matchFiles(f).name);
        %sizetest = size(addingData,1),5
        if  mod( size(addingData,1),5) == 0  %Only add the data if it is divisible by 5
            rawData{fi} = [rawData{fi}; addingData];
            %size(allData{fi})
        end
    end
    
    %sizeout = size(allData{fi})
    Nsims(fi) = size(rawData{fi},1)/5  % # of simulations  ,  (# rows must be a factor of 5)
    Nmodes = 5;
    Ndimensions = 3;
    
    Efields = zeros(Nsims(fi),Nmodes,3);  %allocate space for data,  # simulations * # modes * # Efield vector dimensions
    
    %Change structure of data to [sim#,mode#,dim#] (complex)
    for s = 1:Nsims(fi)  % #rows must be a factor of 5
        for m = 1:Nmodes
            for d = 1:Ndimensions
                Efields(s,m,d) = complex( rawData{fi}( (s-1)*5 + m, (d-1)*2+1 ), rawData{fi}( (s-1)*5 + m, (d-1)*2+2 ) );
            end
        end
    end
    
    
    %Constants:
    n_interference = 1.58;
    lambda_0 = 0.770; %um
    k_0 = 2*pi*n_interference/lambda_0;
    period = 0.51044;
    Gu = 2*pi/period;  %delta k from grating
    k_diff_z  = sqrt(k_0^2-Gu^2);  %vertical component of diffracted vectors
    %k-vectors:
    k = zeros(5,3);
    k(1,:) = [0,0,k_0];
    k(2,:) = [0,-Gu,k_diff_z];
    k(3,:) = [-Gu,0,k_diff_z];
    k(4,:) = [Gu,0,k_diff_z];
    k(5,:) = [0,Gu,k_diff_z];
    
    %Rotate E and k vectors so that k-vector is normal to the surface
    theta = asin(Gu/k_0);  %angle to be rotated
    %Rotation matrices
    R_1 = [ 1, 0, 0;...
        0, 1, 0;...
        0, 0, 1];
    R_2 = [ 1,          0,          0; ...
        0, cos(theta), sin(theta); ...
        0,-sin(theta), cos(theta)];
    
    R_3 = [ cos(theta), 0, sin(theta); ...
        0, 1,          0; ...
        -sin(theta), 0, cos(theta)];
    
    R_4 = [ cos(-theta), 0, sin(-theta); ...
        0, 1,           0; ...
        -sin(-theta), 0, cos(-theta)];
    
    R_5 = [ 1,           0,           0; ...
        0, cos(-theta), sin(-theta); ...
        0,-sin(-theta), cos(-theta)];
    
%     %Check k-vector rotations:
%     kr_1 = (R_1 * k(1,:)')';  %checks out
%     kr_2 = (R_2 * k(2,:)')';
%     kr_3 = (R_3 * k(3,:)')';
%     kr_4 = (R_4 * k(4,:)')';
%     kr_5 = (R_5 * k(5,:)')';
    
    
    EfieldsR = zeros(size(Efields));  %Preallocates
    
    tic
    
    %Rotate each vector for equivalence to normal incidence:
    EfieldsR(:,1,:) = (R_1 * squeeze( Efields(:,1,:) )')';   %Takes all the data of a given mode, transposes it, multiplies by rotation matrix, then transposes back
    EfieldsR(:,2,:) = (R_2 * squeeze( Efields(:,2,:) )')';
    EfieldsR(:,3,:) = (R_3 * squeeze( Efields(:,3,:) )')';
    EfieldsR(:,4,:) = (R_4 * squeeze( Efields(:,4,:) )')';
    EfieldsR(:,5,:) = (R_5 * squeeze( Efields(:,5,:) )')';
    %disp(squeeze(EfieldsR(1:10,1,:)))
    
    
    %Get RCP and LCP components:
    RCP_polarizer =  1/2* [ 1, -1i, 0; 1i, 1, 0; 0,0,0];
    %LCP_polarizer =  1/2* [ 1, 1i, 0; -1i, 1, 0; 0,0,0];
    
    EfieldRCP = zeros(Nsims(fi),Nmodes,Ndimensions);
    EfieldRCP(:,1,:) = (RCP_polarizer * squeeze(EfieldsR(:,1,:))' )';
    EfieldRCP(:,2,:) = (RCP_polarizer * squeeze(EfieldsR(:,2,:))' )';
    EfieldRCP(:,3,:) = (RCP_polarizer * squeeze(EfieldsR(:,3,:))' )';
    EfieldRCP(:,4,:) = (RCP_polarizer * squeeze(EfieldsR(:,4,:))' )';
    EfieldRCP(:,5,:) = (RCP_polarizer * squeeze(EfieldsR(:,5,:))' )';
    
%     EfieldLCP = zeros(Nsims,Nmodes,Ndimensions);
%     EfieldLCP(:,1,:) = (LCP_polarizer * squeeze(EfieldsR(:,1,:))' )';
%     EfieldLCP(:,2,:) = (LCP_polarizer * squeeze(EfieldsR(:,2,:))' )';
%     EfieldLCP(:,3,:) = (LCP_polarizer * squeeze(EfieldsR(:,3,:))' )';
%     EfieldLCP(:,4,:) = (LCP_polarizer * squeeze(EfieldsR(:,4,:))' )';
%     EfieldLCP(:,5,:) = (LCP_polarizer * squeeze(EfieldsR(:,5,:))' )';
    
    %disp(squeeze(EfieldRCP(1:10,1,:) ))  %RCP should be much stronger
    %disp(squeeze(EfieldLCP(1:10,1,:) ))
    
    %Phase: Defined by phase of RCP light
    phaseRCP = angle(EfieldRCP(:,:,1));
    
    %Calculate phase parameter defined in paper
    phaseParam = mod( ( phaseRCP(:,2)+phaseRCP(:,5) ) - ( phaseRCP(:,3) + phaseRCP(:,4) ), 2*pi ); %periodic on 2*pi
    
    %Getting orientation and ellipticity:
    E_mag = abs(EfieldsR); %magnitude of each component
    phases = angle(EfieldsR); %Gets relative phase of each component
    
    
    %Calculate orientation and ellipticity angles
    orientation = 1/2 * atan2d( 2*E_mag(:,:,1).*E_mag(:,:,2).*cos(phases(:,:,1)-phases(:,:,2)) , (E_mag(:,:,2).^2-E_mag(:,:,1).^2) );
    ellipticity = 1/2 * asind( 2*E_mag(:,:,1).*E_mag(:,:,2)./(E_mag(:,:,2).^2+E_mag(:,:,1).^2).*sin(phases(:,:,1)-phases(:,:,2)) );
    
    %Calculate diffraction efficiencies
    %relativeAreas = [1, k_diff_z/k_0, k_diff_z/k_0, k_diff_z/k_0, k_diff_z/k_0];  %Accounts for cosine law of non-normally incident power
    E2_sum = sum( EfieldsR.*conj(EfieldsR), 3);  %sums squares of E-field amplitude
    diffEff = zeros(Nsims(fi),Nmodes);
    diffEff(:,1) =  E2_sum(:,1).* 1 * n_interference;
    diffEff(:,2:5) = E2_sum(:,2:5) .* k_diff_z/k_0 *n_interference;  %Accounts for cosine law of non-normally incident power
    %disp(diffEff(1:10,:))
    %Check
    %sum(diffEff(1:10,:),2)
    
    % %Plot diffraction efficiencies of opposite orders
    % figure
    % plot(diffEff(:,2),diffEff(:,5),'b.')
    %
    % %Plot phase parameter versus diffraction efficiency
    % figure
    % plot( diffEff(:,2), phaseParam, 'b.')
    %
    % %Plot orientation vs ellipticity of diffracted mode
    % figure
    % plot( orientation(:,2),ellipticity(:,2) )
    
    %disp( [ diffEff, phaseParam, orientation, ellipticity ] );
    
    %size1 = size( [ diffEff, phaseParam, orientation, ellipticity ] )
    
    %Combine Calculated data
    fullData{fi} = [ diffEff, phaseParam, orientation, ellipticity ];

    
    checkforimag = max(max(abs(imag(fullData{fi}))))
    
    %size2 = size(fullData{1})
    
end


%Define linespec for each file in plot:
linespec = {'b-','b--','r-','r--'}

%Do filtration and plots

for p=1:length(plottingParams.plots)  %for each plot
    thisPlot = plottingParams.plots(p)
    figure
    hold on
    
    sizefilenames = size(filenames_common)
    for fi = 1:size(filenames_common,2)  %for each fileset
        iout = fi
        if thisPlot.filter  %If you need to filter
            filteringData = real( fullData{fi}( all(isfinite(fullData{fi}),2)  ,:) ); %do basic filtering into copy of data
            for li=1:length(thisPlot.limits ) %for each filter needed
                thisLimit = thisPlot.limits(li);
                index = thisLimit.index
                imin = thisLimit.min
                imax = thisLimit.max
                filteringData = filteringData( filteringData(:,thisLimit.index) > thisLimit.min & filteringData(:,thisLimit.index) < thisLimit.max , : );
                %filteringData( (filteringData(:,thisLimit.index) > thisLimit.min) & (filteringData(:,thisLimit.index) < thisLimit.max) , : ) = [];
                limsize = size(filteringData)
            end
            fullData_filtered = filteringData;
        else
            %fullData_filtered{fi} = real( fullData{fi} );
            fullData_filtered = real( fullData{fi}( all(isfinite(fullData{fi}),2)  ,:) );   %removes rows that contain nan or inf, and removes imaginary part (should be ~0)
        end
        
        %disp(fullData)
        %sizeout = size( fullData_filtered{fi}(:,thisPlot.XaxisIndex))
        
        checkforimag = max(max(abs(imag( fullData_filtered(:,thisPlot.XaxisIndex) ))))
        checkforimag = max(max(abs(imag( fullData_filtered(:,thisPlot.YaxisIndex) ))))
        
        %disp( fullData_filtered{fi}(:,thisPlot.XaxisIndex) )
        
        %Make an alpha shape around the desired axes, scaling the
        %y-axis by the alphaAspectRatio
        %alphaShp = alphaShape( double(fullData{i}(:,thisPlot.XaxisIndex)),  double(fullData{i}(:,thisPlot.YaxisIndex))./thisPlot.alphaAspectRatio, thisPlot.alphaRadius);
        xpoints = fullData_filtered(:,thisPlot.XaxisIndex);
        ypoints = fullData_filtered(:,thisPlot.YaxisIndex)./thisPlot.alphaAspectRatio;
        
        %alphaShp = alphaShape( fullData_filtered{fi}(:,thisPlot.XaxisIndex),  fullData_filtered{fi}(:,thisPlot.YaxisIndex) )
        %alphaShp = alphaShape( xpoints,  ypoints, thisPlot.alphaRadius )
        alphaShp = alphaShape( xpoints,  ypoints, 1 )
        
        %Get the points at the edge of the alpha shape
        [bf,boundaryPoints] = boundaryFacets(alphaShp);
        boundaryPoints(:,2) = boundaryPoints(:,2).*thisPlot.alphaAspectRatio;
        sizbf = size(bf)
        
        %Connect the first and last points of the outside edge
        boundaryPoints(end+1,:) = boundaryPoints(1,:);
        %outsideEdgeL = boundaryPoints( 1);
        %outsideEdgeR = alphaShp.Points( bf(:,1),2);
        %outsideEdge = [outsideEdgeL,outsideEdgeR];
        %lastPoint = [outsideEdge(1,1),outsideEdge(1,2)];
        %outsideEdge = [outsideEdge; lastPoint ];
        
%         %Connect the first and last points of the outside edge
%         outsideEdgeL = alphaShp.Points( bf(:,1),1);
%         outsideEdgeR = alphaShp.Points( bf(:,1),2);
%         outsideEdge = [outsideEdgeL,outsideEdgeR];
%         lastPoint = [outsideEdge(1,1),outsideEdge(1,2)];
%         outsideEdge = [outsideEdge; lastPoint ];
        
        %Plot according to the linespec for the file
        %plot(outsideEdge(:,1), outsideEdge(:,2),linespec{fi});
        plot(boundaryPoints(:,1),boundaryPoints(:,2),linespec{fi});
        
        %Write the convex hull data to file, with the 
        
        
    end





toc
    
end
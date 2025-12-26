function results = analyze_layers(binaryMask)
% ANALYZE_LAYERS Measures the thickness of the detected fascia lines.
%
%   INPUT:  binaryMask (White = Fascia Lines)
%   OUTPUT: results struct with Mean/Max thickness of each line.

    %% 1. DETECT LINES
    [labeledImage, numObjects] = bwlabel(binaryMask);
    stats = regionprops(labeledImage, 'Area', 'Centroid', 'PixelList');
    
    % Filter noise (must be large enough to be a fascia line)
    minAreaThreshold = 1000; 
    validIndices = find([stats.Area] > minAreaThreshold);
    
    if isempty(validIndices)
        warning('No valid fascia lines detected.');
        results = [];
        return;
    end
    
    validStats = stats(validIndices);
    
    %% 2. SORT (Top to Bottom)
    % Sort by Y-coordinate so "Layer 1" is always the top one.
    centroids = cat(1, validStats.Centroid);
    [~, sortOrder] = sort(centroids(:, 2), 'ascend'); 
    sortedStats = validStats(sortOrder);
    
    %% 3. ANALYZE EACH FASCIA LINE
    numLayers = length(sortedStats);
    results = struct();
    
    for i = 1:numLayers
        % Get the pixels for this specific line
        pixelList = sortedStats(i).PixelList;
        
        % --- COLUMN SCANNING ---
        % Find the top and bottom edge of the white line for every column
        cols = unique(pixelList(:,1));
        
        y_top_raw = zeros(size(cols));
        y_bot_raw = zeros(size(cols));
        
        for k = 1:length(cols)
            c = cols(k);
            % Get all Y-values for this X-column
            y_vals = pixelList(pixelList(:,1) == c, 2);
            
            y_top_raw(k) = min(y_vals); % Top edge of the white line
            y_bot_raw(k) = max(y_vals); % Bottom edge of the white line
        end
        
        % --- POLYNOMIAL SMOOTHING ---
        % Fit a curve to smooth out the jagged pixel edges
        p_top = polyfit(cols, y_top_raw, 2);
        p_bot = polyfit(cols, y_bot_raw, 2);
        
        smooth_top = polyval(p_top, cols);
        smooth_bot = polyval(p_bot, cols);
        
        % --- CALCULATE THICKNESS ---
        thicknessProfile = smooth_bot - smooth_top;
        
        % --- STORE CLEAN RESULTS ---
        results(i).LayerID = i;
        results(i).MeanThickness = mean(thicknessProfile);
        results(i).MaxThickness = max(thicknessProfile);
        
        % Save plotting data (hidden from simple display, used for graph)
        results(i).XData = cols;
        results(i).Y_Top = smooth_top;
        results(i).Y_Bottom = smooth_bot;
    end
end
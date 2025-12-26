function final_mask = segment_layer(I_clean)
    %% 1. ENHANCE (Top-Hat)
    se_structure = strel('disk', 15);
    I_enhanced = imtophat(I_clean, se_structure);
    I_enhanced = imadjust(I_enhanced);

    %% 2. STRICT BINARIZATION
    % Sensitivity 0.20 is robust.
    T = adaptthresh(I_enhanced, 0.20, 'ForegroundPolarity', 'bright');
    bw_raw = imbinarize(I_enhanced, T);

    %% 3. THICKNESS FILTER
    % Delete thin vertical lines (muscle texture)
    se_thickness = strel('line', 3, 90);
    bw_thick_only = imopen(bw_raw, se_thickness);

    %% 4. LENGTH FILTER (Tweak 1: Slightly Stricter)
    % Increased from 80 to 100. This helps remove smaller fragments.
    se_length = strel('line', 100, 0);
    bw_long_only = imopen(bw_thick_only, se_length);

    %% 5. BRIDGE GAPS
    bw_connected = imclose(bw_long_only, strel('line', 40, 0));

    %% 6. ACTIVE CONTOUR
    mask = activecontour(I_clean, bw_connected, 30, 'Chan-Vese', ...
        'SmoothFactor', 0.5, 'ContractionBias', 0.1);
    mask = imfill(mask, 'holes');

    %% 7. RANKING SYSTEM 
    [L, num] = bwlabel(mask);
    
    % Get properties (Intensity requires the grayscale image I_clean)
    stats = regionprops(L, I_clean, 'MajorAxisLength', 'Orientation', 'MeanIntensity', 'BoundingBox');
    
    line_scores = zeros(1, num);
    valid_indices = [];
    
    for k = 1:num
        % Constraints
        isHorizontal = abs(stats(k).Orientation) < 15;
        % Keep 250 length requirement (good balance)
        isLong = stats(k).MajorAxisLength > 250; 
        
        if isHorizontal && isLong
            % Features
            thickness = stats(k).BoundingBox(4);
            length_val = stats(k).BoundingBox(3);
            brightness = stats(k).MeanIntensity;
            
            % SCORE = Length * Thickness * Brightness
            line_scores(k) = length_val * thickness * brightness;
            valid_indices = [valid_indices, k];
        end
    end
    
   
    if ~isempty(valid_indices)
        % 1. Find the "Champion" (The strongest line in the image)
        max_score = max(line_scores(valid_indices));
        
        % 2. Filter: Only keep lines that are at least 30% as strong as the Champion
        % This kills the "weak" false positive  
        % score will be very low compared to the massive muscle line.
        score_threshold = 0.30 * max_score;
        
        strong_indices = valid_indices(line_scores(valid_indices) > score_threshold);
        
        % 3. Sort the survivors by score
        [~, sortIdx] = sort(line_scores(strong_indices), 'descend');
        final_candidates = strong_indices(sortIdx);
        
        % 4. Keep Top 3 (Safety cap)
        num_to_keep = min(length(final_candidates), 3);
        best_candidates = final_candidates(1:num_to_keep);
        
        candidates_mask = ismember(L, best_candidates);
    else
        candidates_mask = false(size(mask));
    end

    %% 8. SKIN REMOVAL
    [L_cand, num_cand] = bwlabel(candidates_mask);
    
    if num_cand > 1
        stats_cand = regionprops(L_cand, 'Centroid');
        centroids = cat(1, stats_cand.Centroid);
        
        % Sort Top to Bottom (Y-coordinate)
        [~, sortIdx] = sort(centroids(:,2), 'ascend');
        
        % Remove Top Layer (Skin)
        muscle_indices = sortIdx(2:end);
        final_mask = ismember(L_cand, muscle_indices);
    else
        final_mask = candidates_mask;
    end
end
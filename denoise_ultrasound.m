function I_clean = denoise_ultrasound(I)
    % 1. NORMALIZE
    I = double(I);
    I = (I - min(I(:))) / (max(I(:)) - min(I(:)));

    % 2. SPECKLE REDUCTION (SRAD or Median)
    % Median filter is robust against the "salt and pepper" noise of ultrasound
    I_med = medfilt2(I, [5 5]); 

    % 3. STRONG GAUSSIAN BLUR
    % Sigma = 2.0 (was 0.5 or 1.0). This blurs the fine muscle striations
    % so they don't get detected as lines later.
    I_smooth = imgaussfilt(I_med, 2.0); 

    % 4. NORMALIZE OUTPUT
    I_clean = I_smooth;
    I_clean = (I_clean - min(I_clean(:))) / (max(I_clean(:)) - min(I_clean(:)));
end
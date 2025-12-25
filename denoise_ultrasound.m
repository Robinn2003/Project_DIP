function I_clean = denoise_ultrasound(I)

% Step 0: Ensure input is double and normalized [0,1]
I = double(I);
I = I / max(I(:));

% Step 1: Apply SRAD for speckle noise reduction
num_iter = 20;
dt = 0.03;
q0 = 0.85;
I_srad = SRAD(I, num_iter, dt, q0);

% Step 2: Gentle edge-preserving smoothing
I_smooth = imguidedfilter(I_srad, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);

% Step 3: Moderate contrast enhancement
I_enhanced = adapthisteq(I_smooth, 'ClipLimit', 0.015, 'NBins', 128);

% Step 4: Optional mild sharpening (unsharp masking)
H = fspecial('unsharp');  % default small kernel
I_sharp = imfilter(I_enhanced, H) * 0.2 + I_enhanced * 0.8; % mild blending

% Step 5: Normalize and remove negatives
I_clean = max(I_sharp, 0);
I_clean = I_clean - min(I_clean(:));
I_clean = I_clean / max(I_clean(:));

end
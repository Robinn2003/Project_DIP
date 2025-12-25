function I_srad = SRAD(I, num_iter, dt, q0)
% I      = input grayscale image (double, normalized 0..1)
% num_iter = number of iterations 
% dt     = time step (0.1)
% q0     = speckle threshold (0.5–1.0)
%
% OUTPUT:
% I_srad = denoised ultrasound image

    I = double(I);
    [rows, cols] = size(I);

    for t = 1:num_iter

        % Neighbour differences
        IN = [I(1,:); I(1:rows-1,:)];        % shift up
        IS = [I(2:rows,:); I(rows,:)];       % shift down
        IW = [I(:,1) I(:,1:cols-1)];          % shift left
        IE = [I(:,2:cols) I(:,cols)];         % shift right

        % Directional gradients
        dN = IN - I;
        dS = IS - I;
        dW = IW - I;
        dE = IE - I;

        % Instantaneous coefficient of variation
        num = (dN.^2 + dS.^2 + dW.^2 + dE.^2);
        den = (I.^2 + eps);

        q = sqrt(0.5 * num ./ den);

        % Diffusion coefficients
        c = exp(-(q.^2 - q0^2) ./ (q0^2 * (q.^2 + eps)));

        % Ensure stability
        c = max(min(c, 1), 0);

        % Divergence
        div = c .* dN + c .* dS + c .* dW + c .* dE;

        % Update
        I = I + dt * div;
    end

    I_srad = I;
end
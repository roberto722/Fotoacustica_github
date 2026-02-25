function p0_rec = backproject_waveeq_linear_gpu( ...
    sigMat, fov_x, fov_y, x_position, z_position, ...
    speed_of_sound, sampling_frequency, ...
    cropped_or_unrecorded_signals_at_sinogram_start, ...
    psf, K, useGPU)

if nargin < 11
    useGPU = true;
end

% ---- Cast + move to GPU (consigliato: single) ----
if useGPU
    sigMat      = gpuArray(single(sigMat));
    fov_x       = gpuArray(single(fov_x));
    fov_y       = gpuArray(single(fov_y));
    x_position  = gpuArray(single(x_position(:)')); % 1 x P
    z_position  = gpuArray(single(z_position(:)')); % 1 x P
    psf         = gpuArray(single(psf));
    K           = gpuArray(single(K));
else
    sigMat      = single(sigMat);
    fov_x       = single(fov_x);
    fov_y       = single(fov_y);
    x_position  = single(x_position(:)');
    z_position  = single(z_position(:)');
    psf         = single(psf);
    K           = single(K);
end
tic
dt = single(1 / sampling_frequency);

number_of_samples     = size(sigMat, 1);
number_of_transducers = size(sigMat, 2);
number_of_wavelengths = size(sigMat, 3);

aq_samples  = (1:number_of_samples) + cropped_or_unrecorded_signals_at_sinogram_start;
aq_seconds  = single(aq_samples) * dt;           % 1 x Ns

angle_of_all_transducers = single(-pi/2);
cAng = cos(angle_of_all_transducers);
sAng = sin(angle_of_all_transducers);

% ---- 1) Radial integrals (evita repmat) ----
% sigMat = cumtrapz(t, sig/c, 1) ./ t
sigMat = cumtrapz(aq_seconds, sigMat / single(speed_of_sound), 1) ./ reshape(aq_seconds, [], 1);

% ---- 2) Prefilter ----
sigMat = convn(sigMat, psf, 'same') / sum(psf(:), 'all');

% ---- 3) Precompute T for ALL pixels and transducers (vettoriale) ----
% Flatten grid
X = fov_x(:);  % Npix x 1
Y = fov_y(:);  % Npix x 1
Npix = numel(X);
P    = number_of_transducers;

% Distances: Npix x P (implicit expansion)
dx = X - x_position;  % Npix x P
dy = Y - z_position;  % Npix x P
dist = hypot(dx, dy);

T = round( (dist / single(speed_of_sound) - aq_seconds(1)) * single(sampling_frequency) + 1 );

% Clamp indices to [1, Ns] (importantissimo su GPU per evitare crash)
T = min(max(T, 1), number_of_samples);

% Linear indices into sigMat_wl (Ns x P)
colOffsets = (0:P-1) * number_of_samples;   % 1 x P
linIdx = T + colOffsets;                   % Npix x P

% ---- 4) Divergence helper (gradient) ----
% Assumiamo griglia quasi uniforme: ricavo dx, dy dalla mesh
dx_grid = mean(diff(fov_x(1,:)), 'all');
dy_grid = mean(diff(fov_y(:,1)), 'all');

p0_rec = zeros(size(fov_x,1), size(fov_x,2), number_of_wavelengths, 'like', sigMat);

% ---- 5) Loop sulle wavelength (tipicamente poche) ----
for wl = 1:number_of_wavelengths

    % K submatrix * sigMat(:,:,wl) * dt
    % (se K è grande, questo è costoso: valuteremo dopo come ottimizzarlo/approssimarlo)
    sigMat_wl = K(aq_samples, aq_samples) * sigMat(:,:,wl) * dt; % Ns x P

    % Gather values at (T,p) for all pixels & all transducers: Npix x P
    vals = sigMat_wl(linIdx);

    % Accumulo su transducers: Npix x 1
    sumVals = sum(vals, 2);

    % p0 components (angle constant)
    p0x = reshape(sumVals * (cAng * dt * single(speed_of_sound)), size(fov_x));
    p0y = reshape(sumVals * (sAng * dt * single(speed_of_sound)), size(fov_x));

    % Divergence via gradient (GPU-friendly)
    [dP0x_dx, ~] = gradient(p0x, dx_grid, dy_grid);
    [~, dP0y_dy] = gradient(p0y, dx_grid, dy_grid);
    divP0 = dP0x_dx + dP0y_dy;

    p0_rec(:,:,wl) = fliplr(divP0);
end

% Return to CPU if needed
if useGPU
    p0_rec = gather(p0_rec);
end
t = toc
disp("Tempo BP gpu")
end

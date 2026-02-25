function [subsampled_sinogram] = subSampler(sinogram)
% Supponiamo di avere una matrice M di dimensione 128 × x
% Ad esempio:
% M = rand(128, 1000); % Esempio con 1000 colonne

% Sottocampionamento ogni 4 colonne
subsampled_sinogram = sinogram(1:4:end, :);
subsampled_sinogram = subsampled_sinogram(1:1020, :);

% Verifica delle dimensioni
fprintf('Dimensioni originali: %d x %d\n', size(sinogram,1), size(sinogram,2));
fprintf('Dimensioni sottocampionate: %d x %d\n', size(subsampled_sinogram,1), size(subsampled_sinogram,2));
end


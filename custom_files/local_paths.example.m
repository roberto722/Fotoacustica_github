function paths = local_paths()
%LOCAL_PATHS Esempio di configurazione locale non versionata.
%
%   Copia questo file in custom_files/local_paths.m e personalizza i path.

    paths = struct();

    % Path al toolbox mb-rec-msot
    paths.rec_toolbox_path = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';

    % Path opzionale per dati PoliTo
    paths.polito_data_folder = 'E:\Scardigno\Fotoacustica-MB\data\fantocci_PDMS_Y_20250422';
end

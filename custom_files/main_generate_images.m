% MAIN GENERATION SCRIPT
% Unico punto di accesso consigliato per la generazione/ricostruzione immagini.

clc; clear;

% Scegli il profilo: "voc" | "hdf5" | "polito" | "forearm_complex" | "y_shaped"
profile = "voc";

% Override centralizzati (modifica qui i parametri per il tuo esperimento)
% Suggerimento: configura i path locali in custom_files/local_paths.m
% (vedi custom_files/local_paths.example.m).
overrides = struct();

% Path runtime: premi invio per mantenere i default interni al profilo.
data_folder_input = strtrim(input('Cartella dati input (invio = default): ', 's'));
output_folder_input = strtrim(input('Cartella output salvataggio (invio = default): ', 's'));

if ~isempty(data_folder_input)
    overrides.params.data_folder = string(data_folder_input);
end
if ~isempty(output_folder_input)
    overrides.params.output_folder = string(output_folder_input);
end

% Esempi:
% overrides.rec_toolbox_path = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';
% overrides.source.dataset_name = "VOC2012";
% overrides.params.max_imgs = 10;
% overrides.params.VOC_id_imgs = {"2007_003051.jpg"};

config = build_generation_config(profile, overrides);
run_generation_pipeline(config);

% MAIN GENERATION SCRIPT
% Unico punto di accesso consigliato per la generazione/ricostruzione immagini.

clc; clear;

% Scegli il profilo: "voc" | "hdf5" | "polito" | "forearm_complex" | "y_shaped"
profile = "voc";

% Override centralizzati (modifica qui i parametri per il tuo esperimento)
overrides = struct();
overrides.rec_toolbox_path = 'E:\Scardigno\Fotoacustica-MB\mb-rec-msot';
% Esempi:
% overrides.source.dataset_name = "VOC2012";
% overrides.params.max_imgs = 10;
% overrides.params.VOC_id_imgs = {"2007_003051.jpg"};

config = build_generation_config(profile, overrides);
run_generation_pipeline(config);

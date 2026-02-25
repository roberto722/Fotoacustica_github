% Wrapper legacy: usa il nuovo entrypoint centralizzato.
clc; clear;
warning('Script legacy: usa custom_files/main_generate_images.m per nuovi esperimenti.');
config = build_generation_config("forearm_complex", struct());
run_generation_pipeline(config);

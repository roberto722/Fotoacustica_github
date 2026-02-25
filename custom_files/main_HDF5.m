% Wrapper legacy: usa il nuovo entrypoint centralizzato.
clc; clear;
config = build_generation_config("hdf5", struct());
run_generation_pipeline(config);

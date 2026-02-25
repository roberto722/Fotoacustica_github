% Wrapper legacy: usa il nuovo entrypoint centralizzato.
clc; clear;
config = build_generation_config("forearm_complex", struct());
run_generation_pipeline(config);

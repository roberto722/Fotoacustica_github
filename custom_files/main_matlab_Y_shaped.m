% Wrapper legacy: usa il nuovo entrypoint centralizzato.
clc; clear;
config = build_generation_config("y_shaped", struct());
run_generation_pipeline(config);

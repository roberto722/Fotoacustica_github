# Fotoacustica_github

Repository MATLAB per esperimenti di ricostruzione fotoacustica (model-based e backprojection), con script dedicati a dataset sintetici e reali.

## Stato attuale del progetto
Il codice funziona come raccolta di script di ricerca, ma è poco ordinato: ci sono molti entrypoint simili (`main*.m`), percorsi locali hard-coded (`E:\...`), file di backup (`*.asv`) e utility non documentate.

Per iniziare a mettere ordine, questa repository ora include:
- una mappa dei file principali;
- una convenzione minima su quali script usare come entrypoint;
- una roadmap di riordino incrementale senza rompere i workflow esistenti.

## Mappa rapida

### Entry point principali
- `main_residuals_sinograms.m`: sweep su lambda e salvataggio residuali da sinogrammi.
- `main_residuals_polito_probe.m`: residuali/metriche su configurazione PoliTo probe.
- `custom_files/main.m`: ricostruzione da VOC (workflow base).
- `custom_files/main_residuals.m`: analisi residuali su immagini VOC.
- `custom_files/main_residuals_multiple_curves.m`: confronto di più curve L-curve.
- `custom_files/main_HDF5.m`: pipeline per dataset HDF5.
- `custom_files/main_POLITO_phantoms.m`: pipeline per phantom PoliTo.
- `custom_files/main_matlab_forearm_complex.m`: pipeline forearm complex.
- `custom_files/main_matlab_Y_shaped.m`: pipeline Y-shaped.

### Entry point unificato (consigliato)
- `custom_files/main_generate_images.m`: unico script di accesso per impostare profilo, parametri e avvio della generazione/ricostruzione immagini.
- `custom_files/build_generation_config.m`: configurazione centralizzata (default + override).
- `custom_files/run_generation_pipeline.m`: orchestrazione pipeline per VOC/HDF5/PoliTo/Forearm/Y-shaped.

### Utility di caricamento dati
- `custom_files/dataloader.m`
- `custom_files/dataloader_HDF5.m`
- `custom_files/dataloader_HDF5_subsampler.m`
- `custom_files/dataloader_POLITO.m`
- `custom_files/dataloader_ForearmComplex.m`
- `custom_files/dataloader_Y_shaped.m`
- `custom_files/sinoloader.m`

### Utility di ricostruzione
- `custom_files/reconstruct_model_based.m`
- `custom_files/reconstruct_model_based_residuals.m`
- `custom_files/reconstruct_bp.m`
- `custom_files/backproject_waveeq_linear.m`
- `custom_files/backproject_waveeq_linear_gpu.m`

### Script helper e analisi
- `custom_files/metrics.m`, `custom_files/calMAE.m`
- `custom_files/FFT_viewer.m`, `custom_files/img_viewer.m`
- `custom_files/load_params_concave.m`
- `custom_files/load_or_calculate_kernel_for_backprojection_rec.m`


## Configurazione locale (nuovo)
Per evitare path hard-coded, crea `custom_files/local_paths.m` copiando `custom_files/local_paths.example.m` e personalizza i percorsi locali (toolbox, dati PoliTo, ecc.).

Lo script `main_generate_images.m` e la pipeline centralizzata leggono automaticamente `local_paths.m` se presente. In alternativa puoi passare gli stessi valori via `overrides`.

## Convenzione consigliata (da ora in poi)
1. **Nuovi esperimenti**: partire da uno script `custom_files/main_*.m` specifico per dataset.
2. **Funzioni riusabili**: aggiungerle come `function` in file dedicati, non dentro gli script `main`.
3. **Niente nuovi path hard-coded**: centralizzare i path in una sezione iniziale (`CONFIG PATH`) dello script.
4. **No file `.asv` nel versionamento**: sono backup di MATLAB editor, non codice sorgente.

## Piano di riordino consigliato
1. Centralizzare la configurazione comune in una funzione tipo `build_default_params.m`.
2. Estrarre i path locali in un file utente non versionato (es. `local_paths.m`).
3. Eliminare progressivamente duplicazioni tra `main_residuals*.m`.
4. Aggiungere una `.gitignore` per escludere `.asv`, output `.mat` pesanti e immagini generate.
5. Aggiungere test minimi di regressione numerica sulle funzioni core (`check_length_*`, `reconstruct_model_based*`).

## Note operative
Per eseguire gli script serve il toolbox esterno richiamato con:

```matlab
run([path_to_rec_toolbox filesep 'startup_reconstruction.m']);
```

Aggiorna `path_to_rec_toolbox` in base al tuo ambiente locale.

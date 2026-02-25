# custom_files - guida rapida

Questa cartella contiene quasi tutta la logica sperimentale.

## Organizzazione logica

### 1) Script di avvio (`main_*.m`)
Sono entrypoint per esperimenti specifici (VOC, HDF5, PoliTo, forearm, Y-shaped, residuali).

Regola pratica: duplica il `main` più vicino al tuo caso d'uso e modifica solo i parametri nella sezione iniziale.

### 2) `dataloader_*` e `reconstruct_from_*`
- `dataloader_*`: importano e adattano i dati grezzi (shape, lunghezza sinogrammi, naming).
- `reconstruct_from_*`: orchestrano intera pipeline su un dataset/fonte dati.

### 3) Core numerico
- `reconstruct_model_based.m`
- `reconstruct_model_based_residuals.m`
- `reconstruct_bp.m`
- `backproject_waveeq_linear*.m`

Questi file sono i migliori candidati per test e refactoring incrementale.

## Debito tecnico osservato
- Path assoluti hard-coded in molti file (`E:\...`).
- Parametri duplicati in diversi `main_*.m`.
- Presenza di backup MATLAB (`*.asv`) nello stesso albero.

## Priorità suggerite
1. Introdurre `build_default_params.m` per ridurre duplicazioni.
2. Unificare naming (`*_ids`, `*_id_imgs`, `*_imgs_id`) in una convenzione coerente.
3. Spostare gradualmente script viewer/utility non core in una sottocartella `tools/`.


## Nuovo flusso consigliato (centralizzato)
Per evitare duplicazioni tra i vari `main_*.m`, usa **solo**:

- `main_generate_images.m` come script di accesso unico;
- `build_generation_config.m` per definire profilo e impostazioni;
- `run_generation_pipeline.m` per lanciare la pipeline.

I vecchi script `main.m`, `main_HDF5.m`, `main_POLITO_phantoms.m`, `main_matlab_forearm_complex.m`, `main_matlab_Y_shaped.m` ora sono wrapper legacy che richiamano questa pipeline centralizzata.

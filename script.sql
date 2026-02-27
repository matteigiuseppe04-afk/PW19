-- === Layer "Profilo" (CURRENT/TARGET) + Framework/Controlli/Subcategory ===
CREATE TABLE Framework (
    id_framework SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    versione VARCHAR(50) NOT NULL,
    data_pubblicazione DATE,
    UNIQUE (nome, versione)
);
CREATE TABLE CategoriaFramework (
    id_categoria SERIAL PRIMARY KEY,
    id_framework INT NOT NULL REFERENCES Framework(id_framework) ON DELETE CASCADE,
    codice VARCHAR(30) NOT NULL,          -- es. ID, PR, DE... oppure codici usati nel framework
    nome VARCHAR(150) NOT NULL,
    UNIQUE (id_framework, codice)
);
CREATE TABLE Subcategory (
    id_subcategory SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL REFERENCES CategoriaFramework(id_categoria) ON DELETE CASCADE,
    codice VARCHAR(50) NOT NULL,          -- es. PR.AC-1 / ID.AM-2 (o codifica equivalente)
    descrizione TEXT NOT NULL,
    UNIQUE (id_categoria, codice)
);
-- Istanza del profilo per azienda: attuale (CURRENT) o target (TARGET)
CREATE TABLE Profilo (
    id_profilo SERIAL PRIMARY KEY,
    id_azienda INT NOT NULL REFERENCES Azienda(id_azienda) ON DELETE CASCADE,
    id_framework INT NOT NULL REFERENCES Framework(id_framework),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('CURRENT', 'TARGET')),
    data_riferimento DATE NOT NULL,
    note TEXT,
    UNIQUE (id_azienda, id_framework, tipo, data_riferimento)
);
-- Righe del profilo: valutazione della singola subcategory/controllo
CREATE TABLE ProfiloVoce (
    id_voce SERIAL PRIMARY KEY,
    id_profilo INT NOT NULL REFERENCES Profilo(id_profilo) ON DELETE CASCADE,
    id_subcategory INT NOT NULL REFERENCES Subcategory(id_subcategory),
    stato VARCHAR(15) NOT NULL CHECK (stato IN ('NON_IMPL', 'PARZIALE', 'IMPL', 'N_A')),
    livello_maturita INTEGER CHECK (livello_maturita BETWEEN 0 AND 5),
    note TEXT,
    UNIQUE (id_profilo, id_subcategory)
);
-- Associazione esplicita Asset ↔ Subcategory (richiesta dal prof)
CREATE TABLE AssetSubcategory (
    id_asset INT NOT NULL REFERENCES Asset(id_asset) ON DELETE CASCADE,
    id_subcategory INT NOT NULL REFERENCES Subcategory(id_subcategory) ON DELETE CASCADE,
    ruolo VARCHAR(20) NOT NULL CHECK (ruolo IN ('SOGGETTO', 'IMPLEMENTA', 'SUPPORTA')),
    note TEXT,
    PRIMARY KEY (id_asset, id_subcategory, ruolo)
);
-- Indici utili per query profilo
CREATE INDEX idx_profilo_azienda_tipo ON Profilo (id_azienda, tipo, data_riferimento);
CREATE INDEX idx_voce_profilo ON ProfiloVoce (id_profilo, id_subcategory);
CREATE INDEX idx_asset_subcat_subcategory ON AssetSubcategory (id_subcategory);



CREATE TABLE Azienda (
    id_azienda SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    codice_acn CHAR(10) UNIQUE NOT NULL,
    settore VARCHAR(50),
    sede_legale VARCHAR(150)
);
CREATE TABLE Asset (
    id_asset SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    criticita INTEGER CHECK (criticita BETWEEN 1 AND 5),
    id_azienda INT REFERENCES Azienda(id_azienda) ON DELETE CASCADE
);
CREATE TABLE Servizio (
    id_servizio SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    descrizione TEXT,
    livello_impatti INTEGER CHECK (livello_impatti BETWEEN 1 AND 5)
);
CREATE TABLE Dipendenza (
    id_dipendenza SERIAL PRIMARY KEY,
    id_servizio INT REFERENCES Servizio(id_servizio),
    id_fornitore INT REFERENCES Fornitore(id_fornitore),
    tipo VARCHAR(50),
    data_inizio DATE,
    data_fine DATE
);

--Il sistema implementa un trigger per mantenere lo storico delle modifiche in tabella StoricoVersioni:

CREATE OR REPLACE FUNCTION trg_versioning()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO StoricoVersioni(tabella, id_record, data_modifica, utente)
    VALUES (TG_TABLE_NAME, NEW.id_asset, NOW(), current_user);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER asset_update_trg
AFTER UPDATE ON Asset
FOR EACH ROW EXECUTE FUNCTION trg_versioning();

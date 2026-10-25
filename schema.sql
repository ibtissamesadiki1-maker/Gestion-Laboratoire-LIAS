-- =========================================================================
-- Schéma de base de données MySQL — Laboratoire LIAS
-- Projet JEE — Faculté des Sciences Ben M'Sik Casablanca
-- Normalisation 3NF / BCNF & Historisation Temporelle
-- =========================================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE DATABASE IF NOT EXISTS `lias_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `lias_db`;

-- Désactiver les vérifications de clés étrangères pour le nettoyage et l'import
SET FOREIGN_KEY_CHECKS = 0;

-- Nettoyage des anciennes tables legacy si existantes
DROP TABLE IF EXISTS `publication_author`;
DROP TABLE IF EXISTS `annual_activity_reports`;
DROP TABLE IF EXISTS `affiliation_history`;
DROP TABLE IF EXISTS `applications`;
DROP TABLE IF EXISTS `audit_logs`;
DROP TABLE IF EXISTS `events`;
DROP TABLE IF EXISTS `forum_messages`;
DROP TABLE IF EXISTS `forum_topics`;
DROP TABLE IF EXISTS `material_requests`;
DROP TABLE IF EXISTS `meeting_minutes`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `system_settings`;
DROP TABLE IF EXISTS `teams`;

-- Nettoyage des tables officielles LIAS
DROP TABLE IF EXISTS `convention_activites`;
DROP TABLE IF EXISTS `conventions`;
DROP TABLE IF EXISTS `reunions_pv`;
DROP TABLE IF EXISTS `arrivages_materiel`;
DROP TABLE IF EXISTS `materiels`;
DROP TABLE IF EXISTS `demandes_adhesion`;
DROP TABLE IF EXISTS `evenements`;
DROP TABLE IF EXISTS `publications`;
DROP TABLE IF EXISTS `mandats`;
DROP TABLE IF EXISTS `affiliation_periods`;
DROP TABLE IF EXISTS `members`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `documents_labo`;
DROP TABLE IF EXISTS `communications_internes`;
DROP TABLE IF EXISTS `notifications_labo`;

-- -------------------------------------------------------------------------
-- 1. Table des Utilisateurs du système (Authentification & RBAC)
-- -------------------------------------------------------------------------
CREATE TABLE `users` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(100) NOT NULL,
    `prenom` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` VARCHAR(50) NOT NULL DEFAULT 'visiteur',
    `actif` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

INSERT INTO `users` (`id`, `nom`, `prenom`, `email`, `password`, `role`, `actif`) VALUES
(1, 'Essadiki', 'Ibtissam', 'directeur@lias.ma', 'admin123', 'directeur', 1),
(2, 'Tahiri', 'Youssef', 'permanent@lias.ma', 'pass123', 'permanent', 1),
(10, 'Benjelloun', 'Sara', 'vice-directeur@lias.ma', 'pass123', 'permanent', 1),
(3, 'Alami', 'Amine', 'doctorant@lias.ma', 'doc123', 'doctorant', 1),
(4, 'Admin', 'Système', 'admin@lias.ma', 'admin123', 'admin', 1),
(5, 'Zouhair', 'Karim', 'karim.zouhair@lias.ma', 'pass123', 'permanent', 1),
(11, 'Zouhair', 'Karim', 'chef-equipe@lias.ma', 'pass123', 'permanent', 1),
(6, 'Berrada', 'Fatima', 'associe@lias.ma', 'pass123', 'associe', 1),
(7, 'Mansouri', 'Omar', 'retraite@lias.ma', 'pass123', 'retraite', 0),
(8, 'Bennis', 'Reda', 'ancien@lias.ma', 'pass123', 'ancien', 0);

-- -------------------------------------------------------------------------
-- 2. Table des Membres du laboratoire (Profils académiques)
-- -------------------------------------------------------------------------
CREATE TABLE `members` (
    `id` VARCHAR(50) PRIMARY KEY,
    `firstName` VARCHAR(100) NOT NULL,
    `lastName` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `status` VARCHAR(50) NOT NULL,
    `role` VARCHAR(50) NOT NULL,
    `team` VARCHAR(50),
    `grade` VARCHAR(100),
    `photo` MEDIUMTEXT NULL,
    `etablissement_origine` VARCHAR(150) DEFAULT 'Faculté des Sciences Ben M''Sik',
    `laboratoire_origine` VARCHAR(150) DEFAULT 'LIAS',
    `biographie` TEXT NULL,
    `centres_interet` VARCHAR(255) DEFAULT 'Intelligence Artificielle, Big Data',
    `date_naissance` DATE NULL,
    `date_embauche` DATE NULL,
    `date_affiliation` DATE NOT NULL DEFAULT '2021-09-01'
) ENGINE=InnoDB;

INSERT INTO `members` (`id`, `firstName`, `lastName`, `email`, `status`, `role`, `team`, `grade`, `date_naissance`, `date_embauche`, `date_affiliation`, `biographie`, `centres_interet`) VALUES
('ie', 'Ibtissam', 'Essadiki', 'directeur@lias.ma', 'permanent', 'directeur', 'IA', 'Professeur de l''Enseignement Supérieur', '1980-04-12', '2006-09-01', '2016-09-01', 'Spécialiste en Deep Learning, vision par ordinateur et systèmes distribués. Directrice du laboratoire LIAS.', 'Deep Learning, Vision par Ordinateur, IA & Data Science'),
('sb', 'Sara', 'Benjelloun', 'vice-directeur@lias.ma', 'permanent', 'vice-directeur', 'Big Data', 'Professeur Habilité', '1982-08-25', '2012-10-01', '2018-10-01', 'Recherche sur les architectures distribuées, traitement de flux massifs et lacs de données. Vice-directrice du laboratoire LIAS.', 'Big Data, Apache Spark, Cloud Computing, Streaming'),
('yt', 'Youssef', 'Tahiri', 'permanent@lias.ma', 'permanent', 'membre', 'IA', 'Professeur Habilité', '1983-05-14', '2013-09-01', '2015-09-01', 'Enseignant-chercheur permanent au LIAS. Recherche sur l''optimisation et les architectures de calcul distribué.', 'Systèmes Distribués, Calcul Parallèle, Optimisation Combinatoire'),
('as', 'Amine', 'Alami', 'doctorant@lias.ma', 'doctorant', 'membre', 'NLP', 'Doctorant', '1998-03-15', '2023-11-01', '2023-11-01', 'Thèse sur le traitement automatique du langage naturel (NLP) appliqué aux dialectes maghrébins.', 'NLP, LLMs, Dialectologie Arabe, Transformers'),
('kz', 'Karim', 'Zouhair', 'karim.zouhair@lias.ma', 'permanent', 'chef-equipe', 'Sécurité', 'Maître de Conférences', '1980-11-30', '2010-09-01', '2011-09-01', 'Sécurité des systèmes distribués, architectures Zero-Trust et cryptographie appliquée. Ancien chercheur ayant réintégré le laboratoire.', 'Cybersécurité, Zero-Trust, Blockchain, IoT Security'),
('fb', 'Fatima', 'Berrada', 'associe@lias.ma', 'associe', 'membre', 'IA', 'Chercheur Associé', '1985-06-20', '2014-02-01', '2022-01-10', 'Collaboratrice du LIAS sur l''apprentissage fédéré appliqué à la santé publique.', 'Federated Learning, Privacy, Santé Numérique'),
('om', 'Omar', 'Mansouri', 'retraite@lias.ma', 'retraite', 'aucun', 'Big Data', 'Professeur Émérite', '1958-02-10', '1988-09-01', '2004-09-01', 'Ancien directeur du laboratoire LIAS (2004–2023), mémoire vivante et conseiller scientifique honoraire.', 'Systèmes d''Information, Bases de Données, Algorithmique'),
('rb', 'Reda', 'Bennis', 'ancien@lias.ma', 'ancien', 'aucun', 'IA', 'Ancien Maître de Conférences', '1981-07-19', '2011-09-01', '2015-09-01', 'Ancien chercheur au LIAS (2015-2021), actuellement en mobilité académique.', 'Apprentissage Statistique, Systèmes Multi-Agents');

-- -------------------------------------------------------------------------
-- 3. Table des Périodes d'Affiliation (Historisation temporelle des membres CDC §4.3)
-- -------------------------------------------------------------------------
CREATE TABLE `affiliation_periods` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `member_id` VARCHAR(50) NOT NULL,
    `date_debut` DATE NOT NULL,
    `date_fin` DATE NULL,
    `role_historique` VARCHAR(150) NOT NULL,
    FOREIGN KEY (`member_id`) REFERENCES `members`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO `affiliation_periods` (`id`, `member_id`, `date_debut`, `date_fin`, `role_historique`) VALUES
(1, 'ie', '2016-09-01', '2020-08-31', 'chef-equipe'),
(2, 'ie', '2020-09-01', NULL, 'directeur (Mandat en cours)'),
(3, 'sb', '2018-10-01', '2022-09-30', 'membre'),
(4, 'sb', '2022-10-01', '2024-08-31', 'chef-equipe (Big Data)'),
(5, 'sb', '2024-09-01', NULL, 'Vice-directeur (Mandat en cours)'),
(6, 'as', '2023-11-01', NULL, 'doctorant (Thèse NLP en cours)'),
(6, 'kz', '2011-09-01', '2015-08-31', 'Doctorant & Chercheur (Période initiale)'),
(7, 'kz', '2019-01-15', NULL, 'Retour au laboratoire (Réintégration comme Chef d''équipe Sécurité)'),
(8, 'fb', '2022-01-10', NULL, 'chercheur-associe (Convention active)'),
(9, 'om', '2004-09-01', '2023-08-31', 'directeur (Départ à la Retraite · Statut Gelé)'),
(10, 'rb', '2015-09-01', '2021-08-31', 'chercheur-permanent (Départ / Mobilité externe · Compte désactivé)');

-- -------------------------------------------------------------------------
-- 4. Table des Mandats de Direction et Gouvernance
-- -------------------------------------------------------------------------
CREATE TABLE `mandats` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `titre` VARCHAR(150) NOT NULL,
    `directeur_id` VARCHAR(50) NOT NULL,
    `vice_directeur_id` VARCHAR(50) NULL,
    `chefs_equipes` VARCHAR(255) NULL,
    `date_debut` DATE NOT NULL,
    `date_fin` DATE NULL,
    `actif` BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (`directeur_id`) REFERENCES `members`(`id`)
) ENGINE=InnoDB;

INSERT INTO `mandats` (`id`, `titre`, `directeur_id`, `vice_directeur_id`, `chefs_equipes`, `date_debut`, `date_fin`, `actif`) VALUES
(1, 'Mandat Fondateur 2016-2020 : Consolidation des Équipes', 'om', 'ie', 'Pr. Ibtissam Essadiki (IA), Pr. Sara Benjelloun (Big Data)', '2016-09-01', '2020-08-31', 0),
(2, 'Mandat Quinquennal 2020-2024 : Rayonnement IA & Big Data', 'ie', 'sb', 'Pr. Sara Benjelloun (Big Data), Pr. Karim Zouhair (Sécurité)', '2020-09-01', '2024-08-31', 0),
(3, 'Mandat Actuel 2024-2028 : Intelligence Artificielle Générative & Cybersécurité', 'ie', 'sb', 'Pr. Sara Benjelloun (Big Data), Pr. Karim Zouhair (Sécurité), Pr. Amine Alami (NLP)', '2024-09-01', NULL, 1);

-- -------------------------------------------------------------------------
-- 5. Table des Publications Scientifiques
-- -------------------------------------------------------------------------
CREATE TABLE `publications` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `titre` VARCHAR(255) NOT NULL,
    `auteurs` VARCHAR(255) NOT NULL,
    `annee` INT NOT NULL,
    `revue` VARCHAR(150) NOT NULL,
    `doi` VARCHAR(100),
    `equipe` VARCHAR(50),
    `type` VARCHAR(50)
) ENGINE=InnoDB;

INSERT INTO `publications` (`id`, `titre`, `auteurs`, `annee`, `revue`, `doi`, `equipe`, `type`) VALUES
(1, 'Deep Learning for Arabic Sentiment Analysis in North African Dialects', 'Amine Alami, Ibtissam Essadiki', 2025, 'IEEE Transactions on Affective Computing', '10.1109/TAFFC.2025.01', 'NLP', 'Article'),
(2, 'Scalable Real-Time Anomaly Detection in Big Data Streams', 'Sara Benjelloun, Karim Zouhair', 2024, 'ACM Computing Surveys', '10.1145/3604921', 'Big Data', 'Article'),
(3, 'Zero-Trust Architecture for Cloud-Native Scientific Repositories', 'Karim Zouhair', 2025, 'International Conference on Information Security (ICIS)', '10.1007/978-3-030-99', 'Sécurité', 'Conférence'),
(4, 'Federated Learning over Distributed Healthcare Records', 'Ibtissam Essadiki, Fatima Berrada', 2024, 'Journal of Medical Systems', '10.1007/s10916-024', 'IA', 'Article'),
(5, 'Efficient Indexing of Multilingual Scholarly Publications', 'Amine Alami, Sara Benjelloun', 2023, 'Information Sciences', '10.1016/j.ins.2023', 'Big Data', 'Article');

-- -------------------------------------------------------------------------
-- 6. Table des Évènements Scientifiques
-- -------------------------------------------------------------------------
CREATE TABLE `evenements` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `titre` VARCHAR(255) NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `date` VARCHAR(50) NOT NULL,
    `lieu` VARCHAR(150),
    `description` TEXT,
    `organisateur` VARCHAR(100),
    `statut` VARCHAR(50),
    `edition` VARCHAR(100) DEFAULT 'Édition 2026',
    `programme` TEXT
) ENGINE=InnoDB;

INSERT INTO `evenements` (`id`, `titre`, `type`, `date`, `lieu`, `description`, `organisateur`, `statut`, `edition`, `programme`) VALUES
(1, 'Journée Scientifique LIAS 2026 : Enjeux de l''IA Générative', 'Conférence', '2026-04-15', 'Amphithéâtre Al-Kindi, FSBM', 'Rencontre annuelle rassemblant les 4 équipes de recherche et partenaires industriels.', 'Prof. Ibtissam Essadiki', 'À venir', 'Édition 2026', '09h00: Accueil & Allocution d''ouverture | 10h00: Keynote IA Fondative | 14h00: Sessions Posters Doctorants | 17h00: Clôture'),
(2, 'Workshop : Traitement Distribué avec Apache Spark', 'Workshop', '2026-03-20', 'Salle Réseau 4B', 'Atelier pratique pour les doctorants et chercheurs de l''équipe Big Data.', 'Prof. Sara Benjelloun', 'À venir', 'Édition 2026', '09h30: Introduction aux architectures distribuées | 11h00: TP Spark Streaming & BigLake | 14h30: Déploiement en cluster'),
(3, 'Séminaire : LLMs et Dialectologie Maghrébine', 'Séminaire', '2026-02-10', 'Salle des Thèses', 'Présentation des avancées sur le corpus dialectal marocain (Darija).', 'Amine Alami', 'Passé', 'Édition 2026', '14h30: Présentation des travaux | 15h30: Débat scientifique | 16h30: Synthèse & Publications prévues'),
(4, 'Conférence Internationale sur les Réseaux Intelligents (CIRI)', 'Conférence', '2025-11-18', 'Palais des Congrès, Casablanca', 'Colloque international regroupant des chercheurs du Maghreb et d''Europe.', 'Prof. Karim Zouhair', 'Archivé', 'Édition 2025', 'Session plénière: 5G et IoT | 12 papiers de recherche présentés | Actes publiés aux éditions Springer'),
(5, 'Workshop : Méthodologie de la Recherche & LaTeX Scientifique', 'Workshop', '2025-05-12', 'Salle Multimédia FSBM', 'Formation intensive aux outils de rédaction pour les nouveaux doctorants.', 'Prof. Fatima Berrada', 'Archivé', 'Édition 2025', '09h00: Structuration d''un article IEEE | 14h00: Gabarits Overleaf & Zotero'),
(6, 'Séminaire : Algorithmes Quantiques et Cryptographie Post-Quantique', 'Séminaire', '2024-12-04', 'Salle Al-Biruni', 'Séminaire invité avec le Laboratoire de Physique Théorique.', 'Prof. Ibtissam Essadiki', 'Archivé', 'Édition 2024', '15h00: Exposé magistral | 16h30: Perspectives de collaboration');

-- -------------------------------------------------------------------------
-- 7. Table des Demandes d'Adhésion
-- -------------------------------------------------------------------------
CREATE TABLE `demandes_adhesion` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(100) NOT NULL,
    `prenom` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `statutVise` VARCHAR(50),
    `etablissement` VARCHAR(150),
    `motivation` TEXT,
    `dateSoumission` VARCHAR(50),
    `decision` VARCHAR(50) DEFAULT 'EN_ATTENTE',
    `cv_path` VARCHAR(255) NULL
) ENGINE=InnoDB;

INSERT INTO `demandes_adhesion` (`id`, `nom`, `prenom`, `email`, `statutVise`, `etablissement`, `motivation`, `dateSoumission`, `decision`, `cv_path`) VALUES
(1, 'Tazi', 'Hassan', 'hassan.tazi@gmail.com', 'Doctorant', 'Faculté des Sciences Ben M''Sik', 'Recherche sur l''apprentissage par renforcement.', '2026-02-15', 'EN_ATTENTE', 'dossiers/cv_tazi_hassan.pdf'),
(2, 'Idrissi', 'Nadia', 'nadia.idrissi@ucd.ac.ma', 'Associé', 'Université Chouaib Doukkali', 'Collaboration avec l''équipe Big Data.', '2026-01-20', 'ACCEPTEE', 'dossiers/cv_idrissi_nadia.pdf');

-- -------------------------------------------------------------------------
-- 8. Table du Matériel et Équipements
-- -------------------------------------------------------------------------
CREATE TABLE `materiels` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `designation` VARCHAR(255) NOT NULL,
    `categorie` VARCHAR(100) NOT NULL,
    `demandeur` VARCHAR(150) NOT NULL,
    `dateDemande` VARCHAR(50) NOT NULL,
    `statut` VARCHAR(50) NOT NULL DEFAULT 'EN_ATTENTE',
    `dateAttribution` VARCHAR(50),
    `commentaire` TEXT
) ENGINE=InnoDB;

INSERT INTO `materiels` (`id`, `designation`, `categorie`, `demandeur`, `dateDemande`, `statut`, `dateAttribution`, `commentaire`) VALUES
(1, 'Station de calcul GPU NVIDIA RTX 4090', 'Calcul', 'Amine Alami (Doctorant)', '2026-01-05', 'ACCORDE', '2026-01-15', 'Attribué pour l''entraînement des modèles NLP.'),
(2, 'PC Portable Dell Precision 16"', 'Informatique', 'Prof. Sara Benjelloun', '2025-11-10', 'LIVRE', '2025-11-20', 'Renouvellement pour chef d''équipe Big Data.');

-- -------------------------------------------------------------------------
-- 8.bis Table du Suivi des Arrivages de Matériel (CDC §14)
-- -------------------------------------------------------------------------
CREATE TABLE `arrivages_materiel` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `numero_bon` VARCHAR(100) NOT NULL,
    `designation_lot` VARCHAR(255) NOT NULL,
    `fournisseur_source` VARCHAR(150) NOT NULL,
    `quantite` INT NOT NULL DEFAULT 1,
    `date_arrivage` VARCHAR(50) NOT NULL,
    `statut_reception` VARCHAR(50) NOT NULL DEFAULT 'CONFORME',
    `description` TEXT
) ENGINE=InnoDB;

INSERT INTO `arrivages_materiel` (`id`, `numero_bon`, `designation_lot`, `fournisseur_source`, `quantite`, `date_arrivage`, `statut_reception`, `description`) VALUES
(1, 'BL-CNRST-2026-01', 'Lot 2 Stations Calcul GPU NVIDIA RTX 4090', 'Subvention CNRST IA', 2, '2026-01-04', 'CONFORME', 'Équipements haute performance réceptionnés complets avec garantie 3 ans sur site.'),
(2, 'BL-UNIV-2025-44', 'Lot 3 PC Portables Dell Precision 16"', 'Dotation Faculté FSBM', 3, '2025-11-05', 'CONFORME', 'Stations de travail mobiles destinées aux chercheurs et doctorants du laboratoire.'),
(3, 'BL-REC-2026-08', 'Serveur NAS Rackable 24 To Synology', 'Projet Partenariat OCP', 1, '2026-02-28', 'EN_CONTROLE', 'Infrastructure mutualisée pour le stockage sécurisé des jeux de données volumineux.');

-- -------------------------------------------------------------------------
-- 9. Table des Procès-Verbaux de Réunions (Archivage institutionnel)
-- -------------------------------------------------------------------------
CREATE TABLE `reunions_pv` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `titre` VARCHAR(255) NOT NULL,
    `type_reunion` VARCHAR(100) NOT NULL DEFAULT 'Conseil de Laboratoire',
    `date_reunion` DATE NOT NULL,
    `heure` VARCHAR(50) DEFAULT '10:00 - 12:30',
    `lieu` VARCHAR(150) DEFAULT 'Salle de Réunion LIAS - FSBM',
    `ordre_du_jour` TEXT,
    `chemin_fichier_pv` VARCHAR(255) NOT NULL,
    `directeur_signataire` VARCHAR(100),
    `secretaire_seance` VARCHAR(100) DEFAULT 'Secrétariat LIAS',
    `statut` VARCHAR(50) NOT NULL DEFAULT 'ARCHIVEE'
) ENGINE=InnoDB;

INSERT INTO `reunions_pv` (`id`, `titre`, `type_reunion`, `date_reunion`, `heure`, `lieu`, `ordre_du_jour`, `chemin_fichier_pv`, `directeur_signataire`, `secretaire_seance`, `statut`) VALUES
(1, 'Assemblée Générale Annuelle 2025', 'Assemblée Générale', '2025-09-15', '09:30 - 13:00', 'Amphithéâtre Hassan II - FSBM', '1. Bilan d''activité 2024-2025.\n2. Budget équipement & dotations.\n3. Accueil des nouveaux doctorants.\n4. Élection du comité scientifique.', 'archives/pv_ag_2025.pdf', 'Prof. Ibtissam Essadiki', 'Prof. Mohamed Benali', 'ARCHIVEE'),
(2, 'Conseil de Laboratoire : Validation des Thèses & Soutenances', 'Conseil de Laboratoire', '2025-12-20', '10:00 - 12:30', 'Salle du Conseil LIAS', '1. Autorisation de soutenance de 3 doctorants.\n2. Calendrier scientifique 2026.\n3. Arbitrage des publications internationales.', 'archives/pv_conseil_dec2025.pdf', 'Prof. Ibtissam Essadiki', 'Prof. Nadia Tazi', 'ARCHIVEE'),
(3, 'Conseil Extraordinaire : Arbitrage Matériel GPU', 'Conseil Extraordinaire', '2026-01-10', '14:30 - 16:30', 'Salle de Réunion LIAS - FSBM', '1. Répartition équitable de la dotation calcul haute performance GPU.\n2. Attribution de la station de calcul principale à l''équipe IA.\n3. Planning d''accès partagé pour les doctorants.', 'archives/pv_gpu_jan2026.pdf', 'Prof. Ibtissam Essadiki', 'Prof. Mohamed Benali', 'ARCHIVEE'),
(4, 'Conseil de Laboratoire : Préparation Colloque International 2026', 'Conseil de Laboratoire', '2026-04-15', '10:00 - 12:00', 'Salle des Séminaires LIAS', '1. Organisation logistique et comité scientifique du Colloque.\n2. Validation des appels à communications.\n3. Budget prévisionnel et sponsors industriels.', 'archives/pv_session_avril2026.pdf', 'Prof. Ibtissam Essadiki', 'Secrétariat LIAS', 'PLANIFIEE');

-- -------------------------------------------------------------------------
-- 10. Table des Conventions et Partenariats de Recherche
-- -------------------------------------------------------------------------
CREATE TABLE `conventions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `mandat_id` BIGINT NULL,
    `organisme_partenaire` VARCHAR(150) NOT NULL,
    `type_partenaire` VARCHAR(50) NOT NULL DEFAULT 'Industrie',
    `objet` TEXT NOT NULL,
    `date_signature` DATE NOT NULL,
    `date_echeance` DATE NULL,
    `statut` VARCHAR(50) NOT NULL DEFAULT 'Active',
    `budget_alloue` DECIMAL(12,2) DEFAULT 0.00,
    `document_signe_path` VARCHAR(255) NULL,
    `referent_lias` VARCHAR(100) NULL,
    `contact_partenaire` VARCHAR(150) NULL,
    FOREIGN KEY (`mandat_id`) REFERENCES `mandats`(`id`)
) ENGINE=InnoDB;

INSERT INTO `conventions` (`id`, `mandat_id`, `organisme_partenaire`, `type_partenaire`, `objet`, `date_signature`, `date_echeance`, `statut`, `budget_alloue`, `document_signe_path`, `referent_lias`, `contact_partenaire`) VALUES
(1, 3, 'Centre National pour la Recherche Scientifique et Technique (CNRST)', 'Académique', 'Programme d''appui à la recherche en Intelligence Artificielle et Traitement du Langage Naturel (NLP).', '2024-10-01', '2027-09-30', 'Active', 250000.00, 'archives/conventions/accord_cadre_cnrst_2024.pdf', 'Prof. Ibtissam Essadiki', 'Dr. M. Benali (CNRST)'),
(2, 3, 'OCP Group / UM6P', 'Industrie', 'Optimisation prédictive par Machine Learning des flux logistiques industriels.', '2025-01-15', '2028-01-14', 'Active', 400000.00, 'archives/conventions/partenariat_industriel_ocp_2025.pdf', 'Prof. Sara Benjelloun', 'Ing. R. Cherkaoui (OCP)'),
(3, 2, 'Université Chouaib Doukkali (El Jadida)', 'Académique', 'Cotutelle de thèses en Big Data Analytics et réseaux de capteurs.', '2022-09-01', '2025-08-31', 'Échue', 80000.00, 'archives/conventions/convention_cotutelle_ucd.pdf', 'Prof. Sara Benjelloun', 'Prof. N. Idrissi (UCD)');

-- -------------------------------------------------------------------------
-- 10.bis Table des Activités Associées aux Conventions (CDC §16)
-- -------------------------------------------------------------------------
CREATE TABLE `convention_activites` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `convention_id` BIGINT NOT NULL,
    `titre_activite` VARCHAR(255) NOT NULL,
    `type_activite` VARCHAR(100) NOT NULL,
    `date_activite` VARCHAR(50) NOT NULL,
    `responsable` VARCHAR(100) NOT NULL,
    `statut` VARCHAR(50) NOT NULL DEFAULT 'En cours',
    `livrable_description` TEXT,
    FOREIGN KEY (`convention_id`) REFERENCES `conventions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO `convention_activites` (`id`, `convention_id`, `titre_activite`, `type_activite`, `date_activite`, `responsable`, `statut`, `livrable_description`) VALUES
(1, 1, 'Co-direction & Financement de la thèse en NLP Arabe (Hassan Tazi)', 'Thèse en Cotutelle', '2024-11-01', 'Prof. Ibtissam Essadiki', 'En cours', 'Rapports semestriels et article accepté à IEEE TAFFC'),
(2, 1, 'Workshop Bilatéral LIAS-CNRST sur les Modèles de Langage', 'Workshop Partenaire', '2025-05-20', 'Prof. Amine Alami', 'Terminée', 'Actes d''atelier et partage des corpus dialectaux maghrébins'),
(3, 2, 'Déploiement du modèle prédictif d''optimisation de flux industriels', 'Projet R&D', '2025-03-15', 'Prof. Sara Benjelloun', 'En cours', 'Prototype en production et dashboard temps réel à Jorf Lasfar'),
(4, 2, 'Stage doctoral immersif de recherche appliquée (2 doctorants)', 'Mobilité Doctorale', '2025-09-01', 'Prof. Karim Zouhair', 'En cours', 'Financement de bourse industrielle et mobilité de terrain'),
(5, 3, 'Soutenance de thèse en cotutelle sur les réseaux de capteurs marins', 'Thèse en Cotutelle', '2024-12-18', 'Prof. Sara Benjelloun', 'Terminée', 'Thèse soutenue avec mention Très Honorable et félicitations du jury');

SET FOREIGN_KEY_CHECKS = 1;

package com.lias.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

import com.lias.beans.DocumentLabo;

/**
 * Implémentation JDBC du DAO Archive Documentaire (CDC §10).
 * Structuration : Par événement et par date.
 * Types : Demandes de financement, Programmes, Attestations, Rapports, Documents administratifs.
 * Fonctionnalités : Upload, Téléchargement, Recherche, Historisation.
 */
public class DocumentDaoImpl implements IDocumentDao {

    private static final List<DocumentLabo> FALLBACK_DOCS = new CopyOnWriteArrayList<>();
    private static final AtomicInteger ID_GEN = new AtomicInteger(100);

    static {
        initDefaultDocs();
    }

    public DocumentDaoImpl() {
        initTable();
    }

    private void initTable() {
        String createTableSql = "CREATE TABLE IF NOT EXISTS documents_labo (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, " +
                "dossier VARCHAR(100) NOT NULL, " +
                "sous_dossier VARCHAR(100) NOT NULL, " +
                "edition_rubrique VARCHAR(100), " +
                "nom_fichier VARCHAR(255) NOT NULL, " +
                "taille VARCHAR(50) NOT NULL, " +
                "date_fichier VARCHAR(50) NOT NULL, " +
                "type VARCHAR(20) NOT NULL, " +
                "auteur VARCHAR(150) NOT NULL, " +
                "description TEXT, " +
                "categorie VARCHAR(100) DEFAULT 'Rapports', " +
                "evenement_nom VARCHAR(200)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createTableSql);

            // S'assurer que les colonnes categorie et evenement_nom existent
            try { stmt.executeUpdate("ALTER TABLE documents_labo ADD COLUMN categorie VARCHAR(100) DEFAULT 'Rapports'"); } catch (Exception ignored) {}
            try { stmt.executeUpdate("ALTER TABLE documents_labo ADD COLUMN evenement_nom VARCHAR(200)"); } catch (Exception ignored) {}

            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM documents_labo");
            if (rs.next() && rs.getInt(1) == 0) {
                seedInitialData(conn);
            }
        } catch (Exception e) {
            System.err.println("DocumentDaoImpl: Notice initTable: " + e.getMessage());
        }
    }

    private static void initDefaultDocs() {
        FALLBACK_DOCS.clear();
        int id = 1;

        // 1. DEMANDES DE FINANCEMENT (CDC §10)
        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Journée Scientifique", "Édition 2026",
                "Demande_Financement_CNRST_IA_2026.pdf", "324 KB", "2026-02-15", "pdf", "Prof. Ibtissam Essadiki",
                "Dossier de subvention CNRST pour l'organisation de la Journée Scientifique LIAS 2026",
                "Demandes de financement", "Journée Scientifique LIAS 2026 : Enjeux de l'IA Générative"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "CIRI", "Édition 2025",
                "Subvention_Organisation_CIRI_2025.pdf", "218 KB", "2025-06-20", "pdf", "Prof. Karim Zouhair",
                "Demande de financement accord cadre Université Hassan II & Ministère",
                "Demandes de financement", "Conférence Internationale sur les Réseaux Intelligents (CIRI)"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Workshop Spark", "Édition 2026",
                "Demande_Support_Logistique_Workshop_Spark.pdf", "185 KB", "2026-01-10", "pdf", "Prof. Sara Benjelloun",
                "Budget d'acquisition des licences cloud et serveurs de travaux pratiques",
                "Demandes de financement", "Workshop : Traitement Distribué avec Apache Spark"));

        // 2. PROGRAMMES (CDC §10)
        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Journée Scientifique", "Édition 2026",
                "Programme_Officiel_Journee_LIAS_2026.pdf", "412 KB", "2026-04-01", "pdf", "Prof. Ibtissam Essadiki",
                "Programme détaillé des conférences plénières, keynotes et posters doctorants",
                "Programmes", "Journée Scientifique LIAS 2026 : Enjeux de l'IA Générative"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Workshop Spark", "Édition 2026",
                "Programme_Detaille_Workshop_Spark_2026.pdf", "290 KB", "2026-03-10", "pdf", "Prof. Sara Benjelloun",
                "Planning horaire des ateliers pratiques Apache Spark, PySpark et BigLake",
                "Programmes", "Workshop : Traitement Distribué avec Apache Spark"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Séminaire NLP", "Édition 2026",
                "Planning_Interventions_Seminaire_NLP_2026.pdf", "175 KB", "2026-02-01", "pdf", "Amine Alami",
                "Ordre du jour du séminaire dialectologie et corpus maghrébin",
                "Programmes", "Séminaire : LLMs et Dialectologie Maghrébine"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "CIRI", "Édition 2025",
                "Programme_CIRI_Casablanca_2025.pdf", "540 KB", "2025-10-15", "pdf", "Prof. Karim Zouhair",
                "Livret programme et abstracts de la conférence internationale CIRI",
                "Programmes", "Conférence Internationale sur les Réseaux Intelligents (CIRI)"));

        // 3. ATTESTATIONS (CDC §10)
        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Journée Scientifique", "Édition 2026",
                "Attestations_Emargement_Participants_Journee_2026.pdf", "1.2 MB", "2026-04-16", "pdf", "Système LIAS",
                "Registre des attestations de présence et de communication des enseignants et doctorants",
                "Attestations", "Journée Scientifique LIAS 2026 : Enjeux de l'IA Générative"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "CIRI", "Édition 2025",
                "Attestations_Speakers_CIRI_2025.pdf", "850 KB", "2025-11-20", "pdf", "Prof. Karim Zouhair",
                "Certificats officiels remis aux conférenciers internationaux invités",
                "Attestations", "Conférence Internationale sur les Réseaux Intelligents (CIRI)"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Workshop LaTeX", "Édition 2025",
                "Certificats_Presence_Formation_LaTeX_2025.pdf", "920 KB", "2025-05-13", "pdf", "Prof. Fatima Berrada",
                "Attestations de formation doctorale délivrées aux étudiants de 1ère année",
                "Attestations", "Workshop : Méthodologie de la Recherche & LaTeX Scientifique"));

        // 4. RAPPORTS (CDC §10)
        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Journée Scientifique", "Édition 2026",
                "Rapport_Synthese_Journee_LIAS_2026.docx", "178 KB", "2026-04-20", "docx", "Prof. Ibtissam Essadiki",
                "Compte-rendu scientifique de la manifestation et recommandations du conseil",
                "Rapports", "Journée Scientifique LIAS 2026 : Enjeux de l'IA Générative"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "CIRI", "Édition 2025",
                "Bilan_Scientifique_Financier_CIRI_2025.docx", "265 KB", "2025-12-05", "docx", "Prof. Karim Zouhair",
                "Rapport financier et d'impact académique certifié pour le Conseil Scientifique",
                "Rapports", "Conférence Internationale sur les Réseaux Intelligents (CIRI)"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Évènements", "Séminaire NLP", "Édition 2026",
                "Rapport_Evaluation_Doctorants_2026.docx", "145 KB", "2026-02-15", "docx", "Amine Alami",
                "Bilan des avancées scientifiques sur les modèles LLM et dialectes arabes",
                "Rapports", "Séminaire : LLMs et Dialectologie Maghrébine"));

        // 5. DOCUMENTS ADMINISTRATIFS (CDC §10)
        FALLBACK_DOCS.add(new DocumentLabo(id++, "Administratif", "Conventions", null,
                "Convention_Partenariat_CNRST_LIAS_2025.pdf", "540 KB", "2025-01-15", "pdf", "Prof. Ibtissam Essadiki",
                "Accord officiel de partenariat institutionnel pour les dotations scientifiques",
                "Documents administratifs", "Administratif - Partenariats"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Administratif", "Conseil", null,
                "PV_Reunion_Conseil_Laboratoire_01_2026.pdf", "310 KB", "2026-01-20", "pdf", "Prof. Ibtissam Essadiki",
                "Procès-verbal officiel de la première session ordinaire du Conseil de Laboratoire 2026",
                "Documents administratifs", "Administratif - Gouvernance"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Administratif", "Missions", null,
                "Ordre_Mission_Delegation_CIRI_2025.pdf", "180 KB", "2025-11-10", "pdf", "Direction LIAS",
                "Ordre de mission et prise en charge des déplacements de la délégation LIAS",
                "Documents administratifs", "Conférence Internationale sur les Réseaux Intelligents (CIRI)"));

        FALLBACK_DOCS.add(new DocumentLabo(id++, "Administratif", "International", null,
                "Accord_Cadre_Mobilite_INRIA_2025.pdf", "612 KB", "2025-03-25", "pdf", "Prof. Ibtissam Essadiki",
                "Convention de cotutelle et de mobilité doctorale avec l'INRIA",
                "Documents administratifs", "Administratif - International"));
    }

    private void seedInitialData(Connection conn) {
        String insertSql = "INSERT INTO documents_labo (dossier, sous_dossier, edition_rubrique, nom_fichier, taille, date_fichier, type, auteur, description, categorie, evenement_nom) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            for (DocumentLabo doc : FALLBACK_DOCS) {
                ps.setString(1, doc.getDossier());
                ps.setString(2, doc.getSousDossier());
                ps.setString(3, doc.getEditionRubrique());
                ps.setString(4, doc.getNomFichier());
                ps.setString(5, doc.getTaille());
                ps.setString(6, doc.getDateFichier());
                ps.setString(7, doc.getType());
                ps.setString(8, doc.getAuteur());
                ps.setString(9, doc.getDescription());
                ps.setString(10, doc.getCategorie());
                ps.setString(11, doc.getEvenementNom());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (Exception e) {
            System.err.println("DocumentDaoImpl: Seeding notice: " + e.getMessage());
        }
    }

    private DocumentLabo mapRow(ResultSet rs) throws Exception {
        String categorie = "Rapports";
        try {
            categorie = rs.getString("categorie");
            if (categorie == null || categorie.trim().isEmpty()) categorie = "Rapports";
        } catch (Exception ignored) {}

        String evenementNom = null;
        try {
            evenementNom = rs.getString("evenement_nom");
        } catch (Exception ignored) {}

        return new DocumentLabo(
                rs.getInt("id"),
                rs.getString("dossier"),
                rs.getString("sous_dossier"),
                rs.getString("edition_rubrique"),
                rs.getString("nom_fichier"),
                rs.getString("taille"),
                rs.getString("date_fichier"),
                rs.getString("type"),
                rs.getString("auteur"),
                rs.getString("description"),
                categorie,
                evenementNom
        );
    }

    @Override
    public List<DocumentLabo> findAll() {
        List<DocumentLabo> list = new ArrayList<>();
        String sql = "SELECT * FROM documents_labo ORDER BY date_fichier DESC, id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            if (!list.isEmpty()) return list;
        } catch (Exception ignored) {}
        return new ArrayList<>(FALLBACK_DOCS);
    }

    @Override
    public List<DocumentLabo> findByCategorie(String categorie) {
        if (categorie == null || categorie.trim().isEmpty() || "all".equalsIgnoreCase(categorie)) {
            return findAll();
        }
        List<DocumentLabo> list = new ArrayList<>();
        String sql = "SELECT * FROM documents_labo WHERE LOWER(categorie) LIKE LOWER(?) ORDER BY date_fichier DESC, id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + categorie.trim() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
            if (!list.isEmpty()) return list;
        } catch (Exception ignored) {}

        for (DocumentLabo d : FALLBACK_DOCS) {
            if (d.getCategorie() != null && d.getCategorie().toLowerCase().contains(categorie.toLowerCase())) {
                list.add(d);
            }
        }
        return list;
    }

    @Override
    public List<DocumentLabo> findByEvenement(String evenementNom) {
        if (evenementNom == null || evenementNom.trim().isEmpty() || "all".equalsIgnoreCase(evenementNom)) {
            return findAll();
        }
        List<DocumentLabo> list = new ArrayList<>();
        String sql = "SELECT * FROM documents_labo WHERE LOWER(evenement_nom) LIKE LOWER(?) OR LOWER(sous_dossier) LIKE LOWER(?) ORDER BY date_fichier DESC, id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + evenementNom.trim() + "%");
            ps.setString(2, "%" + evenementNom.trim() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
            if (!list.isEmpty()) return list;
        } catch (Exception ignored) {}

        for (DocumentLabo d : FALLBACK_DOCS) {
            if ((d.getEvenementNom() != null && d.getEvenementNom().toLowerCase().contains(evenementNom.toLowerCase())) ||
                (d.getSousDossier() != null && d.getSousDossier().toLowerCase().contains(evenementNom.toLowerCase()))) {
                list.add(d);
            }
        }
        return list;
    }

    @Override
    public List<DocumentLabo> findByDossier(String dossier, String sousDossier, String editionRubrique) {
        List<DocumentLabo> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM documents_labo WHERE dossier = ?");
        if (sousDossier != null && !sousDossier.trim().isEmpty()) {
            sql.append(" AND sous_dossier = ?");
        }
        if (editionRubrique != null && !editionRubrique.trim().isEmpty()) {
            sql.append(" AND edition_rubrique = ?");
        }
        sql.append(" ORDER BY date_fichier DESC, nom_fichier ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setString(idx++, dossier);
            if (sousDossier != null && !sousDossier.trim().isEmpty()) {
                ps.setString(idx++, sousDossier);
            }
            if (editionRubrique != null && !editionRubrique.trim().isEmpty()) {
                ps.setString(idx++, editionRubrique);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
            if (!list.isEmpty()) return list;
        } catch (Exception ignored) {}

        for (DocumentLabo d : FALLBACK_DOCS) {
            boolean match = d.getDossier().equalsIgnoreCase(dossier);
            if (match && sousDossier != null && !sousDossier.trim().isEmpty()) {
                match = d.getSousDossier().equalsIgnoreCase(sousDossier);
            }
            if (match && editionRubrique != null && !editionRubrique.trim().isEmpty()) {
                match = editionRubrique.equalsIgnoreCase(d.getEditionRubrique());
            }
            if (match) list.add(d);
        }
        return list;
    }

    @Override
    public List<DocumentLabo> search(String query) {
        return searchFiltered(query, null, null, null);
    }

    @Override
    public List<DocumentLabo> searchFiltered(String query, String categorie, String evenementNom, String annee) {
        List<DocumentLabo> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM documents_labo WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append(" AND (LOWER(nom_fichier) LIKE ? OR LOWER(description) LIKE ? OR LOWER(auteur) LIKE ? OR LOWER(evenement_nom) LIKE ? OR LOWER(sous_dossier) LIKE ?)");
            String p = "%" + query.trim().toLowerCase() + "%";
            params.add(p);
            params.add(p);
            params.add(p);
            params.add(p);
            params.add(p);
        }
        if (categorie != null && !categorie.trim().isEmpty() && !"all".equalsIgnoreCase(categorie)) {
            sql.append(" AND LOWER(categorie) LIKE ?");
            params.add("%" + categorie.trim().toLowerCase() + "%");
        }
        if (evenementNom != null && !evenementNom.trim().isEmpty() && !"all".equalsIgnoreCase(evenementNom)) {
            sql.append(" AND (LOWER(evenement_nom) LIKE ? OR LOWER(sous_dossier) LIKE ?)");
            params.add("%" + evenementNom.trim().toLowerCase() + "%");
            params.add("%" + evenementNom.trim().toLowerCase() + "%");
        }
        if (annee != null && !annee.trim().isEmpty() && !"all".equalsIgnoreCase(annee)) {
            sql.append(" AND (date_fichier LIKE ? OR edition_rubrique LIKE ?)");
            params.add(annee.trim() + "%");
            params.add("%" + annee.trim() + "%");
        }

        sql.append(" ORDER BY date_fichier DESC, id DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
            if (!list.isEmpty()) return list;
        } catch (Exception ignored) {}

        // Fallback filter
        for (DocumentLabo d : FALLBACK_DOCS) {
            boolean match = true;
            if (query != null && !query.trim().isEmpty()) {
                String q = query.toLowerCase();
                match = d.getNomFichier().toLowerCase().contains(q) ||
                        (d.getDescription() != null && d.getDescription().toLowerCase().contains(q)) ||
                        d.getAuteur().toLowerCase().contains(q) ||
                        (d.getEvenementNom() != null && d.getEvenementNom().toLowerCase().contains(q));
            }
            if (match && categorie != null && !categorie.trim().isEmpty() && !"all".equalsIgnoreCase(categorie)) {
                match = d.getCategorie() != null && d.getCategorie().toLowerCase().contains(categorie.toLowerCase());
            }
            if (match && evenementNom != null && !evenementNom.trim().isEmpty() && !"all".equalsIgnoreCase(evenementNom)) {
                match = (d.getEvenementNom() != null && d.getEvenementNom().toLowerCase().contains(evenementNom.toLowerCase())) ||
                        (d.getSousDossier() != null && d.getSousDossier().toLowerCase().contains(evenementNom.toLowerCase()));
            }
            if (match && annee != null && !annee.trim().isEmpty() && !"all".equalsIgnoreCase(annee)) {
                match = (d.getDateFichier() != null && d.getDateFichier().startsWith(annee.trim())) ||
                        (d.getEditionRubrique() != null && d.getEditionRubrique().contains(annee.trim()));
            }
            if (match) list.add(d);
        }
        return list;
    }

    @Override
    public List<DocumentLabo> findRecentHistorique(int limit) {
        List<DocumentLabo> list = new ArrayList<>();
        String sql = "SELECT * FROM documents_labo ORDER BY id DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 10);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
            if (!list.isEmpty()) return list;
        } catch (Exception ignored) {}

        int count = 0;
        for (int i = FALLBACK_DOCS.size() - 1; i >= 0 && count < limit; i--) {
            list.add(FALLBACK_DOCS.get(i));
            count++;
        }
        return list;
    }

    @Override
    public List<String> findDistinctEvenements() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT evenement_nom FROM documents_labo WHERE evenement_nom IS NOT NULL AND evenement_nom != '' ORDER BY evenement_nom ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString(1));
            }
            if (!list.isEmpty()) return list;
        } catch (Exception ignored) {}

        for (DocumentLabo d : FALLBACK_DOCS) {
            if (d.getEvenementNom() != null && !list.contains(d.getEvenementNom())) {
                list.add(d.getEvenementNom());
            }
        }
        return list;
    }

    @Override
    public DocumentLabo findById(int id) {
        String sql = "SELECT * FROM documents_labo WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception ignored) {}

        for (DocumentLabo d : FALLBACK_DOCS) {
            if (d.getId() != null && d.getId() == id) return d;
        }
        return null;
    }

    @Override
    public boolean save(DocumentLabo doc) {
        if (doc == null) return false;
        String sql = "INSERT INTO documents_labo (dossier, sous_dossier, edition_rubrique, nom_fichier, taille, date_fichier, type, auteur, description, categorie, evenement_nom) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, doc.getDossier());
            ps.setString(2, doc.getSousDossier());
            ps.setString(3, doc.getEditionRubrique());
            ps.setString(4, doc.getNomFichier());
            ps.setString(5, doc.getTaille() != null ? doc.getTaille() : "150 KB");
            ps.setString(6, doc.getDateFichier());
            ps.setString(7, doc.getType() != null ? doc.getType() : "pdf");
            ps.setString(8, doc.getAuteur());
            ps.setString(9, doc.getDescription());
            ps.setString(10, doc.getCategorie() != null ? doc.getCategorie() : "Rapports");
            ps.setString(11, doc.getEvenementNom() != null ? doc.getEvenementNom() : doc.getSousDossier());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        doc.setId(generatedKeys.getInt(1));
                    }
                }

                // Notification institutionnelle d'archivage (CDC §10)
                String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                        "VALUES ('document', 'Aujourd\\'hui', FALSE, 'Archive LIAS', ?, 'Consulter →', '/documents')";
                try (PreparedStatement psNotif = conn.prepareStatement(notifSql)) {
                    psNotif.setString(1, "Nouveau document archivé : [" + doc.getCategorie() + "] " + doc.getNomFichier() + " déposé par " + doc.getAuteur());
                    psNotif.executeUpdate();
                } catch (Exception ignored) {}

                return true;
            }
        } catch (Exception e) {
            System.err.println("DocumentDaoImpl: save error: " + e.getMessage());
        }

        doc.setId(ID_GEN.incrementAndGet());
        FALLBACK_DOCS.add(0, doc);
        return true;
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM documents_labo WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            return FALLBACK_DOCS.removeIf(d -> d.getId() != null && d.getId() == id);
        }
    }
}

package com.lias.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.lias.beans.Convention;
import com.lias.beans.ConventionActivite;

public class ConventionDaoImpl implements IConventionDao {

    private static final List<Convention> DEMO_CONVENTIONS = new ArrayList<>();
    private static final List<ConventionActivite> DEMO_ACTIVITES = new ArrayList<>();

    static {
        DEMO_CONVENTIONS.add(new Convention(1L, 3L, "Centre National pour la Recherche Scientifique et Technique (CNRST)", 
                "Académique", "Programme d'appui à la recherche en Intelligence Artificielle et Traitement du Langage Naturel (NLP).", 
                LocalDate.parse("2024-10-01"), LocalDate.parse("2027-09-30"), "Active", new java.math.BigDecimal("250000.00"), 
                "archives/conventions/accord_cadre_cnrst_2024.pdf", "Prof. Ibtissam Essadiki", "Dr. M. Benali (Directeur Pôle R&D)"));

        DEMO_CONVENTIONS.add(new Convention(2L, 3L, "OCP Group / UM6P", 
                "Industrie", "Optimisation prédictive par Machine Learning des flux logistiques industriels et miniers.", 
                LocalDate.parse("2025-01-15"), LocalDate.parse("2028-01-14"), "Active", new java.math.BigDecimal("400000.00"), 
                "archives/conventions/partenariat_industriel_ocp_2025.pdf", "Prof. Sara Benjelloun", "Ing. R. Cherkaoui (Lead AI OCP)"));

        DEMO_CONVENTIONS.add(new Convention(3L, 2L, "Université Chouaib Doukkali (El Jadida)", 
                "Académique", "Cotutelle de thèses en Big Data Analytics et réseaux de capteurs intelligents.", 
                LocalDate.parse("2022-09-01"), LocalDate.parse("2025-08-31"), "Échue", new java.math.BigDecimal("80000.00"), 
                "archives/conventions/convention_cotutelle_ucd.pdf", "Prof. Sara Benjelloun", "Prof. N. Idrissi (Coordinatrice UCD)"));

        // Activités associées initiales (CDC §16)
        DEMO_ACTIVITES.add(new ConventionActivite(1L, 1L, "Co-direction & Financement de la thèse en NLP Arabe (Hassan Tazi)", "Thèse en Cotutelle", "2024-11-01", "Prof. Ibtissam Essadiki", "En cours", "Rapports semestriels et article accepté à IEEE TAFFC"));
        DEMO_ACTIVITES.add(new ConventionActivite(2L, 1L, "Workshop Bilatéral LIAS-CNRST sur les Modèles de Langage", "Workshop Partenaire", "2025-05-20", "Prof. Amine Alami", "Terminée", "Actes d'atelier et partage des corpus dialectaux maghrébins"));
        DEMO_ACTIVITES.add(new ConventionActivite(3L, 2L, "Déploiement du modèle prédictif d'optimisation de flux industriels", "Projet R&D", "2025-03-15", "Prof. Sara Benjelloun", "En cours", "Prototype en production et dashboard temps réel à Jorf Lasfar"));
        DEMO_ACTIVITES.add(new ConventionActivite(4L, 2L, "Stage doctoral immersif de recherche appliquée (2 doctorants)", "Mobilité Doctorale", "2025-09-01", "Prof. Karim Zouhair", "En cours", "Financement de bourse industrielle et mobilité de terrain"));
        DEMO_ACTIVITES.add(new ConventionActivite(5L, 3L, "Soutenance de thèse en cotutelle sur les réseaux de capteurs marins", "Thèse en Cotutelle", "2024-12-18", "Prof. Sara Benjelloun", "Terminée", "Thèse soutenue avec mention Très Honorable et félicitations du jury"));
    }

    private void checkAndInitSchema(Connection conn) {
        if (conn == null) return;
        try (Statement st = conn.createStatement()) {
            // 1. Ajouter colonnes d'archivage et de contact si absentes
            try {
                st.executeUpdate("ALTER TABLE conventions ADD COLUMN document_signe_path VARCHAR(255) NULL");
            } catch (SQLException ignored) {}
            try {
                st.executeUpdate("ALTER TABLE conventions ADD COLUMN referent_lias VARCHAR(100) NULL");
            } catch (SQLException ignored) {}
            try {
                st.executeUpdate("ALTER TABLE conventions ADD COLUMN contact_partenaire VARCHAR(150) NULL");
            } catch (SQLException ignored) {}

            // Mettre à jour les documents des conventions 1, 2, 3 si nuls
            st.executeUpdate("UPDATE conventions SET document_signe_path = 'archives/conventions/accord_cadre_cnrst_2024.pdf', referent_lias = 'Prof. Ibtissam Essadiki', contact_partenaire = 'Dr. M. Benali (CNRST)' WHERE id = 1 AND (document_signe_path IS NULL OR document_signe_path = '')");
            st.executeUpdate("UPDATE conventions SET document_signe_path = 'archives/conventions/partenariat_industriel_ocp_2025.pdf', referent_lias = 'Prof. Sara Benjelloun', contact_partenaire = 'Ing. R. Cherkaoui (OCP)' WHERE id = 2 AND (document_signe_path IS NULL OR document_signe_path = '')");
            st.executeUpdate("UPDATE conventions SET document_signe_path = 'archives/conventions/convention_cotutelle_ucd.pdf', referent_lias = 'Prof. Sara Benjelloun', contact_partenaire = 'Prof. N. Idrissi (UCD)' WHERE id = 3 AND (document_signe_path IS NULL OR document_signe_path = '')");

            // 2. Créer table convention_activites (CDC §16)
            st.executeUpdate("CREATE TABLE IF NOT EXISTS convention_activites (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "convention_id BIGINT NOT NULL, " +
                    "titre_activite VARCHAR(255) NOT NULL, " +
                    "type_activite VARCHAR(100) NOT NULL, " +
                    "date_activite VARCHAR(50) NOT NULL, " +
                    "responsable VARCHAR(100) NOT NULL, " +
                    "statut VARCHAR(50) NOT NULL DEFAULT 'En cours', " +
                    "livrable_description TEXT, " +
                    "FOREIGN KEY (convention_id) REFERENCES conventions(id) ON DELETE CASCADE" +
                    ") ENGINE=InnoDB;");

            // Insérer activités initiales si table vide
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM convention_activites")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    for (ConventionActivite a : DEMO_ACTIVITES) {
                        try (PreparedStatement psA = conn.prepareStatement(
                                "INSERT INTO convention_activites (convention_id, titre_activite, type_activite, date_activite, responsable, statut, livrable_description) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?)")) {
                            psA.setLong(1, a.getConventionId());
                            psA.setString(2, a.getTitreActivite());
                            psA.setString(3, a.getTypeActivite());
                            psA.setString(4, a.getDateActivite());
                            psA.setString(5, a.getResponsable());
                            psA.setString(6, a.getStatut());
                            psA.setString(7, a.getLivrableDescription());
                            psA.executeUpdate();
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[ConventionDaoImpl] Info checkAndInitSchema: " + e.getMessage());
        }
    }

    @Override
    public List<Convention> findAll() {
        List<Convention> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            checkAndInitSchema(conn);
            String sql = "SELECT * FROM conventions ORDER BY date_signature DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Convention c = mapConvention(rs);
                    c.setActivites(findActivitesByConventionId(c.getId()));
                    list.add(c);
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[ConventionDaoImpl] Erreur findAll: " + e.getMessage());
            }
        }

        // Fallback démo
        List<Convention> res = new ArrayList<>();
        for (Convention c : DEMO_CONVENTIONS) {
            c.setActivites(findActivitesByConventionId(c.getId()));
            res.add(c);
        }
        return res;
    }

    @Override
    public Convention findById(Long id) {
        if (id == null) return null;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            checkAndInitSchema(conn);
            String sql = "SELECT * FROM conventions WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Convention c = mapConvention(rs);
                        c.setActivites(findActivitesByConventionId(c.getId()));
                        return c;
                    }
                }
            } catch (SQLException e) {
                System.err.println("[ConventionDaoImpl] Erreur findById: " + e.getMessage());
            }
        }
        for (Convention c : DEMO_CONVENTIONS) {
            if (id.equals(c.getId())) {
                c.setActivites(findActivitesByConventionId(c.getId()));
                return c;
            }
        }
        return null;
    }

    @Override
    public boolean save(Convention convention) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            checkAndInitSchema(conn);
            String sql = "INSERT INTO conventions (mandat_id, organisme_partenaire, type_partenaire, objet, date_signature, date_echeance, statut, budget_alloue, document_signe_path, referent_lias, contact_partenaire) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                if (convention.getMandatId() != null) {
                    ps.setLong(1, convention.getMandatId());
                } else {
                    ps.setNull(1, java.sql.Types.BIGINT);
                }
                ps.setString(2, convention.getOrganismePartenaire());
                ps.setString(3, convention.getTypePartenaire());
                ps.setString(4, convention.getObjet());
                ps.setDate(5, convention.getDateSignature() != null ? Date.valueOf(convention.getDateSignature()) : null);
                ps.setDate(6, convention.getDateEcheance() != null ? Date.valueOf(convention.getDateEcheance()) : null);
                ps.setString(7, convention.getStatut());
                ps.setBigDecimal(8, convention.getBudgetAlloue());
                ps.setString(9, convention.getDocumentSignePath() != null ? convention.getDocumentSignePath() : "archives/conventions/accord_" + System.currentTimeMillis() + ".pdf");
                ps.setString(10, convention.getReferentLias() != null ? convention.getReferentLias() : "Prof. Ibtissam Essadiki");
                ps.setString(11, convention.getContactPartenaire());

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet gk = ps.getGeneratedKeys()) {
                        if (gk.next()) convention.setId(gk.getLong(1));
                    }
                    return true;
                }
            } catch (SQLException e) {
                System.err.println("[ConventionDaoImpl] Erreur save convention: " + e.getMessage());
            }
        }
        convention.setId((long) (DEMO_CONVENTIONS.size() + 1));
        DEMO_CONVENTIONS.add(0, convention);
        return true;
    }

    @Override
    public List<ConventionActivite> findActivitesByConventionId(Long conventionId) {
        List<ConventionActivite> list = new ArrayList<>();
        if (conventionId == null) return list;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM convention_activites WHERE convention_id = ? ORDER BY id DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, conventionId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(new ConventionActivite(
                            rs.getLong("id"),
                            rs.getLong("convention_id"),
                            rs.getString("titre_activite"),
                            rs.getString("type_activite"),
                            rs.getString("date_activite"),
                            rs.getString("responsable"),
                            rs.getString("statut"),
                            rs.getString("livrable_description")
                        ));
                    }
                    if (!list.isEmpty()) return list;
                }
            } catch (SQLException e) {
                System.err.println("[ConventionDaoImpl] Erreur findActivitesByConventionId: " + e.getMessage());
            }
        }
        for (ConventionActivite a : DEMO_ACTIVITES) {
            if (conventionId.equals(a.getConventionId())) list.add(a);
        }
        return list;
    }

    @Override
    public List<ConventionActivite> findAllActivites() {
        List<ConventionActivite> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            checkAndInitSchema(conn);
            String sql = "SELECT * FROM convention_activites ORDER BY id DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ConventionActivite(
                        rs.getLong("id"),
                        rs.getLong("convention_id"),
                        rs.getString("titre_activite"),
                        rs.getString("type_activite"),
                        rs.getString("date_activite"),
                        rs.getString("responsable"),
                        rs.getString("statut"),
                        rs.getString("livrable_description")
                    ));
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[ConventionDaoImpl] Erreur findAllActivites: " + e.getMessage());
            }
        }
        return new ArrayList<>(DEMO_ACTIVITES);
    }

    @Override
    public boolean saveActivite(ConventionActivite activite) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            checkAndInitSchema(conn);
            String sql = "INSERT INTO convention_activites (convention_id, titre_activite, type_activite, date_activite, responsable, statut, livrable_description) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, activite.getConventionId());
                ps.setString(2, activite.getTitreActivite());
                ps.setString(3, activite.getTypeActivite());
                ps.setString(4, activite.getDateActivite());
                ps.setString(5, activite.getResponsable());
                ps.setString(6, activite.getStatut());
                ps.setString(7, activite.getLivrableDescription());
                if (ps.executeUpdate() > 0) return true;
            } catch (SQLException e) {
                System.err.println("[ConventionDaoImpl] Erreur saveActivite: " + e.getMessage());
            }
        }
        activite.setId((long) (DEMO_ACTIVITES.size() + 1));
        DEMO_ACTIVITES.add(0, activite);
        return true;
    }

    private Convention mapConvention(ResultSet rs) throws SQLException {
        Convention c = new Convention();
        c.setId(rs.getLong("id"));
        long mId = rs.getLong("mandat_id");
        if (!rs.wasNull()) c.setMandatId(mId);

        c.setOrganismePartenaire(rs.getString("organisme_partenaire"));
        c.setTypePartenaire(rs.getString("type_partenaire"));
        c.setObjet(rs.getString("objet"));

        Date dSig = rs.getDate("date_signature");
        if (dSig != null) c.setDateSignature(dSig.toLocalDate());

        Date dEch = rs.getDate("date_echeance");
        if (dEch != null) c.setDateEcheance(dEch.toLocalDate());

        c.setStatut(rs.getString("statut"));
        c.setBudgetAlloue(rs.getBigDecimal("budget_alloue"));

        try {
            c.setDocumentSignePath(rs.getString("document_signe_path"));
        } catch (SQLException ignored) {}
        try {
            c.setReferentLias(rs.getString("referent_lias"));
        } catch (SQLException ignored) {}
        try {
            c.setContactPartenaire(rs.getString("contact_partenaire"));
        } catch (SQLException ignored) {}

        if (c.getDocumentSignePath() == null || c.getDocumentSignePath().trim().isEmpty()) {
            c.setDocumentSignePath("archives/conventions/convention_" + c.getId() + ".pdf");
        }
        if (c.getReferentLias() == null || c.getReferentLias().trim().isEmpty()) {
            c.setReferentLias("Prof. Ibtissam Essadiki");
        }
        return c;
    }
}

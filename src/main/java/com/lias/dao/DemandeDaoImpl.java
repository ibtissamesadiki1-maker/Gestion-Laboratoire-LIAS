package com.lias.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import com.lias.beans.ArrivageMateriel;
import com.lias.beans.DemandeAdhesion;
import com.lias.beans.Materiel;

public class DemandeDaoImpl implements IDemandeDao {

    private static final List<DemandeAdhesion> DEMO_ADHESIONS = new ArrayList<>();
    private static final List<Materiel> DEMO_MATERIELS = new ArrayList<>();
    private static final List<ArrivageMateriel> DEMO_ARRIVAGES = new ArrayList<>();

    static {
        // Demandes d'adhésion initiales
        DEMO_ADHESIONS.add(new DemandeAdhesion(1L, "Tazi", "Hassan", "hassan.tazi@gmail.com", "Doctorant", "Faculté des Sciences Ben M'Sik", "Recherche sur l'apprentissage par renforcement appliqué à la robotique.", "2026-02-15", "EN_ATTENTE"));
        DEMO_ADHESIONS.add(new DemandeAdhesion(2L, "Idrissi", "Nadia", "nadia.idrissi@ucd.ac.ma", "Associé", "Université Chouaib Doukkali", "Collaboration thématique avec l'équipe Big Data sur la télédétection.", "2026-01-20", "ACCEPTEE"));
        DEMO_ADHESIONS.add(new DemandeAdhesion(3L, "Chraibi", "Mehdi", "mehdi.chraibi@outlook.com", "Doctorant", "Faculté des Sciences Aïn Chock", "Sujet non aligné avec les axes du LIAS.", "2026-01-10", "REFUSEE"));

        // Demandes et attributions de matériel (Distribution équitable CDC §14)
        DEMO_MATERIELS.add(new Materiel(1L, "Station de calcul GPU NVIDIA RTX 4090", "Calcul", "Amine Alami (Doctorant)", "2026-01-05", "ACCORDE", "2026-01-15", "Attribué pour l'entraînement des modèles NLP."));
        DEMO_MATERIELS.add(new Materiel(2L, "PC Portable Dell Precision 16\"", "Informatique", "Prof. Sara Benjelloun", "2025-11-10", "LIVRE", "2025-11-20", "Renouvellement d'équipement pour chef d'équipe Big Data."));
        DEMO_MATERIELS.add(new Materiel(3L, "Serveur de stockage NAS 24 To", "Réseau", "Prof. Karim Zouhair", "2026-02-01", "EN_ATTENTE", null, "En attente de validation budgétaire annuelle."));

        // Suivi des Arrivages de Matériel (CDC §14)
        DEMO_ARRIVAGES.add(new ArrivageMateriel(1L, "BL-CNRST-2026-01", "Lot 2 Stations Calcul GPU NVIDIA RTX 4090", "Subvention CNRST IA", 2, "2026-01-04", "CONFORME", "Équipements haute performance réceptionnés complets avec garantie 3 ans sur site."));
        DEMO_ARRIVAGES.add(new ArrivageMateriel(2L, "BL-UNIV-2025-44", "Lot 3 PC Portables Dell Precision 16\"", "Dotation Faculté FSBM", 3, "2025-11-05", "CONFORME", "Stations de travail mobiles destinées aux chercheurs et doctorants du laboratoire."));
        DEMO_ARRIVAGES.add(new ArrivageMateriel(3L, "BL-REC-2026-08", "Serveur NAS Rackable 24 To Synology", "Projet Partenariat OCP", 1, "2026-02-28", "EN_CONTROLE", "Infrastructure mutualisée pour le stockage sécurisé des jeux de données volumineux."));
    }

    @Override
    public List<DemandeAdhesion> findAllAdhesions() {
        List<DemandeAdhesion> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM demandes_adhesion ORDER BY id DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String cv = null;
                    try { cv = rs.getString("cv_path"); } catch (SQLException ignored) {}
                    if (cv == null || cv.trim().isEmpty()) {
                        cv = "dossiers/cv_" + rs.getString("prenom").toLowerCase() + ".pdf";
                    }

                    list.add(new DemandeAdhesion(
                        rs.getLong("id"),
                        rs.getString("nom"),
                        rs.getString("prenom"),
                        rs.getString("email"),
                        rs.getString("statutVise"),
                        rs.getString("etablissement"),
                        rs.getString("motivation"),
                        rs.getString("dateSoumission"),
                        rs.getString("decision"),
                        cv
                    ));
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur findAllAdhesions: " + e.getMessage());
            }
        }
        return new ArrayList<>(DEMO_ADHESIONS);
    }

    @Override
    public boolean saveAdhesion(DemandeAdhesion adhesion) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "INSERT INTO demandes_adhesion (nom, prenom, email, statutVise, etablissement, motivation, dateSoumission, decision, cv_path) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, adhesion.getNom());
                ps.setString(2, adhesion.getPrenom());
                ps.setString(3, adhesion.getEmail());
                ps.setString(4, adhesion.getStatutVise());
                ps.setString(5, adhesion.getEtablissement());
                ps.setString(6, adhesion.getMotivation());
                ps.setString(7, adhesion.getDateSoumission());
                ps.setString(8, adhesion.getDecision() != null ? adhesion.getDecision() : "EN_ATTENTE");
                ps.setString(9, adhesion.getCvPath() != null ? adhesion.getCvPath() : "dossiers/cv_" + adhesion.getPrenom().toLowerCase() + ".pdf");
                if (ps.executeUpdate() > 0) {
                    // Notification interne pour la direction (CDC §19)
                    String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                      "VALUES ('adhesion', 'Aujourd\\'hui', FALSE, ?, ?, 'Examiner →', '/adhesions')";
                    try (PreparedStatement psN = conn.prepareStatement(notifSql)) {
                        psN.setString(1, adhesion.getPrenom() + " " + adhesion.getNom());
                        psN.setString(2, "Nouvelle demande d'adhésion déposée en ligne (Statut : " + adhesion.getStatutVise() + ").");
                        psN.executeUpdate();
                    } catch (SQLException ignored) {}

                    return true;
                }
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur saveAdhesion: " + e.getMessage());
            }
        }
        adhesion.setId((long) (DEMO_ADHESIONS.size() + 1));
        DEMO_ADHESIONS.add(0, adhesion);
        return true;
    }

    @Override
    public boolean updateDecisionAdhesion(Long id, String decision) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "UPDATE demandes_adhesion SET decision = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, decision);
                ps.setLong(2, id);
                if (ps.executeUpdate() > 0) {
                    // Si acceptée, créer automatiquement le membre, période d'affiliation et notification
                    if ("ACCEPTEE".equalsIgnoreCase(decision)) {
                        creerMembreApresAdhesion(conn, id);
                    } else if ("REFUSEE".equalsIgnoreCase(decision)) {
                        enregistrerRefusAdhesion(conn, id);
                    }
                    return true;
                }
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur updateDecisionAdhesion: " + e.getMessage());
            }
        }
        for (DemandeAdhesion a : DEMO_ADHESIONS) {
            if (a.getId().equals(id)) {
                a.setDecision(decision);
                return true;
            }
        }
        return false;
    }

    @Override
    public DemandeAdhesion findAdhesionById(Long id) {
        if (id == null) return null;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM demandes_adhesion WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String cv = rs.getString("cv_path");
                        if (cv == null || cv.trim().isEmpty()) {
                            cv = "dossiers/cv_" + rs.getString("prenom").toLowerCase() + ".pdf";
                        }
                        return new DemandeAdhesion(
                            rs.getLong("id"),
                            rs.getString("nom"),
                            rs.getString("prenom"),
                            rs.getString("email"),
                            rs.getString("statutVise"),
                            rs.getString("etablissement"),
                            rs.getString("motivation"),
                            rs.getString("dateSoumission"),
                            rs.getString("decision"),
                            cv
                        );
                    }
                }
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur findAdhesionById: " + e.getMessage());
            }
        }
        for (DemandeAdhesion a : DEMO_ADHESIONS) {
            if (id.equals(a.getId())) return a;
        }
        return null;
    }

    @Override
    public DemandeAdhesion findAdhesionByEmail(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM demandes_adhesion WHERE LOWER(email) = LOWER(?) ORDER BY id DESC LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String cv = rs.getString("cv_path");
                        if (cv == null || cv.trim().isEmpty()) {
                            cv = "dossiers/cv_" + rs.getString("prenom").toLowerCase() + ".pdf";
                        }
                        return new DemandeAdhesion(
                            rs.getLong("id"),
                            rs.getString("nom"),
                            rs.getString("prenom"),
                            rs.getString("email"),
                            rs.getString("statutVise"),
                            rs.getString("etablissement"),
                            rs.getString("motivation"),
                            rs.getString("dateSoumission"),
                            rs.getString("decision"),
                            cv
                        );
                    }
                }
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur findAdhesionByEmail: " + e.getMessage());
            }
        }
        for (DemandeAdhesion a : DEMO_ADHESIONS) {
            if (email.trim().equalsIgnoreCase(a.getEmail())) return a;
        }
        return null;
    }

    private void enregistrerRefusAdhesion(Connection conn, Long adhesionId) {
        String sqlSelect = "SELECT * FROM demandes_adhesion WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
            ps.setLong(1, adhesionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String prenom = rs.getString("prenom");
                    String nom = rs.getString("nom");
                    String email = rs.getString("email");
                    String statutVise = rs.getString("statutVise");

                    // 1. Notification dans le centre de notifications (CDC §6 & §19)
                    String sqlNotif = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                      "VALUES ('adhesion', 'Aujourd\\'hui', FALSE, 'Direction LIAS', ?, 'Détails →', '/adhesions')";
                    try (PreparedStatement psN = conn.prepareStatement(sqlNotif)) {
                        psN.setString(1, "Décision d'adhésion : Candidature de " + prenom + " " + nom + " (" + statutVise + ") refusée. Notification automatique envoyée au candidat.");
                        psN.executeUpdate();
                    } catch (SQLException ignored) {}

                    // 2. Traçabilité notification email officiel de refus
                    System.out.println("================================================================================");
                    System.out.println("[SERVICE NOTIFICATION - EMAIL DE REFUS D'ADHÉSION]");
                    System.out.println("Destinataire : " + email + " (" + prenom + " " + nom + ")");
                    System.out.println("Objet        : Décision d'adhésion au Laboratoire LIAS");
                    System.out.println("Message      : Votre dossier n'a pu être retenu pour cette session de recrutement. Nous vous remercions pour l'intérêt porté aux travaux du laboratoire LIAS.");
                    System.out.println("================================================================================");
                }
            }
        } catch (SQLException e) {
            System.err.println("[DemandeDaoImpl] Erreur enregistrerRefusAdhesion: " + e.getMessage());
        }
    }

    private void creerMembreApresAdhesion(Connection conn, Long adhesionId) {
        String sqlSelect = "SELECT * FROM demandes_adhesion WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
            ps.setLong(1, adhesionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String prenom = rs.getString("prenom");
                    String nom = rs.getString("nom");
                    String email = rs.getString("email");
                    String statutVise = rs.getString("statutVise");
                    String etablissement = rs.getString("etablissement");
                    String motivation = rs.getString("motivation");

                    String memberId = (prenom.substring(0, 1) + nom).toLowerCase().replaceAll("[^a-z0-9]", "");
                    if (memberId.length() > 50) memberId = memberId.substring(0, 50);

                    // Détermination stricte du rôle et statut selon la candidature
                    String roleUser = "permanent";
                    if (statutVise != null) {
                        String sLower = statutVise.toLowerCase();
                        if (sLower.contains("doc")) {
                            roleUser = "doctorant";
                        } else if (sLower.contains("assoc")) {
                            roleUser = "associe";
                        } else {
                            roleUser = "permanent";
                        }
                    }
                    String statusMember = roleUser;

                    // 1. Inserer dans members avec profil complet (CDC §3 & §6)
                    String sqlMember = "INSERT INTO members (id, firstName, lastName, email, status, role, team, grade, etablissement_origine, laboratoire_origine, biographie, date_affiliation) " +
                                       "VALUES (?, ?, ?, ?, ?, 'membre', 'IA', ?, ?, 'LIAS', ?, CURDATE()) " +
                                       "ON DUPLICATE KEY UPDATE status = VALUES(status), grade = VALUES(grade), etablissement_origine = VALUES(etablissement_origine), biographie = VALUES(biographie)";
                    try (PreparedStatement psM = conn.prepareStatement(sqlMember)) {
                        psM.setString(1, memberId);
                        psM.setString(2, prenom);
                        psM.setString(3, nom);
                        psM.setString(4, email);
                        psM.setString(5, statusMember);
                        psM.setString(6, statutVise != null ? statutVise : "Membre");
                        psM.setString(7, etablissement != null ? etablissement : "Faculté des Sciences Ben M'Sik");
                        psM.setString(8, motivation != null ? motivation : "Nouveau membre admis au laboratoire LIAS.");
                        psM.executeUpdate();
                    }

                    // 2. Inserer dans affiliation_periods (CDC §4.3)
                    String sqlAff = "INSERT INTO affiliation_periods (member_id, date_debut, date_fin, role_historique) " +
                                    "VALUES (?, CURDATE(), NULL, ?)";
                    try (PreparedStatement psA = conn.prepareStatement(sqlAff)) {
                        psA.setString(1, memberId);
                        psA.setString(2, roleUser);
                        psA.executeUpdate();
                    }

                    // 3. Inserer dans users (Création de compte CDC §6)
                    String sqlUser = "INSERT INTO users (nom, prenom, email, password, role, actif) " +
                                     "VALUES (?, ?, ?, 'pass123', ?, 1) " +
                                     "ON DUPLICATE KEY UPDATE actif = 1, role = VALUES(role)";
                    try (PreparedStatement psU = conn.prepareStatement(sqlUser)) {
                        psU.setString(1, nom);
                        psU.setString(2, prenom);
                        psU.setString(3, email);
                        psU.setString(4, roleUser);
                        psU.executeUpdate();
                    }

                    // 4. Inserer dans notifications_labo (CDC §6 & §19)
                    String sqlNotif = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                      "VALUES ('adhesion', 'Aujourd\\'hui', FALSE, 'Direction LIAS', ?, 'Profil →', '/profils')";
                    try (PreparedStatement psN = conn.prepareStatement(sqlNotif)) {
                        psN.setString(1, "Candidature acceptée : Le compte de " + prenom + " " + nom + " (" + statutVise + ") a été activé. Mot de passe initial: pass123.");
                        psN.executeUpdate();
                    } catch (SQLException ignored) {}

                    // 5. Trace du service de notification par email (CDC §4 & §19)
                    System.out.println("================================================================================");
                    System.out.println("[SERVICE NOTIFICATION - EMAIL DE CONFIRMATION D'ADHÉSION]");
                    System.out.println("Destinataire : " + email + " (" + prenom + " " + nom + ")");
                    System.out.println("Objet        : Décision d'adhésion au Laboratoire LIAS - Compte Activé");
                    System.out.println("Message      : Félicitations ! Votre demande d'adhésion a été validée par la direction du LIAS.");
                    System.out.println("Identifiants : Compte: " + email + " | Mot de passe initial: pass123 | Rôle: " + roleUser);
                    System.out.println("================================================================================");
                }
            }
        } catch (SQLException e) {
            System.err.println("[DemandeDaoImpl] Info: creation membre: " + e.getMessage());
        }
    }

    @Override
    public List<Materiel> findAllMateriels() {
        List<Materiel> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM materiels ORDER BY id DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Materiel(
                        rs.getLong("id"),
                        rs.getString("designation"),
                        rs.getString("categorie"),
                        rs.getString("demandeur"),
                        rs.getString("dateDemande"),
                        rs.getString("statut"),
                        rs.getString("dateAttribution"),
                        rs.getString("commentaire")
                    ));
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur findAllMateriels: " + e.getMessage());
            }
        }
        return new ArrayList<>(DEMO_MATERIELS);
    }

    @Override
    public boolean saveMateriel(Materiel mat) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "INSERT INTO materiels (designation, categorie, demandeur, dateDemande, statut, dateAttribution, commentaire) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, mat.getDesignation());
                ps.setString(2, mat.getCategorie());
                ps.setString(3, mat.getDemandeur());
                ps.setString(4, mat.getDateDemande());
                ps.setString(5, mat.getStatut() != null ? mat.getStatut() : "EN_ATTENTE");
                ps.setString(6, mat.getDateAttribution());
                ps.setString(7, mat.getCommentaire());
                if (ps.executeUpdate() > 0) return true;
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur saveMateriel: " + e.getMessage());
            }
        }
        mat.setId((long) (DEMO_MATERIELS.size() + 1));
        DEMO_MATERIELS.add(0, mat);
        return true;
    }

    @Override
    public boolean updateStatutMateriel(Long id, String statut, String dateAttribution) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "UPDATE materiels SET statut = ?, dateAttribution = COALESCE(?, dateAttribution) WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, statut);
                ps.setString(2, dateAttribution);
                ps.setLong(3, id);
                if (ps.executeUpdate() > 0) return true;
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur updateStatutMateriel: " + e.getMessage());
            }
        }
        for (Materiel m : DEMO_MATERIELS) {
            if (m.getId().equals(id)) {
                m.setStatut(statut);
                if (dateAttribution != null) m.setDateAttribution(dateAttribution);
                return true;
            }
        }
        return false;
    }

    private void checkAndInitArrivagesTable(Connection conn) {
        if (conn == null) return;
        try (Statement st = conn.createStatement()) {
            st.executeUpdate("CREATE TABLE IF NOT EXISTS arrivages_materiel (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "numero_bon VARCHAR(100) NOT NULL, " +
                    "designation_lot VARCHAR(255) NOT NULL, " +
                    "fournisseur_source VARCHAR(150) NOT NULL, " +
                    "quantite INT NOT NULL DEFAULT 1, " +
                    "date_arrivage VARCHAR(50) NOT NULL, " +
                    "statut_reception VARCHAR(50) NOT NULL DEFAULT 'CONFORME', " +
                    "description TEXT" +
                    ") ENGINE=InnoDB;");

            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM arrivages_materiel")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    for (ArrivageMateriel a : DEMO_ARRIVAGES) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "INSERT INTO arrivages_materiel (numero_bon, designation_lot, fournisseur_source, quantite, date_arrivage, statut_reception, description) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?)")) {
                            ps.setString(1, a.getNumeroBon());
                            ps.setString(2, a.getDesignationLot());
                            ps.setString(3, a.getFournisseurSource());
                            ps.setInt(4, a.getQuantite());
                            ps.setString(5, a.getDateArrivage());
                            ps.setString(6, a.getStatutReception());
                            ps.setString(7, a.getDescription());
                            ps.executeUpdate();
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[DemandeDaoImpl] Info: checkAndInitArrivagesTable: " + e.getMessage());
        }
    }

    @Override
    public List<ArrivageMateriel> findAllArrivages() {
        List<ArrivageMateriel> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            checkAndInitArrivagesTable(conn);
            String sql = "SELECT * FROM arrivages_materiel ORDER BY id DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ArrivageMateriel(
                        rs.getLong("id"),
                        rs.getString("numero_bon"),
                        rs.getString("designation_lot"),
                        rs.getString("fournisseur_source"),
                        rs.getInt("quantite"),
                        rs.getString("date_arrivage"),
                        rs.getString("statut_reception"),
                        rs.getString("description")
                    ));
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur findAllArrivages: " + e.getMessage());
            }
        }
        return new ArrayList<>(DEMO_ARRIVAGES);
    }

    @Override
    public boolean saveArrivage(ArrivageMateriel arrivage) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            checkAndInitArrivagesTable(conn);
            String sql = "INSERT INTO arrivages_materiel (numero_bon, designation_lot, fournisseur_source, quantite, date_arrivage, statut_reception, description) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, arrivage.getNumeroBon());
                ps.setString(2, arrivage.getDesignationLot());
                ps.setString(3, arrivage.getFournisseurSource());
                ps.setInt(4, arrivage.getQuantite());
                ps.setString(5, arrivage.getDateArrivage());
                ps.setString(6, arrivage.getStatutReception() != null ? arrivage.getStatutReception() : "CONFORME");
                ps.setString(7, arrivage.getDescription());
                if (ps.executeUpdate() > 0) return true;
            } catch (SQLException e) {
                System.err.println("[DemandeDaoImpl] Erreur saveArrivage: " + e.getMessage());
            }
        }
        arrivage.setId((long) (DEMO_ARRIVAGES.size() + 1));
        DEMO_ARRIVAGES.add(0, arrivage);
        return true;
    }
}


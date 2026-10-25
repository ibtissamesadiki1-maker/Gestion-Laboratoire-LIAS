package com.lias.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.lias.beans.Evenement;

/**
 * Implémentation DAO pour les événements scientifiques du LIAS (CDC §9).
 * Types : Conférences, Séminaires, Workshops.
 * Fonctionnalités : Création, Organisation, Archivage par édition, Affectation d'organisateurs.
 */
public class EvenementDaoImpl implements IEvenementDao {

    private static final List<Evenement> DEMO_EVTS = new ArrayList<>();

    static {
        DEMO_EVTS.add(new Evenement(1L, "Journée Scientifique LIAS 2026 : Enjeux de l'IA Générative", "Conférence", "2026-04-15", "Amphithéâtre Al-Kindi, FSBM", "Rencontre annuelle rassemblant les 4 équipes de recherche et nos partenaires industriels.", "Prof. Ibtissam Essadiki", "À venir", "Édition 2026", "09h00: Accueil | 10h00: Keynote IA Fondative | 14h00: Sessions Posters"));
        DEMO_EVTS.add(new Evenement(2L, "Workshop : Traitement Distribué avec Apache Spark & BigLake", "Workshop", "2026-03-20", "Salle Réseau 4B", "Atelier pratique pour les doctorants et chercheurs de l'équipe Big Data.", "Prof. Sara Benjelloun", "À venir", "Édition 2026", "09h30: Introduction architectures distribuées | 11h00: TP Spark"));
        DEMO_EVTS.add(new Evenement(3L, "Séminaire : LLMs et Dialectologie Maghrébine", "Séminaire", "2026-02-10", "Salle des Thèses", "Présentation des avancées sur le corpus dialectal marocain.", "Amine Alami", "Passé", "Édition 2026", "14h30: Présentation des travaux | 15h30: Débat scientifique"));
        DEMO_EVTS.add(new Evenement(4L, "Conférence Internationale sur les Réseaux Intelligents (CIRI)", "Conférence", "2025-11-18", "Palais des Congrès, Casablanca", "Colloque international regroupant des chercheurs du Maghreb et d'Europe.", "Prof. Karim Zouhair", "Archivé", "Édition 2025", "Session plénière: 5G & IoT | 12 papiers de recherche présentés"));
        DEMO_EVTS.add(new Evenement(5L, "Workshop : Méthodologie de la Recherche & LaTeX Scientifique", "Workshop", "2025-05-12", "Salle Multimédia FSBM", "Formation intensive aux outils de rédaction pour les nouveaux doctorants.", "Prof. Fatima Berrada", "Archivé", "Édition 2025", "09h00: Structuration article IEEE | 14h00: Gabarits Overleaf"));
        DEMO_EVTS.add(new Evenement(6L, "Séminaire : Algorithmes Quantiques et Cryptographie Post-Quantique", "Séminaire", "2024-12-04", "Salle Al-Biruni", "Séminaire invité avec le Laboratoire de Physique Théorique.", "Prof. Ibtissam Essadiki", "Archivé", "Édition 2024", "15h00: Exposé magistral | 16h30: Perspectives de collaboration"));
    }

    private String cleanEncoding(String text) {
        if (text == null) return "";
        return text.replace("Journ??e", "Journée")
                   .replace("Journ?e", "Journée")
                   .replace("G??n??rative", "Générative")
                   .replace("G?n?rative", "Générative")
                   .replace("Distribu??", "Distribué")
                   .replace("Distribu?", "Distribué")
                   .replace("S??minaire", "Séminaire")
                   .replace("S?minaire", "Séminaire")
                   .replace("Conf??rence", "Conférence")
                   .replace("Conf?rence", "Conférence")
                   .replace("Amphith????tre", "Amphithéâtre")
                   .replace("Amphith?tre", "Amphithéâtre")
                   .replace("Amphith??tre", "Amphithéâtre")
                   .replace("M??thodologie", "Méthodologie")
                   .replace("M?thodologie", "Méthodologie")
                   .replace("?dition", "Édition")
                   .replace("??dition", "Édition")
                   .replace("? venir", "À venir")
                   .replace("?? venir", "À venir")
                   .replace("Pass?", "Passé")
                   .replace("Pass??", "Passé")
                   .replace("Archiv?", "Archivé")
                   .replace("Archiv??", "Archivé")
                   .replace("R?seau", "Réseau")
                   .replace("R??seau", "Réseau")
                   .replace("Th?ses", "Thèses")
                   .replace("Th??ses", "Thèses")
                   .replace("Congr?s", "Congrès")
                   .replace("Congr??s", "Congrès")
                   .replace("Ã©", "é")
                   .replace("Ã¨", "è")
                   .replace("Ã ", "à")
                   .replace("Ã¢", "â")
                   .replace("Ã§", "ç")
                   .replace("Ãª", "ê")
                   .replace("Ã«", "ë")
                   .replace("Ã®", "î")
                   .replace("Ã¯", "ï")
                   .replace("Ã´", "ô")
                   .replace("Ã¹", "ù")
                   .replace("Ã»", "û")
                   .replace("Ã¼", "ü")
                   .replace("â€™", "'")
                   .replace("â€“", "–")
                   .replace("â€”", "—")
                   .replace("Â·", "·");
    }

    private Evenement mapResultSet(ResultSet rs) throws SQLException {
        String edition = "Édition 2026";
        try { edition = rs.getString("edition"); } catch (SQLException ignored) {}
        if (edition == null || edition.trim().isEmpty()) edition = "Édition 2026";

        String programme = "";
        try { programme = rs.getString("programme"); } catch (SQLException ignored) {}

        return new Evenement(
            rs.getLong("id"),
            cleanEncoding(rs.getString("titre")),
            cleanEncoding(rs.getString("type")),
            rs.getString("date"),
            cleanEncoding(rs.getString("lieu")),
            cleanEncoding(rs.getString("description")),
            cleanEncoding(rs.getString("organisateur")),
            cleanEncoding(rs.getString("statut")),
            cleanEncoding(edition),
            cleanEncoding(programme)
        );
    }

    @Override
    public List<Evenement> findAll() {
        List<Evenement> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM evenements ORDER BY date DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur findAll: " + e.getMessage());
            }
        }
        return new ArrayList<>(DEMO_EVTS);
    }

    @Override
    public List<Evenement> findByType(String type) {
        if (type == null || type.trim().isEmpty() || "all".equalsIgnoreCase(type)) {
            return findAll();
        }
        List<Evenement> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM evenements WHERE LOWER(type) LIKE LOWER(?) ORDER BY date DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                String pattern = "%" + type.trim() + "%";
                String low = type.toLowerCase();
                if (low.contains("conf")) pattern = "%conf%";
                else if (low.contains("semin") || low.contains("sémin")) pattern = "%minaire%";
                else if (low.contains("workshop")) pattern = "%workshop%";

                ps.setString(1, pattern);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSet(rs));
                    }
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur findByType: " + e.getMessage());
            }
        }
        // Fallback demo
        for (Evenement e : DEMO_EVTS) {
            if (e.getType() != null && e.getType().toLowerCase().contains(type.toLowerCase())) {
                list.add(e);
            }
        }
        return list;
    }

    @Override
    public List<Evenement> findByEdition(String edition) {
        if (edition == null || edition.trim().isEmpty() || "all".equalsIgnoreCase(edition)) {
            return findAll();
        }
        List<Evenement> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM evenements WHERE LOWER(edition) LIKE LOWER(?) ORDER BY date DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, "%" + edition.trim() + "%");
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSet(rs));
                    }
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur findByEdition: " + e.getMessage());
            }
        }
        // Fallback demo
        for (Evenement e : DEMO_EVTS) {
            if (e.getEdition() != null && e.getEdition().toLowerCase().contains(edition.toLowerCase())) {
                list.add(e);
            }
        }
        return list;
    }

    @Override
    public List<String> findEditions() {
        List<String> editions = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT DISTINCT edition FROM evenements WHERE edition IS NOT NULL AND edition != '' ORDER BY edition DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    editions.add(rs.getString("edition"));
                }
                if (!editions.isEmpty()) return editions;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur findEditions: " + e.getMessage());
            }
        }
        editions.add("Édition 2026");
        editions.add("Édition 2025");
        editions.add("Édition 2024");
        return editions;
    }

    @Override
    public Evenement findById(Long id) {
        if (id == null) return null;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM evenements WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSet(rs);
                    }
                }
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur findById: " + e.getMessage());
            }
        }
        for (Evenement e : DEMO_EVTS) {
            if (e.getId() != null && e.getId().equals(id)) return e;
        }
        return null;
    }

    @Override
    public boolean save(Evenement evt) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "INSERT INTO evenements (titre, type, date, lieu, description, organisateur, statut, edition, programme) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, evt.getTitre());
                ps.setString(2, evt.getType());
                ps.setString(3, evt.getDate());
                ps.setString(4, evt.getLieu());
                ps.setString(5, evt.getDescription());
                ps.setString(6, evt.getOrganisateur());
                ps.setString(7, evt.getStatut() != null ? evt.getStatut() : "À venir");
                ps.setString(8, evt.getEdition() != null ? evt.getEdition() : "Édition 2026");
                ps.setString(9, evt.getProgramme());
                int count = ps.executeUpdate();

                // Notification institutionnelle
                String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                  "VALUES ('evenement', 'Aujourd\\'hui', FALSE, 'Direction Scientifique', ?, 'Agenda →', '/evenements')";
                try (PreparedStatement psNotif = conn.prepareStatement(notifSql)) {
                    psNotif.setString(1, "Nouvel événement programmé : " + evt.getType() + " - " + evt.getTitre() + " (" + evt.getEdition() + "), coordonné par " + evt.getOrganisateur());
                    psNotif.executeUpdate();
                } catch (SQLException ignored) {}

                return count > 0;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur save: " + e.getMessage());
            }
        }
        evt.setId((long) (DEMO_EVTS.size() + 1));
        DEMO_EVTS.add(0, evt);
        return true;
    }

    @Override
    public boolean updateOrganisation(Long id, String titre, String type, String date, String lieu, String description, String programme, String organisateur, String statut, String edition) {
        if (id == null) return false;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "UPDATE evenements SET titre = ?, type = ?, date = ?, lieu = ?, description = ?, programme = ?, organisateur = ?, statut = ?, edition = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, titre);
                ps.setString(2, type);
                ps.setString(3, date);
                ps.setString(4, lieu);
                ps.setString(5, description);
                ps.setString(6, programme);
                ps.setString(7, organisateur);
                ps.setString(8, statut);
                ps.setString(9, edition);
                ps.setLong(10, id);
                int count = ps.executeUpdate();

                // Notification organisation
                String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                  "VALUES ('evenement', 'Aujourd\\'hui', FALSE, 'Organisation LIAS', ?, 'Voir détails →', '/evenements')";
                try (PreparedStatement psNotif = conn.prepareStatement(notifSql)) {
                    psNotif.setString(1, "Mise à jour d'organisation : " + titre + " (" + edition + ") - Statut: " + statut);
                    psNotif.executeUpdate();
                } catch (SQLException ignored) {}

                return count > 0;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur updateOrganisation: " + e.getMessage());
            }
        }
        // Fallback demo
        Evenement e = findById(id);
        if (e != null) {
            e.setTitre(titre);
            e.setType(type);
            e.setDate(date);
            e.setLieu(lieu);
            e.setDescription(description);
            e.setProgramme(programme);
            e.setOrganisateur(organisateur);
            e.setStatut(statut);
            e.setEdition(edition);
            return true;
        }
        return false;
    }

    @Override
    public boolean affecterOrganisateur(Long id, String organisateur) {
        if (id == null || organisateur == null) return false;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "UPDATE evenements SET organisateur = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, organisateur);
                ps.setLong(2, id);
                int count = ps.executeUpdate();

                // Notification d'affectation
                String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                  "VALUES ('evenement', 'Aujourd\\'hui', FALSE, 'Direction LIAS', ?, 'Événements →', '/evenements')";
                try (PreparedStatement psNotif = conn.prepareStatement(notifSql)) {
                    psNotif.setString(1, "Affectation d'organisateur : " + organisateur + " a été désigné coordonnateur officiel de l'événement #" + id);
                    psNotif.executeUpdate();
                } catch (SQLException ignored) {}

                return count > 0;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur affecterOrganisateur: " + e.getMessage());
            }
        }
        Evenement e = findById(id);
        if (e != null) {
            e.setOrganisateur(organisateur);
            return true;
        }
        return false;
    }

    @Override
    public boolean archiverEdition(Long id, String edition) {
        if (id == null) return false;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "UPDATE evenements SET statut = 'Archivé', edition = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, edition != null ? edition : "Édition Archivée");
                ps.setLong(2, id);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur archiverEdition: " + e.getMessage());
            }
        }
        Evenement e = findById(id);
        if (e != null) {
            e.setStatut("Archivé");
            if (edition != null) e.setEdition(edition);
            return true;
        }
        return false;
    }

    @Override
    public boolean delete(Long id) {
        if (id == null) return false;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "DELETE FROM evenements WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, id);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                System.err.println("[EvenementDaoImpl] Erreur delete: " + e.getMessage());
            }
        }
        return false;
    }
}

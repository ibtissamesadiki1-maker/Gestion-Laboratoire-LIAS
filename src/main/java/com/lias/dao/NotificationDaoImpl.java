package com.lias.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import com.lias.beans.NotificationLabo;

/**
 * Implémentation JDBC / In-Memory du DAO Notifications (CDC §19).
 * Couvre les flux statutaires :
 * • Événements
 * • Validation demandes
 * • Ajouts de documents
 */
public class NotificationDaoImpl implements INotificationDao {

    private static final List<NotificationLabo> MEMORY_NOTIFS = new CopyOnWriteArrayList<>();

    static {
        initDefaultNotifications();
    }

    public NotificationDaoImpl() {
        initTable();
    }

    private void initTable() {
        String createTableSql = "CREATE TABLE IF NOT EXISTS notifications_labo (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, " +
                "kind VARCHAR(50) NOT NULL, " +
                "when_text VARCHAR(100) NOT NULL, " +
                "is_read BOOLEAN NOT NULL DEFAULT FALSE, " +
                "who VARCHAR(150) NOT NULL, " +
                "body TEXT NOT NULL, " +
                "action_label VARCHAR(50), " +
                "target_url VARCHAR(255)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createTableSql);

            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM notifications_labo");
            if (rs.next() && rs.getInt(1) == 0) {
                seedInitialData(conn);
            }
        } catch (Exception e) {
            System.err.println("NotificationDaoImpl: Table notice: " + e.getMessage());
        }
    }

    private static void initDefaultNotifications() {
        MEMORY_NOTIFS.clear();
        int id = 1;
        // Publications réelles
        MEMORY_NOTIFS.add(new NotificationLabo(id++, "publication", "il y a 1 h", false, "Amine Alami & Pr. Ibtissam Essadiki", "ont publié l'article « Deep Learning for Arabic Sentiment Analysis in North African Dialects » (IEEE Transactions).", "Consulter →", "/publications?year=2025"));
        // Événements réels (CDC §19)
        MEMORY_NOTIFS.add(new NotificationLabo(id++, "event", "il y a 3 h", false, "Prof. Ibtissam Essadiki", "a programmé la « Journée Scientifique LIAS 2026 : Enjeux de l'IA Générative » pour le 15 avril 2026.", "Consulter →", "/evenements"));
        // Événement Workshop réel (CDC §19)
        MEMORY_NOTIFS.add(new NotificationLabo(id++, "event", "hier", false, "Prof. Sara Benjelloun", "a ouvert le programme du « Workshop : Traitement Distribué avec Apache Spark ».", "Consulter →", "/evenements"));
        // Calendrier & Réunions
        MEMORY_NOTIFS.add(new NotificationLabo(id++, "meeting", "hier", true, "Direction LIAS", "Rappel : Calendrier académique des manifestations scientifiques et soutenances.", "Calendrier →", "/calendrier"));
        // Validation demandes (CDC §19 - Direction / Permanents)
        MEMORY_NOTIFS.add(new NotificationLabo(id++, "adhesion", "il y a 4 jours", true, "Direction LIAS", "Demandes d'adhésion doctorales arbitrées et intégrées au répertoire.", "Annuaire →", "/profils"));
        // Conventions réelles (CDC §19 - Direction / Permanents)
        MEMORY_NOTIFS.add(new NotificationLabo(id++, "convention", "il y a 1 sem.", true, "Direction LIAS", "Convention de recherche avec Inria Saclay signée et archivée.", "Convention →", "/conventions"));
    }

    private void seedInitialData(Connection conn) {
        String insertSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            for (NotificationLabo n : MEMORY_NOTIFS) {
                ps.setString(1, n.getKind());
                ps.setString(2, n.getWhenText());
                ps.setBoolean(3, n.isRead());
                ps.setString(4, n.getWho());
                ps.setString(5, n.getBody());
                ps.setString(6, n.getActionLabel());
                ps.setString(7, n.getTargetUrl());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (Exception e) {
            System.err.println("NotificationDaoImpl seed notice: " + e.getMessage());
        }
    }

    @Override
    public List<NotificationLabo> findAll() {
        List<NotificationLabo> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications_labo ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            return new ArrayList<>(MEMORY_NOTIFS);
        }
        return list.isEmpty() ? new ArrayList<>(MEMORY_NOTIFS) : list;
    }

    @Override
    public List<NotificationLabo> findByKind(String kind) {
        if (kind == null || "toutes".equalsIgnoreCase(kind)) return findAll();
        List<NotificationLabo> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications_labo WHERE kind = ? ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kind);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            for (NotificationLabo n : MEMORY_NOTIFS) {
                if (kind.equalsIgnoreCase(n.getKind())) list.add(n);
            }
        }
        return list;
    }

    @Override
    public List<NotificationLabo> findByCategory(String category) {
        if (category == null || "toutes".equalsIgnoreCase(category)) {
            return findAll();
        }
        if ("non lues".equalsIgnoreCase(category) || "unread".equalsIgnoreCase(category)) {
            return findUnread();
        }

        String catLower = category.toLowerCase().trim();
        List<NotificationLabo> list = new ArrayList<>();
        List<NotificationLabo> all = findAll();

        for (NotificationLabo n : all) {
            String k = n.getKind() != null ? n.getKind().toLowerCase() : "";
            if (catLower.contains("event") || catLower.contains("evenement")) {
                if (k.equals("event") || k.equals("meeting")) list.add(n);
            } else if (catLower.contains("valid") || catLower.contains("demand") || catLower.contains("adhes")) {
                if (k.equals("validation") || k.equals("adhesion") || k.equals("materiel")) list.add(n);
            } else if (catLower.contains("doc") || catLower.contains("pv") || catLower.contains("rapport")) {
                if (k.equals("document") || k.equals("pv") || k.equals("rapport")) list.add(n);
            } else if (catLower.contains("pub")) {
                if (k.equals("publication")) list.add(n);
            } else if (k.equalsIgnoreCase(catLower)) {
                list.add(n);
            }
        }
        return list;
    }

    @Override
    public List<NotificationLabo> findUnread() {
        List<NotificationLabo> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications_labo WHERE is_read = FALSE ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            for (NotificationLabo n : MEMORY_NOTIFS) {
                if (!n.isRead()) list.add(n);
            }
        }
        return list;
    }

    @Override
    public boolean markAsRead(int id) {
        String sql = "UPDATE notifications_labo SET is_read = TRUE WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception ignored) {}

        for (NotificationLabo n : MEMORY_NOTIFS) {
            if (n.getId() != null && n.getId() == id) {
                n.setRead(true);
                break;
            }
        }
        return true;
    }

    @Override
    public boolean markAllAsRead() {
        String sql = "UPDATE notifications_labo SET is_read = TRUE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (Exception ignored) {}

        for (NotificationLabo n : MEMORY_NOTIFS) {
            n.setRead(true);
        }
        return true;
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM notifications_labo WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception ignored) {}

        MEMORY_NOTIFS.removeIf(n -> n.getId() != null && n.getId() == id);
        return true;
    }

    @Override
    public boolean save(NotificationLabo notif) {
        if (notif == null) return false;
        String sql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, notif.getKind());
            ps.setString(2, notif.getWhenText());
            ps.setBoolean(3, notif.isRead());
            ps.setString(4, notif.getWho());
            ps.setString(5, notif.getBody());
            ps.setString(6, notif.getActionLabel());
            ps.setString(7, notif.getTargetUrl());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) notif.setId(rs.getInt(1));
                }
                MEMORY_NOTIFS.add(0, notif);
                return true;
            }
        } catch (Exception ignored) {}

        notif.setId(MEMORY_NOTIFS.size() + 1);
        MEMORY_NOTIFS.add(0, notif);
        return true;
    }

    private NotificationLabo mapRow(ResultSet rs) throws Exception {
        return new NotificationLabo(
                rs.getInt("id"),
                rs.getString("kind"),
                rs.getString("when_text"),
                rs.getBoolean("is_read"),
                rs.getString("who"),
                rs.getString("body"),
                rs.getString("action_label"),
                rs.getString("target_url")
        );
    }
}

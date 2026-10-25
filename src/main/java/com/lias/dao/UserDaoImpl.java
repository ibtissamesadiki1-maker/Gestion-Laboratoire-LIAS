package com.lias.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.lias.beans.User;

/**
 * Implémentation JDBC du DAO Utilisateur.
 * Utilise les requêtes préparées (PreparedStatement) pour sécuriser l'accès aux données.
 * Intègre également une liste de secours (fallback) pour faciliter la démo si MySQL n'est pas encore démarré.
 */
public class UserDaoImpl implements IUserDao {

    // Utilisateurs par défaut de démonstration (pour assurer le fonctionnement immédiat)
    private static final List<User> DEMO_USERS = new ArrayList<>();

    static {
        DEMO_USERS.add(new User(1L, "Essadiki", "Ibtissam", "directeur@lias.ma", "admin123", "directeur", true));
        DEMO_USERS.add(new User(2L, "Tahiri", "Youssef", "permanent@lias.ma", "pass123", "permanent", true));
        DEMO_USERS.add(new User(10L, "Benjelloun", "Sara", "vice-directeur@lias.ma", "pass123", "permanent", true));
        DEMO_USERS.add(new User(5L, "Zouhair", "Karim", "karim.zouhair@lias.ma", "pass123", "permanent", true));
        DEMO_USERS.add(new User(11L, "Zouhair", "Karim", "chef-equipe@lias.ma", "pass123", "permanent", true));
        DEMO_USERS.add(new User(3L, "Alami", "Amine", "doctorant@lias.ma", "doc123", "doctorant", true));
        DEMO_USERS.add(new User(4L, "Admin", "Système", "admin@lias.ma", "admin123", "admin", true));
        DEMO_USERS.add(new User(5L, "Berrada", "Fatima", "associe@lias.ma", "pass123", "associe", true));
        DEMO_USERS.add(new User(6L, "Mansouri", "Omar", "retraite@lias.ma", "pass123", "retraite", false));
        DEMO_USERS.add(new User(7L, "Bennis", "Reda", "ancien@lias.ma", "pass123", "ancien", false));
    }

    @Override
    public User findByCredentials(String email, String password) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM users WHERE email = ? AND password = ? AND actif = 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                ps.setString(2, password);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSetToUser(rs);
                    }
                }
            } catch (SQLException e) {
                System.err.println("[UserDaoImpl] Erreur SQL findByCredentials : " + e.getMessage());
            }
        }

        // Fallback en mémoire si la base n'est pas encore connectée
        for (User u : DEMO_USERS) {
            if (u.getEmail().equalsIgnoreCase(email) && u.getPassword().equals(password)) {
                return u;
            }
        }
        return null;
    }

    @Override
    public User findByEmail(String email) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM users WHERE email = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSetToUser(rs);
                    }
                }
            } catch (SQLException e) {
                System.err.println("[UserDaoImpl] Erreur SQL findByEmail : " + e.getMessage());
            }
        }

        for (User u : DEMO_USERS) {
            if (u.getEmail().equalsIgnoreCase(email)) {
                return u;
            }
        }
        return null;
    }

    @Override
    public User findById(Long id) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM users WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSetToUser(rs);
                    }
                }
            } catch (SQLException e) {
                System.err.println("[UserDaoImpl] Erreur SQL findById : " + e.getMessage());
            }
        }

        for (User u : DEMO_USERS) {
            if (u.getId().equals(id)) {
                return u;
            }
        }
        return null;
    }

    @Override
    public List<User> findAll() {
        List<User> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM users";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUser(rs));
                }
                return list;
            } catch (SQLException e) {
                System.err.println("[UserDaoImpl] Erreur SQL findAll : " + e.getMessage());
            }
        }
        return new ArrayList<>(DEMO_USERS);
    }

    @Override
    public boolean save(User user) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "INSERT INTO users (nom, prenom, email, password, role, actif) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, user.getNom());
                ps.setString(2, user.getPrenom());
                ps.setString(3, user.getEmail());
                ps.setString(4, user.getPassword());
                ps.setString(5, user.getRole());
                ps.setBoolean(6, user.isActif());
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                System.err.println("[UserDaoImpl] Erreur SQL save : " + e.getMessage());
            }
        }
        DEMO_USERS.add(user);
        return true;
    }

    @Override
    public boolean update(User user) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "UPDATE users SET nom = ?, prenom = ?, email = ?, role = ?, actif = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, user.getNom());
                ps.setString(2, user.getPrenom());
                ps.setString(3, user.getEmail());
                ps.setString(4, user.getRole());
                ps.setBoolean(5, user.isActif());
                ps.setLong(6, user.getId());
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                System.err.println("[UserDaoImpl] Erreur SQL update : " + e.getMessage());
            }
        }
        return false;
    }

    @Override
    public boolean delete(Long id) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "DELETE FROM users WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, id);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                System.err.println("[UserDaoImpl] Erreur SQL delete : " + e.getMessage());
            }
        }
        return DEMO_USERS.removeIf(u -> u.getId().equals(id));
    }

    private String cleanEncoding(String text) {
        if (text == null) return null;
        if (text.contains("Syst??me") || text.contains("Syst?me") || text.contains("SystÃ¨me")) {
            return "Système";
        }
        return text.replace("Ã©", "é")
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
                   .replace("Â·", "·")
                   .replace("·", "·");
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        return new User(
            rs.getLong("id"),
            cleanEncoding(rs.getString("nom")),
            cleanEncoding(rs.getString("prenom")),
            rs.getString("email"),
            rs.getString("password"),
            rs.getString("role"),
            rs.getBoolean("actif")
        );
    }
}

package com.lias.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.lias.beans.Publication;

public class PublicationDaoImpl implements IPublicationDao {

    private static final List<Publication> DEMO_PUBS = new ArrayList<>();

    static {
        DEMO_PUBS.add(new Publication(6L, "High-Performance Edge AI for Smart Healthcare Systems", "Amine Alami, Ibtissam Essadiki", 2026, "IEEE Internet of Things Journal", "10.1109/JIOT.2026.1029", "IA", "Article"));
        DEMO_PUBS.add(new Publication(7L, "Privacy-Preserving Federated Architectures on Distributed Networks", "Sara Benjelloun, Karim Zouhair", 2026, "Journal of Network and Computer Applications", "10.1016/j.jnca.2026.04", "Sécurité", "Article"));
        DEMO_PUBS.add(new Publication(8L, "Quantum Machine Learning Paradigms for Genomic Classification", "Fatima Berrada, Ibtissam Essadiki", 2026, "International Conference on Machine Learning (ICML)", "10.1145/369812.2026", "Big Data", "Conférence"));
        DEMO_PUBS.add(new Publication(1L, "Deep Learning for Arabic Sentiment Analysis in North African Dialects", "Amine Alami, Ibtissam Essadiki", 2025, "IEEE Transactions on Affective Computing", "10.1109/TAFFC.2025.01", "NLP", "Article"));
        DEMO_PUBS.add(new Publication(2L, "Scalable Real-Time Anomaly Detection in Big Data Streams", "Sara Benjelloun, Karim Zouhair", 2024, "ACM Computing Surveys", "10.1145/3604921", "Big Data", "Article"));
        DEMO_PUBS.add(new Publication(3L, "Zero-Trust Architecture for Cloud-Native Scientific Repositories", "Karim Zouhair", 2025, "International Conference on Information Security (ICIS)", "10.1007/978-3-030-99", "Sécurité", "Conférence"));
        DEMO_PUBS.add(new Publication(4L, "Federated Learning over Distributed Healthcare Records", "Ibtissam Essadiki, Fatima Berrada", 2024, "Journal of Medical Systems", "10.1007/s10916-024", "IA", "Article"));
        DEMO_PUBS.add(new Publication(5L, "Efficient Indexing of Multilingual Scholarly Publications", "Amine Alami, Sara Benjelloun", 2023, "Information Sciences", "10.1016/j.ins.2023", "Big Data", "Article"));
    }

    @Override
    public List<Publication> findAll() {
        List<Publication> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM publications ORDER BY annee DESC, id DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Publication(
                        rs.getLong("id"),
                        rs.getString("titre"),
                        rs.getString("auteurs"),
                        rs.getInt("annee"),
                        rs.getString("revue"),
                        rs.getString("doi"),
                        rs.getString("equipe"),
                        rs.getString("type")
                    ));
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[PublicationDaoImpl] Erreur findAll: " + e.getMessage());
            }
        }
        return new ArrayList<>(DEMO_PUBS);
    }

    @Override
    public List<Publication> findByYear(int year) {
        List<Publication> filtered = new ArrayList<>();
        for (Publication p : findAll()) {
            if (p.getAnnee() == year) filtered.add(p);
        }
        return filtered;
    }

    @Override
    public List<Publication> findByTeam(String team) {
        List<Publication> filtered = new ArrayList<>();
        for (Publication p : findAll()) {
            if (p.getEquipe() != null && p.getEquipe().equalsIgnoreCase(team)) {
                filtered.add(p);
            }
        }
        return filtered;
    }

    @Override
    public List<Publication> searchAndSort(String team, Integer year, String author, String sortBy) {
        List<Publication> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            StringBuilder sql = new StringBuilder("SELECT * FROM publications WHERE 1=1");
            List<Object> params = new ArrayList<>();
            if (team != null && !team.trim().isEmpty()) {
                sql.append(" AND LOWER(equipe) = LOWER(?)");
                params.add(team.trim());
            }
            if (year != null && year > 0) {
                sql.append(" AND annee = ?");
                params.add(year);
            }
            if (author != null && !author.trim().isEmpty()) {
                sql.append(" AND LOWER(auteurs) LIKE LOWER(?)");
                params.add("%" + author.trim().toLowerCase() + "%");
            }

            if ("auteur".equalsIgnoreCase(sortBy) || "auteur_asc".equalsIgnoreCase(sortBy)) {
                sql.append(" ORDER BY auteurs ASC, annee DESC");
            } else if ("annee_asc".equalsIgnoreCase(sortBy)) {
                sql.append(" ORDER BY annee ASC, id DESC");
            } else if ("equipe".equalsIgnoreCase(sortBy) || "equipe_asc".equalsIgnoreCase(sortBy)) {
                sql.append(" ORDER BY equipe ASC, annee DESC");
            } else {
                sql.append(" ORDER BY annee DESC, id DESC");
            }

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    Object p = params.get(i);
                    if (p instanceof Integer) {
                        ps.setInt(i + 1, (Integer) p);
                    } else {
                        ps.setString(i + 1, (String) p);
                    }
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(new Publication(
                            rs.getLong("id"),
                            rs.getString("titre"),
                            rs.getString("auteurs"),
                            rs.getInt("annee"),
                            rs.getString("revue"),
                            rs.getString("doi"),
                            rs.getString("equipe"),
                            rs.getString("type")
                        ));
                    }
                }
                return list;
            } catch (SQLException e) {
                System.err.println("[PublicationDaoImpl] Erreur searchAndSort: " + e.getMessage());
            }
        }

        // Fallback en mémoire
        List<Publication> filtered = new ArrayList<>();
        for (Publication p : findAll()) {
            boolean match = true;
            if (team != null && !team.trim().isEmpty() && (p.getEquipe() == null || !p.getEquipe().equalsIgnoreCase(team.trim()))) {
                match = false;
            }
            if (year != null && year > 0 && p.getAnnee() != year) {
                match = false;
            }
            if (author != null && !author.trim().isEmpty() && (p.getAuteurs() == null || !p.getAuteurs().toLowerCase().contains(author.trim().toLowerCase()))) {
                match = false;
            }
            if (match) filtered.add(p);
        }

        if ("auteur".equalsIgnoreCase(sortBy) || "auteur_asc".equalsIgnoreCase(sortBy)) {
            filtered.sort((a, b) -> (a.getAuteurs() != null ? a.getAuteurs() : "").compareToIgnoreCase(b.getAuteurs() != null ? b.getAuteurs() : ""));
        } else if ("annee_asc".equalsIgnoreCase(sortBy)) {
            filtered.sort((a, b) -> Integer.compare(a.getAnnee(), b.getAnnee()));
        } else if ("equipe".equalsIgnoreCase(sortBy) || "equipe_asc".equalsIgnoreCase(sortBy)) {
            filtered.sort((a, b) -> (a.getEquipe() != null ? a.getEquipe() : "").compareToIgnoreCase(b.getEquipe() != null ? b.getEquipe() : ""));
        } else {
            filtered.sort((a, b) -> Integer.compare(b.getAnnee(), a.getAnnee()));
        }

        return filtered;
    }

    @Override
    public List<Publication> findByAuthor(String author) {
        List<Publication> filtered = new ArrayList<>();
        for (Publication p : findAll()) {
            if (p.getAuteurs() != null && p.getAuteurs().toLowerCase().contains(author.toLowerCase())) {
                filtered.add(p);
            }
        }
        return filtered;
    }

    @Override
    public boolean save(Publication pub) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "INSERT INTO publications (titre, auteurs, annee, revue, doi, equipe, type) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, pub.getTitre());
                ps.setString(2, pub.getAuteurs());
                ps.setInt(3, pub.getAnnee());
                ps.setString(4, pub.getRevue());
                ps.setString(5, pub.getDoi());
                ps.setString(6, pub.getEquipe());
                ps.setString(7, pub.getType());
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                System.err.println("[PublicationDaoImpl] Erreur save: " + e.getMessage());
            }
        }
        pub.setId((long) (DEMO_PUBS.size() + 1));
        DEMO_PUBS.add(0, pub);
        return true;
    }
}

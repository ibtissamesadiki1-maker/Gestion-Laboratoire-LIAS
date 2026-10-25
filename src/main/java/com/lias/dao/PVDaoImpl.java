package com.lias.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.lias.beans.ReunionPV;

public class PVDaoImpl implements IPVDao {

    @Override
    public List<ReunionPV> findAll() {
        List<ReunionPV> list = new ArrayList<>();
        String sql = "SELECT * FROM reunions_pv ORDER BY date_reunion DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapPV(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public ReunionPV findById(Long id) {
        String sql = "SELECT * FROM reunions_pv WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapPV(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<ReunionPV> findByType(String type) {
        List<ReunionPV> list = new ArrayList<>();
        String sql = "SELECT * FROM reunions_pv WHERE type_reunion = ? ORDER BY date_reunion DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPV(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<ReunionPV> findByStatut(String statut) {
        List<ReunionPV> list = new ArrayList<>();
        String sql = "SELECT * FROM reunions_pv WHERE statut = ? ORDER BY date_reunion DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, statut);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPV(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<ReunionPV> search(String query) {
        List<ReunionPV> list = new ArrayList<>();
        if (query == null || query.trim().isEmpty()) {
            return findAll();
        }

        String sql = "SELECT * FROM reunions_pv WHERE " +
                     "LOWER(titre) LIKE ? OR " +
                     "LOWER(type_reunion) LIKE ? OR " +
                     "LOWER(ordre_du_jour) LIKE ? OR " +
                     "LOWER(directeur_signataire) LIKE ? OR " +
                     "LOWER(secretaire_seance) LIKE ? OR " +
                     "LOWER(lieu) LIKE ? " +
                     "ORDER BY date_reunion DESC";

        String p = "%" + query.trim().toLowerCase() + "%";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 1; i <= 6; i++) {
                ps.setString(i, p);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPV(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean save(ReunionPV pv) {
        String sql = "INSERT INTO reunions_pv (titre, type_reunion, date_reunion, heure, lieu, ordre_du_jour, chemin_fichier_pv, directeur_signataire, secretaire_seance, statut) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, pv.getTitre());
            ps.setString(2, pv.getTypeReunion() != null ? pv.getTypeReunion() : "Conseil de Laboratoire");
            ps.setDate(3, pv.getDateReunion() != null ? Date.valueOf(pv.getDateReunion()) : new Date(System.currentTimeMillis()));
            ps.setString(4, pv.getHeure() != null ? pv.getHeure() : "10:00 - 12:30");
            ps.setString(5, pv.getLieu() != null ? pv.getLieu() : "Salle de Réunion LIAS - FSBM");
            ps.setString(6, pv.getOrdreDuJour() != null ? pv.getOrdreDuJour() : "");
            ps.setString(7, pv.getCheminFichierPV() != null && !pv.getCheminFichierPV().isEmpty() ? pv.getCheminFichierPV() : "archives/pv_document.pdf");
            ps.setString(8, pv.getDirecteurSignataire() != null ? pv.getDirecteurSignataire() : "Prof. Ibtissam Essadiki");
            ps.setString(9, pv.getSecretaireSeance() != null ? pv.getSecretaireSeance() : "Secrétariat LIAS");
            ps.setString(10, pv.getStatut() != null ? pv.getStatut() : "ARCHIVEE");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        pv.setId(generatedKeys.getLong(1));
                    }
                }
                return true;
            }
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(ReunionPV pv) {
        String sql = "UPDATE reunions_pv SET titre=?, type_reunion=?, date_reunion=?, heure=?, lieu=?, ordre_du_jour=?, chemin_fichier_pv=?, directeur_signataire=?, secretaire_seance=?, statut=? " +
                     "WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, pv.getTitre());
            ps.setString(2, pv.getTypeReunion());
            ps.setDate(3, pv.getDateReunion() != null ? Date.valueOf(pv.getDateReunion()) : null);
            ps.setString(4, pv.getHeure());
            ps.setString(5, pv.getLieu());
            ps.setString(6, pv.getOrdreDuJour());
            ps.setString(7, pv.getCheminFichierPV());
            ps.setString(8, pv.getDirecteurSignataire());
            ps.setString(9, pv.getSecretaireSeance());
            ps.setString(10, pv.getStatut());
            ps.setLong(11, pv.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updatePVFile(Long id, String cheminFichier, String statut) {
        String sql = "UPDATE reunions_pv SET chemin_fichier_pv=?, statut=? WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cheminFichier);
            ps.setString(2, statut != null ? statut : "ARCHIVEE");
            ps.setLong(3, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(Long id) {
        String sql = "DELETE FROM reunions_pv WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private ReunionPV mapPV(ResultSet rs) throws SQLException {
        ReunionPV pv = new ReunionPV();
        pv.setId(rs.getLong("id"));
        pv.setTitre(rs.getString("titre"));

        try {
            pv.setTypeReunion(rs.getString("type_reunion"));
        } catch (SQLException ignored) {
            pv.setTypeReunion("Conseil de Laboratoire");
        }

        Date d = rs.getDate("date_reunion");
        if (d != null) pv.setDateReunion(d.toLocalDate());

        try {
            pv.setHeure(rs.getString("heure"));
        } catch (SQLException ignored) {
            pv.setHeure("10:00 - 12:30");
        }

        try {
            pv.setLieu(rs.getString("lieu"));
        } catch (SQLException ignored) {
            pv.setLieu("Salle de Réunion LIAS - FSBM");
        }

        pv.setOrdreDuJour(rs.getString("ordre_du_jour"));
        pv.setCheminFichierPV(rs.getString("chemin_fichier_pv"));
        pv.setDirecteurSignataire(rs.getString("directeur_signataire"));

        try {
            pv.setSecretaireSeance(rs.getString("secretaire_seance"));
        } catch (SQLException ignored) {
            pv.setSecretaireSeance("Secrétariat LIAS");
        }

        try {
            pv.setStatut(rs.getString("statut"));
        } catch (SQLException ignored) {
            pv.setStatut("ARCHIVEE");
        }

        return pv;
    }
}

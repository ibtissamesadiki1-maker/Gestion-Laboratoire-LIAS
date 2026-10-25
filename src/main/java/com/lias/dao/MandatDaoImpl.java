package com.lias.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.lias.beans.Mandat;

public class MandatDaoImpl implements IMandatDao {

    @Override
    public List<Mandat> findAll() {
        List<Mandat> list = new ArrayList<>();
        String sql = "SELECT m.*, " +
                     "CONCAT(d.firstName, ' ', d.lastName) AS dirNom, " +
                     "CONCAT(v.firstName, ' ', v.lastName) AS viceNom " +
                     "FROM mandats m " +
                     "LEFT JOIN members d ON m.directeur_id = d.id " +
                     "LEFT JOIN members v ON m.vice_directeur_id = v.id " +
                     "ORDER BY m.date_debut DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Mandat m = mapMandat(rs);
                list.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Mandat findActive() {
        String sql = "SELECT m.*, " +
                     "CONCAT(d.firstName, ' ', d.lastName) AS dirNom, " +
                     "CONCAT(v.firstName, ' ', v.lastName) AS viceNom " +
                     "FROM mandats m " +
                     "LEFT JOIN members d ON m.directeur_id = d.id " +
                     "LEFT JOIN members v ON m.vice_directeur_id = v.id " +
                     "WHERE m.actif = TRUE LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return mapMandat(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Mandat findById(Long id) {
        String sql = "SELECT m.*, " +
                     "CONCAT(d.firstName, ' ', d.lastName) AS dirNom, " +
                     "CONCAT(v.firstName, ' ', v.lastName) AS viceNom " +
                     "FROM mandats m " +
                     "LEFT JOIN members d ON m.directeur_id = d.id " +
                     "LEFT JOIN members v ON m.vice_directeur_id = v.id " +
                     "WHERE m.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMandat(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean save(Mandat mandat) {
        String sql = "INSERT INTO mandats (titre, directeur_id, vice_directeur_id, date_debut, date_fin, actif, chefs_equipes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, mandat.getTitre());
            ps.setString(2, mandat.getDirecteurId());
            ps.setString(3, mandat.getViceDirecteurId());
            ps.setDate(4, mandat.getDateDebut() != null ? Date.valueOf(mandat.getDateDebut()) : null);
            ps.setDate(5, mandat.getDateFin() != null ? Date.valueOf(mandat.getDateFin()) : null);
            ps.setBoolean(6, mandat.isActif());
            ps.setString(7, mandat.getChefsEquipes() != null ? mandat.getChefsEquipes() : "Chefs d'équipe du laboratoire");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Mandat mapMandat(ResultSet rs) throws SQLException {
        Mandat m = new Mandat();
        m.setId(rs.getLong("id"));
        m.setTitre(rs.getString("titre"));
        m.setDirecteurId(rs.getString("directeur_id"));
        m.setDirecteurNomComplet(rs.getString("dirNom"));
        m.setViceDirecteurId(rs.getString("vice_directeur_id"));
        m.setViceDirecteurNomComplet(rs.getString("viceNom"));

        Date dDeb = rs.getDate("date_debut");
        if (dDeb != null) m.setDateDebut(dDeb.toLocalDate());

        Date dFin = rs.getDate("date_fin");
        if (dFin != null) m.setDateFin(dFin.toLocalDate());

        m.setActif(rs.getBoolean("actif"));

        try {
            String chefs = rs.getString("chefs_equipes");
            if (chefs != null && !chefs.trim().isEmpty()) {
                m.setChefsEquipes(chefs);
            } else {
                m.setChefsEquipes("Pr. Sara Benjelloun (Big Data), Pr. Karim Zouhair (Sécurité), Pr. Amine Alami (NLP)");
            }
        } catch (SQLException ignored) {
            m.setChefsEquipes("Pr. Sara Benjelloun (Big Data), Pr. Karim Zouhair (Sécurité), Pr. Amine Alami (NLP)");
        }

        return m;
    }
}

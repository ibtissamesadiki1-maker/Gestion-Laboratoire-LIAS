package com.lias.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import com.lias.beans.Member;
import com.lias.beans.AffiliationPeriod;

public class MemberDaoImpl implements IMemberDao {

    private static final List<Member> DEMO_MEMBERS = new ArrayList<>();

    static {
        DEMO_MEMBERS.add(new Member("ie", "Ibtissam", "Essadiki", "directeur@lias.ma", "permanent", "directeur", "IA", 
            "Professeur de l'Enseignement Supérieur", null, "Faculté des Sciences Ben M'Sik", "LIAS", 
            "Spécialiste en Deep Learning, vision par ordinateur et systèmes distribués. Directrice du laboratoire LIAS.", 
            "Deep Learning, Vision par Ordinateur, IA & Data Science", "2016-09-01", "1980-04-12", "2006-09-01"));
        DEMO_MEMBERS.add(new Member("sb", "Sara", "Benjelloun", "permanent@lias.ma", "permanent", "chef-equipe", "Big Data", 
            "Professeur Habilité", null, "Faculté des Sciences Ben M'Sik", "LIAS", 
            "Recherche sur les architectures distribuées, traitement de flux massifs et lacs de données.", 
            "Big Data, Apache Spark, Cloud Computing, Streaming", "2018-10-01", "1982-08-25", "2012-10-01"));
        DEMO_MEMBERS.add(new Member("as", "Amine", "Alami", "doctorant@lias.ma", "doctorant", "membre", "NLP", 
            "Doctorant", null, "Faculté des Sciences Ben M'Sik", "LIAS", 
            "Thèse sur le traitement automatique du langage naturel (NLP) appliqué aux dialectes maghrébins.", 
            "NLP, LLMs, Dialectologie Arabe, Transformers", "2023-11-01", "1998-03-15", "2023-11-01"));
        DEMO_MEMBERS.add(new Member("kz", "Karim", "Zouhair", "karim.zouhair@lias.ma", "permanent", "chef-equipe", "Sécurité", 
            "Maître de Conférences", null, "Faculté des Sciences Ben M'Sik", "LIAS", 
            "Sécurité des systèmes distribués, architectures Zero-Trust et cryptographie appliquée.", 
            "Cybersécurité, Zero-Trust, Blockchain, IoT Security", "2011-09-01", "1980-11-30", "2010-09-01"));
        DEMO_MEMBERS.add(new Member("fb", "Fatima", "Berrada", "associe@lias.ma", "associe", "membre", "IA", 
            "Chercheur Associé", null, "ENSIAS Rabat", "Laboratoire IMS", 
            "Collaboratrice du LIAS sur l'apprentissage fédéré appliqué à la santé publique.", 
            "Federated Learning, Privacy, Santé Numérique", "2022-01-10", "1985-06-20", "2014-02-01"));
        DEMO_MEMBERS.add(new Member("om", "Omar", "Mansouri", "retraite@lias.ma", "retraite", "aucun", "Big Data", 
            "Professeur Émérite", null, "Faculté des Sciences Ben M'Sik", "LIAS", 
            "Ancien directeur du laboratoire LIAS (2004–2023), mémoire vivante et conseiller scientifique honoraire.", 
            "Systèmes d'Information, Bases de Données, Algorithmique", "2004-09-01", "1958-02-10", "1988-09-01"));
        DEMO_MEMBERS.add(new Member("rb", "Reda", "Bennis", "ancien@lias.ma", "ancien", "aucun", "IA", 
            "Ancien Maître de Conférences", null, "Université Mohammed V", "LIAS", 
            "Ancien chercheur au LIAS (2015-2021), actuellement en mobilité académique.", 
            "Apprentissage Statistique, Systèmes Multi-Agents", "2015-09-01", "1981-07-19", "2011-09-01"));

        // Auto-migration safe pour la colonne photo
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("ALTER TABLE members MODIFY COLUMN photo MEDIUMTEXT NULL");
                } catch (SQLException ignored) {}
            }
        } catch (Exception ignored) {}
    }

    private static String cleanEncoding(String text) {
        if (text == null) return null;
        return text.replace("Habilit??", "Habilité")
                   .replace("Habilit?", "Habilité")
                   .replace("Ma??tre", "Maître")
                   .replace("Ma?tre", "Maître")
                   .replace("Conf??rences", "Conférences")
                   .replace("Conf?rences", "Conférences")
                   .replace("S??curit??", "Sécurité")
                   .replace("S?curit?", "Sécurité")
                   .replace("S??curité", "Sécurité")
                   .replace("Sécurit??", "Sécurité")
                   .replace("D??part", "Départ")
                   .replace("D?part", "Départ")
                   .replace("?? la Retraite", "à la Retraite")
                   .replace("? la Retraite", "à la Retraite")
                   .replace("Statut Gel??", "Statut Gelé")
                   .replace("Statut Gel?", "Statut Gelé")
                   .replace("P??riode", "Période")
                   .replace("P?riode", "Période")
                   .replace("Facult??", "Faculté")
                   .replace("Facult?", "Faculté")
                   .replace("Th??ses", "Thèses")
                   .replace("Th?ses", "Thèses")
                   .replace("??quip", "équip")
                   .replace("Ém??rite", "Émérite")
                   .replace("Em??rite", "Émérite")
                   .replace("??", "—");
    }

    private Member mapResultSetToMember(ResultSet rs) throws SQLException {
        String id = rs.getString("id");
        String firstName = cleanEncoding(rs.getString("firstName"));
        String lastName = cleanEncoding(rs.getString("lastName"));
        String email = rs.getString("email");
        String status = rs.getString("status");
        String role = rs.getString("role");
        String team = cleanEncoding(rs.getString("team"));
        String grade = cleanEncoding(rs.getString("grade"));

        String photo = null;
        String etablissement = "Faculté des Sciences Ben M'Sik";
        String labo = "LIAS";
        String bio = null;
        String centres = "Intelligence Artificielle, Big Data";
        String dateAffiliation = "2021-09-01";
        String dateNaissance = "1985-01-01";
        String dateEmbauche = "2015-09-01";

        try { photo = rs.getString("photo"); } catch (SQLException ignored) {}
        try { etablissement = cleanEncoding(rs.getString("etablissement_origine")); } catch (SQLException ignored) {}
        try { labo = cleanEncoding(rs.getString("laboratoire_origine")); } catch (SQLException ignored) {}
        try { bio = cleanEncoding(rs.getString("biographie")); } catch (SQLException ignored) {}
        try { centres = cleanEncoding(rs.getString("centres_interet")); } catch (SQLException ignored) {}
        try { 
            java.sql.Date d = rs.getDate("date_affiliation");
            if (d != null) dateAffiliation = d.toString();
        } catch (SQLException ignored) {}
        try { 
            java.sql.Date d = rs.getDate("date_naissance");
            if (d != null) dateNaissance = d.toString();
        } catch (SQLException ignored) {}
        try { 
            java.sql.Date d = rs.getDate("date_embauche");
            if (d != null) dateEmbauche = d.toString();
        } catch (SQLException ignored) {}

        return new Member(id, firstName, lastName, email, status, role, team, grade,
                          photo, etablissement, labo, bio, centres, dateAffiliation, dateNaissance, dateEmbauche);
    }

    @Override
    public List<Member> findAll() {
        List<Member> list = new ArrayList<>();
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM members ORDER BY lastName ASC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToMember(rs));
                }
                if (!list.isEmpty()) return list;
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur findAll: " + e.getMessage());
            }
        }
        return new ArrayList<>(DEMO_MEMBERS);
    }

    @Override
    public Member findById(String id) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM members WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSetToMember(rs);
                    }
                }
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur findById: " + e.getMessage());
            }
        }
        for (Member m : DEMO_MEMBERS) {
            if (m.getId().equalsIgnoreCase(id)) return m;
        }
        return null;
    }

    @Override
    public Member findByEmail(String email) {
        if (email == null) return null;
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "SELECT * FROM members WHERE LOWER(email) = LOWER(?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSetToMember(rs);
                    }
                }
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur findByEmail: " + e.getMessage());
            }
        }
        for (Member m : DEMO_MEMBERS) {
            if (m.getEmail().equalsIgnoreCase(email.trim())) return m;
        }
        return null;
    }

    @Override
    public List<Member> findByTeam(String team) {
        List<Member> filtered = new ArrayList<>();
        for (Member m : findAll()) {
            if (m.getTeam() != null && m.getTeam().equalsIgnoreCase(team)) {
                filtered.add(m);
            }
        }
        return filtered;
    }

    @Override
    public List<Member> findByStatus(String status) {
        List<Member> filtered = new ArrayList<>();
        for (Member m : findAll()) {
            if (m.getStatus() != null && m.getStatus().equalsIgnoreCase(status)) {
                filtered.add(m);
            }
        }
        return filtered;
    }

    @Override
    public boolean save(Member member) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "INSERT INTO members (id, firstName, lastName, email, status, role, team, grade, photo, etablissement_origine, laboratoire_origine, biographie, centres_interet, date_affiliation, date_naissance, date_embauche) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, member.getId());
                ps.setString(2, member.getFirstName());
                ps.setString(3, member.getLastName());
                ps.setString(4, member.getEmail());
                ps.setString(5, member.getStatus());
                ps.setString(6, member.getRole());
                ps.setString(7, member.getTeam());
                ps.setString(8, member.getGrade());
                ps.setString(9, member.getPhoto());
                ps.setString(10, member.getEtablissementOrigine());
                ps.setString(11, member.getLaboratoireOrigine());
                ps.setString(12, member.getBiographie());
                ps.setString(13, member.getCentresInteret());
                ps.setDate(14, member.getDateAffiliation() != null ? java.sql.Date.valueOf(member.getDateAffiliation()) : null);
                ps.setDate(15, member.getDateNaissance() != null ? java.sql.Date.valueOf(member.getDateNaissance()) : null);
                ps.setDate(16, member.getDateEmbauche() != null ? java.sql.Date.valueOf(member.getDateEmbauche()) : null);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur save: " + e.getMessage());
            }
        }
        DEMO_MEMBERS.add(member);
        return true;
    }

    @Override
    public boolean update(Member member) {
        Member oldMember = findById(member.getId());

        Connection conn = DBConnection.getConnection();
        boolean updated = false;
        if (conn != null) {
            String sql = "UPDATE members SET firstName = ?, lastName = ?, email = ?, status = ?, role = ?, team = ?, grade = ?, "
                       + "photo = ?, etablissement_origine = ?, laboratoire_origine = ?, biographie = ?, centres_interet = ?, "
                       + "date_affiliation = ?, date_naissance = ?, date_embauche = ? "
                       + "WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, member.getFirstName());
                ps.setString(2, member.getLastName());
                ps.setString(3, member.getEmail());
                ps.setString(4, member.getStatus());
                ps.setString(5, member.getRole());
                ps.setString(6, member.getTeam());
                ps.setString(7, member.getGrade());
                ps.setString(8, member.getPhoto());
                ps.setString(9, member.getEtablissementOrigine());
                ps.setString(10, member.getLaboratoireOrigine());
                ps.setString(11, member.getBiographie());
                ps.setString(12, member.getCentresInteret());
                ps.setDate(13, member.getDateAffiliation() != null ? java.sql.Date.valueOf(member.getDateAffiliation()) : null);
                ps.setDate(14, member.getDateNaissance() != null ? java.sql.Date.valueOf(member.getDateNaissance()) : null);
                ps.setDate(15, member.getDateEmbauche() != null ? java.sql.Date.valueOf(member.getDateEmbauche()) : null);
                ps.setString(16, member.getId());
                updated = ps.executeUpdate() > 0;
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur update: " + e.getMessage());
            }
        }

        // Si la base n'est pas dispo, on met à jour en mémoire
        for (int i = 0; i < DEMO_MEMBERS.size(); i++) {
            if (DEMO_MEMBERS.get(i).getId().equalsIgnoreCase(member.getId())) {
                DEMO_MEMBERS.set(i, member);
                updated = true;
                break;
            }
        }

        // CDC §3 & §4.3 : Historisation automatique des changements (si statut ou rôle a changé)
        if (oldMember != null && (!oldMember.getRole().equalsIgnoreCase(member.getRole()) || !oldMember.getStatus().equalsIgnoreCase(member.getStatus()))) {
            if (conn != null) {
                String closeSql = "UPDATE affiliation_periods SET date_fin = ? WHERE member_id = ? AND date_fin IS NULL";
                try (PreparedStatement psC = conn.prepareStatement(closeSql)) {
                    psC.setDate(1, java.sql.Date.valueOf(LocalDate.now()));
                    psC.setString(2, member.getId());
                    psC.executeUpdate();
                } catch (SQLException ignored) {}
            }

            AffiliationPeriod newPeriod = new AffiliationPeriod();
            newPeriod.setMemberId(member.getId());
            newPeriod.setDateDebut(LocalDate.now());
            newPeriod.setDateFin(null);
            newPeriod.setRoleHistorique(member.getRole() + " (" + member.getStatus() + ")");
            addAffiliationPeriod(newPeriod);
        }

        return updated;
    }

    @Override
    public List<AffiliationPeriod> getAffiliationPeriods(String memberId) {
        List<AffiliationPeriod> list = new ArrayList<>();
        String sql = "SELECT * FROM affiliation_periods WHERE member_id = ? ORDER BY date_debut ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AffiliationPeriod ap = new AffiliationPeriod();
                    ap.setId(rs.getLong("id"));
                    ap.setMemberId(rs.getString("member_id"));
                    java.sql.Date dDeb = rs.getDate("date_debut");
                    if (dDeb != null) ap.setDateDebut(dDeb.toLocalDate());
                    java.sql.Date dFin = rs.getDate("date_fin");
                    if (dFin != null) ap.setDateFin(dFin.toLocalDate());
                    String rh = rs.getString("role_historique");
                    if (rh != null) {
                        rh = rh.replace("D??part", "Départ").replace("D?part", "Départ")
                               .replace("?? la Retraite", "à la Retraite").replace("? la Retraite", "à la Retraite")
                               .replace("Statut Gel??", "Statut Gelé").replace("Statut Gel?", "Statut Gelé")
                               .replace("P??riode", "Période").replace("??quip", "équip")
                               .replace("??", "—");
                    }
                    ap.setRoleHistorique(rh);
                    list.add(ap);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean addAffiliationPeriod(AffiliationPeriod period) {
        String sql = "INSERT INTO affiliation_periods (member_id, date_debut, date_fin, role_historique) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, period.getMemberId());
            ps.setDate(2, period.getDateDebut() != null ? java.sql.Date.valueOf(period.getDateDebut()) : null);
            ps.setDate(3, period.getDateFin() != null ? java.sql.Date.valueOf(period.getDateFin()) : null);
            ps.setString(4, period.getRoleHistorique());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean closeCurrentAffiliation(String memberId, LocalDate dateFin, String motif) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sql = "UPDATE affiliation_periods SET date_fin = ?, role_historique = CONCAT(role_historique, ' [Départ: ', ?, ']') "
                       + "WHERE member_id = ? AND date_fin IS NULL";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, java.sql.Date.valueOf(dateFin));
                ps.setString(2, motif != null ? motif : "Fin de période");
                ps.setString(3, memberId);
                int count = ps.executeUpdate();

                // Passer le statut du membre à 'ancien'
                String updateMember = "UPDATE members SET status = 'ancien', role = 'aucun' WHERE id = ?";
                try (PreparedStatement psMem = conn.prepareStatement(updateMember)) {
                    psMem.setString(1, memberId);
                    psMem.executeUpdate();
                }
                return count > 0;
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    @Override
    public boolean reopenAffiliation(String memberId, LocalDate dateDebut, String role) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            // S'assurer qu'aucune période précédente n'est restée sans date_fin
            String closeSql = "UPDATE affiliation_periods SET date_fin = ? WHERE member_id = ? AND date_fin IS NULL";
            try (PreparedStatement psClose = conn.prepareStatement(closeSql)) {
                psClose.setDate(1, java.sql.Date.valueOf(dateDebut.minusDays(1)));
                psClose.setString(2, memberId);
                psClose.executeUpdate();
            } catch (SQLException ignored) {}

            String sql = "INSERT INTO affiliation_periods (member_id, date_debut, date_fin, role_historique) VALUES (?, ?, NULL, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, memberId);
                ps.setDate(2, java.sql.Date.valueOf(dateDebut));
                ps.setString(3, role != null ? role : "Retour au laboratoire (Réintégration)");
                int count = ps.executeUpdate();

                // Réactiver le membre avec statut permanent
                String updateMember = "UPDATE members SET status = 'permanent', role = ? WHERE id = ?";
                try (PreparedStatement psMem = conn.prepareStatement(updateMember)) {
                    psMem.setString(1, "membre");
                    psMem.setString(2, memberId);
                    psMem.executeUpdate();
                }
                return count > 0;
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    @Override
    public boolean gelerCompteRetraite(String memberId, LocalDate dateDepart, String motif) {
        if (memberId == null) return false;
        Member member = findById(memberId);
        if (member == null) return false;
        if (dateDepart == null) dateDepart = LocalDate.now();

        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            try {
                // 1. Clôturer l'affiliation active avec mention Retraite (CDC §8.1 : Historique conservé)
                String roleHist = (motif != null && !motif.trim().isEmpty()) 
                        ? "Départ à la Retraite · Statut Gelé (" + motif.trim() + ")" 
                        : "Départ à la Retraite · Statut Gelé";
                String sqlAff = "UPDATE affiliation_periods SET date_fin = ?, role_historique = CONCAT(role_historique, ' [', ?, ']') WHERE member_id = ? AND date_fin IS NULL";
                try (PreparedStatement ps = conn.prepareStatement(sqlAff)) {
                    ps.setDate(1, java.sql.Date.valueOf(dateDepart));
                    ps.setString(2, roleHist);
                    ps.setString(3, memberId);
                    ps.executeUpdate();
                }

                // 2. Mettre à jour le membre (statut = retraite, rôle de gouvernance = aucun)
                String sqlMem = "UPDATE members SET status = 'retraite', role = 'aucun' WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlMem)) {
                    ps.setString(1, memberId);
                    ps.executeUpdate();
                }

                // 3. Geler le compte utilisateur dans users (actif = 0, role = retraite -> Aucun accès actif)
                String sqlUser = "UPDATE users SET actif = 0, role = 'retraite' WHERE email = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlUser)) {
                    ps.setString(1, member.getEmail());
                    ps.executeUpdate();
                }

                // 4. Notification institutionnelle
                String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                  "VALUES ('gouvernance', 'Aujourd\\'hui', FALSE, 'Direction LIAS', ?, 'Profil →', ?)";
                try (PreparedStatement ps = conn.prepareStatement(notifSql)) {
                    ps.setString(1, "Départ à la Retraite : Le compte de " + member.getFullName() + " a été gelé (aucun accès actif). L'ensemble de son historique de recherche et ses publications sont scrupuleusement conservés.");
                    ps.setString(2, "/profils?id=" + memberId);
                    ps.executeUpdate();
                } catch (SQLException ignored) {}

                member.setStatus("retraite");
                member.setRole("aucun");
                return true;
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur gelerCompteRetraite: " + e.getMessage());
            }
        }
        return false;
    }

    @Override
    public boolean desactiverAncienMembre(String memberId, LocalDate dateDepart, String motif) {
        if (memberId == null) return false;
        Member member = findById(memberId);
        if (member == null) return false;
        if (dateDepart == null) dateDepart = LocalDate.now();

        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            try {
                // 1. Clôturer l'affiliation active (CDC §8.2 : Historique conservé)
                String roleHist = (motif != null && !motif.trim().isEmpty()) 
                        ? "Départ du laboratoire · Compte Désactivé (" + motif.trim() + ")" 
                        : "Départ du laboratoire · Compte Désactivé";
                String sqlAff = "UPDATE affiliation_periods SET date_fin = ?, role_historique = CONCAT(role_historique, ' [', ?, ']') WHERE member_id = ? AND date_fin IS NULL";
                try (PreparedStatement ps = conn.prepareStatement(sqlAff)) {
                    ps.setDate(1, java.sql.Date.valueOf(dateDepart));
                    ps.setString(2, roleHist);
                    ps.setString(3, memberId);
                    ps.executeUpdate();
                }

                // 2. Mettre à jour le membre (statut = ancien, rôle = aucun)
                String sqlMem = "UPDATE members SET status = 'ancien', role = 'aucun' WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlMem)) {
                    ps.setString(1, memberId);
                    ps.executeUpdate();
                }

                // 3. Désactiver le compte dans users (actif = 0, role = ancien)
                String sqlUser = "UPDATE users SET actif = 0, role = 'ancien' WHERE email = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlUser)) {
                    ps.setString(1, member.getEmail());
                    ps.executeUpdate();
                }

                // 4. Notification institutionnelle
                String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                  "VALUES ('gouvernance', 'Aujourd\\'hui', FALSE, 'Direction LIAS', ?, 'Profil →', ?)";
                try (PreparedStatement ps = conn.prepareStatement(notifSql)) {
                    ps.setString(1, "Départ du Laboratoire : Le compte de " + member.getFullName() + " a été désactivé. L'historique complet est conservé et le compte peut éventuellement être réactivé.");
                    ps.setString(2, "/profils?id=" + memberId);
                    ps.executeUpdate();
                } catch (SQLException ignored) {}

                member.setStatus("ancien");
                member.setRole("aucun");
                return true;
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur desactiverAncienMembre: " + e.getMessage());
            }
        }
        return false;
    }

    @Override
    public boolean reactiverAncienMembre(String memberId, LocalDate dateRetour, String nouveauStatut, String nouveauRole) {
        if (memberId == null) return false;
        Member member = findById(memberId);
        if (member == null) return false;
        if (dateRetour == null) dateRetour = LocalDate.now();
        if (nouveauStatut == null || nouveauStatut.trim().isEmpty()) nouveauStatut = "permanent";
        if (nouveauRole == null || nouveauRole.trim().isEmpty()) nouveauRole = "membre";

        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            try {
                // 1. Clôturer d'éventuelles périodes résiduelles
                String closeSql = "UPDATE affiliation_periods SET date_fin = ? WHERE member_id = ? AND date_fin IS NULL";
                try (PreparedStatement psClose = conn.prepareStatement(closeSql)) {
                    psClose.setDate(1, java.sql.Date.valueOf(dateRetour.minusDays(1)));
                    psClose.setString(2, memberId);
                    psClose.executeUpdate();
                }

                // 2. Ouvrir la nouvelle période d'affiliation active (CDC §8.2 : Réactivation)
                String sqlAff = "INSERT INTO affiliation_periods (member_id, date_debut, date_fin, role_historique) VALUES (?, ?, NULL, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlAff)) {
                    ps.setString(1, memberId);
                    ps.setDate(2, java.sql.Date.valueOf(dateRetour));
                    ps.setString(3, "Retour au laboratoire (Réactivation de compte — Statut " + nouveauStatut + ")");
                    ps.executeUpdate();
                }

                // 3. Mettre à jour le statut et le rôle dans members
                String sqlMem = "UPDATE members SET status = ?, role = ? WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlMem)) {
                    ps.setString(1, nouveauStatut);
                    ps.setString(2, nouveauRole);
                    ps.setString(3, memberId);
                    ps.executeUpdate();
                }

                // 4. Réactiver l'accès dans users (actif = 1, role = nouveauStatut)
                String sqlUser = "UPDATE users SET actif = 1, role = ? WHERE email = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlUser)) {
                    ps.setString(1, nouveauStatut);
                    ps.setString(2, member.getEmail());
                    ps.executeUpdate();
                }

                // 5. Notification institutionnelle
                String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                  "VALUES ('gouvernance', 'Aujourd\\'hui', FALSE, 'Direction LIAS', ?, 'Profil →', ?)";
                try (PreparedStatement ps = conn.prepareStatement(notifSql)) {
                    ps.setString(1, "Réactivation de compte : Le compte de " + member.getFullName() + " a été réactivé avec succès. Accès système rétabli.");
                    ps.setString(2, "/profils?id=" + memberId);
                    ps.executeUpdate();
                } catch (SQLException ignored) {}

                member.setStatus(nouveauStatut);
                member.setRole(nouveauRole);
                return true;
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur reactiverAncienMembre: " + e.getMessage());
            }
        }
        return false;
    }

    @Override
    public boolean changeMemberRole(String memberId, String nouveauRole, LocalDate dateEffet, String motif) {
        if (memberId == null || nouveauRole == null) return false;
        Member member = findById(memberId);
        if (member == null) return false;

        String oldRole = member.getRole();
        if (dateEffet == null) dateEffet = LocalDate.now();

        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            try {
                // 1. Clôturer l'ancien rôle / période active (CDC §7 : Historique complet des rôles)
                String closeSql = "UPDATE affiliation_periods SET date_fin = ? WHERE member_id = ? AND date_fin IS NULL";
                try (PreparedStatement psC = conn.prepareStatement(closeSql)) {
                    psC.setDate(1, java.sql.Date.valueOf(dateEffet));
                    psC.setString(2, memberId);
                    psC.executeUpdate();
                }

                // 2. Insérer le nouveau rôle dans l'historique sans supprimer aucune donnée antérieure (CDC §7)
                String roleLibelle = formatRoleLibelle(nouveauRole);
                String roleHist = roleLibelle + (motif != null && !motif.trim().isEmpty() ? " · " + motif.trim() : "");
                String insertSql = "INSERT INTO affiliation_periods (member_id, date_debut, date_fin, role_historique) VALUES (?, ?, NULL, ?)";
                try (PreparedStatement psI = conn.prepareStatement(insertSql)) {
                    psI.setString(1, memberId);
                    psI.setDate(2, java.sql.Date.valueOf(dateEffet));
                    psI.setString(3, roleHist);
                    psI.executeUpdate();
                }

                // 3. Mettre à jour le rôle dans members
                String updateSql = "UPDATE members SET role = ? WHERE id = ?";
                try (PreparedStatement psU = conn.prepareStatement(updateSql)) {
                    psU.setString(1, nouveauRole);
                    psU.setString(2, memberId);
                    psU.executeUpdate();
                }

                // 4. Mettre à jour le rôle applicatif dans users si nomination à la direction
                if ("directeur".equalsIgnoreCase(nouveauRole)) {
                    String userSql = "UPDATE users SET role = 'directeur' WHERE email = ?";
                    try (PreparedStatement psUser = conn.prepareStatement(userSql)) {
                        psUser.setString(1, member.getEmail());
                        psUser.executeUpdate();
                    }
                } else if ("directeur".equalsIgnoreCase(oldRole)) {
                    String userSql = "UPDATE users SET role = ? WHERE email = ?";
                    try (PreparedStatement psUser = conn.prepareStatement(userSql)) {
                        psUser.setString(1, member.getStatus() != null ? member.getStatus() : "permanent");
                        psUser.setString(2, member.getEmail());
                        psUser.executeUpdate();
                    }
                }

                // 5. Consigner dans notifications_labo (CDC §7 & §19)
                String notifSql = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                  "VALUES ('gouvernance', 'Aujourd\\'hui', FALSE, 'Direction LIAS', ?, 'Profil →', ?)";
                try (PreparedStatement psN = conn.prepareStatement(notifSql)) {
                    psN.setString(1, "Évolution de gouvernance : " + member.getFirstName() + " " + member.getLastName() + " a été nommé " + roleLibelle + ". Tous ses travaux et publications sont conservés.");
                    psN.setString(2, "/profils?id=" + memberId);
                    psN.executeUpdate();
                } catch (SQLException ignored) {}

                member.setRole(nouveauRole);
                return true;
            } catch (SQLException e) {
                System.err.println("[MemberDaoImpl] Erreur changeMemberRole: " + e.getMessage());
            }
        }

        member.setRole(nouveauRole);
        return true;
    }

    public static String formatRoleLibelle(String role) {
        if (role == null || role.trim().isEmpty()) return "Membre d'équipe";
        String r = role.toLowerCase().replace("_", "-").trim();
        switch (r) {
            case "directeur": return "Directeur";
            case "vice-directeur": return "Vice-directeur";
            case "chef-equipe": return "Chef d'équipe";
            case "membre":
            case "membre-equipe": return "Membre d'équipe";
            case "aucun": return "Aucun rôle actif";
            default: return role;
        }
    }
}

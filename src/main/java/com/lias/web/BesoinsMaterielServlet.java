package com.lias.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.lias.beans.Materiel;
import com.lias.beans.User;
import com.lias.dao.DBConnection;
import com.lias.dao.DemandeDaoImpl;
import com.lias.dao.IDemandeDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Contrôleur JEE dédié à la Gestion des Besoins en Matériel (CDC §15).
 * Fonctionnalités :
 * - Soumission des demandes (par chercheurs et doctorants)
 * - Validation par la direction (arbitrage avec motif et notification)
 * - Historique complet
 */
@WebServlet(name = "BesoinsMaterielServlet", urlPatterns = {"/besoins-materiel", "/besoins"})
public class BesoinsMaterielServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IDemandeDao demandeDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.demandeDao = new DemandeDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        List<Materiel> allMateriels = demandeDao.findAllMateriels();
        List<Materiel> enAttenteList = new ArrayList<>();
        List<Materiel> accordeesList = new ArrayList<>();
        List<Materiel> refuseesList = new ArrayList<>();

        if (allMateriels != null) {
            for (Materiel m : allMateriels) {
                String s = m.getStatut() != null ? m.getStatut().toUpperCase() : "";
                if ("ACCORDE".equals(s) || "LIVRE".equals(s) || "ATTRIBUE".equals(s)) {
                    accordeesList.add(m);
                } else if ("REFUSE".equals(s)) {
                    refuseesList.add(m);
                } else {
                    enAttenteList.add(m);
                }
            }
        }

        request.setAttribute("allMateriels", allMateriels);
        request.setAttribute("enAttenteList", enAttenteList);
        request.setAttribute("accordeesList", accordeesList);
        request.setAttribute("refuseesList", refuseesList);
        request.setAttribute("activeNav", "besoins-materiel");

        request.getRequestDispatcher("/WEB-INF/views/besoins_materiel.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("currentUser");
            if (user == null) user = (User) session.getAttribute("user");
        }

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=auth_requise");
            return;
        }

        String action = request.getParameter("action");

        // Action 1 : Validation / Arbitrage par la Direction (CDC §15)
        if ("valider".equals(action)) {
            boolean isDirecteur = "directeur".equalsIgnoreCase(user.getRole()) || "admin".equalsIgnoreCase(user.getRole());
            if (!isDirecteur) {
                response.sendRedirect(request.getContextPath() + "/besoins-materiel?error=unauthorized");
                return;
            }

            String idStr = request.getParameter("id");
            String statut = request.getParameter("statut"); // ACCORDE, REFUSE
            String motif = request.getParameter("commentaire");

            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    Long id = Long.parseLong(idStr.trim());
                    String dateDecision = LocalDate.now().toString();
                    demandeDao.updateStatutMateriel(id, statut, dateDecision);

                    // Si un motif est fourni, on peut le consigner
                    if (motif != null && !motif.trim().isEmpty()) {
                        Connection conn = DBConnection.getConnection();
                        if (conn != null) {
                            try (PreparedStatement ps = conn.prepareStatement("UPDATE materiels SET commentaire = CONCAT(COALESCE(commentaire, ''), ' [Décision Direction: ', ?, ']') WHERE id = ?")) {
                                ps.setString(1, motif.trim());
                                ps.setLong(2, id);
                                ps.executeUpdate();
                            } catch (SQLException ignored) {}
                        }
                    }

                    // Notification automatique (CDC §15 & §19)
                    Connection conn = DBConnection.getConnection();
                    if (conn != null) {
                        String sqlNotif = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                                          "VALUES ('materiel', 'Aujourd\\'hui', FALSE, 'Direction LIAS', ?, 'Voir décision →', '/besoins-materiel')";
                        try (PreparedStatement psN = conn.prepareStatement(sqlNotif)) {
                            psN.setString(1, "Décision sur besoin en matériel : Demande #" + id + " " + ("ACCORDE".equals(statut) ? "validée et accordée." : "refusée. Motif: " + motif));
                            psN.executeUpdate();
                        } catch (SQLException ignored) {}
                    }

                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/besoins-materiel?msg=decision_enregistree");
            return;
        }

        // Action 2 : Soumission d'une nouvelle demande de besoin en matériel (CDC §15)
        String designation = request.getParameter("designation");
        String categorie = request.getParameter("categorie");
        String priorite = request.getParameter("priorite");
        if (priorite == null || priorite.trim().isEmpty()) priorite = "NORMALE";

        String coutStr = request.getParameter("coutEstime");
        Double coutEstime = null;
        if (coutStr != null && !coutStr.trim().isEmpty()) {
            try {
                coutEstime = Double.parseDouble(coutStr.replaceAll("[^0-9.]", ""));
            } catch (NumberFormatException ignored) {}
        }

        String justification = request.getParameter("justification");
        if (justification == null || justification.trim().isEmpty()) {
            justification = request.getParameter("description");
        }

        String roleTag = user.getRole() != null ? " (" + user.getRole() + ")" : "";
        String demandeur = (user.getPrenom() != null ? user.getPrenom() + " " : "") + (user.getNom() != null ? user.getNom() : user.getEmail()) + roleTag;
        String dateDemande = LocalDate.now().toString();

        Materiel mat = new Materiel(null, designation, categorie, demandeur, dateDemande, "EN_ATTENTE", null, justification, priorite, coutEstime);
        demandeDao.saveMateriel(mat);

        // Notification d'alerte pour la Direction (CDC §15 & §19)
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            String sqlNotif = "INSERT INTO notifications_labo (kind, when_text, is_read, who, body, action_label, target_url) " +
                              "VALUES ('materiel', 'Aujourd\\'hui', FALSE, ?, ?, 'Arbitrer →', '/besoins-materiel')";
            try (PreparedStatement psN = conn.prepareStatement(sqlNotif)) {
                psN.setString(1, demandeur);
                psN.setString(2, "Nouvelle expression de besoin (" + priorite + ") : " + designation + " pour projet scientifique.");
                psN.executeUpdate();
            } catch (SQLException ignored) {}
        }

        response.sendRedirect(request.getContextPath() + "/besoins-materiel?msg=demande_enregistree");
    }
}

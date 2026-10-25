package com.lias.web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lias.beans.NotificationLabo;
import com.lias.beans.Publication;
import com.lias.beans.User;
import com.lias.dao.INotificationDao;
import com.lias.dao.IPublicationDao;
import com.lias.dao.NotificationDaoImpl;
import com.lias.dao.PublicationDaoImpl;

/**
 * Contrôleur JEE pour la gestion des publications scientifiques (CDC §12 ⭐).
 * 
 * Fonctionnalités :
 * - Ajout par membres et doctorants
 * - Consultation globale (publique et interne)
 * - Classement par :
 *   o Auteur
 *   o Année
 *   o Équipe
 */
@WebServlet(name = "PublicationServlet", urlPatterns = {"/publications"})
public class PublicationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IPublicationDao pubDao;
    private INotificationDao notifDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.pubDao = new PublicationDaoImpl();
        this.notifDao = new NotificationDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String team = request.getParameter("team");
        String yearStr = request.getParameter("year");
        String author = request.getParameter("author");
        String tri = request.getParameter("tri"); // "auteur", "annee", "annee_asc", "equipe"

        Integer year = null;
        if (yearStr != null && !yearStr.trim().isEmpty()) {
            try {
                year = Integer.parseInt(yearStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        if (tri == null || tri.trim().isEmpty()) {
            tri = "annee_desc";
        }

        // 1. Consultation globale et recherche multi-critères avec classement (CDC §12)
        List<Publication> liste = pubDao.searchAndSort(team, year, author, tri);

        // 2. Calcul des KPI sur l'ensemble du catalogue
        List<Publication> allPubs = pubDao.findAll();
        int countArticles = 0;
        int countConferences = 0;
        int countOuvrages = 0;
        Set<Integer> distinctYears = new HashSet<>();
        Set<String> distinctTeams = new HashSet<>();

        for (Publication p : allPubs) {
            String tp = p.getType() != null ? p.getType().toLowerCase() : "";
            if (tp.contains("conf")) countConferences++;
            else if (tp.contains("ouvr") || tp.contains("livre") || tp.contains("brevet")) countOuvrages++;
            else countArticles++;

            distinctYears.add(p.getAnnee());
            if (p.getEquipe() != null && !p.getEquipe().trim().isEmpty()) {
                distinctTeams.add(p.getEquipe().trim());
            }
        }

        request.setAttribute("publications", liste);
        request.setAttribute("totalPublications", allPubs.size());
        request.setAttribute("countArticles", countArticles);
        request.setAttribute("countConferences", countConferences);
        request.setAttribute("countOuvrages", countOuvrages);

        request.setAttribute("selectedTeam", team);
        request.setAttribute("selectedYear", yearStr);
        request.setAttribute("selectedAuthor", author);
        request.setAttribute("selectedTri", tri);

        request.setAttribute("distinctYears", distinctYears);
        request.setAttribute("distinctTeams", distinctTeams);

        request.setAttribute("activeNav", "publications");
        request.getRequestDispatcher("/WEB-INF/views/publications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null && session != null) {
            user = (User) session.getAttribute("user");
        }

        // 1. Contrôle d'accès : Réservé aux membres actifs et doctorants (CDC §12)
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=auth_requise");
            return;
        }

        String userRole = user.getRole() != null ? user.getRole().toLowerCase() : "";
        if ("retraite".equals(userRole) || "ancien".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/publications?error=compte_bloque");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String titre = request.getParameter("titre");
        String auteurs = request.getParameter("auteurs");
        int annee = 2026;
        try {
            annee = Integer.parseInt(request.getParameter("annee"));
        } catch (Exception ignored) {}
        String revue = request.getParameter("revue");
        String doi = request.getParameter("doi");
        String equipe = request.getParameter("equipe");
        String type = request.getParameter("type");

        if (titre != null && !titre.trim().isEmpty()) {
            Publication pub = new Publication(null, titre.trim(), auteurs != null ? auteurs.trim() : "Membre LIAS", annee, revue != null ? revue.trim() : "Actes LIAS", doi != null ? doi.trim() : "", equipe != null ? equipe.trim() : "IA", type != null ? type.trim() : "Article");
            pubDao.save(pub);

            // Notification automatique au laboratoire (CDC §19)
            String auteurNom = (user.getPrenom() != null ? user.getPrenom() + " " : "") + (user.getNom() != null ? user.getNom() : "Chercheur");
            notifDao.save(new NotificationLabo(
                null,
                "publication",
                "Aujourd'hui",
                true,
                auteurNom,
                "Nouvelle publication déclarée : « " + (titre.length() > 60 ? titre.substring(0, 57) + "..." : titre) + " » (" + annee + ").",
                "Consulter →",
                "/publications?year=" + annee
            ));

            response.sendRedirect(request.getContextPath() + "/publications?msg=ajoute");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/publications");
    }
}

package com.lias.web;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lias.beans.Evenement;
import com.lias.beans.MessageCommunication;
import com.lias.beans.User;
import com.lias.dao.CommunicationDaoImpl;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.ICommunicationDao;
import com.lias.dao.IEvenementDao;

/**
 * Contrôleur JEE pour la Communication Interne du LIAS (CDC §13 ⭐).
 * 
 * Fonctionnalités :
 * - Discussions entre membres (Général, Thèses)
 * - Échanges par équipe (IA, Big Data, Sécurité, Systèmes)
 * - Discussions liées aux événements (Canaux rattachés à chaque conférence, séminaire ou workshop)
 */
@WebServlet(name = "CommunicationServlet", urlPatterns = {"/communication"})
public class CommunicationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ICommunicationDao communicationDao;
    private IEvenementDao evenementDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.communicationDao = new CommunicationDaoImpl();
        this.evenementDao = new EvenementDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String canal = request.getParameter("canal");
        if (canal == null || canal.trim().isEmpty()) {
            canal = "general";
        }

        // 1. Récupération des événements pour les discussions liées aux événements (CDC §13)
        List<Evenement> evenementsList = evenementDao.findAll();
        request.setAttribute("evenementsList", evenementsList);

        // 2. Résolution du titre et description du canal
        String canalTitre = "Canal Général & Direction";
        String canalDesc = "Discussions transversales, annonces officielles et coordination de l'ensemble des membres du laboratoire LIAS.";
        String canalType = "membres"; // "membres", "equipe", "evenement"

        if ("general".equalsIgnoreCase(canal)) {
            canalTitre = "Général & Direction";
            canalDesc = "Discussions transversales, annonces statutaires et vie du laboratoire LIAS.";
            canalType = "membres";
        } else if ("theses".equalsIgnoreCase(canal)) {
            canalTitre = "Doctorants & Thèses";
            canalDesc = "Entraide méthodologique, préparation des soutenances, séminaires doctoraux et posters.";
            canalType = "membres";
        } else if ("team_ia".equalsIgnoreCase(canal)) {
            canalTitre = "Équipe Intelligence Artificielle (IA & NLP)";
            canalDesc = "Travaux sur l'apprentissage profond, traitement automatique des langues et vision par ordinateur.";
            canalType = "equipe";
        } else if ("team_bigdata".equalsIgnoreCase(canal) || "team_dscc".equalsIgnoreCase(canal)) {
            canalTitre = "Équipe Big Data & Data Science";
            canalDesc = "Architectures distribuées, traitement de flux massifs, pipelines Spark et analyse prédictive.";
            canalType = "equipe";
        } else if ("team_securite".equalsIgnoreCase(canal)) {
            canalTitre = "Équipe Cybersécurité & Réseaux";
            canalDesc = "Protocoles Zero-Trust, cryptographie post-quantique et résilience des infrastructures critiques.";
            canalType = "equipe";
        } else if ("team_systemes".equalsIgnoreCase(canal) || "team_msi".equalsIgnoreCase(canal)) {
            canalTitre = "Équipe Cloud & Systèmes Embarqués";
            canalDesc = "Edge Computing, micro-services, Internet des Objets (IoT) et virtualisation scientifique.";
            canalType = "equipe";
        } else if (canal.startsWith("event_")) {
            canalType = "evenement";
            try {
                Long evtId = Long.parseLong(canal.substring(6));
                Evenement ev = evenementDao.findById(evtId);
                if (ev != null) {
                    canalTitre = "Événement : " + ev.getTitre();
                    canalDesc = ev.getType() + " du " + ev.getDate() + " (" + ev.getLieu() + ") · Organisateur : " + (ev.getOrganisateur() != null ? ev.getOrganisateur() : "Comité d'organisation");
                } else {
                    canalTitre = "Discussion Événement #" + evtId;
                    canalDesc = "Canal dédié à la coordination logistique et scientifique de la manifestation.";
                }
            } catch (Exception e) {
                canalTitre = "Discussion Événement";
                canalDesc = "Canal dédié à la coordination logistique et scientifique de la manifestation.";
            }
        }

        List<MessageCommunication> messages = communicationDao.findByCanal(canal);
        request.setAttribute("messages", messages);
        request.setAttribute("activeCanal", canal);
        request.setAttribute("canalTitre", canalTitre);
        request.setAttribute("canalDesc", canalDesc);
        request.setAttribute("canalType", canalType);
        request.setAttribute("activeNav", "communication");

        request.getRequestDispatcher("/WEB-INF/views/communication.jsp").forward(request, response);
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

        String canalId = request.getParameter("canalId");
        if (canalId == null || canalId.trim().isEmpty()) {
            canalId = "general";
        }
        String contenu = request.getParameter("message");
        if (contenu != null && !contenu.trim().isEmpty()) {
            String roleLibelle = user.getRole() != null ? user.getRole().toUpperCase() : "MEMBRE";
            String auteurNom = (user.getPrenom() != null ? user.getPrenom() + " " : "") + (user.getNom() != null ? user.getNom() : "Chercheur");
            
            // Résolution nom du canal
            String canalNom = "Canal " + canalId;
            if ("general".equalsIgnoreCase(canalId)) canalNom = "Général & Direction";
            else if ("theses".equalsIgnoreCase(canalId)) canalNom = "Doctorants & Thèses";
            else if ("team_ia".equalsIgnoreCase(canalId)) canalNom = "Équipe IA";
            else if ("team_bigdata".equalsIgnoreCase(canalId) || "team_dscc".equalsIgnoreCase(canalId)) canalNom = "Équipe Big Data";
            else if ("team_securite".equalsIgnoreCase(canalId)) canalNom = "Équipe Cybersécurité";
            else if ("team_systemes".equalsIgnoreCase(canalId) || "team_msi".equalsIgnoreCase(canalId)) canalNom = "Équipe Systèmes";
            else if (canalId.startsWith("event_")) {
                try {
                    Long eId = Long.parseLong(canalId.substring(6));
                    Evenement ev = evenementDao.findById(eId);
                    if (ev != null) canalNom = ev.getTitre();
                } catch (Exception ignored) {}
            }

            String dateEnvoi = "Aujourd'hui à " + DateTimeFormatter.ofPattern("HH:mm").format(LocalDateTime.now());

            MessageCommunication msg = new MessageCommunication(
                null, canalId, canalNom, auteurNom, user.getEmail(), roleLibelle, contenu.trim(), dateEnvoi
            );
            communicationDao.save(msg);
        }

        response.sendRedirect(request.getContextPath() + "/communication?canal=" + canalId + "&msg=envoye");
    }
}

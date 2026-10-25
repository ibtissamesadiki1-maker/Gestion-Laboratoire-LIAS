package com.lias.web;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lias.beans.Evenement;
import com.lias.beans.Member;
import com.lias.beans.User;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.IEvenementDao;
import com.lias.dao.IMemberDao;
import com.lias.dao.MemberDaoImpl;

/**
 * Contrôleur JEE pour la gestion des évènements scientifiques (CDC §9).
 * Types : Conférences, Séminaires, Workshops.
 * Fonctionnalités : Création, Organisation, Archivage par édition, Affectation d'organisateurs.
 */
@WebServlet(name = "EvenementServlet", urlPatterns = {"/evenements"})
public class EvenementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IEvenementDao evtDao;
    private IMemberDao memberDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.evtDao = new EvenementDaoImpl();
        this.memberDao = new MemberDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String typeFilter = request.getParameter("type");
        String editionFilter = request.getParameter("edition");
        String tab = request.getParameter("tab");

        List<Evenement> allEvents = evtDao.findAll();
        List<Evenement> displayedEvents = allEvents;

        if (typeFilter != null && !typeFilter.trim().isEmpty() && !"all".equalsIgnoreCase(typeFilter)) {
            displayedEvents = evtDao.findByType(typeFilter);
        } else if (editionFilter != null && !editionFilter.trim().isEmpty() && !"all".equalsIgnoreCase(editionFilter)) {
            displayedEvents = evtDao.findByEdition(editionFilter);
        }

        // Statistiques de classification
        long nbConferences = 0;
        long nbSeminaires = 0;
        long nbWorkshops = 0;
        long nbArchives = 0;

        for (Evenement e : allEvents) {
            String t = e.getType();
            if (t != null) {
                if (t.toLowerCase().contains("confér") || t.toLowerCase().contains("confer")) nbConferences++;
                else if (t.toLowerCase().contains("sémin") || t.toLowerCase().contains("semin")) nbSeminaires++;
                else if (t.toLowerCase().contains("workshop")) nbWorkshops++;
            }
            if ("Archivé".equalsIgnoreCase(e.getStatut()) || "Passé".equalsIgnoreCase(e.getStatut())) {
                nbArchives++;
            }
        }

        // Liste des chercheurs actifs pour l'affectation d'organisateurs (CDC §9)
        List<Member> membres = memberDao.findAll();
        List<String> editions = evtDao.findEditions();

        request.setAttribute("evenements", displayedEvents);
        request.setAttribute("totalEventsCount", Long.valueOf(allEvents.size()));
        request.setAttribute("nbConferences", Long.valueOf(nbConferences));
        request.setAttribute("nbSeminaires", Long.valueOf(nbSeminaires));
        request.setAttribute("nbWorkshops", Long.valueOf(nbWorkshops));
        request.setAttribute("nbArchives", Long.valueOf(nbArchives));
        request.setAttribute("membres", membres);
        request.setAttribute("editions", editions);
        request.setAttribute("selectedType", typeFilter);
        request.setAttribute("selectedEdition", editionFilter);
        request.setAttribute("activeNav", "evenements");

        request.getRequestDispatcher("/WEB-INF/views/evenements.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;
        if (user == null && session != null) {
            user = (User) session.getAttribute("user");
        }
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=auth_requise");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "creer";
        }

        switch (action) {
            case "affecter_organisateur": {
                // Affectation d'organisateurs (CDC §9)
                String idStr = request.getParameter("id");
                String organisateur = request.getParameter("organisateur");
                if (idStr != null && organisateur != null) {
                    try {
                        Long id = Long.parseLong(idStr);
                        evtDao.affecterOrganisateur(id, organisateur.trim());
                    } catch (NumberFormatException ignored) {}
                }
                response.sendRedirect(request.getContextPath() + "/evenements?msg=organisateur_affecte");
                break;
            }

            case "modifier_organisation": {
                // Gestion organisationnelle (CDC §9)
                String idStr = request.getParameter("id");
                if (idStr != null) {
                    try {
                        Long id = Long.parseLong(idStr);
                        String titre = request.getParameter("titre");
                        String type = request.getParameter("type");
                        String date = request.getParameter("date");
                        String lieu = request.getParameter("lieu");
                        String description = request.getParameter("description");
                        String programme = request.getParameter("programme");
                        String organisateur = request.getParameter("organisateur");
                        String statut = request.getParameter("statut");
                        String edition = request.getParameter("edition");
                        if (edition == null || edition.trim().isEmpty()) {
                            edition = "Édition " + (date != null && date.length() >= 4 ? date.substring(0, 4) : "2026");
                        }

                        evtDao.updateOrganisation(id, titre, type, date, lieu, description, programme, organisateur, statut, edition);
                    } catch (NumberFormatException ignored) {}
                }
                response.sendRedirect(request.getContextPath() + "/evenements?msg=organisation_modifiee");
                break;
            }

            case "archiver_edition": {
                // Archivage par édition (CDC §9)
                String idStr = request.getParameter("id");
                String edition = request.getParameter("edition");
                if (idStr != null) {
                    try {
                        Long id = Long.parseLong(idStr);
                        evtDao.archiverEdition(id, edition);
                    } catch (NumberFormatException ignored) {}
                }
                response.sendRedirect(request.getContextPath() + "/evenements?msg=edition_archivee");
                break;
            }

            case "supprimer": {
                String idStr = request.getParameter("id");
                if (idStr != null) {
                    try {
                        Long id = Long.parseLong(idStr);
                        evtDao.delete(id);
                    } catch (NumberFormatException ignored) {}
                }
                response.sendRedirect(request.getContextPath() + "/evenements?msg=supprime");
                break;
            }

            case "creer":
            default: {
                // Création d'événement (CDC §9)
                String titre = request.getParameter("titre");
                String type = request.getParameter("type");
                String date = request.getParameter("date");
                String lieu = request.getParameter("lieu");
                String description = request.getParameter("description");
                String programme = request.getParameter("programme");
                String organisateur = request.getParameter("organisateur");
                String edition = request.getParameter("edition");
                String statut = request.getParameter("statut");

                if (edition == null || edition.trim().isEmpty()) {
                    edition = "Édition " + (date != null && date.length() >= 4 ? date.substring(0, 4) : "2026");
                }
                if (statut == null || statut.trim().isEmpty()) {
                    statut = "À venir";
                }

                Evenement evt = new Evenement(null, titre, type, date, lieu, description, organisateur, statut, edition, programme);
                evtDao.save(evt);

                response.sendRedirect(request.getContextPath() + "/evenements?msg=cree");
                break;
            }
        }
    }
}

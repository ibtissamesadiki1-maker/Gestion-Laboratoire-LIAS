package com.lias.web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.lias.beans.Convention;
import com.lias.beans.DocumentLabo;
import com.lias.beans.Evenement;
import com.lias.beans.Member;
import com.lias.beans.Publication;
import com.lias.beans.ReunionPV;
import com.lias.dao.ConventionDaoImpl;
import com.lias.dao.DocumentDaoImpl;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.IConventionDao;
import com.lias.dao.IDocumentDao;
import com.lias.dao.IEvenementDao;
import com.lias.dao.IMemberDao;
import com.lias.dao.IPublicationDao;
import com.lias.dao.IPVDao;
import com.lias.dao.MemberDaoImpl;
import com.lias.dao.PVDaoImpl;
import com.lias.dao.PublicationDaoImpl;

/**
 * Contrôleur de Recherche Globale et Consultation Multi-Entités (CDC §18).
 * Recherche globale unifiée :
 * • Membres
 * • Documents
 * • Événements
 * • Publications
 * • (+ Conventions & Procès-Verbaux)
 */
@WebServlet(name = "RechercheServlet", urlPatterns = {"/recherche"})
public class RechercheServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IMemberDao memberDao;
    private IPublicationDao publicationDao;
    private IEvenementDao evenementDao;
    private IDocumentDao documentDao;
    private IConventionDao conventionDao;
    private IPVDao pvDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.memberDao = new MemberDaoImpl();
        this.publicationDao = new PublicationDaoImpl();
        this.evenementDao = new EvenementDaoImpl();
        this.documentDao = new DocumentDaoImpl();
        this.conventionDao = new ConventionDaoImpl();
        this.pvDao = new PVDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String q = request.getParameter("q");
        String category = request.getParameter("cat");
        if (category == null || category.trim().isEmpty()) {
            category = "tout";
        }

        List<Member> resMembers = new ArrayList<>();
        List<Publication> resPubs = new ArrayList<>();
        List<Evenement> resEvents = new ArrayList<>();
        List<DocumentLabo> resDocs = new ArrayList<>();
        List<Convention> resConventions = new ArrayList<>();
        List<ReunionPV> resPVs = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            String lower = q.trim().toLowerCase();

            // 1. Recherche Membres (CDC §18)
            try {
                for (Member m : memberDao.findAll()) {
                    String full = (m.getNom() + " " + m.getPrenom() + " " + m.getEmail() + " " + m.getEquipe() + " " + 
                                  (m.getGrade() != null ? m.getGrade() : "") + " " + 
                                  (m.getStatut() != null ? m.getStatut() : "") + " " + 
                                  (m.getRole() != null ? m.getRole() : "")).toLowerCase();
                    if (full.contains(lower)) resMembers.add(m);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            // 2. Recherche Publications (CDC §18)
            try {
                for (Publication p : publicationDao.findAll()) {
                    String full = (p.getTitre() + " " + p.getAuteurs() + " " + p.getRevue() + " " + p.getEquipe() + " " + 
                                  (p.getType() != null ? p.getType() : "") + " " + p.getAnnee()).toLowerCase();
                    if (full.contains(lower)) resPubs.add(p);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            // 3. Recherche Événements (CDC §18)
            try {
                for (Evenement ev : evenementDao.findAll()) {
                    String full = (ev.getTitre() + " " + ev.getLieu() + " " + ev.getOrganisateur() + " " + 
                                  ev.getDescription() + " " + ev.getType()).toLowerCase();
                    if (full.contains(lower)) resEvents.add(ev);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            // 4. Recherche Documents (CDC §18)
            try {
                resDocs = documentDao.search(lower);
            } catch (Exception e) {
                e.printStackTrace();
            }

            // 5. Recherche Conventions (CDC §16)
            try {
                for (Convention c : conventionDao.findAll()) {
                    String full = (c.getOrganismePartenaire() + " " + c.getObjet() + " " + c.getTypePartenaire() + " " + 
                                  (c.getReferentLias() != null ? c.getReferentLias() : "")).toLowerCase();
                    if (full.contains(lower)) resConventions.add(c);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            // 6. Recherche Procès-Verbaux (CDC §17)
            try {
                resPVs = pvDao.search(lower);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        int totalCount = resMembers.size() + resPubs.size() + resEvents.size() + resDocs.size() + resConventions.size() + resPVs.size();

        request.setAttribute("query", q != null ? q.trim() : "");
        request.setAttribute("category", category);

        request.setAttribute("resMembers", resMembers);
        request.setAttribute("resPubs", resPubs);
        request.setAttribute("resEvents", resEvents);
        request.setAttribute("resDocs", resDocs);
        request.setAttribute("resConventions", resConventions);
        request.setAttribute("resPVs", resPVs);

        request.setAttribute("countMembers", resMembers.size());
        request.setAttribute("countPubs", resPubs.size());
        request.setAttribute("countEvents", resEvents.size());
        request.setAttribute("countDocs", resDocs.size());
        request.setAttribute("countConventions", resConventions.size());
        request.setAttribute("countPVs", resPVs.size());
        request.setAttribute("totalCount", totalCount);

        request.setAttribute("activeNav", "recherche");

        request.getRequestDispatcher("/WEB-INF/views/recherche.jsp").forward(request, response);
    }
}

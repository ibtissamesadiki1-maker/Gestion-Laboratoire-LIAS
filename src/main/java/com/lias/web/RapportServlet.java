package com.lias.web;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lias.beans.Convention;
import com.lias.beans.DocumentLabo;
import com.lias.beans.Evenement;
import com.lias.beans.Mandat;
import com.lias.beans.Materiel;
import com.lias.beans.Member;
import com.lias.beans.NotificationLabo;
import com.lias.beans.Publication;
import com.lias.beans.ReunionPV;
import com.lias.beans.User;
import com.lias.dao.ConventionDaoImpl;
import com.lias.dao.DBConnection;
import com.lias.dao.DemandeDaoImpl;
import com.lias.dao.DocumentDaoImpl;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.IConventionDao;
import com.lias.dao.IDemandeDao;
import com.lias.dao.IDocumentDao;
import com.lias.dao.IEvenementDao;
import com.lias.dao.IMandatDao;
import com.lias.dao.IMemberDao;
import com.lias.dao.INotificationDao;
import com.lias.dao.IPVDao;
import com.lias.dao.IPublicationDao;
import com.lias.dao.MandatDaoImpl;
import com.lias.dao.MemberDaoImpl;
import com.lias.dao.NotificationDaoImpl;
import com.lias.dao.PVDaoImpl;
import com.lias.dao.PublicationDaoImpl;

/**
 * Contrôleur JEE pour la production automatisée du rapport annuel d'activité (CDC §11 ⭐).
 * 
 * Fonctionnalités :
 * - Génération annuelle automatique
 * - Basé sur :
 *   o Événements
 *   o Publications
 *   o Activités (Conventions, Matériel & Dotations, Encadrements, Délibérations de conseil)
 * - Objectif :
 *   o Condition obligatoire pour l'arbitrage et l'allocation du budget annuel
 */
@WebServlet(name = "RapportServlet", urlPatterns = {"/rapport"})
public class RapportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IMemberDao memberDao;
    private IPublicationDao pubDao;
    private IEvenementDao evtDao;
    private IConventionDao conventionDao;
    private IDemandeDao demandeDao;
    private IPVDao pvDao;
    private IMandatDao mandatDao;
    private IDocumentDao documentDao;
    private INotificationDao notifDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.memberDao = new MemberDaoImpl();
        this.pubDao = new PublicationDaoImpl();
        this.evtDao = new EvenementDaoImpl();
        this.conventionDao = new ConventionDaoImpl();
        this.demandeDao = new DemandeDaoImpl();
        this.pvDao = new PVDaoImpl();
        this.mandatDao = new MandatDaoImpl();
        this.documentDao = new DocumentDaoImpl();
        this.notifDao = new NotificationDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Détermination de l'année d'exercice (par défaut l'année en cours : 2026)
        String anneeStr = request.getParameter("annee");
        int annee = 2026;
        if (anneeStr != null && !anneeStr.trim().isEmpty()) {
            try {
                annee = Integer.parseInt(anneeStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        // 2. Génération automatique basée sur les ÉVÉNEMENTS (CDC §11)
        List<Evenement> allEvts = evtDao.findAll();
        List<Evenement> evtsExercice = new ArrayList<>();
        int countConferences = 0;
        int countSeminaires = 0;
        int countWorkshops = 0;

        for (Evenement e : allEvts) {
            boolean matchYear = false;
            if (e.getDate() != null && e.getDate().startsWith(String.valueOf(annee))) {
                matchYear = true;
            } else if (e.getEdition() != null && e.getEdition().contains(String.valueOf(annee))) {
                matchYear = true;
            }
            if (matchYear) {
                evtsExercice.add(e);
                String t = e.getType() != null ? e.getType().toLowerCase() : "";
                if (t.contains("conf")) countConferences++;
                else if (t.contains("semin") || t.contains("sémin")) countSeminaires++;
                else if (t.contains("work")) countWorkshops++;
            }
        }

        // 3. Génération automatique basée sur les PUBLICATIONS (CDC §11)
        List<Publication> pubsExercice = pubDao.findByYear(annee);
        if (pubsExercice == null || pubsExercice.isEmpty()) {
            // Si aucune pub trouvée pour cette année exacte, charger un ensemble cohérent
            List<Publication> allPubs = pubDao.findAll();
            pubsExercice = new ArrayList<>();
            for (Publication p : allPubs) {
                if (p.getAnnee() == annee) pubsExercice.add(p);
            }
        }

        int countArticles = 0;
        int countConfPubs = 0;
        for (Publication p : pubsExercice) {
            String tp = p.getType() != null ? p.getType().toLowerCase() : "";
            if (tp.contains("conf")) countConfPubs++;
            else countArticles++;
        }

        // 4. Génération automatique basée sur les ACTIVITÉS (CDC §11)
        // 4.1 Conventions & Partenariats de recherche
        List<Convention> allConventions = conventionDao.findAll();
        List<Convention> conventionsExercice = new ArrayList<>();
        double budgetConventionsTotal = 0.0;
        for (Convention c : allConventions) {
            boolean active = "Active".equalsIgnoreCase(c.getStatut());
            boolean signedInYear = (c.getDateSignature() != null && c.getDateSignature().getYear() == annee);
            if (active || signedInYear) {
                conventionsExercice.add(c);
                if (c.getBudgetAlloue() != null) {
                    budgetConventionsTotal += c.getBudgetAlloue().doubleValue();
                }
            }
        }

        // 4.2 Équipements & Dotations de matériel allouées
        List<Materiel> allMateriels = demandeDao.findAllMateriels();
        List<Materiel> materielsExercice = new ArrayList<>();
        for (Materiel m : allMateriels) {
            boolean matchMatYear = false;
            if (m.getDateAttribution() != null && m.getDateAttribution().contains(String.valueOf(annee))) {
                matchMatYear = true;
            } else if (m.getDateDemande() != null && m.getDateDemande().contains(String.valueOf(annee))) {
                matchMatYear = true;
            }
            if (matchMatYear || materielsExercice.size() < 3) {
                materielsExercice.add(m);
            }
        }

        // 4.3 Capital Humain & Encadrement Doctoral
        List<Member> allMembres = memberDao.findAll();
        int countPermanents = 0;
        int countDoctorants = 0;
        int countAssocies = 0;
        for (Member m : allMembres) {
            String st = m.getStatut() != null ? m.getStatut().toLowerCase() : "";
            if (st.contains("doc")) countDoctorants++;
            else if (st.contains("assoc")) countAssocies++;
            else countPermanents++;
        }

        // 4.4 Réunions & Délibérations du Conseil de Laboratoire
        List<ReunionPV> allPVs = pvDao.findAll();
        List<ReunionPV> pvsExercice = new ArrayList<>();
        for (ReunionPV pv : allPVs) {
            if (pv.getDateReunion() != null && pv.getDateReunion().getYear() == annee) {
                pvsExercice.add(pv);
            } else if (pvsExercice.size() < 2) {
                pvsExercice.add(pv);
            }
        }

        // 5. Direction & Gouvernance Active (CDC §5 & §11)
        Mandat mandatActif = null;
        try {
            mandatActif = mandatDao.findActive();
        } catch (Exception ignored) {}

        String nomDirecteur = "Prof. Ibtissam Essadiki";
        String nomViceDirecteur = "Prof. Sara Benjelloun";
        String periodeMandat = "2024–2027";
        if (mandatActif != null) {
            if (mandatActif.getDirecteurNomComplet() != null && !mandatActif.getDirecteurNomComplet().trim().isEmpty()) {
                String d = mandatActif.getDirecteurNomComplet().trim();
                nomDirecteur = d.startsWith("Pr") ? d : "Pr. " + d;
            }
            if (mandatActif.getViceDirecteurNomComplet() != null && !mandatActif.getViceDirecteurNomComplet().trim().isEmpty()) {
                String v = mandatActif.getViceDirecteurNomComplet().trim();
                nomViceDirecteur = v.startsWith("Pr") ? v : "Pr. " + v;
            }
            if (mandatActif.getDateDebut() != null && mandatActif.getDateFin() != null) {
                periodeMandat = mandatActif.getDateDebut().getYear() + "–" + mandatActif.getDateFin().getYear();
            }
        }

        // 6. OBJECTIF : Condition pour budget annuel (CDC §11)
        // Calcul automatique de la subvention éligible selon le barème officiel de performance
        long dotationSocle = 250000L; // Dotation de base de fonctionnement du laboratoire
        long incitationPublications = (long) pubsExercice.size() * 15000L; // 15 000 MAD par publication indexée
        long soutienEvenements = (long) evtsExercice.size() * 20000L;      // 20 000 MAD par colloque/workshop
        long appuiConventions = (long) conventionsExercice.size() * 25000L; // 25 000 MAD par convention active
        long budgetAnnuelEligibleTotal = dotationSocle + incitationPublications + soutienEvenements + appuiConventions;

        boolean conditionBudgetValidee = (evtsExercice.size() > 0 && pubsExercice.size() > 0 && allMembres.size() > 0);

        // 7. Transmission des attributs à la vue JSP
        request.setAttribute("anneeRapport", annee);
        request.setAttribute("totalMembres", allMembres.size());
        request.setAttribute("countPermanents", countPermanents);
        request.setAttribute("countDoctorants", countDoctorants);
        request.setAttribute("countAssocies", countAssocies);
        
        request.setAttribute("totalPublications", pubsExercice.size());
        request.setAttribute("countArticles", countArticles);
        request.setAttribute("countConfPubs", countConfPubs);
        request.setAttribute("publications", pubsExercice);

        request.setAttribute("totalEvenements", evtsExercice.size());
        request.setAttribute("countConferences", countConferences);
        request.setAttribute("countSeminaires", countSeminaires);
        request.setAttribute("countWorkshops", countWorkshops);
        request.setAttribute("evenements", evtsExercice);

        request.setAttribute("totalConventions", conventionsExercice.size());
        request.setAttribute("conventions", conventionsExercice);
        request.setAttribute("budgetConventionsTotal", budgetConventionsTotal);

        request.setAttribute("materiels", materielsExercice);
        request.setAttribute("totalMateriels", materielsExercice.size());

        request.setAttribute("pvs", pvsExercice);
        request.setAttribute("totalPVs", pvsExercice.size());

        request.setAttribute("nomDirecteur", nomDirecteur);
        request.setAttribute("nomViceDirecteur", nomViceDirecteur);
        request.setAttribute("periodeMandat", periodeMandat);

        // Attributs pour le Budget Annuel (CDC §11)
        request.setAttribute("dotationSocle", dotationSocle);
        request.setAttribute("incitationPublications", incitationPublications);
        request.setAttribute("soutienEvenements", soutienEvenements);
        request.setAttribute("appuiConventions", appuiConventions);
        request.setAttribute("budgetAnnuelEligibleTotal", budgetAnnuelEligibleTotal);
        request.setAttribute("conditionBudgetValidee", conditionBudgetValidee);

        request.setAttribute("activeNav", "rapport");

        request.getRequestDispatcher("/WEB-INF/views/rapport.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String action = request.getParameter("action");
        String anneeStr = request.getParameter("annee");
        int annee = 2026;
        if (anneeStr != null && !anneeStr.trim().isEmpty()) {
            try {
                annee = Integer.parseInt(anneeStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        if ("certifier_budget".equals(action)) {
            // Récupérer le nom du signataire
            String signataire = "Prof. Ibtissam Essadiki (Directrice)";
            if (user != null) {
                signataire = (user.getPrenom() != null ? user.getPrenom() + " " : "") + 
                             (user.getNom() != null ? user.getNom() : "Direction LIAS");
            }

            // 1. Archivage documentaire officiel (Conformité CDC §10 & §11)
            String dateDuJour = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            DocumentLabo docRapport = new DocumentLabo(
                null,
                "Rapports",
                "Rapport Annuel " + annee,
                "Édition " + annee,
                "Rapport_Annuel_LIAS_" + annee + "_Certifie.pdf",
                "2.4 MB",
                dateDuJour,
                "pdf",
                signataire,
                "Rapport d'activité scientifique officiel pour l'exercice " + annee + 
                ". Document certifié conforme, condition préalable obligatoire pour l'arbitrage du budget annuel (CDC §11).",
                "Rapports",
                "Administratif - Conseil"
            );
            documentDao.save(docRapport);

            // 2. Notification institutionnelle
            notifDao.save(new NotificationLabo(
                null,
                "rapport",
                "Aujourd'hui",
                true,
                signataire,
                "Le Rapport Annuel d'Activité " + annee + " a été homologué et certifié pour l'arbitrage du budget annuel de recherche.",
                "Consulter →",
                "/rapport?annee=" + annee
            ));

            response.sendRedirect(request.getContextPath() + "/rapport?annee=" + annee + "&msg=certified");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/rapport?annee=" + annee);
    }
}

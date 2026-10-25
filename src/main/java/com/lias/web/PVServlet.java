package com.lias.web;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.lias.beans.NotificationLabo;
import com.lias.beans.ReunionPV;
import com.lias.beans.User;
import com.lias.dao.INotificationDao;
import com.lias.dao.IPVDao;
import com.lias.dao.NotificationDaoImpl;
import com.lias.dao.PVDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Contrôleur des Procès-Verbaux (PV) et Réunions du Laboratoire (CDC §17 ⭐).
 * Fonctionnalités :
 * • Création des réunions
 * • Ordre du jour
 * • Upload des PV
 * • Archivage institutionnel
 */
@WebServlet(name = "PVServlet", urlPatterns = {"/pv"})
public class PVServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IPVDao pvDao;
    private INotificationDao notifDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.pvDao = new PVDaoImpl();
        this.notifDao = new NotificationDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. TÉLÉCHARGEMENT OU CONSULTATION STREAM DU PV (CDC §17 ⭐)
        String action = request.getParameter("action");
        String idStr = request.getParameter("id");
        if (("telecharger".equalsIgnoreCase(action) || "consulter".equalsIgnoreCase(action)) && idStr != null) {
            try {
                Long id = Long.parseLong(idStr.trim());
                ReunionPV pv = pvDao.findById(id);
                if (pv != null) {
                    boolean inline = "consulter".equalsIgnoreCase(action);
                    streamPVDocument(pv, response, inline);
                    return;
                }
            } catch (NumberFormatException ignored) {}
        }

        // SUPPRESSION
        if ("supprimer".equalsIgnoreCase(action) && idStr != null) {
            HttpSession session = request.getSession(false);
            User user = getSessionUser(session);
            if (user != null && canManage(user)) {
                try {
                    Long id = Long.parseLong(idStr.trim());
                    pvDao.delete(id);
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/pv?success=deleted");
            return;
        }

        // 2. FILTRAGE ET RECHERCHE (CDC §17 ⭐)
        String q = request.getParameter("q");
        String type = request.getParameter("type");
        String statut = request.getParameter("statut");

        List<ReunionPV> allPvs = pvDao.findAll();
        List<ReunionPV> displayedPvs = allPvs;

        if (q != null && !q.trim().isEmpty()) {
            displayedPvs = pvDao.search(q.trim());
        } else if (type != null && !type.trim().isEmpty() && !"all".equalsIgnoreCase(type)) {
            displayedPvs = pvDao.findByType(type.trim());
        } else if (statut != null && !statut.trim().isEmpty() && !"all".equalsIgnoreCase(statut)) {
            displayedPvs = pvDao.findByStatut(statut.trim());
        }

        // Calcul des statistiques institutionnelles
        int countAG = 0;
        int countCL = 0;
        int countCE = 0;
        int countPlanifiees = 0;
        int countArchivees = 0;

        for (ReunionPV r : allPvs) {
            String t = r.getTypeReunion() != null ? r.getTypeReunion() : "";
            if (t.contains("Générale")) countAG++;
            else if (t.contains("Extraordinaire")) countCE++;
            else countCL++;

            if ("PLANIFIEE".equalsIgnoreCase(r.getStatut())) {
                countPlanifiees++;
            } else {
                countArchivees++;
            }
        }

        request.setAttribute("pvs", displayedPvs);
        request.setAttribute("allPvs", allPvs);
        request.setAttribute("totalCount", allPvs.size());
        request.setAttribute("countAG", countAG);
        request.setAttribute("countCL", countCL);
        request.setAttribute("countCE", countCE);
        request.setAttribute("countPlanifiees", countPlanifiees);
        request.setAttribute("countArchivees", countArchivees);

        request.setAttribute("searchQuery", q != null ? q.trim() : "");
        request.setAttribute("selectedType", type != null ? type.trim() : "all");
        request.setAttribute("selectedStatut", statut != null ? statut.trim() : "all");

        request.setAttribute("activeMenu", "pv");
        request.setAttribute("activeNav", "pv");

        request.getRequestDispatcher("/WEB-INF/views/pv.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = getSessionUser(session);

        if (user == null || !canManage(user)) {
            response.sendRedirect(request.getContextPath() + "/pv?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");

        // A. UPLOAD D'UN PV POUR UNE RÉUNION EXISTANTE
        if ("upload_pv".equalsIgnoreCase(action)) {
            String reunionIdStr = request.getParameter("reunionId");
            String nomFichier = request.getParameter("nomFichier");
            String statut = request.getParameter("statut");

            if (reunionIdStr != null && !reunionIdStr.trim().isEmpty()) {
                try {
                    Long rId = Long.parseLong(reunionIdStr.trim());
                    if (nomFichier == null || nomFichier.trim().isEmpty()) {
                        nomFichier = "archives/pv_officiel_seance_" + rId + ".pdf";
                    }
                    if (statut == null || statut.trim().isEmpty()) {
                        statut = "ARCHIVEE";
                    }
                    pvDao.updatePVFile(rId, nomFichier.trim(), statut.trim());

                    // Notification
                    NotificationLabo notif = new NotificationLabo(
                        0, "pv", "À l'instant", false,
                        user.getPrenom() + " " + user.getNom(),
                        "Nouveau Procès-Verbal (PV) officiel signé et archivé dans le registre.",
                        "Consulter le PV →", "/pv"
                    );
                    notifDao.save(notif);

                    response.sendRedirect(request.getContextPath() + "/pv?success=uploaded");
                    return;
                } catch (NumberFormatException ignored) {}
            }
        }

        // B. CRÉATION D'UNE RÉUNION & ORDRE DU JOUR (CDC §17 ⭐)
        String titre = request.getParameter("titre");
        String typeReunion = request.getParameter("typeReunion");
        String dateReunionStr = request.getParameter("dateReunion");
        String heure = request.getParameter("heure");
        String lieu = request.getParameter("lieu");
        String ordreDuJour = request.getParameter("ordreDuJour");
        String cheminFichierPV = request.getParameter("cheminFichierPV");
        String directeurSignataire = request.getParameter("directeurSignataire");
        String secretaireSeance = request.getParameter("secretaireSeance");
        String statut = request.getParameter("statut");

        if (titre != null && !titre.trim().isEmpty() && dateReunionStr != null && !dateReunionStr.trim().isEmpty()) {
            try {
                ReunionPV pv = new ReunionPV();
                pv.setTitre(titre.trim());
                pv.setTypeReunion(typeReunion != null && !typeReunion.trim().isEmpty() ? typeReunion.trim() : "Conseil de Laboratoire");
                pv.setDateReunion(LocalDate.parse(dateReunionStr.trim()));
                pv.setHeure(heure != null && !heure.trim().isEmpty() ? heure.trim() : "10:00 - 12:30");
                pv.setLieu(lieu != null && !lieu.trim().isEmpty() ? lieu.trim() : "Salle de Réunion LIAS - FSBM");
                pv.setOrdreDuJour(ordreDuJour != null ? ordreDuJour.trim() : "");
                pv.setDirecteurSignataire(directeurSignataire != null && !directeurSignataire.trim().isEmpty() ? directeurSignataire.trim() : "Prof. Ibtissam Essadiki");
                pv.setSecretaireSeance(secretaireSeance != null && !secretaireSeance.trim().isEmpty() ? secretaireSeance.trim() : (user.getPrenom() + " " + user.getNom()));
                
                if (statut == null || statut.trim().isEmpty()) {
                    statut = "ARCHIVEE";
                }
                pv.setStatut(statut.trim());

                if (cheminFichierPV != null && !cheminFichierPV.trim().isEmpty()) {
                    pv.setCheminFichierPV(cheminFichierPV.trim());
                } else {
                    pv.setCheminFichierPV("archives/pv_seance_" + System.currentTimeMillis() + ".pdf");
                }

                pvDao.save(pv);

                // Notification pour la mémoire institutionnelle
                String actionDesc = "PLANIFIEE".equalsIgnoreCase(statut) ? 
                    "Nouvelle réunion programmée avec Ordre du Jour officiel : " + titre.trim() :
                    "Procès-Verbal consigné et archivé au registre : " + titre.trim();

                NotificationLabo notif = new NotificationLabo(
                    0, "pv", "À l'instant", false,
                    user.getPrenom() + " " + user.getNom(),
                    actionDesc,
                    "Registre PV →", "/pv"
                );
                notifDao.save(notif);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/pv?success=created");
    }

    private User getSessionUser(HttpSession session) {
        if (session == null) return null;
        User u = (User) session.getAttribute("currentUser");
        if (u == null) u = (User) session.getAttribute("user");
        return u;
    }

    private boolean canManage(User user) {
        if (user == null || user.getRole() == null) return false;
        String r = user.getRole().toLowerCase();
        return "directeur".equals(r) || "permanent".equals(r) || "admin".equals(r);
    }

    /**
     * Génère et diffuse le document officiel certifié du Procès-Verbal LIAS (CDC §17 ⭐).
     */
    private void streamPVDocument(ReunionPV pv, HttpServletResponse response, boolean inline) throws IOException {
        String disposition = inline ? "inline" : "attachment";
        String filename = "PV_LIAS_Session_" + pv.getId() + ".txt";

        response.setContentType("text/plain; charset=UTF-8");
        response.setHeader("Content-Disposition", disposition + "; filename=\"" + filename + "\"");

        StringBuilder sb = new StringBuilder();
        sb.append("=========================================================================================\n");
        sb.append("                    ROYAUME DU MAROC — UNIVERSITÉ HASSAN II DE CASABLANCA\n");
        sb.append("                       FACULTÉ DES SCIENCES BEN M'SIK (FSBM)\n");
        sb.append("            LABORATOIRE D'INFORMATIQUE ET D'AIDE À LA DÉCISION (LIAS)\n");
        sb.append("=========================================================================================\n\n");
        sb.append("                      PROCÈS-VERBAL OFFICIEL DE RÉUNION (CDC §17)\n");
        sb.append("                     RÉFÉRENCE D'ARCHIVE : PV-LIAS-").append(pv.getDateReunion().getYear()).append("-00").append(pv.getId()).append("\n\n");
        sb.append("-----------------------------------------------------------------------------------------\n");
        sb.append("1. INFORMATIONS GÉNÉRALES DE LA SÉANCE\n");
        sb.append("-----------------------------------------------------------------------------------------\n");
        sb.append(" • TITRE DE LA SÉANCE    : ").append(pv.getTitre()).append("\n");
        sb.append(" • NATURE DE LA RÉUNION  : ").append(pv.getTypeReunion()).append("\n");
        sb.append(" • DATE DE LA TENUE      : ").append(pv.getDateReunion()).append("\n");
        sb.append(" • HORAIRE DES DÉBATS    : ").append(pv.getHeure()).append("\n");
        sb.append(" • LIEU DE LA SÉANCE     : ").append(pv.getLieu()).append("\n");
        sb.append(" • STATUT AU REGISTRE    : ").append(pv.getStatut()).append("\n\n");

        sb.append("-----------------------------------------------------------------------------------------\n");
        sb.append("2. COMPOSITION DU BUREAU DE SÉANCE & SIGNATAIRES\n");
        sb.append("-----------------------------------------------------------------------------------------\n");
        sb.append(" • PRÉSIDENCE DE SÉANCE  : ").append(pv.getDirecteurSignataire()).append(" (Directeur du Laboratoire LIAS)\n");
        sb.append(" • SECRÉTARIAT DE SÉANCE : ").append(pv.getSecretaireSeance() != null ? pv.getSecretaireSeance() : "Secrétariat LIAS").append("\n");
        sb.append(" • PARTICIPANTS          : Membres statutaires, responsables d'équipes et représentants doctorants.\n\n");

        sb.append("-----------------------------------------------------------------------------------------\n");
        sb.append("3. ORDRE DU JOUR ARRÊTÉ & DÉLIBÉRATIONS ADOPTÉES\n");
        sb.append("-----------------------------------------------------------------------------------------\n");
        String odj = pv.getOrdreDuJour();
        if (odj != null && !odj.trim().isEmpty()) {
            sb.append(odj.trim()).append("\n\n");
        } else {
            sb.append("Points d'ordre du jour statutaires abordés lors de la séance.\n\n");
        }

        sb.append("-----------------------------------------------------------------------------------------\n");
        sb.append("4. CERTIFICATION & ARCHIVAGE INSTITUTIONNEL\n");
        sb.append("-----------------------------------------------------------------------------------------\n");
        sb.append(" • CHEMIN DU FICHIER     : ").append(pv.getCheminFichierPV()).append("\n");
        sb.append(" • HORODATAGE SYSTÈME    : ").append(LocalDate.now()).append("\n");
        sb.append(" • VALEUR STATUTAIRE     : Document officiel validé conformément aux règlements intérieurs\n");
        sb.append("                           du LIAS et des dispositions de l'Université Hassan II de Casablanca.\n\n");
        sb.append("   Pour extrait certifié conforme,\n");
        sb.append("   Le Directeur du Laboratoire LIAS :\n");
        sb.append("   ").append(pv.getDirecteurSignataire()).append("\n");
        sb.append("=========================================================================================\n");

        byte[] bytes = sb.toString().getBytes(StandardCharsets.UTF_8);
        response.setContentLength(bytes.length);
        try (OutputStream os = response.getOutputStream()) {
            os.write(bytes);
            os.flush();
        }
    }
}

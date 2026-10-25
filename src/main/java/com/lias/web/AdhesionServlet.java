package com.lias.web;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import com.lias.beans.DemandeAdhesion;
import com.lias.dao.DemandeDaoImpl;
import com.lias.dao.IDemandeDao;

/**
 * Contrôleur JEE pour les demandes d'adhésion au laboratoire (CDC §6).
 */
@WebServlet(name = "AdhesionServlet", urlPatterns = {"/adhesions"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 25,      // 25MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AdhesionServlet extends HttpServlet {
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
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        com.lias.beans.User user = null;
        if (session != null) {
            user = (com.lias.beans.User) session.getAttribute("currentUser");
            if (user == null) user = (com.lias.beans.User) session.getAttribute("user");
        }
        boolean isDirecteur = (user != null && ("directeur".equalsIgnoreCase(user.getRole()) || "admin".equalsIgnoreCase(user.getRole())));

        // Les dossiers complets ne sont exposés qu'à la direction en mandat (CDC §6)
        if (isDirecteur) {
            List<DemandeAdhesion> adhesions = demandeDao.findAllAdhesions();
            request.setAttribute("adhesions", adhesions);
            request.setAttribute("demandes", adhesions);
        }

        // Suivi en ligne d'une candidature par un candidat via son email (CDC §6)
        String checkEmail = request.getParameter("checkEmail");
        if (checkEmail != null && !checkEmail.trim().isEmpty()) {
            DemandeAdhesion suivi = demandeDao.findAdhesionByEmail(checkEmail.trim());
            request.setAttribute("suiviCandidature", suivi);
            request.setAttribute("searchedEmail", checkEmail.trim());
        }

        request.getRequestDispatcher("/WEB-INF/views/adhesions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("decision".equals(action) || "valider".equals(action) || "refuser".equals(action)) {
            jakarta.servlet.http.HttpSession session = request.getSession(false);
            com.lias.beans.User user = null;
            if (session != null) {
                user = (com.lias.beans.User) session.getAttribute("currentUser");
                if (user == null) user = (com.lias.beans.User) session.getAttribute("user");
            }
            // Contrôle strict : Uniquement par le directeur en mandat (CDC §5.2 & §6)
            if (user == null || (!"directeur".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole()))) {
                response.sendRedirect(request.getContextPath() + "/login?error=auth_requise");
                return;
            }

            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                idStr = request.getParameter("demandeId");
            }
            Long id = Long.parseLong(idStr);
            String decision = request.getParameter("decision"); // ACCEPTEE ou REFUSEE
            if (decision == null || decision.trim().isEmpty()) {
                decision = "valider".equalsIgnoreCase(action) ? "ACCEPTEE" : "REFUSEE";
            }
            demandeDao.updateDecisionAdhesion(id, decision);
            response.sendRedirect(request.getContextPath() + "/adhesions?msg=decision_enregistree");
            return;
        } else if ("consulter".equals(action)) {
            // Suivi direct du dossier par le candidat
            String email = request.getParameter("email");
            if (email == null) email = request.getParameter("checkEmail");
            String encoded = email != null ? java.net.URLEncoder.encode(email.trim(), "UTF-8") : "";
            response.sendRedirect(request.getContextPath() + "/adhesions?checkEmail=" + encoded + "#suiviCandidature");
            return;
        } else {
            // Soumission en ligne avec dossier complet (CV, motivation...) (CDC §6)
            String nom = request.getParameter("nom");
            String prenom = request.getParameter("prenom");
            String email = request.getParameter("email");
            String statutVise = request.getParameter("statutVise");
            if (statutVise == null || statutVise.trim().isEmpty()) {
                statutVise = request.getParameter("statutPostule");
            }
            String etablissement = request.getParameter("etablissement");
            if (etablissement == null || etablissement.trim().isEmpty()) {
                etablissement = request.getParameter("etablissementOrigine");
            }
            String motivation = request.getParameter("motivation");

            // Traitement du CV physique uploadé (obligatoire et transmis tel quel à la direction)
            String cvPath = null;
            try {
                Part filePart = request.getPart("cvFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String submittedName = filePart.getSubmittedFileName();
                    if (submittedName != null && !submittedName.trim().isEmpty()) {
                        String cleanName = new File(submittedName).getName().replaceAll("[^a-zA-Z0-9._-]", "_");
                        String prefix = "cv_" + (prenom != null && !prenom.trim().isEmpty() ? prenom.trim().toLowerCase().replaceAll("[^a-z0-9]", "") : "candidat") + "_";
                        String savedFileName = prefix + cleanName;

                        // Emplacement physique dans la webapp Tomcat
                        String uploadPath = request.getServletContext().getRealPath("/dossiers");
                        if (uploadPath == null) {
                            uploadPath = "/usr/local/tomcat/webapps/ROOT/dossiers";
                        }
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        File destFile = new File(uploadDir, savedFileName);
                        try (InputStream in = filePart.getInputStream()) {
                            Files.copy(in, destFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        }

                        // Persistance additionnelle dans le dossier local du projet si distinct
                        try {
                            File hostDir = new File("src/main/webapp/dossiers");
                            if (hostDir.exists() && !hostDir.getAbsolutePath().equals(uploadDir.getAbsolutePath())) {
                                Files.copy(destFile.toPath(), new File(hostDir, savedFileName).toPath(), StandardCopyOption.REPLACE_EXISTING);
                            }
                        } catch (Exception ignored) {}

                        cvPath = "dossiers/" + savedFileName;
                    }
                }
            } catch (Exception ex) {
                // Pas de part multipart ou encodage standard
            }

            if (cvPath == null || cvPath.trim().isEmpty()) {
                cvPath = request.getParameter("cvPath");
            }
            if (cvPath == null || cvPath.trim().isEmpty()) {
                cvPath = request.getParameter("cvUrl");
            }
            if (cvPath == null || cvPath.trim().isEmpty()) {
                cvPath = "dossiers/cv_" + (prenom != null ? prenom.toLowerCase() : "candidat") + ".pdf";
            }
            String date = LocalDate.now().toString();

            DemandeAdhesion d = new DemandeAdhesion(null, nom, prenom, email, statutVise, etablissement, motivation, date, "EN_ATTENTE", cvPath.trim());
            demandeDao.saveAdhesion(d);
            String encodedEmail = email != null ? java.net.URLEncoder.encode(email.trim(), "UTF-8") : "";
            response.sendRedirect(request.getContextPath() + "/adhesions?msg=soumission_reussie&checkEmail=" + encodedEmail + "#suiviCandidature");
        }
    }
}

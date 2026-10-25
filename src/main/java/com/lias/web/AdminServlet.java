package com.lias.web;

import java.io.IOException;
import java.util.List;

import com.lias.beans.User;
import com.lias.beans.Member;
import com.lias.beans.NotificationLabo;
import com.lias.dao.IUserDao;
import com.lias.dao.UserDaoImpl;
import com.lias.dao.IMemberDao;
import com.lias.dao.MemberDaoImpl;
import com.lias.dao.IPublicationDao;
import com.lias.dao.PublicationDaoImpl;
import com.lias.dao.IEvenementDao;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.IDocumentDao;
import com.lias.dao.DocumentDaoImpl;
import com.lias.dao.IPVDao;
import com.lias.dao.PVDaoImpl;
import com.lias.dao.IConventionDao;
import com.lias.dao.ConventionDaoImpl;
import com.lias.dao.INotificationDao;
import com.lias.dao.NotificationDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Contrôleur d'Administration Système, Gouvernance Technique (CDC §5.1)
 * et Supervision des Règles Générales du Système & Mémoire Institutionnelle (CDC §21 ⭐).
 */
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IUserDao userDao;
    private IMemberDao memberDao;
    private IPublicationDao publicationDao;
    private IEvenementDao evenementDao;
    private IDocumentDao documentDao;
    private IPVDao pvDao;
    private IConventionDao conventionDao;
    private INotificationDao notificationDao;

    @Override
    public void init() throws ServletException {
        this.userDao = new UserDaoImpl();
        this.memberDao = new MemberDaoImpl();
        this.publicationDao = new PublicationDaoImpl();
        this.evenementDao = new EvenementDaoImpl();
        this.documentDao = new DocumentDaoImpl();
        this.pvDao = new PVDaoImpl();
        this.conventionDao = new ConventionDaoImpl();
        this.notificationDao = new NotificationDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("currentUser");
            if (user == null) user = (User) session.getAttribute("user");
        }

        boolean isAuthorized = user != null && ("admin".equalsIgnoreCase(user.getRole()) || "directeur".equalsIgnoreCase(user.getRole()));
        if (!isAuthorized) {
            request.setAttribute("requiredRole", "Directeur du Laboratoire ou Administrateur Système");
            request.setAttribute("deniedUrl", request.getRequestURI());
            request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
            return;
        }

        List<User> users = userDao.findAll();
        request.setAttribute("users", users);
        request.setAttribute("activeMenu", "admin");
        request.setAttribute("activeNav", "admin");

        // Métriques techniques de maintenance (CDC §5.1)
        Runtime rt = Runtime.getRuntime();
        long totalMem = rt.totalMemory() / (1024 * 1024);
        long freeMem = rt.freeMemory() / (1024 * 1024);
        long usedMem = totalMem - freeMem;
        request.setAttribute("jvmUsedMem", usedMem + " MB");
        request.setAttribute("jvmTotalMem", totalMem + " MB");
        request.setAttribute("javaVersion", System.getProperty("java.version"));
        request.setAttribute("osName", System.getProperty("os.name"));

        // Métriques d'intégrité globale et de mémoire institutionnelle (CDC §21 ⭐)
        List<Member> allMembers = memberDao.findAll();
        int countPermanents = 0;
        int countDoctorants = 0;
        int countAssocies = 0;
        int countRetraites = 0;
        int countAnciens = 0;

        for (Member m : allMembers) {
            String st = m.getStatus() != null ? m.getStatus().toLowerCase() : "";
            if ("permanent".equals(st)) countPermanents++;
            else if ("doctorant".equals(st)) countDoctorants++;
            else if ("associe".equals(st)) countAssocies++;
            else if ("retraite".equals(st)) countRetraites++;
            else if ("ancien".equals(st)) countAnciens++;
            else countPermanents++;
        }

        request.setAttribute("allMembers", allMembers);
        request.setAttribute("countPermanents", countPermanents);
        request.setAttribute("countDoctorants", countDoctorants);
        request.setAttribute("countAssocies", countAssocies);
        request.setAttribute("countRetraites", countRetraites);
        request.setAttribute("countAnciens", countAnciens);

        // Données institutionnelles globales (CDC §21 ⭐)
        int totalPubs = publicationDao.findAll().size();
        int totalEvents = evenementDao.findAll().size();
        int totalDocs = documentDao.findAll().size();
        int totalPVs = pvDao.findAll().size();
        int totalConventions = conventionDao.findAll().size();
        List<NotificationLabo> auditLogs = notificationDao.findAll();

        request.setAttribute("totalPubs", totalPubs);
        request.setAttribute("totalEvents", totalEvents);
        request.setAttribute("totalDocs", totalDocs);
        request.setAttribute("totalPVs", totalPVs);
        request.setAttribute("totalConventions", totalConventions);
        request.setAttribute("auditLogs", auditLogs);

        request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentAdmin = null;
        if (session != null) {
            currentAdmin = (User) session.getAttribute("currentUser");
            if (currentAdmin == null) currentAdmin = (User) session.getAttribute("user");
        }

        boolean isAuthorized = currentAdmin != null && ("admin".equalsIgnoreCase(currentAdmin.getRole()) || "directeur".equalsIgnoreCase(currentAdmin.getRole()));
        if (!isAuthorized) {
            request.setAttribute("requiredRole", "Directeur du Laboratoire ou Administrateur Système");
            request.setAttribute("deniedUrl", request.getRequestURI());
            request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
            return;
        }

        String action = request.getParameter("action");

        if ("toggleActif".equalsIgnoreCase(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                Long id = Long.parseLong(idStr);
                User targetUser = userDao.findById(id);
                if (targetUser != null && !targetUser.getId().equals(currentAdmin.getId())) {
                    boolean newActif = !targetUser.isActif();
                    targetUser.setActif(newActif);
                    if (newActif && ("ancien".equalsIgnoreCase(targetUser.getRole()) || "retraite".equalsIgnoreCase(targetUser.getRole()))) {
                        targetUser.setRole("permanent");
                    }
                    userDao.update(targetUser);

                    Member mem = memberDao.findByEmail(targetUser.getEmail());
                    if (mem != null) {
                        if (newActif) {
                            memberDao.reactiverAncienMembre(mem.getId(), java.time.LocalDate.now(), "permanent", "membre");
                        } else {
                            memberDao.desactiverAncienMembre(mem.getId(), java.time.LocalDate.now(), "Désactivation par l'administrateur");
                        }
                    }
                }
            }
        } else if ("reactiverCompte".equalsIgnoreCase(action)) {
            // CDC §8.2 : Ancien membre — Réactivation de compte
            String idStr = request.getParameter("id");
            if (idStr != null) {
                Long id = Long.parseLong(idStr);
                User targetUser = userDao.findById(id);
                if (targetUser != null) {
                    targetUser.setActif(true);
                    if ("ancien".equalsIgnoreCase(targetUser.getRole()) || "retraite".equalsIgnoreCase(targetUser.getRole())) {
                        targetUser.setRole("permanent");
                    }
                    userDao.update(targetUser);

                    Member mem = memberDao.findByEmail(targetUser.getEmail());
                    if (mem != null) {
                        memberDao.reactiverAncienMembre(mem.getId(), java.time.LocalDate.now(), "permanent", "membre");
                    }
                }
            }
        } else if ("gelerRetraite".equalsIgnoreCase(action)) {
            // CDC §8.1 : Retraité — Compte gelé, aucun accès actif
            String idStr = request.getParameter("id");
            if (idStr != null) {
                Long id = Long.parseLong(idStr);
                User targetUser = userDao.findById(id);
                if (targetUser != null) {
                    Member mem = memberDao.findByEmail(targetUser.getEmail());
                    if (mem != null) {
                        memberDao.gelerCompteRetraite(mem.getId(), java.time.LocalDate.now(), "Mise en retraite (Admin)");
                    } else {
                        targetUser.setActif(false);
                        targetUser.setRole("retraite");
                        userDao.update(targetUser);
                    }
                }
            }
        } else if ("changeRole".equalsIgnoreCase(action)) {
            String idStr = request.getParameter("id");
            String newRole = request.getParameter("role");
            if (idStr != null && newRole != null) {
                Long id = Long.parseLong(idStr);
                User targetUser = userDao.findById(id);
                if (targetUser != null) {
                    Member mem = memberDao.findByEmail(targetUser.getEmail());
                    if ("retraite".equalsIgnoreCase(newRole)) {
                        if (mem != null) {
                            memberDao.gelerCompteRetraite(mem.getId(), java.time.LocalDate.now(), "Attribution statut Retraité");
                        } else {
                            targetUser.setRole("retraite");
                            targetUser.setActif(false);
                            userDao.update(targetUser);
                        }
                    } else if ("ancien".equalsIgnoreCase(newRole)) {
                        if (mem != null) {
                            memberDao.desactiverAncienMembre(mem.getId(), java.time.LocalDate.now(), "Attribution statut Ancien Membre");
                        } else {
                            targetUser.setRole("ancien");
                            targetUser.setActif(false);
                            userDao.update(targetUser);
                        }
                    } else {
                        targetUser.setRole(newRole);
                        targetUser.setActif(true);
                        userDao.update(targetUser);
                        if (mem != null && ("ancien".equalsIgnoreCase(mem.getStatus()) || "retraite".equalsIgnoreCase(mem.getStatus()))) {
                            memberDao.reactiverAncienMembre(mem.getId(), java.time.LocalDate.now(), newRole, "membre");
                        }
                    }
                }
            }
        } else if ("create".equalsIgnoreCase(action)) {
            String nom = request.getParameter("nom");
            String prenom = request.getParameter("prenom");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String role = request.getParameter("role");

            if (nom != null && prenom != null && email != null && password != null) {
                User newUser = new User();
                newUser.setNom(nom.trim());
                newUser.setPrenom(prenom.trim());
                newUser.setEmail(email.trim());
                newUser.setPassword(password.trim());
                newUser.setRole(role != null ? role.trim() : "visiteur");
                newUser.setActif(true);

                userDao.save(newUser);
            }
        } else if ("saveParametrage".equalsIgnoreCase(action)) {
            // Sauvegarde des paramètres de l'application (CDC §5.1)
            String labName = request.getParameter("labName");
            String dateCreation = request.getParameter("dateCreation");
            String quotaStockage = request.getParameter("quotaStockage");
            String maintenanceMode = request.getParameter("maintenanceMode");

            if (labName != null) getServletContext().setAttribute("app_labName", labName.trim());
            if (dateCreation != null) getServletContext().setAttribute("app_dateCreation", dateCreation.trim());
            if (quotaStockage != null) getServletContext().setAttribute("app_quotaStockage", quotaStockage.trim());
            getServletContext().setAttribute("app_maintenanceMode", "on".equalsIgnoreCase(maintenanceMode));

            response.sendRedirect(request.getContextPath() + "/admin?tab=param&success=params_saved");
            return;
        } else if ("maintenance".equalsIgnoreCase(action)) {
            // Maintenance technique (CDC §5.1)
            String operation = request.getParameter("operation");
            if ("purgeCache".equalsIgnoreCase(operation)) {
                System.gc();
            } else if ("checkDb".equalsIgnoreCase(operation)) {
                userDao.findAll();
            }
            response.sendRedirect(request.getContextPath() + "/admin?tab=maint&success=maint_done");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin?success=updated");
    }
}

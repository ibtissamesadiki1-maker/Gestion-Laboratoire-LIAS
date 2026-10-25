package com.lias.web;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lias.beans.NotificationLabo;
import com.lias.beans.User;
import com.lias.dao.INotificationDao;
import com.lias.dao.NotificationDaoImpl;

/**
 * Contrôleur du Centre de Notifications (CDC §19).
 * Couvre les 3 piliers statutaires du Cahier des Charges :
 * • Événements (manifestations scientifiques, rappels calendrier)
 * • Validation demandes (adhésions, arbitrages de matériel)
 * • Ajouts de documents (dépôts documentaires, PV scellés, rapports annuels)
 */
@WebServlet(name = "NotificationServlet", urlPatterns = {"/notifications"})
public class NotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private INotificationDao notificationDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.notificationDao = new NotificationDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");

        // Action 1 : Marquer tout comme lu
        if ("markAllRead".equalsIgnoreCase(action) || "mark_all_read".equalsIgnoreCase(action)) {
            notificationDao.markAllAsRead();
            response.sendRedirect(request.getContextPath() + "/notifications?msg=tout_lu");
            return;
        }

        // Action 2 : Marquer une notification spécifique comme lue
        if ("mark_read".equalsIgnoreCase(action) || "markRead".equalsIgnoreCase(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    notificationDao.markAsRead(Integer.parseInt(idStr.trim()));
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/notifications?msg=lu");
            return;
        }

        // Action 3 : Supprimer une notification
        if ("supprimer".equalsIgnoreCase(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    notificationDao.delete(Integer.parseInt(idStr.trim()));
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/notifications?msg=supprime");
            return;
        }

        // Filtrage par catégorie CDC §19
        String filter = request.getParameter("filter");
        if (filter == null || filter.trim().isEmpty()) {
            filter = "toutes";
        }

        List<NotificationLabo> notifications = notificationDao.findByCategory(filter);

        // Calcul des métriques statistiques pour les onglets
        List<NotificationLabo> allNotifs = notificationDao.findAll();
        int totalCount = allNotifs.size();
        int unreadCount = notificationDao.findUnread().size();
        int countEvents = notificationDao.findByCategory("evenements").size();
        int countValidations = notificationDao.findByCategory("validations").size();
        int countDocs = notificationDao.findByCategory("documents").size();

        request.setAttribute("notifications", notifications);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("unreadCount", unreadCount);
        request.setAttribute("countEvents", countEvents);
        request.setAttribute("countValidations", countValidations);
        request.setAttribute("countDocs", countDocs);

        request.setAttribute("activeFilter", filter.toLowerCase());
        request.setAttribute("activeNav", "notifications");

        request.getRequestDispatcher("/WEB-INF/views/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("markAllRead".equalsIgnoreCase(action)) {
            notificationDao.markAllAsRead();
            response.sendRedirect(request.getContextPath() + "/notifications?msg=tout_lu");
            return;
        } 
        
        if ("markRead".equalsIgnoreCase(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    notificationDao.markAsRead(Integer.parseInt(idStr.trim()));
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/notifications?msg=lu");
            return;
        }

        // Diffusion d'une notification institutionnelle (Directeur / Admin)
        if ("creer_notification".equalsIgnoreCase(action)) {
            HttpSession session = request.getSession(false);
            User user = null;
            if (session != null) {
                user = (User) session.getAttribute("currentUser");
                if (user == null) user = (User) session.getAttribute("user");
            }

            String kind = request.getParameter("kind");
            String who = request.getParameter("who");
            String body = request.getParameter("body");
            String actionLabel = request.getParameter("actionLabel");
            String targetUrl = request.getParameter("targetUrl");

            if (body != null && !body.trim().isEmpty()) {
                if (kind == null || kind.trim().isEmpty()) kind = "event";
                if (who == null || who.trim().isEmpty()) {
                    who = (user != null && user.getPrenom() != null ? user.getPrenom() + " " + user.getNom() : "Direction LIAS");
                }
                if (actionLabel == null || actionLabel.trim().isEmpty()) actionLabel = "Consulter →";
                if (targetUrl == null || targetUrl.trim().isEmpty()) targetUrl = "/notifications";

                NotificationLabo notif = new NotificationLabo(
                    null, kind.trim(), "À l'instant", false, who.trim(), body.trim(), actionLabel.trim(), targetUrl.trim()
                );
                notificationDao.save(notif);
                response.sendRedirect(request.getContextPath() + "/notifications?msg=cree");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/notifications");
    }
}

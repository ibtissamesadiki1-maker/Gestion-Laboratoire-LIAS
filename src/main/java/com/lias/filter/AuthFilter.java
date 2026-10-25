package com.lias.filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Filtre de sécurité JEE (AuthFilter).
 * Vérifie qu'une session HTTP active existe avant d'accéder aux pages privées.
 * Si non connecté, redirige automatiquement vers la page de login.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {
    "/home", "/home/*",
    "/admin", "/admin/*",
    "/publications", "/publications/*",
    "/evenements", "/evenements/*",
    "/calendrier", "/calendrier/*",
    "/membres", "/membres/*",
    "/profils", "/profils/*",
    "/materiel", "/materiel/*",
    "/besoins-materiel", "/besoins-materiel/*",
    "/besoins", "/besoins/*",
    "/conventions", "/conventions/*",
    "/mandats", "/mandats/*",
    "/pv", "/pv/*",
    "/documents", "/documents/*",
    "/communication", "/communication/*",
    "/rapport", "/rapport/*",
    "/notifications", "/notifications/*",
    "/recherche", "/recherche/*"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialisation du filtre
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        boolean isLoggedIn = (session != null && (session.getAttribute("currentUser") != null || session.getAttribute("user") != null));

        if (isLoggedIn) {
            String servletPath = request.getServletPath();
            com.lias.beans.User user = (com.lias.beans.User) session.getAttribute("currentUser");
            if (user == null) user = (com.lias.beans.User) session.getAttribute("user");
            String role = user != null && user.getRole() != null ? user.getRole().toLowerCase() : "visiteur";

            // CDC §8.1 : Retraité — Compte gelé, aucun accès actif
            if ("retraite".equalsIgnoreCase(role)) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login?error=compte_gele");
                return;
            }

            // CDC §8.2 : Ancien membre — Compte désactivé, aucun accès actif
            if ("ancien".equalsIgnoreCase(role) || (user != null && !user.isActif())) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login?error=compte_desactive");
                return;
            }

            boolean isDoctorant = "doctorant".equals(role);
            boolean isAssocie = "associe".equals(role);
            boolean isPermanent = "permanent".equals(role);
            boolean isDirectorOrAdmin = "directeur".equals(role) || "admin".equals(role);

            // CDC §2.2 C : Doctorants -> Aucun accès aux modules internes de gouvernance
            // CDC §2.2 B : Membres associés -> Accès limité consultation / pas de gestion interne
            boolean isInternalModule = servletPath.startsWith("/mandats") ||
                                       servletPath.startsWith("/pv") ||
                                       servletPath.startsWith("/documents") ||
                                       servletPath.startsWith("/rapport") ||
                                       servletPath.startsWith("/admin");

            if ((isDoctorant || isAssocie) && isInternalModule) {
                request.setAttribute("requiredRole", "Membre Permanent ou Direction (Module interne réservé)");
                request.setAttribute("deniedUrl", request.getRequestURI());
                request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
                return;
            }

            // Seuls le directeur ou l'administrateur ont accès à l'administration technique et au rapport annuel
            if (isPermanent && (servletPath.startsWith("/admin") || servletPath.startsWith("/rapport"))) {
                request.setAttribute("requiredRole", "Directeur du Laboratoire ou Administrateur Système");
                request.setAttribute("deniedUrl", request.getRequestURI());
                request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
                return;
            }

            // Utilisateur connecté et autorisé -> autoriser l'accès
            chain.doFilter(req, res);
        } else {
            String servletPath = request.getServletPath();
            String method = request.getMethod();

            // CDC §2.1 Visiteurs (public) : Accès libre sans authentification pour consultation
            boolean isPublicConsultation = "GET".equalsIgnoreCase(method) && 
                (servletPath.startsWith("/publications") || 
                 servletPath.startsWith("/evenements") || 
                 servletPath.startsWith("/profils") || 
                 servletPath.startsWith("/membres") ||
                 servletPath.startsWith("/calendrier"));

            if (isPublicConsultation) {
                chain.doFilter(req, res);
            } else {
                // Utilisateur non connecté -> redirection vers la page de connexion
                response.sendRedirect(request.getContextPath() + "/login?error=auth_requise");
            }
        }
    }

    @Override
    public void destroy() {
        // Nettoyage des ressources du filtre
    }
}

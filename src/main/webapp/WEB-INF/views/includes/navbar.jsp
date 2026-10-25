<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lias.beans.User"%>
<%
    User navUser = (User) session.getAttribute("currentUser");
    
    // Récupération fiable de l'URI d'origine en cas de forward JSP
    String reqUri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
    if (reqUri == null) {
        reqUri = request.getRequestURI();
    }
    String ctx = request.getContextPath();
    String pathAfterCtx = (reqUri != null && ctx != null && reqUri.startsWith(ctx)) ? reqUri.substring(ctx.length()) : (reqUri != null ? reqUri : "");

    // Détection stricte de la page d'accueil (vitrine one-page) vs pages dédiées
    boolean isHome = "/public".equals(pathAfterCtx) || "/accueil".equals(pathAfterCtx) || "/".equals(pathAfterCtx) || "".equals(pathAfterCtx);
    boolean isProfils = pathAfterCtx.startsWith("/profils") || pathAfterCtx.startsWith("/membres");
    boolean isPubs = pathAfterCtx.startsWith("/publications");
    boolean isEvents = pathAfterCtx.startsWith("/evenements");
    boolean isAdhesions = pathAfterCtx.startsWith("/adhesions");
%>
<header class="topbar">
    <div class="brand">
        <a href="<%= isHome ? "#top" : ctx + "/public" %>" class="brand-link" style="display:flex; align-items:center; gap:12px; text-decoration:none;">
            <div class="brand-logo-badge">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="3"/>
                    <ellipse cx="12" cy="12" rx="9" ry="4" transform="rotate(30 12 12)"/>
                    <ellipse cx="12" cy="12" rx="9" ry="4" transform="rotate(-30 12 12)"/>
                </svg>
            </div>
            <div class="brand-text-block">
                <div class="brand-title-row">
                    <span class="brand-name-text">LIAS</span>
                    <span class="brand-pill-tag">FSBM</span>
                </div>
                <span class="brand-subtext">Laboratoire d'Informatique &amp; Applications</span>
            </div>
        </a>
    </div>

    <nav class="nav">
        <% if (isHome) { %>
            <a href="#top" class="active nav-link" id="nav-top">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                Accueil
            </a>
            <a href="#equipes" class="nav-link" id="nav-equipes">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                Équipes
            </a>
            <a href="#publications" class="nav-link" id="nav-publications">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                Publications
            </a>
            <a href="#evenements" class="nav-link" id="nav-evenements">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                Événements
            </a>
        <% } else { %>
            <a href="<%= ctx %>/public" class="nav-link">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                Accueil
            </a>
            <a href="<%= ctx %>/profils" class="nav-link <%= isProfils ? "active" : "" %>">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                Membres
            </a>
            <a href="<%= ctx %>/publications" class="nav-link <%= isPubs ? "active" : "" %>">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                Publications
            </a>
            <a href="<%= ctx %>/evenements" class="nav-link <%= isEvents ? "active" : "" %>">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                Événements
            </a>
        <% } %>

        <% if (navUser != null) { %>
            <a href="<%= ctx %>/home" class="nav-link <%= "/home".equals(pathAfterCtx) ? "active" : "" %>">Tableau de bord</a>
            <a href="<%= ctx %>/adhesions" class="nav-link <%= isAdhesions ? "active" : "" %>">Adhésions</a>
            <a href="<%= ctx %>/materiel" class="nav-link <%= "/materiel".equals(pathAfterCtx) ? "active" : "" %>">Matériel</a>
            <% if ("directeur".equalsIgnoreCase(navUser.getRole()) || "admin".equalsIgnoreCase(navUser.getRole())) { %>
                <a href="<%= ctx %>/rapport" class="nav-link <%= "/rapport".equals(pathAfterCtx) ? "active" : "" %>">Rapport Annuel</a>
            <% } %>

            <div class="user-badge">
                <span class="user-dot"></span>
                <span><%= navUser.getPrenom() %> <%= navUser.getNom() %></span>
                <span class="user-role"><%= navUser.getRole() %></span>
            </div>
            <a href="<%= ctx %>/logout" class="btn-nav-logout">Déconnexion</a>
        <% } else { %>
            <% if (isHome) { %>
                <a href="#rejoindre" class="nav-badge-btn nav-link" id="nav-rejoindre">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                    Rejoindre
                </a>
            <% } else { %>
                <a href="<%= ctx %>/adhesions" class="nav-badge-btn <%= isAdhesions ? "active" : "" %>">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                    Rejoindre
                </a>
            <% } %>
            <a href="<%= ctx %>/login" class="cta">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                Espace Membres
            </a>
        <% } %>
    </nav>
</header>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lias.beans.User"%>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) u = (User) session.getAttribute("user");
    String currentRole = u != null && u.getRole() != null ? u.getRole() : "visiteur";
    String requiredRole = (String) request.getAttribute("requiredRole");
    if (requiredRole == null) requiredRole = "Directeur du Laboratoire ou Administrateur Système";
    String deniedUrl = (String) request.getAttribute("deniedUrl");
    if (deniedUrl == null) deniedUrl = request.getRequestURI();
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 Accès Réservé — Laboratoire LIAS</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        .error-container {
            max-width: 680px;
            margin: 60px auto;
            background: var(--surface, #FAF7F2);
            border: 1px solid var(--border, #E2D9CC);
            border-radius: 6px;
            padding: 36px 40px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.06);
            text-align: center;
        }
        .error-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 4px 12px;
            background: #FBEAE8;
            color: #B5453E;
            border: 1px solid #E8B4AF;
            border-radius: 100px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            font-weight: 600;
            margin-bottom: 20px;
        }
        .error-icon {
            font-size: 54px;
            color: #B5453E;
            margin-bottom: 12px;
        }
        .error-table {
            width: 100%;
            margin: 24px 0;
            border-collapse: collapse;
            text-align: left;
            font-family: 'Inter', sans-serif;
            font-size: 13.5px;
            background: var(--surface-2, #F3ECE1);
            border-radius: 4px;
            overflow: hidden;
        }
        .error-table td {
            padding: 12px 16px;
            border-bottom: 1px solid var(--border, #E2D9CC);
        }
        .error-table tr:last-child td {
            border-bottom: none;
        }
    </style>
</head>
<body class="app-body">
    <!-- APP HEADER -->
    <%@ include file="../includes/app_header.jsp" %>

    <div class="app-container">
        <!-- SIDEBAR -->
        <%@ include file="../includes/sidebar.jsp" %>

        <!-- MAIN -->
        <main class="app-main">
            <div class="error-container">
                <div class="error-icon">🛡</div>
                <div class="error-badge">Code HTTP 403 · Accès Réservé</div>
                
                <h1 style="font-family:var(--font-serif); font-size:24px; color:var(--ink); margin:0 0 10px 0;">
                    Privilèges Insuffisants pour Cette Section
                </h1>
                
                <p style="font-family:'Inter', sans-serif; font-size:14px; color:var(--muted); line-height:1.6; margin:0 auto; max-width:540px;">
                    Cette section du système d'information du laboratoire LIAS est soumise à un contrôle d'accès strict défini par les règles de gouvernance du laboratoire.
                </p>

                <table class="error-table">
                    <tr>
                        <td style="color:var(--muted); width:40%;">Ressource demandée :</td>
                        <td style="font-family:'JetBrains Mono', monospace; font-size:12px; color:var(--ink);"><%= deniedUrl %></td>
                    </tr>
                    <tr>
                        <td style="color:var(--muted);">Votre rôle actuel :</td>
                        <td>
                            <span class="badge" style="background:rgba(27,47,74,0.1); color:var(--navy); font-weight:600; text-transform:uppercase; font-size:11px; padding:3px 8px; border-radius:3px;">
                                <%= currentRole %>
                            </span>
                            <% if (u != null) { %>
                                <span style="font-size:12px; color:var(--muted); margin-left:6px;">(<%= u.getEmail() %>)</span>
                            <% } %>
                        </td>
                    </tr>
                    <tr>
                        <td style="color:var(--muted);">Habilitation requise :</td>
                        <td style="color:#B5453E; font-weight:600;"><%= requiredRole %></td>
                    </tr>
                    <tr>
                        <td style="color:var(--muted);">Règle académique :</td>
                        <td style="font-size:12px; color:var(--muted); line-height:1.4;">
                            Conformément aux règles de gouvernance, la configuration des comptes et la validation des mandats sont réservées à la Direction et aux Administrateurs du laboratoire.
                        </td>
                    </tr>
                </table>

                <div style="display:flex; justify-content:center; gap:14px; margin-top:28px;">
                    <a href="<%= request.getContextPath() %>/home" class="btn btn-primary">
                        ← Retour au Tableau de bord
                    </a>
                    <a href="<%= request.getContextPath() %>/profils" class="btn btn-secondary">
                        Consulter mon profil
                    </a>
                </div>
            </div>
        </main>
    </div>
</body>
</html>

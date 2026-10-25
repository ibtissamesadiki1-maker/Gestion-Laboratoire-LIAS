<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.MessageCommunication"%>
<%@ page import="com.lias.beans.Evenement"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    List<MessageCommunication> messages = (List<MessageCommunication>) request.getAttribute("messages");
    List<Evenement> evenementsList = (List<Evenement>) request.getAttribute("evenementsList");
    String activeCanal = (String) request.getAttribute("activeCanal");
    if (activeCanal == null) activeCanal = "general";
    String canalTitre = (String) request.getAttribute("canalTitre");
    if (canalTitre == null) canalTitre = "Canal Général & Direction";
    String canalDesc = (String) request.getAttribute("canalDesc");
    if (canalDesc == null) canalDesc = "Discussions transversales et coordination des membres du LIAS.";
    String canalType = (String) request.getAttribute("canalType");
    if (canalType == null) canalType = "membres";

    String msgStatus = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Communication Interne & Canaux de Discussion</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        .comm-layout {
            display: grid;
            grid-template-columns: 320px 1fr;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: var(--surface);
            overflow: hidden;
            height: calc(100vh - 210px);
            min-height: 600px;
            box-shadow: var(--shadow-sm);
        }
        .comm-sidebar {
            background: var(--surface-2);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }
        .channel-category-header {
            padding: 14px 18px 6px;
            font-family: var(--font-mono);
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.12em;
            color: var(--navy);
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .channel-link {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px 18px;
            color: var(--ink);
            text-decoration: none !important;
            font-size: 13px;
            font-weight: 500;
            border-left: 3px solid transparent;
            transition: all 0.12s ease;
        }
        .channel-link:hover {
            background: rgba(21, 43, 68, 0.05);
            color: var(--navy);
        }
        .channel-link.active {
            background: #FFFFFF;
            color: var(--navy);
            font-weight: 700;
            border-left-color: var(--accent-2);
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
        .channel-badge-hash {
            font-family: var(--font-mono);
            font-size: 14px;
            color: var(--accent-2);
            font-weight: 700;
        }
        .channel-badge-evt {
            font-size: 11px;
            color: #4338CA;
            background: #EEF2FF;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: 600;
        }
        .comm-main {
            display: flex;
            flex-direction: column;
            background: #FFFFFF;
            height: 100%;
            overflow: hidden;
        }
        .comm-header {
            padding: 16px 24px;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--surface);
        }
        .comm-messages-list {
            flex: 1;
            padding: 24px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .msg-card {
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }
        .msg-avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: var(--navy);
            color: #FFFFFF;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
            flex-shrink: 0;
        }
        .msg-body-wrapper {
            flex: 1;
            background: var(--surface-2);
            padding: 12px 16px;
            border-radius: 4px;
            border: 1px solid var(--border);
        }
        .msg-author-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 4px;
            flex-wrap: wrap;
        }
        .msg-author-name {
            font-weight: 700;
            color: var(--navy);
            font-size: 13.5px;
        }
        .msg-time {
            font-size: 11px;
            color: var(--muted);
            font-family: var(--font-mono);
            margin-left: auto;
        }
        .msg-text {
            font-size: 13.5px;
            line-height: 1.55;
            color: var(--ink);
        }
        .comm-composer {
            padding: 16px 24px;
            border-top: 1px solid var(--border);
            background: var(--surface);
        }
        .toast-notification {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            background: #ECFDF5;
            border: 1px solid #A7F3D0;
            border-radius: 4px;
            margin-bottom: 18px;
            color: #065F46;
        }
    </style>
</head>
<body>

<% if (currentUser == null) { %>
    <%@ include file="includes/navbar.jsp" %>
    <div class="container" style="max-width: 1280px; margin: 0 auto; padding: 30px 20px;">
<% } else { %>
<div class="app-shell">
    <%@ include file="includes/app_header.jsp" %>
    <div class="app-body">
        <%@ include file="includes/sidebar.jsp" %>
        <main class="app-main">
            <div class="app-content">
<% } %>

        <!-- TOAST STATUS -->
        <% if ("envoye".equals(msgStatus)) { %>
            <div class="toast-notification" id="appToast">
                <div style="font-size: 18px;">✓</div>
                <div>
                    <strong style="font-size: 13.5px;">Message diffusé avec succès !</strong>
                    <div style="font-size: 12px; opacity: 0.9;">Votre intervention est enregistrée et visible pour tous les membres du canal.</div>
                </div>
            </div>
        <% } %>

        <!-- EN-TÊTE ÉDITORIAL OFFICIEL -->
        <div class="page-header" style="margin-bottom: 18px;">
            <div>
                <span class="eyebrow" style="color: var(--accent-2);">Collaboration Scientifique & Réseau Interne</span>
                <h1 class="page-title">Communication Interne</h1>
                <p class="page-sub">
                    Plateforme collaborative officielle du laboratoire LIAS structurée en 3 espaces : discussions entre membres, échanges par équipe de recherche, et coordination autour des événements.
                </p>
            </div>
        </div>

        <!-- LAYOUT DE COMMUNICATION (CANAUX + FIL DE DISCUSSION) -->
        <div class="comm-layout">
            
            <!-- ========================================================================= -->
            <!-- SIDEBAR DES CANAUX (3 FAMILLES )                               -->
            <!-- ========================================================================= -->
            <div class="comm-sidebar">
                
                <!-- 1. Discussions entre membres -->
                <div class="channel-category-header">
                    <span>👥</span> Discussions entre membres
                </div>
                <a href="<%= request.getContextPath() %>/communication?canal=general" 
                   class="channel-link <%= "general".equals(activeCanal) ? "active" : "" %>">
                    <span class="channel-badge-hash">#</span>
                    <span>Général & Direction</span>
                </a>
                <a href="<%= request.getContextPath() %>/communication?canal=theses" 
                   class="channel-link <%= "theses".equals(activeCanal) ? "active" : "" %>">
                    <span class="channel-badge-hash">#</span>
                    <span>Doctorants & Thèses</span>
                </a>

                <!-- 2. Échanges par équipe -->
                <div class="channel-category-header" style="margin-top: 14px;">
                    <span>🔬</span> Échanges par équipe
                </div>
                <a href="<%= request.getContextPath() %>/communication?canal=team_ia" 
                   class="channel-link <%= "team_ia".equals(activeCanal) ? "active" : "" %>">
                    <span class="channel-badge-hash">#</span>
                    <span>Équipe IA (NLP & Vision)</span>
                </a>
                <a href="<%= request.getContextPath() %>/communication?canal=team_bigdata" 
                   class="channel-link <%= "team_bigdata".equals(activeCanal) || "team_dscc".equals(activeCanal) ? "active" : "" %>">
                    <span class="channel-badge-hash">#</span>
                    <span>Équipe Big Data & DS</span>
                </a>
                <a href="<%= request.getContextPath() %>/communication?canal=team_securite" 
                   class="channel-link <%= "team_securite".equals(activeCanal) ? "active" : "" %>">
                    <span class="channel-badge-hash">#</span>
                    <span>Équipe Cybersécurité</span>
                </a>
                <a href="<%= request.getContextPath() %>/communication?canal=team_systemes" 
                   class="channel-link <%= "team_systemes".equals(activeCanal) || "team_msi".equals(activeCanal) ? "active" : "" %>">
                    <span class="channel-badge-hash">#</span>
                    <span>Équipe Cloud & Systèmes</span>
                </a>

                <!-- 3. Discussions liées aux événements -->
                <div class="channel-category-header" style="margin-top: 14px;">
                    <span>🎙️</span> Discussions liées aux événements
                </div>
                <% if (evenementsList != null && !evenementsList.isEmpty()) {
                    for (Evenement ev : evenementsList) {
                        String evCanalId = "event_" + ev.getId();
                        String shortTitle = ev.getTitre();
                        if (shortTitle.length() > 28) shortTitle = shortTitle.substring(0, 26) + "...";
                %>
                    <a href="<%= request.getContextPath() %>/communication?canal=<%= evCanalId %>" 
                       class="channel-link <%= evCanalId.equals(activeCanal) ? "active" : "" %>"
                       title="<%= ev.getType() %> : <%= ev.getTitre() %> (<%= ev.getDate() %>)">
                        <span class="channel-badge-evt"><%= ev.getType() != null ? ev.getType().substring(0, Math.min(4, ev.getType().length())) : "Evt" %></span>
                        <span><%= shortTitle %></span>
                    </a>
                <%  }
                } else { %>
                    <div style="padding: 6px 18px; font-size: 11px; color: var(--muted); font-style: italic;">
                        Aucun événement actif.
                    </div>
                <% } %>

                <div style="margin-top: auto; padding: 14px 16px; border-top: 1px solid var(--border); font-size: 11.5px; color: var(--muted); line-height: 1.4; background: rgba(255,255,255,0.5);">
                    🔒 <strong>Archivage interne :</strong> L'ensemble des messages et pièces échangées demeurent conservés dans la mémoire du laboratoire.
                </div>
            </div>

            <!-- ========================================================================= -->
            <!-- FIL CENTRAL DES MESSAGES DU CANAL SÉLECTIONNÉ                             -->
            <!-- ========================================================================= -->
            <div class="comm-main">
                <!-- En-tête du canal actif -->
                <div class="comm-header">
                    <div>
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span style="color: var(--accent-2); font-family: var(--font-mono); font-size: 18px; font-weight: 700;">#</span>
                            <h3 style="font-size: 17px; margin: 0; color: var(--navy); font-family: var(--font-serif);">
                                <%= canalTitre %>
                            </h3>
                            <% if ("membres".equals(canalType)) { %>
                                <span class="badge badge-navy" style="font-size: 10px;">👥 Discussions entre membres</span>
                            <% } else if ("equipe".equals(canalType)) { %>
                                <span class="badge badge-secondary" style="font-size: 10px;">🔬 Échanges par équipe</span>
                            <% } else if ("evenement".equals(canalType)) { %>
                                <span class="badge badge-outline" style="font-size: 10px; color: #4338CA; border-color: #A5B4FC;">🎙️ Discussion liée à l'événement</span>
                            <% } %>
                        </div>
                        <p style="font-size: 12px; color: var(--muted); margin: 3px 0 0;">
                            <%= canalDesc %>
                        </p>
                    </div>
                    <span class="badge badge-navy"><%= messages != null ? messages.size() : 0 %> messages</span>
                </div>

                <!-- Liste des messages -->
                <div class="comm-messages-list" id="messagesContainer">
                    <%
                        if (messages != null && !messages.isEmpty()) {
                            for (MessageCommunication m : messages) {
                                String initials = "LI";
                                if (m.getAuteurNom() != null && m.getAuteurNom().trim().length() > 0) {
                                    String[] parts = m.getAuteurNom().trim().split("\\s+");
                                    if (parts.length >= 2) {
                                        initials = ("" + parts[0].charAt(0) + parts[1].charAt(0)).toUpperCase();
                                    } else {
                                        initials = m.getAuteurNom().substring(0, Math.min(2, m.getAuteurNom().length())).toUpperCase();
                                    }
                                }
                    %>
                    <div class="msg-card">
                        <div class="msg-avatar"><%= initials %></div>
                        <div class="msg-body-wrapper">
                            <div class="msg-author-header">
                                <span class="msg-author-name"><%= m.getAuteurNom() %></span>
                                <span class="badge badge-navy" style="font-size: 10px; padding: 2px 6px;">
                                    <%= m.getAuteurRole() != null ? m.getAuteurRole() : "Membre" %>
                                </span>
                                <span class="msg-time"><%= m.getDateEnvoi() %></span>
                            </div>
                            <div class="msg-text">
                                <%= m.getMessage() %>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div style="margin: auto; text-align: center; color: var(--muted); padding: 40px 20px;">
                        <div style="font-size: 32px; margin-bottom: 8px;">💬</div>
                        <strong style="color: var(--navy); font-size: 15px;">Aucun message pour l'instant sur ce canal</strong>
                        <p style="font-size: 13px; margin: 4px 0 0;">Soyez le premier membre à lancer la discussion !</p>
                    </div>
                    <% } %>
                </div>

                <!-- Compositeur de message -->
                <div class="comm-composer">
                    <% if (currentUser != null) { %>
                        <form action="<%= request.getContextPath() %>/communication" method="POST" style="display: flex; gap: 12px; align-items: flex-end;">
                            <input type="hidden" name="canalId" value="<%= activeCanal %>">
                            <div style="flex: 1;">
                                <div style="font-size: 11px; color: var(--muted); margin-bottom: 4px; display: flex; justify-content: space-between;">
                                    <span>Publier en tant que : <strong><%= currentUser.getPrenom() %> <%= currentUser.getNom() %></strong> (<%= currentUser.getRole() %>)</span>
                                    <span>Canal : <code>#<%= activeCanal %></code></span>
                                </div>
                                <textarea name="message" class="form-control" rows="2" 
                                          placeholder="Écrire un message aux membres du canal #<%= activeCanal %>... (Appuyez sur Envoyer)" required></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary" style="height: 52px; padding: 0 20px; font-weight: 600;">
                                Envoyer ✈
                            </button>
                        </form>
                    <% } else { %>
                        <div style="text-align: center; padding: 12px; font-size: 13px; color: var(--muted); background: var(--surface-2); border-radius: 4px;">
                            🔒 Vous devez être <a href="<%= request.getContextPath() %>/login" style="color: var(--navy); font-weight: 600;">connecté</a> pour participer aux échanges internes du laboratoire.
                        </div>
                    <% } %>
                </div>

            </div>

        </div>

<% if (currentUser == null) { %>
    </div>
    <%@ include file="includes/footer.jsp" %>
<% } else { %>
            </div>
        </main>
    </div>
</div>
<% } %>

    <script>
        // Auto-scroll vers le dernier message
        window.addEventListener('DOMContentLoaded', function() {
            var container = document.getElementById('messagesContainer');
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        });
    </script>
</body>
</html>

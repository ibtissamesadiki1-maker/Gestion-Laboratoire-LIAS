<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.NotificationLabo"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    String userRole = currentUser != null && currentUser.getRole() != null ? currentUser.getRole().toLowerCase() : "visiteur";
    boolean isAdmin = "admin".equals(userRole);
    boolean isDirector = "directeur".equals(userRole);
    boolean isPermanent = "permanent".equals(userRole);
    boolean isInternalUser = isDirector || isPermanent;
    boolean canBroadcast = isDirector || isAdmin || isPermanent;

    List<NotificationLabo> notifs = (List<NotificationLabo>) request.getAttribute("notifications");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    if (totalCount == null) totalCount = (notifs != null ? notifs.size() : 0);
    Integer unreadCount = (Integer) request.getAttribute("unreadCount");
    if (unreadCount == null) unreadCount = 0;
    Integer countEvents = (Integer) request.getAttribute("countEvents");
    if (countEvents == null) countEvents = 0;
    Integer countValidations = (Integer) request.getAttribute("countValidations");
    if (countValidations == null) countValidations = 0;
    Integer countDocs = (Integer) request.getAttribute("countDocs");
    if (countDocs == null) countDocs = 0;

    String activeFilter = (String) request.getAttribute("activeFilter");
    if (activeFilter == null) activeFilter = "toutes";

    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Centre de Notifications</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        .notif-tab {
            padding: 8px 16px;
            background: transparent;
            border: 1px solid var(--border-color, #E5E7EB);
            border-radius: 4px;
            font-family: 'Inter', sans-serif;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted, #6B7280);
            text-decoration: none;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.15s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .notif-tab:hover {
            color: var(--navy-primary, #0B192C);
            background: #F8FAFC;
        }
        .notif-tab.active {
            background: var(--navy-primary, #0B192C);
            color: #FFFFFF;
            border-color: var(--navy-primary, #0B192C);
        }
        .notif-card {
            display: grid;
            grid-template-columns: auto 1fr auto;
            gap: 16px;
            align-items: center;
            padding: 18px 22px;
            background: #FFFFFF;
            border: 1px solid var(--border-color, #E5E7EB);
            border-radius: 6px;
            margin-bottom: 12px;
            transition: all 0.2s ease;
        }
        .notif-card.unread {
            background: #FAFCFF;
            border-left: 4px solid var(--navy-primary, #0B192C);
        }
        .notif-card:hover {
            box-shadow: 0 4px 12px rgba(11, 25, 44, 0.05);
            transform: translateY(-1px);
        }
        .notif-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }
        .circle-event { background: #FFFBEB; color: #B45309; border: 1px solid #FDE68A; }
        .circle-validation { background: #EEF2FF; color: #4338CA; border: 1px solid #C7D2FE; }
        .circle-doc { background: #F0FDF4; color: #15803D; border: 1px solid #BBF7D0; }
        .circle-pub { background: #FDF2F8; color: #BE185D; border: 1px solid #FBCFE8; }

        .notif-kind-badge {
            font-size: 10px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>

<div class="app-shell">
    <%@ include file="includes/app_header.jsp" %>
    <div class="app-body">
        <%@ include file="includes/sidebar.jsp" %>
        <main class="app-main">
            <div class="app-content">

                <!-- Alert Feedback -->
                <% if ("tout_lu".equals(msg)) { %>
                    <div class="alert alert-success" style="background:#ECFDF5; border-right:4px solid #059669; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#065F46; font-size:13.5px;">
                        ✓ Toutes les notifications ont été marquées comme lues.
                    </div>
                <% } else if ("lu".equals(msg)) { %>
                    <div class="alert alert-success" style="background:#ECFDF5; border-right:4px solid #059669; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#065F46; font-size:13.5px;">
                        ✓ La notification sélectionnée a été marquée comme consultée.
                    </div>
                <% } else if ("cree".equals(msg)) { %>
                    <div class="alert alert-success" style="background:#ECFDF5; border-right:4px solid #059669; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#065F46; font-size:13.5px;">
                        ✓ Notification diffusée avec succès à l'ensemble des membres du laboratoire.
                    </div>
                <% } else if ("supprime".equals(msg)) { %>
                    <div class="alert alert-info" style="background:#EFF6FF; border-right:4px solid #3B82F6; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#1E40AF; font-size:13.5px;">
                        ✓ Notification supprimée de votre fil d'actualité.
                    </div>
                <% } %>

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <span class="eyebrow" style="color:var(--gold-accent); font-weight:700;">
                            <%= isAdmin ? "Administration Système · Audit &amp; Sécurité" : "Système d'Information &amp; Alertes" %>
                        </span>
                        <h1 class="page-title">
                            <%= isAdmin ? "Centre d'Audit &amp; Notifications Système" : "Centre de Notifications" %>
                        </h1>
                        <p class="page-sub">
                            <% if (isAdmin) { %>
                                Surveillance en temps réel des <strong>accès système</strong>, de l'<strong>intégrité des données</strong> et des <strong>alertes d'administration</strong> du LIAS.
                            <% } else { %>
                                Surveillance en temps réel des <strong>événements scientifiques</strong>, <strong>validations de demandes</strong> et <strong>ajouts de documents</strong> officiels du LIAS.
                            <% } %>
                        </p>
                    </div>
                    <div style="display:flex; gap:10px; flex-wrap:wrap;">
                        <% if (canBroadcast) { %>
                            <button type="button" class="btn btn-primary" onclick="document.getElementById('modalBroadcast').style.display='flex'">
                                <%= isAdmin ? "+ Diffuser une Alerte Système" : "+ Diffuser une Alerte" %>
                            </button>
                        <% } %>
                        <a href="<%= request.getContextPath() %>/notifications?action=mark_all_read" class="btn btn-secondary">
                            ✓ Tout marquer comme lu
                        </a>
                    </div>
                </div>

                <!-- Stat Cards -->
                <% if (isAdmin) { %>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px;">
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid var(--navy-primary);">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Flux Total Système</div>
                        <div style="font-size: 28px; font-weight: 800; color: var(--navy-primary); margin-top: 4px;"><%= totalCount %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Notifications &amp; événements</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #DC2626;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Non Lues</div>
                        <div style="font-size: 28px; font-weight: 800; color: #DC2626; margin-top: 4px;"><%= unreadCount %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">En attente de consultation</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #0284C7;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">🛡️ Sécurité &amp; RBAC</div>
                        <div style="font-size: 22px; font-weight: 800; color: #0284C7; margin-top: 4px;">CONFORME</div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Contrôle d'accès strict actif</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #059669;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">💾 Intégrité Base SQL</div>
                        <div style="font-size: 22px; font-weight: 800; color: #059669; margin-top: 4px;">100% INTÈGRE</div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Schéma MySQL 8.0 synchronisé</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #D97706;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">⚡ Serveur Tomcat</div>
                        <div style="font-size: 22px; font-weight: 800; color: #D97706; margin-top: 4px;">EN LIGNE</div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Port 8080 · Java 21</div>
                    </div>
                </div>
                <% } else if (!isInternalUser) { %>
                <!-- STAT CARDS DOCTORANT / ASSOCIÉ -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px;">
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid var(--navy-primary);">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Flux Scientifique</div>
                        <div style="font-size: 28px; font-weight: 800; color: var(--navy-primary); margin-top: 4px;"><%= countEvents %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Manifestations scientifiques</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #DC2626;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Non Lues</div>
                        <div style="font-size: 28px; font-weight: 800; color: #DC2626; margin-top: 4px;"><%= unreadCount %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">En attente de consultation</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #B45309;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">📅 Événements &amp; Séminaires</div>
                        <div style="font-size: 28px; font-weight: 800; color: #B45309; margin-top: 4px;"><%= countEvents %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Conférences, ateliers &amp; thèses</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #059669;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">🎓 Espace Recherche</div>
                        <div style="font-size: 22px; font-weight: 800; color: #059669; margin-top: 4px;">ACTIF</div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Publications &amp; Agenda ouverts</div>
                    </div>
                </div>
                <% } else { %>
                <!-- STAT CARDS PERMANENTS & DIRECTION -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px;">
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid var(--navy-primary);">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Flux Total</div>
                        <div style="font-size: 28px; font-weight: 800; color: var(--navy-primary); margin-top: 4px;"><%= totalCount %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Notifications enregistrées</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #DC2626;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Non Lues</div>
                        <div style="font-size: 28px; font-weight: 800; color: #DC2626; margin-top: 4px;"><%= unreadCount %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">En attente de consultation</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #B45309;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">📅 Événements Scientifiques</div>
                        <div style="font-size: 28px; font-weight: 800; color: #B45309; margin-top: 4px;"><%= countEvents %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Conférences, séminaires &amp; conseils</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #4338CA;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">✓ Validation des Demandes</div>
                        <div style="font-size: 28px; font-weight: 800; color: #4338CA; margin-top: 4px;"><%= countValidations %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Adhésions &amp; besoins en matériel</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #15803D;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">📁 Archives Documentaires</div>
                        <div style="font-size: 28px; font-weight: 800; color: #15803D; margin-top: 4px;"><%= countDocs %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Archives, PV scellés &amp; rapports</div>
                    </div>
                </div>
                <% } %>

                <!-- FILTER TABS -->
                <div style="display: flex; gap: 8px; margin-bottom: 22px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px; overflow-x: auto;">
                    <a href="<%= request.getContextPath() %>/notifications?filter=toutes" class="notif-tab <%= "toutes".equalsIgnoreCase(activeFilter) ? "active" : "" %>">
                        <span>Toutes</span>
                        <span class="badge" style="background:rgba(0,0,0,0.1); font-weight:700;">(<%= isInternalUser ? totalCount : countEvents %>)</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/notifications?filter=non lues" class="notif-tab <%= ("non lues".equalsIgnoreCase(activeFilter) || "unread".equalsIgnoreCase(activeFilter)) ? "active" : "" %>">
                        <span>Non lues</span>
                        <span class="badge" style="background:rgba(0,0,0,0.1); font-weight:700;">(<%= unreadCount %>)</span>
                    </a>
                    <% if (isInternalUser) { %>
                    <a href="<%= request.getContextPath() %>/notifications?filter=evenements" class="notif-tab <%= ("evenements".equalsIgnoreCase(activeFilter) || "event".equalsIgnoreCase(activeFilter)) ? "active" : "" %>">
                        <span>📅 Événements</span>
                        <span class="badge" style="background:rgba(0,0,0,0.1); font-weight:700;">(<%= countEvents %>)</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/notifications?filter=validations" class="notif-tab <%= ("validations".equalsIgnoreCase(activeFilter) || "validation".equalsIgnoreCase(activeFilter) || "demandes".equalsIgnoreCase(activeFilter)) ? "active" : "" %>">
                        <span>✓ Validations &amp; Demandes</span>
                        <span class="badge" style="background:rgba(0,0,0,0.1); font-weight:700;">(<%= countValidations %>)</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/notifications?filter=documents" class="notif-tab <%= ("documents".equalsIgnoreCase(activeFilter) || "document".equalsIgnoreCase(activeFilter)) ? "active" : "" %>">
                        <span>📁 Documents &amp; Archives</span>
                        <span class="badge" style="background:rgba(0,0,0,0.1); font-weight:700;">(<%= countDocs %>)</span>
                    </a>
                    <% } %>
                </div>

                <!-- NOTIFICATIONS FEED -->
                <div>
                    <% if (isAdmin) { %>
                        <!-- FLUX D'AUDIT TECHNIQUE & SÉCURITÉ SYSTÈME (ADMIN - ) -->
                        <div class="notif-card">
                            <div class="notif-circle" style="background:#ECFDF5; color:#059669; border:1px solid #A7F3D0;">
                                🛡️
                            </div>
                            <div>
                                <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
                                    <span class="notif-kind-badge" style="background:#ECFDF5; color:#059669; border:1px solid #A7F3D0;">
                                        SÉCURITÉ SYSTÈME
                                    </span>
                                </div>
                                <div style="font-size: 14px; color: var(--navy-primary); line-height: 1.5;">
                                    <strong>Administrateur Système</strong> Session super-utilisateur authentifiée avec succès sur Tomcat 10.1.
                                </div>
                                <div style="font-family: 'JetBrains Mono', monospace; font-size: 11.5px; color: var(--text-muted); margin-top: 4px;">
                                    🕒 À l'instant · IP Localhost · Rôle RBAC : admin
                                </div>
                            </div>
                            <div style="display: flex; gap: 8px; align-items: center; justify-content: flex-end;">
                                <a href="<%= request.getContextPath() %>/admin?tab=maint" class="btn btn-secondary btn-sm" style="font-size: 12px; padding: 6px 12px; white-space: nowrap;">
                                    Diagnostic JVM →
                                </a>
                            </div>
                        </div>

                        <div class="notif-card">
                            <div class="notif-circle" style="background:#EFF6FF; color:#0284C7; border:1px solid #BAE6FD;">
                                💾
                            </div>
                            <div>
                                <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
                                    <span class="notif-kind-badge" style="background:#EFF6FF; color:#0284C7; border:1px solid #BAE6FD;">
                                        INTÉGRITÉ BASE SQL
                                    </span>
                                </div>
                                <div style="font-size: 14px; color: var(--navy-primary); line-height: 1.5;">
                                    <strong>Moteur MySQL 8.0</strong> Schéma `lias_db` synchronisé, encodage UTF8MB4 vérifié et contraintes intègres.
                                </div>
                                <div style="font-family: 'JetBrains Mono', monospace; font-size: 11.5px; color: var(--text-muted); margin-top: 4px;">
                                    🕒 Aujourd'hui · Port 3307/3306 · Santé : Opérationnelle
                                </div>
                            </div>
                            <div style="display: flex; gap: 8px; align-items: center; justify-content: flex-end;">
                                <a href="<%= request.getContextPath() %>/admin?tab=integrity" class="btn btn-secondary btn-sm" style="font-size: 12px; padding: 6px 12px; white-space: nowrap;">
                                    Vérifier l'intégrité →
                                </a>
                            </div>
                        </div>

                        <div class="notif-card">
                            <div class="notif-circle" style="background:#FFFBEB; color:#D97706; border:1px solid #FDE68A;">
                                👥
                            </div>
                            <div>
                                <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
                                    <span class="notif-kind-badge" style="background:#FFFBEB; color:#D97706; border:1px solid #FDE68A;">
                                        GESTION DES COMPTES
                                    </span>
                                </div>
                                <div style="font-size: 14px; color: var(--navy-primary); line-height: 1.5;">
                                    <strong>Contrôle RBAC</strong> 8 comptes utilisateurs actifs avec séparation stricte (Admin technique vs Direction métier).
                                </div>
                                <div style="font-family: 'JetBrains Mono', monospace; font-size: 11.5px; color: var(--text-muted); margin-top: 4px;">
                                    🕒 Aujourd'hui · Table `users`
                                </div>
                            </div>
                            <div style="display: flex; gap: 8px; align-items: center; justify-content: flex-end;">
                                <a href="<%= request.getContextPath() %>/admin" class="btn btn-secondary btn-sm" style="font-size: 12px; padding: 6px 12px; white-space: nowrap;">
                                    Gérer les comptes →
                                </a>
                            </div>
                        </div>

                        <div class="notif-card">
                            <div class="notif-circle" style="background:#F5F3FF; color:#7C3AED; border:1px solid #DDD6FE;">
                                ⚙️
                            </div>
                            <div>
                                <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
                                    <span class="notif-kind-badge" style="background:#F5F3FF; color:#7C3AED; border:1px solid #DDD6FE;">
                                        MAINTENANCE SERVEUR
                                    </span>
                                </div>
                                <div style="font-size: 14px; color: var(--navy-primary); line-height: 1.5;">
                                    <strong>Apache Tomcat 10.1</strong> Runtime Java 21 en ligne sans erreur bloquante.
                                </div>
                                <div style="font-family: 'JetBrains Mono', monospace; font-size: 11.5px; color: var(--text-muted); margin-top: 4px;">
                                    🕒 Il y a 2 heures · Conteneur `lias-app`
                                </div>
                            </div>
                            <div style="display: flex; gap: 8px; align-items: center; justify-content: flex-end;">
                                <a href="<%= request.getContextPath() %>/admin?tab=param" class="btn btn-secondary btn-sm" style="font-size: 12px; padding: 6px 12px; white-space: nowrap;">
                                    Paramètres système →
                                </a>
                            </div>
                        </div>

                    <% } else { %>
                        <!-- FLUX DE NOTIFICATIONS ACADÉMIQUES (DIRECTEUR, CHERCHEURS, DOCTORANTS) -->
                        <% if (notifs == null || notifs.isEmpty()) { %>
                            <div class="card" style="padding: 48px 24px; text-align: center; color: var(--text-muted);">
                                <div style="font-size: 32px; margin-bottom: 12px;">🔔</div>
                                <h3 style="color: var(--navy-primary); margin-bottom: 6px;">Aucune notification</h3>
                                <p style="font-size: 13.5px; margin: 0;">Aucun message ou alerte ne correspond au filtre « <%= activeFilter %> ».</p>
                            </div>
                        <% } else { %>
                            <% for (NotificationLabo n : notifs) { 
                                String k = n.getKind() != null ? n.getKind().toLowerCase() : "";
                                
                                // C : Les doctorants et associés ne reçoivent pas les notifications des modules internes
                                if (!isInternalUser && !("event".equals(k) || "meeting".equals(k) || "publication".equals(k) || "info".equals(k) || "system".equals(k))) {
                                    continue;
                                }

                                String circleClass = "circle-validation";
                                String icon = "✓";
                                String badgeLabel = "VALIDATION";
                                String badgeStyle = "background:#EEF2FF; color:#4338CA; border:1px solid #C7D2FE;";

                                if ("event".equals(k) || "meeting".equals(k)) {
                                    circleClass = "circle-event";
                                    icon = "📅";
                                    badgeLabel = "ÉVÉNEMENT SCIENTIFIQUE";
                                    badgeStyle = "background:#FFFBEB; color:#B45309; border:1px solid #FDE68A;";
                                } else if ("document".equals(k) || "pv".equals(k) || "rapport".equals(k)) {
                                    circleClass = "circle-doc";
                                    icon = "📁";
                                    badgeLabel = "DOCUMENT OFFICIEL";
                                    badgeStyle = "background:#F0FDF4; color:#15803D; border:1px solid #BBF7D0;";
                                } else if ("publication".equals(k)) {
                                    circleClass = "circle-pub";
                                    icon = "📚";
                                    badgeLabel = "PUBLICATION";
                                    badgeStyle = "background:#FDF2F8; color:#BE185D; border:1px solid #FBCFE8;";
                                } else if ("materiel".equals(k) || "adhesion".equals(k)) {
                                    circleClass = "circle-validation";
                                    icon = "✓";
                                    badgeLabel = "DEMANDE & ARBITRAGE";
                                    badgeStyle = "background:#EEF2FF; color:#4338CA; border:1px solid #C7D2FE;";
                                }
                            %>
                                <div class="notif-card <%= !n.isRead() ? "unread" : "" %>">
                                    <div class="notif-circle <%= circleClass %>">
                                        <%= icon %>
                                    </div>
                                    <div>
                                        <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
                                            <span class="notif-kind-badge" style="<%= badgeStyle %>">
                                                <%= badgeLabel %>
                                            </span>
                                            <% if (!n.isRead()) { %>
                                                <span style="font-size:10px; font-weight:800; color:#DC2626; text-transform:uppercase; letter-spacing:0.5px;">● NON LUE</span>
                                            <% } %>
                                        </div>
                                        <div style="font-size: 14px; color: var(--navy-primary); line-height: 1.5;">
                                            <strong><%= n.getWho() %></strong> <%= n.getBody() %>
                                        </div>
                                        <div style="font-family: 'JetBrains Mono', monospace; font-size: 11.5px; color: var(--text-muted); margin-top: 4px;">
                                            🕒 <%= n.getWhenText() %>
                                        </div>
                                    </div>
                                    <div style="display: flex; gap: 8px; align-items: center; justify-content: flex-end;">
                                        <% if (n.getTargetUrl() != null && !n.getTargetUrl().trim().isEmpty()) { %>
                                            <a href="<%= request.getContextPath() %><%= n.getTargetUrl() %>" class="btn btn-secondary btn-sm" style="font-size: 12px; padding: 6px 12px; white-space: nowrap;">
                                                <%= n.getActionLabel() != null ? n.getActionLabel() : "Consulter →" %>
                                            </a>
                                        <% } %>
                                        <% if (!n.isRead()) { %>
                                            <a href="<%= request.getContextPath() %>/notifications?action=mark_read&id=<%= n.getId() %>" class="btn btn-ghost btn-sm" style="font-size: 11px; padding: 4px 8px;" title="Marquer comme lu">
                                                ✓ Vu
                                            </a>
                                        <% } %>
                                    </div>
                                </div>
                            <% } %>
                        <% } %>
                    <% } %>
                </div>

            </div>
        </main>
    </div>
</div>

<!-- MODAL DIFFUSER NOTIFICATION -->
<% if (canBroadcast) { %>
<div id="modalBroadcast" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.6); z-index:9999; align-items:center; justify-content:center; backdrop-filter:blur(3px); padding:20px;">
    <div class="card" style="width: 100%; max-width: 540px; padding: 28px; background: #FFF; border-radius: 8px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 18px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
            <div>
                <span style="font-size: 11px; text-transform: uppercase; color: var(--gold-accent); font-weight: 700;">Centre de Notifications</span>
                <h3 style="margin:2px 0 0; font-size: 18px; font-weight: 800; color: var(--navy-primary);">Diffuser une Alerte / Notification</h3>
            </div>
            <button type="button" onclick="document.getElementById('modalBroadcast').style.display='none'" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-muted);">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/notifications" method="POST">
            <input type="hidden" name="action" value="creer_notification">

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-weight:700; font-size:12px;">Catégorie *</label>
                <select name="kind" class="form-control" required>
                    <% if (isAdmin) { %>
                        <option value="system">Alerte &amp; Maintenance Système</option>
                        <option value="security">Sécurité &amp; Intégrité</option>
                        <option value="info">Communication Technique</option>
                    <% } else { %>
                        <option value="event">Événement Scientifique / Réunion</option>
                        <option value="validation">Validation de Demande / Arbitrage</option>
                        <option value="document">Ajout de Document / PV Archivé</option>
                        <option value="publication">Publication Scientifique</option>
                    <% } %>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-weight:700; font-size:12px;">Émetteur / Source *</label>
                <input type="text" name="who" class="form-control" value="<%= isAdmin ? "Administration Système LIAS" : "Direction du Laboratoire LIAS" %>" required>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-weight:700; font-size:12px;">Corps de la Notification / Message *</label>
                <textarea name="body" class="form-control" rows="3" placeholder="Texte de l'alerte ou de la communication officielle..." required></textarea>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 22px;">
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Texte du Bouton</label>
                    <input type="text" name="actionLabel" class="form-control" value="Consulter →">
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Lien de Redirection</label>
                    <input type="text" name="targetUrl" class="form-control" value="/calendrier">
                </div>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="document.getElementById('modalBroadcast').style.display='none'">Annuler</button>
                <button type="submit" class="btn btn-primary">Envoyer la Notification</button>
            </div>
        </form>
    </div>
</div>
<% } %>

</body>
</html>

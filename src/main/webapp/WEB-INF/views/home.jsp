<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.User"%>
<%@ page import="com.lias.beans.Evenement"%>
<%@ page import="com.lias.beans.DemandeAdhesion"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String userRole = currentUser != null && currentUser.getRole() != null ? currentUser.getRole().toLowerCase() : "visiteur";
    boolean isAdmin = "admin".equals(userRole);
    boolean isDirector = "directeur".equals(userRole);
    boolean isPermanent = "permanent".equals(userRole);
    boolean isDoctorant = "doctorant".equals(userRole);
    boolean isAssocie = "associe".equals(userRole);
    boolean hasInternal = isDirector || isPermanent;
    request.setAttribute("activeNav", "dashboard");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Tableau de bord institutionnel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        .gov-tile {
            background: var(--surface-2);
            border: 1px solid var(--border);
            padding: 12px 14px;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        }
        .gov-tile-label {
            font-family: var(--font-mono);
            font-size: 10px;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: var(--muted);
            margin-bottom: 3px;
        }
        .gov-tile-name {
            font-family: var(--font-serif);
            font-size: 14.5px;
            font-weight: 600;
            color: var(--ink);
        }
        .mandate-track {
            position: relative;
            height: 8px;
            background: var(--surface-2);
            border: 1px solid var(--border);
            margin: 12px 0 8px;
            border-radius: 9999px;
            overflow: hidden;
        }
        .mandate-fill {
            height: 100%;
            background: linear-gradient(90deg, #0284C7, #0D9488);
            border-radius: 9999px;
            width: 58%;
        }
        .report-line {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-top: 1px solid var(--border);
            font-size: 13px;
        }
    </style>
</head>
<body>

<div class="app-shell">
    <!-- Top Sticky Header -->
    <%@ include file="includes/app_header.jsp" %>

    <div class="app-body">
        <!-- Left Sidebar Navigation -->
        <%@ include file="includes/sidebar.jsp" %>

        <!-- Main Workspace -->
        <main class="app-main">
            <div class="app-content">

                <!-- Header Welcome Section -->
                <div>
                    <div class="eyebrow" style="margin-bottom: 6px;">
                        <% if (isAdmin) { %>
                            ADMINISTRATION SYSTÈME · GESTION TECHNIQUE
                        <% } else if (isDoctorant) { %>
                            ESPACE PERSONNEL DOCTORANT
                        <% } else if (isAssocie) { %>
                            ESPACE CHERCHEUR ASSOCIÉ
                        <% } else if (isDirector) { %>
                            DIRECTION DU LABORATOIRE · MANDAT EN COURS
                        <% } else { %>
                            MEMBRE PERMANENT · RECHERCHE &amp; GOUVERNANCE
                        <% } %>
                    </div>
                    <h1 style="font-size: 38px; font-weight: 500; margin: 0 0 6px; letter-spacing: -0.015em;">
                        Bonjour, <%= currentUser != null ? currentUser.getPrenom() + " " + currentUser.getNom() : "" %>.
                    </h1>
                    <p style="font-family: var(--font-serif); font-style: italic; font-size: 18px; color: var(--muted); margin: 0 0 16px; line-height: 1.5;">
                        <% if (isAdmin) { %>
                            Supervision technique de la plateforme, maintenance du serveur, métriques de la base de données et gestion des comptes utilisateurs.
                        <% } else if (isDirector) { %>
                            Quatre demandes d'adhésion attendent votre arbitrage. Le rapport annuel 2025–2026 est à 78 % de complétude.
                        <% } else if (isDoctorant) { %>
                            Accès personnel : vous pouvez consulter l'annuaire, suivre l'agenda et déclarer vos nouvelles publications scientifiques.
                        <% } else if (isAssocie) { %>
                            Bienvenue, collaborateur associé du LIAS. Vous pouvez consulter les travaux du laboratoire et participer aux événements.
                        <% } else { %>
                            Bienvenue sur la plateforme officielle de mémoire institutionnelle et de gestion du LIAS.
                        <% } %>
                    </p>
                </div>

                <!-- KPI Cards Strip -->
                <div class="stats-grid">
                    <% if (isAdmin) { %>
                        <div class="stat-card">
                            <div class="k">Comptes Utilisateurs</div>
                            <div class="v"><%= request.getAttribute("totalUsers") != null ? request.getAttribute("totalUsers") : "7" %></div>
                            <div class="s">Comptes RBAC configurés</div>
                        </div>
                        <div class="stat-card">
                            <div class="k">Mémoire JVM</div>
                            <div class="v" style="font-size: 24px; color: var(--accent-2);"><%= request.getAttribute("jvmUsedMem") != null ? request.getAttribute("jvmUsedMem") : "64 MB" %></div>
                            <div class="s">Allouée : <%= request.getAttribute("jvmTotalMem") != null ? request.getAttribute("jvmTotalMem") : "256 MB" %></div>
                        </div>
                        <div class="stat-card">
                            <div class="k">Membres Répertoire</div>
                            <div class="v"><%= request.getAttribute("totalMembres") != null ? request.getAttribute("totalMembres") : "7" %></div>
                            <div class="s">Dossiers académiques</div>
                        </div>
                        <div class="stat-card">
                            <div class="k">État Plateforme</div>
                            <div class="v" style="font-size: 22px; color: #059669;">OPÉRATIONNEL</div>
                            <div class="s">Système &amp; Base synchronisés</div>
                        </div>
                    <% } else { %>
                        <div class="stat-card">
                            <div class="k">Membres Actifs</div>
                            <div class="v"><%= request.getAttribute("totalMembres") != null ? request.getAttribute("totalMembres") : "7" %></div>
                            <div class="s">dont doctorants et associés</div>
                        </div>
                        <div class="stat-card">
                            <div class="k">Publications 2026</div>
                            <div class="v"><%= request.getAttribute("totalPublications") != null ? request.getAttribute("totalPublications") : "5" %></div>
                            <div class="s">Indexées Scopus &amp; DBLP</div>
                        </div>
                        <div class="stat-card">
                            <div class="k">Événements à Venir</div>
                            <div class="v"><%= request.getAttribute("totalEvenements") != null ? request.getAttribute("totalEvenements") : "6" %></div>
                            <div class="s">Prochains 6 mois</div>
                        </div>
                        <div class="stat-card">
                            <% if (isDirector) { %>
                                <div class="k">Demandes en Attente</div>
                                <div class="v" style="color: var(--accent-2);"><%= request.getAttribute("totalDemandes") != null ? request.getAttribute("totalDemandes") : "2" %></div>
                                <div class="s">À valider par la Direction</div>
                            <% } else if (isPermanent) { %>
                                <div class="k">Statut Profil</div>
                                <div class="v" style="font-size: 22px; color: var(--navy);">PERMANENT</div>
                                <div class="s">Enseignant-Chercheur actif</div>
                            <% } else { %>
                                <div class="k">Statut Profil</div>
                                <div class="v" style="font-size: 22px; color: var(--navy);"><%= isDoctorant ? "DOCTORANT" : "ASSOCIÉ" %></div>
                                <div class="s">Compte personnel vérifié</div>
                            <% } %>
                        </div>
                    <% } %>
                </div>

                <!-- 2-Column Main Layout Grid -->
                <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 24px; align-items: start;">

                    <!-- LEFT COLUMN -->
                    <div style="display: flex; flex-direction: column; gap: 24px;">

                        <% if (isAdmin) { %>
                        <!-- COCKPIT ADMINISTRATEUR SYSTÈME -->
                        <div class="card" style="border-left: 4px solid #0284C7; background: linear-gradient(135deg, rgba(2, 132, 199, 0.03) 0%, rgba(13, 148, 136, 0.04) 100%);">
                            <div style="display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px;">
                                <span class="eyebrow" style="color: #0284C7; font-weight: 700;">Administration Système · Gestion Technique</span>
                                <span class="badge badge-navy" style="font-size: 10px;">Super-Utilisateur</span>
                            </div>
                            <h3 style="font-size: 20px; margin: 0 0 8px; color: var(--navy);">Supervision &amp; Modules Techniques</h3>
                            <p style="font-size: 13.5px; color: var(--muted); margin: 0 0 16px;">
                                En tant qu'administrateur système, vous assurez la gestion technique de la plateforme et le paramétrage global :
                            </p>
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                                <a href="<%= request.getContextPath() %>/admin" style="padding: 12px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; text-decoration: none; color: inherit; display: block; transition: all 0.15s;">
                                    <div style="font-weight: 700; color: var(--navy); font-size: 13.5px; display: flex; justify-content: space-between; align-items: center;">
                                        <span>⚙️ 1. Comptes Utilisateurs</span>
                                        <span class="badge badge-gold" style="font-size: 10px;"><%= request.getAttribute("totalUsers") %> comptes</span>
                                    </div>
                                    <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">Création, rôles RBAC, activation &amp; désactivation</div>
                                </a>
                                <a href="<%= request.getContextPath() %>/admin?tab=param" style="padding: 12px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; text-decoration: none; color: inherit; display: block; transition: all 0.15s;">
                                    <div style="font-weight: 700; color: var(--navy); font-size: 13.5px;">🛠️ 2. Paramétrage Système</div>
                                    <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">Nom du laboratoire, quotas &amp; règles système</div>
                                </a>
                                <a href="<%= request.getContextPath() %>/admin?tab=maint" style="padding: 12px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; text-decoration: none; color: inherit; display: block; transition: all 0.15s;">
                                    <div style="font-weight: 700; color: var(--navy); font-size: 13.5px;">📊 3. Diagnostic &amp; Maintenance</div>
                                    <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">État JVM, mémoire vive &amp; intégrité serveur</div>
                                </a>
                                <a href="<%= request.getContextPath() %>/admin?tab=integrity" style="padding: 12px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; text-decoration: none; color: inherit; display: block; transition: all 0.15s;">
                                    <div style="font-weight: 700; color: var(--navy); font-size: 13.5px;">🛡️ 4. Règles &amp; Intégrité</div>
                                    <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">Mémoire institutionnelle &amp; historique complet</div>
                                </a>
                            </div>
                        </div>

                        <% } else if (isDirector) { %>
                        <!-- COCKPIT DU DIRECTEUR (MANDAT ACTIF) · -->
                        <div class="card" style="border-left: 4px solid var(--accent-2); background: linear-gradient(135deg, rgba(21, 43, 68, 0.03) 0%, rgba(184, 91, 53, 0.05) 100%);">
                            <div style="display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px;">
                                <span class="eyebrow" style="color: var(--accent-2); font-weight: 700;">Gouvernance Métier · Directeur en Mandat Actif</span>
                                <span class="badge badge-gold" style="font-size: 10px;">Mandat Actif</span>
                            </div>
                            <h3 style="font-size: 20px; margin: 0 0 8px; color: var(--navy);">Responsabilités &amp; Pilotage du Laboratoire</h3>
                            <p style="font-size: 13.5px; color: var(--muted); margin: 0 0 16px;">
                                En tant que responsable métier du LIAS, vous assurez la validation des flux institutionnels et le pilotage des obligations académiques :
                            </p>
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                                <a href="<%= request.getContextPath() %>/adhesions" style="padding: 12px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; text-decoration: none; color: inherit; display: block; transition: all 0.15s;">
                                    <div style="font-weight: 700; color: var(--navy); font-size: 13.5px; display: flex; justify-content: space-between; align-items: center;">
                                        <span>1. Validation des Adhésions</span>
                                        <% 
                                            Integer pAdhesions = (Integer) request.getAttribute("pendingAdhesionsCount");
                                            if (pAdhesions != null && pAdhesions > 0) { 
                                        %>
                                            <span class="badge badge-gold" style="font-size: 10px;"><%= pAdhesions %> en attente</span>
                                        <% } %>
                                    </div>
                                    <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">Arbitrage des dossiers doctorants &amp; associés avec CV</div>
                                </a>
                                <a href="<%= request.getContextPath() %>/materiel" style="padding: 12px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; text-decoration: none; color: inherit; display: block; transition: all 0.15s;">
                                    <div style="font-weight: 700; color: var(--navy); font-size: 13.5px;">2. Validation des Demandes</div>
                                    <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">Distribution équitable &amp; dotation en matériel</div>
                                </a>
                                <a href="<%= request.getContextPath() %>/evenements" style="padding: 12px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; text-decoration: none; color: inherit; display: block; transition: all 0.15s;">
                                    <div style="font-weight: 700; color: var(--navy); font-size: 13.5px;">3. Supervision des Événements</div>
                                    <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">Conférences, séminaires &amp; coordination des éditions</div>
                                </a>
                                <a href="<%= request.getContextPath() %>/rapport" style="padding: 12px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; text-decoration: none; color: inherit; display: block; transition: all 0.15s;">
                                    <div style="font-weight: 700; color: var(--navy); font-size: 13.5px;">4. Pilotage du Rapport Annuel</div>
                                    <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">Condition d'attribution du budget annuel de recherche</div>
                                </a>
                            </div>
                        </div>
                        <% } %>

                        <% if (isDirector || isPermanent) { %>
                        <!-- Card Mandat en cours (Direction & Permanents) -->
                        <div class="card" id="mandats">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px;">
                                <div>
                                    <div class="eyebrow" style="margin-bottom: 4px;">GOUVERNANCE · MANDAT EN COURS</div>
                                    <h3 style="font-size: 22px; margin: 0;">Mandat Actuel 2024 — 2028</h3>
                                </div>
                                <span class="badge badge-sage">ACTIF · EN COURS</span>
                            </div>

                            <div class="mandate-track">
                                <div class="mandate-fill" style="width: 45%;"></div>
                            </div>
                            <div style="display: flex; justify-content: space-between; font-family: var(--font-mono); font-size: 11px; color: var(--muted); margin-bottom: 18px;">
                                <span>sept. 2024</span>
                                <span>Exercice statutaire quadriennal</span>
                                <span>août 2028</span>
                            </div>

                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                                <div class="gov-tile">
                                    <div class="gov-tile-label">DIRECTRICE (MANDAT ACTIF)</div>
                                    <div class="gov-tile-name">Pr. Ibtissam Essadiki</div>
                                </div>
                                <div class="gov-tile">
                                    <div class="gov-tile-label">VICE-DIRECTRICE</div>
                                    <div class="gov-tile-name">Pr. Sara Benjelloun</div>
                                </div>
                                <div class="gov-tile">
                                    <div class="gov-tile-label">CHEF D'ÉQUIPE — IA &amp; VISION</div>
                                    <div class="gov-tile-name">Pr. Ibtissam Essadiki</div>
                                </div>
                                <div class="gov-tile">
                                    <div class="gov-tile-label">CHEF D'ÉQUIPE — BIG DATA</div>
                                    <div class="gov-tile-name">Pr. Sara Benjelloun</div>
                                </div>
                                <div class="gov-tile">
                                    <div class="gov-tile-label">CHEF D'ÉQUIPE — CYBERSÉCURITÉ</div>
                                    <div class="gov-tile-name">Pr. Karim Zouhair</div>
                                </div>
                                <div class="gov-tile">
                                    <div class="gov-tile-label">RESPONSABLE RECHERCHE — NLP</div>
                                    <div class="gov-tile-name">Dr. Amine Alami</div>
                                </div>
                            </div>
                            <div style="margin-top: 14px; padding-top: 12px; border-top: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; font-size: 12px;">
                                <a href="<%= request.getContextPath() %>/mandats" style="color: var(--accent-2); font-weight: 600; text-decoration: none;">Historique des mandats →</a>
                                <div style="display: flex; gap: 14px;">
                                    <a href="<%= request.getContextPath() %>/conventions" style="color: var(--navy); font-weight: 500; text-decoration: none;">Conventions</a>
                                    <a href="<%= request.getContextPath() %>/pv" style="color: var(--navy); font-weight: 500; text-decoration: none;">Procès-verbaux</a>
                                </div>
                            </div>
                        </div>
                        <% } else if (!isAdmin) { %>
                        <!-- Card Espace Publications Doctorant / Associé -->
                        <div class="card" style="border-left: 4px solid var(--accent-2);">
                            <div class="eyebrow" style="margin-bottom: 4px;">PRODUCTION SCIENTIFIQUE</div>
                            <h3 style="font-size: 22px; margin: 0 0 12px;">Espace Publications &amp; Thèse</h3>
                            <p style="font-family: var(--font-serif); font-size: 15px; color: var(--muted); line-height: 1.6; margin: 0 0 18px;">
                                En tant que <%= isDoctorant ? "doctorant" : "membre associé" %>, vous disposez d'un compte personnel vous permettant de consulter l'ensemble des travaux du laboratoire et de déclarer vos nouveaux articles, revues et communications indexées.
                            </p>
                            <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                                <a href="<%= request.getContextPath() %>/publications" class="btn btn-primary">+ Déclarer une publication</a>
                                <a href="<%= request.getContextPath() %>/profils" class="btn btn-secondary">Mon profil &amp; Annuaire</a>
                            </div>
                        </div>
                        <% } %>

                        <% if (isAdmin) { %>
                        <!-- Card Journal d'Audit & Sécurité Système (Admin) -->
                        <div class="card" style="padding: 0; overflow: hidden;">
                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 18px 24px; border-bottom: 1px solid var(--border);">
                                <div>
                                    <div class="eyebrow" style="margin-bottom: 2px;">SÉCURITÉ &amp; TRAÇABILITÉ</div>
                                    <h3 style="font-size: 18px; margin: 0;">Journal d'Audit &amp; Activités Système</h3>
                                </div>
                                <span class="badge badge-navy">Temps Réel</span>
                            </div>
                            <div style="display: flex; flex-direction: column;">
                                <div style="display: grid; grid-template-columns: 95px 1fr auto; gap: 16px; padding: 14px 24px; border-bottom: 1px solid var(--border); align-items: center;">
                                    <div style="font-family: var(--font-mono); font-size: 12px; color: var(--muted);">Aujourd'hui</div>
                                    <div>
                                        <div style="font-size: 14px; font-weight: 600; color: var(--ink);">Authentification Administrateur Système</div>
                                        <div style="font-size: 12px; color: var(--muted);">Session super-utilisateur active via admin@lias.ma</div>
                                    </div>
                                    <span class="badge badge-success">Succès</span>
                                </div>
                                <div style="display: grid; grid-template-columns: 95px 1fr auto; gap: 16px; padding: 14px 24px; border-bottom: 1px solid var(--border); align-items: center;">
                                    <div style="font-family: var(--font-mono); font-size: 12px; color: var(--muted);">2026-10-06</div>
                                    <div>
                                        <div style="font-size: 14px; font-weight: 600; color: var(--ink);">Intégrité &amp; Cohérence de la Base de Données</div>
                                        <div style="font-size: 12px; color: var(--muted);">Schéma SQL synchronisé et contraintes vérifiées</div>
                                    </div>
                                    <span class="badge badge-navy">100% Intègre</span>
                                </div>
                                <div style="display: grid; grid-template-columns: 95px 1fr auto; gap: 16px; padding: 14px 24px; align-items: center;">
                                    <div style="font-family: var(--font-mono); font-size: 12px; color: var(--muted);">2026-10-06</div>
                                    <div>
                                        <div style="font-size: 14px; font-weight: 600; color: var(--ink);">Contrôle des Privilèges d'Accès RBAC</div>
                                        <div style="font-size: 12px; color: var(--muted);">Séparation stricte des rôles : Direction / Admin / Chercheurs</div>
                                    </div>
                                    <span class="badge badge-gold">Sécurisé</span>
                                </div>
                            </div>
                        </div>

                        <% } else { %>
                        <!-- Card Agenda Scientifique (Chercheurs, Directeur, Doctorants) -->
                        <div class="card" style="padding: 0; overflow: hidden;" id="evenements">
                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 18px 24px; border-bottom: 1px solid var(--border);">
                                <div>
                                    <div class="eyebrow" style="margin-bottom: 2px;">AGENDA SCIENTIFIQUE</div>
                                    <h3 style="font-size: 18px; margin: 0;">Événements à venir</h3>
                                </div>
                                <span class="badge badge-muted">6 mois</span>
                            </div>
                            <div>
                                <%
                                    List<Evenement> events = (List<Evenement>) request.getAttribute("upcomingEvents");
                                    if (events != null && !events.isEmpty()) {
                                        int i = 0;
                                        for (Evenement ev : events) {
                                            if (++i > 4) break;
                                %>
                                <div style="display: grid; grid-template-columns: 85px 1fr auto; gap: 16px; padding: 14px 24px; border-bottom: 1px solid var(--border); align-items: center;">
                                    <div style="font-family: var(--font-mono); text-align: left;">
                                        <div style="font-size: 13px; font-weight: 600; color: var(--ink);"><%= ev.getDate() != null ? ev.getDate().toString() : "2026-06" %></div>
                                        <div style="font-size: 11px; color: var(--muted);">2026</div>
                                    </div>
                                    <div>
                                        <div style="font-family: var(--font-serif); font-size: 15px; font-weight: 500; color: var(--ink);"><%= ev.getTitre() %></div>
                                        <div style="font-size: 12px; color: var(--muted); margin-top: 2px;">
                                            <%= ev.getType() %> · <%= ev.getLieu() %>
                                        </div>
                                    </div>
                                    <span class="badge badge-navy"><%= ev.getType() %></span>
                                </div>
                                <%
                                        }
                                    } else {
                                %>
                                <div style="display: grid; grid-template-columns: 85px 1fr auto; gap: 16px; padding: 14px 24px; border-bottom: 1px solid var(--border); align-items: center;">
                                    <div style="font-family: var(--font-mono); text-align: left;">
                                        <div style="font-size: 13px; font-weight: 600; color: var(--ink);">14 JUIN</div>
                                        <div style="font-size: 11px; color: var(--muted);">2026</div>
                                    </div>
                                    <div>
                                        <div style="font-family: var(--font-serif); font-size: 15px; font-weight: 500; color: var(--ink);">Federated Learning sur Edge</div>
                                        <div style="font-size: 12px; color: var(--muted); margin-top: 2px;">Séminaire · Salle 12 · Ben M'Sik</div>
                                    </div>
                                    <span class="badge badge-navy">Séminaire</span>
                                </div>
                                <div style="display: grid; grid-template-columns: 85px 1fr auto; gap: 16px; padding: 14px 24px; border-bottom: 1px solid var(--border); align-items: center;">
                                    <div style="font-family: var(--font-mono); text-align: left;">
                                        <div style="font-size: 13px; font-weight: 600; color: var(--ink);">10 JUIL.</div>
                                        <div style="font-size: 11px; color: var(--muted);">2026</div>
                                    </div>
                                    <div>
                                        <div style="font-family: var(--font-serif); font-size: 15px; font-weight: 500; color: var(--ink);">ACL 2026 — Vienne, Autriche</div>
                                        <div style="font-size: 12px; color: var(--muted); margin-top: 2px;">Conférence · Présentation travaux NLP</div>
                                    </div>
                                    <span class="badge badge-navy">Conférence</span>
                                </div>
                                <% } %>
                            </div>
                        </div>
                        <% } %>

                    </div>

                    <!-- RIGHT COLUMN -->
                    <div style="display: flex; flex-direction: column; gap: 24px;">

                        <% if (isAdmin) { %>
                        <!-- Card Infrastructure & Environnement Technique (Admin) -->
                        <div class="card">
                            <div class="eyebrow" style="margin-bottom: 4px;">INFRASTRUCTURE SERVEUR</div>
                            <h3 style="font-size: 20px; margin: 0 0 14px;">Environnement Technique</h3>
                            
                            <div style="display: flex; flex-direction: column; gap: 12px; font-size: 13px;">
                                <div style="display: flex; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--border);">
                                    <span style="color: var(--muted);">Serveur Web :</span>
                                    <strong style="color: var(--ink); font-family: var(--font-mono);">Apache Tomcat 10.1</strong>
                                </div>
                                <div style="display: flex; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--border);">
                                    <span style="color: var(--muted);">Java Runtime :</span>
                                    <strong style="color: var(--ink); font-family: var(--font-mono);"><%= System.getProperty("java.version") %></strong>
                                </div>
                                <div style="display: flex; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--border);">
                                    <span style="color: var(--muted);">Base de Données :</span>
                                    <strong style="color: var(--ink); font-family: var(--font-mono);">MySQL 8.0 (UTF-8)</strong>
                                </div>
                                <div style="display: flex; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--border);">
                                    <span style="color: var(--muted);">Statut Global :</span>
                                    <strong style="color: #059669; font-family: var(--font-mono);">100% Opérationnel</strong>
                                </div>
                            </div>

                            <a href="<%= request.getContextPath() %>/admin?tab=maint" class="btn btn-secondary" style="width: 100%; margin-top: 16px; justify-content: center; font-size: 13px;">
                                Diagnostic &amp; Maintenance →
                            </a>
                        </div>

                        <!-- Card Raccourcis Outils Admin -->
                        <div class="card">
                            <div class="eyebrow" style="margin-bottom: 4px;">OUTILS SYSTÈME</div>
                            <h3 style="font-size: 20px; margin: 0 0 12px;">Accès Rapides</h3>
                            <div style="display: flex; flex-direction: column; gap: 8px;">
                                <a href="<%= request.getContextPath() %>/admin" class="btn btn-secondary" style="justify-content: flex-start; font-size: 13px;">
                                    ⚙️ Gestion des Comptes Utilisateurs
                                </a>
                                <a href="<%= request.getContextPath() %>/profils" class="btn btn-secondary" style="justify-content: flex-start; font-size: 13px;">
                                    👥 Annuaire des Membres
                                </a>
                                <a href="<%= request.getContextPath() %>/notifications" class="btn btn-secondary" style="justify-content: flex-start; font-size: 13px;">
                                    🔔 Centre de Notifications
                                </a>
                            </div>
                        </div>

                        <% } else if (isDirector) { %>
                        <!-- Card Rapport Annuel avec Circular RingProgress (Direction) -->
                        <div class="card" id="rapport">
                            <div class="eyebrow" style="margin-bottom: 4px;">RAPPORT ANNUEL · OBLIGATOIRE</div>
                            <h3 style="font-size: 21px; margin: 0 0 16px;">Exercice 2025 — 2026</h3>

                            <div class="ring-progress-wrapper">
                                <svg class="ring-progress-svg" width="100" height="100" viewBox="0 0 100 100">
                                    <circle cx="50" cy="50" r="40" stroke="var(--border)" stroke-width="6" fill="none" />
                                    <circle cx="50" cy="50" r="40" stroke="var(--navy)" stroke-width="6" fill="none"
                                            stroke-dasharray="196 251.3" stroke-dashoffset="-62.8"
                                            transform="rotate(-90 50 50)" stroke-linecap="butt" />
                                    <text x="50" y="53" text-anchor="middle" font-family="var(--font-serif)" font-size="24" font-weight="500" fill="var(--ink)">
                                        78<tspan font-size="12" fill="var(--muted)">%</tspan>
                                    </text>
                                </svg>
                                <div class="ring-progress-text">
                                    Données agrégées depuis le 1<sup>er</sup> septembre 2025. Mise à jour automatique chaque nuit.
                                </div>
                            </div>

                            <div style="margin-top: 14px;">
                                <div class="report-line">
                                    <span style="color: var(--ink);">Événements collectés</span>
                                    <span style="font-family: var(--font-mono); font-size: 12px; color: var(--sage); font-weight: 500;">24/24</span>
                                </div>
                                <div class="report-line">
                                    <span style="color: var(--ink);">Publications validées</span>
                                    <span style="font-family: var(--font-mono); font-size: 12px; color: var(--muted); font-weight: 500;">42/52</span>
                                </div>
                                <div class="report-line">
                                    <span style="color: var(--ink);">Conventions actives</span>
                                    <span style="font-family: var(--font-mono); font-size: 12px; color: var(--sage); font-weight: 500;">7/7</span>
                                </div>
                                <div class="report-line">
                                    <span style="color: var(--ink);">Mandat / gouvernance</span>
                                    <span style="font-family: var(--font-mono); font-size: 12px; color: var(--sage); font-weight: 500;">OK</span>
                                </div>
                            </div>

                            <a href="<%= request.getContextPath() %>/rapport" class="btn btn-primary" style="width: 100%; margin-top: 16px; justify-content: center;">
                                Ouvrir le rapport →
                            </a>
                        </div>

                        <!-- Card Demandes d'adhésion (Arbitrage Direction) -->
                        <div class="card" id="adhesions">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                <div>
                                    <div class="eyebrow" style="margin-bottom: 2px;">À DÉCIDER</div>
                                    <h3 style="font-size: 18px; margin: 0;">Demandes d'adhésion</h3>
                                </div>
                                <span class="badge badge-gold">4 en attente</span>
                            </div>

                            <div style="display: flex; flex-direction: column; gap: 10px;">
                                <div style="display: flex; align-items: center; gap: 12px; padding: 10px 0; border-top: 1px solid var(--border);">
                                    <div style="width: 32px; height: 32px; background: var(--surface-2); border: 1px solid var(--border); display: flex; align-items: center; justify-content: center; font-family: var(--font-mono); font-size: 11px; font-weight: 600; color: var(--navy); border-radius: 2px;">
                                        SF
                                    </div>
                                    <div style="flex: 1; min-width: 0;">
                                        <div style="font-size: 13px; font-weight: 500; color: var(--ink);">Salma El Fassi</div>
                                        <div style="font-size: 11.5px; color: var(--muted);">Doctorante · FS Ben M'Sik</div>
                                    </div>
                                </div>
                            </div>

                            <a href="<%= request.getContextPath() %>/adhesions" class="btn btn-secondary" style="width: 100%; margin-top: 12px; justify-content: center; font-size: 12.5px;">
                                Traiter les demandes
                            </a>
                        </div>

                        <% } else if (isPermanent) { %>
                        <!-- Card Espace Permanent (Logistique & Matériel) -->
                        <div class="card">
                            <div class="eyebrow" style="margin-bottom: 4px;">LOGISTIQUE DE RECHERCHE</div>
                            <h3 style="font-size: 20px; margin: 0 0 12px;">Équipements &amp; Matériel</h3>
                            <p style="font-family: var(--font-serif); font-size: 14px; color: var(--muted); line-height: 1.5; margin: 0 0 16px;">
                                En tant que membre permanent, vous pouvez soumettre des demandes de matériel (stations de calcul GPU, PC portables) soumises à l'arbitrage de la direction.
                            </p>
                            <a href="<%= request.getContextPath() %>/materiel" class="btn btn-secondary" style="width: 100%; justify-content: center;">
                                Accéder au module Matériel →
                            </a>
                        </div>

                        <% } else { %>
                        <!-- Card Droits & Périmètre du Compte (Doctorants / Associés) -->
                        <div class="card">
                            <div class="eyebrow" style="margin-bottom: 4px;">PÉRIMÈTRE DES ACCÈS</div>
                            <h3 style="font-size: 20px; margin: 0 0 14px;">Droits de votre profil</h3>
                            
                            <div style="display: flex; flex-direction: column; gap: 10px; font-size: 13px;">
                                <div style="display: flex; align-items: center; gap: 8px; color: var(--success, #059669);">
                                    <span>✔</span>
                                    <span>Consultation des publications du laboratoire</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px; color: var(--success, #059669);">
                                    <span>✔</span>
                                    <span>Déclaration et ajout de travaux indexés</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px; color: var(--success, #059669);">
                                    <span>✔</span>
                                    <span>Participation aux événements et séminaires</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px; color: var(--muted); margin-top: 4px; padding-top: 8px; border-top: 1px solid var(--border);">
                                    <span>ℹ</span>
                                    <span>Gouvernance &amp; PV réservés aux membres permanents</span>
                                </div>
                            </div>

                            <div style="margin-top: 16px; padding: 10px; background: var(--surface-2); border-radius: 2px; font-family: var(--font-mono); font-size: 11px; color: var(--muted);">
                                Espace de travail dédié aux chercheurs &amp; doctorants.
                            </div>
                        </div>
                        <% } %>

                    </div>

                </div>

            </div>
        </main>
    </div>
</div>

</body>
</html>

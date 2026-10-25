<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.Member"%>
<%@ page import="com.lias.beans.Publication"%>
<%@ page import="com.lias.beans.Evenement"%>
<%@ page import="com.lias.beans.DocumentLabo"%>
<%@ page import="com.lias.beans.Convention"%>
<%@ page import="com.lias.beans.ReunionPV"%>
<%@ page import="com.lias.beans.User"%>
<%
    String query = (String) request.getAttribute("query");
    if (query == null) query = "";
    String category = (String) request.getAttribute("category");
    if (category == null) category = "tout";

    List<Member> resMembers = (List<Member>) request.getAttribute("resMembers");
    List<Publication> resPubs = (List<Publication>) request.getAttribute("resPubs");
    List<Evenement> resEvents = (List<Evenement>) request.getAttribute("resEvents");
    List<DocumentLabo> resDocs = (List<DocumentLabo>) request.getAttribute("resDocs");
    List<Convention> resConventions = (List<Convention>) request.getAttribute("resConventions");
    List<ReunionPV> resPVs = (List<ReunionPV>) request.getAttribute("resPVs");

    Integer totalCount = (Integer) request.getAttribute("totalCount");
    if (totalCount == null) totalCount = 0;
    Integer countMembers = (Integer) request.getAttribute("countMembers");
    if (countMembers == null) countMembers = 0;
    Integer countPubs = (Integer) request.getAttribute("countPubs");
    if (countPubs == null) countPubs = 0;
    Integer countEvents = (Integer) request.getAttribute("countEvents");
    if (countEvents == null) countEvents = 0;
    Integer countDocs = (Integer) request.getAttribute("countDocs");
    if (countDocs == null) countDocs = 0;
    Integer countConventions = (Integer) request.getAttribute("countConventions");
    if (countConventions == null) countConventions = 0;
    Integer countPVs = (Integer) request.getAttribute("countPVs");
    if (countPVs == null) countPVs = 0;
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Recherche Globale & Consultation</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        .search-category-tabs {
            display: flex;
            gap: 8px;
            margin: 20px 0;
            border-bottom: 1px solid var(--border-color, #E5E7EB);
            padding-bottom: 12px;
            overflow-x: auto;
        }
        .cat-tab {
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
        .cat-tab:hover {
            color: var(--navy-primary, #0B192C);
            background: #F8FAFC;
        }
        .cat-tab.active {
            background: var(--navy-primary, #0B192C);
            color: #FFFFFF;
            border-color: var(--navy-primary, #0B192C);
        }
        .search-item-card {
            background: #FFFFFF;
            border: 1px solid var(--border-color, #E5E7EB);
            border-radius: 6px;
            padding: 16px 20px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            transition: all 0.2s ease;
        }
        .search-item-card:hover {
            border-color: var(--navy-primary, #0B192C);
            box-shadow: 0 4px 12px rgba(11, 25, 44, 0.06);
            transform: translateY(-1px);
        }
        .entity-badge {
            font-size: 10.5px;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .badge-member { background: #EEF2FF; color: #4338CA; border: 1px solid #C7D2FE; }
        .badge-doc { background: #F0FDF4; color: #15803D; border: 1px solid #BBF7D0; }
        .badge-event { background: #FEF3C7; color: #B45309; border: 1px solid #FDE68A; }
        .badge-pub { background: #FDF2F8; color: #BE185D; border: 1px solid #FBCFE8; }
        .badge-conv { background: #F5F3FF; color: #6D28D9; border: 1px solid #DDD6FE; }
        .badge-pv { background: #ECFDF5; color: #047857; border: 1px solid #A7F3D0; }

        .suggest-chip {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            background: #F1F5F9;
            color: var(--navy-primary, #0B192C);
            text-decoration: none;
            margin: 4px 4px 4px 0;
            border: 1px solid #E2E8F0;
            transition: all 0.15s;
        }
        .suggest-chip:hover {
            background: var(--navy-primary, #0B192C);
            color: #FFF;
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

                <!-- SECTION HEAD -->
                <div class="page-header">
                    <div>
                        <span class="eyebrow" style="color:var(--gold-accent); font-weight:700;">Système d'Information & Consultation</span>
                        <h1 class="page-title">Recherche Globale & Consultation</h1>
                        <p class="page-sub">
                            Moteur unifié multi-entités : explorez simultanément les <strong>membres</strong>, <strong>documents</strong>, <strong>événements</strong> et <strong>publications</strong> scientifiques du laboratoire LIAS.
                        </p>
                    </div>
                </div>

                <!-- SEARCH BAR -->
                <div class="card" style="padding: 24px; margin-bottom: 24px; background: #FFF;">
                    <form action="<%= request.getContextPath() %>/recherche" method="GET" style="margin: 0;">
                        <div style="display: flex; gap: 12px;">
                            <div style="flex: 1; position: relative;">
                                <span style="position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 18px;">⌕</span>
                                <input type="text" name="q" value="<%= query %>" autofocus
                                       placeholder="Rechercher par nom de chercheur, thématique, publication, type de document, événement..." 
                                       class="form-control"
                                       style="width: 100%; padding: 14px 16px 14px 46px; font-size: 15px; border: 2px solid var(--border-color); border-radius: 6px;">
                            </div>
                            <button type="submit" class="btn btn-primary" style="padding: 0 28px; font-size: 14px; font-weight: 700;">
                                Rechercher
                            </button>
                        </div>
                    </form>

                    <!-- Suggestions rapides de recherche -->
                    <div style="margin-top: 14px; font-size: 12px; color: var(--text-muted);">
                        <strong style="color: var(--navy-primary);">Recherches fréquentes :</strong>
                        <a href="<%= request.getContextPath() %>/recherche?q=Intelligence Artificielle" class="suggest-chip">Intelligence Artificielle</a>
                        <a href="<%= request.getContextPath() %>/recherche?q=Ibtissam Essadiki" class="suggest-chip">Prof. Ibtissam Essadiki</a>
                        <a href="<%= request.getContextPath() %>/recherche?q=GPU" class="suggest-chip">GPU / Calcul</a>
                        <a href="<%= request.getContextPath() %>/recherche?q=Big Data" class="suggest-chip">Big Data</a>
                        <a href="<%= request.getContextPath() %>/recherche?q=Rapport" class="suggest-chip">Rapports d'activité</a>
                        <a href="<%= request.getContextPath() %>/recherche?q=Doctorant" class="suggest-chip">Doctorants</a>
                        <a href="<%= request.getContextPath() %>/recherche?q=CNRST" class="suggest-chip">Partenaires CNRST</a>
                    </div>
                </div>

                <!-- CATEGORY TABS -->
                <% if (!query.isEmpty()) { %>
                    <div class="search-category-tabs">
                        <a href="<%= request.getContextPath() %>/recherche?q=<%= java.net.URLEncoder.encode(query, "UTF-8") %>&cat=tout" class="cat-tab <%= "tout".equals(category) ? "active" : "" %>">
                            <span>Tous les résultats</span>
                            <span class="badge" style="background: rgba(0,0,0,0.1); font-weight:700;">(<%= totalCount %>)</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/recherche?q=<%= java.net.URLEncoder.encode(query, "UTF-8") %>&cat=membres" class="cat-tab <%= "membres".equals(category) ? "active" : "" %>">
                            <span>👥 Membres</span>
                            <span class="badge" style="background: rgba(0,0,0,0.1); font-weight:700;">(<%= countMembers %>)</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/recherche?q=<%= java.net.URLEncoder.encode(query, "UTF-8") %>&cat=documents" class="cat-tab <%= "documents".equals(category) ? "active" : "" %>">
                            <span>📄 Documents</span>
                            <span class="badge" style="background: rgba(0,0,0,0.1); font-weight:700;">(<%= countDocs %>)</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/recherche?q=<%= java.net.URLEncoder.encode(query, "UTF-8") %>&cat=evenements" class="cat-tab <%= "evenements".equals(category) ? "active" : "" %>">
                            <span>📅 Événements</span>
                            <span class="badge" style="background: rgba(0,0,0,0.1); font-weight:700;">(<%= countEvents %>)</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/recherche?q=<%= java.net.URLEncoder.encode(query, "UTF-8") %>&cat=publications" class="cat-tab <%= "publications".equals(category) ? "active" : "" %>">
                            <span>📚 Publications</span>
                            <span class="badge" style="background: rgba(0,0,0,0.1); font-weight:700;">(<%= countPubs %>)</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/recherche?q=<%= java.net.URLEncoder.encode(query, "UTF-8") %>&cat=pv" class="cat-tab <%= "pv".equals(category) ? "active" : "" %>">
                            <span>📜 Délibérations & PV</span>
                            <span class="badge" style="background: rgba(0,0,0,0.1); font-weight:700;">(<%= countPVs %>)</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/recherche?q=<%= java.net.URLEncoder.encode(query, "UTF-8") %>&cat=conventions" class="cat-tab <%= "conventions".equals(category) ? "active" : "" %>">
                            <span>⌘ Conventions</span>
                            <span class="badge" style="background: rgba(0,0,0,0.1); font-weight:700;">(<%= countConventions %>)</span>
                        </a>
                    </div>

                    <!-- RESULTS SECTION -->
                    <% if (totalCount == 0) { %>
                        <div class="card" style="padding: 56px 24px; text-align: center; color: var(--text-muted);">
                            <div style="font-size: 32px; margin-bottom: 12px;">🔍</div>
                            <h3 style="color: var(--navy-primary); margin-bottom: 8px;">Aucun résultat trouvé</h3>
                            <p style="font-size: 14px; max-width: 480px; margin: 0 auto;">
                                Aucun élément ne correspond au mot-clé « <strong><%= query %></strong> » dans les membres, documents, événements, publications ou délibérations.
                            </p>
                        </div>
                    <% } else { %>

                        <!-- 1. MEMBRES -->
                        <% if (("tout".equals(category) || "membres".equals(category)) && resMembers != null && !resMembers.isEmpty()) { %>
                            <div style="margin: 24px 0 12px; display:flex; align-items:center; gap:8px;">
                                <span class="entity-badge badge-member">Membres (<%= resMembers.size() %>)</span>
                                <h3 style="font-size: 16px; font-weight: 800; color: var(--navy-primary); margin: 0;">Chercheurs & Doctorants du LIAS</h3>
                            </div>
                            <% for (Member m : resMembers) { %>
                                <div class="search-item-card">
                                    <div style="display: flex; align-items: center; gap: 14px;">
                                        <div style="width: 42px; height: 42px; border-radius: 50%; background: var(--navy-primary); color: #FFF; font-weight: 700; display: flex; align-items: center; justify-content: center; font-size: 14px;">
                                            <%= (m.getPrenom() != null && !m.getPrenom().isEmpty() ? m.getPrenom().substring(0, 1) : "C") %><%= (m.getNom() != null && !m.getNom().isEmpty() ? m.getNom().substring(0, 1) : "H") %>
                                        </div>
                                        <div>
                                            <div style="font-size: 15px; font-weight: 700; color: var(--navy-primary);">
                                                <%= m.getNom() %> <%= m.getPrenom() %>
                                            </div>
                                            <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                                <strong style="color: var(--gold-accent);"><%= m.getGrade() != null ? m.getGrade() : "Chercheur" %></strong> · 
                                                <span>Statut: <%= m.getStatut() != null ? m.getStatut().toUpperCase() : "PERMANENT" %></span> · 
                                                <span>Équipe: <%= m.getEquipe() %></span> · 
                                                <span style="font-family: 'JetBrains Mono', monospace;"><%= m.getEmail() %></span>
                                            </div>
                                        </div>
                                    </div>
                                    <a href="<%= request.getContextPath() %>/profils?id=<%= m.getId() %>" class="btn btn-secondary btn-sm">
                                        Consulter profil complet →
                                    </a>
                                </div>
                            <% } %>
                        <% } %>

                        <!-- 2. DOCUMENTS -->
                        <% if (("tout".equals(category) || "documents".equals(category)) && resDocs != null && !resDocs.isEmpty()) { %>
                            <div style="margin: 28px 0 12px; display:flex; align-items:center; gap:8px;">
                                <span class="entity-badge badge-doc">Documents (<%= resDocs.size() %>)</span>
                                <h3 style="font-size: 16px; font-weight: 800; color: var(--navy-primary); margin: 0;">Archive Documentaire Officielle</h3>
                            </div>
                            <% for (DocumentLabo d : resDocs) { %>
                                <div class="search-item-card">
                                    <div style="display: flex; align-items: center; gap: 14px;">
                                        <div style="width: 42px; height: 42px; border-radius: 6px; background: #F0FDF4; border: 1px solid #BBF7D0; color: #15803D; font-weight: 800; display: flex; align-items: center; justify-content: center; font-size: 12px;">
                                            PDF
                                        </div>
                                        <div>
                                            <div style="font-size: 15px; font-weight: 700; color: var(--navy-primary);">
                                                <%= d.getNomFichier() %>
                                            </div>
                                            <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                                <strong style="color: #15803D;"><%= d.getCategorie() %></strong> · 
                                                <span>Événement: <%= d.getEvenementNom() != null ? d.getEvenementNom() : d.getSousDossier() %></span> · 
                                                <span>Taille: <%= d.getTaille() %></span> · 
                                                <span style="font-family: 'JetBrains Mono', monospace;"><%= d.getDateFichier() %></span>
                                            </div>
                                            <% if (d.getDescription() != null && !d.getDescription().isEmpty()) { %>
                                                <div style="font-size: 12px; color: var(--text-color); margin-top: 4px;">
                                                    <%= d.getDescription() %>
                                                </div>
                                            <% } %>
                                        </div>
                                    </div>
                                    <a href="<%= request.getContextPath() %>/documents?download=<%= d.getId() %>" class="btn btn-primary btn-sm">
                                        ⤓ Télécharger archive
                                    </a>
                                </div>
                            <% } %>
                        <% } %>

                        <!-- 3. ÉVÉNEMENTS -->
                        <% if (("tout".equals(category) || "evenements".equals(category)) && resEvents != null && !resEvents.isEmpty()) { %>
                            <div style="margin: 28px 0 12px; display:flex; align-items:center; gap:8px;">
                                <span class="entity-badge badge-event">Événements (<%= resEvents.size() %>)</span>
                                <h3 style="font-size: 16px; font-weight: 800; color: var(--navy-primary); margin: 0;">Activités & Manifestations Scientifiques</h3>
                            </div>
                            <% for (Evenement e : resEvents) { %>
                                <div class="search-item-card">
                                    <div style="display: flex; align-items: center; gap: 14px;">
                                        <div style="width: 42px; height: 42px; border-radius: 6px; background: #FFFBEB; border: 1px solid #FDE68A; color: #B45309; font-weight: 800; display: flex; flex-direction: column; align-items: center; justify-content: center; font-size: 11px;">
                                            <span><%= e.getDate() != null && e.getDate().length() >= 7 ? e.getDate().substring(5, 7) : "CAL" %></span>
                                            <span style="font-size:9px;"><%= e.getDate() != null && e.getDate().length() >= 4 ? e.getDate().substring(0, 4) : "" %></span>
                                        </div>
                                        <div>
                                            <div style="font-size: 15px; font-weight: 700; color: var(--navy-primary);">
                                                <%= e.getTitre() %>
                                            </div>
                                            <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                                <strong style="color: #B45309;"><%= e.getType() %></strong> · 
                                                <span>Date: <%= e.getDate() %></span> · 
                                                <span>Lieu: <%= e.getLieu() %></span> · 
                                                <span>Organisateur: <%= e.getOrganisateur() %></span>
                                            </div>
                                            <% if (e.getDescription() != null && !e.getDescription().isEmpty()) { %>
                                                <div style="font-size: 12px; color: var(--text-color); margin-top: 4px;">
                                                    <%= e.getDescription() %>
                                                </div>
                                            <% } %>
                                        </div>
                                    </div>
                                    <a href="<%= request.getContextPath() %>/calendrier" class="btn btn-secondary btn-sm">
                                        Consulter au calendrier →
                                    </a>
                                </div>
                            <% } %>
                        <% } %>

                        <!-- 4. PUBLICATIONS -->
                        <% if (("tout".equals(category) || "publications".equals(category)) && resPubs != null && !resPubs.isEmpty()) { %>
                            <div style="margin: 28px 0 12px; display:flex; align-items:center; gap:8px;">
                                <span class="entity-badge badge-pub">Publications (<%= resPubs.size() %>)</span>
                                <h3 style="font-size: 16px; font-weight: 800; color: var(--navy-primary); margin: 0;">Production Scientifique Internationale</h3>
                            </div>
                            <% for (Publication p : resPubs) { %>
                                <div class="search-item-card">
                                    <div style="display: flex; align-items: center; gap: 14px;">
                                        <div style="width: 42px; height: 42px; border-radius: 6px; background: #FDF2F8; border: 1px solid #FBCFE8; color: #BE185D; font-weight: 800; display: flex; align-items: center; justify-content: center; font-size: 13px;">
                                            <%= p.getAnnee() %>
                                        </div>
                                        <div>
                                            <div style="font-size: 15px; font-weight: 700; color: var(--navy-primary);">
                                                <%= p.getTitre() %>
                                            </div>
                                            <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                                <span style="font-weight: 600; color: var(--navy-primary);"><%= p.getAuteurs() %></span> · 
                                                <em><%= p.getRevue() %></em> (<%= p.getAnnee() %>) · 
                                                <span>Équipe: <%= p.getEquipe() %></span>
                                            </div>
                                        </div>
                                    </div>
                                    <a href="<%= request.getContextPath() %>/publications" class="btn btn-secondary btn-sm">
                                        Consulter publication →
                                    </a>
                                </div>
                            <% } %>
                        <% } %>

                        <!-- 5. PROCÈS-VERBAUX -->
                        <% if (("tout".equals(category) || "pv".equals(category)) && resPVs != null && !resPVs.isEmpty()) { %>
                            <div style="margin: 28px 0 12px; display:flex; align-items:center; gap:8px;">
                                <span class="entity-badge badge-pv">Procès-Verbaux (<%= resPVs.size() %>)</span>
                                <h3 style="font-size: 16px; font-weight: 800; color: var(--navy-primary); margin: 0;">Délibérations & PV de Conseils</h3>
                            </div>
                            <% for (ReunionPV pv : resPVs) { %>
                                <div class="search-item-card">
                                    <div>
                                        <span class="entity-badge badge-pv" style="margin-bottom:4px;"><%= pv.getTypeReunion() %></span>
                                        <div style="font-size: 15px; font-weight: 700; color: var(--navy-primary); margin-top:2px;">
                                            <%= pv.getTitre() %>
                                        </div>
                                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                            <span>Date: <%= pv.getDateReunion() %></span> · 
                                            <span>Signataire: <%= pv.getDirecteurSignataire() %></span> · 
                                            <span>Statut: <%= pv.getStatut() %></span>
                                        </div>
                                    </div>
                                    <div style="display:flex; gap:8px;">
                                        <a href="<%= request.getContextPath() %>/pv?action=telecharger&id=<%= pv.getId() %>" class="btn btn-primary btn-sm">
                                            ⤓ Télécharger PV
                                        </a>
                                    </div>
                                </div>
                            <% } %>
                        <% } %>

                        <!-- 6. CONVENTIONS -->
                        <% if (("tout".equals(category) || "conventions".equals(category)) && resConventions != null && !resConventions.isEmpty()) { %>
                            <div style="margin: 28px 0 12px; display:flex; align-items:center; gap:8px;">
                                <span class="entity-badge badge-conv">Conventions (<%= resConventions.size() %>)</span>
                                <h3 style="font-size: 16px; font-weight: 800; color: var(--navy-primary); margin: 0;">Accords & Conventions de Recherche</h3>
                            </div>
                            <% for (Convention c : resConventions) { %>
                                <div class="search-item-card">
                                    <div>
                                        <div style="font-size: 15px; font-weight: 700; color: var(--navy-primary);">
                                            <%= c.getOrganismePartenaire() %>
                                        </div>
                                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                            <span>Type: <%= c.getTypePartenaire() %></span> · 
                                            <span>Objet: <%= c.getObjet() %></span> · 
                                            <span>Statut: <%= c.getStatut() %></span>
                                        </div>
                                    </div>
                                    <a href="<%= request.getContextPath() %>/conventions" class="btn btn-secondary btn-sm">
                                        Consulter convention →
                                    </a>
                                </div>
                            <% } %>
                        <% } %>

                    <% } %>
                <% } else { %>
                    <!-- ÉTAT D'ACCUEIL AVEC MODULES INDEXÉS -->
                    <div class="card" style="padding: 40px 28px; text-align: center;">
                        <div style="font-size: 36px; margin-bottom: 12px;">🔎</div>
                        <h2 style="font-size: 18px; font-weight: 800; color: var(--navy-primary); margin-bottom: 8px;">
                            Exploration Unifiée du Laboratoire LIAS
                        </h2>
                        <p style="font-size: 13.5px; color: var(--text-muted); max-width: 540px; margin: 0 auto 24px;">
                            Saisissez un mot-clé ou un nom pour interroger en temps réel l'ensemble de la base de connaissances du laboratoire.
                        </p>

                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; text-align: left; max-width: 840px; margin: 0 auto;">
                            <div class="card" style="padding: 16px; border: 1px solid var(--border-color);">
                                <div style="font-weight: 700; font-size: 13px; color: var(--navy-primary); margin-bottom: 4px;">👥 Membres du Laboratoire</div>
                                <div style="font-size: 12px; color: var(--text-muted);">Enseignants-chercheurs permanents, doctorants et membres associés.</div>
                            </div>
                            <div class="card" style="padding: 16px; border: 1px solid var(--border-color);">
                                <div style="font-weight: 700; font-size: 13px; color: var(--navy-primary); margin-bottom: 4px;">📄 Archive Documentaire</div>
                                <div style="font-size: 12px; color: var(--text-muted);">Financements, attestations, programmes, rapports et attestations.</div>
                            </div>
                            <div class="card" style="padding: 16px; border: 1px solid var(--border-color);">
                                <div style="font-weight: 700; font-size: 13px; color: var(--navy-primary); margin-bottom: 4px;">📅 Événements Scientifiques</div>
                                <div style="font-size: 12px; color: var(--text-muted);">Séminaires, colloques, workshops techniques et soutenances.</div>
                            </div>
                            <div class="card" style="padding: 16px; border: 1px solid var(--border-color);">
                                <div style="font-weight: 700; font-size: 13px; color: var(--navy-primary); margin-bottom: 4px;">📚 Publications Indexées</div>
                                <div style="font-size: 12px; color: var(--text-muted);">Articles Scopus, revues internationales et communications de congrès.</div>
                            </div>
                        </div>
                    </div>
                <% } %>

            </div>
        </main>
    </div>
</div>

</body>
</html>

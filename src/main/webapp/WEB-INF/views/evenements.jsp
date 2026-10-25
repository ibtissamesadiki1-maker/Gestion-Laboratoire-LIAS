<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.Evenement"%>
<%@ page import="com.lias.beans.Member"%>
<%@ page import="com.lias.beans.User"%>
<%
    List<Evenement> evts = (List<Evenement>) request.getAttribute("evenements");
    List<Member> membres = (List<Member>) request.getAttribute("membres");
    List<String> editions = (List<String>) request.getAttribute("editions");
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");

    String msg = request.getParameter("msg");
    String selectedType = (String) request.getAttribute("selectedType");
    String selectedEdition = (String) request.getAttribute("selectedEdition");

    Number totalEventsCountNum = (Number) request.getAttribute("totalEventsCount");
    Number nbConferencesNum = (Number) request.getAttribute("nbConferences");
    Number nbSeminairesNum = (Number) request.getAttribute("nbSeminaires");
    Number nbWorkshopsNum = (Number) request.getAttribute("nbWorkshops");
    Number nbArchivesNum = (Number) request.getAttribute("nbArchives");

    long totalEventsCount = totalEventsCountNum != null ? totalEventsCountNum.longValue() : (evts != null ? (long) evts.size() : 0L);
    long nbConferences = nbConferencesNum != null ? nbConferencesNum.longValue() : 0L;
    long nbSeminaires = nbSeminairesNum != null ? nbSeminairesNum.longValue() : 0L;
    long nbWorkshops = nbWorkshopsNum != null ? nbWorkshopsNum.longValue() : 0L;
    long nbArchives = nbArchivesNum != null ? nbArchivesNum.longValue() : 0L;

    boolean canManage = currentUser != null && ("directeur".equalsIgnoreCase(currentUser.getRole()) 
                        || "admin".equalsIgnoreCase(currentUser.getRole()) 
                        || "permanent".equalsIgnoreCase(currentUser.getRole())
                        || "chef-equipe".equalsIgnoreCase(currentUser.getRole())
                        || "vice-directeur".equalsIgnoreCase(currentUser.getRole()));
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Gestion des Événements Scientifiques</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        .kpi-types-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        .kpi-type-card {
            background: var(--surface);
            border: 1px solid var(--border);
            padding: 16px 20px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.2s;
            text-decoration: none;
            color: inherit;
        }
        .kpi-type-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border-color: var(--accent-2);
        }
        .kpi-type-card.active {
            border-left: 4px solid var(--navy);
            background: rgba(27, 47, 74, 0.03);
        }
        .kpi-type-icon {
            font-size: 26px;
            margin-right: 12px;
        }
        .kpi-type-num {
            font-family: var(--font-serif);
            font-size: 28px;
            font-weight: 600;
            color: var(--navy);
            line-height: 1;
        }
        .kpi-type-label {
            font-family: var(--font-mono);
            font-size: 11px;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--muted);
            margin-top: 4px;
        }

        .filter-edition-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--surface);
            border: 1px solid var(--border);
            padding: 12px 20px;
            border-radius: 4px;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 12px;
        }
        .filter-pills {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .filter-pill {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12.5px;
            font-weight: 500;
            text-decoration: none;
            color: var(--ink);
            background: var(--surface-2);
            border: 1px solid var(--border);
            transition: all 0.15s;
        }
        .filter-pill:hover, .filter-pill.active {
            background: var(--navy);
            color: var(--cream);
            border-color: var(--navy);
        }

        .event-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 4px;
            padding: 22px 24px;
            margin-bottom: 16px;
            transition: all 0.2s;
            position: relative;
        }
        .event-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.04);
            border-color: #cbd5e1;
        }
        .event-card-grid {
            display: grid;
            grid-template-columns: 90px 1fr auto;
            gap: 24px;
            align-items: flex-start;
        }
        .event-date-box {
            text-align: center;
            padding: 12px 8px;
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: 4px;
        }
        .event-day {
            font-family: var(--font-serif);
            font-size: 32px;
            font-weight: 600;
            color: var(--navy);
            line-height: 1;
        }
        .event-month-year {
            font-family: var(--font-mono);
            font-size: 10px;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: var(--muted);
            margin-top: 4px;
        }

        .event-title-row {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 8px;
        }
        .event-title {
            font-family: var(--font-serif);
            font-size: 20px;
            font-weight: 600;
            color: var(--ink);
            margin: 0;
            line-height: 1.3;
        }
        .event-meta-line {
            display: flex;
            align-items: center;
            gap: 18px;
            font-size: 13px;
            color: var(--muted);
            margin-bottom: 12px;
            flex-wrap: wrap;
        }
        .event-meta-item {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .event-programme-box {
            background: rgba(237, 229, 211, 0.2);
            border-left: 3px solid var(--accent-2);
            padding: 10px 14px;
            margin: 12px 0;
            border-radius: 0 4px 4px 0;
            font-size: 13px;
            line-height: 1.5;
        }
        .event-programme-title {
            font-family: var(--font-mono);
            font-size: 10.5px;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            color: var(--navy);
            margin-bottom: 4px;
            font-weight: 600;
        }

        .event-action-bar {
            display: flex;
            gap: 8px;
            margin-top: 14px;
            padding-top: 12px;
            border-top: 1px dashed var(--border);
            flex-wrap: wrap;
        }
        .btn-action-small {
            padding: 5px 12px;
            font-size: 12px;
            border-radius: 2px;
            cursor: pointer;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--ink);
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.15s;
        }
        .btn-action-small:hover {
            background: var(--surface-2);
            border-color: var(--navy);
        }
        .btn-action-primary {
            background: var(--navy);
            color: var(--cream);
            border-color: var(--navy);
        }
        .btn-action-primary:hover {
            background: var(--navy-dark);
            color: #fff;
        }

        /* Modal Dialog Styling */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.6);
            z-index: 1000;
            backdrop-filter: blur(2px);
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.active {
            display: flex;
        }
        .modal-dialog {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 4px;
            max-width: 620px;
            width: 92%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            padding: 28px;
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
            padding-bottom: 14px;
            margin-bottom: 20px;
        }
        .modal-title {
            font-family: var(--font-serif);
            font-size: 22px;
            font-weight: 600;
            margin: 0;
            color: var(--navy);
        }
        .modal-close {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: var(--muted);
        }

        @media (max-width: 900px) {
            .kpi-types-grid { grid-template-columns: repeat(2, 1fr); }
            .event-card-grid { grid-template-columns: 1fr; }
            .event-date-box { display: inline-block; width: 100px; }
        }
    </style>
</head>
<body>

<% if (currentUser == null) { %>
    <%@ include file="includes/navbar.jsp" %>
    <div class="container" style="max-width: 1280px; margin: 0 auto; padding: 40px 24px;">
<% } else { %>
    <div class="app-shell">
        <%@ include file="includes/app_header.jsp" %>
        <div class="app-body">
            <%@ include file="includes/sidebar.jsp" %>
            <main class="app-main">
                <div class="app-content">
<% } %>

        <!-- En-tête éditorial officiel -->
        <div class="page-header" style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
            <div>
                <span class="eyebrow">Agenda Scientifique & Patrimoine Académique</span>
                <h1 class="page-title">Gestion des Événements Scientifiques</h1>
                <p class="page-sub">
                    Création, organisation, archivage par édition et affectation officielle d'organisateurs pour les conférences, séminaires et workshops du LIAS.
                </p>
            </div>
            <% if (canManage) { %>
                <button class="btn btn-primary" onclick="openAddEventModal()">
                    + Créer un événement
                </button>
            <% } %>
        </div>

        <!-- Toast Notifications -->
        <% if ("cree".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">✓</div>
                <div class="toast-content">
                    <div class="toast-title">Événement créé avec succès !</div>
                    <div class="toast-desc">La manifestation a été enregistrée avec son édition, son organisation et son responsable désigné.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()">✕</button>
            </div>
        <% } else if ("organisateur_affecte".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">👤</div>
                <div class="toast-content">
                    <div class="toast-title">Organisateur affecté avec succès !</div>
                    <div class="toast-desc">Le membre du laboratoire a été officiellement désigné coordonnateur de la manifestation.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()">✕</button>
            </div>
        <% } else if ("organisation_modifiee".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">⚙️</div>
                <div class="toast-content">
                    <div class="toast-title">Organisation mise à jour avec succès !</div>
                    <div class="toast-desc">Le programme, la logistique, l'édition et le statut organisationnel ont été mis à jour.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()">✕</button>
            </div>
        <% } else if ("edition_archivee".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">📁</div>
                <div class="toast-content">
                    <div class="toast-title">Édition archivée avec succès !</div>
                    <div class="toast-desc">La manifestation est désormais conservée dans le patrimoine scientifique des éditions passées.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()">✕</button>
            </div>
        <% } else if ("supprime".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">🗑️</div>
                <div class="toast-content">
                    <div class="toast-title">Événement retiré de l'agenda</div>
                    <div class="toast-desc">La suppression a été effectuée dans la base de données.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()">✕</button>
            </div>
        <% } %>

        <!-- Types d'événements : Conférences, Séminaires, Workshops -->
        <div class="kpi-types-grid">
            <a href="<%= request.getContextPath() %>/evenements?type=Conference" class="kpi-type-card <%= (selectedType != null && selectedType.toLowerCase().contains("conf")) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-type-icon">🎙️</span>
                    <div>
                        <div class="kpi-type-num"><%= nbConferences %></div>
                        <div class="kpi-type-label">Conférences</div>
                    </div>
                </div>
                <span class="badge badge-navy" style="font-size: 10px;">Académique</span>
            </a>

            <a href="<%= request.getContextPath() %>/evenements?type=Seminaire" class="kpi-type-card <%= (selectedType != null && selectedType.toLowerCase().contains("semin")) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-type-icon">🎓</span>
                    <div>
                        <div class="kpi-type-num"><%= nbSeminaires %></div>
                        <div class="kpi-type-label">Séminaires</div>
                    </div>
                </div>
                <span class="badge badge-gold" style="font-size: 10px;">Recherche</span>
            </a>

            <a href="<%= request.getContextPath() %>/evenements?type=Workshop" class="kpi-type-card <%= (selectedType != null && selectedType.toLowerCase().contains("workshop")) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-type-icon">💻</span>
                    <div>
                        <div class="kpi-type-num"><%= nbWorkshops %></div>
                        <div class="kpi-type-label">Workshops</div>
                    </div>
                </div>
                <span class="badge badge-sage" style="font-size: 10px;">Pratique</span>
            </a>

            <a href="<%= request.getContextPath() %>/evenements" class="kpi-type-card <%= (selectedType == null && selectedEdition == null) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-type-icon">📁</span>
                    <div>
                        <div class="kpi-type-num"><%= totalEventsCount %></div>
                        <div class="kpi-type-label">Toutes Éditions</div>
                    </div>
                </div>
                <span class="badge badge-burgundy" style="font-size: 10px;"><%= nbArchives %> Archivés</span>
            </a>
        </div>

        <!-- Barre de Filtres et Archivage par Édition -->
        <div class="filter-edition-bar">
            <div class="filter-pills">
                <span style="font-size: 12px; font-family: var(--font-mono); color: var(--muted); text-transform: uppercase; align-self: center; margin-right: 6px;">Types :</span>
                <a href="<%= request.getContextPath() %>/evenements" class="filter-pill <%= (selectedType == null || selectedType.isEmpty()) && (selectedEdition == null || selectedEdition.isEmpty()) ? "active" : "" %>">Tous</a>
                <a href="<%= request.getContextPath() %>/evenements?type=Conference" class="filter-pill <%= (selectedType != null && selectedType.toLowerCase().contains("conf")) ? "active" : "" %>">🎙️ Conférences</a>
                <a href="<%= request.getContextPath() %>/evenements?type=Seminaire" class="filter-pill <%= (selectedType != null && selectedType.toLowerCase().contains("semin")) ? "active" : "" %>">🎓 Séminaires</a>
                <a href="<%= request.getContextPath() %>/evenements?type=Workshop" class="filter-pill <%= (selectedType != null && selectedType.toLowerCase().contains("workshop")) ? "active" : "" %>">💻 Workshops</a>
            </div>

            <div style="display: flex; align-items: center; gap: 10px;">
                <label for="editionFilterSelect" style="font-size: 12px; font-family: var(--font-mono); color: var(--navy); font-weight: 600;">
                    📂 Archivage par Édition :
                </label>
                <select id="editionFilterSelect" class="form-control" style="width: auto; padding: 5px 10px; font-size: 12.5px; border-radius: 3px;" onchange="filterByEdition(this.value)">
                    <option value="">Toutes les Éditions</option>
                    <% if (editions != null) {
                        for (String ed : editions) { %>
                            <option value="<%= ed %>" <%= ed.equalsIgnoreCase(selectedEdition) ? "selected" : "" %>><%= ed %></option>
                    <%  }
                    } %>
                </select>
            </div>
        </div>

        <!-- Liste des Événements Scientifiques -->
        <div class="events-container">
            <%
                if (evts != null && !evts.isEmpty()) {
                    for (Evenement e : evts) {
                        String typeTone = "badge-navy";
                        String typeIcon = "🎙️";
                        if ("Séminaire".equalsIgnoreCase(e.getType())) {
                            typeTone = "badge-gold";
                            typeIcon = "🎓";
                        } else if ("Workshop".equalsIgnoreCase(e.getType())) {
                            typeTone = "badge-sage";
                            typeIcon = "💻";
                        }

                        String statutTone = "badge-navy";
                        if ("En cours".equalsIgnoreCase(e.getStatut())) statutTone = "badge-gold";
                        else if ("Passé".equalsIgnoreCase(e.getStatut()) || "Archivé".equalsIgnoreCase(e.getStatut())) statutTone = "badge-sage";

                        String dateStr = e.getDate();
                        String day = "15";
                        String monthYear = "2026-04";
                        if (dateStr != null && dateStr.length() >= 10) {
                            day = dateStr.substring(8, 10);
                            monthYear = dateStr.substring(0, 7);
                        }
            %>
            <div class="event-card">
                <div class="event-card-grid">
                    <!-- Date box -->
                    <div class="event-date-box">
                        <div class="event-day"><%= day %></div>
                        <div class="event-month-year"><%= monthYear %></div>
                    </div>

                    <!-- Contenu principal -->
                    <div>
                        <div class="event-title-row">
                            <span class="badge <%= typeTone %>" style="font-size: 11px;">
                                <%= typeIcon %> <%= e.getType() %>
                            </span>
                            <span class="badge badge-gold" style="font-size: 11px; font-family: var(--font-mono);">
                                📂 <%= e.getEdition() != null ? e.getEdition() : "Édition 2026" %>
                            </span>
                            <span class="badge <%= statutTone %>" style="font-size: 11px;">
                                ● <%= e.getStatut() != null ? e.getStatut() : "À venir" %>
                            </span>
                        </div>

                        <h3 class="event-title"><%= e.getTitre() %></h3>

                        <div class="event-meta-line">
                            <div class="event-meta-item">
                                <span>📍</span> <strong>Lieu :</strong> <%= e.getLieu() != null ? e.getLieu() : "Non spécifié" %>
                            </div>
                            <div class="event-meta-item">
                                <span>👤</span> <strong>Organisateur affecté :</strong> 
                                <span style="color: var(--navy); font-weight: 600;"><%= e.getOrganisateur() != null ? e.getOrganisateur() : "Non affecté" %></span>
                            </div>
                        </div>

                        <% if (e.getDescription() != null && !e.getDescription().trim().isEmpty()) { %>
                            <p style="font-size: 13.5px; color: var(--ink); line-height: 1.55; margin: 6px 0 10px;">
                                <%= e.getDescription() %>
                            </p>
                        <% } %>

                        <!-- Programme et Organisation -->
                        <% if (e.getProgramme() != null && !e.getProgramme().trim().isEmpty()) { %>
                            <div class="event-programme-box">
                                <div class="event-programme-title">📋 Organisation & Programme détaillé :</div>
                                <div style="color: var(--ink); white-space: pre-line;"><%= e.getProgramme() %></div>
                            </div>
                        <% } %>

                        <!-- Actions organisationnelles pour les chercheurs/direction -->
                        <% if (canManage) { %>
                            <div class="event-action-bar">
                                <button type="button" class="btn-action-small btn-action-primary" 
                                        onclick="openAffecterModal('<%= e.getId() %>', '<%= e.getTitre().replace("'", "\\'") %>', '<%= e.getOrganisateur() != null ? e.getOrganisateur().replace("'", "\\'") : "" %>')">
                                    👤 Affecter un organisateur
                                </button>

                                <button type="button" class="btn-action-small" 
                                        onclick="openOrganisationModal('<%= e.getId() %>', '<%= e.getTitre().replace("'", "\\'") %>', '<%= e.getType() %>', '<%= e.getDate() %>', '<%= e.getLieu() != null ? e.getLieu().replace("'", "\\'") : "" %>', '<%= e.getDescription() != null ? e.getDescription().replace("'", "\\'").replace("\n", "\\n") : "" %>', '<%= e.getProgramme() != null ? e.getProgramme().replace("'", "\\'").replace("\n", "\\n") : "" %>', '<%= e.getOrganisateur() != null ? e.getOrganisateur().replace("'", "\\'") : "" %>', '<%= e.getStatut() %>', '<%= e.getEdition() %>')">
                                    ⚙️ Gérer l'organisation
                                </button>

                                <% if (!"Archivé".equalsIgnoreCase(e.getStatut())) { %>
                                    <form action="<%= request.getContextPath() %>/evenements" method="post" style="display: inline;" onsubmit="return confirm('Archiver cet événement dans sa collection d\'édition ?');">
                                        <input type="hidden" name="action" value="archiver_edition">
                                        <input type="hidden" name="id" value="<%= e.getId() %>">
                                        <input type="hidden" name="edition" value="<%= e.getEdition() %>">
                                        <button type="submit" class="btn-action-small">
                                            📁 Archiver l'édition
                                        </button>
                                    </form>
                                <% } %>

                                <% if ("admin".equalsIgnoreCase(currentUser.getRole()) || "directeur".equalsIgnoreCase(currentUser.getRole())) { %>
                                    <form action="<%= request.getContextPath() %>/evenements" method="post" style="display: inline;" onsubmit="return confirm('Confirmer la suppression de cet événement ?');">
                                        <input type="hidden" name="action" value="supprimer">
                                        <input type="hidden" name="id" value="<%= e.getId() %>">
                                        <button type="submit" class="btn-action-small" style="color: #B5453E;">
                                            🗑️ Supprimer
                                        </button>
                                    </form>
                                <% } %>

                                <a href="<%= request.getContextPath() %>/communication?canal=event_<%= e.getId() %>" class="btn-action-small" style="color: var(--navy); border-color: var(--accent-2); background: rgba(197, 160, 89, 0.08);" title="Rejoindre le canal de discussion dédié à cet événement">
                                    💬 Canal de discussion
                                </a>
                            </div>
                        <% } %>
                    </div>

                    <!-- Badge latéral droit -->
                    <div>
                        <span class="badge" style="font-family: var(--font-mono); font-size: 11px; background: var(--surface-2); border: 1px solid var(--border);">
                            #<%= e.getId() %>
                        </span>
                    </div>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <div style="padding: 48px; text-align: center; background: var(--surface); border: 1px solid var(--border); border-radius: 4px;">
                <div style="font-size: 36px; margin-bottom: 12px;">📁</div>
                <h3 style="font-family: var(--font-serif); font-size: 20px; color: var(--navy); margin-bottom: 6px;">Aucun événement ne correspond à ce filtre</h3>
                <p style="font-size: 13.5px; color: var(--muted); max-width: 480px; margin: 0 auto 18px;">
                    Aucune manifestation scientifique n'a été enregistrée pour ce type ou cette édition dans les registres du laboratoire.
                </p>
                <a href="<%= request.getContextPath() %>/evenements" class="btn btn-secondary">Réinitialiser les filtres</a>
            </div>
            <% } %>
        </div>

        <!-- Section de Présentation Académique de l'Archivage par Édition -->
        <div style="margin-top: 36px; padding: 24px; background: rgba(27, 47, 74, 0.03); border: 1px solid var(--border); border-radius: 4px;">
            <div style="display: flex; gap: 16px; align-items: flex-start;">
                <div style="font-size: 28px;">🏛️</div>
                <div>
                    <h4 style="font-family: var(--font-serif); font-size: 18px; margin: 0 0 6px; color: var(--navy);">
                        Archivage Scientifique & Mémoire des Éditions
                    </h4>
                    <p style="font-size: 13.5px; color: var(--muted); margin: 0; line-height: 1.55;">
                        Conformément au règlement du laboratoire LIAS, chaque manifestation (conférence, séminaire ou atelier) est archivée par édition annuelle. Cet archivage pérenne conserve l'ensemble des actes, procès-verbaux d'ateliers, programmes scientifiques et la désignation des organisateurs pour le bilan quadriennal du laboratoire.
                    </p>
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

<!-- ========================================================================= -->
<!-- 1. MODAL : CRÉATION D'ÉVÉNEMENT                                  -->
<!-- ========================================================================= -->
<div id="addEventModal" class="modal-overlay">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">+ Créer un Événement Scientifique</h3>
            <button type="button" class="modal-close" onclick="closeModal('addEventModal')">✕</button>
        </div>
        <form action="<%= request.getContextPath() %>/evenements" method="post">
            <input type="hidden" name="action" value="creer">

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Titre de la manifestation scientifique *</label>
                <input type="text" name="titre" class="form-control" placeholder="ex: Journée Nationale sur le Big Data et l'IA Fondative..." required>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Type d'événement *</label>
                    <select name="type" class="form-control" required>
                        <option value="Conférence">🎙️ Conférence</option>
                        <option value="Séminaire">🎓 Séminaire</option>
                        <option value="Workshop">💻 Workshop</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Édition (Archivage par édition) *</label>
                    <input type="text" name="edition" class="form-control" placeholder="ex: Édition 2026, 5e Édition" value="Édition 2026" required>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Date de tenue *</label>
                    <input type="date" name="date" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Lieu / Salle *</label>
                    <input type="text" name="lieu" class="form-control" placeholder="Amphi Al-Kindi / Salle des Thèses" required>
                </div>
            </div>

            <!-- Affectation d'organisateur -->
            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Affectation d'organisateur (Membres du LIAS) *</label>
                <select name="organisateur" class="form-control" required>
                    <option value="">-- Choisir un membre responsable parmi les chercheurs --</option>
                    <% if (membres != null) {
                        for (Member m : membres) { %>
                            <option value="<%= m.getFullName() %>"><%= m.getFullName() %> (<%= m.getStatus() %> - <%= m.getRole() %>)</option>
                    <%  }
                    } %>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Programme & Planning (Organisation)</label>
                <textarea name="programme" class="form-control" rows="3" placeholder="09h00: Accueil & Émargement&#10;10h00: Conférence plénière&#10;14h00: Sessions doctorants et débats"></textarea>
            </div>

            <div class="form-group" style="margin-bottom: 18px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Description & Thématiques abordées</label>
                <textarea name="description" class="form-control" rows="2" placeholder="Objectifs scientifiques, public cible et laboratoires partenaires invités..."></textarea>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('addEventModal')">Annuler</button>
                <button type="submit" class="btn btn-primary">Enregistrer et programmer →</button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================================================= -->
<!-- 2. MODAL : AFFECTATION D'ORGANISATEUR                          -->
<!-- ========================================================================= -->
<div id="affecterModal" class="modal-overlay">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">👤 Affectation d'Organisateurs</h3>
            <button type="button" class="modal-close" onclick="closeModal('affecterModal')">✕</button>
        </div>
        <form action="<%= request.getContextPath() %>/evenements" method="post">
            <input type="hidden" name="action" value="affecter_organisateur">
            <input type="hidden" id="affecterEventId" name="id">

            <p style="font-size: 13.5px; color: var(--muted); margin-bottom: 16px;">
                Désignez le membre responsable de la coordination de l'événement : <strong id="affecterEventTitre" style="color: var(--ink);"></strong>
            </p>

            <div class="form-group" style="margin-bottom: 18px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Sélectionner le nouveau coordonnateur scientifique *</label>
                <select id="affecterSelectOrganisateur" name="organisateur" class="form-control" required>
                    <option value="">-- Choisir un membre du laboratoire --</option>
                    <% if (membres != null) {
                        for (Member m : membres) { %>
                            <option value="<%= m.getFullName() %>"><%= m.getFullName() %> (<%= m.getStatus() %> · <%= m.getRole() %>)</option>
                    <%  }
                    } %>
                </select>
            </div>

            <div style="padding: 12px; background: rgba(237, 229, 211, 0.3); border-radius: 4px; font-size: 12.5px; color: var(--muted); margin-bottom: 18px;">
                ℹ️ Cette désignation officielle notifiera le membre et inscrira son rôle dans les actes d'organisation de la manifestation.
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('affecterModal')">Annuler</button>
                <button type="submit" class="btn btn-primary">Valider l'affectation →</button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================================================= -->
<!-- 3. MODAL : GESTION DE L'ORGANISATION                          -->
<!-- ========================================================================= -->
<div id="organisationModal" class="modal-overlay">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">⚙️ Gérer l'Organisation de l'Événement</h3>
            <button type="button" class="modal-close" onclick="closeModal('organisationModal')">✕</button>
        </div>
        <form action="<%= request.getContextPath() %>/evenements" method="post">
            <input type="hidden" name="action" value="modifier_organisation">
            <input type="hidden" id="orgEventId" name="id">

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Titre de la manifestation *</label>
                <input type="text" id="orgTitre" name="titre" class="form-control" required>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Type</label>
                    <select id="orgType" name="type" class="form-control">
                        <option value="Conférence">🎙️ Conférence</option>
                        <option value="Séminaire">🎓 Séminaire</option>
                        <option value="Workshop">💻 Workshop</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Édition</label>
                    <input type="text" id="orgEdition" name="edition" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Statut</label>
                    <select id="orgStatut" name="statut" class="form-control">
                        <option value="À venir">À venir</option>
                        <option value="En cours">En cours</option>
                        <option value="Passé">Passé</option>
                        <option value="Archivé">Archivé</option>
                    </select>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Date de l'événement *</label>
                    <input type="date" id="orgDate" name="date" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Lieu / Salle *</label>
                    <input type="text" id="orgLieu" name="lieu" class="form-control" required>
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Organisateur affecté *</label>
                <select id="orgOrganisateur" name="organisateur" class="form-control" required>
                    <% if (membres != null) {
                        for (Member m : membres) { %>
                            <option value="<%= m.getFullName() %>"><%= m.getFullName() %></option>
                    <%  }
                    } %>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Programme & Logistique de la journée</label>
                <textarea id="orgProgramme" name="programme" class="form-control" rows="3"></textarea>
            </div>

            <div class="form-group" style="margin-bottom: 18px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Description scientifique</label>
                <textarea id="orgDescription" name="description" class="form-control" rows="2"></textarea>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('organisationModal')">Annuler</button>
                <button type="submit" class="btn btn-primary">Mettre à jour l'organisation →</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openAddEventModal() {
        document.getElementById('addEventModal').classList.add('active');
    }

    function openAffecterModal(id, titre, currentOrg) {
        document.getElementById('affecterEventId').value = id;
        document.getElementById('affecterEventTitre').innerText = titre;
        var sel = document.getElementById('affecterSelectOrganisateur');
        if (currentOrg && sel) {
            for (var i = 0; i < sel.options.length; i++) {
                if (sel.options[i].value === currentOrg) {
                    sel.selectedIndex = i;
                    break;
                }
            }
        }
        document.getElementById('affecterModal').classList.add('active');
    }

    function openOrganisationModal(id, titre, type, date, lieu, desc, prog, org, statut, edition) {
        document.getElementById('orgEventId').value = id;
        document.getElementById('orgTitre').value = titre;
        document.getElementById('orgType').value = type;
        document.getElementById('orgDate').value = date;
        document.getElementById('orgLieu').value = lieu;
        document.getElementById('orgDescription').value = desc;
        document.getElementById('orgProgramme').value = prog;
        document.getElementById('orgStatut').value = statut;
        document.getElementById('orgEdition').value = edition;

        var sel = document.getElementById('orgOrganisateur');
        if (org && sel) {
            for (var i = 0; i < sel.options.length; i++) {
                if (sel.options[i].value === org) {
                    sel.selectedIndex = i;
                    break;
                }
            }
        }
        document.getElementById('organisationModal').classList.add('active');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('active');
    }

    function filterByEdition(edition) {
        if (!edition) {
            window.location.href = '<%= request.getContextPath() %>/evenements';
        } else {
            window.location.href = '<%= request.getContextPath() %>/evenements?edition=' + encodeURIComponent(edition);
        }
    }

    function closeToast() {
        var toast = document.getElementById("appToast");
        if (toast) {
            toast.classList.add("toast-hide");
            setTimeout(function() { toast.remove(); }, 350);
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        var toast = document.getElementById("appToast");
        if (toast) {
            setTimeout(function() { closeToast(); }, 5000);
            if (window.history.replaceState) {
                var cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                window.history.replaceState({ path: cleanUrl }, '', cleanUrl);
            }
        }
    });

    // Fermer les modaux avec Échap
    window.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeModal('addEventModal');
            closeModal('affecterModal');
            closeModal('organisationModal');
        }
    });
</script>

</body>
</html>

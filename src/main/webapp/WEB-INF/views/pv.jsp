<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.ReunionPV"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    boolean canManage = (currentUser != null && ("directeur".equalsIgnoreCase(currentUser.getRole()) || "permanent".equalsIgnoreCase(currentUser.getRole()) || "admin".equalsIgnoreCase(currentUser.getRole())));

    List<ReunionPV> pvs = (List<ReunionPV>) request.getAttribute("pvs");
    List<ReunionPV> allPvs = (List<ReunionPV>) request.getAttribute("allPvs");
    String msg = request.getParameter("success");
    String error = request.getParameter("error");

    Integer totalCount = (Integer) request.getAttribute("totalCount");
    if (totalCount == null) totalCount = (pvs != null ? pvs.size() : 0);

    Integer countAG = (Integer) request.getAttribute("countAG");
    if (countAG == null) countAG = 0;
    Integer countCL = (Integer) request.getAttribute("countCL");
    if (countCL == null) countCL = 0;
    Integer countCE = (Integer) request.getAttribute("countCE");
    if (countCE == null) countCE = 0;
    Integer countPlanifiees = (Integer) request.getAttribute("countPlanifiees");
    if (countPlanifiees == null) countPlanifiees = 0;
    Integer countArchivees = (Integer) request.getAttribute("countArchivees");
    if (countArchivees == null) countArchivees = 0;

    String selectedType = (String) request.getAttribute("selectedType");
    if (selectedType == null) selectedType = "all";
    String selectedStatut = (String) request.getAttribute("selectedStatut");
    if (selectedStatut == null) selectedStatut = "all";
    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) searchQuery = "";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Procès-Verbaux de Réunions</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        .pv-badge {
            display: inline-flex;
            align-items: center;
            padding: 3px 9px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .pv-badge-ag { background: #EEF2FF; color: #4338CA; border: 1px solid #C7D2FE; }
        .pv-badge-cl { background: #F0FDF4; color: #15803D; border: 1px solid #BBF7D0; }
        .pv-badge-ce { background: #FFFBEB; color: #B45309; border: 1px solid #FDE68A; }
        .pv-badge-planifiee { background: #FEF3C7; color: #92400E; border: 1px solid #FCD34D; }
        .pv-badge-archivee { background: #ECFDF5; color: #047857; border: 1px solid #A7F3D0; }

        .pv-tab-btn {
            padding: 8px 16px;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            color: var(--muted, #6B7280);
            background: transparent;
            border: 1px solid var(--border, #E5E7EB);
            white-space: nowrap;
            transition: all 0.2s;
        }
        .pv-tab-btn:hover {
            color: var(--navy-primary, #0B192C);
            background: #F8FAFC;
        }
        .pv-tab-btn.active {
            background: var(--navy-primary, #0B192C);
            color: #FFFFFF;
            border-color: var(--navy-primary, #0B192C);
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

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <span class="eyebrow" style="color:var(--gold-accent); font-weight:700;">Gouvernance & Mémoire Institutionnelle</span>
                        <h1 class="page-title">Procès-Verbaux de Réunions (PV)</h1>
                        <p class="page-sub">
                            Création des séances, structuration de l'ordre du jour, upload des documents signés et archivage légal du LIAS.
                        </p>
                    </div>
                    <div style="display:flex; gap:10px; flex-wrap:wrap;">
                        <% if (canManage) { %>
                            <button type="button" class="btn btn-secondary" onclick="openUploadModal()">
                                ⤓ Upload d'un PV
                            </button>
                            <button type="button" class="btn btn-primary" onclick="openCreateModal()">
                                + Créer une Réunion & Ordre du Jour
                            </button>
                        <% } %>
                    </div>
                </div>

                <!-- Alert Messages -->
                <% if ("created".equals(msg)) { %>
                    <div class="alert alert-success" style="background:#ECFDF5; border-right:4px solid #059669; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#065F46; font-size:13.5px;">
                        ✓ La réunion et son ordre du jour officiel ont été enregistrés avec succès dans le registre institutionnel.
                    </div>
                <% } else if ("uploaded".equals(msg)) { %>
                    <div class="alert alert-success" style="background:#ECFDF5; border-right:4px solid #059669; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#065F46; font-size:13.5px;">
                        ✓ Le fichier officiel du Procès-Verbal a été téléversé et archivé sous sceau officiel.
                    </div>
                <% } else if ("deleted".equals(msg)) { %>
                    <div class="alert alert-info" style="background:#EFF6FF; border-right:4px solid #3B82F6; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#1E40AF; font-size:13.5px;">
                        ✓ La séance sélectionnée a été retirée du registre officiel.
                    </div>
                <% } else if ("unauthorized".equals(error)) { %>
                    <div class="alert alert-danger" style="background:#FEF2F2; border-right:4px solid #DC2626; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#991B1B; font-size:13.5px;">
                        ✕ Vous n'avez pas l'habilitation requise pour consigner ou modifier un procès-verbal officiel.
                    </div>
                <% } %>

                <!-- Stat Cards -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 16px; margin-bottom: 25px;">
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid var(--navy-primary);">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Total Délibérations</div>
                        <div style="font-size: 28px; font-weight: 800; color: var(--navy-primary); margin-top: 4px;"><%= totalCount %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Séances consignées au LIAS</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #4338CA;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Assemblées Générales</div>
                        <div style="font-size: 28px; font-weight: 800; color: #4338CA; margin-top: 4px;"><%= countAG %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Sessions plénières annuelles</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #15803D;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Conseils de Laboratoire</div>
                        <div style="font-size: 28px; font-weight: 800; color: #15803D; margin-top: 4px;"><%= countCL %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Validation thèses & budgets</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #D97706;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">Sessions Planifiées</div>
                        <div style="font-size: 28px; font-weight: 800; color: #D97706; margin-top: 4px;"><%= countPlanifiees %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Ordre du jour en diffusion</div>
                    </div>
                    <div class="card" style="padding: 18px 22px; border-top: 3px solid #059669;">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; letter-spacing: 0.5px;">PV Archivés & Signés</div>
                        <div style="font-size: 28px; font-weight: 800; color: #059669; margin-top: 4px;"><%= countArchivees %></div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Coffre-fort légal FSBM</div>
                    </div>
                </div>

                <!-- Filters & Search Toolbar -->
                <div class="card" style="padding: 16px 20px; margin-bottom: 22px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; gap: 16px; flex-wrap: wrap;">
                        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                            <a href="<%= request.getContextPath() %>/pv" class="pv-tab-btn <%= ("all".equals(selectedType) && "all".equals(selectedStatut)) ? "active" : "" %>">
                                Tout le registre (<%= totalCount %>)
                            </a>
                            <a href="<%= request.getContextPath() %>/pv?type=Conseil de Laboratoire" class="pv-tab-btn <%= "Conseil de Laboratoire".equals(selectedType) ? "active" : "" %>">
                                Conseils de Labo (<%= countCL %>)
                            </a>
                            <a href="<%= request.getContextPath() %>/pv?type=Assemblée Générale" class="pv-tab-btn <%= "Assemblée Générale".equals(selectedType) ? "active" : "" %>">
                                Assemblées Générales (<%= countAG %>)
                            </a>
                            <a href="<%= request.getContextPath() %>/pv?type=Conseil Extraordinaire" class="pv-tab-btn <%= "Conseil Extraordinaire".equals(selectedType) ? "active" : "" %>">
                                Conseils Extraordinaires (<%= countCE %>)
                            </a>
                            <a href="<%= request.getContextPath() %>/pv?statut=PLANIFIEE" class="pv-tab-btn <%= "PLANIFIEE".equalsIgnoreCase(selectedStatut) ? "active" : "" %>">
                                Planifiées (<%= countPlanifiees %>)
                            </a>
                            <a href="<%= request.getContextPath() %>/pv?statut=ARCHIVEE" class="pv-tab-btn <%= "ARCHIVEE".equalsIgnoreCase(selectedStatut) ? "active" : "" %>">
                                Archivés & Signés (<%= countArchivees %>)
                            </a>
                        </div>

                        <form action="<%= request.getContextPath() %>/pv" method="GET" style="display: flex; gap: 8px; margin: 0;">
                            <input type="text" name="q" value="<%= searchQuery %>" placeholder="Recherche séance, ordre du jour, signataire..." class="form-control" style="width: 260px; font-size: 13px;">
                            <button type="submit" class="btn btn-secondary" style="padding: 6px 14px; font-size: 13px;">Filtrer</button>
                        </form>
                    </div>
                </div>

                <!-- Table des Procès-Verbaux -->
                <div class="card">
                    <div class="card-header" style="padding: 18px 24px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <h3 style="font-size: 17px; font-weight: 800; color: var(--navy-primary); margin: 0;">
                                Registre Officiel des Procès-Verbaux & Délibérations
                            </h3>
                            <span style="font-size: 12px; color: var(--text-muted);">
                                <%= (pvs != null ? pvs.size() : 0) %> réunion(s) affichée(s) selon vos critères
                            </span>
                        </div>
                    </div>
                    <div class="table-container" style="overflow-x: auto;">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="min-width: 220px;">Séance & Nature</th>
                                    <th style="min-width: 150px;">Date & Lieu</th>
                                    <th style="min-width: 280px;">Ordre du Jour & Décisions</th>
                                    <th style="min-width: 170px;">Signataires & Bureau</th>
                                    <th>Statut</th>
                                    <th style="text-align: right; min-width: 180px;">Actions & Document</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (pvs != null && !pvs.isEmpty()) { 
                                    for (ReunionPV pv : pvs) { 
                                        String typeBadgeClass = "pv-badge-cl";
                                        if (pv.getTypeReunion() != null) {
                                            if (pv.getTypeReunion().contains("Générale")) typeBadgeClass = "pv-badge-ag";
                                            else if (pv.getTypeReunion().contains("Extraordinaire")) typeBadgeClass = "pv-badge-ce";
                                        }
                                        boolean isArchive = "ARCHIVEE".equalsIgnoreCase(pv.getStatut());
                                %>
                                    <tr>
                                        <td>
                                            <span class="pv-badge <%= typeBadgeClass %>" style="margin-bottom: 4px;">
                                                <%= pv.getTypeReunion() != null ? pv.getTypeReunion() : "Conseil de Laboratoire" %>
                                            </span>
                                            <div style="font-weight: 700; color: var(--navy-primary); font-size: 14px; margin-top: 3px;">
                                                <%= pv.getTitre() %>
                                            </div>
                                            <div style="font-size: 11px; color: var(--text-muted); font-family: 'JetBrains Mono', monospace;">
                                                Réf: PV-LIAS-<%= pv.getDateReunion() != null ? pv.getDateReunion().getYear() : 2026 %>-00<%= pv.getId() %>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-family: 'JetBrains Mono', monospace; font-size: 13px; font-weight: 600; color: var(--navy-primary);">
                                                <%= pv.getDateReunion() %>
                                            </div>
                                            <div style="font-size: 11.5px; color: var(--text-muted);">
                                                <%= pv.getHeure() != null ? pv.getHeure() : "10:00 - 12:30" %>
                                            </div>
                                            <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">
                                                📍 <%= pv.getLieu() != null ? pv.getLieu() : "Salle LIAS" %>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="max-height: 70px; overflow: hidden; text-overflow: ellipsis; font-size: 12.5px; color: var(--text-color); line-height: 1.5; white-space: pre-line;">
                                                <%= pv.getOrdreDuJour() != null && !pv.getOrdreDuJour().isEmpty() ? pv.getOrdreDuJour() : "— Aucun point renseigné —" %>
                                            </div>
                                            <button type="button" class="btn btn-ghost btn-sm" 
                                                    style="padding: 2px 6px; font-size: 11px; margin-top: 4px; color: var(--gold-accent); text-decoration: underline;"
                                                    onclick="showAgendaModal('<%= pv.getId() %>', '<%= pv.getTitre().replace("'", "\\'") %>', '<%= (pv.getOrdreDuJour() != null ? pv.getOrdreDuJour().replace("\n", "\\n").replace("'", "\\'") : "") %>')">
                                                Voir l'ordre du jour complet →
                                            </button>
                                        </td>
                                        <td>
                                            <div style="font-weight: 700; font-size: 13px; color: var(--navy-primary);">
                                                <%= pv.getDirecteurSignataire() != null ? pv.getDirecteurSignataire() : "Prof. Ibtissam Essadiki" %>
                                            </div>
                                            <div style="font-size: 11px; color: var(--text-muted);">Directeur / Président</div>
                                            <div style="font-size: 11.5px; color: var(--text-muted); margin-top: 3px;">
                                                Rapporteur: <%= pv.getSecretaireSeance() != null ? pv.getSecretaireSeance() : "Secrétariat LIAS" %>
                                            </div>
                                        </td>
                                        <td>
                                            <% if (isArchive) { %>
                                                <span class="pv-badge pv-badge-archivee">
                                                    ✓ Archivé & Signé
                                                </span>
                                            <% } else { %>
                                                <span class="pv-badge pv-badge-planifiee">
                                                    ⏳ Planifiée
                                                </span>
                                            <% } %>
                                        </td>
                                        <td style="text-align: right;">
                                            <div style="display: inline-flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end;">
                                                <!-- Visualisation direct document certifié -->
                                                <a href="<%= request.getContextPath() %>/pv?action=consulter&id=<%= pv.getId() %>" target="_blank" 
                                                   class="btn btn-secondary btn-sm" style="font-size: 11px; padding: 4px 8px;" title="Consulter le texte officiel du PV">
                                                    👁 Visualiser
                                                </a>
                                                <!-- Téléchargement officiel -->
                                                <a href="<%= request.getContextPath() %>/pv?action=telecharger&id=<%= pv.getId() %>" 
                                                   class="btn btn-primary btn-sm" style="font-size: 11px; padding: 4px 8px;" title="Télécharger le fichier PV scellé">
                                                    ⤓ Télécharger
                                                </a>
                                                <!-- Upload PV pour réunion existante -->
                                                <% if (canManage) { %>
                                                    <button type="button" class="btn btn-ghost btn-sm" style="font-size: 11px; padding: 4px 6px;"
                                                            title="Attacher ou remplacer le fichier numérisé"
                                                            onclick="openUploadFor('<%= pv.getId() %>', '<%= pv.getTitre().replace("'", "\\'") %>')">
                                                        📁 Upload
                                                    </button>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                <%  } 
                                } else { %>
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: 48px; color: var(--text-muted);">
                                            Aucune réunion ou procès-verbal trouvé pour les filtres sélectionnés.
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>
</div>

<!-- MODAL 1: CRÉER UNE RÉUNION & ORDRE DU JOUR -->
<% if (canManage) { %>
<div id="modalCreateMeeting" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.6); z-index:9999; align-items:center; justify-content:center; backdrop-filter:blur(3px); padding:20px;">
    <div class="card" style="width: 100%; max-width: 680px; max-height:90vh; overflow-y:auto; padding: 28px; background: #FFF; border-radius: 8px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px;">
            <div>
                <span style="font-size: 11px; text-transform: uppercase; color: var(--gold-accent); font-weight: 700;">Procès-verbaux</span>
                <h3 style="margin:2px 0 0; font-size: 18px; font-weight: 800; color: var(--navy-primary);">Création d'une Réunion & Ordre du Jour</h3>
            </div>
            <button type="button" onclick="closeCreateModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-muted);">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/pv" method="POST">
            <input type="hidden" name="action" value="creer_reunion">

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-weight:700; font-size:12px;">Titre de la Séance / Réunion *</label>
                <input type="text" name="titre" class="form-control" placeholder="ex: Conseil de Laboratoire - Arbitrage Budgétaire & Projets 2026" required>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Type de Réunion *</label>
                    <select name="typeReunion" class="form-control" required>
                        <option value="Conseil de Laboratoire">Conseil de Laboratoire (CL)</option>
                        <option value="Assemblée Générale">Assemblée Générale (AG)</option>
                        <option value="Conseil Extraordinaire">Conseil Extraordinaire (CE)</option>
                        <option value="Commission Doctorale">Commission Doctorale (CD)</option>
                        <option value="Comité de Direction">Comité de Direction</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Statut Initial *</label>
                    <select name="statut" class="form-control" required>
                        <option value="PLANIFIEE">Séance Planifiée (Ordre du jour préliminaire)</option>
                        <option value="ARCHIVEE" selected>Séance Tenue & PV Archivé</option>
                    </select>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Date de Réunion *</label>
                    <input type="date" name="dateReunion" class="form-control" required value="<%= java.time.LocalDate.now() %>">
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Horaires</label>
                    <input type="text" name="heure" class="form-control" value="10:00 - 12:30">
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Lieu / Salle</label>
                    <input type="text" name="lieu" class="form-control" value="Salle de Réunion LIAS - FSBM">
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Présidence / Direction Signataire *</label>
                    <input type="text" name="directeurSignataire" class="form-control" value="Prof. Ibtissam Essadiki" required>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-weight:700; font-size:12px;">Secrétaire de Séance / Rapporteur</label>
                    <input type="text" name="secretaireSeance" class="form-control" value="Prof. Mohamed Benali">
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-weight:700; font-size:12px; display:flex; justify-content:space-between;">
                    <span>Ordre du Jour & Décisions Statutaires *</span>
                    <span style="font-weight:normal; color:var(--text-muted); font-size:11px;">Points abordés et délibérations</span>
                </label>
                <textarea name="ordreDuJour" class="form-control" rows="5" placeholder="1. Approbation du procès-verbal de la session précédente.&#10;2. Bilan des activités scientifiques et publications déposées.&#10;3. Répartition budgétaire et dotations matérielles.&#10;4. Validation des autorisations de soutenance.&#10;5. Divers et calendrier des prochaines séances." required>1. Approbation du procès-verbal de la séance précédente.
2. Bilan des activités scientifiques et arbitrage des publications.
3. Examen des besoins matériels et affectation des équipements.
4. Calendrier des soutenances de thèse et colloques.</textarea>
            </div>

            <div class="form-group" style="margin-bottom: 24px;">
                <label class="form-label" style="font-weight:700; font-size:12px;">Référence Document Numérique (Upload / Archive)</label>
                <input type="text" name="cheminFichierPV" class="form-control" value="archives/pv_seance_mars2026.pdf" placeholder="ex: archives/pv_session_officielle.pdf">
                <small style="color:var(--text-muted); font-size:11px;">Le document officiel généré et téléchargeable sera automatiquement certifié par le système.</small>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px; border-top:1px solid var(--border-color); padding-top:16px;">
                <button type="button" class="btn btn-secondary" onclick="closeCreateModal()">Annuler</button>
                <button type="submit" class="btn btn-primary">Enregistrer au Registre</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL 2: UPLOAD D'UN PV SIGNÉ -->
<div id="modalUploadPV" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.6); z-index:9999; align-items:center; justify-content:center; backdrop-filter:blur(3px); padding:20px;">
    <div class="card" style="width: 100%; max-width: 520px; padding: 28px; background: #FFF; border-radius: 8px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 18px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
            <h3 style="margin:0; font-size: 18px; font-weight: 800; color: var(--navy-primary);">Upload & Archivage d'un PV Signé</h3>
            <button type="button" onclick="closeUploadModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-muted);">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/pv" method="POST">
            <input type="hidden" name="action" value="upload_pv">

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-weight:700; font-size:12px;">Sélectionner la Réunion *</label>
                <select id="uploadMeetingSelect" name="reunionId" class="form-control" required>
                    <% if (allPvs != null) {
                        for (ReunionPV p : allPvs) { %>
                            <option value="<%= p.getId() %>"><%= p.getDateReunion() %> — <%= p.getTitre() %> (<%= p.getStatut() %>)</option>
                    <%  }
                    } %>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-weight:700; font-size:12px;">Fichier du Procès-Verbal Scanné / PDF *</label>
                <input type="file" class="form-control" style="padding:8px;" onchange="fillUploadName(this)">
                <input type="text" id="uploadFilenameInput" name="nomFichier" class="form-control" style="margin-top:6px;" value="archives/pv_signe_direction_lias.pdf" placeholder="Nom ou chemin d'archivage">
            </div>

            <div class="form-group" style="margin-bottom: 22px;">
                <label class="form-label" style="font-weight:700; font-size:12px;">Statut d'Archivage</label>
                <input type="text" name="statut" class="form-control" value="ARCHIVEE" readonly style="background:#F3F4F6;">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" class="btn btn-secondary" onclick="closeUploadModal()">Annuler</button>
                <button type="submit" class="btn btn-primary">Valider le Dépôt du PV</button>
            </div>
        </form>
    </div>
</div>
<% } %>

<!-- MODAL 3: CONSULTER L'ORDRE DU JOUR COMPLET -->
<div id="modalAgenda" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.6); z-index:9999; align-items:center; justify-content:center; backdrop-filter:blur(3px); padding:20px;">
    <div class="card" style="width: 100%; max-width: 600px; padding: 28px; background: #FFF; border-radius: 8px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 14px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
            <div>
                <span style="font-size: 11px; text-transform: uppercase; color: var(--gold-accent); font-weight: 700;">Ordre du Jour & Décisions</span>
                <h3 id="modalAgendaTitle" style="margin:2px 0 0; font-size: 17px; font-weight: 800; color: var(--navy-primary);"></h3>
            </div>
            <button type="button" onclick="closeAgendaModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-muted);">&times;</button>
        </div>

        <div id="modalAgendaBody" style="font-size: 13.5px; line-height: 1.6; color: var(--ink); background:#F8FAFC; border:1px solid var(--border); border-radius:4px; padding:16px; white-space:pre-line; max-height:55vh; overflow-y:auto; font-family:'Inter', sans-serif;">
        </div>

        <div style="display:flex; justify-content:flex-end; margin-top: 18px;">
            <button type="button" class="btn btn-secondary" onclick="closeAgendaModal()">Fermer</button>
        </div>
    </div>
</div>

<script>
    function openCreateModal() {
        var m = document.getElementById('modalCreateMeeting');
        if (m) m.style.display = 'flex';
    }
    function closeCreateModal() {
        var m = document.getElementById('modalCreateMeeting');
        if (m) m.style.display = 'none';
    }
    function openUploadModal() {
        var m = document.getElementById('modalUploadPV');
        if (m) m.style.display = 'flex';
    }
    function closeUploadModal() {
        var m = document.getElementById('modalUploadPV');
        if (m) m.style.display = 'none';
    }
    function openUploadFor(id, title) {
        var sel = document.getElementById('uploadMeetingSelect');
        if (sel) sel.value = id;
        openUploadModal();
    }
    function fillUploadName(input) {
        if (input.files && input.files[0]) {
            var fn = input.files[0].name;
            var inp = document.getElementById('uploadFilenameInput');
            if (inp) inp.value = "archives/" + fn;
        }
    }
    function showAgendaModal(id, title, content) {
        document.getElementById('modalAgendaTitle').innerText = title;
        document.getElementById('modalAgendaBody').innerText = content || "Aucun détail d'ordre du jour disponible pour cette séance.";
        document.getElementById('modalAgenda').style.display = 'flex';
    }
    function closeAgendaModal() {
        document.getElementById('modalAgenda').style.display = 'none';
    }
</script>

</body>
</html>

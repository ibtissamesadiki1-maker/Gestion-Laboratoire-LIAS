<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.lias.beans.DocumentLabo"%>
<%@ page import="com.lias.beans.Evenement"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    String userRole = currentUser != null ? currentUser.getRole() : "visiteur";
    boolean canUpload = currentUser != null && !"visiteur".equalsIgnoreCase(userRole);

    List<DocumentLabo> allDocs = (List<DocumentLabo>) request.getAttribute("allDocs");
    if (allDocs == null) allDocs = new ArrayList<>();

    List<DocumentLabo> currentDocs = (List<DocumentLabo>) request.getAttribute("currentDocs");
    if (currentDocs == null) currentDocs = new ArrayList<>();

    List<DocumentLabo> recentHistorique = (List<DocumentLabo>) request.getAttribute("recentHistorique");
    if (recentHistorique == null) recentHistorique = new ArrayList<>();

    List<Evenement> evenementsList = (List<Evenement>) request.getAttribute("evenementsList");
    if (evenementsList == null) evenementsList = new ArrayList<>();

    List<String> distinctEvents = (List<String>) request.getAttribute("distinctEvents");
    if (distinctEvents == null) distinctEvents = new ArrayList<>();

    String searchQuery = (String) request.getAttribute("searchQuery");
    String selectedCategorie = (String) request.getAttribute("selectedCategorie");
    String selectedEvenement = (String) request.getAttribute("selectedEvenement");
    String selectedAnnee = (String) request.getAttribute("selectedAnnee");

    Number countFinancementsNum = (Number) request.getAttribute("countFinancements");
    Number countProgrammesNum = (Number) request.getAttribute("countProgrammes");
    Number countAttestationsNum = (Number) request.getAttribute("countAttestations");
    Number countRapportsNum = (Number) request.getAttribute("countRapports");
    Number countAdministratifsNum = (Number) request.getAttribute("countAdministratifs");

    long countFinancements = countFinancementsNum != null ? countFinancementsNum.longValue() : 0L;
    long countProgrammes = countProgrammesNum != null ? countProgrammesNum.longValue() : 0L;
    long countAttestations = countAttestationsNum != null ? countAttestationsNum.longValue() : 0L;
    long countRapports = countRapportsNum != null ? countRapportsNum.longValue() : 0L;
    long countAdministratifs = countAdministratifsNum != null ? countAdministratifsNum.longValue() : 0L;

    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LIAS — Archive Documentaire</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        .kpi-docs-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 14px;
            margin-bottom: 24px;
        }
        .kpi-doc-card {
            background: var(--surface);
            border: 1px solid var(--border);
            padding: 14px 16px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.2s;
            text-decoration: none;
            color: inherit;
        }
        .kpi-doc-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border-color: var(--navy);
        }
        .kpi-doc-card.active {
            border-left: 4px solid var(--navy);
            background: rgba(27, 47, 74, 0.04);
        }
        .kpi-doc-icon {
            font-size: 24px;
            margin-right: 10px;
        }
        .kpi-doc-num {
            font-family: var(--font-serif);
            font-size: 24px;
            font-weight: 600;
            color: var(--navy);
            line-height: 1;
        }
        .kpi-doc-label {
            font-family: var(--font-mono);
            font-size: 10px;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--muted);
            margin-top: 3px;
        }

        /* Filter Box */
        .filter-search-box {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 4px;
            padding: 18px 20px;
            margin-bottom: 22px;
        }
        .filter-form-grid {
            display: grid;
            grid-template-columns: 2fr 1.5fr 1.5fr 1fr auto;
            gap: 12px;
            align-items: flex-end;
        }

        /* Table & Cards */
        .docs-table-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 4px;
            overflow: hidden;
            margin-bottom: 24px;
        }
        .docs-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13.5px;
        }
        .docs-table th {
            background: var(--surface-2);
            padding: 12px 16px;
            text-align: left;
            font-family: var(--font-mono);
            font-size: 11px;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--muted);
            border-bottom: 1px solid var(--border);
        }
        .docs-table td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        .docs-table tr:hover td {
            background: rgba(237, 229, 211, 0.25);
        }

        .file-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 38px;
            height: 38px;
            border-radius: 3px;
            font-family: var(--font-mono);
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            flex-shrink: 0;
        }
        .file-badge-pdf { background: #FDE8E8; color: #9B1C1C; border: 1px solid #F8B4B4; }
        .file-badge-docx { background: #E1EFFE; color: #1E429F; border: 1px solid #A4CAFE; }
        .file-badge-xlsx { background: #DEF7EC; color: #03543F; border: 1px solid #84E1BC; }
        .file-badge-zip { background: #FEF08A; color: #713F12; border: 1px solid #FDE047; }

        .cat-tag {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 500;
            white-space: nowrap;
        }
        .cat-tag-financement { background: #DEF7EC; color: #03543F; border: 1px solid #84E1BC; }
        .cat-tag-programme { background: #E1EFFE; color: #1E429F; border: 1px solid #A4CAFE; }
        .cat-tag-attestation { background: #FEF08A; color: #713F12; border: 1px solid #FDE047; }
        .cat-tag-rapport { background: #F3E8FF; color: #6B21A8; border: 1px solid #D8B4FE; }
        .cat-tag-admin { background: #EDF2F7; color: #2D3748; border: 1px solid #CBD5E0; }

        .btn-download {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: var(--navy);
            color: var(--cream);
            border-radius: 3px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 500;
            transition: all 0.15s;
        }
        .btn-download:hover {
            background: var(--navy-dark);
            color: #fff;
            transform: translateY(-1px);
        }

        /* Historisation Timeline */
        .historique-box {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 4px;
            padding: 20px 24px;
            margin-top: 24px;
        }
        .timeline-doc-item {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 10px 0;
            border-bottom: 1px dashed var(--border);
            font-size: 13px;
        }
        .timeline-doc-item:last-child {
            border-bottom: none;
        }
        .timeline-doc-date {
            font-family: var(--font-mono);
            font-size: 11px;
            color: var(--muted);
            width: 90px;
            flex-shrink: 0;
        }

        @media (max-width: 1000px) {
            .kpi-docs-grid { grid-template-columns: repeat(2, 1fr); }
            .filter-form-grid { grid-template-columns: 1fr; }
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

        <!-- EN-TÊTE ÉDITORIAL OFFICIEL -->
        <div class="page-header" style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
            <div>
                <span class="eyebrow">Patrimoine Scientifique & Mémoire Légale</span>
                <h1 class="page-title">Archivage Documentaire</h1>
                <p class="page-sub">
                    Structuration par événement et par date de l'ensemble des pièces scientifiques et administratives du laboratoire LIAS.
                </p>
            </div>
            <% if (canUpload) { %>
                <button type="button" class="btn btn-primary" onclick="openUploadModal()">
                    ⤒ Téléverser un document
                </button>
            <% } %>
        </div>

        <!-- TOAST NOTIFICATIONS -->
        <% if ("uploaded".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">✓</div>
                <div class="toast-content">
                    <div class="toast-title">Document archivé avec succès !</div>
                    <div class="toast-desc">La pièce a été rattachée à son événement, horodatée et indexée dans l'arborescence pérenne.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()">✕</button>
            </div>
        <% } else if ("deleted".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">🗑️</div>
                <div class="toast-content">
                    <div class="toast-title">Document retiré des archives</div>
                    <div class="toast-desc">L'enregistrement documentaire a été supprimé de la base de données.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()">✕</button>
            </div>
        <% } %>

        <!-- LES 5 TYPES DE DOCUMENTS OFFICIELS -->
        <div class="kpi-docs-grid">
            <a href="<%= request.getContextPath() %>/documents?categorie=Demandes+de+financement" class="kpi-doc-card <%= (selectedCategorie != null && selectedCategorie.toLowerCase().contains("financ")) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-doc-icon">💰</span>
                    <div>
                        <div class="kpi-doc-num"><%= countFinancements %></div>
                        <div class="kpi-doc-label">Financements</div>
                    </div>
                </div>
            </a>

            <a href="<%= request.getContextPath() %>/documents?categorie=Programmes" class="kpi-doc-card <%= (selectedCategorie != null && selectedCategorie.toLowerCase().contains("programm")) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-doc-icon">📋</span>
                    <div>
                        <div class="kpi-doc-num"><%= countProgrammes %></div>
                        <div class="kpi-doc-label">Programmes</div>
                    </div>
                </div>
            </a>

            <a href="<%= request.getContextPath() %>/documents?categorie=Attestations" class="kpi-doc-card <%= (selectedCategorie != null && selectedCategorie.toLowerCase().contains("attest")) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-doc-icon">📜</span>
                    <div>
                        <div class="kpi-doc-num"><%= countAttestations %></div>
                        <div class="kpi-doc-label">Attestations</div>
                    </div>
                </div>
            </a>

            <a href="<%= request.getContextPath() %>/documents?categorie=Rapports" class="kpi-doc-card <%= (selectedCategorie != null && selectedCategorie.toLowerCase().contains("rapport")) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-doc-icon">📊</span>
                    <div>
                        <div class="kpi-doc-num"><%= countRapports %></div>
                        <div class="kpi-doc-label">Rapports</div>
                    </div>
                </div>
            </a>

            <a href="<%= request.getContextPath() %>/documents?categorie=Documents+administratifs" class="kpi-doc-card <%= (selectedCategorie != null && selectedCategorie.toLowerCase().contains("admin")) ? "active" : "" %>">
                <div style="display: flex; align-items: center;">
                    <span class="kpi-doc-icon">🏛️</span>
                    <div>
                        <div class="kpi-doc-num"><%= countAdministratifs %></div>
                        <div class="kpi-doc-label">Administratifs</div>
                    </div>
                </div>
            </a>
        </div>

        <!-- RECHERCHE & STRUCTURATION : PAR ÉVÉNEMENT, PAR DATE & PAR TYPE -->
        <div class="filter-search-box">
            <form action="<%= request.getContextPath() %>/documents" method="GET" class="filter-form-grid">
                <!-- Recherche textuelle -->
                <div class="form-group" style="margin: 0;">
                    <label class="form-label" style="font-size: 11px; text-transform: uppercase;">🔍 Recherche textuelle :</label>
                    <input type="text" name="q" value="<%= searchQuery != null ? searchQuery : "" %>" 
                           placeholder="Mot-clé, nom de fichier, auteur..." class="form-control" style="font-size: 13px;">
                </div>

                <!-- Type de document (5 Types ) -->
                <div class="form-group" style="margin: 0;">
                    <label class="form-label" style="font-size: 11px; text-transform: uppercase;">Type de document :</label>
                    <select name="categorie" class="form-control" style="font-size: 13px;">
                        <option value="">-- Tous les types --</option>
                        <option value="Demandes de financement" <%= (selectedCategorie != null && selectedCategorie.contains("financ")) ? "selected" : "" %>>💰 Demandes de financement</option>
                        <option value="Programmes" <%= (selectedCategorie != null && selectedCategorie.contains("programm")) ? "selected" : "" %>>📋 Programmes</option>
                        <option value="Attestations" <%= (selectedCategorie != null && selectedCategorie.contains("attest")) ? "selected" : "" %>>📜 Attestations</option>
                        <option value="Rapports" <%= (selectedCategorie != null && selectedCategorie.contains("rapport")) ? "selected" : "" %>>📊 Rapports</option>
                        <option value="Documents administratifs" <%= (selectedCategorie != null && selectedCategorie.contains("admin")) ? "selected" : "" %>>🏛️ Documents administratifs</option>
                    </select>
                </div>

                <!-- Structuration par événement -->
                <div class="form-group" style="margin: 0;">
                    <label class="form-label" style="font-size: 11px; text-transform: uppercase;">📍 Par Événement :</label>
                    <select name="evenement" class="form-control" style="font-size: 13px;">
                        <option value="">-- Tous les événements --</option>
                        <% if (evenementsList != null) {
                            for (Evenement ev : evenementsList) { %>
                                <option value="<%= ev.getTitre() %>" <%= (selectedEvenement != null && selectedEvenement.equalsIgnoreCase(ev.getTitre())) ? "selected" : "" %>>
                                    <%= ev.getType() %> : <%= ev.getTitre() %>
                                </option>
                        <%  }
                        } %>
                        <option value="Administratif" <%= (selectedEvenement != null && selectedEvenement.contains("Admin")) ? "selected" : "" %>>🏛️ Administratif (Partenariats, PV, Conventions)</option>
                    </select>
                </div>

                <!-- Structuration par date / année -->
                <div class="form-group" style="margin: 0;">
                    <label class="form-label" style="font-size: 11px; text-transform: uppercase;">📅 Par Date (Année) :</label>
                    <select name="annee" class="form-control" style="font-size: 13px;">
                        <option value="">Toutes dates</option>
                        <option value="2026" <%= "2026".equals(selectedAnnee) ? "selected" : "" %>>Année 2026</option>
                        <option value="2025" <%= "2025".equals(selectedAnnee) ? "selected" : "" %>>Année 2025</option>
                        <option value="2024" <%= "2024".equals(selectedAnnee) ? "selected" : "" %>>Année 2024</option>
                        <option value="2023" <%= "2023".equals(selectedAnnee) ? "selected" : "" %>>Année 2023</option>
                    </select>
                </div>

                <div style="display: flex; gap: 8px;">
                    <button type="submit" class="btn btn-primary" style="padding: 9px 16px;">Filtrer</button>
                    <a href="<%= request.getContextPath() %>/documents" class="btn btn-secondary" style="padding: 9px 12px;" title="Réinitialiser">↺</a>
                </div>
            </form>
        </div>

        <!-- TABLEAU DES DOCUMENTS ARCHIVÉS -->
        <div class="docs-table-card">
            <table class="docs-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">Format</th>
                        <th>Document & Description</th>
                        <th>Type</th>
                        <th>Événement Rattaché</th>
                        <th>Date d'archivage</th>
                        <th>Auteur / Déposant</th>
                        <th style="text-align: right; width: 140px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (currentDocs != null && !currentDocs.isEmpty()) {
                        for (DocumentLabo d : currentDocs) {
                            String ext = d.getType() != null ? d.getType().toLowerCase() : "pdf";
                            String badgeClass = "file-badge-pdf";
                            if ("docx".equals(ext)) badgeClass = "file-badge-docx";
                            else if ("xlsx".equals(ext)) badgeClass = "file-badge-xlsx";
                            else if ("zip".equals(ext)) badgeClass = "file-badge-zip";

                            String catClass = "cat-tag-rapport";
                            String cat = d.getCategorie() != null ? d.getCategorie() : "Rapports";
                            if (cat.contains("financ")) catClass = "cat-tag-financement";
                            else if (cat.contains("programm")) catClass = "cat-tag-programme";
                            else if (cat.contains("attest")) catClass = "cat-tag-attestation";
                            else if (cat.contains("admin")) catClass = "cat-tag-admin";
                    %>
                    <tr>
                        <td>
                            <div class="file-badge <%= badgeClass %>"><%= ext %></div>
                        </td>
                        <td>
                            <div style="font-weight: 600; color: var(--navy); font-size: 14px;"><%= d.getNomFichier() %></div>
                            <% if (d.getDescription() != null && !d.getDescription().trim().isEmpty()) { %>
                                <div style="font-size: 12px; color: var(--muted); margin-top: 3px;"><%= d.getDescription() %></div>
                            <% } %>
                            <div style="font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-top: 3px;">
                                Taille : <%= d.getTaille() != null ? d.getTaille() : "250 KB" %>
                            </div>
                        </td>
                        <td>
                            <span class="cat-tag <%= catClass %>"><%= cat %></span>
                        </td>
                        <td>
                            <div style="font-size: 13px; color: var(--ink);">
                                📍 <strong><%= d.getEvenementNom() != null ? d.getEvenementNom() : d.getSousDossier() %></strong>
                            </div>
                            <% if (d.getEditionRubrique() != null && !d.getEditionRubrique().trim().isEmpty()) { %>
                                <div style="font-size: 11px; font-family: var(--font-mono); color: var(--muted);"><%= d.getEditionRubrique() %></div>
                            <% } %>
                        </td>
                        <td>
                            <div style="font-family: var(--font-mono); font-size: 12.5px; color: var(--navy);">
                                📅 <%= d.getDateFichier() %>
                            </div>
                        </td>
                        <td>
                            <div style="font-size: 13px; color: var(--ink);">👤 <%= d.getAuteur() %></div>
                        </td>
                        <td style="text-align: right;">
                            <a href="<%= request.getContextPath() %>/documents?download=<%= d.getId() %>" class="btn-download" title="Télécharger le document certifié">
                                ⤓ Télécharger
                            </a>
                        </td>
                    </tr>
                    <%  }
                    } else { %>
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 48px; color: var(--muted);">
                            <div style="font-size: 32px; margin-bottom: 8px;">📁</div>
                            <div style="font-family: var(--font-serif); font-size: 18px; color: var(--navy);">Aucun document ne correspond aux filtres sélectionnés.</div>
                            <div style="font-size: 13px; margin-top: 6px;">Essayez d'élargir la recherche ou de réinitialiser les filtres de type et d'événement.</div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- MODULE D'HISTORISATION & TRAÇABILITÉ -->
        <div class="historique-box">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <span style="font-size: 24px;">🏛️</span>
                    <div>
                        <h3 style="font-family: var(--font-serif); font-size: 18px; margin: 0; color: var(--navy);">
                            Historisation & Traçabilité des Dépôts
                        </h3>
                        <p style="font-size: 12.5px; color: var(--muted); margin: 2px 0 0;">
                            Registre immuable des versements documentaires : chaque pièce est scrupuleusement horodatée, indexée et pérennisée.
                        </p>
                    </div>
                </div>
                <span class="badge badge-gold" style="font-family: var(--font-mono); font-size: 11px;">Historique Actif</span>
            </div>

            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px;">
                <% if (recentHistorique != null) {
                    for (int i = 0; i < Math.min(recentHistorique.size(), 6); i++) {
                        DocumentLabo h = recentHistorique.get(i);
                %>
                <div class="timeline-doc-item">
                    <div class="timeline-doc-date">📅 <%= h.getDateFichier() %></div>
                    <div style="flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                        <span style="font-weight: 600; color: var(--navy);"><%= h.getNomFichier() %></span>
                        <div style="font-size: 11.5px; color: var(--muted);">
                            <%= h.getCategorie() %> · Déposé par <%= h.getAuteur() %> (<%= h.getEvenementNom() != null ? h.getEvenementNom() : h.getSousDossier() %>)
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/documents?download=<%= h.getId() %>" style="color: var(--navy); font-size: 14px; text-decoration: none;" title="Télécharger">⤓</a>
                </div>
                <%  }
                } %>
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
<!-- MODAL : TÉLÉVERSEMENT / UPLOAD DE DOCUMENT                   -->
<!-- ========================================================================= -->
<div id="uploadModal" class="modal-overlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.6); z-index: 1000; backdrop-filter: blur(2px); align-items: center; justify-content: center;">
    <div class="modal-dialog" style="background: var(--surface); border: 1px solid var(--border); border-radius: 4px; max-width: 640px; width: 92%; max-height: 90vh; overflow-y: auto; box-shadow: 0 20px 40px rgba(0,0,0,0.2); padding: 28px;">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); padding-bottom: 14px; margin-bottom: 20px;">
            <h3 style="font-family: var(--font-serif); font-size: 22px; font-weight: 600; margin: 0; color: var(--navy);">
                ⤒ Téléverser un Document Officiel
            </h3>
            <button type="button" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--muted);" onclick="closeUploadModal()">✕</button>
        </div>

        <form action="<%= request.getContextPath() %>/documents" method="POST">
            <!-- Nom du fichier -->
            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Nom officiel du document *</label>
                <input type="text" name="nomFichier" class="form-control" placeholder="ex: Demande_Subvention_CNRST_2026.pdf" required>
            </div>

            <!-- Type de document (5 Types officiels ) -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Type de document *</label>
                    <select name="categorie" class="form-control" required>
                        <option value="Demandes de financement">💰 Demandes de financement</option>
                        <option value="Programmes">📋 Programmes</option>
                        <option value="Attestations">📜 Attestations</option>
                        <option value="Rapports" selected>📊 Rapports</option>
                        <option value="Documents administratifs">🏛️ Documents administratifs</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Format du fichier *</label>
                    <select name="type" class="form-control" required>
                        <option value="pdf">Fichier PDF (.pdf)</option>
                        <option value="docx">Document Word (.docx)</option>
                        <option value="xlsx">Feuille Excel (.xlsx)</option>
                        <option value="zip">Archive ZIP (.zip)</option>
                    </select>
                </div>
            </div>

            <!-- Structuration par événement & par date -->
            <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 14px; margin-bottom: 14px;">
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Événement rattaché *</label>
                    <select name="evenementNom" class="form-control" required>
                        <% if (evenementsList != null) {
                            for (Evenement ev : evenementsList) { %>
                                <option value="<%= ev.getTitre() %>"><%= ev.getType() %> : <%= ev.getTitre() %></option>
                        <%  }
                        } %>
                        <option value="Administratif - Conseil">🏛️ Administratif - Conseil de Laboratoire</option>
                        <option value="Administratif - Partenariats">🏛️ Administratif - Conventions & Partenariats</option>
                        <option value="Administratif - Général">🏛️ Administratif - Actes Généraux</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" style="font-size: 12px; font-weight: 600;">Date du document *</label>
                    <input type="date" name="dateFichier" class="form-control" required value="<%= java.time.LocalDate.now() %>">
                </div>
            </div>

            <!-- Description -->
            <div class="form-group" style="margin-bottom: 20px;">
                <label class="form-label" style="font-size: 12px; font-weight: 600;">Description & Note d'archivage</label>
                <textarea name="description" class="form-control" rows="2" placeholder="Objet de la pièce, signataire, cadre du projet ou de la manifestation..."></textarea>
            </div>

            <div style="padding: 12px; background: rgba(27, 47, 74, 0.04); border-radius: 4px; font-size: 12.5px; color: var(--navy); margin-bottom: 18px;">
                ℹ️ <strong>Historisation institutionnelle :</strong> Ce versement sera immédiatement indexé dans la base documentaire et téléchargeable avec certification officielle du LIAS.
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeUploadModal()">Annuler</button>
                <button type="submit" class="btn btn-primary">Valider le téléversement (Upload) →</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openUploadModal() {
        var modal = document.getElementById('uploadModal');
        modal.style.display = 'flex';
    }

    function closeUploadModal() {
        var modal = document.getElementById('uploadModal');
        modal.style.display = 'none';
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

    // Fermer modal avec Échap
    window.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeUploadModal();
        }
    });
</script>

</body>
</html>

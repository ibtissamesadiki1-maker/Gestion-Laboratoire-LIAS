<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.math.BigDecimal"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Locale"%>
<%@ page import="com.lias.beans.Convention"%>
<%@ page import="com.lias.beans.ConventionActivite"%>
<%@ page import="com.lias.beans.Mandat"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    boolean canManage = (currentUser != null && ("directeur".equalsIgnoreCase(currentUser.getRole()) || "permanent".equalsIgnoreCase(currentUser.getRole()) || "admin".equalsIgnoreCase(currentUser.getRole())));

    List<Convention> conventions = (List<Convention>) request.getAttribute("conventions");
    List<ConventionActivite> allActivites = (List<ConventionActivite>) request.getAttribute("allActivites");
    Mandat mandatActif = (Mandat) request.getAttribute("mandatActif");
    String msg = request.getParameter("success");

    int totalCount = (conventions != null) ? conventions.size() : 0;
    int activeCount = 0;
    BigDecimal totalBudget = BigDecimal.ZERO;
    if (conventions != null) {
        for (Convention c : conventions) {
            if ("Active".equalsIgnoreCase(c.getStatut())) activeCount++;
            if (c.getBudgetAlloue() != null) {
                totalBudget = totalBudget.add(c.getBudgetAlloue());
            }
        }
    }
    int totalActivites = (allActivites != null) ? allActivites.size() : 0;
    NumberFormat currencyFormat = NumberFormat.getInstance(Locale.FRANCE);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Conventions & Collaborations</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        .tab-btn {
            padding: 9px 18px;
            font-family: var(--font-sans);
            font-size: 13px;
            font-weight: 600;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--muted);
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.15s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .tab-btn:hover {
            color: var(--ink);
            border-color: var(--navy);
        }
        .tab-btn.active {
            background: var(--navy);
            color: #FFF;
            border-color: var(--navy);
            box-shadow: 0 2px 4px rgba(21, 43, 68, 0.15);
        }
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(2px);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            padding: 20px;
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
                        <span class="eyebrow">Coopération Scientifique & Rayonnement</span>
                        <h1 class="page-title">Conventions & Collaborations</h1>
                        <p class="page-sub">
                            Gestion des partenaires stratégiques, formalisation des accords, archivage documentaire des conventions signées et suivi dynamique des activités associées.
                        </p>
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <% if (currentUser != null) { %>
                            <button type="button" class="btn btn-secondary" onclick="openModal('modalActivite')">
                                + Déclarer une activité associée
                            </button>
                        <% } %>
                        <% if (canManage) { %>
                            <button type="button" class="btn btn-primary" onclick="openModal('modalConvention')">
                                + Nouvelle convention
                            </button>
                        <% } %>
                    </div>
                </div>

                <!-- Notifications -->
                <% if ("created".equals(msg)) { %>
                    <div class="toast-notification" id="appToast">
                        <div class="toast-icon">✓</div>
                        <div class="toast-content">
                            <div class="toast-title">Convention créée avec succès !</div>
                            <div class="toast-desc">L'accord-cadre de partenariat et son document ont été enregistrés et rattachés au mandat en cours.</div>
                        </div>
                        <button type="button" class="toast-close" onclick="closeToast()" title="Fermer">✕</button>
                    </div>
                <% } else if ("activite_ajoutee".equals(msg)) { %>
                    <div class="toast-notification" id="appToast">
                        <div class="toast-icon">🔬</div>
                        <div class="toast-content">
                            <div class="toast-title">Activité associée enregistrée !</div>
                            <div class="toast-desc">L'activité scientifique (projet R&D, thèse, mobilité) a été rattachée à la convention partenaire.</div>
                        </div>
                        <button type="button" class="toast-close" onclick="closeToast()" title="Fermer">✕</button>
                    </div>
                <% } %>

                <!-- Stat Cards -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="k">Conventions Enregistrées</div>
                        <div class="v"><%= totalCount %></div>
                        <div class="s">accords institutionnels</div>
                    </div>
                    <div class="stat-card">
                        <div class="k">Partenariats Actifs</div>
                        <div class="v" style="color: #10B981;"><%= activeCount %></div>
                        <div class="s">en cours d'exécution</div>
                    </div>
                    <div class="stat-card">
                        <div class="k">Budget Mobilisé</div>
                        <div class="v" style="color: var(--accent-2);"><%= currencyFormat.format(totalBudget) %> <span style="font-size: 13px;">MAD</span></div>
                        <div class="s">fonds de co-financement R&D</div>
                    </div>
                    <div class="stat-card">
                        <div class="k">Activités Associées</div>
                        <div class="v" style="color: var(--navy);"><%= totalActivites %></div>
                        <div class="s">thèses, projets & mobilités</div>
                    </div>
                </div>

                <!-- Onglets interactifs -->
                <div style="display: flex; gap: 10px; margin-bottom: 24px; flex-wrap: wrap;">
                    <button type="button" id="tabBtnConventions" class="tab-btn active" onclick="switchConvTab('conventions')">
                        🤝 Répertoire des Conventions (<%= totalCount %>)
                    </button>
                    <button type="button" id="tabBtnActivites" class="tab-btn" onclick="switchConvTab('activites')">
                        🔬 Suivi des Activités Associées (<%= totalActivites %>)
                    </button>
                    <button type="button" id="tabBtnArchives" class="tab-btn" onclick="switchConvTab('archives')">
                        📁 Archivage Documentaire des Accords
                    </button>
                </div>

                <!-- ================================================================= -->
                <!-- ONGLET 1 : Répertoire des Partenaires & Conventions -->
                <!-- ================================================================= -->
                <div id="viewConventions" class="table-container">
                    <div style="padding: 16px 20px; background: var(--surface-2); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center;">
                        <strong style="color: var(--navy); font-size: 14px;">🤝 Répertoire Officiel des Partenaires & Conventions</strong>
                        <span style="font-size: 12px; color: var(--muted);"><%= totalCount %> conventions enregistrées</span>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Organisme Partenaire</th>
                                <th>Typologie</th>
                                <th>Objet de la Convention</th>
                                <th>Période de Validité</th>
                                <th>Budget Alloué</th>
                                <th>Référents (LIAS & Partenaire)</th>
                                <th>Statut & Document</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (conventions != null && !conventions.isEmpty()) {
                                    for (Convention c : conventions) {
                                        String badgeColor = "badge-sage";
                                        if ("En négociation".equalsIgnoreCase(c.getStatut())) badgeColor = "badge-gold";
                                        else if ("Échue".equalsIgnoreCase(c.getStatut()) || "Clôturée".equalsIgnoreCase(c.getStatut())) badgeColor = "badge-muted";
                            %>
                            <tr>
                                <td>
                                    <strong style="font-family: var(--font-serif); font-size: 15px; color: var(--navy);"><%= c.getOrganismePartenaire() %></strong>
                                </td>
                                <td>
                                    <span class="badge badge-navy"><%= c.getTypePartenaire() != null ? c.getTypePartenaire() : "Académique" %></span>
                                </td>
                                <td style="max-width: 280px; font-size: 13px; color: var(--text-color);">
                                    <%= c.getObjet() %>
                                </td>
                                <td style="font-family: var(--font-mono); font-size: 12px;">
                                    <div>Du <%= c.getDateSignature() %></div>
                                    <div style="color: var(--muted);">au <%= c.getDateEcheance() != null ? c.getDateEcheance() : "Indéterminée" %></div>
                                </td>
                                <td style="font-family: var(--font-mono); font-size: 13px; font-weight: 700; color: var(--navy);">
                                    <%= (c.getBudgetAlloue() != null && c.getBudgetAlloue().compareTo(BigDecimal.ZERO) > 0) ? currencyFormat.format(c.getBudgetAlloue()) + " MAD" : "Sans flux financier" %>
                                </td>
                                <td style="font-size: 12px; line-height: 1.5;">
                                    <div><strong>LIAS :</strong> <%= c.getReferentLias() != null ? c.getReferentLias() : "Direction" %></div>
                                    <% if (c.getContactPartenaire() != null && !c.getContactPartenaire().isEmpty()) { %>
                                        <div style="color: var(--muted);"><strong>Partenaire :</strong> <%= c.getContactPartenaire() %></div>
                                    <% } %>
                                </td>
                                <td>
                                    <div style="display: flex; flex-direction: column; gap: 6px;">
                                        <span class="badge <%= badgeColor %>"><%= c.getStatut() %></span>
                                        <a href="<%= request.getContextPath() %>/conventions?action=telecharger&id=<%= c.getId() %>" 
                                           class="btn btn-sm btn-secondary" style="font-size: 11px; padding: 3px 6px; text-align: center;" target="_blank">
                                            📄 Accord signé
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7" style="padding: 24px; text-align: center; color: var(--muted);">Aucune convention enregistrée.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- ================================================================= -->
                <!-- ONGLET 2 : Suivi des Activités Associées -->
                <!-- ================================================================= -->
                <div id="viewActivites" class="table-container" style="display: none;">
                    <div style="padding: 16px 20px; background: var(--surface-2); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                        <div>
                            <strong style="color: var(--navy); font-size: 14px;">🔬 Suivi des Activités Conjointes & Projets Associés</strong>
                            <div style="font-size: 12px; color: var(--muted); margin-top: 2px;">
                                Thèses en cotutelle, projets R&D conjoints, mobilités de chercheurs et workshops issus des conventions actives.
                            </div>
                        </div>
                        <button type="button" class="btn btn-sm btn-accent" onclick="openModal('modalActivite')">
                            + Déclarer une activité associée
                        </button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Titre de l'Activité</th>
                                <th>Typologie</th>
                                <th>Convention de Rattachement</th>
                                <th>Responsable</th>
                                <th>Date / Période</th>
                                <th>Statut</th>
                                <th>Livrable / Retombées Scientifiques</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (allActivites != null && !allActivites.isEmpty()) {
                                    for (ConventionActivite a : allActivites) {
                                        String aBadge = "badge-sage";
                                        if ("Planifiée".equalsIgnoreCase(a.getStatut())) aBadge = "badge-gold";
                                        else if ("Terminée".equalsIgnoreCase(a.getStatut())) aBadge = "badge-navy";

                                        // Trouver le nom de la convention
                                        String nomPartenaire = "Convention #" + a.getConventionId();
                                        if (conventions != null) {
                                            for (Convention c : conventions) {
                                                if (c.getId().equals(a.getConventionId())) {
                                                    nomPartenaire = c.getOrganismePartenaire();
                                                    break;
                                                }
                                            }
                                        }
                            %>
                            <tr>
                                <td>
                                    <strong style="font-family: var(--font-serif); font-size: 14.5px; color: var(--navy);"><%= a.getTitreActivite() %></strong>
                                </td>
                                <td>
                                    <span class="badge badge-gold" style="font-weight: 600;"><%= a.getTypeActivite() %></span>
                                </td>
                                <td>
                                    <strong style="font-size: 13px;"><%= nomPartenaire %></strong>
                                </td>
                                <td><strong><%= a.getResponsable() %></strong></td>
                                <td style="font-family: var(--font-mono); font-size: 12px;"><%= a.getDateActivite() %></td>
                                <td><span class="badge <%= aBadge %>"><%= a.getStatut() %></span></td>
                                <td style="font-size: 12px; color: var(--muted); max-width: 260px;">
                                    <%= a.getLivrableDescription() != null ? a.getLivrableDescription() : "—" %>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7" style="padding: 24px; text-align: center; color: var(--muted);">Aucune activité associée déclarée pour le moment.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- ================================================================= -->
                <!-- ONGLET 3 : Archivage Documentaire des Accords -->
                <!-- ================================================================= -->
                <div id="viewArchives" class="table-container" style="display: none;">
                    <div style="padding: 16px 20px; background: var(--surface-2); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center;">
                        <strong style="color: var(--navy); font-size: 14px;">📁 Registre d'Archivage Documentaire des Accords & Contrats</strong>
                        <span style="font-size: 12px; color: var(--muted);"><%= totalCount %> documents archivés</span>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Intitulé du Document Archivé</th>
                                <th>Organisme Partenaire</th>
                                <th>Typologie d'Accord</th>
                                <th>Date d'Archivage</th>
                                <th>Emplacement Sécurisé</th>
                                <th>Accès & Téléchargement</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (conventions != null && !conventions.isEmpty()) {
                                    for (Convention c : conventions) {
                            %>
                            <tr>
                                <td>
                                    <strong style="font-family: var(--font-serif); font-size: 14.5px; color: var(--navy);">
                                        Accord de Partenariat — <%= c.getOrganismePartenaire() %>
                                    </strong>
                                </td>
                                <td><%= c.getOrganismePartenaire() %></td>
                                <td><span class="badge badge-navy"><%= c.getTypePartenaire() %></span></td>
                                <td style="font-family: var(--font-mono); font-size: 12px;"><%= c.getDateSignature() %></td>
                                <td style="font-family: var(--font-mono); font-size: 11.5px; color: var(--muted);">
                                    <%= c.getDocumentSignePath() %>
                                </td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/conventions?action=telecharger&id=<%= c.getId() %>" 
                                       class="btn btn-sm btn-primary" target="_blank">
                                        📥 Télécharger PDF
                                    </a>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="6" style="padding: 24px; text-align: center; color: var(--muted);">Aucun document archivé.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

            </div>
        </main>
    </div>
</div>

<!-- MODAL 1 : Création de Convention -->
<div id="modalConvention" class="modal-overlay">
    <div class="card" style="width: 100%; max-width: 680px; max-height: 90vh; overflow-y: auto; position: relative;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid var(--border); padding-bottom: 12px;">
            <h3 style="font-size: 18px; margin: 0; color: var(--navy);">🏛️ Enregistrer une Nouvelle Convention de Partenariat</h3>
            <button type="button" class="btn btn-sm btn-secondary" onclick="closeModal('modalConvention')">✕</button>
        </div>
        <form action="<%= request.getContextPath() %>/conventions" method="post">
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 14px;">
                <div class="form-group">
                    <label class="form-label">Organisme Partenaire *</label>
                    <input type="text" name="organismePartenaire" class="form-control" placeholder="ex: Université Paris-Saclay / OCP Group / CNRS" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Type de Partenaire *</label>
                    <select name="typePartenaire" class="form-control">
                        <option value="Académique">Académique International</option>
                        <option value="National">Académique National</option>
                        <option value="Industrie">Industrie / Entreprise R&D</option>
                        <option value="Institutionnel">Institutionnel / Étatique</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Objet & Objectifs de la Convention *</label>
                <textarea name="objet" class="form-control" rows="2" placeholder="Domaines de collaboration, thématiques de recherche conjointes, échanges..." required></textarea>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px;">
                <div class="form-group">
                    <label class="form-label">Date de Signature *</label>
                    <input type="date" name="dateSignature" class="form-control" value="<%= java.time.LocalDate.now() %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Date d'Échéance</label>
                    <input type="date" name="dateEcheance" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">Budget Alloué (MAD)</label>
                    <input type="number" name="budgetAlloue" class="form-control" placeholder="ex: 150000">
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                <div class="form-group">
                    <label class="form-label">Référent Scientifique LIAS</label>
                    <input type="text" name="referentLias" class="form-control" value="Prof. Ibtissam Essadiki">
                </div>
                <div class="form-group">
                    <label class="form-label">Coordinateur chez le Partenaire</label>
                    <input type="text" name="contactPartenaire" class="form-control" placeholder="Nom et email du coordinateur">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Nom du Fichier Document Archivé (PDF)</label>
                <input type="text" name="documentSignePath" class="form-control" placeholder="archives/conventions/accord_cadre_partenaire.pdf">
            </div>

            <div style="display: flex; gap: 10px; margin-top: 20px;">
                <button type="submit" class="btn btn-primary">Enregistrer la convention officielle →</button>
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalConvention')">Annuler</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL 2 : Déclarer une Activité Associée -->
<div id="modalActivite" class="modal-overlay">
    <div class="card" style="width: 100%; max-width: 620px; max-height: 90vh; overflow-y: auto; position: relative;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid var(--border); padding-bottom: 12px;">
            <h3 style="font-size: 18px; margin: 0; color: var(--navy);">🔬 Déclarer une Activité Associée à une Convention</h3>
            <button type="button" class="btn btn-sm btn-secondary" onclick="closeModal('modalActivite')">✕</button>
        </div>
        <form action="<%= request.getContextPath() %>/conventions" method="post">
            <input type="hidden" name="action" value="ajouter_activite">

            <div class="form-group">
                <label class="form-label">Convention de Partenariat Associée *</label>
                <select name="conventionId" class="form-control" required>
                    <% if (conventions != null) {
                        for (Convention c : conventions) { %>
                            <option value="<%= c.getId() %>"><%= c.getOrganismePartenaire() %> (<%= c.getStatut() %>)</option>
                    <%  }
                    } %>
                </select>
            </div>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 14px;">
                <div class="form-group">
                    <label class="form-label">Intitulé de l'Activité Conjointe *</label>
                    <input type="text" name="titreActivite" class="form-control" placeholder="ex: Thèse en cotutelle sur l'IA / Workshop bilatéral" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Type d'Activité *</label>
                    <select name="typeActivite" class="form-control">
                        <option value="Thèse en Cotutelle">Thèse en Cotutelle</option>
                        <option value="Projet R&D">Projet R&D Conjoint</option>
                        <option value="Mobilité Doctorale">Mobilité / Séjour Doctorant</option>
                        <option value="Workshop Partenaire">Workshop / Séminaire Bilatéral</option>
                        <option value="Publication Conjointe">Publication Co-signée</option>
                    </select>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px;">
                <div class="form-group">
                    <label class="form-label">Date / Période *</label>
                    <input type="date" name="dateActivite" class="form-control" value="<%= java.time.LocalDate.now() %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Responsable LIAS</label>
                    <input type="text" name="responsable" class="form-control" placeholder="Nom de l'encadrant ou chercheur">
                </div>
                <div class="form-group">
                    <label class="form-label">Statut</label>
                    <select name="statut" class="form-control">
                        <option value="En cours">En cours</option>
                        <option value="Planifiée">Planifiée</option>
                        <option value="Terminée">Terminée</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Livrables scientifiques & description des retombées</label>
                <textarea name="livrableDescription" class="form-control" rows="2" placeholder="Articles publiés, brevets, soutenance, prototypes logiciels..."></textarea>
            </div>

            <div style="display: flex; gap: 10px; margin-top: 20px;">
                <button type="submit" class="btn btn-primary">Enregistrer l'activité associée →</button>
                <button type="button" class="btn btn-secondary" onclick="closeModal('modalActivite')">Annuler</button>
            </div>
        </form>
    </div>
</div>

    <script>
        function switchConvTab(tab) {
            document.getElementById('viewConventions').style.display = (tab === 'conventions') ? 'block' : 'none';
            document.getElementById('viewActivites').style.display = (tab === 'activites') ? 'block' : 'none';
            document.getElementById('viewArchives').style.display = (tab === 'archives') ? 'block' : 'none';

            document.getElementById('tabBtnConventions').classList.toggle('active', tab === 'conventions');
            document.getElementById('tabBtnActivites').classList.toggle('active', tab === 'activites');
            document.getElementById('tabBtnArchives').classList.toggle('active', tab === 'archives');
        }

        function openModal(id) {
            var m = document.getElementById(id);
            if (m) m.style.display = 'flex';
        }

        function closeModal(id) {
            var m = document.getElementById(id);
            if (m) m.style.display = 'none';
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
    </script>
</body>
</html>

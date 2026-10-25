<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.Materiel"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    boolean isDirecteur = (currentUser != null && ("directeur".equalsIgnoreCase(currentUser.getRole()) || "admin".equalsIgnoreCase(currentUser.getRole())));

    List<Materiel> allMateriels = (List<Materiel>) request.getAttribute("allMateriels");
    List<Materiel> enAttenteList = (List<Materiel>) request.getAttribute("enAttenteList");
    List<Materiel> accordeesList = (List<Materiel>) request.getAttribute("accordeesList");
    List<Materiel> refuseesList = (List<Materiel>) request.getAttribute("refuseesList");

    int totalCount = (allMateriels != null) ? allMateriels.size() : 0;
    int attenteCount = (enAttenteList != null) ? enAttenteList.size() : 0;
    int accordeeCount = (accordeesList != null) ? accordeesList.size() : 0;
    int refuseeCount = (refuseesList != null) ? refuseesList.size() : 0;

    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Gestion des Besoins en Matériel</title>
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
        .badge-urgent {
            background: #FEE2E2;
            color: #991B1B;
            border: 1px solid #FCA5A5;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
        }
        .badge-normale {
            background: #E0E7FF;
            color: #3730A3;
            border: 1px solid #C7D2FE;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
        }
        .badge-faible {
            background: #F3F4F6;
            color: #4B5563;
            border: 1px solid #E5E7EB;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
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
                        <span class="eyebrow">Expression Scientifique & Arbitrage Budgétaire</span>
                        <h1 class="page-title">Gestion des Besoins en Matériel</h1>
                        <p class="page-sub">
                            Soumission en ligne des demandes par les chercheurs et doctorants, validation par la Direction et historique complet.
                        </p>
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button type="button" class="btn btn-primary" onclick="toggleFormBesoin()">
                            + Soumettre une demande de matériel
                        </button>
                        <a href="<%= request.getContextPath() %>/materiel" class="btn btn-secondary">
                            📦 Parc & Distribution Équitable →
                        </a>
                    </div>
                </div>

                <!-- Toast Notifications -->
                <% if ("demande_enregistree".equals(msg)) { %>
                    <div class="toast-notification" id="appToast">
                        <div class="toast-icon">✓</div>
                        <div class="toast-content">
                            <div class="toast-title">Expression de besoin soumise avec succès !</div>
                            <div class="toast-desc">Votre demande d'équipement scientifique a été enregistrée et transmise à la Direction pour arbitrage.</div>
                        </div>
                        <button type="button" class="toast-close" onclick="closeToast()" title="Fermer">✕</button>
                    </div>
                <% } else if ("decision_enregistree".equals(msg)) { %>
                    <div class="toast-notification" id="appToast">
                        <div class="toast-icon">⚖️</div>
                        <div class="toast-content">
                            <div class="toast-title">Décision d'arbitrage enregistrée !</div>
                            <div class="toast-desc">La décision de la Direction a été consignée dans l'historique et le demandeur a été notifié.</div>
                        </div>
                        <button type="button" class="toast-close" onclick="closeToast()" title="Fermer">✕</button>
                    </div>
                <% } %>

                <!-- KPI Strips -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="k">Total Besoins Exprimés</div>
                        <div class="v"><%= totalCount %></div>
                        <div class="s">demandes enregistrées</div>
                    </div>
                    <div class="stat-card">
                        <div class="k">En Cours d'Arbitrage</div>
                        <div class="v" style="color: var(--warning);"><%= attenteCount %></div>
                        <div class="s">attente de validation direction</div>
                    </div>
                    <div class="stat-card">
                        <div class="k">Demandes Accordées</div>
                        <div class="v" style="color: var(--sage);"><%= accordeeCount %></div>
                        <div class="s">dotations validées</div>
                    </div>
                    <div class="stat-card">
                        <div class="k">Demandes Refusées</div>
                        <div class="v" style="color: #991B1B;"><%= refuseeCount %></div>
                        <div class="s">non retenues / reportées</div>
                    </div>
                </div>

                <!-- Formulaire de Soumission des Demandes -->
                <div id="formBesoinCard" class="card" style="display: none; border-left: 4px solid var(--navy); margin-bottom: 28px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                        <h3 style="font-size: 18px; margin: 0; color: var(--navy);">📝 Formulaire de Soumission d'un Besoin en Matériel</h3>
                        <button type="button" class="btn btn-sm btn-secondary" onclick="toggleFormBesoin()">✕ Fermer</button>
                    </div>
                    <form action="<%= request.getContextPath() %>/besoins-materiel" method="post">
                        <input type="hidden" name="action" value="soumettre">

                        <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 16px;">
                            <div class="form-group">
                                <label class="form-label">Désignation de l'équipement sollicité *</label>
                                <input type="text" name="designation" class="form-control" placeholder="ex: Station de calcul GPU RTX 4090 / PC Portable 16 pouce..." required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Catégorie d'équipement *</label>
                                <select name="categorie" class="form-control">
                                    <option value="Calcul / Serveur">Calcul / Serveur GPU</option>
                                    <option value="Poste de Travail">Poste de Travail / PC Portable</option>
                                    <option value="Réseau & Stockage">Réseau & Stockage NAS</option>
                                    <option value="Périphérique">Périphérique Scientifique</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Niveau de Priorité</label>
                                <select name="priorite" class="form-control">
                                    <option value="NORMALE">NORMALE (Recherche continue)</option>
                                    <option value="URGENTE">URGENTE (Échéance de thèse / Soumission)</option>
                                    <option value="FAIBLE">FAIBLE (Renouvellement programmé)</option>
                                </select>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 16px;">
                            <div class="form-group">
                                <label class="form-label">Budget prévisionnel estimé (MAD)</label>
                                <input type="number" name="coutEstime" class="form-control" placeholder="ex: 35000">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Projet de Recherche / Thèse rattachée *</label>
                                <input type="text" name="justification" class="form-control" placeholder="ex: Thèse NLP - Modèles LLM Dialectaux / Projet Partenariat CNRST" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Justification scientifique & verrous techniques à lever *</label>
                            <textarea name="description" class="form-control" rows="3" placeholder="Expliquez pourquoi cet équipement est indispensable pour mener à bien vos travaux au laboratoire LIAS..." required></textarea>
                        </div>

                        <div style="display: flex; gap: 10px;">
                            <button type="submit" class="btn btn-primary">Transmettre la demande à la Direction →</button>
                            <button type="button" class="btn btn-secondary" onclick="toggleFormBesoin()">Annuler</button>
                        </div>
                    </form>
                </div>

                <!-- Onglets interactifs -->
                <div style="display: flex; gap: 10px; margin-bottom: 24px; flex-wrap: wrap;">
                    <button type="button" id="btnTabAttente" class="tab-btn active" onclick="switchBesoinTab('attente')">
                        ⏱️ Demandes en attente d'arbitrage (<%= attenteCount %>)
                    </button>
                    <button type="button" id="btnTabAccordee" class="tab-btn" onclick="switchBesoinTab('accordee')">
                        ✓ Demandes accordées & dotées (<%= accordeeCount %>)
                    </button>
                    <button type="button" id="btnTabRefusee" class="tab-btn" onclick="switchBesoinTab('refusee')">
                        ✕ Demandes refusées (<%= refuseeCount %>)
                    </button>
                    <button type="button" id="btnTabHistorique" class="tab-btn" onclick="switchBesoinTab('historique')">
                        📜 Historique complet (<%= totalCount %>)
                    </button>
                </div>

                <!-- ============================================================= -->
                <!-- VUE 1 : Demandes en attente d'arbitrage par la Direction -->
                <!-- ============================================================= -->
                <div id="viewAttente" class="table-container">
                    <div style="padding: 14px 20px; background: rgba(184, 91, 53, 0.08); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;">
                        <span style="font-size: 13.5px; color: var(--accent-2); font-weight: 700;">
                            ⏱️ Demandes de matériel formulées en attente d'arbitrage budgétaire
                        </span>
                        <% if (isDirecteur) { %>
                            <span class="badge badge-gold">Espace d'arbitrage réservé à la Direction</span>
                        <% } %>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Demandeur & Équipe</th>
                                <th>Équipement Sollicité</th>
                                <th>Catégorie</th>
                                <th>Priorité</th>
                                <th>Date Demande</th>
                                <th>Projet / Justification</th>
                                <% if (isDirecteur) { %><th>Validation par Direction</th><% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (enAttenteList != null && !enAttenteList.isEmpty()) {
                                    for (Materiel m : enAttenteList) {
                                        String pBadge = "badge-normale";
                                        if ("URGENTE".equalsIgnoreCase(m.getPriorite())) pBadge = "badge-urgent";
                                        else if ("FAIBLE".equalsIgnoreCase(m.getPriorite())) pBadge = "badge-faible";
                            %>
                            <tr>
                                <td>
                                    <strong style="font-family: var(--font-serif); font-size: 14.5px; color: var(--navy);"><%= m.getDemandeur() %></strong>
                                </td>
                                <td>
                                    <strong><%= m.getDesignation() %></strong>
                                    <% if (m.getCoutEstime() != null && m.getCoutEstime() > 0) { %>
                                        <div style="font-family: var(--font-mono); font-size: 11px; color: var(--muted); margin-top: 2px;">
                                            Est. : <%= m.getCoutEstime() %> MAD
                                        </div>
                                    <% } %>
                                </td>
                                <td><span class="badge badge-navy"><%= m.getCategorie() %></span></td>
                                <td><span class="<%= pBadge %>"><%= m.getPriorite() %></span></td>
                                <td style="font-family: var(--font-mono); font-size: 12px;"><%= m.getDateDemande() %></td>
                                <td style="font-size: 12px; color: var(--muted); max-width: 280px;">
                                    <%= m.getCommentaire() != null ? m.getCommentaire() : "Demande d'équipement de recherche" %>
                                </td>
                                <% if (isDirecteur) { %>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <form action="<%= request.getContextPath() %>/besoins-materiel" method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="valider">
                                            <input type="hidden" name="id" value="<%= m.getId() %>">
                                            <input type="hidden" name="statut" value="ACCORDE">
                                            <input type="hidden" name="commentaire" value="Validé et alloué par décision de la Direction.">
                                            <button type="submit" class="btn btn-sm btn-accent" title="Valider la dotation">✓ Accorder</button>
                                        </form>
                                        <button type="button" class="btn btn-sm btn-danger" 
                                            onclick="openRefusModal('<%= m.getId() %>', '<%= m.getDesignation() %>')" title="Refuser">
                                            ✕ Refuser
                                        </button>
                                    </div>
                                </td>
                                <% } %>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="<%= isDirecteur ? 7 : 6 %>" style="padding: 24px; text-align: center; color: var(--sage); font-weight: 600;">
                                    ✓ Aucune demande de matériel en attente. Tous les besoins ont été arbitrés !
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- ============================================================= -->
                <!-- VUE 2 : Demandes accordées & dotées -->
                <!-- ============================================================= -->
                <div id="viewAccordee" class="table-container" style="display: none;">
                    <div style="padding: 14px 20px; background: rgba(46, 125, 50, 0.06); border-bottom: 1px solid var(--border);">
                        <strong style="color: var(--sage); font-size: 13.5px;">✓ Registre des Besoins Accordés et Validés par la Direction</strong>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Demandeur</th>
                                <th>Matériel Accordé</th>
                                <th>Catégorie</th>
                                <th>Date Soumission</th>
                                <th>Date Décision</th>
                                <th>Statut</th>
                                <th>Motif & Décision Direction</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (accordeesList != null && !accordeesList.isEmpty()) {
                                    for (Materiel m : accordeesList) {
                            %>
                            <tr>
                                <td><strong><%= m.getDemandeur() %></strong></td>
                                <td><strong><%= m.getDesignation() %></strong></td>
                                <td><span class="badge badge-navy"><%= m.getCategorie() %></span></td>
                                <td style="font-family: var(--font-mono); font-size: 12px;"><%= m.getDateDemande() %></td>
                                <td style="font-family: var(--font-mono); font-size: 12px; color: var(--sage); font-weight: 600;">
                                    <%= m.getDateAttribution() != null ? m.getDateAttribution() : "—" %>
                                </td>
                                <td><span class="badge badge-sage"><%= m.getStatut() %></span></td>
                                <td style="font-size: 12px; color: var(--muted);"><%= m.getCommentaire() != null ? m.getCommentaire() : "Dotation validée" %></td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7" style="padding: 24px; text-align: center; color: var(--muted);">Aucune demande validée pour le moment.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- ============================================================= -->
                <!-- VUE 3 : Demandes refusées -->
                <!-- ============================================================= -->
                <div id="viewRefusee" class="table-container" style="display: none;">
                    <div style="padding: 14px 20px; background: rgba(220, 38, 38, 0.05); border-bottom: 1px solid var(--border);">
                        <strong style="color: #991B1B; font-size: 13.5px;">✕ Demandes Refusées ou Non Retenues</strong>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Demandeur</th>
                                <th>Matériel</th>
                                <th>Catégorie</th>
                                <th>Date Demande</th>
                                <th>Date Arbitrage</th>
                                <th>Statut</th>
                                <th>Motif du Refus</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (refuseesList != null && !refuseesList.isEmpty()) {
                                    for (Materiel m : refuseesList) {
                            %>
                            <tr>
                                <td><strong><%= m.getDemandeur() %></strong></td>
                                <td><strong><%= m.getDesignation() %></strong></td>
                                <td><span class="badge badge-navy"><%= m.getCategorie() %></span></td>
                                <td style="font-family: var(--font-mono); font-size: 12px;"><%= m.getDateDemande() %></td>
                                <td style="font-family: var(--font-mono); font-size: 12px; color: #991B1B;"><%= m.getDateAttribution() != null ? m.getDateAttribution() : "—" %></td>
                                <td><span class="badge badge-danger"><%= m.getStatut() %></span></td>
                                <td style="font-size: 12px; color: var(--muted);"><%= m.getCommentaire() != null ? m.getCommentaire() : "Budget insuffisant ou non prioritaire" %></td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7" style="padding: 24px; text-align: center; color: var(--muted);">Aucun refus enregistré.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- ============================================================= -->
                <!-- VUE 4 : Historique Complet des Besoins -->
                <!-- ============================================================= -->
                <div id="viewHistorique" class="table-container" style="display: none;">
                    <div style="padding: 14px 20px; background: var(--surface-2); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center;">
                        <strong style="color: var(--navy); font-size: 13.5px;">📜 Historique Complet et Traçabilité des Besoins</strong>
                        <span style="font-size: 12px; color: var(--muted);"><%= totalCount %> entrées historiques</span>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Demandeur</th>
                                <th>Équipement</th>
                                <th>Catégorie</th>
                                <th>Date Soumission</th>
                                <th>Statut Actuel</th>
                                <th>Date Décision</th>
                                <th>Commentaires & Décision</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (allMateriels != null && !allMateriels.isEmpty()) {
                                    for (Materiel m : allMateriels) {
                                        String tone = "badge-gold";
                                        if ("ACCORDE".equalsIgnoreCase(m.getStatut()) || "LIVRE".equalsIgnoreCase(m.getStatut()) || "ATTRIBUE".equalsIgnoreCase(m.getStatut())) tone = "badge-sage";
                                        else if ("REFUSE".equalsIgnoreCase(m.getStatut())) tone = "badge-danger";
                            %>
                            <tr>
                                <td><strong><%= m.getDemandeur() %></strong></td>
                                <td><strong><%= m.getDesignation() %></strong></td>
                                <td><span class="badge badge-navy"><%= m.getCategorie() %></span></td>
                                <td style="font-family: var(--font-mono); font-size: 12px;"><%= m.getDateDemande() %></td>
                                <td><span class="badge <%= tone %>"><%= m.getStatut() %></span></td>
                                <td style="font-family: var(--font-mono); font-size: 12px;"><%= m.getDateAttribution() != null ? m.getDateAttribution() : "En attente" %></td>
                                <td style="font-size: 12px; color: var(--muted); max-width: 280px;"><%= m.getCommentaire() != null ? m.getCommentaire() : "—" %></td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7" style="padding: 24px; text-align: center; color: var(--muted);">Aucun enregistrement d'historique.</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Modal de Refus avec Motif (Direction ) -->
                <div id="modalRefus" class="card" style="display: none; border-left: 4px solid #991B1B; margin-top: 24px; background: rgba(220, 38, 38, 0.03);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                        <h3 style="font-size: 16px; margin: 0; color: #991B1B;">Décision de Rejet / Refus de la Demande</h3>
                        <button type="button" class="btn btn-sm btn-secondary" onclick="closeRefusModal()">✕ Fermer</button>
                    </div>
                    <form action="<%= request.getContextPath() %>/besoins-materiel" method="post">
                        <input type="hidden" name="action" value="valider">
                        <input type="hidden" id="refusId" name="id" value="">
                        <input type="hidden" name="statut" value="REFUSE">

                        <div class="form-group">
                            <label class="form-label">Équipement concerné</label>
                            <input type="text" id="refusDesignation" class="form-control" readonly>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Motif officiel du refus (Transmis au demandeur) *</label>
                            <textarea name="commentaire" class="form-control" rows="2" placeholder="Précisez la raison : enveloppe budgétaire épuisée, équipement non éligible, report au prochain exercice..." required></textarea>
                        </div>
                        <div style="display: flex; gap: 10px;">
                            <button type="submit" class="btn btn-danger">Confirmer le refus de la demande</button>
                            <button type="button" class="btn btn-secondary" onclick="closeRefusModal()">Annuler</button>
                        </div>
                    </form>
                </div>

            </div>
        </main>
    </div>
</div>

    <script>
        function toggleFormBesoin() {
            var f = document.getElementById('formBesoinCard');
            if (!f) return;
            f.style.display = (f.style.display === 'block') ? 'none' : 'block';
            if (f.style.display === 'block') f.scrollIntoView({ behavior: 'smooth' });
        }

        function switchBesoinTab(tab) {
            document.getElementById('viewAttente').style.display = (tab === 'attente') ? 'block' : 'none';
            document.getElementById('viewAccordee').style.display = (tab === 'accordee') ? 'block' : 'none';
            document.getElementById('viewRefusee').style.display = (tab === 'refusee') ? 'block' : 'none';
            document.getElementById('viewHistorique').style.display = (tab === 'historique') ? 'block' : 'none';

            document.getElementById('btnTabAttente').classList.toggle('active', tab === 'attente');
            document.getElementById('btnTabAccordee').classList.toggle('active', tab === 'accordee');
            document.getElementById('btnTabRefusee').classList.toggle('active', tab === 'refusee');
            document.getElementById('btnTabHistorique').classList.toggle('active', tab === 'historique');
        }

        function openRefusModal(id, desig) {
            var m = document.getElementById('modalRefus');
            var inputId = document.getElementById('refusId');
            var inputDesig = document.getElementById('refusDesignation');
            if (m && inputId && inputDesig) {
                inputId.value = id;
                inputDesig.value = desig;
                m.style.display = 'block';
                m.scrollIntoView({ behavior: 'smooth' });
            }
        }

        function closeRefusModal() {
            var m = document.getElementById('modalRefus');
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

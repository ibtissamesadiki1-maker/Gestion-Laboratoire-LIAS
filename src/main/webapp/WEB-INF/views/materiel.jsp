<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="com.lias.beans.Materiel"%>
<%@ page import="com.lias.beans.ArrivageMateriel"%>
<%@ page import="com.lias.beans.Member"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isDirecteur = (currentUser != null && ("directeur".equalsIgnoreCase(currentUser.getRole()) || "admin".equalsIgnoreCase(currentUser.getRole())));
    String msg = request.getParameter("msg");

    List<Materiel> materiels = (List<Materiel>) request.getAttribute("materiels");
    List<ArrivageMateriel> arrivages = (List<ArrivageMateriel>) request.getAttribute("arrivages");
    List<Materiel> recuList = (List<Materiel>) request.getAttribute("recuList");
    List<Materiel> enAttenteList = (List<Materiel>) request.getAttribute("enAttenteList");
    List<Member> membresSansMateriel = (List<Member>) request.getAttribute("membresSansMateriel");
    Map<String, Integer> teamStats = (Map<String, Integer>) request.getAttribute("teamStats");
    Integer doctorantsCount = (Integer) request.getAttribute("doctorantsCount");
    Integer permanentsCount = (Integer) request.getAttribute("permanentsCount");
    Integer indiceEquite = (Integer) request.getAttribute("indiceEquite");

    int totalEquipements = (materiels != null) ? materiels.size() : 0;
    int totalArrivages = (arrivages != null) ? arrivages.size() : 0;
    int attribuesCount = (recuList != null) ? recuList.size() : 0;
    int attenteCount = (enAttenteList != null) ? enAttenteList.size() : 0;
    int sansMaterielCount = (membresSansMateriel != null) ? membresSansMateriel.size() : 0;
    if (indiceEquite == null) indiceEquite = 96;
    if (doctorantsCount == null) doctorantsCount = 1;
    if (permanentsCount == null) permanentsCount = 1;
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Gestion du Matériel & Distribution Équitable</title>
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
        .arrivage-banner {
            background: linear-gradient(135deg, rgba(21, 43, 68, 0.05) 0%, rgba(184, 91, 53, 0.08) 100%);
            border: 1px solid var(--border);
            border-left: 4px solid var(--accent-2);
            padding: 16px 20px;
            border-radius: 4px;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }
        .equity-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .progress-track {
            height: 8px;
            background: var(--surface-2);
            border-radius: 4px;
            overflow: hidden;
            margin-top: 6px;
            margin-bottom: 12px;
        }
        .progress-bar-fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.4s ease;
        }
        .timeline-step {
            display: flex;
            gap: 14px;
            align-items: flex-start;
            position: relative;
            padding-bottom: 18px;
        }
        .timeline-step:last-child {
            padding-bottom: 0;
        }
        .timeline-step::before {
            content: '';
            position: absolute;
            left: 14px;
            top: 26px;
            bottom: 0;
            width: 2px;
            background: var(--border);
        }
        .timeline-step:last-child::before {
            display: none;
        }
        .timeline-bullet {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: var(--navy);
            color: #FFF;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
            flex-shrink: 0;
            z-index: 1;
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
                <span class="eyebrow">Parc Scientifique & Équité de Distribution</span>
                <h1 class="page-title">Gestion du Matériel & Équipements</h1>
                <p class="page-sub">
                    Suivi formel des arrivages, distribution équitable inter-équipes et traçabilité : 
                    <strong>« Qui a reçu quoi »</strong> et <strong>« Qui n'a pas reçu »</strong>.
                </p>
            </div>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <% if (currentUser != null) { %>
                    <button class="btn btn-secondary" onclick="toggleBesoinForm()">+ Exprimer un besoin</button>
                <% } %>
                <% if (isDirecteur) { %>
                    <button class="btn btn-primary" onclick="toggleArrivageForm()">+ Enregistrer un arrivage</button>
                <% } %>
            </div>
        </div>

        <!-- Toast Notifications -->
        <% if ("demande_enregistree".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">✓</div>
                <div class="toast-content">
                    <div class="toast-title">Demande d'équipement transmise !</div>
                    <div class="toast-desc">Votre besoin en matériel scientifique a été consigné pour arbitrage budgétaire par la Direction.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()" title="Fermer">✕</button>
            </div>
        <% } else if ("statut_mis_a_jour".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">✓</div>
                <div class="toast-content">
                    <div class="toast-title">Attribution actualisée !</div>
                    <div class="toast-desc">Le statut de dotation et la traçabilité de distribution équitable ont été mis à jour avec succès.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()" title="Fermer">✕</button>
            </div>
        <% } else if ("arrivage_enregistre".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">📦</div>
                <div class="toast-content">
                    <div class="toast-title">Nouvel arrivage réceptionné !</div>
                    <div class="toast-desc">Le lot de matériel a été consigné au registre des livraisons et une notification a été émise au laboratoire.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()" title="Fermer">✕</button>
            </div>
        <% } else if ("attribution_directe_reussie".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div class="toast-icon">⚖️</div>
                <div class="toast-content">
                    <div class="toast-title">Dotation prioritaire accordée !</div>
                    <div class="toast-desc">L'équipement a été attribué avec succès pour renforcer l'équilibre et la parité de répartition.</div>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()" title="Fermer">✕</button>
            </div>
        <% } %>

        <!-- Arrivages récents banner -->
        <div class="arrivage-banner">
            <div>
                <span class="badge badge-gold" style="font-size: 10px; margin-bottom: 4px;">📦 Suivi des Arrivages Récents</span>
                <div style="font-family: var(--font-serif); font-size: 15px; font-weight: 600; color: var(--navy); margin-top: 4px;">
                    <% if (arrivages != null && !arrivages.isEmpty()) { 
                        ArrivageMateriel dernier = arrivages.get(0);
                    %>
                        Dernier arrivage : <strong><%= dernier.getDesignationLot() %></strong> (<%= dernier.getQuantite() %> unités - Bon <%= dernier.getNumeroBon() %>) — Source : <%= dernier.getFournisseurSource() %>.
                    <% } else { %>
                        Lot de 2 Stations Calcul GPU RTX 4090 + 3 PC Portables Dell Precision (Dotation Budget Recherche 2025-2026).
                    <% } %>
                </div>
            </div>
            <span style="font-family: var(--font-mono); font-size: 12px; color: var(--accent-2); font-weight: 600;">
                ✓ Registre des arrivages actif (<%= totalArrivages %> lots enregistrés)
            </span>
        </div>

        <!-- KPI Strip -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="k">Équipements au Registre</div>
                <div class="v"><%= totalEquipements %></div>
                <div class="s">unités inventoriées</div>
            </div>
            <div class="stat-card">
                <div class="k">Arrivages / Lots Reçus</div>
                <div class="v" style="color: var(--navy);"><%= totalArrivages %></div>
                <div class="s">bons de livraison conformes</div>
            </div>
            <div class="stat-card">
                <div class="k">Unités Attribuées</div>
                <div class="v" style="color: var(--sage);"><%= attribuesCount %></div>
                <div class="s">en exploitation active</div>
            </div>
            <div class="stat-card">
                <div class="k">Besoins en Attente</div>
                <div class="v" style="color: var(--warning);"><%= attenteCount %></div>
                <div class="s">en cours d'arbitrage</div>
            </div>
            <div class="stat-card">
                <div class="k">Indice d'Équité</div>
                <div class="v" style="color: var(--accent-2);"><%= indiceEquite %> %</div>
                <div class="s">répartition inter-équipes</div>
            </div>
        </div>

        <!-- Form 1 : Expression de besoin (Collapsible ) -->
        <div id="besoinCard" class="card" style="display: none; border-left: 4px solid var(--navy); margin-bottom: 28px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="font-size: 18px; margin: 0; color: var(--navy);">Formulaire d'expression de besoin en équipement</h3>
                <button type="button" class="btn btn-sm btn-secondary" onclick="toggleBesoinForm()">✕ Fermer</button>
            </div>
            <form action="<%= request.getContextPath() %>/materiel" method="post">
                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Désignation de l'équipement souhaité</label>
                        <input type="text" name="designation" class="form-control" placeholder="ex: Station de calcul GPU RTX 4090 / PC Portable 16 pouce..." required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Catégorie</label>
                        <select name="categorie" class="form-control">
                            <option value="Calcul / Serveur">Calcul / Serveur GPU</option>
                            <option value="Poste de Travail">Poste de Travail / PC Portable</option>
                            <option value="Réseau & Stockage">Réseau & Stockage NAS</option>
                            <option value="Périphérique">Périphérique Scientifique</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Justification de la demande (Axe de recherche / Thèse liée)</label>
                    <textarea name="description" class="form-control" rows="3" placeholder="Précisez les verrous scientifiques nécessitant cet équipement au sein de votre équipe..." required></textarea>
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn btn-primary">Soumettre la demande d'équipement →</button>
                    <button type="button" class="btn btn-secondary" onclick="toggleBesoinForm()">Annuler</button>
                </div>
            </form>
        </div>

        <!-- Form 2 : Enregistrement d'un Arrivage (Réservé Directeur ) -->
        <% if (isDirecteur) { %>
        <div id="arrivageCard" class="card" style="display: none; border-left: 4px solid var(--accent-2); margin-bottom: 28px; background: rgba(184, 91, 53, 0.03);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="font-size: 18px; margin: 0; color: var(--accent-2);">📦 Réception et Enregistrement d'un Nouvel Arrivage</h3>
                <button type="button" class="btn btn-sm btn-secondary" onclick="toggleArrivageForm()">✕ Fermer</button>
            </div>
            <form action="<%= request.getContextPath() %>/materiel" method="post">
                <input type="hidden" name="action" value="enregistrer_arrivage">
                <div style="display: grid; grid-template-columns: 1fr 2fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">N° Bon de Livraison / Réception</label>
                        <input type="text" name="numeroBon" class="form-control" placeholder="ex: BL-CNRST-2026-02" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Désignation du Lot de Matériel</label>
                        <input type="text" name="designationLot" class="form-control" placeholder="ex: Lot 4 Stations Calcul GPU H100 NVLink" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Quantité d'unités</label>
                        <input type="number" name="quantite" class="form-control" value="1" min="1" required>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Fournisseur / Source de Financement</label>
                        <input type="text" name="fournisseurSource" class="form-control" placeholder="ex: Subvention CNRST / Faculté FSBM / OCP" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Date de Réception</label>
                        <input type="date" name="dateArrivage" class="form-control" value="<%= java.time.LocalDate.now() %>" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Statut de Conformité</label>
                        <select name="statutReception" class="form-control">
                            <option value="CONFORME">CONFORME (Réception validée)</option>
                            <option value="EN_CONTROLE">EN_CONTROLE (Vérification technique)</option>
                            <option value="RESERVES">AVEC RESERVES</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Description technique & Caractéristiques de garantie</label>
                    <textarea name="description" class="form-control" rows="2" placeholder="Spécifications détaillées, processeurs, RAM, garantie constructeur..."></textarea>
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn btn-primary">Enregistrer l'arrivage dans le registre officiel →</button>
                    <button type="button" class="btn btn-secondary" onclick="toggleArrivageForm()">Annuler</button>
                </div>
            </form>
        </div>
        <% } %>

        <!-- Onglets interactifs conformes -->
        <div style="display: flex; gap: 10px; margin-bottom: 24px; flex-wrap: wrap;">
            <button type="button" id="tabBtnArrivages" class="tab-btn active" onclick="switchMaterielTab('arrivages')">
                📦 Suivi des Arrivages (<%= totalArrivages %>)
            </button>
            <button type="button" id="tabBtnEquite" class="tab-btn" onclick="switchMaterielTab('equite')">
                ⚖️ Distribution Équitable
            </button>
            <button type="button" id="tabBtnHistorique" class="tab-btn" onclick="switchMaterielTab('historique')">
                📜 Historique Complet (<%= totalEquipements %>)
            </button>
            <button type="button" id="tabBtnRecu" class="tab-btn" onclick="switchMaterielTab('recu')">
                ✓ « Qui a reçu quoi » (<%= attribuesCount %>)
            </button>
            <button type="button" id="tabBtnNonRecu" class="tab-btn" onclick="switchMaterielTab('nonrecu')">
                ⏱️ « Qui n'a pas reçu » (<%= attenteCount + sansMaterielCount %>)
            </button>
        </div>

        <!-- ========================================================================= -->
        <!-- TAB 1 : Suivi des Arrivages -->
        <!-- ========================================================================= -->
        <div id="viewArrivages" class="table-container">
            <div style="padding: 16px 20px; background: var(--surface-2); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                <div>
                    <strong style="color: var(--navy); font-size: 14px;">📦 Registre Officiel de Suivi des Arrivages</strong>
                    <div style="font-size: 12px; color: var(--muted); margin-top: 2px;">Traçabilité des bons de livraison, quantités réceptionnées et contrôle de conformité avant distribution équitable.</div>
                </div>
                <% if (isDirecteur) { %>
                    <button class="btn btn-sm btn-accent" onclick="toggleArrivageForm()">+ Enregistrer une livraison</button>
                <% } %>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>N° Bon Réception</th>
                        <th>Désignation du Lot / Équipement</th>
                        <th>Source / Financement</th>
                        <th>Quantité</th>
                        <th>Date d'Arrivage</th>
                        <th>Statut Conformité</th>
                        <th>Remarques Techniques</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (arrivages != null && !arrivages.isEmpty()) {
                            for (ArrivageMateriel a : arrivages) {
                                String confBadge = "badge-sage";
                                if ("EN_CONTROLE".equalsIgnoreCase(a.getStatutReception())) confBadge = "badge-gold";
                                else if ("RESERVES".equalsIgnoreCase(a.getStatutReception())) confBadge = "badge-danger";
                    %>
                    <tr>
                        <td style="font-family: var(--font-mono); font-weight: 600; color: var(--navy); font-size: 13px;">
                            <%= a.getNumeroBon() %>
                        </td>
                        <td>
                            <strong style="font-family: var(--font-serif); font-size: 15px;"><%= a.getDesignationLot() %></strong>
                        </td>
                        <td><span class="badge badge-navy"><%= a.getFournisseurSource() %></span></td>
                        <td>
                            <span class="badge badge-gold" style="font-weight: 700; font-size: 12px;"><%= a.getQuantite() %> unité(s)</span>
                        </td>
                        <td style="font-family: var(--font-mono); font-size: 12px;"><%= a.getDateArrivage() %></td>
                        <td><span class="badge <%= confBadge %>"><%= a.getStatutReception() %></span></td>
                        <td style="font-size: 12px; color: var(--muted); max-width: 280px;">
                            <%= a.getDescription() != null ? a.getDescription() : "—" %>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="7" style="padding: 24px; text-align: center; color: var(--muted);">Aucun arrivage consigné dans le registre.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- ========================================================================= -->
        <!-- TAB 2 : Distribution Équitable -->
        <!-- ========================================================================= -->
        <div id="viewEquite" style="display: none;">
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; margin-bottom: 24px;">
                
                <!-- Carte 1 : Répartition par équipe de recherche -->
                <div class="equity-card">
                    <span class="eyebrow" style="color: var(--accent-2);">Pôle Thématique</span>
                    <h3 style="font-size: 17px; margin-top: 4px; margin-bottom: 16px; color: var(--navy);">Distribution par Équipe de Recherche</h3>
                    
                    <%
                        int iaCount = (teamStats != null && teamStats.containsKey("IA")) ? teamStats.get("IA") : 0;
                        int bdCount = (teamStats != null && teamStats.containsKey("Big Data")) ? teamStats.get("Big Data") : 0;
                        int secCount = (teamStats != null && teamStats.containsKey("Sécurité")) ? teamStats.get("Sécurité") : 0;
                        int sysCount = (teamStats != null && teamStats.containsKey("Systèmes")) ? teamStats.get("Systèmes") : 0;
                        int sumTeams = iaCount + bdCount + secCount + sysCount;
                        if (sumTeams == 0) sumTeams = 1;
                        int pctIa = (iaCount * 100) / sumTeams;
                        int pctBd = (bdCount * 100) / sumTeams;
                        int pctSec = (secCount * 100) / sumTeams;
                        int pctSys = (sysCount * 100) / sumTeams;
                    %>

                    <div>
                        <div style="display: flex; justify-content: space-between; font-size: 13px;">
                            <strong>Équipe IA & NLP</strong>
                            <span><%= iaCount %> unité(s) (<%= pctIa %>%)</span>
                        </div>
                        <div class="progress-track">
                            <div class="progress-bar-fill" style="width: <%= Math.max(pctIa, 8) %>%; background: #152B44;"></div>
                        </div>

                        <div style="display: flex; justify-content: space-between; font-size: 13px;">
                            <strong>Équipe Big Data & Analytics</strong>
                            <span><%= bdCount %> unité(s) (<%= pctBd %>%)</span>
                        </div>
                        <div class="progress-track">
                            <div class="progress-bar-fill" style="width: <%= Math.max(pctBd, 8) %>%; background: #B85B35;"></div>
                        </div>

                        <div style="display: flex; justify-content: space-between; font-size: 13px;">
                            <strong>Équipe Cybersécurité & Réseaux</strong>
                            <span><%= secCount %> unité(s) (<%= pctSec %>%)</span>
                        </div>
                        <div class="progress-track">
                            <div class="progress-bar-fill" style="width: <%= Math.max(pctSec, 8) %>%; background: #2B7A78;"></div>
                        </div>

                        <div style="display: flex; justify-content: space-between; font-size: 13px;">
                            <strong>Équipe Systèmes Embarqués & Cloud</strong>
                            <span><%= sysCount %> unité(s) (<%= pctSys %>%)</span>
                        </div>
                        <div class="progress-track">
                            <div class="progress-bar-fill" style="width: <%= Math.max(pctSys, 8) %>%; background: #6B7280;"></div>
                        </div>
                    </div>
                </div>

                <!-- Carte 2 : Équité Catégorielle (Permanents vs Doctorants) -->
                <div class="equity-card">
                    <span class="eyebrow" style="color: var(--sage);">Parité & Soutien à la Thèse</span>
                    <h3 style="font-size: 17px; margin-top: 4px; margin-bottom: 16px; color: var(--navy);">Équité Chercheurs Permanents vs Doctorants</h3>
                    
                    <%
                        int totalPers = doctorantsCount + permanentsCount;
                        if (totalPers == 0) totalPers = 1;
                        int pctDoc = (doctorantsCount * 100) / totalPers;
                        int pctPerm = (permanentsCount * 100) / totalPers;
                    %>

                    <div style="margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 4px;">
                            <span>🎓 Doctorants & Jeunes Chercheurs</span>
                            <strong><%= doctorantsCount %> dotation(s) (<%= pctDoc %>%)</strong>
                        </div>
                        <div class="progress-track">
                            <div class="progress-bar-fill" style="width: <%= Math.max(pctDoc, 10) %>%; background: #2E7D32;"></div>
                        </div>

                        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 4px;">
                            <span>🏛️ Enseignants-Chercheurs Permanents</span>
                            <strong><%= permanentsCount %> dotation(s) (<%= pctPerm %>%)</strong>
                        </div>
                        <div class="progress-track">
                            <div class="progress-bar-fill" style="width: <%= Math.max(pctPerm, 10) %>%; background: #152B44;"></div>
                        </div>
                    </div>

                    <div style="background: rgba(46, 125, 50, 0.08); border-left: 3px solid var(--sage); padding: 12px; border-radius: 4px; font-size: 12.5px; color: var(--ink);">
                        <strong>Règle d'or de la gouvernance LIAS :</strong> Les doctorants travaillant sur des modèles lourds (NLP, Deep Learning) bénéficient d'un accès garanti aux stations de calcul haute performance sans discrimination de grade.
                    </div>
                </div>

                <!-- Carte 3 : Charte & Principes de distribution équitable -->
                <div class="equity-card">
                    <span class="eyebrow" style="color: var(--navy);">Audit & Déontologie</span>
                    <h3 style="font-size: 17px; margin-top: 4px; margin-bottom: 12px; color: var(--navy);">Charte de Distribution Équitable</h3>
                    <ul style="padding-left: 20px; font-size: 13px; line-height: 1.6; color: var(--muted);">
                        <li><strong style="color: var(--ink);">Non-monopolisation :</strong> Aucun laboratoire ni membre ne peut concentrer plus de 30% des arrivages récents.</li>
                        <li><strong style="color: var(--ink);">Priorité aux non-pourvus :</strong> Toute nouvelle livraison est orientée préférentiellement vers les membres sans dotation active.</li>
                        <li><strong style="color: var(--ink);">Contrôle par le Directeur :</strong> Arbitrage strict consigné avec justification de projet.</li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- ========================================================================= -->
        <!-- TAB 3 : Historique Complet & Traçabilité du cycle de vie -->
        <!-- ========================================================================= -->
        <div id="viewHistorique" class="table-container" style="display: none;">
            <div style="padding: 16px 20px; background: var(--surface-2); border-bottom: 1px solid var(--border); font-size: 13px; color: var(--navy); font-weight: 600;">
                📜 Historique Complet des Mouvements & Cycle de Vie du Matériel
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Désignation & Caractéristiques</th>
                        <th>Catégorie</th>
                        <th>Bénéficiaire / Demandeur</th>
                        <th>Cycle de Vie & Jalons</th>
                        <th>Statut Actuel</th>
                        <% if (isDirecteur) { %><th>Arbitrage Direction</th><% } %>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (materiels != null && !materiels.isEmpty()) {
                            for (Materiel m : materiels) {
                                String tone = "badge-muted";
                                if ("ACCORDE".equalsIgnoreCase(m.getStatut()) || "LIVRE".equalsIgnoreCase(m.getStatut()) || "ATTRIBUE".equalsIgnoreCase(m.getStatut())) tone = "badge-sage";
                                else if ("EN_ATTENTE".equalsIgnoreCase(m.getStatut())) tone = "badge-gold";
                    %>
                    <tr>
                        <td>
                            <strong style="font-family: var(--font-serif); font-size: 15px;"><%= m.getDesignation() %></strong>
                            <% if (m.getCommentaire() != null && !m.getCommentaire().isEmpty()) { %>
                                <div style="font-size: 12px; color: var(--muted); margin-top: 3px;"><%= m.getCommentaire() %></div>
                            <% } %>
                        </td>
                        <td><span class="badge badge-navy"><%= m.getCategorie() %></span></td>
                        <td><strong><%= m.getDemandeur() != null ? m.getDemandeur() : "Non attribué" %></strong></td>
                        <td>
                            <div style="font-size: 11.5px; line-height: 1.5; color: var(--muted);">
                                <div>• Demande : <strong><%= m.getDateDemande() != null ? m.getDateDemande() : "—" %></strong></div>
                                <% if (m.getDateAttribution() != null) { %>
                                    <div style="color: var(--sage); font-weight: 600;">• Attribution : <%= m.getDateAttribution() %></div>
                                <% } %>
                            </div>
                        </td>
                        <td><span class="badge <%= tone %>"><%= m.getStatut() %></span></td>
                        <% if (isDirecteur) { %>
                        <td>
                            <% if ("EN_ATTENTE".equalsIgnoreCase(m.getStatut())) { %>
                            <div style="display: flex; gap: 6px;">
                                <form action="<%= request.getContextPath() %>/materiel" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="attribuer">
                                    <input type="hidden" name="id" value="<%= m.getId() %>">
                                    <input type="hidden" name="materielId" value="<%= m.getId() %>">
                                    <input type="hidden" name="statut" value="ACCORDE">
                                    <button type="submit" class="btn btn-sm btn-accent" title="Accorder la dotation">✓ Accorder</button>
                                </form>
                                <form action="<%= request.getContextPath() %>/materiel" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="attribuer">
                                    <input type="hidden" name="id" value="<%= m.getId() %>">
                                    <input type="hidden" name="materielId" value="<%= m.getId() %>">
                                    <input type="hidden" name="statut" value="REFUSE">
                                    <button type="submit" class="btn btn-sm btn-danger" title="Refuser">✕</button>
                                </form>
                            </div>
                            <% } else { %>
                                <span style="font-size: 11.5px; color: var(--muted);">✓ Traité</span>
                            <% } %>
                        </td>
                        <% } %>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="6" style="padding: 24px; text-align: center; color: var(--muted);">Aucun équipement enregistré.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- ========================================================================= -->
        <!-- TAB 4 : Suivi « Qui a reçu quoi » -->
        <!-- ========================================================================= -->
        <div id="viewRecu" class="table-container" style="display: none;">
            <div style="padding: 16px 20px; background: rgba(46, 125, 50, 0.06); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center;">
                <span style="font-size: 13.5px; color: var(--sage); font-weight: 700;">
                    ✓ Suivi nominatif des dotations accordées : « Qui a reçu quoi »
                </span>
                <span class="badge badge-sage"><%= attribuesCount %> bénéficiaire(s) pourvu(s)</span>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Chercheur Bénéficiaire</th>
                        <th>Équipement Reçu & Modèle</th>
                        <th>Catégorie</th>
                        <th>Date d'Attribution</th>
                        <th>Projet Rattaché & Justification</th>
                        <th>Statut d'Exploitation</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (recuList != null && !recuList.isEmpty()) {
                            for (Materiel m : recuList) {
                    %>
                    <tr>
                        <td>
                            <strong style="font-family: var(--font-serif); font-size: 15px; color: var(--navy);"><%= m.getDemandeur() %></strong>
                        </td>
                        <td>
                            <strong><%= m.getDesignation() %></strong>
                        </td>
                        <td><span class="badge badge-navy"><%= m.getCategorie() %></span></td>
                        <td style="font-family: var(--font-mono); font-size: 12px; color: var(--accent-2); font-weight: 600;">
                            <%= m.getDateAttribution() != null ? m.getDateAttribution() : m.getDateDemande() %>
                        </td>
                        <td style="font-size: 12px; color: var(--muted);"><%= m.getCommentaire() != null ? m.getCommentaire() : "Attribution validée pour la recherche LIAS" %></td>
                        <td><span class="badge badge-sage"><%= m.getStatut() %></span></td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="6" style="padding: 24px; text-align: center; color: var(--muted);">Aucune dotation encore accordée.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- ========================================================================= -->
        <!-- TAB 5 : Suivi « Qui n'a pas reçu » -->
        <!-- ========================================================================= -->
        <div id="viewNonRecu" style="display: none;">
            
            <!-- Volet A : Demandes exprimées en attente d'arbitrage -->
            <div class="table-container" style="margin-bottom: 28px;">
                <div style="padding: 14px 20px; background: rgba(184, 91, 53, 0.08); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-size: 13.5px; color: var(--accent-2); font-weight: 700;">
                        ⏱️ Volet A : Demandes en attente d'arbitrage budgétaire (<%= attenteCount %>)
                    </span>
                    <span style="font-size: 12px; color: var(--muted);">Chercheurs ayant formulé une demande en attente de dotation</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Demandeur en Attente</th>
                            <th>Équipement Sollicité</th>
                            <th>Catégorie</th>
                            <th>Date de Demande</th>
                            <th>Projet / Thèse</th>
                            <% if (isDirecteur) { %><th>Arbitrage Prioritaire</th><% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (enAttenteList != null && !enAttenteList.isEmpty()) {
                                for (Materiel m : enAttenteList) {
                        %>
                        <tr>
                            <td>
                                <strong style="font-family: var(--font-serif); font-size: 15px; color: var(--accent-2);"><%= m.getDemandeur() %></strong>
                            </td>
                            <td><strong><%= m.getDesignation() %></strong></td>
                            <td><span class="badge badge-navy"><%= m.getCategorie() %></span></td>
                            <td style="font-family: var(--font-mono); font-size: 12px;"><%= m.getDateDemande() %></td>
                            <td style="font-size: 12px; color: var(--muted);"><%= m.getCommentaire() != null ? m.getCommentaire() : "En attente d'arbitrage budgétaire" %></td>
                            <% if (isDirecteur) { %>
                            <td>
                                <form action="<%= request.getContextPath() %>/materiel" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="attribuer">
                                    <input type="hidden" name="id" value="<%= m.getId() %>">
                                    <input type="hidden" name="materielId" value="<%= m.getId() %>">
                                    <input type="hidden" name="statut" value="ACCORDE">
                                    <button type="submit" class="btn btn-sm btn-accent">Attribuer maintenant →</button>
                                </form>
                            </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="6" style="padding: 20px; text-align: center; color: var(--sage); font-weight: 600;">
                                ✓ Aucune demande en attente d'arbitrage budgétaire.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Volet B : Membres actifs du laboratoire sans équipement attribué -->
            <div class="table-container">
                <div style="padding: 14px 20px; background: var(--surface-2); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                    <div>
                        <span style="font-size: 13.5px; color: var(--navy); font-weight: 700;">
                            👥 Volet B : Membres actifs du laboratoire n'ayant reçu aucun matériel (<%= sansMaterielCount %>)
                        </span>
                        <div style="font-size: 12px; color: var(--muted); margin-top: 2px;">
                            Indicateur de distribution équitable : Permet à la Direction d'orienter les nouveaux arrivages vers ces membres prioritaires.
                        </div>
                    </div>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Membre / Chercheur</th>
                            <th>Statut & Grade</th>
                            <th>Équipe</th>
                            <th>Email Institutionnel</th>
                            <th>Date d'Affiliation</th>
                            <% if (isDirecteur) { %><th>Action Direction</th><% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (membresSansMateriel != null && !membresSansMateriel.isEmpty()) {
                                for (Member mb : membresSansMateriel) {
                        %>
                        <tr>
                            <td>
                                <strong style="font-family: var(--font-serif); font-size: 15px; color: var(--navy);">
                                    <%= mb.getFirstName() %> <%= mb.getLastName() %>
                                </strong>
                            </td>
                            <td>
                                <span class="badge badge-gold"><%= mb.getStatus() %></span>
                                <span style="font-size: 12px; color: var(--muted); margin-left: 4px;"><%= mb.getGrade() != null ? mb.getGrade() : "" %></span>
                            </td>
                            <td><span class="badge badge-navy"><%= mb.getTeam() != null ? mb.getTeam() : "LIAS" %></span></td>
                            <td style="font-family: var(--font-mono); font-size: 12px;"><%= mb.getEmail() %></td>
                            <td style="font-family: var(--font-mono); font-size: 12px; color: var(--muted);"><%= mb.getDateAffiliation() != null ? mb.getDateAffiliation() : "2024" %></td>
                            <% if (isDirecteur) { %>
                            <td>
                                <button type="button" class="btn btn-sm btn-secondary" 
                                    onclick="openDotationDirecte('<%= mb.getFirstName() %> <%= mb.getLastName() %> (<%= mb.getStatus() %>)')">
                                    + Attribuer dotation
                                </button>
                            </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="6" style="padding: 24px; text-align: center; color: var(--sage); font-weight: 600;">
                                🏆 Parfaite équité : 100% des membres actifs du laboratoire possèdent une dotation scientifique !
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        </div>

        <!-- Modal / Formulaire d'attribution directe à un membre sans matériel -->
        <% if (isDirecteur) { %>
        <div id="dotationModal" class="card" style="display: none; border-left: 4px solid var(--sage); margin-top: 24px; background: rgba(46, 125, 50, 0.04);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="font-size: 17px; margin: 0; color: var(--sage);">⚖️ Attribution Prioritaire de Matériel pour Distribution Équitable</h3>
                <button type="button" class="btn btn-sm btn-secondary" onclick="closeDotationDirecte()">✕ Annuler</button>
            </div>
            <form action="<%= request.getContextPath() %>/materiel" method="post">
                <input type="hidden" name="action" value="attribuer_direct">
                <div style="display: grid; grid-template-columns: 1.5fr 2fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Bénéficiaire (Membre sans équipement)</label>
                        <input type="text" id="dotationDemandeur" name="demandeur" class="form-control" readonly required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Équipement Attribué</label>
                        <input type="text" name="designation" class="form-control" placeholder="ex: PC Portable Dell Precision 16'' / Station GPU" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Catégorie</label>
                        <select name="categorie" class="form-control">
                            <option value="Poste de Travail">Poste de Travail</option>
                            <option value="Calcul">Calcul / GPU</option>
                            <option value="Réseau">Réseau & Stockage</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Motif de la dotation équitable</label>
                    <input type="text" name="commentaire" class="form-control" value="Dotation équitable au titre du soutien aux membres et doctorants actifs.">
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn btn-primary">Confirmer l'attribution prioritaire →</button>
                    <button type="button" class="btn btn-secondary" onclick="closeDotationDirecte()">Annuler</button>
                </div>
            </form>
        </div>
        <% } %>

            </div>
        </main>
    </div>
</div>

    <script>
        function toggleBesoinForm() {
            var f = document.getElementById('besoinCard');
            if (!f) return;
            f.style.display = f.style.display === 'block' ? 'none' : 'block';
            if (f.style.display === 'block') f.scrollIntoView({ behavior: 'smooth' });
        }
        function toggleArrivageForm() {
            var f = document.getElementById('arrivageCard');
            if (!f) return;
            f.style.display = f.style.display === 'block' ? 'none' : 'block';
            if (f.style.display === 'block') f.scrollIntoView({ behavior: 'smooth' });
        }
        function openDotationDirecte(demandeurName) {
            var m = document.getElementById('dotationModal');
            var input = document.getElementById('dotationDemandeur');
            if (m && input) {
                input.value = demandeurName;
                m.style.display = 'block';
                m.scrollIntoView({ behavior: 'smooth' });
            }
        }
        function closeDotationDirecte() {
            var m = document.getElementById('dotationModal');
            if (m) m.style.display = 'none';
        }
        function switchMaterielTab(tab) {
            var vArrivages = document.getElementById('viewArrivages');
            var vEquite = document.getElementById('viewEquite');
            var vHistorique = document.getElementById('viewHistorique');
            var vRecu = document.getElementById('viewRecu');
            var vNonRecu = document.getElementById('viewNonRecu');

            if (vArrivages) vArrivages.style.display = (tab === 'arrivages') ? 'block' : 'none';
            if (vEquite) vEquite.style.display = (tab === 'equite') ? 'block' : 'none';
            if (vHistorique) vHistorique.style.display = (tab === 'historique') ? 'block' : 'none';
            if (vRecu) vRecu.style.display = (tab === 'recu') ? 'block' : 'none';
            if (vNonRecu) vNonRecu.style.display = (tab === 'nonrecu') ? 'block' : 'none';

            var bArrivages = document.getElementById('tabBtnArrivages');
            var bEquite = document.getElementById('tabBtnEquite');
            var bHistorique = document.getElementById('tabBtnHistorique');
            var bRecu = document.getElementById('tabBtnRecu');
            var bNonRecu = document.getElementById('tabBtnNonRecu');

            if (bArrivages) bArrivages.classList.toggle('active', tab === 'arrivages');
            if (bEquite) bEquite.classList.toggle('active', tab === 'equite');
            if (bHistorique) bHistorique.classList.toggle('active', tab === 'historique');
            if (bRecu) bRecu.classList.toggle('active', tab === 'recu');
            if (bNonRecu) bNonRecu.classList.toggle('active', tab === 'nonrecu');
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
                setTimeout(function() {
                    closeToast();
                }, 5000);
                if (window.history.replaceState) {
                    var cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                    window.history.replaceState({ path: cleanUrl }, '', cleanUrl);
                }
            }
        });
    </script>
</body>
</html>

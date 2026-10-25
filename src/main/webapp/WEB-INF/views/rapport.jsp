<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.Publication"%>
<%@ page import="com.lias.beans.Evenement"%>
<%@ page import="com.lias.beans.Convention"%>
<%@ page import="com.lias.beans.Materiel"%>
<%@ page import="com.lias.beans.ReunionPV"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canCertify = (currentUser != null && ("directeur".equalsIgnoreCase(currentUser.getRole()) || "admin".equalsIgnoreCase(currentUser.getRole())));
    
    Integer annee = (Integer) request.getAttribute("anneeRapport");
    if (annee == null) annee = 2026;

    String msg = request.getParameter("msg");
    String nomDirecteur = (String) request.getAttribute("nomDirecteur");
    if (nomDirecteur == null) nomDirecteur = "Prof. Ibtissam Essadiki";
    String nomViceDirecteur = (String) request.getAttribute("nomViceDirecteur");
    if (nomViceDirecteur == null) nomViceDirecteur = "Prof. Sara Benjelloun";
    String periodeMandat = (String) request.getAttribute("periodeMandat");
    if (periodeMandat == null) periodeMandat = "2024–2027";

    List<Publication> pubs = (List<Publication>) request.getAttribute("publications");
    List<Evenement> evts = (List<Evenement>) request.getAttribute("evenements");
    List<Convention> convs = (List<Convention>) request.getAttribute("conventions");
    List<Materiel> mats = (List<Materiel>) request.getAttribute("materiels");
    List<ReunionPV> pvs = (List<ReunionPV>) request.getAttribute("pvs");

    long dotationSocle = request.getAttribute("dotationSocle") != null ? (Long) request.getAttribute("dotationSocle") : 250000L;
    long incitationPubs = request.getAttribute("incitationPublications") != null ? (Long) request.getAttribute("incitationPublications") : 45000L;
    long soutienEvts = request.getAttribute("soutienEvenements") != null ? (Long) request.getAttribute("soutienEvenements") : 60000L;
    long appuiConvs = request.getAttribute("appuiConventions") != null ? (Long) request.getAttribute("appuiConventions") : 50000L;
    long budgetTotal = request.getAttribute("budgetAnnuelEligibleTotal") != null ? (Long) request.getAttribute("budgetAnnuelEligibleTotal") : 405000L;
    boolean conditionValidee = request.getAttribute("conditionBudgetValidee") != null ? (Boolean) request.getAttribute("conditionBudgetValidee") : true;
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Rapport Annuel d'Activité Scientifique</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        .report-paper {
            background: #FFFFFF;
            border: 1px solid var(--border);
            padding: 56px 64px;
            max-width: 980px;
            margin: 0 auto 60px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
            position: relative;
            border-radius: 4px;
        }
        .report-header-crest {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid var(--navy);
            padding-bottom: 24px;
            margin-bottom: 32px;
        }
        .report-section {
            margin-bottom: 36px;
        }
        .report-section-num {
            font-family: var(--font-mono);
            font-size: 11px;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: var(--accent-2);
            margin-bottom: 6px;
            display: block;
            font-weight: 700;
        }
        .report-section h3 {
            font-size: 20px;
            color: var(--navy);
            border-bottom: 1px solid var(--border);
            padding-bottom: 8px;
            margin-bottom: 14px;
            font-family: var(--font-serif);
        }
        .budget-condition-box {
            background: linear-gradient(135deg, rgba(27, 47, 74, 0.03) 0%, rgba(197, 160, 89, 0.08) 100%);
            border: 1.5px solid var(--accent-2);
            border-radius: 6px;
            padding: 20px 24px;
            margin-bottom: 32px;
            position: relative;
        }
        .budget-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #059669;
            color: #FFFFFF;
            padding: 4px 10px;
            border-radius: 9999px;
            font-size: 11.5px;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }
        .year-tab {
            padding: 7px 14px;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            border: 1px solid var(--border);
            color: var(--navy);
            background: var(--surface);
            transition: all 0.15s;
        }
        .year-tab.active {
            background: var(--navy);
            color: #FFF;
            border-color: var(--navy);
        }
        .toast-notification {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 18px;
            background: #ECFDF5;
            border: 1px solid #A7F3D0;
            border-radius: 4px;
            margin-bottom: 24px;
            color: #065F46;
        }
        .table-custom {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            margin-top: 10px;
        }
        .table-custom th {
            background: var(--surface-2);
            color: var(--navy);
            font-weight: 600;
            text-align: left;
            padding: 9px 12px;
            border: 1px solid var(--border);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .table-custom td {
            padding: 9px 12px;
            border: 1px solid var(--border);
            color: var(--ink);
        }
        .table-custom tr:nth-child(even) td {
            background: rgba(248, 250, 252, 0.6);
        }

        @media print {
            .topbar, footer, .no-print, .app-header, .app-sidebar, .sidebar { display: none !important; }
            body { background: #FFF !important; padding: 0 !important; margin: 0 !important; }
            body::before { display: none; }
            .app-shell, .app-body, .app-main { display: block !important; padding: 0 !important; margin: 0 !important; width: 100% !important; }
            .report-paper { border: none !important; box-shadow: none !important; padding: 0 !important; margin: 0 !important; max-width: 100% !important; }
            .app-content { padding: 0 !important; max-width: 100% !important; }
        }
    </style>
</head>
<body>

<% if (currentUser == null) { %>
    <%@ include file="includes/navbar.jsp" %>
    <div class="container" style="max-width: 1200px; margin: 0 auto; padding: 30px 20px;">
<% } else { %>
    <div class="app-shell">
        <%@ include file="includes/app_header.jsp" %>
        <div class="app-body">
            <%@ include file="includes/sidebar.jsp" %>
            <main class="app-main">
                <div class="app-content">
<% } %>

        <!-- BARRE D'ACTIONS & PILOTAGE ANNUEL -->
        <div class="page-header no-print" style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px; margin-bottom: 24px;">
            <div>
                <span class="eyebrow" style="color: var(--accent-2);">Gouvernance Scientifique & Financement</span>
                <h1 class="page-title">Rapport d'Activité Annuel</h1>
                <p class="page-sub">
                    Génération annuelle automatique basée sur les événements, les publications et les activités. Condition statutaire pour l'arbitrage du budget annuel.
                </p>
            </div>
            
            <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                <!-- Sélecteur d'exercice fiscal -->
                <div style="display: flex; gap: 6px; align-items: center; background: var(--surface-2); padding: 4px; border-radius: 6px; border: 1px solid var(--border);">
                    <span style="font-size: 11px; font-weight: 700; color: var(--muted); padding: 0 6px;">EXERCICE :</span>
                    <a href="<%= request.getContextPath() %>/rapport?annee=2026" class="year-tab <%= annee == 2026 ? "active" : "" %>">2026</a>
                    <a href="<%= request.getContextPath() %>/rapport?annee=2025" class="year-tab <%= annee == 2025 ? "active" : "" %>">2025</a>
                    <a href="<%= request.getContextPath() %>/rapport?annee=2024" class="year-tab <%= annee == 2024 ? "active" : "" %>">2024</a>
                </div>

                <a href="<%= request.getContextPath() %>/rapport?annee=<%= annee %>" class="btn btn-secondary" title="Recalculer dynamiquement l'ensemble des indicateurs de l'année">
                    🔄 Génération Automatique
                </a>

                <button onclick="window.print()" class="btn btn-secondary" title="Imprimer ou exporter en PDF officiel">
                    🖨️ Imprimer / PDF
                </button>

                <% if (canCertify) { %>
                    <form action="<%= request.getContextPath() %>/rapport" method="POST" style="margin: 0;" onsubmit="return confirm('Confirmez-vous l\\'homologation et le dépôt officiel de ce rapport annuel pour l\\'arbitrage du budget annuel ?');">
                        <input type="hidden" name="action" value="certifier_budget">
                        <input type="hidden" name="annee" value="<%= annee %>">
                        <button type="submit" class="btn btn-primary" title="Valider, horodater et archiver ce rapport dans la base légale pour le budget">
                            ✓ Homologuer pour Budget Annuel
                        </button>
                    </form>
                <% } %>
            </div>
        </div>

        <!-- NOTIFICATION TOAST -->
        <% if ("certified".equals(msg)) { %>
            <div class="toast-notification no-print" id="toastCert">
                <div style="font-size: 20px;">✓</div>
                <div>
                    <div style="font-weight: 700; font-size: 14px;">Rapport Annuel <%= annee %> Homologué & Déposé avec Succès !</div>
                    <div style="font-size: 12.5px; opacity: 0.9;">
                        Le document officiel a été archivé dans le registre documentaire (Section 10), horodaté et transmis pour l'arbitrage du budget annuel de recherche.
                    </div>
                </div>
            </div>
        <% } %>

        <!-- DOCUMENT OFFICIEL D'ÉVALUATION SCIENTIFIQUE (PAPER ACADÉMIQUE) -->
        <div class="report-paper">

            <!-- EN-TÊTE OFFICIEL UNIVERSITAIRE -->
            <div class="report-header-crest">
                <div>
                    <div style="font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.15em; text-transform: uppercase; color: var(--muted);">
                        Royaume du Maroc · Université Hassan II de Casablanca
                    </div>
                    <div style="font-family: var(--font-serif); font-size: 22px; font-weight: 700; color: var(--navy); margin-top: 4px;">
                        Faculté des Sciences Ben M'Sik
                    </div>
                    <div style="font-family: var(--font-sans); font-size: 13.5px; color: var(--muted); margin-top: 2px;">
                        Laboratoire d'Informatique et Applications Scientifiques (LIAS) · Créé le 15 Septembre 2003
                    </div>
                </div>
                <div style="text-align: right;">
                    <div class="brand-mark" style="width: 52px; height: 52px; font-size: 30px; margin-left: auto;">L</div>
                    <div style="font-family: var(--font-mono); font-size: 11px; font-weight: 700; color: var(--navy); margin-top: 6px;">
                        EXERCICE SCIENTIFIQUE <%= annee %>
                    </div>
                    <div style="font-size: 11px; color: #059669; font-weight: 600;">
                        ● Génération annuelle automatique
                    </div>
                </div>
            </div>

            <!-- TITRE DU RAPPORT -->
            <div style="text-align: center; margin-bottom: 36px;">
                <span class="eyebrow" style="color: var(--accent-2); font-size: 12px; letter-spacing: 0.2em;">RAPPORT ANNUEL CONSOLIDÉ D'ÉVALUATION</span>
                <h2 style="font-size: 30px; line-height: 1.2; margin: 8px 0 10px; color: var(--navy); font-family: var(--font-serif);">
                    Bilan d'Activité & Rayonnement Scientifique
                </h2>
                <div style="font-family: var(--font-serif); font-style: italic; font-size: 15.5px; color: var(--muted);">
                    Sous la direction du <strong><%= nomDirecteur %></strong> · Vice-direction : <strong><%= nomViceDirecteur %></strong> (Mandat <%= periodeMandat %>)
                </div>
            </div>

            <!-- ENCART OBJECTIF : CONDITION POUR BUDGET ANNUEL (CDC §11) -->
            <div class="budget-condition-box" style="background: #F8FAFC; border: 1.5px solid #CBD5E1; border-left: 5px solid var(--navy); border-radius: 6px; padding: 20px 24px; margin-bottom: 32px;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; margin-bottom: 12px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="font-size: 20px;">🏛️</span>
                        <strong style="color: var(--navy); font-size: 15px;">Objectif Réglementaire (CDC §11) : Condition d'Attribution du Budget Annuel</strong>
                    </div>
                    <span class="budget-pill" style="background: #059669; color: #FFF; padding: 5px 14px; border-radius: 9999px; font-size: 11.5px; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase;">
                        ✓ Rapport Validé & Éligible au Financement
                    </span>
                </div>
                <p style="font-size: 13.5px; line-height: 1.6; color: var(--ink); margin: 0 0 16px;">
                    Conformément aux statuts de l'Université Hassan II et du Ministère de l'Enseignement Supérieur et de la Recherche Scientifique, la transmission et l'homologation de ce rapport d'activité annuel consolidé est la <strong>condition formelle obligatoire</strong> pour l'arbitrage, l'allocation et le renouvellement des crédits de fonctionnement et de recherche du laboratoire LIAS.
                </p>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; background: #FFFFFF; padding: 14px 18px; border-radius: 6px; border: 1px solid var(--border);">
                    <div>
                        <div style="font-size: 11px; color: var(--muted); text-transform: uppercase; font-weight: 600;">1. Événements Organisés :</div>
                        <div style="font-size: 15px; font-weight: 700; color: var(--navy); margin-top: 3px;"><%= request.getAttribute("totalEvenements") != null ? request.getAttribute("totalEvenements") : 0 %> manifestations</div>
                    </div>
                    <div>
                        <div style="font-size: 11px; color: var(--muted); text-transform: uppercase; font-weight: 600;">2. Publications & Travaux :</div>
                        <div style="font-size: 15px; font-weight: 700; color: var(--navy); margin-top: 3px;"><%= request.getAttribute("totalPublications") != null ? request.getAttribute("totalPublications") : 0 %> productions</div>
                    </div>
                    <div>
                        <div style="font-size: 11px; color: var(--muted); text-transform: uppercase; font-weight: 600;">3. Partenariats & Moyens :</div>
                        <div style="font-size: 15px; font-weight: 700; color: var(--navy); margin-top: 3px;"><%= request.getAttribute("totalConventions") != null ? request.getAttribute("totalConventions") : 0 %> conventions · <%= request.getAttribute("totalMateriels") != null ? request.getAttribute("totalMateriels") : 0 %> dotations</div>
                    </div>
                    <div style="border-left: 2px solid #059669; padding-left: 14px;">
                        <div style="font-size: 11px; color: #059669; font-weight: 700; text-transform: uppercase;">Statut d'Arbitrage :</div>
                        <div style="font-size: 14px; font-weight: 700; color: #059669; margin-top: 3px;">Dossier Complet & Homologué</div>
                    </div>
                </div>
            </div>

            <!-- RÉSUMÉ DES INDICATEURS CLÉS (KPIs) -->
            <div class="stats-grid" style="margin-bottom: 36px;">
                <div class="stat-card">
                    <div class="k">1. Événements Scientifiques</div>
                    <div class="v"><%= request.getAttribute("totalEvenements") != null ? request.getAttribute("totalEvenements") : 0 %></div>
                    <div class="s"><%= request.getAttribute("countConferences") %> conf. · <%= request.getAttribute("countSeminaires") %> sém. · <%= request.getAttribute("countWorkshops") %> work.</div>
                </div>
                <div class="stat-card">
                    <div class="k">2. Publications de l'Exercice</div>
                    <div class="v"><%= request.getAttribute("totalPublications") != null ? request.getAttribute("totalPublications") : 0 %></div>
                    <div class="s"><%= request.getAttribute("countArticles") %> articles indexés · <%= request.getAttribute("countConfPubs") %> communications</div>
                </div>
                <div class="stat-card">
                    <div class="k">3. Activités de Recherche</div>
                    <div class="v"><%= request.getAttribute("totalConventions") != null ? (Integer)request.getAttribute("totalConventions") + (Integer)request.getAttribute("totalMateriels") : 0 %></div>
                    <div class="s"><%= request.getAttribute("totalConventions") %> conventions · <%= request.getAttribute("totalMateriels") %> dotations matériel</div>
                </div>
                <div class="stat-card">
                    <div class="k">Capital Humain Actif</div>
                    <div class="v"><%= request.getAttribute("totalMembres") != null ? request.getAttribute("totalMembres") : 0 %></div>
                    <div class="s"><%= request.getAttribute("countPermanents") %> permanents · <%= request.getAttribute("countDoctorants") %> doctorants</div>
                </div>
            </div>

            <!-- ========================================================================= -->
            <!-- SECTION I : BASÉ SUR LES ÉVÉNEMENTS                          -->
            <!-- ========================================================================= -->
            <div class="report-section">
                <span class="report-section-num">Pilier I · Activité Événementielle</span>
                <h3>1. Événements Scientifiques Organisés & Rayonnement</h3>
                <p style="font-size: 14px; line-height: 1.7; color: var(--ink);">
                    Durant l'exercice <strong><%= annee %></strong>, le LIAS a assuré l'animation scientifique à travers l'organisation de 
                    <strong><%= request.getAttribute("totalEvenements") %> manifestations majeures</strong> (Conférences internationales, Séminaires thématiques et Workshops doctoraux), mobilisant l'ensemble des équipes de recherche :
                </p>

                <% if (evts != null && !evts.isEmpty()) { %>
                    <table class="table-custom">
                        <thead>
                            <tr>
                                <th style="width: 105px;">Date</th>
                                <th>Manifestation / Événement</th>
                                <th style="width: 110px;">Type</th>
                                <th style="width: 140px;">Organisateur affecté</th>
                                <th style="width: 140px;">Lieu & Édition</th>
                                <th style="width: 90px;">Statut</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Evenement e : evts) { %>
                                <tr>
                                    <td style="font-family: var(--font-mono); font-weight: 600;"><%= e.getDate() %></td>
                                    <td>
                                        <strong><%= e.getTitre() %></strong>
                                        <% if (e.getDescription() != null && !e.getDescription().trim().isEmpty()) { %>
                                            <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;"><%= e.getDescription() %></div>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="badge badge-navy" style="font-size: 11px;"><%= e.getType() %></span>
                                    </td>
                                    <td style="font-size: 12.5px; color: var(--navy); font-weight: 600;">
                                        👤 <%= e.getOrganisateur() != null ? e.getOrganisateur() : "Comité d'organisation" %>
                                    </td>
                                    <td style="font-size: 12px; color: var(--muted);">
                                        <%= e.getLieu() != null ? e.getLieu() : "FSBM" %><br>
                                        <span style="font-family: var(--font-mono); font-size: 10.5px;"><%= e.getEdition() != null ? e.getEdition() : "Édition " + annee %></span>
                                    </td>
                                    <td>
                                        <span class="badge <%= "Archivé".equalsIgnoreCase(e.getStatut()) ? "badge-navy" : "badge-outline" %>" style="font-size: 10px;">
                                            <%= e.getStatut() %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div style="padding: 16px; background: var(--surface-2); border-radius: 4px; font-size: 13px; color: var(--muted); font-style: italic;">
                        Aucun événement scientifique formellement enregistré pour l'exercice <%= annee %>.
                    </div>
                <% } %>
            </div>

            <!-- ========================================================================= -->
            <!-- SECTION II : BASÉ SUR LES PUBLICATIONS                       -->
            <!-- ========================================================================= -->
            <div class="report-section">
                <span class="report-section-num">Pilier II · Production Académique</span>
                <h3>2. Publications Scientifiques & Productions de l'Exercice</h3>
                <p style="font-size: 14px; line-height: 1.7; color: var(--ink);">
                    La production scientifique de l'exercice <strong><%= annee %></strong> compte 
                    <strong><%= request.getAttribute("totalPublications") %> publications validées</strong> dans des revues internationales indexées (Scopus / Web of Science) et actes de colloques sélectifs :
                </p>

                <% if (pubs != null && !pubs.isEmpty()) { %>
                    <table class="table-custom">
                        <thead>
                            <tr>
                                <th style="width: 60px;">Année</th>
                                <th>Titre de la publication</th>
                                <th style="width: 170px;">Auteurs</th>
                                <th style="width: 160px;">Revue / Conférence & DOI</th>
                                <th style="width: 80px;">Équipe</th>
                                <th style="width: 85px;">Format</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Publication p : pubs) { %>
                                <tr>
                                    <td style="font-family: var(--font-mono); font-weight: 700;"><%= p.getAnnee() %></td>
                                    <td>
                                        <strong style="color: var(--navy);"><%= p.getTitre() %></strong>
                                    </td>
                                    <td style="font-size: 12px; color: var(--ink);">
                                        <%= p.getAuteurs() %>
                                    </td>
                                    <td style="font-size: 12px;">
                                        <em><%= p.getRevue() != null ? p.getRevue() : "Actes LIAS" %></em>
                                        <% if (p.getDoi() != null && !p.getDoi().trim().isEmpty()) { %>
                                            <div style="font-family: var(--font-mono); font-size: 10.5px; color: var(--muted); margin-top: 2px;">
                                                DOI : <%= p.getDoi() %>
                                            </div>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="badge badge-outline" style="font-size: 11px;"><%= p.getEquipe() != null ? p.getEquipe() : "LIAS" %></span>
                                    </td>
                                    <td>
                                        <span class="badge <%= "Article".equalsIgnoreCase(p.getType()) ? "badge-navy" : "badge-secondary" %>" style="font-size: 10px;">
                                            <%= p.getType() != null ? p.getType() : "Article" %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div style="padding: 16px; background: var(--surface-2); border-radius: 4px; font-size: 13px; color: var(--muted); font-style: italic;">
                        Aucune publication scientifique répertoriée pour l'année <%= annee %>.
                    </div>
                <% } %>
            </div>

            <!-- ========================================================================= -->
            <!-- SECTION III : BASÉ SUR LES ACTIVITÉS                         -->
            <!-- ========================================================================= -->
            <div class="report-section">
                <span class="report-section-num">Pilier III · Projets, Moyens & Activités</span>
                <h3>3. Activités de Recherche, Partenariats & Dotations Matérielles</h3>
                <p style="font-size: 14px; line-height: 1.7; color: var(--ink);">
                    Le développement des activités scientifiques du laboratoire s'appuie sur des partenariats institutionnels et industriels, ainsi que sur l'affectation équitable des moyens matériels et informatiques :
                </p>

                <!-- 3.1 Conventions et Partenariats de Recherche -->
                <h4 style="font-size: 15px; color: var(--navy); margin: 18px 0 8px;">3.1 Conventions de Recherche & Partenariats Actifs</h4>
                <% if (convs != null && !convs.isEmpty()) { %>
                    <table class="table-custom">
                        <thead>
                            <tr>
                                <th>Organisme Partenaire</th>
                                <th style="width: 110px;">Type Partenaire</th>
                                <th>Objet de la Convention</th>
                                <th style="width: 100px;">Statut</th>
                                <th style="width: 110px;">Budget Alloué</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Convention c : convs) { %>
                                <tr>
                                    <td><strong><%= c.getOrganismePartenaire() %></strong></td>
                                    <td><span class="badge badge-secondary" style="font-size: 10.5px;"><%= c.getTypePartenaire() %></span></td>
                                    <td style="font-size: 12.5px;"><%= c.getObjet() %></td>
                                    <td>
                                        <span class="badge <%= "Active".equalsIgnoreCase(c.getStatut()) ? "badge-navy" : "badge-outline" %>" style="font-size: 10px;">
                                            <%= c.getStatut() %>
                                        </span>
                                    </td>
                                    <td style="font-family: var(--font-mono); font-weight: 700; color: #059669;">
                                        <%= c.getBudgetAlloue() != null ? String.format("%,.0f MAD", c.getBudgetAlloue()) : "—" %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div style="font-size: 12.5px; color: var(--muted); font-style: italic;">Aucune convention spécifique pour cette période.</div>
                <% } %>

                <!-- 3.2 Dotations de Matériel Scientifique & Équipements Déployés -->
                <h4 style="font-size: 15px; color: var(--navy); margin: 22px 0 8px;">3.2 Dotations en Matériel & Équipements Scientifiques Déployés</h4>
                <% if (mats != null && !mats.isEmpty()) { %>
                    <table class="table-custom">
                        <thead>
                            <tr>
                                <th>Désignation de l'Équipement</th>
                                <th style="width: 110px;">Catégorie</th>
                                <th style="width: 160px;">Bénéficiaire / Équipe</th>
                                <th style="width: 100px;">Statut</th>
                                <th style="width: 110px;">Date Attribution</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Materiel m : mats) { %>
                                <tr>
                                    <td><strong><%= m.getDesignation() %></strong></td>
                                    <td><span class="badge badge-outline" style="font-size: 10.5px;"><%= m.getCategorie() %></span></td>
                                    <td style="font-size: 12.5px;"><%= m.getDemandeur() %></td>
                                    <td>
                                        <span class="badge <%= "LIVRE".equalsIgnoreCase(m.getStatut()) || "ACCORDE".equalsIgnoreCase(m.getStatut()) ? "badge-navy" : "badge-secondary" %>" style="font-size: 10px;">
                                            <%= m.getStatut() %>
                                        </span>
                                    </td>
                                    <td style="font-family: var(--font-mono); font-size: 12px;"><%= m.getDateAttribution() != null ? m.getDateAttribution() : "En cours" %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div style="font-size: 12.5px; color: var(--muted); font-style: italic;">Aucune dotation de matériel enregistrée pour cet exercice.</div>
                <% } %>

                <!-- 3.3 Capital Humain et Encadrement Doctoral -->
                <h4 style="font-size: 15px; color: var(--navy); margin: 22px 0 8px;">3.3 Capital Humain, Encadrement Doctoral & Équipes</h4>
                <div style="background: var(--surface-2); padding: 14px 18px; border-radius: 4px; font-size: 13.5px; line-height: 1.7;">
                    L'effectif statutaire du LIAS pour l'exercice <%= annee %> comprend 
                    <strong><%= request.getAttribute("totalMembres") %> chercheurs actifs</strong>, répartis entre :
                    <strong><%= request.getAttribute("countPermanents") %> Enseignants-Chercheurs Permanents</strong>, 
                    <strong><%= request.getAttribute("countDoctorants") %> Doctorants en cours de thèse</strong> et 
                    <strong><%= request.getAttribute("countAssocies") %> Chercheurs Associés</strong>.
                    Toutes les thèses font l'objet d'un suivi annuel validé en Conseil de Laboratoire.
                </div>
            </div>

            <!-- ========================================================================= -->
            <!-- SECTION IV : VISA, SIGNATURE & CACHET ÉLECTRONIQUE              -->
            <!-- ========================================================================= -->
            <div style="margin-top: 48px; padding-top: 24px; border-top: 2px solid var(--navy); display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 20px;">
                <div>
                    <div style="font-size: 12.5px; color: var(--muted);">
                        Fait à Casablanca (Faculté des Sciences Ben M'Sik), le <%= java.time.LocalDate.now() %>
                    </div>
                    <div style="font-family: var(--font-mono); font-size: 11px; color: #059669; font-weight: 600; margin-top: 4px;">
                        ✓ Document certifié conforme pour transmission ministérielle & arbitrage budgétaire
                    </div>
                    <div style="font-size: 11px; color: var(--muted); margin-top: 2px;">
                        Archivage légal permanent sous référence : <code>DOC-LIAS-<%= annee %>-RAPPORT-ANNUEL</code>
                    </div>
                </div>

                <div style="text-align: center; min-width: 240px; padding: 12px; border: 1px dashed var(--border); border-radius: 4px; background: rgba(248, 250, 252, 0.7);">
                    <div style="font-family: var(--font-serif); font-size: 14px; font-weight: 700; color: var(--navy);">
                        Le Directeur du Laboratoire LIAS
                    </div>
                    <div style="font-family: var(--font-serif); font-style: italic; font-size: 17px; color: var(--navy); margin-top: 14px; font-weight: 600;">
                        <%= nomDirecteur %>
                    </div>
                    <div style="font-family: var(--font-mono); font-size: 9.5px; color: #059669; letter-spacing: 0.12em; margin-top: 6px; font-weight: 700;">
                        [CACHET ÉLECTRONIQUE MINISTÉRIEL HOMOLOGUÉ]
                    </div>
                </div>
            </div>

        </div>

<% if (currentUser == null) { %>
    </div>
<% } else { %>
                </div>
            </main>
        </div>
    </div>
<% } %>

</body>
</html>

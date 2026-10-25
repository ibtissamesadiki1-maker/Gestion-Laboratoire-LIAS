<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.lias.beans.DemandeAdhesion" %>
            <%@ page import="com.lias.beans.User" %>
                <% User currentUser=(User) session.getAttribute("currentUser"); if (currentUser==null)
                    currentUser=(User) session.getAttribute("user"); boolean isDirecteur=(currentUser !=null &&
                    ("directeur".equalsIgnoreCase(currentUser.getRole()) || "admin"
                    .equalsIgnoreCase(currentUser.getRole()))); String msg=request.getParameter("msg");
                    List<DemandeAdhesion> demandes = (List<DemandeAdhesion>) request.getAttribute("demandes");
                        if (demandes == null) {
                        demandes = (List<DemandeAdhesion>) request.getAttribute("adhesions");
                            }
                            DemandeAdhesion suivi = (DemandeAdhesion) request.getAttribute("suiviCandidature");
                            String searchedEmail = (String) request.getAttribute("searchedEmail");
                            %>
                            <!DOCTYPE html>
                            <html lang="fr">

                            <head>
                                <meta charset="UTF-8">
                                <title>LIAS — Demandes d'Adhésion & Recrutement</title>
                                <meta name="viewport" content="width=device-width, initial-scale=1">
                                <link rel="stylesheet"
                                    href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
                                <style>
                                    .modal-backdrop-custom {
                                        position: fixed;
                                        top: 0;
                                        left: 0;
                                        width: 100vw;
                                        height: 100vh;
                                        background: rgba(15, 23, 42, 0.65);
                                        backdrop-filter: blur(4px);
                                        z-index: 9999;
                                        display: none;
                                        align-items: center;
                                        justify-content: center;
                                        padding: 20px;
                                    }

                                    .modal-backdrop-custom.active {
                                        display: flex;
                                    }

                                    .modal-card {
                                        background: var(--surface);
                                        border: 1px solid var(--border);
                                        border-radius: 6px;
                                        max-width: 680px;
                                        width: 100%;
                                        max-height: 90vh;
                                        overflow-y: auto;
                                        padding: 32px;
                                        box-shadow: var(--shadow-lg);
                                        animation: modalFadeIn 0.2s ease-out;
                                    }

                                    @keyframes modalFadeIn {
                                        from {
                                            opacity: 0;
                                            transform: translateY(12px) scale(0.98);
                                        }

                                        to {
                                            opacity: 1;
                                            transform: translateY(0) scale(1);
                                        }
                                    }

                                    .dossier-grid {
                                        display: grid;
                                        grid-template-columns: 140px 1fr;
                                        gap: 12px 16px;
                                        margin: 20px 0;
                                        font-size: 13.5px;
                                    }

                                    .dossier-label {
                                        color: var(--muted);
                                        font-weight: 600;
                                    }

                                    .dossier-value {
                                        color: var(--navy);
                                    }

                                    .motivation-quote {
                                        background: rgba(244, 239, 230, 0.6);
                                        border-left: 3px solid var(--accent-2);
                                        padding: 14px 18px;
                                        font-family: var(--font-serif);
                                        font-style: italic;
                                        font-size: 14px;
                                        line-height: 1.6;
                                        color: var(--ink);
                                        border-radius: 0 4px 4px 0;
                                        margin-top: 6px;
                                        white-space: pre-wrap;
                                    }

                                    .cv-upload-card {
                                        border: 2px dashed #CBD5E1;
                                        border-radius: 12px;
                                        background: #F8FAFC;
                                        cursor: pointer;
                                        transition: all 0.2s ease;
                                        overflow: hidden;
                                        margin-top: 6px;
                                    }

                                    .cv-upload-card:hover {
                                        border-color: #0284C7;
                                        background: #F0F9FF;
                                    }

                                    .cv-upload-card.dragover {
                                        border-color: #0284C7;
                                        background: #E0F2FE;
                                        transform: scale(1.005);
                                    }
                                </style>
                            </head>

                            <body>

                                <% if (currentUser==null) { %>
                                    <%@ include file="includes/navbar.jsp" %>
                                        <div class="container"
                                            style="max-width: 1100px; margin: 0 auto; padding: 40px 24px;">
                                            <% } else { %>
                                                <div class="app-shell">
                                                    <%@ include file="includes/app_header.jsp" %>
                                                        <div class="app-body">
                                                            <%@ include file="includes/sidebar.jsp" %>
                                                                <main class="app-main">
                                                                    <div class="app-content">
                                                                        <% } %>

                                                                            <!-- Page Header -->
                                                                            <div class="page-header">
                                                                                <div>
                                                                                    <span class="eyebrow">
                                                                                        <%= isDirecteur
                                                                                            ? "Gouvernance & Recrutement · Décision Directeur en Mandat"
                                                                                            : "Rejoindre le Laboratoire LIAS · FSBM Casablanca"
                                                                                            %>
                                                                                    </span>
                                                                                    <h1 class="page-title">Gestion des
                                                                                        Demandes d'Adhésion ⭐</h1>
                                                                                    <p class="page-sub">
                                                                                        Procédure officielle d'accueil
                                                                                        des doctorants,
                                                                                        enseignants-chercheurs et
                                                                                        chercheurs associés au sein du
                                                                                        LIAS. Chaque décision est
                                                                                        instruite exclusivement par le
                                                                                        directeur en mandat actif.
                                                                                    </p>
                                                                                </div>
                                                                                <% if (!isDirecteur &&
                                                                                    currentUser==null) { %>
                                                                                    <div
                                                                                        style="display: flex; gap: 10px;">
                                                                                        <a href="#formulaireCandidature"
                                                                                            class="btn btn-primary">Déposer
                                                                                            une candidature ↓</a>
                                                                                        <a href="#suiviCandidature"
                                                                                            class="btn btn-secondary">Suivre
                                                                                            ma candidature</a>
                                                                                    </div>
                                                                                    <% } %>
                                                                            </div>

                                                                            <% if ("soumission_reussie".equals(msg)) {
                                                                                %>
                                                                                <div class="toast-notification"
                                                                                    id="appToast">
                                                                                    <div class="toast-icon">✓</div>
                                                                                    <div class="toast-content">
                                                                                        <div class="toast-title">
                                                                                            Candidature transmise avec
                                                                                            succès !</div>
                                                                                        <div class="toast-desc">Votre
                                                                                            dossier complet (CV,
                                                                                            motivation, rattachement) a
                                                                                            été enregistré et transmis à
                                                                                            la direction du laboratoire
                                                                                            LIAS. Vous pouvez suivre son
                                                                                            statut ci-dessous.</div>
                                                                                    </div>
                                                                                    <button type="button"
                                                                                        class="toast-close"
                                                                                        onclick="closeToast()"
                                                                                        title="Fermer">✕</button>
                                                                                </div>
                                                                                <% } else if
                                                                                    ("decision_enregistree".equals(msg))
                                                                                    { %>
                                                                                    <div class="toast-notification"
                                                                                        id="appToast">
                                                                                        <div class="toast-icon">✓</div>
                                                                                        <div class="toast-content">
                                                                                            <div class="toast-title">
                                                                                                Décision directoriale
                                                                                                enregistrée !</div>
                                                                                            <div class="toast-desc">
                                                                                                L'arbitrage a été
                                                                                                appliqué : si acceptée,
                                                                                                le compte d'accès et
                                                                                                l'affiliation sont créés
                                                                                                ; si refusée, la
                                                                                                notification officielle
                                                                                                a été transmise.</div>
                                                                                        </div>
                                                                                        <button type="button"
                                                                                            class="toast-close"
                                                                                            onclick="closeToast()"
                                                                                            title="Fermer">✕</button>
                                                                                    </div>
                                                                                    <% } %>

                                                                                        <% if (isDirecteur) { int
                                                                                            nbAttente=0; int
                                                                                            nbAcceptees=0; int
                                                                                            nbRefusees=0; if (demandes
                                                                                            !=null) { for
                                                                                            (DemandeAdhesion d :
                                                                                            demandes) { if
                                                                                            ("ACCEPTEE".equalsIgnoreCase(d.getDecision()))
                                                                                            nbAcceptees++; else if
                                                                                            ("REFUSEE".equalsIgnoreCase(d.getDecision()))
                                                                                            nbRefusees++; else
                                                                                            nbAttente++; } } %>
                                                                                            <!-- ESPACE DIRECTEUR : Métriques & Arbitrage des Candidatures -->
                                                                                            <div
                                                                                                style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;">
                                                                                                <div class="card"
                                                                                                    style="padding: 20px; border-left: 4px solid var(--navy);">
                                                                                                    <span
                                                                                                        style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.08em; color: var(--muted); font-weight: 600;">Total
                                                                                                        Dossiers
                                                                                                        Reçus</span>
                                                                                                    <div
                                                                                                        style="font-family: var(--font-serif); font-size: 28px; font-weight: 700; color: var(--navy); margin-top: 6px;">
                                                                                                        <%= demandes
                                                                                                            !=null ?
                                                                                                            demandes.size()
                                                                                                            : 0 %>
                                                                                                    </div>
                                                                                                    <div
                                                                                                        style="font-size: 11.5px; color: var(--muted); margin-top: 4px;">
                                                                                                        Candidatures en
                                                                                                        ligne</div>
                                                                                                </div>
                                                                                                <div class="card"
                                                                                                    style="padding: 20px; border-left: 4px solid var(--accent-2);">
                                                                                                    <span
                                                                                                        style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.08em; color: var(--muted); font-weight: 600;">En
                                                                                                        Instance
                                                                                                        d'Arbitrage</span>
                                                                                                    <div
                                                                                                        style="font-family: var(--font-serif); font-size: 28px; font-weight: 700; color: var(--accent-2); margin-top: 6px;">
                                                                                                        <%= nbAttente %>
                                                                                                    </div>
                                                                                                    <div
                                                                                                        style="font-size: 11.5px; color: var(--muted); margin-top: 4px;">
                                                                                                        Décision
                                                                                                        directoriale
                                                                                                        requise</div>
                                                                                                </div>
                                                                                                <div class="card"
                                                                                                    style="padding: 20px; border-left: 4px solid var(--accent);">
                                                                                                    <span
                                                                                                        style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.08em; color: var(--muted); font-weight: 600;">Dossiers
                                                                                                        Validés &
                                                                                                        Intégrés</span>
                                                                                                    <div
                                                                                                        style="font-family: var(--font-serif); font-size: 28px; font-weight: 700; color: var(--accent); margin-top: 6px;">
                                                                                                        <%= nbAcceptees
                                                                                                            %>
                                                                                                    </div>
                                                                                                    <div
                                                                                                        style="font-size: 11.5px; color: var(--muted); margin-top: 4px;">
                                                                                                        Comptes membres
                                                                                                        activés</div>
                                                                                                </div>
                                                                                            </div>

                                                                                            <div class="card"
                                                                                                style="border-left: 4px solid var(--accent-2); margin-bottom: 32px;">
                                                                                                <div
                                                                                                    style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                                                                                                    <div>
                                                                                                        <span
                                                                                                            class="eyebrow">Dossiers
                                                                                                            & Registre
                                                                                                            d'Adhésion ·
                                                                                                            Uniquement
                                                                                                            par le
                                                                                                            directeur en
                                                                                                            mandat</span>
                                                                                                        <h2
                                                                                                            style="font-size: 22px; margin: 4px 0 0;">
                                                                                                            Arbitrage
                                                                                                            des Demandes
                                                                                                            d'Intégration
                                                                                                            au LIAS</h2>
                                                                                                    </div>
                                                                                                    <span
                                                                                                        class="badge badge-gold">
                                                                                                        <%= nbAttente %>
                                                                                                            en attente
                                                                                                            d'arbitrage
                                                                                                    </span>
                                                                                                </div>
                                                                                                <p
                                                                                                    style="font-size: 13.5px; color: var(--muted); margin-bottom: 24px;">
                                                                                                    Chaque candidature
                                                                                                    acceptée génère
                                                                                                    automatiquement le
                                                                                                    compte d'accès du
                                                                                                    membre, son
                                                                                                    rattachement à
                                                                                                    l'équipe et sa
                                                                                                    première période
                                                                                                    d'affiliation. En
                                                                                                    cas de refus, une
                                                                                                    notification
                                                                                                    officielle et un
                                                                                                    email automatique
                                                                                                    sont consignés.
                                                                                                </p>

                                                                                                <div
                                                                                                    class="table-container">
                                                                                                    <table>
                                                                                                        <thead>
                                                                                                            <tr>
                                                                                                                <th>Date
                                                                                                                </th>
                                                                                                                <th>Candidat
                                                                                                                </th>
                                                                                                                <th>Contact
                                                                                                                    Email
                                                                                                                </th>
                                                                                                                <th>Statut
                                                                                                                    Visé
                                                                                                                </th>
                                                                                                                <th>Établissement
                                                                                                                </th>
                                                                                                                <th>CV /
                                                                                                                    Dossier
                                                                                                                </th>
                                                                                                                <th>Décision
                                                                                                                    &
                                                                                                                    Actions
                                                                                                                </th>
                                                                                                            </tr>
                                                                                                        </thead>
                                                                                                        <tbody>
                                                                                                            <% if
                                                                                                                (demandes
                                                                                                                !=null
                                                                                                                &&
                                                                                                                !demandes.isEmpty())
                                                                                                                { for
                                                                                                                (DemandeAdhesion
                                                                                                                d :
                                                                                                                demandes)
                                                                                                                {
                                                                                                                boolean
                                                                                                                isPending=(d.getDecision()==null
                                                                                                                || "EN_ATTENTE"
                                                                                                                .equalsIgnoreCase(d.getDecision()));
                                                                                                                boolean
                                                                                                                isAccepted="ACCEPTEE"
                                                                                                                .equalsIgnoreCase(d.getDecision());
                                                                                                                boolean
                                                                                                                isRefused="REFUSEE"
                                                                                                                .equalsIgnoreCase(d.getDecision());
                                                                                                                String
                                                                                                                motEsc=d.getMotivation()
                                                                                                                !=null ?
                                                                                                                d.getMotivation().replace("\"", "&quot;"
                                                                                                                ).replace("'", "\\'"
                                                                                                                ) : "" ;
                                                                                                                %>
                                                                                                                <tr>
                                                                                                                    <td
                                                                                                                        style="font-family: var(--font-mono); font-size: 12px;">
                                                                                                                        <%= d.getDateSoumission()
                                                                                                                            %>
                                                                                                                    </td>
                                                                                                                    <td>
                                                                                                                        <a href="javascript:void(0)"
                                                                                                                            onclick="openDossierModal('<%= d.getId() %>', '<%= d.getNom().replace("'", "\\'") %>', '<%= d.getPrenom().replace("'", "\\'") %>', '<%= d.getEmail().replace("'", "\\'") %>', '<%= d.getStatutVise() %>', '<%= d.getEtablissement().replace("'", "\\'") %>', '<%= d.getCvPath() %>', '<%= motEsc %>', '<%= d.getDateSoumission() %>', '<%= d.getDecision() %>')"
                                                                                                                            style="text-decoration: none; color: inherit;">
                                                                                                                            <strong
                                                                                                                                style="font-family: var(--font-serif); font-size: 15px; color: var(--navy);">
                                                                                                                                <%= d.getNom()
                                                                                                                                    %>
                                                                                                                                    <%= d.getPrenom()
                                                                                                                                        %>
                                                                                                                            </strong>
                                                                                                                        </a>
                                                                                                                        <% if
                                                                                                                            (d.getMotivation()
                                                                                                                            !=null
                                                                                                                            &&
                                                                                                                            !d.getMotivation().trim().isEmpty())
                                                                                                                            {
                                                                                                                            %>
                                                                                                                            <div style="font-size: 11.5px; color: var(--muted); margin-top: 3px; max-width: 240px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"
                                                                                                                                title="<%= d.getMotivation() %>">
                                                                                                                                <%= d.getMotivation()
                                                                                                                                    %>
                                                                                                                            </div>
                                                                                                                            <% }
                                                                                                                                %>
                                                                                                                    </td>
                                                                                                                    <td
                                                                                                                        style="font-family: var(--font-mono); font-size: 12px; color: var(--navy);">
                                                                                                                        <%= d.getEmail()
                                                                                                                            %>
                                                                                                                    </td>
                                                                                                                    <td><span
                                                                                                                            class="badge badge-navy">
                                                                                                                            <%= d.getStatutVise()
                                                                                                                                %>
                                                                                                                        </span>
                                                                                                                    </td>
                                                                                                                    <td
                                                                                                                        style="font-size: 12.5px; color: var(--muted);">
                                                                                                                        <%= d.getEtablissement()
                                                                                                                            %>
                                                                                                                    </td>
                                                                                                                    <td>
                                                                                                                        <span
                                                                                                                            class="badge badge-gold"
                                                                                                                            style="font-size: 11px; cursor: pointer;"
                                                                                                                            onclick="openDossierModal('<%= d.getId() %>', '<%= d.getNom().replace("'", "\\'") %>', '<%= d.getPrenom().replace("'", "\\'") %>', '<%= d.getEmail().replace("'", "\\'") %>', '<%= d.getStatutVise() %>', '<%= d.getEtablissement().replace("'", "\\'") %>', '<%= d.getCvPath() %>', '<%= motEsc %>', '<%= d.getDateSoumission() %>', '<%= d.getDecision() %>')">
                                                                                                                            📄
                                                                                                                            <%= d.getCvPath()
                                                                                                                                !=null
                                                                                                                                ?
                                                                                                                                d.getCvPath().substring(d.getCvPath().lastIndexOf("/")
                                                                                                                                +
                                                                                                                                1)
                                                                                                                                : "CV_candidat.pdf"
                                                                                                                                %>
                                                                                                                        </span>
                                                                                                                    </td>
                                                                                                                    <td>
                                                                                                                        <% if
                                                                                                                            (isPending)
                                                                                                                            {
                                                                                                                            %>
                                                                                                                            <div
                                                                                                                                style="display: inline-flex; gap: 6px; align-items: center;">
                                                                                                                                <form
                                                                                                                                    action="<%= request.getContextPath() %>/adhesions"
                                                                                                                                    method="post"
                                                                                                                                    style="display: inline;"
                                                                                                                                    onsubmit="return confirm('Valider la candidature de <%= d.getPrenom() %> <%= d.getNom() %> ? Cette action va créer son compte membre et sa période d\'affiliation.');">
                                                                                                                                    <input
                                                                                                                                        type="hidden"
                                                                                                                                        name="demandeId"
                                                                                                                                        value="<%= d.getId() %>">
                                                                                                                                    <button
                                                                                                                                        type="submit"
                                                                                                                                        name="action"
                                                                                                                                        value="valider"
                                                                                                                                        class="btn btn-sm btn-accent"
                                                                                                                                        title="Valider le dossier et intégrer le membre">✓
                                                                                                                                        Accepter</button>
                                                                                                                                </form>
                                                                                                                                <form
                                                                                                                                    action="<%= request.getContextPath() %>/adhesions"
                                                                                                                                    method="post"
                                                                                                                                    style="display: inline;"
                                                                                                                                    onsubmit="return confirm('Refuser la candidature de <%= d.getPrenom() %> <%= d.getNom() %> ? Une notification officielle de refus sera transmise.');">
                                                                                                                                    <input
                                                                                                                                        type="hidden"
                                                                                                                                        name="demandeId"
                                                                                                                                        value="<%= d.getId() %>">
                                                                                                                                    <button
                                                                                                                                        type="submit"
                                                                                                                                        name="action"
                                                                                                                                        value="refuser"
                                                                                                                                        class="btn btn-sm btn-danger"
                                                                                                                                        title="Refuser la candidature">✕
                                                                                                                                        Refuser</button>
                                                                                                                                </form>
                                                                                                                                <button
                                                                                                                                    type="button"
                                                                                                                                    class="btn btn-sm btn-secondary"
                                                                                                                                    onclick="openDossierModal('<%= d.getId() %>', '<%= d.getNom().replace("'", "\\'") %>', '<%= d.getPrenom().replace("'", "\\'") %>', '<%= d.getEmail().replace("'", "\\'") %>', '<%= d.getStatutVise() %>', '<%= d.getEtablissement().replace("'", "\\'") %>', '<%= d.getCvPath() %>', '<%= motEsc %>', '<%= d.getDateSoumission() %>', '<%= d.getDecision() %>')"
                                                                                                                                    title="Voir dossier complet">Détails</button>
                                                                                                                            </div>
                                                                                                                            <% } else
                                                                                                                                if
                                                                                                                                (isAccepted)
                                                                                                                                {
                                                                                                                                %>
                                                                                                                                <span
                                                                                                                                    class="badge badge-accent"
                                                                                                                                    style="display: inline-flex; align-items: center; gap: 4px;">✓
                                                                                                                                    Acceptée
                                                                                                                                    (Compte
                                                                                                                                    créé)</span>
                                                                                                                                <% } else
                                                                                                                                    if
                                                                                                                                    (isRefused)
                                                                                                                                    {
                                                                                                                                    %>
                                                                                                                                    <span
                                                                                                                                        class="badge badge-danger"
                                                                                                                                        style="display: inline-flex; align-items: center; gap: 4px;">✕
                                                                                                                                        Refusée
                                                                                                                                        (Notifiée)</span>
                                                                                                                                    <% }
                                                                                                                                        %>
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                                <% } }
                                                                                                                    else
                                                                                                                    { %>
                                                                                                                    <tr>
                                                                                                                        <td colspan="7"
                                                                                                                            style="padding: 24px; text-align: center; color: var(--muted);">
                                                                                                                            Aucune
                                                                                                                            demande
                                                                                                                            d'adhésion
                                                                                                                            enregistrée.
                                                                                                                        </td>
                                                                                                                    </tr>
                                                                                                                    <% }
                                                                                                                        %>
                                                                                                        </tbody>
                                                                                                    </table>
                                                                                                </div>
                                                                                            </div>

                                                                                            <!-- Modal Détails Dossier Direction -->
                                                                                            <div id="dossierModalBackdrop"
                                                                                                class="modal-backdrop-custom"
                                                                                                onclick="closeDossierModalOnBackdrop(event)">
                                                                                                <div class="modal-card">
                                                                                                    <div
                                                                                                        style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px;">
                                                                                                        <div>
                                                                                                            <span
                                                                                                                class="eyebrow">Examen
                                                                                                                Institutionnel
                                                                                                                ·
                                                                                                                Direction
                                                                                                                LIAS</span>
                                                                                                            <h3 id="modalCandidatNom"
                                                                                                                style="font-size: 22px; margin: 4px 0 0; color: var(--navy);">
                                                                                                                Dossier
                                                                                                                de
                                                                                                                Candidature
                                                                                                            </h3>
                                                                                                        </div>
                                                                                                        <button
                                                                                                            type="button"
                                                                                                            onclick="closeDossierModal()"
                                                                                                            style="background: none; border: none; font-size: 22px; cursor: pointer; color: var(--muted);">✕</button>
                                                                                                    </div>

                                                                                                    <div
                                                                                                        class="dossier-grid">
                                                                                                        <span
                                                                                                            class="dossier-label">Statut
                                                                                                            Postulé
                                                                                                            :</span>
                                                                                                        <span
                                                                                                            class="dossier-value"
                                                                                                            id="modalStatutVise"></span>

                                                                                                        <span
                                                                                                            class="dossier-label">Email
                                                                                                            Académique
                                                                                                            :</span>
                                                                                                        <span
                                                                                                            class="dossier-value"
                                                                                                            id="modalEmail"
                                                                                                            style="font-family: var(--font-mono);"></span>

                                                                                                        <span
                                                                                                            class="dossier-label">Établissement
                                                                                                            :</span>
                                                                                                        <span
                                                                                                            class="dossier-value"
                                                                                                            id="modalEtablissement"></span>

                                                                                                        <span
                                                                                                            class="dossier-label">Date
                                                                                                            Dépôt
                                                                                                            :</span>
                                                                                                        <span
                                                                                                            class="dossier-value"
                                                                                                            id="modalDate"
                                                                                                            style="font-family: var(--font-mono);"></span>

                                                                                                        <span
                                                                                                            class="dossier-label">Curriculum
                                                                                                            Vitae
                                                                                                            :</span>
                                                                                                        <span
                                                                                                            class="dossier-value">
                                                                                                            <a id="modalCvLink"
                                                                                                                href="#"
                                                                                                                target="_blank"
                                                                                                                class="badge badge-gold"
                                                                                                                style="text-decoration: none;">📄
                                                                                                                Consulter
                                                                                                                le CV du
                                                                                                                candidat</a>
                                                                                                        </span>

                                                                                                        <span
                                                                                                            class="dossier-label">Statut
                                                                                                            Décisionnel
                                                                                                            :</span>
                                                                                                        <span
                                                                                                            class="dossier-value"
                                                                                                            id="modalDecisionBadge"></span>
                                                                                                    </div>

                                                                                                    <div
                                                                                                        style="margin-top: 18px;">
                                                                                                        <span
                                                                                                            class="dossier-label"
                                                                                                            style="display: block; margin-bottom: 6px;">Lettre
                                                                                                            de
                                                                                                            Motivation &
                                                                                                            Projet de
                                                                                                            Recherche
                                                                                                            :</span>
                                                                                                        <div class="motivation-quote"
                                                                                                            id="modalMotivation">
                                                                                                        </div>
                                                                                                    </div>

                                                                                                    <div id="modalActionButtons"
                                                                                                        style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border); display: flex; justify-content: flex-end; gap: 10px;">
                                                                                                        <!-- Dynamically filled depending on pending / decision status -->
                                                                                                    </div>
                                                                                                </div>
                                                                                            </div>

                                                                                            <% } %>

                                                                                                <% if
                                                                                                    (currentUser==null)
                                                                                                    { %>
                                                                                                    <!-- ZONE CANDIDAT : Suivi en ligne de Candidature -->
                                                                                                    <div id="suiviCandidature"
                                                                                                        class="card"
                                                                                                        style="max-width: 800px; margin: 0 auto 36px; padding: 28px; border-left: 4px solid var(--navy);">
                                                                                                        <div
                                                                                                            style="display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 12px;">
                                                                                                            <div>
                                                                                                                <span
                                                                                                                    class="eyebrow">Espace
                                                                                                                    Candidat
                                                                                                                    ·
                                                                                                                    Suivi
                                                                                                                    en
                                                                                                                    Ligne</span>
                                                                                                                <h3
                                                                                                                    style="font-size: 20px; margin: 4px 0 0;">
                                                                                                                    Consulter
                                                                                                                    l'état
                                                                                                                    d'avancement
                                                                                                                    de
                                                                                                                    ma
                                                                                                                    candidature
                                                                                                                </h3>
                                                                                                            </div>
                                                                                                            <span
                                                                                                                class="badge badge-gold">Suivi
                                                                                                                Direct</span>
                                                                                                        </div>
                                                                                                        <p
                                                                                                            style="font-size: 13.5px; color: var(--muted); margin-bottom: 20px;">
                                                                                                            Saisissez
                                                                                                            votre
                                                                                                            adresse
                                                                                                            email
                                                                                                            académique
                                                                                                            utilisée
                                                                                                            lors de la
                                                                                                            soumission
                                                                                                            de votre
                                                                                                            dossier pour
                                                                                                            consulter
                                                                                                            l'arbitrage
                                                                                                            du directeur
                                                                                                            en mandat.
                                                                                                        </p>

                                                                                                        <form
                                                                                                            action="<%= request.getContextPath() %>/adhesions"
                                                                                                            method="post"
                                                                                                            style="display: flex; gap: 10px; margin-bottom: 20px;">
                                                                                                            <input
                                                                                                                type="hidden"
                                                                                                                name="action"
                                                                                                                value="consulter">
                                                                                                            <input
                                                                                                                type="email"
                                                                                                                name="email"
                                                                                                                class="form-control"
                                                                                                                placeholder="votre.email@universite.ma"
                                                                                                                value="<%= searchedEmail != null ? searchedEmail : "" %>"
                                                                                                                required
                                                                                                                style="flex: 1;">
                                                                                                            <button
                                                                                                                type="submit"
                                                                                                                class="btn btn-secondary"
                                                                                                                style="white-space: nowrap;">Vérifier
                                                                                                                mon
                                                                                                                statut
                                                                                                                →</button>
                                                                                                        </form>

                                                                                                        <% if (suivi
                                                                                                            !=null) {
                                                                                                            boolean
                                                                                                            isPending=(suivi.getDecision()==null
                                                                                                            || "EN_ATTENTE"
                                                                                                            .equalsIgnoreCase(suivi.getDecision()));
                                                                                                            boolean
                                                                                                            isAccepted="ACCEPTEE"
                                                                                                            .equalsIgnoreCase(suivi.getDecision());
                                                                                                            boolean
                                                                                                            isRefused="REFUSEE"
                                                                                                            .equalsIgnoreCase(suivi.getDecision());
                                                                                                            %>
                                                                                                            <div
                                                                                                                style="background: var(--surface); border: 1px solid var(--border); border-radius: 4px; padding: 20px;">
                                                                                                                <div
                                                                                                                    style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                                                                                                    <div>
                                                                                                                        <strong
                                                                                                                            style="font-size: 16px; color: var(--navy);">
                                                                                                                            <%= suivi.getPrenom()
                                                                                                                                %>
                                                                                                                                <%= suivi.getNom()
                                                                                                                                    %>
                                                                                                                        </strong>
                                                                                                                        <span
                                                                                                                            style="font-size: 12px; color: var(--muted); margin-left: 8px;">(Dossier
                                                                                                                            soumis
                                                                                                                            le
                                                                                                                            <%= suivi.getDateSoumission()
                                                                                                                                %>
                                                                                                                                )</span>
                                                                                                                    </div>
                                                                                                                    <% if
                                                                                                                        (isAccepted)
                                                                                                                        {
                                                                                                                        %>
                                                                                                                        <span
                                                                                                                            class="badge badge-accent"
                                                                                                                            style="font-size: 12px;">✓
                                                                                                                            Candidature
                                                                                                                            Acceptée</span>
                                                                                                                        <% } else
                                                                                                                            if
                                                                                                                            (isRefused)
                                                                                                                            {
                                                                                                                            %>
                                                                                                                            <span
                                                                                                                                class="badge badge-danger"
                                                                                                                                style="font-size: 12px;">✕
                                                                                                                                Candidature
                                                                                                                                Refusée</span>
                                                                                                                            <% } else
                                                                                                                                {
                                                                                                                                %>
                                                                                                                                <span
                                                                                                                                    class="badge badge-gold"
                                                                                                                                    style="font-size: 12px;">⏳
                                                                                                                                    En
                                                                                                                                    Cours
                                                                                                                                    d'Arbitrage</span>
                                                                                                                                <% }
                                                                                                                                    %>
                                                                                                                </div>

                                                                                                                <div
                                                                                                                    style="font-size: 13.5px; line-height: 1.6; margin-bottom: 12px;">
                                                                                                                    <strong>Statut
                                                                                                                        visé
                                                                                                                        :</strong>
                                                                                                                    <%= suivi.getStatutVise()
                                                                                                                        %>
                                                                                                                        ·
                                                                                                                        <strong>Établissement
                                                                                                                            :</strong>
                                                                                                                        <%= suivi.getEtablissement()
                                                                                                                            %>
                                                                                                                </div>

                                                                                                                <% if
                                                                                                                    (isAccepted)
                                                                                                                    { %>
                                                                                                                    <div
                                                                                                                        style="background: rgba(46, 125, 50, 0.08); border: 1px solid #2e7d32; border-radius: 4px; padding: 14px; margin-top: 10px;">
                                                                                                                        <strong
                                                                                                                            style="color: #2e7d32; display: block; margin-bottom: 4px;">🎉
                                                                                                                            Félicitations
                                                                                                                            !
                                                                                                                            Votre
                                                                                                                            candidature
                                                                                                                            a
                                                                                                                            été
                                                                                                                            validée
                                                                                                                            par
                                                                                                                            la
                                                                                                                            direction.</strong>
                                                                                                                        <div
                                                                                                                            style="font-size: 13px; color: var(--ink);">
                                                                                                                            Votre
                                                                                                                            compte
                                                                                                                            membre
                                                                                                                            LIAS
                                                                                                                            a
                                                                                                                            été
                                                                                                                            automatiquement
                                                                                                                            créé
                                                                                                                            et
                                                                                                                            activé.<br>
                                                                                                                            <strong>Identifiant
                                                                                                                                :</strong>
                                                                                                                            <code
                                                                                                                                style="font-family: var(--font-mono);"><%= suivi.getEmail() %></code><br>
                                                                                                                            <strong>Mot
                                                                                                                                de
                                                                                                                                passe
                                                                                                                                initial
                                                                                                                                :</strong>
                                                                                                                            <code
                                                                                                                                style="font-family: var(--font-mono);">pass123</code>
                                                                                                                            (à
                                                                                                                            modifier
                                                                                                                            lors
                                                                                                                            de
                                                                                                                            votre
                                                                                                                            première
                                                                                                                            connexion).
                                                                                                                        </div>
                                                                                                                        <div
                                                                                                                            style="margin-top: 12px;">
                                                                                                                            <a href="<%= request.getContextPath() %>/login"
                                                                                                                                class="btn btn-sm btn-primary">Accéder
                                                                                                                                à
                                                                                                                                mon
                                                                                                                                espace
                                                                                                                                membre
                                                                                                                                →</a>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                    <% } else
                                                                                                                        if
                                                                                                                        (isRefused)
                                                                                                                        {
                                                                                                                        %>
                                                                                                                        <div
                                                                                                                            style="background: rgba(198, 40, 40, 0.08); border: 1px solid #c62828; border-radius: 4px; padding: 14px; margin-top: 10px;">
                                                                                                                            <strong
                                                                                                                                style="color: #c62828; display: block; margin-bottom: 4px;">Décision
                                                                                                                                officielle
                                                                                                                                de
                                                                                                                                la
                                                                                                                                direction
                                                                                                                                :</strong>
                                                                                                                            <div
                                                                                                                                style="font-size: 13px; color: var(--ink);">
                                                                                                                                Votre
                                                                                                                                dossier
                                                                                                                                de
                                                                                                                                candidature
                                                                                                                                n'a
                                                                                                                                pu
                                                                                                                                être
                                                                                                                                retenu
                                                                                                                                pour
                                                                                                                                cette
                                                                                                                                session
                                                                                                                                de
                                                                                                                                recrutement
                                                                                                                                académique.
                                                                                                                                Une
                                                                                                                                notification
                                                                                                                                formelle
                                                                                                                                a
                                                                                                                                été
                                                                                                                                consignée.
                                                                                                                                Nous
                                                                                                                                vous
                                                                                                                                remercions
                                                                                                                                pour
                                                                                                                                l'intérêt
                                                                                                                                manifesté
                                                                                                                                envers
                                                                                                                                les
                                                                                                                                travaux
                                                                                                                                de
                                                                                                                                recherche
                                                                                                                                du
                                                                                                                                LIAS.
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                        <% } else
                                                                                                                            {
                                                                                                                            %>
                                                                                                                            <div
                                                                                                                                style="background: rgba(184, 91, 53, 0.08); border: 1px solid var(--accent-2); border-radius: 4px; padding: 14px; margin-top: 10px;">
                                                                                                                                <strong
                                                                                                                                    style="color: var(--accent-2); display: block; margin-bottom: 4px;">Dossier
                                                                                                                                    complet
                                                                                                                                    en
                                                                                                                                    cours
                                                                                                                                    d'évaluation</strong>
                                                                                                                                <div
                                                                                                                                    style="font-size: 13px; color: var(--ink);">
                                                                                                                                    Votre
                                                                                                                                    dossier
                                                                                                                                    complet
                                                                                                                                    (CV
                                                                                                                                    et
                                                                                                                                    lettre
                                                                                                                                    de
                                                                                                                                    motivation)
                                                                                                                                    est
                                                                                                                                    actuellement
                                                                                                                                    examiné
                                                                                                                                    par
                                                                                                                                    le
                                                                                                                                    directeur
                                                                                                                                    du
                                                                                                                                    laboratoire
                                                                                                                                    (mandat
                                                                                                                                    en
                                                                                                                                    cours).
                                                                                                                                    Vous
                                                                                                                                    recevrez
                                                                                                                                    une
                                                                                                                                    notification
                                                                                                                                    par
                                                                                                                                    email
                                                                                                                                    dès
                                                                                                                                    l'enregistrement
                                                                                                                                    de
                                                                                                                                    l'arbitrage.
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                            <% }
                                                                                                                                %>
                                                                                                            </div>
                                                                                                            <% } else if
                                                                                                                (searchedEmail
                                                                                                                !=null
                                                                                                                &&
                                                                                                                !searchedEmail.trim().isEmpty())
                                                                                                                { %>
                                                                                                                <div
                                                                                                                    style="padding: 16px; background: rgba(0,0,0,0.02); border: 1px dashed var(--border); border-radius: 4px; text-align: center; color: var(--muted); font-size: 13.5px;">
                                                                                                                    Aucun
                                                                                                                    dossier
                                                                                                                    d'adhésion
                                                                                                                    trouvé
                                                                                                                    pour
                                                                                                                    l'adresse
                                                                                                                    <strong>
                                                                                                                        <%= searchedEmail
                                                                                                                            %>
                                                                                                                    </strong>.
                                                                                                                    Vérifiez
                                                                                                                    votre
                                                                                                                    saisie
                                                                                                                    ou
                                                                                                                    déposez
                                                                                                                    votre
                                                                                                                    candidature
                                                                                                                    ci-dessous.
                                                                                                                </div>
                                                                                                                <% } %>
                                                                                                    </div>

                                                                                                    <!-- Formulaire de Candidature pour Candidats / Visiteurs Uniquement -->
                                                                                                    <div id="formulaireCandidature"
                                                                                                        class="card"
                                                                                                        style="max-width: 800px; margin: 0 auto 40px; padding: 40px; border-left: 4px solid var(--accent-2);">
                                                                                                        <span
                                                                                                            class="eyebrow">Dépôt
                                                                                                            de Dossier
                                                                                                            Universitaire
                                                                                                            en
                                                                                                            Ligne</span>
                                                                                                        <h2
                                                                                                            style="font-size: 28px; margin: 4px 0 8px;">
                                                                                                            Formulaire
                                                                                                            de
                                                                                                            Candidature
                                                                                                            & Adhésion
                                                                                                        </h2>
                                                                                                        <p
                                                                                                            style="font-size: 14px; color: var(--muted); margin-bottom: 28px;">
                                                                                                            Renseignez
                                                                                                            vos
                                                                                                            coordonnées
                                                                                                            exactes et
                                                                                                            joignez
                                                                                                            votre CV
                                                                                                            ainsi que
                                                                                                            votre projet
                                                                                                            de
                                                                                                            recherche.
                                                                                                            L'instruction
                                                                                                            est menée
                                                                                                            exclusivement
                                                                                                            par le
                                                                                                            directeur du
                                                                                                            laboratoire
                                                                                                            en mandat
                                                                                                            actif.
                                                                                                        </p>

                                                                                                        <form id="candidatureForm" action="<%= request.getContextPath() %>/adhesions" method="post" enctype="multipart/form-data" onsubmit="return validateCandidatureForm(event);">
                                                                                                            <input type="hidden" name="action" value="soumettre">

                                                                                                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                                                                                                                <div class="form-group">
                                                                                                                    <label class="form-label">Nom de famille <span style="color: #EF4444; font-weight: 700;">*</span></label>
                                                                                                                    <input type="text" name="nom" class="form-control" placeholder="ex: Bennani" required>
                                                                                                                </div>
                                                                                                                <div class="form-group">
                                                                                                                    <label class="form-label">Prénom <span style="color: #EF4444; font-weight: 700;">*</span></label>
                                                                                                                    <input type="text" name="prenom" class="form-control" placeholder="ex: Salma" required>
                                                                                                                </div>
                                                                                                            </div>

                                                                                                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                                                                                                                <div class="form-group">
                                                                                                                    <label class="form-label">Adresse email académique <span style="color: #EF4444; font-weight: 700;">*</span></label>
                                                                                                                    <input type="email" name="email" class="form-control" placeholder="candidat@univ-h2c.ma" required>
                                                                                                                </div>
                                                                                                                <div class="form-group">
                                                                                                                    <label class="form-label">Statut postulé <span style="color: #EF4444; font-weight: 700;">*</span></label>
                                                                                                                    <select name="statutPostule" class="form-control" required>
                                                                                                                        <option value="doctorant">Doctorant en Thèse</option>
                                                                                                                        <option value="permanent">Enseignant-Chercheur Permanent</option>
                                                                                                                        <option value="associe">Chercheur Associé / Post-Doc</option>
                                                                                                                    </select>
                                                                                                                </div>
                                                                                                            </div>

                                                                                                            <div class="form-group">
                                                                                                                <label class="form-label">Établissement ou Université de rattachement <span style="color: #EF4444; font-weight: 700;">*</span></label>
                                                                                                                <input type="text" name="etablissementOrigine" class="form-control" placeholder="ex: Faculté des Sciences Ben M'Sik / ENSIAS / Autre..." required>
                                                                                                            </div>

                                                                                                            <div class="form-group">
                                                                                                                <label class="form-label" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                                                                                                    <span>Curriculum Vitae / Dossier scientifique <span style="color: #EF4444; font-weight: 700;">* (Obligatoire)</span></span>
                                                                                                                    <span id="cvFileStatusText" style="font-size: 11.5px; color: var(--muted); font-weight: 500;">Format PDF, DOC, DOCX (max 10 Mo)</span>
                                                                                                                </label>

                                                                                                                <!-- Sélecteur de fichier natif du navigateur -->
                                                                                                                <input type="file" id="cvFileInput" name="cvFile" accept=".pdf,.doc,.docx" style="display: none;" onchange="handleCvFileSelect(this)">

                                                                                                                <!-- Zone de dépôt et de sélection de fichier stylisée -->
                                                                                                                <div id="cvDropZone" class="cv-upload-card" onclick="triggerCvFilePicker(event)" ondragover="handleCvDragOver(event)" ondragleave="handleCvDragLeave(event)" ondrop="handleCvDrop(event)">

                                                                                                                    <!-- État initial : Aucun fichier sélectionné -->
                                                                                                                    <div id="cvUploadPrompt" style="display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; padding: 26px 20px; gap: 10px;">
                                                                                                                        <div style="width: 48px; height: 48px; border-radius: 12px; background: rgba(2, 132, 199, 0.1); display: flex; align-items: center; justify-content: center; color: #0284C7;">
                                                                                                                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                                                                                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                                                                                                                                <polyline points="17 8 12 3 7 8" />
                                                                                                                                <line x1="12" y1="3" x2="12" y2="15" />
                                                                                                                            </svg>
                                                                                                                        </div>
                                                                                                                        <div>
                                                                                                                            <div style="font-weight: 700; color: var(--navy); font-size: 14.5px; margin-bottom: 3px;">
                                                                                                                                Cliquez ici pour choisir votre CV depuis votre ordinateur <span style="color: #EF4444; font-weight: 700;">*</span>
                                                                                                                            </div>
                                                                                                                            <div style="font-size: 12px; color: var(--muted);">
                                                                                                                                ou glissez-déposez votre document directement ici (PDF ou Word)
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                        <button type="button" class="btn btn-secondary btn-sm" style="margin-top: 4px; pointer-events: none; display: inline-flex; align-items: center; gap: 6px; font-weight: 600;">
                                                                                                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                                                                                <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
                                                                                                                            </svg>
                                                                                                                            📁 Parcourir vos dossiers...
                                                                                                                        </button>
                                                                                                                    </div>

                                                                                                                    <!-- État sélectionné : Fichier choisi -->
                                                                                                                    <div id="cvFileSelectedCard" style="display: none; align-items: center; justify-content: space-between; padding: 16px 20px; background: #F0FDF4; border-radius: 10px;">
                                                                                                                        <div style="display: flex; align-items: center; gap: 14px;">
                                                                                                                            <div style="width: 44px; height: 44px; border-radius: 10px; background: #DCFCE7; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0;">
                                                                                                                                📄
                                                                                                                            </div>
                                                                                                                            <div style="text-align: left;">
                                                                                                                                <div id="cvSelectedFileName" style="font-weight: 700; color: #166534; font-size: 14px; word-break: break-all;">
                                                                                                                                    mon_cv.pdf
                                                                                                                                </div>
                                                                                                                                <div style="display: flex; align-items: center; gap: 10px; margin-top: 2px;">
                                                                                                                                    <span id="cvSelectedFileSize" style="font-size: 11.5px; color: #15803D; font-family: var(--font-mono);">245 Ko</span>
                                                                                                                                    <span style="font-size: 11px; padding: 2px 8px; border-radius: 9999px; background: #BBF7D0; color: #14532D; font-weight: 600;">✓ Fichier prêt à l'envoi</span>
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                        <div style="display: flex; align-items: center; gap: 8px;" onclick="event.stopPropagation();">
                                                                                                                            <button type="button" class="btn btn-sm btn-secondary" onclick="triggerCvFilePicker(event)" title="Sélectionner un autre fichier">
                                                                                                                                Changer
                                                                                                                            </button>
                                                                                                                            <button type="button" class="btn btn-sm btn-danger" onclick="clearCvSelection(event)" title="Retirer ce fichier" style="padding: 4px 8px;">
                                                                                                                                ✕
                                                                                                                            </button>
                                                                                                                        </div>
                                                                                                                    </div>

                                                                                                                </div>
                                                                                                                <div id="cvErrorMessage" style="display: none; color: #DC2626; font-size: 12.5px; font-weight: 600; margin-top: 8px; padding: 8px 12px; background: #FEF2F2; border: 1px solid #FCA5A5; border-radius: 6px;">
                                                                                                                    ⚠️ Le CV est obligatoire. Veuillez obligatoirement choisir un fichier CV (PDF ou Word) depuis vos dossiers avant d'envoyer votre candidature.
                                                                                                                </div>
                                                                                                                <small style="color: var(--muted); font-size: 11px; margin-top: 6px; display: block;">
                                                                                                                    Le fichier sélectionné sera transmis à la Direction du laboratoire pour étude du dossier.
                                                                                                                </small>
                                                                                                            </div>

                                                                                                            <div class="form-group">
                                                                                                                <label class="form-label">Lettre de motivation & Sujet de recherche envisagé <span style="color: #EF4444; font-weight: 700;">*</span></label>
                                                                                                                <textarea name="motivation" class="form-control" rows="5" placeholder="Décrivez vos motivations, axes de recherche envisagés au LIAS et vos compétences clés..." required></textarea>
                                                                                                            </div>

                                                                                                            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 14px; font-size: 15px;">
                                                                                                                Transmettre mon dossier complet au Directeur du LIAS →
                                                                                                            </button>
                                                                                                        </form>
                                                                                                    </div>
                                                                                                    <% } else if
                                                                                                        (!isDirecteur) {
                                                                                                        %>
                                                                                                        <!-- Membre déjà intégré -->
                                                                                                        <div class="card"
                                                                                                            style="text-align: center; padding: 48px 24px; max-width: 650px; margin: 40px auto;">
                                                                                                            <div
                                                                                                                style="font-size: 42px; margin-bottom: 16px;">
                                                                                                                🎓</div>
                                                                                                            <h3
                                                                                                                style="font-size: 22px; margin-bottom: 8px;">
                                                                                                                Vous
                                                                                                                êtes
                                                                                                                déjà
                                                                                                                membre
                                                                                                                affilié
                                                                                                                au LIAS
                                                                                                            </h3>
                                                                                                            <p
                                                                                                                style="color: var(--muted); font-size: 14px; line-height: 1.6; margin-bottom: 24px;">
                                                                                                                Votre
                                                                                                                compte
                                                                                                                est
                                                                                                                actif et
                                                                                                                votre
                                                                                                                affiliation
                                                                                                                est
                                                                                                                enregistrée.
                                                                                                                L'arbitrage
                                                                                                                des
                                                                                                                nouvelles
                                                                                                                candidatures
                                                                                                                est
                                                                                                                réservé
                                                                                                                exclusivement
                                                                                                                au
                                                                                                                directeur
                                                                                                                en
                                                                                                                mandat
                                                                                                                actif.
                                                                                                            </p>
                                                                                                            <a href="<%= request.getContextPath() %>/home"
                                                                                                                class="btn btn-primary">Retour
                                                                                                                à mon
                                                                                                                tableau
                                                                                                                de bord
                                                                                                                →</a>
                                                                                                        </div>
                                                                                                        <% } %>

                                                                                                            <% if
                                                                                                                (currentUser==null)
                                                                                                                { %>
                                                                    </div>
                                                                    <%@ include file="includes/footer.jsp" %>
                                                                        <% } else { %>
                                                        </div>
                                                        </main>
                                                </div>
                                        </div>
                                        <% } %>

                                            <script>
                                                function closeToast() {
                                                    var toast = document.getElementById("appToast");
                                                    if (toast) {
                                                        toast.classList.add("toast-hide");
                                                        setTimeout(function () { toast.remove(); }, 350);
                                                    }
                                                }

                                                function openDossierModal(id, nom, prenom, email, statut, etablissement, cv, motivation, date, decision) {
                                                    document.getElementById("modalCandidatNom").textContent = "Dossier de " + prenom + " " + nom;
                                                    document.getElementById("modalStatutVise").textContent = statut;
                                                    document.getElementById("modalEmail").textContent = email;
                                                    document.getElementById("modalEtablissement").textContent = etablissement;
                                                    document.getElementById("modalDate").textContent = date;
                                                    document.getElementById("modalCvLink").href = "<%= request.getContextPath() %>/" + (cv ? cv : "dossiers/cv.pdf");
                                                    document.getElementById("modalCvLink").textContent = "📄 " + (cv ? cv.substring(cv.lastIndexOf("/") + 1) : "Consulter CV.pdf");
                                                    document.getElementById("modalMotivation").textContent = motivation && motivation.trim() ? motivation : "Aucune lettre de motivation fournie.";

                                                    var badgeSpan = document.getElementById("modalDecisionBadge");
                                                    var actionsDiv = document.getElementById("modalActionButtons");
                                                    actionsDiv.innerHTML = "";

                                                    if (decision === "ACCEPTEE") {
                                                        badgeSpan.innerHTML = '<span class="badge badge-accent">✓ Validée & Compte Créé</span>';
                                                        actionsDiv.innerHTML = '<button type="button" class="btn btn-secondary" onclick="closeDossierModal()">Fermer</button>';
                                                    } else if (decision === "REFUSEE") {
                                                        badgeSpan.innerHTML = '<span class="badge badge-danger">✕ Refusée (Notification transmise)</span>';
                                                        actionsDiv.innerHTML = '<button type="button" class="btn btn-secondary" onclick="closeDossierModal()">Fermer</button>';
                                                    } else {
                                                        badgeSpan.innerHTML = '<span class="badge badge-gold">⏳ En attente d\'arbitrage</span>';
                                                        actionsDiv.innerHTML =
                                                            '<form action="<%= request.getContextPath() %>/adhesions" method="post" style="display:inline;" onsubmit="return confirm(\'Valider la candidature de ' + prenom + ' ' + nom + ' ? Un compte membre sera créé.\');">' +
                                                            '  <input type="hidden" name="demandeId" value="' + id + '">' +
                                                            '  <button type="submit" name="action" value="valider" class="btn btn-accent">✓ Accepter & Créer Compte</button>' +
                                                            '</form>' +
                                                            '<form action="<%= request.getContextPath() %>/adhesions" method="post" style="display:inline; margin-left:8px;" onsubmit="return confirm(\'Refuser la candidature ? Une notification sera émise.\');">' +
                                                            '  <input type="hidden" name="demandeId" value="' + id + '">' +
                                                            '  <button type="submit" name="action" value="refuser" class="btn btn-danger">✕ Refuser & Notifier</button>' +
                                                            '</form>' +
                                                            '<button type="button" class="btn btn-secondary" style="margin-left:8px;" onclick="closeDossierModal()">Fermer</button>';
                                                    }

                                                    var backdrop = document.getElementById("dossierModalBackdrop");
                                                    if (backdrop) backdrop.classList.add("active");
                                                }

                                                function closeDossierModal() {
                                                    var backdrop = document.getElementById("dossierModalBackdrop");
                                                    if (backdrop) backdrop.classList.remove("active");
                                                }

                                                function closeDossierModalOnBackdrop(e) {
                                                    if (e.target.id === "dossierModalBackdrop") {
                                                        closeDossierModal();
                                                    }
                                                }

                                                function validateCandidatureForm(e) {
                                                    var fileInput = document.getElementById("cvFileInput");
                                                    var dropZone = document.getElementById("cvDropZone");
                                                    var errorMsg = document.getElementById("cvErrorMessage");

                                                    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
                                                        if (e) {
                                                            e.preventDefault();
                                                            e.stopPropagation();
                                                        }
                                                        if (dropZone) {
                                                            dropZone.style.border = "2px dashed #EF4444";
                                                            dropZone.style.background = "#FEF2F2";
                                                            dropZone.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                                        }
                                                        if (errorMsg) {
                                                            errorMsg.style.display = "block";
                                                        }
                                                        return false;
                                                    }
                                                    return true;
                                                }

                                                function triggerCvFilePicker(e) {
                                                    if (e) {
                                                        e.preventDefault();
                                                        e.stopPropagation();
                                                    }
                                                    var fileInput = document.getElementById("cvFileInput");
                                                    if (fileInput) fileInput.click();
                                                }

                                                function handleCvFileSelect(input) {
                                                    if (input.files && input.files.length > 0) {
                                                        displaySelectedCv(input.files[0]);
                                                    }
                                                }

                                                function displaySelectedCv(file) {
                                                    var prompt = document.getElementById("cvUploadPrompt");
                                                    var card = document.getElementById("cvFileSelectedCard");
                                                    var nameEl = document.getElementById("cvSelectedFileName");
                                                    var sizeEl = document.getElementById("cvSelectedFileSize");
                                                    var hiddenInput = document.getElementById("cvPathInput");
                                                    var statusText = document.getElementById("cvFileStatusText");
                                                    var dropZone = document.getElementById("cvDropZone");
                                                    var errorMsg = document.getElementById("cvErrorMessage");

                                                    if (errorMsg) errorMsg.style.display = "none";
                                                    if (nameEl) nameEl.textContent = file.name;
                                                    if (sizeEl) {
                                                        var sizeKb = Math.round(file.size / 1024);
                                                        var sizeStr = sizeKb > 1024 ? (sizeKb / 1024).toFixed(1) + " Mo" : sizeKb + " Ko";
                                                        sizeEl.textContent = sizeStr;
                                                    }
                                                    if (hiddenInput) {
                                                        var cleanName = file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
                                                        hiddenInput.value = "dossiers/" + cleanName;
                                                    }
                                                    if (statusText) {
                                                        statusText.innerHTML = '<span style="color: #16A34A; font-weight: 700;">✓ Fichier prêt</span>';
                                                    }

                                                    if (prompt) prompt.style.display = "none";
                                                    if (card) card.style.display = "flex";
                                                    if (dropZone) {
                                                        dropZone.style.border = "2px solid #86EFAC";
                                                        dropZone.style.background = "#F0FDF4";
                                                    }
                                                }

                                                function clearCvSelection(e) {
                                                    if (e) {
                                                        e.preventDefault();
                                                        e.stopPropagation();
                                                    }
                                                    var fileInput = document.getElementById("cvFileInput");
                                                    var prompt = document.getElementById("cvUploadPrompt");
                                                    var card = document.getElementById("cvFileSelectedCard");
                                                    var hiddenInput = document.getElementById("cvPathInput");
                                                    var statusText = document.getElementById("cvFileStatusText");
                                                    var dropZone = document.getElementById("cvDropZone");
                                                    var errorMsg = document.getElementById("cvErrorMessage");

                                                    if (fileInput) fileInput.value = "";
                                                    if (hiddenInput) hiddenInput.value = "";
                                                    if (prompt) prompt.style.display = "flex";
                                                    if (card) card.style.display = "none";
                                                    if (errorMsg) errorMsg.style.display = "none";
                                                    if (dropZone) {
                                                        dropZone.style.border = "2px dashed #CBD5E1";
                                                        dropZone.style.background = "transparent";
                                                    }
                                                    if (statusText) {
                                                        statusText.textContent = "Format PDF, DOC, DOCX (max 10 Mo)";
                                                    }
                                                }

                                                function handleCvDragOver(e) {
                                                    e.preventDefault();
                                                    e.stopPropagation();
                                                    var dropZone = document.getElementById("cvDropZone");
                                                    if (dropZone) dropZone.classList.add("dragover");
                                                }

                                                function handleCvDragLeave(e) {
                                                    e.preventDefault();
                                                    e.stopPropagation();
                                                    var dropZone = document.getElementById("cvDropZone");
                                                    if (dropZone) dropZone.classList.remove("dragover");
                                                }

                                                function handleCvDrop(e) {
                                                    e.preventDefault();
                                                    e.stopPropagation();
                                                    var dropZone = document.getElementById("cvDropZone");
                                                    if (dropZone) dropZone.classList.remove("dragover");

                                                    if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length > 0) {
                                                        var file = e.dataTransfer.files[0];
                                                        var fileInput = document.getElementById("cvFileInput");
                                                        try {
                                                            fileInput.files = e.dataTransfer.files;
                                                        } catch (err) { }
                                                        displaySelectedCv(file);
                                                    }
                                                }

                                                document.addEventListener("DOMContentLoaded", function () {
                                                    var toast = document.getElementById("appToast");
                                                    if (toast) {
                                                        setTimeout(function () {
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
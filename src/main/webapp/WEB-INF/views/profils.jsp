<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.Member"%>
<%@ page import="com.lias.beans.User"%>
<%@ page import="com.lias.beans.Publication"%>
<%@ page import="com.lias.beans.AffiliationPeriod"%>
<%
    List<Member> membres = (List<Member>) request.getAttribute("membres");
    String selectedTeam = (String) request.getAttribute("selectedTeam");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String selectedRole = (String) request.getAttribute("selectedRole");
    Member selectedMember = (Member) request.getAttribute("selectedMember");
    List<Publication> memberPublications = (List<Publication>) request.getAttribute("memberPublications");
    List<AffiliationPeriod> affiliationPeriods = (List<AffiliationPeriod>) request.getAttribute("affiliationPeriods");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    boolean isDirector = currentUser != null && "directeur".equalsIgnoreCase(currentUser.getRole());
    boolean isAdmin = currentUser != null && "admin".equalsIgnoreCase(currentUser.getRole());

    boolean isSelf = currentUser != null && selectedMember != null && currentUser.getEmail().equalsIgnoreCase(selectedMember.getEmail());
    boolean canEdit = isDirector || isSelf;
    boolean canViewConfidential = isDirector || isSelf || isAdmin;

    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Profils & Membres du Laboratoire</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        .chip {
            padding: 5px 11px;
            font-family: var(--font-mono);
            font-size: 11px;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--muted);
            border-radius: 2px;
            text-decoration: none !important;
            transition: all 0.15s;
        }
        .chip:hover, .chip.active {
            background: var(--navy);
            color: var(--cream);
            border-color: var(--navy);
        }

        .member-item {
            padding: 14px 16px;
            background: var(--surface);
            border: 1px solid var(--border);
            margin-bottom: 8px;
            border-radius: 2px;
            cursor: pointer;
            text-decoration: none !important;
            color: inherit;
            display: block;
            transition: all 0.15s;
        }
        .member-item:hover, .member-item.selected {
            background: var(--surface-2);
            border-color: var(--border-dark);
            box-shadow: var(--shadow-sm);
        }
        .member-item.selected {
            border-left: 4px solid var(--accent-2);
        }

        .dossier-card {
            background: var(--surface);
            border: 1px solid var(--border);
            padding: 36px;
            border-radius: 2px;
            box-shadow: var(--shadow-sm);
        }
        .dossier-avatar {
            width: 76px;
            height: 76px;
            background: var(--navy);
            color: var(--cream);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: var(--font-serif);
            font-size: 32px;
            font-weight: 600;
            border-radius: 4px;
            overflow: hidden;
            flex-shrink: 0;
        }
        .dossier-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .timeline-box {
            border-left: 2px solid var(--accent-2);
            padding-left: 18px;
            margin-left: 6px;
            margin-top: 14px;
        }
        .timeline-step {
            position: relative;
            margin-bottom: 20px;
        }
        .timeline-step::before {
            content: '';
            position: absolute;
            left: -23px;
            top: 4px;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--navy);
        }

        .edit-form-card {
            display: none;
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-left: 4px solid var(--accent-2);
            padding: 24px;
            margin-bottom: 24px;
            border-radius: 2px;
        }
        .form-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .field-group {
            margin-bottom: 14px;
        }
        .field-group label {
            display: block;
            font-family: var(--font-mono);
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: var(--muted);
            margin-bottom: 4px;
        }
        .field-group input, .field-group select, .field-group textarea {
            width: 100%;
            padding: 9px 12px;
            background: var(--surface);
            border: 1px solid var(--border);
            font-family: var(--font-sans);
            font-size: 13.5px;
            color: var(--ink);
            border-radius: 2px;
            box-sizing: border-box;
        }
        .field-group textarea {
            resize: vertical;
            min-height: 70px;
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

        <% if ("succes_maj".equals(msg)) { %>
        <div style="background: #EBF7EE; border: 1px solid #C4E7CB; color: #1E6B37; padding: 14px 18px; border-radius: 2px; margin-bottom: 24px; font-size: 13.5px;">
            ✔ <strong>Profil mis à jour avec succès !</strong> Les modifications ont été enregistrées et historisées automatiquement dans la mémoire institutionnelle du LIAS.
        </div>
        <% } else if ("retraite_enregistree".equals(msg)) { %>
        <div style="background: #FDF2E9; border: 1px solid #FADBD8; color: #A04000; padding: 14px 18px; border-radius: 2px; margin-bottom: 24px; font-size: 13.5px;">
            🔒 <strong>Départ à la retraite enregistré avec succès !</strong> Le compte utilisateur a été <strong>gelé</strong> (aucun accès actif). Conformément aux règles d'intégrité, l'ensemble de l'historique de carrière, des publications scientifiques et des projets est intégralement conservé dans les archives du LIAS.
        </div>
        <% } else if ("depart_enregistre".equals(msg)) { %>
        <div style="background: #FFF8E1; border: 1px solid #FFE082; color: #8D6E63; padding: 14px 18px; border-radius: 2px; margin-bottom: 24px; font-size: 13.5px;">
            🚪 <strong>Départ du membre enregistré !</strong> Le compte a été <strong>désactivé</strong> et la période d'affiliation active clôturée. L'historique complet est conservé. Ce compte pourra éventuellement être réactivé ultérieurement par la Direction.
        </div>
        <% } else if ("reactivation_enregistree".equals(msg)) { %>
        <div style="background: #E8F5E9; border: 1px solid #A5D6A7; color: #2E7D32; padding: 14px 18px; border-radius: 2px; margin-bottom: 24px; font-size: 13.5px;">
            🔄 <strong>Compte réactivé avec succès !</strong> L'accès au système a été rétabli et une nouvelle période d'affiliation active a été ouverte.
        </div>
        <% } else if ("retour_enregistre".equals(msg)) { %>
        <div style="background: #E8F5E9; border: 1px solid #A5D6A7; color: #2E7D32; padding: 14px 18px; border-radius: 2px; margin-bottom: 24px; font-size: 13.5px;">
            🔄 <strong>Retour et réintégration enregistrés avec succès !</strong> Une nouvelle période d'affiliation en cours a été ouverte.
        </div>
        <% } else if ("periode_ajoutee".equals(msg)) { %>
        <div style="background: #E3F2FD; border: 1px solid #90CAF9; color: #1565C0; padding: 14px 18px; border-radius: 2px; margin-bottom: 24px; font-size: 13.5px;">
            ⏱️ <strong>Période d'affiliation ajoutée avec succès !</strong> La frise temporelle a été actualisée.
        </div>
        <% } else if ("role_modifie".equals(msg)) { %>
        <div style="background: #EBF7EE; border: 1px solid #C4E7CB; color: #1E6B37; padding: 14px 18px; border-radius: 2px; margin-bottom: 24px; font-size: 13.5px;">
            ⭐ <strong>Rôle et responsabilités mis à jour avec succès !</strong> Conformément aux règles d'intégrité, aucune donnée antérieure n'a été supprimée (publications et travaux scientifiques conservés) et l'historique complet a été enrichi.
        </div>
        <% } %>

        <!-- Header -->
        <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 16px;">
            <div>
                <span class="eyebrow">Ressources Humaines &amp; Traçabilité</span>
                <h1 class="page-title">Gestion des Profils Membres</h1>
                <p class="page-sub">
                    Dossier académique individuel, affiliation institutionnelle, biographie, publications et historisation temporelle sans suppression de données.
                </p>
            </div>
            <% if (isDirector) { %>
                <a href="<%= request.getContextPath() %>/admin" class="btn btn-secondary">⚙ Gérer les comptes utilisateurs</a>
            <% } %>
        </div>

        <!-- Filter Bar : Statut & Rôles CDC §7 -->
        <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; align-items: center;">
            <span style="font-family: var(--font-mono); font-size: 11px; color: var(--muted); text-transform: uppercase;">Filtrer par statut :</span>
            <a href="<%= request.getContextPath() %>/profils" class="chip <%= selectedStatus == null && selectedRole == null ? "active" : "" %>">Tous (<%= membres != null ? membres.size() : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/profils?status=permanent" class="chip <%= "permanent".equals(selectedStatus) ? "active" : "" %>">Permanents</a>
            <a href="<%= request.getContextPath() %>/profils?status=doctorant" class="chip <%= "doctorant".equals(selectedStatus) ? "active" : "" %>">Doctorants</a>
            <a href="<%= request.getContextPath() %>/profils?status=associe" class="chip <%= "associe".equals(selectedStatus) ? "active" : "" %>">Associés</a>
            <a href="<%= request.getContextPath() %>/profils?status=retraite" class="chip <%= "retraite".equals(selectedStatus) ? "active" : "" %>">Retraités [Gelé]</a>
            <a href="<%= request.getContextPath() %>/profils?status=ancien" class="chip <%= "ancien".equals(selectedStatus) ? "active" : "" %>">Anciens Membres</a>
        </div>

        <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 24px; align-items: center; padding: 10px 14px; background: rgba(2, 132, 199, 0.05); border: 1px solid rgba(2, 132, 199, 0.2); border-radius: 4px;">
            <span style="font-family: var(--font-mono); font-size: 11px; color: var(--navy); font-weight: 700; text-transform: uppercase;">Rôles & Gouvernance (CDC §7) :</span>
            <a href="<%= request.getContextPath() %>/profils?role=directeur" class="chip <%= "directeur".equalsIgnoreCase(selectedRole) ? "active" : "" %>" style="border-color: #B89255; color: #92400E;">⭐ Directeur</a>
            <a href="<%= request.getContextPath() %>/profils?role=vice-directeur" class="chip <%= "vice-directeur".equalsIgnoreCase(selectedRole) ? "active" : "" %>" style="border-color: #0284C7; color: #0369A1;">⭐ Vice-directeur</a>
            <a href="<%= request.getContextPath() %>/profils?role=chef-equipe" class="chip <%= "chef-equipe".equalsIgnoreCase(selectedRole) ? "active" : "" %>">⭐ Chefs d'équipe</a>
            <a href="<%= request.getContextPath() %>/profils?role=membre" class="chip <%= "membre".equalsIgnoreCase(selectedRole) ? "active" : "" %>">Membres d'équipe</a>
        </div>

        <!-- Main 2-Column Layout -->
        <div style="display: grid; grid-template-columns: 360px 1fr; gap: 32px; align-items: start;">

            <!-- Left: List of Members (Consultation des autres membres) -->
            <div>
                <div style="margin-bottom: 12px; font-family: var(--font-mono); font-size: 11px; color: var(--muted); text-transform: uppercase;">
                    Annuaire des Chercheurs & Membres
                </div>

                <%
                    if (membres != null && !membres.isEmpty()) {
                        for (Member m : membres) {
                            boolean isSel = selectedMember != null && selectedMember.getId().equalsIgnoreCase(m.getId());
                %>
                <a href="<%= request.getContextPath() %>/profils?id=<%= m.getId() %><%= selectedStatus != null ? "&status=" + selectedStatus : "" %>" 
                   class="member-item <%= isSel ? "selected" : "" %>">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                        <div>
                            <strong style="font-family: var(--font-serif); font-size: 16px; color: var(--ink);"><%= m.getPrenom() %> <%= m.getNom() %></strong>
                            <div style="font-size: 12px; color: var(--muted); margin-top: 2px;"><%= m.getGrade() != null ? m.getGrade() : "" %></div>
                            <div style="font-size: 11.5px; color: var(--navy); font-weight: 500; margin-top: 2px;"><%= m.getEquipe() != null ? m.getEquipe() : "" %></div>
                            <% if (m.getRoleLibelle() != null && !"Membre d'équipe".equalsIgnoreCase(m.getRoleLibelle()) && !"aucun".equalsIgnoreCase(m.getRole())) { %>
                                <span class="badge <%= m.getRoleBadgeClass() %>" style="font-size: 9.5px; padding: 2px 6px; margin-top: 4px; display: inline-block;">
                                    ⭐ <%= m.getRoleLibelle() %>
                                </span>
                            <% } %>
                        </div>
                        <span class="badge <%= "doctorant".equalsIgnoreCase(m.getStatut()) ? "badge-gold" : ("retraite".equalsIgnoreCase(m.getStatut()) || "ancien".equalsIgnoreCase(m.getStatut()) ? "badge-muted" : "badge-navy") %>" style="font-size: 10.5px;">
                            <%= m.getStatut() %>
                        </span>
                    </div>
                </a>
                <%
                        }
                    } else {
                %>
                <div class="card" style="font-size: 13px; color: var(--muted);">
                    Aucun membre trouvé pour ce filtre.
                </div>
                <% } %>
            </div>

            <!-- Right: Detailed Dossier -->
            <div>
                <% if (selectedMember != null) { %>

                <!-- Formulaire de modification libre du profil -->
                <% if (canEdit) { %>
                <div id="editProfileCard" class="edit-form-card">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                        <h3 style="font-size: 18px; margin: 0; color: var(--ink);">✏️ Modifier les informations du profil</h3>
                        <button type="button" class="btn btn-sm btn-secondary" onclick="toggleEditForm()">Fermer</button>
                    </div>
                    <form action="<%= request.getContextPath() %>/profils" method="post">
                        <input type="hidden" name="id" value="<%= selectedMember.getId() %>">

                        <div class="form-grid-2">
                            <div class="field-group">
                                <label>Prénom</label>
                                <input type="text" name="firstName" value="<%= selectedMember.getPrenom() %>" required>
                            </div>
                            <div class="field-group">
                                <label>Nom</label>
                                <input type="text" name="lastName" value="<%= selectedMember.getNom() %>" required>
                            </div>
                        </div>

                        <div class="form-grid-2">
                            <div class="field-group">
                                <label>Email Institutionnel</label>
                                <input type="email" name="email" value="<%= selectedMember.getEmail() %>" required>
                            </div>
                            <div class="field-group">
                                <label style="display: flex; justify-content: space-between; align-items: center;">
                                    <span>Photo de profil</span>
                                    <span id="photoFileName" style="font-size: 11px; color: var(--muted); font-weight: normal;"></span>
                                </label>
                                <input type="hidden" name="photo" id="photoDataUrl" value="<%= selectedMember.getPhoto() != null ? selectedMember.getPhoto() : "" %>">
                                <input type="file" id="photoFileInput" accept="image/png, image/jpeg, image/webp, image/gif" style="display: none;" onchange="handlePhotoFileSelected(this)">
                                
                                <div style="display: flex; align-items: center; gap: 12px; padding: 8px 12px; background: var(--surface-2, #F1F5F9); border: 1px dashed var(--accent-2, #0284C7); border-radius: 6px;">
                                    <div id="photoPreviewContainer" style="width: 44px; height: 44px; border-radius: 50%; overflow: hidden; background: linear-gradient(135deg, #0284C7 0%, #0D9488 100%); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 15px; flex-shrink: 0; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.08);">
                                        <% if (selectedMember.getPhoto() != null && !selectedMember.getPhoto().trim().isEmpty()) { %>
                                            <img id="photoPreviewImg" src="<%= selectedMember.getPhoto() %>" alt="Aperçu" style="width: 100%; height: 100%; object-fit: cover;">
                                        <% } else { %>
                                            <span id="photoPreviewFallback"><%= (selectedMember.getPrenom() != null && !selectedMember.getPrenom().isEmpty() ? selectedMember.getPrenom().substring(0,1) : "") + (selectedMember.getNom() != null && !selectedMember.getNom().isEmpty() ? selectedMember.getNom().substring(0,1) : "") %></span>
                                        <% } %>
                                    </div>
                                    
                                    <div style="display: flex; flex-direction: column; gap: 4px; flex-grow: 1;">
                                        <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                            <button type="button" class="btn btn-secondary btn-sm" onclick="document.getElementById('photoFileInput').click()" style="display: inline-flex; align-items: center; gap: 6px; font-size: 12px; padding: 5px 12px; background: #fff; border-color: var(--accent-2); color: var(--accent-2); font-weight: 600; cursor: pointer; border-radius: 4px;">
                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                                📁 Choisir depuis vos dossiers…
                                            </button>
                                            <button type="button" id="btnRemovePhoto" class="btn btn-secondary btn-sm" onclick="clearPhotoSelection()" style="font-size: 11px; padding: 4px 8px; color: #EF4444; border-color: #FCA5A5; background: #fff; cursor: pointer; border-radius: 4px; <%= (selectedMember.getPhoto() == null || selectedMember.getPhoto().trim().isEmpty()) ? "display:none;" : "" %>">
                                                ✕ Retirer
                                            </button>
                                        </div>
                                        <div style="font-size: 11px; color: var(--muted);">Sélectionnez un fichier image depuis votre ordinateur (PNG, JPG, WebP)</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="form-grid-2">
                            <div class="field-group">
                                <label>Établissement d'origine</label>
                                <input type="text" name="etablissementOrigine" value="<%= selectedMember.getEtablissementOrigine() != null ? selectedMember.getEtablissementOrigine() : "" %>">
                            </div>
                            <div class="field-group">
                                <label>Laboratoire d'origine</label>
                                <input type="text" name="laboratoireOrigine" value="<%= selectedMember.getLaboratoireOrigine() != null ? selectedMember.getLaboratoireOrigine() : "" %>">
                            </div>
                        </div>

                        <div class="form-grid-2">
                            <div class="field-group">
                                <label>Équipe de recherche actuelle</label>
                                <select name="team">
                                    <option value="IA" <%= "IA".equalsIgnoreCase(selectedMember.getEquipe()) ? "selected" : "" %>>Intelligence Artificielle & Vision</option>
                                    <option value="Big Data" <%= "Big Data".equalsIgnoreCase(selectedMember.getEquipe()) ? "selected" : "" %>>Science des Données & Big Data</option>
                                    <option value="NLP" <%= "NLP".equalsIgnoreCase(selectedMember.getEquipe()) ? "selected" : "" %>>Traitement Automatique des Langues (NLP)</option>
                                    <option value="Sécurité" <%= "Sécurité".equalsIgnoreCase(selectedMember.getEquipe()) ? "selected" : "" %>>Cybersécurité & Réseaux</option>
                                </select>
                            </div>
                            <div class="field-group">
                                <label>Grade Académique</label>
                                <input type="text" name="grade" value="<%= selectedMember.getGrade() != null ? selectedMember.getGrade() : "" %>">
                            </div>
                        </div>

                        <!-- Données Temporelles du Membre -->
                        <div style="padding: 14px; background: var(--surface); border: 1px solid var(--border); border-radius: 2px; margin-bottom: 14px;">
                            <div style="font-family: var(--font-mono); font-size: 11px; text-transform: uppercase; color: var(--navy); margin-bottom: 10px; font-weight: 600;">
                                ⏱️ Données Temporelles & Ancienneté
                            </div>
                            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px;">
                                <div class="field-group" style="margin-bottom: 0;">
                                    <label>Date de naissance (Confidentielle 🔒)</label>
                                    <input type="date" name="dateNaissance" value="<%= selectedMember.getDateNaissance() != null ? selectedMember.getDateNaissance() : "" %>">
                                    <small style="color: var(--muted); font-size: 10.5px;">Visible uniquement par vous et la Direction</small>
                                </div>
                                <div class="field-group" style="margin-bottom: 0;">
                                    <% if ("doctorant".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                        <label>Statut Doctorat</label>
                                        <input type="text" value="Étudiant-Chercheur (Non salarié)" readonly style="background: var(--surface-2); color: var(--muted); cursor: not-allowed;">
                                        <small style="color: var(--muted); font-size: 10.5px;">Non assujetti à une embauche administrative</small>
                                    <% } else if ("associe".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                        <label>Statut Collaborateur</label>
                                        <input type="text" value="Chercheur Associé Externe" readonly style="background: var(--surface-2); color: var(--muted); cursor: not-allowed;">
                                        <small style="color: var(--muted); font-size: 10.5px;">Affiliation universitaire partenaire</small>
                                    <% } else { %>
                                        <label>Date d'embauche administrative</label>
                                        <input type="date" name="dateEmbauche" value="<%= selectedMember.getDateEmbauche() != null ? selectedMember.getDateEmbauche() : "" %>">
                                        <small style="color: var(--muted); font-size: 10.5px;">Recrutement officiel enseignement supérieur</small>
                                    <% } %>
                                </div>
                                <div class="field-group" style="margin-bottom: 0;">
                                    <label style="color: var(--accent-2); font-weight: 600;">Date d'affiliation (Clé métier ⭐)</label>
                                    <input type="date" name="dateAffiliation" value="<%= selectedMember.getDateAffiliation() != null ? selectedMember.getDateAffiliation() : "" %>" <%= !isDirector ? "readonly title='Modifiable uniquement par la Direction'" : "" %>>
                                    <small style="color: var(--accent-2); font-size: 10.5px;"><%= isDirector ? "Modifiable par la Direction" : "Clé métier LIAS (Fixée par la Direction)" %></small>
                                </div>
                            </div>
                        </div>

                        <% if (isDirector) { %>
                        <div class="form-grid-2" style="padding: 10px; background: rgba(184, 146, 85, 0.1); border: 1px solid var(--border); border-radius: 2px; margin-bottom: 14px;">
                            <div class="field-group" style="margin-bottom: 0;">
                                <label style="color: var(--accent-2); font-weight: 600;">Statut Officiel (Privilège Direction)</label>
                                <select name="status">
                                    <option value="permanent" <%= "permanent".equalsIgnoreCase(selectedMember.getStatut()) ? "selected" : "" %>>Permanent</option>
                                    <option value="doctorant" <%= "doctorant".equalsIgnoreCase(selectedMember.getStatut()) ? "selected" : "" %>>Doctorant</option>
                                    <option value="associe" <%= "associe".equalsIgnoreCase(selectedMember.getStatut()) ? "selected" : "" %>>Associé</option>
                                    <option value="retraite" <%= "retraite".equalsIgnoreCase(selectedMember.getStatut()) ? "selected" : "" %>>Retraité [Gelé]</option>
                                    <option value="ancien" <%= "ancien".equalsIgnoreCase(selectedMember.getStatut()) ? "selected" : "" %>>Ancien Membre</option>
                                </select>
                            </div>
                            <div class="field-group" style="margin-bottom: 0;">
                                <label style="color: var(--accent-2); font-weight: 600;">Rôle & Responsabilité</label>
                                <select name="role">
                                    <option value="directeur" <%= "directeur".equalsIgnoreCase(selectedMember.getRole()) ? "selected" : "" %>>Directeur</option>
                                    <option value="vice-directeur" <%= "vice-directeur".equalsIgnoreCase(selectedMember.getRole()) ? "selected" : "" %>>Vice-directeur</option>
                                    <option value="chef-equipe" <%= "chef-equipe".equalsIgnoreCase(selectedMember.getRole()) ? "selected" : "" %>>Chef d'équipe</option>
                                    <option value="membre" <%= "membre".equalsIgnoreCase(selectedMember.getRole()) || "membre-equipe".equalsIgnoreCase(selectedMember.getRole()) || "aucun".equalsIgnoreCase(selectedMember.getRole()) ? "selected" : "" %>>Membre d'équipe</option>
                                </select>
                            </div>
                        </div>
                        <% } %>

                        <div class="field-group">
                            <label>Centres d'intérêt & Domaines de recherche</label>
                            <input type="text" name="centresInteret" value="<%= selectedMember.getCentresInteret() != null ? selectedMember.getCentresInteret() : "" %>" placeholder="Séparez par des virgules (ex: Deep Learning, Cloud, NLP)">
                        </div>

                        <div class="field-group">
                            <label>Biographie académique & Présentation</label>
                            <textarea name="biographie" placeholder="Parcours, responsabilités et thématiques de recherche..."><%= selectedMember.getBiographie() != null ? selectedMember.getBiographie() : "" %></textarea>
                        </div>

                        <div style="display: flex; gap: 12px; margin-top: 16px;">
                            <button type="submit" class="btn btn-primary">Enregistrer les modifications →</button>
                            <button type="button" class="btn btn-secondary" onclick="toggleEditForm()">Annuler</button>
                        </div>
                    </form>
                </div>
                <% } %>

                <% if (isDirector) { %>
                <!-- Formulaire dédié : Évolution de Rôle & Responsabilités -->
                <div id="roleChangeFormCard" style="display: none; background: #FAF7F2; border: 1px solid var(--accent-2); border-left: 4px solid var(--accent-2); padding: 22px; border-radius: 4px; margin-bottom: 24px; box-shadow: var(--shadow-sm);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">
                        <h3 style="font-size: 17px; margin: 0; color: var(--navy); display: flex; align-items: center; gap: 8px;">
                            <span>⭐</span> Évolution du Rôle & Responsabilités
                        </h3>
                        <span class="badge badge-gold" style="font-size: 11px;">Garantie : Préservation intégrale des données</span>
                    </div>
                    <div style="background: rgba(184, 91, 53, 0.08); border-left: 3px solid var(--accent-2); padding: 10px 14px; margin-bottom: 16px; font-size: 12.5px; color: var(--ink);">
                        <strong>Règles de gestion :</strong>
                        <ul style="margin: 4px 0 0 18px; padding: 0;">
                            <li><strong>Un membre peut changer de rôle :</strong> attribution des 4 types officiels (Directeur, Vice-directeur, Chef d’équipe, Membre d’équipe).</li>
                            <li><strong>Aucun changement ne supprime les données :</strong> l'ensemble des publications, productions scientifiques, projets et historique restent intacts.</li>
                            <li><strong>Historique complet des rôles :</strong> la période précédente est clôturée et la nouvelle est immédiatement tracée dans la mémoire institutionnelle.</li>
                        </ul>
                    </div>
                    <form action="<%= request.getContextPath() %>/profils" method="post">
                        <input type="hidden" name="id" value="<%= selectedMember.getId() %>">
                        <input type="hidden" name="action" value="changer_role">
                        <div style="display: grid; grid-template-columns: 1fr 1fr 1.5fr; gap: 14px; margin-bottom: 16px;">
                            <div class="field-group" style="margin-bottom: 0;">
                                <label>Nouveau Rôle Officiel *</label>
                                <select name="nouveauRole" required style="width: 100%; padding: 9px 12px; border: 1px solid var(--border); font-size: 13.5px; border-radius: 2px;">
                                    <option value="directeur" <%= "directeur".equalsIgnoreCase(selectedMember.getRole()) ? "selected" : "" %>>Directeur</option>
                                    <option value="vice-directeur" <%= "vice-directeur".equalsIgnoreCase(selectedMember.getRole()) ? "selected" : "" %>>Vice-directeur</option>
                                    <option value="chef-equipe" <%= "chef-equipe".equalsIgnoreCase(selectedMember.getRole()) ? "selected" : "" %>>Chef d'équipe</option>
                                    <option value="membre" <%= "membre".equalsIgnoreCase(selectedMember.getRole()) || "membre-equipe".equalsIgnoreCase(selectedMember.getRole()) ? "selected" : "" %>>Membre d'équipe</option>
                                </select>
                            </div>
                            <div class="field-group" style="margin-bottom: 0;">
                                <label>Date d'effet de la nomination *</label>
                                <input type="date" name="dateEffet" required value="<%= java.time.LocalDate.now().toString() %>" style="width: 100%; padding: 8px 12px; border: 1px solid var(--border); font-size: 13.5px; border-radius: 2px;">
                            </div>
                            <div class="field-group" style="margin-bottom: 0;">
                                <label>Motif de transition / Décision de gouvernance</label>
                                <input type="text" name="motif" placeholder="Ex: Élection mandat 2026-2029, Nomination chef d'équipe..." style="width: 100%; padding: 8px 12px; border: 1px solid var(--border); font-size: 13.5px; border-radius: 2px;">
                            </div>
                        </div>
                        <div style="display: flex; gap: 10px;">
                            <button type="submit" class="btn btn-primary" style="font-size: 13px;">Appliquer le changement de rôle →</button>
                            <button type="button" class="btn btn-secondary" onclick="toggleRoleChangeForm()" style="font-size: 13px;">Annuler</button>
                        </div>
                    </form>
                </div>
                <% } %>

                <div class="dossier-card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
                        <div style="display: flex; gap: 20px; align-items: center;">
                            <div class="dossier-avatar">
                                <% if (selectedMember.getPhoto() != null && !selectedMember.getPhoto().trim().isEmpty()) { %>
                                    <img src="<%= selectedMember.getPhoto() %>" alt="<%= selectedMember.getFullName() %>">
                                <% } else { %>
                                    <%= selectedMember.getPrenom().substring(0,1) %><%= selectedMember.getNom().substring(0,1) %>
                                <% } %>
                            </div>
                            <div>
                                <h2 style="font-size: 30px; margin: 0; font-family: var(--font-serif);"><%= selectedMember.getPrenom() %> <%= selectedMember.getNom() %></h2>
                                <div style="font-family: var(--font-serif); font-style: italic; font-size: 15.5px; color: var(--muted); margin-top: 3px;">
                                    <%= selectedMember.getGrade() != null ? selectedMember.getGrade() : "Chercheur" %> · Équipe : <strong style="color: var(--navy);"><%= selectedMember.getEquipe() %></strong>
                                </div>
                            </div>
                        </div>
                        
                        <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                            <% if ("retraite".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                <span class="badge" style="background: #B5453E; color: #FFF; font-size: 12px; padding: 6px 14px;">
                                    🔒 RETRAITÉ [COMPTE GELÉ]
                                </span>
                            <% } else if ("ancien".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                <span class="badge" style="background: #64748B; color: #FFF; font-size: 12px; padding: 6px 14px;">
                                    🚪 ANCIEN MEMBRE [COMPTE DÉSACTIVÉ]
                                </span>
                            <% } else { %>
                                <span class="badge badge-navy" style="font-size: 12px; padding: 6px 14px;">
                                    Statut : <%= selectedMember.getStatut().toUpperCase() %>
                                </span>
                            <% } %>

                            <% if (!"retraite".equalsIgnoreCase(selectedMember.getStatut()) && !"ancien".equalsIgnoreCase(selectedMember.getStatut())) { %>
                            <span class="badge <%= selectedMember.getRoleBadgeClass() %>" style="font-size: 12px; padding: 6px 14px;">
                                ⭐ Rôle : <%= selectedMember.getRoleLibelle() %>
                            </span>
                            <% } %>

                            <% if (isDirector) { %>
                                <% if ("ancien".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                    <button class="btn btn-primary btn-sm" onclick="toggleReactivationForm()" style="background: #2E7D32; border-color: #2E7D32; font-size: 12px; padding: 6px 14px;">
                                        🔄 Réactiver ce compte
                                    </button>
                                <% } else if ("retraite".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                    <span class="badge badge-muted" style="font-size: 11px; padding: 6px 12px;">
                                        🔒 Aucun accès actif autorisé
                                    </span>
                                <% } else { %>
                                    <button class="btn btn-secondary btn-sm" onclick="toggleRoleChangeForm()" style="font-size: 12px; padding: 6px 14px; border-color: var(--accent-2); color: var(--accent-2); font-weight: 600;">
                                        🔄 Changer de rôle
                                    </button>
                                    <button class="btn btn-secondary btn-sm" onclick="toggleRetraiteForm()" style="font-size: 12px; padding: 6px 14px; border-color: #E53E3E; color: #C53030; font-weight: 600;">
                                        🏖️ Mettre en retraite
                                    </button>
                                    <button class="btn btn-secondary btn-sm" onclick="toggleDepartForm()" style="font-size: 12px; padding: 6px 14px; border-color: #8D6E63; color: #6D4C41; font-weight: 600;">
                                        🚪 Départ du labo
                                    </button>
                                <% } %>
                            <% } %>

                            <% if (canEdit && !"retraite".equalsIgnoreCase(selectedMember.getStatut()) && !"ancien".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                <button class="btn btn-primary btn-sm" onclick="toggleEditForm()" style="font-size: 12px; padding: 6px 14px;">
                                    ✏️ Modifier le profil
                                </button>
                            <% } %>
                        </div>
                    </div>

                    <!-- Bannières d'information spécifique -->
                    <% if ("retraite".equalsIgnoreCase(selectedMember.getStatut())) { %>
                    <div style="margin-top: 20px; padding: 16px 20px; background: #FFF5F5; border: 1px solid #FED7D7; border-left: 5px solid #E53E3E; border-radius: 4px; font-size: 13px; color: #9B2C2C;">
                        <div style="font-weight: 700; font-size: 14.5px; display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                            <span>🔒</span> Compte Gelé — Fin de carrière & Retraite
                        </div>
                        <p style="margin: 0 0 6px; line-height: 1.5;">
                            Ce chercheur honoraire est parti à la retraite. <strong>Aucun accès actif n'est autorisé</strong> sur les applications et services du laboratoire.
                        </p>
                        <div style="font-size: 12px; color: #742A2A;">
                            ✔ <strong>Historique intégralement conservé :</strong> Ses <strong><%= memberPublications != null ? memberPublications.size() : 0 %> publication(s) scientifique(s)</strong>, ses travaux académiques, ses mandats passés et ses périodes d'affiliation demeurent pérennes dans la mémoire institutionnelle du LIAS.
                        </div>
                    </div>
                    <% } else if ("ancien".equalsIgnoreCase(selectedMember.getStatut())) { %>
                    <div style="margin-top: 20px; padding: 16px 20px; background: #F8FAFC; border: 1px solid #CBD5E1; border-left: 5px solid #64748B; border-radius: 4px; font-size: 13px; color: #334155; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                        <div style="flex: 1; min-width: 260px;">
                            <div style="font-weight: 700; font-size: 14.5px; display: flex; align-items: center; gap: 8px; margin-bottom: 6px; color: #1E293B;">
                                <span>🚪</span> Compte Désactivé — Ancien Membre
                            </div>
                            <p style="margin: 0 0 4px; line-height: 1.5;">
                                Ce chercheur a quitté le laboratoire LIAS (mobilité académique ou fin de contrat). <strong>Son compte est désactivé</strong> et ses accès applicatifs sont suspendus.
                            </p>
                            <div style="font-size: 12px; color: #475569;">
                                ✔ <strong>Historique conservé</strong> · <strong>Peut éventuellement être réactivé :</strong> La Direction du laboratoire peut à tout moment réactiver le compte et ouvrir une nouvelle période d'affiliation active lors d'un retour.
                            </div>
                        </div>
                        <% if (isDirector) { %>
                            <button type="button" class="btn btn-primary" onclick="toggleReactivationForm()" style="background: #2E7D32; border-color: #2E7D32; font-size: 13px; padding: 8px 16px; white-space: nowrap;">
                                🔄 Réactiver ce compte
                            </button>
                        <% } %>
                    </div>
                    <% } %>

                    <!-- Fiche Signalétique -->
                    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin: 28px 0 20px; background: var(--surface-2); padding: 18px; border-radius: 2px;">
                        <div>
                            <span class="eyebrow" style="font-size: 10px;">Établissement d'origine</span>
                            <strong style="font-size: 12.5px; display: block; margin-top: 3px; color: var(--ink);"><%= selectedMember.getEtablissementOrigine() != null ? selectedMember.getEtablissementOrigine() : "FSBM Casablanca" %></strong>
                        </div>
                        <div>
                            <span class="eyebrow" style="font-size: 10px;">Laboratoire d'origine</span>
                            <strong style="font-size: 12.5px; display: block; margin-top: 3px; color: var(--ink);"><%= selectedMember.getLaboratoireOrigine() != null ? selectedMember.getLaboratoireOrigine() : "LIAS" %></strong>
                        </div>
                        <div>
                            <span class="eyebrow" style="font-size: 10px;">Contact Officiel</span>
                            <span style="font-family: var(--font-mono); font-size: 12px; color: var(--navy); display: block; margin-top: 3px;"><%= selectedMember.getEmail() %></span>
                        </div>
                        <div>
                            <span class="eyebrow" style="font-size: 10px;">Rôle & Responsabilité</span>
                            <strong style="font-family: var(--font-serif); font-size: 13.5px; color: var(--navy); display: block; margin-top: 3px;">
                                ⭐ <%= selectedMember.getRoleLibelle() %>
                            </strong>
                        </div>
                    </div>

                    <!-- Repères Temporels & Ancienneté -->
                    <div style="margin: 0 0 28px; padding: 18px; border: 1px solid var(--border); background: var(--surface); border-radius: 4px; box-shadow: var(--shadow-sm);">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                            <span class="eyebrow" style="font-size: 11px; color: var(--navy); font-weight: 700; letter-spacing: 0.08em;">
                                ⏱️ Repères Temporels du Système
                            </span>
                            <span class="badge badge-navy" style="font-size: 10px;">Traçabilité Temporelle</span>
                        </div>
                        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;">
                            <!-- Date d'affiliation (Clé métier ⭐) -->
                            <div style="background: rgba(184, 91, 53, 0.05); border: 1px solid var(--accent-2); padding: 14px; border-radius: 3px;">
                                <div style="display: flex; justify-content: space-between; align-items: baseline;">
                                    <span class="eyebrow" style="font-size: 10px; color: var(--accent-2); font-weight: bold;">Date d'affiliation au LIAS</span>
                                    <span class="badge badge-gold" style="font-size: 9.5px; padding: 2px 6px;">⭐ Clé Métier</span>
                                </div>
                                <strong style="font-family: var(--font-mono); font-size: 16px; color: var(--ink); display: block; margin-top: 5px;">
                                    📅 <%= selectedMember.getDateAffiliation() != null ? selectedMember.getDateAffiliation() : "2021-09-01" %>
                                </strong>
                                <span style="font-size: 11px; color: var(--muted); display: block; margin-top: 3px;">
                                    Clé métier déterminant l'appartenance institutionnelle
                                </span>
                            </div>

                            <!-- Date d'embauche / Statut spécifique -->
                            <div style="background: var(--surface-2); border: 1px solid var(--border); padding: 14px; border-radius: 3px;">
                                <% if ("doctorant".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                    <span class="eyebrow" style="font-size: 10px;">Inscription en Thèse</span>
                                    <strong style="font-family: var(--font-mono); font-size: 16px; color: var(--ink); display: block; margin-top: 5px;">
                                        🎓 <%= selectedMember.getDateAffiliation() != null ? selectedMember.getDateAffiliation() : "2023-11-01" %>
                                    </strong>
                                    <span style="font-size: 11px; color: var(--muted); display: block; margin-top: 3px;">
                                        Inscription doctorale (Non salarié permanent)
                                    </span>
                                <% } else if ("associe".equalsIgnoreCase(selectedMember.getStatut())) { %>
                                    <span class="eyebrow" style="font-size: 10px;">Statut Collaborateur</span>
                                    <strong style="font-family: var(--font-mono); font-size: 16px; color: var(--ink); display: block; margin-top: 5px;">
                                        🤝 Chercheur Associé
                                    </strong>
                                    <span style="font-size: 11px; color: var(--muted); display: block; margin-top: 3px;">
                                        Affiliation externe · Collaboration de recherche
                                    </span>
                                <% } else { %>
                                    <span class="eyebrow" style="font-size: 10px;">Date d'embauche</span>
                                    <strong style="font-family: var(--font-mono); font-size: 16px; color: var(--ink); display: block; margin-top: 5px;">
                                        💼 <%= selectedMember.getDateEmbauche() != null ? selectedMember.getDateEmbauche() : "Non renseignée" %>
                                    </strong>
                                    <span style="font-size: 11px; color: var(--muted); display: block; margin-top: 3px;">
                                        Recrutement administratif dans l'enseignement
                                    </span>
                                <% } %>
                            </div>

                            <!-- Date de naissance (Confidentielle 🔒) -->
                            <div style="background: var(--surface-2); border: 1px solid var(--border); padding: 14px; border-radius: 3px;">
                                <div style="display: flex; justify-content: space-between; align-items: baseline;">
                                    <span class="eyebrow" style="font-size: 10px;">Date de naissance</span>
                                    <span class="badge <%= canViewConfidential ? "badge-success" : "badge-muted" %>" style="font-size: 9.5px; padding: 2px 6px;">
                                        🔒 Confidentielle
                                    </span>
                                </div>
                                <% if (canViewConfidential) { %>
                                    <strong style="font-family: var(--font-mono); font-size: 16px; color: var(--ink); display: block; margin-top: 5px;">
                                        🎂 <%= selectedMember.getDateNaissance() != null ? selectedMember.getDateNaissance() : "1985-01-01" %>
                                    </strong>
                                    <span style="font-size: 11px; color: #2e7d32; display: block; margin-top: 3px;">
                                        ✓ Visible uniquement par vous et la Direction
                                    </span>
                                <% } else { %>
                                    <div style="font-family: var(--font-serif); font-style: italic; font-size: 14px; color: var(--muted); margin-top: 6px;">
                                        🔒 Donnée masquée
                                    </div>
                                    <span style="font-size: 11px; color: var(--muted); display: block; margin-top: 3px;">
                                        Protégée par le règlement intérieur (non publique)
                                    </span>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Biographie -->
                    <h3 style="font-size: 18px; border-bottom: 1px solid var(--border); padding-bottom: 8px; margin-bottom: 12px;">
                        Biographie académique
                    </h3>
                    <p style="font-family: var(--font-serif); font-size: 15px; color: var(--ink); line-height: 1.6; margin: 0 0 24px;">
                        <%= selectedMember.getBiographie() != null && !selectedMember.getBiographie().trim().isEmpty() 
                            ? selectedMember.getBiographie() 
                            : "Membre actif du Laboratoire d'Informatique et Applications Scientifiques (LIAS), participant aux travaux de recherche et aux projets collaboratifs." %>
                    </p>

                    <!-- Centres d'intérêt -->
                    <h3 style="font-size: 18px; border-bottom: 1px solid var(--border); padding-bottom: 8px; margin-bottom: 14px;">
                        Centres d'intérêt & Domaines d'expertise
                    </h3>
                    <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 28px;">
                        <% 
                            String centresStr = selectedMember.getCentresInteret();
                            if (centresStr != null && !centresStr.trim().isEmpty()) {
                                String[] parts = centresStr.split(",");
                                for (String c : parts) {
                        %>
                            <span class="badge badge-muted" style="padding: 5px 10px; font-size: 12px;"><%= c.trim() %></span>
                        <% 
                                }
                            } else {
                        %>
                            <span class="badge badge-muted">Informatique</span>
                            <span class="badge badge-muted">Science des données</span>
                        <% } %>
                    </div>

                    <!-- Publications du membre -->
                    <div style="display: flex; justify-content: space-between; align-items: baseline; border-bottom: 1px solid var(--border); padding-bottom: 8px; margin-bottom: 14px;">
                        <h3 style="font-size: 18px; margin: 0;">
                            Publications scientifiques (<%= memberPublications != null ? memberPublications.size() : 0 %>)
                        </h3>
                        <a href="<%= request.getContextPath() %>/publications?author=<%= java.net.URLEncoder.encode(selectedMember.getNom(), "UTF-8") %>" style="font-size: 12px; color: var(--navy); text-decoration: none;">
                            Voir dans le catalogue →
                        </a>
                    </div>

                    <% if (memberPublications != null && !memberPublications.isEmpty()) { %>
                        <div style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 28px;">
                            <% for (Publication pub : memberPublications) { %>
                            <div style="padding: 12px 14px; background: var(--surface-2); border: 1px solid var(--border); border-radius: 2px;">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                    <span style="font-family: var(--font-mono); font-size: 11px; font-weight: 600; color: var(--navy);"><%= pub.getAnnee() %> · <%= pub.getType() != null ? pub.getType() : "Article" %></span>
                                    <% if (pub.getDoi() != null && !pub.getDoi().isEmpty()) { %>
                                        <span style="font-family: var(--font-mono); font-size: 10.5px; color: var(--muted);">DOI: <%= pub.getDoi() %></span>
                                    <% } %>
                                </div>
                                <div style="font-family: var(--font-serif); font-size: 14.5px; font-weight: 500; color: var(--ink);">
                                    <%= pub.getTitre() %>
                                </div>
                                <div style="font-size: 12px; color: var(--muted); margin-top: 2px;">
                                    <em><%= pub.getRevue() %></em> — <%= pub.getAuteurs() %>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div style="padding: 14px; background: var(--surface-2); border: 1px solid var(--border); border-radius: 2px; font-size: 13px; color: var(--muted); margin-bottom: 28px;">
                            Aucune publication individuelle enregistrée sous le nom de ce chercheur pour le moment.
                        </div>
                    <% } %>

                    <!-- Historisation temporelle des rôles et affiliations -->
                    <div style="display: flex; justify-content: space-between; align-items: baseline; border-bottom: 1px solid var(--border); padding-bottom: 8px; margin-bottom: 16px; flex-wrap: wrap; gap: 10px;">
                        <div>
                            <h3 style="font-size: 18px; margin: 0;">
                                Historique complet des rôles et affiliations
                            </h3>
                            <span style="font-size: 11.5px; color: var(--muted);">
                                Traçabilité intégrale du cycle de vie et des mandats : changements de rôles et périodes d'affiliation conservés sans aucune suppression de données.
                            </span>
                        </div>
                        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                            <% if (isDirector) { %>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="toggleRoleChangeForm()" style="font-size: 11.5px; padding: 5px 10px; border-color: var(--accent-2); color: var(--accent-2); font-weight: 600;">⭐ Changer de rôle</button>
                            <% } %>
                            <% if (canEdit || isDirector) { %>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="toggleDepartForm()" style="font-size: 11.5px; padding: 5px 10px;">🚪 Quitter le labo</button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="toggleRetourForm()" style="font-size: 11.5px; padding: 5px 10px;">🔄 Réintégrer (Retour)</button>
                            <button type="button" class="btn btn-primary btn-sm" onclick="togglePeriodeForm()" style="font-size: 11.5px; padding: 5px 10px;">➕ Ajouter période</button>
                            <% } %>
                        </div>
                    </div>

                    <div style="background: rgba(30, 107, 55, 0.06); border: 1px solid #C4E7CB; padding: 10px 14px; border-radius: 2px; font-size: 12.5px; color: #1E6B37; margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                        <span>🛡️</span>
                        <strong>Intégrité garantie :</strong> Aucun changement de rôle ne supprime les données scientifiques (publications, communications, projets antérieurs conservés à 100%).
                    </div>

                    <% if (canEdit || isDirector) { %>
                    <!-- Formulaire de mise à la retraite -->
                    <div id="retraiteFormCard" style="display: none; background: #FFFBFB; border: 1px solid #FEB2B2; border-left: 4px solid #E53E3E; padding: 20px; border-radius: 4px; margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <h4 style="margin: 0; font-size: 15px; color: #9B2C2C;">🏖️ Enregistrer le départ à la retraite</h4>
                            <span class="badge badge-gold" style="font-size: 10.5px;">Compte gelé · Historique conservé</span>
                        </div>
                        <p style="font-size: 12.5px; color: #742A2A; margin: 0 0 14px;">
                            <strong>Règle de gestion :</strong> Le compte utilisateur sera <strong>gelé</strong> (aucun accès actif ne sera plus possible). Toutes ses publications, affiliations passées et projets sont <strong>scrupuleusement conservés</strong> dans les archives institutionnelles.
                        </p>
                        <form action="<%= request.getContextPath() %>/profils" method="post" style="display: flex; gap: 12px; align-items: flex-end; flex-wrap: wrap;">
                            <input type="hidden" name="id" value="<%= selectedMember.getId() %>">
                            <input type="hidden" name="action" value="partir_retraite">
                            <div>
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Date effective de retraite * :</label>
                                <input type="date" name="dateFin" required value="<%= java.time.LocalDate.now().toString() %>" style="padding: 7px 10px; border: 1px solid var(--border); font-size: 13px;">
                            </div>
                            <div style="flex: 1; min-width: 220px;">
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Motif officiel / Décoration :</label>
                                <input type="text" name="motif" value="Départ à la Retraite · Professeur Émérite" style="width: 100%; padding: 7px 10px; border: 1px solid var(--border); font-size: 13px;">
                            </div>
                            <button type="submit" class="btn btn-secondary btn-sm" style="background: #E53E3E; color: #FFF; border: none; padding: 8px 16px; font-weight: 600;" onclick="return confirm('Confirmer la mise en retraite ? Le compte sera gelé (aucun accès actif).');">Confirmer le gel du compte</button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="toggleRetraiteForm()">Annuler</button>
                        </form>
                    </div>

                    <!-- Formulaire de départ (Quitter le labo) -->
                    <div id="departFormCard" style="display: none; background: #FFFDF5; border: 1px solid #FFE082; border-left: 4px solid #D97706; padding: 20px; border-radius: 4px; margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <h4 style="margin: 0; font-size: 15px; color: #8D6E63;">🚪 Enregistrer le départ du membre</h4>
                            <span class="badge badge-muted" style="font-size: 10.5px;">Compte désactivé · Réactivable</span>
                        </div>
                        <p style="font-size: 12.5px; color: var(--muted); margin: 0 0 14px;">
                            <strong>Règle de gestion :</strong> Le compte utilisateur sera <strong>désactivé</strong> et la période d'affiliation clôturée. L'historique complet est conservé et le compte pourra être <strong>réactivé</strong> ultérieurement en cas de retour.
                        </p>
                        <form action="<%= request.getContextPath() %>/profils" method="post" style="display: flex; gap: 12px; align-items: flex-end; flex-wrap: wrap;">
                            <input type="hidden" name="id" value="<%= selectedMember.getId() %>">
                            <input type="hidden" name="action" value="quitter_labo">
                            <div>
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Date de fin / départ * :</label>
                                <input type="date" name="dateFin" required value="<%= java.time.LocalDate.now().toString() %>" style="padding: 7px 10px; border: 1px solid var(--border); font-size: 13px;">
                            </div>
                            <div style="flex: 1; min-width: 220px;">
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Motif de départ (mobilité, mutation...) :</label>
                                <input type="text" name="motif" placeholder="Ex: Mobilité internationale, Fin de contrat doctoral..." style="width: 100%; padding: 7px 10px; border: 1px solid var(--border); font-size: 13px;">
                            </div>
                            <button type="submit" class="btn btn-secondary btn-sm" style="background: #8D6E63; color: #FFF; border: none; padding: 8px 16px; font-weight: 600;" onclick="return confirm('Confirmer la désactivation du compte pour départ ?');">Confirmer la désactivation</button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="toggleDepartForm()">Annuler</button>
                        </form>
                    </div>

                    <!-- Formulaire de réactivation -->
                    <div id="reactivationFormCard" style="display: none; background: #F4FBF5; border: 1px solid #A5D6A7; border-left: 4px solid #2E7D32; padding: 20px; border-radius: 4px; margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <h4 style="margin: 0; font-size: 15px; color: #2E7D32;">🔄 Réactivation de compte & Réintégration</h4>
                            <span class="badge badge-success" style="font-size: 10.5px;">Rétablissement des accès actifs</span>
                        </div>
                        <p style="font-size: 12.5px; color: #1B5E20; margin: 0 0 14px;">
                            <strong>Règle de gestion :</strong> Le compte de l'ancien membre est <strong>réactivé</strong>, ses accès sont rétablis et une <strong>nouvelle période d'affiliation active</strong> est ouverte dans la mémoire du laboratoire.
                        </p>
                        <form action="<%= request.getContextPath() %>/profils" method="post" style="display: grid; grid-template-columns: 1fr 1fr 1fr auto auto; gap: 12px; align-items: flex-end;">
                            <input type="hidden" name="id" value="<%= selectedMember.getId() %>">
                            <input type="hidden" name="action" value="reactiver_membre">
                            <div>
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Date de réintégration * :</label>
                                <input type="date" name="dateDebut" required value="<%= java.time.LocalDate.now().toString() %>" style="width: 100%; padding: 7px 10px; border: 1px solid var(--border); font-size: 13px;">
                            </div>
                            <div>
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Statut réattribué * :</label>
                                <select name="nouveauStatut" style="width: 100%; padding: 7px 10px; border: 1px solid var(--border); font-size: 13px;">
                                    <option value="permanent" selected>Permanent</option>
                                    <option value="associe">Associé</option>
                                    <option value="doctorant">Doctorant</option>
                                </select>
                            </div>
                            <div>
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Rôle à la reprise * :</label>
                                <select name="nouveauRole" style="width: 100%; padding: 7px 10px; border: 1px solid var(--border); font-size: 13px;">
                                    <option value="membre" selected>Membre d'équipe</option>
                                    <option value="chef-equipe">Chef d'équipe</option>
                                    <option value="vice-directeur">Vice-directeur</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary btn-sm" style="background: #2E7D32; border: none; padding: 8px 16px; font-weight: 600;">Réactiver l'accès →</button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="toggleReactivationForm()">Annuler</button>
                        </form>
                    </div>

                    <!-- Formulaire d'ajout direct de période -->
                    <div id="periodeFormCard" style="display: none; background: #F0F4F8; border: 1px solid #90CAF9; padding: 18px; border-radius: 4px; margin-bottom: 18px;">
                        <h4 style="margin: 0 0 10px; font-size: 14px; color: #1565C0;">➕ Ajouter une période d'affiliation spécifique (Historique)</h4>
                        <form action="<%= request.getContextPath() %>/profils" method="post" style="display: flex; gap: 12px; align-items: flex-end; flex-wrap: wrap;">
                            <input type="hidden" name="id" value="<%= selectedMember.getId() %>">
                            <input type="hidden" name="action" value="ajouter_periode">
                            <div>
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Date début * :</label>
                                <input type="date" name="dateDebut" required style="padding: 6px 10px; border: 1px solid var(--border); font-size: 12.5px;">
                            </div>
                            <div>
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Date fin (optionnelle si en cours) :</label>
                                <input type="date" name="dateFin" style="padding: 6px 10px; border: 1px solid var(--border); font-size: 12.5px;">
                            </div>
                            <div style="flex: 1; min-width: 180px;">
                                <label style="display: block; font-size: 11px; font-family: var(--font-mono); color: var(--muted); margin-bottom: 3px;">Rôle / Libellé de la période :</label>
                                <input type="text" name="roleHistorique" placeholder="Ex: Chercheur invité, Doctorant..." required style="width: 100%; padding: 6px 10px; border: 1px solid var(--border); font-size: 12.5px;">
                            </div>
                            <button type="submit" class="btn btn-primary btn-sm" style="padding: 7px 14px;">Enregistrer la période</button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="togglePeriodeForm()">Annuler</button>
                        </form>
                    </div>
                    <% } %>

                    <% if (affiliationPeriods != null && affiliationPeriods.size() > 1) { %>
                    <div style="background: rgba(184, 91, 53, 0.06); border: 1px solid var(--accent-2); padding: 10px 14px; border-radius: 2px; font-size: 12.5px; color: var(--accent-2); margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                        <span>🔄</span>
                        <strong>Parcours à affiliations multiples :</strong> Ce membre a quitté puis réintégré le laboratoire LIAS. Chaque tranche est conservée dans l'historique temporel.
                    </div>
                    <% } %>

                    <div class="timeline-box">
                        <% if (affiliationPeriods != null && !affiliationPeriods.isEmpty()) { %>
                            <% for (AffiliationPeriod ap : affiliationPeriods) { 
                                boolean isActive = (ap.getDateFin() == null);
                            %>
                            <div class="timeline-step" style="<%= isActive ? "border-left: 2px solid #2e7d32; padding-left: 10px;" : "" %>">
                                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                                    <div style="font-family: var(--font-mono); font-size: 11.5px; font-weight: 600; color: var(--navy);">
                                        📅 <%= ap.getDateDebut() != null ? ap.getDateDebut().toString() : "" %> 
                                        &nbsp;→&nbsp; 
                                        <%= ap.getDateFin() != null ? ap.getDateFin().toString() : "Actuel (En cours)" %>
                                    </div>
                                    <span class="badge <%= isActive ? "badge-success" : "badge-muted" %>" style="font-size: 10px; padding: 2px 7px;">
                                        <%= isActive ? "✅ Période active" : "⏱️ Clôturée" %>
                                    </span>
                                </div>
                                <div style="font-weight: 600; color: var(--ink); font-size: 14.5px; margin-top: 4px;">
                                    <% 
                                        String rHist = ap.getRoleHistorique() != null ? ap.getRoleHistorique() : "";
                                        rHist = rHist.replace("D??part", "Départ").replace("D?part", "Départ")
                                                     .replace("?? la Retraite", "à la Retraite").replace("? la Retraite", "à la Retraite")
                                                     .replace("Statut Gel??", "Statut Gelé").replace("Statut Gel?", "Statut Gelé")
                                                     .replace("P??riode", "Période").replace("??quip", "équip")
                                                     .replace("??", "—");
                                    %>
                                    <% if (rHist.toLowerCase().contains("retour") || rHist.toLowerCase().contains("réintégration") || rHist.toLowerCase().contains("reintegration")) { %>
                                        🔄 <%= rHist %>
                                    <% } else if (rHist.toLowerCase().contains("départ") || rHist.toLowerCase().contains("depart") || rHist.toLowerCase().contains("retraite")) { %>
                                        🏖️ <%= rHist %>
                                    <% } else { %>
                                        🏛️ <%= rHist %>
                                    <% } %>
                                </div>
                                <div style="font-size: 12px; color: var(--muted); margin-top: 2px;">
                                    Laboratoire LIAS · Faculté des Sciences Ben M'Sik Casablanca (Enregistrement non-destructif)
                                </div>
                            </div>
                            <% } %>
                        <% } else { %>
                            <div class="timeline-step">
                                <div style="font-family: var(--font-mono); font-size: 11px; color: var(--muted);">Depuis <%= selectedMember.getDateAffiliation() %></div>
                                <div style="font-weight: 600; color: var(--ink); font-size: 14px;">Affiliation active · <%= selectedMember.getGrade() %></div>
                                <div style="font-size: 12.5px; color: var(--muted);">Faculté des Sciences Ben M'Sik, Université Hassan II de Casablanca.</div>
                            </div>
                        <% } %>
                    </div>

                </div>
                <% } %>
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

<script>
    function toggleEditForm() {
        var card = document.getElementById('editProfileCard');
        if (card) {
            if (card.style.display === 'block') {
                card.style.display = 'none';
            } else {
                card.style.display = 'block';
                card.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }
    }

    function toggleDepartForm() {
        var card = document.getElementById('departFormCard');
        if (card) {
            card.style.display = (card.style.display === 'block') ? 'none' : 'block';
            if (card.style.display === 'block') card.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function toggleRetourForm() {
        var card = document.getElementById('retourFormCard');
        if (card) {
            card.style.display = (card.style.display === 'block') ? 'none' : 'block';
            if (card.style.display === 'block') card.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function togglePeriodeForm() {
        var card = document.getElementById('periodeFormCard');
        if (card) {
            card.style.display = (card.style.display === 'block') ? 'none' : 'block';
            if (card.style.display === 'block') card.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function toggleRoleChangeForm() {
        var card = document.getElementById('roleChangeFormCard');
        if (card) {
            card.style.display = (card.style.display === 'block') ? 'none' : 'block';
            if (card.style.display === 'block') card.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function toggleRetraiteForm() {
        var card = document.getElementById('retraiteFormCard');
        if (card) {
            card.style.display = (card.style.display === 'block') ? 'none' : 'block';
            if (card.style.display === 'block') card.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function handlePhotoFileSelected(input) {
        if (input.files && input.files[0]) {
            var file = input.files[0];
            if (file.size > 6 * 1024 * 1024) {
                alert("L'image sélectionnée est trop volumineuse (> 6 Mo). Veuillez choisir une image plus légère.");
                return;
            }
            var reader = new FileReader();
            reader.onload = function(e) {
                var dataUrl = e.target.result;
                document.getElementById('photoDataUrl').value = dataUrl;
                
                var container = document.getElementById('photoPreviewContainer');
                container.innerHTML = '<img id="photoPreviewImg" src="' + dataUrl + '" alt="Aperçu" style="width:100%; height:100%; object-fit:cover;">';
                
                var fileNameSpan = document.getElementById('photoFileName');
                if (fileNameSpan) fileNameSpan.innerText = '📁 ' + file.name;
                
                var btnRemove = document.getElementById('btnRemovePhoto');
                if (btnRemove) btnRemove.style.display = 'inline-flex';
            };
            reader.readAsDataURL(file);
        }
    }

    function clearPhotoSelection() {
        document.getElementById('photoDataUrl').value = '';
        var fileInp = document.getElementById('photoFileInput');
        if (fileInp) fileInp.value = '';
        var container = document.getElementById('photoPreviewContainer');
        var initials = '<%= (selectedMember != null && selectedMember.getPrenom() != null && !selectedMember.getPrenom().isEmpty() ? selectedMember.getPrenom().substring(0,1) : "") + (selectedMember != null && selectedMember.getNom() != null && !selectedMember.getNom().isEmpty() ? selectedMember.getNom().substring(0,1) : "") %>';
        container.innerHTML = '<span id="photoPreviewFallback">' + initials + '</span>';
        var fileNameSpan = document.getElementById('photoFileName');
        if (fileNameSpan) fileNameSpan.innerText = '';
        var btnRemove = document.getElementById('btnRemovePhoto');
        if (btnRemove) btnRemove.style.display = 'none';
    }
</script>

</body>
</html>

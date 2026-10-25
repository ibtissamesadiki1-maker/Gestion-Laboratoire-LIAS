<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.Mandat"%>
<%@ page import="com.lias.beans.Member"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    boolean isDirecteur = (currentUser != null && ("directeur".equalsIgnoreCase(currentUser.getRole()) || "admin".equalsIgnoreCase(currentUser.getRole())));

    List<Mandat> mandats = (List<Mandat>) request.getAttribute("mandats");
    Mandat mandatActif = (Mandat) request.getAttribute("mandatActif");
    List<Member> permanents = (List<Member>) request.getAttribute("permanents");
    String msg = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Gouvernance & Historique des Mandats</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
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
                        <span class="eyebrow">Organisation & Gouvernance Institutionnelle</span>
                        <h1 class="page-title">Mandats de Direction</h1>
                        <p class="page-sub">
                            Historique officiel des mandats de direction du LIAS. Conformément au cahier des charges, la fonction de direction est temporaire et découplée de la qualité de membre permanent du laboratoire.
                        </p>
                    </div>
                    <% if (isDirecteur) { %>
                        <button type="button" class="btn btn-primary" onclick="document.getElementById('modalMandat').style.display='flex'">
                            + Enregistrer un mandat
                        </button>
                    <% } %>
                </div>

                <% if ("created".equals(msg)) { %>
                    <div class="alert alert-success" style="background:#ECFDF5; border-right:4px solid #059669; padding:12px 18px; border-radius:4px; margin-bottom:20px; color:#065F46; font-size:13.5px;">
                        ✓ Le mandat a été consigné avec succès dans le registre officiel de gouvernance.
                    </div>
                <% } %>

                <!-- Mandat Actif Hero Card -->
                <% if (mandatActif != null) { %>
                <div class="card" style="background: linear-gradient(135deg, #152B44 0%, #0D1C2D 100%); color: #FFF; border: none; padding: 28px; margin-bottom: 30px; border-radius: 8px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 15px;">
                        <div>
                            <span class="chip" style="background: rgba(184,146,85,0.25); color: #F8E7C9; border: 1px solid #B89255; font-family: monospace; font-size: 11px;">MANDAT EN COURS D'EXERCICE</span>
                            <h2 style="font-size: 22px; font-weight: 800; margin: 10px 0; color: #FFF;"><%= mandatActif.getTitre() %></h2>
                            <p style="color: #CBD5E1; font-size: 14px; margin-bottom: 16px;">
                                Mandat quadriennal approuvé par le Conseil de Laboratoire et la Faculté des Sciences Ben M'Sik.
                            </p>
                        </div>
                        <div style="text-align: right;">
                            <span class="status-badge" style="background: #10B981; color: #FFF; padding: 4px 12px; border-radius: 4px; font-weight: 700; font-size: 12px;">ACTIF</span>
                        </div>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-top: 15px; padding-top: 15px; border-top: 1px solid rgba(255,255,255,0.15);">
                        <div>
                            <div style="font-size: 11px; text-transform: uppercase; color: #94A3B8; font-weight: 700;">Directeur du Laboratoire</div>
                            <div style="font-size: 15px; font-weight: 700; color: #F8FAFC; margin-top: 2px;">
                                <%= mandatActif.getDirecteurNomComplet() != null ? mandatActif.getDirecteurNomComplet() : mandatActif.getDirecteurId() %>
                            </div>
                        </div>
                        <div>
                            <div style="font-size: 11px; text-transform: uppercase; color: #94A3B8; font-weight: 700;">Vice-Directeur</div>
                            <div style="font-size: 15px; font-weight: 700; color: #F8FAFC; margin-top: 2px;">
                                <%= mandatActif.getViceDirecteurNomComplet() != null ? mandatActif.getViceDirecteurNomComplet() : "Non désigné" %>
                            </div>
                        </div>
                        <div>
                            <div style="font-size: 11px; text-transform: uppercase; color: #94A3B8; font-weight: 700;">Chefs d'Équipe</div>
                            <div style="font-size: 13.5px; font-weight: 600; color: #E2E8F0; margin-top: 2px;">
                                <%= mandatActif.getChefsEquipes() != null ? mandatActif.getChefsEquipes() : "Pr. Sara Benjelloun, Pr. Karim Zouhair, Pr. Amine Alami" %>
                            </div>
                        </div>
                        <div>
                            <div style="font-size: 11px; text-transform: uppercase; color: #94A3B8; font-weight: 700;">Période Officielle</div>
                            <div style="font-size: 14px; font-family: monospace; color: #B89255; margin-top: 2px;">
                                <%= mandatActif.getDateDebut() %> ⟶ <%= mandatActif.getDateFin() != null ? mandatActif.getDateFin() : "Présent" %>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>

                <!-- Timeline & Registre des mandats -->
                <div class="card">
                    <div class="card-header" style="padding: 18px 24px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center;">
                        <h3 style="font-size: 17px; font-weight: 800; color: var(--navy-primary); margin: 0;">Registre Chronologique des Mandats</h3>
                        <span style="font-size: 12px; color: var(--text-muted);"><%= mandats != null ? mandats.size() : 0 %> mandats enregistrés</span>
                    </div>
                    <div class="table-container" style="overflow-x: auto;">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Titre du Mandat</th>
                                    <th>Directeur</th>
                                    <th>Vice-Directeur</th>
                                    <th>Chefs d'Équipe</th>
                                    <th>Date Début</th>
                                    <th>Date Fin</th>
                                    <th>Statut</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (mandats != null && !mandats.isEmpty()) { 
                                    for (Mandat m : mandats) { %>
                                    <tr>
                                        <td><strong><%= m.getTitre() %></strong></td>
                                        <td><%= m.getDirecteurNomComplet() != null ? m.getDirecteurNomComplet() : m.getDirecteurId() %></td>
                                        <td><%= m.getViceDirecteurNomComplet() != null ? m.getViceDirecteurNomComplet() : "—" %></td>
                                        <td style="font-size: 12.5px; color: var(--text-secondary);"><%= m.getChefsEquipes() != null ? m.getChefsEquipes() : "Chefs d'équipe statutaires" %></td>
                                        <td style="font-family: monospace;"><%= m.getDateDebut() %></td>
                                        <td style="font-family: monospace;"><%= m.getDateFin() != null ? m.getDateFin() : "En cours" %></td>
                                        <td>
                                            <% if (m.isActif()) { %>
                                                <span class="status-badge status-active" style="background:#ECFDF5; color:#065F46; border:1px solid #A7F3D0;">Actif</span>
                                            <% } else { %>
                                                <span class="status-badge" style="background:#F1F5F9; color:#475569;">Clôturé</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr>
                                        <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                            Aucun mandat archivé dans la base.
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

<!-- Modal Ajout Mandat -->
<% if (isDirecteur) { %>
<div id="modalMandat" class="modal-backdrop" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
    <div class="modal-card" style="background:#FFF; width:100%; max-width:550px; border-radius:8px; overflow:hidden; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
        <div style="background:var(--navy-primary); color:#FFF; padding:16px 20px; display:flex; justify-content:space-between; align-items:center;">
            <h3 style="margin:0; font-size:16px; font-weight:800;">Enregistrer un Mandat de Direction</h3>
            <button type="button" onclick="document.getElementById('modalMandat').style.display='none'" style="background:none; border:none; color:#FFF; font-size:18px; cursor:pointer;">✕</button>
        </div>
        <form action="<%= request.getContextPath() %>/mandats" method="POST" style="padding:20px;">
            <div style="margin-bottom:14px;">
                <label style="display:block; font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:4px;">Titre du Mandat *</label>
                <input type="text" name="titre" required class="input-text" style="width:100%; padding:8px 12px; border:1px solid #CBD5E1; border-radius:4px;" placeholder="Ex: Mandat 2026-2030 : Consolidation IA">
            </div>
            
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:14px;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:4px;">Directeur désigné *</label>
                    <select name="directeurId" required class="input-text" style="width:100%; padding:8px 12px; border:1px solid #CBD5E1; border-radius:4px;">
                        <% if (permanents != null) { 
                            for (Member p : permanents) { %>
                                <option value="<%= p.getId() %>"><%= p.getFullName() %> (<%= p.getTeam() %>)</option>
                        <% } } %>
                    </select>
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:4px;">Vice-Directeur (optionnel)</label>
                    <select name="viceDirecteurId" class="input-text" style="width:100%; padding:8px 12px; border:1px solid #CBD5E1; border-radius:4px;">
                        <option value="">-- Aucun --</option>
                        <% if (permanents != null) { 
                            for (Member p : permanents) { %>
                                <option value="<%= p.getId() %>"><%= p.getFullName() %></option>
                        <% } } %>
                    </select>
                </div>
            </div>

            <div style="margin-bottom:14px;">
                <label style="display:block; font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:4px;">Chefs d'Équipe associés</label>
                <input type="text" name="chefsEquipes" class="input-text" style="width:100%; padding:8px 12px; border:1px solid #CBD5E1; border-radius:4px;" placeholder="Ex: Pr. Sara Benjelloun (Big Data), Pr. Karim Zouhair (Sécurité)">
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:14px;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:4px;">Date de Début *</label>
                    <input type="date" name="dateDebut" required class="input-text" style="width:100%; padding:8px 12px; border:1px solid #CBD5E1; border-radius:4px;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:4px;">Date de Fin</label>
                    <input type="date" name="dateFin" class="input-text" style="width:100%; padding:8px 12px; border:1px solid #CBD5E1; border-radius:4px;">
                </div>
            </div>

            <div style="margin-bottom:18px;">
                <label style="font-size:13px; color:var(--text-secondary); cursor:pointer; display:flex; align-items:center; gap:8px;">
                    <input type="checkbox" name="actif" value="true">
                    <span>Définir comme mandat actif en cours d'exercice</span>
                </label>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" onclick="document.getElementById('modalMandat').style.display='none'" class="btn btn-secondary">Annuler</button>
                <button type="submit" class="btn btn-primary">Enregistrer le mandat</button>
            </div>
        </form>
    </div>
</div>
<% } %>

</body>
</html>

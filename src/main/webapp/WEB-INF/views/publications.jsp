<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Set"%>
<%@ page import="com.lias.beans.Publication"%>
<%@ page import="com.lias.beans.User"%>
<%
    List<Publication> pubs = (List<Publication>) request.getAttribute("publications");
    String selectedYear = (String) request.getAttribute("selectedYear");
    String selectedTeam = (String) request.getAttribute("selectedTeam");
    String selectedAuthor = (String) request.getAttribute("selectedAuthor");
    String selectedTri = (String) request.getAttribute("selectedTri");
    if (selectedTri == null) selectedTri = "annee_desc";

    Integer totalPubs = (Integer) request.getAttribute("totalPublications");
    if (totalPubs == null) totalPubs = (pubs != null ? pubs.size() : 0);
    Integer countArticles = (Integer) request.getAttribute("countArticles");
    if (countArticles == null) countArticles = 0;
    Integer countConferences = (Integer) request.getAttribute("countConferences");
    if (countConferences == null) countConferences = 0;
    Integer countOuvrages = (Integer) request.getAttribute("countOuvrages");
    if (countOuvrages == null) countOuvrages = 0;

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");

    boolean canAdd = (currentUser != null && 
        !"retraite".equalsIgnoreCase(currentUser.getRole()) && 
        !"ancien".equalsIgnoreCase(currentUser.getRole()));

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Publications Scientifiques & Production Académique</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        .filter-grid {
            display: grid;
            grid-template-columns: 1.2fr 1.2fr 1.5fr 1.2fr auto;
            gap: 12px;
            align-items: flex-end;
        }
        .add-form-card {
            display: none;
            background: var(--surface);
            border: 1px solid var(--border);
            padding: 28px;
            margin-bottom: 28px;
            border-left: 4px solid var(--navy);
            border-radius: 4px;
            box-shadow: var(--shadow-sm);
        }
        .pub-row {
            display: grid;
            grid-template-columns: 85px 1fr 140px;
            gap: 20px;
            padding: 20px 24px;
            border-bottom: 1px solid var(--border);
            align-items: baseline;
            transition: background 0.15s;
        }
        .pub-row:hover {
            background: rgba(237, 229, 211, 0.25);
        }
        .pub-year {
            font-family: var(--font-serif);
            font-size: 26px;
            font-weight: 700;
            color: var(--navy);
            font-variant-numeric: tabular-nums;
        }
        .pub-title {
            font-family: var(--font-serif);
            font-size: 17.5px;
            font-weight: 600;
            color: var(--ink);
            margin: 0 0 6px;
            line-height: 1.35;
        }
        .pub-authors {
            font-size: 13.5px;
            color: var(--muted);
        }
        .pub-venue {
            font-style: italic;
            color: var(--navy);
            font-size: 13px;
            margin-top: 2px;
        }
        .sort-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 4px;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--navy);
            text-decoration: none;
            font-size: 12.5px;
            font-weight: 600;
            transition: all 0.15s ease;
        }
        .sort-pill.active {
            background: var(--navy);
            color: #FFFFFF;
            border-color: var(--navy);
        }
        .pub-pill {
            background: #F8FAFC;
            border: 1px solid #CBD5E1;
            border-radius: 20px;
            padding: 5px 14px;
            font-size: 12px;
            font-weight: 600;
            color: #475569;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .pub-pill:hover {
            background: #E2E8F0;
            color: #0F172A;
            border-color: #94A3B8;
        }
        .pub-pill.active {
            background: #0284C7;
            color: #FFFFFF;
            border-color: #0284C7;
            box-shadow: 0 2px 8px rgba(2, 132, 199, 0.25);
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
                <span class="eyebrow" style="color: var(--accent-2);">Production Scientifique & Rayonnement Académique</span>
                <h1 class="page-title"><%= (currentUser != null) ? "Gestion des Publications" : "Catalogue des Publications Scientifiques" %></h1>
                <p class="page-sub">
                    <% if (currentUser != null) { %>
                        Consultation globale du catalogue et déclaration autonome réservée aux membres et doctorants du laboratoire LIAS.
                    <% } else { %>
                        Consultation publique du catalogue officiel des productions scientifiques, articles indexés et actes de conférences du laboratoire LIAS.
                    <% } %>
                </p>
            </div>
            <% if (canAdd) { %>
                <button type="button" class="btn btn-primary" onclick="toggleAddForm()">
                    + Ajouter une publication (Membres & Doctorants)
                </button>
            <% } %>
        </div>

        <!-- TOAST NOTIFICATIONS -->
        <% if ("ajoute".equals(msg)) { %>
            <div class="toast-notification" id="appToast">
                <div style="font-size: 20px;">✓</div>
                <div>
                    <div style="font-weight: 700; font-size: 14px;">Publication enregistrée avec succès !</div>
                    <div style="font-size: 12.5px; opacity: 0.9;">Votre travail a été indexé au catalogue du laboratoire et notifié à l'ensemble des membres.</div>
                </div>
            </div>
        <% } else if ("compte_bloque".equals(error)) { %>
            <div class="toast-notification" style="background: #FEF2F2; border-color: #FECACA; color: #991B1B;">
                <div style="font-size: 20px;">🔒</div>
                <div>
                    <div style="font-weight: 700; font-size: 14px;">Action non autorisée</div>
                    <div style="font-size: 12.5px; opacity: 0.9;">Les comptes retraités ou désactivés ne disposent pas des droits d'ajout scientifique.</div>
                </div>
            </div>
        <% } %>

        <!-- KPI SUMMARY CARDS (CONSULTATION GLOBALE ) -->
        <div class="stats-grid" style="margin-bottom: 24px;">
            <div class="stat-card">
                <div class="k">Consultation Globale</div>
                <div class="v"><%= totalPubs %></div>
                <div class="s">Total des productions indexées</div>
            </div>
            <div class="stat-card">
                <div class="k">Articles de Revues</div>
                <div class="v"><%= countArticles %></div>
                <div class="s">Revues Scopus / WoS (Q1 & Q2)</div>
            </div>
            <div class="stat-card">
                <div class="k">Actes de Conférences</div>
                <div class="v"><%= countConferences %></div>
                <div class="s">Colloques internationaux à comité</div>
            </div>
            <div class="stat-card">
                <div class="k">Ouvrages & Brevets</div>
                <div class="v"><%= countOuvrages %></div>
                <div class="s">Monographies & propriété intellectuelle</div>
            </div>
        </div>

        <!-- FORMULAIRE DE DÉCLARATION (AJOUT PAR MEMBRES ET DOCTORANTS ) -->
        <% if (canAdd) { %>
        <div id="addFormCard" class="add-form-card">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); padding-bottom: 12px; margin-bottom: 20px;">
                <h3 style="font-size: 20px; font-family: var(--font-serif); margin: 0; color: var(--navy);">
                    📝 Déclarer une nouvelle production scientifique (Membres & Doctorants)
                </h3>
                <button type="button" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--muted);" onclick="toggleAddForm()">✕</button>
            </div>

            <form action="<%= request.getContextPath() %>/publications" method="POST">
                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px; margin-bottom: 14px;">
                    <div class="form-group">
                        <label class="form-label" style="font-size: 12px; font-weight: 600;">Titre complet de la publication *</label>
                        <input type="text" name="titre" class="form-control" placeholder="ex: Deep Learning for Anomaly Detection in Scientific Clouds" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" style="font-size: 12px; font-weight: 600;">Année de publication *</label>
                        <input type="number" name="annee" class="form-control" value="2026" min="2000" max="2035" required>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1.5fr 1.5fr; gap: 16px; margin-bottom: 14px;">
                    <div class="form-group">
                        <label class="form-label" style="font-size: 12px; font-weight: 600;">Auteurs (séparés par des virgules) *</label>
                        <input type="text" name="auteurs" class="form-control" 
                                value="<%= (currentUser != null) ? (currentUser.getPrenom() + " " + currentUser.getNom()) : "" %>" 
                                placeholder="ex: Amine Alami, Ibtissam Essadiki" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" style="font-size: 12px; font-weight: 600;">Revue, Colloque ou Éditeur scientifique *</label>
                        <input type="text" name="revue" class="form-control" placeholder="ex: IEEE Internet of Things Journal / Springer Nature" required>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr 1.2fr; gap: 16px; margin-bottom: 20px;">
                    <div class="form-group">
                        <label class="form-label" style="font-size: 12px; font-weight: 600;">Type de production *</label>
                        <select name="type" class="form-control" required>
                            <option value="Article" selected>Article de Revue (Journal)</option>
                            <option value="Conférence">Actes de Conférence (Proceedings)</option>
                            <option value="Ouvrage">Chapitre d'Ouvrage / Livre</option>
                            <option value="Brevet">Brevet d'Invention</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" style="font-size: 12px; font-weight: 600;">Équipe de rattachement *</label>
                        <select name="equipe" class="form-control" required>
                            <option value="IA" selected>Équipe IA (Intelligence Artificielle & NLP)</option>
                            <option value="Big Data">Équipe Big Data & Data Science</option>
                            <option value="Sécurité">Équipe Cybersécurité & Réseaux</option>
                            <option value="Systèmes">Équipe Cloud & Systèmes Embarqués</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" style="font-size: 12px; font-weight: 600;">Identifiant numérique DOI / URL</label>
                        <input type="text" name="doi" class="form-control" placeholder="ex: 10.1109/JIOT.2026.1029">
                    </div>
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn btn-primary">Enregistrer la publication →</button>
                    <button type="button" class="btn btn-secondary" onclick="toggleAddForm()">Annuler</button>
                </div>
            </form>
        </div>
        <% } %>

        <!-- BARRE DE RECHERCHE & CLASSEMENT ÉLÉGANTE -->
        <div class="card" style="padding: 18px 22px; margin-bottom: 24px; border: 1px solid var(--border); border-radius: 12px; background: #FFFFFF; box-shadow: 0 2px 10px rgba(15,23,42,0.03);">
            
            <!-- Recherche textuelle instantanée + Tri rapide -->
            <div style="display: flex; gap: 12px; align-items: center; margin-bottom: 14px;">
                <div style="position: relative; flex: 1;">
                    <span style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #64748B; font-size: 15px;">🔍</span>
                    <input type="text" id="livePubSearch" class="form-control" 
                           placeholder="Rechercher par titre, auteur, équipe, conférence ou revue..."
                           style="padding-left: 42px; height: 44px; border-radius: 10px; font-size: 13.5px; border: 1px solid #CBD5E1; background: #F8FAFC; width: 100%; transition: all 0.2s;"
                           oninput="filterPubsInstantaneously()">
                </div>
                <div>
                    <select id="quickSortSelect" class="form-control" style="height: 44px; border-radius: 10px; font-size: 13px; font-weight: 600; color: #0F172A; min-width: 185px;" onchange="applyQuickSort(this.value)">
                        <option value="annee_desc" <%= "annee_desc".equals(selectedTri) ? "selected" : "" %>>📅 Plus récentes (2025)</option>
                        <option value="annee_asc" <%= "annee_asc".equals(selectedTri) ? "selected" : "" %>>📅 Chronologique</option>
                        <option value="auteur" <%= "auteur".equals(selectedTri) ? "selected" : "" %>>👤 Auteur (A-Z)</option>
                        <option value="equipe" <%= "equipe".equals(selectedTri) ? "selected" : "" %>>👥 Par Équipe</option>
                    </select>
                </div>
            </div>

            <!-- Filtres Rapides par Équipe & Année en 1 Clic (Pills) -->
            <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px; padding-top: 12px; border-top: 1px solid #F1F5F9;">
                <div style="display: flex; align-items: center; gap: 6px; flex-wrap: wrap;" id="pubPillFilters">
                    <span style="font-size: 11.5px; font-weight: 700; color: #64748B; margin-right: 4px; text-transform: uppercase; letter-spacing: 0.05em;">Filtres rapides :</span>
                    
                    <button type="button" class="pub-pill active" onclick="filterByPill('all', this)">Toutes</button>
                    <button type="button" class="pub-pill" onclick="filterByPill('2025', this)">2025</button>
                    <button type="button" class="pub-pill" onclick="filterByPill('2024', this)">2024</button>
                    <button type="button" class="pub-pill" onclick="filterByPill('2023', this)">2023</button>
                    
                    <span style="color: #CBD5E1; margin: 0 4px;">|</span>
                    
                    <button type="button" class="pub-pill" onclick="filterByPill('IA', this)">Équipe IA</button>
                    <button type="button" class="pub-pill" onclick="filterByPill('Big Data', this)">Big Data</button>
                    <button type="button" class="pub-pill" onclick="filterByPill('Sécurité', this)">Sécurité</button>
                    <button type="button" class="pub-pill" onclick="filterByPill('NLP', this)">NLP</button>
                </div>

                <div id="visiblePubCount" style="font-size: 12px; font-weight: 600; color: #0284C7; font-family: var(--font-mono); background: #F0F9FF; padding: 4px 10px; border-radius: 6px;">
                    <%= pubs != null ? pubs.size() : 0 %> publication(s)
                </div>
            </div>
        </div>

        <!-- LISTE DES PUBLICATIONS DU CATALOGUE -->
        <div class="table-container" style="background: var(--surface); border: 1px solid var(--border); border-radius: 4px; overflow: hidden;">
            <%
                if (pubs != null && !pubs.isEmpty()) {
                    for (Publication p : pubs) {
                        String displayType = p.getType() != null ? p.getType().replace("Conf?rence", "Conférence") : "Article";
                        String displayTeam = p.getEquipe() != null ? p.getEquipe().replace("S?curit?", "Sécurité") : "LIAS";
            %>
            <div class="pub-row">
                <div class="pub-year"><%= p.getAnnee() %></div>
                <div>
                    <h3 class="pub-title"><%= p.getTitre() %></h3>
                    <div class="pub-authors">👤 <%= p.getAuteurs() %></div>
                    <div class="pub-venue">📖 <%= p.getRevue() %></div>
                    <% if (p.getDoi() != null && !p.getDoi().isEmpty()) { %>
                        <div style="font-family: var(--font-mono); font-size: 11px; color: var(--muted); margin-top: 4px;">
                            DOI : <a href="https://doi.org/<%= p.getDoi() %>" target="_blank" style="color: var(--navy); text-decoration: none;"><code><%= p.getDoi() %></code> ↗</a>
                        </div>
                    <% } %>
                </div>
                <div style="text-align: right;">
                    <span class="badge <%= "Article".equalsIgnoreCase(displayType) ? "badge-navy" : "badge-secondary" %>">
                        <%= displayType %>
                    </span>
                    <div style="font-family: var(--font-mono); font-size: 11px; color: var(--accent-2); font-weight: 700; margin-top: 6px;">
                        Équipe <%= displayTeam %>
                    </div>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <div style="padding: 48px 24px; text-align: center; color: var(--muted); font-size: 14px;">
                🔍 Aucune publication ne correspond à ces critères de recherche et classement.
                <div style="margin-top: 10px;">
                    <a href="<%= request.getContextPath() %>/publications" class="btn btn-secondary btn-sm">Réinitialiser les filtres</a>
                </div>
            </div>
            <% } %>
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
        function toggleAddForm() {
            var f = document.getElementById('addFormCard');
            if (f) {
                f.style.display = f.style.display === 'block' ? 'none' : 'block';
                if (f.style.display === 'block') {
                    f.scrollIntoView({ behavior: 'smooth' });
                }
            }
        }

        var currentActivePill = 'all';

        function filterPubsInstantaneously() {
            var input = document.getElementById('livePubSearch');
            var query = input ? input.value.toLowerCase().trim() : '';
            var rows = document.querySelectorAll('.pub-row');
            var visibleCount = 0;

            rows.forEach(function(row) {
                var text = row.innerText.toLowerCase();
                var matchesQuery = !query || text.indexOf(query) !== -1;
                var matchesPill = true;

                if (currentActivePill !== 'all') {
                    matchesPill = text.indexOf(currentActivePill.toLowerCase()) !== -1;
                }

                if (matchesQuery && matchesPill) {
                    row.style.display = 'grid';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });

            var countBadge = document.getElementById('visiblePubCount');
            if (countBadge) {
                countBadge.textContent = visibleCount + ' publication(s)';
            }
        }

        function filterByPill(filterVal, btn) {
            currentActivePill = filterVal;
            var pills = document.querySelectorAll('.pub-pill');
            pills.forEach(function(p) { p.classList.remove('active'); });
            if (btn) btn.classList.add('active');
            filterPubsInstantaneously();
        }

        function applyQuickSort(sortVal) {
            window.location.href = '<%= request.getContextPath() %>/publications?tri=' + encodeURIComponent(sortVal);
        }
    </script>
</body>
</html>

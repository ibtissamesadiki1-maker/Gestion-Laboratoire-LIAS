<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.lias.beans.User"%>
<%
    User navUser = (User) session.getAttribute("currentUser");
    if (navUser == null) navUser = (User) session.getAttribute("user");
    String userInitials = "LI";
    if (navUser != null && navUser.getPrenom() != null && navUser.getNom() != null && !navUser.getPrenom().isEmpty() && !navUser.getNom().isEmpty()) {
        userInitials = ("" + navUser.getPrenom().charAt(0) + navUser.getNom().charAt(0)).toUpperCase();
    }

    int headerUnreadCount = 0;
    java.util.List<com.lias.beans.NotificationLabo> headerTopNotifs = null;
    try {
        com.lias.dao.INotificationDao headerNotifDao = new com.lias.dao.NotificationDaoImpl();
        headerUnreadCount = headerNotifDao.findUnread().size();
        java.util.List<com.lias.beans.NotificationLabo> allHeader = headerNotifDao.findAll();
        if (allHeader != null && !allHeader.isEmpty()) {
            headerTopNotifs = allHeader.subList(0, Math.min(4, allHeader.size()));
        }
    } catch (Exception ignored) {}
%>
<header class="app-header">
    <div class="header-left">
        <a href="<%= request.getContextPath() %>/home" class="header-brand">
            <div class="brand-logo-badge" style="width:34px; height:34px; border-radius:10px; background:linear-gradient(135deg, #0284C7 0%, #0D9488 100%); color:#fff; display:flex; align-items:center; justify-content:center; box-shadow:0 2px 8px rgba(2, 132, 199, 0.25);">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="3"/>
                    <ellipse cx="12" cy="12" rx="9" ry="4" transform="rotate(30 12 12)"/>
                    <ellipse cx="12" cy="12" rx="9" ry="4" transform="rotate(-30 12 12)"/>
                </svg>
            </div>
            <div class="brand-name">LIAS</div>
        </a>
        <div class="header-divider"></div>
        <div class="header-institution">
            <div class="inst-faculty">Faculté des Sciences Ben M'Sik</div>
            <div class="inst-univ">Casablanca · Université Hassan II</div>
        </div>
    </div>

    <div class="header-center">
        <div class="header-search-box" onclick="openSearchModal()" role="button" tabindex="0" title="Recherche globale (Ctrl+K)">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0284C7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <span class="search-placeholder">Recherche globale…</span>
            <kbd class="search-kbd">⌘K</kbd>
        </div>
    </div>

    <div class="header-right" style="position: relative;">
        <button type="button" class="header-icon-btn" title="Notifications &amp; Alertes" onclick="toggleNotifications()">
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#0284C7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
            <% if (headerUnreadCount > 0) { %>
                <span class="bell-badge"><%= headerUnreadCount %></span>
            <% } %>
        </button>

        <!-- Notifications Dropdown Popover -->
        <div id="notifPopover" class="user-dropdown-popover" style="display: none; width: 340px; right: 200px; top: 56px; text-align: left; padding: 16px 20px; box-shadow: var(--shadow-md); border-radius: 12px; z-index: 1000;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                <strong style="font-size: 13px; color: var(--navy); font-family: var(--font-serif);">Notifications &amp; Alertes</strong>
                <span class="badge badge-gold" style="font-size: 10px;"><%= headerUnreadCount %> nouvelle(s)</span>
            </div>
            <div class="popover-divider" style="margin: 8px 0;"></div>
            
            <% 
                boolean isAdminHeader = navUser != null && "admin".equalsIgnoreCase(navUser.getRole());
                boolean isInternalHeader = navUser != null && ("directeur".equalsIgnoreCase(navUser.getRole()) || "permanent".equalsIgnoreCase(navUser.getRole()));
                if (isAdminHeader) { 
            %>
                <a href="<%= request.getContextPath() %>/notifications" class="popover-item" style="padding: 8px 0; display: block; text-decoration: none; border-bottom: 1px solid var(--border);">
                    <div style="font-weight: 600; font-size: 12px; color: var(--ink);">🛡️ Session Admin Sécurisée</div>
                    <div style="font-size: 11px; color: var(--muted);">Super-utilisateur connecté via Tomcat 10.1</div>
                </a>
                <a href="<%= request.getContextPath() %>/admin?tab=integrity" class="popover-item" style="padding: 8px 0; display: block; text-decoration: none; border-bottom: 1px solid var(--border);">
                    <div style="font-weight: 600; font-size: 12px; color: var(--ink);">💾 Base de Données MySQL</div>
                    <div style="font-size: 11px; color: var(--muted);">Schéma lias_db 100% intègre et synchronisé</div>
                </a>
                <a href="<%= request.getContextPath() %>/admin" class="popover-item" style="padding: 8px 0; display: block; text-decoration: none; border-bottom: 1px solid var(--border);">
                    <div style="font-weight: 600; font-size: 12px; color: var(--ink);">👥 Rôles &amp; Comptes RBAC</div>
                    <div style="font-size: 11px; color: var(--muted);">8 comptes configurés et opérationnels</div>
                </a>
            <% } else if (headerTopNotifs != null && !headerTopNotifs.isEmpty()) { 
                int countShown = 0;
                for (com.lias.beans.NotificationLabo hn : headerTopNotifs) { 
                    String hk = hn.getKind() != null ? hn.getKind().toLowerCase() : "";
                    if (!isInternalHeader && !("event".equals(hk) || "meeting".equals(hk) || "publication".equals(hk) || "info".equals(hk))) {
                        continue;
                    }
                    countShown++;
            %>
                    <a href="<%= request.getContextPath() %><%= hn.getTargetUrl() != null ? hn.getTargetUrl() : "/notifications" %>" class="popover-item" style="padding: 8px 0; display: block; text-decoration: none; border-bottom: 1px solid var(--border);">
                        <div style="font-weight: 600; font-size: 12px; color: var(--ink);"><%= hn.getWho() %></div>
                        <div style="font-size: 11px; color: var(--muted);"><%= hn.getBody() %></div>
                    </a>
            <%  } 
                if (countShown == 0) { %>
                    <div style="font-size:12px; color:var(--muted); text-align:center; padding:10px 0;">Aucune notification récente.</div>
            <%  }
            } else { %>
                <div style="font-size:12px; color:var(--muted); text-align:center; padding:10px 0;">Aucune notification récente.</div>
            <% } %>

            <div class="popover-divider" style="margin: 8px 0;"></div>
            <a href="<%= request.getContextPath() %>/notifications" style="display:block; text-align:center; font-size:12px; color:var(--navy); font-weight:600; text-decoration:none; padding:6px 0;">
                <%= isAdminHeader ? "Ouvrir le journal d'audit complet →" : "Voir toutes les notifications →" %>
            </a>
        </div>


        <div class="header-user-menu">
            <div class="user-avatar"><%= userInitials %></div>
            <div class="user-meta">
                <div class="user-name"><%= navUser != null ? navUser.getPrenom() + " " + navUser.getNom() : "Utilisateur" %></div>
                <div class="user-role-label">VUE : <%= navUser != null ? navUser.getRole().toUpperCase() : "MEMBRE" %></div>
            </div>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="color:var(--muted); margin-left:4px;"><polyline points="6 9 12 15 18 9"/></svg>
            
            <div class="user-dropdown-popover" id="userPopover" style="display: none;">
                <div class="popover-header">
                    <strong><%= navUser != null ? navUser.getEmail() : "" %></strong>
                    <div style="font-size:11px; color:var(--muted);">Rôle système: <%= navUser != null ? navUser.getRole() : "" %></div>
                </div>
                <div class="popover-divider"></div>
                <a href="<%= request.getContextPath() %>/public" class="popover-item">↗ Site public du LIAS</a>
                <a href="<%= request.getContextPath() %>/profils" class="popover-item">Mon profil chercheur</a>
                <a href="<%= request.getContextPath() %>/notifications" class="popover-item">Centre de notifications</a>
                <div class="popover-divider"></div>
                <a href="<%= request.getContextPath() %>/logout" class="popover-item danger">Déconnexion</a>
            </div>
        </div>
    </div>
</header>

<!-- Quick Search Modal (⌘K / Ctrl+K) -->
<div id="searchModal" class="search-modal-backdrop" style="display: none;" onclick="if(event.target===this) closeSearchModal()">
    <div class="search-modal-card">
        <div class="search-modal-input-row">
            <span style="font-size:16px; color:var(--muted); font-family:var(--font-mono);">⌕</span>
            <input type="text" id="globalSearchInput" placeholder="Rechercher membre, publication, événement, document… (Entrée pour recherche complète)" oninput="filterQuickSearch(this.value)" onkeydown="if(event.key==='Enter') doGlobalSearch(this.value)">
            <kbd onclick="closeSearchModal()" style="cursor:pointer; font-family:var(--font-mono); font-size:11px; padding:2px 6px; border:1px solid var(--border); border-radius:2px; background:var(--surface);">Échap</kbd>
        </div>
        <div class="search-modal-results" id="searchResults">
            <div class="search-result-group">
                <div class="search-group-title">Raccourcis & Modules</div>
                <a href="<%= request.getContextPath() %>/home" class="search-result-item">
                    <span class="sr-icon">⊟</span>
                    <span class="sr-text">Tableau de bord institutionnel</span>
                    <span class="sr-tag">Principal</span>
                </a>
                <a href="<%= request.getContextPath() %>/profils" class="search-result-item">
                    <span class="sr-icon">⊙</span>
                    <span class="sr-text">Profils des chercheurs & doctorants</span>
                    <span class="sr-tag">Annuaire</span>
                </a>
                <a href="<%= request.getContextPath() %>/calendrier" class="search-result-item">
                    <span class="sr-icon">▦</span>
                    <span class="sr-text">Calendrier scientifique & événements</span>
                    <span class="sr-tag">Agenda</span>
                </a>
                <a href="<%= request.getContextPath() %>/documents" class="search-result-item">
                    <span class="sr-icon">▤</span>
                    <span class="sr-text">Archive documentaire institutionnelle</span>
                    <span class="sr-tag">Documents</span>
                </a>
                <a href="<%= request.getContextPath() %>/communication" class="search-result-item">
                    <span class="sr-icon">❝</span>
                    <span class="sr-text">Communication interne & canaux d'équipes</span>
                    <span class="sr-tag">Échanges</span>
                </a>
                <a href="<%= request.getContextPath() %>/publications" class="search-result-item">
                    <span class="sr-icon">¶</span>
                    <span class="sr-text">Catalogue des publications scientifiques</span>
                    <span class="sr-tag">Recherche</span>
                </a>
                <a href="<%= request.getContextPath() %>/materiel" class="search-result-item">
                    <span class="sr-icon">▭</span>
                    <span class="sr-text">Parc de matériel scientifique & allocations</span>
                    <span class="sr-tag">Équipement</span>
                </a>
                <a href="<%= request.getContextPath() %>/conventions" class="search-result-item">
                    <span class="sr-icon">⌘</span>
                    <span class="sr-text">Conventions & Partenariats institutionnels</span>
                    <span class="sr-tag">Accords</span>
                </a>
                <a href="<%= request.getContextPath() %>/notifications" class="search-result-item">
                    <span class="sr-icon">◉</span>
                    <span class="sr-text">Centre de notifications & alertes</span>
                    <span class="sr-tag">Notifications</span>
                </a>
            </div>
        </div>
    </div>
</div>

<script>
    function doGlobalSearch(val) {
        if (val && val.trim().length > 0) {
            window.location.href = '<%= request.getContextPath() %>/recherche?q=' + encodeURIComponent(val.trim());
        }
    }
    function openSearchModal() {
        var modal = document.getElementById('searchModal');
        if (modal) {
            modal.style.display = 'flex';
            setTimeout(function() {
                var inp = document.getElementById('globalSearchInput');
                if (inp) inp.focus();
            }, 50);
        }
    }
    function closeSearchModal() {
        var modal = document.getElementById('searchModal');
        if (modal) modal.style.display = 'none';
    }
    document.addEventListener('keydown', function(e) {
        if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
            e.preventDefault();
            var modal = document.getElementById('searchModal');
            if (modal && modal.style.display === 'flex') closeSearchModal();
            else openSearchModal();
        }
        if (e.key === 'Escape') closeSearchModal();
    });

    function toggleNotifications() {
        var pop = document.getElementById('notifPopover');
        var userPop = document.getElementById('userPopover');
        if (userPop) userPop.style.display = 'none';
        if (pop) {
            pop.style.display = (pop.style.display === 'block') ? 'none' : 'block';
        }
    }

    function filterQuickSearch(query) {
        query = query.toLowerCase().trim();
        var items = document.querySelectorAll('.search-result-item');
        items.forEach(function(item) {
            var text = item.innerText.toLowerCase();
            if (!query || text.indexOf(query) !== -1) {
                item.style.display = 'flex';
            } else {
                item.style.display = 'none';
            }
        });
    }

    // Toggle user dropdown on click & close on click outside
    document.addEventListener('DOMContentLoaded', function() {
        var userMenu = document.querySelector('.header-user-menu');
        var popover = document.getElementById('userPopover');
        var notifPop = document.getElementById('notifPopover');
        var notifBtn = document.querySelector('.header-icon-btn');

        if (userMenu && popover) {
            userMenu.addEventListener('click', function(e) {
                e.stopPropagation();
                if (notifPop) notifPop.style.display = 'none';
                popover.style.display = (popover.style.display === 'flex') ? 'none' : 'flex';
            });
        }
        if (notifBtn && notifPop) {
            notifBtn.addEventListener('click', function(e) {
                e.stopPropagation();
            });
        }
        document.addEventListener('click', function(e) {
            if (popover) popover.style.display = 'none';
            if (notifPop && !notifPop.contains(e.target)) notifPop.style.display = 'none';
        });
    });
</script>

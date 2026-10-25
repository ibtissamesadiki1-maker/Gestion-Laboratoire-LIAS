<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.Evenement"%>
<%@ page import="com.lias.beans.ReunionPV"%>
<%@ page import="com.lias.beans.User"%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    List<Evenement> evenements = (List<Evenement>) request.getAttribute("evenements");
    List<ReunionPV> pvs = (List<ReunionPV>) request.getAttribute("pvs");

    Integer initYear = (Integer) request.getAttribute("initialYear");
    if (initYear == null) initYear = 2026;
    Integer initMonth = (Integer) request.getAttribute("initialMonth");
    if (initMonth == null) initMonth = 8; // Septembre
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Calendrier Scientifique & Navigation Temporelle</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        .cal-nav-btn {
            background: #FFFFFF;
            border: 1px solid var(--border-color, #E2E8F0);
            color: var(--navy-primary, #0F172A);
            width: 38px;
            height: 38px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            cursor: pointer;
            border-radius: 8px;
            transition: all 0.15s ease;
        }
        .cal-nav-btn:hover {
            background: #0284C7;
            color: #FFFFFF;
            border-color: #0284C7;
        }
        .cal-grid-table {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            border: 1px solid var(--border-color, #E2E8F0);
            border-radius: 14px;
            overflow: hidden;
            background: #FFFFFF;
            box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.05);
        }
        .cal-header-cell {
            padding: 14px 14px;
            background: #F8FAFC;
            border-bottom: 1px solid var(--border-color, #E2E8F0);
            font-family: var(--font-sans, 'Inter', sans-serif);
            font-size: 11.5px;
            letter-spacing: 0.08em;
            color: #64748B;
            text-transform: uppercase;
            text-align: center;
            font-weight: 700;
        }
        .cal-day-cell {
            min-height: 125px;
            padding: 10px 8px;
            border-right: 1px solid var(--border-color, #E2E8F0);
            border-bottom: 1px solid var(--border-color, #E2E8F0);
            background: #FFFFFF;
            position: relative;
            transition: background 0.12s ease;
        }
        .cal-day-cell:nth-child(7n) {
            border-right: none;
        }
        .cal-day-cell.other-month {
            background: #F8FAFC;
            opacity: 0.45;
        }
        .cal-day-cell.is-today {
            background: #F0F9FF;
        }
        .cal-day-number {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            font-family: var(--font-sans, 'Inter', sans-serif);
            font-size: 13px;
            color: #0F172A;
            border-radius: 50%;
            margin-bottom: 6px;
            font-weight: 700;
        }
        .cal-day-cell.is-today .cal-day-number {
            background: #0284C7;
            color: #FFFFFF;
        }
        .cal-event-pill {
            display: block;
            margin-bottom: 5px;
            padding: 5px 8px;
            border-radius: 6px;
            font-size: 11px;
            line-height: 1.3;
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #FFFFFF;
            text-decoration: none;
            cursor: pointer;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            box-shadow: 0 1px 2px rgba(0,0,0,0.08);
            transition: transform 0.12s ease, box-shadow 0.12s ease;
        }
        .cal-event-pill:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.12);
        }
        .pill-conference { background: #0F172A; }
        .pill-seminaire { background: #0284C7; }
        .pill-workshop { background: #059669; }
        .pill-pv { background: #7C3AED; }
        .pill-autre { background: #475569; }

        .legend-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
        }
    </style>
</head>
<body>

<% if (currentUser == null) { %>
    <%@ include file="includes/navbar.jsp" %>
    <div class="container" style="max-width: 1200px; margin: 0 auto; padding: 40px 24px;">
<% } else { %>
<div class="app-shell">
    <%@ include file="includes/app_header.jsp" %>
    <div class="app-body">
        <%@ include file="includes/sidebar.jsp" %>
        <main class="app-main">
            <div class="app-content">
<% } %>

        <!-- En-tête de page -->
        <div class="page-header" style="margin-bottom: 24px;">
            <div>
                <span class="eyebrow" style="color:var(--gold-accent); font-weight:700;">Vie Scientifique & Temporalité</span>
                <h1 class="page-title">Calendrier Scientifique & Temporalité</h1>
                <p class="page-sub">
                    Visualisation chronologique unifiée de toutes les manifestations, conférences, séminaires, workshops et délibérations statutaires du laboratoire LIAS.
                </p>
            </div>
            <div style="display: flex; gap: 10px; align-items: center; flex-wrap:wrap;">
                <button type="button" class="btn btn-secondary" onclick="setToday()">Aujourd'hui</button>
                <div style="display: inline-flex; border: 1px solid var(--border-color); border-radius: 4px; overflow: hidden;">
                    <button type="button" id="btnVueMois" class="btn btn-sm btn-primary" onclick="switchView('mois')" style="border-radius:0;">Vue Grille</button>
                    <button type="button" id="btnVueAgenda" class="btn btn-sm btn-secondary" onclick="switchView('agenda')" style="border-radius:0;">Vue Agenda</button>
                </div>
                <% if (currentUser != null) { %>
                    <a href="<%= request.getContextPath() %>/evenements" class="btn btn-primary">+ Planifier Événement</a>
                <% } %>
            </div>
        </div>

        <!-- BARRE DE NAVIGATION TEMPORELLE -->
        <div class="card" style="padding: 16px 20px; margin-bottom: 20px; background: #FFF;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                
                <!-- Commandes de navigation temporelle -->
                <div style="display: flex; align-items: center; gap: 12px;">
                    <button type="button" class="cal-nav-btn" onclick="changeMonth(-1)" title="Mois précédent">←</button>
                    
                    <h2 id="calendarTitle" style="font-family: var(--font-serif); font-size: 24px; font-weight: 700; color: var(--navy-primary); margin: 0; min-width: 200px; text-transform: capitalize;">
                        Septembre 2026
                    </h2>

                    <button type="button" class="cal-nav-btn" onclick="changeMonth(1)" title="Mois suivant">→</button>

                    <!-- Sélecteurs de saut temporel direct -->
                    <div style="display: flex; gap: 6px; margin-left: 10px;">
                        <select id="jumpMonth" onchange="jumpToSelected()" class="form-control" style="padding: 4px 8px; font-size: 13px; width: 120px;">
                            <option value="0">Janvier</option>
                            <option value="1">Février</option>
                            <option value="2">Mars</option>
                            <option value="3">Avril</option>
                            <option value="4">Mai</option>
                            <option value="5">Juin</option>
                            <option value="6">Juillet</option>
                            <option value="7">Août</option>
                            <option value="8" selected>Septembre</option>
                            <option value="9">Octobre</option>
                            <option value="10">Novembre</option>
                            <option value="11">Décembre</option>
                        </select>

                        <select id="jumpYear" onchange="jumpToSelected()" class="form-control" style="padding: 4px 8px; font-size: 13px; width: 90px;">
                            <option value="2024">2024</option>
                            <option value="2025">2025</option>
                            <option value="2026" selected>2026</option>
                            <option value="2027">2027</option>
                            <option value="2028">2028</option>
                        </select>
                    </div>
                </div>

                <!-- Légende des couleurs -->
                <div style="display: flex; gap: 14px; align-items: center; font-size: 12.5px; color: var(--text-muted); flex-wrap: wrap;">
                    <div style="display: flex; align-items: center; gap: 6px;">
                        <span class="legend-dot" style="background: #0B192C;"></span>
                        <span>Conférence</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 6px;">
                        <span class="legend-dot" style="background: #B08838;"></span>
                        <span>Séminaire</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 6px;">
                        <span class="legend-dot" style="background: #15803D;"></span>
                        <span>Workshop</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 6px;">
                        <span class="legend-dot" style="background: #6D28D9;"></span>
                        <span>Conseil / PV</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- VUE 1 : GRILLE MENSUELLE -->
        <div id="calendarMonthView">
            <div class="cal-grid-table">
                <div class="cal-header-cell">Lundi</div>
                <div class="cal-header-cell">Mardi</div>
                <div class="cal-header-cell">Mercredi</div>
                <div class="cal-header-cell">Jeudi</div>
                <div class="cal-header-cell">Vendredi</div>
                <div class="cal-header-cell">Samedi</div>
                <div class="cal-header-cell">Dimanche</div>

                <div id="calendarGridDays" style="display: contents;">
                    <!-- Cellules générées dynamiquement -->
                </div>
            </div>
        </div>

        <!-- VUE 2 : LISTE AGENDA CHRONOLOGIQUE -->
        <div id="calendarAgendaView" style="display: none;">
            <div class="card" style="padding: 24px;">
                <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 16px; color: var(--navy-primary);">
                    Agenda Chronologique des Événements & Délibérations
                </h3>
                <div id="agendaListContent">
                    <!-- Rempli en JS -->
                </div>
            </div>
        </div>

        <!-- MODAL DÉTAILS DE L'ÉVÉNEMENT -->
        <div id="eventModal" style="display:none; position: fixed; inset: 0; background: rgba(11,25,44,0.6); backdrop-filter: blur(3px); z-index: 99999; align-items: center; justify-content: center; padding: 20px;">
            <div class="card" style="max-width: 540px; width: 100%; padding: 28px; background: #FFF; border-radius: 8px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2); position: relative;">
                <button type="button" onclick="closeEventModal()" style="position: absolute; top: 16px; right: 16px; background: none; border: none; font-size: 24px; cursor: pointer; color: var(--text-muted);">&times;</button>
                
                <span id="modalTypeBadge" class="badge" style="background:#EEF2FF; color:#4338CA; border:1px solid #C7D2FE; margin-bottom: 10px; font-weight: 700; text-transform: uppercase;">
                    Conférence
                </span>
                
                <h3 id="modalEventTitle" style="font-size: 19px; font-weight: 800; color: var(--navy-primary); margin: 6px 0 14px; line-height: 1.4;">
                    Titre de l'événement
                </h3>

                <div style="font-size: 13.5px; color: var(--text-color); margin-bottom: 16px; line-height: 1.6; background: #F8FAFC; padding: 14px; border-radius: 6px; border: 1px solid var(--border-color);">
                    <p style="margin: 0 0 6px;">📅 <strong>Date :</strong> <span id="modalEventDate">2026-09-15</span></p>
                    <p style="margin: 0 0 6px;">📍 <strong>Lieu / Salle :</strong> <span id="modalEventLieu">Amphithéâtre FSBM</span></p>
                    <p style="margin: 0;">👤 <strong>Responsable / Organisateur :</strong> <span id="modalEventOrg">Direction LIAS</span></p>
                </div>

                <div style="padding: 14px; border-radius: 6px; font-size: 13px; color: var(--text-color); line-height: 1.6; margin-bottom: 20px; border: 1px solid var(--border-color); background: #FFF;">
                    <strong style="display: block; margin-bottom: 4px; color: var(--navy-primary);">Description & Ordre du Jour :</strong>
                    <div id="modalEventDesc" style="white-space: pre-line;">Détails de la manifestation...</div>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px;">
                    <button type="button" class="btn btn-secondary" onclick="closeEventModal()">Fermer</button>
                    <a id="modalActionLink" href="<%= request.getContextPath() %>/evenements" class="btn btn-primary">
                        Consulter détails complets →
                    </a>
                </div>
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

<!-- Données JSON des Événements & Réunions PV du laboratoire -->
<script>
    var labEvents = [
        <%
            // 1. Événements scientifiques (Conférences, Séminaires, Workshops)
            if (evenements != null) {
                for (int i = 0; i < evenements.size(); i++) {
                    Evenement e = evenements.get(i);
        %>
        {
            id: <%= e.getId() %>,
            title: "<%= e.getTitre() != null ? e.getTitre().replace("\"", "\\\"") : "" %>",
            type: "<%= e.getType() != null ? e.getType() : "Séminaire" %>",
            date: "<%= e.getDate() != null ? e.getDate() : "" %>",
            lieu: "<%= e.getLieu() != null ? e.getLieu().replace("\"", "\\\"") : "FSBM Casablanca" %>",
            organisateur: "<%= e.getOrganisateur() != null ? e.getOrganisateur().replace("\"", "\\\"") : "LIAS" %>",
            description: "<%= e.getDescription() != null ? e.getDescription().replace("\"", "\\\"").replace("\n", " ") : "" %>",
            source: "evenement"
        },
        <%
                }
            }

            // 2. Délibérations et réunions officielles (Conseils de Laboratoire, AG, CE)
            if (pvs != null) {
                for (int j = 0; j < pvs.size(); j++) {
                    ReunionPV pv = pvs.get(j);
        %>
        {
            id: <%= pv.getId() %>,
            title: "<%= pv.getTitre() != null ? pv.getTitre().replace("\"", "\\\"") : "" %>",
            type: "<%= pv.getTypeReunion() != null ? pv.getTypeReunion() : "Conseil de Laboratoire" %>",
            date: "<%= pv.getDateReunion() != null ? pv.getDateReunion().toString() : "" %>",
            lieu: "<%= pv.getLieu() != null ? pv.getLieu().replace("\"", "\\\"") : "Salle LIAS - FSBM" %>",
            organisateur: "<%= pv.getDirecteurSignataire() != null ? pv.getDirecteurSignataire().replace("\"", "\\\"") : "Prof. Ibtissam Essadiki" %>",
            description: "Ordre du jour :\n<%= pv.getOrdreDuJour() != null ? pv.getOrdreDuJour().replace("\"", "\\\"").replace("\n", "\\n") : "" %>",
            source: "pv"
        }<%= (j < pvs.size() - 1) ? "," : "" %>
        <%
                }
            }
        %>
    ];

    var currentYear = <%= initYear %>;
    var currentMonth = <%= initMonth %>; // 0-indexed : 8 = Septembre

    var monthNames = [
        "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
        "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];

    function renderCalendar() {
        var titleEl = document.getElementById("calendarTitle");
        titleEl.innerText = monthNames[currentMonth] + " " + currentYear;

        // Mettre à jour les sélecteurs de saut direct
        var selM = document.getElementById("jumpMonth");
        if (selM) selM.value = currentMonth;
        var selY = document.getElementById("jumpYear");
        if (selY) selY.value = currentYear;

        var gridDaysEl = document.getElementById("calendarGridDays");
        gridDaysEl.innerHTML = "";

        var firstDayDate = new Date(currentYear, currentMonth, 1);
        var startDay = (firstDayDate.getDay() + 6) % 7; // Lundi = 0
        var daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
        var daysInPrevMonth = new Date(currentYear, currentMonth, 0).getDate();

        var today = new Date();
        var isCurrentRealMonth = (today.getFullYear() === currentYear && today.getMonth() === currentMonth);
        var realTodayDate = today.getDate();

        // 1. Jours du mois précédent
        for (var i = startDay - 1; i >= 0; i--) {
            var prevD = daysInPrevMonth - i;
            var cell = document.createElement("div");
            cell.className = "cal-day-cell other-month";
            cell.innerHTML = '<span class="cal-day-number">' + prevD + '</span>';
            gridDaysEl.appendChild(cell);
        }

        // 2. Jours du mois courant
        var monthEventsList = [];
        for (var d = 1; d <= daysInMonth; d++) {
            var cell = document.createElement("div");
            var isTodayCell = (isCurrentRealMonth && d === realTodayDate);
            cell.className = "cal-day-cell" + (isTodayCell ? " is-today" : "");

            var dateStr = currentYear + "-" + String(currentMonth + 1).padStart(2, '0') + "-" + String(d).padStart(2, '0');
            var dayHtml = '<span class="cal-day-number">' + d + '</span>';

            // Filtrer les événements et réunions de ce jour
            var dayEvts = labEvents.filter(function(ev) {
                return ev.date === dateStr;
            });

            dayEvts.forEach(function(ev) {
                monthEventsList.push(ev);
                var pillClass = "pill-seminaire";
                var t = (ev.type || "").toLowerCase();
                if (ev.source === "pv" || t.indexOf("conseil") !== -1 || t.indexOf("assembl") !== -1) {
                    pillClass = "pill-pv";
                } else if (t.indexOf("conf") !== -1) {
                    pillClass = "pill-conference";
                } else if (t.indexOf("work") !== -1 || t.indexOf("atelier") !== -1) {
                    pillClass = "pill-workshop";
                }

                dayHtml += '<div class="cal-event-pill ' + pillClass + '" onclick="showEventModal(\'' + ev.id + '\', \'' + ev.source + '\')" title="' + ev.title + '">' +
                           ev.title + '</div>';
            });

            cell.innerHTML = dayHtml;
            gridDaysEl.appendChild(cell);
        }

        // 3. Jours du mois suivant
        var totalCells = startDay + daysInMonth;
        var nextDays = (7 - (totalCells % 7)) % 7;
        for (var n = 1; n <= nextDays; n++) {
            var cell = document.createElement("div");
            cell.className = "cal-day-cell other-month";
            cell.innerHTML = '<span class="cal-day-number">' + n + '</span>';
            gridDaysEl.appendChild(cell);
        }

        // Remplir l'agenda chronologique
        var agendaListEl = document.getElementById("agendaListContent");
        if (monthEventsList.length === 0) {
            agendaListEl.innerHTML = '<p style="color:var(--text-muted); font-size:14px; text-align:center; padding:32px 0;">Aucun événement ou réunion programmé pour ce mois.</p>';
        } else {
            var agHtml = '<div style="display:flex; flex-direction:column; gap:12px;">';
            monthEventsList.forEach(function(ev) {
                var badgeBg = "#EEF2FF";
                var badgeColor = "#4338CA";
                if (ev.source === "pv") {
                    badgeBg = "#F5F3FF";
                    badgeColor = "#6D28D9";
                }
                agHtml += '<div class="card" style="padding:16px 20px; display:flex; justify-content:space-between; align-items:center; cursor:pointer; border:1px solid var(--border-color);" onclick="showEventModal(\'' + ev.id + '\', \'' + ev.source + '\')">' +
                          '<div><strong style="font-size:15px; color:var(--navy-primary);">' + ev.title + '</strong>' +
                          '<div style="font-size:12px; color:var(--text-muted); margin-top:4px;">📍 ' + ev.lieu + ' · 👤 ' + ev.organisateur + '</div></div>' +
                          '<div style="text-align:right;"><span class="badge" style="background:' + badgeBg + '; color:' + badgeColor + '; font-weight:700;">' + ev.date + '</span><div style="font-size:11.5px; color:var(--text-muted); margin-top:4px;">' + ev.type + '</div></div>' +
                          '</div>';
            });
            agHtml += '</div>';
            agendaListEl.innerHTML = agHtml;
        }
    }

    function changeMonth(delta) {
        currentMonth += delta;
        if (currentMonth < 0) {
            currentMonth = 11;
            currentYear--;
        } else if (currentMonth > 11) {
            currentMonth = 0;
            currentYear++;
        }
        renderCalendar();
    }

    function jumpToSelected() {
        var selM = document.getElementById("jumpMonth");
        var selY = document.getElementById("jumpYear");
        if (selM && selY) {
            currentMonth = parseInt(selM.value);
            currentYear = parseInt(selY.value);
            renderCalendar();
        }
    }

    function setToday() {
        var now = new Date();
        currentYear = now.getFullYear();
        currentMonth = now.getMonth();
        renderCalendar();
    }

    function switchView(view) {
        var m = document.getElementById("calendarMonthView");
        var a = document.getElementById("calendarAgendaView");
        var bm = document.getElementById("btnVueMois");
        var ba = document.getElementById("btnVueAgenda");

        if (view === 'mois') {
            m.style.display = "block";
            a.style.display = "none";
            bm.className = "btn btn-sm btn-primary";
            ba.className = "btn btn-sm btn-secondary";
        } else {
            m.style.display = "none";
            a.style.display = "block";
            bm.className = "btn btn-sm btn-secondary";
            ba.className = "btn btn-sm btn-primary";
        }
    }

    function showEventModal(id, source) {
        var ev = labEvents.find(function(e) { return String(e.id) === String(id) && e.source === source; });
        if (!ev) return;

        document.getElementById("modalEventTitle").innerText = ev.title;
        document.getElementById("modalTypeBadge").innerText = ev.type;
        document.getElementById("modalEventDate").innerText = ev.date;
        document.getElementById("modalEventLieu").innerText = ev.lieu;
        document.getElementById("modalEventOrg").innerText = ev.organisateur;
        document.getElementById("modalEventDesc").innerText = ev.description || "Aucune description détaillée renseignée.";

        var link = document.getElementById("modalActionLink");
        if (link) {
            if (ev.source === "pv") {
                link.href = "<%= request.getContextPath() %>/pv";
                link.innerText = "Consulter dans le Registre PV →";
            } else {
                link.href = "<%= request.getContextPath() %>/evenements";
                link.innerText = "Consulter dans les Événements →";
            }
        }

        var modal = document.getElementById("eventModal");
        modal.style.display = "flex";
    }

    function closeEventModal() {
        document.getElementById("eventModal").style.display = "none";
    }

    document.addEventListener("DOMContentLoaded", function() {
        renderCalendar();
    });
</script>

</body>
</html>

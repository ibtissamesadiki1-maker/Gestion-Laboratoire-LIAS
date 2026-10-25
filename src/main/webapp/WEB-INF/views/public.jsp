<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.lias.beans.Publication"%>
<%@ page import="com.lias.beans.Evenement"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Laboratoire d'Informatique &amp; Applications Scientifiques</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        /* Modern Hero Showcase */
        .hero-modern-wrap {
            padding: 80px 40px 60px;
            max-width: 1280px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1.25fr 1fr;
            gap: 60px;
            align-items: center;
        }

        .hero-badge-pill {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 7px 18px;
            background: #FFFFFF;
            border: 1px solid #BAE6FD;
            border-radius: 9999px;
            font-family: var(--font-sans);
            font-size: 12.5px;
            font-weight: 600;
            color: #0369A1;
            box-shadow: 0 4px 12px rgba(2, 132, 199, 0.08);
            margin-bottom: 24px;
        }

        .pulse-beacon {
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background: #10B981;
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
            animation: beaconPulse 2s infinite;
        }

        @keyframes beaconPulse {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        .hero-modern-title {
            font-family: var(--font-serif);
            font-size: 56px;
            font-weight: 800;
            line-height: 1.1;
            letter-spacing: -0.035em;
            color: #0F172A;
            margin: 0 0 20px;
        }

        .hero-modern-title .highlight {
            background: linear-gradient(135deg, #0284C7 0%, #0D9488 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero-modern-desc {
            font-size: 17px;
            line-height: 1.65;
            color: #475569;
            margin: 0 0 32px;
            max-width: 600px;
        }

        .hero-actions-row {
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 36px;
        }

        .btn-modern-primary {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 13px 26px;
            background: linear-gradient(135deg, #0284C7 0%, #0D9488 100%);
            color: #FFFFFF !important;
            font-weight: 600;
            font-size: 14.5px;
            border-radius: 12px;
            text-decoration: none !important;
            box-shadow: 0 4px 16px rgba(2, 132, 199, 0.35);
            transition: all 0.2s ease;
        }

        .btn-modern-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(2, 132, 199, 0.45);
        }

        .btn-modern-ghost {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 13px 24px;
            background: #FFFFFF;
            color: #334155 !important;
            font-weight: 600;
            font-size: 14.5px;
            border: 1.5px solid #E2E8F0;
            border-radius: 12px;
            text-decoration: none !important;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.04);
            transition: all 0.2s ease;
        }

        .btn-modern-ghost:hover {
            background: #F8FAFC;
            border-color: #CBD5E1;
            color: #0284C7 !important;
            transform: translateY(-2px);
        }

        .hero-metrics-pill-bar {
            display: inline-flex;
            align-items: center;
            gap: 20px;
            padding: 12px 20px;
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            box-shadow: 0 2px 10px rgba(15, 23, 42, 0.04);
            font-size: 13px;
            color: #475569;
        }

        .hero-metric-dot-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
            color: #0F172A;
        }

        .hero-metric-dot-item svg {
            color: #0284C7;
        }

        /* Glassmorphism Hub Showcase Card */
        .glass-hub-card {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 24px;
            padding: 36px;
            box-shadow: 0 20px 45px -10px rgba(15, 23, 42, 0.08), 0 4px 16px -2px rgba(15, 23, 42, 0.03);
            position: relative;
            overflow: hidden;
        }

        .glass-hub-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(90deg, #0284C7, #0D9488, #38BDF8);
        }

        .hub-card-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .hub-tag {
            font-family: var(--font-mono);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: #0284C7;
            background: #E0F2FE;
            padding: 4px 10px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .hub-founded-badge {
            font-family: var(--font-mono);
            font-size: 11px;
            color: #64748B;
            font-weight: 600;
        }

        .hub-domains-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 24px;
        }

        .hub-domain-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 14px;
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            transition: all 0.2s ease;
        }

        .hub-domain-item:hover {
            border-color: #BAE6FD;
            background: #F0F9FF;
            transform: translateY(-2px);
        }

        .domain-icon-box {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .domain-name {
            font-family: var(--font-sans);
            font-size: 12.5px;
            font-weight: 600;
            color: #0F172A;
            line-height: 1.25;
        }

        .hub-director-box {
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .hub-director-avatar {
            width: 46px;
            height: 46px;
            border-radius: 50%;
            background: linear-gradient(135deg, #0284C7 0%, #0D9488 100%);
            color: #FFFFFF;
            font-family: var(--font-serif);
            font-size: 16px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            box-shadow: 0 4px 10px rgba(2, 132, 199, 0.25);
        }

        .hub-director-info {
            flex: 1;
        }

        .hub-director-quote {
            font-size: 13px;
            color: #334155;
            line-height: 1.5;
            margin: 0 0 4px;
            font-style: italic;
        }

        .hub-director-author {
            font-family: var(--font-mono);
            font-size: 11px;
            color: #0284C7;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        /* Modern 4 Stats Floating Cards */
        .stats-section-wrap {
            max-width: 1280px;
            margin: 0 auto 60px;
            padding: 0 40px;
        }

        .stats-floating-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }

        .stat-floating-card {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 18px;
            padding: 26px 24px;
            box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.04);
            display: flex;
            align-items: flex-start;
            gap: 16px;
            transition: all 0.2s ease;
        }

        .stat-floating-card:hover {
            transform: translateY(-3px);
            border-color: #BAE6FD;
            box-shadow: 0 12px 28px -4px rgba(2, 132, 199, 0.1);
        }

        .stat-icon-wrap {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .stat-content {
            flex: 1;
        }

        .stat-label-modern {
            font-size: 12px;
            font-weight: 600;
            color: #64748B;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 4px;
        }

        .stat-value-modern {
            font-family: var(--font-serif);
            font-size: 38px;
            font-weight: 800;
            color: #0F172A;
            line-height: 1;
            letter-spacing: -0.03em;
            margin-bottom: 4px;
        }

        .stat-desc-modern {
            font-size: 12px;
            color: #94A3B8;
            line-height: 1.4;
        }

        /* Section Layouts */
        .section-public-modern {
            max-width: 1280px;
            margin: 0 auto 72px;
            padding: 0 40px;
        }

        .section-header-modern {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 24px;
            margin-bottom: 36px;
        }

        .section-tag-modern {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-family: var(--font-mono);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: #0284C7;
            margin-bottom: 8px;
        }

        .section-title-modern {
            font-family: var(--font-serif);
            font-size: 34px;
            font-weight: 800;
            color: #0F172A;
            margin: 0;
            letter-spacing: -0.02em;
        }

        /* Teams Cards */
        .teams-grid-modern {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 24px;
        }

        .team-card-modern {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 20px;
            padding: 32px;
            box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.04);
            display: flex;
            flex-direction: column;
            gap: 16px;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .team-card-modern:hover {
            transform: translateY(-4px);
            border-color: #BAE6FD;
            box-shadow: 0 16px 36px -4px rgba(2, 132, 199, 0.12);
        }

        .team-top-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .team-icon-circle {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .team-pill-badge {
            font-family: var(--font-mono);
            font-size: 11px;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 9999px;
            background: #E0F2FE;
            color: #0284C7;
            border: 1px solid #BAE6FD;
        }

        .team-title-modern {
            font-family: var(--font-serif);
            font-size: 22px;
            font-weight: 800;
            color: #0F172A;
            margin: 0;
            letter-spacing: -0.015em;
        }

        .team-desc-modern {
            font-size: 14.5px;
            color: #64748B;
            line-height: 1.6;
            margin: 0;
        }

        .team-footer-modern {
            margin-top: auto;
            padding-top: 18px;
            border-top: 1px solid #F1F5F9;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 13px;
        }

        .team-leader {
            color: #334155;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .team-members-tag {
            font-family: var(--font-mono);
            font-size: 11.5px;
            color: #0284C7;
            background: #F0F9FF;
            padding: 3px 10px;
            border-radius: 6px;
            font-weight: 600;
        }

        .team-accordion-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            width: 100%;
            margin-top: 14px;
            padding: 9px 14px;
            font-size: 13px;
            font-weight: 600;
            color: #0284C7;
            background: #F0F9FF;
            border: 1px solid #BAE6FD;
            border-radius: 9px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .team-accordion-btn:hover {
            background: #E0F2FE;
            border-color: #0284C7;
            color: #0369A1;
        }

        .team-accordion-btn.active {
            background: #0284C7;
            color: #FFFFFF;
            border-color: #0284C7;
        }

        .team-accordion-btn .chevron-icon {
            transition: transform 0.25s ease;
        }

        .team-accordion-btn.active .chevron-icon {
            transform: rotate(180deg);
        }

        .team-members-collapse {
            max-height: 0;
            overflow: hidden;
            opacity: 0;
            transition: max-height 0.35s ease, opacity 0.3s ease, margin-top 0.2s ease;
            margin-top: 0;
            display: flex;
            flex-direction: column;
            gap: 9px;
        }

        .team-members-collapse.open {
            max-height: 550px;
            opacity: 1;
            margin-top: 14px;
            overflow-y: auto;
            padding-top: 2px;
        }

        .team-member-item {
            display: flex;
            align-items: center;
            gap: 11px;
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            padding: 9px 12px;
            transition: transform 0.15s ease, border-color 0.15s ease;
        }

        .team-member-item:hover {
            border-color: #BAE6FD;
            background: #FFFFFF;
            transform: translateY(-1px);
        }

        .member-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, #0284C7, #0D9488);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #FFFFFF;
            font-weight: 700;
            font-size: 13px;
            flex-shrink: 0;
        }

        .member-info {
            flex: 1;
            min-width: 0;
        }

        .member-name {
            font-size: 13px;
            font-weight: 700;
            color: #0F172A;
            line-height: 1.25;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .member-role {
            font-size: 11px;
            color: #64748B;
            margin-top: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .member-tag {
            font-size: 10.5px;
            font-family: var(--font-mono);
            padding: 3px 7px;
            border-radius: 5px;
            background: #E2E8F0;
            color: #334155;
            font-weight: 600;
            text-transform: capitalize;
            flex-shrink: 0;
        }

        /* Modern Event Cards */

        .events-grid-modern {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }

        .event-card-modern {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 18px;
            padding: 26px;
            box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.04);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            gap: 20px;
            transition: all 0.2s ease;
        }

        .event-card-modern:hover {
            transform: translateY(-3px);
            border-color: #BAE6FD;
            box-shadow: 0 12px 28px -4px rgba(2, 132, 199, 0.1);
        }

        /* Modern CTA Banner */
        .cta-banner-modern {
            background: radial-gradient(circle at 15% 15%, rgba(2, 132, 199, 0.2) 0%, transparent 45%),
                        radial-gradient(circle at 85% 85%, rgba(13, 148, 136, 0.18) 0%, transparent 50%),
                        linear-gradient(135deg, #0B132B 0%, #0F172A 100%);
            color: #FFFFFF;
            border-radius: 24px;
            padding: 60px 48px;
            max-width: 1280px;
            margin: 0 auto 80px;
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 48px;
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 24px 48px -12px rgba(15, 23, 42, 0.25);
        }

        .cta-title-modern {
            font-family: var(--font-serif);
            font-size: 38px;
            font-weight: 800;
            color: #FFFFFF;
            margin: 0 0 14px;
            letter-spacing: -0.02em;
            line-height: 1.2;
        }

        .cta-desc-modern {
            font-size: 16px;
            color: #94A3B8;
            line-height: 1.6;
            margin: 0 0 28px;
        }

        /* Partners Grid */
        .partners-grid-modern {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 16px;
        }

        .partner-card-modern {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            padding: 20px 14px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
            transition: all 0.2s ease;
        }

        .partner-card-modern:hover {
            border-color: #BAE6FD;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(2, 132, 199, 0.08);
        }

        .partner-badge-circle {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: #E0F2FE;
            color: #0284C7;
            font-family: var(--font-serif);
            font-size: 15px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .partner-name-text {
            font-family: var(--font-sans);
            font-size: 12px;
            font-weight: 600;
            color: #334155;
        }

        @media (max-width: 960px) {
            .hero-modern-wrap { grid-template-columns: 1fr; gap: 40px; padding: 48px 20px; }
            .hero-modern-title { font-size: 40px; }
            .stats-floating-grid { grid-template-columns: 1fr 1fr; }
            .teams-grid-modern { grid-template-columns: 1fr; }
            .events-grid-modern { grid-template-columns: 1fr; }
            .cta-banner-modern { grid-template-columns: 1fr; padding: 40px 24px; }
            .partners-grid-modern { grid-template-columns: repeat(3, 1fr); }
        }
    </style>
</head>
<body>

    <!-- Shared Topbar -->
    <%@ include file="includes/navbar.jsp" %>

    <!-- Hero Section -->
    <section class="hero-modern-wrap" id="top">
        <div>
            <div class="hero-badge-pill">
                <span class="pulse-beacon"></span>
                <span>Portail Scientifique Officiel · FSBM Université Hassan II</span>
            </div>
            
            <h1 class="hero-modern-title">
                Laboratoire d'Informatique &amp; <span class="highlight">Applications Scientifiques</span>.
            </h1>
            
            <p class="hero-modern-desc">
                Pôle d'excellence académique fondé le 15 septembre 2003, dédié à la recherche fondamentale, aux technologies d'avant-garde en Big Data, Intelligence Artificielle et Systèmes Distribués.
            </p>

            <div class="hero-actions-row">
                <a href="<%= request.getContextPath() %>/login" class="btn-modern-primary">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                    Espace Membres
                </a>
                <a href="<%= request.getContextPath() %>/publications" class="btn-modern-ghost">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                    Publications &amp; Travaux
                </a>
            </div>

            <div class="hero-metrics-pill-bar">
                <div class="hero-metric-dot-item">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>38 Membres Titulaires &amp; Doctorants</span>
                </div>
                <div style="width: 1px; height: 16px; background: #E2E8F0;"></div>
                <div class="hero-metric-dot-item">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>280+ Publications Indexées</span>
                </div>
            </div>
        </div>

        <!-- Glass Hub Showcase Card -->
        <div class="glass-hub-card">
            <div class="hub-card-top">
                <div class="hub-tag">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 14 14"/></svg>
                    LIAS Research Hub
                </div>
                <div class="hub-founded-badge">
                    Fondé le 15 Septembre 2003
                </div>
            </div>

            <div class="hub-domains-grid">
                <div class="hub-domain-item">
                    <div class="domain-icon-box" style="background: #E0F2FE; color: #0284C7;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>
                    </div>
                    <div>
                        <div class="domain-name">Big Data &amp; Analyse Prédictive</div>
                        <div style="font-size: 11px; color: #64748B;">Équipe 1 · 11 chercheurs</div>
                    </div>
                </div>

                <div class="hub-domain-item">
                    <div class="domain-icon-box" style="background: #F3E8FF; color: #7C3AED;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/><line x1="9" y1="1" x2="9" y2="4"/><line x1="15" y1="1" x2="15" y2="4"/><line x1="9" y1="20" x2="9" y2="23"/><line x1="15" y1="20" x2="15" y2="23"/></svg>
                    </div>
                    <div>
                        <div class="domain-name">IA, Vision &amp; Deep Learning</div>
                        <div style="font-size: 11px; color: #64748B;">Équipe 2 · 9 chercheurs</div>
                    </div>
                </div>

                <div class="hub-domain-item">
                    <div class="domain-icon-box" style="background: #CCFBF1; color: #0D9488;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/></svg>
                    </div>
                    <div>
                        <div class="domain-name">Systèmes Distribués &amp; Cloud</div>
                        <div style="font-size: 11px; color: #64748B;">Équipe 3 · 10 chercheurs</div>
                    </div>
                </div>

                <div class="hub-domain-item">
                    <div class="domain-icon-box" style="background: #DCFCE7; color: #15803D;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    </div>
                    <div>
                        <div class="domain-name">Cybersécurité &amp; IoT</div>
                        <div style="font-size: 11px; color: #64748B;">Équipe 4 · 8 chercheurs</div>
                    </div>
                </div>
            </div>

            <div class="hub-director-box">
                <div class="hub-director-avatar">IE</div>
                <div class="hub-director-info">
                    <p class="hub-director-quote">
                        « Le laboratoire constitue la mémoire vivante de notre production scientifique et l'engagement commun pour l'excellence académique. »
                    </p>
                    <div class="hub-director-author">Pr. I. Essadiki — Directrice du Laboratoire LIAS</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section (4 Floating Cards) -->
    <div class="stats-section-wrap">
        <div class="stats-floating-grid">
            <div class="stat-floating-card">
                <div class="stat-icon-wrap" style="background: #E0F2FE; color: #0284C7;">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                </div>
                <div class="stat-content">
                    <div class="stat-label-modern">Communauté</div>
                    <div class="stat-value-modern"><%= request.getAttribute("totalMembres") != null ? request.getAttribute("totalMembres") : "38" %></div>
                    <div class="stat-desc-modern">Enseignants &amp; doctorants actifs</div>
                </div>
            </div>

            <div class="stat-floating-card">
                <div class="stat-icon-wrap" style="background: #CCFBF1; color: #0D9488;">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                </div>
                <div class="stat-content">
                    <div class="stat-label-modern">Production</div>
                    <div class="stat-value-modern"><%= request.getAttribute("totalPublications") != null ? request.getAttribute("totalPublications") : "280+" %></div>
                    <div class="stat-desc-modern">Articles &amp; revues indexés Q1/Q2</div>
                </div>
            </div>

            <div class="stat-floating-card">
                <div class="stat-icon-wrap" style="background: #FEF3C7; color: #D97706;">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                </div>
                <div class="stat-content">
                    <div class="stat-label-modern">Partenariats</div>
                    <div class="stat-value-modern">14</div>
                    <div class="stat-desc-modern">Accords nationaux &amp; mondiaux</div>
                </div>
            </div>

            <div class="stat-floating-card">
                <div class="stat-icon-wrap" style="background: #DCFCE7; color: #15803D;">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                </div>
                <div class="stat-content">
                    <div class="stat-label-modern">Fondation</div>
                    <div class="stat-value-modern" style="font-size: 26px; padding-top: 6px;">15/09/2003</div>
                    <div class="stat-desc-modern">23 ans d'excellence continue</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Équipes de Recherche -->
    <%
        com.lias.dao.IMemberDao publicMemberDao = new com.lias.dao.MemberDaoImpl();
        java.util.List<com.lias.beans.Member> labMembers = null;
        try {
            labMembers = publicMemberDao.findAll();
        } catch (Exception ex) {
            labMembers = new java.util.ArrayList<>();
        }
        if (labMembers == null) labMembers = new java.util.ArrayList<>();

        java.util.List<com.lias.beans.Member> team1Members = new java.util.ArrayList<>();
        java.util.List<com.lias.beans.Member> team2Members = new java.util.ArrayList<>();
        java.util.List<com.lias.beans.Member> team3Members = new java.util.ArrayList<>();
        java.util.List<com.lias.beans.Member> team4Members = new java.util.ArrayList<>();

        for (com.lias.beans.Member mb : labMembers) {
            String t = mb.getTeam() != null ? mb.getTeam().toLowerCase() : "";
            if (t.contains("big") || t.contains("data") || t.contains("donnée")) {
                team1Members.add(mb);
            } else if (t.contains("ia") || t.contains("intelligence") || t.contains("vision")) {
                team2Members.add(mb);
            } else if (t.contains("cloud") || t.contains("distrib") || t.contains("nlp") || t.contains("syst")) {
                team3Members.add(mb);
            } else if (t.contains("sec") || t.contains("séc") || t.contains("reseau") || t.contains("réseau")) {
                team4Members.add(mb);
            }
        }
    %>
    <section class="section-public-modern" id="equipes">
        <div class="section-header-modern">
            <div>
                <div class="section-tag-modern">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>
                    Organisation Scientifique
                </div>
                <h2 class="section-title-modern">Quatre équipes de recherche labellisées</h2>
            </div>
        </div>

        <div class="teams-grid-modern">
            <!-- Équipe 1 -->
            <div class="team-card-modern">
                <div class="team-top-row">
                    <div class="team-icon-circle" style="background: #E0F2FE; color: #0284C7;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>
                    </div>
                    <span class="team-pill-badge">Équipe 1</span>
                </div>
                <h3 class="team-title-modern">Science des Données &amp; Big Data</h3>
                <p class="team-desc-modern">
                    Modélisation prédictive, traitement de flux massifs, architecture de lac de données et fouille de données complexes appliquées à la santé, au transport et à l'énergie.
                </p>
                <div class="team-footer-modern">
                    <span class="team-leader">Responsable : <strong>Pr. A. Alami</strong></span>
                    <span class="team-members-tag"><%= team1Members.size() > 0 ? team1Members.size() + " chercheurs" : "11 chercheurs" %></span>
                </div>
                <button type="button" class="team-accordion-btn" onclick="toggleTeamAccordion('team-1-list', this)">
                    <span>Voir les membres</span>
                    <svg class="chevron-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div id="team-1-list" class="team-members-collapse">
                    <% if (team1Members.isEmpty()) { %>
                        <div style="font-size: 12px; color: #64748B; padding: 10px; background: #F8FAFC; border-radius: 8px; text-align: center;">Équipe en cours d'affiliation</div>
                    <% } else {
                        for (com.lias.beans.Member m : team1Members) {
                            String inits = "";
                            if (m.getFirstName() != null && !m.getFirstName().isEmpty()) inits += m.getFirstName().charAt(0);
                            if (m.getLastName() != null && !m.getLastName().isEmpty()) inits += m.getLastName().charAt(0);
                    %>
                    <div class="team-member-item">
                        <div class="member-avatar"><%= inits.toUpperCase() %></div>
                        <div class="member-info">
                            <div class="member-name"><%= m.getFirstName() %> <%= m.getLastName() %></div>
                            <div class="member-role"><%= m.getGrade() != null ? m.getGrade() : (m.getRole() != null ? m.getRole() : "Chercheur") %></div>
                        </div>
                        <span class="member-tag"><%= m.getStatus() != null ? m.getStatus() : "Actif" %></span>
                    </div>
                    <% } } %>
                </div>
            </div>

            <!-- Équipe 2 -->
            <div class="team-card-modern">
                <div class="team-top-row">
                    <div class="team-icon-circle" style="background: #F3E8FF; color: #7C3AED;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/><line x1="9" y1="1" x2="9" y2="4"/><line x1="15" y1="1" x2="15" y2="4"/><line x1="9" y1="20" x2="9" y2="23"/><line x1="15" y1="20" x2="15" y2="23"/></svg>
                    </div>
                    <span class="team-pill-badge" style="background: #F3E8FF; color: #7C3AED; border-color: #DDD6FE;">Équipe 2</span>
                </div>
                <h3 class="team-title-modern">Intelligence Artificielle &amp; Vision</h3>
                <p class="team-desc-modern">
                    Apprentissage profond, vision par ordinateur, traitement automatique du langage naturel (NLP) et conception d'agents autonomes d'aide à la décision médicale et industrielle.
                </p>
                <div class="team-footer-modern">
                    <span class="team-leader">Responsable : <strong>Pr. F. Zahra</strong></span>
                    <span class="team-members-tag" style="background: #FAF5FF; color: #7C3AED;"><%= team2Members.size() > 0 ? team2Members.size() + " chercheurs" : "9 chercheurs" %></span>
                </div>
                <button type="button" class="team-accordion-btn" onclick="toggleTeamAccordion('team-2-list', this)">
                    <span>Voir les membres</span>
                    <svg class="chevron-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div id="team-2-list" class="team-members-collapse">
                    <% if (team2Members.isEmpty()) { %>
                        <div style="font-size: 12px; color: #64748B; padding: 10px; background: #F8FAFC; border-radius: 8px; text-align: center;">Équipe en cours d'affiliation</div>
                    <% } else {
                        for (com.lias.beans.Member m : team2Members) {
                            String inits = "";
                            if (m.getFirstName() != null && !m.getFirstName().isEmpty()) inits += m.getFirstName().charAt(0);
                            if (m.getLastName() != null && !m.getLastName().isEmpty()) inits += m.getLastName().charAt(0);
                    %>
                    <div class="team-member-item">
                        <div class="member-avatar" style="background: linear-gradient(135deg, #7C3AED, #EC4899);"><%= inits.toUpperCase() %></div>
                        <div class="member-info">
                            <div class="member-name"><%= m.getFirstName() %> <%= m.getLastName() %></div>
                            <div class="member-role"><%= m.getGrade() != null ? m.getGrade() : (m.getRole() != null ? m.getRole() : "Chercheur") %></div>
                        </div>
                        <span class="member-tag"><%= m.getStatus() != null ? m.getStatus() : "Actif" %></span>
                    </div>
                    <% } } %>
                </div>
            </div>

            <!-- Équipe 3 -->
            <div class="team-card-modern">
                <div class="team-top-row">
                    <div class="team-icon-circle" style="background: #CCFBF1; color: #0D9488;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/></svg>
                    </div>
                    <span class="team-pill-badge" style="background: #CCFBF1; color: #0D9488; border-color: #99F6E4;">Équipe 3</span>
                </div>
                <h3 class="team-title-modern">Systèmes Distribués &amp; Cloud</h3>
                <p class="team-desc-modern">
                    Infrastructures cloud hybrides, architectures de micro-services tolérantes aux pannes, consensus décentralisé et calcul intensif haute performance (HPC).
                </p>
                <div class="team-footer-modern">
                    <span class="team-leader">Responsable : <strong>Pr. M. Idrissi</strong></span>
                    <span class="team-members-tag" style="background: #F0FDFA; color: #0D9488;"><%= team3Members.size() > 0 ? team3Members.size() + " chercheurs" : "10 chercheurs" %></span>
                </div>
                <button type="button" class="team-accordion-btn" onclick="toggleTeamAccordion('team-3-list', this)">
                    <span>Voir les membres</span>
                    <svg class="chevron-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div id="team-3-list" class="team-members-collapse">
                    <% if (team3Members.isEmpty()) { %>
                        <div style="font-size: 12px; color: #64748B; padding: 10px; background: #F8FAFC; border-radius: 8px; text-align: center;">Équipe en cours d'affiliation</div>
                    <% } else {
                        for (com.lias.beans.Member m : team3Members) {
                            String inits = "";
                            if (m.getFirstName() != null && !m.getFirstName().isEmpty()) inits += m.getFirstName().charAt(0);
                            if (m.getLastName() != null && !m.getLastName().isEmpty()) inits += m.getLastName().charAt(0);
                    %>
                    <div class="team-member-item">
                        <div class="member-avatar" style="background: linear-gradient(135deg, #0D9488, #10B981);"><%= inits.toUpperCase() %></div>
                        <div class="member-info">
                            <div class="member-name"><%= m.getFirstName() %> <%= m.getLastName() %></div>
                            <div class="member-role"><%= m.getGrade() != null ? m.getGrade() : (m.getRole() != null ? m.getRole() : "Chercheur") %></div>
                        </div>
                        <span class="member-tag"><%= m.getStatus() != null ? m.getStatus() : "Actif" %></span>
                    </div>
                    <% } } %>
                </div>
            </div>

            <!-- Équipe 4 -->
            <div class="team-card-modern">
                <div class="team-top-row">
                    <div class="team-icon-circle" style="background: #DCFCE7; color: #15803D;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    </div>
                    <span class="team-pill-badge" style="background: #DCFCE7; color: #15803D; border-color: #BBF7D0;">Équipe 4</span>
                </div>
                <h3 class="team-title-modern">Cybersécurité &amp; Réseaux</h3>
                <p class="team-desc-modern">
                    Sécurité des objets connectés (IoT), cryptographie post-quantique appliquée, résilience des infrastructures critiques et conformité de la confidentialité des données massives.
                </p>
                <div class="team-footer-modern">
                    <span class="team-leader">Responsable : <strong>Pr. K. Tazi</strong></span>
                    <span class="team-members-tag" style="background: #F0FDF4; color: #15803D;"><%= team4Members.size() > 0 ? team4Members.size() + " chercheurs" : "8 chercheurs" %></span>
                </div>
                <button type="button" class="team-accordion-btn" onclick="toggleTeamAccordion('team-4-list', this)">
                    <span>Voir les membres</span>
                    <svg class="chevron-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div id="team-4-list" class="team-members-collapse">
                    <% if (team4Members.isEmpty()) { %>
                        <div style="font-size: 12px; color: #64748B; padding: 10px; background: #F8FAFC; border-radius: 8px; text-align: center;">Équipe en cours d'affiliation</div>
                    <% } else {
                        for (com.lias.beans.Member m : team4Members) {
                            String inits = "";
                            if (m.getFirstName() != null && !m.getFirstName().isEmpty()) inits += m.getFirstName().charAt(0);
                            if (m.getLastName() != null && !m.getLastName().isEmpty()) inits += m.getLastName().charAt(0);
                    %>
                    <div class="team-member-item">
                        <div class="member-avatar" style="background: linear-gradient(135deg, #15803D, #059669);"><%= inits.toUpperCase() %></div>
                        <div class="member-info">
                            <div class="member-name"><%= m.getFirstName() %> <%= m.getLastName() %></div>
                            <div class="member-role"><%= m.getGrade() != null ? m.getGrade() : (m.getRole() != null ? m.getRole() : "Chercheur") %></div>
                        </div>
                        <span class="member-tag"><%= m.getStatus() != null ? m.getStatus() : "Actif" %></span>
                    </div>
                    <% } } %>
                </div>
            </div>
        </div>
    </section>

    <!-- Publications Récentes -->

    <section class="section-public-modern" id="publications">
        <div class="section-header-modern">
            <div>
                <div class="section-tag-modern">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                    Rayonnement &amp; Diffusion
                </div>
                <h2 class="section-title-modern">Dernières publications scientifiques</h2>
            </div>
            <a href="<%= request.getContextPath() %>/publications" class="btn-modern-ghost" style="padding: 10px 20px; font-size: 13.5px;">
                Toutes les publications →
            </a>
        </div>

        <div class="table-container" style="border-radius: 18px; box-shadow: 0 4px 20px -2px rgba(15,23,42,0.04);">
            <table>
                <thead>
                    <tr>
                        <th style="width: 80px;">Année</th>
                        <th>Titre du travail scientifique</th>
                        <th>Auteurs du LIAS</th>
                        <th>Revue / Conférence</th>
                        <th>Indexation</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Publication> pubs = (List<Publication>) request.getAttribute("recentPublications");
                        if (pubs != null && !pubs.isEmpty()) {
                            int count = 0;
                            for (Publication p : pubs) {
                                if (++count > 5) break;
                    %>
                    <tr>
                        <td>
                            <span class="badge badge-navy" style="font-size: 12px; font-weight: 700;"><%= p.getAnnee() %></span>
                        </td>
                        <td>
                            <div style="font-weight: 600; font-size: 14.5px; color: #0F172A; margin-bottom: 2px;">
                                <%= p.getTitre() %>
                            </div>
                            <% if (p.getDoi() != null && !p.getDoi().isEmpty()) { %>
                                <div style="font-family: var(--font-mono); font-size: 11px; color: #0284C7;">DOI: <%= p.getDoi() %></div>
                            <% } %>
                        </td>
                        <td style="color: #64748B; font-size: 13.5px;"><%= p.getAuteurs() %></td>
                        <td style="color: #334155; font-style: italic; font-size: 13.5px;"><%= p.getRevue() %></td>
                        <td>
                            <span class="badge badge-gold"><%= p.getType() != null ? p.getType() : "Article" %></span>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td><span class="badge badge-navy" style="font-size: 12px; font-weight: 700;">2025</span></td>
                        <td>
                            <div style="font-weight: 600; font-size: 14.5px; color: #0F172A;">A Deep Learning Approach for Real-Time Anomaly Detection in High-Velocity Data Streams</div>
                            <div style="font-family: var(--font-mono); font-size: 11px; color: #0284C7;">DOI: 10.1109/TKDE.2025.04112</div>
                        </td>
                        <td style="color: #64748B;">Y. Benali, S. Chraibi, A. Alami</td>
                        <td style="color: #334155; font-style: italic;">IEEE Transactions on Knowledge and Data Engineering</td>
                        <td><span class="badge badge-gold">Revue Q1</span></td>
                    </tr>
                    <tr>
                        <td><span class="badge badge-navy" style="font-size: 12px; font-weight: 700;">2024</span></td>
                        <td>
                            <div style="font-weight: 600; font-size: 14.5px; color: #0F172A;">Privacy-Preserving Federated Learning for Distributed Scientific Datasets</div>
                            <div style="font-family: var(--font-mono); font-size: 11px; color: #0284C7;">DOI: 10.1145/3412345.3412350</div>
                        </td>
                        <td style="color: #64748B;">M. Idrissi, F. Zahra</td>
                        <td style="color: #334155; font-style: italic;">ACM Computing Surveys</td>
                        <td><span class="badge badge-gold">Article</span></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- Événements Scientifiques -->
    <section class="section-public-modern" id="evenements">
        <div class="section-header-modern">
            <div>
                <div class="section-tag-modern">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    Agenda &amp; Rencontres
                </div>
                <h2 class="section-title-modern">Événements &amp; Séminaires</h2>
            </div>
            <a href="<%= request.getContextPath() %>/evenements" class="btn-modern-ghost" style="padding: 10px 20px; font-size: 13.5px;">
                Tous les événements →
            </a>
        </div>

        <div class="events-grid-modern">
            <%
                List<Evenement> evts = (List<Evenement>) request.getAttribute("upcomingEvents");
                if (evts != null && !evts.isEmpty()) {
                    int eCount = 0;
                    for (Evenement evt : evts) {
                        if (++eCount > 3) break;

                        // 1. Nettoyage Encodage
                        String cleanTitle = evt.getTitre() != null ? evt.getTitre()
                            .replace("Maghr?bine", "Maghrébine")
                            .replace("Maghr?bin", "Maghrébin")
                            .replace("G?n?rative", "Générative")
                            .replace("Distribu?", "Distribué")
                            .replace("S?minaire", "Séminaire")
                            .replace("Conf?rence", "Conférence") : "";

                        String rawDesc = evt.getDescription() != null ? evt.getDescription() : "";
                        String cleanDesc = rawDesc
                            .replace("?quipes", "équipes")
                            .replace("?quipe", "équipe")
                            .replace("Pr?sentation", "Présentation")
                            .replace("avanc?es", "avancées")
                            .replace("avanc?e", "avancée")
                            .replace("Maghr?bine", "Maghrébine")
                            .replace("Maghr?bin", "Maghrébin")
                            .replace("r?seau", "réseau")
                            .replace("R?seau", "Réseau");

                        if (cleanDesc.length() > 115) {
                            cleanDesc = cleanDesc.substring(0, 112) + "...";
                        }

                        // 2. Formatage Date Française
                        String rawDate = evt.getDate() != null ? evt.getDate().trim() : "";
                        String displayDate = rawDate;
                        if (rawDate.matches("\\d{4}-\\d{2}-\\d{2}")) {
                            String[] parts = rawDate.split("-");
                            String yr = parts[0];
                            String mo = parts[1];
                            String da = parts[2];
                            String moName = "Janvier";
                            if ("02".equals(mo)) moName = "Février";
                            else if ("03".equals(mo)) moName = "Mars";
                            else if ("04".equals(mo)) moName = "Avril";
                            else if ("05".equals(mo)) moName = "Mai";
                            else if ("06".equals(mo)) moName = "Juin";
                            else if ("07".equals(mo)) moName = "Juillet";
                            else if ("08".equals(mo)) moName = "Août";
                            else if ("09".equals(mo)) moName = "Septembre";
                            else if ("10".equals(mo)) moName = "Octobre";
                            else if ("11".equals(mo)) moName = "Novembre";
                            else if ("12".equals(mo)) moName = "Décembre";
                            displayDate = da + " " + moName + " " + yr;
                        }

                        // 3. Statut & Past/Future styling
                        String rawStatut = evt.getStatut() != null ? evt.getStatut() : "À venir";
                        boolean isPasse = rawStatut.toLowerCase().contains("pass") || rawStatut.toLowerCase().contains("archiv") || rawStatut.toLowerCase().contains("term");
            %>
            <a href="<%= request.getContextPath() %>/evenements" class="event-card-modern" style="cursor: pointer; text-decoration: none; color: inherit;">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                        <span class="badge <%= "Conférence".equalsIgnoreCase(evt.getType()) ? "badge-navy" : "badge-gold" %>"><%= evt.getType() != null ? evt.getType() : "Séminaire" %></span>
                        <span style="font-family: var(--font-mono); font-size: 11.5px; color: #64748B; font-weight: 600;"><%= displayDate %></span>
                    </div>
                    <h3 style="font-family: var(--font-serif); font-size: 18.5px; font-weight: 700; color: #0F172A; margin: 0 0 10px; line-height: 1.35;">
                        <%= cleanTitle %>
                    </h3>
                    <p style="font-size: 13.5px; color: #64748B; line-height: 1.55; margin: 0;">
                        <%= cleanDesc %>
                    </p>
                </div>
                <div style="padding-top: 14px; border-top: 1px solid #F1F5F9; display: flex; justify-content: space-between; align-items: center; font-size: 12.5px; color: #475569; margin-top: 16px;">
                    <span style="display: flex; align-items: center; gap: 6px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0284C7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        <%= evt.getLieu() != null ? evt.getLieu() : "FSBM Casablanca" %>
                    </span>
                    <% if (isPasse) { %>
                        <span style="font-family: var(--font-mono); font-size: 11px; color: #64748B; font-weight: 700; background: #F1F5F9; padding: 3px 8px; border-radius: 6px;">⚪ Passé</span>
                    <% } else { %>
                        <span style="font-family: var(--font-mono); font-size: 11px; color: #0284C7; font-weight: 700; background: #E0F2FE; padding: 3px 8px; border-radius: 6px;">🟢 À venir</span>
                    <% } %>
                </div>
            </a>
            <%
                    }
                } else {
            %>
            <div class="event-card-modern">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                        <span class="badge badge-gold">Workshop</span>
                        <span style="font-family: var(--font-mono); font-size: 11.5px; color: #64748B; font-weight: 600;">15 AVR 2026</span>
                    </div>
                    <h3 style="font-family: var(--font-serif); font-size: 19px; font-weight: 700; color: #0F172A; margin: 0 0 10px; line-height: 1.35;">
                        Journée Doctorale IA &amp; Big Data
                    </h3>
                    <p style="font-size: 14px; color: #64748B; line-height: 1.55; margin: 0;">
                        Présentation des avancées des travaux de thèses de doctorat et échanges scientifiques avec les chercheurs associés.
                    </p>
                </div>
                <div style="padding-top: 14px; border-top: 1px solid #F1F5F9; display: flex; justify-content: space-between; align-items: center; font-size: 12.5px; color: #475569;">
                    <span style="display: flex; align-items: center; gap: 6px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0284C7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        Amphithéâtre Al-Khawarizmi
                    </span>
                    <span style="font-family: var(--font-mono); font-size: 11px; color: #0284C7; font-weight: 700;">À venir</span>
                </div>
            </div>

            <div class="event-card-modern">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                        <span class="badge badge-gold">Séminaire</span>
                        <span style="font-family: var(--font-mono); font-size: 11.5px; color: #64748B; font-weight: 600;">10 MAI 2026</span>
                    </div>
                    <h3 style="font-family: var(--font-serif); font-size: 19px; font-weight: 700; color: #0F172A; margin: 0 0 10px; line-height: 1.35;">
                        Calcul Haute Performance &amp; Clouds
                    </h3>
                    <p style="font-size: 14px; color: #64748B; line-height: 1.55; margin: 0;">
                        Conférence invitée avec des experts du CNRS sur les architectures distribuées résilientes et le consensus scalable.
                    </p>
                </div>
                <div style="padding-top: 14px; border-top: 1px solid #F1F5F9; display: flex; justify-content: space-between; align-items: center; font-size: 12.5px; color: #475569;">
                    <span style="display: flex; align-items: center; gap: 6px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0284C7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        Salle des Séminaires LIAS
                    </span>
                    <span style="font-family: var(--font-mono); font-size: 11px; color: #0284C7; font-weight: 700;">À venir</span>
                </div>
            </div>

            <div class="event-card-modern">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                        <span class="badge badge-gold">Soutenance</span>
                        <span style="font-family: var(--font-mono); font-size: 11.5px; color: #64748B; font-weight: 600;">20 JUIN 2026</span>
                    </div>
                    <h3 style="font-family: var(--font-serif); font-size: 19px; font-weight: 700; color: #0F172A; margin: 0 0 10px; line-height: 1.35;">
                        Soutenance de Thèse de Doctorat
                    </h3>
                    <p style="font-size: 14px; color: #64748B; line-height: 1.55; margin: 0;">
                        Thèse intitulée « Privacy-Preserving Federated Learning » présentée par Y. Amrani devant le jury de la FSBM.
                    </p>
                </div>
                <div style="padding-top: 14px; border-top: 1px solid #F1F5F9; display: flex; justify-content: space-between; align-items: center; font-size: 12.5px; color: #475569;">
                    <span style="display: flex; align-items: center; gap: 6px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0284C7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        Salle des Thèses, FSBM
                    </span>
                    <span style="font-family: var(--font-mono); font-size: 11px; color: #0284C7; font-weight: 700;">À venir</span>
                </div>
            </div>
            <% } %>
        </div>
    </section>

    <!-- Partenaires -->
    <section class="section-public-modern">
        <div class="section-tag-modern">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
            Réseau &amp; Collaborations
        </div>
        <h2 class="section-title-modern" style="margin-bottom: 24px;">Partenaires académiques et industriels</h2>
        
        <div class="partners-grid-modern">
            <div class="partner-card-modern">
                <div class="partner-badge-circle">CT</div>
                <div class="partner-name-text">Casa Transports</div>
            </div>
            <div class="partner-card-modern">
                <div class="partner-badge-circle">IN</div>
                <div class="partner-name-text">INRIA Paris</div>
            </div>
            <div class="partner-card-modern">
                <div class="partner-badge-circle">UM</div>
                <div class="partner-name-text">Univ. Mohammed V</div>
            </div>
            <div class="partner-card-modern">
                <div class="partner-badge-circle">LP</div>
                <div class="partner-name-text">CNRS-LIPN</div>
            </div>
            <div class="partner-card-modern">
                <div class="partner-badge-circle">EN</div>
                <div class="partner-name-text">ENSIAS Rabat</div>
            </div>
            <div class="partner-card-modern">
                <div class="partner-badge-circle">OC</div>
                <div class="partner-name-text">OCP Innovation</div>
            </div>
        </div>
    </section>

    <!-- CTA Collaborer -->
    <section class="cta-banner-modern" id="rejoindre">
        <div>
            <div class="section-tag-modern" style="color: #38BDF8;">Rejoignez le laboratoire</div>
            <h2 class="cta-title-modern">Vous souhaitez collaborer avec le LIAS ?</h2>
            <p class="cta-desc-modern">
                Doctorants, enseignants-chercheurs associés, partenaires industriels — chaque candidature est traitée avec rigueur et traçabilité par la Direction en mandat.
            </p>
        </div>
        <div style="display: flex; flex-direction: column; gap: 16px; align-items: flex-start;">
            <a href="<%= request.getContextPath() %>/adhesions" class="btn-modern-primary" style="padding: 14px 28px; font-size: 15px;">
                Déposer une candidature d'adhésion →
            </a>
            <a href="mailto:contact@lias.ma" style="color: #94A3B8; font-size: 13.5px; text-decoration: none; display: flex; align-items: center; gap: 8px;">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                contact@lias.ma · FSBM Casablanca
            </a>
        </div>
    </section>

    <!-- Shared Footer -->
    <%@ include file="includes/footer.jsp" %>

    <!-- Active Anchor Scroll Spy -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var navMap = {
                'top': document.getElementById('nav-top'),
                'equipes': document.getElementById('nav-equipes'),
                'publications': document.getElementById('nav-publications'),
                'evenements': document.getElementById('nav-evenements'),
                'rejoindre': document.getElementById('nav-rejoindre')
            };

            var sections = ['top', 'equipes', 'publications', 'evenements', 'rejoindre']
                .map(function(id) { return document.getElementById(id); })
                .filter(Boolean);

            if ('IntersectionObserver' in window && sections.length > 0) {
                var observer = new IntersectionObserver(function(entries) {
                    entries.forEach(function(entry) {
                        if (entry.isIntersecting) {
                            var id = entry.target.id;
                            Object.keys(navMap).forEach(function(k) {
                                if (navMap[k]) navMap[k].classList.remove('active');
                            });
                            if (navMap[id]) navMap[id].classList.add('active');
                        }
                    });
                }, {
                    rootMargin: '-20% 0px -65% 0px',
                    threshold: 0.05
                });
                sections.forEach(function(sec) { observer.observe(sec); });
            }
        });
    </script>

    <!-- Team Accordion Toggle Handler -->
    <script>
        function toggleTeamAccordion(id, btn) {
            var el = document.getElementById(id);
            if (!el) return;
            var isOpen = el.classList.contains('open');
            var labelSpan = btn.querySelector('span');
            if (isOpen) {
                el.classList.remove('open');
                btn.classList.remove('active');
                if (labelSpan) labelSpan.textContent = 'Voir les membres';
            } else {
                el.classList.add('open');
                btn.classList.add('active');
                if (labelSpan) labelSpan.textContent = 'Masquer les membres';
            }
        }
    </script>

</body>
</html>

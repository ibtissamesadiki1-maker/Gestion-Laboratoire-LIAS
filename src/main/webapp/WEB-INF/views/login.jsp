<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>LIAS — Connexion à l'Espace Membre</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2026_modern_fresh_v5">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            background: #0F172A;
            font-family: var(--font-sans);
        }

        .login-wrapper {
            display: grid;
            grid-template-columns: 1.15fr 1fr;
            min-height: 100vh;
        }

        /* Left Showcase Column */
        .login-left-panel {
            background: radial-gradient(circle at 20% 20%, rgba(2, 132, 199, 0.18) 0%, transparent 40%),
                        radial-gradient(circle at 80% 80%, rgba(13, 148, 136, 0.15) 0%, transparent 45%),
                        linear-gradient(145deg, #0B132B 0%, #0F172A 50%, #1E293B 100%);
            color: #FFFFFF;
            padding: 64px 72px;
            display: flex;
            flex-direction: column;
            position: relative;
            overflow: hidden;
            border-right: 1px solid rgba(255, 255, 255, 0.08);
        }

        .login-brand-group {
            display: flex;
            align-items: center;
            gap: 16px;
            text-decoration: none !important;
            z-index: 2;
        }

        .login-logo-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            background: linear-gradient(135deg, #0284C7 0%, #0D9488 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #FFFFFF;
            box-shadow: 0 8px 24px rgba(2, 132, 199, 0.35);
        }

        .login-brand-title {
            font-family: var(--font-serif);
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -0.02em;
            color: #FFFFFF;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .login-pill-badge {
            font-family: var(--font-mono);
            font-size: 10px;
            background: rgba(2, 132, 199, 0.2);
            border: 1px solid rgba(56, 189, 248, 0.4);
            color: #38BDF8;
            padding: 3px 9px;
            border-radius: 9999px;
            font-weight: 600;
            letter-spacing: 0.08em;
        }

        .login-left-content {
            margin: auto 0;
            z-index: 2;
        }

        .login-tag-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 9999px;
            font-family: var(--font-mono);
            font-size: 11px;
            color: #38BDF8;
            margin-bottom: 24px;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .login-hero-heading {
            font-family: var(--font-serif);
            font-size: 50px;
            font-weight: 800;
            line-height: 1.08;
            letter-spacing: -0.03em;
            margin: 0 0 20px;
            color: #FFFFFF;
        }

        .login-hero-heading span {
            background: linear-gradient(135deg, #38BDF8 0%, #2DD4BF 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .login-hero-desc {
            font-size: 16.5px;
            line-height: 1.65;
            color: #94A3B8;
            max-width: 480px;
            margin: 0 0 36px;
        }

        .login-features-list {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .login-feature-item {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14.5px;
            color: #CBD5E1;
        }

        .login-check-icon {
            width: 22px;
            height: 22px;
            border-radius: 50%;
            background: rgba(16, 185, 129, 0.15);
            border: 1px solid rgba(16, 185, 129, 0.35);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #34D399;
            flex-shrink: 0;
        }

        .login-left-footer {
            z-index: 2;
            font-family: var(--font-mono);
            font-size: 11.5px;
            color: #64748B;
            display: flex;
            align-items: center;
            gap: 10px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            padding-top: 24px;
        }

        /* Right Form Column */
        .login-right-panel {
            background: #F8FAFC;
            padding: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .login-form-box {
            width: 100%;
            max-width: 440px;
            background: #FFFFFF;
            padding: 40px;
            border-radius: 20px;
            border: 1px solid #E2E8F0;
            box-shadow: 0 16px 36px -4px rgba(15, 23, 42, 0.06), 0 4px 12px -2px rgba(15, 23, 42, 0.03);
        }

        .login-form-header {
            margin-bottom: 28px;
        }

        .login-form-eyebrow {
            font-family: var(--font-mono);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: #0284C7;
            margin-bottom: 6px;
            display: block;
        }

        .login-form-title {
            font-family: var(--font-serif);
            font-size: 28px;
            font-weight: 800;
            color: #0F172A;
            margin: 0 0 6px;
            letter-spacing: -0.02em;
        }

        .login-form-sub {
            font-size: 14px;
            color: #64748B;
            line-height: 1.5;
            margin: 0;
        }

        .input-group {
            margin-bottom: 20px;
        }

        .input-label {
            display: block;
            font-size: 12.5px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 8px;
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            color: #94A3B8;
            pointer-events: none;
            display: flex;
            align-items: center;
        }

        .input-field {
            width: 100%;
            padding: 13px 14px 13px 44px;
            background: #F8FAFC;
            border: 1.5px solid #E2E8F0;
            border-radius: 12px;
            font-size: 14px;
            font-family: var(--font-sans);
            color: #0F172A;
            transition: all 0.2s ease;
            outline: none;
            box-sizing: border-box;
        }

        .input-field:focus {
            background: #FFFFFF;
            border-color: #0284C7;
            box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.12);
        }

        .login-btn-submit {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #0284C7 0%, #0D9488 100%);
            color: #FFFFFF;
            font-weight: 600;
            font-size: 14.5px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 4px 16px rgba(2, 132, 199, 0.3);
            transition: all 0.2s ease;
        }

        .login-btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 22px rgba(2, 132, 199, 0.4);
        }

        .demo-roles-box {
            margin-top: 28px;
            padding: 16px 18px;
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
        }

        .demo-roles-title {
            font-family: var(--font-mono);
            font-size: 10.5px;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: #475569;
            margin: 0 0 10px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .demo-chips-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 6px;
        }

        .demo-chip {
            padding: 6px 10px;
            background: #FFFFFF;
            border: 1px solid #CBD5E1;
            border-radius: 8px;
            font-family: var(--font-sans);
            font-size: 11.5px;
            font-weight: 600;
            color: #334155;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: all 0.15s ease;
            text-align: left;
        }

        .demo-chip:hover {
            border-color: #0284C7;
            background: #E0F2FE;
            color: #0284C7;
            transform: translateY(-1px);
        }

        .demo-chip.special {
            color: #B91C1C;
            border-color: #FECACA;
            background: #FEF2F2;
        }

        .demo-chip.special:hover {
            background: #FEE2E2;
            border-color: #EF4444;
        }

        .alert-error-modern {
            padding: 12px 16px;
            background: #FFF1F2;
            border: 1px solid #FECDD3;
            border-left: 4px solid #E11D48;
            border-radius: 10px;
            color: #9F1239;
            font-size: 13px;
            line-height: 1.5;
            margin-bottom: 20px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }

        @media (max-width: 960px) {
            .login-wrapper { grid-template-columns: 1fr; }
            .login-left-panel { display: none; }
            .login-right-panel { padding: 32px 16px; }
            .login-form-box { padding: 28px 20px; }
        }
    </style>
</head>
<body>

    <div class="login-wrapper">

        <!-- Left Showcase Column -->
        <div class="login-left-panel">
            <a href="<%= request.getContextPath() %>/public" class="login-brand-group">
                <div class="login-logo-icon">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="3"/>
                        <ellipse cx="12" cy="12" rx="9" ry="4" transform="rotate(30 12 12)"/>
                        <ellipse cx="12" cy="12" rx="9" ry="4" transform="rotate(-30 12 12)"/>
                    </svg>
                </div>
                <div>
                    <div class="login-brand-title">
                        LIAS
                        <span class="login-pill-badge">FSBM</span>
                    </div>
                </div>
            </a>

            <div class="login-left-content">
                <div class="login-tag-pill">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="#38BDF8"><circle cx="12" cy="12" r="10"/></svg>
                    Portail d'Excellence Scientifique
                </div>
                <h1 class="login-hero-heading">
                    La mémoire vivante de la <span>recherche</span>.
                </h1>
                <p class="login-hero-desc">
                    Espace institutionnel unifié pour la gouvernance, le suivi de la production scientifique, la traçabilité des mandats et la collaboration des chercheurs.
                </p>

                <div class="login-features-list">
                    <div class="login-feature-item">
                        <div class="login-check-icon">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                        <span>Traçabilité intégrale des décisions et des mandats</span>
                    </div>
                    <div class="login-feature-item">
                        <div class="login-check-icon">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                        <span>Production automatisée du rapport d'activité annuel</span>
                    </div>
                    <div class="login-feature-item">
                        <div class="login-check-icon">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                        <span>Distribution équitable et suivi des dotations matérielles</span>
                    </div>
                    <div class="login-feature-item">
                        <div class="login-check-icon">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                        <span>Archivage numérique et préservation absolue des données</span>
                    </div>
                </div>
            </div>

            <div class="login-left-footer">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                Faculté des Sciences Ben M'Sik · Université Hassan II de Casablanca
            </div>
        </div>

        <!-- Right Form Column -->
        <div class="login-right-panel">
            <div class="login-form-box">
                <div class="login-form-header">
                    <span class="login-form-eyebrow">Espace d'accès sécurisé</span>
                    <h2 class="login-form-title">Connexion Membres</h2>
                    <p class="login-form-sub">Veuillez renseigner votre email et mot de passe pour vous connecter.</p>
                </div>

                <% 
                    String error = (String) request.getAttribute("errorMessage");
                    if (error == null) error = (String) request.getAttribute("error");
                    String errParam = request.getParameter("error");
                    if ("auth_requise".equals(errParam)) {
                        error = "Veuillez vous connecter pour accéder à cet espace protégé.";
                    } else if ("compte_gele".equals(errParam)) {
                        error = "Compte gelé (Statut Retraité). Vos données et publications demeurent archivées dans la mémoire du laboratoire.";
                    } else if ("compte_desactive".equals(errParam)) {
                        error = "Compte désactivé (Statut Ancien Membre). Vos données restent conservées.";
                    }
                    if (error != null && !error.isEmpty()) { 
                %>
                    <div class="alert-error-modern">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        <div><%= error %></div>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/login" method="post">
                    <div class="input-group">
                        <label class="input-label" for="email">Adresse email institutionnelle</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            </span>
                            <input type="email" id="email" name="email" class="input-field" placeholder="directeur@lias.ma" required autofocus>
                        </div>
                    </div>

                    <div class="input-group">
                        <label class="input-label" for="password">Mot de passe sécurisé</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            </span>
                            <input type="password" id="password" name="password" class="input-field" placeholder="••••••••••••" required>
                        </div>
                    </div>

                    <button type="submit" class="login-btn-submit">
                        <span>Se connecter à la plateforme</span>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                    </button>
                </form>

                <!-- Démo Rapide (1 Clic) -->
                <div class="demo-roles-box">
                    <div class="demo-roles-title">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0284C7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                        Comptes de test (cliquez pour remplir) :
                    </div>
                    <div class="demo-chips-grid">
                        <button type="button" class="demo-chip" onclick="fillForm('directeur@lias.ma', 'admin123')">
                            👑 Directeur
                        </button>
                        <button type="button" class="demo-chip" onclick="fillForm('vice-directeur@lias.ma', 'pass123')" style="border-color: #0284C7; color: #0284C7; font-weight: 700;">
                            ⭐ Vice-Directeur (Sara Benjelloun)
                        </button>
                        <button type="button" class="demo-chip" onclick="fillForm('karim.zouhair@lias.ma', 'pass123')" style="border-color: #059669; color: #059669; font-weight: 700;">
                            🛡️ Chef d'équipe (Karim Zouhair)
                        </button>
                        <button type="button" class="demo-chip" onclick="fillForm('permanent@lias.ma', 'pass123')" style="border-color: #7C3AED; color: #6D28D9; font-weight: 700;">
                            🔬 Membre Permanent (Youssef Tahiri)
                        </button>
                        <button type="button" class="demo-chip" onclick="fillForm('doctorant@lias.ma', 'doc123')">
                            🎓 Doctorant
                        </button>
                        <button type="button" class="demo-chip" onclick="fillForm('admin@lias.ma', 'admin123')">
                            ⚡ Admin
                        </button>
                        <button type="button" class="demo-chip special" onclick="fillForm('retraite@lias.ma', 'pass123')">
                            🔒 Retraité
                        </button>
                        <button type="button" class="demo-chip special" onclick="fillForm('ancien@lias.ma', 'pass123')">
                            🚪 Ancien Membre
                        </button>
                    </div>
                </div>

                <div style="margin-top: 24px; text-align: center;">
                    <a href="<%= request.getContextPath() %>/public" style="color: #64748B; font-size: 13px; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                        Retour au site public
                    </a>
                </div>
            </div>
        </div>

    </div>

    <script>
        function fillForm(email, pass) {
            document.getElementById('email').value = email;
            document.getElementById('password').value = pass;
        }
    </script>
</body>
</html>

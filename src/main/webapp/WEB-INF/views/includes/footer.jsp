<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<footer>
    <div class="footer-inner" style="display:grid; grid-template-columns: 2fr 1fr 1fr 1.2fr; gap: 40px; margin-bottom: 36px;">
        <div>
            <div class="brand" style="margin-bottom: 14px;">
                <div class="brand-mark">L</div>
                <div class="brand-name">LIAS</div>
            </div>
            <p style="font-family: var(--font-serif); font-size: 13.5px; color: var(--muted); line-height: 1.55; margin: 0; max-width: 380px;">
                Laboratoire d'Informatique et Applications Scientifiques. Faculté des Sciences Ben M'Sik — Université Hassan II — Casablanca, Maroc.
            </p>
        </div>
        <div>
            <h5 style="font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.15em; text-transform: uppercase; color: var(--muted); margin-bottom: 14px;">Navigation</h5>
            <ul style="list-style:none; padding:0; margin:0; line-height: 2;">
                <li><a href="<%= request.getContextPath() %>/public">Accueil Public</a></li>
                <li><a href="<%= request.getContextPath() %>/profils">Annuaire des Chercheurs</a></li>
                <li><a href="<%= request.getContextPath() %>/publications">Publications</a></li>
                <li><a href="<%= request.getContextPath() %>/evenements">Événements & Séminaires</a></li>
            </ul>
        </div>
        <div>
            <h5 style="font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.15em; text-transform: uppercase; color: var(--muted); margin-bottom: 14px;">Accès</h5>
            <ul style="list-style:none; padding:0; margin:0; line-height: 2;">
                <li><a href="<%= request.getContextPath() %>/login">Espace Membres</a></li>
                <li><a href="<%= request.getContextPath() %>/adhesions">Demande d'Adhésion</a></li>
                <li><a href="<%= request.getContextPath() %>/home">Tableau de Bord</a></li>
            </ul>
        </div>
        <div>
            <h5 style="font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.15em; text-transform: uppercase; color: var(--muted); margin-bottom: 14px;">Contact & Institution</h5>
            <ul style="list-style:none; padding:0; margin:0; line-height: 1.9;">
                <li style="font-family: var(--font-mono); font-size: 12px; color: var(--ink);">contact@lias.ma</li>
                <li style="font-family: var(--font-sans); font-size: 12.5px; color: var(--muted);">FSBM · B.P. 7955 Sidi Othman</li>
                <li style="font-family: var(--font-sans); font-size: 12.5px; color: var(--muted);">Casablanca, Maroc</li>
            </ul>
        </div>
    </div>
    <div style="border-top: 1px solid var(--border); padding-top: 20px; display: flex; justify-content: space-between; align-items: center; font-family: var(--font-mono); font-size: 11px; color: var(--muted); max-width: 1280px; margin: 0 auto;">
        <span>© 2003–2026 LIAS · Faculté des Sciences Ben M'Sik · Tous droits réservés</span>
        <span>Projet JEE Master DS&BD · Architecture MVC 2 Pure</span>
    </div>
</footer>

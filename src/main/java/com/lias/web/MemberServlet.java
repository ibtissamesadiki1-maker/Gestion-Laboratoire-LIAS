package com.lias.web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lias.beans.AffiliationPeriod;
import com.lias.beans.Member;
import com.lias.beans.Publication;
import com.lias.beans.User;
import com.lias.dao.IMemberDao;
import com.lias.dao.MemberDaoImpl;
import com.lias.dao.IPublicationDao;
import com.lias.dao.PublicationDaoImpl;

/**
 * Contrôleur JEE pour la gestion et consultation des profils membres (CDC §3).
 * Fonctionnalités implémentées :
 * 1. Consultation des profils des membres et chercheurs associés/doctorants/retraités.
 * 2. Modification libre du profil par le membre connecté.
 * 3. Historisation automatique des changements d'affiliation/statut.
 */
@WebServlet(name = "MemberServlet", urlPatterns = {"/membres", "/profils"})
public class MemberServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IMemberDao memberDao;
    private IPublicationDao pubDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.memberDao = new MemberDaoImpl();
        this.pubDao = new PublicationDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // ── CDC §2.1 / §5.1 : /profils est une page INTERNE — authentification obligatoire ──
        HttpSession sessionCheck = request.getSession(false);
        User currentUserCheck = sessionCheck != null ? (User) sessionCheck.getAttribute("currentUser") : null;
        if (currentUserCheck == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String team = request.getParameter("team");
        String status = request.getParameter("status");
        String role = request.getParameter("role");
        String selectId = request.getParameter("id");
        List<Member> liste;

        if (team != null && !team.trim().isEmpty()) {
            liste = memberDao.findByTeam(team.trim());
        } else if (status != null && !status.trim().isEmpty()) {
            liste = memberDao.findByStatus(status.trim());
        } else if (role != null && !role.trim().isEmpty()) {
            liste = new ArrayList<>();
            for (Member m : memberDao.findAll()) {
                if (role.trim().equalsIgnoreCase(m.getRole()) ||
                    (role.trim().equalsIgnoreCase("chef-equipe") && ("chef-equipe".equalsIgnoreCase(m.getRole()) || "chef_equipe".equalsIgnoreCase(m.getRole()))) ||
                    (role.trim().equalsIgnoreCase("vice-directeur") && ("vice-directeur".equalsIgnoreCase(m.getRole()) || "vicedirecteur".equalsIgnoreCase(m.getRole()))) ||
                    (role.trim().equalsIgnoreCase("membre") && ("membre".equalsIgnoreCase(m.getRole()) || "membre-equipe".equalsIgnoreCase(m.getRole())))) {
                    liste.add(m);
                }
            }
        } else {
            liste = memberDao.findAll();
        }

        Member selectedMember = null;
        if (liste != null && !liste.isEmpty()) {
            if (selectId != null && !selectId.trim().isEmpty()) {
                for (Member m : liste) {
                    if (m.getId().equalsIgnoreCase(selectId.trim())) {
                        selectedMember = m;
                        break;
                    }
                }
            }
            if (selectedMember == null) {
                // Si l'utilisateur est connecté, on essaye de sélectionner son propre profil par défaut
                HttpSession session = request.getSession(false);
                User cu = session != null ? (User) session.getAttribute("currentUser") : null;
                if (cu != null) {
                    for (Member m : liste) {
                        if (m.getEmail().equalsIgnoreCase(cu.getEmail())) {
                            selectedMember = m;
                            break;
                        }
                    }
                }
            }
            if (selectedMember == null && !liste.isEmpty()) {
                selectedMember = liste.get(0);
            }
        }

        // Publications associées au membre sélectionné (CDC §3)
        List<Publication> memberPubs = new ArrayList<>();
        if (selectedMember != null) {
            String authorKey = selectedMember.getLastName();
            List<Publication> allPubs = pubDao.findAll();
            if (allPubs != null) {
                for (Publication p : allPubs) {
                    if (p.getAuteurs() != null && 
                        (p.getAuteurs().toLowerCase().contains(authorKey.toLowerCase()) || 
                         p.getAuteurs().toLowerCase().contains(selectedMember.getFirstName().toLowerCase()))) {
                        memberPubs.add(p);
                    }
                }
            }
            // Périodes d'affiliation historisées (CDC §3 & §4)
            List<AffiliationPeriod> periods = memberDao.getAffiliationPeriods(selectedMember.getId());
            request.setAttribute("affiliationPeriods", periods);
        }

        request.setAttribute("membres", liste);
        request.setAttribute("selectedMember", selectedMember);
        request.setAttribute("memberPublications", memberPubs);
        request.setAttribute("selectedTeam", team);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedRole", role);
        request.getRequestDispatcher("/WEB-INF/views/profils.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null && session != null) {
            currentUser = (User) session.getAttribute("user");
        }

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=auth_requise");
            return;
        }

        String memberId = request.getParameter("id");
        if (memberId == null || memberId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/profils");
            return;
        }

        Member member = memberDao.findById(memberId.trim());
        if (member == null) {
            response.sendRedirect(request.getContextPath() + "/profils");
            return;
        }

        // Vérification des droits : un membre ne peut modifier que son propre profil, sauf le directeur ou l'administrateur technique
        boolean isDirector = "directeur".equalsIgnoreCase(currentUser.getRole());
        boolean isAdmin = "admin".equalsIgnoreCase(currentUser.getRole());
        boolean isSelf = currentUser.getEmail().equalsIgnoreCase(member.getEmail());

        if (!isDirector && !isSelf && !isAdmin) {
            request.setAttribute("requiredRole", "Propriétaire du compte ou Direction du Laboratoire (CDC §3)");
            request.setAttribute("deniedUrl", request.getRequestURI());
            request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
            return;
        }

        String action = request.getParameter("action");

        // CDC §8.1 : Retraité — Compte gelé, historique conservé, aucun accès actif
        if ("partir_retraite".equalsIgnoreCase(action)) {
            if (!isDirector) {
                request.setAttribute("requiredRole", "Direction du Laboratoire (CDC §8.1)");
                request.setAttribute("deniedUrl", request.getRequestURI());
                request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
                return;
            }
            String dateFinStr = request.getParameter("dateFin");
            String motif = request.getParameter("motif");
            java.time.LocalDate dateFin = (dateFinStr != null && !dateFinStr.trim().isEmpty()) 
                    ? java.time.LocalDate.parse(dateFinStr.trim()) 
                    : java.time.LocalDate.now();
            memberDao.gelerCompteRetraite(member.getId(), dateFin, motif);
            response.sendRedirect(request.getContextPath() + "/profils?id=" + member.getId() + "&msg=retraite_enregistree");
            return;
        }

        // CDC §8.2 : Ancien membre — Compte désactivé, historique conservé
        if ("quitter_labo".equalsIgnoreCase(action)) {
            if (!isDirector && !isSelf) {
                request.setAttribute("requiredRole", "Propriétaire du compte ou Direction du Laboratoire (CDC §8.2)");
                request.setAttribute("deniedUrl", request.getRequestURI());
                request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
                return;
            }
            String dateFinStr = request.getParameter("dateFin");
            String motif = request.getParameter("motif");
            java.time.LocalDate dateFin = (dateFinStr != null && !dateFinStr.trim().isEmpty()) 
                    ? java.time.LocalDate.parse(dateFinStr.trim()) 
                    : java.time.LocalDate.now();
            memberDao.desactiverAncienMembre(member.getId(), dateFin, motif);
            response.sendRedirect(request.getContextPath() + "/profils?id=" + member.getId() + "&msg=depart_enregistre");
            return;
        }

        // CDC §8.2 : Ancien membre — Peut éventuellement être réactivé
        if ("reactiver_membre".equalsIgnoreCase(action) || "revenir_labo".equalsIgnoreCase(action)) {
            if (!isDirector) {
                request.setAttribute("requiredRole", "Direction du Laboratoire (CDC §8.2)");
                request.setAttribute("deniedUrl", request.getRequestURI());
                request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
                return;
            }
            String dateDebutStr = request.getParameter("dateDebut");
            String nouveauStatut = request.getParameter("nouveauStatut");
            String nouveauRole = request.getParameter("nouveauRole");
            java.time.LocalDate dateDebut = (dateDebutStr != null && !dateDebutStr.trim().isEmpty()) 
                    ? java.time.LocalDate.parse(dateDebutStr.trim()) 
                    : java.time.LocalDate.now();
            if (nouveauStatut == null || nouveauStatut.trim().isEmpty()) nouveauStatut = "permanent";
            if (nouveauRole == null || nouveauRole.trim().isEmpty()) nouveauRole = "membre";

            memberDao.reactiverAncienMembre(member.getId(), dateDebut, nouveauStatut, nouveauRole);
            response.sendRedirect(request.getContextPath() + "/profils?id=" + member.getId() + "&msg=reactivation_enregistree");
            return;
        }

        if ("ajouter_periode".equalsIgnoreCase(action)) {
            String dDeb = request.getParameter("dateDebut");
            String dFin = request.getParameter("dateFin");
            String roleHist = request.getParameter("roleHistorique");
            if (dDeb != null && !dDeb.trim().isEmpty()) {
                AffiliationPeriod ap = new AffiliationPeriod();
                ap.setMemberId(member.getId());
                ap.setDateDebut(java.time.LocalDate.parse(dDeb.trim()));
                if (dFin != null && !dFin.trim().isEmpty()) {
                    ap.setDateFin(java.time.LocalDate.parse(dFin.trim()));
                }
                ap.setRoleHistorique(roleHist != null && !roleHist.trim().isEmpty() ? roleHist.trim() : "Affiliation au laboratoire");
                memberDao.addAffiliationPeriod(ap);
            }
            response.sendRedirect(request.getContextPath() + "/profils?id=" + member.getId() + "&msg=periode_ajoutee");
            return;
        }

        // CDC §7 : Gestion des rôles et responsabilités — Un membre peut changer de rôle sans suppression de données
        if ("changer_role".equalsIgnoreCase(action)) {
            if (!isDirector) {
                request.setAttribute("requiredRole", "Direction du Laboratoire (CDC §7)");
                request.setAttribute("deniedUrl", request.getRequestURI());
                request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
                return;
            }
            String nouveauRole = request.getParameter("nouveauRole");
            String dateEffetStr = request.getParameter("dateEffet");
            String motif = request.getParameter("motif");
            java.time.LocalDate dateEffet = (dateEffetStr != null && !dateEffetStr.trim().isEmpty())
                    ? java.time.LocalDate.parse(dateEffetStr.trim())
                    : java.time.LocalDate.now();
            memberDao.changeMemberRole(member.getId(), nouveauRole, dateEffet, motif);
            response.sendRedirect(request.getContextPath() + "/profils?id=" + member.getId() + "&msg=role_modifie");
            return;
        }

        // Extraction des informations modifiables selon CDC §3 & §4
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String photo = request.getParameter("photo");
        String etablissement = request.getParameter("etablissementOrigine");
        String laboratoire = request.getParameter("laboratoireOrigine");
        String biographie = request.getParameter("biographie");
        String centresInteret = request.getParameter("centresInteret");
        String team = request.getParameter("team");
        String grade = request.getParameter("grade");

        // Données temporelles CDC §4.2
        String dateNaissance = request.getParameter("dateNaissance");
        String dateEmbauche = request.getParameter("dateEmbauche");
        String dateAffiliation = request.getParameter("dateAffiliation");

        if (firstName != null && !firstName.trim().isEmpty()) member.setFirstName(firstName.trim());
        if (lastName != null && !lastName.trim().isEmpty()) member.setLastName(lastName.trim());
        if (email != null && !email.trim().isEmpty()) member.setEmail(email.trim());
        if (photo != null) member.setPhoto(photo.trim());
        if (etablissement != null) member.setEtablissementOrigine(etablissement.trim());
        if (laboratoire != null) member.setLaboratoireOrigine(laboratoire.trim());
        if (biographie != null) member.setBiographie(biographie.trim());
        if (centresInteret != null) member.setCentresInteret(centresInteret.trim());
        if (team != null && !team.trim().isEmpty()) member.setTeam(team.trim());
        if (grade != null && !grade.trim().isEmpty()) member.setGrade(grade.trim());

        // Mise à jour des données temporelles (CDC §4.2)
        if (dateNaissance != null && !dateNaissance.trim().isEmpty()) member.setDateNaissance(dateNaissance.trim());
        if (dateEmbauche != null && !dateEmbauche.trim().isEmpty()) member.setDateEmbauche(dateEmbauche.trim());
        if (isDirector && dateAffiliation != null && !dateAffiliation.trim().isEmpty()) {
            member.setDateAffiliation(dateAffiliation.trim());
        }

        // Seule la direction peut modifier le statut officiel et le rôle de gouvernance (CDC §7)
        if (isDirector) {
            String status = request.getParameter("status");
            String role = request.getParameter("role");
            if (status != null && !status.trim().isEmpty()) member.setStatus(status.trim());
            if (role != null && !role.trim().isEmpty() && !role.trim().equalsIgnoreCase(member.getRole())) {
                memberDao.changeMemberRole(member.getId(), role.trim(), java.time.LocalDate.now(), "Mise à jour via fiche de profil");
            }
        }

        // Sauvegarde avec historisation automatique des changements (CDC §3 & §4)
        memberDao.update(member);

        // Mise à jour de la session si le membre a modifié ses propres informations
        if (isSelf) {
            currentUser.setNom(member.getLastName());
            currentUser.setPrenom(member.getFirstName());
            currentUser.setEmail(member.getEmail());
            session.setAttribute("currentUser", currentUser);
            session.setAttribute("user", currentUser);
        }

        response.sendRedirect(request.getContextPath() + "/profils?id=" + member.getId() + "&msg=succes_maj");
    }
}

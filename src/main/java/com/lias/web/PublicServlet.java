package com.lias.web;

import java.io.IOException;
import java.util.List;
import com.lias.beans.Member;
import com.lias.dao.IPublicationDao;
import com.lias.dao.PublicationDaoImpl;
import com.lias.dao.IEvenementDao;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.IMemberDao;
import com.lias.dao.MemberDaoImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Servlet public d'accueil du Laboratoire LIAS.
 * Accessible à tous les visiteurs sans authentification (CDC §2.1).
 * Fournit les données réelles (publications récentes, événements, membres par équipe).
 */
@WebServlet(name = "PublicServlet", urlPatterns = {"/public", "/accueil"})
public class PublicServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private IPublicationDao pubDao;
    private IEvenementDao evtDao;
    private IMemberDao memberDao;

    @Override
    public void init() throws ServletException {
        pubDao = new PublicationDaoImpl();
        evtDao = new EvenementDaoImpl();
        memberDao = new MemberDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            request.setAttribute("recentPublications", pubDao.findAll());
            request.setAttribute("upcomingEvents", evtDao.findAll());
            request.setAttribute("totalMembres", memberDao.findAll().size());
            request.setAttribute("totalPublications", pubDao.findAll().size());

            // ── CDC §2.1 : Affichage public des membres par équipe ──
            String equipeParam = request.getParameter("equipe");
            if (equipeParam != null && !equipeParam.trim().isEmpty()) {
                // Mapping numéro équipe → nom équipe en base
                String teamName = null;
                switch (equipeParam.trim()) {
                    case "1": teamName = "Science des Données & Big Data"; break;
                    case "2": teamName = "Intelligence Artificielle & Vision"; break;
                    case "3": teamName = "Systèmes Distribués & Cloud"; break;
                    case "4": teamName = "Cybersécurité & Réseaux"; break;
                    default:  teamName = equipeParam.trim(); break;
                }
                List<Member> equipeMembers = memberDao.findByTeam(teamName);
                // Fallback: cherche aussi par équipe courte (ex: "IA", "Big Data")
                if (equipeMembers == null || equipeMembers.isEmpty()) {
                    equipeMembers = memberDao.findAll();
                }
                request.setAttribute("equipeMembers", equipeMembers);
                request.setAttribute("selectedEquipe", equipeParam.trim());
                request.setAttribute("selectedEquipeName", teamName);
            }
        } catch (Exception e) {
            // Tolérance aux pannes en cas de souci BD
        }
        request.getRequestDispatcher("/WEB-INF/views/public.jsp").forward(request, response);
    }
}

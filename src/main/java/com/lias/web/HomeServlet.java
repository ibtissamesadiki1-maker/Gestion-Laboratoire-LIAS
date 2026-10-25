package com.lias.web;

import java.io.IOException;
import com.lias.dao.IMemberDao;
import com.lias.dao.MemberDaoImpl;
import com.lias.dao.IPublicationDao;
import com.lias.dao.PublicationDaoImpl;
import com.lias.dao.IEvenementDao;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.IDemandeDao;
import com.lias.dao.DemandeDaoImpl;
import com.lias.dao.IUserDao;
import com.lias.dao.UserDaoImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Contrôleur du tableau de bord institutionnel (/home).
 * Fournit les KPI adaptés à chaque profil : Direction, Admin Système, Chercheurs, Doctorants.
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private IMemberDao memberDao;
    private IPublicationDao pubDao;
    private IEvenementDao evtDao;
    private IDemandeDao demandeDao;
    private IUserDao userDao;

    @Override
    public void init() throws ServletException {
        memberDao = new MemberDaoImpl();
        pubDao = new PublicationDaoImpl();
        evtDao = new EvenementDaoImpl();
        demandeDao = new DemandeDaoImpl();
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            request.setAttribute("totalMembres", memberDao.findAll().size());
            request.setAttribute("totalPublications", pubDao.findAll().size());
            request.setAttribute("totalEvenements", evtDao.findAll().size());
            
            // Métriques Utilisateurs Système (Admin CDC §5.1)
            int totalUsers = userDao.findAll().size();
            request.setAttribute("totalUsers", totalUsers);

            // Métriques Système JVM
            Runtime rt = Runtime.getRuntime();
            long totalMem = rt.totalMemory() / (1024 * 1024);
            long freeMem = rt.freeMemory() / (1024 * 1024);
            long usedMem = totalMem - freeMem;
            request.setAttribute("jvmUsedMem", usedMem + " MB");
            request.setAttribute("jvmTotalMem", totalMem + " MB");

            java.util.List<com.lias.beans.DemandeAdhesion> allAdhesions = demandeDao.findAllAdhesions();
            int pendingAdhesions = 0;
            if (allAdhesions != null) {
                for (com.lias.beans.DemandeAdhesion a : allAdhesions) {
                    if (a.getDecision() == null || "EN_ATTENTE".equalsIgnoreCase(a.getDecision())) {
                        pendingAdhesions++;
                    }
                }
            }
            request.setAttribute("totalDemandes", allAdhesions != null ? allAdhesions.size() : 0);
            request.setAttribute("pendingAdhesionsCount", pendingAdhesions);
            request.setAttribute("upcomingEvents", evtDao.findAll());
            request.setAttribute("pendingDemandes", allAdhesions);
        } catch (Exception e) {
            // Tolérance aux pannes
        }
        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}


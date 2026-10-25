package com.lias.web;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import com.lias.beans.Mandat;
import com.lias.beans.Member;
import com.lias.beans.User;
import com.lias.dao.IMandatDao;
import com.lias.dao.IMemberDao;
import com.lias.dao.MandatDaoImpl;
import com.lias.dao.MemberDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class MandatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IMandatDao mandatDao;
    private IMemberDao memberDao;

    @Override
    public void init() throws ServletException {
        this.mandatDao = new MandatDaoImpl();
        this.memberDao = new MemberDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Mandat> mandats = mandatDao.findAll();
        Mandat actif = mandatDao.findActive();
        List<Member> permanents = memberDao.findByStatus("permanent");

        request.setAttribute("mandats", mandats);
        request.setAttribute("mandatActif", actif);
        request.setAttribute("permanents", permanents);
        request.setAttribute("activeMenu", "mandats");

        request.getRequestDispatcher("/WEB-INF/views/mandats.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("currentUser");
            if (user == null) user = (User) session.getAttribute("user");
        }

        if (user == null || (!"directeur".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/mandats?error=unauthorized");
            return;
        }

        String titre = request.getParameter("titre");
        String directeurId = request.getParameter("directeurId");
        String viceDirecteurId = request.getParameter("viceDirecteurId");
        String chefsEquipes = request.getParameter("chefsEquipes");
        String dateDebutStr = request.getParameter("dateDebut");
        String dateFinStr = request.getParameter("dateFin");
        boolean actif = "true".equalsIgnoreCase(request.getParameter("actif")) || "on".equalsIgnoreCase(request.getParameter("actif"));

        if (titre != null && !titre.trim().isEmpty() && directeurId != null && dateDebutStr != null && !dateDebutStr.trim().isEmpty()) {
            try {
                Mandat m = new Mandat();
                m.setTitre(titre.trim());
                m.setDirecteurId(directeurId);
                m.setViceDirecteurId(viceDirecteurId != null && !viceDirecteurId.trim().isEmpty() ? viceDirecteurId : null);
                m.setChefsEquipes(chefsEquipes != null && !chefsEquipes.trim().isEmpty() ? chefsEquipes.trim() : "Chefs d'équipe du laboratoire");
                m.setDateDebut(LocalDate.parse(dateDebutStr.trim()));
                if (dateFinStr != null && !dateFinStr.trim().isEmpty()) {
                    m.setDateFin(LocalDate.parse(dateFinStr.trim()));
                }
                m.setActif(actif);

                mandatDao.save(m);
            } catch (Exception e) {
                // Ignore parse errors safely
            }
        }

        response.sendRedirect(request.getContextPath() + "/mandats?success=created");
    }
}

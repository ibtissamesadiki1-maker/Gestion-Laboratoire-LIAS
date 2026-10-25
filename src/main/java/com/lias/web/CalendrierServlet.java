package com.lias.web;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.lias.beans.Evenement;
import com.lias.beans.ReunionPV;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.IEvenementDao;
import com.lias.dao.IPVDao;
import com.lias.dao.PVDaoImpl;

/**
 * Contrôleur du Calendrier Scientifique & Navigation Temporelle (CDC §20).
 * Fonctionnalités :
 * • Visualisation des événements (conférences, séminaires, workshops, conseils & assemblées)
 * • Navigation temporelle (mensuelle, annuelle, sélecteur direct et vue agenda)
 */
@WebServlet(name = "CalendrierServlet", urlPatterns = {"/calendrier"})
public class CalendrierServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IEvenementDao evenementDao;
    private IPVDao pvDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.evenementDao = new EvenementDaoImpl();
        this.pvDao = new PVDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Evenement> evenements = evenementDao.findAll();
        List<ReunionPV> pvs = pvDao.findAll();

        String yearStr = request.getParameter("year");
        String monthStr = request.getParameter("month");

        int initialYear = LocalDate.now().getYear();
        int initialMonth = LocalDate.now().getMonthValue() - 1; // 0-indexed for JS

        if (yearStr != null) {
            try {
                initialYear = Integer.parseInt(yearStr.trim());
            } catch (NumberFormatException ignored) {}
        }
        if (monthStr != null) {
            try {
                int m = Integer.parseInt(monthStr.trim());
                if (m >= 1 && m <= 12) {
                    initialMonth = m - 1;
                } else if (m >= 0 && m <= 11) {
                    initialMonth = m;
                }
            } catch (NumberFormatException ignored) {}
        }

        request.setAttribute("evenements", evenements);
        request.setAttribute("pvs", pvs);
        request.setAttribute("initialYear", initialYear);
        request.setAttribute("initialMonth", initialMonth);
        request.setAttribute("activeNav", "calendrier");

        request.getRequestDispatcher("/WEB-INF/views/calendrier.jsp").forward(request, response);
    }
}

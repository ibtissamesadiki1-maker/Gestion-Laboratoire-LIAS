package com.lias.web;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lias.beans.User;
import com.lias.metier.IMetier;
import com.lias.metier.MetierImpl;

/**
 * Contrôleur JEE d'authentification (Login).
 * Gère l'affichage du formulaire et le traitement de la connexion.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IMetier metier;

    @Override
    public void init() throws ServletException {
        super.init();
        this.metier = new MetierImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Si l'utilisateur est déjà connecté, on le redirige directement vers /home
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Affichage de la page de connexion
        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // CDC §8.1 & §8.2 : Départ et retraite — Vérification compte gelé (retraité) ou désactivé (ancien membre)
        User userCheck = metier.getUtilisateurParEmail(email);
        if (userCheck != null && userCheck.getPassword().equals(password)) {
            boolean isRetraite = "retraite".equalsIgnoreCase(userCheck.getRole());
            boolean isAncienOrInactive = "ancien".equalsIgnoreCase(userCheck.getRole()) || !userCheck.isActif();

            if (isRetraite) {
                // CDC §8.1 : Retraité — Compte gelé, historique conservé, aucun accès actif
                request.setAttribute("errorMessage", "🔒 Compte gelé (Statut Retraité — CDC §8.1). Conformément au règlement, aucun accès actif n'est autorisé sur le système. Votre historique complet (publications scientifiques, mandats et affiliations) demeure intégralement préservé dans la mémoire institutionnelle du LIAS.");
                request.setAttribute("emailEntered", email);
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                return;
            } else if (isAncienOrInactive) {
                // CDC §8.2 : Ancien membre — Compte désactivé, historique conservé, peut éventuellement être réactivé
                request.setAttribute("errorMessage", "🚪 Compte désactivé (Statut Ancien Membre — CDC §8.2). Vous avez quitté le laboratoire. Votre historique complet est conservé. Ce compte peut éventuellement être réactivé par la Direction ou l'Administrateur Système.");
                request.setAttribute("emailEntered", email);
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                return;
            }
        }

        User user = metier.authentifier(email, password);

        if (user != null) {
            // Création / Récupération de la session HTTP
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());

            // Redirection vers l'espace membre
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            // Échec d'authentification
            request.setAttribute("errorMessage", "Identifiants invalides. Veuillez vérifier votre email et mot de passe.");
            request.setAttribute("emailEntered", email);
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }
}

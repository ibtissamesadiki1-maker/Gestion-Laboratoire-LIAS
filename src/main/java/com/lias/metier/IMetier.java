package com.lias.metier;

import java.util.List;
import com.lias.beans.User;

/**
 * Interface de la couche Métier (Business Logic Layer).
 * Encapsule les règles métier de l'application LIAS.
 */
public interface IMetier {
    /**
     * Authentifie un utilisateur avec son email et son mot de passe.
     * @return User si authentifié, null sinon.
     */
    User authentifier(String email, String password);

    /**
     * Recherche un utilisateur par son identifiant unique.
     */
    User getUtilisateurParId(Long id);

    /**
     * Recherche un utilisateur par son adresse email.
     */
    User getUtilisateurParEmail(String email);

    /**
     * Liste tous les utilisateurs enregistrés.
     */
    List<User> getTousLesUtilisateurs();

    /**
     * Inscription d'un nouvel utilisateur ou membre.
     */
    boolean inscrireUtilisateur(User user);
}

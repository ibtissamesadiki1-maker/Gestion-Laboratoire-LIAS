package com.lias.metier;

import java.util.List;
import com.lias.beans.User;
import com.lias.dao.IUserDao;
import com.lias.dao.UserDaoImpl;

/**
 * Implémentation de la couche Métier.
 * Applique les règles de gestion et délègue l'accès aux données au DAO.
 */
public class MetierImpl implements IMetier {

    private IUserDao userDao;

    public MetierImpl() {
        this.userDao = new UserDaoImpl();
    }

    public MetierImpl(IUserDao userDao) {
        this.userDao = userDao;
    }

    @Override
    public User authentifier(String email, String password) {
        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            return null;
        }
        return userDao.findByCredentials(email.trim().toLowerCase(), password);
    }

    @Override
    public User getUtilisateurParId(Long id) {
        if (id == null) return null;
        return userDao.findById(id);
    }

    @Override
    public User getUtilisateurParEmail(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        return userDao.findByEmail(email.trim().toLowerCase());
    }

    @Override
    public List<User> getTousLesUtilisateurs() {
        return userDao.findAll();
    }

    @Override
    public boolean inscrireUtilisateur(User user) {
        if (user == null || user.getEmail() == null) return false;
        // Vérifier l'unicité de l'email
        if (userDao.findByEmail(user.getEmail()) != null) {
            return false;
        }
        return userDao.save(user);
    }
}

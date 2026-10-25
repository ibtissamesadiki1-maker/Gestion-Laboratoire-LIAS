package com.lias.dao;

import java.util.List;
import com.lias.beans.User;

/**
 * Interface DAO pour la gestion des utilisateurs (Design Pattern DAO).
 */
public interface IUserDao {
    User findByCredentials(String email, String password);
    User findByEmail(String email);
    User findById(Long id);
    List<User> findAll();
    boolean save(User user);
    boolean update(User user);
    boolean delete(Long id);
}

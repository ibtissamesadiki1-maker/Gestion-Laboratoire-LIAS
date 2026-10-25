package com.lias.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Gestionnaire de connexion JDBC vers MySQL.
 * Fournit une connexion active pour chaque opération DAO dans l'environnement multi-thread Servlet.
 */
public class DBConnection {

    private static final String HOST = System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "localhost";
    private static final String PORT = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "3306";
    private static final String DB_NAME = "lias_db";
    private static final String URL = "jdbc:mysql://" + HOST + ":" + PORT + "/" + DB_NAME + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
    private static final String USER = "lias_user";
    private static final String PASSWORD = "lias_password";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] Driver MySQL introuvable : " + e.getMessage());
        }
    }

    private DBConnection() {
        // Constructeur privé
    }

    /**
     * Fournit une nouvelle connexion active pour le bloc try-with-resources.
     */
    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            System.err.println("[DBConnection] Erreur de connexion à la base de données : " + e.getMessage());
            return null;
        }
    }

    /**
     * Méthode utilitaire de compatibilité.
     */
    public static void closeConnection() {
        // Géré par try-with-resources dans chaque DAO
    }
}

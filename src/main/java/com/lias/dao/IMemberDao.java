package com.lias.dao;

import java.util.List;
import com.lias.beans.Member;
import com.lias.beans.AffiliationPeriod;

public interface IMemberDao {
    List<Member> findAll();
    Member findById(String id);
    Member findByEmail(String email);
    List<Member> findByTeam(String team);
    List<Member> findByStatus(String status);
    boolean save(Member member);
    boolean update(Member member);
    List<AffiliationPeriod> getAffiliationPeriods(String memberId);
    boolean addAffiliationPeriod(AffiliationPeriod period);
    boolean closeCurrentAffiliation(String memberId, java.time.LocalDate dateFin, String motif);
    boolean reopenAffiliation(String memberId, java.time.LocalDate dateDebut, String role);
    boolean changeMemberRole(String memberId, String nouveauRole, java.time.LocalDate dateEffet, String motif);
    // CDC §8.1 : Retraité — Compte gelé, historique conservé, aucun accès actif
    boolean gelerCompteRetraite(String memberId, java.time.LocalDate dateDepart, String motif);
    // CDC §8.2 : Ancien membre — Compte désactivé, historique conservé
    boolean desactiverAncienMembre(String memberId, java.time.LocalDate dateDepart, String motif);
    // CDC §8.2 : Ancien membre — Peut éventuellement être réactivé
    boolean reactiverAncienMembre(String memberId, java.time.LocalDate dateRetour, String nouveauStatut, String nouveauRole);
}


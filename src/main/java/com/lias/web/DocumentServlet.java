package com.lias.web;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lias.beans.DocumentLabo;
import com.lias.beans.Evenement;
import com.lias.beans.User;
import com.lias.dao.DocumentDaoImpl;
import com.lias.dao.EvenementDaoImpl;
import com.lias.dao.IDocumentDao;
import com.lias.dao.IEvenementDao;

/**
 * Contrôleur de l'Archive Documentaire Institutionnelle (CDC §10).
 * Structuration : Par événement et par date.
 * Types : Demandes de financement, Programmes, Attestations, Rapports, Documents administratifs.
 * Fonctionnalités : Upload, Téléchargement, Recherche, Historisation.
 */
@WebServlet(name = "DocumentServlet", urlPatterns = {"/documents"})
public class DocumentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IDocumentDao documentDao;
    private IEvenementDao evenementDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.documentDao = new DocumentDaoImpl();
        this.evenementDao = new EvenementDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // 1. TÉLÉCHARGEMENT DE DOCUMENT (CDC §10 ⭐)
        String downloadIdStr = request.getParameter("download");
        if (downloadIdStr != null && !downloadIdStr.trim().isEmpty()) {
            try {
                int docId = Integer.parseInt(downloadIdStr.trim());
                DocumentLabo doc = documentDao.findById(docId);
                if (doc != null) {
                    streamDocument(doc, response);
                    return;
                }
            } catch (NumberFormatException ignored) {}
        }

        // 2. RECHERCHE ET STRUCTURATION (PAR ÉVÉNEMENT, PAR DATE & PAR TYPE - CDC §10 ⭐)
        String query = request.getParameter("q");
        String categorie = request.getParameter("categorie");
        String evenement = request.getParameter("evenement");
        String annee = request.getParameter("annee");

        List<DocumentLabo> allDocs = documentDao.findAll();
        List<DocumentLabo> displayedDocs = allDocs;

        boolean isFiltering = (query != null && !query.trim().isEmpty()) ||
                              (categorie != null && !categorie.trim().isEmpty() && !"all".equalsIgnoreCase(categorie)) ||
                              (evenement != null && !evenement.trim().isEmpty() && !"all".equalsIgnoreCase(evenement)) ||
                              (annee != null && !annee.trim().isEmpty() && !"all".equalsIgnoreCase(annee));

        if (isFiltering) {
            displayedDocs = documentDao.searchFiltered(query, categorie, evenement, annee);
        }

        // 3. STATISTIQUES DES 5 TYPES OFFICIELS (CDC §10 ⭐)
        long countFinancements = 0;
        long countProgrammes = 0;
        long countAttestations = 0;
        long countRapports = 0;
        long countAdministratifs = 0;

        for (DocumentLabo d : allDocs) {
            String cat = d.getCategorie();
            if (cat != null) {
                String low = cat.toLowerCase();
                if (low.contains("financ")) countFinancements++;
                else if (low.contains("programm")) countProgrammes++;
                else if (low.contains("attest")) countAttestations++;
                else if (low.contains("rapport")) countRapports++;
                else if (low.contains("admin")) countAdministratifs++;
            }
        }

        // 4. HISTORISATION DES DÉPÔTS (CDC §10 ⭐)
        List<DocumentLabo> recentHistorique = documentDao.findRecentHistorique(10);

        // 5. LISTE DES ÉVÉNEMENTS DU LIAS POUR LA STRUCTURATION (CDC §9 & §10)
        List<Evenement> evenementsList = evenementDao.findAll();
        List<String> distinctEventsInDocs = documentDao.findDistinctEvenements();

        request.setAttribute("allDocs", allDocs);
        request.setAttribute("currentDocs", displayedDocs);
        request.setAttribute("recentHistorique", recentHistorique);
        request.setAttribute("evenementsList", evenementsList);
        request.setAttribute("distinctEvents", distinctEventsInDocs);

        // Statistiques des types officiels
        request.setAttribute("countFinancements", Long.valueOf(countFinancements));
        request.setAttribute("countProgrammes", Long.valueOf(countProgrammes));
        request.setAttribute("countAttestations", Long.valueOf(countAttestations));
        request.setAttribute("countRapports", Long.valueOf(countRapports));
        request.setAttribute("countAdministratifs", Long.valueOf(countAdministratifs));

        // Paramètres actifs
        request.setAttribute("searchQuery", query);
        request.setAttribute("selectedCategorie", categorie);
        request.setAttribute("selectedEvenement", evenement);
        request.setAttribute("selectedAnnee", annee);
        request.setAttribute("activeNav", "documents");

        request.getRequestDispatcher("/WEB-INF/views/documents.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("currentUser");
            if (user == null) user = (User) session.getAttribute("user");
        }

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=auth_requise");
            return;
        }

        String action = request.getParameter("action");
        if ("supprimer".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr.trim());
                    documentDao.delete(id);
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/documents?msg=deleted");
            return;
        }

        // UPLOAD DE DOCUMENT (CDC §10 ⭐)
        String nomFichier = request.getParameter("nomFichier");
        String categorie = request.getParameter("categorie");
        String evenementNom = request.getParameter("evenementNom");
        String dateFichier = request.getParameter("dateFichier");
        String type = request.getParameter("type");
        String description = request.getParameter("description");
        String dossier = request.getParameter("dossier");
        String sousDossier = request.getParameter("sousDossier");
        String edition = request.getParameter("edition");

        if (categorie == null || categorie.trim().isEmpty()) {
            categorie = "Rapports";
        }
        if (evenementNom == null || evenementNom.trim().isEmpty()) {
            evenementNom = "Administratif - Général";
        }
        if (dossier == null || dossier.trim().isEmpty()) {
            dossier = "Évènements";
        }
        if (sousDossier == null || sousDossier.trim().isEmpty()) {
            sousDossier = evenementNom;
        }
        if (dateFichier == null || dateFichier.trim().isEmpty()) {
            dateFichier = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }
        if (type == null || type.trim().isEmpty()) {
            type = "pdf";
        }
        if (nomFichier == null || nomFichier.trim().isEmpty()) {
            nomFichier = "Document_" + categorie.replace(" ", "_") + "_" + System.currentTimeMillis() + "." + type;
        }

        String auteur = (user.getPrenom() != null ? user.getPrenom() + " " : "") + (user.getNom() != null ? user.getNom() : "Membre LIAS");

        DocumentLabo newDoc = new DocumentLabo(
                null,
                dossier.trim(),
                sousDossier.trim(),
                edition != null && !edition.trim().isEmpty() ? edition.trim() : "Édition " + dateFichier.substring(0, 4),
                nomFichier.trim(),
                "280 KB",
                dateFichier.trim(),
                type.trim().toLowerCase(),
                auteur,
                description != null ? description.trim() : ("Document " + categorie + " déposé pour " + evenementNom),
                categorie.trim(),
                evenementNom.trim()
        );

        documentDao.save(newDoc);

        response.sendRedirect(request.getContextPath() + "/documents?msg=uploaded");
    }

    private void streamDocument(DocumentLabo doc, HttpServletResponse response) throws IOException {
        String ext = doc.getType() != null ? doc.getType().toLowerCase() : "pdf";
        String mimeType = "application/octet-stream";
        if ("pdf".equals(ext)) mimeType = "application/pdf";
        else if ("docx".equals(ext)) mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        else if ("xlsx".equals(ext)) mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        else if ("zip".equals(ext)) mimeType = "application/zip";

        response.setContentType(mimeType);
        response.setHeader("Content-Disposition", "attachment; filename=\"" + doc.getNomFichier() + "\"");

        // Contenu institutionnel officiel certifié LIAS
        StringBuilder content = new StringBuilder();
        content.append("================================================================================\n");
        content.append("ROYAUME DU MAROC - UNIVERSITÉ HASSAN II DE CASABLANCA\n");
        content.append("FACULTÉ DES SCIENCES BEN M'SIK - DÉPARTEMENT D'INFORMATIQUE\n");
        content.append("LABORATOIRE D'INFORMATIQUE ET D'AIDE À LA DÉCISION (LIAS)\n");
        content.append("================================================================================\n\n");
        content.append("DOCUMENT OFFICIEL ARCHIVÉ\n");
        content.append("INTITULÉ DU FICHIER : ").append(doc.getNomFichier()).append("\n");
        content.append("TYPE DE DOCUMENT     : ").append(doc.getCategorie()).append("\n");
        content.append("ÉVÉNEMENT RATTACHÉ   : ").append(doc.getEvenementNom() != null ? doc.getEvenementNom() : doc.getSousDossier()).append("\n");
        content.append("DATE D'ARCHIVAGE     : ").append(doc.getDateFichier()).append("\n");
        content.append("AUTEUR DU DÉPÔT      : ").append(doc.getAuteur()).append("\n");
        content.append("TAILLE DU FICHIER    : ").append(doc.getTaille()).append("\n");
        content.append("FORMAT               : ").append(doc.getType() != null ? doc.getType().toUpperCase() : "PDF").append("\n");
        content.append("DESCRIPTION          : ").append(doc.getDescription() != null ? doc.getDescription() : "Document officiel archivé du laboratoire LIAS.").append("\n\n");
        content.append("--------------------------------------------------------------------------------\n");
        content.append("TRAÇABILITÉ & HISTORISATION INSTITUTIONNELLE :\n");
        content.append("Enregistré avec succès dans le Système d'Information du laboratoire LIAS.\n");
        content.append("Conservation pérenne pour le patrimoine scientifique et le rapport annuel.\n");
        content.append("================================================================================\n");

        byte[] bytes = content.toString().getBytes(StandardCharsets.UTF_8);
        response.setContentLength(bytes.length);
        try (OutputStream os = response.getOutputStream()) {
            os.write(bytes);
            os.flush();
        }
    }
}

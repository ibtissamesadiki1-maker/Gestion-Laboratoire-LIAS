<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirection automatique vers la page publique du laboratoire
    response.sendRedirect(request.getContextPath() + "/public");
%>

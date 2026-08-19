<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>

<jcr:sql
        var="_css_"
        sql="SELECT * FROM [jnt:file] As node WHERE ISDESCENDANTNODE (node, '${renderContext.site.path}/files/css')"
/>

<link rel="stylesheet" type="text/css" href="/modules/bootstrap4-core/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/modules/industrial/css/style.css">
<c:forEach items="${_css_.nodes}" var="node">
    <c:url var="customCSSUrl" value="${node.url}"/>
    <c:if test="${fn:endsWith(customCSSUrl, '.css')}">
        <link rel="stylesheet" type="text/css" href="${customCSSUrl}">
    </c:if>
</c:forEach>

<template:include view="default"/>

<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%-- The site's resources for a content rendered without a page of its own: the preview of a content
     folder's item, or a form edited in the Page Builder from its folder. The platform's content template
     renders the site node with this view and places what it declares in the document head, so such a
     content gets the same stylesheets as the pages (see template.industrial.jsp).
     The page head's animate.min.css, owl.carousel.min.css and jquery.fancybox.min.css are left out on
     purpose: they dress animations, carousels and lightboxes, none of which a form has. Everything a
     form's look depends on is here, the site's own contributed CSS included. --%>
<%-- A literal link, as in the page template: the resources attribute is comma-separated and would split the URL --%>
<link href="https://fonts.googleapis.com/css?family=Montserrat:400,700|Oxygen:400,700" rel="stylesheet">
<template:addResources type="css" resources="bootstrap.min.css"/>
<template:addResources type="css" resources="font-awesome.min.css"/>
<template:addResources type="css" resources="style.css"/>
<template:addResources type="css" resources="style.patch.css"/>
<template:addResources type="css" resources="formidable.css"/>
<%-- Last, as in the page template: its position there is deliberate --%>
<template:addResources type="css" resources="ionicons.4.6.3.min.css" media="screen"/>

<%-- The site's own stylesheets, as the page template and the content-manager view load them: both are
     site-scoped queries, so they need no page. --%>
<jcr:sql
        var="_css_"
        sql="SELECT * FROM [jnt:file] As node WHERE ISDESCENDANTNODE (node, '${renderContext.site.path}/files/css')"
/>
<c:forEach items="${_css_.nodes}" var="node">
    <c:url var="customCSSUrl" value="${node.url}"/>
    <c:if test="${fn:endsWith(customCSSUrl, '.css')}">
        <template:addResources type="css" resources="${customCSSUrl}"/>
    </c:if>
</c:forEach>

<jcr:sql
        var="_css_content_"
        sql="SELECT * FROM [tint:css] As node WHERE ISDESCENDANTNODE (node, '${renderContext.site.path}/contents')"
/>
<c:forEach items="${_css_content_.nodes}" var="node">
    <template:module node="${node}" nodeTypes="tint:css"/>
</c:forEach>

<c:if test="${renderContext.editMode}">
    <template:addResources type="css" resources="edit.css"/>
</c:if>

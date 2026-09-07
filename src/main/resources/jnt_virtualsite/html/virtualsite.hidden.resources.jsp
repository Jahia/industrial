<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%-- The site's resources for a content rendered without a page of its own: the preview of a content
     folder's item, or a form edited in the Page Builder from its folder. The platform's content template
     renders the site node with this view and places what it declares in the document head, so such a
     content gets the same stylesheets as the pages (see template.industrial.jsp). --%>
<%-- A literal link, as in the page template: the resources attribute is comma-separated and would split the URL --%>
<link href="https://fonts.googleapis.com/css?family=Montserrat:400,700|Oxygen:400,700" rel="stylesheet">
<template:addResources type="css" resources="bootstrap.min.css"/>
<template:addResources type="css" resources="font-awesome.min.css"/>
<template:addResources type="css" resources="style.css"/>
<template:addResources type="css" resources="style.patch.css"/>
<template:addResources type="css" resources="ionicons.4.6.3.min.css" media="screen"/>
<template:addResources type="css" resources="formidable.css"/>
<c:if test="${renderContext.editMode}">
    <template:addResources type="css" resources="edit.css"/>
</c:if>

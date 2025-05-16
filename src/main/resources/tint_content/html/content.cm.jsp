<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
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

<%--<fmt:setLocale value="${currentResource.locale.language}" scope="session"/>--%>

<%--<c:set var="title" value="${currentNode.properties['jcr:title'].string}"/>--%>
<%--<c:set var="titleEscaped" value="${not empty title ? fn:escapeXml(title) : fn:escapeXml(currentNode.name)}"/>--%>

<%--<c:set var="teaser" value="${currentNode.properties['teaser'].string}"/>--%>
<%--<c:set var="body" value="${currentNode.properties['body'].string}"/>--%>

<%--<fmt:message key="label.date.at" var="at"/>--%>
<%--<c:set var="date" value="${currentNode.properties['date'].date}"/>--%>
<%--<fmt:formatDate value="${date.time}" pattern="dd MMM yyyy" var="formatedDate"/>--%>
<%--<fmt:formatDate value="${date.time}" pattern="HH:ss" var="formatedTime"/>--%>
<%--<c:if test="${not empty formatedDate && formatedTime != '00:00'}">--%>
<%--    <c:set var="formatedDate" value="${formatedDate} ${at} ${formatedTime}"/>--%>
<%--</c:if>--%>

<%--<c:set var="imageNode" value="${currentNode.properties['images'][0].node}"/>--%>
<%--<template:addCacheDependency node="${imageNode}"/>--%>

<%--<c:set var="width" value="${not empty currentResource.moduleParams.mediaWidth ? currentResource.moduleParams.mediaWidth : '1920'}"/>--%>
<%--<c:set var="height" value="${currentResource.moduleParams.mediaHeight}"/>--%>
<%--<c:set var="scale" value="${currentResource.moduleParams.mediaScale}"/>--%>
<%--<c:set var="quality" value="${currentResource.moduleParams.mediaQuality}"/>--%>

<%--<c:catch var ="getUrlException">--%>
<%--    <c:set var="imageURL" value="${imageNode.getUrl(['width:'.concat(width),'height:'.concat(height),'scale:'.concat(scale),'quality:'.concat(quality)])}"/>--%>
<%--</c:catch>--%>
<%--<c:if test = "${getUrlException != null}">--%>
<%--    <c:set var="imageURL" value="${imageNode.getUrl()}"/>--%>
<%--</c:if>--%>


<%--<div class="inner-page">--%>
<%--    <div class="slider-item" style="background-image: url('${imageURL}');">--%>
<%--    </div>--%>
<%--</div>--%>

<%--<section class="pb-5">--%>
<%--    <div class="container container-content bg-white">--%>
<%--        <div class="row justify-content-center">--%>
<%--            <div class="col-md-10 mb-5">--%>
<%--                <h1>${titleEscaped}</h1>--%>
<%--                <c:if test = "${not empty formatedDate}">--%>
<%--                <div class="border-top border-bottom border-secondary pt-4 pb-4">--%>
<%--                    <span class="ion-md-calendar mr-2"></span>--%>
<%--                    <fmt:message key="label.date.createdAt"/> : ${formatedDate}--%>
<%--                </div>--%>
<%--                </c:if>--%>
<%--            </div>--%>
<%--        </div>--%>

<%--        <div class="row row-teaser justify-content-center">--%>
<%--            <div class="col-md-10">--%>
<%--                <div class="lead">--%>
<%--                    ${teaser}--%>
<%--                </div>--%>
<%--            </div>--%>
<%--        </div>--%>

<%--        <div class="row row-article justify-content-center">--%>
<%--            <div class="col-md-10">--%>
<%--                ${body}--%>
<%--            </div>--%>
<%--        </div>--%>
<%--    </div>--%>
<%--</section>--%>
